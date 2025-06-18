//
//  CameraViewController.swift
//  PlantDiseaseDetector
//
//  Created by Chairal Octavyanz on 13/06/25.
//

import Foundation
import UIKit
import AVFoundation
import SwiftUI
import PhotosUI
import TOCropViewController

protocol CameraViewControllerDelegate: AnyObject {
    func didSelect(image: UIImage)
    func didCancel()
}

/// camera for taking photos
extension CameraViewController {
    func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        guard let camera = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: camera),
              captureSession.canAddInput(input) else { return }
        
        captureDevice = camera
        
        do {
            try captureDevice?.lockForConfiguration()
            captureDevice?.videoZoomFactor = 1.0 // jnitial zoom level
            captureDevice?.ramp(toVideoZoomFactor: 1.0, withRate: 10.0)
            captureDevice?.videoZoomFactor = max(1.0, captureDevice?.videoZoomFactor ?? 1.0)
            captureDevice?.unlockForConfiguration()
        } catch {
            print("Error setting up zoom: \(error)")
        }
        
        captureSession.addInput(input)
        
        photoOutput = AVCapturePhotoOutput()
        captureSession.addOutput(photoOutput)
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.insertSublayer(previewLayer, at: 0)
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
    
    func drawCornerFrame(over parentView: UIView) {
        let cornerLayer = CAShapeLayer()
        cornerLayer.name = "cornerLayer"
        cornerLayer.strokeColor = UIColor.white.cgColor
        cornerLayer.lineWidth = 3
        cornerLayer.fillColor = UIColor.clear.cgColor
        cornerLayer.lineCap = .round
        
        let path = UIBezierPath()
        
        let frameSize = parentView.bounds.width - 50
        let originX = (parentView.bounds.width - frameSize) / 2
        let originY = (parentView.bounds.height - frameSize) / 2
        let cornerLength: CGFloat = 100
        let radius: CGFloat = 60
        
        // top-left
        path.move(to: CGPoint(x: originX + cornerLength , y: originY))
        path.addLine(to: CGPoint(x: originX + radius, y: originY))
        path.addArc(withCenter: CGPoint(x: originX + radius, y: originY + radius),
                    radius: radius,
                    startAngle: 3 * CGFloat.pi / 2,
                    endAngle: CGFloat.pi,
                    clockwise: false)
        path.addLine(to: CGPoint(x: originX, y: originY + cornerLength))
        
        // top-right
        path.move(to: CGPoint(x: originX + frameSize, y: originY + cornerLength))
        path.addLine(to: CGPoint(x: originX + frameSize, y: originY + radius))
        path.addArc(withCenter: CGPoint(x: (originX + frameSize) - radius, y: originY + radius),
                    radius: radius,
                    startAngle: 0,
                    endAngle: 3 * CGFloat.pi / 2,
                    clockwise: false)
        path.addLine(to: CGPoint(x: originX + frameSize - cornerLength, y: originY))
        
        // bottom-left
        path.move(to: CGPoint(x: originX, y: originY + frameSize - cornerLength))
        path.addLine(to: CGPoint(x: originX, y: originY + frameSize - radius))
        path.addArc(withCenter: CGPoint(x: originX + radius, y: originY + frameSize - radius),
                    radius: radius,
                    startAngle: .pi,
                    endAngle: .pi / 2,
                    clockwise: false)
        path.addLine(to: CGPoint(x: originX + cornerLength, y: originY + frameSize))
        
        // bottom-right
        path.move(to: CGPoint(x: originX + frameSize - cornerLength, y: originY + frameSize))
        path.addLine(to: CGPoint(x: originX + frameSize - radius, y: originY + frameSize))
        path.addArc(withCenter: CGPoint(x: originX + frameSize - radius, y: originY + frameSize - radius),
                    radius: radius,
                    startAngle: .pi / 2,
                    endAngle: 0,
                    clockwise: false)
        path.addLine(to: CGPoint(x: originX + frameSize, y: originY + frameSize - cornerLength))
        
        cornerLayer.path = path.cgPath
        parentView.layer.addSublayer(cornerLayer)
    }
    
    func addCancelBtn() {
        let cancel = UIButton(type: .system)
        cancel.setImage(UIImage(systemName: "xmark"), for: .normal)
        cancel.tintColor = .white
        cancel.frame = CGRect(x: 20, y: 60, width: 40, height: 40)
        cancel.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        view.addSubview(cancel)
    }
    
    func addHelpBtn() {
        let helpBtn = UIButton(type: .system)
        helpBtn.setImage(UIImage(systemName: "questionmark.circle"), for: .normal)
        helpBtn.tintColor = .white
        helpBtn.frame = CGRect(x: view.bounds.width - 100, y: 60, width: 40, height: 40)
        helpBtn.addTarget(self, action: #selector(showHelpSheet), for: .touchUpInside)
        view.addSubview(helpBtn)
    }
    
    func addTorchBtn(){
        let flashBtn = UIButton(type: .system)
        flashBtn.setImage(UIImage(systemName: "bolt.fill"), for: .normal)
        flashBtn.tintColor = isFlashOn ? .yellow : .white
        flashBtn.frame = CGRect(x: view.bounds.width - 60, y: 60, width: 40, height: 40)
        flashBtn.addTarget(self, action: #selector(toggleFlash), for: .touchUpInside)
        view.addSubview(flashBtn)
    }
    
    func addGalleryBtn(){
        let galleryButton = UIButton(type: .custom)
        galleryButton.frame = CGRect(x: 35, y: view.bounds.height - 215, width: 70, height: 70)
        galleryButton.backgroundColor = .gray
        galleryButton.layer.cornerRadius = 8
        galleryButton.addTarget(self, action: #selector(openPhotoLibrary), for: .touchUpInside)
        view.addSubview(galleryButton)
    }
    
    func addCaptureBtn(){
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: (view.bounds.width - 70) / 2, y: view.bounds.height - 220, width: 80, height: 80)
        button.backgroundColor = .white
        button.layer.cornerRadius = 40
        button.addTarget(self, action: #selector(takePhoto), for: .touchUpInside)
        view.addSubview(button)
    }
    
    func setupOverlay() {
        addCancelBtn()
        addHelpBtn()
        addTorchBtn()
        addGalleryBtn()
        addCaptureBtn()
    }
    
    @objc func takePhoto() {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = isFlashOn ? .on : .off
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    @objc func cancelTapped() {
        delegate?.didCancel()
    }
    
    @objc func showHelpSheet() {
        let helpVC = UIHostingController(rootView: HowToTakePictureView())
        helpVC.modalPresentationStyle = .automatic
        present(helpVC, animated: true, completion: nil)
    }
    
    @objc func toggleFlash(_ sender: UIButton) {
        isFlashOn.toggle()
        sender.tintColor = isFlashOn ? .yellow : .white
        
        guard let device = captureDevice, device.hasTorch else { return }
        
        do {
            try device.lockForConfiguration()
            if isFlashOn {
                try device.setTorchModeOn(level: 1.0)
            } else {
                device.torchMode = .off
            }
        } catch {
            print("Torch could not be used: \(error)")
        }
    }
    
    @objc func handlePinchGesture(_ sender: UIPinchGestureRecognizer) {
        guard let device = captureDevice else { return }
        
        /// check if video device supports zooming
        if !device.isFocusPointOfInterestSupported || !device.isExposurePointOfInterestSupported {
            return
        }
        
        switch sender.state {
        case .began:
            initialZoomFactor = device.videoZoomFactor
        case .changed:
            let factor = initialZoomFactor * sender.scale
            let newZoomFactor = max(1.0, min(factor, device.activeFormat.videoMaxZoomFactor))
            
            do {
                try device.lockForConfiguration()
                device.ramp(toVideoZoomFactor: newZoomFactor, withRate: 10.0)
                device.unlockForConfiguration()
            } catch {
                print("Error setting zoom: \(error)")
            }
        case .ended:
            break
        default:
            break
        }
    }
}

/// cropping pictures taken from camera
extension CameraViewController {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else { return }
        
        /// calculate the crop rectangle based on frame coordinates
        let frameWidth = view.bounds.width - 50
        let originX = (view.bounds.width - frameWidth) / 2
        let originY = (view.bounds.height - frameWidth) / 2
        
        let cropRect = CGRect(x: originX, y: originY, width: frameWidth, height: frameWidth)
        
        /// convert cropRect from previewLayer coordinates to image coordinates
        guard let previewLayer = self.previewLayer else {
            DispatchQueue.main.async {
                self.selectedImage = image
                self.showPreview()
            }
            return
        }
        
        let croppedImage: UIImage?
        let photoOutputConnection = photoOutput.connection
        if let videoPreviewLayerConnection = previewLayer.connection,
           let outputConnection = photoOutputConnection as? AVCaptureConnection {
            
            let orientation = videoPreviewLayerConnection.videoOrientation
            let captureDeviceResolution = photo.resolvedSettings.photoDimensions
            
            croppedImage = image.cropped(to: cropRect, previewLayer: previewLayer, outputConnection: outputConnection, deviceResolution: captureDeviceResolution, deviceOrientation: orientation)
        } else {
            croppedImage = image.cropped(to: cropRect, previewLayer: previewLayer) /// simpler crop if connections are complex
        }
        
        DispatchQueue.main.async {
            if let realCroppedImg = croppedImage {
                self.selectedImage = realCroppedImg
            } else {
                self.selectedImage = image
            }
            self.showPreview()
        }
    }
}

/// gallery view for uploading photos
extension CameraViewController {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }
        
        provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
            guard let self = self, let uiImage = image as? UIImage else { return }
            
            DispatchQueue.main.async {
                self.selectedImage = uiImage
                let cropVC = TOCropViewController(croppingStyle: .default, image: uiImage)
                cropVC.delegate = self
                cropVC.aspectRatioPreset = .presetSquare
                cropVC.aspectRatioLockEnabled = true
                cropVC.resetAspectRatioEnabled = false
                self.present(cropVC, animated: true)
            }
        }
    }
    
    @objc func openPhotoLibrary() {
        var warningVC: UIHostingController<UploadWarningView>!
        
        warningVC = UIHostingController(
            rootView:
                UploadWarningView(
                    onContinue: {
                        warningVC.dismiss(animated: true) {
                            self.presentPhotoPicker()
                        }
                    },
                    onCancel: {
                        warningVC.dismiss(animated: true)
                    }
                )
        )
        
        warningVC.modalPresentationStyle = .automatic
        self.present(warningVC, animated: true)
    }
    
    func presentPhotoPicker() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let selectedImage = info[.originalImage] as? UIImage {
            delegate?.didSelect(image: selectedImage)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

/// cropping pictures from gallery
extension CameraViewController {
    
    func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true) {
            self.selectedImage = image
            self.showPreview()
        }
    }
    
    func presentCropView(for image: UIImage) {
        let cropView = CropView(
            image: image,
            onCrop: { croppedImage in
                self.dismiss(animated: true) {
                    self.delegate?.didSelect(image: croppedImage)
                }
            },
            onCancel: {
                self.dismiss(animated: true, completion: nil)
            }
        )
        
        let hostingController = UIHostingController(rootView: cropView)
        hostingController.modalPresentationStyle = .fullScreen
        self.present(hostingController, animated: true)
    }
}

