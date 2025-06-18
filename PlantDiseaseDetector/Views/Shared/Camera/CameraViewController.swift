import UIKit
import AVFoundation
import SwiftUI
import PhotosUI
import TOCropViewController

protocol CameraViewControllerDelegate: AnyObject {
    func didCapture(image: UIImage)
    func didCancel()
}

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate, TOCropViewControllerDelegate {
    
    var captureSession: AVCaptureSession!
    var photoOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var captureDevice: AVCaptureDevice?
    weak var delegate: CameraViewControllerDelegate?
    var selectedImage: UIImage?
    var showPreviewAfterCrop = false
    var isFlashOn: Bool = false
    var onImageConfirmed: ((UIImage) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupOverlay()
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

    
    func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        guard let camera = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: camera),
              captureSession.canAddInput(input) else { return }
        
        captureDevice = camera
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
    
    func setupOverlay() {
        let cancel = UIButton(type: .system)
        cancel.setImage(UIImage(systemName: "xmark"), for: .normal)
        cancel.tintColor = .white
        cancel.frame = CGRect(x: 20, y: 60, width: 40, height: 40)
        cancel.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        view.addSubview(cancel)
        
        let helpBtn = UIButton(type: .system)
        helpBtn.setImage(UIImage(systemName: "questionmark.circle"), for: .normal)
        helpBtn.tintColor = .white
        helpBtn.frame = CGRect(x: view.bounds.width - 100, y: 60, width: 40, height: 40)
        helpBtn.addTarget(self, action: #selector(showHelpSheet), for: .touchUpInside)
        view.addSubview(helpBtn)
        
        let flashBtn = UIButton(type: .system)
        flashBtn.setImage(UIImage(systemName: "bolt.fill"), for: .normal)
        flashBtn.tintColor = isFlashOn ? .yellow : .white
        flashBtn.frame = CGRect(x: view.bounds.width - 60, y: 60, width: 40, height: 40)
        flashBtn.addTarget(self, action: #selector(toggleFlash), for: .touchUpInside)
        view.addSubview(flashBtn)
        
        let galleryButton = UIButton(type: .custom)
        galleryButton.frame = CGRect(x: 35, y: view.bounds.height - 215, width: 70, height: 70)
        galleryButton.backgroundColor = .gray
        galleryButton.layer.cornerRadius = 8
        galleryButton.addTarget(self, action: #selector(openPhotoLibrary), for: .touchUpInside)
        view.addSubview(galleryButton)
        
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: (view.bounds.width - 70) / 2, y: view.bounds.height - 220, width: 80, height: 80)
        button.backgroundColor = .white
        button.layer.cornerRadius = 40
        button.addTarget(self, action: #selector(takePhoto), for: .touchUpInside)
        view.addSubview(button)
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
            device.unlockForConfiguration()
        } catch {
            print("Torch could not be used: \(error)")
        }
    }
    
    @objc func openPhotoLibrary() {
        var warningVC: UIHostingController<UploadWarningView>!
        
        warningVC = UIHostingController(rootView:
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
            delegate?.didCapture(image: selectedImage)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else { return }

        if captureDevice?.hasTorch == true {
            try? captureDevice?.lockForConfiguration()
            captureDevice?.torchMode = .off
            captureDevice?.unlockForConfiguration()
        }

        // 🔥 Crop berdasarkan frame overlay
        if let croppedImage = cropCapturedImageToOverlay(image) {
            self.selectedImage = croppedImage
            self.showPreview()
        } else {
            print("Failed to crop")
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
        
        // Top-left
        path.move(to: CGPoint(x: originX + cornerLength , y: originY))
        path.addLine(to: CGPoint(x: originX + radius, y: originY))
        path.addArc(withCenter: CGPoint(x: originX + radius, y: originY + radius),
                    radius: radius,
                    startAngle: 3 * CGFloat.pi / 2,
                    endAngle: CGFloat.pi,
                    clockwise: false)
        path.addLine(to: CGPoint(x: originX, y: originY + cornerLength))
        
        // Top-right
        path.move(to: CGPoint(x: originX + frameSize, y: originY + cornerLength))
        path.addLine(to: CGPoint(x: originX + frameSize, y: originY + radius))
        path.addArc(withCenter: CGPoint(x: (originX + frameSize) - radius, y: originY + radius),
                    radius: radius,
                    startAngle: 0,
                    endAngle: 3 * CGFloat.pi / 2,
                    clockwise: false)
        path.addLine(to: CGPoint(x: originX + frameSize - cornerLength, y: originY))
        
        // Bottom-left
        path.move(to: CGPoint(x: originX, y: originY + frameSize - cornerLength))
        path.addLine(to: CGPoint(x: originX, y: originY + frameSize - radius))
        path.addArc(withCenter: CGPoint(x: originX + radius, y: originY + frameSize - radius),
                    radius: radius,
                    startAngle: .pi,
                    endAngle: .pi / 2,
                    clockwise: false)
        path.addLine(to: CGPoint(x: originX + cornerLength, y: originY + frameSize))
        
        // Bottom-right
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
    
    func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true) {
            self.selectedImage = image
            self.showPreview()
        }
    }
    
    func showPreview() {
        let previewVC = UIHostingController(rootView:
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
                                                            self.onImageConfirmed?(image) // Kirim ke parent
                                                        }
                                                    }
                                                )
        )
        self.present(previewVC, animated: true)
    }
    
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
    
    func cropCapturedImageToOverlay(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }

        // 🔥 Gunakan self.previewLayer
        let previewSize = self.previewLayer.bounds.size

        let imageSize = CGSize(width: cgImage.width, height: cgImage.height)

        let scaleX = imageSize.width / previewSize.width
        let scaleY = imageSize.height / previewSize.height

        let frameSize = previewSize.width - 50
        let originX = (previewSize.width - frameSize) / 2
        let originY = (previewSize.height - frameSize) / 2

        let cropRect = CGRect(
            x: originX * scaleX,
            y: originY * scaleY,
            width: frameSize * scaleX,
            height: frameSize * scaleY
        ).integral

        guard let cropped = cgImage.cropping(to: cropRect) else { return nil }

        return UIImage(cgImage: cropped, scale: image.scale, orientation: image.imageOrientation)
    }

}

