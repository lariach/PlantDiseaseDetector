//
//  InfoView.swift
//  PlantDiseaseDetector
//
//  Created by Chairal Octavyanz on 04/06/25.
//

import SwiftUI

struct LibraryView: View {
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Plant Disease Library")
                        .font(.title)
                        .bold()
                        .foregroundColor(Color("color-font-green"))
                        .padding(.horizontal)
                        .padding(.top, 40)
                    
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(diseaseList) { disease in
                            DiseaseLibraryCard(disease: disease)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
            }
            .background(Color("color-BgPage"))
//            .navigationTitle("Plant Disease Library")
        }
    }
}

#Preview {
    LibraryView()
}
