import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../../l10n/app_localizations.dart';
import '../../services/app_feedback_service.dart';
import '../../services/auth_service.dart';
import '../../services/data_repository.dart';
import '../../services/notification_preferences_service.dart';
import '../../services/reminder_service.dart';
import '../../models/declutter_item.dart';
import '../../providers/subscription_provider.dart';
import '../../ui/paywall/paywall_page.dart';
import '../../widgets/smart_image_widget.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.onLocaleChange});

  final void Function(Locale) onLocaleChange;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _authService = AuthService();
  bool _notificationsEnabled = false;
  bool _notificationsLoading = true;

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

  String? get _avatarPath {
    final metadata = _authService.currentUser?.userMetadata;
    if (metadata != null && metadata['avatar_url'] != null) {
      return metadata['avatar_url'] as String;
    }
    return null;
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

  /// Build profile avatar using SmartImageWidget for fast loading
  /// Same pattern as resell item images - loads instantly with proper caching
  Widget _buildProfileAvatar() {
    const avatarSize = 80.0;
    
    // Placeholder with user initial
    Widget placeholder = CircleAvatar(
      radius: 40,
      backgroundColor: const Color(0xFFB794F6).withValues(alpha: 0.15),
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
    );

    if (_avatarPath == null || _avatarPath!.isEmpty) {
      return placeholder;
    }

    // Use SmartImageWidget for both local and remote paths
    // This has the same fast caching as resell item images
    return ClipOval(
      child: SizedBox(
        width: avatarSize,
        height: avatarSize,
        child: SmartImageWidget(
          localPath: _avatarPath!.startsWith('http') ? null : _avatarPath,
          remotePath: _avatarPath!.startsWith('http') ? _avatarPath : null,
          fit: BoxFit.cover,
          width: avatarSize,
          height: avatarSize,
          placeholder: placeholder,
          errorWidget: placeholder,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
  }

  Future<void> _loadNotificationPreference() async {
    final enabled =
        await NotificationPreferencesService.areNotificationsEnabled();
    if (!mounted) return;
    setState(() {
      _notificationsEnabled = enabled;
      _notificationsLoading = false;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    if (_notificationsLoading) return;
    setState(() {
      _notificationsLoading = true;
    });

    if (value) {
      final success = await ReminderService.enableGeneralReminders(context);
      if (mounted) {
        setState(() {
          _notificationsEnabled = success ? true : _notificationsEnabled;
          _notificationsLoading = false;
        });
      }
    } else {
      await ReminderService.disableGeneralReminders(context);
      if (mounted) {
        setState(() {
          _notificationsEnabled = false;
          _notificationsLoading = false;
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
                    // Profile Avatar - uses SmartImageWidget for fast loading
                    _buildProfileAvatar(),
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
                    onTap: () {},
                    trailing: Switch(
                      value: _notificationsEnabled,
                      onChanged: _notificationsLoading
                          ? null
                          : _toggleNotifications,
                      activeColor: const Color(0xFFB794F6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Premium Section
            _buildSectionTitle(context, l10n.premiumMembership),
            const SizedBox(height: 12),
            Consumer<SubscriptionProvider>(
              builder: (context, subscriptionProvider, _) {
                if (subscriptionProvider.isLoading) {
                  return Container(
                    padding: const EdgeInsets.all(20),
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
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }

                if (subscriptionProvider.isPremium) {
                  return _buildPremiumActiveCard(
                    context,
                    l10n,
                    subscriptionProvider.isInTrial,
                    subscriptionProvider.expirationDate,
                  );
                } else {
                  return _buildUpgradeCard(context, l10n);
                }
              },
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
                      AppFeedbackService.rateApp();
                    },
                  ),
                  const Divider(height: 1, indent: 56),
                  _SettingsTile(
                    icon: Icons.share_outlined,
                    title: l10n.shareApp,
                    onTap: () {
                      AppFeedbackService.shareApp();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Data Management Section
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
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.delete_forever_outlined,
                    title: l10n.deleteAccount,
                    textColor: Colors.red,
                    onTap: () => _confirmDeleteAccount(context, l10n),
                  ),
                  const Divider(height: 1, indent: 56),
                  _SettingsTile(
                    icon: Icons.logout,
                    title: l10n.logout,
                    textColor: Colors.red,
                    onTap: () {
                      _showLogoutDialog(context);
                    },
                  ),
                ],
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

  Future<void> _confirmDeleteAccount(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final isChinese =
        Localizations.localeOf(context).languageCode.toLowerCase() == 'zh';

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.deleteAccountConfirmTitle,
          style: const TextStyle(
            fontFamily: 'SF Pro Display',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        content: Text(
          l10n.deleteAccountConfirmMessage,
          style: const TextStyle(
            fontFamily: 'SF Pro Text',
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Color(0xFF111827),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
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
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              l10n.deleteAccountButton,
              style: const TextStyle(
                fontFamily: 'SF Pro Text',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    // Show a simple loading dialog
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Row(
            children: [
              const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
              const SizedBox(width: 16),
              Flexible(
                child: Text(
                  l10n.deletingAccount,
                  style: const TextStyle(
                    fontFamily: 'SF Pro Text',
                    fontSize: 15,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      await _authService.deleteAccount();
      if (!mounted) return;
      // Close loading dialog; auth listener will redirect to welcome.
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isChinese ? '账号已删除' : 'Account deleted.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isChinese
                ? '删除账号失败：${e.toString()}'
                : 'Failed to delete account: ${e.toString()}',
          ),
        ),
      );
    }
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

                // CRITICAL: Navigate to welcome page and clear all previous routes
                // This ensures the user cannot go back to authenticated screens
                if (mounted && context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/welcome',
                    (route) => false, // Remove all previous routes
                  );
                }
              } catch (e) {
                if (mounted && context.mounted) {
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
      path: 'contact.keepjoy@gmail.com',
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
    final Uri url = Uri.parse('https://keepjoy-site.vercel.app/privacy.html');

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
    final Uri url = Uri.parse('https://keepjoy-site.vercel.app/terms.html');

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
                  'photoPath': item.localPhotoPath ?? item.remotePhotoPath,
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
                  'beforePhotoPath': session.localBeforePhotoPath ?? session.remoteBeforePhotoPath,
                  'afterPhotoPath': session.localAfterPhotoPath ?? session.remoteAfterPhotoPath,
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
                  'photoPath': memory.localPhotoPath ?? memory.remotePhotoPath,
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

  Widget _buildPremiumActiveCard(
    BuildContext context,
    AppLocalizations l10n,
    bool isInTrial,
    DateTime? expirationDate,
  ) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    String statusText = isInTrial ? l10n.trialActive : l10n.premiumActive;
    String expiryText = expirationDate != null
        ? l10n.renewsOn(dateFormat.format(expirationDate))
        : '';

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) => const PaywallPage(),
            fullscreenDialog: true,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF5ECFB8), Color(0xFFB794F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5ECFB8).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusText,
                      style: const TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    if (expiryText.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        expiryText,
                        style: TextStyle(
                          fontFamily: 'SF Pro Text',
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpgradeCard(BuildContext context, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) => const PaywallPage(),
            fullscreenDialog: true,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0EA5E9).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.star,
                  color: Color(0xFF0EA5E9),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.upgradeToPremium,
                      style: const TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.premiumMembershipDescription,
                      style: const TextStyle(
                        fontFamily: 'SF Pro Text',
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF9CA3AF),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.textColor,
    this.trailing,
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
            trailing ??
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF9CA3AF),
                  size: 20,
                ),
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
