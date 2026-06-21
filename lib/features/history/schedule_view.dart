import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';

import '../../main.dart';
import '../../models/patient_profile.dart';
import '../../models/medication_record.dart';
import '../../core/database/medication_repository.dart';
import '../dashboard/dashboard_view.dart';

final allRecordsProvider = StreamProvider<List<MedicationRecord>>((ref) {
  final repo = ref.watch(medicationRepoProvider);
  return repo.watchAllRecords();
});

class ScheduleView extends ConsumerWidget {
  const ScheduleView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(patientProfileProvider);
    final recordsAsync = ref.watch(allRecordsProvider);

    return Scaffold(
      backgroundColor: bgLightBlue,
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: primaryBlue)),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (profile) {
          if (profile == null) return const Center(child: Text('Profil tidak ditemukan'));

          return recordsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: primaryBlue)),
            error: (err, _) => Center(child: Text('Error data riwayat: $err')),
            data: (records) {
              final now = DateTime.now();

              // Filter data untuk Hari Ini
              final todaysRecords = records.where((r) =>
              r.scheduledTime.year == now.year &&
                  r.scheduledTime.month == now.month &&
                  r.scheduledTime.day == now.day).toList();

              return Column(
                children: [
                  // HEADER HALAMAN JADWAL
                  Container(
                    width: double.infinity,
                    color: primaryBlue,
                    padding: const EdgeInsets.fromLTRB(24, 48, 24, 20),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Jadwal & Riwayat Obat',
                          style: TextStyle(color: bgWhite, fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Pantau dan lihat kembali dokumentasi terapi Anda',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),

                  // DAFTAR KONTEN UTAMA
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        // SECTION 1: JADWAL HARI INI
                        _buildSectionHeader('Jadwal Hari Ini', Icons.today_rounded),
                        const SizedBox(height: 10),
                        ...profile.schedules.map((sched) {
                          final timeParts = sched.time!.split(':');
                          final matchRecord = todaysRecords.where((r) =>
                          r.scheduledTime.hour == int.parse(timeParts[0]) &&
                              r.scheduledTime.minute == int.parse(timeParts[1])).firstOrNull;

                          return _buildTodayScheduleCard(sched, matchRecord);
                        }),

                        const SizedBox(height: 24),

                        // SECTION 2: JADWAL BESOK
                        _buildSectionHeader('Jadwal Besok', Icons.next_plan_outlined),
                        const SizedBox(height: 10),
                        ...profile.schedules.map((sched) {
                          return _buildTomorrowScheduleCard(sched);
                        }),

                        const SizedBox(height: 24),

                        // SECTION 3: RIWAYAT SEMUA KONSUMSI (LOG KRONOLOGIS)
                        _buildSectionHeader('Riwayat Konsumsi Obat', Icons.history_rounded),
                        const SizedBox(height: 10),
                        if (records.isEmpty)
                          _buildEmptyState('Belum ada riwayat minum obat yang tercatat.')
                        else
                          ...records.reversed.map((record) => _buildHistoryRow(record)),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: darkText, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: darkText),
        ),
      ],
    );
  }

  Widget _buildTodayScheduleCard(RegimenSchedule sched, MedicationRecord? record) {
    final isTaken = record != null;
    final medicineNames = sched.medicines.map((m) => m.name ?? 'Obat').join(', ');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isTaken ? accentGreen.withOpacity(0.1) : primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isTaken ? Icons.check_circle : Icons.pending_actions_rounded,
              color: isTaken ? accentGreen : primaryBlue,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sched.time?.replaceAll(':', '.') ?? '00.00',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkText),
                ),
                const SizedBox(height: 2),
                Text(
                  medicineNames,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isTaken ? accentGreen : accentOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isTaken ? 'Selesai' : 'Belum',
              style: TextStyle(
                color: isTaken ? bgWhite : accentOrange,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTomorrowScheduleCard(RegimenSchedule sched) {
    final medicineNames = sched.medicines.map((m) => m.name ?? 'Obat').join(', ');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bgLightBlue, width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.wb_sunny_outlined, color: accentOrange, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Besok, ${sched.time?.replaceAll(':', '.') ?? '07.00'}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: darkText),
                ),
                const SizedBox(height: 2),
                Text(
                  medicineNames,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryRow(MedicationRecord record) {
    final displayTime = record.takenTime ?? record.scheduledTime;

    final dateFormatted = DateFormat('dd MMM yyyy').format(displayTime);
    final timeFormatted = DateFormat('HH:mm').format(displayTime).replaceAll(':', '.');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          if (record.imagePath != null && record.imagePath!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(record.imagePath!),
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildHistoryIconPlaceholder(),
              ),
            )
          else
            _buildHistoryIconPlaceholder(),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Konfirmasi Foto Berhasil',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: darkText),
                ),
                const SizedBox(height: 2),
                Text(
                  'Jadwal: ${DateFormat('HH:mm').format(record.scheduledTime).replaceAll(':', '.')}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                timeFormatted,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: primaryBlue),
              ),
              Text(
                dateFormatted,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildHistoryIconPlaceholder() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bgLightBlue,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.photo_library_outlined, color: primaryBlue, size: 20),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.grey, fontSize: 13),
      ),
    );
  }
}