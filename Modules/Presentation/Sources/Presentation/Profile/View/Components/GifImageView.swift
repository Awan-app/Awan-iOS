//
//  GifImageView.swift
//  Presentation
//
//  Created by AndrewMagdy on 21/07/2026.
//

import SwiftUI
import ImageIO
import MobileCoreServices

struct GifImageView: UIViewRepresentable {
    private let name: String

    init(_ name: String) {
        self.name = name
    }

    func makeUIView(context: Context) -> UIImageView {
        let imageView = IntrinsicSizeImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true

        if let url = Bundle.main.url(forResource: name, withExtension: "gif"),
           let source = CGImageSourceCreateWithURL(url as CFURL, nil) {
            let count = CGImageSourceGetCount(source)
            var images: [UIImage] = []
            var duration: TimeInterval = 0

            for i in 0..<count {
                if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                    images.append(UIImage(cgImage: cgImage))
                }

                if let properties = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [String: Any],
                   let gifInfo = properties[kCGImagePropertyGIFDictionary as String] as? [String: Any] {
                    if let delayTime = gifInfo[kCGImagePropertyGIFUnclampedDelayTime as String] as? Double {
                        duration += delayTime
                    } else if let delayTime = gifInfo[kCGImagePropertyGIFDelayTime as String] as? Double {
                        duration += delayTime
                    }
                }
            }

            if !images.isEmpty {
                imageView.animationImages = images
                imageView.animationDuration = duration
                imageView.startAnimating()
            }
        }

        return imageView
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {}
}

// UIImageView subclass that yields full layout control to SwiftUI's .frame() modifier.
private final class IntrinsicSizeImageView: UIImageView {
    override var intrinsicContentSize: CGSize { .zero }
}

