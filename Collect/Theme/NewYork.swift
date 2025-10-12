import AppKit
import CoreText
import SwiftUI

/// Helpers for using Apple's "New York" serif font across SwiftUI and AppKit.
/// - Notes:
///   - The "New York" family ships with modern macOS/iOS SDKs with multiple optical sizes:
///     Small, Medium, Large. Availability can vary by OS version and install.
///   - These helpers attempt to load a New York family font first. If unavailable,
///     they fall back to a standard serif (Times New Roman), then to the system serif design.
///   - You can use the SwiftUI or AppKit variants depending on your UI layer.
public enum NewYork {
    public enum OpticalSize: CaseIterable {
        case small
        case medium
        case large

        var familyCandidates: [String] {
            // Try specific optical-size families first, then generic family name.
            switch self {
            case .small:
                return ["New York Small", "New York"]
            case .medium:
                return ["New York Medium", "New York"]
            case .large:
                return ["New York Large", "New York"]
            }
        }
    }

    // MARK: - SwiftUI

    /// Returns a SwiftUI Font for New York or falls back to a serif system equivalent.
    public static func font(size: CGFloat,
                            weight: Font.Weight = .regular,
                            opticalSize: OpticalSize = .medium) -> Font
    {
        if let ns = nsFont(size: size,
                           weight: nsFontWeight(from: weight),
                           opticalSize: opticalSize)
        {
            return Font(ns)
        }

        // Fallbacks: Times New Roman -> serif system
        if let times = NSFont(name: "Times New Roman", size: size) {
            let adjusted = NSFontManager.shared.convert(times, toWeight: nsFontWeight(from: weight))
            return Font(adjusted)
        }

        // System serif fallback
        return Font.system(size: size, weight: weight, design: .serif)
    }

    // MARK: - AppKit

    /// Returns an NSFont for New York or falls back to a serif system equivalent.
    public static func nsFont(size: CGFloat,
                              weight: NSFont.Weight = .regular,
                              opticalSize: OpticalSize = .medium) -> NSFont?
    {
        // Attempt via CoreText descriptor with weight trait for the New York family candidates.
        for family in opticalSize.familyCandidates {
            if let f = createCTFont(familyName: family, size: size, weight: weight) {
                return f
            }
        }

        // Fallback: Times New Roman with adjusted weight
        if let times = NSFont(name: "Times New Roman", size: size) {
            return NSFontManager.shared.convert(times, toWeight: weight)
        }

        // Final fallback: system serif-ish (system font; AppKit doesn't expose serif design like SwiftUI)
        // Use system font then attempt to adjust weight.
        let system = NSFont.systemFont(ofSize: size, weight: weight)
        return system
    }

    // MARK: - Convenience Presets

    public enum Preset {
        // Titles (serif display)
        public static func largeTitle() -> Font {
            font(size: 34, weight: .bold, opticalSize: .large)
        }

        public static func title() -> Font {
            font(size: 24, weight: .semibold, opticalSize: .medium)
        }

        public static func title2() -> Font {
            font(size: 20, weight: .medium, opticalSize: .medium)
        }

        // Body
        public static func body() -> Font {
            font(size: 15, weight: .regular, opticalSize: .medium)
        }

        public static func caption() -> Font {
            font(size: 13, weight: .regular, opticalSize: .small)
        }

        public static func small() -> Font {
            font(size: 11, weight: .regular, opticalSize: .small)
        }
    }

    // MARK: - Internal helpers

    /// Attempts to create an NSFont using CoreText by family name and weight.
    private static func createCTFont(familyName: String,
                                     size: CGFloat,
                                     weight: NSFont.Weight) -> NSFont?
    {
        // Traits dictionary with desired weight
        let traits: [CFString: Any] = [
            kCTFontWeightTrait: CGFloat(weight.rawValue),
        ]
        let attributes: [CFString: Any] = [
            kCTFontFamilyNameAttribute: familyName as CFString,
            kCTFontTraitsAttribute: traits,
        ]

        let descriptor = CTFontDescriptorCreateWithAttributes(attributes as CFDictionary)
        let ctFont = CTFontCreateWithFontDescriptor(descriptor, size, nil)

        // Validate that we actually got a New York font (avoid silent fallback to other families)
        let family = CTFontCopyFamilyName(ctFont) as String
        if family.contains("New York") {
            // CTFont and NSFont are toll-free bridged on macOS.
            return ctFont as NSFont
        }

        // Some OS versions may report generic family; attempt a second pass by explicitly using the PostScript name if present.
        // If we can't establish New York, return nil so callers can try fallbacks.
        return nil
    }

    /// Maps SwiftUI Font.Weight to NSFont.Weight
    private static func nsFontWeight(from weight: Font.Weight) -> NSFont.Weight {
        switch weight {
        case .ultraLight: return .ultraLight
        case .thin: return .thin
        case .light: return .light
        case .regular: return .regular
        case .medium: return .medium
        case .semibold: return .semibold
        case .bold: return .bold
        case .heavy: return .heavy
        case .black: return .black
        default: return .regular
        }
    }
}

// MARK: - NSFontManager weight conversion helper

private extension NSFontManager {
    /// Best-effort weight conversion using NSFontManager's built-in stepping.
    /// This avoids complex trait math that can cause ambiguous compiler issues.
    func convert(_ font: NSFont, toWeight weight: NSFont.Weight) -> NSFont {
        // Heuristic: bump once toward bold for >= .semibold, once toward light for <= .light.
        if weight >= .semibold {
            return convertWeight(true, of: font)
        } else if weight <= .light {
            return convertWeight(false, of: font)
        } else {
            return font
        }
    }
}
