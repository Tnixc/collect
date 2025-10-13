import AppKit
import SwiftUI

enum AppTheme {
    // Background colors
    static let backgroundPrimary = Color(hex: "#f0efed")
    static let backgroundSecondary = Color(hex: "#e1e0de")
    static let backgroundTertiary = Color(hex: "#ebeae8")

    // Text colors
    static let textPrimary = Color(hex: "#5a5856")
    static let textSecondary = Color(hex: "#878583")
    static let textTertiary = Color(hex: "#a5a3a1")

    // Accent colors
    static let accentPrimary = Color(hex: "#4b8ca0")
    static let accentSecondary = Color(hex: "#878583")

    // Semantic colors for actions
    static let destructive = Color(hex: "#b4463c")
    static let buttonTextLight = Color.white
    static let dropdownShadow = Color.black.opacity(0.1)
    static let pillBackground = Color.white.opacity(0.35)
    static let pillBackgroundFaint = Color.white.opacity(0.05)

    // Card colors (muted versions)
    static let cardTan = Color(hex: "#d2d0ce")
    static let cardYellow = Color(hex: "#d9cfb8")
    static let cardGreen = Color(hex: "#c4d1ba")
    static let cardBlue = Color(hex: "#c4d6dd")
    static let cardPink = Color(hex: "#dcc9d4")
    static let cardPurple = Color(hex: "#d4d2dd")
    static let cardGray = Color(hex: "#dadad9")
    static let cardPeach = Color(hex: "#e4d3cd")
    static let cardRed = Color(hex: "#ddc7c4")
    static let cardOrange = Color(hex: "#e8d9c8")
    static let cardTeal = Color(hex: "#c4dbd9")
    static let cardNavy = Color(hex: "#c9d2dd")

    // Category colors (saturated originals)
    static let categoryRed = Color(hex: "#b4463c")
    static let categoryDarkRed = Color(hex: "#aa505a")
    static let categoryPeach = Color(hex: "#d27d6e")
    static let categorySalmon = Color(hex: "#cd735f")
    static let categoryPink = Color(hex: "#be6e8c")
    static let categoryPurple = Color(hex: "#a064aa")
    static let categoryLavender = Color(hex: "#827db4")
    static let categoryOrange = Color(hex: "#dc8246")
    static let categoryYellow = Color(hex: "#be913c")
    static let categoryGreen = Color(hex: "#698250")
    static let categoryTeal = Color(hex: "#46877d")
    static let categoryBlue = Color(hex: "#4b8ca0")
    static let categoryCyan = Color(hex: "#508291")
    static let categoryNavy = Color(hex: "#5a73a5")

    // Card color palette
    static let cardColors: [String: Color] = [
        "cardTan": cardTan,
        "cardYellow": cardYellow,
        "cardGreen": cardGreen,
        "cardBlue": cardBlue,
        "cardPink": cardPink,
        "cardPurple": cardPurple,
        "cardGray": cardGray,
        "cardPeach": cardPeach,
        "cardRed": cardRed,
        "cardOrange": cardOrange,
        "cardTeal": cardTeal,
        "cardNavy": cardNavy,
    ]

    // Category color palette
    static let categoryColors: [String: Color] = [
        "red": categoryRed,
        "darkRed": categoryDarkRed,
        "peach": categoryPeach,
        "salmon": categorySalmon,
        "pink": categoryPink,
        "purple": categoryPurple,
        "lavender": categoryLavender,
        "orange": categoryOrange,
        "yellow": categoryYellow,
        "green": categoryGreen,
        "teal": categoryTeal,
        "blue": categoryBlue,
        "cyan": categoryCyan,
        "navy": categoryNavy,
    ]

    // Get color by name
    static func color(for name: String) -> Color {
        cardColors[name] ?? cardTan
    }

    // Category color mapping
    static func categoryColor(for name: String) -> Color {
        categoryColors[name] ?? categoryBlue
    }

    // Category color mapping for NSColor (AppKit)
    static func categoryNSColor(for name: String) -> NSColor {
        NSColor(categoryColor(for: name))
    }

