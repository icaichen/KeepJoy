import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.onLocaleChange});

  final void Function(Locale) onLocaleChange;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Settings Section
            _buildSectionTitle(context, l10n.settings),
            SizedBox(height: screenHeight * 0.01),
            Card(
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.language,
                    title: l10n.language,
                    onTap: () {
                      _showLanguageDialog(context);
                    },
                  ),
                  Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.notifications_outlined,
                    title: l10n.notifications,
                    onTap: () {
                      // TODO: Implement notifications settings
                    },
                  ),
                  Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.palette_outlined,
                    title: l10n.theme,
                    onTap: () {
                      _showThemeDialog(context);
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.03),

            // Support & Information Section
            _buildSectionTitle(context, l10n.support),
            SizedBox(height: screenHeight * 0.01),
            Card(
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.help_outline,
                    title: l10n.helpAndSupport,
                    onTap: () {
                      // TODO: Implement help
                    },
                  ),
                  Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.info_outline,
                    title: l10n.aboutApp,
                    onTap: () {
                      _showAboutDialog(context);
                    },
                  ),
                  Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    title: l10n.privacyPolicy,
                    onTap: () {
                      // TODO: Implement privacy policy
                    },
                  ),
                  Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.description_outlined,
                    title: l10n.termsOfService,
                    onTap: () {
                      // TODO: Implement terms
                    },
                  ),
                  Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.star_outline,
                    title: l10n.rateApp,
                    onTap: () {
                      // TODO: Implement rate app
                    },
                  ),
                  Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.share_outlined,
                    title: l10n.shareApp,
                    onTap: () {
                      // TODO: Implement share
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.03),

            // Data Management Section
            _buildSectionTitle(context, l10n.data),
            SizedBox(height: screenHeight * 0.01),
            Card(
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.download_outlined,
                    title: l10n.exportData,
                    onTap: () {
                      // TODO: Implement export
                    },
                  ),
                  Divider(height: 1),
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
            SizedBox(height: screenHeight * 0.03),

            // Version
            Center(
              child: Text(
                '${l10n.version} 1.0.0',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
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
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
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
        title: Text(l10n.languageSettings),
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
            SizedBox(height: 8),
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

  void _showThemeDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.theme),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ThemeOption(
              title: l10n.lightMode,
              isSelected: false,
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement theme switching
              },
            ),
            SizedBox(height: 8),
            _ThemeOption(
              title: l10n.darkMode,
              isSelected: true,
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement theme switching
              },
            ),
            SizedBox(height: 8),
            _ThemeOption(
              title: l10n.systemDefault,
              isSelected: false,
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement theme switching
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
        title: Text(l10n.aboutApp),
        content: Text(
          'KeepJoy helps you declutter your life with joy.\n\n${l10n.version} 1.0.0',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isChinese = Localizations.localeOf(context)
        .languageCode
        .toLowerCase()
        .startsWith('zh');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearAllData),
        content: Text(
          isChinese
              ? '确定要清除所有数据吗？此操作无法撤销。'
              : 'Are you sure you want to clear all data? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement clear data
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isChinese ? '数据已清除' : 'Data cleared',
                  ),
                ),
              );
            },
            child: Text(
              isChinese ? '清除' : 'Clear',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 24, color: textColor),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: textColor,
                    ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey),
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
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(child: Text(title)),
            if (isSelected)
              Icon(
                Icons.check,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(child: Text(title)),
            if (isSelected)
              Icon(
                Icons.check,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}
