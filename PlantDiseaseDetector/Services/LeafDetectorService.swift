//
//  LeafDetectorService.swift
//  PlantDiseaseDetector
//
//  Created by Adeline Charlotte Augustinne on 16/06/25.
//

import SwiftUI
import CoreML
import UIKit

// struct for detection result
struct Detection: Identifiable {
    let id = UUID()
    var box: CGRect      // bounding box in original image coordinates (x, y, width, height)
    var confidence: Float
    var classId: Int
    var className: String
}

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

// convert UIImage to CVPixelBuffer
extension UIImage {
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
}

final class LeafDetectorService: ObservableObject {
    private var leafModel: LeafDetector
    private var modelInputSize = CGSize(width: 640, height: 640)
    private var confidenceThreshold: Float = 0.6
    private var iouThreshold: Float = 0.7
    
    private var classNames = ["leaf"]
    
    
    init(
        confidenceThreshold: Float = 0.6,
        iouThreshold: Float = 0.7,
        classNames: [String] = ["leaf"]
    ) throws {
        let configuration = MLModelConfiguration()
        self.leafModel = try LeafDetector(configuration: configuration)
        
        self.confidenceThreshold = confidenceThreshold
        self.iouThreshold = iouThreshold
        self.classNames = classNames
    }
    
    func calculateIoU(box1: CGRect, box2: CGRect) -> Float {
        
        let intersection = box1.intersection(box2)
        let intersectionArea = intersection.width * intersection.height
        let unionArea = (box1.width * box1.height) + (box2.width * box2.height) - intersectionArea
        if unionArea == 0 { return 0 }
        return Float(intersectionArea / unionArea)
    }
    
    func nonMaxSuppression(boxes: [CGRect], confidences: [Float], iouThreshold: Float) -> [Int] {
        guard !boxes.isEmpty else { return [] }
        
        var sortedIndices = confidences.enumerated().sorted { $0.element > $1.element }.map { $0.offset }
        var keep: [Int] = []
        var suppressed = [Bool](repeating: false, count: boxes.count)
        
        while let currentMaxIndex = sortedIndices.first {
            if !suppressed[currentMaxIndex] {
                keep.append(currentMaxIndex)
                
                for i in 1..<sortedIndices.count {
                    let nextBoxIndex = sortedIndices[i]
                    if !suppressed[nextBoxIndex] {
                        let iou = calculateIoU(box1: boxes[currentMaxIndex], box2: boxes[nextBoxIndex])
                        if iou > iouThreshold {
                            suppressed[nextBoxIndex] = true
                        }
                    }
                }
            }
            sortedIndices.removeFirst()
        }
        return keep
    }
    
    func processYOLOv8Output(
        output: MLMultiArray,
        imageWidth: CGFloat,
        imageHeight: CGFloat
    ) -> [Detection] {
        
        // ensure output shape is as expected: [1, 5, 8400]
        guard output.shape.count == 3,
              output.shape[0].intValue == 1,
              output.shape[1].intValue == 5, // [cx, cy, w, h, confidence]
              output.shape[2].intValue == 8400 else {
            print("Error: Unexpected output shape. Expected [1, 5, 8400], got \(output.shape)")
            return []
        }
        
        let numProposals = output.shape[2].intValue
        let floatPointer = UnsafeMutablePointer<Float>(OpaquePointer(output.dataPointer))
        
        var candidateBoxes: [CGRect] = []
        var candidateConfidences: [Float] = []
        var candidateClassIds: [Int] = [] // 0 for single class
        
        // Iterate through all 8400 proposals
        for i in 0..<numProposals {
            // Aaccess data for the i-th proposal based on `1 x 5 x 8400` where 5 is the attribute dimension and 8400 is the proposals
            // assuming row-major layout for MLMultiArray:
            // attribute_index * num_proposals + proposal_index
            
            let cx = floatPointer[0 * numProposals + i]
            let cy = floatPointer[1 * numProposals + i]
            let w = floatPointer[2 * numProposals + i]
            let h = floatPointer[3 * numProposals + i]
            let confidence = floatPointer[4 * numProposals + i]
            
            if confidence >= self.confidenceThreshold {
                let bbox = CGRect.normalizedYoloToCGRect(
                    cx: cx,
                    cy: cy,
                    width: w,
                    height: h,
                    imageWidth: imageWidth,
                    imageHeight: imageHeight
                )
                candidateBoxes.append(bbox)
                candidateConfidences.append(confidence)
                candidateClassIds.append(0) // 0 for single class
            }
        }
        
        // Non-Maximum Suppression (NMS)
        let nmsIndices = self.nonMaxSuppression(
            boxes: candidateBoxes,
            confidences: candidateConfidences,
            iouThreshold: iouThreshold
        )
        
        var finalDetections: [Detection] = []
        for index in nmsIndices {
            finalDetections.append(Detection(
                box: candidateBoxes[index],
                confidence: candidateConfidences[index],
                classId: candidateClassIds[index],
                className: self.classNames[candidateClassIds[index]]
            ))
        }
        
        return finalDetections
    }
    
    func detectLeaf(in image: UIImage) -> [Detection]? {
        
        guard let pixelBuffer = image.toCVPixelBuffer(targetSize: modelInputSize) else {
            print("Failed to convert image to pixel buffer.")
            return nil
        }
        
        do {
            let modelInput = LeafDetectorInput(image: pixelBuffer)
            
            let prediction = try leafModel.prediction(input: modelInput)
            
            let modelOutput = prediction.var_1139
            
            
            let originalImageWidth = image.size.width
            let originalImageHeight = image.size.height
            
            let detectedObjects = self.processYOLOv8Output(
                output: modelOutput,
                imageWidth: originalImageWidth,
                imageHeight: originalImageHeight
            )
            
            if detectedObjects.isEmpty {
                print("No leaf objects detected")
                return nil
            } else {
                print("Detected leaf object")
                return detectedObjects
            }
        } catch {
            print("Prediction error: \(error.localizedDescription)")
            return nil
        }
    }
}
