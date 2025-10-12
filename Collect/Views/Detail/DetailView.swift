import SwiftUI

struct DetailView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            AppTheme.backgroundPrimary
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Header Section
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .top) {
                            Text("Computer Science")
                                .font(Typography.largeTitle)
                                .foregroundColor(AppTheme.textPrimary)

                            Button(action: {}) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                            .buttonStyle(.plain)
                            .padding(.top, 8)

                            Spacer()
                        }

                        Text(
                            "A description or notes about Computer Science"
                        )
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.textSecondary)
                        .padding(.bottom, 16)
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 24)

                    // Tab Bar
                    HStack(spacing: 0) {
                        TabButton(
                            title: "Items",
                            icon: "doc.text.fill",
                            isSelected: true
                        )
                        TabButton(
                            title: "Notebooks",
                            icon: "book.fill",
                            isSelected: false
                        )
                        TabButton(
                            title: "Canvases",
                            icon: "square.grid.2x2",
                            isSelected: false
                        )
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 16)

                    // Divider
                    Rectangle()
                        .fill(AppTheme.dividerColor)
                        .frame(height: 1)
                        .padding(.horizontal, 32)

                    // Authors Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Authors")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppTheme.textTertiary)
                            .padding(.top, 16)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                AuthorChip(name: "unknown", count: 3)
                                AuthorChip(name: "DR", count: 1)
                                AuthorChip(
                                    name: "Llama Team @ Meta",
                                    count: 1
                                )
                                AuthorChip(
                                    name: "Antti Laaksonen",
                                    count: 1
                                )
                                AuthorChip(
                                    name: "Daniel Nishball",
                                    count: 1
                                )
                                AuthorChip(name: "Dylan Patel", count: 1)
                                AuthorChip(name: "Douglas Thain", count: 1)
                            }
                        }
                    }
                    .padding(.horizontal, 32)

                    // New Items Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("New items (1)")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                            .padding(.top, 24)

                        FileCard(
                            title: "NOT.pdf",
                            author: "unknown",
                            year: "2025",
                            tags: ["NEW", "Computer Scienc"],
                            backgroundColor: AppTheme.cardYellow,
                            noteCount: 0
                        )
                        .frame(width: 180, height: 240)
                    }
                    .padding(.horizontal, 32)

                    // Items Grid Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Items (8)")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(AppTheme.textPrimary)

                            Button(action: {}) {
                                HStack(spacing: 4) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 11))
                                    Text("Add")
                                        .font(.system(size: 12))
                                }
                                .foregroundColor(AppTheme.textSecondary)
                            }
                            .buttonStyle(.plain)

                            Spacer()

                            Button(action: {}) {
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.up.arrow.down")
                                        .font(.system(size: 11))
                                    Text("Recently added")
                                        .font(.system(size: 12))
                                }
                                .foregroundColor(AppTheme.textSecondary)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.top, 24)

                        // Grid of Cards
                        LazyVGrid(
                            columns: [
                                GridItem(
                                    .adaptive(minimum: 180, maximum: 220),
                                    spacing: 16
                                )
                            ],
                            spacing: 16
                        ) {
                            FileCard(
                                title:
                                    "An Incremental Approach to Compiler Construction",
                                author: "unknown",
                                year: "2025",
                                tags: ["Computer Science"],
                                backgroundColor: AppTheme.cardTan,
                                noteCount: 0
                            )
                            .frame(minHeight: 240, maxHeight: 280)

                            FileCard(
                                title:
                                    "The Deep Learning Compiler: A Comprehensive Survey",
                                author: "unknown",
                                year: "2025",
                                tags: ["Computer Science"],
                                backgroundColor: AppTheme.cardYellow,
                                noteCount: 0
                            )
                            .frame(minHeight: 240, maxHeight: 280)

                            FileCard(
                                title:
                                    "Language Server Protocol and Language Servers.pdf",
                                author: "DR",
                                year: "2025",
                                tags: ["Computer Science"],
                                backgroundColor: AppTheme.cardBlue,
                                noteCount: 0
                            )
                            .frame(minHeight: 240, maxHeight: 280)

                            FileCard(
                                title: "LLM Scaling Laws",
                                author: "Dylan Patel, Daniel Nishball",
                                year: "2024",
                                tags: ["Computer Science"],
                                backgroundColor: AppTheme.cardGreen,
                                noteCount: 0
                            )
                            .frame(minHeight: 240, maxHeight: 280)

                            FileCard(
                                title:
                                    "Introduction to Compilers and Language Design",
                                author: "Douglas Thain",
                                year: "2023",
                                tags: ["Computer Science"],
                                backgroundColor: AppTheme.cardPeach,
                                noteCount: 0
                            )
                            .frame(minHeight: 240, maxHeight: 280)
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 32)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppTheme.dividerColor, lineWidth: 2)
        )
        .padding(8)
    }
}
