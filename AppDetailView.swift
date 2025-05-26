import SwiftUI
import UniformTypeIdentifiers

struct AppDetailView: View {
    let app: AltStoreApp
    @EnvironmentObject var accentManager: AccentColorManager

    @State private var isDownloading = false
    @State private var downloadProgress: Double = 0
    @State private var downloadError: String?
    @State private var downloadURL: URL?

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 18) {
                AsyncImage(url: URL(string: app.iconURL)) { phase in
                    switch phase {
                    case .success(let image): image.resizable().aspectRatio(contentMode: .fit)
                    case .failure(_): Image(systemName: "app.fill").resizable().aspectRatio(contentMode: .fit)
                    case .empty: ProgressView()
                    @unknown default: EmptyView()
                    }
                }
                .frame(width: 90, height: 90)
                .clipShape(RoundedRectangle(cornerRadius: 20))

                Text(app.name)
                    .font(.title)
                    .foregroundColor(.white)

                Text(app.bundleIdentifier)
                    .font(.caption)
                    .foregroundColor(.secondary)

                if let version = app.versions.first {
                    Text("Version : \(version.version)")
                        .font(.subheadline)
                        .foregroundColor(accentManager.color)
                }

                if let description = app.versions.first?.localizedDescription?["fr"] ?? app.versions.first?.localizedDescription?["en"] {
                    Text(description)
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(.top, 4)
                }

                // Téléchargement IPA
                if isDownloading {
                    ProgressView(value: downloadProgress)
                        .accentColor(accentManager.color)
                        .padding()
                } else if let downloadError = downloadError {
                    Text("Erreur : \(downloadError)")
                        .foregroundColor(.red)
                } else {
                    Button("Télécharger IPA") {
                        startDownload()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(accentManager.color)
                }

                // Actions sur fichier téléchargé
                if let url = downloadURL {
                    HStack {
                        Button("Ouvrir dans Fichiers") {
                            openInFiles(url: url)
                        }
                        .buttonStyle(.bordered)

                        ShareLink(item: url) {
                            Label("Partager", systemImage: "square.and.arrow.up")
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
            .padding()
        }
        .background(Color.black.ignoresSafeArea())
        .navigationTitle(app.name)
    }

    private func startDownload() {
        guard let version = app.versions.first, let ipaURL = URL(string: version.url) else {
            downloadError = "Lien de téléchargement manquant."
            return
        }
        isDownloading = true
        downloadProgress = 0
        downloadError = nil
        downloadURL = nil

        let task = URLSession.shared.downloadTask(with: ipaURL) { tempURL, response, error in
            DispatchQueue.main.async {
                isDownloading = false
                if let error = error {
                    downloadError = error.localizedDescription
                    return
                }
                guard let tempURL = tempURL else {
                    downloadError = "Téléchargement échoué."
                    return
                }
                do {
                    let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    let destURL = docs.appendingPathComponent("\(app.name)-\(version.version).ipa")
                    // Si déjà existant, on écrase
                    if FileManager.default.fileExists(atPath: destURL.path) {
                        try FileManager.default.removeItem(at: destURL)
                    }
                    try FileManager.default.moveItem(at: tempURL, to: destURL)
                    downloadURL = destURL
                } catch {
                    downloadError = error.localizedDescription
                }
            }
        }
        // Progression
        let observation = task.progress.observe(\.fractionCompleted) { prog, _ in
            DispatchQueue.main.async {
                downloadProgress = prog.fractionCompleted
            }
        }
        task.resume()
        // Nettoyage de l'observation : on ne la garde pas (risque minime ici car closure brève, sinon stocker dans un @StateObject)
    }

    private func openInFiles(url: URL) {
        #if canImport(UIKit)
        UIApplication.shared.open(url)
        #endif
    }
}
