import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_filex/open_filex.dart';
import '../dashboard/dashboard_view.dart'; // Mengambil konstanta warna utama seperti primaryBlue, darkText, bgWhite, dll.

class EducationView extends StatefulWidget {
  const EducationView({super.key});

  @override
  State<EducationView> createState() => _EducationViewState();
}

class _EducationViewState extends State<EducationView> {
  final PageController _carouselController = PageController(viewportFraction: 0.85);
  String _selectedCategory = 'Semua';

  // Data Edukasi Lokal (Offline-first)
  final List<Map<String, dynamic>> _educationData = [
    {
      'id': 'pdf_1',
      'type': 'PDF',
      'category': 'Panduan',
      'title': 'Buku Saku Pasien TB Resistan Obat',
      'subtitle': 'Kemenkes RI 2024',
      'description': 'Panduan resmi mengenai cara menjalani pengobatan TB-RO, efek samping, dan tips psikologis agar berhasil sembuh.',
      'tag': 'Wajib Baca',
      'color': const Color(0xFFEFF6FF),
      'iconColor': primaryBlue,
      'icon': Icons.picture_as_pdf_rounded,
      'assetPath': 'assets/pdf/buku_saku_tb.pdf',
    },
    {
      'id': 'img_1',
      'type': 'Gambar',
      'category': 'Leaflet',
      'title': 'Mengenal Ragam Tuberkulosis (TBC)',
      'subtitle': 'Infografis Edukasi',
      'description': 'Leaflet visual taktis mengenai cara penularan TBC, gejala utama, dan pentingnya patuh minum OAT.',
      'tag': 'Visual',
      'color': const Color(0xFFFFF7ED),
      'iconColor': accentOrange,
      'icon': Icons.collections_rounded,
      'assetPath': 'assets/images/leaflet_gejala_tb.jpeg',
    },
    {
      'id': 'art_1',
      'type': 'Artikel',
      'category': 'Tips',
      'title': 'Nutrisi Tepat Pendukung Kesembuhan',
      'subtitle': 'Artikel 3 Menit',
      'description': 'Daftar makanan tinggi protein dan vitamin yang membantu mempercepat regenerasi jaringan paru selama pengobatan.',
      'tag': 'Tips Gizi',
      'color': const Color(0xFFF0FDF4),
      'iconColor': Colors.green,
      'icon': Icons.article_rounded,
      'assetPath': '', // Artikel murni teks offline
    },
  ];

  Future<void> _launchWhatsApp() async {
    const phoneNumber = '6282116864170';
    const message = 'Halo Admin TBC Care, saya membutuhkan informasi lebih lanjut mengenai program pengobatan terapi saya.';

    // Menggunakan skema whatsapp:// send lebih agresif memanggil aplikasi native
    final nativeUrl = Uri.parse('whatsapp://send?phone=$phoneNumber&text=${Uri.encodeComponent(message)}');
    final webUrl = Uri.parse('https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}');

    try {
      // Langsung coba buka aplikasi WhatsApp native di HP
      await launchUrl(nativeUrl, mode: LaunchMode.externalApplication);
    } catch (e) {
      // Jika gagal/tidak ada WA native, lempar ke browser web agar tidak freeze
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    }
  }

