import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // <--- IMPORT DOTENV
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../dashboard/dashboard_view.dart'; // Pastikan warna Anda (primaryBlue, darkText, bgWhite, dll) ada di sini

// ======================================================================
// RIVERPOD PROVIDER UNTUK GEMINI CHAT SESSION
// ======================================================================
final geminiChatProvider = StateNotifierProvider<GeminiChatNotifier, List<Map<String, dynamic>>>((ref) {
  return GeminiChatNotifier();
});

class GeminiChatNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  late ChatSession _chatSession;
  bool _isInitialized = false;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  GeminiChatNotifier() : super([]) {
    _initializeGemini();
  }

  void _initializeGemini() {
    // 1. Ambil API Key dari file .env secara aman
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

    if (apiKey.isEmpty) {
      debugPrint("Peringatan: GEMINI_API_KEY tidak ditemukan di file .env!");
    }

    final model = GenerativeModel(
      model: 'gemini-2.5-flash-lite', // Model super cepat dan hemat token
      apiKey: apiKey,
      systemInstruction: Content.system(
          "Anda adalah 'Asisten Virtual TBC Care', seorang pakar kesehatan digital, ramah, dan sangat ahli mengenai Tuberkulosis (TBC). "
              "Tugas utama Anda adalah menjawab pertanyaan pasien mengenai gejala TBC, efek samping obat (seperti urine merah karena Rifampisin), "
              "panduan nutrisi, pentingnya kepatuhan minum obat, dan memberikan motivasi psikologis agar pasien sembuh total. "
              "Gunakan bahasa Indonesia yang santun, jelas, menenangkan, dan mudah dipahami oleh orang awam. "
              "JANGAN MENJAWAB pertanyaan di luar topik kesehatan, medis, atau TBC. Jika ditanya di luar topik, tolak dengan sopan."
              "JAWAB DENGAN MAKSIMAL 300 KATA ATAU KURANG"
      ),
    );

    _chatSession = model.startChat();
    _isInitialized = true;

    state = [
      {
        'isBot': true,
        'text': 'Halo! Saya Asisten Virtual TBC Care yang didukung oleh AI. Ada keluhan atau pertanyaan seputar pengobatan TBC Anda hari ini? Mari kita diskusikan bersama.',
      }
    ];
  }

  Future<void> sendMessage(String text) async {
    if (!_isInitialized || text.trim().isEmpty || _isLoading) return;

    final userMessage = {'isBot': false, 'text': text.trim()};

    // Perbaikan: Set loading TRUE dan langsung masukkan pesan user ke UI
    _isLoading = true;
    state = [...state, userMessage];

    try {
      final response = await _chatSession.sendMessage(Content.text(text.trim()));

      if (response.text != null) {
        state = [
          ...state,
          {'isBot': true, 'text': response.text!}
        ];
      }
    } catch (e) {
      // Perbaikan: Cetak log error asli di terminal untuk mempermudah debugging kamu
      debugPrint("ERROR GEMINI DETECTED: $e");

      state = [
        ...state,
        {
          'isBot': true,
          'text': 'Maaf, terjadi kendala saat memproses pesan Anda. Mohon pastikan API Key di .env sudah benar atau periksa koneksi internet Anda. (Error: $e)'
        }
      ];
    } finally {
      // Perbaikan: Matikan loading dan trigger re-render UI
      _isLoading = false;
      state = [...state];
    }
  }

  void resetChat() {
    _initializeGemini();
  }
}

// ======================================================================
// VIEW UTAMA: PUSAT EDUKASI
// ======================================================================
class EducationView extends StatefulWidget {
  const EducationView({super.key});

  @override
  State<EducationView> createState() => _EducationViewState();
}

