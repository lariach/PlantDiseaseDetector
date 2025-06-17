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
    var onTakePict: () -> Void

    var body: some View {
        ZStack {
            Button(action: {
                onTakePict()
            }) {
                Image("logo-camera")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Color("color-FABGreen"))
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .padding(.bottom, 30)
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
