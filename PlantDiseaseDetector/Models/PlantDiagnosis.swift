//
//  Models.swift
//  PlantDiseaseDetector
//
//  Created by Chairal Octavyanz on 10/06/25.
//

import Foundation
import SwiftData
import UIKit

struct DiseaseWrapper: Codable, Hashable {
    var disease: DiseaseEnum
    var probability: Double
}

// no id var because SwiftData already uses built-in persistent ID
@Model
class PlantDiagnosis {
    var disease: DiseaseEnum
    var probability: Double
    var diseases: [DiseaseWrapper]
    var createdAt: Date
    
    @Attribute(.externalStorage) var photo: Data
    
    init(disease: DiseaseEnum, probability: Double, diseases: [DiseaseWrapper], photo: UIImage) {
        self.disease = disease
        self.probability = probability
        self.diseases = diseases
        self.createdAt = Date()
        self.probability = probability
        self.photo = photo.jpegData(compressionQuality: 0.8) ?? Data()
    }
    
    func getImage() -> UIImage {
        return UIImage(data: photo) ?? UIImage()
    }
    
    
}
