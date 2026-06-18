import 'package:isar/isar.dart';

part 'patient_profile.g.dart';

@embedded
class MedicineDetail {
  String? name;
  String? dosage;
}

@embedded
class RegimenSchedule {
  String? time;
  List<MedicineDetail> medicines = [];
}

@collection
class PatientProfile {
  Id id = Isar.autoIncrement;

  late String fullName;
  @Index(unique: true)
  late String nik;
  late DateTime birthDate;
  late String phoneNumber;

  late String puskesmasName;
  late String pmoName;

  late String pin;

  late DateTime treatmentStartDate;
  late String regimenCategory;

  late int totalTreatmentDays;

  List<RegimenSchedule> schedules = [];
}