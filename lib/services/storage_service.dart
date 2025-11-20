import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:keepjoy_app/services/auth_service.dart';

/// Supabase Storage Service
/// Handles file uploads to Supabase Storage with automatic retry
class StorageService {
  final _authService = AuthService();
  SupabaseClient? get _client => _authService.client;
  String? get _userId => _authService.currentUserId;

  /// Upload image to memories bucket
  Future<String> uploadMemoryImage(File imageFile) async {
    return await _uploadImage(
      imageFile: imageFile,
      bucket: 'memories',
      prefix: 'memory',
    );
  }

  /// Upload image to items bucket
  Future<String> uploadItemImage(File imageFile) async {
    return await _uploadImage(
      imageFile: imageFile,
      bucket: 'items',
      prefix: 'item',
    );
  }

  /// Upload image to sessions bucket (before/after photos)
  Future<String> uploadSessionImage(File imageFile) async {
    return await _uploadImage(
      imageFile: imageFile,
      bucket: 'sessions',
      prefix: 'session',
    );
  }

  /// Upload image to profiles bucket (avatar)
  Future<String> uploadProfileImage(File imageFile) async {
    return await _uploadImage(
      imageFile: imageFile,
      bucket: 'profiles',
      prefix: 'avatar',
    );
  }

  /// Generic image upload method with retry
  Future<String> _uploadImage({
    required File imageFile,
    required String bucket,
    required String prefix,
    int maxAttempts = 3,
  }) async {
    if (_client == null) throw StateError('Supabase client not initialized');
    if (_userId == null) throw StateError('User not authenticated');

    final fileName = '${prefix}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final filePath = '$_userId/$fileName';

    int attempt = 0;
    while (true) {
      try {
        debugPrint(
          '☁️ Uploading to $bucket/$filePath (attempt ${attempt + 1})',
        );

        // Upload file
        await _client!.storage
            .from(bucket)
            .upload(
              filePath,
              imageFile,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: false,
              ),
            );

        // Get public URL
        final publicUrl = _client!.storage.from(bucket).getPublicUrl(filePath);

        debugPrint('✅ Upload successful: $publicUrl');
        return publicUrl;
      } catch (e) {
        attempt++;
        if (attempt >= maxAttempts) {
          debugPrint('❌ Upload failed after $maxAttempts attempts: $e');
          rethrow;
        }

        // Exponential backoff: 2s, 4s, 8s
        final delay = Duration(seconds: 2 << (attempt - 1));
        debugPrint(
          '⚠️ Upload attempt $attempt failed, retrying in ${delay.inSeconds}s...',
        );
        await Future.delayed(delay);
      }
    }
  }

  /// Delete image from storage
  Future<void> deleteImage(String publicUrl, String bucket) async {
    if (_client == null) return;

    try {
      // Extract file path from public URL
      final uri = Uri.parse(publicUrl);
      final pathSegments = uri.pathSegments;

      // Find the file path after the bucket name
      final bucketIndex = pathSegments.indexOf(bucket);
      if (bucketIndex == -1 || bucketIndex == pathSegments.length - 1) {
        debugPrint('⚠️ Could not extract file path from URL: $publicUrl');
        return;
      }

      final filePath = pathSegments.sublist(bucketIndex + 2).join('/');
      debugPrint('🗑️ Deleting from $bucket: $filePath');

      await _client!.storage.from(bucket).remove([filePath]);
      debugPrint('✅ Deleted: $filePath');
    } catch (e) {
      debugPrint('⚠️ Failed to delete image: $e');
      // Don't throw - deletion failure shouldn't block the app
    }
  }

  /// Download image from storage to local cache
  Future<File> downloadImage(String publicUrl, String localPath) async {
    if (_client == null) throw StateError('Supabase client not initialized');

    try {
      debugPrint('⬇️ Downloading image: $publicUrl');

      // Extract bucket and file path from URL
      final uri = Uri.parse(publicUrl);
      final pathSegments = uri.pathSegments;

      // Storage URL format: /storage/v1/object/public/{bucket}/{path}
      String bucket = '';
      List<String> filePath = [];

      for (int i = 0; i < pathSegments.length; i++) {
        if (pathSegments[i] == 'object' &&
            i + 2 < pathSegments.length &&
            pathSegments[i + 1] == 'public') {
          bucket = pathSegments[i + 2];
          filePath = pathSegments.sublist(i + 3);
          break;
        }
      }

      if (bucket.isEmpty) {
        throw Exception('Could not extract bucket from URL: $publicUrl');
      }

      final path = filePath.join('/');
      debugPrint('   Bucket: $bucket, Path: $path');

      // Download file bytes
      final bytes = await _client!.storage.from(bucket).download(path);

      // Save to local file
      final file = File(localPath);
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes);

      final sizeMB = (bytes.length / 1024 / 1024).toStringAsFixed(2);
      debugPrint('✅ Downloaded: $localPath ($sizeMB MB)');

      return file;
    } catch (e) {
      debugPrint('❌ Download failed: $e');
      rethrow;
    }
  }

  /// Check if file exists in storage
  Future<bool> fileExists(String publicUrl, String bucket) async {
    if (_client == null) return false;

    try {
      final uri = Uri.parse(publicUrl);
      final pathSegments = uri.pathSegments;
      final bucketIndex = pathSegments.indexOf(bucket);

      if (bucketIndex == -1 || bucketIndex == pathSegments.length - 1) {
        return false;
      }

      final filePath = pathSegments.sublist(bucketIndex + 2).join('/');
      final files = await _client!.storage
          .from(bucket)
          .list(path: path.dirname(filePath));

      return files.any((file) => file.name == path.basename(filePath));
    } catch (e) {
      debugPrint('⚠️ Error checking file existence: $e');
      return false;
    }
  }
}
