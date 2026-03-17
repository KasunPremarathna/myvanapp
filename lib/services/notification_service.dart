import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import '../main.dart';

class NotificationService {
  static Future<void> scheduleReminder({
    required int id,
    required String vanModel,
    required String description,
    required DateTime scheduledDate,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'myvan_reminders',
      'My Van Reminders',
      channelDescription: 'Van service reminders',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      '🔧 Service Reminder: $vanModel',
      description.isNotEmpty ? description : 'Time for your van service!',
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelReminder(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  static Future<bool> requestPermissions() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  static const int _reEngagementId = 999;

  static Future<void> scheduleReEngagementReminder() async {
    // Cancel any existing one first
    await flutterLocalNotificationsPlugin.cancel(_reEngagementId);

    final scheduledDate = DateTime.now().add(const Duration(days: 5));
    
    await flutterLocalNotificationsPlugin.zonedSchedule(
      _reEngagementId,
      'We miss you! 🚗',
      'Check your van\'s service status and fuel records in My Van app.',
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          're_engagement_channel',
          'Re-engagement Reminders',
          channelDescription: 'Reminders when the app hasn\'t been opened for a while',
          importance: Importance.low,
          priority: Priority.low,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
