// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'KeepJoy';

  @override
  String get home => 'Home';

  @override
  String get items => 'Items';

  @override
  String get memories => 'Memories';

  @override
  String get insights => 'Insights';

  @override
  String get goodEvening => 'Good Evening';

  @override
  String get coreModules => 'Core Modules';

  @override
  String get joyfulMemories => 'Joyful Memories';

  @override
  String get viewAll => 'View All';

  @override
  String get quickDeclutter => 'Quick\nDeclutter';

  @override
  String get quickSweep => 'Quick\nSweep';

  @override
  String get joyDeclutter => 'Joy\nDeclutter';

  @override
  String get quickDeclutterTitle => 'Quick Declutter';

  @override
  String get finish => 'Finish';

  @override
  String get captureItem => 'Capture item';

  @override
  String get addThisItem => 'Add this item';

  @override
  String get itemsAdded => 'Items added';

  @override
  String get step1CaptureItem => 'Step 1 · Capture your item';

  @override
  String get step1Description =>
      'Take a photo so we can identify and organize it for you.';

  @override
  String get step2ReviewDetails => 'Step 2 · Review details';

  @override
  String get itemName => 'Item Name';

  @override
  String get category => 'Category';

  @override
  String get identifyingItem => 'Identifying item…';

  @override
  String get unnamedItem => 'Unnamed item';

  @override
  String get itemAdded => 'Item added.';

  @override
  String addedItemsViaQuickDeclutter(int count) {
    return 'Added $count item(s) via Quick Declutter.';
  }

  @override
  String get couldNotAccessCamera => 'Could not access camera.';

  @override
  String get categoryClothes => 'Clothes';

  @override
  String get categoryBooks => 'Books';

  @override
  String get categoryPapers => 'Papers';

  @override
  String get categoryMiscellaneous => 'Miscellaneous';

  @override
  String get categorySentimental => 'Sentimental';

  @override
  String get categoryBeauty => 'Beauty';

  @override
  String get activeQuickSweep => 'Active Quick Sweep';

  @override
  String get resume => 'Resume';

  @override
  String get pickAnArea => 'Pick an area';

  @override
  String get livingRoom => 'Living Room';

  @override
  String get bedroom => 'Bedroom';

  @override
  String get kitchen => 'Kitchen';

  @override
  String get homeOffice => 'Home Office';

  @override
  String get garage => 'Garage';

  @override
  String get customArea => 'Custom area…';

  @override
  String get nameYourArea => 'Name your area';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get quickSweepTimer => 'Quick Sweep';

  @override
  String get minimize => 'Minimize';

  @override
  String get complete => 'Complete';

  @override
  String get thisMonthProgress => 'This Month\'s Progress';

  @override
  String itemsLetGo(int count) {
    return 'Items let go: $count';
  }

  @override
  String sessions(int count) {
    return 'Sessions: $count';
  }

  @override
  String spaceFreed(String amount) {
    return 'Space freed: $amount m²';
  }

  @override
  String get secondHandTracker => 'Second-hand Tracker';

  @override
  String get viewDetails => 'View Details';

  @override
  String get joyDeclutterTitle => 'Joy Declutter';

  @override
  String get joyDeclutterCaptureTitle => 'Capture Item';

  @override
  String get nextStep => 'Next Step';

  @override
  String get doesItSparkJoy => 'Does this item spark joy?';

  @override
  String get joyQuestionDescription =>
      'Hold the item in your hands and ask yourself: Does this bring joy to my life?';

  @override
  String get keepItem => 'Yes, Keep It';

  @override
  String get letGoItem => 'No, Let It Go';

  @override
  String get itemKept =>
      'Item kept! This completes your Joy Declutter session.';

  @override
  String get selectLetGoRoute => 'How would you like to let go of this item?';

  @override
  String get routeResell => 'Resell';

  @override
  String get routeResellDescription => 'Sell to someone who will appreciate it';

  @override
  String get routeDonation => 'Donation';

  @override
  String get routeDonationDescription => 'Give to those in need';

  @override
  String get routeDiscard => 'Discard';

  @override
  String get routeDiscardDescription => 'Dispose of responsibly';

  @override
  String get routeRecycle => 'Recycle';

  @override
  String get routeRecycleDescription => 'Give materials new life';

  @override
  String get joyDeclutterComplete => 'Joy Declutter session complete!';

  @override
  String get itemLetGo => 'You\'ve chosen to let go of this item.';

  @override
  String comingSoon(String title) {
    return '$title — coming next';
  }
}
