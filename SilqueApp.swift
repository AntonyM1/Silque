import SwiftUI

@main
struct SilqueApp: App {
    @StateObject var accentManager = AccentColorManager()
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(accentManager)
        }
    }
}
