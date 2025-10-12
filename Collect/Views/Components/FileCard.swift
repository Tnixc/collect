import SwiftUI

struct FileCard: View {
    let title: String
    let author: String
    let year: String
    let tags: [String]
    let backgroundColor: Color
    let noteCount: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Top badges
            HStack(spacing: 6) {
                ForEach(tags, id: \.self) { tag in
                    Text(tag)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.white.opacity(0.5))
                        .cornerRadius(4)
                }
                
                Text(year)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(AppTheme.textSecondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.white.opacity(0.5))
                    .cornerRadius(4)
                
                Spacer()
            }
            .padding(12)
            
            Spacer()
            
            // Title
            Text(title)
                .font(.system(size: 16, weight: .medium, design: .serif))
                .foregroundColor(AppTheme.textPrimary)
                .lineLimit(4)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 12)
                .fixedSize(horizontal: false, vertical: true)
            
            // Author
            Text(author)
                .font(.system(size: 12))
                .foregroundColor(AppTheme.textSecondary)
                .lineLimit(2)
                .padding(.horizontal, 12)
                .padding(.top, 6)
                .padding(.bottom, 12)
            
            // Bottom info
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "book")
                        .font(.system(size: 10))
                    Text("\(noteCount)")
                        .font(.system(size: 11))
                }
                .foregroundColor(AppTheme.textTertiary)
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textSecondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
        .shadow(color: Color.black.opacity(0.02), radius: 8, x: 0, y: 4)
    }
}