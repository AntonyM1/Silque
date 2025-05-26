import SwiftUI
import UniformTypeIdentifiers

struct SigningTaskItem: Identifiable, Equatable {
    let id = UUID()
    let ipaName: String
    let certificate: String
    let status: String
}

struct SigningView: View {
    @EnvironmentObject var accentManager: AccentColorManager
    @State private var tasks: [SigningTaskItem] = []
    @State private var availableCerts: [String] = ["Antony Dev", "Test Cert"]
    @State private var selectedCert: String = ""
    @State private var ipaURL: URL?
    @State private var showFileImporter = false
    @State private var statusMessage = ""

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 12) {
                HStack {
                    Button {
                        showFileImporter = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "square.and.arrow.down")
                                .font(.system(size: 16, weight: .medium))
                            Text(ipaURL != nil ? ipaURL!.lastPathComponent : "Importer une IPA")
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color.black.opacity(0.8)))
                    }
                    .buttonStyle(.plain)
                    .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [UTType(filenameExtension: "ipa")!], allowsMultipleSelection: false) { result in
                        switch result {
                        case .success(let urls):
                            ipaURL = urls.first
                        case .failure(_):
                            ipaURL = nil
                        }
                    }

                    Picker("Certificat", selection: $selectedCert) {
                        ForEach(availableCerts, id: \.self) { cert in
                            Text(cert)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 140)
                    .padding(.horizontal, 4)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.black.opacity(0.8)))
                    .foregroundColor(.white)

                    Button(action: addSignTask) {
                        Image(systemName: "wand.and.stars")
                            .font(.system(size: 19, weight: .bold))
                            .foregroundColor(accentManager.color)
                    }
                    .disabled(ipaURL == nil || selectedCert.isEmpty)
                }
                .padding(.horizontal, 10)
                .padding(.top, 6)

                if !statusMessage.isEmpty {
                    Text(statusMessage)
                        .font(.footnote)
                        .foregroundColor(accentManager.color)
                        .padding(.bottom, 2)
                }

                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(tasks) { task in
                            VisionOSCard {
                                HStack(spacing: 12) {
                                    Image(systemName: "wand.and.stars")
                                        .font(.system(size: 22, weight: .semibold))
                                        .foregroundColor(accentManager.color)
                                        .frame(width: 28, height: 28)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(task.ipaName)
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(.white)
                                        Text("Cert: \(task.certificate)")
                                            .font(.system(size: 12))
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Text(task.status)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(task.status == "Terminé" ? .green : .orange)
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
            .navigationTitle("Signer une IPA")
        }
    }

    private func addSignTask() {
        guard let ipaURL, !selectedCert.isEmpty else { return }
        let newTask = SigningTaskItem(ipaName: ipaURL.lastPathComponent, certificate: selectedCert, status: "Terminé")
        withAnimation(.spring(response: 0.6, dampingFraction: 0.85)) {
            tasks.insert(newTask, at: 0)
            statusMessage = "Signature IPA simulée !"
        }
        self.ipaURL = nil
        self.selectedCert = ""
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { statusMessage = "" }
    }
}
