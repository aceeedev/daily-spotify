import 'dart:io' show Platform;
import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:daily_spotify/backend/database_manager.dart' as db;

class NotificationManager {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future init({bool initScheduled = false}) async {
    // initialize the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestSoundPermission: false,
      requestBadgePermission: false,
    );
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );

    if (initScheduled) {
      tz.initializeTimeZones();

      final locationName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(locationName));
    }
  }

  static Future<bool> requestPermissions() async {
    bool? result = false;

    bool notificationsEnabled =
        await db.Config.instance.getNotificationsEnabled();
    if (notificationsEnabled) {
      if (Platform.isAndroid) {
        result = await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()!
            .requestPermission();
      } else if (Platform.isIOS) {
        result = await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
      }
    }

    result ??= false;
    db.Config.instance.saveNotificationsEnabled(result);

    return result;
  }

  static Future scheduleNotifications() async {
    const Duration buffer = Duration(hours: 3);
    const List<String> possibleNotificationMessages = [
      'Your pitch is ready!',
      'Discover new music!',
      'Your pitch is waiting for you',
      'Today\'s your pitch is going to be a banger',
      'Today\'s your pitch is 🔥',
      'Your pitch just dropped 😎',
    ];

    DateTime now = DateTime.now();

    // see if notifications should be scheduled
    bool notificationsEnabled =
        await db.Config.instance.getNotificationsEnabled();
    DateTime? lastTimeNotificationsScheduled =
        await db.Config.instance.getLastTimeNotificationsScheduled();
    bool timeToScheduleNotifications = lastTimeNotificationsScheduled == null
        ? true
        : now.difference(lastTimeNotificationsScheduled).inDays >= 1;
    if (!notificationsEnabled || !timeToScheduleNotifications) return;

    await _flutterLocalNotificationsPlugin.cancelAll();

    const List<Duration> whenToScheduleList = [
      Duration(days: 1),
      Duration(days: 2),
      Duration(days: 3),
      Duration(days: 7)
    ];

    for (int i = 0; i < whenToScheduleList.length; i++) {
      final Duration duration = whenToScheduleList[i];
      // add slight randomization to each schedule
      final Duration offset = Duration(
          milliseconds: -buffer.inMilliseconds +
              Random().nextInt(buffer.inMilliseconds * 2));
      final Duration randomizedDuration = Duration(
          milliseconds: duration.inMilliseconds + offset.inMilliseconds);

      // make sure randomization does not push notification to another date
      final Duration scheduledDuration =
          now.difference(now.add(offset)).inDays == 0
              ? randomizedDuration
              : duration;

      await _flutterLocalNotificationsPlugin.zonedSchedule(
          i,
          possibleNotificationMessages[
              Random().nextInt(possibleNotificationMessages.length)],
          'Click to find out your pitch',
          tz.TZDateTime.now(tz.local).add(scheduledDuration),
          const NotificationDetails(
              android: AndroidNotificationDetails('your pitch', 'your pitch',
                  channelDescription: 'notifications for your pitch'),
              iOS: DarwinNotificationDetails()),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime);
    }

    await db.Config.instance.saveLastTimeNotificationsScheduled(now);
  }

  static Future<List<PendingNotificationRequest>>
      getScheduledNotifications() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }
}
