import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'core/database/medication_repository.dart';
import 'models/medication_record.dart';
import 'features/alarm/alarm_service.dart';

late Isar isar;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Isar Database
  final dir = await getApplicationDocumentsDirectory();
  isar = await Isar.open(
    [MedicationRecordSchema],
    directory: dir.path,
  );

  // Inisialisasi Alarm & Notifikasi
  await AlarmService.init();

  runApp(const ProviderScope(child: MyApp()));
}

final streakProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(medicationRepoProvider);
  return await repo.calculateCurrentStreak();
});

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TB Reminder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const DashboardPoC(),
    );
  }
}

// Gunakan ConsumerWidget (bukan StatelessWidget) agar bisa membaca Provider
class DashboardPoC extends ConsumerWidget {
  const DashboardPoC({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Membaca state streak saat ini
    final streakAsyncValue = ref.watch(streakProvider);
    final repo = ref.read(medicationRepoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Kepatuhan'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Streak Minum Obat Anda:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),

            // Menangani status loading, error, dan data dari FutureProvider
            streakAsyncValue.when(
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) => Text('Error: $err'),
              data: (streak) => Text(
                '$streak Hari',
                style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal
                ),
              ),
            ),

            const SizedBox(height: 40),

            ElevatedButton.icon(
              onPressed: () async {
                // Ambil jumlah data yang ada untuk memanipulasi tanggal mundur ke belakang
                final recordsCount = await repo.getAllRecords().then((list) => list.length);

                // Logika Simulasi:
                // Klik 1: Insert data hari ini
                // Klik 2: Insert data kemarin (-1 hari)
                // Klik 3: Insert data lusa kemarin (-2 hari), dst.
                final simulatedDate = DateTime.now().subtract(Duration(days: recordsCount));

                // Bypass fungsi standar dan langsung tembak ke Isar untuk testing
                await repo.db.writeTxn(() async {
                  final record = MedicationRecord()
                    ..scheduledTime = simulatedDate
                    ..takenTime = simulatedDate
                    ..isTaken = true
                    ..imagePath = "/dummy/path/foto_$recordsCount.jpg";

                  await repo.db.medicationRecords.put(record);
                });

                // Refresh UI
                ref.invalidate(streakProvider);
              },
              icon: const Icon(Icons.history),
              label: const Text('Simulasi Tambah Hari Streak'),
            ),

            const SizedBox(height: 10),

// Tombol tambahan untuk mereset database jika kamu ingin mengulang dari 0
            TextButton.icon(
              onPressed: () async {
                await repo.db.writeTxn(() async {
                  await repo.db.medicationRecords.clear();
                });
                ref.invalidate(streakProvider);
              },
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              label: const Text('Reset Semua Data', style: TextStyle(color: Colors.red)),
            ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () async {
                // 1. Minta izin dulu! Pop-up akan muncul saat pertama kali diklik
                await AlarmService.requestPermission();

                // 2. Jadwalkan alarm
                final scheduledTime = DateTime.now().add(const Duration(seconds: 10));
                await AlarmService.scheduleAlarm(scheduledTime, 999);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Alarm dijadwalkan dalam 10 detik! Tutup aplikasi sekarang.')),
                );
              },
              icon: const Icon(Icons.notifications_active),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              label: const Text('Test Alarm (10 Detik)', style: TextStyle(color: Colors.black)),
            )
          ],
        ),
      ),
    );
  }
}

