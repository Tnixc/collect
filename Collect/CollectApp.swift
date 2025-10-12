import SwiftUI

@main
struct CollectApp: App {
    @StateObject private var keyboardNav = KeyboardNavigationManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(keyboardNav)
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
    }
}
