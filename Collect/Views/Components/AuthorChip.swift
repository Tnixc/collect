import SwiftUI

struct AuthorChip: View {
    let name: String
    let count: Int
    
    var body: some View {
        HStack(spacing: 4) {
            Text(name)
                .font(.system(size: 12))
            Text("\(count)")
                .font(.system(size: 11))
                .foregroundColor(AppTheme.textTertiary)
        }
        .foregroundColor(AppTheme.textSecondary)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(AppTheme.badgeBrown)
        .cornerRadius(12)
    }
}