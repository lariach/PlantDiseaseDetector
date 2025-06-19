//
//  CreditsView.swift
//  PlantDiseaseDetector
//
//  Created by Adeline Charlotte Augustinne on 19/06/25.
//

import Foundation
import SwiftUI

struct CreditsView: View {
    
    var resources = [
        "Rashikrahmanpritom. Plant Disease Recognition Dataset.": "https://www.kaggle.com/datasets/rashikrahmanpritom/plant-disease-recognition-dataset",
        "Universidad Tecnica de Manabi. LeLePhid." : "https://data.mendeley.com/datasets/4b6vr2zkbm/1",
        "Daffodil International University. Aloe Vera Leaf Disease Detection Dataset." : "https://data.mendeley.com/datasets/7w6t4zx33n/1",
    ]
    
    var body: some View {
        ZStack{
            Color("color-BgPage").ignoresSafeArea()
            VStack(spacing: 20){
                Image("AppLogo").resizable().frame(width: 200, height: 200)
                VStack(alignment: .center){
                    Text("About LeafLens")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("color-font-green"))
                    Text("Created by LeafLens Team 2025")
                        .font(.headline)
                        .fontWeight(.regular)
                        .foregroundColor(Color("color-font-green"))
                }
                VStack(alignment: .center, spacing: 15){
                    Text("Resources")
                        .font(.title2)
                        .fontWeight(.semibold)                        .foregroundColor(Color("color-font-green"))
                    VStack(alignment: .leading){
                        ForEach(resources.sorted(by: < ), id: \.key) { key, value in
                                Text("\(key)")
                                    .fontWeight(.regular)
                                    .foregroundColor(Color("color-font-green"))
                                Text("\(value)")
                                    .font(.subheadline)
                                    .fontWeight(.regular)
                                    .foregroundColor(Color("color-font-green"))
                                    .opacity(60/100)
                                    .padding(.bottom, 10)
                            }
                        }.frame(
                            width: 350)
                    }
                }
            }
        }
    }

#Preview {
    CreditsView()
}
