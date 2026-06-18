import 'package:isar/isar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Sesuaikan path import ini agar mengarah ke file model dan main.dart-mu
import '../../models/medication_record.dart';
import '../../main.dart'; // Untuk mengakses instance global 'isar'

// ======================================================================
// PROVIDER UNTUK REPOSITORY
// Ini yang dipanggil oleh streakProvider di main.dart
// ======================================================================
final medicationRepoProvider = Provider<MedicationRepository>((ref) {
  return MedicationRepository(isar);
});

// ======================================================================
// KELAS REPOSITORY
// Bertugas sebagai jembatan antara Database Isar dan UI
// ======================================================================
class MedicationRepository {
  final Isar db;

  MedicationRepository(this.db);

  // Fungsi untuk mengambil semua riwayat (bisa dipakai untuk kalender nanti)
  Future<List<MedicationRecord>> getAllRecords() async {
    return await db.medicationRecords.where().findAll();
  }

  // Fungsi untuk menyimpan record baru setelah pasien konfirmasi foto
  Future<void> addRecord(MedicationRecord record) async {
    await db.writeTxn(() async {
      await db.medicationRecords.put(record);
    });
  }

  // ======================================================================
  // LOGIKA STREAK KETAT (Strict Adherence)
  // ======================================================================
  Future<int> calculateCurrentStreak() async {
    // 1. Ambil SEMUA data dari database
    final allRecords = await db.medicationRecords.where().findAll();

    if (allRecords.isEmpty) return 0;

    // 2. Kelompokkan data per Hari (Tanggal Kalender) tanpa jam
    Map<DateTime, List<MedicationRecord>> recordsByDate = {};
    for (var record in allRecords) {
      final t = record.scheduledTime;
      final date = DateTime(t.year, t.month, t.day);
      recordsByDate.putIfAbsent(date, () => []).add(record);
    }

    // 3. Urutkan dari tanggal terbaru ke terlama
    final sortedDates = recordsByDate.keys.toList()..sort((a, b) => b.compareTo(a));
    if (sortedDates.isEmpty) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final mostRecentDate = sortedDates.first;

    // 4. Syarat Mutlak: Jika catatan terakhir lebih dari kemarin, otomatis streak putus (0)
    if (today.difference(mostRecentDate).inDays > 1) {
      return 0;
    }

    int streak = 0;
    DateTime expectedDate = mostRecentDate; // Mulai perhitungan mundur dari tanggal terbaru

    // 5. Iterasi Evaluasi Streak Ketat
    for (var date in sortedDates) {
      if (date.isAtSameMomentAs(expectedDate)) {

        final dailyRecords = recordsByDate[date]!;
        bool isDayComplete = true;
        bool hasTakenAtLeastOne = false;

        // Evaluasi semua jadwal obat dalam satu hari itu
        for (var record in dailyRecords) {
          // Hanya evaluasi jadwal yang seharusnya sudah diminum (waktunya sudah lewat/hari ini)
          if (record.scheduledTime.isBefore(now)) {
            if (!record.isTaken) {
              // ADA SATU SAJA OBAT YANG BOLONG!
              isDayComplete = false;
              break;
            } else {
              hasTakenAtLeastOne = true;
            }
          }
        }

        if (isDayComplete && hasTakenAtLeastOne) {
          // Hari ini sukses 100% tanpa ada jadwal lewat yang bolong
          streak++;
          // Mundur target ke hari sebelumnya
          expectedDate = expectedDate.subtract(const Duration(days: 1));
        } else if (!isDayComplete) {
          // Rantai streak terputus di hari ini
          break;
        }

      } else {
        // Ada hari kalender yang benar-benar tidak ada datanya (terlewat penuh)
        break;
      }
    }

    return streak;
  }
}