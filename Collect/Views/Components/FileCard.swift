import SwiftUI

struct FileCard: View {
    let title: String
    let author: String
    let year: String
    let tags: [String]
    let size: Int64
    let pages: Int?
    let lastOpened: Date?
    let backgroundColor: Color
    let onTap: () -> Void
    let editAction: () -> Void
    
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

            // File info
            let formattedSize = formatFileSize(size)
            let pagesText = pages.map { "\($0) pages" } ?? ""
            let lastOpenedText = lastOpened.map { formatLastOpened($0) } ?? "Never opened"
            let infoText = [formattedSize, pagesText, lastOpenedText].filter { !$0.isEmpty }.joined(separator: " • ")
            Text(infoText)
                .font(.system(size: 11))
                .foregroundColor(AppTheme.textTertiary)
                .padding(.horizontal, 12)
                .padding(.bottom, 6)

            // Bottom info
            HStack {
                Spacer()

                Menu {
                    Button("Open", action: onTap)
                    Button("Edit Metadata", action: editAction)
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textSecondary)
                }
                .menuStyle(.borderlessButton)
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
        .shadow(color: Color.black.opacity(0.02), radius: 8, x: 0, y: 4)
        .onTapGesture {
            onTap()
        }
    }

    private func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useKB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }

    private func formatLastOpened(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return "Opened \(formatter.localizedString(for: date, relativeTo: Date()))"
    }
}