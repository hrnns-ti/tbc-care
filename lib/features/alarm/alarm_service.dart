import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class AlarmService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Nama Channel ID wajib konsisten agar sistem Android mengenali properti suaranya
  static const String _channelId = 'tb_reminder_channel_v4';

  // ======================================================================
  // 1. INISIALISASI NOTIFIKASI & ZONA WAKTU
  // ======================================================================
  static Future<void> init() async {
    // Inisialisasi basis data zona waktu global
    tz.initializeTimeZones();

    // Mengambil nama lokasi asli dari sistem operasi perangkat (contoh: "Asia/Jakarta")
    final rawTimeZone = await FlutterTimezone.getLocalTimezone();
    String timeZoneName = rawTimeZone.toString();

    // Pembersihan string format khusus jika terdeteksi (Bug bawaan beberapa tipe HP)
    if (timeZoneName.contains('(') && timeZoneName.contains(',')) {
      timeZoneName = timeZoneName.split('(')[1].split(',')[0].trim();
    } else if (timeZoneName.contains('(') && timeZoneName.contains(')')) {
      timeZoneName = timeZoneName.split('(')[1].split(')')[0].trim();
    }

    try {
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      // Jika zona waktu perangkat gagal diparsing, kunci ke WIB sebagai fallback aman
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    }

    // Ambil implementasi spesifik Android untuk mendaftarkan Notification Channel resmi
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
    _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      'Pengingat Minum Obat',
      description: 'Channel utama untuk alarm pengingat minum obat TBC',
      importance: Importance.max, // Memastikan notifikasi melayang di atas layar (Heads-up)
      playSound: true,
      sound: RawResourceAndroidNotificationSound('alarm'), // Mengarah ke res/raw/alarm.mp3
    );

    // Daftarkan ke sistem inti Android OS
    await androidImplementation?.createNotificationChannel(channel);

    // Atur ikon bawaan yang muncul di status bar HP
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);
  }

  // ======================================================================
  // 2. REQUEST IZIN SISTEM OPERASI (Dibutuhkan untuk Android 13+)
  // ======================================================================
  static Future<void> requestPermission() async {
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    // Meminta izin memunculkan notifikasi pop-up
    await androidImplementation?.requestNotificationsPermission();
    // Meminta izin eksekusi alarm tepat waktu (Exact Alarm) saat HP tertidur/idle
    await androidImplementation?.requestExactAlarmsPermission();
  }

  // ======================================================================
  // 3. MENJADWALKAN ALARM BERKALA (DENGAN FIX BIAS DETIK)
  // ======================================================================
  static Future<void> scheduleAlarm(DateTime scheduledTime, int alarmId) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      _channelId,
      'Pengingat Minum Obat',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('alarm'),
      // Flag angka 4 artinya FLAG_INSISTENT. Membuat musik alarm berbunyi terus-menerus
      // tanpa berhenti sampai pasien membuka HP dan menekan tombol konfirmasi.
      additionalFlags: Int32List.fromList(<int>[4]),
    );

    final NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    // KUNCI UTAMA FIX: Paksa komponen detik dan milidetik ke angka 0 bersih!
    final cleanedTime = DateTime(
        scheduledTime.year,
        scheduledTime.month,
        scheduledTime.day,
        scheduledTime.hour,
        scheduledTime.minute,
        0, 0
    );

    // Konversi ke format TZDateTime yang dipahami library timezone
    tz.TZDateTime scheduledTZTime = tz.TZDateTime.from(cleanedTime, tz.local);
    final nowTZ = tz.TZDateTime.now(tz.local);

    // Jika target waktu persis sama dengan jam sekarang ATAU sudah terlewat beberapa menit lalu,
    // langsung lemparkan penempatan alarm pertamanya ke esok hari agar aman dari bug hangus instan.
    if (scheduledTZTime.isBefore(nowTZ) ||
        (scheduledTZTime.hour == nowTZ.hour && scheduledTZTime.minute == nowTZ.minute)) {
      scheduledTZTime = scheduledTZTime.add(const Duration(days: 1));
    }

    // Batalkan terlebih dahulu ID alarm lama untuk mencegah penumpukan ID kembar di memory Android
    await _notificationsPlugin.cancel(alarmId);

    // Daftarkan ke sistem penjadwalan Android OS
    await _notificationsPlugin.zonedSchedule(
      alarmId,
      'Waktunya Minum Obat! 💊',
      'Jangan lupa konfirmasi setelah minum obat ya.',
      scheduledTZTime,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Tetap paksa berbunyi walau HP dalam mode hemat baterai Doze
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Membuat alarm otomatis mengulang di jam yang sama setiap harinya
    );

    debugPrint('➡️ ALARM DAFTAR: ID [$alarmId] dipasang untuk target: $scheduledTZTime');
  }

  // ======================================================================
  // 4. MEMBATALKAN ALARM
  // ======================================================================
  static Future<void> cancelAlarm(int id) async {
    try {
      await _notificationsPlugin.cancel(id);
      debugPrint('🗑️ Alarm ID $id berhasil dibersihkan dari sistem Android.');
    } catch (e) {
      debugPrint('Gagal membatalkan alarm dengan ID $id: $e');
    }
  }
}