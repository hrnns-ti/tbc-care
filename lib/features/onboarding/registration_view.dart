import 'package:flutter/material.dart';

// Sesuaikan path import ini dengan struktur foldermu
import '../../models/patient_profile.dart';
import '../../features/alarm/alarm_service.dart';
import '../../main.dart';
import '../dashboard/dashboard_view.dart';

// Definisi Palet Warna Baru (Neo-Minimalist)
const Color primaryBlue = Color(0xFF749BFF);
const Color darkText = Color(0xFF18191E);
const Color bgWhite = Color(0xFFFFFFFF);

// Helper class untuk mengelola input obat (Nama & Dosis)
class MedicineInput {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dosageController = TextEditingController();
}

// Helper class untuk mengelola input jadwal
class ScheduleInput {
  TimeOfDay? time;
  List<MedicineInput> medicines = [MedicineInput()]; // Default 1 obat
}

class RegistrationView extends StatefulWidget {
  const RegistrationView({super.key});

  @override
  State<RegistrationView> createState() => _RegistrationViewState();
}

class _RegistrationViewState extends State<RegistrationView> {
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
  DateTime _startDate = DateTime.now();
  String _regimenCategory = 'Kategori 1';
  final _treatmentDurationDaysController = TextEditingController();
  final List<ScheduleInput> _schedules = [ScheduleInput()];

