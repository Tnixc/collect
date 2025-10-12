import Combine
import Foundation

// Assuming these are in the same module, but adding imports if needed
// import "./FileItem"
// import "./FileMetadata"
// import "./Category"
// import "../Services/MetadataService"
// import "../Services/FileSystemService"

public enum SortOption: String, CaseIterable {
    case recentlyAdded = "Recently Added"
    case recentlyOpened = "Recently Opened"
    case dateModified = "Date Modified"
    case titleAZ = "Title A-Z"
    case titleZA = "Title Z-A"
    case authorAZ = "Author A-Z"
    case authorZA = "Author Z-A"

    var iconName: String {
        switch self {
        case .recentlyAdded:
            return "plus.circle"
        case .recentlyOpened:
            return "clock"
        case .dateModified:
            return "calendar"
        case .titleAZ:
            return "text.insert"
        case .titleZA:
            return "text.append"
        case .authorAZ:
            return "person.2"
        case .authorZA:
            return "person.2"
        }
    }
}

public enum ViewMode: String, CaseIterable, Hashable {
    case grid = "Grid"
    case list = "List"
    
    var iconName: String {
        switch self {
        case .grid:
            return "square.grid.2x2"
        case .list:
            return "list.bullet"
        }
    }
}

class AppState: ObservableObject {
    @Published var files: [FileItem] = []
    @Published var metadata: [UUID: FileMetadata] = [:]
    @Published var categories: [Category] = []
    @Published var selectedCategory: String? = nil
    @Published var selectedAuthor: String? = nil
    @Published var searchText: String = ""
    @Published var tagColors: [String: String] = [:]
    @Published var sortOption: SortOption = .recentlyOpened {
        didSet {
            UserDefaults.standard.set(sortOption.rawValue, forKey: "sortOption")
        }
    }
    @Published var showReadingList: Bool = false
    @Published var showRecent: Bool = false
    @Published var viewMode: ViewMode = .grid {
        didSet {
            UserDefaults.standard.set(viewMode.rawValue, forKey: "viewMode")
        }
    }

    init() {
        // Load sort option from UserDefaults
        if let savedSortOption = UserDefaults.standard.string(forKey: "sortOption"),
           let option = SortOption(rawValue: savedSortOption)
        {
            sortOption = option
        }
        
        // Load view mode from UserDefaults
        if let savedViewMode = UserDefaults.standard.string(forKey: "viewMode"),
           let mode = ViewMode(rawValue: savedViewMode)
        {
            viewMode = mode
        }
    }

    // Computed properties
    var filteredFiles: [FileItem] {
        var filtered = files

        // Filter by category/tag
        if let category = selectedCategory {
            if category == "Uncategorized" {
                filtered = filtered.filter { file in
                    guard let meta = metadata[file.id] else { return true }
                    return meta.tags.isEmpty
                }
            } else {
                filtered = filtered.filter { file in
                    guard let meta = metadata[file.id] else { return false }
                    return meta.tags.contains(category)
                }
            }
        }

        // Filter by author
        if let author = selectedAuthor {
            filtered = filtered.filter { file in
                guard let meta = metadata[file.id] else { return false }
                return meta.authors.contains(author)
            }
        }

        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { file in
                let meta = metadata[file.id]
                let titleMatch = meta?.title?.localizedCaseInsensitiveContains(searchText) ?? false
                let authorMatch = meta?.authors.contains { $0.localizedCaseInsensitiveContains(searchText) } ?? false
                let filenameMatch = file.filename.localizedCaseInsensitiveContains(searchText)
                return titleMatch || authorMatch || filenameMatch
            }
        }

