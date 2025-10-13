import AppKit
import SwiftUI

enum AppTheme {
    // MARK: - Category Colors (Saturated)

    static let categoryPeach = Color(hex: "#C97D6E")
    static let categoryDarkRed = Color(hex: "#C98A7D")
    static let categoryPink = Color(hex: "#BC76C1")
    static let categoryPurple = Color(hex: "#8C6FAA")
    static let categoryRed = Color(hex: "#CB7676")
    static let categorySalmon = Color(hex: "#CC8D82")
    static let categoryYellow = Color(hex: "#CC8D70")
    static let categoryOrange = Color(hex: "#DCA466")
    static let categoryDarkGreen = Color(hex: "#4C8E72")
    static let categoryGreen = Color(hex: "#80A665")
    static let categoryTeal = Color(hex: "#5EA994")
    static let categoryBlue = Color(hex: "#5D9AA9")
    static let categoryCyan = Color(hex: "#6394BF")
    static let categoryNavy = Color(hex: "#6872AB")

    // MARK: - Card Colors (Desaturated - Adaptive)

    static var cardPeach: Color {
        ThemeManager.shared.isDarkMode
            ? Color(hex: "#B4A09C") : Color(hex: "#AC9793")
    }

    static var cardDarkRed: Color {
        ThemeManager.shared.isDarkMode
            ? Color(hex: "#B9A9A5") : Color(hex: "#A38D88")
    }

    static var cardPink: Color {
        ThemeManager.shared.isDarkMode
            ? Color(hex: "#B09EB2") : Color(hex: "#A08C93")
    }

    static var cardPurple: Color {
        ThemeManager.shared.isDarkMode
            ? Color(hex: "#9991A1") : Color(hex: "#8D7E8F")
    }

    static var cardRed: Color {
        ThemeManager.shared.isDarkMode
            ? Color(hex: "#B8A2A2") : Color(hex: "#876B69")
    }

    static var cardSalmon: Color {
        ThemeManager.shared.isDarkMode
            ? Color(hex: "#BDADAA") : Color(hex: "#887174")
    }

    static var cardYellow: Color {
        ThemeManager.shared.isDarkMode
            ? Color(hex: "#B6A69E") : Color(hex: "#A38D7E")
    }

    static var cardOrange: Color {
        ThemeManager.shared.isDarkMode
            ? Color(hex: "#BDAE9E") : Color(hex: "#8D826C")
    }

    static var cardDarkGreen: Color {
        ThemeManager.shared.isDarkMode
            ? Color(hex: "#6E847B") : Color(hex: "#696F62")
    }

    static var cardGreen: Color {
        ThemeManager.shared.isDarkMode
            ? Color(hex: "#909A89") : Color(hex: "#5E6E6C")
    }

    static var cardTeal: Color {
        ThemeManager.shared.isDarkMode
            ? Color(hex: "#869A94") : Color(hex: "#6A7B80")
    }

    static var cardBlue: Color {
        ThemeManager.shared.isDarkMode
            ? Color(hex: "#859599") : Color(hex: "#687478")
    }

    static var cardCyan: Color {
        ThemeManager.shared.isDarkMode
            ? Color(hex: "#919EA9") : Color(hex: "#767C88")
    }

    static var cardNavy: Color {
        ThemeManager.shared.isDarkMode
            ? Color(hex: "#8D8F9F") : Color(hex: "#92919F")
    }

    // MARK: - Text Colors

    static var textPrimary: Color {
        ThemeManager.shared.isDarkMode
            ? Color(hex: "#D8D6C9") : Color(hex: "#5A5856")
    }

    static var textSecondary: Color {
        ThemeManager.shared.isDarkMode
            ? Color(hex: "#B2B0A6") : Color(hex: "#696765")
    }

    static var textTertiary: Color {
        ThemeManager.shared.isDarkMode
            ? Color(hex: "#999895") : Color(hex: "#787674")
    }

    static var textQuaternary: Color {
        ThemeManager.shared.isDarkMode
            ? Color(hex: "#7F7F7C") : Color(hex: "#878583")
    }

    // MARK: - Background Colors

    static var backgroundPrimary: Color {
        ThemeManager.shared.isDarkMode
            ? Color(hex: "#121212") : Color(hex: "#EBEAE8")
    }

    static var backgroundSecondary: Color {
        ThemeManager.shared.isDarkMode
            ? Color(hex: "#181818") : Color(hex: "#E1E0DE")
    }

