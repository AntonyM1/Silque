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
    @State private var newAppName = ""
    @State private var newAppIcon = "app.fill"
    @State private var searchText = ""
    @FocusState private var isTextFieldFocused: Bool

    var filteredApps: [AppItem] {
        if searchText.isEmpty { return apps }
        return apps.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 8) {
                // Barre de saisie
                HStack(spacing: 6) {
                    HStack(spacing: 0) {
                        TextField("Nouvelle app...", text: $newAppName)
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                            .placeholder(when: newAppName.isEmpty) {
                                Text("Nouvelle app...")
                                    .foregroundColor(.white.opacity(0.4))
                                    .font(.system(size: 15))
                            }
                            .textFieldStyle(.plain)
                            .focused($isTextFieldFocused)
                            .frame(height: 30)
                        Menu {
                            ForEach(["app.fill", "note.text", "safari.fill", "envelope.fill", "star.fill", "music.note", "gamecontroller.fill"], id: \.self) { icon in
                                Button { newAppIcon = icon } label: {
                                    Label(icon, systemImage: icon)
                                }
                            }
                        } label: {
                            ZStack {
                                Circle().fill(Color.black.opacity(0.4)).frame(width: 24, height: 24)
                                Image(systemName: newAppIcon)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(accentManager.color)
                            }
                        }.buttonStyle(.plain)
                    }
                    .padding(.horizontal, 8)
                    .frame(height: 36)
                    .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.black.opacity(0.8)))
                    Button(action: addApp) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(accentManager.color)
                    }
                    .disabled(newAppName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(.horizontal, 10)
                .padding(.top, 6)
                // Barre de recherche
                HStack(spacing: 4) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white.opacity(0.6))
                        .font(.system(size: 14))
                    TextField("Recherche d'apps...", text: $searchText)
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .placeholder(when: searchText.isEmpty) {
                            Text("Recherche d'apps...")
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
                                        .foregroundColor(.white)
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

    private func addApp() {
        let name = newAppName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        let new = AppItem(name: name, icon: newAppIcon)
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            apps.insert(new, at: 0)
            newAppName = ""
            isTextFieldFocused = false
            PersistenceManager.shared.saveApps(apps)
        }
        haptics()
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
