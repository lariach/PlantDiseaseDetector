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
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading) {
                    Text("Plant Disease Library")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(Color("color-font-green"))
                        .padding(.top, 30)
                    
                    Text("Discover and learn about common plant issues")
                        .font(.subheadline)
                        .foregroundColor(Color("color-font-green"))
                }
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(diseaseList) { disease in
                            DiseaseLibraryCard(disease: disease)
                        }
                    }
                }
            }
            .background(Color("color-BgPage"))
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    ContentView()
}
