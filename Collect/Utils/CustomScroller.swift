import AppKit
import SwiftUI

/// Custom NSScroller subclass with transparent background
class TransparentScroller: NSScroller {
    override class var isCompatibleWithOverlayScrollers: Bool {
        return true
    }

    override func draw(_: NSRect) {
        // Draw the scroller knob only, no background
        drawKnob()
    }

    override func drawKnob() {
        let knobRect = rect(for: .knob)

        // Only draw if we have a valid knob rect
        guard !knobRect.isEmpty else { return }

        // Draw knob with slight transparency
        let knobPath = NSBezierPath(roundedRect: knobRect, xRadius: 4, yRadius: 4)

        // Use theme-aware colors
        let knobColor: NSColor
        let isDarkMode = NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        if isDarkMode {
            knobColor = NSColor.white.withAlphaComponent(0.3)
        } else {
            knobColor = NSColor.black.withAlphaComponent(0.2)
        }

        knobColor.setFill()
        knobPath.fill()
    }
}

/// Extension to apply transparent scrollers to any NSScrollView
extension NSScrollView {
    func applyTransparentScrollers() {
        // Use overlay style to exclude scrollbars from layout
        scrollerStyle = .overlay

        // Make background transparent
        backgroundColor = .clear
        drawsBackground = false

        // Auto-hide scrollers when not in use
        autohidesScrollers = true

        // Set scroller knob style to default for overlay
        scrollerKnobStyle = .default

        // Force the scroller style
        horizontalScroller?.alphaValue = 0.0

        // Replace vertical scroller with TransparentScroller if needed
        if !(verticalScroller is TransparentScroller) {
            let newScroller = TransparentScroller()
            verticalScroller = newScroller
        }
        verticalScroller?.alphaValue = 1.0

        // Set contentView to not draw background
        contentView.drawsBackground = false
        contentView.layer?.backgroundColor = .clear
    }

    /// Static method to globally configure scrollbar appearance
    static func configureGlobalScrollbarAppearance() {
        // Force overlay scroller style globally via UserDefaults
        UserDefaults.standard.set(1, forKey: "NSPreferredScrollerStyle")
    }
}

/// View modifier to apply transparent scrollers to SwiftUI ScrollViews
struct TransparentScrollerModifier: ViewModifier {
    @State private var hasApplied = false

    func body(content: Content) -> some View {
        content
            .onAppear {
                applyWithRetries()
            }
            .background(
                // Also try applying when the view updates
                GeometryReader { _ in
                    Color.clear
                        .onAppear {
                            if !hasApplied {
                                applyWithRetries()
                            }
                        }
                }
            )
    }

    private func applyWithRetries() {
        // Try immediately
        applyToAllWindows()

        // Retry after a short delay to catch lazy-loaded scroll views
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.applyToAllWindows()
            self.hasApplied = true
        }

        // One more retry for good measure
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.applyToAllWindows()
        }
    }

    private func applyToAllWindows() {
        // Apply to all windows, not just key window
        guard let app = NSApplication.shared as NSApplication? else { return }
        for window in app.windows {
            applyToScrollViews(in: window.contentView)
        }
    }

    private func applyToScrollViews(in view: NSView?) {
        guard let view = view else { return }

        if let scrollView = view as? NSScrollView {
            print("🔍 Found NSScrollView: \(scrollView)")
            print("   - Current style: \(scrollView.scrollerStyle.rawValue)")
            print("   - Has vertical scroller: \(scrollView.hasVerticalScroller)")
            print("   - Has horizontal scroller: \(scrollView.hasHorizontalScroller)")
            scrollView.applyTransparentScrollers()
            print("   ✅ Applied transparent scrollers")
        }

        // Recursively check all subviews
        for subview in view.subviews {
            applyToScrollViews(in: subview)
        }
    }
}

extension View {
    /// Applies transparent scroller styling to scrollbars
    func transparentScrollbars() -> some View {
        modifier(TransparentScrollerModifier())
    }
}

/// Global utility to configure all scrollbars in the application
enum ScrollbarConfiguration {
    /// Apply transparent scrollbars to all NSScrollViews in all windows
    static func configureAllScrollbars() {
        print("🎨 Configuring all scrollbars...")

        // Set global preference first
        NSScrollView.configureGlobalScrollbarAppearance()

        // Safely check if NSApp is available
        guard let app = NSApplication.shared as NSApplication? else {
            print("⚠️ NSApp not available yet, retrying...")
            // If NSApp isn't ready yet, try again later
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                configureAllScrollbars()
            }
            return
        }

        print("🪟 Found \(app.windows.count) window(s)")

        // Apply to all existing windows
        for window in app.windows {
            print("   Scanning window: \(window)")
            applyToScrollViews(in: window.contentView)
        }

        // Set up swizzling to automatically configure new NSScrollViews
        swizzleNSScrollViewInit()

        // Keep monitoring for new scroll views
        startMonitoring()
    }

    private static var isMonitoring = false

    private static func startMonitoring() {
        guard !isMonitoring else { return }
        isMonitoring = true

        // Use a timer to periodically check for new scroll views
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            guard let app = NSApplication.shared as NSApplication? else { return }
            for window in app.windows {
                applyToScrollViews(in: window.contentView)
            }
        }
    }

    private static func applyToScrollViews(in view: NSView?) {
        guard let view = view else { return }

        if let scrollView = view as? NSScrollView {
            print("🔍 [Global] Found NSScrollView: \(scrollView)")
            scrollView.applyTransparentScrollers()
        }

        for subview in view.subviews {
            applyToScrollViews(in: subview)
        }
    }

    private static var hasSwizzled = false

    private static func swizzleNSScrollViewInit() {
        guard !hasSwizzled else { return }
        hasSwizzled = true

        // Swizzle the init method to automatically apply transparent scrollers
        let originalSelector = #selector(NSScrollView.init(frame:))
        let swizzledSelector = #selector(NSScrollView.transparentInit(frame:))

        guard let originalMethod = class_getInstanceMethod(NSScrollView.self, originalSelector),
              let swizzledMethod = class_getInstanceMethod(NSScrollView.self, swizzledSelector)
        else {
            return
        }

        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}

extension NSScrollView {
    @objc dynamic func transparentInit(frame: NSRect) -> NSScrollView {
        // Call original init (now swizzled)
        let scrollView = transparentInit(frame: frame)

        // Apply transparent scroller settings immediately
        scrollView.scrollerStyle = .overlay
        scrollView.backgroundColor = .clear
        scrollView.drawsBackground = false
        scrollView.autohidesScrollers = true

        // Also apply after a delay to catch SwiftUI overrides
        DispatchQueue.main.async {
            scrollView.applyTransparentScrollers()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            scrollView.applyTransparentScrollers()
        }

        return scrollView
    }
}
