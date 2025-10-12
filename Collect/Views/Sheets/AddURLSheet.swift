import SwiftUI

struct AddURLSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    @State private var urlString = ""
    @State private var isDownloading = false
    @State private var downloadError: String?

    var body: some View {
        VStack(spacing: 20) {
            Text("Add from URL")
                .font(.title)
                .padding(.top)

            VStack(alignment: .leading, spacing: 10) {
                Text("URL")
                    .font(.headline)

                TextField("Enter URL to download", text: $urlString)
                    .textFieldStyle(.roundedBorder)
                    .disabled(isDownloading)
            }
            .padding(.horizontal)

            if let error = downloadError {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }

            if isDownloading {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Downloading...")
                        .font(.body)
                }
                .padding(.vertical, 10)
            }

            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                .disabled(isDownloading)

                Spacer()

                Button("Download") {
                    downloadFile()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(urlString.isEmpty || isDownloading)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .frame(width: 400, height: 200)
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
                let downloadedURL = try await DownloadService.shared.downloadFile(from: url, to: SettingsSheet.getSourceDirectoryURL()!)

                // Process the downloaded file
                let fileID = FileSystemService.shared.ensureFileID(for: downloadedURL)
                let fileItem = FileItem(id: fileID, fileURL: downloadedURL)

                // Add to app state
                var files = appState.files
                files.append(fileItem)
                appState.setFiles(files)

                // Create initial metadata
                let filename = downloadedURL.lastPathComponent
                let metadata = MetadataService.shared.createMetadata(fileID: fileID, title: filename)
                appState.updateMetadata(for: fileID, metadata: metadata)

                // Open metadata editor
                // Note: This would need to be handled by the parent view
                // For now, just dismiss
                dismiss()

            } catch {
                downloadError = "Download failed: \(error.localizedDescription)"
                isDownloading = false
            }
        }
    }
}
