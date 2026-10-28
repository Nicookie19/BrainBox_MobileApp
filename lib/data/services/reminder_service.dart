import 'package:flutter/material.dart';

abstract class ReminderService {
  /// Initialize the reminder service
  Future<void> initialize();

  /// Schedule a daily reminder at the specified time
  Future<void> scheduleDailyReminder(TimeOfDay time);

  /// Cancel all scheduled reminders
  Future<void> cancelAllReminders();

  /// Check if reminders are enabled
  Future<bool> areRemindersEnabled();

  /// Request notification permissions
  Future<bool> requestPermissions();

  /// Dispose resources
  void dispose();
}

/// No-op implementation for platforms that don't support notifications (e.g., Web)
class NoOpReminderService implements ReminderService {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> scheduleDailyReminder(TimeOfDay time) async {}

  @override
  Future<void> cancelAllReminders() async {}

  @override
  Future<bool> areRemindersEnabled() async => false;

  @override
  Future<bool> requestPermissions() async => false;

  @override
  void dispose() {}
}

/// Real implementation using local_notifications package
/// This is a stub - actual implementation would use flutter_local_notifications
class LocalNotificationsReminderService implements ReminderService {
  bool _initialized = false;
  bool _permissionsGranted = false;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    // In a real implementation, this would initialize flutter_local_notifications
    // await _notificationsPlugin.initialize(...);
    _initialized = true;
    _permissionsGranted = await requestPermissions();
  }

  @override
  Future<void> scheduleDailyReminder(TimeOfDay time) async {
    if (!_initialized) await initialize();
    if (!_permissionsGranted) return;

    // In a real implementation:
    // await _notificationsPlugin.zonedSchedule(
    //   0,
    //   'Time to learn!',
    //   'Your daily lesson is waiting.',
    //   _nextInstanceOfTime(time),
    //   const NotificationDetails(
    //     android: AndroidNotificationDetails(
    //       'daily_reminder',
    //       'Daily Reminder',
    //       channelDescription: 'Daily learning reminder',
    //       importance: Importance.high,
    //       priority: Priority.high,
    //     ),
    //     iOS: DarwinNotificationDetails(),
    //   ),
    //   androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    //   matchDateTimeComponents: DateTimeComponents.time,
    // );
  }

  @override
  Future<void> cancelAllReminders() async {
    if (!_initialized) return;
    // await _notificationsPlugin.cancelAll();
  }

  @override
  Future<bool> areRemindersEnabled() async {
    return _permissionsGranted;
  }

  @override
  Future<bool> requestPermissions() async {
    // In a real implementation:
    // final androidResult = await _notificationsPlugin
    //     .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
    //     ?.requestNotifications();
    // final iosResult = await _notificationsPlugin
    //     .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
    //     ?.requestPermissions(alert: true, badge: true, sound: true);
    // _permissionsGranted = (androidResult ?? false) || (iosResult ?? false);
    // return _permissionsGranted;
    _permissionsGranted = true; // Stub for testing
    return true;
  }

  @override
  void dispose() {
    // _notificationsPlugin.dispose();
  }
}

/// Factory to get the appropriate reminder service for the platform
class ReminderServiceFactory {
  static ReminderService? _instance;

  static ReminderService get instance {
    _instance ??= _createService();
    return _instance!;
  }

  static ReminderService _createService() {
    // On Web, use NoOpReminderService
    // On mobile, use LocalNotificationsReminderService
    // For now, use NoOpReminderService as default
    return NoOpReminderService();
  }

  static void setInstance(ReminderService service) {
    _instance?.dispose();
    _instance = service;
  }

  static void resetForTesting() {
    _instance?.dispose();
    _instance = null;
  }
}
