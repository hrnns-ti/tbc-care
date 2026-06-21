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

  Stream<List<MedicationRecord>> watchAllRecords() {
    return db.medicationRecords.where().anyId().watch(fireImmediately: true);
  }

  Future<List<MedicationRecord>> getAllRecords() async {
    return await db.medicationRecords.where().findAll();
  }

  Future<void> addRecord(MedicationRecord record) async {
    await db.writeTxn(() async {
      await db.medicationRecords.put(record);
    });
  }

  // ======================================================================
  // HITUNG CURRENT STREAK SECARA AMAN DAN REAL-TIME
  // ======================================================================
  Future<int> calculateCurrentStreak() async {
    final allRecords = await db.medicationRecords.where().findAll();
    if (allRecords.isEmpty) return 0;

    // Grouping record berdasarkan tanggal tanpa jam (agar mudah dicari)
    Map<DateTime, List<MedicationRecord>> recordsByDate = {};
    for (var record in allRecords) {
      final t = record.scheduledTime;
      final date = DateTime(t.year, t.month, t.day);
      recordsByDate.putIfAbsent(date, () => []).add(record);
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int streak = 0;
    DateTime checkDate = today;

    // Pengaman: Cari tanggal paling awal yang ada di database agar loop tidak kebablasan ke tahun 1970
    final allScheduledTimes = allRecords.map((e) => e.scheduledTime).toList();
    allScheduledTimes.sort((a, b) => a.compareTo(b));
    final oldestDateInDb = DateTime(
        allScheduledTimes.first.year,
        allScheduledTimes.first.month,
        allScheduledTimes.first.day
    );

    // Lakukan perulangan mundur hari demi hari
    while (true) {
      // Batas Pengaman Ekstrim: Jika pencarian mundur sudah melewati data tertua di DB, hentikan loop
      if (checkDate.isBefore(oldestDateInDb)) {
        break;
      }

      final dailyRecords = recordsByDate[checkDate];

      // Kasus A: Hari yang dicek tidak punya jadwal sama sekali di database
      if (dailyRecords == null || dailyRecords.isEmpty) {
        if (checkDate == today) {
          // Jika hari ini belum ada jadwal (misal baru ganti hari dan Isar belum generate rekam medis harian),
          // jangan putuskan streak hari kemarin. Langsung lompat cek hari kemarin.
          checkDate = checkDate.subtract(const Duration(days: 1));
          continue;
        } else {
          // Jika hari kemarin atau sebelumnya bolong tanpa record, streak resmi putus!
          break;
        }
      }

      // Kasus B: Hari tersebut memiliki jadwal, mari kita evaluasi kepatuhannya
      bool isToday = (checkDate == today);
      bool isDayValid = true;
      bool checkedAtLeastOne = false;

      for (var record in dailyRecords) {
        if (isToday) {
          // Khusus HARI INI: Hanya cek jadwal yang SEHARUSNYA SUDAH diminum (jamnya sudah lewat)
          if (record.scheduledTime.isBefore(now)) {
            checkedAtLeastOne = true;
            if (!record.isTaken) {
              isDayValid = false; // Ada obat yang terlewat hari ini!
              break;
            }
          }
        } else {
          // Untuk HARI KEMARIN dan seterusnya: Wajib SEMUA obat statusnya isTaken == true
          checkedAtLeastOne = true;
          if (!record.isTaken) {
            isDayValid = false;
            break;
          }
        }
      }

      // Tentukan apakah streak bertambah atau putus berdasarkan evaluasi hari tersebut
      if (!isDayValid) {
        // Pasien terbukti melewatkan obat (baik hari ini atau hari kemarin). Streak putus!
        break;
      }

      if (isToday) {
        // Khusus hari ini:
        if (checkedAtLeastOne) {
          // Jika sudah ada obat yang dilewati jamnya dan sukses diminum semua,
          // hari ini BERHAK dihitung masuk ke streak sementara berjalan.
          streak++;
        } else {
          // Jika sekarang masih pagi dan belum ada jadwal yang lewat jamnya,
          // hari ini jangan putus, tapi belum dihitung +1 streak (menunggu sampai jamnya tiba).
          // Cukup biarkan streak bernilai dari hari kemarin.
        }
      } else {
        // Untuk hari kemarin dan seterusnya yang sukses 100%
        streak++;
      }

      // Mundur 1 hari ke belakang untuk pengecekan loop berikutnya
      checkDate = checkDate.subtract(const Duration(days: 1));
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
    int daysPassed = now.difference(startDate).inDays + 1;
    if (daysPassed < 1) daysPassed = 1;

    final expectedMeds = daysPassed * schedulesPerDay;
    final takenMedsCount = await db.medicationRecords.filter().isTakenEqualTo(true).count();

    if (expectedMeds == 0) return 100.0;

    return (takenMedsCount / expectedMeds) * 100;
  }


  Future<PatientProfile?> getPatientProfile() async {
    return await db.patientProfiles.where().findFirst();
  }

  // ======================================================================
  // UPDATE PROFIL PASIEN
  // ======================================================================
  Future<void> updatePatientProfile(PatientProfile profile) async {
    await db.writeTxn(() async {
      await db.patientProfiles.put(profile);
    });
  }
}