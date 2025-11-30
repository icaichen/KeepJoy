import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:keepjoy_app/services/storage_service.dart';

/// Image Cache Service
/// Handles lazy loading and caching of images from cloud storage
/// with smart cleanup and access tracking
class ImageCacheService {
  static ImageCacheService? _instance;
  static ImageCacheService get instance {
    _instance ??= ImageCacheService._();
    return _instance!;
  }

  ImageCacheService._();

  final _storageService = StorageService();
  final _downloadingUrls = <String>{};

  // Cache cleanup configuration
  static const int _cacheExpiryDays = 30; // Delete images not accessed in 30 days
  static const int _maxCacheSizeMB = 500; // Warn if cache exceeds 500 MB

  /// Get local cache directory for images
  Future<Directory> _getCacheDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${appDir.path}/image_cache');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }

  /// Generate cache file path from URL
  Future<String> _getCacheFilePath(String url) async {
    final cacheDir = await _getCacheDir();
    // Use URL hash as filename to avoid special characters
    final fileName = url.hashCode.abs().toString();
    return '${cacheDir.path}/$fileName.jpg';
  }

  /// Get cache metadata file path
  Future<String> _getMetadataFilePath() async {
    final cacheDir = await _getCacheDir();
    return '${cacheDir.path}/cache_metadata.json';
  }

  /// Load cache metadata (last access times)
  Future<Map<String, int>> _loadMetadata() async {
    try {
      final metadataPath = await _getMetadataFilePath();
      final file = File(metadataPath);
      if (!await file.exists()) return {};

      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      return json.map((key, value) => MapEntry(key, value as int));
    } catch (e) {
      debugPrint('⚠️ Failed to load cache metadata: $e');
      return {};
    }
  }

  /// Save cache metadata
  Future<void> _saveMetadata(Map<String, int> metadata) async {
    try {
      final metadataPath = await _getMetadataFilePath();
      final file = File(metadataPath);
      await file.writeAsString(jsonEncode(metadata));
    } catch (e) {
      debugPrint('❌ Failed to save cache metadata: $e');
    }
  }

  /// Update last access time for a cached file
  Future<void> _updateAccessTime(String fileName) async {
    final metadata = await _loadMetadata();
    metadata[fileName] = DateTime.now().millisecondsSinceEpoch;
    await _saveMetadata(metadata);
  }

  /// Check if image is cached locally
  Future<bool> isCached(String? url) async {
    if (url == null || url.isEmpty) return false;
    // Local files are already "cached"
    if (!url.startsWith('http')) return true;

    final cachePath = await _getCacheFilePath(url);
    return File(cachePath).existsSync();
  }

  /// Get image file (local path or cached cloud image)
  /// Downloads from cloud if not cached
  Future<File?> getImage(String? url) async {
    if (url == null || url.isEmpty) return null;

    // If it's a local file path, return it directly
    if (!url.startsWith('http')) {
      final file = File(url);
      if (await file.exists()) {
        return file;
      }
      return null;
    }

    // Check if already cached
    final cachePath = await _getCacheFilePath(url);
    final cachedFile = File(cachePath);
    if (await cachedFile.exists()) {
      debugPrint('📦 Using cached image: $url');

      // Update last access time
      final fileName = url.hashCode.abs().toString();
      await _updateAccessTime(fileName);

      return cachedFile;
    }

    // Download from cloud if not already downloading
    if (_downloadingUrls.contains(url)) {
      debugPrint('⏳ Image already downloading: $url');
      return null;
    }

    try {
      _downloadingUrls.add(url);
      debugPrint('⬇️ Downloading image: $url');

      // Download to cache
      final downloaded = await _storageService.downloadImage(url, cachePath);
      debugPrint('✅ Image cached: $url');

      // Update access time for newly downloaded image
      final fileName = url.hashCode.abs().toString();
      await _updateAccessTime(fileName);

      return downloaded;
    } catch (e) {
      debugPrint('❌ Failed to download image: $e');
      return null;
    } finally {
      _downloadingUrls.remove(url);
    }
  }

  /// Preload images in background (optional optimization)
  Future<void> preloadImages(List<String?> urls) async {
    final cloudUrls = urls
        .where((url) => url != null && url.startsWith('http'))
        .cast<String>()
        .toList();

    debugPrint('📥 Preloading ${cloudUrls.length} images...');

    for (final url in cloudUrls) {
      if (!await isCached(url)) {
        // Don't await - let them download in background
        getImage(url).catchError((e) {
          debugPrint('⚠️ Preload failed for $url: $e');
          return null;
        });
      }
    }
  }

