//
//  ContentView.swift
//  PlantDiseaseDetector
//
//  Created by Chairal Octavyanz on 04/06/25.
//

import SwiftUI
import SwiftData
import PhotosUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    
    @Environment(\.modelContext) private var context
    
    @State private var showTakePict = false
    @State private var showUploadPhoto = false
    @State private var isAddMenuPresented = false
    
    @State private var selectedItem: PhotosPickerItem? // holds the selected photo item
    @State private var selectedImage: UIImage? // holds the loaded image
    @State private var showingCamera = false // control camera sheet visability
    
    @State private var showPreview = false
    @State private var historyList: [History] = []

    
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Main content & navbar
                VStack(spacing: 0) {
                    Group {
                        if selectedTab == 0 {
                            AnyView(HomeView(historyList: $historyList))
                        } else if selectedTab == 1 {
                            AnyView(LibraryView())
                        } else {
                            AnyView(EmptyView())
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white)
                    .ignoresSafeArea(.all, edges: .bottom)
                    Spacer() // Push content to top
                    
                    // Custom Bottom Navigation Bar
                    HStack {
                        Spacer()
                        Button(action: {
                            selectedTab = 0
                        }) {
                            Image(selectedTab == 0 ? "logo-home-bold" : "logo-home-thin")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Spacer()
                        Button(action: {
                            selectedTab = 1
                        }) {
                            Image(selectedTab == 1 ? "logo-library-bold" : "logo-library-thin")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    .frame(height: 70)
                    .frame(maxWidth: .infinity)
                    .background(Color("color-NavbarGreen"))
                    .ignoresSafeArea(.all, edges: .bottom)

                }
                
                // FAB Layer (selalu di atas semua)
                Group {
                    if selectedTab == 0 {
                        AddPhotoFAB(
                            onTakePict: {
                                showTakePict = true
                            }
                        )
                    }
                }
            }
            .navigationDestination(isPresented: $showTakePict) {
                CameraView(image: $selectedImage) { confirmedImage in
                    let newHistory = History(
                        name: "New Scan",
                        image: saveImageToDisk(image: confirmedImage),
                        date: Date(),
                        disease1: "rust",
                        disease2: "powdery",
                        disease3: "sunburn"
                    )
                    historyList.append(newHistory) // ✅ Tambah ke list
                }
            }

            .navigationDestination(isPresented: $showPreview) {
                PreviewPhotoView(
                    image: $selectedImage,
                    onReupload: {
                        selectedImage = nil
                        showTakePict = true
                        showPreview = false
                    },
                    onUse: {
                        if let img = selectedImage {
                            let newHistory = History(
                                name: "New Scan",
                                image: saveImageToDisk(image: img), // helper function
                                date: Date(),
                                disease1: "rust", disease2: "powdery", disease3: "sunburn"
                            )
                            historyList.append(newHistory)
                        }
                        showPreview = false
                    }
                )
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
    }
}

#Preview {
    ContentView()
}



