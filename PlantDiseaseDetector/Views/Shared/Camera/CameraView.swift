//
//  CameraView.swift
//  PlantDiseaseDetector
//
//  Created by Chairal Octavyanz on 13/06/25.
//

import Foundation
import SwiftUI
import AVFoundation

struct CameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var onImageConfirmed: ((UIImage) -> Void)?
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> CameraViewController {
        let vc = CameraViewController()
        vc.delegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, CameraViewControllerDelegate {
        let parent: CameraView

        init(_ parent: CameraView) {
            self.parent = parent
        }

        func didCapture(image: UIImage) {
            // Hitung ukuran view kamera berdasarkan `UIScreen.main.bounds`
            _ = UIScreen.main.bounds.size

            if let croppedImage = cropImageToMatchOverlay(from: image, screenSize: UIScreen.main.bounds.size) {
                parent.image = croppedImage
                parent.presentationMode.wrappedValue.dismiss()
                parent.onImageConfirmed?(croppedImage) // trigger closure
            } else {
                print("Failed to crop image")
            }
        }

        func didCancel() {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

func cropImageToMatchOverlay(from image: UIImage, screenSize: CGSize) -> UIImage? {
    guard let cgImage = image.cgImage else { return nil }

    // Asumsikan frameSize di CameraViewController adalah lebar layar - 50
    let frameSize = screenSize.width - 50
    let originX = (screenSize.width - frameSize) / 2
    let originY = (screenSize.height - frameSize) / 2

    let cropRect = CGRect(
        x: originX * (CGFloat(cgImage.width) / screenSize.width),
        y: originY * (CGFloat(cgImage.height) / screenSize.height),
        width: frameSize * (CGFloat(cgImage.width) / screenSize.width),
        height: frameSize * (CGFloat(cgImage.height) / screenSize.height)
    ).integral

    guard let croppedCGImage = cgImage.cropping(to: cropRect) else {
        return nil
    }

    return UIImage(cgImage: croppedCGImage, scale: image.scale, orientation: image.imageOrientation)
}

