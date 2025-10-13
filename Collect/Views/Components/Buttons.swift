import SwiftUI

enum ButtonStyle {
    case primary
    case ghost
    case plain
    case destructive
}

struct UIButton: View {
    @EnvironmentObject var themeManager: ThemeManager
    let action: () -> Void
    let label: String?
    let icon: String?
    let width: CGFloat?
    let height: CGFloat?
    let align: Alignment?
    let style: ButtonStyle

    @State private var isHovered = false
    @State private var isPressed = false

    init(
        action: @escaping () -> Void,
        style: ButtonStyle = .primary,
        label: String? = nil,
        icon: String? = nil,
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        align: Alignment? = nil
    ) {
        self.action = action
        self.style = style
        self.label = label
        self.icon = icon
        self.width = width
        self.height = height
        self.align = align
    }

    private var backgroundColor: Color {
        switch style {
        case .ghost, .plain:
            if isHovered {
                return AppTheme.backgroundTertiary.opacity(0.5)
            }
            return .clear

        case .destructive:
            if isHovered {
                return AppTheme.destructive.opacity(0.2)
            }
            return AppTheme.backgroundTertiary

        case .primary:
            if isHovered {
                return AppTheme.accentPrimary.opacity(0.8)
            }
            return AppTheme.accentPrimary
        }
    }

    private var foregroundColor: Color {
        if style == .destructive && isHovered {
            return AppTheme.destructive
        }

        if style == .primary {
            return AppTheme.buttonTextLight
        }

        return AppTheme.textPrimary
    }

    private var borderWidth: CGFloat {
        switch style {
        case .plain, .destructive:
            return 1
        default:
            return 0
        }
    }

    private var borderColor: Color {
        switch style {
        case .plain:
            return AppTheme.dividerColor
        case .destructive:
            if isHovered {
                return AppTheme.categoryRed
            }
            return AppTheme.dividerColor
        default:
            return .clear
        }
    }

    private var buttonHeight: CGFloat {
        if let height = height {
            return height
        }
        return 32
    }

    private var scaleEffect: CGFloat {
        if isPressed {
            return 0.95
        }
        return 1.0
    }

    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
                action()
            }
        }) {
            HStack {
                if align == .trailing {
                    Spacer()
                }
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16)).frame(width: 16)
                        .foregroundColor(foregroundColor)
                }
                if let label = label {
                    Text(label)
                        .foregroundColor(foregroundColor)
                }
                if align == .leading {
                    Spacer()
                }
            }
            .padding(8)
            .padding(.horizontal, 12)
            .frame(width: width, height: buttonHeight)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .contentShape(RoundedRectangle(cornerRadius: 8))
            .scaleEffect(scaleEffect)
        }
        .buttonStyle(.plain)
        .smartFocusRing()
        .id(themeManager.effectiveColorScheme)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}
