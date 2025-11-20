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

    private var buttonHoverOverlayColor: Color {
        switch style {
        case .primary:
            return Color.white.opacity(isHovered ? 0.2 : 0)
        case .destructive:
            return AppTheme.destructive.opacity(isHovered ? 0.1 : 0)
        default:
            return Color.white.opacity(
                isHovered
                    ? (themeManager.isDarkMode ? 0.22 : 0.12)
                    : 0
            )
        }
    }

    private var tintColor: Color {
        switch style {
        case .primary:
            return AppTheme.accentPrimary
        case .destructive:
            return AppTheme.destructive.opacity(0.1)
        default:
            return .clear
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
            .background(tintColor)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .glassBackground(
                material: .hudWindow,
                blendingMode: .withinWindow,
                emphasized: false,
                cornerRadius: 8,
                strokeColor: style == .primary ? .clear : themeManager.glassSecondaryStrokeColor,
                strokeWidth: 1,
                overlayColor: themeManager.glassOverlayColor
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .fill(buttonHoverOverlayColor)
                    .allowsHitTesting(false)
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
