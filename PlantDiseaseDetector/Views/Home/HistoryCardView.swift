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
                Image(history.image)
                    .resizable()
                    .aspectRatio(1, contentMode: .fill) 
                    .frame(width: 120, height: 120)
                    .clipped()
                    .cornerRadius(12)
                    .padding(10)

                VStack (alignment: .leading, spacing: 5){
                    Text(history.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color("color-font-green"))
                    
                    HStack {
                        Image(systemName: "clock")
                            .font(.system(size: 14))
                        Text(
                            history.date
                                .formatted(date: .abbreviated, time: .shortened)
                        )
                        .font(.caption)
                    }
                    .foregroundColor(.black)
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .font(.system(size: 20))
                            
                    }
                    .padding(.bottom, 15)
                    .padding(.trailing, 10)
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

#Preview {
    ContentView()
}
