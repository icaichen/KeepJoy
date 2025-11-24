import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../services/image_compression_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/gradient_button.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _authService = AuthService();
  final _storageService = StorageService();

  bool _isLoading = false;
  String? _avatarPath;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = _authService.currentUser;
    if (user != null) {
      _emailController.text = user.email ?? '';

      final metadata = user.userMetadata;
      if (metadata != null && metadata['name'] != null) {
        _nameController.text = metadata['name'] as String;
      } else {
        // Extract name from email if no metadata
        final email = user.email ?? '';
        if (email.contains('@')) {
          _nameController.text = email.split('@').first;
        }
      }

      // Load avatar if exists
      if (metadata != null && metadata['avatar_url'] != null) {
        _avatarPath = metadata['avatar_url'] as String;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  ImageProvider? _avatarImageProvider() {
    if (_avatarPath == null) return null;
    final path = _avatarPath!;
    if (path.startsWith('http')) {
      return NetworkImage(path);
    }
    final file = File(path);
    return file.existsSync() ? FileImage(file) : null;
  }

  bool get _hasAvatarImage {
    if (_avatarPath == null) return false;
    final path = _avatarPath!;
    if (path.startsWith('http')) return true;
    return File(path).existsSync();
  }

  Future<String?> _saveImagePermanently(String tempPath) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final profileDir = Directory('${appDir.path}/profile');
      if (!await profileDir.exists()) {
        await profileDir.create(recursive: true);
      }

      final fileName =
          'avatar_${DateTime.now().millisecondsSinceEpoch}${path.extension(tempPath)}';
      final permanentPath = path.join(profileDir.path, fileName);

      final tempFile = File(tempPath);
      await tempFile.copy(permanentPath);

      return permanentPath;
    } catch (e) {
      debugPrint('❌ Failed to save image permanently: $e');
      return null;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      // Save to permanent storage
      final permanentPath = await _saveImagePermanently(pickedFile.path);
      if (permanentPath != null) {
        setState(() {
          _avatarPath = permanentPath;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final l10n = AppLocalizations.of(context)!;

    try {
      String? avatarUrlToSave;

      // Upload avatar if a local image is selected
      if (_avatarPath != null && !_avatarPath!.startsWith('http')) {
        final file = File(_avatarPath!);
        if (file.existsSync()) {
          final compressed =
              await ImageCompressionService.compressAvatarImage(file);
          avatarUrlToSave =
              await _storageService.uploadProfileImage(compressed);
        }
      } else if (_avatarPath != null) {
        avatarUrlToSave = _avatarPath;
      }

      // Update user metadata
      if (_authService.client == null) return;
      await _authService.client!.auth.updateUser(
        UserAttributes(
          data: {
            'name': _nameController.text.trim(),
            if (avatarUrlToSave != null) 'avatar_url': avatarUrlToSave,
          },
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.profileUpdateSuccess),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.profileUpdateFailed('$e')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.editProfile,
          style: const TextStyle(
            fontFamily: 'SF Pro Display',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: Text(
              l10n.save,
              style: TextStyle(
                fontFamily: 'SF Pro Text',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _isLoading
                    ? const Color(0xFF9CA3AF)
                    : const Color(0xFFB794F6),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar Section
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: const Color(
                        0xFFB794F6,
                      ).withValues(alpha: 0.15),
                      backgroundImage: _avatarImageProvider(),
                      child: !_hasAvatarImage
                          ? Text(
                              _nameController.text.isNotEmpty
                                  ? _nameController.text[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                fontFamily: 'SF Pro Display',
                                fontSize: 40,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFB794F6),
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFB794F6),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Name Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.name,
                        style: const TextStyle(
                          fontFamily: 'SF Pro Text',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: l10n.enterYourName,
                          hintStyle: const TextStyle(
                            fontFamily: 'SF Pro Text',
                            color: Color(0xFF9CA3AF),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE5E7EA),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE5E7EA),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFB794F6),
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFFAFAFA),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.nameRequired;
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Email Field (Read-only)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.email,
                        style: const TextStyle(
                          fontFamily: 'SF Pro Text',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailController,
                        enabled: false,
                        decoration: InputDecoration(
                          hintStyle: const TextStyle(
                            fontFamily: 'SF Pro Text',
                            color: Color(0xFF9CA3AF),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE5E7EA),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE5E7EA),
                            ),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE5E7EA),
                            ),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF3F4F6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.emailNotEditable,
                        style: const TextStyle(
                          fontFamily: 'SF Pro Text',
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              GradientButton(
                onPressed: _saveProfile,
                isLoading: _isLoading,
                width: double.infinity,
                child: Text(l10n.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
