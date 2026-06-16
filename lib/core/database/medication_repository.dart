import 'package:isar/isar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../main.dart';
import '../../models/medication_record.dart';

class MedicationRepository {
  final Isar db;

  MedicationRepository(this.db);

  // 1. Tambah jadwal baru
  Future<void> addRecord(DateTime schedule) async {
    final record = MedicationRecord()..scheduledTime = schedule;

    await db.writeTxn(() async {
      await db.medicationRecords.put(record);
    });
  }

  // 2. Konfirmasi minum obat
  Future<void> markAsTaken(int id, String photoPath) async {
    await db.writeTxn(() async {
      final record = await db.medicationRecords.get(id);
      if (record != null) {
        record.isTaken = true;
        record.takenTime = DateTime.now();
        record.imagePath = photoPath;
        await db.medicationRecords.put(record);
      }
    });
  }

  // 3. Mengambil semua riwayat (Untuk kalender)
  Future<List<MedicationRecord>> getAllRecords() async {
    return await db.medicationRecords.where().findAll();
  }

  // 4. Kalkulasi Streak
  Future<int> calculateCurrentStreak() async {
    // Ambil data yang sudah diminum, urutkan dari yang terbaru
    final takenRecords = await db.medicationRecords
        .filter()
        .isTakenEqualTo(true)
        .sortByTakenTimeDesc()
        .findAll();

    if (takenRecords.isEmpty) return 0;

    int streak = 1;
    DateTime lastTakenDate = takenRecords.first.takenTime!;

    // Looping untuk mengecek apakah hari sebelumnya berturut-turut
    for (int i = 1; i < takenRecords.length; i++) {
      final currentDate = takenRecords[i].takenTime!;
      final difference = lastTakenDate.difference(currentDate).inDays;

      if (difference == 1) {
        streak++;
        lastTakenDate = currentDate;
      } else if (difference > 1) {
        // Jika jeda lebih dari 1 hari, streak terputus
        break;
      }
    }

    return streak;
  }
}

final medicationRepoProvider = Provider<MedicationRepository>((ref) {
  return MedicationRepository(isar);
});