import Foundation

class PersistenceManager {
    static let shared = PersistenceManager()
    private init() {}

    private let appsFile = "apps.json"
    private let certificatesFile = "certificates.json"
    private let sourcesFile = "sources.json"

    // MARK: - Apps

    func saveApps(_ apps: [AppItem]) {
        let url = getDocumentsDirectory().appendingPathComponent(appsFile)
        do {
            let data = try JSONEncoder().encode(apps)
            try data.write(to: url)
        } catch {
            print("Erreur de sauvegarde des apps: \(error)")
        }
    }

    func loadApps() -> [AppItem] {
        let url = getDocumentsDirectory().appendingPathComponent(appsFile)
        guard let data = try? Data(contentsOf: url) else { return [] }
        return (try? JSONDecoder().decode([AppItem].self, from: data)) ?? []
    }

    // MARK: - Certificates

    func saveCertificates(_ certs: [CertificatePair]) {
        let url = getDocumentsDirectory().appendingPathComponent(certificatesFile)
        do {
            let data = try JSONEncoder().encode(certs)
            try data.write(to: url)
        } catch {
            print("Erreur de sauvegarde des certificats: \(error)")
        }
    }

    func loadCertificates() -> [CertificatePair] {
        let url = getDocumentsDirectory().appendingPathComponent(certificatesFile)
        guard let data = try? Data(contentsOf: url) else { return [] }
        return (try? JSONDecoder().decode([CertificatePair].self, from: data)) ?? []
    }

    // MARK: - Sources

    func saveSources(_ sources: [SourceItem]) {
        let url = getDocumentsDirectory().appendingPathComponent(sourcesFile)
        do {
            let data = try JSONEncoder().encode(sources)
            try data.write(to: url)
        } catch {
            print("Erreur de sauvegarde des sources: \(error)")
        }
    }

    func loadSources() -> [SourceItem] {
        let url = getDocumentsDirectory().appendingPathComponent(sourcesFile)
        guard let data = try? Data(contentsOf: url) else { return [] }
        return (try? JSONDecoder().decode([SourceItem].self, from: data)) ?? []
    }

    // MARK: - Helpers

    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
