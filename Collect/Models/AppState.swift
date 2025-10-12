import Combine
import Foundation

class AppState: ObservableObject {
    @Published var files: [FileItem] = []
    @Published var metadata: [UUID: FileMetadata] = [:]
    @Published var categories: [Category] = []
    @Published var selectedCategory: String? = nil
    @Published var selectedAuthor: String? = nil
    @Published var searchText: String = ""
    @Published var tagColors: [String: String] = [:]

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

        return filtered
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

    var recentFiles: [FileItem] {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return files.filter { $0.dateAdded > sevenDaysAgo }
    }

    // Methods to update state
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
}
