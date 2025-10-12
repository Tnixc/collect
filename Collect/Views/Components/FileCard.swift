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
                isHovering ? AppTheme.textPrimary.opacity(0.3) : AppTheme.dividerColor,
                lineWidth: isHovering ? 2.5 : 2
            )
        )
        .shadow(
            color: isHovering ? Color.black.opacity(0.15) : Color.clear,
            radius: isHovering ? 12 : 0,
            x: 0,
            y: isHovering ? 6 : 0
        )
        .scaleEffect(isHovering ? 1.03 : 1.0)
        .offset(y: isHovering ? -2 : 0)
        .onHover { hovering in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isHovering = hovering
            }
            if hovering {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
        .onTapGesture(count: 2) {
            onTap()
        }
        .contextMenu {
            Button(action: onTap) {
                Label("Open", systemImage: "doc")
            }
            Button(action: editAction) {
                Label("Edit Metadata", systemImage: "pencil")
            }
            Menu {
                ForEach(categories, id: \.name) { category in
                    Button(action: {
                        addToCategoryAction(category.name)
                    }) {
                        Label(category.name, systemImage: "tag")
                    }
                }
                Divider()
                Button(action: createCategoryAction) {
                    Label("Create New Category", systemImage: "plus")
                }
            } label: {
                Label("Add to Category", systemImage: "folder")
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
        .background(AppTheme.pillBackground)
        .clipShape(Capsule())
    }

    private func colorFromName(_ name: String) -> Color {
        AppTheme.categoryColor(for: name)
    }
}
