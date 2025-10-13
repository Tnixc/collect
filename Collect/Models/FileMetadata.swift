import Foundation

struct FileMetadata: Codable, Identifiable {
    var id: UUID
    var title: String?
    var authors: [String]
    var year: Int?
    var tags: [String]
    var dateAdded: Date
    var lastOpened: Date?
    var pages: Int?
    var cardColor: String // Hex color string or name
    var isInReadingList: Bool

    init(id: UUID, title: String? = nil, authors: [String] = [], year: Int? = nil, tags: [String] = [], dateAdded: Date = Date(), lastOpened: Date? = nil, pages: Int? = nil, cardColor: String = "cardBlue", isInReadingList: Bool = false) {
        self.id = id
        self.title = title
        self.authors = authors
        self.year = year
        self.tags = tags
        self.dateAdded = dateAdded
        self.lastOpened = lastOpened
        self.pages = pages
        self.cardColor = cardColor
        self.isInReadingList = isInReadingList
    }
}
