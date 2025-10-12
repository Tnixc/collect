# SwiftUI macOS File Organization App - REVISED Development Plan

## Project Overview
A **local-only** macOS app for organizing **PDFs** (under 400 files) with external metadata storage, tag-based filtering, and URL-based file downloading. Files are viewed via **Quick Look** and external apps.

---

## Core Architecture (Revised)

### 1. **Data Models**

- **FileItem**: Represents a physical PDF file with:
  - File path/URL
  - Filename
  - File size
  - Date added/modified
  - **Unique ID** (read from extended attribute `com.collect.fileid`)
  - Reference to metadata (matched by unique ID)

- **FileMetadata**: Externally stored metadata including:
  - **Unique file ID** (matches extended attribute on file)
  - Tags/Categories (array of strings)
  - Author(s) (array of strings)
  - Year
  - Title (defaults to filename if not set)
  - Notes/Description
  - Date added to library
  - **Card color** (for visual distinction)

- **Category/Tag**: 
  - Name
  - Color (for sidebar display)
  - Item count (computed from files)

### 2. **Data Storage**

- **File System**: PDFs stored in a single user-selected source directory (scanned recursively)
- **Extended Attributes**: Each PDF gets a unique ID stored as `com.collect.fileid` xattr
  - ID persists with the file through moves/renames within the system
  - Generated once when file is first discovered
  - Used for stable file-to-metadata matching
- **Metadata Storage**: Single JSON file in Application Support:
  - `~/Library/Application Support/Collect/metadata.json`
  - Dictionary structure: `{ "file-id": MetadataObject }`
- **Settings**: UserDefaults for:
  - Source directory path
  - Theme preference (if manual override)
  - Window size/position
  - Last selected category

### 3. **File System Operations**

- Recursive directory scanner (finds all `.pdf` files)
- Extended attribute read/write for unique IDs
- Metadata matching by unique ID
- Uncategorized detection (files with no tags in metadata)
- No real-time file watching needed (small scale, refresh on app activation)

---

## Feature Breakdown (Revised)

### Phase 1: Core Functionality

#### A. **File Discovery & Identity Management**
- Scan source directory recursively for PDFs
- Read extended attribute `com.collect.fileid` from each file
- If attribute missing, generate UUID and write to xattr
- Build in-memory list of FileItems with their IDs
- Match FileItems to metadata by ID
- Detect files without metadata entries

#### B. **Metadata Management**
- Load metadata.json at startup
- In-memory dictionary: `[UUID: FileMetadata]`
- Create/update/delete metadata entries
- Auto-save to JSON after changes (debounced)
- Handle orphaned metadata (file no longer exists)

#### C. **Category/Tag System**
- Extract unique tags from all metadata
- Auto-generate category list with item counts
- Special "Uncategorized" category (files without tags)
- Category colors (predefined palette or user-selected)
- Multi-tag support per file

#### D. **Quick Look Integration**
- Implement Quick Look preview panel
- Space bar to preview selected file
- Click to open in default PDF app (Preview, etc.)
- Right-click → "Open With" menu

### Phase 2: User Interface

#### A. **Main Window Structure**
- **Sidebar** (200-250pt width):
  - Fixed sections: Recent, Reading list (future), Discover (future)
  - Divider
  - "My library" header
  - Category list with color dots and counts
  - "New category +" button
  - Settings button (bottom)

- **Main Content Area**:
  - **Breadcrumb/Header**: "My Library / Computer Science"
  - **Title & Description**: Large serif title with editable description
  - **Tab Bar**: Items (only tab for MVP; others for future)
  - **Author Filter**: Horizontal chips showing all authors with counts
  - **"New items" Section**: Recently added files (last 7 days)
  - **Items Grid**: 3-4 columns adaptive grid of cards
  - **Toolbar**: + Add, 🔍 Search, sort dropdown

#### B. **Card Component** (FileCardView)
- Rounded rectangle with pastel background color
- Top badges: Year, Category tags
- Title in serif font (multi-line, truncated)
- Author name in smaller text
- Bottom-left: icon indicator (PDF icon)
- Bottom-right: context menu button
- Hover effects
- Click to Quick Look
- Double-click to open in external app

#### C. **Metadata Editor Sheet**
- Triggered by: Edit button, new file, or card menu
- Fields:
  - Title (text field)
  - Author(s) (tag input with autocomplete)
  - Year (number field)
  - Tags/Categories (tag input with autocomplete)
  - Notes (multi-line text)
  - Card color picker (pastel palette)
- Save/Cancel buttons

### Phase 3: Advanced Features

#### A. **URL Download Feature**
- Sheet/dialog with URL input field
- Execute `wget` via `Process`:
  ```
  wget -P <source_directory> <url>
  ```
- Show progress/spinner (indeterminate since wget output parsing is complex)
- On completion:
  - Scan for new file
  - Assign unique ID via xattr
  - Open metadata editor pre-filled with filename
- Error handling for network/wget failures

