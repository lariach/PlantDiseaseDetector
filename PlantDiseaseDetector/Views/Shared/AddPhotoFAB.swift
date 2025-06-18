//
//  AddPhotoFAB.swift
//  PlantDiseaseDetector
//
//  Created by Chairal Octavyanz on 13/06/25.
//

import Foundation
import SwiftUI
import PhotosUI

struct AddPhotoFAB: View {
    @State private var showMenu = false
    var onTakePict: () -> Void
    
    @State private var selectedItem: PhotosPickerItem? // holds the selected photo item
    @State private var selectedImage: UIImage? // holds the loaded image
    @State private var showingCamera = false // control camera sheet visability
    
    var body: some View {
        ZStack {
            // Floating button utama (+)
            Button(action: {
                onTakePict()
                showMenu = false
                
            }) {
                Image("logo-camera")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Color("color-FABGreen"))
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .padding(.bottom, 120)
            .padding(.trailing, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            
        }
    }
}

#Preview {
    AddPhotoFAB(
        onTakePict: {}
    )
}
