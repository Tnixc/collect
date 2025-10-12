import Foundation

struct FileItem: Identifiable {
    let id: UUID
    let fileURL: URL
    let filename: String
    let fileSize: Int64
    let dateAdded: Date
    let dateModified: Date
    
    // TODO: Add QLPreviewItem conformance later
    
    init(id: UUID, fileURL: URL, dateAdded: Date = Date()) {
        self.id = id
        self.fileURL = fileURL
        self.filename = fileURL.lastPathComponent
        self.dateAdded = dateAdded
        
        // Get file attributes
        let attributes = try? FileManager.default.attributesOfItem(atPath: fileURL.path)
        self.fileSize = attributes?[.size] as? Int64 ?? 0
        self.dateModified = attributes?[.modificationDate] as? Date ?? Date()
    }
}