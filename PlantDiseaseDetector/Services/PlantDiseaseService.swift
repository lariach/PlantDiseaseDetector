//
//  PlantDiseaseService.swift
//  PlantDiseaseDetector
//
//  Created by Rico Tandrio on 13/06/25.
//

import CoreML
import UIKit

class PlantDiseaseService {
    private let model: PlantDisease

    init() {
        self.model = try! PlantDisease(configuration: MLModelConfiguration())
    }

    func classify(image: UIImage?) -> (resultText: String, prediction: PlantDiseaseOutput?) {
        guard let image = image else {
            return ("No image provided", nil)
        }
        
        let width = Int(image.size.width)
        let height = Int(image.size.height)

        guard let pixelBuffer = image.toCVPixelBuffer(width: width, height: height) else {
            return ("Failed to convert image to pixel buffer", nil)
        }

        do {
            let prediction = try model.prediction(image: pixelBuffer)
            return ("Classification succeeded", prediction)
        } catch {
            return ("Prediction failed: \(error.localizedDescription)", nil)
        }
    }
}
