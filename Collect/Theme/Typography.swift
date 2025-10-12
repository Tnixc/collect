import SwiftUI

// Typography definitions
struct Typography {
    // Display/Title: System serif for compatibility
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .serif)
    static let title = Font.system(size: 24, weight: .semibold, design: .serif)
    static let title2 = Font.system(size: 20, weight: .medium, design: .serif)
    
    // Body/UI: SF Pro (system)
    static let body = Font.system(size: 15)
    static let caption = Font.system(size: 13)
    static let small = Font.system(size: 11)
}