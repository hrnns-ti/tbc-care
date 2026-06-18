import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../main.dart';
import '../../core/utils/camera_service.dart';
import '../../models/patient_profile.dart'; // Import schema Isar

// Palet Warna Neo-Minimalist & Aksen dari Referensi
const Color primaryBlue = Color(0xFF749BFF);
const Color darkText = Color(0xFF18191E);
const Color bgWhite = Color(0xFFFFFFFF);
const Color paleOrange = Color(0xFFFFF7ED); // Untuk kotak Streak
const Color accentOrange = Color(0xFFEA580C);

final CameraService _cameraService = CameraService();

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(patientProfileProvider);
    final streakAsync = ref.watch(streakProvider); // Mengambil data streak dari main.dart

    return Scaffold(
      backgroundColor: const Color(0xFFF3F0FF), // Soft background
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: primaryBlue)),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (profile) {
            if (profile == null) return const Center(child: Text('Data tidak ditemukan'));

            // Kalkulasi Progress Real-time
            final now = DateTime.now();
            // Menghitung selisih hari sejak mulai berobat (+1 karena hari H adalah hari ke-1)
            final daysPassed = now.difference(profile.treatmentStartDate).inDays + 1;
            final safeDaysPassed = daysPassed > 0 ? daysPassed : 1;

            // Mengamankan agar progress tidak lebih dari 100%
            final progressRatio = (safeDaysPassed / profile.totalTreatmentDays).clamp(0.0, 1.0);

            // Hitung sisa bulan
            final daysLeft = profile.totalTreatmentDays - safeDaysPassed;
            final monthsLeft = (daysLeft / 30).ceil();

            return CustomScrollView(
              slivers: [
                // =====================================
                // HEADER SECTION
                // =====================================
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hi, ${profile.fullName.split(' ').first}',
                              style: const TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Positive Today',
                              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: darkText, letterSpacing: -1.0),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: bgWhite,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.notifications_none, color: darkText),
                        ),
                      ],
                    ),
                  ),
                ),

                // =====================================
                // PROGRESS & STATS CARDS (FIXED LAYOUT)
                // =====================================
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    // IntrinsicHeight memastikan Row tahu batas tinggi maksimum komponennya
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // STREAK CARD (Orange)
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: paleOrange,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.local_fire_department, color: accentOrange, size: 24),
                                      const SizedBox(width: 8),
                                      streakAsync.when(
                                        loading: () => const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                                        error: (e, s) => const Text('-'),
                                        data: (streak) => Text(
                                          '$streak',
                                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: accentOrange, height: 1),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  const Text('hari berturut-turut', style: TextStyle(color: accentOrange, fontSize: 12, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // TREATMENT PROGRESS CARD (White)
                          Expanded(
                            flex: 3,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: bgWhite,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Pengobatan', style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w500)),
                                      Text('Hari $safeDaysPassed/${profile.totalTreatmentDays}', style: const TextStyle(color: darkText, fontSize: 12, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: progressRatio,
                                      minHeight: 8,
                                      backgroundColor: primaryBlue.withOpacity(0.15),
                                      valueColor: const AlwaysStoppedAnimation<Color>(primaryBlue),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Estimasi selesai ${monthsLeft > 0 ? "$monthsLeft bln lagi" : "Bulan ini!"}',
                                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // COMPLIANCE RATE CARD
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: bgWhite, borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.show_chart, color: primaryBlue),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Kepatuhan 100%', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkText)),
                              Text('Lihat kalender lengkap', style: TextStyle(fontSize: 12, color: Colors.black54)),
                            ],
                          ),
                          const Spacer(),
                          const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                ),

                // =====================================
                // SMART SCHEDULE SECTION
                // =====================================
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: TodayScheduleManager(schedules: profile.schedules.toList()),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ======================================================================
// MANAGER JADWAL CERDAS (Menampilkan 1 Jadwal Relevan Saja)
// ======================================================================
class TodayScheduleManager extends StatefulWidget {
  final List<RegimenSchedule> schedules;

  const TodayScheduleManager({super.key, required this.schedules});

  @override
  State<TodayScheduleManager> createState() => _TodayScheduleManagerState();
}

class _TodayScheduleManagerState extends State<TodayScheduleManager> {
  int _activeScheduleIndex = 0; // Melacak jadwal mana yang sedang "aktif" hari ini

  void _onScheduleConfirmed() {
    setState(() {
      _activeScheduleIndex++; // Pindah ke jadwal berikutnya setelah dikonfirmasi
    });
  }

  @override
  Widget build(BuildContext context) {
    // Jika semua jadwal hari ini sudah diselesaikan
    if (_activeScheduleIndex >= widget.schedules.length) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(32)),
        child: Column(
          children: const [
            Icon(Icons.task_alt, color: primaryBlue, size: 64),
            SizedBox(height: 16),
            Text('Luar Biasa!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryBlue)),
            SizedBox(height: 8),
            Text('Semua jadwal minum obat hari ini telah diselesaikan.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
          ],
        ),
      );
    }

    // Menampilkan jadwal yang sedang aktif (Terdekat/Belum diselesaikan)
    final activeSchedule = widget.schedules[_activeScheduleIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Jadwal Terdekat', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: darkText)),
            const Spacer(),
            Text('${_activeScheduleIndex + 1} dari ${widget.schedules.length}', style: const TextStyle(fontWeight: FontWeight.bold, color: primaryBlue)),
          ],
        ),
        const SizedBox(height: 16),
        MedicineScheduleCard(
          schedule: activeSchedule,
          onConfirmed: _onScheduleConfirmed,
        ),
      ],
    );
  }
}

