import SwiftUI

struct MainView: View {
    @State private var selectedTab: Tab = .apps
    @StateObject var accentManager = AccentColorManager()

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.ignoresSafeArea()
            Group {
                switch selectedTab {
                case .apps: AppsView().environmentObject(accentManager)
                case .sources: SourcesView().environmentObject(accentManager)
                case .certificates: CertificatesView().environmentObject(accentManager)
                case .signing: SigningView().environmentObject(accentManager)
                case .ota: OTAInstallationView().environmentObject(accentManager)
                case .profile: ProfileSheetView().environmentObject(accentManager)
                case .settings: SettingsView().environmentObject(accentManager)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.clear)
            FloatingTabBar(selectedTab: $selectedTab)
                .environmentObject(accentManager)
        }
        .ignoresSafeArea(.keyboard)
    }
}
