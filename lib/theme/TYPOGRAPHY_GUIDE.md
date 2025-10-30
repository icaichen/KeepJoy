# KeepJoy Typography System Guide

A comprehensive guide to using the KeepJoy typography system for consistent, readable, and beautiful text across both Chinese and English.

## Table of Contents
- [Quick Start](#quick-start)
- [Font Families](#font-families)
- [Text Styles Reference](#text-styles-reference)
- [Usage Examples](#usage-examples)
- [Best Practices](#best-practices)
- [Migration Guide](#migration-guide)

---

## Quick Start

### Import the Typography
```dart
import 'package:keepjoy_app/theme/typography.dart';
```

### Use Theme Text Styles (Recommended)
```dart
// Use Material theme text styles (automatically respects theme)
Text(
  'Welcome',
  style: Theme.of(context).textTheme.headlineLarge,
)
```

### Use Custom Text Styles
```dart
// Use custom predefined styles
Text(
  'Good Morning',
  style: AppTypography.greeting,
)
```

---

## Font Families

### Primary Font: SF Pro
- **SF Pro Display**: Used for large text (≥20pt) - titles, headers, hero content
- **SF Pro Text**: Used for small text (<20pt) - body, labels, descriptions

### Chinese Fallbacks (in order)
1. **PingFang SC** - Apple's modern Chinese font (iOS/macOS)
2. **Source Han Sans CN** - Adobe's open-source Pan-CJK font
3. **Noto Sans SC** - Google's Pan-CJK font
4. **Roboto** - Android fallback
5. **Inter** - Web fallback

The system automatically selects the best available font for Chinese characters while maintaining SF Pro for English.

---

## Text Styles Reference

### Material Theme Styles

#### Display Styles (Hero Content)
Use for app name, splash screens, major section headers.

| Style | Size | Weight | Use Case |
|-------|------|--------|----------|
| `displayLarge` | 48pt | Bold (700) | App splash, hero titles |
| `displayMedium` | 36pt | Bold (700) | Major section headers |
| `displaySmall` | 28pt | SemiBold (600) | Sub-headers |

```dart
Text(
  'KeepJoy',
  style: Theme.of(context).textTheme.displayLarge,
)
```

#### Headline Styles (Section Headers)
Use for screen titles, card headers, section dividers.

| Style | Size | Weight | Use Case |
|-------|------|--------|----------|
| `headlineLarge` | 32pt | SemiBold (600) | Screen titles |
| `headlineMedium` | 24pt | SemiBold (600) | Card headers |
| `headlineSmall` | 20pt | SemiBold (600) | Section headers |

```dart
Text(
  '本月成就', // Monthly Achievements
  style: Theme.of(context).textTheme.headlineMedium,
)
```

#### Title Styles (Emphasized Text)
Use for list item titles, dialog headers, emphasized labels.

| Style | Size | Weight | Use Case |
|-------|------|--------|----------|
| `titleLarge` | 22pt | SemiBold (600) | Dialog titles, large cards |
| `titleMedium` | 18pt | Medium (500) | List items, small cards |
| `titleSmall` | 16pt | Medium (500) | Subtle emphasis |

```dart
Text(
  '心动整理', // Joy Declutter
  style: Theme.of(context).textTheme.titleMedium,
)
```

#### Body Styles (Regular Content)
Use for article text, descriptions, multi-line content.

| Style | Size | Weight | Line Height | Use Case |
|-------|------|--------|-------------|----------|
| `bodyLarge` | 16pt | Regular (400) | 1.5 | Long paragraphs |
| `bodyMedium` | 14pt | Regular (400) | 1.5 | Descriptions |
| `bodySmall` | 12pt | Regular (400) | 1.4 | Captions, metadata |

```dart
Text(
  '共处理 42 件物品，释放空间', // Processed 42 items
  style: Theme.of(context).textTheme.bodyMedium,
)
```

#### Label Styles (Buttons & Compact Text)
Use for button text, tabs, chips, badges.

| Style | Size | Weight | Use Case |
|-------|------|--------|----------|
| `labelLarge` | 14pt | Medium (500) | Primary buttons |
| `labelMedium` | 12pt | Medium (500) | Secondary buttons, chips |
| `labelSmall` | 10pt | Medium (500) | Tiny labels, badges |

```dart
ElevatedButton(
  onPressed: () {},
  child: Text(
    '开始整理', // Start Organizing
    style: Theme.of(context).textTheme.labelLarge,
  ),
)
```

---

### Custom Predefined Styles

For common UI patterns, use these custom styles:

| Style | Description | Example Usage |
|-------|-------------|---------------|
| `AppTypography.greeting` | Large greeting text | "Good Morning" |
| `AppTypography.heroTitle` | Hero section titles | "Continue Your Joy Journey" |
| `AppTypography.sectionHeader` | Section headers | "Start Declutter" |
| `AppTypography.cardTitle` | Card titles | "Monthly Progress" |
| `AppTypography.subtitle` | Secondary info | Taglines, descriptions |
| `AppTypography.caption` | Smallest text | Timestamps, metadata |
| `AppTypography.metricValue` | Large numbers | "42", "¥128" |
| `AppTypography.metricLabel` | Metric labels | "items", "yuan" |
| `AppTypography.buttonText` | Button text on gradients | White text on colored buttons |
| `AppTypography.quote` | Italic quotes | Daily inspiration quotes |
| `AppTypography.quoteAttribution` | Quote authors | "— Marie Kondo" |

```dart
// Greeting
Text(
  isChinese ? '早上好' : 'Good Morning',
  style: AppTypography.greeting,
)

// Hero Title
Text(
  'Continue Your Joy Journey',
  style: AppTypography.heroTitle,
)

// Metric Display
Column(
  children: [
    Text('42', style: AppTypography.metricValue.white),
    Text('件物品', style: AppTypography.metricLabel.white),
  ],
)

// Quote
Text(
  '"Less is more."',
  style: AppTypography.quote.black87,
)
```

---

## Usage Examples

### Example 1: Insights Screen Header

```dart
// Large title that fades out
Text(
  summaryTitle,
  style: const TextStyle(
    fontSize: 46,
    fontWeight: FontWeight.w800,
    color: Colors.white,
    letterSpacing: -0.6,
    height: 1.0,
  ),
)

// ✅ BETTER: Use custom style
Text(
  summaryTitle,
  style: Theme.of(context).textTheme.displayLarge?.copyWith(
    fontSize: 46,
    fontWeight: FontWeight.w800,
    color: Colors.white,
    letterSpacing: -0.6,
    height: 1.0,
  ),
)
```

### Example 2: Metric Cards

```dart
// Current implementation
Text(
  '42',
  style: const TextStyle(
    fontSize: 42,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    height: 1.0,
  ),
)

// ✅ BETTER: Use AppTypography
Text(
  '42',
  style: AppTypography.metricValue.white,
)
```

### Example 3: Section Headers

```dart
// Current implementation
Text(
  l10n.startDeclutter,
  style: const TextStyle(
    fontFamily: 'SF Pro Display',
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: Color(0xDE000000),
    letterSpacing: 0,
    height: 1.0,
  ),
)

// ✅ BETTER: Use AppTypography
Text(
  l10n.startDeclutter,
  style: AppTypography.sectionHeader,
)
```

### Example 4: Dynamic Color Styling

```dart
// Using extension methods
Text(
  'Primary Text',
  style: Theme.of(context).textTheme.bodyLarge?.bold.primary(context),
)

// Using helper methods
Text(
  'Colored Text',
  style: AppTypography.withColor(
    AppTypography.cardTitle,
    Theme.of(context).colorScheme.primary,
  ),
)
```

---

## Best Practices

### ✅ DO

1. **Use theme text styles** for most text
   ```dart
   style: Theme.of(context).textTheme.bodyMedium
   ```

2. **Use custom styles** for common patterns
   ```dart
   style: AppTypography.greeting
   ```

3. **Use extension methods** for modifications
   ```dart
   style: AppTypography.cardTitle.white
   ```

4. **Consider line height** for Chinese text
   - Chinese characters need slightly more line height (1.4-1.6)
   - Our system defaults are optimized for both languages

5. **Use appropriate weights**
   - Chinese fonts: avoid weights below 400 (too thin)
   - Chinese fonts: limit to 400, 500, 600, 700

### ❌ DON'T

1. **Don't hardcode font families** everywhere
   ```dart
   // ❌ BAD
   style: TextStyle(fontFamily: 'SF Pro Display')

   // ✅ GOOD
   style: Theme.of(context).textTheme.headlineLarge
   ```

2. **Don't create ad-hoc text styles** for common patterns
   ```dart
   // ❌ BAD: Creating one-off styles
   style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700)

   // ✅ GOOD: Use predefined styles
   style: AppTypography.greeting
   ```

3. **Don't ignore letter spacing for Chinese**
   - Chinese text typically needs `letterSpacing: 0`
   - English large titles benefit from negative letter spacing (-0.5 to -1.0)

4. **Don't use extreme font weights for Chinese**
   - Weights <400: too thin, hard to read
   - Weights >700: too bold, loses character detail

---

## Migration Guide

### Step 1: Replace Hardcoded Styles

**Before:**
```dart
Text(
  'Welcome',
  style: TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  ),
)
```

**After:**
```dart
Text(
  'Welcome',
  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
    color: Colors.black87,
  ),
)
```

### Step 2: Use Custom Styles for Common Patterns

**Before:**
```dart
Text(
  '早上好',
  style: TextStyle(
    fontFamily: 'SF Pro Display',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: Color(0xDE000000),
    letterSpacing: 0,
    height: 1.0,
  ),
)
```

**After:**
```dart
Text(
  '早上好',
  style: AppTypography.greeting,
)
```

### Step 3: Apply Colors with Extensions

**Before:**
```dart
Text(
  'Primary Text',
  style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Theme.of(context).colorScheme.primary,
  ),
)
```

**After:**
```dart
Text(
  'Primary Text',
  style: Theme.of(context).textTheme.bodyLarge?.bold.primary(context),
)
```

---

## Typography Testing Checklist

When implementing new UI:

- [ ] Large titles (>28pt) use Display styles or custom hero styles
- [ ] Section headers use Headline styles
- [ ] Body text uses Body styles with appropriate line height
- [ ] Buttons use Label styles
- [ ] Chinese text is readable at all sizes
- [ ] English text has appropriate letter spacing
- [ ] Text hierarchy is clear (size, weight, color differences)
- [ ] White text on colored backgrounds is legible
- [ ] Long paragraphs have sufficient line height (1.5+)

---

## Font Weight Reference

| Weight Name | Value | Use Case |
|-------------|-------|----------|
| Regular | 400 | Body text, descriptions |
| Medium | 500 | Emphasized labels, buttons |
| SemiBold | 600 | Headers, card titles |
| Bold | 700 | Hero titles, metrics |
| ExtraBold | 800 | Special emphasis (use sparingly) |

**Note:** For Chinese fonts, stick to 400-700 range for best readability.

---

## Color Opacity Reference

| Opacity | Hex | Use Case |
|---------|-----|----------|
| 87% | `0xDE000000` | Primary text (black87) |
| 54% | `0x8A000000` | Secondary text (black54) |
| 38% | `0x61000000` | Disabled text |
| 75% | `0xBFFFFFFF` | Secondary on dark (white75) |

---

## Questions?

For questions or suggestions about the typography system, refer to:
- Material Design 3 Typography: https://m3.material.io/styles/typography
- SF Pro Font Documentation: https://developer.apple.com/fonts/
- PingFang SC Guidelines: https://developer.apple.com/fonts/

---

**Last Updated:** 2025-10-30
**Version:** 1.0.0
