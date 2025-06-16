//
//  Models.swift
//  PlantDiseaseDetector
//
//  Created by Chairal Octavyanz on 10/06/25.
//

import Foundation
import SwiftData

// no id var because SwiftData already uses built-in persistent ID
@Model
class PlantDiagnosis {
    var disease: DiseaseEnum
    var createdAt: Date
    var photo: Data
    
    init(disease: DiseaseEnum, createdAt: Date, photo: Data) {
        self.disease = disease
        self.createdAt = createdAt
        self.photo = photo
    }
}
