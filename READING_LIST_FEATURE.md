# Reading List Feature Implementation

## Overview
This document describes the implementation of the Reading List feature in the Collect app. The reading list allows users to mark PDFs for later reading and access them through a dedicated sidebar section.

## Changes Made

### 1. Data Model Updates

#### FileMetadata.swift
- Added `isInReadingList: Bool` property to track which files are in the reading list
- Updated the initializer to include this new property with a default value of `false`
- The property is automatically persisted through the existing `Codable` conformance

### 2. State Management

#### AppState.swift
- Added `@Published var showReadingList: Bool = false` to track when the reading list view is active
- Added computed properties:
  - `readingListFiles: [FileItem]` - Returns files that are marked as in the reading list
  - `readingListCount: Int` - Returns the count of items in the reading list
- Added methods:
  - `addToReadingList(fileID: UUID)` - Marks a file as being in the reading list
  - `removeFromReadingList(fileID: UUID)` - Removes a file from the reading list
  - `toggleReadingList(fileID: UUID)` - Toggles the reading list status of a file

### 3. UI Updates

#### SidebarView.swift
- Made the "Reading list" sidebar item functional
- Display the count of items in the reading list (when > 0)
- Added selection state - the item appears selected when `showReadingList` is true
- Added tap gesture to toggle the reading list view
- When reading list is selected, it clears category and author filters
- Updated other sidebar items to clear `showReadingList` when selected

#### DetailView.swift
- Updated header to show "Reading list" when in reading list mode
- Hide the category edit button when viewing the reading list
- Hide the authors section when viewing the reading list
- Display appropriate empty state messages:
  - "No items in reading list" with book icon
  - "Add items to your reading list from the context menu."
- Updated the grid to show either `readingListFiles` or `filteredFiles` based on mode
- Added support for reading list actions in the AppKitCardsGrid component

#### AppKitCardsGrid.swift
- Added new action closures:
  - `addToReadingListAction: (UUID) -> Void`
  - `removeFromReadingListAction: (UUID) -> Void`
- Updated the `FileCardItem` class to support reading list actions:
  - Added action properties
  - Added `@objc` methods for adding/removing from reading list
  - Updated context menu to include reading list option
- Context menu now shows:
  - "Add to Reading List" with book icon (when not in list)
  - "Remove from Reading List" with filled book icon (when in list)
- Added separator before delete/show in finder actions for better organization

### 4. Context Menu Integration

The reading list functionality is accessible through right-click context menus on file cards:
- **Add to Reading List**: Appears when file is not in the reading list
- **Remove from Reading List**: Appears when file is already in the reading list
- The menu item dynamically changes based on the current state
- Uses appropriate SF Symbol icons (`book` and `book.fill`)

## User Experience

### Adding Items to Reading List
1. Right-click on any PDF card
2. Select "Add to Reading List"
3. The item count appears next to "Reading list" in the sidebar

### Viewing Reading List
1. Click the "Reading list" item in the sidebar
2. The main view switches to show only items in the reading list
3. The header displays "Reading list"
4. Authors filter is hidden (not applicable for reading list view)

### Removing Items from Reading List
1. While viewing any category or the reading list itself
2. Right-click on a card in the reading list
3. Select "Remove from Reading List"
4. The item is removed from the reading list but remains in the library

## Data Persistence

The reading list state is automatically persisted through the existing metadata system:
- `isInReadingList` is part of `FileMetadata` which is `Codable`
- Changes are saved to `metadata.json` via `MetadataService`
- Reading list state persists across app launches

## Technical Notes

- The reading list is independent of categories - items can be in both a category and the reading list
- The reading list view shows all items marked for reading, regardless of their category
- Sorting options remain available in reading list view
- Search functionality works within the reading list view
- File deletion removes the item from both the reading list and the library
- The implementation follows the existing patterns in the codebase for consistency

## Future Enhancements (Not Implemented)

Possible future improvements:
- Batch operations (add multiple items at once)
- Reading progress tracking
- Recently removed items
- Reading list export/import
- Multiple reading lists
- Drag and drop reordering
- Reading list sharing