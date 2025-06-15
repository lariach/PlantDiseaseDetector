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
        
        Text("ini home page")

        
    }
}

#Preview {
    HomeView()
}