    static var backgroundTertiary: Color {
        ThemeManager.shared.isDarkMode
            ? Color(hex: "#1F1F1F") : Color(hex: "#D2D0CE")
    }

    // MARK: - Gray Scale

    static var gray1: Color {
        ThemeManager.shared.isDarkMode
            ? Color(hex: "#666666") : Color(hex: "#969492")
    }

    static var gray2: Color {
        ThemeManager.shared.isDarkMode
            ? Color(hex: "#4C4C4C") : Color(hex: "#A5A3A1")
    }

    static var gray3: Color {
        ThemeManager.shared.isDarkMode
            ? Color(hex: "#333333") : Color(hex: "#B4B2B0")
    }

    static var gray4: Color {
        ThemeManager.shared.isDarkMode
            ? Color(hex: "#060606") : Color(hex: "#C3C1BF")
    }

    // MARK: - Semantic Colors

    static var borderColor: Color {
        ThemeManager.shared.isDarkMode
            ? Color(hex: "#333333") : Color(hex: "#C3C1BF")
    }

    static var dividerColor: Color {
        ThemeManager.shared.isDarkMode
            ? Color(hex: "#333333") : Color(hex: "#D2D0CE")
    }

    static var destructive: Color {
        ThemeManager.shared.isDarkMode
            ? Color(hex: "#CB7676") : Color(hex: "#B4463C")
    }

    static var accentPrimary: Color {
        ThemeManager.shared.isDarkMode
            ? Color(hex: "#5D9AA9") : Color(hex: "#4B8CA0")
    }

    static var accentSecondary: Color {
        ThemeManager.shared.isDarkMode
            ? Color(hex: "#999895") : Color(hex: "#878583")
    }

    static var dropdownShadow: Color {
        Color.black.opacity(ThemeManager.shared.isDarkMode ? 0.3 : 0.1)
    }

    static var pillBackground: Color {
        ThemeManager.shared.isDarkMode
            ? Color.white.opacity(0.1)
            : Color.white.opacity(0.35)
    }

    static var pillBackgroundFaint: Color {
        ThemeManager.shared.isDarkMode
            ? Color.white.opacity(0.05)
            : Color.white.opacity(0.05)
    }

    static var sidebarItemActive: Color {
        ThemeManager.shared.isDarkMode
            ? Color(hex: "#1F1F1F") : Color(hex: "#E1E0DE")
    }

    static var sidebarItemHover: Color {
        ThemeManager.shared.isDarkMode
            ? Color(hex: "#181818") : Color(hex: "#EBEAE8")
    }

    static var selectionStroke: Color {
        ThemeManager.shared.isDarkMode
            ? Color(hex: "#666666") : Color(hex: "#A5A3A1")
    }

    static var buttonTextLight: Color {
        ThemeManager.shared.isDarkMode ? Color(hex: "#D8D6C9") : Color.white
    }

    // MARK: - Color Palettes

    static let categoryColors: [String: Color] = [
        "peach": categoryPeach,
        "darkRed": categoryDarkRed,
        "pink": categoryPink,
        "purple": categoryPurple,
        "red": categoryRed,
        "salmon": categorySalmon,
        "yellow": categoryYellow,
        "orange": categoryOrange,
        "darkGreen": categoryDarkGreen,
        "green": categoryGreen,
        "teal": categoryTeal,
        "blue": categoryBlue,
        "cyan": categoryCyan,
        "navy": categoryNavy,
    ]

    static var cardColors: [String: Color] {
        [
            "cardPeach": cardPeach,
            "cardDarkRed": cardDarkRed,
            "cardPink": cardPink,
            "cardPurple": cardPurple,
            "cardRed": cardRed,
            "cardSalmon": cardSalmon,
            "cardYellow": cardYellow,
            "cardOrange": cardOrange,
            "cardDarkGreen": cardDarkGreen,
            "cardGreen": cardGreen,
            "cardTeal": cardTeal,
            "cardBlue": cardBlue,
            "cardCyan": cardCyan,
            "cardNavy": cardNavy,
        ]
    }

    // MARK: - Helper Methods

    static func categoryColor(for name: String) -> Color {
        categoryColors[name] ?? categoryBlue
    }

    static func cardColor(for name: String) -> Color {
        cardColors[name] ?? cardBlue
    }

    static func categoryNSColor(for name: String) -> NSColor {
        NSColor(categoryColor(for: name))
    }

    // MARK: - NSColor Variants