        // Sort the filtered files
        return filtered.sorted { lhs, rhs in
            switch sortOption {
            case .recentlyAdded:
                return lhs.dateAdded > rhs.dateAdded
            case .recentlyOpened:
                let lhsOpened = metadata[lhs.id]?.lastOpened ?? Date.distantPast
                let rhsOpened = metadata[rhs.id]?.lastOpened ?? Date.distantPast
                return lhsOpened > rhsOpened
            case .dateModified:
                return lhs.dateModified > rhs.dateModified
            case .titleAZ:
                let lhsTitle = metadata[lhs.id]?.title ?? lhs.filename
                let rhsTitle = metadata[rhs.id]?.title ?? rhs.filename
                return lhsTitle.localizedCaseInsensitiveCompare(rhsTitle) == .orderedAscending
            case .titleZA:
                let lhsTitle = metadata[lhs.id]?.title ?? lhs.filename
                let rhsTitle = metadata[rhs.id]?.title ?? rhs.filename
                return lhsTitle.localizedCaseInsensitiveCompare(rhsTitle) == .orderedDescending
            case .authorAZ:
                let lhsAuthors = metadata[lhs.id]?.authors ?? []
                let rhsAuthors = metadata[rhs.id]?.authors ?? []
                let lhsAuthor = lhsAuthors.first ?? ""
                let rhsAuthor = rhsAuthors.first ?? ""
                return lhsAuthor.localizedCaseInsensitiveCompare(rhsAuthor) == .orderedAscending
            case .authorZA:
                let lhsAuthors = metadata[lhs.id]?.authors ?? []
                let rhsAuthors = metadata[rhs.id]?.authors ?? []
                let lhsAuthor = lhsAuthors.first ?? ""
                let rhsAuthor = rhsAuthors.first ?? ""
                return lhsAuthor.localizedCaseInsensitiveCompare(rhsAuthor) == .orderedDescending
            }
        }
    }

    var allAuthors: [String] {
        var authors = Set<String>()
        for meta in metadata.values {
            authors.formUnion(meta.authors)
        }
        return Array(authors).sorted()
    }

    var authorCounts: [String: Int] {
        var counts: [String: Int] = [:]
        for meta in metadata.values {
            for author in meta.authors {
                counts[author, default: 0] += 1
            }
        }
        return counts
    }

    var filteredAuthorCounts: [String: Int] {
        var counts: [String: Int] = [:]

        // Get the file IDs from filteredFiles (which are already filtered by category)
        let filteredFileIDs = Set(filteredFiles.map { $0.id })

        // Count authors only from filtered files
        for fileID in filteredFileIDs {
            if let meta = metadata[fileID] {
                for author in meta.authors {
                    counts[author, default: 0] += 1
                }
            }
        }
        return counts
    }

    var recentFiles: [FileItem] {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return files.filter { $0.dateAdded > sevenDaysAgo }
    }

    var lastOpenedFiles: [FileItem] {
        return files
            .filter { metadata[$0.id]?.lastOpened != nil }
            .sorted { lhs, rhs in
                let lhsOpened = metadata[lhs.id]?.lastOpened ?? Date.distantPast
                let rhsOpened = metadata[rhs.id]?.lastOpened ?? Date.distantPast
                return lhsOpened > rhsOpened
            }
            .prefix(3)
            .map { $0 }
    }

    var lastAddedFiles: [FileItem] {
        return files
            .sorted { $0.dateAdded > $1.dateAdded }
            .prefix(3)
            .map { $0 }
    }

    var readingListFiles: [FileItem] {
        return files.filter { file in
            metadata[file.id]?.isInReadingList == true
        }
    }

    var readingListCount: Int {
        return readingListFiles.count
    }

    // Methods to update state
    func addToReadingList(fileID: UUID) {
        guard var meta = metadata[fileID] else { return }
        meta.isInReadingList = true
        updateMetadata(for: fileID, metadata: meta)
    }

    func removeFromReadingList(fileID: UUID) {
        guard var meta = metadata[fileID] else { return }
        meta.isInReadingList = false
        updateMetadata(for: fileID, metadata: meta)
    }

    func toggleReadingList(fileID: UUID) {
        guard let meta = metadata[fileID] else { return }
        if meta.isInReadingList {
            removeFromReadingList(fileID: fileID)
        } else {
            addToReadingList(fileID: fileID)
        }
    }

    func updateMetadata(for fileID: UUID, metadata: FileMetadata) {
        self.metadata[fileID] = metadata
        MetadataService.shared.tagColors = tagColors
        MetadataService.shared.save(metadata: self.metadata)
        updateCategories()
    }

    func deleteMetadata(for fileID: UUID) {
        metadata.removeValue(forKey: fileID)
        updateCategories()
    }

    func updateCategories() {
        var tagCounts: [String: Int] = [:]
        var uncategorizedCount = 0

        for file in files {
            if let meta = metadata[file.id], !meta.tags.isEmpty {
                for tag in meta.tags {
                    tagCounts[tag, default: 0] += 1
                }
            } else {
                uncategorizedCount += 1
            }
        }

        let colors = ["blue", "green", "orange", "pink", "purple", "yellow", "gray", "tan"]
        var colorIndex = 0

        categories = tagCounts.map { name, count in
            let color = tagColors[name] ?? colors[colorIndex % colors.count]
            if tagColors[name] == nil { colorIndex += 1 }
            return Category(name: name, color: color, itemCount: count)
        }.sorted(by: { $0.name < $1.name })

        if uncategorizedCount > 0 {
            categories.insert(Category(name: "Uncategorized", color: "gray", itemCount: uncategorizedCount), at: 0)
        }
    }

    func setFiles(_ files: [FileItem]) {
        self.files = files
        updateCategories()
    }

    func renameFile(fileID: UUID, newFilename: String) {
        guard let index = files.firstIndex(where: { $0.id == fileID }) else { return }
        let oldFile = files[index]
        do {
            let newURL = try FileSystemService.shared.renameFile(at: oldFile.fileURL, to: newFilename)
            let newFileItem = FileItem(id: fileID, fileURL: newURL)
            files[index] = newFileItem
            // Update metadata title if it was the filename
            if var meta = metadata[fileID], meta.title == oldFile.filename {
                meta.title = newFilename
                updateMetadata(for: fileID, metadata: meta)
            }
        } catch {
            print("Error renaming file: \(error)")
        }
    }

    func deleteFile(fileID: UUID) {
        guard let index = files.firstIndex(where: { $0.id == fileID }) else { return }
        let file = files[index]
        do {
            try FileSystemService.shared.deleteFile(at: file.fileURL)
            files.remove(at: index)
            deleteMetadata(for: fileID)
        } catch {
            print("Error deleting file: \(error)")
        }
    }

    func renameCategory(from oldName: String, to newName: String, color: String) {
        // Prevent renaming the "Uncategorized" category
        guard oldName != "Uncategorized" else {
            print("Cannot rename the Uncategorized category")
            return
        }

        // Prevent renaming to "Uncategorized"
        guard newName != "Uncategorized" else {
            print("Cannot rename a category to Uncategorized")
            return
        }

        // Update tagColors
        tagColors.removeValue(forKey: oldName)
        tagColors[newName] = color

        // Update all metadata tags
        for (fileID, var meta) in metadata {
            if let index = meta.tags.firstIndex(of: oldName) {
                meta.tags[index] = newName
                metadata[fileID] = meta
            }
        }

        // Update selected category if it was the renamed one
        if selectedCategory == oldName {
            selectedCategory = newName
        }

        // Save metadata and update categories
        MetadataService.shared.tagColors = tagColors
        MetadataService.shared.save(metadata: metadata)
        updateCategories()
    }

    func deleteCategory(_ categoryName: String) {
        // Prevent deleting the "Uncategorized" category
        guard categoryName != "Uncategorized" else {
            print("Cannot delete the Uncategorized category")
            return
        }

        // Remove from tagColors
        tagColors.removeValue(forKey: categoryName)

        // Remove category from all metadata tags
        for (fileID, var meta) in metadata {
            if let index = meta.tags.firstIndex(of: categoryName) {
                meta.tags.remove(at: index)
                metadata[fileID] = meta
            }
        }

        // Clear selected category if it was the deleted one
        if selectedCategory == categoryName {
            selectedCategory = nil
        }

        // Save metadata and update categories
        MetadataService.shared.tagColors = tagColors
        MetadataService.shared.save(metadata: metadata)
        updateCategories()
    }
}
