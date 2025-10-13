import AppKit
import SwiftUI
import UniformTypeIdentifiers

// Extension to make UUID work with .sheet(item:)
extension UUID: Identifiable {
    public var id: UUID { self }
}

struct DetailView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var themeManager: ThemeManager
    @State private var editingFileID: UUID?
    @State private var showingCreateCategory = false
    @State private var creatingForFileID: UUID?
    @State private var editingCategory: Category?
    @State private var isDropdownExpanded = false
    @FocusState private var isSearchFocused: Bool

    private let cardColors: [NSColor] = AppTheme.cardNSColors

    // Action closures
    private var onTap: (UUID) -> Void {
        { fileID in
            if let meta = appState.metadata[fileID] {
                NSWorkspace.shared.open(appState.files.first(where: { $0.id == fileID })!.fileURL)
                var updatedMeta = meta
                updatedMeta.lastOpened = Date()
                appState.updateMetadata(for: fileID, metadata: updatedMeta)
            }
        }
    }

    private var editAction: (UUID) -> Void {
        { self.editingFileID = $0 }
    }

    private var addToCategoryAction: (UUID, String) -> Void {
        { fileID, categoryName in
            if var meta = appState.metadata[fileID] {
                if !meta.tags.contains(categoryName) {
                    meta.tags.append(categoryName)
                    appState.updateMetadata(for: fileID, metadata: meta)
                }
            }
        }
    }

    private var createCategoryAction: (UUID) -> Void {
        { fileID in
            self.creatingForFileID = fileID
            self.showingCreateCategory = true
        }
    }

    private var deleteAction: (UUID) -> Void {
        { appState.deleteFile(fileID: $0) }
    }

    private var showInFinderAction: (UUID) -> Void {
        { fileID in
            if let file = appState.files.first(where: { $0.id == fileID }) {
                NSWorkspace.shared.selectFile(file.fileURL.path, inFileViewerRootedAtPath: "")
            }
        }
    }

    private var addToReadingListAction: (UUID) -> Void {
        { appState.addToReadingList(fileID: $0) }
    }

    private var removeFromReadingListAction: (UUID) -> Void {
        { appState.removeFromReadingList(fileID: $0) }
    }

    var body: some View {
        ZStack {
            AppTheme.backgroundPrimary
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    DetailHeaderView(onEditCategory: { self.editingCategory = $0 })

                    Rectangle()
                        .fill(AppTheme.dividerColor)
                        .frame(height: 1)
                        .padding(.horizontal, 32)

                    if !appState.showReadingList && !appState.showRecent {
                        AuthorsSectionView()
                    }

                    if appState.showRecent {
                        RecentView(
                            isDropdownExpanded: $isDropdownExpanded,
                            cardColors: cardColors,
                            onTap: onTap,
                            editAction: editAction,
                            addToCategoryAction: addToCategoryAction,
                            createCategoryAction: createCategoryAction,
                            deleteAction: deleteAction,
                            showInFinderAction: showInFinderAction,
                            addToReadingListAction: addToReadingListAction,
                            removeFromReadingListAction: removeFromReadingListAction
                        )
                    } else {
                        ItemsSectionView(
                            isDropdownExpanded: $isDropdownExpanded,
                            isSearchFocused: $isSearchFocused,
                            cardColors: cardColors,
                            onTap: onTap,
                            editAction: editAction,
                            addToCategoryAction: addToCategoryAction,
                            createCategoryAction: createCategoryAction,
                            deleteAction: deleteAction,
                            showInFinderAction: showInFinderAction,
                            addToReadingListAction: addToReadingListAction,
                            removeFromReadingListAction: removeFromReadingListAction
                        )
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
                .stroke(AppTheme.dividerColor, lineWidth: 1)
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
