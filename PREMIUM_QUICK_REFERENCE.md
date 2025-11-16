# Premium Features - Quick Reference Card

## 🔒 How to Lock a Feature

### Option 1: Wrap Widget (Recommended)
```dart
PremiumLock(
  child: YourPremiumFeature(),
)
```

### Option 2: Check Before Navigation
```dart
if (await requirePremium(context)) {
  Navigator.push(context, MaterialPageRoute(
    builder: (_) => PremiumFeaturePage(),
  ));
}
```

### Option 3: Conditional Rendering
```dart
Consumer<SubscriptionProvider>(
  builder: (context, provider, _) {
    if (provider.isPremium) {
      return PremiumFeature();
    }
    return FreeFeature();
  },
)
```

## 🎨 UI Components

### Premium Button
```dart
PremiumButton(
  text: 'Export Data',
  icon: Icons.download,
  onTap: () => exportData(),
)
```

### Custom Lock UI
```dart
PremiumLock(
  child: AdvancedChart(),
  lockedChild: Container(
    child: Column(
      children: [
        Icon(Icons.lock),
        Text('Upgrade to view charts'),
      ],
    ),
  ),
)
```

### Premium Badge
```dart
if (!subscriptionProvider.isPremium)
  Container(
    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: Color(0xFFB794F6),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text('PRO', style: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    )),
  )
```

## ✅ Premium Checks

### Check Status (Reactive)
```dart
// In build method
final isPremium = Provider.of<SubscriptionProvider>(context).isPremium;
```

### Check Status (Non-Reactive)
```dart
final isPremium = Provider.of<SubscriptionProvider>(
  context, 
  listen: false,
).isPremium;
```

### Helper Function
```dart
final isPremium = await isPremiumUser(context);
```

## 📱 Where to Lock Features

### ✅ Features That Should Be Locked

1. **Memories Page** (`lib/features/memories/memories_page.dart`)
   ```dart
   // In navigation code
   if (await requirePremium(context)) {
     Navigator.push(context, MaterialPageRoute(
       builder: (_) => MemoriesPage(),
     ));
   }
   ```

2. **Export Button** (Profile page - already implemented)
   ```dart
   PremiumButton(
     text: l10n.exportData,
     icon: Icons.download,
     onTap: () => _exportData(context),
   )
   ```

3. **Annual/Monthly Reports** (`lib/features/insights/...`)
   ```dart
   PremiumLock(
     child: AnnualReportWidget(),
   )
   ```

4. **Advanced Charts** (Dashboard/Insights)
   ```dart
   Consumer<SubscriptionProvider>(
     builder: (context, provider, _) {
       if (provider.isPremium) {
         return AdvancedCharts();
       }
       return BasicSummary();
     },
   )
   ```

5. **Custom Reminders** (Settings)
   ```dart
   ListTile(
     title: Text('Custom Reminders'),
     trailing: Icon(Icons.lock_outlined),
     onTap: () async {
       if (await requirePremium(context)) {
         // Show custom reminder settings
       }
     },
   )
   ```

### 📂 Free Features (Don't Lock)
- Dashboard overview
- All declutter modes
- Items page (view all items)
- Resell page (basic tracking)
- Basic notifications
- Profile and settings

## 🎯 Common Patterns

### Pattern 1: Menu Item with Lock
```dart
ListTile(
  leading: Icon(Icons.analytics),
  title: Text('Advanced Analytics'),
  trailing: Consumer<SubscriptionProvider>(
    builder: (context, provider, _) {
      if (!provider.isPremium) {
        return Icon(Icons.lock_outlined, color: Color(0xFFB794F6));
      }
      return Icon(Icons.chevron_right);
    },
  ),
  onTap: () async {
    if (await requirePremium(context)) {
      Navigator.push(context, ...);
    }
  },
)
```

### Pattern 2: Feature Card with Lock Overlay
```dart
PremiumLock(
  child: Card(
    child: Column(
      children: [
        Text('Yearly Report'),
        Text('View your annual progress'),
      ],
    ),
  ),
)
```

### Pattern 3: Conditional Button
```dart
Consumer<SubscriptionProvider>(
  builder: (context, provider, _) {
    if (provider.isPremium) {
      return ElevatedButton(
        onPressed: () => showReport(),
        child: Text('View Report'),
      );
    }
    return OutlinedButton(
      onPressed: () => Navigator.push(context, 
        MaterialPageRoute(builder: (_) => PaywallPage()),
      ),
      child: Row(
        children: [
          Icon(Icons.lock),
          Text('Unlock Report'),
        ],
      ),
    );
  },
)
```

## 🚀 Next Steps

### Step 1: Lock Memories Page
File: `lib/features/memories/memories_page.dart` or navigation to it

```dart
// Before:
onTap: () {
  Navigator.push(context, MaterialPageRoute(
    builder: (_) => MemoriesPage(),
  ));
}

// After:
onTap: () async {
  if (await requirePremium(context)) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => MemoriesPage(),
    ));
  }
}
```

### Step 2: Lock Export (Already Done ✅)
The export functionality in the profile page already requires premium.

### Step 3: Lock Advanced Insights
Find charts/analytics widgets and wrap with `PremiumLock`:

```dart
PremiumLock(
  child: AdvancedChartWidget(),
)
```

### Step 4: Lock Custom Reminders
In reminder settings, check premium before showing advanced options:

```dart
if (await isPremiumUser(context)) {
  // Show custom reminder options
} else {
  // Show paywall
  await Navigator.push(context, MaterialPageRoute(
    builder: (_) => PaywallPage(),
  ));
}
```

### Step 5: Lock Session Recovery
In deep cleaning flow, check premium before allowing resume:

```dart
if (session.isInterrupted && await requirePremium(context)) {
  // Allow resume
}
```

## 💡 Tips

1. **Always import provider:**
   ```dart
   import 'package:provider/provider.dart';
   import '../providers/subscription_provider.dart';
   ```

2. **Use Consumer for reactive UI:**
   When premium status affects what's displayed, use `Consumer`

3. **Use listen: false for actions:**
   When checking premium for an action (not UI), use `listen: false`

4. **Test both states:**
   Test your app as both free and premium user

5. **Clear error messages:**
   When premium is required, show clear upgrade prompts

## 🔧 Debugging

### Check Current Status
```dart
final provider = Provider.of<SubscriptionProvider>(context, listen: false);
debugPrint('Is Premium: ${provider.isPremium}');
debugPrint('Is In Trial: ${provider.isInTrial}');
debugPrint('Billing Period: ${provider.billingPeriod}');
```

### Force Refresh
```dart
await Provider.of<SubscriptionProvider>(context, listen: false).refreshStatus();
```

### Check Offerings
```dart
final offerings = await SubscriptionService.getOfferings();
debugPrint('Available packages: ${offerings?.current?.availablePackages.length}');
```

## 📋 Checklist

- [ ] Memories page navigation locked
- [ ] Export button uses PremiumButton (already done)
- [ ] Advanced analytics locked
- [ ] Custom reminders locked
- [ ] Session recovery locked
- [ ] Reports (annual/monthly) locked
- [ ] All premium features show lock icon when not subscribed
- [ ] Tested purchase flow
- [ ] Tested restore flow
- [ ] Tested trial display

## 🎉 You're Ready!

Use these patterns throughout your app to lock premium features. The subscription system is fully implemented and ready to use!