#### B. **File Operations Menu**
- Quick Look (Space)
- Open (Return or double-click)
- Open With... (submenu)
- Show in Finder
- Edit Metadata...
- Delete (move to Trash with confirmation)
- Copy Metadata (for future)

#### C. **Filtering & Search**
- Sidebar: Click category to filter by tag
- Author chips: Click to filter by author
- Search field: Filter by filename/title/author
- Combined filters (category AND author AND search)
- "Recently added" filter (last 7 days)

---

## Design System

### 1. **Theme Architecture**

**File: `Theme/AppTheme.swift`**
- Centralized color and typography definitions
- Environment-based light/dark mode support
- Custom color extension with semantic names

**Color Palette Structure**:
```swift
// Background colors
- backgroundPrimary (window background)
- backgroundSecondary (sidebar background)
- backgroundTertiary (card/panel background)

// Text colors
- textPrimary
- textSecondary
- textTertiary

// Accent colors
- accentPrimary (active items)
- accentSecondary (hover states)

// Card colors (pastels - 8-10 variants)
- cardTan, cardYellow, cardGreen, cardBlue, cardPink, cardPurple, cardGray

// Semantic colors
- borderColor
- dividerColor
- sidebarItemActive
```

Each color has light and dark mode variants.

### 2. **Typography**

**File: `Theme/Typography.swift`**
- **Display/Title**: New York (serif) - for category titles, card titles
- **Body/UI**: SF Pro (system) - for labels, buttons, metadata
- Font sizes:
  - `.largeTitle` - 34pt (category headers)
  - `.title` - 24pt (card titles)
  - `.title2` - 20pt
  - `.body` - 15pt (metadata, labels)
  - `.caption` - 13pt (author names, badges)

### 3. **Component Styles**

**Files in `Theme/Components/`**:
- `CardStyle.swift` - Rounded corner, shadow, background
- `ChipStyle.swift` - Pill-shaped tags with borders
- `ButtonStyles.swift` - Custom toolbar buttons
- `SidebarItemStyle.swift` - Category items with color dots

---

## Technical Implementation Details

### 1. **SwiftUI Views Structure**

```
ContentView
├── NavigationSplitView
│   ├── Sidebar (List)
│   │   ├── Section("") - Recent, Reading list, Discover
│   │   ├── Section("My library")
│   │   │   └── ForEach(categories)
│   │   │       └── CategoryRow (Label with color dot)
│   │   └── Button("New category +")
│   │
│   └── DetailView (for selected category)
│       ├── VStack
│       │   ├── HeaderView (breadcrumb, title, description)
│       │   ├── TabView (Items/Notebooks/Canvases)
│       │   ├── AuthorFilterView (ScrollView horizontal)
│       │   ├── NewItemsSection (if any recent)
│       │   └── ItemsGridView
│       │       └── LazyVGrid
│       │           └── ForEach(filteredFiles)
│       │               └── FileCardView
│       │                   ├── VStack
│       │                   ├── Badges (year, tags)
│       │                   ├── Title (serif)
│       │                   ├── Author
│       │                   └── Footer icons
│
└── Sheets/Overlays
    ├── AddURLSheet
    ├── EditMetadataSheet
    ├── SettingsSheet
    └── QuickLookPreview
```

### 2. **State Management**

- **AppState (ObservableObject)**: Root state
  - `@Published var files: [FileItem]`
  - `@Published var metadata: [UUID: FileMetadata]`
  - `@Published var categories: [Category]`
  - `@Published var selectedCategory: String?`
  - `@Published var selectedAuthor: String?`
  - `@Published var searchText: String`
  - Computed: `filteredFiles`, `allAuthors`, `recentFiles`

- **@AppStorage**: User preferences
  - `sourceDirectoryPath`
  - `windowSize`, `sidebarWidth`

### 3. **View Models / Services**

**FileSystemService.swift**:
- `scanDirectory(path: URL) -> [URL]` - Recursive PDF scan
- `getFileID(url: URL) -> UUID?` - Read xattr
- `setFileID(url: URL, id: UUID)` - Write xattr
- `ensureFileID(url: URL) -> UUID` - Read or create

**MetadataService.swift**:
- `load() -> [UUID: FileMetadata]`
- `save(metadata: [UUID: FileMetadata])`
- `createMetadata(fileID: UUID) -> FileMetadata`
- `updateMetadata(fileID: UUID, metadata: FileMetadata)`
- `deleteMetadata(fileID: UUID)`

**DownloadService.swift**:
- `downloadFile(url: String, destination: URL) async throws -> URL`
- Execute `wget` via `Process`
- Return downloaded file URL

**QuickLookService.swift**:
- Wrapper for `QLPreviewPanel`
- Manage preview items

### 4. **Extended Attributes Implementation**

