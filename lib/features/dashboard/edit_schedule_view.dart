import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/medication_repository.dart';
import '../../main.dart';
import '../../models/patient_profile.dart';
import '../dashboard/dashboard_view.dart'; // Mengambil konstanta warna

class EditScheduleView extends ConsumerStatefulWidget {
  final PatientProfile profile;

  const EditScheduleView({super.key, required this.profile});

  @override
  ConsumerState<EditScheduleView> createState() => _EditScheduleViewState();
}

class _EditScheduleViewState extends ConsumerState<EditScheduleView> {
  late List<RegimenSchedule> _tempSchedules;

  @override
  void initState() {
    super.initState();
    // Melakukan deep clone data jadwal dan obat-obatan agar perubahan tidak langsung merusak data asli sebelum disimpan
    _tempSchedules = widget.profile.schedules.map((s) {
      return RegimenSchedule()
        ..time = s.time
        ..medicines = s.medicines.map((m) {
          return MedicineDetail()
            ..name = m.name
            ..dosage = m.dosage;
        }).toList();
    }).toList();

    _sortSchedules();
  }

  void _sortSchedules() {
    _tempSchedules.sort((a, b) => (a.time ?? '00:00').compareTo(b.time ?? '00:00'));
  }

  // Memicu Time Picker untuk Tambah atau Edit Jam Alarm
  Future<void> _pickTime(BuildContext context, {int? index}) async {
    TimeOfDay initialTime = TimeOfDay.now();

    if (index != null && _tempSchedules[index].time != null) {
      final parts = _tempSchedules[index].time!.split(':');
      initialTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: primaryBlue),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      final String formattedTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';

      setState(() {
        if (index != null) {
          _tempSchedules[index].time = formattedTime;
        } else {
          // Tambah jam baru dengan 1 default obat kosong (pasien harus mengisi komposisinya)
          _tempSchedules.add(RegimenSchedule()
            ..time = formattedTime
            ..medicines = [MedicineDetail()..name = ''..dosage = '']);
        }
        _sortSchedules();
      });
    }
  }

  // Menampilkan bottom sheet / dialog interaktif untuk mengedit obat di dalam jadwal tersebut
  void _manageMedicinesBottomSheet(int scheduleIndex) {
    final schedule = _tempSchedules[scheduleIndex];

    // Siapkan list controller lokal untuk melacak input teks form
    List<TextEditingController> nameControllers = [];
    List<TextEditingController> dosageControllers = [];

    for (var med in schedule.medicines) {
      nameControllers.add(TextEditingController(text: med.name));
      dosageControllers.add(TextEditingController(text: med.dosage));
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Agar form naik saat keyboard muncul
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Komposisi Jam ${schedule.time?.replaceAll(':', '.') ?? '00.00'}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkText),
                      ),
                        TextButton.icon(
                        onPressed: () {
                          setModalState(() {
                            nameControllers.add(TextEditingController());
                            dosageControllers.add(TextEditingController());
                            schedule.medicines.add(MedicineDetail()..name = ''..dosage = '');
                          });
                        },
                        icon: const Icon(Icons.add_circle_outline_rounded, color: primaryBlue, size: 20),
                        label: const Text(
                          'Obat',
                          style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: schedule.medicines.length,
                      itemBuilder: (context, medIndex) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 5,
                                child: TextField(
                                  controller: nameControllers[medIndex],
                                  decoration: InputDecoration(
                                    labelText: 'Nama Obat',
                                    isDense: true,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 4,
                                child: TextField(
                                  controller: dosageControllers[medIndex],
                                  decoration: InputDecoration(
                                    labelText: 'Dosis',
                                    hintText: 'Misal: 1 tab',
                                    isDense: true,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ),
                              if (schedule.medicines.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                                  onPressed: () {
                                    setModalState(() {
                                      nameControllers.removeAt(medIndex);
                                      dosageControllers.removeAt(medIndex);
                                      schedule.medicines.removeAt(medIndex);
                                    });
                                  },
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkText,
                        foregroundColor: bgWhite,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        // Salinkan semua input teks kembali ke state penampung utama
                        setState(() {
                          for (int i = 0; i < schedule.medicines.length; i++) {
                            schedule.medicines[i].name = nameControllers[i].text.trim();
                            schedule.medicines[i].dosage = dosageControllers[i].text.trim();
                          }
                          // Bersihkan obat yang tidak sengaja terisi string kosong seluruhnya
                          schedule.medicines.removeWhere((m) => (m.name == null || m.name!.isEmpty));

                          // Jika obat kosong, berikan placeholder default agar tidak error di dashboard
                          if (schedule.medicines.isEmpty) {
                            schedule.medicines.add(MedicineDetail()..name = 'Obat OAT'..dosage = '1 Tab');
                          }
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('OK, Terapkan Komposisi', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _deleteSchedule(int index) {
    setState(() {
      _tempSchedules.removeAt(index);
    });
  }

  Future<void> _saveChanges() async {
    final updatedProfile = widget.profile..schedules = _tempSchedules;
    final repo = ref.read(medicationRepoProvider);

    await repo.updatePatientProfile(updatedProfile);

    // Refresh provider agar dashboard dan view history langsung ter-update otomatis
    ref.invalidate(patientProfileProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jadwal & Komposisi Obat berhasil diperbarui!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLightBlue,
      appBar: AppBar(
        title: const Text('Atur Jadwal & Obat', style: TextStyle(fontWeight: FontWeight.bold, color: bgWhite)),
        backgroundColor: primaryBlue,
        iconTheme: const IconThemeData(color: bgWhite),
      ),
      body: Column(
        children: [
          Container(
            color: primaryBlue.withOpacity(0.05),
            padding: const EdgeInsets.all(16),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, color: primaryBlue, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Ketuk baris jam untuk mengubah waktu alarm, ketuk ikon edit di kanan untuk mengubah isi racikan obat.',
                    style: TextStyle(fontSize: 12, color: darkText),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _tempSchedules.isEmpty
                ? const Center(child: Text('Belum ada jadwal diatur. Tambah baru di bawah.'))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _tempSchedules.length,
              itemBuilder: (context, index) {
                final item = _tempSchedules[index];
                final medicineNames = item.medicines.isEmpty
                    ? 'Belum ada rincian obat'
                    : item.medicines.map((m) => '${m.name} (${m.dosage ?? '-'})').join(', ');

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(color: bgWhite, borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    onTap: () => _pickTime(context, index: index),
                    leading: const Icon(Icons.alarm_rounded, color: accentOrange),
                    title: Text(
                      item.time?.replaceAll(':', '.') ?? '00.00',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: darkText),
                    ),
                    subtitle: Text(
                      medicineNames,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_note_rounded, color: primaryBlue, size: 26),
                          onPressed: () => _manageMedicinesBottomSheet(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                          onPressed: () => _deleteSchedule(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickTime(context),
                    icon: const Icon(Icons.add_alarm_rounded),
                    label: const Text('TAMBAH JAM'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryBlue,
                      side: const BorderSide(color: primaryBlue, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: bgWhite,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('SIMPAN JADWAL', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}