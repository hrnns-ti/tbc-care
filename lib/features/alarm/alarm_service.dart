import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class AlarmService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // 1. Inisialisasi Notifikasi & Zona Waktu
  // 1. Inisialisasi Notifikasi & Zona Waktu
  static Future<void> init() async {
    // Setup Timezone
    tz.initializeTimeZones();

    // Mengambil data timezone mentah dari perangkat
    final rawTimeZone = await FlutterTimezone.getLocalTimezone();
    String timeZoneName = rawTimeZone.toString();

    // Logika Pembersihan: Jika mengembalikan format "TimezoneInfo(Asia/Jakarta, ...)"
    if (timeZoneName.contains('(') && timeZoneName.contains(',')) {
      // Ambil teks di antara '(' dan ',' yaitu "Asia/Jakarta"
      timeZoneName = timeZoneName.split('(')[1].split(',')[0].trim();
    } else if (timeZoneName.contains('(') && timeZoneName.contains(')')) {
      // Jaga-jaga jika formatnya "TimezoneInfo(Asia/Jakarta)"
      timeZoneName = timeZoneName.split('(')[1].split(')')[0].trim();
    }

    // Eksekusi dengan nama yang sudah bersih (misal: "Asia/Jakarta")
    try {
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      // Fallback paling aman untuk area Indonesia Barat jika parsing gagal
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    }

    // Setup Notifikasi Android
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);
  }

  // 2. Minta Izin
  static Future<void> requestPermission() async {
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.requestNotificationsPermission();
    await androidImplementation?.requestExactAlarmsPermission();
  }

  static Future<void> scheduleAlarm(DateTime scheduledTime, int alarmId) async {

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'tb_reminder_channel_v4',
      'Pengingat Minum Obat',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('alarm'),
      additionalFlags: Int32List.fromList(<int>[4]),
    );

    final NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    final tz.TZDateTime scheduledTZTime = tz.TZDateTime.from(scheduledTime, tz.local);

    await _notificationsPlugin.zonedSchedule(
      alarmId,
      'Waktunya Minum Obat! 💊',
      'Jangan lupa konfirmasi setelah minum obat ya.',
      scheduledTZTime,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}