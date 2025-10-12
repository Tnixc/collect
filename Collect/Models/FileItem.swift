import Foundation

struct FileItem: Identifiable {
    let id: UUID
    let fileURL: URL
    let filename: String
    let fileSize: Int64
    let dateAdded: Date
    let dateModified: Date

    init(id: UUID, fileURL: URL, dateAdded: Date = Date()) {
        self.id = id
        self.fileURL = fileURL
        filename = fileURL.lastPathComponent
        self.dateAdded = dateAdded

        // Get file attributes
        let attributes = try? FileManager.default.attributesOfItem(atPath: fileURL.path)
        fileSize = attributes?[.size] as? Int64 ?? 0
        dateModified = attributes?[.modificationDate] as? Date ?? Date()
    }
}
