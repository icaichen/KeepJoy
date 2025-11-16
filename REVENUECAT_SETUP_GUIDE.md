# RevenueCat Subscription Setup Guide

## ✅ Implementation Complete!

Your KeepJoy app now has a fully functional subscription system using RevenueCat's latest API (v7.3.1).

---

## 📋 What Was Implemented

### 1. **Dependencies Added** ✓
- `purchases_flutter: ^7.3.1` - Latest RevenueCat SDK
- `provider: ^6.1.2` - State management for subscription status

### 2. **Files Created** ✓

#### Configuration
- **`lib/config/revenuecat_config.dart`**
  - API keys for iOS and Android
  - Product IDs and entitlement configuration
  - **⚠️ ACTION REQUIRED:** Replace placeholder API keys with your actual keys from RevenueCat dashboard

#### Services
- **`lib/services/subscription_service.dart`**
  - RevenueCat initialization
  - Check premium status
  - Fetch offerings
  - Purchase and restore purchases
  - Get subscription details
  - Uses latest RevenueCat API with proper error handling

#### State Management
- **`lib/providers/subscription_provider.dart`**
  - Global subscription state management
  - Real-time listener for subscription changes
  - Automatically updates UI when subscription status changes

#### UI
- **`lib/ui/paywall/paywall_page.dart`**
  - Beautiful paywall with monthly/annual options
  - Shows trial information
  - Automatic price fetching from stores
  - Restore purchases button
  - Loading and error states

### 3. **Files Updated** ✓

- **`lib/main.dart`**
  - RevenueCat initialization on app startup
  - Wrapped app with SubscriptionProvider
  - Upgrade dialog navigates to paywall

- **`lib/services/premium_access_service.dart`**
  - Now checks both trial AND RevenueCat subscription

- **`lib/features/profile/profile_page.dart`**
  - Shows real-time subscription status
  - Premium active card (with expiry date)
  - Upgrade card (when not premium)
  - Tappable to open paywall

---

## 🔧 Setup Steps (Required Before Testing)

### Step 1: RevenueCat Dashboard Setup

1. **Create RevenueCat Account**
   - Go to https://app.revenuecat.com
   - Sign up and create a new project

2. **Get API Keys**
   - Navigate to: **Project Settings → API Keys**
   - Copy your iOS and Android API keys
   - Update `lib/config/revenuecat_config.dart`:
     ```dart
     static const String iosApiKey = 'YOUR_IOS_API_KEY_HERE';
     static const String androidApiKey = 'YOUR_ANDROID_API_KEY_HERE';
     ```

3. **Create Products in App Store Connect / Google Play Console**

   **iOS (App Store Connect):**
   - Go to App Store Connect → Your App → Features → In-App Purchases
   - Create two **Auto-Renewable Subscriptions**:
     - Product ID: `keepjoy_premium_monthly`
       - Duration: 1 month
       - Free Trial: 7 days
     - Product ID: `keepjoy_premium_yearly`
       - Duration: 1 year
       - Free Trial: 7 days

   **Android (Google Play Console):**
   - Go to Play Console → Your App → Monetize → Products → Subscriptions
   - Create two subscriptions with same IDs:
     - `keepjoy_premium_monthly`
     - `keepjoy_premium_yearly`
     - Add 7-day free trial to both

4. **Configure RevenueCat**
   - In RevenueCat dashboard:
     - **Entitlements:** Create entitlement called `premium`
     - **Offerings:** Create an offering called `default`
     - **Packages:** Add two packages to the `default` offering:
       - `$rc_monthly` → `keepjoy_premium_monthly`
       - `$rc_annual` → `keepjoy_premium_yearly`

5. **Link App Store / Play Console**
   - RevenueCat → Project Settings → Apps
   - Add your iOS app (Bundle ID)
   - Add your Android app (Package name)
   - Enter your shared secrets / service account credentials

### Step 2: iOS Capabilities

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner target
3. Go to **Signing & Capabilities**
4. Click **+ Capability**
5. Add **In-App Purchase**

### Step 3: Test with Sandbox

**iOS:**
- Settings → App Store → Sandbox Account → Add test user
- Run app and test purchases

**Android:**
- Google Play Console → Internal testing
- Add testers and install via internal testing track

---

## 🎨 UI Features

### Profile Page
- **Free User:** Shows "Upgrade to Premium" card with star icon
- **Premium User:** Shows gradient card with:
  - "Premium Active" or "Trial Active"
  - Renewal date
  - Tap to manage subscription

