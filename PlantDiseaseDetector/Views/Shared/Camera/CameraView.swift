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
            parent.image = image
            parent.presentationMode.wrappedValue.dismiss()
        }

        func didCancel() {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
