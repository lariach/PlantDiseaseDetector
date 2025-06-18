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
                    if plantDiagnosis.disease == .healthy {
                        VStack(alignment: .leading, spacing: 10) {
                            
                            HStack {
                                Image("plant-healthy")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .padding(.trailing, 5)
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("No major issues detected")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color.font)
                                    
                                    Text("Your plant is healthy & well-loved")
                                        .font(.subheadline)
                                        .foregroundColor(Color.font)
                                }
                                .padding(.trailing, 8)
                            }
                            
                            Spacer().frame(height: 5)
                            
                            Text("Hey, you are doing a great job!")
                                .font(.system(size: 22, weight: .semibold))
                                .fontWeight(.semibold)
                                .foregroundColor(Color("color-font-green"))
                                .padding(.leading, 10)
                            
                            Text("You can still follow common practices to prevent your plant from contracting any diseases.")
                                .font(.subheadline)
                                .foregroundColor(Color.font)
                                .padding(.leading, 10)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Healthy Soil")
                                    .font(.headline)
                                
                                Text("Ensure soil drains well and contains organic matter. Overly wet soil can lead to root rot and fungal diseases. Adding compost and fertilizer improves both structure and nutrients, helping plants resist disease.")
                                
                                Rectangle()
                                    .frame(width: .infinity, height: 1)
                                    .foregroundStyle(Color.font)
                                    .opacity(0.2)
                                    .padding(.vertical, 10)
                                
                                Text("Sanitation")
                                    .font(.headline)
                                
                                Text("Remove diseased leaves, stems, or fruit promptly and dispose of them properly—never compost them, as pathogens can survive and reinfect healthy plants.")
                                
                                Rectangle()
                                    .frame(width: .infinity, height: 1)
                                    .foregroundStyle(Color.font)
                                    .opacity(0.2)
                                    .padding(.vertical, 10)
                                
                                
                                Text("Proper Watering")
                                    .font(.headline)
                                
                                Text("Water at the base of plants instead of overhead to avoid wet leaves. Morning watering is best so moisture can dry quickly, lowering the risk of fungal and bacterial diseases.")
                                
                                Rectangle()
                                    .frame(width: .infinity, height: 1)
                                    .foregroundStyle(Color.font)
                                    .opacity(0.2)
                                    .padding(.vertical, 10)
                                
                                
                                Text("Good Air Circulation")
                                    .font(.headline)
                                
                                Text("Space plants appropriately and prune overgrown areas to improve airflow. Dry leaves are less likely to develop fungal issues.")
                                
                                Rectangle()
                                    .frame(width: .infinity, height: 1)
                                    .foregroundStyle(Color.font)
                                    .opacity(0.2)
                                    .padding(.vertical, 10)
                                
                                
                                Text("Monitoring & Early Action")
                                    .font(.headline)
                                
                                Text("Inspect your plants regularly. At the first sign of disease, remove affected parts and, if needed, apply organic treatments like neem oil or beneficial microbes.")
                                
                                Spacer().frame(height: 10)
                            }
                            .padding(20)
                            .font(.subheadline)
                            .background(Color.white)
                            .foregroundColor(Color.font)
                            .frame(maxWidth: .infinity)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.clear)
                            )
                            .padding(.horizontal, 5)
                            .padding(.top, 10)
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 10) {
                            
                            HStack {
                                Image("plant-afflicted")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .padding(.trailing, 5)
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Your plant is afflicted")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color.font)
                                    
                                    Text("Get to know your plant’s issue better for more effective treatment.")
                                        .font(.subheadline)
                                        .foregroundColor(Color.font)
                                }
                                .padding(.trailing, 8)
                            }
                            
                            Spacer().frame(height: 5)
                            
                            Text("We almost certain that the likely issue:")
                                .font(.system(size: 22, weight: .semibold))
                                .fontWeight(.semibold)
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
                                Text("Other possible issues:")
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundColor(Color("color-font-green"))
                                    .padding(.leading, 10)
                                
                                
                                LazyVGrid(columns: columns, spacing: 6) {
                                    
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
                }
                .padding(20)
                
            }
        }
        .background(Color("color-BgPage"))
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Disease Detail")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("color-font-green"))
            }
        }
        .toolbarBackground(Color("color-BgPage"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear() {
            print(plantDiagnosis.diseases)
        }
    }
}

#Preview {
    PlantDiagnosisView(plantDiagnosis: PlantDiagnosis(
        disease: .healthy,
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
