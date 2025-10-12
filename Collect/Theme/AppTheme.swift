import SwiftUI

enum AppTheme {
    // Background colors
    static let backgroundPrimary = Color(red: 0.98, green: 0.98, blue: 0.97)
    static let backgroundSecondary = Color(red: 0.96, green: 0.95, blue: 0.94)
    static let backgroundTertiary = Color.white

    // Text colors
    static let textPrimary = Color(red: 0.2, green: 0.18, blue: 0.16)
    static let textSecondary = Color(red: 0.55, green: 0.52, blue: 0.48)
    static let textTertiary = Color(red: 0.7, green: 0.67, blue: 0.63)

    // Accent colors
    // rgba(0, 136, 223, 1)
    static let accentPrimary = Color(red: 0, green: 0.53, blue: 0.87)
    static let accentSecondary = Color(red: 0.55, green: 0.52, blue: 0.48)

    // Card colors (pastels matching the reference)
    static let cardTan = Color(red: 0.93, green: 0.88, blue: 0.82)
    static let cardYellow = Color(red: 0.95, green: 0.94, blue: 0.78)
    static let cardGreen = Color(red: 0.85, green: 0.92, blue: 0.82)
    static let cardBlue = Color(red: 0.84, green: 0.89, blue: 0.92)
    static let cardPink = Color(red: 0.95, green: 0.88, blue: 0.88)
    static let cardPurple = Color(red: 0.90, green: 0.87, blue: 0.93)
    static let cardGray = Color(red: 0.91, green: 0.90, blue: 0.89)
    static let cardPeach = Color(red: 0.95, green: 0.90, blue: 0.85)

    // Semantic colors
    static let borderColor = Color(red: 0.88, green: 0.86, blue: 0.84)
    static let dividerColor = Color(red: 0.90, green: 0.88, blue: 0.86)
    static let sidebarItemActive = Color(red: 0.94, green: 0.93, blue: 0.92)
    static let sidebarItemHover = Color(red: 0.97, green: 0.96, blue: 0.95)

    // Badge colors (for author chips and tags)
    static let badgeBrown = Color(red: 0.85, green: 0.80, blue: 0.72)
    static let badgeBeige = Color(red: 0.90, green: 0.87, blue: 0.82)

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
    ]

    // Get color by name
    static func color(for name: String) -> Color {
        cardColors[name] ?? cardTan
    }
}
