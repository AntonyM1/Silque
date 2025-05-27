import SwiftUI

struct ProfileSheetView: View {
    @AppStorage("userFirstName") private var userFirstName: String = ""
    @EnvironmentObject var accentManager: AccentColorManager
    @FocusState private var isTextFieldFocused: Bool
    @State private var tempAccent: Color = .purple // valeur par défaut, sera synchronisée dans .onAppear

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 24) {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 70, height: 70)
                    .foregroundColor(accentManager.color)
                    .padding(.top, 24)

                Text(userFirstName.isEmpty ? "Profil" : userFirstName)
                    .font(.title2.weight(.bold))
                    .foregroundColor(.white)

                HStack {
                    TextField("Entrez votre prénom", text: $userFirstName)
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .placeholder(when: userFirstName.isEmpty) {
                            Text("Entrez votre prénom")
                                .foregroundColor(.white.opacity(0.4))
                                .font(.system(size: 18))
                        }
                        .textFieldStyle(.plain)
                        .focused($isTextFieldFocused)
                        .frame(height: 36)
                        .padding(.horizontal, 10)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.black.opacity(0.8)))
                }
                .padding(.horizontal, 16)

                // ===> Ajoute ceci pour choisir la couleur d’accent
                HStack {
                    Text("Couleur d’accent")
                        .foregroundColor(.white)
                    ColorPicker("", selection: $tempAccent, supportsOpacity: false)
                        .labelsHidden()
                        .onChange(of: tempAccent) { newColor in
                            accentManager.setAccentColor(newColor)
                        }
                }
                .padding(.horizontal, 16)

                Spacer()
            }
            .padding(.top, 32)
            .onAppear {
                tempAccent = accentManager.color
            }
        }
        .navigationTitle(userFirstName.isEmpty ? "Profil" : userFirstName)
    }
}
