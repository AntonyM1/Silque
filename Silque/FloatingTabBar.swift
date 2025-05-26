import SwiftUI

enum Tab: Int, CaseIterable {
    case apps, sources, certificates, signing, ota, profile, settings
}

struct FloatingTabBar: View {
    @Binding var selectedTab: Tab
    @EnvironmentObject var accentManager: AccentColorManager

    var body: some View {
        HStack(spacing: 0) {
            tabButton(tab: .apps, icon: "app.fill", label: "Apps")
            tabButton(tab: .sources, icon: "tray.full.fill", label: "Sources")
            tabButton(tab: .certificates, icon: "doc.badge.plus", label: "Certificats")
            tabButton(tab: .signing, icon: "wand.and.stars", label: "Signer")
            tabButton(tab: .ota, icon: "antenna.radiowaves.left.and.right", label: "OTA")
            tabButton(tab: .profile, icon: "person.crop.circle.fill", label: "Moi")
            tabButton(tab: .settings, icon: "gearshape.fill", label: "Réglages")
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 3)
        )
        .padding(.horizontal, 8)
        .padding(.bottom, 10)
    }

    @ViewBuilder
    private func tabButton(tab: Tab, icon: String, label: String) -> some View {
        Button {
            withAnimation(.easeOut(duration: 0.12)) { selectedTab = tab }
        } label: {
            VStack(spacing: 2) {
                ZStack {
                    if selectedTab == tab {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(accentManager.color.opacity(0.17))
                            .frame(width: 32, height: 32)
                            .blur(radius: 0.5)
                    }
                    Image(systemName: icon)
                        .font(.system(size: selectedTab == tab ? 20 : 17, weight: .bold))
                        .foregroundColor(selectedTab == tab ? accentManager.color : .secondary)
                }
                Text(label)
                    .font(.caption2)
                    .foregroundColor(selectedTab == tab ? accentManager.color : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 2)
        }
        .buttonStyle(.plain)
    }
}
