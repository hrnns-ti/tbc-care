import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

// Import Schema Isar
import 'models/patient_profile.dart';
import 'models/medication_record.dart';

// Import Services & Repository
import 'core/database/medication_repository.dart';
import 'features/alarm/alarm_service.dart';

// Import Views
import 'features/onboarding/registration_view.dart';
import 'features/dashboard/dashboard_view.dart';

late Isar isar;

void main() async {
  // Wajib dipanggil di awal untuk memastikan binding native Flutter siap
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inisialisasi Isar Database
  final dir = await getApplicationDocumentsDirectory();
  isar = await Isar.open(
    [
      MedicationRecordSchema,
      PatientProfileSchema
    ],
    directory: dir.path,
  );

  // 2. Inisialisasi Alarm & Notifikasi Native (Menggunakan package:alarm baru)
  await AlarmService.init();

  // 3. Smart Routing & SINKRONISASI ALARM OTOMATIS
  final profile = await isar.patientProfiles.where().findFirst();
  final bool hasProfile = profile != null;

  if (hasProfile) {
    debugPrint('🔄 Sinkronisasi alarm otomatis dimulai...');
    final now = DateTime.now();

    // ======================================================================
    // 🔥 PERBAIKAN 1: BERSIHKAN ALARM HANTU YANG SUDAH DIHAPUS USER
    // Batalkan sisa antrean ID lama di Android OS (Batas aman: slot 1-10)
    // sebelum mendaftarkan susunan jadwal yang paling baru.
    // ======================================================================
    for (int id = 1; id <= 10; id++) {
      await AlarmService.cancelAlarm(id);
    }

    // Looping jadwal resmi dari database dan daftarkan ke AlarmService baru
    for (int i = 0; i < profile.schedules.length; i++) {
      final sched = profile.schedules[i];

      // Ambil waktu dari jadwal. Jika null, gunakan fallback default aman '07:00'
      final String rawTime = sched.time ?? '07:00';
      final timeParts = rawTime.split(':');

      if (timeParts.length == 2) {
        final hour = int.tryParse(timeParts[0]) ?? 7;
        final minute = int.tryParse(timeParts[1]) ?? 0;

        DateTime targetDateTime = DateTime(
            now.year, now.month, now.day,
            hour, minute,
            0, 0
        );

        // Menggunakan ID unik berdasarkan indeks jadwal (+1 agar tidak mulai dari 0)
        await AlarmService.scheduleAlarm(targetDateTime, i + 1);
      }
    }
    debugPrint('✅ Semua alarm berhasil dijadwalkan ulang secara bersih.');
  }

  runApp(ProviderScope(child: MyApp(hasProfile: hasProfile)));
}

class MyApp extends StatelessWidget {
  final bool hasProfile;

  const MyApp({super.key, required this.hasProfile});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TB Care',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A90E2), // primaryBlue
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA), // bgLightBlue
        useMaterial3: true,
      ),
      home: hasProfile ? const DashboardView() : const RegistrationView(),
    );
  }
}

// ======================================================================
// 🔥 PERBAIKAN 2: SINKRONISASI ARSITEKTUR PROVIDER VIA REPOSITORY
// Gunakan repo agar seragam dengan state management di halaman lain
// ======================================================================
final patientProfileProvider = FutureProvider<PatientProfile?>((ref) async {
  final repo = ref.watch(medicationRepoProvider);
  return await repo.getPatientProfile();
});

final streakProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(medicationRepoProvider);
  return await repo.calculateCurrentStreak();
});