  // Controller Step 4
  final _pinController = TextEditingController();

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
    _pinController.dispose();
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
      backgroundColor: const Color(0xFFF3F0FF),
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
            // Progress Indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: List.generate(4, (index) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 8.0),
                      height: 4,
                      decoration: BoxDecoration(
                        color: _currentPage >= index ? primaryBlue : Colors.black12,
                        borderRadius: BorderRadius.circular(2),
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
                  _buildPinSetupStep(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET: STEP 1 - DATA PRIBADI
  // ==========================================
  Widget _buildPersonalDataStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mari mulai\nperjalanan Anda.',
            style: TextStyle(fontSize: 36, height: 1.1, fontWeight: FontWeight.w800, letterSpacing: -1.0, color: darkText),
          ),
          const SizedBox(height: 40),
          _buildCleanTextField(label: 'NAMA LENGKAP', controller: _nameController, hint: 'Contoh: Budi Santoso'),
          const SizedBox(height: 24),
          _buildCleanTextField(label: 'NOMOR INDUK KEPENDUDUKAN', controller: _nikController, hint: '16 digit NIK', keyboardType: TextInputType.number),
          const SizedBox(height: 24),

          const Text('TANGGAL LAHIR', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: Colors.grey)),
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime(1990),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (date != null) setState(() => _birthDate = date);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black12, width: 2))),
              child: Text(
                _birthDate != null ? '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}' : 'Pilih Tanggal Lahir',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: _birthDate != null ? darkText : Colors.black26),
              ),
            ),
          ),
          const SizedBox(height: 24),

          _buildCleanTextField(label: 'NOMOR HANDPHONE', controller: _phoneController, hint: '0812xxxxxxx', keyboardType: TextInputType.phone),
          const SizedBox(height: 48),

          SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: darkText, foregroundColor: Colors.white, elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Lanjutkan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ==========================================
  // WIDGET: STEP 2 - DATA MEDIS
  // ==========================================
  Widget _buildMedicalDataStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi\nFasilitas Kesehatan.',
            style: TextStyle(fontSize: 36, height: 1.1, fontWeight: FontWeight.w800, letterSpacing: -1.0, color: darkText),
          ),
          const SizedBox(height: 40),
          _buildCleanTextField(label: 'NAMA PUSKESMAS / RS', controller: _puskesmasController, hint: 'Contoh: Puskesmas Ciputat'),
          const SizedBox(height: 24),
          _buildCleanTextField(label: 'NAMA PMO (PENGAWAS MINUM OBAT)', controller: _pmoController, hint: 'Keluarga / Kader TB'),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: darkText, foregroundColor: Colors.white, elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Lanjutkan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // WIDGET: STEP 3 - REGIMEN, DURASI & JADWAL
  // ==========================================
  Widget _buildRegimenDataStep() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            children: [
              const Text(
                'Atur Jadwal\nPengobatan.',
                style: TextStyle(fontSize: 36, height: 1.1, fontWeight: FontWeight.w800, letterSpacing: -1.0, color: darkText),
              ),
              const SizedBox(height: 40),

              // KATEGORI
              const Text('KATEGORI REGIMEN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: Colors.grey)),
              DropdownButtonFormField<String>(
                value: _regimenCategory,
                icon: const Icon(Icons.keyboard_arrow_down, color: darkText),
                decoration: const InputDecoration(
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12, width: 2)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: primaryBlue, width: 2)),
                ),
                items: ['Kategori 1', 'Kategori 2', 'MDR-TB'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                  );
                }).toList(),
                onChanged: (newValue) => setState(() => _regimenCategory = newValue!),
              ),
              const SizedBox(height: 24),

              // DURASI PENGOBATAN
              _buildCleanTextField(
                label: 'TOTAL DURASI PENGOBATAN (HARI)',
                controller: _treatmentDurationDaysController,
                hint: 'Misal: 180',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 40),

              const Text('JADWAL & LIST OBAT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: Colors.grey)),
              const SizedBox(height: 16),

              // RENDER JADWAL DINAMIS
              ...List.generate(_schedules.length, (index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: bgWhite,
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Jadwal Ke-${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: primaryBlue)),
                          if (_schedules.length > 1)
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () => setState(() => _schedules.removeAt(index)),
                            )
                        ],
                      ),
                      const SizedBox(height: 16),

                      // TIME PICKER
                      InkWell(
                        onTap: () async {
                          final time = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 7, minute: 0));
                          if (time != null) setState(() => _schedules[index].time = time);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(color: primaryBlue.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _schedules[index].time != null ? _schedules[index].time!.format(context) : 'Pilih Waktu',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _schedules[index].time != null ? darkText : Colors.black38),
                              ),
                              const Icon(Icons.access_time, color: primaryBlue),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // NESTED LIST: RENDER INPUT OBAT & DOSIS
                      ...List.generate(_schedules[index].medicines.length, (medIndex) {
                        final medInput = _schedules[index].medicines[medIndex];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  controller: medInput.nameController,
                                  decoration: InputDecoration(
                                    labelText: 'Nama Obat',
                                    hintText: 'Misal: Rifampicin',
                                    isDense: true,
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black12)),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: primaryBlue, width: 2)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 1,
                                child: TextField(
                                  controller: medInput.dosageController,
                                  decoration: InputDecoration(
                                    labelText: 'Dosis',
                                    hintText: 'mg/ml',
                                    isDense: true,
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black12)),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: primaryBlue, width: 2)),
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
                          icon: const Icon(Icons.add_box_outlined, color: Colors.grey, size: 18),
                          label: const Text('Tambah Obat', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // TOMBOL TAMBAH JADWAL BARU
              TextButton.icon(
                onPressed: () => setState(() => _schedules.add(ScheduleInput())),
                icon: const Icon(Icons.add, color: primaryBlue),
                label: const Text('Tambah Waktu Minum Obat', style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton(
              onPressed: _schedules.any((s) => s.time != null) ? _nextPage : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: darkText, foregroundColor: Colors.white, elevation: 0,
                disabledBackgroundColor: Colors.black12,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Lanjutkan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // WIDGET: STEP 4 - PIN & SAVE TO ISAR
  // ==========================================
  Widget _buildPinSetupStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Amankan\nData Anda.',
            style: TextStyle(fontSize: 36, height: 1.1, fontWeight: FontWeight.w800, letterSpacing: -1.0, color: darkText),
          ),
          const SizedBox(height: 40),
          _buildCleanTextField(
            label: 'BUAT PIN 6 DIGIT', controller: _pinController, hint: '• • • • • •', keyboardType: TextInputType.number,
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton(
              onPressed: _saveAndFinish,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue, foregroundColor: Colors.white, elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Selesai & Mulai', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // Logika Utama Menyimpan ke Database Isar
  Future<void> _saveAndFinish() async {
    if (_nameController.text.isEmpty || _nikController.text.isEmpty || _phoneController.text.isEmpty || _pinController.text.length < 6 || _birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mohon lengkapi semua data pribadi, tanggal lahir, dan PIN 6 digit.')));
      return;
    }

    if (_nameController.text.isEmpty ||
        _nikController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _treatmentDurationDaysController.text.isEmpty ||
        _pinController.text.length < 6 ||
        _birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mohon lengkapi semua data, durasi pengobatan, dan PIN 6 digit.')));
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
      ..pin = _pinController.text
      ..treatmentStartDate = _startDate
      ..regimenCategory = _regimenCategory
      ..totalTreatmentDays = int.tryParse(_treatmentDurationDaysController.text) ?? 180
      ..schedules = finalSchedules;

    try {
      await isar.writeTxn(() async {
        await isar.patientProfiles.put(profile);
      });

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
          const SnackBar(content: Text('Registrasi Berhasil!')),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardView()),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan data: $e')));
      }
    }
  }

  Widget _buildCleanTextField({required String label, required TextEditingController controller, required String hint, TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: Colors.grey)),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: darkText),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black26),
            border: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12, width: 2)),
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12, width: 2)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: primaryBlue, width: 2)),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ],
    );
  }
}