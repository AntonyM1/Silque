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

    var filteredSources: [SourceItem] {
        if searchText.isEmpty { return sources }
        return sources.filter { $0.name.localizedCaseInsensitiveContains(searchText) || $0.url.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack(spacing: 8) {
                    // Barre de saisie
                    HStack(spacing: 6) {
                        HStack(spacing: 0) {
                            TextField("Nom de la source...", text: $newSourceName)
                                .font(.system(size: 15))
                                .foregroundColor(.white)
                                .placeholder(when: newSourceName.isEmpty) {
                                    Text("Nom de la source...")
                                        .foregroundColor(.white.opacity(0.4))
                                        .font(.system(size: 15))
                                }
                                .textFieldStyle(.plain)
                                .focused($isTextFieldFocused)
                                .frame(height: 30)
                            TextField("URL...", text: $newSourceURL)
                                .font(.system(size: 15))
                                .foregroundColor(.white)
                                .placeholder(when: newSourceURL.isEmpty) {
                                    Text("URL...")
                                        .foregroundColor(.white.opacity(0.4))
                                        .font(.system(size: 15))
                                }
                                .textFieldStyle(.plain)
                                .frame(height: 30)
                        }
                        .padding(.horizontal, 8)
                        .frame(height: 36)
                        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.black.opacity(0.8)))
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
                            .foregroundColor(.white.opacity(0.6))
                            .font(.system(size: 14))
                        TextField("Recherche de sources...", text: $searchText)
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .placeholder(when: searchText.isEmpty) {
                                Text("Recherche de sources...")
                                    .foregroundColor(.white.opacity(0.4))
                                    .font(.system(size: 14))
                            }
                            .textFieldStyle(.plain)
                            .opacity(0.8)
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color.black.opacity(0.8)))
                    .padding(.horizontal, 10)
                    // Liste
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(filteredSources) { source in
                                NavigationLink(destination: SourceAppsView(source: source)) {
                                    VisionOSCard {
                                        HStack(spacing: 12) {
                                            Image(systemName: "tray.full.fill")
                                                .font(.system(size: 22, weight: .semibold))
                                                .foregroundColor(accentManager.color)
                                                .frame(width: 30, height: 30)
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(source.name)
                                                    .font(.system(size: 15, weight: .semibold))
                                                    .foregroundColor(.white)
                                                Text(source.url)
                                                    .font(.system(size: 12))
                                                    .foregroundColor(.secondary)
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
                                    .padding(.horizontal, 4)
                                }
                            }
                        }
                    }
                    .padding(.top, 5)
                }
                .padding(.vertical, 6)
                .navigationTitle("Sources")
            }
        }
    }

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
}
