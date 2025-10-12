import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var appState: AppState
    @State private var hoveredItem: String? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 80)
            // Fixed Items
            VStack(alignment: .leading, spacing: 1) {
                SidebarItem(
                    title: "Recent",
                    icon: nil,
                    count: nil,
                    isHovered: hoveredItem == "Recent"
                )
                .onHover { hoveredItem = $0 ? "Recent" : nil }
                
                SidebarItem(
                    title: "Reading list",
                    icon: nil,
                    count: nil,
                    isHovered: hoveredItem == "Reading list"
                )
                .onHover { hoveredItem = $0 ? "Reading list" : nil }
                
                SidebarItem(
                    title: "Discover",
                    icon: nil,
                    count: nil,
                    isHovered: hoveredItem == "Discover"
                )
                .onHover { hoveredItem = $0 ? "Discover" : nil }
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
                
                ForEach(sampleCategories) { category in
                    SidebarCategoryItem(
                        title: category.name,
                        color: category.color,
                        count: category.itemCount,
                        isSelected: category.name == "Computer Science",
                        isHovered: hoveredItem == category.name
                    )
                    .onHover { hoveredItem = $0 ? category.name : nil }
                }
                
                Button(action: {}) {
                    HStack(spacing: 8) {
                        Text("New category")
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .font(.system(size: 13))
                        Text("+")
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundColor(AppTheme.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                }
                .buttonStyle(.plain)
                .background(
                    hoveredItem == "New category"
                        ? AppTheme.sidebarItemHover : Color.clear
                )
                .cornerRadius(6)
                .padding(.horizontal, 8)
                .onHover { hoveredItem = $0 ? "New category" : nil }
            }
            .padding(.top, 4)
            
            Spacer()
            
            // Settings Button
            Button(action: {}) {
                HStack(spacing: 8) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 13))
                    Text("Settings")
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .font(.system(size: 13))
                }
                .foregroundColor(AppTheme.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
            .background(
                hoveredItem == "Settings"
                    ? AppTheme.sidebarItemHover : Color.clear
            )
            .cornerRadius(6)
            .padding(.horizontal, 8)
            .padding(.bottom, 16)
            .onHover { hoveredItem = $0 ? "Settings" : nil }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.backgroundSecondary)
        .ignoresSafeArea(.container, edges: .top)
        .environment(\.lineLimit, 1)
        .environment(\.truncationMode, .tail)
        // Custom divider overlay removed; manual split controls spacing now
    }
    
    var sampleCategories: [Category] {
        [
            Category(name: "Uncategorized", color: "gray", itemCount: 0),
            Category(name: "Computer Science", color: "blue", itemCount: 8),
            Category(name: "Finance", color: "orange", itemCount: 1),
            Category(name: "Math", color: "pink", itemCount: 2),
        ]
    }
}
