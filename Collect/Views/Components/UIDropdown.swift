import AppKit
import SwiftUI

struct UIDropdown<T: Hashable>: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var selectedOption: T
    @Binding var isExpanded: Bool
    private let options: [T]
    private let optionToString: (T) -> String
    private let optionToIcon: ((T) -> String)?
    private let width: CGFloat
    private let height: CGFloat
    private let onSelect: ((T) -> Void)?
    private let onClick: (() -> Void)?

    @State private var isButtonEnabled = true
    @State private var isButtonHovered = false

    private let itemHeight = 28.0

    private var buttonHoverOverlayColor: Color {
        Color.white.opacity(
            isButtonHovered
                ? (themeManager.isDarkMode ? 0.22 : 0.12)
                : 0
        )
    }

    init(
        selectedOption: Binding<T>,
        isExpanded: Binding<Bool>,
        options: [T],
        optionToString: @escaping (T) -> String,
        optionToIcon: ((T) -> String)? = nil,
        width: CGFloat,
        height: CGFloat,
        onSelect: ((T) -> Void)? = nil,
        onClick: (() -> Void)? = nil
    ) {
        _selectedOption = selectedOption
        _isExpanded = isExpanded
        self.options = options
        self.optionToString = optionToString
        self.optionToIcon = optionToIcon
        self.width = width
        self.height = height
        self.onSelect = onSelect
        self.onClick = onClick
    }

    var body: some View {
        selectionButton
            .overlay(
                Group {
                    if isExpanded {
                        Color.black.opacity(0.001)
                            .frame(width: 10000, height: 10000)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation(.snappy(duration: 0.2)) {
                                    isExpanded = false
                                }
                            }
                    }
                }
            )
            .overlay(alignment: .top) {
                if isExpanded {
                    dropdownMenu
                        .offset(y: height + 4)
                        .transition(.blurReplace)
                }
            }
            .zIndex(isExpanded ? 999 : 0)
    }

    private var selectionButton: some View {
        Button(action: toggleExpanded) {
            HStack {
                Text(optionToString(selectedOption))
                    .fontWeight(.medium)
                    .foregroundColor(AppTheme.textPrimary)
                Spacer()
                if let icon = optionToIcon?(selectedOption) {
                    Image(systemName: icon)
                        .foregroundColor(AppTheme.textPrimary)
                        .font(.system(size: 14))
                }
                Image(systemName: "chevron.down")
                    .foregroundColor(AppTheme.textSecondary)
                    .fontWeight(.bold)
            }
            .padding(8)
            .frame(width: width, height: height)
            .background(Color.clear)
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
        .buttonStyle(.plain)
        .smartFocusRing()
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .fill(buttonHoverOverlayColor)
                .allowsHitTesting(false)
        )
        .onHover { hovering in
            isButtonHovered = hovering
        }
    }

    private var dropdownMenu: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(options, id: \.self) { option in
                dropdownMenuItem(for: option)
            }
        }
        .padding(4)
        .background(Color.clear)
        .glassBackground(
            material: .hudWindow,
            blendingMode: .withinWindow,
            emphasized: true,
            cornerRadius: 10,
            strokeColor: themeManager.glassPrimaryStrokeColor,
            strokeWidth: 1,
            overlayColor: themeManager.glassOverlayColor
        )
        .frame(width: width)
        .fixedSize(horizontal: false, vertical: true)
        .shadow(color: themeManager.glassShadowColor, radius: 20)
    }

    private func dropdownMenuItem(for option: T) -> some View {
        DropdownMenuItemView(
            option: option,
            isSelected: selectedOption == option,
            optionToString: optionToString,
            optionToIcon: optionToIcon,
            itemHeight: itemHeight,
            onSelect: { selectOption(option) }
        )
    }

    private func toggleExpanded() {
        if let onClick = onClick {
            onClick()
        }
        withAnimation(.snappy(duration: 0.2)) {
            isExpanded.toggle()
        }
    }

    private func selectOption(_ option: T) {
        selectedOption = option
        if let onSelect = onSelect {
            onSelect(option)
        }
        withAnimation(.snappy(duration: 0.2)) {
            isExpanded = false
        }
    }
}

struct DropdownMenuItemView<T: Hashable>: View {
    @EnvironmentObject var themeManager: ThemeManager
    let option: T
    let isSelected: Bool
    let optionToString: (T) -> String
    let optionToIcon: ((T) -> String)?
    let itemHeight: CGFloat
    let onSelect: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: onSelect) {
            HStack {
                Image(systemName: "checkmark")
                    .scaleEffect(1, anchor: .center)
                    .foregroundColor(isSelected ? AppTheme.textPrimary : .clear)
                    .fontWeight(.medium)
                    .frame(width: 15)
                    .padding(.leading, 8)
                Text(optionToString(option))
                    .foregroundColor(AppTheme.textPrimary)
                    .padding(.vertical)
                    .frame(height: itemHeight)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                if let icon = optionToIcon?(option) {
                    Image(systemName: icon)
                        .foregroundColor(AppTheme.textPrimary)
                        .font(.system(size: 14))
                        .frame(width: 20)
                        .padding(.trailing, 6)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                isHovered
                    ? AppTheme.backgroundTertiary.opacity(0.5) : Color.clear
            )
            .cornerRadius(8)
        }
        .buttonStyle(.borderless)
        .smartFocusRing()
        .frame(height: itemHeight)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}
