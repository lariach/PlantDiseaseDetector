//
//  PreviewPhotoView.swift
//  PlantDiseaseDetector
//
//  Created by Chairal Octavyanz on 16/06/25.
//

import Foundation
import SwiftUI

struct PreviewPhotoView: View {
    @Binding var image: UIImage?
    var onReupload: () -> Void
    var onUse: () -> Void
    
    var body: some View {
        VStack {
            Text("Confirm/Retake Photo")
                .font(.headline)
                .padding(.top)
            
            Spacer()
            
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            
            Spacer()
            
            HStack {
                Button("Reupload") {
                    onReupload() // ⬅️ Panggil closure
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .cornerRadius(10)
                
                Spacer()
                
                Button("Use Picture") {
                    onUse() // ⬅️ Panggil closure
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
            }
            .padding(.horizontal)
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

//#Preview {
//    PreviewPhotoView(image: <#T##UIImage?#>, onReupload: <#T##() -> Void#>, onUse: <#T##() -> Void#>)
//}
