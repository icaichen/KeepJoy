// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get goodMorning => 'Good Morning';

  @override
  String get goodAfternoon => 'Good Afternoon';

  @override
  String get readyToSparkJoy => 'Ready to spark joy today?';

  @override
  String get startYourDeclutterJourney => 'Start your declutter journey';

  @override
  String get chooseFlowTitle => 'Choose a flow';

  @override
  String get chooseFlowSubtitle =>
      'Pick the experience that fits your current energy.';

  @override
  String get joyDeclutterFlowDescription => 'Lead with joy when letting go';

  @override
  String get quickDeclutterFlowDescription =>
      'Clear spaces in under 10 minutes';

  @override
  String get deepCleaningFlowDescription =>
      'Structured sessions for thorough results';

  @override
  String get startAction => 'Start';

  @override
  String get dailyInspiration => 'Daily Inspiration';

  @override
  String get welcomeBack => 'Welcome back to your joy journey';

  @override
  String get continueYourJoyJourney => 'Continue your journey';

  @override
  String get tagline1 => 'Continue organizing your space with mindfulness';

  @override
  String get tagline2 => 'Transforming spaces, one item at a time';

  @override
  String get tagline3 => 'Creating clarity with intentional living';

  @override
  String get tagline4 => 'Every item has a story, honor it with purpose';

  @override
  String get tagline5 => 'Building joy through mindful decluttering';

  @override
  String get thisMonthProgress => 'Recent Activities';

  @override
  String get areasCleared => 'Areas Cleared';

  @override
  String get streakAchievement => 'Streak Achievement';

  @override
  String daysStreak(int count) {
    return '$count day streak!';
  }

  @override
  String get keepGoing => 'Keep going!';

  @override
  String get dashboardCreateGoalTitle => 'Create New Goal';

  @override
  String get dashboardGoalLabel => 'Goal';

  @override
  String get dashboardGoalHint =>
      'e.g., Declutter 50 items by end of December\nor Clean kitchen and take photos';

  @override
  String get dashboardDateOptional => 'Date (Optional)';

  @override
  String get dashboardTapToSelectDate => 'Tap to select date';

  @override
  String get dashboardEnterGoalPrompt => 'Please enter a goal';

  @override
  String get dashboardGoalCreated => 'Goal created';

  @override
  String get dashboardCreateAction => 'Create';

  @override
  String get dashboardCreateSessionTitle => 'Create New Session';

  @override
  String get dashboardModeLabel => 'Mode';

  @override
  String get dashboardAreaHint => 'e.g., Kitchen, Bedroom';

  @override
  String get dashboardSelectDate => 'Select date';

  @override
  String get dashboardSelectTimeOptional => 'Select time (optional)';

  @override
  String get dashboardEnterAreaPrompt => 'Please enter an area name';

  @override
  String get dashboardSessionCreated => 'Session created';

  @override
  String get dashboardMonthlyProgress => 'Monthly Progress';

  @override
  String get dashboardDeclutteredLabel => 'Decluttered Items';

  @override
  String get dashboardResellLabel => 'Resell Value';

  @override
  String get dashboardResellReportTitle => 'Resell Analysis';

  @override
  String get dashboardResellReportSubtitle => 'View full report';

  @override
  String get dashboardMemoryLaneTitle => 'Memory Lane';

  @override
  String get dashboardMemoryLaneSubtitle => 'Revisit your journey';

  @override
  String get dashboardYearlyReportsTitle => 'Yearly Reports';

  @override
  String get dashboardYearlyReportsSubtitle => 'View annual summary';

  @override
  String get dashboardCurrentStreakTitle => 'Current Streak';

  @override
  String get dashboardStreakSubtitle => 'Days in a row';

  @override
  String get dashboardActiveSessionTitle => 'Active Session';

  @override
  String get dashboardTodoTitle => 'To Do';

  @override
  String get dashboardViewCalendar => 'View Calendar';

  @override
  String get dashboardNoTodosTitle => 'No items yet';

  @override
  String get dashboardNoTodosSubtitle =>
      'Tap below to create a goal or session';

  @override
  String get dashboardCalendarTitle => 'Calendar';

  @override
  String get dashboardNoSessionsForDay => 'No sessions on this day';

  @override
  String get dashboardStartNow => 'Start Now';

  @override
  String get deepCleaningAnalysisTitle => 'Deep Cleaning Analysis';

  @override
  String get dashboardSessionsLabel => 'Sessions';

  @override
  String get dashboardItemsLabel => 'Items';

  @override
  String get dashboardAverageFocusLabel => 'Avg Focus';

  @override
  String get dashboardAverageJoyLabel => 'Avg Joy';

  @override
  String dashboardSessionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessions',
      one: '1 session',
      zero: '0 sessions',
    );
    return '($_temp0)';
  }

  @override
  String get dashboardCleaningHistory => 'Cleaning History';

  @override
  String dashboardSessionTotal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessions',
      one: '1 session',
      zero: 'No sessions',
    );
    return '$_temp0';
  }

  @override
  String get dashboardFocusLabel => 'Focus';

  @override
  String get dashboardJoyLabel => 'Joy';

  @override
  String get dashboardItemsCleanedLabel => 'Items cleaned';

  @override
  String get dashboardSessionData => 'Session Data';

  @override
  String get dashboardBefore => 'Before';

  @override
  String get dashboardAfter => 'After';

  @override
  String get dashboardSwipeToCompare => 'Swipe to compare';

  @override
  String get dashboardDurationLabel => 'Duration';

  @override
  String dashboardDurationMinutes(String minutes) {
    return '$minutes min';
  }

  @override
  String get dashboardItemsDeclutteredLabel => 'Items decluttered';

  @override
  String get dashboardMessinessReducedLabel => 'Messiness reduced';

  @override
  String dashboardMessinessImprovement(
    int improvement,
    String before,
    String after,
  ) {
    return '$improvement% (from $before to $after)';
  }

  @override
  String get dashboardNoDetailedMetrics => 'No detailed metrics recorded yet';

  @override
  String get dashboardNoDetailsSaved =>
      'Add photos or session metrics to unlock detailed insights here.';

  @override
  String get dashboardLettingGoDetailsTitle => 'Letting Go Details';

  @override
  String get dashboardLettingGoDetailsSubtitle =>
      'See how items found their next home';

  @override
  String get dashboardSessionDeleted => 'Session deleted';

  @override
  String get dashboardNotScheduled => 'Not scheduled';

  @override
  String get dashboardToday => 'Today';

  @override
  String get dashboardTomorrow => 'Tomorrow';

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
  String get profile => 'Profile';

  @override
  String get quote1 =>
      '\"The space in which we live should be for the person we are becoming now, not for the person we were in the past.\" — Marie Kondo';

  @override
  String get quote2 =>
      '\"Outer order contributes to inner calm.\" — Gretchen Rubin';

  @override
  String get quote3 =>
      '\"Have nothing in your house that you do not know to be useful, or believe to be beautiful.\" — William Morris';

  @override
  String get quote4 =>
      '\"Clutter is not just physical stuff. It\'s old ideas, toxic relationships, and bad habits.\" — Eleanor Brownn';

  @override
  String get quote5 =>
      '\"The objective of cleaning is not just to clean, but to feel happiness living within that environment.\" — Marie Kondo';

  @override
  String get quote6 =>
      '\"Simplicity is the ultimate sophistication.\" — Leonardo da Vinci';

  @override
  String get quote7 =>
      '\"When your room is clean and uncluttered, you have no choice but to examine your inner state.\" — Marie Kondo';

  @override
  String get quote8 =>
      '\"Clear clutter. Make space for you.\" — Magdalena VandenBerg';

  @override
  String get quote9 =>
      '\"The first step in crafting the life you want is to get rid of everything you don\'t.\" — Joshua Becker';

  @override
  String get quote10 =>
      '\"A clean house is a sign of a wasted life.\" — Unknown';

  @override
  String get quote11 =>
      '\"The more you have, the more you are occupied. The less you have, the more free you are.\" — Mother Teresa';

  @override
  String get quote12 =>
      '\"Life is really simple, but we insist on making it complicated.\" — Confucius';

  @override
  String get quote13 =>
      '\"Minimalism is not a lack of something. It\'s simply the perfect amount of something.\" — Nicholas Burroughs';

  @override
  String get quote14 =>
      '\"Your home should tell the story of who you are, and be a collection of what you love.\" — Nate Berkus';

  @override
  String get quote15 =>
      '\"Getting rid of everything that doesn\'t matter allows you to remember who you are.\" — Unknown';

  @override
  String get goodEvening => 'Good Evening';

  @override
  String get coreModules => 'Core Modules';

  @override
  String get joyfulMemories => 'Joyful Memories';

  @override
  String get viewAll => 'View All';

  @override
  String get quickDeclutter => 'Quick Declutter';

  @override
  String get quickSweep => 'Quick\nSweep';

  @override
  String get joyDeclutter => 'Joy Declutter';

  @override
  String get quickDeclutterTitle => 'Quick Declutter';

  @override
  String get declutterSession => 'Declutter Session';

  @override
  String get kept => 'Kept';

  @override
  String get letGo => 'Let Go';

  @override
  String get scanYourNextItem => 'Scan Your Next Item';

  @override
  String get readyWhenYouAre => 'Ready when you are!';

  @override
  String get finishSession => 'Finish Session';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get capture => 'Capture';

  @override
  String get retakePhoto => 'Retake Photo';

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
  String get joyDeclutterTitle => 'Joy Declutter';

  @override
  String get joyDeclutterSubtitle => 'Start guided session';

  @override
  String get quickDeclutterSubtitle => '15-min timer session';

  @override
  String get deepCleaningSubtitle => 'Photo-based cleaning';

  @override
  String get doesItSparkJoy => 'Does this item spark joy?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get next => 'Next';

  @override
  String get pleaseEnterItemName => 'Please enter an item name';

  @override
  String get howToLetGo => 'How would you like to let it go?';

  @override
  String get routeDiscard => 'Discard';

  @override
  String get routeDonation => 'Donation';

  @override
  String get routeRecycle => 'Recycle';

  @override
  String get routeResell => 'Resell';

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
  String get closet => 'Closet';

  @override
  String get bathroom => 'Bathroom';

  @override
  String get study => 'Study';

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
  String get recentActivities => 'Recent Activities';

  @override
  String get streak => 'Streak';

  @override
  String get itemDecluttered => 'Item Decluttered';

  @override
  String get newValueCreated => 'Value Added';

  @override
  String get roomCleaned => 'Room Cleaned';

  @override
  String get memoryCreated => 'Memory created successfully';

  @override
  String get itemsResell => 'Items Resell';

  @override
  String get itemsDashboardComingSoon => 'Items dashboard coming soon';

  @override
  String get memoriesDashboardComingSoon => 'Memories dashboard coming soon';

  @override
  String get insightsDashboardComingSoon => 'Insights dashboard coming soon';

  @override
  String get ok => 'OK';

  @override
  String get startDeclutter => 'Start Declutter';

  @override
  String get startOrganizing => 'Start Organizing';

  @override
  String get joyDeclutterModeSubtitle => 'One item at a time, feel the joy';

  @override
  String get quickDeclutterModeSubtitle => 'Quick capture, batch process';

  @override
  String get deepCleaningModeSubtitle => 'Focused cleaning session';

  @override
  String get activitySeparator => ' • ';

  @override
  String get noRecentActivity => 'No recent activity yet—keep going!';

  @override
  String get justNow => 'just now';

  @override
  String minsAgo(int count) {
    return '$count mins ago';
  }

  @override
  String hoursAgo(int count) {
    return '$count hours ago';
  }

  @override
  String daysAgo(int count) {
    return '$count days ago';
  }

  @override
  String itemsLetGo(int count) {
    return 'Items let go: $count';
  }

  @override
  String sessions(int count) {
    return '$count sessions';
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
  String get cleaningLegendButton => 'Legend';

  @override
  String get cleaningLegendTitle => 'Cleaning Areas Legend';

  @override
  String get cleaningLegendNone => '0 sessions • not started';

  @override
  String get cleaningLegendLight => '1-2 sessions • light touch';

  @override
  String get cleaningLegendMomentum => '3-4 sessions • getting momentum';

  @override
  String get cleaningLegendSteady => '5-7 sessions • steady groove';

  @override
  String get cleaningLegendHighFocus => '8-10 sessions • high focus';

  @override
  String get cleaningLegendMaintenance => '11+ sessions • maintenance mode';

  @override
  String get joyDeclutterCaptureTitle => 'Capture Item';

  @override
  String get nextStep => 'Next Step';

  @override
  String get joyQuestionDescription =>
      'Hold the item in your hands and ask yourself: Does this bring joy to my life?';

  @override
  String joyQuestionProgress(int current, int total) {
    return 'Question $current/$total';
  }

  @override
  String get joyQuestion1Prompt => 'When did you last use this item?';

  @override
  String get joyQuestion2Prompt => 'Do you have a similar item you prefer?';

  @override
  String get joyQuestion3Prompt => 'Would you buy this item again today?';

  @override
  String get joyQuestion4Prompt =>
      'Does this fit your current lifestyle and goals?';

  @override
  String get joyQuestion5Prompt =>
      'Are you keeping it because you spent too much money?';

  @override
  String get joyQuestionOptionLessThanMonth => '< 1 month';

  @override
  String get joyQuestionOption1To6Months => '1-6 months';

  @override
  String get joyQuestionOption6To12Months => '6-12 months';

  @override
  String get joyQuestionOptionMoreThanYear => '> 1 year';

  @override
  String get joyQuestion2Yes => 'Yes';

  @override
  String get joyQuestion2No => 'No';

  @override
  String get joyQuestion3Yes => 'Yes';

  @override
  String get joyQuestion3No => 'No';

  @override
  String get joyQuestion4Yes => 'Yes';

  @override
  String get joyQuestion4No => 'No';

  @override
  String get joyQuestion5Yes => 'Yes';

  @override
  String get joyQuestion5No => 'No';

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
  String get routeResellDescription => 'Sell to someone who will appreciate it';

  @override
  String get routeDonationDescription => 'Give to those in need';

  @override
  String get routeDiscardDescription => 'Dispose of responsibly';

  @override
  String get routeRecycleDescription => 'Give materials new life';

  @override
  String get joyDeclutterComplete => 'Joy Declutter session complete!';

  @override
  String get itemLetGo => 'You\'ve chosen to let go of this item.';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get captureItemToStart => 'Capture an item to start decluttering';

  @override
  String get takePicture => 'Take the picture';

  @override
  String get itemsCaptured => 'Items captured';

  @override
  String get nextItem => 'Next item';

  @override
  String get finishDeclutter => 'Finish declutter';

  @override
  String get deepCleaningTitle => 'Deep Cleaning';

  @override
  String get continueButton => 'Continue';

  @override
  String get itemSaved => 'Item saved successfully!';

  @override
  String get timeToLetGo => 'Time to Let Go';

  @override
  String itemMarkedAs(String option) {
    return 'Item marked as $option';
  }

  @override
  String get clickToStartTimer => 'Click to Start Timer';

  @override
  String get stop => 'Stop';

  @override
  String get inProgress => 'In Progress';

  @override
  String get continueSession => 'Continue Session';

  @override
  String started(String when) {
    return 'Started $when';
  }

  @override
  String get deepCleaningSessionCompleted => 'Deep Cleaning session completed';

  @override
  String get memoriesTitle => 'Memories';

  @override
  String get memoriesEmptyTitle => 'No memories yet';

  @override
  String get memoriesEmptySubtitle =>
      'Your decluttering journey will create beautiful memories here';

  @override
  String get memoriesEmptyAction => 'Start decluttering to create memories';

  @override
  String get memoryDetailTitle => 'Memory Details';

  @override
  String memoryCreatedOn(String date) {
    return 'Created on $date';
  }

  @override
  String get memoryTypeDecluttering => 'Decluttering';

  @override
  String get memoryTypeCleaning => 'Cleaning';

  @override
  String get memoryTypeCustom => 'Custom';

  @override
  String get memoryTypeGrateful => 'Grateful';

  @override
  String get memoryTypeLesson => 'Lesson';

  @override
  String get memoryTypeCelebrate => 'Celebrate';

  @override
  String get priorityToday => 'Today';

  @override
  String get priorityThisWeek => 'This Week';

  @override
  String get prioritySomeday => 'Someday';

  @override
  String get memoryAddNote => 'Add a note';

  @override
  String get memoryEditNote => 'Edit note';

  @override
  String get memorySaveNote => 'Save note';

  @override
  String get memoryDeleteMemory => 'Delete memory';

  @override
  String get memoryDeleteConfirm =>
      'Are you sure you want to delete this memory?';

  @override
  String get memoryDeleted => 'Memory deleted';

  @override
  String get memoryNoteSaved => 'Note saved';

  @override
  String get memoryShare => 'Share memory';

  @override
  String get memoryViewPhoto => 'View photo';

  @override
  String get memoryNoPhoto => 'No photo available';

  @override
  String memoryFromItem(String itemName) {
    return 'From: $itemName';
  }

  @override
  String memoryCategory(String category) {
    return 'Category: $category';
  }

  @override
  String get memoryRecent => 'Recent';

  @override
  String get memoryThisWeek => 'This Week';

  @override
  String get memoryThisMonth => 'This Month';

  @override
  String get memoryOlder => 'Older';

  @override
  String get memoryAll => 'All';

  @override
  String get memoryFilterByType => 'Filter by type';

  @override
  String get memorySortByDate => 'Sort by date';

  @override
  String get memorySortByType => 'Sort by type';

  @override
  String get memoryCreateFromItem => 'Create memory from item';

  @override
  String get memoryCreateCustom => 'Create custom memory';

  @override
  String get language => 'Language';

  @override
  String get languageSettings => 'Language Settings';

  @override
  String get english => 'English';

  @override
  String get chinese => '中文 (Chinese)';

  @override
  String get statistics => 'Statistics';

  @override
  String get totalItemsDecluttered => 'Total Items Decluttered';

  @override
  String get sessionsCompleted => 'Sessions Completed';

  @override
  String get memoriesCreated => 'Memories Created';

  @override
  String get currentStreak => 'Current Streak';

  @override
  String days(int count) {
    return '$count days';
  }

  @override
  String get settings => 'Settings';

  @override
  String get notifications => 'Notifications';

  @override
  String get theme => 'Theme';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get systemDefault => 'System Default';

  @override
  String get support => 'Support & Information';

  @override
  String get helpAndSupport => 'Help & Support';

  @override
  String get aboutApp => 'About KeepJoy';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get rateApp => 'Rate the App';

  @override
  String get shareApp => 'Share with Friends';

  @override
  String get data => 'Data Management';

  @override
  String get exportData => 'Export Data';

  @override
  String get clearAllData => 'Clear All Data';

  @override
  String get logout => 'Log Out';

  @override
  String get version => 'Version';

  @override
  String get takeBeforePhoto => 'Take Before Photo';

  @override
  String get skipPhoto => 'Skip';

  @override
  String get takeAfterPhoto => 'Take After Photo';

  @override
  String get beforePhoto => 'Before Photo';

  @override
  String get afterPhoto => 'After Photo';

  @override
  String get captureBeforeState => 'Capture the current state of your area';

  @override
  String get captureAfterState => 'Capture the result of your cleaning';

  @override
  String get howManyItems => 'How many items did you declutter?';

  @override
  String get focusIndex => 'Focus Index';

  @override
  String get focusIndexDescription =>
      'How focused were you during the cleaning?';

  @override
  String get moodIndex => 'Mood Index';

  @override
  String get moodIndexDescription => 'How do you feel after the cleaning?';

  @override
  String get summary => 'Summary';

  @override
  String get messinessBefore => 'Messiness Before';

  @override
  String get messinessAfter => 'Messiness After';

  @override
  String get timeSpent => 'Time Spent';

  @override
  String get itemsDecluttered => 'Items Decluttered';

  @override
  String get beforeAndAfter => 'Before & After';

  @override
  String get aiAnalysis => 'AI Analysis';

  @override
  String get analyzing => 'Analyzing photos...';

  @override
  String get improvement => 'Improvement';

  @override
  String get finishCleaning => 'Finish Cleaning';

  @override
  String get finishCleaningConfirm =>
      'Are you ready to finish this cleaning session?';

  @override
  String get enterItemsCount => 'Enter number of items';

  @override
  String get done => 'Done';

  @override
  String get noPhotoTaken => 'No photo taken';

  @override
  String get messiness => 'Messiness';

  @override
  String get resellTracker => 'Resell Tracker';

  @override
  String get toSell => 'To Sell';

  @override
  String get listing => 'Listing';

  @override
  String get sold => 'Sold';

  @override
  String get platform => 'Platform';

  @override
  String get sellingPrice => 'Selling Price';

  @override
  String get soldPrice => 'Sold Price';

  @override
  String get soldDate => 'Sold Date';

  @override
  String get markAsListing => 'Mark as Listing';

  @override
  String get markAsSold => 'Mark as Sold';

  @override
  String get changeStatus => 'Change Status';

  @override
  String get enterSellingPrice => 'Enter selling price (optional)';

  @override
  String get enterSoldPrice => 'Enter sold price';

  @override
  String get soldPriceRequired => 'Sold price is required';

  @override
  String get platformXianyu => 'Xianyu';

  @override
  String get platformZhuanzhuan => 'Zhuanzhuan';

  @override
  String get platformEbay => 'eBay';

  @override
  String get platformFacebookMarketplace => 'Facebook Marketplace';

  @override
  String get platformCraigslist => 'Craigslist';

  @override
  String get platformOther => 'Other';

  @override
  String get noItemsToSell => 'No items to sell yet';

  @override
  String get noItemsListing => 'No items currently listed';

  @override
  String get noItemsSold => 'No items sold yet';

  @override
  String addedOn(String date) {
    return 'Added on $date';
  }

  @override
  String get itemDeleted => 'Item deleted';

  @override
  String get deleteItem => 'Delete Item';

  @override
  String get deleteItemConfirm => 'Are you sure you want to delete this item?';

  @override
  String get itemStatusUpdated => 'Item status updated';

  @override
  String get monthlyEarnings => 'This Month\'s Earnings';

  @override
  String get createMemory => 'Create Memory';

  @override
  String get createMemoryTitle => 'Create a Memory';

  @override
  String get whatDidThisItemBring => 'What did this item bring you?';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get addPhoto => 'Add Photo';

  @override
  String get captureSpecialMoment => 'Capture this special moment';

  @override
  String get enterItemName => 'Enter item name';

  @override
  String get selectCategory => 'Select a category';

  @override
  String get pleaseSelectCategory => 'Please select a category';

  @override
  String failedToPickImage(String error) {
    return 'Failed to pick image: $error';
  }

  @override
  String get sentimentLove => 'Love';

  @override
  String get sentimentNostalgia => 'Nostalgia';

  @override
  String get sentimentAdventure => 'Adventure';

  @override
  String get sentimentHappy => 'Happy';

  @override
  String get sentimentGrateful => 'Grateful';

  @override
  String get sentimentPeaceful => 'Peaceful';

  @override
  String get memoryDescription => 'Memory Description';

  @override
  String get describeYourMemory => 'Describe your memory with this item...';

  @override
  String get createMemoryPrompt =>
      'Would you like to create a memory for this item?';

  @override
  String get createMemoryQuestion => 'Create a memory?';

  @override
  String get skipMemory => 'Skip';

  @override
  String get aiIdentifying => 'AI Identifying...';

  @override
  String get aiSuggested => 'AI suggested';

  @override
  String get getDetailedInfo => 'Get detailed info';

  @override
  String get aiIdentificationFailed => 'AI identification failed';

  @override
  String get tryAgain => 'Try again';

  @override
  String get activityCalendar => 'Activity Calendar';

  @override
  String get declutterCalendar => 'Declutter Calendar';

  @override
  String get viewFull => 'View Full';

  @override
  String get addNew => 'Add New';

  @override
  String get startPlanningDeclutter => 'Start planning your declutter';

  @override
  String get calendarTitle => 'Declutter Calendar';

  @override
  String get calendarAddNewPlan => 'Add New Plan';

  @override
  String get calendarPlanTitleLabel => 'Plan Title';

  @override
  String get calendarPlanTitleHint => 'e.g., Clean bedroom';

  @override
  String get calendarPlanAreaLabel => 'Declutter Area';

  @override
  String get calendarPlanAreaHint => 'e.g., Bedroom';

  @override
  String get calendarUnscheduled => 'Unscheduled';

  @override
  String get noPlannedSessions => 'No planned declutter sessions';

  @override
  String get planNewSession => 'Plan New Session';

  @override
  String get add => 'Add';

  @override
  String get area => 'Area';

  @override
  String get areaHint => 'e.g., Kitchen, Bedroom, Closet';

  @override
  String get pleaseEnterArea => 'Please enter an area';

  @override
  String get date => 'Date';

  @override
  String get time => 'Time';

  @override
  String get notes => 'Notes';

  @override
  String get optional => 'optional';

  @override
  String get notesHint => 'Add any notes or reminders...';

  @override
  String get sessionCreated => 'Session created successfully';

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: 'No items',
    );
    return '$_temp0';
  }

  @override
  String get noActivityThisDay => 'No activity on this day';

  @override
  String get joyCheck => 'Joy Check';

  @override
  String get joyCheckMessage1 =>
      'Start with items you haven\'t used in the past year';

  @override
  String get joyCheckMessage2 =>
      'Focus on one small area today—a drawer, a shelf, a corner';

  @override
  String get joyCheckMessage3 =>
      'Hold each item and ask: Does this serve my life right now?';

  @override
  String get joyCheckMessage4 =>
      'Remember, letting go isn\'t losing—it\'s making space for what matters';

  @override
  String get joyCheckMessage5 =>
      'Begin with the easy items first to build momentum';

  @override
  String get joyCheckMessage6 =>
      'Your space reflects your priorities. What do you want it to say?';

  @override
  String get todaysTip => 'Today\'s Tip';

  @override
  String get todaysTip1 =>
      'Deep Cleaning Mode: Tap \'Deep Cleaning\' to capture before/after photos of your space. Start the timer and watch your transformation unfold! The app tracks your progress, measures messiness improvement using AI, and helps you see how much you\'ve accomplished. Perfect for tackling entire rooms!';

  @override
  String get todaysTip2 =>
      'Joy Declutter Method: Having trouble deciding what to keep? Try \'Joy Declutter\' from the home screen. Take a photo of any item, and we\'ll guide you through the KonMari question: \'Does this spark joy?\' Hold it in your hands and trust your feelings. If it doesn\'t bring joy, we\'ll help you let it go with gratitude.';

  @override
  String get todaysTip3 =>
      'Create Lasting Memories: Before letting go of sentimental items, create a memory! Tap the memory icon when decluttering. Capture a photo, write down what this item meant to you, and preserve the story. The physical item may be gone, but your cherished memory lives forever in the app.';

  @override
  String get todaysTip4 =>
      'Quick Sweep Timer: Need motivation? Try \'Quick Sweep\' for a 15-minute power session! Pick any area (living room, closet, desk), start the timer, and race against the clock. It turns decluttering into an exciting game. See how many items you can clear before time runs out!';

  @override
  String get todaysTip5 =>
      'Resell Tracker: Planning to sell items? Use our Resell Tracker! When letting go of items, select \'Resell\' and we\'ll add them to your selling list. Track listings, record sold prices, and watch your monthly earnings grow. Transform clutter into cash!';

  @override
  String get todaysTip6 =>
      'Quick Declutter Scan: Fastest way to declutter! Tap \'Quick Declutter\' and scan items one by one. Our AI identifies each item instantly. Simply decide: Keep or Let Go? Perfect for rapid decluttering sessions when you need to clear out fast!';

  @override
  String get welcomeTagline => 'Transform your space, spark joy in your life';

  @override
  String get getStarted => 'Get Started';

  @override
  String get alreadyHaveAccount => 'Already have an account? Sign In';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get name => 'Name';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get dontHaveAccount => 'Don\'t have an account? Sign Up';

  @override
  String get orContinueWith => 'Or continue with';

  @override
  String get google => 'Google';

  @override
  String get apple => 'Apple';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get enterYourName => 'Enter your name';

  @override
  String get emailNotEditable => 'Email cannot be changed';

  @override
  String get profileUpdateSuccess => 'Profile updated successfully';

  @override
  String profileUpdateFailed(String error) {
    return 'Update failed: $error';
  }

  @override
  String get invalidEmail => 'Invalid email address';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get signInSuccess => 'Signed in successfully';

  @override
  String get signUpSuccess => 'Account created successfully';

  @override
  String get welcomeToKeepJoy => 'Welcome to KeepJoy';

  @override
  String get resetPasswordInstruction =>
      'Enter your email address and we\'ll send you a link to reset your password.';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get resetPasswordEmailSent =>
      'Password reset email sent! Please check your inbox.';

  @override
  String get quickTip => 'Quick Tip';

  @override
  String get whatBroughtYouJoy => 'What brought you joy today?';

  @override
  String get shareYourJoy => 'Share Your Joy';

  @override
  String get monthlyReport => 'Monthly Report';

  @override
  String get declutterRhythmOverview => 'Declutter Rhythm & Achievements';

  @override
  String get deepCleaning => 'Deep Cleaning';

  @override
  String get cleaningAreas => 'Cleaning Areas';

  @override
  String get beforeAfterComparison => 'Before/After Comparison';

  @override
  String get noSessionsThisMonth => 'No sessions this month';

  @override
  String get tapAreaToViewReport => 'Tap area to view report';

  @override
  String times(Object count) {
    return '×$count';
  }

  @override
  String get todaysFocus => 'Today\'s Focus';

  @override
  String get addTask => 'Add a task...';

  @override
  String get noTasksYet => 'No tasks yet. Add your first one!';

  @override
  String get completed => 'Completed';

  @override
  String get markAsComplete => 'Mark as Complete';

  @override
  String get startDeepCleaning => 'Start Deep Cleaning';

  @override
  String get schedule => 'Schedule';

  @override
  String get delete => 'Delete';

  @override
  String get taskAdded => 'Task added';

  @override
  String get taskCompleted => 'Task completed';
}
