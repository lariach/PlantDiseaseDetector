//
//  HomeView.swift
//  PlantDiseaseDetector
//
//  Created by Chairal Octavyanz on 04/06/25.
//

import SwiftUI
import PhotosUI

struct HomeView: View{

    @State private var selectedImage: UIImage? {
        didSet {
            if let image = selectedImage {
                
            }
        }
    }
    
    @State private var showingCamera = false
    @State private var showTakePict = false
    
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
                
                Section(header: Text("History").foregroundColor(Color("color-font-green")).font(.title2).bold()) {
                    if historyList.isEmpty {
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
                                ForEach(historyList) { history in
                                    HistoryCardView(history: history)
                                        .padding(.horizontal, 5)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            
            AddPhotoFAB(
                onTakePict: {
                    showTakePict = true
                }
            )

        }
        .navigationDestination(isPresented: $showTakePict) {
            CameraView(image: $selectedImage)
        }
    }
}

#Preview {
    ContentView()
}
