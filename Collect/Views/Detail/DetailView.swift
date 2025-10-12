import SwiftUI

struct DetailView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingEditSheet = false
    @State private var editingFileID: UUID?

    private let cardColors = [AppTheme.cardTan, AppTheme.cardYellow, AppTheme.cardGreen, AppTheme.cardBlue, AppTheme.cardPink, AppTheme.cardPurple, AppTheme.cardGray, AppTheme.cardPeach]

    var body: some View {
        ZStack {
            AppTheme.backgroundPrimary
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Header Section
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .top) {
                            Text(appState.selectedCategory ?? "All Items")
                                .font(Typography.largeTitle)
                                .foregroundColor(AppTheme.textPrimary)

                            Button(action: {
                                // TODO: Edit category description
                            }) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                            .buttonStyle(.plain)
                            .padding(.top, 8)

                            Spacer()
                        }

                        Text(
                            "A description or notes about \(appState.selectedCategory ?? "All Items")"
                        )
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.textSecondary)
                        .padding(.bottom, 16)
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 24)

                    // Tab Bar
                    HStack(spacing: 0) {
                        TabButton(
                            title: "Items",
                            icon: "doc.text.fill",
                            isSelected: true
                        )
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 16)

                    // Divider
                    Rectangle()
                        .fill(AppTheme.dividerColor)
                        .frame(height: 1)
                        .padding(.horizontal, 32)

                    // Authors Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Authors")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppTheme.textTertiary)
                            .padding(.top, 16)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(appState.authorCounts.sorted(by: { $0.key < $1.key }), id: \.key) { author, count in
                                    AuthorChip(name: author, count: count, isSelected: appState.selectedAuthor == author) {
                                        appState.selectedAuthor = appState.selectedAuthor == author ? nil : author
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 32)

                    // New Items Section
                    if !appState.recentFiles.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("New items (\(appState.recentFiles.count))")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(AppTheme.textPrimary)
                                .padding(.top, 24)

                            ForEach(Array(appState.recentFiles.prefix(1))) { file in
                                if let meta = appState.metadata[file.id] {
                                    FileCard(
                                        title: meta.title ?? file.filename,
                                        author: meta.authors.joined(separator: ", "),
                                        year: meta.year.map(String.init) ?? "",
                                        tags: meta.tags,
                                        size: file.fileSize,
                                        pages: meta.pages,
                                        lastOpened: meta.lastOpened,
                                        backgroundColor: cardColors[0], // First color for new items
                                        onTap: {
                                            NSWorkspace.shared.open(file.fileURL)
                                            var updatedMeta = meta
                                            updatedMeta.lastOpened = Date()
                                            appState.updateMetadata(for: file.id, metadata: updatedMeta)
                                        },
                                        editAction: { editMetadata(for: file.id) }
                                    )
                                    .frame(width: 180, height: 240)
                                }
                            }
                        }
                        .padding(.horizontal, 32)
                    }

                    // Items Grid Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Items (\(appState.filteredFiles.count))")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(AppTheme.textPrimary)

                            Button(action: {}) {
                                HStack(spacing: 4) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 11))
                                    Text("Add")
                                        .font(.system(size: 12))
                                }
                                .foregroundColor(AppTheme.textSecondary)
                            }
                            .buttonStyle(.plain)

                            Spacer()

                            Button(action: {}) {
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.up.arrow.down")
                                        .font(.system(size: 11))
                                    Text("Recently added")
                                        .font(.system(size: 12))
                                }
                                .foregroundColor(AppTheme.textSecondary)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.top, 24)

                        if appState.filteredFiles.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "doc.text")
                                    .font(.system(size: 48))
                                    .foregroundColor(AppTheme.textTertiary)
                                Text("No PDFs found")
                                    .font(.title2)
                                    .foregroundColor(AppTheme.textPrimary)
                                Text("Select a source directory in Settings to get started.")
                                    .font(.body)
                                    .foregroundColor(AppTheme.textSecondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity, minHeight: 200)
                            .padding(.vertical, 40)
                        } else {
                            // Grid of Cards
                            LazyVGrid(
                                columns: [
                                    GridItem(
                                        .adaptive(minimum: 180, maximum: 220),
                                        spacing: 16
                                    )
                                ],
                                spacing: 16
                            ) {
                                ForEach(Array(appState.filteredFiles.enumerated()), id: \.element.id) { index, file in
                                    if let meta = appState.metadata[file.id] {
                                        FileCard(
                                            title: meta.title ?? file.filename,
                                            author: meta.authors.joined(separator: ", "),
                                            year: meta.year.map(String.init) ?? "",
                                            tags: meta.tags,
                                            size: file.fileSize,
                                            pages: meta.pages,
                                            lastOpened: meta.lastOpened,
                                            backgroundColor: cardColors[index % cardColors.count],
                                            onTap: {
                                                NSWorkspace.shared.open(file.fileURL)
                                                var updatedMeta = meta
                                                updatedMeta.lastOpened = Date()
                                                appState.updateMetadata(for: file.id, metadata: updatedMeta)
                                            },
                                            editAction: { editMetadata(for: file.id) }
                                        )
                                        .frame(minHeight: 240, maxHeight: 280)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 32)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppTheme.dividerColor, lineWidth: 2)
        )
        .padding(8)
        .sheet(isPresented: $showingEditSheet) {
            if let fileID = editingFileID {
                EditMetadataSheet(fileID: fileID)
            }
        }
    }

    private func editMetadata(for fileID: UUID) {
        editingFileID = fileID
        showingEditSheet = true
    }
}