    static var textPrimaryNSColor: NSColor {
        ThemeManager.shared.isDarkMode
            ? NSColor(hex: "#D8D6C9") : NSColor(hex: "#5A5856")
    }

    static var textSecondaryNSColor: NSColor {
        ThemeManager.shared.isDarkMode
            ? NSColor(hex: "#B2B0A6") : NSColor(hex: "#696765")
    }

    static var textTertiaryNSColor: NSColor {
        ThemeManager.shared.isDarkMode
            ? NSColor(hex: "#999895") : NSColor(hex: "#787674")
    }

    static var backgroundPrimaryNSColor: NSColor {
        ThemeManager.shared.isDarkMode
            ? NSColor(hex: "#121212") : NSColor(hex: "#EBEAE8")
    }

    static var backgroundSecondaryNSColor: NSColor {
        ThemeManager.shared.isDarkMode
            ? NSColor(hex: "#181818") : NSColor(hex: "#E1E0DE")
    }

    static var dividerNSColor: NSColor {
        ThemeManager.shared.isDarkMode
            ? NSColor(hex: "#333333") : NSColor(hex: "#D2D0CE")
    }

    static var shadowNSColor: NSColor {
        NSColor.black.withAlphaComponent(
            ThemeManager.shared.isDarkMode ? 0.4 : 0.06
        )
    }

    static var pillBackgroundNSColor: NSColor {
        ThemeManager.shared.isDarkMode
            ? NSColor(white: 1, alpha: 0.1)
            : NSColor(white: 1, alpha: 0.55)
    }

    static var pillBackgroundFaintNSColor: NSColor {
        ThemeManager.shared.isDarkMode
            ? NSColor(white: 1, alpha: 0.05)
            : NSColor(white: 1, alpha: 0.25)
    }

    // MARK: - NSColor Arrays

    static let categoryNSColors: [NSColor] = [
        NSColor(categoryPeach),
        NSColor(categoryDarkRed),
        NSColor(categoryPink),
        NSColor(categoryPurple),
        NSColor(categoryRed),
        NSColor(categorySalmon),
        NSColor(categoryYellow),
        NSColor(categoryOrange),
        NSColor(categoryDarkGreen),
        NSColor(categoryGreen),
        NSColor(categoryTeal),
        NSColor(categoryBlue),
        NSColor(categoryCyan),
        NSColor(categoryNavy),
    ]

    static var cardNSColors: [NSColor] {
        [
            NSColor(cardPeach),
            NSColor(cardDarkRed),
            NSColor(cardPink),
            NSColor(cardPurple),
            NSColor(cardRed),
            NSColor(cardSalmon),
            NSColor(cardYellow),
            NSColor(cardOrange),
            NSColor(cardDarkGreen),
            NSColor(cardGreen),
            NSColor(cardTeal),
            NSColor(cardBlue),
            NSColor(cardCyan),
            NSColor(cardNavy),
        ]
    }

    // MARK: - Card to Category Mapping

    static var cardToCategoryMapping: [(card: NSColor, category: NSColor)] {
        [
            (NSColor(cardPeach), NSColor(categoryPeach)),
            (NSColor(cardDarkRed), NSColor(categoryDarkRed)),
            (NSColor(cardPink), NSColor(categoryPink)),
            (NSColor(cardPurple), NSColor(categoryPurple)),
            (NSColor(cardRed), NSColor(categoryRed)),
            (NSColor(cardSalmon), NSColor(categorySalmon)),
            (NSColor(cardYellow), NSColor(categoryYellow)),
            (NSColor(cardOrange), NSColor(categoryOrange)),
            (NSColor(cardDarkGreen), NSColor(categoryDarkGreen)),
            (NSColor(cardGreen), NSColor(categoryGreen)),
            (NSColor(cardTeal), NSColor(categoryTeal)),
            (NSColor(cardBlue), NSColor(categoryBlue)),
            (NSColor(cardCyan), NSColor(categoryCyan)),
            (NSColor(cardNavy), NSColor(categoryNavy)),
        ]
    }

    static func saturatedColor(for cardColor: NSColor) -> NSColor {
        for mapping in cardToCategoryMapping {
            if abs(mapping.card.redComponent - cardColor.redComponent) < 0.01
                && abs(mapping.card.greenComponent - cardColor.greenComponent)
                < 0.01
                && abs(mapping.card.blueComponent - cardColor.blueComponent)
                < 0.01
            {
                return mapping.category
            }
        }
        return cardColor
    }
}

// MARK: - Hex Color Extensions

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
        case 6:
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
