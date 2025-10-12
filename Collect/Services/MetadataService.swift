import Foundation

class MetadataService {
    static let shared = MetadataService()
    
    private let fileManager = FileManager.default
    private let metadataFilename = "metadata.json"
    
    private var applicationSupportDirectory: URL? {
        try? fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("Collect")
    }
    
    private var metadataURL: URL? {
        applicationSupportDirectory?.appendingPathComponent(metadataFilename)
    }
    
    private init() {
        // Ensure directory exists
        if let dir = applicationSupportDirectory {
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        }
    }
    
    // Load metadata from JSON file
    func load() -> [UUID: FileMetadata] {
        guard let url = metadataURL else { return [:] }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let metadataArray = try decoder.decode([FileMetadata].self, from: data)
            var metadataDict: [UUID: FileMetadata] = [:]
            for meta in metadataArray {
                metadataDict[meta.id] = meta
            }
            return metadataDict
        } catch {
            print("Error loading metadata: \(error)")
            return [:]
        }
    }
    
    // Save metadata to JSON file
    func save(metadata: [UUID: FileMetadata]) {
        guard let url = metadataURL else { return }
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            let metadataArray = Array(metadata.values)
            let data = try encoder.encode(metadataArray)
            try data.write(to: url)
        } catch {
            print("Error saving metadata: \(error)")
        }
    }
    
    // Create new metadata entry
    func createMetadata(fileID: UUID, title: String? = nil, pages: Int? = nil) -> FileMetadata {
        FileMetadata(id: fileID, title: title, pages: pages)
    }
    
    // Update metadata (same as save, but for individual)
    func updateMetadata(fileID: UUID, metadata: FileMetadata) {
        var current = load()
        current[fileID] = metadata
        save(metadata: current)
    }
    
    // Delete metadata entry
    func deleteMetadata(fileID: UUID) {
        var current = load()
        current.removeValue(forKey: fileID)
        save(metadata: current)
    }
}