import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'core/database/medication_repository.dart';
import 'models/medication_record.dart';
import 'features/alarm/alarm_service.dart';
import 'core/utils/camera_service.dart';

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

final CameraService _cameraService = CameraService();

class DashboardPoC extends ConsumerWidget {
  const DashboardPoC({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsyncValue = ref.watch(streakProvider);
    final repo = ref.read(medicationRepoProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Warna background off-white yang hangat
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Editorial Style
              const Text(
                'Kepatuhan\nPengobatan',
                style: TextStyle(
                  fontSize: 36,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.0,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 48),

              // Streak Card Minimalist
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'STREAK SAAT INI',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    streakAsyncValue.when(
                      loading: () => const SizedBox(
                        height: 48,
                        width: 48,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      error: (err, stack) => Text('Error: $err'),
                      data: (streak) => Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '$streak',
                            style: const TextStyle(
                              fontSize: 72,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -2.0,
                              color: Colors.teal,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Hari',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Tombol Kamera Utama
              SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  onPressed: () async {
                    final status = await Permission.camera.request();
                    if (status.isGranted) {
                      final path = await _cameraService.takeMedicationPhoto();

                      if (path != null && context.mounted) {
                        final now = DateTime.now();
                        await repo.db.writeTxn(() async {
                          final record = MedicationRecord()
                            ..scheduledTime = now
                            ..takenTime = now
                            ..isTaken = true
                            ..imagePath = path;

                          await repo.db.medicationRecords.put(record);
                        });

                        ref.invalidate(streakProvider);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Konfirmasi dicatat. Terus pertahankan!'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Izin kamera ditolak.')),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A1A), // Hitam pekat tegas
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Konfirmasi Minum Obat',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tombol Debugging (Hanya tampil sementara saat dev)
              Center(
                child: TextButton(
                  onPressed: () async {
                    await repo.db.writeTxn(() async {
                      await repo.db.medicationRecords.clear();
                    });
                    ref.invalidate(streakProvider);
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                  child: const Text('Reset Data (Debug)'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}