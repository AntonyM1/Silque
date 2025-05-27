import SwiftUI

struct OTAInstallationItem: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let link: String
}

struct OTAInstallationView: View {
    @EnvironmentObject var accentManager: AccentColorManager
    @State private var installations: [OTAInstallationItem] = []
    @State private var newInstallName = ""
    @State private var newInstallLink = ""
    @State private var searchText = ""
    @FocusState private var isTextFieldFocused: Bool

    var filteredInstallations: [OTAInstallationItem] {
        if searchText.isEmpty { return installations }
        return installations.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.link.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack(spacing: 8) {
                HStack(spacing: 6) {
                    HStack(spacing: 0) {
                        TextField("Nom...", text: $newInstallName)
                            .font(.system(size: 15))
                            .foregroundColor(.black)
                            .placeholder(when: newInstallName.isEmpty) {
                                Text("Nom...")
                                    .foregroundColor(.black.opacity(0.3))
                                    .font(.system(size: 15))
                            }
                            .textFieldStyle(.plain)
                            .focused($isTextFieldFocused)
                            .frame(height: 30)
                        TextField("Lien OTA...", text: $newInstallLink)
                            .font(.system(size: 15))
                            .foregroundColor(.black)
                            .placeholder(when: newInstallLink.isEmpty) {
                                Text("Lien OTA...")
                                    .foregroundColor(.black.opacity(0.3))
                                    .font(.system(size: 15))
                            }
                            .textFieldStyle(.plain)
                            .frame(height: 30)
                    }
                    .padding(.horizontal, 8)
                    .frame(height: 36)
                    .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.gray.opacity(0.12)))
                    Button(action: addInstallation) {
                        Image(systemName: "plus.circle.fill").font(.system(size: 20, weight: .semibold)).foregroundColor(accentManager.color)
                    }
                    .disabled(newInstallName.trimmingCharacters(in: .whitespaces).isEmpty || newInstallLink.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(.horizontal, 10)
                .padding(.top, 6)
                HStack(spacing: 4) {
                    Image(systemName: "magnifyingglass").foregroundColor(.gray).font(.system(size: 14))
                    TextField("Recherche d'installations...", text: $searchText)
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                        .placeholder(when: searchText.isEmpty) {
                            Text("Recherche d'installations...")
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
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(filteredInstallations) { inst in
                            VisionOSCard {
                                HStack(spacing: 12) {
                                    Image(systemName: "antenna.radiowaves.left.and.right")
                                        .font(.system(size: 22, weight: .semibold))
                                        .foregroundColor(accentManager.color)
                                        .frame(width: 30, height: 30)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(inst.name)
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(.black)
                                        Text(inst.link)
                                            .font(.system(size: 12))
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Button(action: { removeInstallation(inst) }) {
                                        Image(systemName: "trash")
                                            .font(.system(size: 17, weight: .regular))
                                            .foregroundColor(.red)
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityLabel("Supprimer \(inst.name)")
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
            .padding(.vertical, 6)
            .navigationTitle("Installation OTA")
        }
    }

    private func addInstallation() {
        let name = newInstallName.trimmingCharacters(in: .whitespaces)
        let link = newInstallLink.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty && !link.isEmpty else { return }
        let new = OTAInstallationItem(name: name, link: link)
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            installations.insert(new, at: 0)
            newInstallName = ""
            newInstallLink = ""
            isTextFieldFocused = false
        }
        haptics()
    }

    private func removeInstallation(_ inst: OTAInstallationItem) {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            installations.removeAll { $0 == inst }
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