func cropCenterSquare(from image: UIImage) -> UIImage? {
    let sourceSize = image.size
    let sideLength = min(sourceSize.width, sourceSize.height)
    
    let xOffset = (sourceSize.width - sideLength) / 2.0
    let yOffset = (sourceSize.height - sideLength) / 2.0
    
    let cropRect = CGRect(x: xOffset, y: yOffset, width: sideLength, height: sideLength).integral
    
    guard let cgImage = image.cgImage, let croppedCGImage = cgImage.cropping(to: cropRect) else {
        return nil
    }
    
    return UIImage(cgImage: croppedCGImage, scale: image.scale, orientation: image.imageOrientation)
}

//func cropCapturedImageToOverlay(_ image: UIImage) -> UIImage? {
//    guard let cgImage = image.cgImage else { return nil }
//
//    // 🔥 Gunakan self.previewLayer
//    let previewSize = self.previewLayer.bounds.size
//
//    let imageSize = CGSize(width: cgImage.width, height: cgImage.height)
//
//    let scaleX = imageSize.width / previewSize.width
//    let scaleY = imageSize.height / previewSize.height
//
//    let frameSize = previewSize.width - 50
//    let originX = (previewSize.width - frameSize) / 2
//    let originY = (previewSize.height - frameSize) / 2
//
//    let cropRect = CGRect(
//        x: originX * scaleX,
//        y: originY * scaleY,
//        width: frameSize * scaleX,
//        height: frameSize * scaleY
//    ).integral
//
//    guard let cropped = cgImage.cropping(to: cropRect) else { return nil }
//
//    return UIImage(cgImage: cropped, scale: image.scale, orientation: image.imageOrientation)
//}



