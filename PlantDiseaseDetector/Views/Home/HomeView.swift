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
    @State private var noLeavesAlert: Bool = false
    
    private let plantDiseaseService: PlantDiseaseService = PlantDiseaseService()
    
    private let leafDetectorService: LeafDetectorService = {
        do {
            return try LeafDetectorService()
        } catch {
            fatalError("Failed to load LeafDetectionService model: \(error.localizedDescription)")
        }
    }()
    
    @Environment(\.modelContext) var context
    @Query(filter: #Predicate<PlantDiagnosis> { _ in true },
           sort: [SortDescriptor(\PlantDiagnosis.createdAt, order: .reverse)]) var plantDiagnosisList: [PlantDiagnosis]
    
    func create(_ plantDiagnosis: PlantDiagnosis) -> PlantDiagnosis? {
        do {
            context.insert(plantDiagnosis)
            try context.save()
            
            print("Plant record created successfully!")
            return plantDiagnosis
        } catch {
            print("Error creating parking record: \(error)")
        }
        return nil
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
        
        if targetProbability < 0.6 {
            for (disease, probability) in plantDiseaseOutput.targetProbability {
                
                if disease == plantDiseaseOutput.target {
                    continue
                }
                
                if targetProbability - probability <= 0.25 {
                    if let disease = DiseaseEnum(rawValue: disease) {
                        diseases.append(DiseaseWrapper(
                            disease: disease,
                            probability: probability
                        ))
                    }
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
    
    @State private var newPlantDiagnosis: PlantDiagnosis? = nil
    @State private var navigateToNewPlantDiagnosis: Bool = false
    
    func getPlantDisease() {
        guard let image = selectedImage else {
            return
        }
        
        /// object detection; check whether a leaf is present in the provided photo
        guard let detectedObjects = leafDetectorService.detectLeaf(in: image) else {
            print("❌ FAILED: 'leafDetectorService.detectLeaf(in:)' returned nil. This likely means there was an internal error in your LeafDetectorService model or processing. Exiting.")
            return
        }
        
        guard !detectedObjects.isEmpty else {
            print("no leaves detected")
            noLeavesAlert = true
            return
        }
        
        let classifyOutput = plantDiseaseService.classify(image: image)
        
        if let plantDiseaseOutput = classifyOutput.prediction {
            print("Plant Disease Output: \(plantDiseaseOutput)")
            
            newPlantDiagnosis = create(plantDiseaseOutputToPlantDiagnosis(
                plantDiseaseOutput: plantDiseaseOutput,
                photo: image
            ))
            
            navigateToNewPlantDiagnosis = true
        }
    }
    
    var body: some View{
        ZStack {
            Color("color-BgPage").ignoresSafeArea()
            
            NavigationLink(
                destination: Group {
                    if let diagnosis = newPlantDiagnosis {
                        PlantDiagnosisView(plantDiagnosis: diagnosis)
                    } else {
                        EmptyView()
                    }
                },
                isActive: $navigateToNewPlantDiagnosis,
                label: { EmptyView() }
            )
            
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
        .fullScreenCover(isPresented: $showCamera, onDismiss: {
            if(self.selectedImage != nil){ getPlantDisease() }
        }) {
            CameraView(image: $selectedImage) { confirmedImage in
                self.selectedImage = confirmedImage
            }.ignoresSafeArea()
        }
        .alert("No plant detected in the picture!", isPresented: $noLeavesAlert) {
            Button("Go to Clinic", role: .cancel) {
                noLeavesAlert = false
            }
            Button("Retake", role: .destructive) {
                showCamera = true
            }
        } message: {
            Text("Do you want to re-upload? ")
        }
    }
}

#Preview {
    ContentView()
}
