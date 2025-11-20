import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/data_repository.dart';
import '../models/planned_session.dart';
import 'notification_preferences_service.dart';
import 'notification_service_stub.dart'
    if (dart.library.io) 'notification_service_mobile.dart';

class ReminderService {
  static final Random _random = Random();

  static Future<bool> enableGeneralReminders(BuildContext context) async {
    if (kIsWeb) {
      _showSnackBar(context, 'Notifications are not supported on web.');
      return false;
    }

    try {
      final granted = await NotificationService.instance.ensurePermissions();
      if (!granted) {
        final l10n = AppLocalizations.of(context);
        final isChinese = l10n?.localeName.startsWith('zh') ?? false;
        _showSnackBar(
          context,
          isChinese
              ? '无法启用通知。请在系统设置中允许通知权限。'
              : 'Unable to enable notifications. Please allow notification permissions in system settings.',
        );
        return false;
      }

      await NotificationPreferencesService.setNotificationsEnabled(true);
      await evaluateAndScheduleGeneralReminder(context);

      final l10n = AppLocalizations.of(context);
      final isChinese = l10n?.localeName.startsWith('zh') ?? false;
      _showSnackBar(context, isChinese ? '通知已启用' : 'Notifications enabled');
      return true;
    } catch (e) {
      final l10n = AppLocalizations.of(context);
      final isChinese = l10n?.localeName.startsWith('zh') ?? false;
      _showSnackBar(
        context,
        isChinese ? '启用通知失败：$e' : 'Failed to enable notifications: $e',
      );
      return false;
    }
  }

  static Future<void> disableGeneralReminders(BuildContext context) async {
    if (kIsWeb) return;
    try {
      await NotificationPreferencesService.setNotificationsEnabled(false);
      await NotificationService.instance.cancelGeneralReminder();
      await NotificationService.instance.cancelActiveSessionReminder();

      final l10n = AppLocalizations.of(context);
      final isChinese = l10n?.localeName.startsWith('zh') ?? false;
      _showSnackBar(context, isChinese ? '通知已关闭' : 'Notifications disabled');
    } catch (e) {
      final l10n = AppLocalizations.of(context);
      final isChinese = l10n?.localeName.startsWith('zh') ?? false;
      _showSnackBar(
        context,
        isChinese ? '关闭通知失败：$e' : 'Failed to disable notifications: $e',
      );
    }
  }

  static Future<void> evaluateAndScheduleGeneralReminder(
    BuildContext context,
  ) async {
    if (kIsWeb) return;
    final enabled =
        await NotificationPreferencesService.areNotificationsEnabled();
    if (!enabled) return;

    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;

    final hasPending = await _hasPendingSessions();
    final body = hasPending
        ? _pendingMessages(l10n)[_random.nextInt(_pendingMessages(l10n).length)]
        : _joyMessages(l10n)[_random.nextInt(_joyMessages(l10n).length)];
    final days = _random.nextBool() ? 3 : 4;

    await NotificationService.instance.scheduleGeneralReminder(
      title: l10n.reminderGeneralTitle,
      body: body,
      daysFromNow: days,
    );
  }

  static Future<void> scheduleActiveSessionReminder(
    BuildContext context,
  ) async {
    if (kIsWeb) return;
    final enabled =
        await NotificationPreferencesService.areNotificationsEnabled();
    if (!enabled) return;
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;

    await NotificationService.instance.scheduleActiveSessionReminder(
      title: l10n.reminderActiveSessionTitle,
      body: l10n.reminderActiveSessionBody,
      minutesFromNow: 10,
    );
  }

  static Future<void> cancelActiveSessionReminder() async {
    if (kIsWeb) return;
    await NotificationService.instance.cancelActiveSessionReminder();
  }

  static Future<bool> _hasPendingSessions() async {
    try {
      final sessions = await DataRepository().fetchPlannedSessions();
      final now = DateTime.now();
      return sessions.any(
        (PlannedSession session) =>
            !session.isCompleted &&
            (session.scheduledDate == null ||
                session.scheduledDate!.isAfter(
                  now.subtract(const Duration(days: 1)),
                )),
      );
    } catch (_) {
      return false;
    }
  }

  static List<String> _joyMessages(AppLocalizations l10n) => [
    l10n.reminderJoyNudge1,
    l10n.reminderJoyNudge2,
    l10n.reminderJoyNudge3,
  ];

  static List<String> _pendingMessages(AppLocalizations l10n) => [
    l10n.reminderPendingTask1,
    l10n.reminderPendingTask2,
  ];

  static void _showSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
