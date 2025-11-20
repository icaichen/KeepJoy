import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

/// Image Compression Service
/// Handles all image compression with configurable sizes and quality
class ImageCompressionService {
  /// Compress image for memories (2048px, 85% quality)
  static Future<File> compressMemoryImage(File sourceFile) async {
    return await _compressImage(
      sourceFile: sourceFile,
      maxDimension: 2048,
      quality: 85,
      prefix: 'memory_',
    );
  }

  /// Compress image for deep cleaning sessions (2048px, 85% quality)
  static Future<File> compressSessionImage(File sourceFile) async {
    return await _compressImage(
      sourceFile: sourceFile,
      maxDimension: 2048,
      quality: 85,
      prefix: 'session_',
    );
  }

  /// Compress image for items (600px, 80% quality)
  static Future<File> compressItemImage(File sourceFile) async {
    return await _compressImage(
      sourceFile: sourceFile,
      maxDimension: 600,
      quality: 80,
      prefix: 'item_',
    );
  }

  /// Compress image for resell items (600px, 80% quality)
  static Future<File> compressResellImage(File sourceFile) async {
    return await _compressImage(
      sourceFile: sourceFile,
      maxDimension: 600,
      quality: 80,
      prefix: 'resell_',
    );
  }

  /// Compress image for profile avatar (512px, 85% quality)
  static Future<File> compressAvatarImage(File sourceFile) async {
    return await _compressImage(
      sourceFile: sourceFile,
      maxDimension: 512,
      quality: 85,
      prefix: 'avatar_',
    );
  }

  /// Generic image compression method
  static Future<File> _compressImage({
    required File sourceFile,
    required int maxDimension,
    required int quality,
    required String prefix,
  }) async {
    try {
      debugPrint('🗜️ Compressing image: ${sourceFile.path}');
      debugPrint('   Target: ${maxDimension}px, Quality: $quality%');

      // Read source image bytes
      final sourceBytes = await sourceFile.readAsBytes();

      // Decode image
      img.Image? image = img.decodeImage(sourceBytes);
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      debugPrint('   Original size: ${image.width}x${image.height}');

      // Calculate new dimensions while maintaining aspect ratio
      int targetWidth = image.width;
      int targetHeight = image.height;

      if (image.width > maxDimension || image.height > maxDimension) {
        if (image.width > image.height) {
          targetWidth = maxDimension;
          targetHeight = (image.height * maxDimension / image.width).round();
        } else {
          targetHeight = maxDimension;
          targetWidth = (image.width * maxDimension / image.height).round();
        }
      }

      debugPrint('   Compressed size: ${targetWidth}x${targetHeight}');

      // Resize image
      img.Image resized = img.copyResize(
        image,
        width: targetWidth,
        height: targetHeight,
        interpolation: img.Interpolation.cubic,
      );

      // Encode as JPEG with specified quality
      final List<int> compressedBytes = img.encodeJpg(
        resized,
        quality: quality,
      );

      // Save to temporary file
      final Directory tempDir = await getTemporaryDirectory();
      final String fileName =
          '$prefix${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File compressedFile = File('${tempDir.path}/$fileName');
      await compressedFile.writeAsBytes(compressedBytes);

      final originalSize = sourceBytes.length / 1024;
      final compressedSize = compressedBytes.length / 1024;
      final reduction = ((1 - compressedSize / originalSize) * 100)
          .toStringAsFixed(1);

      debugPrint('   Original: ${originalSize.toStringAsFixed(1)} KB');
      debugPrint('   Compressed: ${compressedSize.toStringAsFixed(1)} KB');
      debugPrint('   Reduction: $reduction%');
      debugPrint('✅ Compression complete: ${compressedFile.path}');

      return compressedFile;
    } catch (e) {
      debugPrint('❌ Image compression failed: $e');
      // If compression fails, return original file
      return sourceFile;
    }
  }

  /// Check if image needs compression
  static bool needsCompression(File file, int maxDimension) {
    // For now, always compress to ensure consistent quality
    return true;
  }
}
