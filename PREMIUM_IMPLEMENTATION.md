r# KeepJoy Premium Implementation Guide

## Overview

KeepJoy uses RevenueCat for subscription management with a single Premium tier offering monthly and annual billing options.

## Architecture

### Core Components

1. **`SubscriptionProvider`** (`lib/providers/subscription_provider.dart`)
   - Global state management for premium status
   - Auto-refreshes on subscription changes
   - Provides: `isPremium`, `isInTrial`, `billingPeriod`, `expirationDate`, etc.

2. **`SubscriptionService`** (`lib/services/subscription_service.dart`)
   - Low-level RevenueCat SDK wrapper
   - Methods: `configure()`, `getOfferings()`, `purchasePackage()`, `restorePurchases()`, `isPremium()`

3. **`PaywallPage`** (`lib/ui/paywall/paywall_page.dart`)
   - Beautiful paywall UI with premium features list
   - Package selection (monthly/annual)
   - Trial display
   - Restore purchases button

4. **`PremiumLock` Widget** (`lib/widgets/premium_lock.dart`)
   - Reusable widget to lock features
   - Shows overlay with lock icon
   - Opens paywall on tap

## Configuration

### RevenueCat Setup

**File:** `lib/config/revenuecat_config.dart`

```dart
class RevenueCatConfig {
  static const String iosApiKey = 'your_ios_api_key';
  static const String androidApiKey = 'your_android_api_key';
  
  static const String defaultOfferingId = 'default';
  static const String premiumEntitlementId = 'premium';
}
```

### Product IDs

Configure these in App Store Connect and Google Play Console:

- **iOS:**
  - `keepjoy_premium_monthly`
  - `keepjoy_premium_yearly`

- **Android:**
  - `keepjoy_premium_monthly`
  - `keepjoy_premium_yearly`

### RevenueCat Dashboard

1. Create entitlement: `premium`
2. Create offering: `default`
3. Add packages:
   - Package identifier: `monthly` → Product: `keepjoy_premium_monthly`
   - Package identifier: `annual` → Product: `keepjoy_premium_yearly`

## Usage

### Check Premium Status

```dart
// Method 1: Using Provider (reactive)
Consumer<SubscriptionProvider>(
  builder: (context, subscriptionProvider, _) {
    if (subscriptionProvider.isPremium) {
      return PremiumFeature();
    }
    return UpgradeButton();
  },
)

// Method 2: Using helper function
final isPremium = await isPremiumUser(context);
if (isPremium) {
  // Show premium feature
}

// Method 3: Direct access (non-reactive)
final subscriptionProvider = Provider.of<SubscriptionProvider>(
  context,
  listen: false,
);
if (subscriptionProvider.isPremium) {
  // Do something
}
```

### Lock a Feature

```dart
// Simple lock with default overlay
PremiumLock(
  child: AdvancedAnalyticsWidget(),
)

// Custom locked UI
PremiumLock(
  child: AdvancedAnalyticsWidget(),
  lockedChild: Container(
    color: Colors.grey,
    child: Center(
      child: Text('Premium Feature'),
    ),
  ),
)

// Custom action on tap
PremiumLock(
  child: AdvancedAnalyticsWidget(),
  showPaywall: false,
  onLockTap: () {
    // Custom logic
    showDialog(...);
  },
)
```

### Premium Button

```dart
PremiumButton(
  text: 'Export Data',
  icon: Icons.download,
  onTap: () {
    // This only runs if user is premium
    exportData();
  },
)
```

### Require Premium Before Action

```dart
// Shows paywall if not premium, returns true if premium
final hasPremium = await requirePremium(context);
if (hasPremium) {
  // User is premium, proceed
  navigateToFeature();
}
```

## Feature Access Control

### Free Features
- All declutter modes (Quick, Joy, Deep Cleaning)
- Items page (all items)
- Resell page (tracking only, no export)
- Basic reminders (fixed frequency)
- Profile and settings

### Premium Features
- **Annual & Monthly Reports**
  - Detailed statistics and progress
  - Charts and visualizations
  
- **Memories Page**
  - Save and view precious moments
  - Photos and descriptions
  
- **Export Feature**
  - Export all data as JSON
  - Available in profile
  
- **Advanced Insights**
  - Deep analytics
  - Trend analysis
  - Custom charts
  
- **Custom Reminders**
  - Personalized reminder settings
  - Flexible scheduling
  
- **Session Recovery**
  - Resume interrupted sessions
  - Auto-save progress

## Implementation Examples

### Example 1: Lock Memories Page

```dart
// In bottom navigation or menu
if (await isPremiumUser(context)) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => MemoriesPage()),
  );
} else {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => PaywallPage()),
  );
}
```

### Example 2: Lock Export Button

```dart
PremiumButton(
  text: 'Export Data',
  icon: Icons.download,
  onTap: () async {
    await exportAllData();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Data exported successfully')),
    );
  },
)
```

### Example 3: Show Premium Badge in List

