//
//  HistoryCardView.swift
//  PlantDiseaseDetector
//
//  Created by Chairal Octavyanz on 04/06/25.
//

import SwiftUI
import PhotosUI

struct HistoryCardView: View {
    let history: History
    
    
    
    var body: some View {
        NavigationLink(destination: HistoryDetailView(history: history)) {
            HStack{
                if let uiImage = UIImage(contentsOfFile: history.image) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipped()
                        .cornerRadius(10)
                } else {
                    // Fallback jika gagal load image
                    Color.gray
                        .frame(width: 80, height: 80)
                        .cornerRadius(10)
                }
                
                
                VStack (alignment: .leading, spacing: 5){
                    Text(history.name)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color("color-font-green"))
                    HStack{
                        Image(systemName: "clock")
                        Text(
                            history.date
                                .formatted(date: .abbreviated, time: .shortened)
                        )
                    }
                    .foregroundColor(.black)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 20)
                
                Spacer()
            }
            .frame(maxWidth: 353, maxHeight: 140)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 4)
        }
    }
}

//            ZStack(alignment: .bottomLeading) {
//                Image(disease.imageName)
//                    .resizable()
//                    .scaledToFill()
//                    .frame(width: 180, height: 170)
//                    .clipped()
//                    .cornerRadius(16)
//
//                LinearGradient(
//                    gradient: Gradient(colors: [Color.black.opacity(0.6), .clear]),
//                    startPoint: .bottom,
//                    endPoint: .top
//                )
//                .frame(height: 60)
//                .cornerRadius(16)
//
//                Text(disease.name)
//                    .font(.system(size: 14, weight: .semibold))
//                    .foregroundColor(.white)
//                    .padding(.leading, 12)
//                    .padding(.bottom, 12)
//            }
//            .frame(width: 180, height: 170)
//            .cornerRadius(16)
//            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 4)
//        }
//        .buttonStyle(PlainButtonStyle()) // agar tidak ada efek biru klik
//    }
//}


//#Preview {
//    ZStack {
//        Color("color-BgPage")
//            .ignoresSafeArea()
//        HistoryCardView(history: historyList[0])
//            .padding()
//    }
//}
