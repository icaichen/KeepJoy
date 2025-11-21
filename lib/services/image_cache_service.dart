import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:keepjoy_app/services/storage_service.dart';

/// Image Cache Service
/// Handles lazy loading and caching of images from cloud storage
class ImageCacheService {
  static ImageCacheService? _instance;
  static ImageCacheService get instance {
    _instance ??= ImageCacheService._();
    return _instance!;
  }

  ImageCacheService._();

  final _storageService = StorageService();
  final _downloadingUrls = <String>{};

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
}
