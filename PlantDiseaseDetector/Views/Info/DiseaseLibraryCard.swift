//
//  DiseaseLibraryCard.swift
//  PlantDiseaseDetector
//
//  Created by Chairal Octavyanz on 15/06/25.
//

import SwiftUI
import Foundation

struct DiseaseLibraryCard: View {
    let disease: Disease

    var body: some View {
        NavigationLink(destination: DiseaseDetailView(disease: disease)) {
            ZStack(alignment: .bottomLeading) {
                Image(disease.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 180, height: 170)
                    .clipped()
                    .cornerRadius(16)

                LinearGradient(
                    gradient: Gradient(colors: [Color.black.opacity(0.6), .clear]),
                    startPoint: .bottom,
                    endPoint: .top
                )
                .frame(height: 60)
                .cornerRadius(16)

                Text(disease.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.leading, 12)
                    .padding(.bottom, 12)
            }
            .frame(width: 180, height: 170)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle()) // agar tidak ada efek biru klik
    }
}

#Preview {
    DiseaseLibraryCard(disease: diseaseList[0])
}


