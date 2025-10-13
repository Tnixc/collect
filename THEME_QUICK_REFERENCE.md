# Theme System Quick Reference

## Adding Theme Support to New Views

### 1. Import ThemeManager (if needed)
```swift
@EnvironmentObject var themeManager: ThemeManager
```

### 2. Use AppTheme Colors
Always use `AppTheme` properties instead of hardcoded colors:

```swift
// ✅ Good - Dynamic color
Text("Hello")
    .foregroundColor(AppTheme.textPrimary)

// ❌ Bad - Hardcoded color
Text("Hello")
    .foregroundColor(Color(hex: "#333333"))
```

## Common Color Usage

### Backgrounds
```swift
.background(AppTheme.backgroundPrimary)    // Main background
.background(AppTheme.backgroundSecondary)  // Cards, panels
.background(AppTheme.backgroundTertiary)   // Inputs, hover states
```

### Text
```swift
.foregroundColor(AppTheme.textPrimary)     // Headlines, body
.foregroundColor(AppTheme.textSecondary)   // Captions, labels
.foregroundColor(AppTheme.textTertiary)    // Placeholders, hints
```

### Interactive Elements
```swift
.stroke(AppTheme.borderColor)              // Borders
.fill(AppTheme.dividerColor)               // Dividers, separators
.fill(AppTheme.accentPrimary)              // Primary buttons
.fill(AppTheme.destructive)                // Delete, remove actions
```

### Cards
```swift
AppTheme.cardBlue         // Muted in light, saturated in dark
AppTheme.cardGreen
AppTheme.cardPink
AppTheme.cardPurple
AppTheme.cardRed
AppTheme.cardOrange
AppTheme.cardTeal
AppTheme.cardYellow
AppTheme.cardGray
```

### Category Tags (Always Vibrant)
```swift
AppTheme.categoryBlue     // Consistent across themes
AppTheme.categoryGreen
AppTheme.categoryPink
AppTheme.categoryPurple
AppTheme.categoryRed
AppTheme.categoryOrange
AppTheme.categoryTeal
AppTheme.categoryYellow
```

## AppKit/NSColor Usage

For AppKit components:
```swift
NSColor(AppTheme.textPrimary)              // Convert from Color
AppTheme.textPrimaryNSColor                // Direct NSColor variant
AppTheme.backgroundPrimaryNSColor
AppTheme.dividerNSColor
```

## Checking Current Theme

```swift
if ThemeManager.shared.isDarkMode {
    // Dark mode specific logic
} else {
    // Light mode specific logic
}
```

## Theme Mode Options

```swift
ThemeMode.system    // Follow macOS appearance
ThemeMode.light     // Always light
ThemeMode.dark      // Always dark
```

## Changing Theme Programmatically

```swift
ThemeManager.shared.themeMode = .dark
```

## Common Patterns

### Conditional Opacity
```swift
.opacity(ThemeManager.shared.isDarkMode ? 0.3 : 0.1)
```

### Adaptive Shadows
```swift
.shadow(color: AppTheme.dropdownShadow, radius: 8)
```

### Hover States
```swift
.background(isHovered ? AppTheme.sidebarItemHover : Color.clear)
```

### Active States
```swift
.background(isActive ? AppTheme.sidebarItemActive : Color.clear)
```

## Do's and Don'ts

### ✅ Do
- Use `AppTheme` properties for all colors
- Test your UI in both light and dark modes
- Ensure text has sufficient contrast
- Use semantic color names (textPrimary, not gray333)

### ❌ Don't
- Hardcode hex colors directly in views
- Use `.white` or `.black` (use AppTheme equivalents)
- Assume colors will look the same in both modes
- Mix AppTheme and hardcoded colors

## Testing Your Changes

1. Build and run the app
2. Open Settings (⌘,)
3. Toggle between Light and Dark modes
4. Verify all UI elements adapt correctly
5. Check text contrast and readability

## Color Contrast Guidelines

- Primary text: 4.5:1 minimum contrast ratio
- Secondary text: 3:1 minimum contrast ratio
- UI components: 3:1 minimum contrast ratio

All `AppTheme` colors meet these requirements in both modes.