import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'connectivity_service.dart';
import 'storage_service.dart';

/// Sync queue item representing a pending operation
class SyncQueueItem {
  final String id;
  final String type; // 'upload_image', 'sync_data', 'delete_data'
  final Map<String, dynamic> data;
  final DateTime createdAt;
  int retryCount;
  DateTime? lastRetryAt;

  SyncQueueItem({
    required this.id,
    required this.type,
    required this.data,
    required this.createdAt,
    this.retryCount = 0,
    this.lastRetryAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'data': data,
        'createdAt': createdAt.toIso8601String(),
        'retryCount': retryCount,
        'lastRetryAt': lastRetryAt?.toIso8601String(),
      };

  factory SyncQueueItem.fromJson(Map<String, dynamic> json) {
    return SyncQueueItem(
      id: json['id'] as String,
      type: json['type'] as String,
      data: Map<String, dynamic>.from(json['data'] as Map),
      createdAt: DateTime.parse(json['createdAt'] as String),
      retryCount: json['retryCount'] as int? ?? 0,
      lastRetryAt: json['lastRetryAt'] != null
          ? DateTime.parse(json['lastRetryAt'] as String)
          : null,
    );
  }
}

/// Service for managing background sync queue with debouncing and retry logic
class SyncQueueService {
  static final SyncQueueService _instance = SyncQueueService._internal();
  factory SyncQueueService() => _instance;
  SyncQueueService._internal();

  static const String _queueBoxName = 'sync_queue';
  Timer? _debounceTimer;
  Timer? _processTimer;
  bool _isProcessing = false;

  // Retry delays: 3s, 10s, 30s
  static const List<Duration> _retryDelays = [
    Duration(seconds: 3),
    Duration(seconds: 10),
    Duration(seconds: 30),
  ];

  /// Initialize the sync queue service
  Future<void> initialize() async {
    await Hive.openBox<Map>(_queueBoxName);

    // Start periodic processing
    _startPeriodicProcessing();

    // Listen to connectivity changes
    ConnectivityService().connectivityStream.listen((isConnected) {
      if (isConnected && !_isProcessing) {
        debugPrint('🌐 Network restored, processing sync queue');
        _processQueue();
      }
    });

    debugPrint('✅ SyncQueueService initialized');
  }

