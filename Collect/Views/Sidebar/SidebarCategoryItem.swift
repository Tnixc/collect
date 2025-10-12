import SwiftUI

struct SidebarCategoryItem: View {
    let title: String
    let color: String
    let count: Int
    let isSelected: Bool
    let isHovered: Bool

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(categoryColor)
                .frame(width: 8, height: 8)

            Text(title)
                .font(.system(size: 13))
                .foregroundColor(
                    isSelected ? AppTheme.textPrimary : AppTheme.textSecondary
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
        .padding(.horizontal, 12)
        .padding(.vertical, 5)
        .background(
            isSelected
                ? AppTheme.sidebarItemActive
                : (isHovered ? AppTheme.sidebarItemHover : Color.clear)
        )
        .cornerRadius(5)
        .padding(.horizontal, 8)
    }

    var categoryColor: Color {
        switch color {
        case "blue": return Color(red: 0.4, green: 0.6, blue: 0.9)
        case "orange": return Color(red: 0.95, green: 0.65, blue: 0.4)
        case "pink": return Color(red: 0.95, green: 0.55, blue: 0.65)
        case "gray": return Color(red: 0.7, green: 0.7, blue: 0.7)
        default: return Color.gray
        }
    }
}
