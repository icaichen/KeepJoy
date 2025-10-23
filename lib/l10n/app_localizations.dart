import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'KeepJoy'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @memories.
  ///
  /// In en, this message translates to:
  /// **'Memories'**
  String get memories;

  /// No description provided for @insights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insights;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;

  /// No description provided for @coreModules.
  ///
  /// In en, this message translates to:
  /// **'Core Modules'**
  String get coreModules;

  /// No description provided for @joyfulMemories.
  ///
  /// In en, this message translates to:
  /// **'Joyful Memories'**
  String get joyfulMemories;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @quickDeclutter.
  ///
  /// In en, this message translates to:
  /// **'Quick\nDeclutter'**
  String get quickDeclutter;

  /// No description provided for @quickSweep.
  ///
  /// In en, this message translates to:
  /// **'Quick\nSweep'**
  String get quickSweep;

  /// No description provided for @joyDeclutter.
  ///
  /// In en, this message translates to:
  /// **'Joy\nDeclutter'**
  String get joyDeclutter;

  /// No description provided for @quickDeclutterTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Declutter'**
  String get quickDeclutterTitle;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @captureItem.
  ///
  /// In en, this message translates to:
  /// **'Capture item'**
  String get captureItem;

  /// No description provided for @addThisItem.
  ///
  /// In en, this message translates to:
  /// **'Add this item'**
  String get addThisItem;

  /// No description provided for @itemsAdded.
  ///
  /// In en, this message translates to:
  /// **'Items added'**
  String get itemsAdded;

  /// No description provided for @step1CaptureItem.
  ///
  /// In en, this message translates to:
  /// **'Step 1 · Capture your item'**
  String get step1CaptureItem;

  /// No description provided for @step1Description.
  ///
  /// In en, this message translates to:
  /// **'Take a photo so we can identify and organize it for you.'**
  String get step1Description;

  /// No description provided for @step2ReviewDetails.
  ///
  /// In en, this message translates to:
  /// **'Step 2 · Review details'**
  String get step2ReviewDetails;

  /// No description provided for @itemName.
  ///
  /// In en, this message translates to:
  /// **'Item Name'**
  String get itemName;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @identifyingItem.
  ///
  /// In en, this message translates to:
  /// **'Identifying item…'**
  String get identifyingItem;

  /// No description provided for @unnamedItem.
  ///
  /// In en, this message translates to:
  /// **'Unnamed item'**
  String get unnamedItem;

  /// No description provided for @itemAdded.
  ///
  /// In en, this message translates to:
  /// **'Item added.'**
  String get itemAdded;

  /// Message shown when items are added via Quick Declutter
  ///
  /// In en, this message translates to:
  /// **'Added {count} item(s) via Quick Declutter.'**
  String addedItemsViaQuickDeclutter(int count);

  /// No description provided for @couldNotAccessCamera.
  ///
  /// In en, this message translates to:
  /// **'Could not access camera.'**
  String get couldNotAccessCamera;

  /// No description provided for @categoryClothes.
  ///
  /// In en, this message translates to:
  /// **'Clothes'**
  String get categoryClothes;

  /// No description provided for @categoryBooks.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get categoryBooks;

  /// No description provided for @categoryPapers.
  ///
  /// In en, this message translates to:
  /// **'Papers'**
  String get categoryPapers;

  /// No description provided for @categoryMiscellaneous.
  ///
  /// In en, this message translates to:
  /// **'Miscellaneous'**
  String get categoryMiscellaneous;

  /// No description provided for @categorySentimental.
  ///
  /// In en, this message translates to:
  /// **'Sentimental'**
  String get categorySentimental;

  /// No description provided for @categoryBeauty.
  ///
  /// In en, this message translates to:
  /// **'Beauty'**
  String get categoryBeauty;

  /// No description provided for @activeQuickSweep.
  ///
  /// In en, this message translates to:
  /// **'Active Quick Sweep'**
  String get activeQuickSweep;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @pickAnArea.
  ///
  /// In en, this message translates to:
  /// **'Pick an area'**
  String get pickAnArea;

  /// No description provided for @livingRoom.
  ///
  /// In en, this message translates to:
  /// **'Living Room'**
  String get livingRoom;

  /// No description provided for @bedroom.
  ///
  /// In en, this message translates to:
  /// **'Bedroom'**
  String get bedroom;

  /// No description provided for @kitchen.
  ///
  /// In en, this message translates to:
  /// **'Kitchen'**
  String get kitchen;

  /// No description provided for @homeOffice.
  ///
  /// In en, this message translates to:
  /// **'Home Office'**
  String get homeOffice;

  /// No description provided for @garage.
  ///
  /// In en, this message translates to:
  /// **'Garage'**
  String get garage;

  /// No description provided for @customArea.
  ///
  /// In en, this message translates to:
  /// **'Custom area…'**
  String get customArea;

  /// No description provided for @nameYourArea.
  ///
  /// In en, this message translates to:
  /// **'Name your area'**
  String get nameYourArea;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @quickSweepTimer.
  ///
  /// In en, this message translates to:
  /// **'Quick Sweep'**
  String get quickSweepTimer;

  /// No description provided for @minimize.
  ///
  /// In en, this message translates to:
  /// **'Minimize'**
  String get minimize;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @thisMonthProgress.
  ///
  /// In en, this message translates to:
  /// **'This Month\'s Progress'**
  String get thisMonthProgress;

  /// No description provided for @itemsLetGo.
  ///
  /// In en, this message translates to:
  /// **'Items let go: {count}'**
  String itemsLetGo(int count);

  /// No description provided for @sessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions: {count}'**
  String sessions(int count);

  /// No description provided for @spaceFreed.
  ///
  /// In en, this message translates to:
  /// **'Space freed: {amount} m²'**
  String spaceFreed(String amount);

  /// No description provided for @secondHandTracker.
  ///
  /// In en, this message translates to:
  /// **'Second-hand Tracker'**
  String get secondHandTracker;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @joyDeclutterTitle.
  ///
  /// In en, this message translates to:
  /// **'Joy Declutter'**
  String get joyDeclutterTitle;

  /// No description provided for @joyDeclutterCaptureTitle.
  ///
  /// In en, this message translates to:
  /// **'Capture Item'**
  String get joyDeclutterCaptureTitle;

  /// No description provided for @nextStep.
  ///
  /// In en, this message translates to:
  /// **'Next Step'**
  String get nextStep;

  /// No description provided for @doesItSparkJoy.
  ///
  /// In en, this message translates to:
  /// **'Does this item spark joy?'**
  String get doesItSparkJoy;

  /// No description provided for @joyQuestionDescription.
  ///
  /// In en, this message translates to:
  /// **'Hold the item in your hands and ask yourself: Does this bring joy to my life?'**
  String get joyQuestionDescription;

  /// No description provided for @keepItem.
  ///
  /// In en, this message translates to:
  /// **'Yes, Keep It'**
  String get keepItem;

  /// No description provided for @letGoItem.
  ///
  /// In en, this message translates to:
  /// **'No, Let It Go'**
  String get letGoItem;

  /// No description provided for @itemKept.
  ///
  /// In en, this message translates to:
  /// **'Item kept! This completes your Joy Declutter session.'**
  String get itemKept;

  /// No description provided for @selectLetGoRoute.
  ///
  /// In en, this message translates to:
  /// **'How would you like to let go of this item?'**
  String get selectLetGoRoute;

  /// No description provided for @routeResell.
  ///
  /// In en, this message translates to:
  /// **'Resell'**
  String get routeResell;

  /// No description provided for @routeResellDescription.
  ///
  /// In en, this message translates to:
  /// **'Sell to someone who will appreciate it'**
  String get routeResellDescription;

  /// No description provided for @routeDonation.
  ///
  /// In en, this message translates to:
  /// **'Donation'**
  String get routeDonation;

  /// No description provided for @routeDonationDescription.
  ///
  /// In en, this message translates to:
  /// **'Give to those in need'**
  String get routeDonationDescription;

  /// No description provided for @routeDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get routeDiscard;

  /// No description provided for @routeDiscardDescription.
  ///
  /// In en, this message translates to:
  /// **'Dispose of responsibly'**
  String get routeDiscardDescription;

  /// No description provided for @routeRecycle.
  ///
  /// In en, this message translates to:
  /// **'Recycle'**
  String get routeRecycle;

  /// No description provided for @routeRecycleDescription.
  ///
  /// In en, this message translates to:
  /// **'Give materials new life'**
  String get routeRecycleDescription;

  /// No description provided for @joyDeclutterComplete.
  ///
  /// In en, this message translates to:
  /// **'Joy Declutter session complete!'**
  String get joyDeclutterComplete;

  /// No description provided for @itemLetGo.
  ///
  /// In en, this message translates to:
  /// **'You\'ve chosen to let go of this item.'**
  String get itemLetGo;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'{title} — coming next'**
  String comingSoon(String title);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
