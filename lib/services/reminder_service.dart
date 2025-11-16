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

    final granted = await NotificationService.instance.ensurePermissions();
    if (!granted) {
      _showSnackBar(
        context,
        AppLocalizations.of(context)?.notificationsPermissionDenied ??
            'Unable to enable notifications.',
      );
      return false;
    }

    await NotificationPreferencesService.setNotificationsEnabled(true);
    await evaluateAndScheduleGeneralReminder(context);
    return true;
  }

  static Future<void> disableGeneralReminders() async {
    if (kIsWeb) return;
    await NotificationPreferencesService.setNotificationsEnabled(false);
    await NotificationService.instance.cancelGeneralReminder();
    await NotificationService.instance.cancelActiveSessionReminder();
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
