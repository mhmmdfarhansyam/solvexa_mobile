import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../data/models/solvexa_models.dart';
import '../providers/solvexa_provider.dart';

/// Halaman Form Laporan Baru (`New Ticket` - PRD Bagian 4.4)
/// Mencakup tampilan `Form Laporan - Default` dan `Form Laporan - Dropdown Terbuka`:
/// - Kartu Identitas Aset Terpindai (`PC-LAB3`, `Terverifikasi` / `Online`, read-only lock)
/// - Dropdown Kustom Kategori Kerusakan (`*Wajib`) dengan ikon & sub-deskripsi
/// - Input Deskripsi Kendala (`0 / 250`) + kotak info contoh pengisian
/// - Unggah Foto Bukti (`image_picker`, maksimal 3 foto) + thumbnail `bukti_lab3_01.jpg`
/// - Pemilih Tingkat Urgensi (`Rendah`, `Sedang`, `Darurat`)
/// - Tombol Submit `Kirim Laporan` yang menyimpan ke SQLite (`tickets` & `notifications`)
class NewTicketScreen extends StatefulWidget {
  final CampusAsset? scannedAsset;

  const NewTicketScreen({super.key, this.scannedAsset});

  @override
  State<NewTicketScreen> createState() => _NewTicketScreenState();
}

class _NewTicketScreenState extends State<NewTicketScreen> {
  final TextEditingController _descController = TextEditingController();
  bool _isDropdownExpanded = false;
  String? _selectedCategory;
  String _selectedUrgency = 'Sedang';
  final List<String> _uploadedPhotos = [];

