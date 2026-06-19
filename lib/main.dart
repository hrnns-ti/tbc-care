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

  // 2. Inisialisasi Alarm & Notifikasi Native
  await AlarmService.init();

  // 3. Smart Routing & SINKRONISASI ALARM
  final profile = await isar.patientProfiles.where().findFirst();
  final bool hasProfile = profile != null;

  if (hasProfile) {
    debugPrint('🔄 Sinkronisasi alarm otomatis dimulai...');
    final now = DateTime.now();

    // Looping jadwal dari database dan daftarkan ke AlarmService
    for (int i = 0; i < profile.schedules.length; i++) {
      final sched = profile.schedules[i];
      final timeParts = sched.time!.split(':');

      final targetDateTime = DateTime(
          now.year, now.month, now.day,
          int.parse(timeParts[0]), int.parse(timeParts[1]),
          0, 0
      );

      // Menggunakan ID unik berdasarkan indeks jadwal
      await AlarmService.scheduleAlarm(targetDateTime, i + 1);
    }
    debugPrint('✅ Semua alarm berhasil dijadwalkan ulang.');
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
          seedColor: const Color(0xFF749BFF),
          background: const Color(0xFFF3F0FF),
        ),
        useMaterial3: true,
      ),
      home: hasProfile ? const DashboardView() : const RegistrationView(),
    );
  }
}

// GLOBAL RIVERPOD PROVIDERS
final patientProfileProvider = FutureProvider<PatientProfile?>((ref) async {
  return await isar.patientProfiles.where().findFirst();
});

final streakProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(medicationRepoProvider);
  return await repo.calculateCurrentStreak();
});