// ======================================================================
// KOMPONEN CARD JADWAL (Input Checklist Terpisah Nama & Dosis)
// ======================================================================
class MedicineScheduleCard extends StatefulWidget {
  final RegimenSchedule schedule;
  final VoidCallback onConfirmed;

  const MedicineScheduleCard({super.key, required this.schedule, required this.onConfirmed});

  @override
  State<MedicineScheduleCard> createState() => _MedicineScheduleCardState();
}

class _MedicineScheduleCardState extends State<MedicineScheduleCard> {
  late List<bool> _checkedState;

  @override
  void initState() {
    super.initState();
    // Menginisialisasi status centang sesuai jumlah obat
    _checkedState = List<bool>.filled(widget.schedule.medicines.length, false);
  }

  bool get _isAllChecked => !_checkedState.contains(false);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: bgWhite, borderRadius: BorderRadius.circular(32)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Waktu (Dari gambar: Jadwal Pagi • 07:00)
          Row(
            children: [
              const Icon(Icons.access_time, color: darkText, size: 20),
              const SizedBox(width: 8),
              Text(
                'Jadwal • ${widget.schedule.time ?? '--:--'}',
                style: const TextStyle(fontWeight: FontWeight.w800, color: darkText, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Daftar Obat Dinamis (Nama dan Dosis terpisah)
          ...List.generate(widget.schedule.medicines.length, (index) {
            final med = widget.schedule.medicines.toList()[index];
            final isChecked = _checkedState[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  setState(() {
                    _checkedState[index] = !_checkedState[index];
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: isChecked ? primaryBlue.withOpacity(0.05) : const Color(0xFFF8F9FA),
                    border: Border.all(color: isChecked ? primaryBlue.withOpacity(0.3) : Colors.transparent),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      // Ikon Pil / Check
                      Icon(
                        isChecked ? Icons.check_circle : Icons.medication_outlined,
                        color: isChecked ? primaryBlue : Colors.teal.shade300,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      // Nama Obat
                      Expanded(
                        child: Text(
                          med.name ?? 'Obat',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isChecked ? Colors.grey : darkText,
                            decoration: isChecked ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                      // Dosis
                      Text(
                        med.dosage ?? '-',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isChecked ? Colors.grey : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 16),

          // Tombol Konfirmasi Kamera (Muncul jika semua tercentang)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            height: _isAllChecked ? 56 : 0,
            curve: Curves.easeInOut,
            child: ClipRRect(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final status = await Permission.camera.request();
                  if (status.isGranted) {
                    final path = await _cameraService.takeMedicationPhoto();
                    if (path != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Foto berhasil disimpan!')),
                      );
                      // Memanggil fungsi dari Parent untuk melompat ke jadwal berikutnya
                      widget.onConfirmed();
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Izin kamera ditolak.')),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.camera_alt),
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkText, // Warna tombol tegas sesuai referensi
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                label: const Text('Konfirmasi minum obat', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}