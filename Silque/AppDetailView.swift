//
//  AppDetailView.swift
//  Silque
//
//  Created by Antony Marcelino on 26/05/2025.
//


import SwiftUI

struct AppDetailView: View {
    let app: AltStoreApp
    @EnvironmentObject var accentManager: AccentColorManager
    @State private var isDownloading = false
    @State private var progress: Double = 0
    @State private var downloadError: String?
    @State private var ipaURL: URL?

    var latestVersion: AltStoreAppVersion? {
        app.versions.first
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 18) {
                AsyncImage(url: URL(string: app.iconURL)) { phase in
                    switch phase {
                    case .success(let image): image.resizable().aspectRatio(contentMode: .fit)
                    case .failure(_): Image(systemName: "app.fill").resizable().aspectRatio(contentMode: .fit)
                    case .empty: ProgressView()
                    @unknown default: EmptyView()
                    }
                }
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                Text(app.name)
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                Text(app.bundleIdentifier)
                    .font(.caption)
                    .foregroundColor(.secondary)

                if let latest = latestVersion {
                    Text("Version \(latest.version)")
                        .font(.headline)
                        .foregroundColor(accentManager.color)
                    if let desc = latest.localizedDescription?["fr"] ?? latest.localizedDescription?["en"] {
                        Text(desc)
                            .foregroundColor(.white)
                            .padding(.top, 4)
                    }
                }

                Spacer()

                if let downloadError = downloadError {
                    Text("Erreur: \(downloadError)")
                        .foregroundColor(.red)
                }
                if isDownloading {
                    ProgressView(value: progress)
                        .progressViewStyle(.linear)
                        .frame(width: 180)
                    Text("Téléchargement…")
                        .foregroundColor(.white)
                } else {
                    Button {
                        if let ipaURLString = latestVersion?.url {
                            downloadIPA(from: ipaURLString)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "arrow.down.circle.fill")
                            Text("Télécharger IPA")
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).fill(accentManager.color))
                        .foregroundColor(.white)
                        .font(.headline)
                    }
                }

                if let ipaURL = ipaURL {
                    Text("IPA téléchargée : \(ipaURL.lastPathComponent)")
                        .foregroundColor(.green)
                        .font(.caption)
                        .padding(.top, 6)
                    Button {
                        // TODO : Intégrer action d'ouverture ou de signature
                    } label: {
                        Text("Ouvrir dans Files")
                    }
                    .foregroundColor(accentManager.color)
                }

                Spacer()
            }
            .padding()
            .navigationTitle(app.name)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func downloadIPA(from urlString: String) {
        guard let url = URL(string: urlString) else {
            downloadError = "URL IPA invalide"
            return
        }
        isDownloading = true
        progress = 0
        downloadError = nil
        ipaURL = nil

        let fileName = url.lastPathComponent
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destURL = docs.appendingPathComponent(fileName)

        let task = URLSession.shared.downloadTask(with: url) { tempURL, response, error in
            DispatchQueue.main.async {
                isDownloading = false
                if let error = error {
                    downloadError = error.localizedDescription
                    return
                }
                guard let tempURL = tempURL else {
                    downloadError = "Erreur lors du téléchargement"
                    return
                }
                do {
                    if FileManager.default.fileExists(atPath: destURL.path) {
                        try FileManager.default.removeItem(at: destURL)
                    }
                    try FileManager.default.moveItem(at: tempURL, to: destURL)
                    ipaURL = destURL
                } catch {
                    downloadError = "Impossible de sauvegarder le fichier : \(error.localizedDescription)"
                }
            }
        }

        task.resume()

        // Progression
        let observation = task.progress.observe(\.fractionCompleted) { prog, _ in
            DispatchQueue.main.async {
                progress = prog.fractionCompleted
            }
        }
        // Nettoyage (optionnel : à gérer si tu veux éviter les fuites mémoire)
        // Tu peux stocker l'observation dans une property si tu veux la relâcher plus tard.
    }
}