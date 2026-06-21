import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/medication_repository.dart';
import '../../main.dart';
import '../../models/patient_profile.dart';
import '../alarm/alarm_service.dart';
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Agar form naik saat keyboard muncul
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      builder: (context) {
        return _MedicineFormBottomSheet(
          schedule: schedule,
          onApply: (updatedMedicines) {
            setState(() {
              schedule.medicines = updatedMedicines;
            });
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

    // 1. Simpan perubahan ke dalam Isar Database local
    await repo.updatePatientProfile(updatedProfile);

    // 2. Bersihkan slot alarm lama di sistem Android OS terlebih dahulu untuk menghindari penumpukan ID
    for (int id = 1; id <= 10; id++) {
      await AlarmService.cancelAlarm(id);
    }

    // 3. Daftarkan ulang jadwal alarm baru ke sistem Android OS
    final now = DateTime.now();
    for (int i = 0; i < updatedProfile.schedules.length; i++) {
      final sched = updatedProfile.schedules[i];
      if (sched.time != null) {
        final timeParts = sched.time!.split(':');
        final targetDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
          0,
          0,
        );

        // Mendaftarkan kembali menggunakan ID yang konsisten berbasis urutan index (1, 2, 3...)
        await AlarmService.scheduleAlarm(targetDateTime, i + 1);
      }
    }

    // Refresh provider agar dashboard dan view history langsung ter-update otomatis
    ref.invalidate(patientProfileProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jadwal & Alarm berhasil diperbarui!'),
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

// ======================================================================
// WIDGET KHUSUS KOMPOSISI OBAT UNTUK MENANGANI LIFECYCLE CONTROLLER
// ======================================================================
class _MedicineFormBottomSheet extends StatefulWidget {
  final RegimenSchedule schedule;
  final Function(List<MedicineDetail>) onApply;

  const _MedicineFormBottomSheet({required this.schedule, required this.onApply});

  @override
  State<_MedicineFormBottomSheet> createState() => _MedicineFormBottomSheetState();
}

class _MedicineFormBottomSheetState extends State<_MedicineFormBottomSheet> {
  final List<TextEditingController> _nameControllers = [];
  final List<TextEditingController> _dosageControllers = [];
  final List<MedicineDetail> _localMedicines = [];

  @override
  void initState() {
    super.initState();
    // Salin data ke local list agar perubahan tidak langsung merusak data sebelum klik OK
    for (var med in widget.schedule.medicines) {
      _localMedicines.add(MedicineDetail()..name = med.name..dosage = med.dosage);
      _nameControllers.add(TextEditingController(text: med.name));
      _dosageControllers.add(TextEditingController(text: med.dosage));
    }
  }

  @override
  void dispose() {
    // Di sinilah tempat paling aman untuk membuang controller tanpa mengganggu render tree
    for (var c in _nameControllers) {
      c.dispose();
    }
    for (var c in _dosageControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                'Komposisi Jam ${widget.schedule.time?.replaceAll(':', '.') ?? '00.00'}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkText),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _nameControllers.add(TextEditingController());
                    _dosageControllers.add(TextEditingController());
                    _localMedicines.add(MedicineDetail()..name = ''..dosage = '');
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
              itemCount: _localMedicines.length,
              itemBuilder: (context, medIndex) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: TextField(
                          controller: _nameControllers[medIndex],
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
                          controller: _dosageControllers[medIndex],
                          decoration: InputDecoration(
                            labelText: 'Dosis',
                            hintText: 'Misal: 1 tab',
                            isDense: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      if (_localMedicines.length > 1)
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                          onPressed: () {
                            setState(() {
                              _nameControllers[medIndex].dispose();
                              _dosageControllers[medIndex].dispose();
                              _nameControllers.removeAt(medIndex);
                              _dosageControllers.removeAt(medIndex);
                              _localMedicines.removeAt(medIndex);
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
                // Terapkan data teks dari controller ke local model
                for (int i = 0; i < _localMedicines.length; i++) {
                  _localMedicines[i].name = _nameControllers[i].text.trim();
                  _localMedicines[i].dosage = _dosageControllers[i].text.trim();
                }

                // Bersihkan string kosong yang tidak sengaja ter-submit
                _localMedicines.removeWhere((m) => (m.name == null || m.name!.isEmpty));

                // Placeholder default jika seluruh baris obat dikosongkan
                if (_localMedicines.isEmpty) {
                  _localMedicines.add(MedicineDetail()..name = 'Obat OAT'..dosage = '1 Tab');
                }

                // Kirim balik data yang valid ke view utama melalui callback
                widget.onApply(_localMedicines);
                Navigator.pop(context);
              },
              child: const Text('OK, Terapkan Komposisi', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
}