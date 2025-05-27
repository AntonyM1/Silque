import SwiftUI

struct SourceItem: Identifiable, Equatable, Codable {
    let id: UUID
    let name: String
    let url: String

    init(id: UUID = UUID(), name: String, url: String) {
        self.id = id
        self.name = name
        self.url = url
    }
}

struct SourcesView: View {
    @EnvironmentObject var accentManager: AccentColorManager
    @State private var sources: [SourceItem] = PersistenceManager.shared.loadSources()
    @State private var newSourceName = ""
    @State private var newSourceURL = ""
    @State private var searchText = ""
    @FocusState private var isTextFieldFocused: Bool

    // Pour navigation
    @State private var selectedSource: SourceItem?
    @State private var loadedRepository: AltStoreRepository?
    @State private var isRepoLoading = false
    @State private var repoError: String?

    // Pour navigation vers détail app
    @State private var selectedApp: AltStoreApp?

    var filteredSources: [SourceItem] {
        if searchText.isEmpty { return sources }
        return sources.filter { $0.name.localizedCaseInsensitiveContains(searchText) || $0.url.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                VStack(spacing: 8) {
                    // Barre d’ajout
                    HStack(spacing: 6) {
                        HStack(spacing: 0) {
                            TextField("Nom de la source...", text: $newSourceName)
                                .font(.system(size: 15))
                                .foregroundColor(.black)
                                .placeholder(when: newSourceName.isEmpty) {
                                    Text("Nom de la source...")
                                        .foregroundColor(.black.opacity(0.3))
                                        .font(.system(size: 15))
                                }
                                .textFieldStyle(.plain)
                                .focused($isTextFieldFocused)
                                .frame(height: 30)
                            TextField("URL...", text: $newSourceURL)
                                .font(.system(size: 15))
                                .foregroundColor(.black)
                                .placeholder(when: newSourceURL.isEmpty) {
                                    Text("URL...")
                                        .foregroundColor(.black.opacity(0.3))
                                        .font(.system(size: 15))
                                }
                                .textFieldStyle(.plain)
                                .frame(height: 30)
                        }
                        .padding(.horizontal, 8)
                        .frame(height: 36)
                        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.gray.opacity(0.12)))
                        Button(action: addSource) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(accentManager.color)
                        }
                        .disabled(newSourceName.trimmingCharacters(in: .whitespaces).isEmpty || newSourceURL.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                    .padding(.horizontal, 10)
                    .padding(.top, 6)

                    // Barre de recherche
                    HStack(spacing: 4) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .font(.system(size: 14))
                        TextField("Recherche de sources...", text: $searchText)
                            .font(.system(size: 14))
                            .foregroundColor(.black)
                            .placeholder(when: searchText.isEmpty) {
                                Text("Recherche de sources...")
                                    .foregroundColor(.black.opacity(0.3))
                                    .font(.system(size: 14))
                            }
                            .textFieldStyle(.plain)
                            .opacity(0.9)
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color.gray.opacity(0.12)))
                    .padding(.horizontal, 10)

                    // Liste des sources
                    List {
                        ForEach(filteredSources) { source in
                            Button(action: {
                                selectedSource = source
                                fetchRepository(for: source)
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "tray.full.fill")
                                        .font(.system(size: 22, weight: .semibold))
                                        .foregroundColor(accentManager.color)
                                        .frame(width: 30, height: 30)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(source.name)
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(.black)
                                        Text(source.url)
                                            .font(.system(size: 12))
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Button(action: { removeSource(source) }) {
                                        Image(systemName: "trash")
                                            .font(.system(size: 17, weight: .regular))
                                            .foregroundColor(.red)
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityLabel("Supprimer \(source.name)")
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 7)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .background(Color.white)
                }
                .padding(.vertical, 6)
                .navigationTitle("Sources")
                // Navigation vers Apps d’une source
                .sheet(item: $selectedSource) { source in
                    VStack {
                        if isRepoLoading {
                            ProgressView("Chargement…")
                                .foregroundColor(.black)
                        } else if let error = repoError {
                            VStack(spacing: 16) {
                                Text("Erreur : \(error)")
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                                Button("Réessayer") { fetchRepository(for: source) }
                                    .foregroundColor(accentManager.color)
                            }
                        } else if let repo = loadedRepository {
                            List(repo.apps) { app in
                                Button(action: {
                                    selectedApp = app
                                }) {
                                    HStack(spacing: 14) {
                                        AsyncImage(url: URL(string: app.iconURL)) { phase in
                                            switch phase {
                                            case .success(let image): image.resizable().aspectRatio(contentMode: .fit)
                                            case .failure(_): Image(systemName: "app.fill").resizable().aspectRatio(contentMode: .fit)
                                            case .empty: ProgressView()
                                            @unknown default: EmptyView()
                                            }
                                        }
                                        .frame(width: 42, height: 42)
                                        .clipShape(RoundedRectangle(cornerRadius: 9))
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(app.name).font(.headline).foregroundColor(.black)
                                            Text(app.bundleIdentifier).font(.caption2).foregroundColor(.gray)
                                            if let version = app.versions.first?.version {
                                                Text("Dernière version : \(version)").font(.caption2).foregroundColor(.accentColor)
                                            }
                                        }
                                        Spacer()
                                    }
                                    .padding(.vertical, 5)
                                }
                                .sheet(item: $selectedApp) { app in
                                    AppDetailView(app: app)
                                }
                            }
                            .listStyle(.plain)
                            .background(Color.white)
                            .navigationTitle(repo.name)
                        }
                    }
                    .padding()
                    .background(Color.white.ignoresSafeArea())
                }
            }
        }
    }

    // MARK: - Fonctions

    private func addSource() {
        let name = newSourceName.trimmingCharacters(in: .whitespaces)
        let url = newSourceURL.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty && !url.isEmpty else { return }
        let new = SourceItem(name: name, url: url)
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            sources.insert(new, at: 0)
            newSourceName = ""
            newSourceURL = ""
            isTextFieldFocused = false
            PersistenceManager.shared.saveSources(sources)
        }
        haptics()
    }

    private func removeSource(_ source: SourceItem) {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            sources.removeAll { $0 == source }
            PersistenceManager.shared.saveSources(sources)
        }
        haptics()
    }

    private func haptics() {
        #if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        #endif
    }

    private func fetchRepository(for source: SourceItem) {
        repoError = nil
        isRepoLoading = true
        loadedRepository = nil
        guard let url = URL(string: source.url) else {
            repoError = "URL invalide"
            isRepoLoading = false
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isRepoLoading = false
                if let error = error {
                    repoError = error.localizedDescription
                    return
                }
                guard let data = data else {
                    repoError = "Pas de données reçues"
                    return
                }
                do {
                    let repo = try JSONDecoder().decode(AltStoreRepository.self, from: data)
                    loadedRepository = repo
                } catch {
                    repoError = "Impossible de lire le dépôt : \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}


