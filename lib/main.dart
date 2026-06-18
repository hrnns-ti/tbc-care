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

// Variabel global Isar agar bisa diakses di berbagai tempat jika terdesak
// (Meskipun best practice-nya menggunakan Riverpod Provider)
late Isar isar;

void main() async {
  // Pastikan binding Flutter sudah siap sebelum memanggil native code (seperti path_provider)
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inisialisasi Isar Database (Offline-first)
  final dir = await getApplicationDocumentsDirectory();
  isar = await Isar.open(
    [
      MedicationRecordSchema,
      PatientProfileSchema
    ],
    directory: dir.path,
  );

  // 2. Inisialisasi Alarm & Notifikasi Native Android
  await AlarmService.init();

  // 3. Smart Routing: Cek apakah profil pasien sudah ada di database lokal
  final int profileCount = await isar.patientProfiles.count();
  final bool hasProfile = profileCount > 0;

  // 4. Jalankan aplikasi dengan membungkusnya dalam ProviderScope (Riverpod)
  runApp(ProviderScope(child: MyApp(hasProfile: hasProfile)));
}

// ======================================================================
// MAIN APP WIDGET
// ======================================================================
class MyApp extends StatelessWidget {
  final bool hasProfile;

  const MyApp({super.key, required this.hasProfile});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TB Care',
      debugShowCheckedModeBanner: false, // Menghilangkan banner debug merah agar UI clean
      theme: ThemeData(
        // Menyesuaikan warna dasar dengan tema Neo-Minimalist biru
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF749BFF),
          background: const Color(0xFFF3F0FF), // Soft background default
        ),
        useMaterial3: true,
      ),
      // Jika data pasien sudah ada -> Dashboard. Jika kosong -> Registrasi.
      home: hasProfile ? const DashboardView() : const RegistrationView(),
    );
  }
}

// ======================================================================
// GLOBAL RIVERPOD PROVIDERS
// ======================================================================

// 1. Provider untuk memantau data Profil Pasien
final patientProfileProvider = FutureProvider<PatientProfile?>((ref) async {
  // Karena ini aplikasi single-user, kita cukup mengambil data pertama
  return await isar.patientProfiles.where().findFirst();
});

// 2. Provider untuk menghitung Streak (Hari Berturut-turut)
final streakProvider = FutureProvider<int>((ref) async {
  // Memastikan MedicationRepository membaca instance Isar yang sudah diinisialisasi
  final repo = ref.watch(medicationRepoProvider);
  return await repo.calculateCurrentStreak();
});

// Catatan: Pastikan kamu memiliki provider ini di file medication_repository.dart:
// final medicationRepoProvider = Provider<MedicationRepository>((ref) => MedicationRepository(isar));