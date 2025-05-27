import Foundation
import ZipArchive

struct IPAImportResult {
    let tempDirectory: URL
    let payloadDirectory: URL
    let appBundleURL: URL
    let infoPlistURL: URL
}

enum IPAImportError: LocalizedError {
    case extractionFailed
    case payloadMissing
    case appBundleMissing
    case infoPlistMissing

    var errorDescription: String? {
        switch self {
        case .extractionFailed: return "Impossible d’extraire l’IPA."
        case .payloadMissing:   return "Dossier Payload manquant."
        case .appBundleMissing: return "Bundle .app manquant dans Payload."
        case .infoPlistMissing: return "Info.plist manquant dans le bundle."
        }
    }
}

final class IPAImporter {
    static func extractIPA(at ipaURL: URL) throws -> IPAImportResult {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        guard SSZipArchive.unzipFile(atPath: ipaURL.path, toDestination: tempDir.path) else {
            throw IPAImportError.extractionFailed
        }
        let payloadDir = tempDir.appendingPathComponent("Payload")
        guard FileManager.default.fileExists(atPath: payloadDir.path) else {
            throw IPAImportError.payloadMissing
        }
        let contents = try FileManager.default.contentsOfDirectory(at: payloadDir, includingPropertiesForKeys: nil)
        guard let appBundle = contents.first(where: { $0.pathExtension == "app" }) else {
            throw IPAImportError.appBundleMissing
        }
        let infoPlist = appBundle.appendingPathComponent("Info.plist")
        guard FileManager.default.fileExists(atPath: infoPlist.path) else {
            throw IPAImportError.infoPlistMissing
        }
        return IPAImportResult(
            tempDirectory: tempDir,
            payloadDirectory: payloadDir,
            appBundleURL: appBundle,
            infoPlistURL: infoPlist
        )
    }
}
