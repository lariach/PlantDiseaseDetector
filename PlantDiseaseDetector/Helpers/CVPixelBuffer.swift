//
//  CVPixelBuffer.swift
//  PlantDiseaseDetector
//
//  Created by Rico Tandrio on 13/06/25.
//

import UIKit

extension CVPixelBuffer {
    func toUIImage() -> UIImage? {
        let ciImage = CIImage(cvPixelBuffer: self)
        let context = CIContext()
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        
        return nil
    }
}
