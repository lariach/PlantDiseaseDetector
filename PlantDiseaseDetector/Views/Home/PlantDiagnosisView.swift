//
//  PlantDiagnosisView.swift
//  PlantDiseaseDetector
//
//  Created by Rico Tandrio on 18/06/25.
//

import SwiftUI

struct PlantDiagnosisView: View {
    let plantDiagnosis: PlantDiagnosis
    
    let columns = [GridItem(.flexible(), spacing: 16), GridItem(.flexible())]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Gambar header
                ZStack(alignment: .bottomLeading){
                    Image(uiImage: plantDiagnosis.getImage())
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity ,maxHeight: 350)
                        .clipped()
                    
                    LinearGradient(
                        gradient: Gradient(colors: [Color.black.opacity(0.6), .clear]),
                        startPoint: .bottom,
                        endPoint: .top
                    )
                    .frame(height: 300)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack{
                            Image(systemName: "clock")
                            Text(plantDiagnosis.createdAt.formatted(date: .abbreviated, time: .shortened))
                        }
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(.white)
                    }
                    .padding(20)
                }
                
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("The most likely diagnosis of your plant is")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color("color-font-green"))
                            .padding(.leading, 10)
                        
                        HStack {
                            Spacer()
                            
                            if let disease = diseaseDict[plantDiagnosis.disease] {
                                DiseaseLibraryCard(
                                    disease: disease,
                                    probability: plantDiagnosis.probability,
                                    cardSize: CGSize(width: 353, height: 300)
                                )
                            }
                            
                            Spacer()
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 10)  {
                        if !plantDiagnosis.diseases.isEmpty {
                            Text("another possible diagnosis...")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(Color("color-font-green"))
                                .padding(.leading, 10)
                            
                            
                            LazyVGrid(columns: columns, spacing: 16) {
                                
                                ForEach(plantDiagnosis.diseases, id: \.disease) { plantDiag in
                                    if let disease = diseaseDict[plantDiag.disease] {
                                        DiseaseLibraryCard(
                                            disease: disease,
                                            probability: plantDiag.probability,
                                            cardSize: CGSize(width: 170, height: 170)
                                        )
                                    }
                                }

                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(20)
                
            }
        }
        .background(Color("color-BgPage"))
        .navigationTitle("Diagnosis Result")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear() {
            print(plantDiagnosis.diseases)
        }
    }
}

#Preview {
    PlantDiagnosisView(plantDiagnosis: PlantDiagnosis(
        disease: .rust,
        probability: 0.95,
        diseases: [
            DiseaseWrapper(disease: .rust, probability: 0.35),
            DiseaseWrapper(disease: .powderyMildew, probability: 0.15),
            DiseaseWrapper(disease: .healthy, probability: 0.15),
            DiseaseWrapper(disease: .aphid, probability: 0.15),
            DiseaseWrapper(disease: .leafSpot, probability: 0.15)
        ],
        photo: UIImage(named: "image-rust") ?? UIImage()
    ))
}
