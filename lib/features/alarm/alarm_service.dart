import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

// 1. FUNGSI WAJIB DI LUAR KELAS (Top-Level Function)
@pragma('vm:entry-point')
void fireAlarm() async {
  // Tambahkan baris ini untuk memastikan plugin register siap di isolate baru
  final FlutterLocalNotificationsPlugin backgroundPlugin =
  FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings =
  InitializationSettings(android: initSettingsAndroid);

  await backgroundPlugin.initialize(initSettings);

  const AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails(
    'tb_reminder_channel',
    'Pengingat Minum Obat',
    channelDescription: 'Channel untuk notifikasi waktu minum obat TBC',
    importance: Importance.max,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
  );

  const NotificationDetails platformChannelSpecifics =
  NotificationDetails(android: androidPlatformChannelSpecifics);

  await backgroundPlugin.show(
    DateTime.now().second, // ID dinamis
    'Waktunya Minum Obat! 💊',
    'Jangan lupa konfirmasi setelah minum obat ya.',
    platformChannelSpecifics,
  );
}

// 2. KELAS ALARM SERVICE
class AlarmService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);
    await AndroidAlarmManager.initialize();
  }

  static Future<void> requestPermission() async {
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.requestNotificationsPermission();
    await androidImplementation?.requestExactAlarmsPermission();
  }

  static Future<void> scheduleAlarm(DateTime scheduledTime, int alarmId) async {
    await AndroidAlarmManager.oneShotAt(
      scheduledTime,
      alarmId,
      fireAlarm, // Panggil fungsi top-level di atas
      exact: true,
      wakeup: true,
    );
  }
}