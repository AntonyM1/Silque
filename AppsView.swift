import SwiftUI

struct AppItem: Identifiable, Equatable, Codable {
    let id: UUID
    let name: String
    let icon: String

    init(id: UUID = UUID(), name: String, icon: String) {
        self.id = id
        self.name = name
        self.icon = icon
    }
}

struct AppsView: View {
    @EnvironmentObject var accentManager: AccentColorManager
    @State private var apps: [AppItem] = PersistenceManager.shared.loadApps()
    @State private var searchText = ""

    var filteredApps: [AppItem] {
        if searchText.isEmpty { return apps }
        return apps.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack(spacing: 8) {
                // Barre de recherche
                HStack(spacing: 4) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .font(.system(size: 14))
                    TextField("Recherche d'apps...", text: $searchText)
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                        .placeholder(when: searchText.isEmpty) {
                            Text("Recherche d'apps...")
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
                // Liste d'apps
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(filteredApps) { app in
                            VisionOSCard {
                                HStack(spacing: 12) {
                                    Image(systemName: app.icon)
                                        .font(.system(size: 22, weight: .semibold))
                                        .foregroundColor(colorForAppIcon(app.icon))
                                        .frame(width: 30, height: 30)
                                    Text(app.name)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.black)
                                    Spacer()
                                    Button(action: { removeApp(app) }) {
                                        Image(systemName: "trash")
                                            .font(.system(size: 17, weight: .regular))
                                            .foregroundColor(.red)
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityLabel("Supprimer \(app.name)")
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 7)
                            }
                            .transition(.scale.combined(with: .opacity))
                            .padding(.horizontal, 4)
                        }
                    }
                }
                .padding(.top, 5)
            }
            .padding(.vertical, 6)
            .navigationTitle("Apps")
        }
    }

    private func removeApp(_ app: AppItem) {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            apps.removeAll { $0 == app }
            PersistenceManager.shared.saveApps(apps)
        }
        haptics()
    }

    private func colorForAppIcon(_ icon: String) -> Color {
        switch icon {
        case "safari.fill": return .blue
        case "note.text": return .yellow
        case "envelope.fill": return .blue
        default: return accentManager.color
        }
    }

    private func haptics() {
        #if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        #endif
    }
}
