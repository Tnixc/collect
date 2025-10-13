import AppKit
import SwiftUI

struct ItemsSectionView: View {
    @EnvironmentObject var appState: AppState
    @Binding var isDropdownExpanded: Bool
    let isSearchFocused: FocusState<Bool>.Binding
    let cardColors: [NSColor]
    let onTap: (UUID) -> Void
    let editAction: (UUID) -> Void
    let addToCategoryAction: (UUID, String) -> Void
    let createCategoryAction: (UUID) -> Void
    let deleteAction: (UUID) -> Void
    let showInFinderAction: (UUID) -> Void
    let addToReadingListAction: (UUID) -> Void
    let removeFromReadingListAction: (UUID) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            GeometryReader { geometry in
                if geometry.size.width < 600 {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(
                            "Items (\(appState.showReadingList ? appState.readingListFiles.count : appState.filteredFiles.count))"
                        )
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)

                        HStack(spacing: 8) {
                            // View mode toggle
                            HStack(spacing: 0) {
                                ForEach(ViewMode.allCases, id: \.self) {
                                    mode in
                                    Button(action: {
                                        appState.viewMode = mode
                                    }) {
                                        HStack(spacing: 4) {
                                            Image(
                                                systemName: mode
                                                    .iconName
                                            )
                                            .font(.system(size: 14))
                                            Text(mode.rawValue)
                                                .font(
                                                    .system(
                                                        size: 12,
                                                        weight: .medium
                                                    )
                                                )
                                        }
                                        .foregroundColor(
                                            appState.viewMode == mode
                                                ? AppTheme.textPrimary
                                                : AppTheme.textSecondary
                                        )
                                        .frame(width: 60, height: 32)
                                        .background(
                                            appState.viewMode == mode
                                                ? AppTheme
                                                .backgroundTertiary
                                                : Color.clear
                                        )
                                        .clipShape(
                                            RoundedRectangle(
                                                cornerRadius: 8
                                            )
                                        )
                                        .contentShape(
                                            RoundedRectangle(
                                                cornerRadius: 8
                                            )
                                        )
                                    }
                                    .buttonStyle(.plain)
                                    .smartFocusRing()
                                    .onHover { _ in
                                        withAnimation(
                                            .easeInOut(duration: 0.15)
                                        ) {
                                            // Note: hoveredViewMode is not used here, assuming it's handled elsewhere
                                        }
                                    }
                                }
                            }
                            .background(AppTheme.backgroundSecondary)
                            .clipShape(
                                RoundedRectangle(cornerRadius: 8)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(
                                        AppTheme.dividerColor,
                                        lineWidth: 1
                                    )
                            )
                            UIDropdown(
                                selectedOption: $appState.sortOption,
                                isExpanded: $isDropdownExpanded,
                                options: SortOption.allCases,
                                optionToString: { $0.rawValue },
                                optionToIcon: { $0.iconName },
                                width: 200,
                                height: 32
                            ).zIndex(999)

                            // Search bar
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(AppTheme.textSecondary)
                                TextField("Search", text: $appState.searchText)
                                    .textFieldStyle(.plain)
                                    .frame(width: 200)
                                    .foregroundColor(AppTheme.textPrimary)
                                    .padding(.vertical, 4)
                                    .focused(isSearchFocused)
                                    .smartFocusRing()
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AppTheme.backgroundTertiary)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8).stroke(
                                    AppTheme.dividerColor,
                                    lineWidth: 1.0
                                )
                            )
                        }
                    }
                } else {
                    HStack {
                        Text(
                            "Items (\(appState.showReadingList ? appState.readingListFiles.count : appState.filteredFiles.count))"
                        )
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)

                        Spacer()

                        HStack(spacing: 8) {
                            // View mode toggle
                            HStack(spacing: 0) {
                                ForEach(ViewMode.allCases, id: \.self) {
                                    mode in
                                    Button(action: {
                                        appState.viewMode = mode
                                    }) {
                                        HStack(spacing: 4) {
                                            Image(
                                                systemName: mode
                                                    .iconName
                                            )
                                            .font(.system(size: 14))
                                            Text(mode.rawValue)
                                                .font(
                                                    .system(
                                                        size: 12,
                                                        weight: .medium
                                                    )
                                                )
                                        }
                                        .foregroundColor(
                                            appState.viewMode == mode
                                                ? AppTheme.textPrimary
                                                : AppTheme.textSecondary
                                        )
                                        .frame(width: 60, height: 32)
                                        .background(
                                            appState.viewMode == mode
                                                ? AppTheme
                                                .backgroundTertiary
                                                : Color.clear
                                        )
                                        .clipShape(
                                            RoundedRectangle(
                                                cornerRadius: 8
                                            )
                                        )
                                        .contentShape(
                                            RoundedRectangle(
                                                cornerRadius: 8
                                            )
                                        )
                                    }
                                    .buttonStyle(.plain)
                                    .smartFocusRing()
                                    .onHover { _ in
                                        withAnimation(
                                            .easeInOut(duration: 0.15)
                                        ) {
                                            // Note: hoveredViewMode is not used here
                                        }
                                    }
                                }
                            }
                            .background(AppTheme.backgroundSecondary)
                            .clipShape(
                                RoundedRectangle(cornerRadius: 8)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(
                                        AppTheme.dividerColor,
                                        lineWidth: 1
                                    )
                            )
                            UIDropdown(
                                selectedOption: $appState.sortOption,
                                isExpanded: $isDropdownExpanded,
                                options: SortOption.allCases,
                                optionToString: { $0.rawValue },
                                optionToIcon: { $0.iconName },
                                width: 200,
                                height: 32
                            ).zIndex(999)

                            // Search bar
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(AppTheme.textSecondary)
                                TextField("Search", text: $appState.searchText)
                                    .textFieldStyle(.plain)
                                    .frame(width: 200)
                                    .foregroundColor(AppTheme.textPrimary)
                                    .padding(.vertical, 4)
                                    .focused(isSearchFocused)
                                    .smartFocusRing()
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AppTheme.backgroundTertiary)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8).stroke(
                                    AppTheme.dividerColor,
                                    lineWidth: 1.0
                                )
                            )
                        }
                    }
                }
            }
            .frame(minHeight: 100)

            if (appState.showReadingList
                && appState.readingListFiles.isEmpty)
                || (!appState.showReadingList
                    && appState.filteredFiles.isEmpty)
            {
                VStack(spacing: 16) {
                    Image(
                        systemName: appState.showReadingList
                            ? "book" : "doc.text"
                    )
                    .font(.system(size: 48))
                    .foregroundColor(AppTheme.textTertiary)
                    Text(
                        appState.showReadingList
                            ? "No items in reading list"
                            : "No PDFs found"
                    )
                    .font(.title2)
                    .foregroundColor(AppTheme.textPrimary)
                    Text(
                        appState.showReadingList
                            ? "Add items to your reading list from the context menu."
                            : "Select a source directory in Settings to get started."
                    )
                    .font(.body)
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, minHeight: 200)
                .padding(.vertical, 40)
            } else {
                // Grid or List View
                if appState.viewMode == .grid {
                    AppKitCardsGrid(
                        files: appState.showReadingList
                            ? appState.readingListFiles
                            : appState.filteredFiles,
                        metadata: appState.metadata,
                        categories: appState.categories,
                        cardColors: cardColors,
                        disableHover: isDropdownExpanded,
                        onTap: onTap,
                        editAction: editAction,
                        addToCategoryAction: addToCategoryAction,
                        createCategoryAction: createCategoryAction,
                        deleteAction: deleteAction,
                        showInFinderAction: showInFinderAction,
                        addToReadingListAction: addToReadingListAction,
                        removeFromReadingListAction: removeFromReadingListAction
                    ).zIndex(-1)
                } else {
                    AppKitListView(
                        files: appState.showReadingList
                            ? appState.readingListFiles
                            : appState.filteredFiles,
                        metadata: appState.metadata,
                        categories: appState.categories,
                        onTap: onTap,
                        editAction: editAction,
                        addToCategoryAction: addToCategoryAction,
                        createCategoryAction: createCategoryAction,
                        deleteAction: deleteAction,
                        showInFinderAction: showInFinderAction,
                        addToReadingListAction: addToReadingListAction,
                        removeFromReadingListAction: removeFromReadingListAction
                    )
                    .zIndex(-1)
                    .frame(
                        height: CGFloat(
                            appState.showReadingList
                                ? appState.readingListFiles
                                .count
                                : appState.filteredFiles.count
                        ) * 80
                    )
                }
            }
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 32)
    }
}
