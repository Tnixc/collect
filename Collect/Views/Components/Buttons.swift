import SwiftUI

enum ButtonStyle {
    case primary
    case ghost
    case plain
    case destructive
}

struct UIButton: View {
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
        if style == .ghost || style == .plain {
            return isHovered ? AppTheme.backgroundTertiary.opacity(0.5) : .clear
        } else if style == .destructive && isHovered {
            return Color.red.opacity(0.2)
        } else if style == .primary {
            return isHovered
                ? AppTheme.accentPrimary.opacity(0.8) : AppTheme.accentPrimary
        } else if isHovered {
            return AppTheme.backgroundTertiary.opacity(1.5)
        } else {
            return AppTheme.backgroundTertiary
        }
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
                        .font(.system(size: 15)).frame(width: 14)
                        .foregroundColor(
                            style == .destructive && isHovered
                                ? Color.red
                                : (style == .primary
                                    ? .white : AppTheme.textPrimary)
                        )
                }
                if label != nil {
                    Text(label ?? "")
                        .foregroundColor(
                            style == .destructive && isHovered
                                ? Color.red
                                : (style == .primary
                                    ? .white : AppTheme.textPrimary)
                        )
                }
                if align == .leading {
                    Spacer()
                }
            }
            .padding(8)
            .frame(width: width, height: height ?? 32)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        style == .plain ? AppTheme.borderColor : Color.clear,
                        lineWidth: style == .plain ? 1 : 0
                    )
            )
            .contentShape(RoundedRectangle(cornerRadius: 8))
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(.plain)
        .focusable(false)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}