### Paywall
- Clean, modern design
- Lists all premium features with emojis
- Shows both monthly and annual options
- Annual marked as "BEST VALUE"
- Displays prices from App Store/Play Store
- Shows "Start 7-Day Free Trial" button
- Restore purchases button
- Terms and conditions text

### Premium Access
- When user tries premium feature without subscription:
  - Shows dialog explaining premium requirement
  - "Upgrade to Premium" button opens paywall
  - After purchase, feature unlocks immediately

---

## 🧪 Testing Checklist

- [ ] Replace API keys in `revenuecat_config.dart`
- [ ] Create products in App Store Connect / Play Console
- [ ] Configure RevenueCat dashboard (Entitlements, Offerings, Packages)
- [ ] Enable In-App Purchase capability in Xcode
- [ ] Test purchase flow with sandbox account
- [ ] Test free trial activation
- [ ] Test subscription renewal
- [ ] Test restore purchases
- [ ] Test premium feature access
- [ ] Test subscription expiry

---

## 📱 How It Works

### Flow Diagram
```
App Launch
    ↓
RevenueCat.configure()
    ↓
SubscriptionProvider initialized
    ↓
Listens to customer info updates
    ↓
UI automatically updates
```

### Premium Check
```
User tries premium feature
    ↓
PremiumAccessService.hasPremiumAccess()
    ↓
Check trial (TrialService)
    ↓
Check subscription (SubscriptionService)
    ↓
Return true/false
```

### Purchase Flow
```
User taps "Upgrade to Premium"
    ↓
PaywallPage opens
    ↓
Loads offerings from RevenueCat
    ↓
User selects package
    ↓
Taps "Subscribe Now"
    ↓
Native purchase flow
    ↓
RevenueCat validates receipt
    ↓
Provider updates
    ↓
UI shows premium active
```

---

## 🔍 Key Files Reference

### Check Premium Status Anywhere
```dart
import 'package:provider/provider.dart';
import 'package:keepjoy_app/providers/subscription_provider.dart';

// In widget:
final isPremium = context.watch<SubscriptionProvider>().isPremium;

// Or using service:
final isPremium = await SubscriptionService.isPremium();
```

### Open Paywall
```dart
import 'package:keepjoy_app/ui/paywall/paywall_page.dart';

Navigator.of(context).push(
  MaterialPageRoute(builder: (_) => const PaywallPage()),
);
```

### Lock Premium Features
```dart
import 'package:keepjoy_app/services/premium_access_service.dart';

final hasPremium = await PremiumAccessService.hasPremiumAccess();
if (!hasPremium) {
  // Show upgrade dialog
  return;
}
// Allow feature access
```

---

## 🐛 Troubleshooting

### Build Errors

**If you get SubscriptionPeriod ambiguity:**
- This was a known issue with older RevenueCat versions
- We're using v7.3.1 which should not have this issue
- If it persists, the Podfile is clean (no custom patches needed)

**If purchases_flutter not found:**
```bash
cd ios
pod deintegrate
rm -rf Pods Podfile.lock
pod install
cd ..
flutter clean
flutter pub get
```

### Runtime Errors

**"Invalid API Key":**
- Check that you replaced placeholder keys in `revenuecat_config.dart`
- Verify keys in RevenueCat dashboard match

**"No offerings available":**
- Ensure products are created in App Store Connect / Play Console
- Check RevenueCat dashboard configuration
- Verify product IDs match exactly

**Purchases not working:**
- Ensure In-App Purchase capability is enabled
- Use sandbox test account on iOS
- Check app is signed correctly

---

## 📚 Additional Resources

- [RevenueCat Documentation](https://docs.revenuecat.com/docs)
- [Flutter SDK Reference](https://pub.dev/packages/purchases_flutter)
- [App Store Connect Guide](https://developer.apple.com/app-store-connect/)
- [Google Play Console Guide](https://support.google.com/googleplay/android-developer)

---

## 🎉 You're All Set!

Once you complete the setup steps above and replace the API keys, your subscription system is ready to go!

The implementation uses:
- ✅ Latest RevenueCat API (v7.3.1)
- ✅ Proper error handling
- ✅ Real-time subscription updates
- ✅ Beautiful, modern UI
- ✅ Trial + subscription support
- ✅ Cross-platform (iOS & Android)

**Need help?** Check the troubleshooting section above or refer to RevenueCat's excellent documentation.

