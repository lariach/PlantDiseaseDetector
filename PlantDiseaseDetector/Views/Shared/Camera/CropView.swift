// CropView.swift

import SwiftUI

struct CropView: View {
    var image: UIImage
    
    var onCrop: (UIImage) -> Void
    var onCancel: () -> Void

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    @State private var viewSize: CGSize = .zero

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .scaleEffect(scale)
                .offset(offset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let widthBoundary = (viewSize.width / 2) * (scale - 1)
                            let heightBoundary = (viewSize.height / 2) * (scale - 1)
                            
                            var newOffset = CGSize(
                                width: lastOffset.width + value.translation.width,
                                height: lastOffset.height + value.translation.height
                            )
                            
                            newOffset.width = max(min(newOffset.width, widthBoundary), -widthBoundary)
                            newOffset.height = max(min(newOffset.height, heightBoundary), -heightBoundary)
                            
                            self.offset = newOffset
                        }
                        .onEnded { _ in
                            self.lastOffset = self.offset
                        }
                )
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            let delta = value / self.lastScale
                            self.scale *= delta
                            self.lastScale = value
                        }
                        .onEnded { _ in
                            
                            // ensure min. scale is 1
                            self.scale = max(1, self.scale)
                            self.lastScale = self.scale
                            
                            // reset offset if scale is 1
                            if self.scale == 1 {
                                self.offset = .zero
                                self.lastOffset = .zero
                            }
                        }
                )

            // cropping frame overlay
            Rectangle()
                .fill(Color.black.opacity(0.5))
                .mask(
                    HoleShapeMask(in: CGRect(x: 25, y: (viewSize.height - (viewSize.width - 50)) / 2, width: viewSize.width - 50, height: viewSize.width - 50))
                        .fill(style: FillStyle(eoFill: true))
                )
                .allowsHitTesting(false)
            
            // TODO: remove change to guides like in the camera cropper
            // corner guides (like in the camera view)
            Image("corner-guides")
                .resizable()
                .scaledToFit()
                .frame(width: viewSize.width - 50)


            VStack {
                Spacer()
                HStack {
                    Button("Cancel") {
                        onCancel()
                    }
                    .font(.title3)
                    .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button("Crop Image") {
                        cropImage()
                    }
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.yellow)
                }
                .padding(.horizontal, 25)
                .padding(.vertical, 30)
            }
        }
        .onAppear {
            // TODO: adjust bounding crop box size
            let screenWidth = UIScreen.main.bounds.width
            let imageAspectRatio = image.size.width / image.size.height
            let cropBoxSize = screenWidth - 50
            
            if image.size.width < image.size.height {
                scale = cropBoxSize / (image.size.width * (cropBoxSize / image.size.height))
            } else {
                scale = cropBoxSize / image.size.height
            }
            lastScale = scale
        }
        .background(
            // geometryReader to get the view size
            GeometryReader { proxy in
                Color.clear.onAppear {
                    self.viewSize = proxy.size
                }
            }
        )
    }

    private func cropImage() {
        let screenWidth = UIScreen.main.bounds.width
        let cropBoxSize = screenWidth - 50
        let cropRect = CGRect(x: 25, y: (viewSize.height - cropBoxSize) / 2, width: cropBoxSize, height: cropBoxSize)

        let renderer = ImageRenderer(
            content:
                Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .scaleEffect(scale)
                .offset(offset)
                .frame(width: viewSize.width, height: viewSize.height)
        )

        // set renderer's scale to match the screen's scale
        renderer.scale = UIScreen.main.scale
        
        // render image and crop it
        if let fullImage = renderer.uiImage {
            if let cropped = fullImage.cgImage?.cropping(to: cropRect.applying(CGAffineTransform(scaleX: renderer.scale, y: renderer.scale))) {
                onCrop(UIImage(cgImage: cropped))
            }
        }
    }
}

struct HoleShapeMask: Shape {
    let rect: CGRect

    init(in rect: CGRect) {
        self.rect = rect
    }

    func path(in rect: CGRect) -> Path {
        var path = Rectangle().path(in: rect)
        path.addPath(RoundedRectangle(cornerRadius: 20).path(in: self.rect))
        return path
    }
}
