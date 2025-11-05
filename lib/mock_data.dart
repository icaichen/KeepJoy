import 'package:keepjoy_app/models/planned_session.dart';
import 'package:keepjoy_app/models/deep_cleaning_session.dart';
import 'package:keepjoy_app/models/declutter_item.dart';
import 'package:keepjoy_app/models/memory.dart';
import 'package:keepjoy_app/models/resell_item.dart';
import 'package:keepjoy_app/models/activity_entry.dart';

class MockData {
  static const String userId = 'mock-user-id';

  // Mock Planned Sessions
  static List<PlannedSession> getPlannedSessions() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return [
      // Today's sessions
      PlannedSession(
        id: 'session-1',
        userId: userId,
        title: 'Kitchen Deep Clean',
        area: 'Kitchen',
        scheduledDate: today,
        scheduledTime: '10:00 AM',
        createdAt: now.subtract(const Duration(days: 1)),
        priority: TaskPriority.today,
        mode: SessionMode.deepCleaning,
        isCompleted: false,
      ),
      PlannedSession(
        id: 'session-2',
        userId: userId,
        title: 'Living Room Declutter',
        area: 'Living Room',
        scheduledDate: today,
        scheduledTime: '2:00 PM',
        createdAt: now.subtract(const Duration(days: 1)),
        priority: TaskPriority.today,
        mode: SessionMode.joyDeclutter,
        isCompleted: false,
      ),
      PlannedSession(
        id: 'session-3',
        userId: userId,
        title: 'Declutter 10 items',
        area: 'General',
        scheduledDate: today,
        createdAt: now.subtract(const Duration(days: 2)),
        priority: TaskPriority.today,
        mode: SessionMode.deepCleaning,
        goal: '10 items',
        isCompleted: false,
      ),
      
      // Tomorrow's sessions
      PlannedSession(
        id: 'session-4',
        userId: userId,
        title: 'Bedroom Deep Clean',
        area: 'Bedroom',
        scheduledDate: today.add(const Duration(days: 1)),
        scheduledTime: '9:00 AM',
        createdAt: now,
        priority: TaskPriority.thisWeek,
        mode: SessionMode.deepCleaning,
        isCompleted: false,
      ),
      PlannedSession(
        id: 'session-5',
        userId: userId,
        title: 'Closet Quick Declutter',
        area: 'Closet',
        scheduledDate: today.add(const Duration(days: 1)),
        createdAt: now,
        priority: TaskPriority.thisWeek,
        mode: SessionMode.quickDeclutter,
        isCompleted: false,
      ),

      // Completed sessions
      PlannedSession(
        id: 'session-6',
        userId: userId,
        title: 'Bathroom Deep Clean',
        area: 'Bathroom',
        scheduledDate: today.subtract(const Duration(days: 1)),
        scheduledTime: '3:00 PM',
        createdAt: now.subtract(const Duration(days: 3)),
        priority: TaskPriority.today,
        mode: SessionMode.deepCleaning,
        isCompleted: true,
        completedAt: today.subtract(const Duration(days: 1)),
      ),
      PlannedSession(
        id: 'session-7',
        userId: userId,
        title: 'Garage Quick Sort',
        area: 'Garage',
        scheduledDate: today.subtract(const Duration(days: 2)),
        createdAt: now.subtract(const Duration(days: 4)),
        priority: TaskPriority.thisWeek,
        mode: SessionMode.quickDeclutter,
        isCompleted: true,
        completedAt: today.subtract(const Duration(days: 2)),
        goal: '15 items',
      ),

      // Future sessions
      PlannedSession(
        id: 'session-8',
        userId: userId,
        title: 'Office Organization',
        area: 'Office',
        scheduledDate: today.add(const Duration(days: 5)),
        scheduledTime: '1:00 PM',
        createdAt: now,
        priority: TaskPriority.someday,
        mode: SessionMode.joyDeclutter,
        isCompleted: false,
      ),
    ];
  }

  // Mock Deep Cleaning Sessions
  static List<DeepCleaningSession> getDeepCleaningSessions() {
    final now = DateTime.now();

    return [
      DeepCleaningSession(
        id: 'deep-1',
        userId: userId,
        area: 'Kitchen',
        startTime: now.subtract(const Duration(days: 1)),
        createdAt: now.subtract(const Duration(days: 1)),
        elapsedSeconds: 1800, // 30 minutes
        itemsCount: 12,
        focusIndex: 8,
        moodIndex: 9,
        beforeMessinessIndex: 7.5,
        afterMessinessIndex: 2.0,
      ),
      DeepCleaningSession(
        id: 'deep-2',
        userId: userId,
        area: 'Bathroom',
        startTime: now.subtract(const Duration(days: 2)),
        createdAt: now.subtract(const Duration(days: 2)),
        elapsedSeconds: 1200, // 20 minutes
        itemsCount: 8,
        focusIndex: 7,
        moodIndex: 8,
        beforeMessinessIndex: 6.0,
        afterMessinessIndex: 1.5,
      ),
      DeepCleaningSession(
        id: 'deep-3',
        userId: userId,
        area: 'Living Room',
        startTime: now.subtract(const Duration(days: 5)),
        createdAt: now.subtract(const Duration(days: 5)),
        elapsedSeconds: 2700, // 45 minutes
        itemsCount: 20,
        focusIndex: 9,
        moodIndex: 10,
        beforeMessinessIndex: 8.0,
        afterMessinessIndex: 2.5,
      ),
    ];
  }

  // Mock Declutter Items
  static List<DeclutterItem> getDeclutterItems() {
    final now = DateTime.now();

    return [
      DeclutterItem(
        id: 'item-1',
        userId: userId,
        name: 'Old sweater',
        category: 'Clothing',
        status: DeclutterStatus.donate,
        createdAt: now.subtract(const Duration(days: 1)),
        notes: 'Haven\'t worn in 2 years',
      ),
      DeclutterItem(
        id: 'item-2',
        userId: userId,
        name: 'Kitchen gadget',
        category: 'Kitchen',
        status: DeclutterStatus.resell,
        createdAt: now.subtract(const Duration(days: 2)),
        estimatedValue: 25.0,
      ),
      DeclutterItem(
        id: 'item-3',
        userId: userId,
        name: 'Coffee maker',
        category: 'Kitchen',
        status: DeclutterStatus.trash,
        createdAt: now.subtract(const Duration(days: 3)),
        notes: 'Broken',
      ),
      DeclutterItem(
        id: 'item-4',
        userId: userId,
        name: 'Winter coat',
        category: 'Clothing',
        status: DeclutterStatus.keep,
        createdAt: now.subtract(const Duration(hours: 5)),
        notes: 'Still useful',
      ),
      DeclutterItem(
        id: 'item-5',
        userId: userId,
        name: 'Board game',
        category: 'Entertainment',
        status: DeclutterStatus.donate,
        createdAt: now.subtract(const Duration(days: 4)),
      ),
    ];
  }

  // Mock Memories
  static List<Memory> getMemories() {
    final now = DateTime.now();

    return [
      Memory(
        id: 'memory-1',
        userId: userId,
        title: 'Family vacation photo',
        description: 'Trip to Hawaii 2020',
        createdAt: now.subtract(const Duration(days: 10)),
        tags: ['vacation', 'family', 'beach'],
      ),
      Memory(
        id: 'memory-2',
        userId: userId,
        title: 'Grandmother\'s recipe book',
        description: 'Her handwritten recipes that I digitized',
        createdAt: now.subtract(const Duration(days: 5)),
        tags: ['family', 'cooking', 'heirloom'],
      ),
      Memory(
        id: 'memory-3',
        userId: userId,
        title: 'Concert ticket stub',
        description: 'Favorite band concert 2019',
        createdAt: now.subtract(const Duration(days: 3)),
        tags: ['music', 'concert', 'memories'],
      ),
    ];
  }

  // Mock Resell Items
  static List<ResellItem> getResellItems() {
    final now = DateTime.now();

    return [
      ResellItem(
        id: 'resell-1',
        userId: userId,
        declutterItemId: 'item-2',
        status: ResellStatus.listed,
        createdAt: now.subtract(const Duration(days: 2)),
        listedPrice: 25.0,
        platform: 'Facebook Marketplace',
      ),
      ResellItem(
        id: 'resell-2',
        userId: userId,
        declutterItemId: 'item-6',
        status: ResellStatus.sold,
        createdAt: now.subtract(const Duration(days: 10)),
        listedPrice: 50.0,
        soldPrice: 45.0,
        soldDate: now.subtract(const Duration(days: 5)),
        platform: 'eBay',
      ),
      ResellItem(
        id: 'resell-3',
        userId: userId,
        declutterItemId: 'item-7',
        status: ResellStatus.toSell,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  // Mock Activity History
  static List<ActivityEntry> getActivityHistory() {
    final now = DateTime.now();

    return [
      ActivityEntry(
        type: ActivityType.deepCleaning,
        timestamp: now.subtract(const Duration(hours: 2)),
        description: 'Kitchen',
        itemCount: 12,
      ),
      ActivityEntry(
        type: ActivityType.joyDeclutter,
        timestamp: now.subtract(const Duration(hours: 5)),
        description: 'Old sweater',
        itemCount: 1,
      ),
      ActivityEntry(
        type: ActivityType.quickDeclutter,
        timestamp: now.subtract(const Duration(days: 1, hours: 3)),
        description: 'Kitchen gadget',
        itemCount: 1,
      ),
      ActivityEntry(
        type: ActivityType.deepCleaning,
        timestamp: now.subtract(const Duration(days: 2)),
        description: 'Bathroom',
        itemCount: 8,
      ),
      ActivityEntry(
        type: ActivityType.joyDeclutter,
        timestamp: now.subtract(const Duration(days: 3)),
        description: 'Coffee maker',
        itemCount: 1,
      ),
      ActivityEntry(
        type: ActivityType.deepCleaning,
        timestamp: now.subtract(const Duration(days: 5)),
        description: 'Living Room',
        itemCount: 20,
      ),
    ];
  }

  // Active streak (consecutive days)
  static int getStreak() {
    return 5; // 5 days streak
  }

  // Items decluttered this month
  static int getDeclutteredThisMonth() {
    return 42;
  }

  // Total value from sold items this month
  static double getNewValueThisMonth() {
    return 245.50;
  }
}
