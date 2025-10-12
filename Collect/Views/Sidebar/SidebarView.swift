import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var appState: AppState
    @Binding var showingSettings: Bool
    @Binding var showingCreateCategory: Bool
    @State private var hoveredItem: String? = nil
    @State private var editingCategory: Category? = nil

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 80)
            // Fixed Items
            VStack(alignment: .leading, spacing: 1) {
                SidebarItem(
                    title: "Recent",
                    icon: nil,
                    count: nil,
                    isHovered: hoveredItem == "Recent",
                    isSelected: false
                )
                .onHover { hoveredItem = $0 ? "Recent" : nil }

                SidebarItem(
                    title: "Reading list",
                    icon: nil,
                    count: nil,
                    isHovered: hoveredItem == "Reading list",
                    isSelected: false
                )
                .onHover { hoveredItem = $0 ? "Reading list" : nil }

                SidebarItem(
                    title: "All Items",
                    icon: nil,
                    count: nil,
                    isHovered: hoveredItem == "All Items",
                    isSelected: appState.selectedCategory == nil
                )
                .onHover { hoveredItem = $0 ? "All Items" : nil }
                .onTapGesture {
                    appState.selectedCategory = nil
                    appState.selectedAuthor = nil
                }
            }
            .padding(.horizontal, 8)
            .padding(.top, 12)

            // Divider
            Rectangle()
                .fill(AppTheme.dividerColor)
                .frame(height: 1)
                .padding(.vertical, 10)
                .padding(.horizontal, 16)

            // My Library Section
            VStack(alignment: .leading, spacing: 1) {
                Text("My library")
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppTheme.textTertiary)
                    .textCase(.uppercase)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)

                // Uncategorized category
                if let uncategorized = appState.categories.first(where: { $0.name == "Uncategorized" }) {
                    SidebarCategoryItem(
                        title: uncategorized.name,
                        color: uncategorized.color,
                        count: uncategorized.itemCount,
                        isSelected: appState.selectedCategory == uncategorized.name,
                        isHovered: hoveredItem == uncategorized.name,
                        isUncategorized: true,
                        editAction: {}
                    )
                    .onTapGesture {
                        appState.selectedCategory = appState.selectedCategory == uncategorized.name ? nil : uncategorized.name
                    }
                    .onHover { hoveredItem = $0 ? uncategorized.name : nil }
                }

                // Divider between uncategorized and other categories
                if appState.categories.contains(where: { $0.name == "Uncategorized" }) && appState.categories.count > 1 {
                    Rectangle()
                        .fill(AppTheme.dividerColor)
                        .frame(height: 1)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 16)
                }

                // Other categories
                ForEach(appState.categories.filter { $0.name != "Uncategorized" }) { category in
                    SidebarCategoryItem(
                        title: category.name,
                        color: category.color,
                        count: category.itemCount,
                        isSelected: appState.selectedCategory == category.name,
                        isHovered: hoveredItem == category.name,
                        isUncategorized: false,
                        editAction: { editingCategory = category }
                    )
                    .onTapGesture {
                        appState.selectedCategory = appState.selectedCategory == category.name ? nil : category.name
                    }
                    .onHover { hoveredItem = $0 ? category.name : nil }
                }

                UIButton(action: { showingCreateCategory = true }, style: .ghost, label: "New category +", align: .leading)
                    .padding(.horizontal, 8)
                    .onHover { hoveredItem = $0 ? "New category" : nil }
            }
            .padding(.top, 4)

            Spacer()

            // Settings Button
            UIButton(action: { showingSettings = true }, style: .ghost, label: "Settings", icon: "gearshape", align: .leading)
                .padding(.horizontal, 8)
                .padding(.bottom, 16)
                .onHover { hoveredItem = $0 ? "Settings" : nil }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.backgroundSecondary)
        .ignoresSafeArea(.container, edges: .top)
        .environment(\.lineLimit, 1)
        .environment(\.truncationMode, .tail)
        .sheet(item: $editingCategory) { category in
            EditCategorySheet(category: category) { newName, newColor in
                appState.renameCategory(from: category.name, to: newName, color: newColor)
            }
        }
        // Custom divider overlay removed; manual split controls spacing now
    }
}
