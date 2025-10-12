# UI Implementation Documentation

## Overview
This document describes the custom UI implementation for the Collect macOS app, matching the reference design with a custom titlebar, sidebar, and modern card-based layout.

## Architecture

### Window Structure
- **Custom Titlebar**: No native macOS titlebar - fully custom implementation with traffic lights, breadcrumb navigation, and action buttons
- **Custom Sidebar**: Left panel with fixed width (240pt) containing navigation and categories
- **Main Content Area**: Scrollable detail view with header, tabs, filters, and card grid

### Color Scheme

#### Background Colors
- `backgroundPrimary`: RGB(0.98, 0.98, 0.97) - Main content background (warm off-white)
- `backgroundSecondary`: RGB(0.96, 0.95, 0.94) - Sidebar background (light warm gray)
- `backgroundTertiary`: White - Titlebar and cards

#### Text Colors
- `textPrimary`: RGB(0.2, 0.18, 0.16) - Main text (dark brown-gray)
- `textSecondary`: RGB(0.55, 0.52, 0.48) - Secondary text (medium brown-gray)
- `textTertiary`: RGB(0.7, 0.67, 0.63) - Tertiary text (light brown-gray)

#### Card Colors (Pastels)
- `cardTan`: RGB(0.93, 0.88, 0.82)
- `cardYellow`: RGB(0.95, 0.94, 0.78)
- `cardGreen`: RGB(0.85, 0.92, 0.82)
- `cardBlue`: RGB(0.84, 0.89, 0.92)
- `cardPink`: RGB(0.95, 0.88, 0.88)
- `cardPurple`: RGB(0.90, 0.87, 0.93)
- `cardGray`: RGB(0.91, 0.90, 0.89)
- `cardPeach`: RGB(0.95, 0.90, 0.85)

#### Accent Colors
- `accentPrimary`: RGB(0.4, 0.38, 0.35) - Dark brown-gray for primary actions
- `badgeBrown`: RGB(0.85, 0.80, 0.72) - Author chips background
- `badgeBeige`: RGB(0.90, 0.87, 0.82) - Selected tab background

### Typography

#### Serif Fonts (Titles)
- **Large Title**: 34pt, bold, serif - Category headers
- **Title**: 24pt, semibold, serif - Section titles
- **Card Title**: 16pt, medium, serif - File card titles

#### Sans-serif Fonts (UI)
- **Body**: 15pt - Regular text
- **Caption**: 13pt - Labels, sidebar items
- **Small**: 11pt - Counts, metadata

## Component Breakdown

### 1. Custom Titlebar (`CustomTitleBar`)
**Height**: 52pt

**Elements**:
- Traffic light buttons (red, yellow, green circles - 12pt diameter)
- Breadcrumb navigation: "My Library / Computer Science"
- Action buttons (right-aligned):
  - Plus button (add new item)
  - Search button
  - Close/menu button
- Background: `backgroundTertiary` (white)

### 2. Custom Sidebar (`CustomSidebar`)
**Width**: 240pt

**Sections**:
1. **Fixed Items** (top):
   - Recent
   - Reading list
   - Discover
   - Padding: 8pt horizontal, 12pt top

2. **Divider**: 1pt line with 10pt vertical spacing

3. **My Library**:
   - Section header: "MY LIBRARY" (11pt, uppercase, semibold)
   - Category items with:
     - Colored dot (8pt diameter)
     - Category name (13pt)
     - Item count (11pt, right-aligned)
   - "New category +" button

4. **Settings Button** (bottom):
   - Gear icon + "Settings" text
   - Padding: 16pt bottom

**Interactions**:
- Hover state: Light background (`sidebarItemHover`)
- Selected state: Slightly darker background (`sidebarItemActive`)
- Border radius: 5pt

### 3. Detail View (`DetailView`)

#### Header Section
- **Title**: Large serif font (34pt bold)
- **Edit button**: Pencil icon next to title
- **Description**: Secondary text (14pt)
- Padding: 32pt horizontal, 24pt top

#### Tab Bar
Three tabs: Items, Notebooks, Canvases
- Icons + text (13pt)
- Selected tab: Beige background
- Padding: 12pt horizontal, 6pt vertical

#### Authors Section
- Label: "Authors" (12pt, medium)
- Horizontal scrolling chips:
  - Author name + count
  - Brown badge background
  - 12pt font, 10pt horizontal padding
  - Border radius: 12pt

