//
//  PlistEditor.swift
//  Silque
//
//  Created by Antony Marcelino on 27/05/2025.
//

import Foundation

enum PlistEditorError: LocalizedError {
    case plistNotFound
    case cannotReadPlist
    case cannotWritePlist
    case invalidFormat

    var errorDescription: String? {
        switch self {
        case .plistNotFound:     return "Info.plist introuvable."
        case .cannotReadPlist:   return "Impossible de lire le Info.plist."
        case .cannotWritePlist:  return "Impossible d’écrire dans le Info.plist."
        case .invalidFormat:     return "Format Info.plist non valide."
        }
    }
}

final class PlistEditor {
    private let plistURL: URL
    private var dict: NSMutableDictionary

    init(plistURL: URL) throws {
        self.plistURL = plistURL
        guard FileManager.default.fileExists(atPath: plistURL.path) else {
            throw PlistEditorError.plistNotFound
        }
        guard let dict = NSMutableDictionary(contentsOf: plistURL) else {
            throw PlistEditorError.cannotReadPlist
        }
        self.dict = dict
    }

    func value(forKey key: String) -> String? {
        return dict[key] as? String
    }

    func setValue(_ value: String, forKey key: String) {
        dict[key] = value
    }

    func save() throws {
        let ok = dict.write(to: plistURL, atomically: true)
        if !ok { throw PlistEditorError.cannotWritePlist }
    }
}