  /// Clear all cached images
  Future<void> clearCache() async {
    try {
      final cacheDir = await _getCacheDir();
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        debugPrint('🗑️ Cleared image cache');
      }
    } catch (e) {
      debugPrint('❌ Failed to clear cache: $e');
    }
  }

  /// Get cache size in bytes
  Future<int> getCacheSize() async {
    try {
      final cacheDir = await _getCacheDir();
      if (!await cacheDir.exists()) return 0;

      int totalSize = 0;
      await for (final entity in cacheDir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      return totalSize;
    } catch (e) {
      debugPrint('❌ Failed to get cache size: $e');
      return 0;
    }
  }

  /// Get cache size in human-readable format
  Future<String> getCacheSizeFormatted() async {
    final bytes = await getCacheSize();
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Clean up old cached images (not accessed in X days)
  /// This keeps recently viewed images but removes old ones to save space
  Future<int> cleanupOldCache({int? daysOld}) async {
    final expiryDays = daysOld ?? _cacheExpiryDays;
    final expiryTime = DateTime.now()
        .subtract(Duration(days: expiryDays))
        .millisecondsSinceEpoch;

    int deletedCount = 0;
    int deletedBytes = 0;

    try {
      final cacheDir = await _getCacheDir();
      if (!await cacheDir.exists()) return 0;

      final metadata = await _loadMetadata();
      final filesToDelete = <String>[];

      // Find files that haven't been accessed recently
      await for (final entity in cacheDir.list()) {
        if (entity is File && entity.path.endsWith('.jpg')) {
          final fileName = entity.path.split('/').last.replaceAll('.jpg', '');

          // Check last access time
          final lastAccess = metadata[fileName];
          if (lastAccess == null || lastAccess < expiryTime) {
            final fileSize = await entity.length();
            await entity.delete();
            filesToDelete.add(fileName);
            deletedCount++;
            deletedBytes += fileSize;
            debugPrint('🗑️ Deleted old cache file: $fileName (last accessed: ${lastAccess != null ? DateTime.fromMillisecondsSinceEpoch(lastAccess) : "never"})');
          }
        }
      }

      // Update metadata - remove deleted files
      for (final fileName in filesToDelete) {
        metadata.remove(fileName);
      }
      await _saveMetadata(metadata);

      if (deletedCount > 0) {
        final sizeMB = (deletedBytes / (1024 * 1024)).toStringAsFixed(1);
        debugPrint('✅ Cleanup complete: Deleted $deletedCount files ($sizeMB MB)');
      } else {
        debugPrint('✅ Cleanup complete: No old files to delete');
      }

      return deletedCount;
    } catch (e) {
      debugPrint('❌ Failed to cleanup cache: $e');
      return 0;
    }
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    final size = await getCacheSize();
    final sizeFormatted = await getCacheSizeFormatted();
    final metadata = await _loadMetadata();

    final cacheDir = await _getCacheDir();
    int fileCount = 0;
    if (await cacheDir.exists()) {
      await for (final entity in cacheDir.list()) {
        if (entity is File && entity.path.endsWith('.jpg')) {
          fileCount++;
        }
      }
    }

    final sizeMB = size / (1024 * 1024);
    final isOverLimit = sizeMB > _maxCacheSizeMB;

    // Count files by age
    final now = DateTime.now().millisecondsSinceEpoch;
    final last7Days = now - (7 * 24 * 60 * 60 * 1000);
    final last30Days = now - (30 * 24 * 60 * 60 * 1000);

    int recentFiles = 0;
    int oldFiles = 0;
    for (final accessTime in metadata.values) {
      if (accessTime > last7Days) {
        recentFiles++;
      } else if (accessTime < last30Days) {
        oldFiles++;
      }
    }

    return {
      'totalSize': size,
      'sizeMB': sizeMB,
      'sizeFormatted': sizeFormatted,
      'fileCount': fileCount,
      'recentFiles': recentFiles, // Accessed in last 7 days
      'oldFiles': oldFiles, // Not accessed in 30+ days
      'isOverLimit': isOverLimit,
      'limitMB': _maxCacheSizeMB,
    };
  }

  /// Check if cache needs cleanup (automatic)
  Future<bool> needsCleanup() async {
    final stats = await getCacheStats();
    return stats['isOverLimit'] as bool || (stats['oldFiles'] as int) > 50;
  }

  /// Perform automatic cleanup if needed
  /// Called periodically by the app
  Future<void> autoCleanup() async {
    if (await needsCleanup()) {
      debugPrint('🧹 Auto-cleanup triggered');
      await cleanupOldCache();
    }
  }
}
