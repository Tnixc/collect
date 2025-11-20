import AppKit
import SwiftUI

@main
struct CollectApp: App {
    @StateObject private var keyboardNav = KeyboardNavigationManager.shared
    @StateObject private var themeManager = ThemeManager.shared

    init() {
        // Force global overlay scrollbar style
        NSScrollView.configureGlobalScrollbarAppearance()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(keyboardNav)
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.effectiveColorScheme)
                .onReceive(themeManager.$effectiveColorScheme) { colorScheme in
                    updateWindowAppearance(colorScheme)
                    // Reapply scrollbar config on theme change
                    DispatchQueue.main.async {
                        ScrollbarConfiguration.configureAllScrollbars()
                    }
                }
                .onAppear {
                    // Configure all scrollbars after the window is ready
                    DispatchQueue.main.async {
                        ScrollbarConfiguration.configureAllScrollbars()
                    }
                    // Also apply with delays to catch lazy-loaded views
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        ScrollbarConfiguration.configureAllScrollbars()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        ScrollbarConfiguration.configureAllScrollbars()
                    }
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
    }

    private func updateWindowAppearance(_: ColorScheme) {
        DispatchQueue.main.async {
            WindowChrome.applyToAllWindows()
        }
    }
}
