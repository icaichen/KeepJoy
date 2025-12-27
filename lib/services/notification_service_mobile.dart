import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const int _generalReminderId = 1001;
  static const int _sessionReminderId = 1002;
  static const String _generalChannelId = 'keepjoy_general';
  static const String _sessionChannelId = 'keepjoy_session';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  static const MethodChannel _timeZoneChannel = MethodChannel(
    'com.keepjoy/timezone',
  );

  Future<String?> _getLocalTimezone() async {
    try {
      final value = await _timeZoneChannel.invokeMethod<String>(
        'getLocalTimezone',
      );
      if (value == null || value.trim().isEmpty) {
        return null;
      }
      return value;
    } catch (_) {
      return null;
    }
  }

  Future<bool> ensureInitialized() async {
    if (kIsWeb) {
      return false;
    }
    if (_initialized) {
      return true;
    }

    tz.initializeTimeZones();
    final timeZoneName = await _getLocalTimezone();
    if (timeZoneName != null) {
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } else {
      tz.setLocalLocation(tz.UTC);
    }

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _plugin.initialize(initializationSettings);
    _initialized = true;
    return true;
  }

  Future<bool> ensurePermissions() async {
    final initialized = await ensureInitialized();
    if (!initialized) {
      return false;
    }

    final androidImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final androidGranted =
        await androidImplementation?.requestNotificationsPermission() ?? true;

    final iosImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final iosGranted =
        await iosImplementation?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        true;

    return androidGranted && iosGranted;
  }

  Future<void> scheduleGeneralReminder({
    required String title,
    required String body,
    required int daysFromNow,
  }) async {
    if (!await ensureInitialized()) return;
    await cancelGeneralReminder();

    final scheduledDate = tz.TZDateTime.now(
      tz.local,
    ).add(Duration(days: daysFromNow));

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _generalChannelId,
        'KeepJoy General Reminders',
        channelDescription: 'Gentle nudges to continue your declutter journey.',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: const DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      _generalReminderId,
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'general_reminder',
    );
  }

  Future<void> cancelGeneralReminder() async {
    if (!await ensureInitialized()) return;
    await _plugin.cancel(_generalReminderId);
  }

  Future<void> scheduleActiveSessionReminder({
    required String title,
    required String body,
    required int minutesFromNow,
  }) async {
    if (!await ensureInitialized()) return;
    await cancelActiveSessionReminder();

    final scheduledDate = tz.TZDateTime.now(
      tz.local,
    ).add(Duration(minutes: minutesFromNow));

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _sessionChannelId,
        'KeepJoy Session Reminders',
        channelDescription:
            'Reminders to resume active deep cleaning sessions.',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(presentSound: true),
    );

    await _plugin.zonedSchedule(
      _sessionReminderId,
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'session_reminder',
    );
  }

  Future<void> cancelActiveSessionReminder() async {
    if (!await ensureInitialized()) return;
    await _plugin.cancel(_sessionReminderId);
  }
}
