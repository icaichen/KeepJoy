import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keepjoy_app/services/image_compression_service.dart';
import 'package:keepjoy_app/services/storage_service.dart';
import 'package:keepjoy_app/services/auth_service.dart';

/// Integration test for image compression and storage upload
///
/// This test verifies:
/// 1. Image compression works with different size targets
/// 2. Storage service can upload to Supabase
/// 3. Public URLs are returned correctly
///
/// Prerequisites:
/// - User must be logged in
/// - Supabase Storage buckets must be created (run migration first)
/// - Test image file must exist
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Storage Service Integration Tests', () {
    late StorageService storageService;
    late AuthService authService;

    setUp(() {
      storageService = StorageService();
      authService = AuthService();
    });

    test('Compress and upload memory image', () async {
      // Skip if not authenticated
      if (authService.currentUserId == null) {
        debugPrint('⚠️ Skipping test: User not authenticated');
        return;
      }

      // Create a test image file (you'll need to provide a real image)
      final testImagePath = '/Users/chencai/Development/KeepJoy/assets/images/app_logo.png';
      final testImage = File(testImagePath);

      if (!testImage.existsSync()) {
        debugPrint('⚠️ Skipping test: Test image not found at $testImagePath');
        return;
      }

      debugPrint('🧪 Testing memory image compression and upload...');

      // Step 1: Compress image
      final compressedFile = await ImageCompressionService.compressMemoryImage(testImage);
      expect(compressedFile.existsSync(), true);
      debugPrint('✅ Compression successful: ${compressedFile.path}');

      // Step 2: Upload to storage
      try {
        final publicUrl = await storageService.uploadMemoryImage(compressedFile);
        expect(publicUrl, isNotEmpty);
        expect(publicUrl, contains('memories'));
        debugPrint('✅ Upload successful: $publicUrl');
      } catch (e) {
        if (e.toString().contains('Bucket not found')) {
          debugPrint('⚠️ Storage buckets not created yet. Please run the SQL migration in Supabase Dashboard.');
          debugPrint('   Migration file: supabase/migrations/202501190001_create_storage_buckets.sql');
        } else {
          debugPrint('❌ Upload failed: $e');
        }
        rethrow;
      }
    });

    test('Compress and upload item image', () async {
      if (authService.currentUserId == null) {
        debugPrint('⚠️ Skipping test: User not authenticated');
        return;
      }

      final testImagePath = '/Users/chencai/Development/KeepJoy/assets/images/app_logo.png';
      final testImage = File(testImagePath);

      if (!testImage.existsSync()) {
        debugPrint('⚠️ Skipping test: Test image not found');
        return;
      }

      debugPrint('🧪 Testing item image compression and upload...');

      // Step 1: Compress with item settings (600px, 80% quality)
      final compressedFile = await ImageCompressionService.compressItemImage(testImage);
      expect(compressedFile.existsSync(), true);
      debugPrint('✅ Compression successful: ${compressedFile.path}');

      // Step 2: Upload to items bucket
      try {
        final publicUrl = await storageService.uploadItemImage(compressedFile);
        expect(publicUrl, isNotEmpty);
        expect(publicUrl, contains('items'));
        debugPrint('✅ Upload successful: $publicUrl');
      } catch (e) {
        debugPrint('❌ Upload failed: $e');
        rethrow;
      }
    });

    test('Compress and upload profile avatar', () async {
      if (authService.currentUserId == null) {
        debugPrint('⚠️ Skipping test: User not authenticated');
        return;
      }

      final testImagePath = '/Users/chencai/Development/KeepJoy/assets/images/app_logo.png';
      final testImage = File(testImagePath);

      if (!testImage.existsSync()) {
        debugPrint('⚠️ Skipping test: Test image not found');
        return;
      }

      debugPrint('🧪 Testing avatar image compression and upload...');

      // Step 1: Compress with avatar settings (512px, 85% quality)
      final compressedFile = await ImageCompressionService.compressAvatarImage(testImage);
      expect(compressedFile.existsSync(), true);
      debugPrint('✅ Compression successful: ${compressedFile.path}');

      // Step 2: Upload to profiles bucket
      try {
        final publicUrl = await storageService.uploadProfileImage(compressedFile);
        expect(publicUrl, isNotEmpty);
        expect(publicUrl, contains('profiles'));
        debugPrint('✅ Upload successful: $publicUrl');
      } catch (e) {
        debugPrint('❌ Upload failed: $e');
        rethrow;
      }
    });
  });
}
