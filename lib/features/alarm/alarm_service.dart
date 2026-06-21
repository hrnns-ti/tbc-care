import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class AlarmService {

  // ======================================================================
  // 1. INISIALISASI UTAMA (Dipanggil di main.dart)
  // ======================================================================
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Alarm.init();
  }

  // ======================================================================
  // NEW: MEMENUHI KEBUTUHAN REGISTRATION_VIEW
  // ======================================================================
  static Future<bool> requestPermission() async {
    // Meminta izin notifikasi (Wajib untuk Android 13+)
    final status = await Permission.notification.request();

    // Meminta izin exact alarm jika belum aktif (Android 12+)
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }

    return status.isGranted;
  }

  // ======================================================================
  // 2. REKUES IZIN OPTIMASI BATERAI (Edukasi User demi Keandalan OEM)
  // ======================================================================
  static Future<void> checkAndRequestBatteryOptimization(BuildContext context) async {
    bool isIgnoring = await Permission.ignoreBatteryOptimizations.isGranted;

    if (!isIgnoring) {
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Izin Latar Belakang Diperlukan'),
          content: const Text(
              'Agar alarm pengingat obat tetap berbunyi tepat waktu di HP Anda, '
                  'mohon nonaktifkan "Optimasi Baterai" untuk aplikasi TBC Care di halaman berikutnya.'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('BATAL'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await Permission.ignoreBatteryOptimizations.request();
              },
              child: const Text('IZINKAN'),
            ),
          ],
        ),
      );
    }
  }

  // ======================================================================
  // 3. MENJADWALKAN ALARM (Sesuai Struktur Package Alarm v4.x+)
  // ======================================================================
  static Future<void> scheduleAlarm(DateTime targetDateTime, int alarmId) async {
    final now = DateTime.now();
    DateTime scheduledTime = targetDateTime;

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    final alarmSettings = AlarmSettings(
      id: alarmId,
      dateTime: scheduledTime,
      assetAudioPath: 'assets/audio/alarm.mp3',
      loopAudio: true,
      vibrate: true,

      // Menggunakan .fade sesuai dengan versi package Anda
      volumeSettings:
      VolumeSettings.fade(
        volume: 1.0,
        fadeDuration: const Duration(seconds: 3),
      ),

      notificationSettings: const NotificationSettings(
        title: 'Waktunya Minum Obat! 💊',
        body: 'Jangan lupa konfirmasi setelah minum obat ya.',
        stopButton: 'Matikan Alarm',
        icon: 'notification_icon',
      ),
    );

    await Alarm.stop(alarmId);

    await Alarm.set(alarmSettings: alarmSettings);
    debugPrint('➡️ [PACKAGE ALARM] Terpasang ID [$alarmId] untuk target: $scheduledTime');
  }

  // ======================================================================
  // 4. MEMBATALKAN ATAU MEMATIKAN ALARM
  // ======================================================================
  static Future<void> cancelAlarm(int id) async {
    try {
      await Alarm.stop(id);
      debugPrint('🗑️ Alarm ID $id berhasil dibersihkan/dimatikan dari sistem.');
    } catch (e) {
      debugPrint('❌ Gagal mematikan alarm ID $id: $e');
    }
  }
}