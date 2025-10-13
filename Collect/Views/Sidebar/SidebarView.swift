import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var appState: AppState
    @Binding var showingSettings: Bool
    @Binding var showingCreateCategory: Bool
    @State private var hoveredItem: String? = nil
    @State private var editingCategory: Category? = nil
    @State private var deletingCategory: Category? = nil

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 40)
            // Fixed Items
            VStack(alignment: .leading, spacing: 1) {
                SidebarItem(
                    title: "Recent",
                    icon: "clock",
                    count: nil,
                    isHovered: hoveredItem == "Recent",
                    isSelected: appState.showRecent
                )
                .onHover { isHovering in
                    hoveredItem = isHovering ? "Recent" : nil
                }
                .onTapGesture {
                    appState.showRecent.toggle()
                    if appState.showRecent {
                        appState.selectedCategory = nil
                        appState.selectedAuthors.removeAll()
                        appState.showReadingList = false
                    }
                }

                SidebarItem(
                    title: "Reading list",
                    icon: "book",
                    count: appState.readingListCount > 0 ? appState.readingListCount : nil,
                    isHovered: hoveredItem == "Reading list",
                    isSelected: appState.showReadingList
                )
                .onHover { isHovering in
                    hoveredItem = isHovering ? "Reading list" : nil
                }
                .onTapGesture {
                    appState.showReadingList.toggle()
                    if appState.showReadingList {
                        appState.selectedCategory = nil
                        appState.selectedAuthors.removeAll()
                        appState.showRecent = false
                    }
                }

                SidebarItem(
                    title: "All Items",
                    icon: "tray.full",
                    count: appState.files.count > 0 ? appState.files.count : nil,
                    isHovered: hoveredItem == "All Items",
                    isSelected: appState.selectedCategory == nil && !appState.showReadingList && !appState.showRecent
                )
                .onHover { isHovering in
                    hoveredItem = isHovering ? "All Items" : nil
                }
                .onTapGesture {
                    appState.selectedCategory = nil
                    appState.selectedAuthors.removeAll()
                    appState.showReadingList = false
                    appState.showRecent = false
                }
            }
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
                        isUncategorized: true
                    )
                    .onHover { isHovering in
                        hoveredItem = isHovering ? uncategorized.name : nil
                    }
                    .onTapGesture {
                        appState.selectedCategory = appState.selectedCategory == uncategorized.name ? nil : uncategorized.name
                        appState.showReadingList = false
                        appState.showRecent = false
                    }
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
                        isUncategorized: false
                    )
                    .contextMenu {
                        Button(action: {
                            editingCategory = category
                        }) {
                            Label("Edit Category", systemImage: "pencil")
                        }
                        Divider()
                        Button(role: .destructive, action: {
                            deletingCategory = category
                        }) {
                            Label("Delete Category", systemImage: "trash")
                        }
                    }
                    .onHover { isHovering in
                        hoveredItem = isHovering ? category.name : nil
                    }
                    .onTapGesture {
                        appState.selectedCategory = appState.selectedCategory == category.name ? nil : category.name
                        appState.showReadingList = false
                        appState.showRecent = false
                    }
                }

                UIButton(action: { showingCreateCategory = true }, style: .ghost, label: "New category +", align: .leading)
                    .padding(.horizontal, 8)
                    .onHover { isHovering in
                        hoveredItem = isHovering ? "New category" : nil
                    }
            }
            .padding(.top, 4)

            Spacer()

            // Settings Button
            UIButton(action: { showingSettings = true }, style: .ghost, label: "Settings", icon: "gearshape", align: .leading)
                .padding(.horizontal, 8)
                .padding(.bottom, 16)
                .onHover { isHovering in
                    hoveredItem = isHovering ? "Settings" : nil
                }
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
        .alert("Delete Category", isPresented: .constant(deletingCategory != nil), presenting: deletingCategory) { category in
            Button("Cancel", role: .cancel) {
                deletingCategory = nil
            }
            Button("Delete", role: .destructive) {
                appState.deleteCategory(category.name)
                if appState.selectedCategory == category.name {
                    appState.selectedCategory = nil
                }
                deletingCategory = nil
            }
        } message: { category in
            Text("Are you sure you want to delete \"\(category.name)\"? Items in this category will become uncategorized.")
        }
        // Custom divider overlay removed; manual split controls spacing now
    }
}
