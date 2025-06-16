import UIKit
import AVFoundation
import SwiftUI
import PhotosUI

protocol CameraViewControllerDelegate: AnyObject {
    func didCapture(image: UIImage)
    func didCancel()
}

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let itemProvider = results.first?.itemProvider,
                  itemProvider.canLoadObject(ofClass: UIImage.self) else {
                return
            }

            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                guard let self = self,
                      let uiImage = image as? UIImage else { return }

                DispatchQueue.main.async {
                    self.delegate?.didCapture(image: uiImage)
                }
            }
        }
    
    var captureSession: AVCaptureSession!
    var photoOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var captureDevice: AVCaptureDevice?
    weak var delegate: CameraViewControllerDelegate?
    
    var isFlashOn: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupOverlay()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
        
        // Cek apakah corner layer sudah ditambahkan
        if view.layer.sublayers?.first(where: { $0.name == "cornerLayer" }) == nil {
            drawCornerFrame(over: view)
        }
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
        
        // ✅ Start session in background to avoid blocking UI
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
    
    
    func setupOverlay() {
        // Cancel Button
        let cancel = UIButton(type: .system)
        cancel.setImage(UIImage(systemName: "xmark"), for: .normal)
        cancel.tintColor = .white
        cancel.frame = CGRect(x: 20, y: 60, width: 40, height: 40)
        cancel.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        view.addSubview(cancel)
        
        // Help Button
        let helpBtn = UIButton(type: .system)
        helpBtn.setImage(UIImage(systemName: "questionmark.circle"), for: .normal)
        helpBtn.tintColor = .white
        helpBtn.frame = CGRect(x: view.bounds.width - 100, y: 60, width: 40, height: 40)
        helpBtn.addTarget(self, action: #selector(showHelpSheet), for: .touchUpInside)
        view.addSubview(helpBtn)
        
        // Flash Toggle Button
        let flashBtn = UIButton(type: .system)
        flashBtn.setImage(UIImage(systemName: "bolt.fill"), for: .normal)
        flashBtn.tintColor = isFlashOn ? .yellow : .white
        flashBtn.frame = CGRect(x: view.bounds.width - 60, y: 60, width: 40, height: 40)
        flashBtn.addTarget(self, action: #selector(toggleFlash), for: .touchUpInside)
        view.addSubview(flashBtn)
        
        // Gallery Button
        let galleryButton = UIButton(type: .custom)
        galleryButton.frame = CGRect(x: 35, y: view.bounds.height - 215, width: 70, height: 70)
        galleryButton.backgroundColor = .gray
        galleryButton.layer.cornerRadius = 8
        galleryButton.addTarget(self, action: #selector(openPhotoLibrary), for: .touchUpInside)
        view.addSubview(galleryButton)
        
        // Capture Button
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
        helpVC.modalPresentationStyle = .automatic // or .pageSheet, .formSheet, etc.
        present(helpVC, animated: true, completion: nil)
    }
    
    @objc func toggleFlash(_ sender: UIButton) {
        isFlashOn.toggle()
        sender.tintColor = isFlashOn ? .yellow : .white
        
        guard let device = captureDevice, device.hasTorch else { return }
        
        do {
            try device.lockForConfiguration()
            
            if isFlashOn {
                try device.setTorchModeOn(level: 1.0) // full brightness
            } else {
                device.torchMode = .off
            }
            
            device.unlockForConfiguration()
        } catch {
            print("Torch could not be used: \(error)")
        }
    }
    
//    @objc func openPhotoLibrary() {
//        let picker = UIImagePickerController()
//        picker.sourceType = .photoLibrary
//        picker.delegate = self
//        picker.allowsEditing = false
//        present(picker, animated: true, completion: nil)
//    }
    
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

        warningVC.modalPresentationStyle = UIModalPresentationStyle.automatic
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


    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
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
        
        // Optional: Turn off torch after capture
        if captureDevice?.hasTorch == true {
            try? captureDevice?.lockForConfiguration()
            captureDevice?.torchMode = .off
            captureDevice?.unlockForConfiguration()
        }
        
        // 🧠 Optional: run classification here
        // classify(image) { result in ... }
        
        delegate?.didCapture(image: image)
    }
    
    // Optional: Classification stub
    func classify(_ image: UIImage, completion: @escaping (String) -> Void) {
        // Example only: Call your ML model here
        completion("Healthy") // or "Diseased", etc.
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
    
    
}
