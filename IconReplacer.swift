//
//  IconReplacer.swift
//  Silque
//
//  Created by Antony Marcelino on 27/05/2025.
//


import UIKit

struct IconReplacer {
    static func replaceIcon(in appBundleURL: URL, with image: UIImage) throws {
        let iconSizes = [
            (name: "AppIcon60x60@3x.png", size: CGSize(width: 180, height: 180)),
            (name: "AppIcon60x60@2x.png", size: CGSize(width: 120, height: 120)),
            (name: "icon@3x.png", size: CGSize(width: 180, height: 180)),
            (name: "icon@2x.png", size: CGSize(width: 120, height: 120)),
            (name: "icon.png", size: CGSize(width: 60, height: 60))
        ]
        for icon in iconSizes {
            let resized = image.resized(to: icon.size)
            let url = appBundleURL.appendingPathComponent(icon.name)
            if let data = resized.pngData() {
                try? data.write(to: url)
            }
        }
    }
}

private extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}