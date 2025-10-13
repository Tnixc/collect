import SwiftUI

@main
struct CollectApp: App {
    @StateObject private var keyboardNav = KeyboardNavigationManager.shared
    @StateObject private var themeManager = ThemeManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(keyboardNav)
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.effectiveColorScheme)
                .onReceive(themeManager.$effectiveColorScheme) { colorScheme in
                    updateWindowAppearance(colorScheme)
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
    }

    private func updateWindowAppearance(_: ColorScheme) {
        DispatchQueue.main.async {
            if let window = NSApp.windows.first {
                window.backgroundColor = AppTheme.backgroundSecondaryNSColor
            }
        }
    }
}
