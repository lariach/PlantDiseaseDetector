//
//  UIImage.swift
//  PlantDiseaseDetector
//
//  Created by Rico Tandrio on 13/06/25.
//

import UIKit
import AVFoundation

extension UIImage {
    func toCVPixelBuffer(width: Int, height: Int) -> CVPixelBuffer? {
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue!,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue!
        ] as CFDictionary
        
        var pixelBuffer: CVPixelBuffer?

        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_32ARGB,
            attrs,
            &pixelBuffer
        )

        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }

        CVPixelBufferLockBaseAddress(buffer, [])
        
        let context = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        )

        guard let ctx = context else {
            CVPixelBufferUnlockBaseAddress(buffer, [])
            return nil
        }

        ctx.translateBy(x: 0, y: CGFloat(height))
        ctx.scaleBy(x: 1.0, y: -1.0)

        UIGraphicsPushContext(ctx)
        self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(buffer, [])

        return buffer
    }
    
    func toCVPixelBuffer(targetSize: CGSize) -> CVPixelBuffer? {
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue
        ] as CFDictionary
        var pixelBuffer: CVPixelBuffer?

        let width = Int(targetSize.width)
        let height = Int(targetSize.height)

        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         width,
                                         height,
                                         kCVPixelFormatType_32BGRA,
                                         attrs,
                                         &pixelBuffer)
        guard status == kCVReturnSuccess else {
            return nil
        }

        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)

        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData,
                                width: width,
                                height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!),
                                space: rgbColorSpace,
                                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) // BGRA

        context?.translateBy(x: 0, y: CGFloat(height))
        context?.scaleBy(x: 1.0, y: -1.0)

        UIGraphicsPushContext(context!)
        self.draw(in: CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

        return pixelBuffer
    }
    
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
    
    /// more advanced cropping considering AVCapturePhotoOutput connection and device orientation
    func cropped(to rect: CGRect, previewLayer: AVCaptureVideoPreviewLayer, outputConnection: AVCaptureConnection, deviceResolution: CMVideoDimensions?, deviceOrientation: AVCaptureVideoOrientation) -> UIImage? {
        
        /// get the effective output rect considering the preview layer's scaling
        var outputRect = previewLayer.metadataOutputRectConverted(fromLayerRect: rect)
        
        /// adjust outputRect based on the actual image orientation and aspect ratio
        let imageWidth = CGFloat(self.cgImage?.width ?? 0)
        let imageHeight = CGFloat(self.cgImage?.height ?? 0)
        
        /// determine image orientation
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
        
        /// rotate and scale outputRect to match the image's internal coordinate system
        let adjustedOutputRect: CGRect
        switch effectiveImageOrientation {
        case .up, .upMirrored, .down, .downMirrored:
            /// portrait orientation
            adjustedOutputRect = CGRect(x: outputRect.origin.x, y: outputRect.origin.y, width: outputRect.width, height: outputRect.height)
        case .left, .leftMirrored, .right, .rightMirrored:
            /// landscape orientation
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
        
        return UIImage(cgImage: croppedCGImage, scale: self.scale, orientation: .up)
    }
}
