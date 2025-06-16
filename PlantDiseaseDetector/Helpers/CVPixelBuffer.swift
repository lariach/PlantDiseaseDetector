//
//  CVPixelBuffer.swift
//  PlantDiseaseDetector
//
//  Created by Rico Tandrio on 13/06/25.
//

import UIKit

extension CVPixelBuffer {
    private static let context = CIContext()
    
    func toUIImage() -> UIImage? {
        let ciImage = CIImage(cvPixelBuffer: self)
        if let cgImage = CVPixelBuffer.context.createCGImage(ciImage, from: ciImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        
        return nil
    }
}
