import SwiftUI

struct SidebarCategoryItem: View {
    let title: String
    let color: String
    let count: Int
    let isSelected: Bool
    let isHovered: Bool
    let isUncategorized: Bool

    var body: some View {
        SidebarItemBase(
            isSelected: isSelected,
            isHovered: isHovered,
        ) {
            HStack(spacing: 8) {
                if isUncategorized {
                    SidebarIcon(
                        type: .systemIcon("tray"),
                        isSelected: isSelected
                    )
                } else {
                    SidebarIcon(
                        type: .colorDot(categoryColor),
                        isSelected: isSelected
                    )
                }

                Text(title)
                    .font(.system(size: 13))
                    .foregroundColor(
                        isSelected
                            ? AppTheme.textPrimary : AppTheme.textSecondary
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
            }
        }
    }

    var categoryColor: Color {
        AppTheme.categoryColor(for: color)
    }
}
