import SwiftUI

struct EditMetadataSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var themeManager: ThemeManager

    let fileID: UUID
    @State private var title: String = ""
    @State private var authors: [String] = []
    @State private var year: String = ""
    @State private var tags: [String] = []
    @State private var cardColorName: String = "cardBlue"
    @State private var filename: String = ""
    @State private var isLoaded: Bool = false

    private let cardColorNames = [
        "cardPeach", "cardDarkRed", "cardPink", "cardPurple",
        "cardRed", "cardSalmon", "cardYellow", "cardOrange",
        "cardDarkGreen", "cardGreen", "cardTeal", "cardBlue",
        "cardCyan", "cardNavy",
    ]

    private func colorFromName(_ name: String) -> Color {
        AppTheme.cardColor(for: name)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Edit Metadata")
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
            Text("Edit the metadata and properties for this document.")
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textSecondary)
                .lineSpacing(4)
                .padding(.horizontal, 24)
                .padding(.bottom, 20)

            if isLoaded {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Filename
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Filename")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(AppTheme.textPrimary)

                            TextField("Enter filename", text: $filename)
                                .textFieldStyle(.plain)
                                .font(.system(size: 13))
                                .foregroundColor(AppTheme.textPrimary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(AppTheme.backgroundTertiary)
                                .cornerRadius(6)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(
                                            AppTheme.dividerColor,
                                            lineWidth: 1
                                        )
                                )
                                .smartFocusRing()
                        }

                        // Title
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Title")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(AppTheme.textPrimary)

                            TextField("Enter title", text: $title)
                                .textFieldStyle(.plain)
                                .font(.system(size: 13))
                                .foregroundColor(AppTheme.textPrimary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(AppTheme.backgroundTertiary)
                                .cornerRadius(6)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(
                                            AppTheme.dividerColor,
                                            lineWidth: 1
                                        )
                                )
                                .smartFocusRing()
                        }

                        // Authors
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Authors")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(AppTheme.textPrimary)

                            TextField(
                                "Enter authors (comma separated)",
                                text: Binding(
                                    get: { authors.joined(separator: ", ") },
                                    set: {
                                        authors = $0.split(separator: ",").map {
                                            $0.trimmingCharacters(
                                                in: .whitespaces
                                            )
                                        }
                                    }
                                )
                            )
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
                            .smartFocusRing()
                        }

                        // Year
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Year")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(AppTheme.textPrimary)

                            TextField("Enter year", text: $year)
                                .textFieldStyle(.plain)
                                .font(.system(size: 13))
                                .foregroundColor(AppTheme.textPrimary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(AppTheme.backgroundTertiary)
                                .cornerRadius(6)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(
                                            AppTheme.dividerColor,
                                            lineWidth: 1
                                        )
                                )
                                .smartFocusRing()
                        }

                        // Tags
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tags/Categories")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(AppTheme.textPrimary)

                            TextField(
                                "Enter tags (comma separated)",
                                text: Binding(
                                    get: { tags.joined(separator: ", ") },
                                    set: {
                                        tags = $0.split(separator: ",").map {
                                            $0.trimmingCharacters(
                                                in: .whitespaces
                                            )
                                        }
                                    }
                                )
                            )
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
                            .smartFocusRing()
                        }

                        // Card Color
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Card Color")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(AppTheme.textPrimary)

                            WrappingHStack(spacing: 12) {
                                ForEach(cardColorNames, id: \.self) {
                                    colorName in
                                    let color = colorFromName(colorName)
                                    Button(action: { cardColorName = colorName }
                                    ) {
                                        Circle()
                                            .fill(color)
                                            .frame(width: 32, height: 32)
                                            .overlay(
                                                Circle()
                                                    .stroke(
                                                        AppTheme.textPrimary,
                                                        lineWidth: cardColorName
                                                            == colorName ? 2 : 0
                                                    )
                                            )
                                            .overlay(
                                                Circle()
                                                    .stroke(
                                                        AppTheme.dividerColor,
                                                        lineWidth: cardColorName
                                                            == colorName ? 0 : 1
                                                    )
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
                .frame(minHeight: 350, maxHeight: 500)
            } else {
                // Loading placeholder
                VStack {
                    ProgressView()
                }
                .frame(height: 350)
                .frame(maxWidth: .infinity)
            }

            // Action Buttons
            HStack(spacing: 12) {
                UIButton(action: { dismiss() }, style: .plain, label: "Cancel")

                Spacer()

                UIButton(
                    action: {
                        saveMetadata()
                        dismiss()
                    },
                    style: .primary,
                    label: "Save",
                    icon: "checkmark"
                )
                .disabled(!isLoaded)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .frame(width: 600)
        .background(AppTheme.backgroundPrimary)
        .cornerRadius(12)
        .id(themeManager.effectiveColorScheme)
        .task {
            // Load metadata immediately when the view appears
            loadMetadata()
        }
    }

    private func loadMetadata() {
        if let metadata = appState.metadata[fileID] {
            title = metadata.title ?? ""
            authors = metadata.authors
            year = metadata.year != nil ? String(metadata.year!) : ""
            tags = metadata.tags
            cardColorName = metadata.cardColor
        }
        if let file = appState.files.first(where: { $0.id == fileID }) {
            filename = file.filename
        }
        isLoaded = true
    }

    private func saveMetadata() {
        let yearInt = Int(year)
        let metadata = FileMetadata(
            id: fileID,
            title: title.isEmpty ? nil : title,
            authors: authors,
            year: yearInt,
            tags: tags,
            dateAdded: appState.metadata[fileID]?.dateAdded ?? Date(),
            cardColor: cardColorName
        )
        appState.updateMetadata(for: fileID, metadata: metadata)
        MetadataService.shared.save(metadata: appState.metadata)

        // Rename file if filename changed
        if let oldFile = appState.files.first(where: { $0.id == fileID }),
           filename != oldFile.filename
        {
            appState.renameFile(fileID: fileID, newFilename: filename)
        }
    }
}
