import SwiftUI

struct SidebarItem: View {
    let title: String
    let icon: String?
    let count: Int?
    let isHovered: Bool
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textSecondary)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let count = count {
                Text("\(count)")
                    .font(.system(size: 11))
                    .foregroundColor(AppTheme.textTertiary)
                    .monospacedDigit()
                    .frame(minWidth: 22, alignment: .trailing)
                    .layoutPriority(1)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 5)
        .background(isSelected ? AppTheme.sidebarItemActive : (isHovered ? AppTheme.sidebarItemHover : Color.clear))
        .cornerRadius(5)
        .padding(.horizontal, 8)
    }
}
