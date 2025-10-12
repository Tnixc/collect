import SwiftUI

struct AuthorChip: View {
    let name: String
    let count: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text(name)
                .font(.system(size: 12))
            Text("\(count)")
                .font(.system(size: 11))
                .foregroundColor(AppTheme.textTertiary)
        }
        .foregroundColor(isSelected ? AppTheme.textPrimary : AppTheme.textSecondary)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(isSelected ? AppTheme.badgeBeige : AppTheme.badgeBrown)
        .cornerRadius(12)
        .onTapGesture {
            action()
        }
    }
}
