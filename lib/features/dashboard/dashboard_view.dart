import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:tbc_care/features/dashboard/profile_view.dart';

import '../../main.dart';
import '../../core/utils/camera_service.dart';
import '../../models/patient_profile.dart';
import '../../models/medication_record.dart';
import '../../core/database/medication_repository.dart';
import '../alarm/alarm_service.dart';
import '../educaction/education_view.dart';
import '../history/history_calendar_view.dart';
import '../history/schedule_view.dart';

// Palet Warna Konsisten Sesuai image_9f0ba7.jpg & image_9cd151.jpg
const Color primaryBlue = Color(0xFF4A90E2);
const Color accentGreen = Color(0xFF5CC8A1);
const Color accentOrange = Color(0xFFFFA726);
const Color bgLightBlue = Color(0xFFF5F7FA);
const Color darkText = Color(0xFF18191E);
const Color bgWhite = Color(0xFFFFFFFF);

final CameraService _cameraService = CameraService();

final todaysRecordsProvider = FutureProvider<List<MedicationRecord>>((ref) async {
  final repo = ref.watch(medicationRepoProvider);
  return await repo.getTodaysRecords();
});

final complianceProvider = FutureProvider.family<double, PatientProfile>((ref, profile) async {
  final repo = ref.watch(medicationRepoProvider);
  return await repo.calculateCompliance(profile.treatmentStartDate, profile.schedules.length);
});

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  int _currentIndex = 0; // Mengontrol navigasi bottom bar aktif

  String _calculateTimeRemaining(String? targetTimeStr) {
    if (targetTimeStr == null || targetTimeStr.isEmpty) return '-';
    try {
      final now = DateTime.now();
      final timeParts = targetTimeStr.split(':');
      final target = DateTime(
        now.year, now.month, now.day,
        int.parse(timeParts[0]), int.parse(timeParts[1]),
      );

      var difference = target.difference(now);
      if (difference.isNegative) {
        final tomorrowTarget = target.add(const Duration(days: 1));
        difference = tomorrowTarget.difference(now);
      }

      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;

      if (hours > 0) {
        return '$hours j, $minutes m lagi';
      } else {
        return '$minutes m lagi';
      }
    } catch (e) {
      return targetTimeStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(patientProfileProvider);
    final streakAsync = ref.watch(streakProvider);

    return Scaffold(
      backgroundColor: bgLightBlue,
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: primaryBlue)),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (profile) {
          if (profile == null) return const Center(child: Text('Data tidak ditemukan'));

          // INDEX 1: Menampilkan Halaman Jadwal & Riwayat Terintegrasi
          if (_currentIndex == 1) {
            return Column(
              children: [
                const Expanded(child: ScheduleView()),
                _buildBottomNavigationBar(),
              ],
            );
          }

          // INDEX 2: Modul Edukasi TBC Offline
          if (_currentIndex == 2) {
            return Column(
              children: [
                const Expanded(child: EducationView()),
                _buildBottomNavigationBar(),
              ],
            );
          }

          // INDEX 3: Render halaman Kalender Progress Kepatuhan
          if (_currentIndex == 3) {
            return Column(
              children: [
                const Expanded(child: HistoryCalendarView()),
                _buildBottomNavigationBar(),
              ],
            );
          }

          // INDEX 4: Placeholder Ringkas untuk Menu Profil Pasien
          if (_currentIndex == 4) {
            return Column(
              children: [
                const Expanded(child: ProfileView()),
                _buildBottomNavigationBar(),
              ],
            );
          }

          // INDEX 0: BERANDA UTAMA (DEFAULT)
          final todaysRecordsAsync = ref.watch(todaysRecordsProvider);
          final complianceAsync = ref.watch(complianceProvider(profile));

          final now = DateTime.now();
          final todayMidnight = DateTime(now.year, now.month, now.day);
          final startMidnight = DateTime(profile.treatmentStartDate.year, profile.treatmentStartDate.month, profile.treatmentStartDate.day);
          final daysPassed = todayMidnight.difference(startMidnight).inDays + 1;
          final safeDaysPassed = daysPassed > 0 ? daysPassed : 1;
          final progressRatio = (safeDaysPassed / profile.totalTreatmentDays).clamp(0.0, 1.0);

          return Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    // HEADER UTAMA BERANDA
                    SliverToBoxAdapter(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: primaryBlue,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(32),
                            bottomRight: Radius.circular(32),
                          ),
                        ),
                        padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // BAGIAN NOTIFIKASI DAN GARIS TIGA TELAH DIHAPUS UTUH DI SINI
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Selamat Pagi,\n${profile.fullName.split(' ').first} 👋',
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: bgWhite,
                                          height: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Semangat minum obat hari ini!',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white70,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 90,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    color: bgWhite.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(
                                    Icons.health_and_safety,
                                    size: 56,
                                    color: bgWhite,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // KARTU MANAGEMEN JADWAL AKTIF HARI INI
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                        child: todaysRecordsAsync.when(
                          loading: () => const Center(child: CircularProgressIndicator(color: primaryBlue)),
                          error: (e, s) => Text('Error: $e'),
                          data: (todaysRecords) {
                            return TodayScheduleManager(
                              allSchedules: profile.schedules.toList(),
                              todaysRecords: todaysRecords,
                              baseStreak: streakAsync.asData?.value ?? 0,
                              timeRemainingStr: _calculateTimeRemaining,
                            );
                          },
                        ),
                      ),
                    ),

                    // KARTU STREAK KEPATUHAN BERUNTUN
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: bgWhite,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4))
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '🔥 Streak Kepatuhan',
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: darkText),
                                    ),
                                    const SizedBox(height: 12),
                                    todaysRecordsAsync.when(
                                      loading: () => const CircularProgressIndicator(),
                                      error: (e, s) => const Text('-'),
                                      data: (todaysRecords) {
                                        int completedCount = 0;
                                        for (var sched in profile.schedules) {
                                          final timeParts = sched.time!.split(':');
                                          final isMatch = todaysRecords.any((r) =>
                                          r.scheduledTime.hour == int.parse(timeParts[0]) &&
                                              r.scheduledTime.minute == int.parse(timeParts[1]));
                                          if (isMatch) completedCount++;
                                        }

                                        final currentDbStreak = streakAsync.asData?.value ?? 0;
                                        final displayStreak = (completedCount == profile.schedules.length && completedCount > 0 && currentDbStreak == 0)
                                            ? 1
                                            : currentDbStreak;

                                        return Text(
                                          '$displayStreak',
                                          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: darkText),
                                        );
                                      },
                                    ),
                                    const Text(
                                      'Hari Berturut-turut',
                                      style: TextStyle(color: Colors.grey, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: accentOrange.withOpacity(0.1), shape: BoxShape.circle),
                                child: const Icon(Icons.emoji_events, color: accentOrange, size: 40),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // KARTU LINEAR PROGRES PENGOBATAN TOTAL
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _currentIndex = 3; // Pindah otomatis ke tab progress kalender
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: bgWhite,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4))
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Progress Waktu',
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: darkText),
                                    ),
                                    Text(
                                      'Sisa ${profile.totalTreatmentDays - safeDaysPassed} Hari',
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: accentOrange),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: progressRatio,
                                    minHeight: 10,
                                    backgroundColor: primaryBlue.withOpacity(0.1),
                                    valueColor: const AlwaysStoppedAnimation<Color>(primaryBlue),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Hari ke-$safeDaysPassed dari ${profile.totalTreatmentDays}',
                                      style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w500),
                                    ),
                                    complianceAsync.when(
                                      loading: () => const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2)),
                                      error: (e, s) => const Text('0%'),
                                      data: (comp) => Text(
                                        'Kepatuhan: ${comp.toStringAsFixed(0)}%',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: accentGreen),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // KARTU PENILAIAN JADWAL BESOK
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                        child: todaysRecordsAsync.when(
                          loading: () => const SizedBox.shrink(),
                          error: (e, s) => const SizedBox.shrink(),
                          data: (todaysRecords) {
                            int completedCount = 0;
                            for (var sched in profile.schedules) {
                              final timeParts = sched.time!.split(':');
                              final isMatch = todaysRecords.any((r) =>
                              r.scheduledTime.hour == int.parse(timeParts[0]) &&
                                  r.scheduledTime.minute == int.parse(timeParts[1]));
                              if (isMatch) completedCount++;
                            }

                            if (completedCount < profile.schedules.length) {
                              return _buildFallbackProgressMenu();
                            }

                            final nextDaySchedule = profile.schedules.first;
                            final nextDayMedications = nextDaySchedule.medicines.map((m) => m.name ?? 'Obat').join(', ');

                            return Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: bgWhite,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4))
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Jadwal Berikutnya',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: darkText),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      const Icon(Icons.wb_sunny_rounded, color: accentOrange, size: 28),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  '${nextDaySchedule.time?.replaceAll(':', '.') ?? '07.00'}',
                                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkText),
                                                ),
                                                const Text(
                                                  '  •  Obat Pagi Besok',
                                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: darkText),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              nextDayMedications.isNotEmpty ? nextDayMedications : 'Rifampisin, Isoniazid, ...',
                                              style: const TextStyle(fontSize: 13, color: Colors.grey),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.chevron_right, color: Colors.grey, size: 22),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // NAVBAR FIXED BERDERET PROPORSIOINAL
              _buildBottomNavigationBar(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFallbackProgressMenu() {
    return Container(
      decoration: BoxDecoration(color: bgWhite, borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        onTap: () => setState(() => _currentIndex = 3),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: accentOrange.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.calendar_today, color: accentOrange),
        ),
        title: const Text('Lihat Progress & Kalender Lengkap', style: TextStyle(fontWeight: FontWeight.bold, color: darkText, fontSize: 14)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: bgWhite,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -4))
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, Icons.home_outlined, 'Beranda', 0),
            _buildNavItem(Icons.calendar_month, Icons.calendar_month_outlined, 'Jadwal', 1),
            _buildNavItem(Icons.menu_book, Icons.menu_book_outlined, 'Edukasi', 2),
            _buildNavItem(Icons.bar_chart, Icons.bar_chart_outlined, 'Progress', 3),
            _buildNavItem(Icons.person, Icons.person_outline, 'Profil', 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData activeIcon, IconData inactiveIcon, String label, int index) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 65,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isActive ? activeIcon : inactiveIcon, color: isActive ? primaryBlue : Colors.grey, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? primaryBlue : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================================
