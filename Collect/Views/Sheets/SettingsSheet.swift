import AppKit
import SwiftUI

struct SettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var sourceDirectoryURL: URL?
    @State private var isSelectingDirectory = false

    private let sourceDirectoryBookmarkKey = "sourceDirectoryBookmark"

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Settings")
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
            Text("Select the directory where your PDF files are stored.")
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textSecondary)
                .lineSpacing(4)
                .padding(.horizontal, 24)
                .padding(.bottom, 20)

            // Directory Selection
            HStack(spacing: 8) {
                Text(sourceDirectoryURL?.path ?? "No directory selected")
                    .font(.system(size: 13))
                    .foregroundColor(
                        sourceDirectoryURL != nil
                            ? AppTheme.textPrimary : AppTheme.textSecondary
                    )
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(AppTheme.backgroundTertiary)
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(AppTheme.dividerColor, lineWidth: 1)
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .truncationMode(.middle)

                UIButton(
                    action: { selectDirectory() },
                    style: .primary,
                    label: "Choose...",
                    height: 36
                )
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)

            // Bottom Buttons
            HStack {
                UIButton(action: { dismiss() }, style: .plain, label: "Cancel")

                Spacer()

                UIButton(
                    action: {
                        saveSettings()
                        dismiss()
                    },
                    style: .primary,
                    label: "Save"
                )
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .frame(width: 500)
        .background(AppTheme.backgroundPrimary)
        .cornerRadius(12)
        .onAppear {
            loadSettings()
        }
    }

    private func selectDirectory() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.message = "Choose the directory containing your PDF files"
        panel.prompt = "Select"

        if panel.runModal() == .OK, let url = panel.url {
            sourceDirectoryURL = url
        }
    }

    private func loadSettings() {
        if let bookmarkData = UserDefaults.standard.data(
            forKey: sourceDirectoryBookmarkKey
        ) {
            do {
                var isStale = false
                let url = try URL(
                    resolvingBookmarkData: bookmarkData,
                    options: .withSecurityScope,
                    relativeTo: nil,
                    bookmarkDataIsStale: &isStale
                )
                if !isStale {
                    sourceDirectoryURL = url
                }
            } catch {
                print("Error resolving bookmark: \(error)")
            }
        }
    }

    private func saveSettings() {
        guard let url = sourceDirectoryURL else { return }

        do {
            let bookmarkData = try url.bookmarkData(
                options: .withSecurityScope,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            UserDefaults.standard.set(
                bookmarkData,
                forKey: sourceDirectoryBookmarkKey
            )
        } catch {
            print("Error creating bookmark: \(error)")
        }
    }

    // Method to get the source directory URL with security scope
    static func getSourceDirectoryURL() -> URL? {
        if let bookmarkData = UserDefaults.standard.data(
            forKey: "sourceDirectoryBookmark"
        ) {
            do {
                var isStale = false
                let url = try URL(
                    resolvingBookmarkData: bookmarkData,
                    options: .withSecurityScope,
                    relativeTo: nil,
                    bookmarkDataIsStale: &isStale
                )
                if !isStale {
                    // Start accessing the security-scoped resource
                    if url.startAccessingSecurityScopedResource() {
                        return url
                    }
                }
            } catch {
                print("Error resolving bookmark: \(error)")
            }
        }
        return nil
    }

    // Method to stop accessing security scope when done
    static func stopAccessingSourceDirectory(_ url: URL) {
        url.stopAccessingSecurityScopedResource()
    }
}
