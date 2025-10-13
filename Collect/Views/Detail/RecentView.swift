import AppKit
import SwiftUI

struct RecentView: View {
    @EnvironmentObject var appState: AppState
    @Binding var isDropdownExpanded: Bool
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
            // Last Opened Section
            VStack(alignment: .leading, spacing: 12) {
                Text("Recently Opened")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                    .padding(.top, 24)

                if appState.lastOpenedFiles.isEmpty {
                    VStack(spacing: 8) {
                        Text("No recently opened files")
                            .font(.body)
                            .foregroundColor(
                                AppTheme.textSecondary
                            )
                    }
                    .frame(maxWidth: .infinity, minHeight: 100)
                    .padding(.vertical, 20)
                } else {
                    AppKitCardsGrid(
                        files: appState.lastOpenedFiles,
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
                }
            }

            // Last Added Section
            VStack(alignment: .leading, spacing: 12) {
                Text("Recently Added")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)

                if appState.lastAddedFiles.isEmpty {
                    VStack(spacing: 8) {
                        Text("No recently added files")
                            .font(.body)
                            .foregroundColor(
                                AppTheme.textSecondary
                            )
                    }
                    .frame(maxWidth: .infinity, minHeight: 100)
                    .padding(.vertical, 20)
                } else {
                    AppKitCardsGrid(
                        files: appState.lastAddedFiles,
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
                }
            }
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 32)
    }
}
