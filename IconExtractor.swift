//
//  IconExtractor.swift
//  Silque
//
//  Created by Antony Marcelino on 27/05/2025.
//


import UIKit

struct IconExtractor {
    static func extractIcon(from appBundleURL: URL) -> UIImage? {
        let iconsToTry = [
            "AppIcon60x60@3x.png", "AppIcon60x60@2x.png", "icon@3x.png", "icon@2x.png", "icon.png"
        ]
        for iconName in iconsToTry {
            let iconURL = appBundleURL.appendingPathComponent(iconName)
            if FileManager.default.fileExists(atPath: iconURL.path),
               let data = try? Data(contentsOf: iconURL),
               let image = UIImage(data: data) {
                return image
            }
        }
        // Recherche via CFBundleIcons (avancé, optionnel selon ton app)
        return nil
    }
}