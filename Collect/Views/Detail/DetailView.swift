import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct DetailView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingEditSheet = false
    @State private var editingFileID: UUID?
    @State private var showingCreateCategory = false
    @State private var creatingForFileID: UUID?

    private let cardColors: [NSColor] = [
        NSColor(red: 0.93, green: 0.88, blue: 0.82, alpha: 1),
        NSColor(red: 0.95, green: 0.94, blue: 0.78, alpha: 1),
        NSColor(red: 0.85, green: 0.92, blue: 0.82, alpha: 1),
        NSColor(red: 0.84, green: 0.89, blue: 0.92, alpha: 1),
        NSColor(red: 0.95, green: 0.88, blue: 0.88, alpha: 1),
        NSColor(red: 0.90, green: 0.87, blue: 0.93, alpha: 1),
        NSColor(red: 0.91, green: 0.90, blue: 0.89, alpha: 1),
        NSColor(red: 0.95, green: 0.90, blue: 0.85, alpha: 1),
    ]

    private var gridHeight: CGFloat {
        let itemHeight: CGFloat = 260
        let spacing: CGFloat = 16
        let columns = 3 // approximate
        let rows = ceil(CGFloat(appState.filteredFiles.count) / CGFloat(columns))
        return rows * itemHeight + (rows - 1) * spacing
    }

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

                            UIButton(
                                action: {
                                    // TODO: Edit category description
                                },
                                style: .ghost,
                                icon: "pencil",
                                width: 24,
                                height: 24
                            )
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
                                ForEach(
                                    appState.authorCounts.sorted(by: {
                                        $0.key < $1.key
                                    }),
                                    id: \.key
                                ) { author, count in
                                    AuthorChip(
                                        name: author,
                                        count: count,
                                        isSelected: appState.selectedAuthor
                                            == author
                                    ) {
                                        appState.selectedAuthor =
                                            appState.selectedAuthor == author
                                                ? nil : author
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 32)

                    // Items Grid Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Items (\(appState.filteredFiles.count))")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(AppTheme.textPrimary)

                            Spacer()

                            UIButton(
                                action: {},
                                style: .plain,
                                label: "Recently added",
                                icon: "arrow.up.arrow.down"
                            )
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
                                Text(
                                    "Select a source directory in Settings to get started."
                                )
                                .font(.body)
                                .foregroundColor(AppTheme.textSecondary)
                                .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity, minHeight: 200)
                            .padding(.vertical, 40)
                        } else {
                            // Grid of Cards
                            AppKitCardsGrid(
                                files: appState.filteredFiles,
                                metadata: appState.metadata,
                                categories: appState.categories,
                                cardColors: cardColors,
                                onTap: { fileID in
                                    if let meta = appState.metadata[fileID] {
                                        NSWorkspace.shared.open(
                                            appState.files.first(where: { $0.id == fileID })!.fileURL
                                        )
                                        var updatedMeta = meta
                                        updatedMeta.lastOpened = Date()
                                        appState.updateMetadata(
                                            for: fileID,
                                            metadata: updatedMeta
                                        )
                                    }
                                },
                                editAction: { fileID in
                                    editMetadata(for: fileID)
                                },
                                addToCategoryAction: { fileID, categoryName in
                                    if var meta = appState.metadata[fileID] {
                                        if !meta.tags.contains(categoryName) {
                                            meta.tags.append(categoryName)
                                            appState.updateMetadata(for: fileID, metadata: meta)
                                        }
                                    }
                                },
                                createCategoryAction: { fileID in
                                    creatingForFileID = fileID
                                    showingCreateCategory = true
                                }
                            )
                            .frame(height: gridHeight)
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 32)
                }
            }
        }
        .onDrop(of: [.fileURL], isTargeted: nil) { providers in
            handleFileDrop(providers: providers)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppTheme.dividerColor, lineWidth: 2)
        )
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
        .padding(.top, 1)
        .shadow(color: AppTheme.borderColor.opacity(0.2), radius: 8, y: -4)
        .sheet(isPresented: $showingEditSheet) {
            if let fileID = editingFileID {
                EditMetadataSheet(fileID: fileID)
            }
        }
        .sheet(isPresented: $showingCreateCategory) {
            CreateCategorySheet { name, color in
                appState.tagColors[name] = color
                if let fileID = creatingForFileID,
                   var meta = appState.metadata[fileID]
                {
                    if !meta.tags.contains(name) {
                        meta.tags.append(name)
                        appState.updateMetadata(for: fileID, metadata: meta)
                    }
                }
            }
        }
    }

    private func editMetadata(for fileID: UUID) {
        editingFileID = fileID
        showingEditSheet = true
    }

    private func handleFileDrop(providers: [NSItemProvider]) -> Bool {
        guard let sourceDirectory = SettingsSheet.getSourceDirectoryURL() else {
            // TODO: Show error to user
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
                        // TODO: Show error to user
                        print("Failed to copy file: \(error.localizedDescription)")
                    }
                }
            }
        }

        return true
    }
}
