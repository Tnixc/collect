import SwiftUI
import UniformTypeIdentifiers

struct AddURLSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    @State private var urlString = ""
    @State private var isDownloading = false
    @State private var downloadError: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Adds item to New category")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)

                Spacer()

                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 12)

            // Description
            Text(
                "At the moment you can add research as .PDFs or webpages. Links from popular research sharing sites are automatically downloaded as PDFs."
            )
            .font(.system(size: 13))
            .foregroundColor(AppTheme.textSecondary)
            .lineSpacing(4)
            .padding(.horizontal, 24)
            .padding(.bottom, 20)

            // URL Input
            HStack(spacing: 8) {
                TextField("https://arxiv.org/abs/1304.0445", text: $urlString)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.textPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(AppTheme.backgroundTertiary)
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(AppTheme.dividerColor, lineWidth: 1)
                    )
                    .disabled(isDownloading)

                UIButton(
                    action: {
                        if !urlString.isEmpty, !isDownloading {
                            downloadFile()
                        }
                    },
                    style: .primary,
                    label: "Add link",
                    icon: "link",
                    height: 36
                )
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)

            if let error = downloadError {
                Text(error)
                    .foregroundColor(.red)
                    .font(.system(size: 12))
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
            }

            if isDownloading {
                HStack(spacing: 8) {
                    ProgressView()
                        .scaleEffect(0.7)
                    Text("Downloading...")
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.textSecondary)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }

            // Separator text
            Text("or import a .pdf file from your computer")
                .font(.system(size: 12))
                .foregroundColor(AppTheme.textSecondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 12)

            // Drop area
            VStack(spacing: 12) {
                Text("Drag & drop .pdf files to add")
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.textSecondary)

                UIButton(
                    action: { selectFiles() },
                    style: .primary,
                    label: "Click to select",
                    icon: "folder"
                )
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
            .background(AppTheme.backgroundSecondary.opacity(0.5))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppTheme.dividerColor, lineWidth: 1)
            )
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                handleFileDrop(providers: providers)
            }
        }
        .frame(width: 600)
        .background(AppTheme.backgroundPrimary)
        .cornerRadius(12)
    }

    private func downloadFile() {
        guard let url = URL(string: urlString) else {
            downloadError = "Invalid URL"
            return
        }

        isDownloading = true
        downloadError = nil

        Task {
            do {
                let downloadedURL = try await DownloadService.shared
                    .downloadFile(
                        from: url,
                        to: SettingsSheet.getSourceDirectoryURL()!
                    )

                // Process the downloaded file
                let fileID = FileSystemService.shared.ensureFileID(
                    for: downloadedURL
                )
                let fileItem = FileItem(id: fileID, fileURL: downloadedURL)

                // Add to app state
                var files = appState.files
                files.append(fileItem)
                appState.setFiles(files)

                // Create initial metadata
                let filename = downloadedURL.lastPathComponent
                let metadata = MetadataService.shared.createMetadata(
                    fileID: fileID,
                    title: filename
                )
                appState.updateMetadata(for: fileID, metadata: metadata)

                // Open metadata editor
                // Note: This would need to be handled by the parent view
                // For now, just dismiss
                dismiss()

            } catch let error as DownloadService.DownloadError {
                switch error {
                case .curlNotFound:
                    downloadError = "curl is not available. This should not happen on macOS."
                case .downloadFailed:
                    downloadError = "Download failed. Please check the URL and try again."
                case .notAPDF:
                    downloadError = "The downloaded file is not a PDF. Please provide a direct link to a PDF file."
                }
                isDownloading = false
            } catch {
                downloadError = "Download failed: \(error.localizedDescription)"
                isDownloading = false
            }
        }
    }

    private func selectFiles() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [UTType.pdf]

        panel.begin { response in
            if response == .OK {
                for url in panel.urls {
                    do {
                        let copiedURL = try FileSystemService.shared.copyFile(from: url, to: SettingsSheet.getSourceDirectoryURL()!)

                        // Process the copied file
                        let fileID = FileSystemService.shared.ensureFileID(for: copiedURL)
                        let fileItem = FileItem(id: fileID, fileURL: copiedURL)

                        // Add to app state
                        var files = self.appState.files
                        files.append(fileItem)
                        self.appState.setFiles(files)

                        // Create initial metadata
                        let filename = copiedURL.lastPathComponent
                        let pages = FileSystemService.shared.getPageCount(for: copiedURL)
                        let metadata = MetadataService.shared.createMetadata(
                            fileID: fileID,
                            title: filename,
                            pages: pages
                        )
                        self.appState.updateMetadata(for: fileID, metadata: metadata)

                    } catch {
                        self.downloadError = "Failed to copy file: \(error.localizedDescription)"
                    }
                }
            }
        }
    }

    private func handleFileDrop(providers: [NSItemProvider]) -> Bool {
        guard let sourceDirectory = SettingsSheet.getSourceDirectoryURL() else {
            downloadError = "No source directory set"
            return false
        }

        for provider in providers {
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, error in
                guard let data = item as? Data,
                      let url = URL(dataRepresentation: data, relativeTo: nil),
                      url.pathExtension.lowercased() == "pdf"
                else {
                    return
                }

                DispatchQueue.main.async {
                    do {
                        let copiedURL = try FileSystemService.shared.copyFile(from: url, to: sourceDirectory)

                        // Process the copied file
                        let fileID = FileSystemService.shared.ensureFileID(for: copiedURL)
                        let fileItem = FileItem(id: fileID, fileURL: copiedURL)

                        // Add to app state
                        var files = self.appState.files
                        files.append(fileItem)
                        self.appState.setFiles(files)

                        // Create initial metadata
                        let filename = copiedURL.lastPathComponent
                        let pages = FileSystemService.shared.getPageCount(for: copiedURL)
                        let metadata = MetadataService.shared.createMetadata(
                            fileID: fileID,
                            title: filename,
                            pages: pages
                        )
                        self.appState.updateMetadata(for: fileID, metadata: metadata)

                    } catch {
                        self.downloadError = "Failed to copy file: \(error.localizedDescription)"
                    }
                }
            }
        }

        return true
    }
}
