import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../services/data_repository.dart';
import '../../models/declutter_item.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.onLocaleChange});

  final void Function(Locale) onLocaleChange;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _authService = AuthService();

  String get _userEmail =>
      _authService.currentUser?.email ?? 'user@example.com';

  String get _userName {
    final metadata = _authService.currentUser?.userMetadata;
    if (metadata != null && metadata['name'] != null) {
      return metadata['name'] as String;
    }
    // Extract name from email if no metadata
    final email = _userEmail;
    if (email.contains('@')) {
      return email.split('@').first;
    }
    return 'User';
  }

  String get _userInitial {
    if (_userName.isNotEmpty) {
      return _userName[0].toUpperCase();
    }
    return 'U';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F7),
        elevation: 0,
        title: Text(
          l10n.profile,
          style: const TextStyle(
            fontFamily: 'SF Pro Display',
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Color(0xFF000000),
            letterSpacing: 0,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Details Section
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
                child: Row(
                  children: [
                    // Profile Avatar
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: const Color(
                        0xFFB794F6,
                      ).withValues(alpha: 0.15),
                      child: Text(
                        _userInitial,
                        style: const TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFB794F6),
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // User Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _userName,
                            style: const TextStyle(
                              fontFamily: 'SF Pro Display',
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                              letterSpacing: 0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _userEmail,
                            style: const TextStyle(
                              fontFamily: 'SF Pro Text',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF6B7280),
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Edit Button
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: Color(0xFF6B7280),
                      ),
                      onPressed: () async {
                        final result = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfilePage(),
                          ),
                        );

                        // Refresh the profile if updated
                        if (result == true && mounted) {
                          setState(() {});
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Settings Section
            _buildSectionTitle(context, l10n.settings),
            const SizedBox(height: 12),
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
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.language,
                    title: l10n.language,
                    onTap: () {
                      _showLanguageDialog(context);
                    },
                  ),
                  const Divider(height: 1, indent: 56),
                  _SettingsTile(
                    icon: Icons.notifications_outlined,
                    title: l10n.notifications,
                    onTap: () {
                      // TODO: Implement notifications settings
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Support & Information Section
            _buildSectionTitle(context, l10n.support),
            const SizedBox(height: 12),
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
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.help_outline,
                    title: l10n.helpAndSupport,
                    onTap: () {
                      _openHelpSupport();
                    },
                  ),
                  const Divider(height: 1, indent: 56),
                  _SettingsTile(
                    icon: Icons.info_outline,
                    title: l10n.aboutApp,
                    onTap: () {
                      _showAboutDialog(context);
                    },
                  ),
                  const Divider(height: 1, indent: 56),
                  _SettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    title: l10n.privacyPolicy,
                    onTap: () {
                      _openPrivacyPolicy();
                    },
                  ),
                  const Divider(height: 1, indent: 56),
                  _SettingsTile(
                    icon: Icons.description_outlined,
                    title: l10n.termsOfService,
                    onTap: () {
                      _openTermsOfService();
                    },
                  ),
                  const Divider(height: 1, indent: 56),
                  _SettingsTile(
                    icon: Icons.star_outline,
                    title: l10n.rateApp,
                    onTap: () {
                      _rateApp();
                    },
                  ),
                  const Divider(height: 1, indent: 56),
                  _SettingsTile(
                    icon: Icons.share_outlined,
                    title: l10n.shareApp,
                    onTap: () {
                      _shareApp();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Data Management Section
            _buildSectionTitle(context, l10n.data),
            const SizedBox(height: 12),
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
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.download_outlined,
                    title: l10n.exportData,
                    onTap: () {
                      _exportData(context);
                    },
                  ),
                  const Divider(height: 1, indent: 56),
                  _SettingsTile(
                    icon: Icons.delete_outline,
                    title: l10n.clearAllData,
                    textColor: Colors.red,
                    onTap: () {
                      _showClearDataDialog(context);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Logout Section
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
              child: _SettingsTile(
                icon: Icons.logout,
                title: l10n.logout,
                textColor: Colors.red,
                onTap: () {
                  _showLogoutDialog(context);
                },
              ),
            ),
            const SizedBox(height: 32),

            // Version
            Center(
              child: Text(
                '${l10n.version} 1.0.0',
                style: const TextStyle(
                  fontFamily: 'SF Pro Text',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'SF Pro Display',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Color(0xFF111827),
          letterSpacing: 0,
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = Localizations.localeOf(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Language',
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LanguageOption(
              title: l10n.english,
              isSelected: currentLocale.languageCode == 'en',
              onTap: () {
                Navigator.pop(context);
                widget.onLocaleChange(const Locale('en'));
              },
            ),
            const SizedBox(height: 8),
            _LanguageOption(
              title: l10n.chinese,
              isSelected: currentLocale.languageCode == 'zh',
              onTap: () {
                Navigator.pop(context);
                widget.onLocaleChange(const Locale('zh'));
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'About App',
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        content: Text(
          'KeepJoy helps you declutter your life with joy.\n\n${l10n.version} 1.0.0',
          style: const TextStyle(
            fontFamily: 'SF Pro Text',
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Color(0xFF111827),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.ok,
              style: const TextStyle(
                fontFamily: 'SF Pro Text',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFFB794F6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isChinese = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('zh');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.clearAllData,
                style: const TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isChinese
                  ? '确定要清除所有数据吗？此操作无法撤销。'
                  : 'Are you sure you want to clear all data? This cannot be undone.',
              style: const TextStyle(
                fontFamily: 'SF Pro Text',
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isChinese ? '将删除以下数据：' : 'This will delete:',
                    style: const TextStyle(
                      fontFamily: 'SF Pro Text',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isChinese
                        ? '• 所有物品记录\n• 所有整理记录\n• 所有回忆\n• 所有二手物品追踪\n• 所有照片和数据'
                        : '• All items\n• All sessions\n• All memories\n• All resell items\n• All photos and data',
                    style: const TextStyle(
                      fontFamily: 'SF Pro Text',
                      fontSize: 13,
                      color: Color(0xFF991B1B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              l10n.cancel,
              style: const TextStyle(
                fontFamily: 'SF Pro Text',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              // Show loading dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isChinese ? '正在清除数据...' : 'Clearing data...',
                        style: const TextStyle(
                          fontFamily: 'SF Pro Text',
                          fontSize: 15,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                ),
              );

              try {
                final repository = DataRepository();

                // Clear all data from repository
                await repository.clearAllData();

                // Close loading dialog
                if (mounted) {
                  Navigator.pop(context);
                }

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isChinese ? '所有数据已清除' : 'All data has been cleared',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                // Close loading dialog
                if (mounted) {
                  Navigator.pop(context);
                }

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isChinese ? '清除失败: $e' : 'Clear failed: $e',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(
              isChinese ? '清除' : 'Clear',
              style: const TextStyle(
                fontFamily: 'SF Pro Text',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isChinese = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('zh');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.logout,
          style: const TextStyle(
            fontFamily: 'SF Pro Display',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        content: Text(
          isChinese ? '确定要登出吗？' : 'Are you sure you want to log out?',
          style: const TextStyle(
            fontFamily: 'SF Pro Text',
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Color(0xFF111827),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: const TextStyle(
                fontFamily: 'SF Pro Text',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              // Show loading indicator
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isChinese ? '正在登出...' : 'Logging out...'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              }

              try {
                // Perform logout
                await _authService.signOut();

                // Navigate to welcome screen
                if (mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/welcome', (route) => false);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isChinese ? '登出失败: $e' : 'Logout failed: $e',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(
              isChinese ? '登出' : 'Log Out',
              style: const TextStyle(
                fontFamily: 'SF Pro Text',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openHelpSupport() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@keepjoy.app',
      query: 'subject=Help & Support',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open email client')),
        );
      }
    }
  }

  Future<void> _openPrivacyPolicy() async {
    final Uri url = Uri.parse('https://keepjoy.app/privacy');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open privacy policy')),
        );
      }
    }
  }

  Future<void> _openTermsOfService() async {
    final Uri url = Uri.parse('https://keepjoy.app/terms');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open terms of service')),
        );
      }
    }
  }

  Future<void> _rateApp() async {
    // For iOS
    final Uri iosUrl = Uri.parse('https://apps.apple.com/app/idYOUR_APP_ID');
    // For Android
    final Uri androidUrl = Uri.parse(
      'https://play.google.com/store/apps/details?id=com.keepjoy.app',
    );

    final Uri url = Platform.isIOS ? iosUrl : androidUrl;

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open app store')),
        );
      }
    }
  }

  Future<void> _shareApp() async {
    final isChinese = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('zh');

    final String shareText = isChinese
        ? '快来试试 KeepJoy - 用心动整理法让生活更美好！\n\nhttps://keepjoy.app'
        : 'Check out KeepJoy - Declutter your life with joy!\n\nhttps://keepjoy.app';

    await Share.share(shareText);
  }

  Future<void> _exportData(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final isChinese = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('zh');

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB794F6)),
            ),
            const SizedBox(height: 16),
            Text(
              isChinese ? '正在导出数据...' : 'Exporting data...',
              style: const TextStyle(
                fontFamily: 'SF Pro Text',
                fontSize: 15,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),
      ),
    );

    try {
      final repository = DataRepository();

      // Get all data from repository
      final items = await repository.fetchDeclutterItems();
      final sessions = await repository.fetchDeepCleaningSessions();
      final memories = await repository.fetchMemories();
      final resellItems = await repository.fetchResellItems();

      // Create comprehensive export data
      final exportData = {
        'version': '1.0.0',
        'exportDate': DateTime.now().toIso8601String(),
        'user': {'email': _userEmail, 'name': _userName},
        'data': {
          'items': items
              .map(
                (item) => {
                  'id': item.id,
                  'name': item.name,
                  'displayName': item.displayName(context),
                  'nameLocalizations': item.nameLocalizations,
                  'category': item.category.name,
                  'createdAt': item.createdAt.toIso8601String(),
                  'photoPath': item.photoPath,
                  'status': item.status.name,
                  'notes': item.notes,
                  'joyLevel': item.joyLevel,
                },
              )
              .toList(),
          'sessions': sessions
              .map(
                (session) => {
                  'id': session.id,
                  'area': session.area,
                  'startTime': session.startTime.toIso8601String(),
                  'elapsedSeconds': session.elapsedSeconds,
                  'itemsCount': session.itemsCount,
                  'beforePhotoPath': session.beforePhotoPath,
                  'afterPhotoPath': session.afterPhotoPath,
                  'focusIndex': session.focusIndex,
                  'moodIndex': session.moodIndex,
                },
              )
              .toList(),
          'memories': memories
              .map(
                (memory) => {
                  'id': memory.id,
                  'title': memory.title,
                  'itemName': memory.itemName,
                  'description': memory.description,
                  'sentiment': memory.sentiment?.name,
                  'createdAt': memory.createdAt.toIso8601String(),
                  'photoPath': memory.photoPath,
                  'type': memory.type.name,
                },
              )
              .toList(),
          'resellItems': resellItems
              .map(
                (item) => {
                  'id': item.id,
                  'declutterItemId': item.declutterItemId,
                  'status': item.status.name,
                  'platform': item.platform?.name,
                  'sellingPrice': item.sellingPrice,
                  'soldPrice': item.soldPrice,
                  'soldDate': item.soldDate?.toIso8601String(),
                  'createdAt': item.createdAt.toIso8601String(),
                },
              )
              .toList(),
        },
        'statistics': {
          'totalItems': items.length,
          'totalSessions': sessions.length,
          'totalMemories': memories.length,
          'totalResellItems': resellItems.length,
          'itemsKept': items
              .where((item) => item.status == DeclutterStatus.keep)
              .length,
          'itemsDiscarded': items
              .where((item) => item.status == DeclutterStatus.discard)
              .length,
          'itemsDonated': items
              .where((item) => item.status == DeclutterStatus.donate)
              .length,
          'itemsRecycled': items
              .where((item) => item.status == DeclutterStatus.recycle)
              .length,
          'itemsResell': items
              .where((item) => item.status == DeclutterStatus.resell)
              .length,
        },
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

      // Save to documents directory
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'keepjoy_export_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${directory.path}/$fileName');

      await file.writeAsString(jsonString);

      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);
      }

      if (mounted) {
        // Show success dialog with file location
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              isChinese ? '导出成功' : 'Export Successful',
              style: const TextStyle(
                fontFamily: 'SF Pro Display',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isChinese ? '你的数据已成功导出到：' : 'Your data has been exported to:',
                  style: const TextStyle(
                    fontFamily: 'SF Pro Text',
                    fontSize: 15,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    file.path,
                    style: const TextStyle(
                      fontFamily: 'SF Pro Text',
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isChinese
                      ? '包含 ${items.length} 个物品、${sessions.length} 个记录、${memories.length} 个回忆'
                      : 'Includes ${items.length} items, ${sessions.length} sessions, ${memories.length} memories',
                  style: const TextStyle(
                    fontFamily: 'SF Pro Text',
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  l10n.ok,
                  style: const TextStyle(
                    fontFamily: 'SF Pro Text',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFB794F6),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isChinese ? '导出失败: $e' : 'Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 24, color: textColor ?? const Color(0xFF6B7280)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'SF Pro Text',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: textColor ?? const Color(0xFF111827),
                  letterSpacing: 0,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: const Color(0xFF9CA3AF), size: 20),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFB794F6).withValues(alpha: 0.1)
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? const Color(0xFFB794F6)
                : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'SF Pro Text',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFFB794F6)
                      : const Color(0xFF111827),
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFFB794F6),
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