/// photo previewers
extension CameraViewController {
    func showPreview() {
        let previewVC = UIHostingController(
            rootView:
                PreviewPhotoView(
                    image: Binding<UIImage?>(
                        get: { self.selectedImage },
                        set: { self.selectedImage = $0 }
                    ),
                    
                    onReupload: {
                        self.selectedImage = nil
                        self.openPhotoLibrary()
                    },
                    onUse: {
                        if let image = self.selectedImage {
                            self.onImageConfirmed?(image)
                        }
                    }
                )
        )
        self.present(previewVC, animated: true)
    }

}

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate, TOCropViewControllerDelegate {
    
    @State private var imageToCrop: UIImage?
    @State private var showCropView = false
    
    var captureSession: AVCaptureSession!
    var photoOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var captureDevice: AVCaptureDevice?
    weak var delegate: CameraViewControllerDelegate?
    
    var selectedImage: UIImage?
    var showPreviewAfterCrop = false
    var onImageConfirmed: ((UIImage) -> Void)?
    
    /// camera settings
    var isFlashOn: Bool = false
    private var initialZoomFactor: CGFloat = 1.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupOverlay()
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        view.addGestureRecognizer(pinchRecognizer)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
        
        if view.layer.sublayers?.first(where: { $0.name == "cornerLayer" }) == nil {
            drawCornerFrame(over: view)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
}
