# KeepJoy Localization Guide

## Overview
Your app now uses **Flutter's official localization system** (similar to what Duolingo uses), which is professional and scalable.

## How It Works

### 1. Translation Files (ARB format)
All translations are stored in `lib/l10n/`:
- `app_en.arb` - English translations
- `app_zh.arb` - Chinese translations (Simplified)

### 2. Auto-Generated Code
Flutter automatically generates type-safe localization code:
- `lib/l10n/app_localizations.dart` - Main localization class
- `lib/l10n/app_localizations_en.dart` - English implementation
- `lib/l10n/app_localizations_zh.dart` - Chinese implementation

**⚠️ Never edit these generated files manually!**

## How to Use in Your Code

### Basic Usage
```dart
import 'package:keepjoy_app/l10n/app_localizations.dart';

Widget build(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;

  return Text(l10n.quickDeclutterTitle); // Shows "Quick Declutter" or "快速整理"
}
```

### With Parameters
```dart
// In ARB file:
// "addedItemsViaQuickDeclutter": "Added {count} item(s) via Quick Declutter."

final message = l10n.addedItemsViaQuickDeclutter(5);
// English: "Added 5 item(s) via Quick Declutter."
// Chinese: "已通过快速整理添加5件物品。"
```

## Adding New Translations

### Step 1: Add to ARB files

**English** (`lib/l10n/app_en.arb`):
```json
{
  "myNewKey": "Hello World",
  "@myNewKey": {
    "description": "A greeting message"
  }
}
```

**Chinese** (`lib/l10n/app_zh.arb`):
```json
{
  "myNewKey": "你好世界"
}
```

### Step 2: Regenerate localization files
```bash
flutter gen-l10n
```
or simply run:
```bash
flutter run
```
(it will auto-generate on build)

### Step 3: Use in your code
```dart
final l10n = AppLocalizations.of(context)!;
Text(l10n.myNewKey)
```

## Testing Different Languages

### Change Phone Language
1. Go to device Settings
2. Change language to Chinese or English
3. Restart the app

### Force a Specific Locale (for testing)
In `main.dart`, you can temporarily force a locale:
```dart
MaterialApp(
  locale: const Locale('zh'), // Force Chinese
  // or
  locale: const Locale('en'), // Force English
  ...
)
```

## Available Translation Keys

Here are all the translation keys currently available:

### General
- `appTitle`, `home`, `items`, `memories`, `insights`
- `goodEvening`, `coreModules`, `joyfulMemories`, `viewAll`

### Quick Declutter
- `quickDeclutter`, `quickDeclutterTitle`
- `finish`, `captureItem`, `addThisItem`
- `itemsAdded`, `step1CaptureItem`, `step1Description`, `step2ReviewDetails`
- `itemName`, `category`, `identifyingItem`, `unnamedItem`, `itemAdded`
- `addedItemsViaQuickDeclutter` (with count parameter)
- `couldNotAccessCamera`

### Categories
- `categoryClothes`, `categoryBooks`, `categoryPapers`
- `categoryMiscellaneous`, `categorySentimental`, `categoryBeauty`

### Quick Sweep
- `quickSweep`, `quickSweepTimer`
- `activeQuickSweep`, `resume`, `minimize`, `complete`
- `pickAnArea`, `livingRoom`, `bedroom`, `kitchen`, `homeOffice`, `garage`
- `customArea`, `nameYourArea`, `cancel`, `save`

### Stats & Insights
- `thisMonthProgress`, `itemsLetGo`, `sessions`, `spaceFreed`
- `secondHandTracker`, `viewDetails`
- `comingSoon`

## Benefits of This Approach

✅ **Type-safe** - Autocomplete and compile-time checks
✅ **Professional** - Industry standard (used by Google, Duolingo, etc.)
✅ **Scalable** - Easy to add more languages (just add `app_es.arb` for Spanish, etc.)
✅ **No hardcoded strings** - All text in one place
✅ **Parameter support** - Dynamic values in translations
✅ **Performance** - Optimized by Flutter

## Next Steps

To add more languages:
1. Create new ARB file (e.g., `app_es.arb` for Spanish)
2. Add the locale to `supportedLocales` in `main.dart`:
   ```dart
   supportedLocales: const [
     Locale('en'),
     Locale('zh'),
     Locale('es'), // Add Spanish
   ],
   ```
3. Run `flutter gen-l10n`

## Migration Complete! 🎉

Your old `localization.dart` helper is no longer needed and can be deleted.
