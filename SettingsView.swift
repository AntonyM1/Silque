import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var accentManager: AccentColorManager

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "gearshape.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(accentManager.color)
                    .padding(.top, 24)
                Text("Réglages")
                    .font(.title2.weight(.bold))
                    .foregroundColor(.black)
                Spacer()
            }
        }
        .navigationTitle("Réglages")
    }
}