  /// Add item to sync queue with 5-second debounce
  Future<void> addToQueue({
    required String type,
    required Map<String, dynamic> data,
  }) async {
    final box = Hive.box<Map>(_queueBoxName);
    final item = SyncQueueItem(
      id: '${type}_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      data: data,
      createdAt: DateTime.now(),
    );

    await box.put(item.id, item.toJson());
    debugPrint('📥 Added to sync queue: ${item.type} (${item.id})');

    // Debounce: wait 5 seconds before processing
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 5), () {
      debugPrint('⏰ Debounce timer fired, processing queue');
      _processQueue();
    });
  }

  /// Start periodic queue processing (every 30 seconds)
  void _startPeriodicProcessing() {
    _processTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!_isProcessing) {
        debugPrint('🔄 Periodic queue check');
        _processQueue();
      }
    });
  }

  /// Process all items in the queue
  Future<void> _processQueue() async {
    if (_isProcessing) {
      debugPrint('⚠️ Queue already processing, skipping');
      return;
    }

    if (!await ConnectivityService().isConnected) {
      debugPrint('⚠️ No network connection, skipping queue processing');
      return;
    }

    _isProcessing = true;

    try {
      final box = Hive.box<Map>(_queueBoxName);
      final items = box.values.map((json) {
        return SyncQueueItem.fromJson(Map<String, dynamic>.from(json));
      }).toList();

      debugPrint('📋 Processing ${items.length} items in sync queue');

      for (final item in items) {
        await _processItem(item);
      }
    } catch (e) {
      debugPrint('❌ Error processing queue: $e');
    } finally {
      _isProcessing = false;
    }
  }

  /// Process a single queue item with retry logic
  Future<void> _processItem(SyncQueueItem item) async {
    try {
      debugPrint('🔨 Processing: ${item.type} (retry: ${item.retryCount})');

      switch (item.type) {
        case 'upload_image':
          await _processImageUpload(item);
          break;
        case 'sync_data':
          await _processSyncData(item);
          break;
        case 'delete_data':
          await _processDeleteData(item);
          break;
        default:
          debugPrint('⚠️ Unknown queue item type: ${item.type}');
      }

      // Success - remove from queue
      await _removeFromQueue(item.id);
      debugPrint('✅ Successfully processed: ${item.id}');
    } catch (e) {
      debugPrint('❌ Error processing item ${item.id}: $e');
      await _handleRetry(item);
    }
  }

  /// Upload image to Supabase Storage
  Future<void> _processImageUpload(SyncQueueItem item) async {
    final localPath = item.data['localPath'] as String;
    final remotePath = item.data['remotePath'] as String;
    final bucket = item.data['bucket'] as String;
    final recordId = item.data['recordId'] as String;
    final recordType = item.data['recordType'] as String; // 'memory', 'item', etc.

    // Check if file exists
    final file = File(localPath);
    if (!await file.exists()) {
      debugPrint('⚠️ Local file not found: $localPath');
      await _removeFromQueue(item.id);
      return;
    }

    // Upload to Supabase Storage
    final remoteUrl = await StorageService.uploadFile(
      file: file,
      bucket: bucket,
      path: remotePath,
    );

    debugPrint('☁️ Uploaded to: $remoteUrl');

    // Update Hive record with remote URL
    await _updateRecordWithRemoteUrl(
      recordType: recordType,
      recordId: recordId,
      remoteUrl: remoteUrl,
    );

    // Sync metadata to Supabase database
    await _syncMetadataToSupabase(
      recordType: recordType,
      recordId: recordId,
    );
  }

  /// Sync data record to Supabase
  Future<void> _processSyncData(SyncQueueItem item) async {
    final recordType = item.data['recordType'] as String;
    final recordId = item.data['recordId'] as String;
    final data = item.data['data'] as Map<String, dynamic>;

    final supabase = Supabase.instance.client;
    final tableName = _getTableName(recordType);

    // Upsert to Supabase with conflict resolution (Last Write Wins)
    await supabase.from(tableName).upsert(data);

    debugPrint('☁️ Synced $recordType to Supabase: $recordId');
  }

  /// Delete data from Supabase
  Future<void> _processDeleteData(SyncQueueItem item) async {
    final recordType = item.data['recordType'] as String;
    final recordId = item.data['recordId'] as String;

    final supabase = Supabase.instance.client;
    final tableName = _getTableName(recordType);

    await supabase.from(tableName).delete().eq('id', recordId);

    debugPrint('🗑️ Deleted $recordType from Supabase: $recordId');
  }

  /// Update Hive record with remote URL and synced status
  Future<void> _updateRecordWithRemoteUrl({
    required String recordType,
    required String recordId,
    required String remoteUrl,
  }) async {
    final boxName = _getBoxName(recordType);
    final box = await Hive.openBox(boxName);
    final record = box.get(recordId);

    if (record != null) {
      record['remoteUrl'] = remoteUrl;
      record['synced'] = true;
      record['updatedAt'] = DateTime.now().toIso8601String();
      await box.put(recordId, record);
    }
  }

  /// Sync metadata to Supabase database
  Future<void> _syncMetadataToSupabase({
    required String recordType,
    required String recordId,
  }) async {
    final boxName = _getBoxName(recordType);
    final box = await Hive.openBox(boxName);
    final record = box.get(recordId);

    if (record != null) {
      await addToQueue(
        type: 'sync_data',
        data: {
          'recordType': recordType,
          'recordId': recordId,
          'data': record,
        },
      );
    }
  }

  /// Handle retry logic with exponential backoff
  Future<void> _handleRetry(SyncQueueItem item) async {
    final box = Hive.box<Map>(_queueBoxName);

    if (item.retryCount >= _retryDelays.length) {
      debugPrint('❌ Max retries exceeded for ${item.id}, giving up');
      // Keep in queue for next app restart
      return;
    }

    // Update retry count and schedule next retry
    item.retryCount++;
    item.lastRetryAt = DateTime.now();

    await box.put(item.id, item.toJson());

    final delay = _retryDelays[item.retryCount - 1];
    debugPrint('🔄 Scheduling retry ${item.retryCount} in ${delay.inSeconds}s');

    Timer(delay, () => _processItem(item));
  }

  /// Remove item from queue
  Future<void> _removeFromQueue(String id) async {
    final box = Hive.box<Map>(_queueBoxName);
    await box.delete(id);
  }

  /// Get table name for record type
  String _getTableName(String recordType) {
    switch (recordType) {
      case 'memory':
        return 'memories';
      case 'item':
        return 'declutter_items';
      case 'session':
        return 'deep_cleaning_sessions';
      case 'resell_item':
        return 'resell_items';
      default:
        return recordType;
    }
  }

  /// Get Hive box name for record type
  String _getBoxName(String recordType) {
    switch (recordType) {
      case 'memory':
        return 'memories';
      case 'item':
        return 'declutter_items';
      case 'session':
        return 'deep_cleaning_sessions';
      case 'resell_item':
        return 'resell_items';
      default:
        return recordType;
    }
  }

  /// Force process queue immediately (useful for testing)
  Future<void> forceProcess() async {
    _debounceTimer?.cancel();
    await _processQueue();
  }

  /// Get queue length
  Future<int> getQueueLength() async {
    final box = Hive.box<Map>(_queueBoxName);
    return box.length;
  }

  /// Clear all items from queue (use with caution!)
  Future<void> clearQueue() async {
    final box = Hive.box<Map>(_queueBoxName);
    await box.clear();
    debugPrint('🗑️ Sync queue cleared');
  }

  /// Dispose timers
  void dispose() {
    _debounceTimer?.cancel();
    _processTimer?.cancel();
  }
}
