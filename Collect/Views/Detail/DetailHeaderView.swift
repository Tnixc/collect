import SwiftUI

struct DetailHeaderView: View {
    @EnvironmentObject var appState: AppState
    let onEditCategory: (Category) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 12) {
                if !appState.showReadingList,
                   !appState.showRecent,
                   let categoryName = appState.selectedCategory,
                   categoryName != "Uncategorized",
                   let category = appState.categories.first(where: { $0.name == categoryName })
                {
                    Circle()
                        .fill(AppTheme.categoryColor(for: category.color))
                        .frame(width: 18, height: 18)
                }

                Text(
                    appState.showRecent
                        ? "Recent"
                        : appState.showReadingList
                        ? "Reading list"
                        : (appState.selectedCategory
                            ?? "All Items")
                )
                .font(Font.system(size: 34, weight: .bold, design: .serif))
                .foregroundColor(AppTheme.textPrimary)

                if !appState.showReadingList,
                   !appState.showRecent,
                   let categoryName = appState.selectedCategory,
                   categoryName != "Uncategorized",
                   let category = appState.categories.first(
                       where: { $0.name == categoryName })
                {
                    UIButton(
                        action: {
                            onEditCategory(category)
                        },
                        style: .ghost,
                        icon: "pencil",
                        width: 24,
                        height: 24
                    )
                }

                Spacer()
            }
        }
        .padding(.horizontal, 32)
        .padding(.top, 64)
        .padding(.bottom, 12)
    }
}
