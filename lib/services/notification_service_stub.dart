class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  Future<bool> ensureInitialized() async => false;
  Future<bool> ensurePermissions() async => false;
  Future<void> scheduleGeneralReminder({
    required String title,
    required String body,
    required int daysFromNow,
  }) async {}

  Future<void> cancelGeneralReminder() async {}

  Future<void> scheduleActiveSessionReminder({
    required String title,
    required String body,
    required int minutesFromNow,
  }) async {}

  Future<void> cancelActiveSessionReminder() async {}
}
