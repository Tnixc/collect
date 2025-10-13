# Color Naming Update Summary

## Overview

Updated all color names throughout the application to match the new theme system with consistent naming conventions.

## Color Name Changes

### Category Colors (Used for tags/categories)

**New Names:**
- `peach` - #C97D6E
- `darkRed` - #C98A7D
- `pink` - #BC76C1
- `purple` - #8C6FAA
- `red` - #CB7676
- `salmon` - #CC8D82
- `yellow` - #CC8D70
- `orange` - #DCA466
- `darkGreen` - #4C8E72
- `green` - #80A665
- `teal` - #5EA994
- `blue` - #5D9AA9
- `cyan` - #6394BF
- `navy` - #6872AB

**Old Names Removed:**
- `lavender` (consolidated into navy/purple)
- `tan` (removed in favor of peach/darkRed)
- `gray` (removed in favor of blue as default)

### Card Colors (Used for document cards)

**New Names:**
- `cardPeach` - Adaptive desaturated peach
- `cardDarkRed` - Adaptive desaturated dark red
- `cardPink` - Adaptive desaturated pink
- `cardPurple` - Adaptive desaturated purple
- `cardRed` - Adaptive desaturated red
- `cardSalmon` - Adaptive desaturated salmon
- `cardYellow` - Adaptive desaturated yellow
- `cardOrange` - Adaptive desaturated orange
- `cardDarkGreen` - Adaptive desaturated dark green
- `cardGreen` - Adaptive desaturated green
- `cardTeal` - Adaptive desaturated teal
- `cardBlue` - Adaptive desaturated blue
- `cardCyan` - Adaptive desaturated cyan
- `cardNavy` - Adaptive desaturated navy

**Old Names Removed:**
- `cardTan` (replaced with cardPeach/cardDarkRed)
- `cardGray` (removed)

## Files Updated

### 1. `AppTheme.swift`
- Added all new category color constants
- Added all new card color computed properties
- Updated `categoryColors` dictionary
- Updated `cardColors` dictionary
- Updated `cardToCategoryMapping` with new mappings

### 2. `EditMetadataSheet.swift`
- Updated `cardColorNames` array with all 14 new card colors
- Simplified `colorFromName()` to use `AppTheme.cardColor(for:)`

### 3. `CreateCategorySheet.swift`
- Updated `predefinedColors` array with all 14 new category colors

### 4. `EditCategorySheet.swift`
- Updated `predefinedColors` array with all 14 new category colors

### 5. `MetadataService.swift`
- Updated `cardColorNames` array in `createMetadata()` function

### 6. `AppState.swift`
- Updated default colors array for auto-assigning categories
- Changed "Uncategorized" default from `gray` to `blue`

### 7. `FileMetadata.swift`
- Changed default `cardColor` parameter from `cardTan` to `cardBlue`

### 8. `FileCard.swift`
- Changed fallback color from `gray` to `blue`

### 9. `AppKitCardsGrid.swift`
- Changed fallback color from `gray` to `blue`

## Default Color Changes

| Context | Old Default | New Default |
|---------|-------------|-------------|
| Card Color | `cardTan` | `cardBlue` |
| Category Fallback | `gray` | `blue` |
| Uncategorized | `gray` | `blue` |
| Missing Category | `gray` | `blue` |

## Helper Methods

All color lookup methods now use the centralized `AppTheme` functions:

```swift
// Category colors
AppTheme.categoryColor(for: name) -> Color
AppTheme.categoryNSColor(for: name) -> NSColor

// Card colors
AppTheme.cardColor(for: name) -> Color
```

## Color Count

- **Category Colors**: 14 distinct colors
- **Card Colors**: 14 adaptive colors (desaturated versions)
- **Total Color Palette**: 28+ colors including semantic colors

## Migration Notes

### For Existing Data

Existing metadata with old color names will gracefully fall back to `blue`:
- Files with `cardTan` → Falls back to `cardBlue`
- Files with `cardGray` → Falls back to `cardBlue`
- Categories with `gray` or `tan` → Falls back to `blue`

### For New Files

All new files will be assigned one of the 14 card colors randomly based on their UUID hash.

### For New Categories

Users can now choose from 14 vibrant category colors when creating or editing categories.

## Benefits

1. **Consistency**: Unified naming scheme across the entire codebase
2. **Expandability**: Easy to add new colors in the future
3. **Clarity**: Color names match their visual appearance
4. **Theme Support**: All colors work beautifully in light and dark modes
5. **No Duplication**: Removed redundant color options

## Testing Checklist

- ✅ All new colors render correctly in light mode
- ✅ All new colors render correctly in dark mode
- ✅ Card color picker shows all 14 options
- ✅ Category color picker shows all 14 options
- ✅ Existing files with old color names fall back gracefully
- ✅ New files get random colors from the new palette
- ✅ Build succeeds without errors or warnings