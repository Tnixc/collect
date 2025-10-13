import AppKit
import SwiftUI
import UniformTypeIdentifiers

// Extension to make UUID work with .sheet(item:)
extension UUID: Identifiable {
    public var id: UUID { self }
}

struct DetailView: View {
    @EnvironmentObject var appState: AppState
    @State private var editingFileID: UUID?
    @State private var showingCreateCategory = false
    @State private var creatingForFileID: UUID?
    @State private var editingCategory: Category?
    @State private var isDropdownExpanded = false
    @State private var hoveredViewMode: ViewMode? = nil
    @FocusState private var isSearchFocused: Bool

    private let cardColors: [NSColor] = AppTheme.cardNSColors

    var body: some View {
        ZStack {
            AppTheme.backgroundPrimary
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Header Section
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .top) {
                            Text(
                                appState.showRecent
                                    ? "Recent"
                                    : appState.showReadingList
                                    ? "Reading list"
                                    : (appState.selectedCategory
                                        ?? "All Items")
                            )
                            .font(Typography.largeTitle)
                            .foregroundColor(AppTheme.textPrimary)

                            if !appState.showReadingList,
                               !appState.showRecent,
                               let categoryName = appState.selectedCategory,
                               categoryName != "Uncategorized",
                               let category = appState.categories.first(
                                   where: { $0.name == categoryName })
                            {
                                UIButton(
                                    action: {
                                        editingCategory = category
                                    },
                                    style: .ghost,
                                    icon: "pencil",
                                    width: 24,
                                    height: 24
                                )
                                .padding(.top, 8)
                            }

                            Spacer()
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 64)
                    .padding(.bottom, 24)

                    // Divider
                    Rectangle()
                        .fill(AppTheme.dividerColor)
                        .frame(height: 1)
                        .padding(.horizontal, 32)

                    // Authors Section (hide for reading list and recent)
                    if !appState.showReadingList && !appState.showRecent {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Authors")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(AppTheme.textTertiary)
                                .padding(.top, 16)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(
                                        appState.authorCounts.sorted(
                                            by: {
                                                $0.key < $1.key
                                            }),
                                        id: \.key
                                    ) { author, count in
                                        AuthorChip(
                                            name: author,
                                            count: count,
                                            isSelected: appState.selectedAuthors.contains(author)
                                        ) {
                                            if appState.selectedAuthors.contains(author) {
                                                appState.selectedAuthors.remove(author)
                                            } else {
                                                appState.selectedAuthors.insert(author)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 32)
                    }

                    // Items Grid Section or Recent Sections
                    if appState.showRecent {
                        // Recent View - Two Sections
                        VStack(alignment: .leading, spacing: 24) {
                            // Last Opened Section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Recently Opened")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(AppTheme.textPrimary)
                                    .padding(.top, 24)

                                if appState.lastOpenedFiles.isEmpty {
                                    VStack(spacing: 8) {
                                        Text("No recently opened files")
                                            .font(.body)
                                            .foregroundColor(
                                                AppTheme.textSecondary
                                            )
                                    }
                                    .frame(maxWidth: .infinity, minHeight: 100)
                                    .padding(.vertical, 20)
                                } else {
                                    AppKitCardsGrid(
                                        files: appState.lastOpenedFiles,
                                        metadata: appState.metadata,
                                        categories: appState.categories,
                                        cardColors: cardColors,
                                        disableHover: isDropdownExpanded,
                                        onTap: { fileID in
                                            if let meta = appState.metadata[
                                                fileID
                                            ] {
                                                NSWorkspace.shared.open(
                                                    appState.files.first(
                                                        where: {
                                                            $0.id == fileID
                                                        })!.fileURL
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
                                        addToCategoryAction: {
                                            fileID,
                                                categoryName in
                                            if var meta = appState.metadata[
                                                fileID
                                            ] {
                                                if !meta.tags.contains(
                                                    categoryName
                                                ) {
                                                    meta.tags.append(
                                                        categoryName
                                                    )
                                                    appState.updateMetadata(
                                                        for: fileID,
                                                        metadata: meta
                                                    )
                                                }
                                            }
                                        },
                                        createCategoryAction: { fileID in
                                            creatingForFileID = fileID
                                            showingCreateCategory = true
                                        },
                                        deleteAction: { fileID in
                                            appState.deleteFile(fileID: fileID)
                                        },
                                        showInFinderAction: { fileID in
                                            if let file = appState.files.first(
                                                where: { $0.id == fileID })
                                            {
                                                NSWorkspace.shared.selectFile(
                                                    file.fileURL.path,
                                                    inFileViewerRootedAtPath: ""
                                                )
                                            }
                                        },
                                        addToReadingListAction: { fileID in
                                            appState.addToReadingList(
                                                fileID: fileID
                                            )
                                        },
                                        removeFromReadingListAction: { fileID in
                                            appState.removeFromReadingList(
                                                fileID: fileID
                                            )
                                        }
                                    ).zIndex(-1)
                                }
                            }

                            // Last Added Section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Recently Added")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(AppTheme.textPrimary)

                                if appState.lastAddedFiles.isEmpty {
                                    VStack(spacing: 8) {
                                        Text("No recently added files")
                                            .font(.body)
                                            .foregroundColor(
                                                AppTheme.textSecondary
                                            )
                                    }
                                    .frame(maxWidth: .infinity, minHeight: 100)
                                    .padding(.vertical, 20)
                                } else {
                                    AppKitCardsGrid(
                                        files: appState.lastAddedFiles,
                                        metadata: appState.metadata,
                                        categories: appState.categories,
                                        cardColors: cardColors,
                                        disableHover: isDropdownExpanded,
                                        onTap: { fileID in
                                            if let meta = appState.metadata[
                                                fileID
                                            ] {
                                                NSWorkspace.shared.open(
                                                    appState.files.first(
                                                        where: {
                                                            $0.id == fileID
                                                        })!.fileURL
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
                                        addToCategoryAction: {
                                            fileID,
                                                categoryName in
                                            if var meta = appState.metadata[
                                                fileID
                                            ] {
                                                if !meta.tags.contains(
                                                    categoryName
                                                ) {
                                                    meta.tags.append(
                                                        categoryName
                                                    )
                                                    appState.updateMetadata(
                                                        for: fileID,
                                                        metadata: meta
                                                    )
                                                }
                                            }
                                        },
                                        createCategoryAction: { fileID in
                                            creatingForFileID = fileID
                                            showingCreateCategory = true
                                        },
                                        deleteAction: { fileID in
                                            appState.deleteFile(fileID: fileID)
                                        },
                                        showInFinderAction: { fileID in
                                            if let file = appState.files.first(
                                                where: { $0.id == fileID })
                                            {
                                                NSWorkspace.shared.selectFile(
                                                    file.fileURL.path,
                                                    inFileViewerRootedAtPath: ""
                                                )
                                            }
                                        },
                                        addToReadingListAction: { fileID in
                                            appState.addToReadingList(
                                                fileID: fileID
                                            )
                                        },
                                        removeFromReadingListAction: { fileID in
                                            appState.removeFromReadingList(
                                                fileID: fileID
                                            )
                                        }
                                    ).zIndex(-1)
                                }
                            }
                        }
                        .padding(.horizontal, 32)
                        .padding(.bottom, 32)
                    } else {
                        // Standard Items Grid Section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(
                                    "Items (\(appState.showReadingList ? appState.readingListFiles.count : appState.filteredFiles.count))"
                                )
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(AppTheme.textPrimary)

                                Spacer()

                                HStack(spacing: 8) {
                                    // View mode toggle
                                    HStack(spacing: 0) {
                                        ForEach(ViewMode.allCases, id: \.self) {
                                            mode in
                                            Button(action: {
                                                appState.viewMode = mode
                                            }) {
                                                HStack(spacing: 4) {
                                                    Image(
                                                        systemName: mode
                                                            .iconName
                                                    )
                                                    .font(.system(size: 14))
                                                    Text(mode.rawValue)
                                                        .font(
                                                            .system(
                                                                size: 12,
                                                                weight: .medium
                                                            )
                                                        )
                                                }
                                                .foregroundColor(
                                                    appState.viewMode == mode
                                                        ? AppTheme.textPrimary
                                                        : AppTheme.textSecondary
                                                )
                                                .frame(width: 60, height: 32)
                                                .background(
                                                    appState.viewMode == mode
                                                        ? AppTheme
                                                        .backgroundTertiary
                                                        : Color.clear
                                                )
                                                .clipShape(
                                                    RoundedRectangle(
                                                        cornerRadius: 8
                                                    )
                                                )
                                                .contentShape(
                                                    RoundedRectangle(
                                                        cornerRadius: 8
                                                    )
                                                )
                                            }
                                            .buttonStyle(.plain)
                                            .onHover { hovering in
                                                withAnimation(
                                                    .easeInOut(duration: 0.15)
                                                ) {
                                                    self.hoveredViewMode =
                                                        hovering ? mode : nil
                                                }
                                            }
                                        }
                                    }
                                    .background(AppTheme.backgroundSecondary)
                                    .clipShape(
                                        RoundedRectangle(cornerRadius: 8)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(
                                                AppTheme.dividerColor,
                                                lineWidth: 1
                                            )
                                    )
                                    UIDropdown(
                                        selectedOption: $appState.sortOption,
                                        isExpanded: $isDropdownExpanded,
                                        options: SortOption.allCases,
                                        optionToString: { $0.rawValue },
                                        optionToIcon: { $0.iconName },
                                        width: 200,
                                        height: 32
                                    ).zIndex(999)

                                    // Search bar
                                    HStack {
                                        Image(systemName: "magnifyingglass")
                                            .foregroundColor(AppTheme.textSecondary)
                                        TextField("Search", text: $appState.searchText)
                                            .textFieldStyle(.plain)
                                            .frame(width: 200)
                                            .foregroundColor(AppTheme.textPrimary)
                                            .padding(.vertical, 4)
                                            .focused($isSearchFocused)
                                            .smartFocusRing()
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(AppTheme.backgroundTertiary)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8).stroke(
                                            AppTheme.dividerColor,
                                            lineWidth: 1.0
                                        )
                                    )
                                }
                            }
                            .padding(.top, 24)

                            if (appState.showReadingList
                                && appState.readingListFiles.isEmpty)
                                || (!appState.showReadingList
                                    && appState.filteredFiles.isEmpty)
                            {
                                VStack(spacing: 16) {
                                    Image(
                                        systemName: appState.showReadingList
                                            ? "book" : "doc.text"
                                    )
                                    .font(.system(size: 48))
                                    .foregroundColor(AppTheme.textTertiary)
                                    Text(
                                        appState.showReadingList
                                            ? "No items in reading list"
                                            : "No PDFs found"
                                    )
                                    .font(.title2)
                                    .foregroundColor(AppTheme.textPrimary)
                                    Text(
                                        appState.showReadingList
                                            ? "Add items to your reading list from the context menu."
                                            : "Select a source directory in Settings to get started."
                                    )
                                    .font(.body)
                                    .foregroundColor(AppTheme.textSecondary)
                                    .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity, minHeight: 200)
                                .padding(.vertical, 40)
                            } else {
                                // Grid or List View
                                if appState.viewMode == .grid {
                                    AppKitCardsGrid(
                                        files: appState.showReadingList
                                            ? appState.readingListFiles
                                            : appState.filteredFiles,
                                        metadata: appState.metadata,
                                        categories: appState.categories,
                                        cardColors: cardColors,
                                        disableHover: isDropdownExpanded,
                                        onTap: { fileID in
                                            if let meta = appState.metadata[
                                                fileID
                                            ] {
                                                NSWorkspace.shared.open(
                                                    appState.files.first(
                                                        where: {
                                                            $0.id == fileID
                                                        })!.fileURL
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
                                        addToCategoryAction: {
                                            fileID,
                                                categoryName in
                                            if var meta = appState.metadata[
                                                fileID
                                            ] {
                                                if !meta.tags.contains(
                                                    categoryName
                                                ) {
                                                    meta.tags.append(
                                                        categoryName
                                                    )
                                                    appState.updateMetadata(
                                                        for: fileID,
                                                        metadata: meta
                                                    )
                                                }
                                            }
                                        },
                                        createCategoryAction: { fileID in
                                            creatingForFileID = fileID
                                            showingCreateCategory = true
                                        },
                                        deleteAction: { fileID in
                                            appState.deleteFile(fileID: fileID)
                                        },
                                        showInFinderAction: { fileID in
                                            if let file = appState.files.first(
                                                where: { $0.id == fileID })
                                            {
                                                NSWorkspace.shared.selectFile(
                                                    file.fileURL.path,
                                                    inFileViewerRootedAtPath: ""
                                                )
                                            }
                                        },
                                        addToReadingListAction: { fileID in
                                            appState.addToReadingList(
                                                fileID: fileID
                                            )
                                        },
                                        removeFromReadingListAction: { fileID in
                                            appState.removeFromReadingList(
                                                fileID: fileID
                                            )
                                        }
                                    ).zIndex(-1)
                                } else {
                                    AppKitListView(
                                        files: appState.showReadingList
                                            ? appState.readingListFiles
                                            : appState.filteredFiles,
                                        metadata: appState.metadata,
                                        categories: appState.categories,
                                        onTap: { fileID in
                                            if let meta = appState.metadata[
                                                fileID
                                            ] {
                                                NSWorkspace.shared.open(
                                                    appState.files.first(
                                                        where: {
                                                            $0.id == fileID
                                                        })!.fileURL
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
                                        addToCategoryAction: {
                                            fileID,
                                                categoryName in
                                            if var meta = appState.metadata[
                                                fileID
                                            ] {
                                                if !meta.tags.contains(
                                                    categoryName
                                                ) {
                                                    meta.tags.append(
                                                        categoryName
                                                    )
                                                    appState.updateMetadata(
                                                        for: fileID,
                                                        metadata: meta
                                                    )
                                                }
                                            }
                                        },
                                        createCategoryAction: { fileID in
                                            creatingForFileID = fileID
                                            showingCreateCategory = true
                                        },
                                        deleteAction: { fileID in
                                            appState.deleteFile(fileID: fileID)
                                        },
                                        showInFinderAction: { fileID in
                                            if let file = appState.files.first(
                                                where: { $0.id == fileID })
                                            {
                                                NSWorkspace.shared.selectFile(
                                                    file.fileURL.path,
                                                    inFileViewerRootedAtPath: ""
                                                )
                                            }
                                        },
                                        addToReadingListAction: { fileID in
                                            appState.addToReadingList(
                                                fileID: fileID
                                            )
                                        },
                                        removeFromReadingListAction: { fileID in
                                            appState.removeFromReadingList(
                                                fileID: fileID
                                            )
                                        }
                                    )
                                    .zIndex(-1)
                                    .frame(
                                        height: CGFloat(
                                            appState.showReadingList
                                                ? appState.readingListFiles
                                                .count
                                                : appState.filteredFiles.count
                                        ) * 80
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 32)
                        .padding(.bottom, 32)
                    }
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
        .shadow(color: AppTheme.backgroundTertiary.opacity(0.2), radius: 8, y: -4)
        .sheet(item: $editingFileID) { fileID in
            EditMetadataSheet(fileID: fileID)
                .environmentObject(appState)
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
            .environmentObject(appState)
        }
        .sheet(item: $editingCategory) { category in
            EditCategorySheet(category: category) { newName, newColor in
                appState.renameCategory(
                    from: category.name,
                    to: newName,
                    color: newColor
                )
            }
        }
        .overlay(
            // Invisible button to capture Cmd+F
            Button(action: {
                isSearchFocused = true
            }) {}
                .keyboardShortcut("f", modifiers: .command)
                .opacity(0)
                .frame(width: 0, height: 0)
        )
    }

    private func editMetadata(for fileID: UUID) {
        editingFileID = fileID
    }

    private func handleFileDrop(providers: [NSItemProvider]) -> Bool {
        guard let sourceDirectory = SettingsSheet.getSourceDirectoryURL() else {
            // TODO: Show error to user
            return false
        }

        for provider in providers {
            provider.loadItem(
                forTypeIdentifier: UTType.fileURL.identifier,
                options: nil
            ) { item, error in
                guard let data = item as? Data,
                      let url = URL(dataRepresentation: data, relativeTo: nil),
                      url.pathExtension.lowercased() == "pdf"
                else {
                    return
                }

                DispatchQueue.main.async {
                    do {
                        let copiedURL = try FileSystemService.shared.copyFile(
                            from: url,
                            to: sourceDirectory
                        )

                        // Process the copied file
                        let fileID = FileSystemService.shared.ensureFileID(
                            for: copiedURL
                        )
                        let fileItem = FileItem(id: fileID, fileURL: copiedURL)

                        // Add to app state
                        var files = self.appState.files
                        files.append(fileItem)
                        self.appState.setFiles(files)

                        // Create initial metadata
                        let filename = copiedURL.lastPathComponent
                        let pages = FileSystemService.shared.getPageCount(
                            for: copiedURL
                        )
                        let metadata = MetadataService.shared.createMetadata(
                            fileID: fileID,
                            title: filename,
                            pages: pages
                        )
                        self.appState.updateMetadata(
                            for: fileID,
                            metadata: metadata
                        )

                    } catch {
                        // TODO: Show error to user
                        print(
                            "Failed to copy file: \(error.localizedDescription)"
                        )
                    }
                }
            }
        }

        return true
    }
}
