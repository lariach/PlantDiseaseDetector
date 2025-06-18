//
//  HomeView.swift
//  PlantDiseaseDetector
//
//  Created by Chairal Octavyanz on 04/06/25.
//

import SwiftUI
import PhotosUI
import SwiftData

struct HomeView: View {

    @State private var selectedImage: UIImage?
    
    @State private var showCamera: Bool = false
    @State private var plantDiseaseName: String?
    @State private var plantDiseaseProbability: Double?
    
    private let plantDiseaseService: PlantDiseaseService = PlantDiseaseService()
    
    @Environment(\.modelContext) var context
    
    @Query(filter: #Predicate<PlantDiagnosis> { _ in true },
           sort: [SortDescriptor(\PlantDiagnosis.createdAt, order: .reverse)]) var plantDiagnosisList: [PlantDiagnosis]
    
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
        
        let targetDisease = plantDiseaseOutput.target
        let targetProbability = plantDiseaseOutput.targetProbability[targetDisease] ?? 0.0
        
        if targetProbability < 0.9 {
            for (disease, probability) in plantDiseaseOutput.targetProbability {
                
                if disease == plantDiseaseOutput.target {
                    continue
                }
                
                if let disease = DiseaseEnum(rawValue: disease) {
                    diseases.append(DiseaseWrapper(
                        disease: disease,
                        probability: probability
                    ))
                }
            }
        }

        return PlantDiagnosis(
            disease: DiseaseEnum(rawValue: targetDisease) ?? .rust,
            probability: targetProbability,
            diseases: diseases,
            photo: photo
        )
    }
    
    func getPlantDisease() {
        guard let image = selectedImage else { return }
        
        let output = plantDiseaseService.classify(image: image)
        
        if let plantDiseaseOutput = output.prediction {
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
                            VStack(spacing: 10) {
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