// MANAGER JADWAL CERDAS
// ======================================================================
class TodayScheduleManager extends ConsumerWidget {
  final List<RegimenSchedule> allSchedules;
  final List<MedicationRecord> todaysRecords;
  final int baseStreak;
  final String Function(String?) timeRemainingStr;

  const TodayScheduleManager({
    super.key,
    required this.allSchedules,
    required this.todaysRecords,
    required this.baseStreak,
    required this.timeRemainingStr,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Map<String, dynamic>> pendingSchedules = [];
    int missedCount = 0;
    final now = DateTime.now();

    for (int i = 0; i < allSchedules.length; i++) {
      final sched = allSchedules[i];
      final timeParts = sched.time!.split(':');
      final schedDateTime = DateTime(
          now.year, now.month, now.day,
          int.parse(timeParts[0]), int.parse(timeParts[1])
      );

      bool isTaken = todaysRecords.any((record) {
        return record.scheduledTime.hour == schedDateTime.hour &&
            record.scheduledTime.minute == schedDateTime.minute;
      });

      if (!isTaken) {
        final expiryTime = schedDateTime.add(const Duration(hours: 2));
        if (now.isAfter(expiryTime)) {
          missedCount++;
        } else {
          pendingSchedules.add({'schedule': sched, 'originalIndex': i});
        }
      }
    }

    if (pendingSchedules.isEmpty) {
      final isPerfect = missedCount == 0;
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: isPerfect ? accentGreen.withOpacity(0.1) : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24)
        ),
        child: Row(
          children: [
            Icon(isPerfect ? Icons.check_circle : Icons.error, color: isPerfect ? accentGreen : Colors.red, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPerfect ? 'Semua Obat Diminum!' : 'Jadwal Hari Ini Selesai',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isPerfect ? accentGreen : Colors.red),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isPerfect ? 'Hebat! Kepatuhan hari ini terpenuhi.' : 'Anda melewati $missedCount jadwal obat.',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            )
          ],
        ),
      );
    }

    final activeData = pendingSchedules.first;
    final activeSchedule = activeData['schedule'] as RegimenSchedule;
    final originalIndex = activeData['originalIndex'] as int;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (missedCount > 0)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                const Icon(Icons.warning, color: Colors.red, size: 16),
                const SizedBox(width: 8),
                Text('⚠️ Terlewat $missedCount jadwal sebelumnya', style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        MedicineScheduleCard(
          schedule: activeSchedule,
          originalIndex: originalIndex,
          timeRemaining: timeRemainingStr(activeSchedule.time),
        ),
      ],
    );
  }
}

