import SwiftUI
import UniformTypeIdentifiers

struct CertificatePair: Identifiable, Equatable, Codable {
    let id: UUID
    let p12URL: URL
    let mobileprovisionURL: URL

    init(id: UUID = UUID(), p12URL: URL, mobileprovisionURL: URL) {
        self.id = id
        self.p12URL = p12URL
        self.mobileprovisionURL = mobileprovisionURL
    }
}

enum CertImportStep: Identifiable {
    case p12
    case mobileprovision(URL)
    var id: String {
        switch self {
        case .p12: return "p12"
        case .mobileprovision: return "mobileprovision"
        }
    }
}

struct CertificatesView: View {
    @EnvironmentObject var accentManager: AccentColorManager
    @State private var certificates: [CertificatePair] = PersistenceManager.shared.loadCertificates()
    @State private var importStep: CertImportStep? = nil
    @State private var searchText = ""

    var filteredCertificates: [CertificatePair] {
        if searchText.isEmpty { return certificates }
        return certificates.filter {
            $0.p12URL.lastPathComponent.localizedCaseInsensitiveContains(searchText)
            || $0.mobileprovisionURL.lastPathComponent.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 16) {
                Button(action: {
                    importStep = .p12
                }) {
                    HStack {
                        Image(systemName: "doc.badge.plus")
                            .font(.system(size: 20, weight: .semibold))
                        Text("Importer un couple certificat (.p12) + profil (.mobileprovision)")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(accentManager.color)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.black.opacity(0.8)))
                }

                // Barre de recherche
                HStack(spacing: 4) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white.opacity(0.6))
                        .font(.system(size: 14))
                    TextField("Recherche...", text: $searchText)
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .placeholder(when: searchText.isEmpty) {
                            Text("Recherche...")
                                .foregroundColor(.white.opacity(0.4))
                                .font(.system(size: 14))
                        }
                        .textFieldStyle(.plain)
                        .opacity(0.8)
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.black.opacity(0.8)))
                .padding(.horizontal, 10)

                // Liste des couples
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(filteredCertificates) { pair in
                            VisionOSCard {
                                HStack(spacing: 12) {
                                    Image(systemName: "doc.on.doc.fill")
                                        .font(.system(size: 22, weight: .semibold))
                                        .foregroundColor(accentManager.color)
                                        .frame(width: 30, height: 30)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(pair.p12URL.lastPathComponent)
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(.white)
                                        Text(pair.mobileprovisionURL.lastPathComponent)
                                            .font(.system(size: 13))
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                    Spacer()
                                    Button(action: { removeCertificate(pair) }) {
                                        Image(systemName: "trash")
                                            .font(.system(size: 17, weight: .regular))
                                            .foregroundColor(.red)
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityLabel("Supprimer le couple")
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 7)
                            }
                            .padding(.horizontal, 4)
                        }
                    }
                }
                .padding(.top, 5)
            }
            .padding(.vertical, 8)
            .navigationTitle("Certificats & Profils")
        }
        // Séquence d’import avec .sheet
        .sheet(item: $importStep) { step in
            switch step {
            case .p12:
                DocumentPicker(allowedTypes: ["p12"]) { url in
                    if let url = url {
                        importStep = .mobileprovision(url)
                    } else {
                        importStep = nil
                    }
                }
            case .mobileprovision(let p12url):
                DocumentPicker(allowedTypes: ["mobileprovision"]) { provisionURL in
                    if let provisionURL = provisionURL {
                        let newPair = CertificatePair(p12URL: p12url, mobileprovisionURL: provisionURL)
                        certificates.insert(newPair, at: 0)
                        PersistenceManager.shared.saveCertificates(certificates)
                    }
                    importStep = nil
                }
            }
        }
    }

    private func removeCertificate(_ pair: CertificatePair) {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            certificates.removeAll { $0 == pair }
            PersistenceManager.shared.saveCertificates(certificates)
        }
        haptics()
    }

    private func haptics() {
        #if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        #endif
    }
}

// Picker générique utilisable en .sheet pour contourner les soucis de fileImporter
struct DocumentPicker: UIViewControllerRepresentable {
    var allowedTypes: [String]
    var completion: (URL?) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let utis = allowedTypes.compactMap { UTType(filenameExtension: $0)?.identifier }
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: utis.compactMap { UTType($0) })
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker
        init(parent: DocumentPicker) { self.parent = parent }
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.completion(urls.first)
        }
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.completion(nil)
        }
    }
}
