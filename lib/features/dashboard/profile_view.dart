import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../main.dart';
import '../../models/patient_profile.dart';
import '../../models/medication_record.dart';
import '../../core/database/medication_repository.dart';
import '../dashboard/dashboard_view.dart'; // Mengambil konstanta warna utama
import '../history/schedule_view.dart';  // Mengambil provider allRecordsProvider
import 'edit_schedule_view.dart' hide bgLightBlue, primaryBlue, bgWhite, accentGreen, darkText;

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  void _showEditDurationDialog(BuildContext context, WidgetRef ref, PatientProfile profile) {
    final controller = TextEditingController(text: profile.totalTreatmentDays.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Durasi Pengobatan (Hari)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Misal: 180',
            suffixText: 'Hari',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('BATAL', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              foregroundColor: bgWhite,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              final days = int.tryParse(controller.text) ?? profile.totalTreatmentDays;
              profile.totalTreatmentDays = days;

              final repo = ref.read(medicationRepoProvider);
              await repo.updatePatientProfile(profile);
              ref.invalidate(patientProfileProvider);

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: const Text('Durasi masa pengobatan berhasil diperbarui!'), backgroundColor: accentGreen),
                );
              }
            },
            child: const Text('SIMPAN'),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk menampilkan pilihan Regimen Klinis secara dinamis
  void _showRegimenSelectionBottomSheet(BuildContext context, WidgetRef ref, PatientProfile profile) {
    final categories = ['Fase Intensif', 'Fase Lanjutan'];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Penyesuaian Regimen Klinis',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText),
              ),
              const SizedBox(height: 4),
              const Text(
                'Pilih kategori regimen baru sesuai dengan arahan atau resep terbaru dari dokter Anda.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // Render daftar opsi kategori regimen
              ...categories.map((category) {
                final isSelected = profile.regimenCategory == category;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryBlue.withOpacity(0.08) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? primaryBlue : Colors.black12,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: ListTile(
                    onTap: () async {
                      // 1. Update data pada objek profil
                      profile.regimenCategory = category;

                      // 2. Simpan perubahan ke Isar Database via Repository
                      final repo = ref.read(medicationRepoProvider);
                      await repo.updatePatientProfile(profile);

                      // 3. Invalidasi provider agar dashboard & profile langsung re-render otomatis
                      ref.invalidate(patientProfileProvider);

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Regimen klinis berhasil diubah ke $category'),
                            backgroundColor: accentGreen,
                          ),
                        );
                      }
                    },
                    title: Text(
                      category,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? primaryBlue : darkText,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded, color: primaryBlue)
                        : const Icon(Icons.circle_outlined, color: Colors.grey),
                  ),
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // Helper untuk memicu pop-up edit jadwal (bisa dikembangkan ke halaman edit khusus)
  void _showEditScheduleDialog(BuildContext context, PatientProfile profile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.edit_calendar_rounded, color: primaryBlue),
            SizedBox(width: 8),
            Text('Sesuaikan Jadwal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Fitur penyesuaian jam minum obat dan perubahan kategori regimen via Dokter/PMO sedang disiapkan.',
          style: TextStyle(color: Colors.black54, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('MENGERTI', style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(patientProfileProvider);
    final recordsAsync = ref.watch(allRecordsProvider);

    return profileAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: primaryBlue)),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (profile) {
        if (profile == null) return const Center(child: Text('Profil tidak ditemukan'));

        return recordsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: primaryBlue)),
          error: (err, _) => Center(child: Text('Error: $err')),
          data: (records) {
            // Filter hanya rekaman yang memiliki lampiran foto lokal sah
            final photoRecords = records
                .where((r) => r.imagePath != null && r.imagePath!.isNotEmpty)
                .toList().reversed.toList();

            return DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  // HEADER PROFILE & KARTU NAMA
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: primaryBlue,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: bgWhite, shape: BoxShape.circle),
                              child: CircleAvatar(
                                radius: 36,
                                backgroundColor: bgLightBlue,
                                child: Text(
                                  profile.fullName.substring(0, 2).toUpperCase(),
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryBlue),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profile.fullName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: bgWhite),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'NIK: ${profile.nik}',
                                    style: TextStyle(color: bgWhite.withOpacity(0.8), fontSize: 13),
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(color: bgWhite.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                                    child: Text(
                                      profile.regimenCategory,
                                      style: TextStyle(color: bgWhite, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // TAB BAR UNTUK MEMISAHKAN PANEL PENGATURAN VS GALERI FOTO
                  Container(
                    color: bgLightBlue,
                    child: const TabBar(
                      labelColor: primaryBlue,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: primaryBlue,
                      indicatorWeight: 3,
                      tabs: [
                        Tab(icon: Icon(Icons.tune_rounded), text: 'Pengaturan & Medis'),
                        Tab(icon: Icon(Icons.collections_rounded), text: 'Galeri Foto Obat'),
                      ],
                    ),
                  ),

                  // KONTEN UTAMA TAB VIEW
                  Expanded(
                    child: Container(
                      color: bgLightBlue,
                      child: TabBarView(
                        children: [
                          // TAB 1: PENGATURAN REGIMEN & INFO PRIBADI
                          ListView(
                            padding: const EdgeInsets.all(20),
                            children: [
                              // Kelompok 1: Manajemen Regimen & Waktu Obat
                              _buildSectionTitle('Manajemen Terapi & Pengaturan'),
                              const SizedBox(height: 8),
                              _buildMenuTile(
                                title: 'Atur Ulang Jadwal Minum Obat',
                                subtitle: '${profile.schedules.length} Alarm aktif setiap hari',
                                icon: Icons.alarm_rounded,
                                iconColor: accentOrange,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditScheduleView(profile: profile),
                                    ),
                                  );
                                },
                              ),
                              _buildMenuTile(
                                title: 'Penyesuaian Regimen Klinis',
                                subtitle: 'Kategori: ${profile.regimenCategory}',
                                icon: Icons.healing_rounded,
                                iconColor: primaryBlue,
                                onTap: () => _showRegimenSelectionBottomSheet(context, ref, profile),
                              ),
                              _buildMenuTile(
                                title: 'Durasi Masa Pengobatan',
                                subtitle: 'Target pengobatan: ${profile.totalTreatmentDays} Hari',
                                icon: Icons.calendar_month_rounded,
                                iconColor: accentGreen,
                                onTap: () => _showEditDurationDialog(context, ref, profile),
                              ),

                              const SizedBox(height: 20),

                              // Kelompok 2: Informasi Data Instansi Faskes Pendamping
                              _buildSectionTitle('Fasilitas Kesehatan & Pengawas'),
                              const SizedBox(height: 8),
                              _buildInfoCard(
                                label: 'Puskesmas Pembina',
                                value: profile.puskesmasName,
                                icon: Icons.local_hospital_outlined,
                              ),
                              _buildInfoCard(
                                label: 'Nama PMO (Pengawas Menelan Obat)',
                                value: profile.pmoName,
                                icon: Icons.assignment_ind_outlined,
                              ),
                              _buildInfoCard(
                                label: 'Nomor HP Terdaftar',
                                value: profile.phoneNumber,
                                icon: Icons.phone_android_rounded,
                              ),
                            ],
                          ),

                          // TAB 2: GALERI DOKUMENTASI FOTO KONFIRMASI (GRID VIEW)
                          photoRecords.isEmpty
                              ? _buildEmptyGalleryState()
                              : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3, // 3 kolom gambar sejajar
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 1, // Persegi kotak sempurna
                            ),
                            itemCount: photoRecords.length,
                            itemBuilder: (context, index) {
                              final record = photoRecords[index];
                              return _buildGalleryItem(context, record);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Widget Pembungkus Judul Sub-Bagian
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: darkText,
        ),
      ),
    );
  }

  // Widget Tombol Menu Interaktif
  Widget _buildMenuTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: bgWhite, borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: darkText)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
      ),
    );
  }

  // Widget Kartu Informasi Statis
  Widget _buildInfoCard({required String label, required String value, required IconData icon}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: bgWhite, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: darkText)),
              ],
            ),
          )
        ],
      ),
    );
  }

  // Item Kotak Foto Galeri beserta Logika Klik Detail Pop-up Gambar Besar
  Widget _buildGalleryItem(BuildContext context, MedicationRecord record) {
    final dateStr = DateFormat('dd MMM').format(record.takenTime ?? record.scheduledTime);
    final timeStr = DateFormat('HH:mm').format(record.takenTime ?? record.scheduledTime).replaceAll(':', '.');

    return GestureDetector(
      onTap: () => _showPhotoDetailDialog(context, record),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(record.imagePath!),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image_rounded, color: Colors.grey),
                ),
              ),
            ),
          ),
          // Label mini overlay tanggal di bawah foto agar rapi
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                ),
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
              child: Text(
                '$dateStr - $timeStr',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }

  // Dialog untuk memperbesar melihat detail foto obat dan jam minum aslinya
  void _showPhotoDetailDialog(BuildContext context, MedicationRecord record) {
    final fullDate = DateFormat('EEEE, dd MMMM yyyy', 'id').format(record.takenTime ?? record.scheduledTime);
    final fullTime = DateFormat('HH:mm').format(record.takenTime ?? record.scheduledTime).replaceAll(':', '.');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              child: Image.file(
                File(record.imagePath!),
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Bukti Dokumentasi Minum Obat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: darkText)),
                  const SizedBox(height: 6),
                  Text('🗓️ $fullDate', style: const TextStyle(fontSize: 13, color: Colors.black54)),
                  Text('⏰ Jam Konfirmasi: Pukul $fullTime WIB', style: const TextStyle(fontSize: 13, color: Colors.black54)),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(foregroundColor: bgWhite, backgroundColor: darkText, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text('TUTUP PREVIEW', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyGalleryState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 12),
          Text('Belum ada foto bukti', style: TextStyle(fontWeight: FontWeight.bold, color: darkText, fontSize: 16)),
          SizedBox(height: 4),
          Text('Foto konfirmasi minum obat Anda akan terkumpul di sini.', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}