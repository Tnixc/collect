import Foundation

struct FileMetadata: Codable, Identifiable {
    var id: UUID
    var title: String?
    var authors: [String]
    var year: Int?
    var tags: [String]
    var notes: String?
    var dateAdded: Date
    var cardColor: String // Hex color string or name
    
    init(id: UUID, title: String? = nil, authors: [String] = [], year: Int? = nil, tags: [String] = [], notes: String? = nil, dateAdded: Date = Date(), cardColor: String = "cardTan") {
        self.id = id
        self.title = title
        self.authors = authors
        self.year = year
        self.tags = tags
        self.notes = notes
        self.dateAdded = dateAdded
        self.cardColor = cardColor
    }
}