#### New Items Section
- Header: "New items (1)" (13pt, semibold)
- Single card preview (180pt × 240pt)

#### Items Grid
- Header: "Items (8)" with Add and Sort buttons
- Adaptive grid: minimum 180pt, maximum 220pt per column
- 16pt spacing between cards
- Card height: 240-280pt (flexible)

### 4. File Cards (`FileCard`)

**Structure** (top to bottom):
1. **Top badges** (12pt padding):
   - Tags and year badges
   - 10pt font, white semi-transparent background
   - 4pt corner radius

2. **Spacer** (flexible)

3. **Title** (12pt horizontal padding):
   - 16pt serif font, medium weight
   - Up to 4 lines
   - Dark primary text color

4. **Author** (12pt horizontal padding):
   - 12pt sans-serif font
   - Secondary text color
   - Up to 2 lines
   - 6pt top padding

5. **Bottom bar** (12pt padding):
   - Left: Book icon + note count (11pt, tertiary color)
   - Right: Ellipsis button (context menu)

**Card Styling**:
- Background: Pastel color (varies per card)
- Corner radius: 12pt
- Shadows:
  - Inner: 2pt radius, 1pt offset, 4% opacity
  - Outer: 8pt radius, 4pt offset, 2% opacity

## Layout Specifications

### Spacing
- **Sidebar padding**: 8pt horizontal
- **Main content padding**: 32pt horizontal
- **Vertical section spacing**: 16-24pt
- **Card grid spacing**: 16pt
- **Card internal padding**: 12pt

### Sizing
- **Minimum window**: 900×600pt
- **Sidebar width**: 240pt (fixed)
- **Titlebar height**: 52pt (fixed)
- **Card minimum width**: 180pt
- **Card maximum width**: 220pt
- **Card height**: 240-280pt (flexible)

## Interactions

### Hover States
- **Sidebar items**: Light background overlay
- **Buttons**: Standard macOS button behavior
- **Cards**: Can be extended to show hover effects

### Click Actions
- **Sidebar categories**: Filter view by category
- **Author chips**: Filter by author
- **File cards**: Open Quick Look preview
- **Card ellipsis**: Show context menu

## Technical Implementation

### SwiftUI Structure
```
ContentView
├── CustomTitleBar
└── HStack
    ├── CustomSidebar
    │   ├── Fixed items (Recent, Reading list, Discover)
    │   ├── Divider
    │   ├── My Library section
    │   │   └── Category items
    │   └── Settings button
    └── DetailView (ScrollView)
        ├── Header (title + description)
        ├── Tab bar
        ├── Authors section (horizontal scroll)
        ├── New items section
        └── Items grid (LazyVGrid)
            └── FileCard components
```

### Key Files
- `CollectApp.swift`: Window configuration with `.hiddenTitleBar`
- `ContentView.swift`: Main layout, titlebar, and sidebar
- `Views/Detail/DetailView.swift`: Detail view and file cards
- `Theme/AppTheme.swift`: Color definitions
- `Theme/Typography.swift`: Font definitions

### State Management
- `AppState`: Observable object with published properties
- `@StateObject` for app-level state
- `@EnvironmentObject` for passing state to child views
- `@State` for local component state (hover, selection)

## Future Enhancements

### Phase 2 Features
1. Real data integration with FileSystemService
2. Quick Look preview on card click
3. Metadata editing sheet
4. Search functionality
5. Category creation and management
6. Author filtering logic
7. Sorting options (Recently added, Alphabetical, etc.)

### UI Improvements
1. Smooth animations for state changes
2. Drag and drop support
3. Context menus for cards
4. Keyboard navigation
5. Accessibility improvements
6. Dark mode support

## Design Principles

1. **Consistency**: All UI elements use the custom color scheme
2. **Native feel**: macOS-style interactions and behaviors
3. **Readability**: Serif fonts for content, sans-serif for UI
4. **Hierarchy**: Clear visual hierarchy with color, size, and weight
5. **Whitespace**: Generous padding and spacing for breathing room
6. **Minimalism**: Clean, uncluttered interface with focus on content

## Notes

- No native macOS titlebar or sidebar components used
- Fully custom implementation for maximum design control
- Color scheme uses warm, muted tones for comfortable reading
- Serif fonts for content create a library/document feel
- Pastel card colors provide visual variety without overwhelming
- All spacing and sizing values follow 4pt or 8pt grid system