class _EducationViewState extends State<EducationView> {
  final PageController _carouselController = PageController(viewportFraction: 0.85);
  String _selectedCategory = 'Semua';

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
      'assetPath': '',
    },
  ];

  void _openTbcChatbot() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TbcGeminiChatbotView(),
      ),
    );
  }

  void _handleOpenContent(Map<String, dynamic> item) async {
    Navigator.of(context, rootNavigator: true).pop();

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
                child: Image.asset(item['assetPath'], fit: BoxFit.contain),
              ),
            ),
          ),
        ),
      );
    } else if (item['type'] == 'Artikel') {
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
                Text(item['subtitle'].toUpperCase(), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11)),
                const SizedBox(height: 6),
                Text(item['title'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: darkText)),
                const Divider(height: 32, color: Colors.black12),
                Text('${item['description']}\n\nNutrisi seimbang mempercepat penyembuhan jaringan paru akibat infeksi bakteri TBC...', style: const TextStyle(fontSize: 15, height: 1.6, color: darkText)),
              ],
            ),
          ),
        ),
      );
    } else if (item['type'] == 'PDF') {
      showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));
      try {
        final tempDir = await getTemporaryDirectory();
        final path = '${tempDir.path}/Buku_Saku_Pasien_TB.pdf';
        final file = File(path);
        if (!await file.exists()) {
          final bd = await DefaultAssetBundle.of(context).load(item['assetPath']);
          final bytes = bd.buffer.asUint8List();
          await file.writeAsBytes(bytes, flush: true);
        }
        if (mounted) Navigator.pop(context);
        await OpenFilex.open(path);
      } catch (e) {
        if (mounted) Navigator.pop(context);
      }
    }
  }

  void _openContentPreview(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              color: item['iconColor'].withOpacity(0.1),
              child: Row(
                children: [
                  CircleAvatar(backgroundColor: item['iconColor'], foregroundColor: Colors.white, radius: 18, child: Icon(item['icon'], size: 18)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: darkText),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: item['iconColor'], foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () => _handleOpenContent(item),
                child: Text('BUKA ${item['type'].toUpperCase()} SEKARANG'),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredData = _selectedCategory == 'Semua' ? _educationData : _educationData.where((element) => element['type'] == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: bgLightBlue,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Expanded(
            child: PageView.builder(
              controller: _carouselController,
              itemCount: filteredData.length,
              itemBuilder: (context, index) {
                final item = filteredData[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: Card(
                    color: bgWhite,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    child: InkWell(
                      onTap: () => _openContentPreview(context, item),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: item['color'], borderRadius: BorderRadius.circular(12)), child: Text(item['tag'], style: TextStyle(color: item['iconColor'], fontSize: 11, fontWeight: FontWeight.bold))),
                                Icon(item['icon'], color: item['iconColor'].withOpacity(0.7), size: 28),
                              ],
                            ),
                            const Spacer(),
                            Text(item['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
                            const SizedBox(height: 8),
                            Text(item['description'], maxLines: 3, style: const TextStyle(color: Colors.black54, fontSize: 13)),
                            const Spacer(),
                            Text('Ketuk untuk Preview', style: TextStyle(color: item['iconColor'], fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(20), border: Border.all(color: primaryBlue.withOpacity(0.2))),
              child: Row(
                children: [
                  Container(padding: const EdgeInsets.all(10), decoration: const BoxDecoration(color: primaryBlue, shape: BoxShape.circle), child: const Icon(Icons.auto_awesome_rounded, color: bgWhite, size: 20)),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('AI Konsultan TBC Care', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: darkText)),
                        Text('Diskusi keluhan medis & efek obat pintar via Gemini AI', style: TextStyle(fontSize: 11, color: Colors.black54)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, foregroundColor: bgWhite, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: _openTbcChatbot,
                    child: const Text('TANYA AI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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

// ======================================================================
// WIDGET INTERFAS CHAT HALAMAN CHATBOT GEMINI AI
// ======================================================================
class TbcGeminiChatbotView extends ConsumerStatefulWidget {
  const TbcGeminiChatbotView({super.key});

  @override
  ConsumerState<TbcGeminiChatbotView> createState() => _TbcGeminiChatbotViewState();
}

class _TbcGeminiChatbotViewState extends ConsumerState<TbcGeminiChatbotView> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendChatMessage() {
    final text = _inputController.text;
    if (text.trim().isEmpty) return;

    _inputController.clear();
    ref.read(geminiChatProvider.notifier).sendMessage(text).then((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(geminiChatProvider);
    final chatNotifier = ref.watch(geminiChatProvider.notifier); // Pantau notifier-nya langsung

    return Scaffold(
      backgroundColor: bgLightBlue,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome_rounded, color: bgWhite, size: 20),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Asisten Pintar TBC', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: bgWhite)),
                Text('Didukung oleh Gemini AI', style: TextStyle(fontSize: 11, color: Colors.white70)),
              ],
            )
          ],
        ),
        backgroundColor: primaryBlue,
        iconTheme: const IconThemeData(color: bgWhite),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: bgWhite),
            onPressed: () => ref.read(geminiChatProvider.notifier).resetChat(),
            tooltip: 'Reset Sesi Chat',
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final isBot = msg['isBot'] as bool;

                  return Align(
                    alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                      decoration: BoxDecoration(
                        color: isBot ? bgWhite : primaryBlue,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(isBot ? 4 : 16),
                          bottomRight: Radius.circular(isBot ? 16 : 4),
                        ),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 4, offset: const Offset(0, 2))],
                      ),
                      child: Text(
                        msg['text'],
                        style: TextStyle(color: isBot ? darkText : bgWhite, fontSize: 14, height: 1.4),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Perbaikan Indikator Loading: Sekarang menggunakan state boolean dari notifier
            if (chatNotifier.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: primaryBlue)),
                    SizedBox(width: 10),
                    Text('Asisten sedang mengetik...', style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)),
                  ],
                ),
              ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: bgWhite,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      decoration: InputDecoration(
                        hintText: 'Tanyakan keluhan atau info obat TBC...',
                        hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide(color: Colors.grey.shade300)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: primaryBlue)),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendChatMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: primaryBlue,
                    radius: 20,
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: bgWhite, size: 18),
                      onPressed: _sendChatMessage,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}