# Theme System Documentation

## Overview

Collect now supports light and dark mode with three theme options:
- **System** - Automatically follows your macOS appearance settings
- **Light** - Always use light mode
- **Dark** - Always use dark mode

## Color Palette

The theme system uses a carefully selected color palette that works beautifully in both light and dark modes:

### Grayscale
- `#D8D6C9` - Primary text (dark mode)
- `#B2B0A6` - Secondary text (dark mode)
- `#999895` - Tertiary text (dark mode)
- `#7F7F7C` - Tertiary text (light mode)
- `#666666` - Secondary text (light mode)
- `#4C4C4C` - Card backgrounds (dark mode)
- `#333333` - Primary text (light mode)
- `#1F1F1F` - Tertiary background (dark mode)
- `#181818` - Secondary background (dark mode)
- `#121212` - Primary background (dark mode)
- `#060606` - Deepest black
- `#000000` - Pure black

### Accent Colors (Always vibrant)
- `#C97D6E` - Peach
- `#C98A7D` - Dark Red
- `#BC76C1` - Pink
- `#8C6FAA` - Purple
- `#CB7676` - Red
- `#CC8D82` - Salmon
- `#CC8D70` - Yellow
- `#DCA466` - Orange
- `#4C8E72` - Dark Green
- `#80A665` - Green
- `#5EA994` - Teal
- `#5D9AA9` - Blue
- `#6394BF` - Cyan
- `#6872AB` - Navy/Lavender

## Architecture

### ThemeManager
The central theme management system (`ThemeManager.swift`) handles:
- Theme mode selection (System/Light/Dark)
- Monitoring system appearance changes
- Determining the effective color scheme
- Persisting user preferences

```swift
@StateObject private var themeManager = ThemeManager.shared
```

### AppTheme
The `AppTheme` enum provides dynamic color properties that automatically adapt based on the current theme:

```swift
// Background colors
static var backgroundPrimary: Color
static var backgroundSecondary: Color
static var backgroundTertiary: Color

// Text colors
static var textPrimary: Color
static var textSecondary: Color
static var textTertiary: Color

// Semantic colors
static var borderColor: Color
static var dividerColor: Color
static var accentPrimary: Color
```

All colors automatically switch between light and dark variants based on `ThemeManager.shared.isDarkMode`.

### Category Colors
Category/tag colors remain vibrant and consistent across both themes to ensure tags are always easily identifiable. These use the saturated colors from the palette and don't change between light/dark modes.

## Usage

### In Views
Views automatically receive the theme through the environment:

```swift
@EnvironmentObject var themeManager: ThemeManager
```

Simply use `AppTheme` properties throughout your views:

```swift
Text("Hello")
    .foregroundColor(AppTheme.textPrimary)
    .background(AppTheme.backgroundSecondary)
```

### Changing Themes
Users can change the theme in Settings:

1. Open Settings (⌘,)
2. Select from System, Light, or Dark appearance
3. Changes apply immediately

The preference is saved and persists between app launches.

## Implementation Details

### Theme Detection
The system monitors macOS appearance changes via:
- `NSNotification.Name("AppleInterfaceThemeChangedNotification")`
- `NSApp.effectiveAppearance`

### Color Scheme Application
The theme is applied at the app level in `CollectApp.swift`:

```swift
ContentView()
    .environmentObject(themeManager)
    .preferredColorScheme(themeManager.effectiveColorScheme)
```

### Window Background
The window background color is updated dynamically when the theme changes:

```swift
window.backgroundColor = AppTheme.backgroundSecondaryNSColor
```

## Design Principles

1. **Automatic Adaptation** - Most colors automatically adapt to the current theme
2. **Semantic Naming** - Colors are named by purpose (e.g., `textPrimary`) not appearance
3. **Consistency** - Category colors remain consistent for easy recognition
4. **System Integration** - Default "System" mode respects user's macOS preference
5. **Contrast** - All text colors meet WCAG contrast requirements in both modes

## File Structure

```
Collect/Theme/
├── ThemeManager.swift    # Theme state management
├── AppTheme.swift        # Color definitions and dynamic switching
├── Typography.swift      # Font definitions
└── NewYork.swift         # Font helpers
```