  // Aksi penanganan buka dokumen nyata setelah lolos dari pop-up preview
  void _handleOpenContent(Map<String, dynamic> item) async {
    Navigator.of(context, rootNavigator: true).pop(); // Tutup dialog preview terlebih dahulu

    // 1. JIKA KONTEN ADALAH GAMBAR / LEAFLET (Buka di internal dengan Zoom)
    if (item['type'] == 'Gambar') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: Text(item['title'], style: const TextStyle(color: bgWhite, fontSize: 16, fontWeight: FontWeight.bold)),
              backgroundColor: darkText,
              iconTheme: const IconThemeData(color: bgWhite),
            ),
            backgroundColor: Colors.black,
            body: Center(
              child: InteractiveViewer(
                maxScale: 4.0,
                child: Image.asset(
                  item['assetPath'],
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Text('Gagal memuat gambar offline.\nPastikan file ada di assets/images/',
                          textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );
    }
    // 2. JIKA KONTEN ADALAH ARTIKEL TEKS (Buka di internal sebagai Widget teks biasa)
    else if (item['type'] == 'Artikel') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Artikel Kesehatan', style: TextStyle(color: bgWhite, fontWeight: FontWeight.bold, fontSize: 16)),
              backgroundColor: primaryBlue,
              iconTheme: const IconThemeData(color: bgWhite),
            ),
            body: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(item['subtitle'].toUpperCase(), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5)),
                const SizedBox(height: 6),
                Text(item['title'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: darkText)),
                const Divider(height: 32, color: Colors.black12),
                Text(
                  '${item['description']}\n\n'
                      'Asupan nutrisi yang optimal memegang peranan vital dalam proses regenerasi makrofag dan pemulihan jaringan parenkim paru yang terdampak bakteri Mycobacterium tuberculosis.\n\n'
                      'Pasien sangat dianjurkan mengonsumsi asupan tinggi protein seperti putih telur, ikan, atau dada ayam guna mencegah penyusutan massa otot (wasting) akibat efek kronis infeksi TBC. '
                      'Sinergi diet sehat dan kepatuhan minum obat secara teratur adalah kunci mutlak menuju kesembuhan total.',
                  style: const TextStyle(fontSize: 15, height: 1.6, color: darkText),
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
        ),
      );
    }
    // 3. JIKA KONTEN ADALAH PDF BOOKLET (SOLUSI: Dilempar Instan ke Aplikasi Luar HP)
    else if (item['type'] == 'PDF') {
      // Tampilkan dialog loading melingkar kecil di layar
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final tempDir = await getTemporaryDirectory();
        final path = '${tempDir.path}/Buku_Saku_Pasien_TB.pdf';
        final file = File(path);

        // Hanya salin byte dari aset apabila file fisik belum pernah dibuat sebelumnya di HP
        if (!await file.exists()) {
          final bd = await DefaultAssetBundle.of(context).load(item['assetPath']);
          final bytes = bd.buffer.asUint8List();
          await file.writeAsBytes(bytes, flush: true);
        }

        // Tutup dialog loading secara aman
        if (mounted) Navigator.pop(context);

        // Buka file PDF menggunakan aplikasi PDF Reader internal HP user
        final result = await OpenFilex.open(path);

        if (result.type != ResultType.done && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tidak ditemukan aplikasi pendukung untuk membuka PDF: ${result.message}')),
          );
        }
      } catch (e) {
        if (mounted) Navigator.pop(context); // Tutup loading jika terjadi error skrip
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memproses data file: $e')),
          );
        }
      }
    }
  }

  // Dialog Preview Konten Interaktif
  void _openContentPreview(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Card Dialog
            Container(
              padding: const EdgeInsets.all(20),
              color: item['iconColor'].withOpacity(0.1),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: item['iconColor'],
                    foregroundColor: Colors.white,
                    radius: 18,
                    child: Icon(item['icon'], size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['type'], style: TextStyle(color: item['iconColor'], fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5)),
                        Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: darkText), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  )
                ],
              ),
            ),

            // Deskripsi Singkat Abstraksi Aset
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(item['description'], style: const TextStyle(fontSize: 13, color: Colors.black54, height: 1.5), textAlign: TextAlign.justify),
                  const SizedBox(height: 20),

                  // Tombol Utama Eksekusi Pembacaan Offline
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: item['iconColor'],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: () => _handleOpenContent(item),
                      child: Text('BUKA ${item['type'].toUpperCase()} SEKARANG', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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

  @override
  Widget build(BuildContext context) {
    final filteredData = _selectedCategory == 'Semua'
        ? _educationData
        : _educationData.where((element) => element['type'] == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: bgLightBlue,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER UTAMA
          Container(
            width: double.infinity,
            color: primaryBlue,
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pusat Edukasi TBC', style: TextStyle(color: bgWhite, fontWeight: FontWeight.bold, fontSize: 22)),
                SizedBox(height: 4),
                Text('Materi terverifikasi medis, dapat diakses tanpa kuota internet.', style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),

          // 2. FILTER STRIP INTERAKTIF
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Row(
              children: ['Semua', 'PDF', 'Gambar', 'Artikel'].map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: darkText,
                    labelStyle: TextStyle(color: isSelected ? bgWhite : darkText, fontWeight: FontWeight.bold, fontSize: 12),
                    backgroundColor: bgWhite,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    onSelected: (val) => setState(() => _selectedCategory = cat),
                  ),
                );
              }).toList(),
            ),
          ),

          // 3. INTERACTIVE CAROUSEL SWIPE PREVIEW
          Expanded(
            child: filteredData.isEmpty
                ? const Center(child: Text('Konten belum tersedia'))
                : PageView.builder(
              controller: _carouselController,
              itemCount: filteredData.length,
              itemBuilder: (context, index) {
                final item = filteredData[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: Card(
                    color: bgWhite,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                      side: BorderSide(color: Colors.black.withOpacity(0.03)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        _openContentPreview(context, item);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(color: item['color'], borderRadius: BorderRadius.circular(12)),
                                  child: Text(item['tag'], style: TextStyle(color: item['iconColor'], fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                                Icon(item['icon'], color: item['iconColor'].withOpacity(0.7), size: 28),
                              ],
                            ),
                            const Spacer(),
                            Text(item['subtitle'].toUpperCase(), style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1)),
                            const SizedBox(height: 6),
                            Text(item['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText, height: 1.3)),
                            const SizedBox(height: 10),
                            Text(item['description'], maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black54, fontSize: 13, height: 1.45)),
                            const Spacer(),
                            Row(
                              children: [
                                Text('Ketuk untuk Preview', style: TextStyle(color: item['iconColor'], fontSize: 12, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 4),
                                Icon(Icons.arrow_forward_rounded, color: item['iconColor'], size: 14),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 4. TOMBOL PANGGILAN WHATSAPP PMO / OPERATOR
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                    child: const Icon(Icons.chat_bubble_rounded, color: bgWhite, size: 20),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Butuh Bantuan Klinis?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: darkText)),
                        Text('Hubungi langsung Operator/PMO via WhatsApp', style: TextStyle(fontSize: 11, color: Colors.black54)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: bgWhite,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _launchWhatsApp,
                    child: const Text('TANYA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}