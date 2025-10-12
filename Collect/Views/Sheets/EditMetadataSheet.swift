import SwiftUI

struct EditMetadataSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState

    let fileID: UUID
    @State private var title: String = ""
    @State private var authors: [String] = []
    @State private var year: String = ""
    @State private var tags: [String] = []
    @State private var cardColorName: String = "cardBlue"

    private let cardColorNames = ["cardTan", "cardYellow", "cardGreen", "cardBlue", "cardPink", "cardPurple", "cardGray", "cardPeach"]

    private func colorFromName(_ name: String) -> Color {
        switch name {
        case "cardTan": return AppTheme.cardTan
        case "cardYellow": return AppTheme.cardYellow
        case "cardGreen": return AppTheme.cardGreen
        case "cardBlue": return AppTheme.cardBlue
        case "cardPink": return AppTheme.cardPink
        case "cardPurple": return AppTheme.cardPurple
        case "cardGray": return AppTheme.cardGray
        case "cardPeach": return AppTheme.cardPeach
        default: return AppTheme.cardBlue
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Edit Metadata")
                .font(.title)
                .padding(.top)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Title
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Title")
                            .font(.headline)
                        TextField("Enter title", text: $title)
                            .textFieldStyle(.roundedBorder)
                    }

                    // Authors
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Authors")
                            .font(.headline)
                        TextField("Enter authors (comma separated)", text: Binding(
                            get: { authors.joined(separator: ", ") },
                            set: { authors = $0.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) } }
                        ))
                        .textFieldStyle(.roundedBorder)
                    }

                    // Year
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Year")
                            .font(.headline)
                        TextField("Enter year", text: $year)
                            .textFieldStyle(.roundedBorder)
                    }

                    // Tags
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Tags/Categories")
                            .font(.headline)
                        TextField("Enter tags (comma separated)", text: Binding(
                            get: { tags.joined(separator: ", ") },
                            set: { tags = $0.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) } }
                        ))
                        .textFieldStyle(.roundedBorder)
                    }

                    // Card Color
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Card Color")
                            .font(.headline)

                        HStack(spacing: 12) {
                            ForEach(cardColorNames, id: \.self) { colorName in
                                let color = colorFromName(colorName)
                                Circle()
                                    .fill(color)
                                    .frame(width: 30, height: 30)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.gray.opacity(0.5), lineWidth: cardColorName == colorName ? 2 : 0)
                                    )
                                    .onTapGesture {
                                        cardColorName = colorName
                                    }
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }

            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Spacer()

                Button("Save") {
                    saveMetadata()
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .frame(width: 500, height: 600)
        .onAppear {
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
    }
}
