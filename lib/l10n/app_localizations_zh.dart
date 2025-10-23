// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

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
  String get quote1 => '\"我们居住的空间应该是为现在的自己，而不是过去的自己。\" — 近藤麻理惠';

  @override
  String get quote2 => '\"外在的秩序有助于内心的平静。\" — 格雷琴·鲁宾';

  @override
  String get quote3 => '\"家中只留下你认为有用或美丽的东西。\" — 威廉·莫里斯';

  @override
  String get quote4 => '\"杂乱不仅仅是物质上的，还包括旧观念、有毒的关系和坏习惯。\" — 埃莉诺·布朗';

  @override
  String get quote5 => '\"清洁的目的不仅仅是清洁，而是在这个环境中感到幸福。\" — 近藤麻理惠';

  @override
  String get quote6 => '\"简约是终极的精致。\" — 列奥纳多·达·芬奇';

  @override
  String get quote7 => '\"当你的房间干净整洁时，你别无选择，只能审视自己的内心状态。\" — 近藤麻理惠';

  @override
  String get quote8 => '\"清除杂物，为自己腾出空间。\" — 玛格达莱娜·范登堡';

  @override
  String get quote9 => '\"打造理想生活的第一步是摆脱你不需要的一切。\" — 约书亚·贝克尔';

  @override
  String get quote10 => '\"干净的房子是浪费生命的标志。\" — 佚名';

  @override
  String get quote11 => '\"你拥有的越多，你就越忙碌。你拥有的越少，你就越自由。\" — 特蕾莎修女';

  @override
  String get quote12 => '\"生活其实很简单，但我们坚持把它复杂化。\" — 孔子';

  @override
  String get quote13 => '\"极简主义不是缺少什么，而是恰到好处。\" — 尼古拉斯·伯罗斯';

  @override
  String get quote14 => '\"你的家应该讲述你是谁的故事，是你所爱之物的集合。\" — 内特·伯库斯';

  @override
  String get quote15 => '\"摆脱所有无关紧要的东西，让你记起自己是谁。\" — 佚名';

  @override
  String get goodEvening => '晚上好';

  @override
  String get coreModules => '核心模块';

  @override
  String get joyfulMemories => '美好回忆';

  @override
  String get viewAll => '查看全部';

  @override
  String get quickDeclutter => '快速\n整理';

  @override
  String get quickSweep => '快速\n清扫';

  @override
  String get joyDeclutter => '喜悦\n整理';

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
  String get categoryBooks => '书籍';

  @override
  String get categoryPapers => '文件';

  @override
  String get categoryMiscellaneous => '杂项';

  @override
  String get categorySentimental => '情感纪念品';

  @override
  String get categoryBeauty => '美妆用品';

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
  String get thisMonthProgress => '本月进度';

  @override
  String itemsLetGo(int count) {
    return '已释放物品：$count';
  }

  @override
  String sessions(int count) {
    return '整理次数：$count';
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
  String get joyDeclutterTitle => '喜悦整理';

  @override
  String get joyDeclutterCaptureTitle => '拍摄物品';

  @override
  String get nextStep => '下一步';

  @override
  String get doesItSparkJoy => '这件物品能带给你喜悦吗？';

  @override
  String get joyQuestionDescription => '把物品拿在手中，问问自己：它能为我的生活带来喜悦吗？';

  @override
  String get keepItem => '是的，保留';

  @override
  String get letGoItem => '不，放手';

  @override
  String get itemKept => '已保留物品！喜悦整理完成。';

  @override
  String get selectLetGoRoute => '您希望如何处理这件物品？';

  @override
  String get routeResell => '转售';

  @override
  String get routeResellDescription => '卖给会珍惜它的人';

  @override
  String get routeDonation => '捐赠';

  @override
  String get routeDonationDescription => '送给有需要的人';

  @override
  String get routeDiscard => '丢弃';

  @override
  String get routeDiscardDescription => '负责任地处理';

  @override
  String get routeRecycle => '回收';

  @override
  String get routeRecycleDescription => '让材料获得新生';

  @override
  String get joyDeclutterComplete => '喜悦整理完成！';

  @override
  String get itemLetGo => '您已选择放手这件物品。';

  @override
  String comingSoon(String title) {
    return '$title — 即将推出';
  }
}
