import 'package:isar/isar.dart';

// Baris ini wajib ada. File .g.dart akan di-generate otomatis nanti.
part 'medication_record.g.dart';

@collection
class MedicationRecord {
  Id id = Isar.autoIncrement; // Auto ID

  late DateTime scheduledTime; // Jadwal obat seharusnya diminum

  DateTime? takenTime; // Kapan pengguna benar-benar menekan tombol konfirmasi

  bool isTaken = false; // Status kepatuhan

  String? imagePath; // Menyimpan string lokasi foto lokal, bukan gambar utuh
}