  static const List<Map<String, dynamic>> _categories = [
    {
      'title': 'Hardware (PC/Monitor)',
      'subtitle': 'Unit CPU, layar monitor, periferal',
      'icon': Icons.laptop_chromebook_rounded,
    },
    {
      'title': 'Fasilitas Ruang (AC/Gorden)',
      'subtitle': 'Pendingin, pencahayaan, ventilasi',
      'icon': Icons.ac_unit_rounded,
    },
    {
      'title': 'Sanitasi (Toilet/Air)',
      'subtitle': 'Wastafel, kran air, saluran',
      'icon': Icons.water_drop_outlined,
    },
  ];

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickEvidencePhoto() async {
    if (_uploadedPhotos.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maksimal 3 foto bukti dapat diunggah.')),
      );
      return;
    }
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: ImageSource.gallery);
      setState(() {
        _uploadedPhotos.add(
          file != null ? file.name : 'bukti_lab3_0${_uploadedPhotos.length + 1}.jpg',
        );
      });
    } catch (_) {
      setState(() {
        _uploadedPhotos.add('bukti_lab3_0${_uploadedPhotos.length + 1}.jpg');
      });
    }
  }

  Future<void> _submitReport(CampusAsset asset) async {
    final category = _selectedCategory ?? 'Hardware (PC/Monitor)';
    final provider = context.read<SolvexaProvider>();

    final createdTicket = await provider.submitNewTicket(
      asset: asset,
      category: category,
      description: _descController.text,
      urgency: _selectedUrgency,
      photoPaths: _uploadedPhotos.isEmpty
          ? ['monitor_freeze_error.jpg']
          : _uploadedPhotos,
    );

    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      '/ticket-success',
      arguments: createdTicket,
    );
  }

  @override
  Widget build(BuildContext context) {
    final asset = widget.scannedAsset ??
        const CampusAsset(
          id: 1,
          qrCode: 'PC-LAB3',
          assetName: 'PC Workstation Lab 3 #14',
          category: 'Hardware (PC/Monitor)',
          buildingName: 'Gedung Riset Informatika • Lt. 2',
          floorRoom: 'Lab Komputer 3 • Gedung B, Lantai 2',
          detailSpot: 'Gedung Riset Sains • Lt. 3',
          unitOwner: 'Unit TI Trilogi',
        );

    final charCount = _descController.text.length;

    return Scaffold(
      backgroundColor: SolvexaColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'New Ticket',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: SolvexaColors.textHeading,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Banner (Berubah dinamis mengikuti state Default vs Dropdown Terbuka)
            if (!_isDropdownExpanded) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: SolvexaColors.accentAmberSoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt_rounded, size: 15, color: Color(0xFF92400E)),
                    SizedBox(width: 4),
                    Text(
                      'KAMPUS PINTAR • RUANG LAB',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF92400E),
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Lengkapi detail insiden fasilitas di bawah ini agar teknisi operasional dapat segera menindaklanjuti.',
                style: TextStyle(
                  fontSize: 13.5,
                  color: SolvexaColors.textSub,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
            ] else ...[
              // Kartu LOKASI TERPILIH saat Dropdown Terbuka (Sesuai referensi Form Laporan - Dropdown Terbuka.png)
              Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: SolvexaColors.primaryNavy,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.apartment_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LOKASI TERPILIH',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: SolvexaColors.textSub,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Gedung Riset Sains • Lt. 3',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: SolvexaColors.textHeading,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: SolvexaColors.accentAmber,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Kartu 1: ID Fasilitas Terpindai
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SolvexaColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: SolvexaColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isDropdownExpanded ? 'ID Fasilitas' : 'ID Fasilitas Terpindai',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: SolvexaColors.textSub,
                        ),
                      ),
                      if (_isDropdownExpanded)
                        const Text(
                          'Terverifikasi otomatis',
                          style: TextStyle(
                            fontSize: 12,
                            color: SolvexaColors.textSub,
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: SolvexaColors.successBadgeBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_rounded,
                                size: 14,
                                color: SolvexaColors.successGreen,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Terverifikasi',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: SolvexaColors.successGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: SolvexaColors.primaryNavy,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.desktop_windows_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                asset.qrCode,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: SolvexaColors.textHeading,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                asset.buildingName,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: SolvexaColors.textSub,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_isDropdownExpanded)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: SolvexaColors.successGreen,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                const Text(
                                  'Online',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    color: SolvexaColors.textHeading,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          const Icon(
                            Icons.lock_outline_rounded,
                            color: SolvexaColors.textSub,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Kartu 2: Dropdown Kategori Kerusakan (*Wajib / Wajib dipilih)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SolvexaColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: SolvexaColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Kategori Kerusakan',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: SolvexaColors.textHeading,
                        ),
                      ),
                      Text(
                        _isDropdownExpanded ? 'Wajib dipilih' : '*Wajib',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _isDropdownExpanded
                              ? const Color(0xFFB45309)
                              : SolvexaColors.dangerRed,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isDropdownExpanded = !_isDropdownExpanded;
                        if (_isDropdownExpanded && _uploadedPhotos.isEmpty) {
                          _uploadedPhotos.add('bukti_lab3_01.jpg');
                          _selectedCategory ??= 'Hardware (PC/Monitor)';
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: SolvexaColors.secondarySurface,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          if (_isDropdownExpanded) ...[
                            const Icon(
                              Icons.category_outlined,
                              size: 20,
                              color: SolvexaColors.primaryNavy,
                            ),
                            const SizedBox(width: 10),
                          ],
                          Expanded(
                            child: Text(
                              _selectedCategory ?? 'Pilih Kategori',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: _selectedCategory != null || _isDropdownExpanded
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                                color: _selectedCategory != null || _isDropdownExpanded
                                    ? SolvexaColors.textHeading
                                    : SolvexaColors.textSub,
                              ),
                            ),
                          ),
                          Icon(
                            _isDropdownExpanded
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: SolvexaColors.textHeading,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Daftar Pilihan Kustom saat Dropdown Terbuka
                  if (_isDropdownExpanded) ...[
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: SolvexaColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: SolvexaColors.borderLight),
                      ),
                      child: Column(
                        children: _categories.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final item = entry.value;
                          final isSelected =
                              (_selectedCategory ?? 'Hardware (PC/Monitor)') ==
                                  item['title'];
                          return Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedCategory = item['title'] as String;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEEF2FF),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          item['icon'] as IconData,
                                          color: SolvexaColors.primaryNavy,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['title'] as String,
                                              style: const TextStyle(
                                                fontSize: 14.5,
                                                fontWeight: FontWeight.w800,
                                                color: SolvexaColors.textHeading,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              item['subtitle'] as String,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: SolvexaColors.textSub,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isSelected)
                                        const Icon(
                                          Icons.check_circle_outline_rounded,
                                          color: SolvexaColors.accentAmber,
                                          size: 24,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              if (idx < _categories.length - 1)
                                const Divider(
                                  height: 1,
                                  indent: 14,
                                  endIndent: 14,
                                  color: SolvexaColors.borderLight,
                                ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Kartu 3: Input Deskripsi Kendala (0 / 250)
            if (!_isDropdownExpanded) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SolvexaColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: SolvexaColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Deskripsi Kendala',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: SolvexaColors.textHeading,
                          ),
                        ),
                        Text(
                          '$charCount / 250',
                          style: const TextStyle(
                            fontSize: 12,
                            color: SolvexaColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _descController,
                      maxLength: 250,
                      maxLines: 3,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        counterText: '',
                        hintText:
                            'Jelaskan detail kendala atau kerusakan yang dialami...',
                        hintStyle: const TextStyle(
                          color: SolvexaColors.textMuted,
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 16,
                          color: Color(0xFFB45309),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Contoh: Monitor tidak menyala, kipas PSU berbunyi keras.',
                            style: TextStyle(
                              fontSize: 12,
                              color: SolvexaColors.textSub,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Kartu 4: Unggah Foto Bukti (Mendukung tampilan Default & Thumbnail Terpilih)
            if (_uploadedPhotos.isEmpty && !_isDropdownExpanded)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SolvexaColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: SolvexaColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Unggah Foto Bukti',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: SolvexaColors.textHeading,
                          ),
                        ),
                        Text(
                          'Opsional',
                          style: TextStyle(
                            fontSize: 12,
                            color: SolvexaColors.textSub,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: _pickEvidencePhoto,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF).withOpacity(0.75),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: const BoxDecoration(
                                color: SolvexaColors.accentAmberSoft,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add_a_photo_outlined,
                                color: Color(0xFF92400E),
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Ketuk untuk Mengunggah Foto',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: SolvexaColors.textHeading,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Format JPG, PNG maks. 5MB',
                              style: TextStyle(
                                fontSize: 12,
                                color: SolvexaColors.textSub,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF).withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline_rounded,
                            size: 18,
                            color: SolvexaColors.primaryNavy,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Foto label seri atau layar error untuk mempermudah teknisi.',
                              style: TextStyle(
                                fontSize: 12,
                                color: SolvexaColors.textSub,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              // Tampilan 2 Kolom saat Foto Dipilih (Sesuai Form Laporan - Dropdown Terbuka.png)
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickEvidencePhoto,
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        height: 128,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: SolvexaColors.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: SolvexaColors.borderLight),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEEF2FF),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add_a_photo_outlined,
                                color: SolvexaColors.primaryNavy,
                                size: 20,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Ambil / Unggah',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: SolvexaColors.textHeading,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Maksimal 3 foto',
                              style: TextStyle(
                                fontSize: 11,
                                color: SolvexaColors.textSub,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 128,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                        ),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          const Center(
                            child: Icon(
                              Icons.desktop_windows_rounded,
                              size: 46,
                              color: Colors.white30,
                            ),
                          ),
                          Positioned(
                            left: 10,
                            right: 10,
                            bottom: 10,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    _uploadedPhotos.isNotEmpty
                                        ? _uploadedPhotos.first
                                        : 'bukti_lab3_01.jpg',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.55),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFFB45309),
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Laporan masuk akan segera dialokasikan kepada teknisi gedung yang bertugas hari ini. Mohon pastikan perangkat tidak diutak-atik lebih lanjut demi keamanan.',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: SolvexaColors.textSub,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Kartu 5: Pemilih Tingkat Urgensi (Rendah, Sedang, Darurat)
            if (!_isDropdownExpanded) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SolvexaColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: SolvexaColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tingkat Urgensi',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: SolvexaColors.textHeading,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _UrgencyOptionCard(
                          label: 'Rendah',
                          dotColor: const Color(0xFFCBD5E1),
                          selected: _selectedUrgency == 'Rendah',
                          onTap: () => setState(() => _selectedUrgency = 'Rendah'),
                        ),
                        const SizedBox(width: 10),
                        _UrgencyOptionCard(
                          label: 'Sedang',
                          dotColor: SolvexaColors.accentAmber,
                          selected: _selectedUrgency == 'Sedang',
                          onTap: () => setState(() => _selectedUrgency = 'Sedang'),
                        ),
                        const SizedBox(width: 10),
                        _UrgencyOptionCard(
                          label: 'Darurat',
                          dotColor: SolvexaColors.dangerRed,
                          selected: _selectedUrgency == 'Darurat',
                          onTap: () => setState(() => _selectedUrgency = 'Darurat'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
            ],

            // Tombol Submit Navy Penuh: Kirim Laporan
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => _submitReport(asset),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SolvexaColors.primaryNavy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Kirim Laporan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.send_rounded, size: 18),
                  ],
                ),
              ),
            ),
            if (!_isDropdownExpanded) ...[
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  'Laporan diteruskan ke Pusat Kendali Kampus • Tanggapan ± 15 Menit',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: SolvexaColors.textMuted,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _UrgencyOptionCard extends StatelessWidget {
  final String label;
  final Color dotColor;
  final bool selected;
  final VoidCallback onTap;

  const _UrgencyOptionCard({
    required this.label,
    required this.dotColor,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFEEF2FF)
                : SolvexaColors.secondarySurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? const Color(0xFFC7D2FE)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected
                      ? SolvexaColors.textHeading
                      : SolvexaColors.textSub,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
