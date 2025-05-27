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
    @State private var ipaImportResult: IPAImportResult? = nil
    @State private var showFileImporter = false
    @State private var statusMessage = ""
    @State private var appDisplayName: String = ""
    @State private var appBundleID: String = ""
    @State private var originalIcon: UIImage? = nil
    @State private var newIcon: UIImage? = nil
    @State private var showIconPicker = false

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack(spacing: 18) {
                HStack(spacing: 18) {
                    Button {
                        showFileImporter = true
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color(UIColor.systemGray6))
                                .frame(width: 36, height: 36)
                            Image(systemName: ipaImportResult != nil ? "doc.circle.fill" : "plus.circle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 26, height: 26)
                                .foregroundColor(accentManager.color)
                        }
                    }
                    .buttonStyle(.plain)
                    .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [UTType(filenameExtension: "ipa")!], allowsMultipleSelection: false) { result in
                        switch result {
                        case .success(let urls):
                            if let url = urls.first {
                                do {
                                    let importResult = try IPAImporter.extractIPA(at: url)
                                    ipaImportResult = importResult
                                    ipaURL = url
                                    if let plistEditor = try? PlistEditor(plistURL: importResult.infoPlistURL) {
                                        appDisplayName = plistEditor.value(forKey: "CFBundleDisplayName") ??
                                                         plistEditor.value(forKey: "CFBundleName") ?? ""
                                        appBundleID = plistEditor.value(forKey: "CFBundleIdentifier") ?? ""
                                    }
                                    originalIcon = IconExtractor.extractIcon(from: importResult.appBundleURL)
                                    newIcon = nil
                                    statusMessage = "Importation réussie !"
                                } catch {
                                    ipaImportResult = nil
                                    ipaURL = nil
                                    statusMessage = "Erreur d'importation IPA : \(error.localizedDescription)"
                                }
                            } else {
                                ipaImportResult = nil
                                ipaURL = nil
                                statusMessage = "Aucun fichier sélectionné."
                            }
                        case .failure(_):
                            ipaImportResult = nil
                            ipaURL = nil
                            statusMessage = "Importation annulée."
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
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color(UIColor.systemGray6)))
                    .foregroundColor(.black)

                    Button(action: addSignTask) {
                        Image(systemName: "wand.and.stars")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(accentManager.color)
                            .padding(10)
                            .background(
                                Circle()
                                    .fill(Color(UIColor.systemGray6))
                            )
                    }
                    .disabled(ipaImportResult == nil || selectedCert.isEmpty)
                }
                .padding(.horizontal, 10)
                .padding(.top, 10)

                if !statusMessage.isEmpty {
                    Text(statusMessage)
                        .font(.footnote)
                        .foregroundColor(accentManager.color)
                        .padding(.bottom, 2)
                }

                // Zone de modification du nom, bundle id et de l'icône
                if ipaImportResult != nil {
                    VStack(spacing: 16) {
                        HStack {
                            Text("Nom de l'app :")
                                .foregroundColor(.black)
                            TextField("Nom de l'app", text: $appDisplayName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 170)
                                .onChange(of: appDisplayName) { _ in
                                    updateDisplayName()
                                }
                        }
                        HStack {
                            Text("Bundle ID :")
                                .foregroundColor(.black)
                            TextField("com.exemple.app", text: $appBundleID)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 170)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .onChange(of: appBundleID) { _ in
                                    updateBundleID()
                                }
                        }
                        HStack {
                            Text("Icône :")
                                .foregroundColor(.black)
                            ZStack {
                                if let icon = newIcon ?? originalIcon {
                                    Image(uiImage: icon)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 54, height: 54)
                                        .cornerRadius(12)
                                        .shadow(radius: 1)
                                } else {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.15))
                                        .frame(width: 54, height: 54)
                                        .cornerRadius(12)
                                }
                                Button(action: { showIconPicker = true }) {
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(accentManager.color, lineWidth: 1.5)
                                        .frame(width: 54, height: 54)
                                        .background(Color.clear)
                                }
                                .buttonStyle(.plain)
                            }
                            Text("Changer")
                                .foregroundColor(accentManager.color)
                                .font(.system(size: 14, weight: .medium))
                                .onTapGesture { showIconPicker = true }
                        }
                    }
                    .padding(.horizontal, 14)
                }

                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(tasks) { task in
                            VisionOSCard {
                                HStack(spacing: 12) {
                                    Image(systemName: "wand.and.stars")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(accentManager.color)
                                        .frame(width: 26, height: 26)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(task.ipaName)
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(.black)
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
            .padding(.vertical, 10)
            .navigationTitle("Signer une IPA")
            .sheet(isPresented: $showIconPicker) {
                IconPickerSheet { selectedImage in
                    if let img = selectedImage {
                        newIcon = img
                        updateIcon(img)
                    }
                    showIconPicker = false
                }
            }
        }
    }

    private func updateDisplayName() {
        guard let ipaImportResult else { return }
        do {
            let plistEditor = try PlistEditor(plistURL: ipaImportResult.infoPlistURL)
            plistEditor.setValue(appDisplayName, forKey: "CFBundleDisplayName")
            try plistEditor.save()
        } catch {
            statusMessage = "Erreur lors du changement de nom : \(error.localizedDescription)"
        }
    }

    private func updateBundleID() {
        guard let ipaImportResult else { return }
        do {
            let plistEditor = try PlistEditor(plistURL: ipaImportResult.infoPlistURL)
            plistEditor.setValue(appBundleID, forKey: "CFBundleIdentifier")
            try plistEditor.save()
        } catch {
            statusMessage = "Erreur lors du changement du bundle id : \(error.localizedDescription)"
        }
    }

    private func updateIcon(_ image: UIImage) {
        guard let ipaImportResult else { return }
        do {
            try IconReplacer.replaceIcon(in: ipaImportResult.appBundleURL, with: image)
        } catch {
            statusMessage = "Erreur lors du changement d'icône : \(error.localizedDescription)"
        }
    }

    private func addSignTask() {
        guard let ipaURL, let _ = ipaImportResult, !selectedCert.isEmpty else { return }
        let newTask = SigningTaskItem(ipaName: ipaURL.lastPathComponent, certificate: selectedCert, status: "Terminé")
        withAnimation(.spring(response: 0.6, dampingFraction: 0.85)) {
            tasks.insert(newTask, at: 0)
            statusMessage = "Signature IPA simulée !"
        }
        self.ipaURL = nil
        self.ipaImportResult = nil
        self.selectedCert = ""
        self.appDisplayName = ""
        self.appBundleID = ""
        self.originalIcon = nil
        self.newIcon = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { statusMessage = "" }
    }
}
