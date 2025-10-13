import AppKit
import SwiftUI

struct SettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var themeManager = ThemeManager.shared
    @State private var sourceDirectoryURL: URL?
    @State private var isSelectingDirectory = false
    @State private var savedSourceBookmarks: [Data] = []
    @State private var selectedSavedIndex: Int? = nil
    @State private var initialSourceDirectoryURL: URL? = nil

    private let sourceDirectoryBookmarkKey = "sourceDirectoryBookmark"
    private let sourcesArrayKey = "sourceDirectoryBookmarks"

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
                .smartFocusRing()
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 12)

            // Description
            Text("Configure your application preferences.")
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textSecondary)
                .lineSpacing(4)
                .padding(.horizontal, 24)
                .padding(.bottom, 20)

            Divider()
                .background(AppTheme.dividerColor)
                .padding(.horizontal, 24)
                .padding(.bottom, 16)

            // Theme Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Appearance")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                    .padding(.horizontal, 24)

                HStack(spacing: 8) {
                    ForEach(ThemeMode.allCases, id: \.self) { mode in
                        Button(action: {
                            themeManager.themeMode = mode
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: mode.iconName)
                                    .font(.system(size: 12))
                                Text(mode.rawValue)
                                    .font(.system(size: 13))
                            }
                            .foregroundColor(
                                themeManager.themeMode == mode
                                    ? AppTheme.buttonTextLight
                                    : AppTheme.textPrimary
                            )
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                themeManager.themeMode == mode
                                    ? AppTheme.accentPrimary
                                    : AppTheme.backgroundTertiary
                            )
                            .cornerRadius(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(
                                        themeManager.themeMode == mode
                                            ? AppTheme.accentPrimary
                                            : AppTheme.dividerColor,
                                        lineWidth: 1
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                        .smartFocusRing()
                    }
                }
                .padding(.horizontal, 24)
            }
            .padding(.bottom, 20)

            Divider()
                .background(AppTheme.dividerColor)
                .padding(.horizontal, 24)
                .padding(.bottom, 16)

            // Source Directory Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Source Directory")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                    .padding(.horizontal, 24)

                Text("Select the directory where your PDF files are stored.")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textSecondary)
                    .padding(.horizontal, 24)
            }

            // Directory Selection
            VStack(alignment: .leading, spacing: 8) {
                if !savedSourceBookmarks.isEmpty {
                    Picker("Saved Sources", selection: Binding(
                        get: { selectedSavedIndex ?? -1 },
                        set: { newValue in
                            selectedSavedIndex = (newValue >= 0 ? newValue : nil)
                            if let idx = selectedSavedIndex, idx < savedSourceBookmarks.count,
                               let resolved = resolveBookmark(savedSourceBookmarks[idx])
                            {
                                sourceDirectoryURL = resolved
                            }
                        }
                    )) {
                        ForEach(Array(savedSourceBookmarks.enumerated()), id: \.offset) { index, data in
                            Text(resolveBookmark(data)?.path ?? "Unknown").tag(index)
                        }
                    }
                    .labelsHidden()
                    .padding(.vertical, 16)
                }
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
                    UIButton(
                        action: {
                            if let idx = selectedSavedIndex {
                                savedSourceBookmarks.remove(at: idx)
                                selectedSavedIndex = nil
                                if sourceDirectoryURL != nil {
                                    sourceDirectoryURL = nil
                                }
                            }
                        },
                        style: .plain,
                        label: "Remove"
                    )
                }
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
        .id(themeManager.effectiveColorScheme)
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
        // Load saved sources list
        if let arr = UserDefaults.standard.array(forKey: sourcesArrayKey) as? [Data] {
            savedSourceBookmarks = arr
        }
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
                    initialSourceDirectoryURL = url
                    if let idx = savedSourceBookmarks.firstIndex(of: bookmarkData) {
                        selectedSavedIndex = idx
                    }
                }
            } catch {
                print("Error resolving bookmark: \(error)")
            }
        }
    }

    private func resolveBookmark(_ data: Data) -> URL? {
        do {
            var isStale = false
            let url = try URL(
                resolvingBookmarkData: data,
                options: .withSecurityScope,
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )
            return isStale ? nil : url
        } catch {
            print("Error resolving bookmark: \(error)")
            return nil
        }
    }

    private func saveSettings() {
        guard let url = sourceDirectoryURL else { return }

        let oldURL = initialSourceDirectoryURL

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

            if !savedSourceBookmarks.contains(bookmarkData) {
                savedSourceBookmarks.append(bookmarkData)
            }
            UserDefaults.standard.set(savedSourceBookmarks, forKey: sourcesArrayKey)

            NotificationCenter.default.post(
                name: .sourceDirectoryDidChange,
                object: nil,
                userInfo: ["oldSourceURL": oldURL as Any, "newSourceURL": url]
            )

            initialSourceDirectoryURL = url
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
