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

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get goodAfternoon;

  /// No description provided for @readyToSparkJoy.
  ///
  /// In en, this message translates to:
  /// **'Ready to spark joy today?'**
  String get readyToSparkJoy;

  /// No description provided for @dailyInspiration.
  ///
  /// In en, this message translates to:
  /// **'Daily Inspiration'**
  String get dailyInspiration;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back to your joy journey'**
  String get welcomeBack;

  /// No description provided for @continueYourJoyJourney.
  ///
  /// In en, this message translates to:
  /// **'Continue your journey'**
  String get continueYourJoyJourney;

  /// No description provided for @tagline1.
  ///
  /// In en, this message translates to:
  /// **'Continue organizing your space with mindfulness'**
  String get tagline1;

  /// No description provided for @tagline2.
  ///
  /// In en, this message translates to:
  /// **'Transforming spaces, one item at a time'**
  String get tagline2;

  /// No description provided for @tagline3.
  ///
  /// In en, this message translates to:
  /// **'Creating clarity with intentional living'**
  String get tagline3;

  /// No description provided for @tagline4.
  ///
  /// In en, this message translates to:
  /// **'Every item has a story, honor it with purpose'**
  String get tagline4;

  /// No description provided for @tagline5.
  ///
  /// In en, this message translates to:
  /// **'Building joy through mindful decluttering'**
  String get tagline5;

  /// No description provided for @thisMonthProgress.
  ///
  /// In en, this message translates to:
  /// **'Recent Activities'**
  String get thisMonthProgress;

  /// No description provided for @areasCleared.
  ///
  /// In en, this message translates to:
  /// **'Areas Cleared'**
  String get areasCleared;

  /// No description provided for @streakAchievement.
  ///
  /// In en, this message translates to:
  /// **'Streak Achievement'**
  String get streakAchievement;

  /// No description provided for @daysStreak.
  ///
  /// In en, this message translates to:
  /// **'{count} day streak!'**
  String daysStreak(int count);

  /// No description provided for @keepGoing.
  ///
  /// In en, this message translates to:
  /// **'Keep going!'**
  String get keepGoing;

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

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @quote1.
  ///
  /// In en, this message translates to:
  /// **'\"The space in which we live should be for the person we are becoming now, not for the person we were in the past.\" — Marie Kondo'**
  String get quote1;

  /// No description provided for @quote2.
  ///
  /// In en, this message translates to:
  /// **'\"Outer order contributes to inner calm.\" — Gretchen Rubin'**
  String get quote2;

  /// No description provided for @quote3.
  ///
  /// In en, this message translates to:
  /// **'\"Have nothing in your house that you do not know to be useful, or believe to be beautiful.\" — William Morris'**
  String get quote3;

  /// No description provided for @quote4.
  ///
  /// In en, this message translates to:
  /// **'\"Clutter is not just physical stuff. It\'s old ideas, toxic relationships, and bad habits.\" — Eleanor Brownn'**
  String get quote4;

  /// No description provided for @quote5.
  ///
  /// In en, this message translates to:
  /// **'\"The objective of cleaning is not just to clean, but to feel happiness living within that environment.\" — Marie Kondo'**
  String get quote5;

  /// No description provided for @quote6.
  ///
  /// In en, this message translates to:
  /// **'\"Simplicity is the ultimate sophistication.\" — Leonardo da Vinci'**
  String get quote6;

  /// No description provided for @quote7.
  ///
  /// In en, this message translates to:
  /// **'\"When your room is clean and uncluttered, you have no choice but to examine your inner state.\" — Marie Kondo'**
  String get quote7;

  /// No description provided for @quote8.
  ///
  /// In en, this message translates to:
  /// **'\"Clear clutter. Make space for you.\" — Magdalena VandenBerg'**
  String get quote8;

  /// No description provided for @quote9.
  ///
  /// In en, this message translates to:
  /// **'\"The first step in crafting the life you want is to get rid of everything you don\'t.\" — Joshua Becker'**
  String get quote9;

  /// No description provided for @quote10.
  ///
  /// In en, this message translates to:
  /// **'\"A clean house is a sign of a wasted life.\" — Unknown'**
  String get quote10;

  /// No description provided for @quote11.
  ///
  /// In en, this message translates to:
  /// **'\"The more you have, the more you are occupied. The less you have, the more free you are.\" — Mother Teresa'**
  String get quote11;

  /// No description provided for @quote12.
  ///
  /// In en, this message translates to:
  /// **'\"Life is really simple, but we insist on making it complicated.\" — Confucius'**
  String get quote12;

  /// No description provided for @quote13.
  ///
  /// In en, this message translates to:
  /// **'\"Minimalism is not a lack of something. It\'s simply the perfect amount of something.\" — Nicholas Burroughs'**
  String get quote13;

  /// No description provided for @quote14.
  ///
  /// In en, this message translates to:
  /// **'\"Your home should tell the story of who you are, and be a collection of what you love.\" — Nate Berkus'**
  String get quote14;

  /// No description provided for @quote15.
  ///
  /// In en, this message translates to:
  /// **'\"Getting rid of everything that doesn\'t matter allows you to remember who you are.\" — Unknown'**
  String get quote15;

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
  /// **'Quick Declutter'**
  String get quickDeclutter;

  /// No description provided for @quickSweep.
  ///
  /// In en, this message translates to:
  /// **'Quick\nSweep'**
  String get quickSweep;

  /// No description provided for @joyDeclutter.
  ///
  /// In en, this message translates to:
  /// **'Joy Declutter'**
  String get joyDeclutter;

  /// No description provided for @quickDeclutterTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Declutter'**
  String get quickDeclutterTitle;

  /// No description provided for @declutterSession.
  ///
  /// In en, this message translates to:
  /// **'Declutter Session'**
  String get declutterSession;

  /// No description provided for @kept.
  ///
  /// In en, this message translates to:
  /// **'Kept'**
  String get kept;

  /// No description provided for @letGo.
  ///
  /// In en, this message translates to:
  /// **'Let Go'**
  String get letGo;

  /// No description provided for @scanYourNextItem.
  ///
  /// In en, this message translates to:
  /// **'Scan Your Next Item'**
  String get scanYourNextItem;

  /// No description provided for @readyWhenYouAre.
  ///
  /// In en, this message translates to:
  /// **'Ready when you are!'**
  String get readyWhenYouAre;

  /// No description provided for @finishSession.
  ///
  /// In en, this message translates to:
  /// **'Finish Session'**
  String get finishSession;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @capture.
  ///
  /// In en, this message translates to:
  /// **'Capture'**
  String get capture;

  /// No description provided for @retakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Retake Photo'**
  String get retakePhoto;

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

  /// No description provided for @joyDeclutterTitle.
  ///
  /// In en, this message translates to:
  /// **'Joy Declutter'**
  String get joyDeclutterTitle;

  /// No description provided for @joyDeclutterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start guided session'**
  String get joyDeclutterSubtitle;

  /// No description provided for @quickDeclutterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'15-min timer session'**
  String get quickDeclutterSubtitle;

  /// No description provided for @deepCleaningSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Photo-based cleaning'**
  String get deepCleaningSubtitle;

  /// No description provided for @doesItSparkJoy.
  ///
  /// In en, this message translates to:
  /// **'Does this item spark joy?'**
  String get doesItSparkJoy;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @pleaseEnterItemName.
  ///
  /// In en, this message translates to:
  /// **'Please enter an item name'**
  String get pleaseEnterItemName;

  /// No description provided for @howToLetGo.
  ///
  /// In en, this message translates to:
  /// **'How would you like to let it go?'**
  String get howToLetGo;

  /// No description provided for @routeDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get routeDiscard;

  /// No description provided for @routeDonation.
  ///
  /// In en, this message translates to:
  /// **'Donation'**
  String get routeDonation;

  /// No description provided for @routeRecycle.
  ///
  /// In en, this message translates to:
  /// **'Recycle'**
  String get routeRecycle;

  /// No description provided for @routeResell.
  ///
  /// In en, this message translates to:
  /// **'Resell'**
  String get routeResell;

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

  /// No description provided for @recentActivities.
  ///
  /// In en, this message translates to:
  /// **'Recent Activities'**
  String get recentActivities;

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// No description provided for @itemDecluttered.
  ///
  /// In en, this message translates to:
  /// **'Item Decluttered'**
  String get itemDecluttered;

  /// No description provided for @newValueCreated.
  ///
  /// In en, this message translates to:
  /// **'Value Added'**
  String get newValueCreated;

  /// No description provided for @roomCleaned.
  ///
  /// In en, this message translates to:
  /// **'Room Cleaned'**
  String get roomCleaned;

  /// No description provided for @memoryCreated.
  ///
  /// In en, this message translates to:
  /// **'Memory created successfully'**
  String get memoryCreated;

  /// No description provided for @itemsResell.
  ///
  /// In en, this message translates to:
  /// **'Items Resell'**
  String get itemsResell;

  /// No description provided for @itemsDashboardComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Items dashboard coming soon'**
  String get itemsDashboardComingSoon;

  /// No description provided for @memoriesDashboardComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Memories dashboard coming soon'**
  String get memoriesDashboardComingSoon;

  /// No description provided for @insightsDashboardComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Insights dashboard coming soon'**
  String get insightsDashboardComingSoon;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @startDeclutter.
  ///
  /// In en, this message translates to:
  /// **'Start Declutter'**
  String get startDeclutter;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get justNow;

  /// No description provided for @minsAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} mins ago'**
  String minsAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} hours ago'**
  String hoursAgo(int count);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String daysAgo(int count);

  /// No description provided for @itemsLetGo.
  ///
  /// In en, this message translates to:
  /// **'Items let go: {count}'**
  String itemsLetGo(int count);

  /// No description provided for @sessions.
  ///
  /// In en, this message translates to:
  /// **'{count} sessions'**
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

  /// No description provided for @routeResellDescription.
  ///
  /// In en, this message translates to:
  /// **'Sell to someone who will appreciate it'**
  String get routeResellDescription;

  /// No description provided for @routeDonationDescription.
  ///
  /// In en, this message translates to:
  /// **'Give to those in need'**
  String get routeDonationDescription;

  /// No description provided for @routeDiscardDescription.
  ///
  /// In en, this message translates to:
  /// **'Dispose of responsibly'**
  String get routeDiscardDescription;

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
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @captureItemToStart.
  ///
  /// In en, this message translates to:
  /// **'Capture an item to start decluttering'**
  String get captureItemToStart;

  /// No description provided for @takePicture.
  ///
  /// In en, this message translates to:
  /// **'Take the picture'**
  String get takePicture;

  /// No description provided for @itemsCaptured.
  ///
  /// In en, this message translates to:
  /// **'Items captured'**
  String get itemsCaptured;

  /// No description provided for @nextItem.
  ///
  /// In en, this message translates to:
  /// **'Next item'**
  String get nextItem;

  /// No description provided for @finishDeclutter.
  ///
  /// In en, this message translates to:
  /// **'Finish declutter'**
  String get finishDeclutter;

  /// No description provided for @deepCleaningTitle.
  ///
  /// In en, this message translates to:
  /// **'Deep Cleaning'**
  String get deepCleaningTitle;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @itemSaved.
  ///
  /// In en, this message translates to:
  /// **'Item saved successfully!'**
  String get itemSaved;

  /// No description provided for @timeToLetGo.
  ///
  /// In en, this message translates to:
  /// **'Time to Let Go'**
  String get timeToLetGo;

  /// No description provided for @itemMarkedAs.
  ///
  /// In en, this message translates to:
  /// **'Item marked as {option}'**
  String itemMarkedAs(String option);

  /// No description provided for @clickToStartTimer.
  ///
  /// In en, this message translates to:
  /// **'Click to Start Timer'**
  String get clickToStartTimer;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @continueSession.
  ///
  /// In en, this message translates to:
  /// **'Continue Session'**
  String get continueSession;

  /// No description provided for @started.
  ///
  /// In en, this message translates to:
  /// **'Started {when}'**
  String started(String when);

  /// No description provided for @deepCleaningSessionCompleted.
  ///
  /// In en, this message translates to:
  /// **'Deep Cleaning session completed'**
  String get deepCleaningSessionCompleted;

  /// No description provided for @memoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Memories'**
  String get memoriesTitle;

  /// No description provided for @memoriesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No memories yet'**
  String get memoriesEmptyTitle;

  /// No description provided for @memoriesEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your decluttering journey will create beautiful memories here'**
  String get memoriesEmptySubtitle;

  /// No description provided for @memoriesEmptyAction.
  ///
  /// In en, this message translates to:
  /// **'Start decluttering to create memories'**
  String get memoriesEmptyAction;

  /// No description provided for @memoryDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Memory Details'**
  String get memoryDetailTitle;

  /// No description provided for @memoryCreatedOn.
  ///
  /// In en, this message translates to:
  /// **'Created on {date}'**
  String memoryCreatedOn(String date);

  /// No description provided for @memoryTypeDecluttering.
  ///
  /// In en, this message translates to:
  /// **'Decluttering'**
  String get memoryTypeDecluttering;

  /// No description provided for @memoryTypeCleaning.
  ///
  /// In en, this message translates to:
  /// **'Cleaning'**
  String get memoryTypeCleaning;

  /// No description provided for @memoryTypeCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get memoryTypeCustom;

  /// No description provided for @memoryAddNote.
  ///
  /// In en, this message translates to:
  /// **'Add a note'**
  String get memoryAddNote;

  /// No description provided for @memoryEditNote.
  ///
  /// In en, this message translates to:
  /// **'Edit note'**
  String get memoryEditNote;

  /// No description provided for @memorySaveNote.
  ///
  /// In en, this message translates to:
  /// **'Save note'**
  String get memorySaveNote;

  /// No description provided for @memoryDeleteMemory.
  ///
  /// In en, this message translates to:
  /// **'Delete memory'**
  String get memoryDeleteMemory;

  /// No description provided for @memoryDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this memory?'**
  String get memoryDeleteConfirm;

  /// No description provided for @memoryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Memory deleted'**
  String get memoryDeleted;

  /// No description provided for @memoryNoteSaved.
  ///
  /// In en, this message translates to:
  /// **'Note saved'**
  String get memoryNoteSaved;

  /// No description provided for @memoryShare.
  ///
  /// In en, this message translates to:
  /// **'Share memory'**
  String get memoryShare;

  /// No description provided for @memoryViewPhoto.
  ///
  /// In en, this message translates to:
  /// **'View photo'**
  String get memoryViewPhoto;

  /// No description provided for @memoryNoPhoto.
  ///
  /// In en, this message translates to:
  /// **'No photo available'**
  String get memoryNoPhoto;

  /// No description provided for @memoryFromItem.
  ///
  /// In en, this message translates to:
  /// **'From: {itemName}'**
  String memoryFromItem(String itemName);

  /// No description provided for @memoryCategory.
  ///
  /// In en, this message translates to:
  /// **'Category: {category}'**
  String memoryCategory(String category);

  /// No description provided for @memoryRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get memoryRecent;

  /// No description provided for @memoryThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get memoryThisWeek;

  /// No description provided for @memoryThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get memoryThisMonth;

  /// No description provided for @memoryOlder.
  ///
  /// In en, this message translates to:
  /// **'Older'**
  String get memoryOlder;

  /// No description provided for @memoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get memoryAll;

  /// No description provided for @memoryFilterByType.
  ///
  /// In en, this message translates to:
  /// **'Filter by type'**
  String get memoryFilterByType;

  /// No description provided for @memorySortByDate.
  ///
  /// In en, this message translates to:
  /// **'Sort by date'**
  String get memorySortByDate;

  /// No description provided for @memorySortByType.
  ///
  /// In en, this message translates to:
  /// **'Sort by type'**
  String get memorySortByType;

  /// No description provided for @memoryCreateFromItem.
  ///
  /// In en, this message translates to:
  /// **'Create memory from item'**
  String get memoryCreateFromItem;

  /// No description provided for @memoryCreateCustom.
  ///
  /// In en, this message translates to:
  /// **'Create custom memory'**
  String get memoryCreateCustom;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSettings.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageSettings;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @chinese.
  ///
  /// In en, this message translates to:
  /// **'中文 (Chinese)'**
  String get chinese;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @totalItemsDecluttered.
  ///
  /// In en, this message translates to:
  /// **'Total Items Decluttered'**
  String get totalItemsDecluttered;

  /// No description provided for @sessionsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Sessions Completed'**
  String get sessionsCompleted;

  /// No description provided for @memoriesCreated.
  ///
  /// In en, this message translates to:
  /// **'Memories Created'**
  String get memoriesCreated;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreak;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String days(int count);

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support & Information'**
  String get support;

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About KeepJoy'**
  String get aboutApp;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate the App'**
  String get rateApp;

  /// No description provided for @shareApp.
  ///
  /// In en, this message translates to:
  /// **'Share with Friends'**
  String get shareApp;

  /// No description provided for @data.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get data;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// No description provided for @clearAllData.
  ///
  /// In en, this message translates to:
  /// **'Clear All Data'**
  String get clearAllData;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @takeBeforePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Before Photo'**
  String get takeBeforePhoto;

  /// No description provided for @skipPhoto.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipPhoto;

  /// No description provided for @takeAfterPhoto.
  ///
  /// In en, this message translates to:
  /// **'Take After Photo'**
  String get takeAfterPhoto;

  /// No description provided for @beforePhoto.
  ///
  /// In en, this message translates to:
  /// **'Before Photo'**
  String get beforePhoto;

  /// No description provided for @afterPhoto.
  ///
  /// In en, this message translates to:
  /// **'After Photo'**
  String get afterPhoto;

  /// No description provided for @captureBeforeState.
  ///
  /// In en, this message translates to:
  /// **'Capture the current state of your area'**
  String get captureBeforeState;

  /// No description provided for @captureAfterState.
  ///
  /// In en, this message translates to:
  /// **'Capture the result of your cleaning'**
  String get captureAfterState;

  /// No description provided for @howManyItems.
  ///
  /// In en, this message translates to:
  /// **'How many items did you declutter?'**
  String get howManyItems;

  /// No description provided for @focusIndex.
  ///
  /// In en, this message translates to:
  /// **'Focus Index'**
  String get focusIndex;

  /// No description provided for @focusIndexDescription.
  ///
  /// In en, this message translates to:
  /// **'How focused were you during the cleaning?'**
  String get focusIndexDescription;

  /// No description provided for @moodIndex.
  ///
  /// In en, this message translates to:
  /// **'Mood Index'**
  String get moodIndex;

  /// No description provided for @moodIndexDescription.
  ///
  /// In en, this message translates to:
  /// **'How do you feel after the cleaning?'**
  String get moodIndexDescription;

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @messinessBefore.
  ///
  /// In en, this message translates to:
  /// **'Messiness Before'**
  String get messinessBefore;

  /// No description provided for @messinessAfter.
  ///
  /// In en, this message translates to:
  /// **'Messiness After'**
  String get messinessAfter;

  /// No description provided for @timeSpent.
  ///
  /// In en, this message translates to:
  /// **'Time Spent'**
  String get timeSpent;

  /// No description provided for @itemsDecluttered.
  ///
  /// In en, this message translates to:
  /// **'Items Decluttered'**
  String get itemsDecluttered;

  /// No description provided for @beforeAndAfter.
  ///
  /// In en, this message translates to:
  /// **'Before & After'**
  String get beforeAndAfter;

  /// No description provided for @aiAnalysis.
  ///
  /// In en, this message translates to:
  /// **'AI Analysis'**
  String get aiAnalysis;

  /// No description provided for @analyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing photos...'**
  String get analyzing;

  /// No description provided for @improvement.
  ///
  /// In en, this message translates to:
  /// **'Improvement'**
  String get improvement;

  /// No description provided for @finishCleaning.
  ///
  /// In en, this message translates to:
  /// **'Finish Cleaning'**
  String get finishCleaning;

  /// No description provided for @finishCleaningConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you ready to finish this cleaning session?'**
  String get finishCleaningConfirm;

  /// No description provided for @enterItemsCount.
  ///
  /// In en, this message translates to:
  /// **'Enter number of items'**
  String get enterItemsCount;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @noPhotoTaken.
  ///
  /// In en, this message translates to:
  /// **'No photo taken'**
  String get noPhotoTaken;

  /// No description provided for @messiness.
  ///
  /// In en, this message translates to:
  /// **'Messiness'**
  String get messiness;

  /// No description provided for @resellTracker.
  ///
  /// In en, this message translates to:
  /// **'Resell Tracker'**
  String get resellTracker;

  /// No description provided for @toSell.
  ///
  /// In en, this message translates to:
  /// **'To Sell'**
  String get toSell;

  /// No description provided for @listing.
  ///
  /// In en, this message translates to:
  /// **'Listing'**
  String get listing;

  /// No description provided for @sold.
  ///
  /// In en, this message translates to:
  /// **'Sold'**
  String get sold;

  /// No description provided for @platform.
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get platform;

  /// No description provided for @sellingPrice.
  ///
  /// In en, this message translates to:
  /// **'Selling Price'**
  String get sellingPrice;

  /// No description provided for @soldPrice.
  ///
  /// In en, this message translates to:
  /// **'Sold Price'**
  String get soldPrice;

  /// No description provided for @soldDate.
  ///
  /// In en, this message translates to:
  /// **'Sold Date'**
  String get soldDate;

  /// No description provided for @markAsListing.
  ///
  /// In en, this message translates to:
  /// **'Mark as Listing'**
  String get markAsListing;

  /// No description provided for @markAsSold.
  ///
  /// In en, this message translates to:
  /// **'Mark as Sold'**
  String get markAsSold;

  /// No description provided for @changeStatus.
  ///
  /// In en, this message translates to:
  /// **'Change Status'**
  String get changeStatus;

  /// No description provided for @enterSellingPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter selling price (optional)'**
  String get enterSellingPrice;

  /// No description provided for @enterSoldPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter sold price'**
  String get enterSoldPrice;

  /// No description provided for @soldPriceRequired.
  ///
  /// In en, this message translates to:
  /// **'Sold price is required'**
  String get soldPriceRequired;

  /// No description provided for @platformXianyu.
  ///
  /// In en, this message translates to:
  /// **'Xianyu'**
  String get platformXianyu;

  /// No description provided for @platformZhuanzhuan.
  ///
  /// In en, this message translates to:
  /// **'Zhuanzhuan'**
  String get platformZhuanzhuan;

  /// No description provided for @platformEbay.
  ///
  /// In en, this message translates to:
  /// **'eBay'**
  String get platformEbay;

  /// No description provided for @platformFacebookMarketplace.
  ///
  /// In en, this message translates to:
  /// **'Facebook Marketplace'**
  String get platformFacebookMarketplace;

  /// No description provided for @platformCraigslist.
  ///
  /// In en, this message translates to:
  /// **'Craigslist'**
  String get platformCraigslist;

  /// No description provided for @platformOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get platformOther;

  /// No description provided for @noItemsToSell.
  ///
  /// In en, this message translates to:
  /// **'No items to sell yet'**
  String get noItemsToSell;

  /// No description provided for @noItemsListing.
  ///
  /// In en, this message translates to:
  /// **'No items currently listed'**
  String get noItemsListing;

  /// No description provided for @noItemsSold.
  ///
  /// In en, this message translates to:
  /// **'No items sold yet'**
  String get noItemsSold;

  /// No description provided for @addedOn.
  ///
  /// In en, this message translates to:
  /// **'Added on {date}'**
  String addedOn(String date);

  /// No description provided for @itemDeleted.
  ///
  /// In en, this message translates to:
  /// **'Item deleted'**
  String get itemDeleted;

  /// No description provided for @deleteItem.
  ///
  /// In en, this message translates to:
  /// **'Delete Item'**
  String get deleteItem;

  /// No description provided for @deleteItemConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this item?'**
  String get deleteItemConfirm;

  /// No description provided for @itemStatusUpdated.
  ///
  /// In en, this message translates to:
  /// **'Item status updated'**
  String get itemStatusUpdated;

  /// No description provided for @monthlyEarnings.
  ///
  /// In en, this message translates to:
  /// **'This Month\'s Earnings'**
  String get monthlyEarnings;

  /// No description provided for @createMemory.
  ///
  /// In en, this message translates to:
  /// **'Create Memory'**
  String get createMemory;

  /// No description provided for @createMemoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a Memory'**
  String get createMemoryTitle;

  /// No description provided for @whatDidThisItemBring.
  ///
  /// In en, this message translates to:
  /// **'What did this item bring you?'**
  String get whatDidThisItemBring;

  /// No description provided for @sentimentLove.
  ///
  /// In en, this message translates to:
  /// **'Love'**
  String get sentimentLove;

  /// No description provided for @sentimentNostalgia.
  ///
  /// In en, this message translates to:
  /// **'Nostalgia'**
  String get sentimentNostalgia;

  /// No description provided for @sentimentAdventure.
  ///
  /// In en, this message translates to:
  /// **'Adventure'**
  String get sentimentAdventure;

  /// No description provided for @sentimentHappy.
  ///
  /// In en, this message translates to:
  /// **'Happy'**
  String get sentimentHappy;

  /// No description provided for @sentimentGrateful.
  ///
  /// In en, this message translates to:
  /// **'Grateful'**
  String get sentimentGrateful;

  /// No description provided for @sentimentPeaceful.
  ///
  /// In en, this message translates to:
  /// **'Peaceful'**
  String get sentimentPeaceful;

  /// No description provided for @memoryDescription.
  ///
  /// In en, this message translates to:
  /// **'Memory Description'**
  String get memoryDescription;

  /// No description provided for @describeYourMemory.
  ///
  /// In en, this message translates to:
  /// **'Describe your memory with this item...'**
  String get describeYourMemory;

  /// No description provided for @createMemoryPrompt.
  ///
  /// In en, this message translates to:
  /// **'Would you like to create a memory for this item?'**
  String get createMemoryPrompt;

  /// No description provided for @createMemoryQuestion.
  ///
  /// In en, this message translates to:
  /// **'Create a memory?'**
  String get createMemoryQuestion;

  /// No description provided for @skipMemory.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipMemory;

  /// No description provided for @aiIdentifying.
  ///
  /// In en, this message translates to:
  /// **'AI Identifying...'**
  String get aiIdentifying;

  /// No description provided for @aiSuggested.
  ///
  /// In en, this message translates to:
  /// **'AI suggested'**
  String get aiSuggested;

  /// No description provided for @getDetailedInfo.
  ///
  /// In en, this message translates to:
  /// **'Get detailed info'**
  String get getDetailedInfo;

  /// No description provided for @aiIdentificationFailed.
  ///
  /// In en, this message translates to:
  /// **'AI identification failed'**
  String get aiIdentificationFailed;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @activityCalendar.
  ///
  /// In en, this message translates to:
  /// **'Activity Calendar'**
  String get activityCalendar;

  /// No description provided for @declutterCalendar.
  ///
  /// In en, this message translates to:
  /// **'Declutter Calendar'**
  String get declutterCalendar;

  /// No description provided for @viewFull.
  ///
  /// In en, this message translates to:
  /// **'View Full'**
  String get viewFull;

  /// No description provided for @addNew.
  ///
  /// In en, this message translates to:
  /// **'Add New'**
  String get addNew;

  /// No description provided for @startPlanningDeclutter.
  ///
  /// In en, this message translates to:
  /// **'Start planning your declutter'**
  String get startPlanningDeclutter;

  /// No description provided for @noPlannedSessions.
  ///
  /// In en, this message translates to:
  /// **'No planned declutter sessions'**
  String get noPlannedSessions;

  /// No description provided for @planNewSession.
  ///
  /// In en, this message translates to:
  /// **'Plan New Session'**
  String get planNewSession;

  /// No description provided for @area.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get area;

  /// No description provided for @areaHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Kitchen, Bedroom, Closet'**
  String get areaHint;

  /// No description provided for @pleaseEnterArea.
  ///
  /// In en, this message translates to:
  /// **'Please enter an area'**
  String get pleaseEnterArea;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'optional'**
  String get optional;

  /// No description provided for @notesHint.
  ///
  /// In en, this message translates to:
  /// **'Add any notes or reminders...'**
  String get notesHint;

  /// No description provided for @sessionCreated.
  ///
  /// In en, this message translates to:
  /// **'Session created successfully'**
  String get sessionCreated;

  /// No description provided for @itemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No items} =1{1 item} other{{count} items}}'**
  String itemsCount(int count);

  /// No description provided for @noActivityThisDay.
  ///
  /// In en, this message translates to:
  /// **'No activity on this day'**
  String get noActivityThisDay;

  /// No description provided for @joyCheck.
  ///
  /// In en, this message translates to:
  /// **'Joy Check'**
  String get joyCheck;

  /// No description provided for @joyCheckMessage1.
  ///
  /// In en, this message translates to:
  /// **'Start with items you haven\'t used in the past year'**
  String get joyCheckMessage1;

  /// No description provided for @joyCheckMessage2.
  ///
  /// In en, this message translates to:
  /// **'Focus on one small area today—a drawer, a shelf, a corner'**
  String get joyCheckMessage2;

  /// No description provided for @joyCheckMessage3.
  ///
  /// In en, this message translates to:
  /// **'Hold each item and ask: Does this serve my life right now?'**
  String get joyCheckMessage3;

  /// No description provided for @joyCheckMessage4.
  ///
  /// In en, this message translates to:
  /// **'Remember, letting go isn\'t losing—it\'s making space for what matters'**
  String get joyCheckMessage4;

  /// No description provided for @joyCheckMessage5.
  ///
  /// In en, this message translates to:
  /// **'Begin with the easy items first to build momentum'**
  String get joyCheckMessage5;

  /// No description provided for @joyCheckMessage6.
  ///
  /// In en, this message translates to:
  /// **'Your space reflects your priorities. What do you want it to say?'**
  String get joyCheckMessage6;

  /// No description provided for @todaysTip.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Tip'**
  String get todaysTip;

  /// No description provided for @todaysTip1.
  ///
  /// In en, this message translates to:
  /// **'Deep Cleaning Mode: Tap \'Deep Cleaning\' to capture before/after photos of your space. Start the timer and watch your transformation unfold! The app tracks your progress, measures messiness improvement using AI, and helps you see how much you\'ve accomplished. Perfect for tackling entire rooms!'**
  String get todaysTip1;

  /// No description provided for @todaysTip2.
  ///
  /// In en, this message translates to:
  /// **'Joy Declutter Method: Having trouble deciding what to keep? Try \'Joy Declutter\' from the home screen. Take a photo of any item, and we\'ll guide you through the KonMari question: \'Does this spark joy?\' Hold it in your hands and trust your feelings. If it doesn\'t bring joy, we\'ll help you let it go with gratitude.'**
  String get todaysTip2;

  /// No description provided for @todaysTip3.
  ///
  /// In en, this message translates to:
  /// **'Create Lasting Memories: Before letting go of sentimental items, create a memory! Tap the memory icon when decluttering. Capture a photo, write down what this item meant to you, and preserve the story. The physical item may be gone, but your cherished memory lives forever in the app.'**
  String get todaysTip3;

  /// No description provided for @todaysTip4.
  ///
  /// In en, this message translates to:
  /// **'Quick Sweep Timer: Need motivation? Try \'Quick Sweep\' for a 15-minute power session! Pick any area (living room, closet, desk), start the timer, and race against the clock. It turns decluttering into an exciting game. See how many items you can clear before time runs out!'**
  String get todaysTip4;

  /// No description provided for @todaysTip5.
  ///
  /// In en, this message translates to:
  /// **'Resell Tracker: Planning to sell items? Use our Resell Tracker! When letting go of items, select \'Resell\' and we\'ll add them to your selling list. Track listings, record sold prices, and watch your monthly earnings grow. Transform clutter into cash!'**
  String get todaysTip5;

  /// No description provided for @todaysTip6.
  ///
  /// In en, this message translates to:
  /// **'Quick Declutter Scan: Fastest way to declutter! Tap \'Quick Declutter\' and scan items one by one. Our AI identifies each item instantly. Simply decide: Keep or Let Go? Perfect for rapid decluttering sessions when you need to clear out fast!'**
  String get todaysTip6;

  /// No description provided for @welcomeTagline.
  ///
  /// In en, this message translates to:
  /// **'Transform your space, spark joy in your life'**
  String get welcomeTagline;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign In'**
  String get alreadyHaveAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign Up'**
  String get dontHaveAccount;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get orContinueWith;

  /// No description provided for @google.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get google;

  /// No description provided for @apple.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get apple;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get invalidEmail;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @signInSuccess.
  ///
  /// In en, this message translates to:
  /// **'Signed in successfully'**
  String get signInSuccess;

  /// No description provided for @signUpSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully'**
  String get signUpSuccess;

  /// No description provided for @welcomeToKeepJoy.
  ///
  /// In en, this message translates to:
  /// **'Welcome to KeepJoy'**
  String get welcomeToKeepJoy;

  /// No description provided for @quickTip.
  ///
  /// In en, this message translates to:
  /// **'Quick Tip'**
  String get quickTip;

  /// No description provided for @whatBroughtYouJoy.
  ///
  /// In en, this message translates to:
  /// **'What brought you joy today?'**
  String get whatBroughtYouJoy;

  /// No description provided for @shareYourJoy.
  ///
  /// In en, this message translates to:
  /// **'Share Your Joy'**
  String get shareYourJoy;

  /// No description provided for @monthlyReport.
  ///
  /// In en, this message translates to:
  /// **'Monthly Report'**
  String get monthlyReport;

  /// No description provided for @declutterRhythmOverview.
  ///
  /// In en, this message translates to:
  /// **'Declutter Rhythm & Achievements'**
  String get declutterRhythmOverview;

  /// No description provided for @deepCleaning.
  ///
  /// In en, this message translates to:
  /// **'Deep Cleaning'**
  String get deepCleaning;

  /// No description provided for @cleaningAreas.
  ///
  /// In en, this message translates to:
  /// **'Cleaning Areas'**
  String get cleaningAreas;

  /// No description provided for @beforeAfterComparison.
  ///
  /// In en, this message translates to:
  /// **'Before/After Comparison'**
  String get beforeAfterComparison;

  /// No description provided for @noSessionsThisMonth.
  ///
  /// In en, this message translates to:
  /// **'No sessions this month'**
  String get noSessionsThisMonth;

  /// No description provided for @tapAreaToViewReport.
  ///
  /// In en, this message translates to:
  /// **'Tap area to view report'**
  String get tapAreaToViewReport;

  /// No description provided for @times.
  ///
  /// In en, this message translates to:
  /// **'×{count}'**
  String times(Object count);

  /// No description provided for @todaysFocus.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Focus'**
  String get todaysFocus;

  /// No description provided for @addTask.
  ///
  /// In en, this message translates to:
  /// **'Add a task...'**
  String get addTask;

  /// No description provided for @noTasksYet.
  ///
  /// In en, this message translates to:
  /// **'No tasks yet. Add your first one!'**
  String get noTasksYet;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @markAsComplete.
  ///
  /// In en, this message translates to:
  /// **'Mark as Complete'**
  String get markAsComplete;

  /// No description provided for @startDeepCleaning.
  ///
  /// In en, this message translates to:
  /// **'Start Deep Cleaning'**
  String get startDeepCleaning;

  /// No description provided for @schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @taskAdded.
  ///
  /// In en, this message translates to:
  /// **'Task added'**
  String get taskAdded;

  /// No description provided for @taskCompleted.
  ///
  /// In en, this message translates to:
  /// **'Task completed'**
  String get taskCompleted;
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
