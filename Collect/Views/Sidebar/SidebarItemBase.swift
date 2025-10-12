import SwiftUI

/// Base component for sidebar items with consistent styling
struct SidebarItemBase<Content: View>: View {
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
            .background(backgroundColor)
            .cornerRadius(6)
            .padding(.horizontal, 8)
            .padding(.vertical, 1)
    }

    private var backgroundColor: Color {
        if isSelected {
            return AppTheme.backgroundTertiary
        } else if isHovered {
            return AppTheme.sidebarItemHover
        } else {
            return Color.clear
        }
    }
}

/// Icon view for sidebar items
struct SidebarIcon: View {
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
    }
}
