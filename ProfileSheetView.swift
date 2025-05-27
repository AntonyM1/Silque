import SwiftUI

struct ProfileSheetView: View {
    @EnvironmentObject var accentManager: AccentColorManager
    @State private var showColorPicker = false
    @State private var tempColor: Color = .accentColor

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(accentManager.color)
                    .padding(.top, 35)
                Text("Mon profil")
                    .font(.title2.weight(.bold))
                    .foregroundColor(.black)

                Button {
                    tempColor = accentManager.color
                    showColorPicker = true
                } label: {
                    Text("Personnaliser la couleur d'accent")
                        .font(.system(size: 15, weight: .medium))
                        .padding(.vertical, 7)
                        .padding(.horizontal, 18)
                        .background(RoundedRectangle(cornerRadius: 12).fill(accentManager.color.opacity(0.2)))
                        .foregroundColor(accentManager.color)
                }
                .sheet(isPresented: $showColorPicker) {
                    VStack(spacing: 18) {
                        Text("Choisir une couleur")
                            .font(.headline)
                            .foregroundColor(.black)
                        ColorPicker("Accent", selection: $tempColor, supportsOpacity: false)
                            .padding()
                        Button("Appliquer") {
                            accentManager.setAccentColor(tempColor)
                            showColorPicker = false
                        }
                        .font(.headline)
                        .foregroundColor(tempColor)
                        .padding(.bottom, 18)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white.ignoresSafeArea())
                }

                Spacer()
            }
        }
        .navigationTitle("Moi")
    }
}
