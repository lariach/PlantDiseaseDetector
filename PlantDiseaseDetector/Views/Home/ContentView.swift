//
//  ContentView.swift
//  PlantDiseaseDetector
//
//  Created by Chairal Octavyanz on 04/06/25.
//

import SwiftUI
import SwiftData
import PhotosUI

enum Tab {
    case home, library
}

struct TabBarItem: View {
    var tab: Tab
    var activeImage: String
    var inactiveImage: String
    
    @Binding var selectedTab: Tab
    
    var body: some View {
        Button(action: {
            selectedTab = tab
        }) {
            Image(selectedTab == tab ? activeImage : inactiveImage)
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .foregroundColor(.white)
        }
    }
}

struct ContentView: View {
    @State private var selectedTab: Tab = .home
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                VStack(spacing: 0) {
                    Group {
                        switch selectedTab {
                        case .home:
                            HomeView()
                        case .library:
                            LibraryView()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white)
                    .ignoresSafeArea(.all, edges: .bottom)
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        TabBarItem(
                            tab: .home,
                            activeImage: "logo-home-bold",
                            inactiveImage: "logo-home-thin",
                            selectedTab: $selectedTab
                        )
                        .frame(maxWidth: .infinity)
                        
                        TabBarItem(
                            tab: .library,
                            activeImage: "logo-library-bold",
                            inactiveImage: "logo-library-thin",
                            selectedTab: $selectedTab
                        )
                        .frame(maxWidth: .infinity)
                        
                        Spacer()
                    }
                    .frame(height: 70)
                    .frame(maxWidth: .infinity)
                    .background(Color("color-NavbarGreen"))
                    .ignoresSafeArea(.all, edges: .bottom)

                }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
    }
}

#Preview {
    ContentView()
}



