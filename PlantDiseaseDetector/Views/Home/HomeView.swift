//
//  HomeView.swift
//  PlantDiseaseDetector
//
//  Created by Chairal Octavyanz on 04/06/25.
//

import SwiftUI
import PhotosUI

struct HomeView: View{
    @State private var selectedItem: PhotosPickerItem? // holds the selected photo item
    @State private var selectedImage: UIImage? // holds the loaded image
    @State private var showingCamera = false // control camera sheet visability
    
    var body: some View{
        ZStack {
            Color("color-BgPage")
                .ignoresSafeArea()
            
            VStack(alignment: .leading) {
                Text("Plant Diagnosing")
                    .font(.title)
                    .bold()
                    .foregroundColor(Color("color-font-green"))
                    .padding(.horizontal)
                    .padding(.top, 40)
                
                if historyList.isEmpty {
                    VStack {
                        Text("No history found.")
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(historyList) { history in
                                HistoryCardView(history: history)
                                    .padding(.horizontal, 4)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
