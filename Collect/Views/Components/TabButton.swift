import SwiftUI

struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                Text(title)
                    .font(.system(size: 13))
            }
            .foregroundColor(isSelected ? AppTheme.textPrimary : AppTheme.textSecondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? AppTheme.badgeBeige : Color.clear)
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }
}