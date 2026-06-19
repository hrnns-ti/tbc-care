import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/patient_profile.dart';
import '../../features/alarm/alarm_service.dart';
import '../../main.dart';
import '../dashboard/dashboard_view.dart';

// Palet Warna Konsisten Sesuai View Lainnya
const Color primaryBlue = Color(0xFF4A90E2);
const Color accentGreen = Color(0xFF5CC8A1);
const Color accentOrange = Color(0xFFFFA726);
const Color bgLightBlue = Color(0xFFF5F7FA);
const Color darkText = Color(0xFF18191E);
const Color bgWhite = Color(0xFFFFFFFF);

// Helper class untuk mengelola input obat (Nama & Dosis)
class MedicineInput {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dosageController = TextEditingController();
}

class ScheduleInput {
  TimeOfDay? time;
  List<MedicineInput> medicines = [MedicineInput()]; // Default 1 obat
}

class RegistrationView extends ConsumerStatefulWidget {
  const RegistrationView({super.key});

  @override
  ConsumerState<RegistrationView> createState() => _RegistrationViewState();
}

class _RegistrationViewState extends ConsumerState<RegistrationView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Controllers Step 1
  final _nameController = TextEditingController();
  final _nikController = TextEditingController();
  final _phoneController = TextEditingController();
  DateTime? _birthDate;

  // Controllers Step 2
  final _puskesmasController = TextEditingController();
  final _pmoController = TextEditingController();

  // State Step 3 (Regimen, Durasi & Jadwal Dinamis)
  final DateTime _startDate = DateTime.now();
  String _regimenCategory = 'Fase Intensif';
  final _treatmentDurationDaysController = TextEditingController();
  final List<ScheduleInput> _schedules = [ScheduleInput()];

  void _nextPage() {
    FocusScope.of(context).unfocus();
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _nikController.dispose();
    _phoneController.dispose();
    _puskesmasController.dispose();
    _pmoController.dispose();
    _treatmentDurationDaysController.dispose();

    // Dispose semua controller di dalam nested list
    for (var schedule in _schedules) {
      for (var med in schedule.medicines) {
        med.nameController.dispose();
        med.dosageController.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLightBlue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentPage > 0
            ? IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: darkText, size: 20),
          onPressed: () {
            _pageController.previousPage(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          },
        )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator (Sekarang hanya 3 Step)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: List.generate(3, (index) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 8.0),
                      height: 6,
                      decoration: BoxDecoration(
                        color: _currentPage >= index ? primaryBlue : Colors.black12,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 32),

            // Konten Form
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  _buildPersonalDataStep(),
                  _buildMedicalDataStep(),
                  _buildRegimenDataStep(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalDataStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mari mulai\nperjalanan Anda.',
            style: TextStyle(fontSize: 32, height: 1.2, fontWeight: FontWeight.w900, color: darkText),
          ),
          const SizedBox(height: 12),
          const Text(
            'Lengkapi data diri Anda untuk membuat profil pengobatan yang akurat.',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 32),
          _buildCleanTextField(label: 'Nama Lengkap', controller: _nameController, hint: 'Contoh: Budi Santoso', icon: Icons.person_outline),
          const SizedBox(height: 20),
          _buildCleanTextField(label: 'Nomor Induk Kependudukan', controller: _nikController, hint: '16 digit NIK', keyboardType: TextInputType.number, icon: Icons.badge_outlined),
          const SizedBox(height: 20),

          const Text('Tanggal Lahir', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: darkText)),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime(1990),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(primary: primaryBlue),
                    ),
                    child: child!,
                  );
                },
              );
              if (date != null) setState(() => _birthDate = date);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                color: bgWhite,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, color: Colors.grey, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    _birthDate != null ? '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}' : 'Pilih Tanggal Lahir',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: _birthDate != null ? darkText : Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          _buildCleanTextField(label: 'Nomor Handphone', controller: _phoneController, hint: '0812xxxxxxx', keyboardType: TextInputType.phone, icon: Icons.phone_android_outlined),
          const SizedBox(height: 48),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue, foregroundColor: bgWhite, elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Lanjutkan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildMedicalDataStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi\nFasilitas Kesehatan.',
            style: TextStyle(fontSize: 32, height: 1.2, fontWeight: FontWeight.w900, color: darkText),
          ),
          const SizedBox(height: 12),
          const Text(
            'Data faskes pendamping untuk membantu proses pengawasan pengobatan Anda.',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 32),
          _buildCleanTextField(label: 'Nama Puskesmas / RS', controller: _puskesmasController, hint: 'Contoh: Puskesmas Ciputat', icon: Icons.local_hospital_outlined),
          const SizedBox(height: 20),
          _buildCleanTextField(label: 'Nama PMO (Pengawas Minum Obat)', controller: _pmoController, hint: 'Keluarga / Kader TB', icon: Icons.assignment_ind_outlined),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue, foregroundColor: bgWhite, elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Lanjutkan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegimenDataStep() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            children: [
              const Text(
                'Atur Jadwal\nPengobatan.',
                style: TextStyle(fontSize: 32, height: 1.2, fontWeight: FontWeight.w900, color: darkText),
              ),
              const SizedBox(height: 12),
              const Text(
                'Sesuaikan waktu alarm minum obat dan jenis obat yang diresepkan dokter.',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 32),

              // KATEGORI REGIMEN
              const Text('Kategori Regimen', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: darkText)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: bgWhite,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: DropdownButtonFormField<String>(
                  value: _regimenCategory,
                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                  decoration: const InputDecoration(border: InputBorder.none),
                  items: ['Fase Intensif', 'Fase Lanjutan',].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: darkText)),
                    );
                  }).toList(),
                  onChanged: (newValue) => setState(() => _regimenCategory = newValue!),
                ),
              ),
              const SizedBox(height: 20),

              // DURASI PENGOBATAN
              _buildCleanTextField(
                label: 'Total Durasi Pengobatan (Hari)',
                controller: _treatmentDurationDaysController,
                hint: 'Misal: 180',
                keyboardType: TextInputType.number,
                icon: Icons.date_range_outlined,
              ),
              const SizedBox(height: 32),

              const Text('Jadwal & Komposisi Obat', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: darkText)),
              const SizedBox(height: 16),

              // RENDER JADWAL DINAMIS
              ...List.generate(_schedules.length, (index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: bgWhite,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(color: accentOrange.withOpacity(0.1), shape: BoxShape.circle),
                                child: const Icon(Icons.alarm, color: accentOrange, size: 16),
                              ),
                              const SizedBox(width: 8),
                              Text('Alarm Ke-${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: darkText)),
                            ],
                          ),
                          if (_schedules.length > 1)
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => setState(() => _schedules.removeAt(index)),
                            )
                        ],
                      ),
                      const SizedBox(height: 16),

                      // TIME PICKER
                      InkWell(
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: const TimeOfDay(hour: 7, minute: 0),
                            builder: (context, child) => Theme(
                              data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: primaryBlue)),
                              child: child!,
                            ),
                          );
                          if (time != null) setState(() => _schedules[index].time = time);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: bgLightBlue, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _schedules[index].time != null ? _schedules[index].time!.format(context) : 'Pilih Waktu',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _schedules[index].time != null ? primaryBlue : Colors.grey),
                              ),
                              const Icon(Icons.access_time, color: Colors.grey, size: 20),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('Obat yang diminum:', style: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),

                      // NESTED LIST: RENDER INPUT OBAT & DOSIS
                      ...List.generate(_schedules[index].medicines.length, (medIndex) {
                        final medInput = _schedules[index].medicines[medIndex];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 5,
                                child: TextField(
                                  controller: medInput.nameController,
                                  decoration: InputDecoration(
                                    labelText: 'Nama Obat',
                                    hintText: 'Misal: Rifampicin',
                                    isDense: true,
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: bgLightBlue, width: 2)),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: primaryBlue, width: 2)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 3,
                                child: TextField(
                                  controller: medInput.dosageController,
                                  decoration: InputDecoration(
                                    labelText: 'Dosis',
                                    hintText: 'mg/tab',
                                    isDense: true,
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: bgLightBlue, width: 2)),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: primaryBlue, width: 2)),
                                  ),
                                ),
                              ),
                              if (_schedules[index].medicines.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20),
                                  onPressed: () => setState(() => _schedules[index].medicines.removeAt(medIndex)),
                                )
                            ],
                          ),
                        );
                      }),

                      // TOMBOL TAMBAH OBAT
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => setState(() => _schedules[index].medicines.add(MedicineInput())),
                          icon: const Icon(Icons.add_circle_outline_rounded, color: primaryBlue, size: 18),
                          label: const Text('Tambah Obat', style: TextStyle(color: primaryBlue, fontSize: 13, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // TOMBOL TAMBAH JADWAL BARU
              OutlinedButton.icon(
                onPressed: () => setState(() => _schedules.add(ScheduleInput())),
                icon: const Icon(Icons.add_alarm_rounded, color: primaryBlue),
                label: const Text('TAMBAH WAKTU MINUM OBAT'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryBlue,
                  side: const BorderSide(color: primaryBlue, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _schedules.any((s) => s.time != null) ? _saveAndFinish : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentGreen,
                foregroundColor: bgWhite,
                elevation: 0,
                disabledBackgroundColor: Colors.black12,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Selesai & Simpan Data', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ],
    );
  }

  // Logika Utama Menyimpan ke Database Isar
  Future<void> _saveAndFinish() async {
    if (_nameController.text.isEmpty ||
        _nikController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _treatmentDurationDaysController.text.isEmpty ||
        _birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Mohon lengkapi semua data pribadi dan pengobatan.'),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }

    String formatTimeOfDay(TimeOfDay time) {
      final hour = time.hour.toString().padLeft(2, '0');
      final minute = time.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }

    // Ekstrak data dari Nested Controllers
    List<RegimenSchedule> finalSchedules = [];
    for (var scheduleInput in _schedules) {
      if (scheduleInput.time != null) {
        List<MedicineDetail> meds = [];
        for (var medInput in scheduleInput.medicines) {
          if (medInput.nameController.text.isNotEmpty) {
            meds.add(
                MedicineDetail()
                  ..name = medInput.nameController.text.trim()
                  ..dosage = medInput.dosageController.text.trim()
            );
          }
        }

        finalSchedules.add(
            RegimenSchedule()
              ..time = formatTimeOfDay(scheduleInput.time!)
              ..medicines = meds
        );
      }
    }

    final profile = PatientProfile()
      ..fullName = _nameController.text
      ..nik = _nikController.text
      ..birthDate = _birthDate!
      ..phoneNumber = _phoneController.text
      ..puskesmasName = _puskesmasController.text
      ..pmoName = _pmoController.text
      ..treatmentStartDate = _startDate
      ..regimenCategory = _regimenCategory
      ..totalTreatmentDays = int.tryParse(_treatmentDurationDaysController.text) ?? 180
      ..schedules = finalSchedules;

    try {
      await isar.writeTxn(() async {
        await isar.patientProfiles.put(profile);
      });

      ref.invalidate(patientProfileProvider);

      await AlarmService.requestPermission();
      final now = DateTime.now();

      for (int i = 0; i < finalSchedules.length; i++) {
        final timeStr = finalSchedules[i].time!.split(':');
        final hour = int.parse(timeStr[0]);
        final minute = int.parse(timeStr[1]);

        DateTime scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);
        if (scheduledTime.isBefore(now)) {
          scheduledTime = scheduledTime.add(const Duration(days: 1));
        }
        await AlarmService.scheduleAlarm(scheduledTime, i + 1);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrasi Berhasil!'), backgroundColor: accentGreen),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardView()),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menyimpan data: $e'), backgroundColor: Colors.redAccent)
        );
      }
    }
  }

  Widget _buildCleanTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: darkText)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: bgWhite,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 16, color: darkText),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 15),
              prefixIcon: Icon(icon, color: Colors.grey, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: primaryBlue, width: 2)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}