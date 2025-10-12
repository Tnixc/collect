import AppKit
import SwiftUI

struct FileCard: View {
    let fileID: UUID
    let title: String
    let author: String
    let year: String
    let tags: [String]
    let size: Int64
    let pages: Int?
    let lastOpened: Date?
    let backgroundColor: Color
    let categories: [Category]
    let onTap: () -> Void
    let editAction: () -> Void
    let addToCategoryAction: (String) -> Void
    let createCategoryAction: () -> Void
    @State private var isHovering = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header: Title and author
            HStack(spacing: 6) {
                ForEach(tags, id: \.self) { tag in
                    let color =
                        categories.first(where: { $0.name == tag })?.color
                            ?? "gray"
                    pill(tag, color: color)
                }
                if !year.isEmpty {
                    pill(year)
                }
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.top, 6)
            VStack(alignment: .leading, spacing: 4) {
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

            Spacer()

            // Bottom area: info pills and menu
            WrappingHStack(spacing: 6) {
                pill(formatFileSize(size))
                if let p = pages {
                    pill("\(p) pages")
                }
                pill(
                    lastOpened.map { formatLastOpened($0) } ?? "Never opened"
                )
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
        .contextMenu {
            Button("Open", action: onTap)
            Button("Edit Metadata", action: editAction)
            Menu("Add to Category") {
                ForEach(categories, id: \.name) { category in
                    Button(category.name) {
                        addToCategoryAction(category.name)
                    }
                }
                Button("Create New Category", action: createCategoryAction)
            }
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

    private func pill(_ text: String, color: String? = nil) -> some View {
        HStack(spacing: 4) {
            if let color {
                Circle()
                    .fill(colorFromName(color))
                    .frame(width: 6, height: 6)
            }
            Text(text)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .layoutPriority(1)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.white.opacity(0.55))
        .clipShape(Capsule())
    }

    private func colorFromName(_ name: String) -> Color {
        switch name {
        case "blue": return Color.blue
        case "green": return Color.green
        case "orange": return Color.orange
        case "pink": return Color.pink
        case "purple": return Color.purple
        case "yellow": return Color.yellow
        case "gray": return Color.gray
        case "tan": return Color(red: 0.93, green: 0.88, blue: 0.82)
        default: return Color.blue
        }
    }
}
