import Combine
import SwiftUI

// Notification name for theme changes
extension Notification.Name {
    static let themeDidChange = Notification.Name("ThemeDidChange")
}

enum ThemeMode: String, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"

    var iconName: String {
        switch self {
        case .system:
            return "circle.lefthalf.filled"
        case .light:
            return "sun.max"
        case .dark:
            return "moon"
        }
    }
}

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published var themeMode: ThemeMode = .system {
        didSet {
            UserDefaults.standard.set(themeMode.rawValue, forKey: "themeMode")
            updateEffectiveColorScheme()
        }
    }

    @Published var effectiveColorScheme: ColorScheme = .light {
        didSet {
            // Post notification when effective color scheme changes
            NotificationCenter.default.post(name: .themeDidChange, object: nil)
        }
    }

    private var systemColorSchemeObserver: AnyCancellable?

    private init() {
        // Load saved theme preference
        if let savedMode = UserDefaults.standard.string(forKey: "themeMode"),
           let mode = ThemeMode(rawValue: savedMode)
        {
            themeMode = mode
        }

        // Observe system appearance changes
        observeSystemAppearance()
        updateEffectiveColorScheme()
    }

    private func observeSystemAppearance() {
        // Monitor system appearance changes
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("AppleInterfaceThemeChangedNotification"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateEffectiveColorScheme()
        }
    }

    private func updateEffectiveColorScheme() {
        switch themeMode {
        case .system:
            effectiveColorScheme = getSystemColorScheme()
        case .light:
            effectiveColorScheme = .light
        case .dark:
            effectiveColorScheme = .dark
        }
    }

    private func getSystemColorScheme() -> ColorScheme {
        let appearance = NSApp.effectiveAppearance
        if appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua {
            return .dark
        }
        return .light
    }

    var isDarkMode: Bool {
        effectiveColorScheme == .dark
    }
}
