//
//  Color+Extension.swift
//  PlantDiseaseDetector
//
//  Created by Chairal Octavyanz on 13/06/25.
//

import Foundation
import SwiftUI
import AVFoundation

extension Color {
    static let FABGreen = Color("color-FABGreen")
    static let FABbg = Color("color-FABbg")
}

extension UIImage {
    func cropped(to rect: CGRect, previewLayer: AVCaptureVideoPreviewLayer) -> UIImage? {
        let outputRect = previewLayer.metadataOutputRectConverted(fromLayerRect: rect)
        
        let cgImage = self.cgImage!
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        
        let cropRect = CGRect(x: outputRect.origin.x * width,
                              y: outputRect.origin.y * height,
                              width: outputRect.size.width * width,
                              height: outputRect.size.height * height)
        
        guard let croppedCGImage = cgImage.cropping(to: cropRect) else {
            return nil
        }
        
        return UIImage(cgImage: croppedCGImage, scale: self.scale, orientation: self.imageOrientation)
    }
    
    // More advanced cropping considering AVCapturePhotoOutput connection and device orientation
    func cropped(to rect: CGRect, previewLayer: AVCaptureVideoPreviewLayer, outputConnection: AVCaptureConnection, deviceResolution: CMVideoDimensions?, deviceOrientation: AVCaptureVideoOrientation) -> UIImage? {
        
        // Get the effective output rect considering the preview layer's scaling
        var outputRect = previewLayer.metadataOutputRectConverted(fromLayerRect: rect)
        
        // Adjust outputRect based on the actual image orientation and aspect ratio
        let imageWidth = CGFloat(self.cgImage?.width ?? 0)
        let imageHeight = CGFloat(self.cgImage?.height ?? 0)
        
        // Determine image orientation
        var effectiveImageOrientation = self.imageOrientation
        let connectionOrientation = outputConnection.videoOrientation
        
        if outputConnection.isVideoMirrored {
            switch connectionOrientation {
            case .portrait: effectiveImageOrientation = .leftMirrored
            case .portraitUpsideDown: effectiveImageOrientation = .rightMirrored
            case .landscapeLeft: effectiveImageOrientation = .upMirrored
            case .landscapeRight: effectiveImageOrientation = .downMirrored
            @unknown default: break
            }
        } else {
            switch connectionOrientation {
            case .portrait: effectiveImageOrientation = .up
            case .portraitUpsideDown: effectiveImageOrientation = .down
            case .landscapeLeft: effectiveImageOrientation = .right
            case .landscapeRight: effectiveImageOrientation = .left
            @unknown default: break
            }
        }
        
        // Rotate and scale outputRect to match the image's internal coordinate system
        // This is complex because the image might be rotated by AVFoundation before you get it.
        // A simpler approach is to assume the image is delivered in the correct orientation relative to its pixels,
        // and just adjust the outputRect based on its actual dimensions.
        
        let adjustedOutputRect: CGRect
        switch effectiveImageOrientation {
        case .up, .upMirrored, .down, .downMirrored:
            // Portrait orientations, width and height remain as is
            adjustedOutputRect = CGRect(x: outputRect.origin.x, y: outputRect.origin.y, width: outputRect.width, height: outputRect.height)
        case .left, .leftMirrored, .right, .rightMirrored:
            // Landscape orientations, swap width and height
            adjustedOutputRect = CGRect(x: outputRect.origin.y, y: 1 - (outputRect.origin.x + outputRect.width), width: outputRect.height, height: outputRect.width)
        @unknown default:
            adjustedOutputRect = outputRect
        }
        
        let cropRect = CGRect(x: adjustedOutputRect.origin.x * imageWidth,
                              y: adjustedOutputRect.origin.y * imageHeight,
                              width: adjustedOutputRect.size.width * imageWidth,
                              height: adjustedOutputRect.size.height * imageHeight)
        
        guard let cgImage = self.cgImage else { return nil }
        guard let croppedCGImage = cgImage.cropping(to: cropRect) else {
            return nil
        }
        
        return UIImage(cgImage: croppedCGImage, scale: self.scale, orientation: .up) // Reset orientation to .up as cropping handles rotation
    }
}
