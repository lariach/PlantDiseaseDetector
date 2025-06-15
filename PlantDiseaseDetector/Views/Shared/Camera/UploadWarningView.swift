//
//  UploadWarningView.swift
//  PlantDiseaseDetector
//
//  Created by Chairal Octavyanz on 15/06/25.
//

import Foundation
import SwiftUI

struct UploadWarningView: View {
    var onContinue: () -> Void
    var onCancel: () -> Void

    var body: some View {
        ZStack {
            Color("color-BgPage")
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                HStack {
                    Button("Cancel", action: onCancel)
                        .padding(.leading)
                        .padding(.top, 20)
                        .foregroundColor(Color("color-font-green"))
                    Spacer()
                }
                
                Spacer()
                Spacer()
                
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 196, height: 196)
                        .foregroundColor(Color("color-warning"))
                    
                    
                    Text("Please note that results generated from uploaded photos may not always be perfectly precise.")
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 60)
                        .foregroundColor(Color("color-warning"))
                }
                
                Spacer()
                
                Button(action: onContinue) {
                    HStack {
                        Text("Continue Upload Picture")
                            .font(.system(size: 17, weight: .bold) )
                        Spacer()
                        Image("logo-upload")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                    }
                    .padding(.vertical)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity)
                    .background(Color("color-font-green"))
                    .foregroundColor(.white)
                    .cornerRadius(16)
                }
                .padding(.horizontal, 60)
                
                Spacer()
            }
            .background(Color("BgLightGreen"))
        }
//        .ignoresSafeArea()
    }
}


#Preview {
    UploadWarningView(onContinue: {}, onCancel: {})
}
