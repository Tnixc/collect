import SwiftUI
import AppKit

/// Manages keyboard navigation state to show focus rings only when Tab is pressed
class KeyboardNavigationManager: ObservableObject {
    @Published var isKeyboardNavigating = false
    private var monitor: Any?
    
    static let shared = KeyboardNavigationManager()
    
    private init() {
        setupEventMonitor()
    }
    
    private func setupEventMonitor() {
        // Monitor for Tab key presses (enable keyboard navigation)
        monitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .flagsChanged]) { [weak self] event in
            // Tab key pressed - enable keyboard navigation
            if event.keyCode == 48 { // Tab key
                self?.isKeyboardNavigating = true
            }
            return event
        }
        
        // Monitor for mouse events (disable keyboard navigation)
        NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            self?.isKeyboardNavigating = false
            return event
        }
    }
    
    deinit {
        if let monitor = monitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}

/// View modifier to disable focus ring unless keyboard navigating
struct FocusRingModifier: ViewModifier {
    @ObservedObject var keyboardNav = KeyboardNavigationManager.shared
    
    func body(content: Content) -> some View {
        content
            .focusEffectDisabled(!keyboardNav.isKeyboardNavigating)
    }
}

extension View {
    /// Apply this modifier to disable focus rings unless Tab key is pressed
    func smartFocusRing() -> some View {
        self.modifier(FocusRingModifier())
    }
}