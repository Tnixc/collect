import AppKit
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
    @State private var isHovering = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header: Title and author
            VStack(alignment: .leading, spacing: 4) {

                Menu {
                    Button("Open", action: onTap)
                    Button("Edit Metadata", action: editAction)
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textSecondary)
                }
                .colorMultiply(AppTheme.accentPrimary)
                .menuStyle(.borderlessButton).foregroundStyle(
                    AppTheme.textSecondary
                )

                Text(title)
                    .font(.system(size: 18, weight: .semibold, design: .serif))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                Text(author)
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textSecondary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)

            // Top pills: tags and year
            HStack(spacing: 6) {
                ForEach(tags, id: \.self) { tag in
                    pill(tag)
                }
                if !year.isEmpty {
                    pill(year)
                }
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.top, 6)

            Spacer()

            // Bottom area: info pills and menu
            HStack(spacing: 6) {
                pill(formatFileSize(size))
                if let p = pages {
                    pill("\(p) pages")
                }
                pill(lastOpened.map { formatLastOpened($0) } ?? "Never opened")
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundColor)
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: 8,
                bottomLeadingRadius: 8,
                bottomTrailingRadius: 24,
                topTrailingRadius: 24
            )
        )
        .overlay(
            UnevenRoundedRectangle(
                topLeadingRadius: 8,
                bottomLeadingRadius: 8,
                bottomTrailingRadius: 24,
                topTrailingRadius: 24
            )
            .stroke(
                AppTheme.dividerColor,
                lineWidth: 2
            )
        )
        .scaleEffect(isHovering ? 1.02 : 1.0)
        .onHover { hovering in
            isHovering = hovering
            if hovering {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
        .animation(.easeOut(duration: 0.12), value: isHovering)
        .onTapGesture(count: 2) {
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
        return
            "Opened \(formatter.localizedString(for: date, relativeTo: Date()))"
    }

    private func pill(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(AppTheme.textSecondary)
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
            .layoutPriority(1)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(AppTheme.backgroundTertiary)
            .clipShape(Capsule())
    }
}