// ======================================================================
// KARTU JADWAL AKTIF DENGAN COUNTDOWN DINAMIS
// ======================================================================
class MedicineScheduleCard extends ConsumerStatefulWidget {
  final RegimenSchedule schedule;
  final int originalIndex;
  final String timeRemaining;

  const MedicineScheduleCard({
    super.key,
    required this.schedule,
    required this.originalIndex,
    required this.timeRemaining,
  });

  @override
  ConsumerState<MedicineScheduleCard> createState() => _MedicineScheduleCardState();
}

class _MedicineScheduleCardState extends ConsumerState<MedicineScheduleCard> {
  bool _isLoading = false;

  Future<void> _handleConfirmation() async {
    setState(() => _isLoading = true);

    final status = await Permission.camera.request();
    if (status.isGranted) {
      final path = await _cameraService.takeMedicationPhoto();

      if (path != null && mounted) {
        final timeParts = widget.schedule.time!.split(':');
        final now = DateTime.now();

        // Buat scheduledDateTime asli untuk hari ini (detik & milidetik diset ke 0)
        final scheduledDateTime = DateTime(
            now.year, now.month, now.day,
            int.parse(timeParts[0]), int.parse(timeParts[1]), 0, 0
        );

        // Simpan catatan ke database lokal
        final record = MedicationRecord()
          ..scheduledTime = scheduledDateTime
          ..takenTime = now
          ..isTaken = true
          ..imagePath = path;

        final repo = ref.read(medicationRepoProvider);
        await repo.addRecord(record);

        // === PROSES SINKRONISASI ALARM JADWAL BERIKUTNYA ===
        try {
          final alarmId = widget.originalIndex + 1;

          // 1. Batalkan alarm hari ini yang barusan dikonfirmasi/diminum
          await AlarmService.cancelAlarm(alarmId);

          // 2. Jadwalkan ulang alarm yang sama PERSIS untuk ESOK HARI
          final tomorrowScheduledTime = DateTime(
              now.year, now.month, now.day,
              int.parse(timeParts[0]), int.parse(timeParts[1]), 0, 0
          ).add(const Duration(days: 1));

          await AlarmService.scheduleAlarm(tomorrowScheduledTime, alarmId);
          debugPrint('Sinkronisasi Berhasil: Alarm $alarmId digeser ke esok hari: $tomorrowScheduledTime');
        } catch (e) {
          debugPrint('Gagal mengatur ulang alarm: $e');
        }

        ref.invalidate(streakProvider);
        ref.invalidate(todaysRecordsProvider);
        ref.invalidate(complianceProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Catatan minum obat berhasil disimpan.')),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Izin kamera ditolak.')));
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final medicineNames = widget.schedule.medicines.map((m) => m.name ?? 'Obat').join(', ');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.medication_outlined, color: primaryBlue, size: 22),
              const SizedBox(width: 8),
              const Text('Obat Selanjutnya', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: accentOrange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, color: accentOrange, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      widget.timeRemaining,
                      style: const TextStyle(color: accentOrange, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 14),
          Text(widget.schedule.time ?? '--:--', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: darkText, letterSpacing: -0.5)),
          const SizedBox(height: 4),
          Text(medicineNames.isNotEmpty ? medicineNames : 'Rifampisin, ...', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black54, fontSize: 14)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _handleConfirmation,
              icon: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: bgWhite, strokeWidth: 2))
                  : const Icon(Icons.check_circle_outline, color: bgWhite),
              style: ElevatedButton.styleFrom(backgroundColor: accentGreen, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              label: Text(_isLoading ? 'Menyimpan...' : 'MINUM SEKARANG', style: const TextStyle(fontWeight: FontWeight.w800, color: bgWhite)),
            ),
          ),
        ],
      ),
    );
  }
}