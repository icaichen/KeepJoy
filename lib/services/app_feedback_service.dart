import 'dart:io';
import 'dart:ui';

import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_links.dart';

class AppFeedbackService {
  AppFeedbackService._();

  static final InAppReview _inAppReview = InAppReview.instance;

  /// Request the native in-app review dialog or fall back to the store.
  static Future<void> rateApp() async {
    try {
      final isAvailable = await _inAppReview.isAvailable();
      if (isAvailable) {
        await _inAppReview.requestReview();
        return;
      }
    } catch (_) {
      // Ignore and fall back to store URL below.
    }

    final storeUrl = Platform.isIOS
        ? AppLinks.iosAppStoreUrl
        : AppLinks.androidPlayStoreUrl;

    if (!storeUrl.startsWith('http')) {
      return;
    }

    final uri = Uri.tryParse(storeUrl);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Share a preset message plus the final share URL once available.
  static Future<void> shareApp() async {
    final locale = PlatformDispatcher.instance.locale;
    final isChinese = locale.languageCode.toLowerCase().startsWith('zh');
    final text = isChinese
        ? '我在用 KeepJoy 整理和管理物品，你也可以试试：${AppLinks.shareUrl}'
        : 'I am using KeepJoy to declutter with joy. Try it too: ${AppLinks.shareUrl}';
    await Share.share(text);
  }
}
