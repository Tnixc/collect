import Foundation

struct Category: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let color: String // Hex or name
    var itemCount: Int

    init(name: String, color: String = "blue", itemCount: Int = 0) {
        self.name = name
        self.color = color
        self.itemCount = itemCount
    }
}
