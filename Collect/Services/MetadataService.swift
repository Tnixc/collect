import Foundation

struct SavedData: Codable {
    let metadata: [FileMetadata]
    let tagColors: [String: String]
}

class MetadataService {
    static let shared = MetadataService()

    private let fileManager = FileManager.default
    private let metadataFilename = "metadata.json"

    var tagColors: [String: String] = [:]

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
            let saved = try decoder.decode(SavedData.self, from: data)
            tagColors = saved.tagColors
            var metadataDict: [UUID: FileMetadata] = [:]
            for meta in saved.metadata {
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
            let saved = SavedData(metadata: Array(metadata.values), tagColors: tagColors)
            let data = try encoder.encode(saved)
            try data.write(to: url)
        } catch {
            print("Error saving metadata: \(error)")
        }
    }

    // Create new metadata entry
    func createMetadata(fileID: UUID, title: String? = nil, pages: Int? = nil) -> FileMetadata {
        // Assign a random card color from the available palette
        let cardColorNames = [
            "cardPeach", "cardDarkRed", "cardPink", "cardPurple",
            "cardRed", "cardSalmon", "cardYellow", "cardOrange",
            "cardDarkGreen", "cardGreen", "cardTeal", "cardBlue",
            "cardCyan", "cardNavy",
        ]
        let randomColor = cardColorNames[abs(fileID.hashValue) % cardColorNames.count]
        return FileMetadata(id: fileID, title: title, pages: pages, cardColor: randomColor)
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
