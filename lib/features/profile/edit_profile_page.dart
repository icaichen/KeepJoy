import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';

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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _avatarPath = pickedFile.path;
      });
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
    final isChinese = Localizations.localeOf(context)
        .languageCode
        .toLowerCase()
        .startsWith('zh');

    try {
      // Update user metadata
      await _authService.client.auth.updateUser(
        UserAttributes(
          data: {
            'name': _nameController.text.trim(),
            if (_avatarPath != null) 'avatar_url': _avatarPath,
          },
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isChinese ? '资料已更新' : 'Profile updated successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isChinese ? '更新失败: $e' : 'Update failed: $e',
            ),
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
    final isChinese = Localizations.localeOf(context)
        .languageCode
        .toLowerCase()
        .startsWith('zh');

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
          isChinese ? '编辑资料' : 'Edit Profile',
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
                color: _isLoading ? const Color(0xFF9CA3AF) : const Color(0xFFB794F6),
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
                      backgroundColor: const Color(0xFFB794F6).withValues(alpha: 0.15),
                      backgroundImage: _avatarPath != null && File(_avatarPath!).existsSync()
                          ? FileImage(File(_avatarPath!))
                          : null,
                      child: _avatarPath == null || !File(_avatarPath!).existsSync()
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
                          hintText: isChinese ? '输入你的名字' : 'Enter your name',
                          hintStyle: const TextStyle(
                            fontFamily: 'SF Pro Text',
                            color: Color(0xFF9CA3AF),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE5E7EA)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE5E7EA)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFB794F6), width: 2),
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
                            borderSide: const BorderSide(color: Color(0xFFE5E7EA)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE5E7EA)),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE5E7EA)),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF3F4F6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isChinese ? '邮箱无法修改' : 'Email cannot be changed',
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
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB794F6),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: const Color(0xFF9CA3AF),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          l10n.save,
                          style: const TextStyle(
                            fontFamily: 'SF Pro Text',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
