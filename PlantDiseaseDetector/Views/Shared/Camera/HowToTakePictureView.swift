//
//  HowToTakePictureView.swift
//  PlantDiseaseDetector
//
//  Created by Chairal Octavyanz on 15/06/25.
//

import Foundation
import SwiftUI

struct HowToTakePictureView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color("color-BgPage")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("How to Take Photo?")
                            .font(.title3).bold()
                            .foregroundColor(Color("color-font-green"))
                        Spacer()
                        Button("Done") {
                            dismiss()
                        }
                        .foregroundColor(Color("color-font-green"))
                        .padding(.trailing, 10)
                    }
                    
                    Image("image-howto")
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("• Make sure the affected part fits inside the frame.")
                        Text("• Avoid harsh shadows and artificial lighting.")
                        Text("• Avoid messy or busy backgrounds.")
                        Text("• Hold your phone still to avoid blurriness.")
                    }
                    .padding(20)
                    .font(.subheadline)
                    .foregroundColor(Color("color-font-green"))
                    .frame(maxWidth: .infinity)
                    .background(Color(.white))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.black, lineWidth: 1)
                    )
                    .padding(.horizontal, 5)
                }
                .padding()
            }
        }
    }
}

#Preview {
    HowToTakePictureView()
}
