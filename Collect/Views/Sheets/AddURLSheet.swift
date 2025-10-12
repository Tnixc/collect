import SwiftUI

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
                .focusable(false)
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
                    .focusable(false)

                UIButton(
                    action: {
                        if !urlString.isEmpty && !isDownloading {
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
                    action: { /* TODO: implement file picker */  },
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

            } catch {
                downloadError = "Download failed: \(error.localizedDescription)"
                isDownloading = false
            }
        }
    }
}
