import 'package:isar/isar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Sesuaikan path import ini agar mengarah ke file model dan main.dart-mu
import '../../models/medication_record.dart';
import '../../main.dart';
import '../../models/patient_profile.dart';

final medicationRepoProvider = Provider<MedicationRepository>((ref) {
  return MedicationRepository(isar);
});

class MedicationRepository {
  final Isar db;

  MedicationRepository(this.db);

  Future<List<MedicationRecord>> getAllRecords() async {
    return await db.medicationRecords.where().findAll();
  }

  Future<void> addRecord(MedicationRecord record) async {
    await db.writeTxn(() async {
      await db.medicationRecords.put(record);
    });
  }

  Future<int> calculateCurrentStreak() async {
    final allRecords = await db.medicationRecords.where().findAll();

    if (allRecords.isEmpty) return 0;

    Map<DateTime, List<MedicationRecord>> recordsByDate = {};
    for (var record in allRecords) {
      final t = record.scheduledTime;
      final date = DateTime(t.year, t.month, t.day);
      recordsByDate.putIfAbsent(date, () => []).add(record);
    }

    final sortedDates = recordsByDate.keys.toList()..sort((a, b) => b.compareTo(a));
    if (sortedDates.isEmpty) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final mostRecentDate = sortedDates.first;

    if (today.difference(mostRecentDate).inDays > 1) {
      return 0;
    }

    int streak = 0;
    DateTime expectedDate = mostRecentDate;

    for (var date in sortedDates) {
      if (date.isAtSameMomentAs(expectedDate)) {

        final dailyRecords = recordsByDate[date]!;
        bool isDayComplete = true;
        bool hasTakenAtLeastOne = false;

        for (var record in dailyRecords) {
          if (record.scheduledTime.isBefore(now)) {
            if (!record.isTaken) {
              isDayComplete = false;
              break;
            } else {
              hasTakenAtLeastOne = true;
            }
          }
        }

        if (isDayComplete && hasTakenAtLeastOne) {
          streak++;
          expectedDate = expectedDate.subtract(const Duration(days: 1));
        } else if (!isDayComplete) {
          break;
        }

      } else {
        break;
      }
    }

    return streak;
  }

  // ======================================================================
  // AMBIL DATA HARI INI SAJA
  // ======================================================================
  Future<List<MedicationRecord>> getTodaysRecords() async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return await db.medicationRecords
        .filter()
        .scheduledTimeBetween(todayStart, todayEnd)
        .findAll();
  }

  // ======================================================================
  // HITUNG PERSENTASE KEPATUHAN
  // ======================================================================
  Future<double> calculateCompliance(DateTime startDate, int schedulesPerDay) async {
    final now = DateTime.now();
    // Hitung berapa hari sudah berjalan
    int daysPassed = now.difference(startDate).inDays + 1;
    if (daysPassed < 1) daysPassed = 1;

    // Total obat yang seharusnya sudah diminum sampai hari ini
    final expectedMeds = daysPassed * schedulesPerDay;

    // Total obat yang benar-benar dikonfirmasi di database
    final takenMedsCount = await db.medicationRecords.filter().isTakenEqualTo(true).count();

    if (expectedMeds == 0) return 100.0;

    // Kembalikan dalam bentuk persentase
    return (takenMedsCount / expectedMeds) * 100;
  }

  Future<void> updatePatientProfile(PatientProfile profile) async {
    await isar.writeTxn(() async {
      await isar.patientProfiles.put(profile);
    });
  }
}