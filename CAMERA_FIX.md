# Camera Permission Fix - Quick Declutter

## Problem
The "拍摄物品" (Capture item) button wasn't triggering the camera because **camera permissions were missing** from both iOS and Android configurations.

## What Was Fixed

### ✅ iOS Permissions Added
**File: [ios/Runner/Info.plist](ios/Runner/Info.plist#L48-L53)**

Added three camera-related permissions:
- `NSCameraUsageDescription` - Camera access
- `NSPhotoLibraryUsageDescription` - Photo library access
- `NSMicrophoneUsageDescription` - Microphone access (for videos)

**Localized Permission Messages:**
- English: [ios/Runner/en.lproj/InfoPlist.strings](ios/Runner/en.lproj/InfoPlist.strings)
- Chinese: [ios/Runner/zh-Hans.lproj/InfoPlist.strings](ios/Runner/zh-Hans.lproj/InfoPlist.strings)

### ✅ Android Permissions Added
**File: [android/app/src/main/AndroidManifest.xml](android/app/src/main/AndroidManifest.xml#L2-L8)**

Added:
- `CAMERA` permission
- `READ_EXTERNAL_STORAGE` permission
- `WRITE_EXTERNAL_STORAGE` permission (for Android ≤ 12)
- Camera hardware features (marked as optional)

## How to Test

### Method 1: Clean Build (Recommended)
```bash
# For iOS
flutter clean
flutter pub get
flutter run

# The app will request camera permission on first launch
```

### Method 2: Uninstall & Reinstall
If you've already installed the app:
1. **Uninstall the app** from your device/simulator
2. Run `flutter run` again
3. When you tap "拍摄物品", iOS/Android will show a permission dialog
4. Tap "Allow" or "允许"

### What You Should See

#### iOS Permission Dialog (English):
```
"KeepJoy" Would Like to Access the Camera
This app needs access to your camera to capture
photos of items for decluttering.

[Don't Allow]  [Allow]
```

#### iOS Permission Dialog (Chinese):
```
"KeepJoy"想访问您的相机
此应用需要访问您的相机来拍摄物品照片。

[不允许]  [允许]
```

#### Android Permission Dialog:
```
Allow KeepJoy to take pictures and record video?

[DENY]  [ALLOW]
```

## Troubleshooting

### If camera still doesn't work:

1. **Check device permissions:**
   - iOS: Settings → Privacy & Security → Camera → KeepJoy (should be ON)
   - Android: Settings → Apps → KeepJoy → Permissions → Camera (should be Allowed)

2. **Reset permissions:**
   - Uninstall the app completely
   - Run `flutter clean`
   - Reinstall with `flutter run`

3. **Check simulator/emulator:**
   - iOS Simulator: Simulator → I/O → Camera (should be enabled)
   - Android Emulator: Make sure it has camera hardware enabled

### Error Messages

If you see "无法打开相机" (Could not access camera):
- Permission was denied by user
- Go to Settings and manually enable camera permission
- Restart the app

## Files Modified

1. ✅ [ios/Runner/Info.plist](ios/Runner/Info.plist)
2. ✅ [android/app/src/main/AndroidManifest.xml](android/app/src/main/AndroidManifest.xml)
3. ✅ [ios/Runner/en.lproj/InfoPlist.strings](ios/Runner/en.lproj/InfoPlist.strings) (new)
4. ✅ [ios/Runner/zh-Hans.lproj/InfoPlist.strings](ios/Runner/zh-Hans.lproj/InfoPlist.strings) (new)

## Next Steps

1. **Run the app:**
   ```bash
   flutter run
   ```

2. **Test the flow:**
   - Go to Home screen
   - Tap "Quick Declutter" (快速整理)
   - Tap "拍摄物品" button
   - **You should see a permission request**
   - Allow camera access
   - Camera should open!

3. **Take a photo** and verify:
   - Photo appears in preview
   - Google ML Kit identifies the object
   - Item name auto-fills
   - Category is suggested

## Status: ✅ FIXED

The camera should now work properly on both iOS and Android!