    // Card to Category color mapping (muted card -> saturated category)
    static let cardToCategoryMapping: [NSColor: NSColor] = [
        NSColor(cardTan): NSColor(hex: "#878583"), // Gray-ish
        NSColor(cardYellow): NSColor(categoryYellow),
        NSColor(cardGreen): NSColor(categoryGreen),
        NSColor(cardBlue): NSColor(categoryBlue),
        NSColor(cardPink): NSColor(categoryPink),
        NSColor(cardPurple): NSColor(categoryPurple),
        NSColor(cardGray): NSColor(hex: "#5a5856"), // Darker gray
        NSColor(cardPeach): NSColor(categoryPeach),
        NSColor(cardRed): NSColor(categoryRed),
        NSColor(cardOrange): NSColor(categoryOrange),
        NSColor(cardTeal): NSColor(categoryTeal),
        NSColor(cardNavy): NSColor(categoryNavy),
    ]

    // Get saturated category color for a given card color
    static func saturatedColor(for cardColor: NSColor) -> NSColor {
        // Try to find exact match in mapping
        for (card, category) in cardToCategoryMapping {
            if abs(card.redComponent - cardColor.redComponent) < 0.01
                && abs(card.greenComponent - cardColor.greenComponent) < 0.01
                && abs(card.blueComponent - cardColor.blueComponent) < 0.01
            {
                return category
            }
        }
        // Fallback to same color if no mapping found
        return cardColor
    }

    // NSColor equivalents for AppKit
    static let dividerNSColor = NSColor(hex: "#d2d0ce")
    static let textPrimaryNSColor = NSColor(hex: "#5a5856")
    static let textSecondaryNSColor = NSColor(hex: "#878583")
    static let textTertiaryNSColor = NSColor(hex: "#a5a3a1")
    static let shadowNSColor = NSColor.black.withAlphaComponent(0.06)
    static let pillBackgroundNSColor = NSColor(white: 1, alpha: 0.55)
    static let pillBackgroundFaintNSColor = NSColor(white: 1, alpha: 0.25)

    // Semantic colors
    static let borderColor = Color(hex: "#c3c1bf")
    static let dividerColor = Color(hex: "#d2d0ce")
    static let sidebarItemActive = Color(hex: "#e1e0de")
    static let sidebarItemHover = Color(hex: "#ebeae8")
    static let selectionStroke = Color(hex: "#a5a3a1")

    // Card colors as NSColor array
    static let cardNSColors: [NSColor] = [
        NSColor(cardTan),
        NSColor(cardYellow),
        NSColor(cardGreen),
        NSColor(cardBlue),
        NSColor(cardPink),
        NSColor(cardPurple),
        NSColor(cardGray),
        NSColor(cardPeach),
        NSColor(cardRed),
        NSColor(cardOrange),
        NSColor(cardTeal),
        NSColor(cardNavy),
    ]

    // Category colors as NSColor array
    static let categoryNSColors: [NSColor] = [
        NSColor(categoryRed),
        NSColor(categoryDarkRed),
        NSColor(categoryPeach),
        NSColor(categorySalmon),
        NSColor(categoryPink),
        NSColor(categoryPurple),
        NSColor(categoryLavender),
        NSColor(categoryOrange),
        NSColor(categoryYellow),
        NSColor(categoryGreen),
        NSColor(categoryTeal),
        NSColor(categoryBlue),
        NSColor(categoryCyan),
        NSColor(categoryNavy),
    ]
}

// Hex color extensions
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(
            in: CharacterSet.alphanumerics.inverted
        )
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r: UInt64
        let g: UInt64
        let b: UInt64
        switch hex.count {
        case 6: // RGB
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }
        self.init(
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255
        )
    }
}

extension NSColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(
            in: CharacterSet.alphanumerics.inverted
        )
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r: UInt64
        let g: UInt64
        let b: UInt64
        switch hex.count {
        case 6:
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: 1
        )
    }
}
