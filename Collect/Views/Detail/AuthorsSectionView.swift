import SwiftUI

struct AuthorsSectionView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Authors")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppTheme.textTertiary)
                .padding(.top, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(
                        appState.authorCounts.sorted(
                            by: {
                                $0.key < $1.key
                            }),
                        id: \.key
                    ) { author, count in
                        AuthorChip(
                            name: author,
                            count: count,
                            isSelected: appState.selectedAuthors.contains(author)
                        ) {
                            if appState.selectedAuthors.contains(author) {
                                appState.selectedAuthors.remove(author)
                            } else {
                                appState.selectedAuthors.insert(author)
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 32)
    }
}
