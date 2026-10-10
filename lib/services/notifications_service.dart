import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/tasks.dart';

class NotificationsService {
  NotificationsService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    try {
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
      macOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
      linux: LinuxInitializationSettings(defaultActionName: 'Open taskMS'),
      windows: WindowsInitializationSettings(
        appName: 'taskMS',
        appUserModelId: 'com.example.taskms',
        guid: '94391d63-17e3-4af3-a2cf-2a9198dd80d7',
      ),
      web: WebInitializationSettings(),
    );
    _initialized = await _plugin.initialize(settings: settings) ?? false;
  }

  static Future<bool> requestPermission() async {
    if (!_initialized) await initialize();

    if (kIsWeb) {
      final webPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            WebFlutterLocalNotificationsPlugin
          >();
      return await webPlugin?.requestNotificationsPermission() ?? false;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return await _plugin
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >()
                ?.requestNotificationsPermission() ??
            false;
      case TargetPlatform.iOS:
        return await _plugin
                .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin
                >()
                ?.requestPermissions(alert: true, badge: true, sound: true) ??
            false;
      case TargetPlatform.macOS:
        return await _plugin
                .resolvePlatformSpecificImplementation<
                  MacOSFlutterLocalNotificationsPlugin
                >()
                ?.requestPermissions(alert: true, badge: true, sound: true) ??
            false;
      case TargetPlatform.linux:
      case TargetPlatform.windows:
      case TargetPlatform.fuchsia:
        return true;
    }
  }

  static Future<void> remindAboutTask(ProjectTask task) async {
    if (!_initialized) await initialize();
    final id = task.id ?? task.title.hashCode.abs();
    await _plugin.cancel(id: id);
    final details = const NotificationDetails(
      android: AndroidNotificationDetails(
        'task_deadlines',
        'Task reminders',
        channelDescription: 'Reminders about upcoming task deadlines.',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
      linux: LinuxNotificationDetails(),
      windows: WindowsNotificationDetails(),
      web: WebNotificationDetails(),
    );

    // Browsers and Linux desktops cannot reliably deliver scheduled alerts.
    // Show an immediate local notice there; mobile and Windows get a due-time
    // reminder when the deadline is still far enough in the future.
    if (kIsWeb || defaultTargetPlatform == TargetPlatform.linux) {
      await _plugin.show(
        id: id,
        title: 'Task saved',
        body: '“${task.title}” is due ${_dueLabel(task.deadline)}.',
        notificationDetails: details,
      );
      return;
    }
