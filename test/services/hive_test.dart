import 'package:flutter_test/flutter_test.dart';
import 'package:keepjoy_app/services/hive_service.dart';
import 'package:keepjoy_app/models/hive/memory_hive.dart';
import 'package:keepjoy_app/models/hive/declutter_item_hive.dart';
import 'package:keepjoy_app/models/memory.dart';
import 'package:keepjoy_app/models/declutter_item.dart';

/// Integration tests for Hive local database
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Initialize Hive before tests
    await HiveService.instance.init();
  });

  tearDownAll(() async {
    // Clean up after tests
    await HiveService.instance.close();
  });

  group('HiveService - Memory CRUD', () {
    setUp(() async {
      // Clear data before each test
      await HiveService.instance.clearAll();
    });

    test('Save and retrieve memory', () async {
      final memory = Memory.custom(
        id: 'test_memory_1',
        userId: 'test_user',
        title: 'Test Memory',
        description: 'This is a test memory',
        createdAt: DateTime.now(),
      );

      // Convert to Hive model and save
      final memoryHive = MemoryHive.fromMemory(memory, isDirty: true);
      await HiveService.instance.saveMemory(memoryHive);

      // Retrieve and verify
      final retrieved = HiveService.instance.getMemory('test_memory_1');
      expect(retrieved, isNotNull);
      expect(retrieved!.title, 'Test Memory');
      expect(retrieved.description, 'This is a test memory');
      expect(retrieved.isDirty, true);
      expect(retrieved.isDeleted, false);
    });

    test('Get all memories', () async {
      // Save multiple memories
      for (int i = 0; i < 5; i++) {
        final memory = Memory.custom(
          id: 'memory_$i',
          userId: 'test_user',
          title: 'Memory $i',
          createdAt: DateTime.now(),
        );
        final memoryHive = MemoryHive.fromMemory(memory);
        await HiveService.instance.saveMemory(memoryHive);
      }

      // Retrieve all
      final memories = HiveService.instance.getAllMemories(userId: 'test_user');
      expect(memories.length, 5);
    });

    test('Soft delete memory', () async {
      final memory = Memory.custom(
        id: 'delete_test',
        userId: 'test_user',
        title: 'Delete Test',
        createdAt: DateTime.now(),
      );

      final memoryHive = MemoryHive.fromMemory(memory);
      await HiveService.instance.saveMemory(memoryHive);

      // Soft delete
      await HiveService.instance.deleteMemory('delete_test');

      // Should not appear in getAllMemories (by default)
      final activeMemories = HiveService.instance.getAllMemories(userId: 'test_user');
      expect(activeMemories.length, 0);

      // Should appear when includeDeleted = true
      final allMemories = HiveService.instance.getAllMemories(
        userId: 'test_user',
        includeDeleted: true,
      );
      expect(allMemories.length, 1);
      expect(allMemories.first.isDeleted, true);
    });

    test('Get dirty memories', () async {
      // Save clean memory
      final cleanMemory = Memory.custom(
        id: 'clean',
        userId: 'test_user',
        title: 'Clean',
        createdAt: DateTime.now(),
      );
      final cleanHive = MemoryHive.fromMemory(cleanMemory, isDirty: false);
      await HiveService.instance.saveMemory(cleanHive);

      // Save dirty memory
      final dirtyMemory = Memory.custom(
        id: 'dirty',
        userId: 'test_user',
        title: 'Dirty',
        createdAt: DateTime.now(),
      );
      final dirtyHive = MemoryHive.fromMemory(dirtyMemory, isDirty: true);
      await HiveService.instance.saveMemory(dirtyHive);

      // Get dirty memories
      final dirtyMemories = HiveService.instance.getDirtyMemories();
      expect(dirtyMemories.length, 1);
      expect(dirtyMemories.first.id, 'dirty');
    });

    test('Mark memory as synced', () async {
      final memory = Memory.custom(
        id: 'sync_test',
        userId: 'test_user',
        title: 'Sync Test',
        createdAt: DateTime.now(),
      );

      final memoryHive = MemoryHive.fromMemory(memory, isDirty: true);
      await HiveService.instance.saveMemory(memoryHive);

      // Verify it's dirty
      expect(memoryHive.isDirty, true);

      // Mark as synced
      memoryHive.markSynced();
      await memoryHive.save();

      // Verify it's no longer dirty
      final retrieved = HiveService.instance.getMemory('sync_test');
      expect(retrieved!.isDirty, false);
      expect(retrieved.syncedAt, isNotNull);
    });
  });

  group('HiveService - Item CRUD', () {
    setUp(() async {
      await HiveService.instance.clearAll();
    });

    test('Save and retrieve item', () async {
      final item = DeclutterItem(
        id: 'test_item_1',
        userId: 'test_user',
        name: 'Test Item',
        category: DeclutterCategory.clothes,
        status: DeclutterStatus.keep,
        notes: 'Test notes',
      );

      final itemHive = DeclutterItemHive.fromItem(item, isDirty: true);
      await HiveService.instance.saveItem(itemHive);

      final retrieved = HiveService.instance.getItem('test_item_1');
      expect(retrieved, isNotNull);
      expect(retrieved!.name, 'Test Item');
      expect(retrieved.category, 'clothes');
      expect(retrieved.status, 'keep');
    });

    test('Convert between domain and Hive models', () async {
      final item = DeclutterItem(
        id: 'convert_test',
        userId: 'test_user',
        name: 'Convert Test',
        category: DeclutterCategory.electronics,
        status: DeclutterStatus.donate,
        joyLevel: 8,
        purchaseReview: PurchaseReview.worthIt,
      );

      // Convert to Hive
      final itemHive = DeclutterItemHive.fromItem(item);

      // Convert back to domain
      final convertedItem = itemHive.toItem();

      // Verify all fields
      expect(convertedItem.id, item.id);
      expect(convertedItem.name, item.name);
      expect(convertedItem.category, DeclutterCategory.electronics);
      expect(convertedItem.status, DeclutterStatus.donate);
      expect(convertedItem.joyLevel, 8);
      expect(convertedItem.purchaseReview, PurchaseReview.worthIt);
    });
  });

  group('HiveService - Statistics', () {
    setUp(() async {
      await HiveService.instance.clearAll();
    });

    test('Get database statistics', () async {
      // Add some test data
      for (int i = 0; i < 3; i++) {
        final memory = Memory.custom(
          id: 'mem_$i',
          userId: 'test_user',
          title: 'Memory $i',
          createdAt: DateTime.now(),
        );
        final memoryHive = MemoryHive.fromMemory(memory, isDirty: i == 0);
        await HiveService.instance.saveMemory(memoryHive);
      }

      // Delete one
      await HiveService.instance.deleteMemory('mem_0');

      // Get stats
      final stats = HiveService.instance.getStats();
      final memoryStats = stats['memories'] as Map;

      expect(memoryStats['total'], 3);
      expect(memoryStats['active'], 2); // 3 - 1 deleted
      expect(memoryStats['dirty'], 1); // mem_0 was dirty and now deleted
      expect(memoryStats['deleted'], 1);
    });
  });
}
