import SwiftUI

struct SidebarCategoryItem: View {
    let title: String
    let color: String
    let count: Int
    let isSelected: Bool
    let isHovered: Bool
    let isUncategorized: Bool
    let editAction: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(categoryColor)
                .frame(width: 8, height: 8)

            Text(title)
                .font(.system(size: 13))
                .foregroundColor(
                    isSelected ? AppTheme.textPrimary :
                    (isUncategorized ? AppTheme.textTertiary : AppTheme.textSecondary)
                )
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("\(count)")
                .font(.system(size: 11))
                .foregroundColor(AppTheme.textTertiary)
                .monospacedDigit()
                .frame(minWidth: 22, alignment: .trailing)
                .layoutPriority(1)

            if !isUncategorized && isHovered {
                Button(action: editAction) {
                    Image(systemName: "pencil")
                        .font(.system(size: 10))
                        .foregroundColor(AppTheme.textTertiary)
                        .opacity(0.8)
                }
                .buttonStyle(.plain)
                .frame(width: 16, height: 16)
                .onHover { isOver in
                    // Ensure button is interactive
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 5)
        .background(
            isSelected
                ? AppTheme.sidebarItemActive
                : (isUncategorized
                    ? Color.gray.opacity(0.08)
                    : (isHovered ? AppTheme.sidebarItemHover : Color.clear))
        )
        .cornerRadius(5)
        .padding(.horizontal, 8)
    }

    var categoryColor: Color {
        AppTheme.categoryColor(for: color)
    }
}
