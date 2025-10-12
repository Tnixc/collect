import SwiftUI

struct SidebarItem: View {
    let title: String
    let icon: String?
    let count: Int?
    let isHovered: Bool
    let isSelected: Bool

    var body: some View {
        SidebarItemBase(isSelected: isSelected, isHovered: isHovered) {
            HStack(spacing: 8) {
                if let icon = icon {
                    SidebarIcon(
                        type: .systemIcon(icon),
                        isSelected: isSelected
                    )
                }
                
                Text(title)
                    .font(.system(size: 13))
                    .foregroundColor(isSelected ? AppTheme.textPrimary : AppTheme.textSecondary)
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
        }
    }
}