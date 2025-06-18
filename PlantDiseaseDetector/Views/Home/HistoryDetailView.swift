//
//  DiseaseDetailView.swift
//  PlantDiseaseDetector
//
//  Created by Chairal Octavyanz on 15/06/25.
//

import Foundation
import SwiftUI

struct HistoryDetailView: View {
    let history: History
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Gambar header
                ZStack(alignment: .bottomLeading){
                    Image(history.image)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity ,maxHeight: 350)
                        .clipped()
                    
                    LinearGradient(
                        gradient: Gradient(colors: [Color.black.opacity(0.6), .clear]),
                        startPoint: .bottom,
                        endPoint: .top
                    )
                    .frame(height: 300)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack{
                            Image(systemName: "clock")
                            Text(history.date.formatted(date: .abbreviated, time: .shortened))
                        }
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(.white)
                    }
                    .padding(20)
                }
                
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("The most likely diagnosis of your plant is")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color("color-font-green"))
                            .padding(.leading, 10)
                        
                        HStack{
                            Spacer()
                            DiseaseLibraryCard(
                                disease: diseaseList[0],
                                cardSize: CGSize(width: 353, height: 300))
                            Spacer()
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 10)  {
                        Text("another possible diagnosis...")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color("color-font-green"))
                            .padding(.leading, 10)
                        
                        
                        LazyVGrid(columns: columns, spacing: 16) {
                            DiseaseLibraryCard(disease: diseaseList[1], cardSize: CGSize(width: 170, height: 170))
                            DiseaseLibraryCard(disease: diseaseList[2], cardSize: CGSize(width: 170, height: 170))
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(20)
                
            }
        }
        .background(Color("color-BgPage"))
        //        .navigationTitle("Disease Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    HistoryDetailView(history: History(
        name: "name1",
        image: "image-howto",
        date: dateFrom("Jun 16, 2025 at 1:42 AM"),
        disease1: "rust",
        disease2: "powdery",
        disease3: "sunburn"
    )
    )
}

//
//struct SectionView: View {
//    let title: String
//    let content: String
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text(title)
//                .font(.system(size: 22, weight: .bold))
//                .foregroundColor(Color("color-font-green"))
//            Text(content)
//                .font(.system(size: 16, weight: .regular))
//                .foregroundColor(.black)
//        }
//    }
//}


