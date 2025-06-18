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
            Color.background.ignoresSafeArea()
            
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
                        HStack {
                            Image("photo-how0")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                            
                            Text("Keep the affected part centered and fully visible in the frame.")
                        }
                        
                        HStack {
                            Image("photo-how1")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                            
                            Text("Ensure the background is clear—no other plants or distracting objects.")
                        }
                        
                        HStack {
                            Image("photo-how2")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                            
                            Text("Avoid harsh shadows or artificial lighting that may alter color.")
                        }
                        
                        HStack {
                            Image("photo-how3")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                            
                            Text("Hold your device steady to prevent blurry images.")
                        }
                    }
                    .padding(20)
                    .font(.subheadline)
                    .background(Color.white)
                    .foregroundColor(Color.font)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.font, lineWidth: 1)
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
