//
//  CGRect.swift
//  PlantDiseaseDetector
//
//  Created by Rico Tandrio on 17/06/25.
//

import Foundation

// convert normalized YOLO box to CGRect
extension CGRect {
    static func normalizedYoloToCGRect(cx: Float, cy: Float, width: Float, height: Float, imageWidth: CGFloat, imageHeight: CGFloat) -> CGRect {
        let xCenter = CGFloat(cx) * imageWidth
        let yCenter = CGFloat(cy) * imageHeight
        let w = CGFloat(width) * imageWidth
        let h = CGFloat(height) * imageHeight
        
        let x = xCenter - w / 2
        let y = yCenter - h / 2
        
        return CGRect(x: x, y: y, width: w, height: h)
    }
}
