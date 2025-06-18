//
//  DiseaseDetailView.swift
//  PlantDiseaseDetector
//
//  Created by Chairal Octavyanz on 15/06/25.
//

import Foundation
import SwiftUI

struct DiseaseDetailView: View {
    let disease: Disease

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                ZStack(alignment: .bottomLeading){
                    Image(disease.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .clipped()
                    
                    LinearGradient(
                        gradient: Gradient(colors: [Color.black.opacity(0.6), .clear]),
                        startPoint: .bottom,
                        endPoint: .top
                    )
                    .frame(height: 300)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        
                        Text(disease.name)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color.background)
                        
                        Text(disease.overview)
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(Color.background)
                                  
                    }
                    .padding(20)
                }
                
                VStack(alignment: .leading, spacing: 30) {
                    SectionView(title: "Symptoms", content: disease.symptoms)
                    SectionView(title: "Causes", content: disease.causes)
                    SectionView(title: "Treatments", content: disease.treatments)
                }
                .padding(20)
                
                Spacer().frame(height: 30)
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
        
    }
}

struct SectionView: View {
    let title: String
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color.font)
            Text(content)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Color.font)
        }
    }
}


#Preview {
    DiseaseDetailView(disease: Disease(
        id: .rust,
        name: "Rust",
        imageName: "image-rust",
        overview: "A fungal disease that primarily affects leaves, forming characteristic rust-colored pustules.",
        symptoms: "Tiny, powdery orange, yellow, or brown spots that often appear in clusters on the underside of leaves. Infected leaves may curl, distort, and fall off prematurely. In advanced stages, plants look thin and stressed.",
        causes: "Caused by rust fungi such as Puccinia and Uromyces. Spores spread via wind and water. Infection is favored by damp environments with warm days and cool nights.",
        treatments: """
        • Cultural: Prune affected areas; reduce humidity; water at the soil level.
        • Chemical: Apply fungicides containing mancozeb or chlorothalonil.
        • Organic: Use sulfur dust, neem oil, or baking soda sprays.
        """    ))
}

