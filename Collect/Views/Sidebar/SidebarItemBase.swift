import SwiftUI

/// Base component for sidebar items with consistent styling
struct SidebarItemBase<Content: View>: View {
    @EnvironmentObject var themeManager: ThemeManager
    let isSelected: Bool
    let isHovered: Bool
    let content: () -> Content

    init(
        isSelected: Bool,
        isHovered: Bool,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.isSelected = isSelected
        self.isHovered = isHovered
        self.content = content
    }

    var body: some View {
        content()
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                ZStack {
                    if isSelected {
                        AppTheme.accentPrimary.opacity(0.1)

                        Color.clear
                            .glassBackground(
                                material: .hudWindow,
                                blendingMode: .withinWindow,
                                emphasized: false,
                                cornerRadius: 8,
                                strokeColor: themeManager.glassSecondaryStrokeColor,
                                strokeWidth: 1,
                                overlayColor: themeManager.glassOverlayColor
                            )
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .fill(hoverOverlayColor)
                    .allowsHitTesting(false)
            )
            .padding(.horizontal, 8)
            .padding(.vertical, 1)
            .id(themeManager.effectiveColorScheme)
    }

    private var hoverOverlayColor: Color {
        Color.white.opacity(
            isHovered
                ? (themeManager.isDarkMode ? 0.22 : 0.12)
                : 0
        )
    }
}

/// Icon view for sidebar items
struct SidebarIcon: View {
    @EnvironmentObject var themeManager: ThemeManager

    enum IconType {
        case systemIcon(String)
        case colorDot(Color)
    }

    let type: IconType
    let isSelected: Bool

    var body: some View {
        Group {
            switch type {
            case let .systemIcon(name):
                Image(systemName: name)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(
                        isSelected
                            ? AppTheme.textPrimary : AppTheme.textSecondary
                    )
            case let .colorDot(color):
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
            }
        }
        .frame(width: 16, alignment: .center)
        .id(themeManager.effectiveColorScheme)
    }
}