```dart
ListTile(
  title: Text('Annual Report'),
  trailing: Consumer<SubscriptionProvider>(
    builder: (context, provider, _) {
      if (!provider.isPremium) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Color(0xFFB794F6),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'PRO',
            style: TextStyle(
              fontSize: 10,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }
      return Icon(Icons.chevron_right);
    },
  ),
  onTap: () async {
    if (await requirePremium(context)) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AnnualReportPage()),
      );
    }
  },
)
```

### Example 4: Conditional Feature in Dashboard

```dart
Consumer<SubscriptionProvider>(
  builder: (context, subscriptionProvider, _) {
    final isPremium = subscriptionProvider.isPremium;
    
    return Column(
      children: [
        // Always show
        QuickDeclutterCard(),
        JoyDeclutterCard(),
        
        // Premium only
        if (isPremium) ...[
          AdvancedInsightsCard(),
          MemoriesPreviewCard(),
        ],
        
        // Locked for free users
        if (!isPremium)
          PremiumLock(
            child: AdvancedInsightsCard(),
          ),
      ],
    );
  },
)
```

## Profile Page Implementation

The profile page now shows:

### For Free Users:
- Upgrade card with "Upgrade to Premium" button
- Lists premium benefits
- Opens paywall on tap

### For Premium Users:
- Beautiful gradient card showing:
  - Premium status (with trial indicator if applicable)
  - Billing period (Monthly/Annual)
  - Renewal/expiration date
  - "Manage Subscription" button (opens paywall)

## Paywall Implementation

The paywall shows:
1. **Header:** "Unlock KeepJoy Premium"
2. **Feature List:** 6 premium features with icons
3. **Package Selection:** 
   - Cards for monthly and annual plans
   - Price from store (auto-formatted by locale)
   - Trial badge if applicable
   - "Best Value" badge on annual
4. **Purchase Button:** "Start Subscription"
5. **Restore Button:** For existing subscribers
6. **Terms:** Small text at bottom

## Testing

### Test Scenarios

1. **First Purchase:**
   - Open app → Navigate to premium feature
   - See paywall → Select package → Purchase
   - Verify premium status updates immediately
   - Verify access granted

2. **Trial Activation:**
   - Purchase with trial offer
   - Verify "Trial" badge shows in profile
   - Verify full access during trial

3. **Restore Purchases:**
   - Sign out and reinstall app
   - Go to paywall → Tap "Restore Purchases"
   - Verify subscription restored

4. **Subscription Expiration:**
   - Cancel subscription in store
   - Wait for expiration
   - Verify access revoked
   - Verify locked UI appears

5. **Offline Handling:**
   - Turn off network
   - Verify cached premium status works
   - Verify graceful error messages

## RevenueCat Sandbox Testing

### iOS:
1. Use sandbox tester account in App Store Connect
2. Sign in to Settings → App Store with sandbox account
3. Purchase in app (no charge)
4. Verify in RevenueCat dashboard

### Android:
1. Add test account in Google Play Console
2. Use test account on device
3. Purchase in app (no charge)
4. Verify in RevenueCat dashboard

## Troubleshooting

### "No offerings available"
- Check RevenueCat API keys in config
- Verify offerings configured in RevenueCat dashboard
- Check network connection
- Verify product IDs match exactly

### "Purchase failed"
- Check sandbox/production environment
- Verify product IDs are active in store
- Check RevenueCat project settings
- Review logs in RevenueCat dashboard

### Premium status not updating
- Call `subscriptionProvider.refreshStatus()` manually
- Check listener is set up in SubscriptionProvider
- Verify entitlement ID matches: `premium`

### Trial not showing
- Verify intro offer configured in store
- Check product.introPrice is not null
- Ensure 7-day free trial is set in store

## Best Practices

1. **Always use Provider for UI:** Don't call `SubscriptionService` directly in widgets
2. **Cache aggressively:** Provider caches status automatically
3. **Handle loading states:** Show loading indicators during purchase/restore
4. **Show trial prominently:** Users love free trials
5. **Clear error messages:** Guide users when purchases fail
6. **Test offline:** App should work with cached status
7. **Refresh after login:** Call `refreshStatus()` after authentication

## Migration from Trial System

If you have an existing trial system:

1. Remove `TrialService` and `PremiumAccessService`
2. Replace all `TrialService.hasPremiumAccess()` with `isPremiumUser(context)`
3. Replace all trial UI with `PremiumLock` widget
4. Update profile page to use `SubscriptionProvider`
5. Remove any hardcoded trial logic

## Summary

- **State:** `SubscriptionProvider` (global, reactive)
- **Service:** `SubscriptionService` (low-level API wrapper)
- **UI:** `PaywallPage` (purchase flow)
- **Widgets:** `PremiumLock`, `PremiumButton` (reusable components)
- **Config:** `RevenueCatConfig` (API keys)
- **Products:** `keepjoy_premium_monthly`, `keepjoy_premium_yearly`
- **Entitlement:** `premium`
- **Offering:** `default`

All premium checks should go through `SubscriptionProvider.isPremium` for consistency and reactivity.

