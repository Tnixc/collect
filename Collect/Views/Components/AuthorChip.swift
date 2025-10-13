import SwiftUI

struct AuthorChip: View {
    @EnvironmentObject var themeManager: ThemeManager
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
                .foregroundColor(isSelected ? AppTheme.textPrimary : AppTheme.textTertiary)
        }
        .foregroundColor(
            isSelected ? AppTheme.textPrimary : AppTheme.textTertiary
        )
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            isSelected ? AppTheme.pillBackground : AppTheme.backgroundSecondary
        )
        .cornerRadius(12)
        .id(themeManager.effectiveColorScheme)
        .onTapGesture {
            action()
        }
    }
}
