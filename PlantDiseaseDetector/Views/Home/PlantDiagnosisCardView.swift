//
//  PlantDiagnosisCardView.swift
//  PlantDiseaseDetector
//
//  Created by Rico Tandrio on 18/06/25.
//

import SwiftUI

struct PlantDiagnosisCardView: View {
    let plantDiagnosis: PlantDiagnosis
    
    let onDelete: () -> Void

    @State private var onDeleteAlertPresented: Bool = false
    
    func openDeleteAlert() {
        onDeleteAlertPresented = true
    }
    
    func closeDeleteAlert() {
        onDeleteAlertPresented = false
    }
    
    var body: some View {
        NavigationLink(destination: PlantDiagnosisView(plantDiagnosis: plantDiagnosis)) {
            
            HStack {
                
                Image(uiImage: plantDiagnosis.getImage())
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
                    .frame(width: 120, height: 120)
                    .clipped()
                    .cornerRadius(12)
                    .padding(10)
                

                VStack (alignment: .leading, spacing: 5){
                    
                    Text(plantDiagnosis.disease.rawValue)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color("color-font-green"))
                    
                    HStack {
                        Image(systemName: "clock")
                            .font(.system(size: 14))
                        
                        Text(
                            plantDiagnosis.createdAt
                                .formatted(date: .abbreviated, time: .shortened)
                        )
                        .font(.caption)
                    }
                    .foregroundColor(.black)
                
                
                    Spacer()
                    
                    Button {
                        openDeleteAlert()
                    } label: {
                        HStack {
                            Spacer()
                            
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                                .font(.system(size: 20))
                            
                        }
                        .padding(.bottom, 15)
                        .padding(.trailing, 10)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 20)
                
                Spacer()
            }
            .frame(maxWidth: 353, maxHeight: 140)
            .background(Color.white)
            .cornerRadius(20)
            .padding(.vertical, 5)
            .padding(.horizontal, 5)
            .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 4)
            .alert("Delete Diagnosis", isPresented: $onDeleteAlertPresented) {
                Button("Cancel", role: .cancel) {
                    closeDeleteAlert()
                }
                Button("Delete", role: .destructive) {
                    onDelete()
                }
            } message: {
                Text("Are you sure you want to delete this diagnosis?")
            }
        }
    }
}

#Preview {
    PlantDiagnosisCardView(
        plantDiagnosis: PlantDiagnosis(
            disease: .rust,
            probability: 0.95,
            diseases: [],
            photo: UIImage(systemName: "photo") ?? UIImage()
        ),
        onDelete: {}
    )
}
