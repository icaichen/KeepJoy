// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get goodMorning => '早上好';

  @override
  String get goodAfternoon => '下午好';

  @override
  String get readyToSparkJoy => '准备好开启轻盈整理之旅了吗？';

  @override
  String get startYourDeclutterJourney => '开始你的断舍离旅程';

  @override
  String get chooseFlowTitle => '选择整理方式';

  @override
  String get chooseFlowSubtitle => '根据当前状态选择最合适的整理体验。';

  @override
  String get joyDeclutterFlowDescription => '帮助你做出艰难的决定';

  @override
  String get quickDeclutterFlowDescription => '只保留带来快乐的物品';

  @override
  String get deepCleaningFlowDescription => '规划、聚焦、完成大扫除';

  @override
  String get deepCleaningComparisonsTitle => '前后对比报告';

  @override
  String get deepCleaningComparisonsEmpty => '添加照片和凌乱度数据即可查看前后对比。';

  @override
  String get startAction => '开始';

  @override
  String get dailyInspiration => '每日灵感';

  @override
  String get welcomeBack => '欢迎回到你的轻盈整理之旅';

  @override
  String get continueYourJoyJourney => '继续你的旅程';

  @override
  String get tagline1 => '用正念继续整理你的空间';

  @override
  String get tagline2 => '一次一件物品，改变空间';

  @override
  String get tagline3 => '以有意识的生活创造清晰';

  @override
  String get tagline4 => '每件物品都有故事，用心对待';

  @override
  String get tagline5 => '通过用心整理建立快乐';

  @override
  String get thisMonthProgress => '最近活动';

  @override
  String get areasCleared => '清理区域';

  @override
  String get streakAchievement => '连续成就';

  @override
  String daysStreak(int count) {
    return '连续 $count 天！';
  }

  @override
  String get keepGoing => '继续加油！';

  @override
  String get dashboardCreateGoalTitle => '创建目标';

  @override
  String get dashboardGoalLabel => '目标';

  @override
  String get dashboardGoalHint => '例如：12 月底前整理 50 件物品\n或：清理厨房并拍照记录';

  @override
  String get dashboardDateOptional => '日期（可选）';

  @override
  String get dashboardTapToSelectDate => '点击选择日期';

  @override
  String get dashboardEnterGoalPrompt => '请输入目标';

  @override
  String get dashboardGoalCreated => '目标已创建';

  @override
  String get dashboardCreateAction => '创建';

  @override
  String get dashboardCreateSessionTitle => '创建计划';

  @override
  String get dashboardModeLabel => '模式';

  @override
  String get dashboardAreaHint => '例如：厨房、卧室';

  @override
  String get dashboardSelectDate => '选择日期';

  @override
  String get dashboardSelectTimeOptional => '选择时间（可选）';

  @override
  String get dashboardEnterAreaPrompt => '请输入区域名称';

  @override
  String get dashboardSessionCreated => '计划已创建';

  @override
  String get dashboardMonthlyProgress => '本月进度';

  @override
  String get dashboardYearlyProgress => '年度进度';

  @override
  String get dashboardDeclutteredLabel => '已整理物品';

  @override
  String get dashboardResellLabel => '转售收益';

  @override
  String get dashboardResellReportTitle => '二手洞察';

  @override
  String get dashboardResellReportSubtitle => '了解二手表现';

  @override
  String get dashboardMemoryLaneTitle => '年度记忆';

  @override
  String get dashboardMemoryLaneSubtitle => '重温这一年的闪光时刻';

  @override
  String get dashboardYearlyReportsTitle => '年度洞察';

  @override
  String get dashboardYearlyReportsSubtitle => '查看年度洞察';

  @override
  String get dashboardCurrentStreakTitle => '当前连击';

  @override
  String get dashboardStreakSubtitle => '天连续记录';

  @override
  String get dashboardActiveSessionTitle => '进行中的任务';

  @override
  String get dashboardTodoTitle => '待办事项';

  @override
  String get dashboardViewCalendar => '查看日历';

  @override
  String get dashboardNoTodosTitle => '暂无待办事项';

  @override
  String get dashboardNoTodosSubtitle => '点击下方按钮创建目标或任务';

  @override
  String get dashboardCalendarTitle => '计划日历';

  @override
  String get dashboardNoSessionsForDay => '这天没有计划任务';

  @override
  String get deepCleaningAnalysisTitle => '大扫除分析';

  @override
  String get dashboardSessionsLabel => '整理次数';

  @override
  String get dashboardItemsLabel => '清理物品';

  @override
  String get dashboardAverageFocusLabel => '平均专注度';

  @override
  String get dashboardAverageJoyLabel => '平均喜悦';

  @override
  String get dashboardAreasClearedLabel => '已清理区域';

  @override
  String get dashboardTotalTimeLabel => '总时间';

  @override
  String dashboardSessionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 次',
      one: '1 次',
      zero: '0 次',
    );
    return '($_temp0)';
  }

  @override
  String get dashboardCleaningHistory => '整理记录';

  @override
  String dashboardSessionTotal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 次整理',
      one: '1 次整理',
      zero: '暂无整理',
    );
    return '$_temp0';
  }

  @override
  String get dashboardFocusLabel => '专注度';

  @override
  String get dashboardJoyLabel => '轻盈感';

  @override
  String get dashboardItemsCleanedLabel => '清理物品';

  @override
  String get dashboardSessionData => '整理数据';

  @override
  String get dashboardBefore => '整理前';

  @override
  String get dashboardAfter => '整理后';

  @override
  String get dashboardSwipeToCompare => '左右滑动查看';

  @override
  String get dashboardDurationLabel => '时长';

  @override
  String dashboardDurationMinutes(String minutes) {
    return '$minutes 分钟';
  }

  @override
  String get dashboardItemsDeclutteredLabel => '整理物品数量';

  @override
  String get dashboardMessinessReducedLabel => '整洁度提升';

  @override
  String dashboardMessinessImprovement(
    int improvement,
    String before,
    String after,
  ) {
    return '$improvement%（从 $before 到 $after）';
  }

  @override
  String get dashboardNoDetailedMetrics => '未记录详细数据';

  @override
  String get dashboardNoDetailsSaved => '添加整理照片或指标，以获得更深入的洞察。';

  @override
  String get dashboardLettingGoDetailsTitle => '整理结果分布';

  @override
  String get dashboardLettingGoDetailsSubtitle => '看看保留与各去向的比例';

  @override
  String get dashboardKeptLabel => '保留';

  @override
  String get dashboardSessionDeleted => '计划已删除';

  @override
  String get dashboardDeleteSessionTitle => '删除计划？';

  @override
  String get dashboardDeleteSessionMessage => '确定要删除这个计划吗？';

  @override
  String get dashboardNotScheduled => '未设定时间';

  @override
  String get dashboardToday => '今天';

  @override
  String get dashboardTomorrow => '明天';

  @override
  String get dashboardStartNow => '开始';

  @override
  String get appTitle => 'KeepJoy';

  @override
  String get home => '首页';

  @override
  String get items => '物品';

  @override
  String get memories => '回忆';

  @override
  String get insights => '洞察';

  @override
  String get profile => '个人资料';

  @override
  String get quote1 => '\"家中只留下你认为有用或美丽的东西。\" — 威廉·莫里斯';

  @override
  String get quote2 => '\"简约是终极的精致。\" — 列奥纳多·达·芬奇';

  @override
  String get quote3 => '\"你拥有的越多，你就越忙碌。你拥有的越少，你就越自由。\" — 特蕾莎修女';

  @override
  String get quote4 => '\"生活其实很简单，但我们坚持把它复杂化。\" — 孔子';

  @override
  String get quote5 => '\"少即是多。\" — 路德维希·密斯·凡德罗';

  @override
  String get quote6 => '\"当不再需要删减任何东西时，完美才算达成。\" — 安托万·德·圣-埃克苏佩里';

  @override
  String get quote7 => '\"欲望越少，拥有越多。\" — 伊壁鸠鲁';

  @override
  String get quote8 => '\"富有不在于拥有很多，而在于需要很少。\" — 爱比克泰德';

  @override
  String get quote9 => '\"自然从不做无用之事。\" — 亚里士多德';

  @override
  String get quote10 => '\"秩序是美的基础。\" — 赛珍珠';

  @override
  String get quote11 => '\"最大的财富，是少欲而心安。\" — 柏拉图';

  @override
  String get quote12 => '\"简单，是所有优雅的核心。\" — 可可·香奈儿';

  @override
  String get quote13 => '\"活着是最罕见的事，大多数人只是存在。\" — 奥斯卡·王尔德';

  @override
  String get quote14 => '\"灵魂的成长在于减法，而非加法。\" — 古修行格言';

  @override
  String get quote15 => '\"美好的人生由理性引导，由爱点亮。\" — 伯特兰·罗素';

  @override
  String get goodEvening => '晚上好';

  @override
  String get coreModules => '核心模块';

  @override
  String get joyfulMemories => '美好回忆';

  @override
  String get viewAll => '查看全部';

  @override
  String get quickDeclutter => '心动小帮手';

  @override
  String get quickSweep => '快速\n清扫';

  @override
  String get joyDeclutter => '轻盈整理';

  @override
  String get quickDeclutterTitle => '快速整理';

  @override
  String get declutterSession => '整理进程';

  @override
  String get kept => '保留';

  @override
  String get letGo => '舍弃';

  @override
  String get scanYourNextItem => '扫描下一件物品';

  @override
  String get readyWhenYouAre => '准备好了就开始吧！';

  @override
  String get finishSession => '结束进程';

  @override
  String get takePhoto => '拍摄物品';

  @override
  String get capture => '拍摄';

  @override
  String get retakePhoto => '重新拍摄';

  @override
  String get finish => '完成';

  @override
  String get captureItem => '拍摄物品';

  @override
  String get addThisItem => '添加此物品';

  @override
  String get itemsAdded => '已添加的物品';

  @override
  String get step1CaptureItem => '步骤一 · 拍摄物品';

  @override
  String get step1Description => '拍摄物品照片，我们会协助识别与归类。';

  @override
  String get step2ReviewDetails => '步骤二 · 查看详情';

  @override
  String get itemName => '物品名称';

  @override
  String get category => '分类';

  @override
  String get identifyingItem => '正在识别物品…';

  @override
  String get unnamedItem => '未命名物品';

  @override
  String get itemAdded => '物品已添加。';

  @override
  String addedItemsViaQuickDeclutter(int count) {
    return '已通过快速整理添加$count件物品。';
  }

  @override
  String get couldNotAccessCamera => '无法打开相机。';

  @override
  String get categoryClothes => '衣物';

  @override
  String get categoryBooksDocuments => '书籍/文档';

  @override
  String get categoryElectronics => '电子产品';

  @override
  String get categoryMiscellaneous => '杂项';

  @override
  String get categorySentimental => '情感纪念品';

  @override
  String get categoryBeauty => '美妆用品';

  @override
  String get joyDeclutterTitle => '轻盈整理';

  @override
  String get joyDeclutterSubtitle => '开始引导流程';

  @override
  String get quickDeclutterSubtitle => '15分钟计时';

  @override
  String get deepCleaningSubtitle => '拍照整理空间';

  @override
  String get doesItSparkJoy => '这件物品能让你开心吗？';

  @override
  String get yes => '是的';

  @override
  String get no => '不能';

  @override
  String get next => '下一步';

  @override
  String get pleaseEnterItemName => '请输入物品名称';

  @override
  String get howToLetGo => '你想怎样处理它？';

  @override
  String get routeDiscard => '丢弃';

  @override
  String get routeDonation => '捐赠';

  @override
  String get routeRecycle => '回收';

  @override
  String get routeResell => '转售';

  @override
  String get activeQuickSweep => '进行中的快速清扫';

  @override
  String get resume => '继续';

  @override
  String get pickAnArea => '选择区域';

  @override
  String get livingRoom => '客厅';

  @override
  String get bedroom => '卧室';

  @override
  String get kitchen => '厨房';

  @override
  String get homeOffice => '书房';

  @override
  String get garage => '车库';

  @override
  String get closet => '衣橱';

  @override
  String get bathroom => '浴室';

  @override
  String get study => '书房';

  @override
  String get customArea => '自定义区域…';

  @override
  String get nameYourArea => '命名您的区域';

  @override
  String get cancel => '取消';

  @override
  String get save => '保存';

  @override
  String get quickSweepTimer => '快速清扫';

  @override
  String get minimize => '最小化';

  @override
  String get complete => '完成';

  @override
  String get recentActivities => '最近活动';

  @override
  String get streak => '连续天数';

  @override
  String get itemDecluttered => '已整理物品';

  @override
  String get newValueCreated => '新生价值';

  @override
  String get roomCleaned => '已清洁房间';

  @override
  String get memoryCreated => '回忆创建成功';

  @override
  String get itemsResell => '待转售物品';

  @override
  String get itemsDashboardComingSoon => '物品仪表板即将推出';

  @override
  String get memoriesDashboardComingSoon => '回忆仪表板即将推出';

  @override
  String get insightsDashboardComingSoon => '洞察仪表板即将推出';

  @override
  String get ok => '好的';

  @override
  String get startDeclutter => '开始整理';

  @override
  String get startOrganizing => '开始整理';

  @override
  String get joyDeclutterModeSubtitle => '一次一件，用心感受';

  @override
  String get quickDeclutterModeSubtitle => '快速拍照，批量处理';

  @override
  String get deepCleaningModeSubtitle => '专注整理，焕然一新';

  @override
  String get activitySeparator => ' · ';

  @override
  String get noRecentActivity => '近期还没有活动记录，继续加油！';

  @override
  String get justNow => '刚刚';

  @override
  String minsAgo(int count) {
    return '$count分钟前';
  }

  @override
  String hoursAgo(int count) {
    return '$count小时前';
  }

  @override
  String daysAgo(int count) {
    return '$count天前';
  }

  @override
  String itemsLetGo(int count) {
    return '已释放物品：$count';
  }

  @override
  String sessions(int count) {
    return '$count 次';
  }

  @override
  String spaceFreed(String amount) {
    return '释放空间：$amount 平方米';
  }

  @override
  String get secondHandTracker => '二手物品追踪';

  @override
  String get viewDetails => '查看详情';

  @override
  String get close => '关闭';

  @override
  String get cleaningLegendButton => '颜色说明';

  @override
  String get cleaningLegendTitle => '整理区域颜色说明';

  @override
  String get cleaningLegendNone => '0 次：尚未开始';

  @override
  String get cleaningLegendLight => '1-2 次：轻度整理';

  @override
  String get cleaningLegendMomentum => '3-4 次：逐步推进';

  @override
  String get cleaningLegendSteady => '5-7 次：稳步推进';

  @override
  String get cleaningLegendHighFocus => '8-10 次：高频整理';

  @override
  String get cleaningLegendMaintenance => '11 次以上：持续维护';

  @override
  String get joyDeclutterCaptureTitle => '拍摄物品';

  @override
  String get nextStep => '下一步';

  @override
  String get joyQuestionDescription => '把物品拿在手中，问问自己：它能为我的生活带来喜悦吗？';

  @override
  String joyQuestionProgress(int current, int total) {
    return '问题 $current/$total';
  }

  @override
  String get joyQuestion1Prompt => '你上次使用这件物品是什么时候？';

  @override
  String get joyQuestion2Prompt => '你有其他类似但更喜欢的物品吗？';

  @override
  String get joyQuestion3Prompt => '如果今天重新购买，你还会选择它吗？';

  @override
  String get joyQuestion4Prompt => '它是否符合你当前的生活方式和目标？';

  @override
  String get joyQuestion5Prompt => '你是否因为花了太多钱而不舍得放手？';

  @override
  String get joyQuestionOptionLessThanMonth => '不到1个月';

  @override
  String get joyQuestionOption1To6Months => '1-6个月';

  @override
  String get joyQuestionOption6To12Months => '6-12个月';

  @override
  String get joyQuestionOptionMoreThanYear => '超过1年';

  @override
  String get joyQuestion2Yes => '是的';

  @override
  String get joyQuestion2No => '没有';

  @override
  String get joyQuestion3Yes => '会的';

  @override
  String get joyQuestion3No => '不会';

  @override
  String get joyQuestion4Yes => '符合';

  @override
  String get joyQuestion4No => '不符合';

  @override
  String get joyQuestion5Yes => '是的';

  @override
  String get joyQuestion5No => '不是';

  @override
  String get keepItem => '是的，保留';

  @override
  String get letGoItem => '不，放手';

  @override
  String get itemKept => '已保留物品！轻盈整理完成。';

  @override
  String get selectLetGoRoute => '您希望如何处理这件物品？';

  @override
  String get routeResellDescription => '卖给会珍惜它的人';

  @override
  String get routeDonationDescription => '送给有需要的人';

  @override
  String get routeDiscardDescription => '负责任地处理';

  @override
  String get routeRecycleDescription => '让材料获得新生';

  @override
  String get joyDeclutterComplete => '轻盈整理完成！';

  @override
  String get itemLetGo => '您已选择放手这件物品。';

  @override
  String get comingSoon => '即将推出';

  @override
  String get captureItemToStart => '拍摄物品，让我们引导你做出决定';

  @override
  String get takePicture => '拍摄物品';

  @override
  String get itemsCaptured => '已拍摄物品';

  @override
  String get nextItem => '下一个物品';

  @override
  String get finishDeclutter => '完成整理';

  @override
  String get deepCleaningTitle => '大扫除';

  @override
  String get continueButton => '继续';

  @override
  String get itemSaved => '物品已成功保存！';

  @override
  String get timeToLetGo => '是时候放手了';

  @override
  String itemMarkedAs(String option) {
    return '物品已标记为$option';
  }

  @override
  String get clickToStartTimer => '点击开始计时';

  @override
  String get stop => '停止';

  @override
  String get inProgress => '进行中';

  @override
  String get continueSession => '继续进程';

  @override
  String started(String when) {
    return '开始于$when';
  }

  @override
  String get deepCleaningSessionCompleted => '大扫除进程已完成';

  @override
  String get memoriesTitle => '回忆';

  @override
  String get memoriesEmptyTitle => '还没有回忆';

  @override
  String get memoriesEmptySubtitle => '您的整理之旅将在这里创造美好的回忆';

  @override
  String get memoriesEmptyAction => '开始整理以创造回忆';

  @override
  String get memoryDetailTitle => '回忆详情';

  @override
  String memoryCreatedOn(String date) {
    return '创建于 $date';
  }

  @override
  String get memoryTypeDecluttering => '整理';

  @override
  String get memoryTypeCleaning => '清洁';

  @override
  String get memoryTypeCustom => '自定义';

  @override
  String get memoryTypeGrateful => '感恩';

  @override
  String get memoryTypeLesson => '教训';

  @override
  String get memoryTypeCelebrate => '庆祝';

  @override
  String get priorityToday => '今天';

  @override
  String get priorityThisWeek => '本周';

  @override
  String get prioritySomeday => '未来';

  @override
  String get memoryAddNote => '添加备注';

  @override
  String get memoryEditNote => '编辑备注';

  @override
  String get memorySaveNote => '保存备注';

  @override
  String get memoryDeleteMemory => '删除回忆';

  @override
  String get memoryDeleteConfirm => '您确定要删除这个回忆吗？';

  @override
  String get memoryDeleted => '回忆已删除';

  @override
  String get memoryNoteSaved => '备注已保存';

  @override
  String get memoryShare => '分享回忆';

  @override
  String get memoryViewPhoto => '查看照片';

  @override
  String get memoryNoPhoto => '暂无照片';

  @override
  String memoryFromItem(String itemName) {
    return '来自：$itemName';
  }

  @override
  String memoryCategory(String category) {
    return '分类：$category';
  }

  @override
  String get memoryRecent => '最近';

  @override
  String get memoryThisWeek => '本周';

  @override
  String get memoryThisMonth => '本月';

  @override
  String get memoryOlder => '更早';

  @override
  String get memoryAll => '全部';

  @override
  String get memoryFilterByType => '按类型筛选';

  @override
  String get memorySortByDate => '按日期排序';

  @override
  String get memorySortByType => '按类型排序';

  @override
  String get memoryCreateFromItem => '从物品创建回忆';

  @override
  String get memoryCreateCustom => '创建自定义回忆';

  @override
  String get language => '语言';

  @override
  String get languageSettings => '语言设置';

  @override
  String get english => 'English (英语)';

  @override
  String get chinese => '中文';

  @override
  String get statistics => '统计数据';

  @override
  String get totalItemsDecluttered => '已整理物品总数';

  @override
  String get sessionsCompleted => '已完成会话';

  @override
  String get memoriesCreated => '已创建回忆';

  @override
  String get currentStreak => '当前连续天数';

  @override
  String days(int count) {
    return '$count 天';
  }

  @override
  String get settings => '设置';

  @override
  String get notifications => '通知';

  @override
  String get theme => '主题';

  @override
  String get darkMode => '深色模式';

  @override
  String get lightMode => '浅色模式';

  @override
  String get systemDefault => '跟随系统';

  @override
  String get support => '支持与信息';

  @override
  String get helpAndSupport => '帮助与支持';

  @override
  String get aboutApp => '关于 KeepJoy';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get termsOfService => '服务条款';

  @override
  String get rateApp => '评价 KeepJoy';

  @override
  String get shareApp => '分享 KeepJoy';

  @override
  String get notificationsPermissionDenied =>
      '目前无法启用通知，请到系统设置中为 KeepJoy 开启通知权限。';

  @override
  String get reminderGeneralTitle => 'KeepJoy 温馨提醒';

  @override
  String get reminderJoyNudge1 => '花一点时间感谢一件物品，来一场 Joy Dedclutter 吧？';

  @override
  String get reminderJoyNudge2 => '家里想念心动感，轻松整理一个角落，让空间再次发光。';

  @override
  String get reminderJoyNudge3 => '小步伐也能带来清晰，现在拍下一件物品开始 Joy Dedclutter。';

  @override
  String get reminderPendingTask1 => '还有整理计划未完成，安排一个时间继续吧。';

  @override
  String get reminderPendingTask2 => '目标还在等你，抽空续上轻盈整理旅程。';

  @override
  String get reminderActiveSessionTitle => '大扫除仍在进行';

  @override
  String get reminderActiveSessionBody => '你的大扫除流程还没结束，回来继续并记录成果吧。';

  @override
  String get memoryNoDescription => '这段回忆目前还没有补充说明。';

  @override
  String get premiumRequiredTitle => 'KeepJoy 高级版';

  @override
  String get premiumRequiredMessage => '7 天试用已结束，升级即可继续使用大扫除流程、完整报表与提醒功能。';

  @override
  String get premiumExpiredMessage => '您的订阅已过期或需要恢复。请续订或恢复购买以继续使用高级功能。';

  @override
  String get premiumLockedOverlay => '升级以查看完整洞察';

  @override
  String get premiumMembership => '高级会员';

  @override
  String get premiumMembershipDescription => '解锁专属仪式、更深入的洞察和进阶自动化。';

  @override
  String get upgradeToPremium => '升级为 KeepJoy 高级版';

  @override
  String get paywallTitle => 'KeepJoy 高级版';

  @override
  String get paywallDescription => '选择一个订阅方案，解锁完整的轻盈整理工具。';

  @override
  String get paywallLoading => '正在加载订阅方案...';

  @override
  String get paywallUnavailable => '当前无法获取订阅信息，请稍后重试。';

  @override
  String get paywallPurchaseButton => '立即订阅';

  @override
  String get paywallRestorePurchases => '恢复购买';

  @override
  String get paywallPurchaseSuccess => '高级版已解锁，尽情享用 KeepJoy！';

  @override
  String get paywallPurchaseFailure => '无法完成购买，请稍后再试。';

  @override
  String get paywallRestoreSuccess => '已恢复之前的购买。';

  @override
  String get paywallRestoreFailure => '暂时没有可恢复的购买记录。';

  @override
  String get restorePurchases => '恢复购买';

  @override
  String get subscribeNow => '立即订阅';

  @override
  String get mostPopular => '最受欢迎';

  @override
  String get recommended => '推荐';

  @override
  String get noOfferingsAvailable => '暂无订阅选项';

  @override
  String get selectPlan => '选择方案';

  @override
  String get purchaseSuccessful => '购买成功';

  @override
  String get purchasesRestored => '购买已恢复';

  @override
  String get freeTrial => '免费试用';

  @override
  String get trialActive => '试用中';

  @override
  String get premiumActive => '高级版已激活';

  @override
  String renewsOn(String date) {
    return '续订日期：$date';
  }

  @override
  String get featureMemoriesPage => '心动回忆';

  @override
  String get featureMemoriesPageDesc => '记录并珍藏你的断舍离回忆';

  @override
  String get featureMemoryLane => '年度记忆';

  @override
  String get featureMemoryLaneDesc => '可视化你的整理旅程时光线';

  @override
  String get featureResellTrends => '二手趋势';

  @override
  String get featureResellTrendsDesc => '追踪物品的潜在转售价值';

  @override
  String get featureYearlyChronicle => '心动年鉴';

  @override
  String get featureYearlyChronicleDesc => '大扫除的详细分析报告';

  @override
  String trialDays(String days) {
    return '$days天免费试用';
  }

  @override
  String startFreeTrial(String days) {
    return '开始$days天免费试用';
  }

  @override
  String get billedYearlyAfterTrial => '试用结束后按年计费';

  @override
  String get billedMonthlyAfterTrial => '试用结束后按月计费';

  @override
  String get unlockPremium => '解锁高级功能';

  @override
  String get premiumFeatures => '高级功能';

  @override
  String savePercent(String percent) {
    return '节省$percent%';
  }

  @override
  String get perMonth => '/月';

  @override
  String get perYear => '/年';

  @override
  String get monthlyPlan => '月度方案';

  @override
  String get annualPlan => '年度方案';

  @override
  String get changePlansAnytime => '随时更改或取消订阅';

  @override
  String get featureExportData => '导出数据';

  @override
  String get featureAdvancedInsights => '高级洞察';

  @override
  String get featureCustomReminders => '自定义提醒';

  @override
  String get featureSessionResume => '恢复会话';

  @override
  String get startSubscription => '开始订阅';

  @override
  String get subscriptionTerms => '订阅将自动续订，除非在当前周期结束前至少24小时关闭自动续订。';

  @override
  String get subscriptionSuccess => '订阅成功！';

  @override
  String get data => '数据管理';

  @override
  String get exportData => '导出数据';

  @override
  String get clearAllData => '清除所有数据';

  @override
  String get storage => '储存空间';

  @override
  String get imageCache => '图片缓存';

  @override
  String get clearCache => '清空缓存';

  @override
  String get clearCacheSubtitle => '删除所有缓存图片';

  @override
  String get clearCacheConfirmTitle => '确定清空缓存？';

  @override
  String get clearCacheConfirmMessage => '这将删除所有缓存图片。需要时会重新下载。';

  @override
  String get clear => '清空';

  @override
  String get deleteAccount => '删除账号';

  @override
  String get deleteAccountConfirmTitle => '确定删除账号？';

  @override
  String get deleteAccountConfirmMessage =>
      '这将永久删除您的账号及所有数据，包括回忆、整理物品和照片。此操作无法撤销。';

  @override
  String get deleteAccountButton => '删除我的账号';

  @override
  String get deletingAccount => '正在删除账号...';

  @override
  String get accountDeleted => '账号已成功删除';

  @override
  String get logout => '登出';

  @override
  String get version => '版本';

  @override
  String get takeBeforePhoto => '拍摄清理前照片';

  @override
  String get skipPhoto => '跳过';

  @override
  String get takeAfterPhoto => '拍摄清理后照片';

  @override
  String get beforePhoto => '清理前';

  @override
  String get afterPhoto => '清理后';

  @override
  String get captureBeforeState => '拍摄区域当前状态';

  @override
  String get captureAfterState => '拍摄清理后的成果';

  @override
  String get howManyItems => '您整理了多少件物品？';

  @override
  String get focusIndex => '专注度';

  @override
  String get focusIndexDescription => '清理过程中您的专注程度如何？';

  @override
  String get moodIndex => '心情指数';

  @override
  String get moodIndexDescription => '清理后您的心情如何？';

  @override
  String get summary => '总结';

  @override
  String get messinessBefore => '清理前凌乱度';

  @override
  String get messinessAfter => '清理后凌乱度';

  @override
  String get timeSpent => '用时';

  @override
  String get itemsDecluttered => '已整理物品';

  @override
  String get beforeAndAfter => '前后对比';

  @override
  String get aiAnalysis => 'AI 分析';

  @override
  String get analyzing => '正在分析照片...';

  @override
  String get improvement => '改善程度';

  @override
  String get finishCleaning => '结束清理';

  @override
  String get finishCleaningConfirm => '您确定要结束这次清理吗？';

  @override
  String get enterItemsCount => '输入物品数量';

  @override
  String get done => '完成';

  @override
  String get noPhotoTaken => '未拍摄照片';

  @override
  String get messiness => '凌乱度';

  @override
  String get resellTracker => '转售追踪';

  @override
  String get toSell => '待售';

  @override
  String get listing => '在售';

  @override
  String get sold => '售出';

  @override
  String get platform => '平台';

  @override
  String get sellingPrice => '售价';

  @override
  String get soldPrice => '成交价';

  @override
  String get soldDate => '售出日期';

  @override
  String get markAsListing => '标记为在售';

  @override
  String get markAsSold => '标记为售出';

  @override
  String get changeStatus => '更改状态';

  @override
  String get enterSellingPrice => '输入售价（可选）';

  @override
  String get enterSoldPrice => '输入成交价';

  @override
  String get soldPriceRequired => '成交价为必填项';

  @override
  String get platformXianyu => '闲鱼';

  @override
  String get platformZhuanzhuan => '转转';

  @override
  String get platformEbay => 'eBay';

  @override
  String get platformFacebookMarketplace => 'Facebook Marketplace';

  @override
  String get platformCraigslist => 'Craigslist';

  @override
  String get platformOther => '其他';

  @override
  String get noItemsToSell => '暂无待售物品';

  @override
  String get noItemsListing => '暂无在售物品';

  @override
  String get noItemsSold => '暂无售出物品';

  @override
  String addedOn(String date) {
    return '添加于 $date';
  }

  @override
  String get itemDeleted => '物品已删除';

  @override
  String get deleteItem => '删除物品';

  @override
  String get deleteItemConfirm => '确定要删除此物品吗？';

  @override
  String get itemStatusUpdated => '物品状态已更新';

  @override
  String get monthlyEarnings => '本月收入';

  @override
  String get createMemory => '创建回忆';

  @override
  String get createMemoryTitle => '创建回忆';

  @override
  String get whatDidThisItemBring => '这件物品给你带来了什么？';

  @override
  String get haveYouLetGoOfThisItem => '你是否已经放手这件物品？';

  @override
  String get selectStatus => '选择物品状态';

  @override
  String get chooseFromGallery => '从相册选择';

  @override
  String get addPhoto => '添加照片';

  @override
  String get captureSpecialMoment => '捕捉这个特别的时刻';

  @override
  String get enterItemName => '输入物品名称';

  @override
  String get selectCategory => '选择分类';

  @override
  String get pleaseSelectCategory => '请选择一个分类';

  @override
  String failedToPickImage(String error) {
    return '选取图片失败：$error';
  }

  @override
  String get sentimentLove => '爱';

  @override
  String get sentimentNostalgia => '怀念';

  @override
  String get sentimentAdventure => '冒险';

  @override
  String get sentimentHappy => '快乐';

  @override
  String get sentimentGrateful => '感激';

  @override
  String get sentimentPeaceful => '平静';

  @override
  String get memoryDescription => '回忆描述';

  @override
  String get describeYourMemory => '描述你与这件物品的回忆...';

  @override
  String get createMemoryPrompt => '要为这件物品创建回忆吗？';

  @override
  String get createMemoryQuestion => '创建回忆？';

  @override
  String get skipMemory => '跳过';

  @override
  String get aiIdentifying => 'AI识别中...';

  @override
  String get aiSuggested => 'AI建议';

  @override
  String get getDetailedInfo => '获取详细信息';

  @override
  String get aiIdentificationFailed => 'AI识别失败';

  @override
  String get tryAgain => '重试';

  @override
  String get activityCalendar => '活动日历';

  @override
  String get declutterCalendar => '整理日历';

  @override
  String get viewFull => '查看全部';

  @override
  String get addNew => '添加新计划';

  @override
  String get startPlanningDeclutter => '开始规划你的整理计划';

  @override
  String get calendarTitle => '整理日历';

  @override
  String get calendarAddNewPlan => '添加新计划';

  @override
  String get calendarPlanTitleLabel => '计划标题';

  @override
  String get calendarPlanTitleHint => '例如：整理卧室';

  @override
  String get calendarPlanAreaLabel => '整理区域';

  @override
  String get calendarPlanAreaHint => '例如：卧室';

  @override
  String get calendarUnscheduled => '待安排';

  @override
  String get noPlannedSessions => '暂无计划的整理任务';

  @override
  String get planNewSession => '计划新任务';

  @override
  String get add => '添加';

  @override
  String get area => '区域';

  @override
  String get areaHint => '例如：厨房、卧室、衣柜';

  @override
  String get pleaseEnterArea => '请输入区域';

  @override
  String get date => '日期';

  @override
  String get time => '时间';

  @override
  String get notes => '备注';

  @override
  String get optional => '可选';

  @override
  String get notesHint => '添加备注或提醒...';

  @override
  String get sessionCreated => '任务创建成功';

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件物品',
      one: '1件物品',
      zero: '没有物品',
    );
    return '$_temp0';
  }

  @override
  String get noActivityThisDay => '这天没有活动';

  @override
  String get joyCheck => '轻盈提醒';

  @override
  String get joyCheckMessage1 => '从一年内没用过的物品开始整理';

  @override
  String get joyCheckMessage2 => '今天专注于一个小区域——一个抽屉、一个架子、一个角落';

  @override
  String get joyCheckMessage3 => '拿起每件物品问自己：它现在还服务于我的生活吗？';

  @override
  String get joyCheckMessage4 => '记住，放手不是失去——而是为重要的事物腾出空间';

  @override
  String get joyCheckMessage5 => '从简单的物品开始，建立整理的动力';

  @override
  String get joyCheckMessage6 => '你的空间反映你的优先事项。你想让它说什么？';

  @override
  String get todaysTip => '今日建议';

  @override
  String get todaysTip1 =>
      '大扫除模式：点击「大扫除」拍摄空间的前后对比照。启动计时器，见证你的转变！应用会追踪你的进度，使用AI测量混乱度改善，让你看到自己完成了多少。非常适合整理整个房间！';

  @override
  String get todaysTip2 =>
      '快乐整理法：难以决定保留什么？试试首页的「快乐整理」。给物品拍照，我们会引导你完成近藤麻理惠的提问：「这能带给我快乐吗？」把它拿在手中，相信你的感觉。如果它不能带来快乐，我们会帮你感恩地放手。';

  @override
  String get todaysTip3 =>
      '创建永久回忆：在放手有纪念意义的物品前，创建回忆！整理时点击回忆图标。拍摄照片，写下这件物品对你的意义，保存故事。实体物品可能消失，但你珍贵的回忆永远留在应用中。';

  @override
  String get todaysTip4 =>
      '快速扫除计时器：需要动力？试试「快速扫除」，进行15分钟的高效整理！选择任何区域（客厅、衣柜、书桌），启动计时器，与时钟赛跑。它让整理变成激动人心的游戏。看看你能在时间用完前清理多少物品！';

  @override
  String get todaysTip5 =>
      '转卖追踪器：计划出售物品？使用我们的转卖追踪器！在放手物品时，选择「转卖」，我们会将它们添加到你的待售列表。追踪上架、记录售价，观看你的月收入增长。把杂物变成现金！';

  @override
  String get todaysTip6 =>
      '快速整理扫描：最快的整理方式！点击「快速整理」逐个扫描物品。我们的AI会立即识别每件物品。只需决定：保留还是放手？非常适合需要快速清理的快速整理场景！';

  @override
  String get welcomeTagline => '整理你的空间，点燃生活的快乐';

  @override
  String get getStarted => '开始使用';

  @override
  String get alreadyHaveAccount => '已有账号？登录';

  @override
  String get signIn => '登录';

  @override
  String get signUp => '注册';

  @override
  String get email => '邮箱';

  @override
  String get password => '密码';

  @override
  String get confirmPassword => '确认密码';

  @override
  String get name => '姓名';

  @override
  String get forgotPassword => '忘记密码？';

  @override
  String get dontHaveAccount => '还没有账号？注册';

  @override
  String get orContinueWith => '或使用以下方式继续';

  @override
  String get google => 'Google';

  @override
  String get apple => 'Apple';

  @override
  String get emailRequired => '请输入邮箱';

  @override
  String get passwordRequired => '密码是必需的';

  @override
  String get nameRequired => '请输入姓名';

  @override
  String get editProfile => '编辑资料';

  @override
  String get enterYourName => '输入你的名字';

  @override
  String get emailNotEditable => '邮箱无法修改';

  @override
  String get profileUpdateSuccess => '资料已更新';

  @override
  String profileUpdateFailed(String error) {
    return '更新失败：$error';
  }

  @override
  String get invalidEmail => '邮箱格式不正确';

  @override
  String get passwordTooShort => '密码至少需要6个字符';

  @override
  String get passwordsDoNotMatch => '密码不匹配';

  @override
  String get signInSuccess => '登录成功';

  @override
  String get signUpSuccess => '注册成功';

  @override
  String get welcomeToKeepJoy => '欢迎来到KeepJoy';

  @override
  String get resetPassword => '重置密码';

  @override
  String get resetPasswordInstruction => '输入您的邮箱地址，我们将向您发送重置密码的链接。';

  @override
  String get resetPasswordNewPassword => '请在下方输入您的新密码';

  @override
  String get resetPasswordSuccess => '密码重置成功！您现在可以使用新密码登录。';

  @override
  String get resetPasswordFailed => '密码重置失败。请重试。';

  @override
  String get resetPasswordInvalidCode => '重置代码无效或已过期。请重新申请密码重置。';

  @override
  String get sendResetLink => '发送重置链接';

  @override
  String get resetPasswordEmailSent => '密码重置邮件已发送！请检查您的收件箱。';

  @override
  String get passwordMinLength => '密码至少需要6个字符';

  @override
  String get networkError => '网络错误。请检查您的连接后重试。';

  @override
  String get quickTip => '快速提示';

  @override
  String get whatBroughtYouJoy => '哪些物品值得为其创建回忆？';

  @override
  String get shareYourJoy => '分享你的快乐';

  @override
  String get monthlyReport => '本月整理报告';

  @override
  String get declutterRhythmOverview => '整理节奏与成果一览';

  @override
  String get deepCleaning => '极速大扫除';

  @override
  String get cleaningAreas => '整理区域';

  @override
  String get beforeAfterComparison => '前后对比';

  @override
  String get noSessionsThisMonth => '本月暂无整理记录';

  @override
  String get tapAreaToViewReport => '点击区域查看详细报告';

  @override
  String times(Object count) {
    return '×$count';
  }

  @override
  String get todaysFocus => '今日计划';

  @override
  String get addTask => '添加新任务...';

  @override
  String get noTasksYet => '暂无任务，添加第一个吧！';

  @override
  String get completed => '已完成';

  @override
  String get markAsComplete => '标记为完成';

  @override
  String get startDeepCleaning => '开始大扫除';

  @override
  String get schedule => '安排时间';

  @override
  String get delete => '删除';

  @override
  String get taskAdded => '任务已添加';

  @override
  String get taskCompleted => '任务已完成';
}
