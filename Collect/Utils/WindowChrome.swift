import AppKit
import SwiftUI

/// Centralized helper for configuring Collect's window chrome.
/// Call `WindowChrome.apply(to:)` on every NSWindow you want to style like Arc.
enum WindowChrome {
    /// Applies the transparent / unified style to a specific window.
    static func apply(to window: NSWindow?) {
        guard let window else { return }

        window.isOpaque = false
        window.backgroundColor = .clear
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.hasShadow = true
        window.invalidateShadow()

        if #available(macOS 13, *) {
            window.toolbarStyle = .unified
            window.toolbar?.showsBaselineSeparator = false
        }
        if #available(macOS 11, *) {
            window.titlebarSeparatorStyle = .none
        }

        if let contentView = window.contentView {
            contentView.wantsLayer = true
            contentView.layer?.masksToBounds = false
            contentView.layer?.backgroundColor = NSColor.clear.cgColor
        }
    }

    /// Convenience to apply the styling to all visible windows (useful after theme changes).
    static func applyToAllWindows() {
        NSApp.windows.forEach { apply(to: $0) }
    }
}

/// Injects access to the hosting window from SwiftUI.
/// Add `.configureWindowChrome()` to a root view to automatically style the window.
struct WindowChromeAccessor: NSViewRepresentable {
    var configure: (NSWindow) -> Void

    func makeNSView(context _: Context) -> NSView {
        let view = NSView(frame: .zero)
        DispatchQueue.main.async {
            if let window = view.window {
                configure(window)
            }
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context _: Context) {
        DispatchQueue.main.async {
            if let window = nsView.window {
                configure(window)
            }
        }
    }
}

extension View {
    /// Automatically configures the host window using `WindowChrome.apply(to:)`.
    func configureWindowChrome(
        _ configure: @escaping (NSWindow) -> Void = WindowChrome.apply(to:)
    ) -> some View {
        background(WindowChromeAccessor(configure: configure))
    }

    /// Applies a macOS glass material background with rounded corners and an optional hairline stroke.
    func glassBackground(
        material: NSVisualEffectView.Material = .menu,
        blendingMode: NSVisualEffectView.BlendingMode = .behindWindow,
        emphasized: Bool = false,
        cornerRadius: CGFloat = 12,
        strokeColor: Color = Color.white.opacity(0.08),
        strokeWidth: CGFloat = 1,
        overlayColor: Color = .clear
    ) -> some View {
        modifier(
            GlassBackgroundModifier(
                material: material,
                blendingMode: blendingMode,
                emphasized: emphasized,
                cornerRadius: cornerRadius,
                strokeColor: strokeColor,
                strokeWidth: strokeWidth,
                overlayColor: overlayColor
            )
        )
    }
}

/// SwiftUI wrapper around `NSVisualEffectView` to create an Arc-like glass background.
struct GlassMaterialView: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode
    var emphasized: Bool

    func makeNSView(context _: Context) -> NSVisualEffectView {
        let effectView = HostingVisualEffectView()
        effectView.state = .active
        effectView.material = material
        effectView.blendingMode = blendingMode
        effectView.isEmphasized = emphasized
        effectView.wantsLayer = true
        if #available(macOS 11, *) {
            effectView.layer?.cornerCurve = .continuous
        }
        return effectView
    }

    func updateNSView(_ nsView: NSVisualEffectView, context _: Context) {
        nsView.state = .active
        nsView.material = material
        nsView.blendingMode = blendingMode
        nsView.isEmphasized = emphasized
    }
}

private struct GlassBackgroundModifier: ViewModifier {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode
    var emphasized: Bool
    var cornerRadius: CGFloat
    var strokeColor: Color
    var strokeWidth: CGFloat
    var overlayColor: Color

    func body(content: Content) -> some View {
        content
            .background(
                GlassMaterialView(
                    material: material,
                    blendingMode: blendingMode,
                    emphasized: emphasized
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(overlayColor)
                    .allowsHitTesting(false)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(strokeColor, lineWidth: strokeWidth)
                    .allowsHitTesting(false)
            )
    }
}

/// Custom `NSVisualEffectView` that keeps window + content fully transparent.
private final class HostingVisualEffectView: NSVisualEffectView {
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        window?.isOpaque = false
        window?.backgroundColor = .clear
    }
}
