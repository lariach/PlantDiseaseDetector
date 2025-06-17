//
//  HomeView.swift
//  PlantDiseaseDetector
//
//  Created by Chairal Octavyanz on 04/06/25.
//

import SwiftUI
import PhotosUI
import SwiftData

struct PlantDiagnosisView: View {
    let plantDiagnosis: PlantDiagnosis
    
    var body: some View {
        Text("Hello, World!")
    }
}

struct PlantDiagnosisCardView: View {
    let plantDiagnosis: PlantDiagnosis
    
    let onDelete: () -> Void
    
    var body: some View {
        NavigationLink(destination: PlantDiagnosisView(plantDiagnosis: plantDiagnosis)) {
            
            HStack{
                
                Image(uiImage: plantDiagnosis.getImage())
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
                    .frame(width: 120, height: 120)
                    .clipped()
                    .cornerRadius(12)
                    .padding(10)
                

                VStack (alignment: .leading, spacing: 5){
                    
                    Text(plantDiagnosis.disease.rawValue)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color("color-font-green"))
                    
                    HStack {
                        Image(systemName: "clock")
                            .font(.system(size: 14))
                        
                        Text(
                            plantDiagnosis.createdAt
                                .formatted(date: .abbreviated, time: .shortened)
                        )
                        .font(.caption)
                    }
                    .foregroundColor(.black)
                
                
                    Spacer()
                    
                    Button {
                        onDelete()
                    } label: {
                        HStack {
                            Spacer()
                            
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                                .font(.system(size: 20))
                            
                        }
                        .padding(.bottom, 15)
                        .padding(.trailing, 10)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 20)
                
                Spacer()
            }
            .frame(maxWidth: 353, maxHeight: 140)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 4)
        }
    }
}

struct HomeView: View {

    @State private var selectedImage: UIImage?
    
    @State private var showCamera: Bool = false
    @State private var plantDiseaseName: String?
    @State private var plantDiseaseProbability: Double?
    
    private let plantDiseaseService: PlantDiseaseService = PlantDiseaseService()
    
    
    @Environment(\.modelContext) var context
    
    @Query var plantDiagnosisList: [PlantDiagnosis]
    
    func create(_ plantDiagnosis: PlantDiagnosis) {
        do {
            context.insert(plantDiagnosis)
            try context.save()
            
            print("Plant record created successfully!")
        } catch {
            print("Error creating parking record: \(error)")
        }
    }
    
    func delete(_ plantDiagnosis: PlantDiagnosis) {
        do {
            context.delete(plantDiagnosis)
            try context.save()
            print("Plant diagnosis deleted successfully!")
        } catch {
            print("Error deleting plant diagnosis: \(error)")
        }
    }
    
    func plantDiseaseOutputToPlantDiagnosis(plantDiseaseOutput: PlantDiseaseOutput, photo: UIImage) -> PlantDiagnosis {
        var diseases: [DiseaseWrapper] = []
        
        for (disease, probability) in plantDiseaseOutput.targetProbability {
            diseases.append(DiseaseWrapper(
                disease: DiseaseEnum(rawValue: disease) ?? .rust,
                probability: probability
            ))
        }
        
        return PlantDiagnosis(
            disease: DiseaseEnum(rawValue: plantDiseaseOutput.target) ?? .rust,
            probability: plantDiseaseOutput.targetProbability[plantDiseaseOutput.target] ?? 0.0,
            diseases: diseases,
            photo: photo
        )
    }
    
    func getPlantDisease() {
        guard let image = selectedImage else { return }
        
        let output = plantDiseaseService.classify(image: image)
        
        if let plantDiseaseOutput = output.prediction {
            print("Plant Disease Output: \(plantDiseaseOutput)")
            
            create(plantDiseaseOutputToPlantDiagnosis(
                plantDiseaseOutput: plantDiseaseOutput,
                photo: image
            ))
        }
    }
    
    var body: some View{
        ZStack {
            Color("color-BgPage").ignoresSafeArea()
            
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    
                    Text("Plant Clinic")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(Color("color-font-green"))
                        .padding(.top, 30)
                    
                    Text("Like a personal plant doctor—in your pocket!")
                        .font(.subheadline)
                        .foregroundColor(Color("color-font-green"))
                }
                
                Spacer().frame(height: 20)
                
                Section(header: Text("History")
                    .foregroundColor(Color("color-font-green"))
                    .font(.title2)
                    .bold()
                ) {
                    if plantDiagnosisList.isEmpty {
                        
                        VStack {
                            Spacer()
                            
                            Text("No disease identified")
                                .font(.headline)
                                .foregroundColor(Color("color-font-green"))
                            
                            Text("Snap or upload a picture of your plant, and we’ll diagnose its issue")
                                .font(.subheadline)
                                .foregroundColor(Color("color-font-green"))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                    } else {
                        
                        ScrollView {
                            VStack(spacing: 16) {
                                ForEach(plantDiagnosisList) { diagnosis in
                                    PlantDiagnosisCardView(
                                        plantDiagnosis: diagnosis,
                                        onDelete: {
                                            delete(diagnosis)
                                        }
                                    )
                                }
                            }
                        }
                        
                    }
                }
            }
            .padding(.horizontal, 20)
            
            AddPhotoFAB(
                onTakePict: {
                    showCamera = true
                }
            )

        }
        .fullScreenCover(isPresented: $showCamera, onDismiss: getPlantDisease) {
            CameraView(image: $selectedImage)
        }
    }
}

#Preview {
    ContentView()
}
