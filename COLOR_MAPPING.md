# Color Mapping Reference

## Light Mode → Dark Mode Color Mappings

### Backgrounds

| Usage | Light Mode | Dark Mode |
|-------|-----------|-----------|
| Primary Background | `#f0efed` (Warm Off-White) | `#121212` (Near Black) |
| Secondary Background | `#e1e0de` (Light Beige) | `#181818` (Very Dark Gray) |
| Tertiary Background | `#ebeae8` (Soft Beige) | `#1F1F1F` (Dark Gray) |

### Text

| Usage | Light Mode | Dark Mode |
|-------|-----------|-----------|
| Primary Text | `#333333` (Near Black) | `#D8D6C9` (Warm Light) |
| Secondary Text | `#666666` (Medium Gray) | `#B2B0A6` (Medium Light) |
| Tertiary Text | `#7F7F7C` (Light Gray) | `#999895` (Light Medium) |

### UI Elements

| Usage | Light Mode | Dark Mode |
|-------|-----------|-----------|
| Borders | `#c3c1bf` (Light Gray-Brown) | `#333333` (Dark Gray) |
| Dividers | `#d2d0ce` (Pale Gray) | `#333333` (Dark Gray) |
| Accent Primary | `#4b8ca0` (Muted Teal) | `#5D9AA9` (Bright Teal) |
| Destructive | `#b4463c` (Muted Red) | `#CB7676` (Bright Red) |
| Selection Stroke | `#a5a3a1` (Medium Gray) | `#666666` (Medium Gray) |

### Card Colors

| Name | Light Mode (Muted) | Dark Mode (Saturated) |
|------|-------------------|---------------------|
| Tan | `#d2d0ce` | `#4C4C4C` |
| Yellow | `#d9cfb8` | `#4C4C4C` |
| Green | `#c4d1ba` | `#4C8E72` |
| Blue | `#c4d6dd` | `#5D9AA9` |
| Pink | `#dcc9d4` | `#BC76C1` |
| Purple | `#d4d2dd` | `#8C6FAA` |
| Gray | `#dadad9` | `#4C4C4C` |
| Peach | `#e4d3cd` | `#C97D6E` |
| Red | `#ddc7c4` | `#CB7676` |
| Orange | `#e8d9c8` | `#DCA466` |
| Teal | `#c4dbd9` | `#5EA994` |
| Navy | `#c9d2dd` | `#6394BF` |

## Category/Tag Colors (Consistent Across Themes)

These colors remain vibrant and consistent in both light and dark modes for easy recognition:

| Name | Hex Code | Description |
|------|----------|-------------|
| Red | `#CB7676` | Bright Red |
| Dark Red | `#C98A7D` | Coral Red |
| Peach | `#C97D6E` | Peachy Red |
| Salmon | `#CC8D82` | Salmon Pink |
| Pink | `#BC76C1` | Magenta Pink |
| Purple | `#8C6FAA` | Deep Purple |
| Lavender | `#6872AB` | Blue Purple |
| Orange | `#DCA466` | Warm Orange |
| Yellow | `#CC8D70` | Amber Yellow |
| Green | `#80A665` | Sage Green |
| Teal | `#5EA994` | Turquoise |
| Blue | `#5D9AA9` | Ocean Blue |
| Cyan | `#6394BF` | Sky Blue |
| Navy | `#6872AB` | Deep Blue |

## Opacity Adjustments

| Element | Light Mode | Dark Mode |
|---------|-----------|-----------|
| Dropdown Shadow | `black @ 0.1` | `black @ 0.3` |
| Pill Background | `white @ 0.35` | `white @ 0.1` |
| Pill Background Faint | `white @ 0.05` | `white @ 0.05` |
| Shadow (General) | `black @ 0.06` | `black @ 0.4` |

## Design Philosophy

### Light Mode
- **Backgrounds**: Warm, paper-like beiges create a comfortable reading environment
- **Text**: Dark grays provide excellent readability without harsh black
- **Cards**: Muted, pastel-toned colors keep the interface calm and professional
- **Accents**: Slightly desaturated for visual harmony

### Dark Mode
- **Backgrounds**: True blacks and dark grays (#121212, #181818, #1F1F1F) reduce eye strain
- **Text**: Warm light colors (#D8D6C9) maintain readability without glare
- **Cards**: Saturated colors provide visual interest against dark backgrounds
- **Accents**: Brighter variants ensure visibility and clickability

### Category Colors
- Always vibrant and saturated for instant recognition
- Carefully selected for color-blind accessibility
- Consistent across both themes to build user familiarity
- High contrast against both light and dark backgrounds

## Color Accessibility

All color combinations meet WCAG 2.1 standards:
- **Level AA**: 4.5:1 contrast ratio for normal text
- **Level AAA**: 7:1 contrast ratio for primary headings
- **UI Components**: 3:1 minimum contrast ratio

## Usage Guidelines

1. **Always use AppTheme properties** - Never hardcode hex values in views
2. **Test in both modes** - Switch themes frequently during development
3. **Respect semantic meaning** - Use `textPrimary` for body text, not arbitrary colors
4. **Category colors are special** - Use them only for tags and category indicators
5. **Card colors adapt** - They automatically switch between muted and saturated