```swift
// Read xattr
func getFileID(url: URL) -> UUID? {
    let data = try? url.withUnsafeFileSystemRepresentation { path in
        let length = getxattr(path, "com.collect.fileid", nil, 0, 0, 0)
        guard length > 0 else { return nil }
        var buffer = [UInt8](repeating: 0, count: length)
        getxattr(path, "com.collect.fileid", &buffer, length, 0, 0)
        return Data(buffer)
    }
    guard let data = data, let string = String(data: data, encoding: .utf8) else {
        return nil
    }
    return UUID(uuidString: string)
}

// Write xattr
func setFileID(url: URL, id: UUID) {
    let idString = id.uuidString
    try? url.withUnsafeFileSystemRepresentation { path in
        setxattr(path, "com.collect.fileid", idString, idString.utf8.count, 0, 0)
    }
}
```

### 5. **Quick Look Integration**

```swift
// Conform to QLPreviewItem protocol
extension FileItem: QLPreviewItem {
    var previewItemURL: URL? { fileURL }
}

// Show Quick Look panel
let panel = QLPreviewPanel.shared()
panel?.makeKeyAndOrderFront(nil)
```

---

## File Structure

```
Collect/
├── CollectApp.swift (main app entry with @main)
├── Models/
│   ├── FileItem.swift
│   ├── FileMetadata.swift
│   ├── Category.swift
│   └── AppState.swift (main state object)
├── Services/
│   ├── FileSystemService.swift (scan, xattr operations)
│   ├── MetadataService.swift (JSON read/write)
│   ├── DownloadService.swift (wget wrapper)
│   └── QuickLookService.swift (QL integration)
├── Views/
│   ├── ContentView.swift (NavigationSplitView root)
│   ├── Sidebar/
│   │   ├── SidebarView.swift
│   │   └── CategoryRowView.swift
│   ├── Detail/
│   │   ├── DetailView.swift
│   │   ├── HeaderView.swift
│   │   ├── AuthorFilterView.swift
│   │   ├── NewItemsSection.swift
│   │   └── ItemsGridView.swift
│   ├── Components/
│   │   ├── FileCardView.swift
│   │   └── AuthorChipView.swift
│   └── Sheets/
│       ├── AddURLSheet.swift
│       ├── EditMetadataSheet.swift
│       └── SettingsSheet.swift
├── Theme/
│   ├── AppTheme.swift (color definitions)
│   ├── Typography.swift (font extensions)
│   └── Components/
│       ├── CardStyle.swift
│       ├── ChipStyle.swift
│       └── ButtonStyles.swift
├── Utilities/
│   ├── Extensions.swift
│   └── Constants.swift
└── Resources/
    └── Assets.xcassets
```

---

## Key Technical Considerations (Revised)

### 1. **Extended Attributes**
- **Pros**: Fast, stable across renames/moves, no external DB needed
- **Cons**: Lost when files copied to non-macOS systems or certain cloud sync
- **Mitigation**: Store filename as fallback in metadata for recovery
- Use `setxattr`/`getxattr` from `Darwin` framework
- Handle gracefully when xattr is stripped (prompt user to reassign)

### 2. **Performance**
- No need for file watching at this scale (< 400 files)
- Refresh file list on app activation
- Single scan at startup (~100ms for 400 files)
- In-memory filtering is fast enough
- Metadata JSON < 500KB, loads instantly

### 3. **Security & Permissions**
- Request file access via Open Panel (user selects directory)
- Store bookmark for persistent access (sandboxed app)
- Xattr operations require file read/write access
- wget must be installed (check with `which wget`, prompt if missing)

### 4. **Error Handling**
- Missing xattr → generate new ID
- Corrupted metadata.json → backup and reset
- wget not found → show alert with installation instructions
- File deleted → mark metadata as orphaned (optional cleanup)
- Download failure → show error with details

### 5. **Edge Cases**
- Duplicate filenames in different directories (OK, UUID handles it)
- File moved outside source directory (appears deleted)
- Metadata without matching file (orphaned, show in settings)
- xattr stripped from file (reassign by filename match + user confirmation)
- Empty library (show onboarding/empty state)

---

## Development Phases Priority (Revised)

### **Phase 1 - MVP** (Week 1)
1. Basic SwiftUI app structure with NavigationSplitView
2. File scanning service (find PDFs recursively)
3. Extended attribute read/write for unique IDs
4. Simple metadata JSON storage (load/save)
5. Sidebar with hardcoded categories
6. Basic grid view with card layout
7. Theme system with light/dark colors
8. Serif fonts for titles

### **Phase 2 - Core Features** (Week 2)
1. Metadata editor sheet (all fields)
2. Tag/category extraction and filtering
3. Author extraction and filtering
4. Uncategorized detection
5. Quick Look integration (space bar preview)
6. Open in external app
7. Search functionality
8. "New items" section (7-day filter)

### **Phase 3 - Polish** (Week 3)
1. URL download with wget
2. Card color selection
3. File operations menu (delete, reveal, etc.)
4. Settings panel (source directory picker)
5. Empty states and error messages
6. Onboarding flow
7. Keyboard shortcuts
8. Animations and transitions

---
