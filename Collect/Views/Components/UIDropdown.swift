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
        ZStack(alignment: .top) {
            if isExpanded {
                selectionButton
                dropdownMenu
            } else {
                selectionButton
            }
        }
        .zIndex(isExpanded ? 999 : -10)
        .id(themeManager.effectiveColorScheme)
        .onAppear {
            setupMouseEventMonitor()
        }
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
            .background(
                isButtonHovered
                    ? AppTheme.backgroundTertiary.opacity(1.5)
                    : AppTheme.backgroundTertiary
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .smartFocusRing()
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    isButtonHovered
                        ? AppTheme.dividerColor.opacity(1.5)
                        : AppTheme.dividerColor,
                    lineWidth: 1
                )
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isButtonHovered = hovering
            }
        }
    }

    private var dropdownMenu: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(options, id: \.self) { option in
                dropdownMenuItem(for: option)
            }
        }
        .padding(4)
        .background(AppTheme.backgroundPrimary)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(AppTheme.dividerColor.opacity(0.2), lineWidth: 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .frame(width: width)
        .position(
            x: width / 2,
            y: itemHeight / 2 * CGFloat(options.count) + itemHeight * 2 - 6
        )
        .transition(.blurReplace)
        .zIndex(1000)
        .frame(maxHeight: height).fixedSize(horizontal: true, vertical: true)
        .shadow(color: AppTheme.dropdownShadow, radius: 20)
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
        guard isButtonEnabled else { return }

        withAnimation(.snappy(duration: 0.15)) {
            isExpanded.toggle()
        }

        isButtonEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isButtonEnabled = true
        }
    }

    private func selectOption(_ option: T) {
        selectedOption = option
        if let onSelect = onSelect {
            onSelect(option)
        }
        toggleExpanded()
    }

    private func setupMouseEventMonitor() {
        NSEvent.addLocalMonitorForEvents(matching: [
            .leftMouseUp, .rightMouseUp,
        ]) {
            event in
            if isExpanded {
                DispatchQueue.main.async {
                    toggleExpanded()
                }
            }
            return event
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
        .id(themeManager.effectiveColorScheme)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.1)) {
                isHovered = hovering
            }
        }
    }
}
