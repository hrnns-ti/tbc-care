import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../main.dart';
import '../../models/patient_profile.dart';
import '../../models/medication_record.dart';
import '../../core/database/medication_repository.dart';

// Palet Warna Konsisten Sesuai image_9f0ba7.jpg
const Color primaryBlue = Color(0xFF4A90E2);
const Color accentGreen = Color(0xFF5CC8A1);
const Color accentOrange = Color(0xFFFFA726);
const Color bgLightBlue = Color(0xFFF5F7FA);
const Color darkText = Color(0xFF18191E);
const Color bgWhite = Color(0xFFFFFFFF);

class HistoryCalendarView extends ConsumerStatefulWidget {
  const HistoryCalendarView({super.key});

  @override
  ConsumerState<HistoryCalendarView> createState() => _HistoryCalendarViewState();
}

class _HistoryCalendarViewState extends ConsumerState<HistoryCalendarView> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(patientProfileProvider);

    return profileAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: primaryBlue)),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (profile) {
        if (profile == null) return const Center(child: Text('Data profil tidak ditemukan'));

        final now = DateTime.now();
        final todayMidnight = DateTime(now.year, now.month, now.day);
        final startMidnight = DateTime(profile.treatmentStartDate.year, profile.treatmentStartDate.month, profile.treatmentStartDate.day);

        // Menghitung berapa hari yang sudah dilalui sejak tanggal mulai
        final daysPassed = todayMidnight.difference(startMidnight).inDays + 1;
        final safeDaysPassed = daysPassed > 0 ? daysPassed : 1;

        // Persentase Berdasarkan Hari Jalan / Total Durasi Pengobatan (Misal: 12 hari / 180 hari)
        double timelineProgressPercent = (safeDaysPassed / profile.totalTreatmentDays) * 100;
        timelineProgressPercent = timelineProgressPercent.clamp(0.0, 100.0);

        final totalWeeks = (profile.totalTreatmentDays / 7).ceil();
        final currentWeek = (safeDaysPassed / 7).ceil().clamp(1, totalWeeks);

        final repo = ref.watch(medicationRepoProvider);

        return FutureBuilder<List<MedicationRecord>>(
          future: repo.getAllRecords(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: primaryBlue));
            }

            final records = snapshot.data ?? [];

            final Map<DateTime, int> dailyTakenMap = {};
            for (var r in records) {
              if (r.isTaken) {
                final dateKey = DateTime(r.scheduledTime.year, r.scheduledTime.month, r.scheduledTime.day);
                dailyTakenMap[dateKey] = (dailyTakenMap[dateKey] ?? 0) + 1;
              }
            }

            int totalTakenInMonth = 0;
            int expectedSchedulesInMonth = 0;

            for (int i = 0; i < 30; i++) {
              final checkDate = todayMidnight.subtract(Duration(days: i));
              if (checkDate.isAfter(startMidnight) || checkDate.isAtSameMomentAs(startMidnight)) {
                final cleanKey = DateTime(checkDate.year, checkDate.month, checkDate.day);

                // Tambahkan ekspektasi (misal sehari wajib 2x minum)
                expectedSchedulesInMonth += profile.schedules.length;
                // Tambahkan realita (berapa kali diminum hari itu)
                totalTakenInMonth += (dailyTakenMap[cleanKey] ?? 0);
              }
            }

            double complianceRate = expectedSchedulesInMonth > 0
                ? (totalTakenInMonth / expectedSchedulesInMonth) * 100
                : 100.0;
            if (complianceRate > 100) complianceRate = 100;

            return Column(
              children: [
                Container(
                  width: double.infinity,
                  color: primaryBlue,
                  padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
                  child: const Center(
                    child: Text(
                      'Progress & Kepatuhan',
                      style: TextStyle(color: bgWhite, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildProgressCard(timelineProgressPercent, currentWeek, totalWeeks, profile.regimenCategory, safeDaysPassed, profile.totalTreatmentDays),
                        const SizedBox(height: 16),

                        // Pass parameter map int dan jumlah jadwal harian
                        _buildCalendarCard(dailyTakenMap, profile.schedules.length, startMidnight, todayMidnight),
                        const SizedBox(height: 16),
                        _buildMonthlyStatsCard(complianceRate),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Modifikasi parameter untuk menampilkan detail hari berjalan di sub-text
  Widget _buildProgressCard(double progressPercent, int currentWeek, int totalWeeks, String phase, int daysPassed, int totalDays) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 90,
                height: 90,
                child: CircularProgressIndicator(
                  value: progressPercent / 100, // Menggunakan persentase durasi hari
                  strokeWidth: 10,
                  backgroundColor: bgLightBlue,
                  valueColor: const AlwaysStoppedAnimation<Color>(primaryBlue), // Diubah ke Biru agar membedakan dari indikator kepatuhan obat
                ),
              ),
              Text(
                '${progressPercent.toStringAsFixed(0)}%',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: darkText),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Minggu $currentWeek dari $totalWeeks',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkText),
                ),
                const SizedBox(height: 4),
                Text(
                  'Hari $daysPassed dari $totalDays hari',
                  style: const TextStyle(fontSize: 13, color: primaryBlue, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  phase,
                  style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCalendarCard(Map<DateTime, int> dailyTakenMap, int expectedPerDay, DateTime startDate, DateTime today) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: bgWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Text(
              'Kalender Kepatuhan',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: darkText),
            ),
          ),
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              leftChevronIcon: Icon(Icons.chevron_left, color: primaryBlue),
              rightChevronIcon: Icon(Icons.chevron_right, color: primaryBlue),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
              weekendStyle: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
            ),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) => _buildCalendarDayNode(day, dailyTakenMap, expectedPerDay, startDate, today),
              todayBuilder: (context, day, focusedDay) => _buildCalendarDayNode(day, dailyTakenMap, expectedPerDay, startDate, today, isToday: true),
              outsideBuilder: (context, day, focusedDay) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarDayNode(DateTime day, Map<DateTime, int> dailyTakenMap, int expectedPerDay, DateTime startDate, DateTime today, {bool isToday = false}) {
    final cleanDay = DateTime(day.year, day.month, day.day);

    Color circleColor = Colors.transparent;
    Color textColor = darkText;
    Widget? innerWidget;

    if (cleanDay.isBefore(startDate)) {
      textColor = Colors.grey.withOpacity(0.4);
    } else if (cleanDay.isAfter(today)) {
      circleColor = bgLightBlue;
      textColor = Colors.black54;
    } else {
      final takenCount = dailyTakenMap[cleanDay] ?? 0;

      if (takenCount >= expectedPerDay) {
        // Tuntas 100% minum obat hari itu
        circleColor = accentGreen;
        textColor = bgWhite;
        innerWidget = const Icon(Icons.check, color: bgWhite, size: 14);
      } else if (takenCount > 0) {
        // Bolong parsial (misal: jadwal 2x, baru minum 1x)
        circleColor = Colors.redAccent;
        textColor = bgWhite;
        innerWidget = const Icon(Icons.close, color: bgWhite, size: 14);
      } else {
        // Lupa minum sama sekali
        if (isToday) {
          circleColor = primaryBlue.withOpacity(0.2);
          textColor = primaryBlue;
        } else {
          circleColor = Colors.redAccent;
          textColor = bgWhite;
          innerWidget = const Icon(Icons.close, color: bgWhite, size: 14);
        }
      }
    }

    return Container(
      margin: const EdgeInsets.all(5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: circleColor,
        shape: BoxShape.circle,
        border: isToday ? Border.all(color: primaryBlue, width: 1.5) : null,
      ),
      child: innerWidget ?? Text(
        '${day.day}',
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }

  Widget _buildMonthlyStatsCard(double compliance) {
    String evaluationText = 'Sangat Baik!';
    if (compliance < 80) evaluationText = 'Perlu Ditingkatkan!';
    if (compliance < 60) evaluationText = 'Waspada!';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kepatuhan Minum Obat',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: darkText),
                ),
                const SizedBox(height: 12),
                Text(
                  '${compliance.toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: darkText),
                ),
                const SizedBox(height: 2),
                Text(
                  evaluationText,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: accentGreen),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    height: 6,
                    width: 140,
                    color: bgLightBlue,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: compliance / 100,
                        child: Container(color: accentGreen),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.star, color: accentOrange, size: 54),
          ),
        ],
      ),
    );
  }
}