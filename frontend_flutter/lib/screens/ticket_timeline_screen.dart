import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme/app_colors.dart';
import '../data/models/solvexa_models.dart';
import '../providers/solvexa_provider.dart';
import '../widgets/solvexa_navigation.dart';

/// Layar Pelacakan Status Laporan (`Status Laporan - Timeline.png` - PRD Bagian 4.6)
/// Mencakup:
/// - Baris Navigasi Atas (`<- Kembali`, badge kuning `PRIORITAS TINGGI`, tombol share)
/// - Kartu Header Tiket (`ID: #SLV-001`, `Aset: PC-LAB3`, `4 Nov 2026, 09:15`, `Hardware (PC / Monitor)`,
///   `Lab Komputer 3 • Gedung B, Lantai 2`, kotak `GEJALA MASALAH`)
/// - Kartu Alur Penanganan (Stepper Vertikal 3 tahap: `Dilaporkan`, `Diproses Teknisi` + kontak Hendra Pratama, `Selesai`)
/// - Kartu Catatan Lapangan Teknisi (`field_note`, `Diperbarui: 09:22 WIB`, `Kirim Pesan`)
/// - Tombol Aksi Bawah: `Tambah Bukti` & `Segarkan Status` (membuka simulasi Teknisi Operasional untuk memajukan status)
class TicketTimelineScreen extends StatefulWidget {
  final TicketModel? initialTicket;

  const TicketTimelineScreen({super.key, this.initialTicket});

  @override
  State<TicketTimelineScreen> createState() => _TicketTimelineScreenState();
}

class _TicketTimelineScreenState extends State<TicketTimelineScreen> {
  late TicketModel _currentTicket;

  @override
  void initState() {
    super.initState();
    _currentTicket = widget.initialTicket ??
        const TicketModel(
          id: 1,
          ticketNumber: '#SLV-001',
          assetCode: 'PC-LAB3',
          assetName: 'PC Workstation Lab 3 #14',
          category: 'Hardware (PC / Monitor)',
          categorySubtitle: 'Unit CPU, layar monitor, periferal',
          buildingLocation: 'Lab Komputer 3 • Gedung B, Lantai 2',
          roomDetail: 'Gedung Riset Sains • Lab 3 (Meja 14)',
          description:
              'Monitor blank hitam berulang & indikator kipas PSU berbunyi keras.',
          urgency: 'Darurat',
          priorityLabel: 'PRIORITAS TINGGI',
          status: 'Diproses Teknisi',
          photoPaths: ['monitor_freeze_error.jpg'],
          technicianName: 'Hendra Pratama',
          technicianUnit: 'Divisi Sarpras & Lab IT',
          technicianPhone: '+6281299003344',
          estimatedResponse: 'Maks. 15-30 Menit',
          estimatedCompletion: '~25 MENIT',
          fieldNote:
              'Sedang dilakukan pengecekan kabel daya dan komponen GPU. Indikasi awal thermal throttling atau kabel PCIe kendor. Akan dilakukan pergantian pasta pendingin.',
          fieldNoteUpdatedAt: '09:22 WIB',
          reportedAt: '4 Nov 2026, 09:15',
          processedAt: '4 Nov 2026, 09:20',
        );
  }

  Future<void> _addMoreEvidencePhoto() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      final newFile = picked?.name ?? 'bukti_tambahan_${_currentTicket.photoPaths.length + 1}.jpg';
      final updatedPhotos = [..._currentTicket.photoPaths, newFile];
      final provider = context.read<SolvexaProvider>();
      final updated = await provider.advanceOrUpdateTicketStatus(
        ticket: _currentTicket,
        targetStatus: _currentTicket.status,
        updatedPhotos: updatedPhotos,
      );
      if (mounted) {
        setState(() => _currentTicket = updated);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bukti foto "$newFile" berhasil ditambahkan ke tiket.')),
        );
      }
    } catch (_) {}
  }

  void _openTechnicianSimulationModal() {
    final noteController = TextEditingController(text: _currentTicket.fieldNote);
    final estController = TextEditingController(text: _currentTicket.estimatedCompletion);
    String selectedStatus = _currentTicket.status;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: SolvexaColors.accentAmberSoft,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.engineering_rounded,
                          color: Color(0xFFB45309),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Simulasi Teknisi Operasional (Demo)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: SolvexaColors.textHeading,
                              ),
                            ),
                            Text(
                              'Ubah status tiket & catatan lapangan di SQLite lokal',
                              style: TextStyle(
                                fontSize: 12,
                                color: SolvexaColors.textSub,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Pilih Status Penanganan:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: SolvexaColors.textHeading,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['Dilaporkan', 'Diproses Teknisi', 'Selesai'].map((st) {
                      final active = selectedStatus == st;
                      return ChoiceChip(
                        label: Text(st),
                        selected: active,
                        selectedColor: SolvexaColors.accentAmber,
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: active ? SolvexaColors.primaryNavy : SolvexaColors.textSub,
                        ),
                        onSelected: (_) => setModalState(() => selectedStatus = st),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: estController,
                    decoration: InputDecoration(
                      labelText: 'Estimasi Waktu Penanganan',
                      filled: true,
                      fillColor: SolvexaColors.secondarySurface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: noteController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Catatan Lapangan Teknisi (field_note)',
                      filled: true,
                      fillColor: SolvexaColors.secondarySurface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final provider = context.read<SolvexaProvider>();
                        final updated = await provider.advanceOrUpdateTicketStatus(
                          ticket: _currentTicket,
                          targetStatus: selectedStatus,
                          customFieldNote: noteController.text,
                          customEstimation: estController.text,
                        );
                        if (mounted) {
                          setState(() => _currentTicket = updated);
                        }
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                      icon: const Icon(Icons.save_outlined),
                      label: const Text(
                        'Simpan Pembaruan Teknisi ke SQLite',
                        style: TextStyle(fontWeight: FontWeight.w800),
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

  @override
  Widget build(BuildContext context) {
    final isProcessingOrDone =
        _currentTicket.status == 'Diproses Teknisi' || _currentTicket.status == 'Selesai';
    final isDone = _currentTicket.status == 'Selesai';

    return Scaffold(
      backgroundColor: SolvexaColors.background,
      appBar: const SolvexaTopAppBar(title: 'Home'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Baris Navigasi Atas: <- Kembali | PRIORITAS TINGGI | Share
            Row(
              children: [
                InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.arrow_back_rounded,
                          size: 16,
                          color: SolvexaColors.primaryNavy,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Kembali',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: SolvexaColors.primaryNavy,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: SolvexaColors.accentAmber,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'PRIORITAS TINGGI',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: SolvexaColors.primaryNavy,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Tautan pelacakan tiket ${_currentTicket.ticketNumber} disalin.',
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEEF2FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.share_outlined,
                      size: 17,
                      color: SolvexaColors.primaryNavy,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Kartu Header Tiket
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: SolvexaColors.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: SolvexaColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'ID: ${_currentTicket.ticketNumber}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: SolvexaColors.primaryNavy,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: SolvexaColors.textSub,
                          ),
                          children: [
                            const TextSpan(text: 'Aset: '),
                            TextSpan(
                              text: _currentTicket.assetCode,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: SolvexaColors.textHeading,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: SolvexaColors.textSub,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _currentTicket.reportedAt,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: SolvexaColors.textSub,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _currentTicket.category,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: SolvexaColors.textHeading,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.apartment_rounded,
                        size: 16,
                        color: Color(0xFF92400E),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _currentTicket.buildingLocation,
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: SolvexaColors.textSub,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: SolvexaColors.primaryNavy,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.desktop_windows_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'GEJALA MASALAH',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                  color: SolvexaColors.textSub,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _currentTicket.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  color: SolvexaColors.textHeading,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Kartu Alur Penanganan (Stepper Vertikal)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: SolvexaColors.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: SolvexaColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Alur Penanganan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: SolvexaColors.textHeading,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: SolvexaColors.successBadgeBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'ESTIMASI: ${_currentTicket.estimatedCompletion}',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF047857),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // STEP 1: Dilaporkan (09:15 WIB)
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: SolvexaColors.successGreen.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Container(
                                  width: 22,
                                  height: 22,
                                  decoration: const BoxDecoration(
                                    color: SolvexaColors.successGreen,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check_rounded,
                                    size: 15,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                width: 2.5,
                                color: SolvexaColors.successGreen,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Text(
                                      'Dilaporkan',
                                      style: TextStyle(
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.w800,
                                        color: SolvexaColors.textHeading,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      '09:15 WIB',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: SolvexaColors.textSub,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Tiket berhasil dibuat oleh sivitas akademika via Solvexa Mobile',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: SolvexaColors.textSub,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.verified_user_outlined,
                                      size: 14,
                                      color: Color(0xFF92400E),
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      'Terverifikasi Otomatis Sistem',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF92400E),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // STEP 2: Diproses Teknisi (Sedang Dikerjakan)
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: isProcessingOrDone
                                    ? SolvexaColors.primaryNavy
                                    : SolvexaColors.secondarySurface,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.engineering_rounded,
                                color: isProcessingOrDone
                                    ? Colors.white
                                    : SolvexaColors.textMuted,
                                size: 20,
                              ),
                            ),
                            Expanded(
                              child: Container(
                                width: 2,
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                color: isDone
                                    ? SolvexaColors.successGreen
                                    : SolvexaColors.borderLight,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'Diproses Teknisi',
                                      style: TextStyle(
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.w800,
                                        color: SolvexaColors.textHeading,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: SolvexaColors.accentAmber,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Text(
                                        isDone
                                            ? '• Selesai Dikerjakan'
                                            : '• Sedang Dikerjakan',
                                        style: const TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w800,
                                          color: SolvexaColors.primaryNavy,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Teknisi Bpk. Hendra sedang menuju lokasi dan memeriksa perangkat.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: SolvexaColors.textHeading,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Kartu Kontak Teknisi Hendra Pratama
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEF2FF),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    children: [
                                      const CircleAvatar(
                                        radius: 20,
                                        backgroundColor: SolvexaColors.primaryNavy,
                                        child: Text(
                                          'HP',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Hendra Pratama',
                                              style: TextStyle(
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.w800,
                                                color: SolvexaColors.textHeading,
                                              ),
                                            ),
                                            Text(
                                              'Divisi Sarpras & Lab IT',
                                              style: TextStyle(
                                                fontSize: 11.5,
                                                color: SolvexaColors.textSub,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          final uri = Uri.parse(
                                            'tel:${_currentTicket.technicianPhone}',
                                          );
                                          if (await canLaunchUrl(uri)) {
                                            await launchUrl(uri);
                                          }
                                        },
                                        child: Container(
                                          width: 36,
                                          height: 36,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.call_outlined,
                                            size: 18,
                                            color: SolvexaColors.primaryNavy,
                                          ),
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
                  ),

                  // STEP 3: Selesai (Menunggu / Tuntas)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isDone
                              ? SolvexaColors.successBadgeBg
                              : const Color(0xFFEEF2FF),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle_outline_rounded,
                          color: isDone
                              ? SolvexaColors.successGreen
                              : SolvexaColors.textMuted,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Selesai',
                                  style: TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w800,
                                    color: isDone
                                        ? SolvexaColors.textHeading
                                        : SolvexaColors.textSub,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isDone ? 'Terverifikasi' : 'Menunggu',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDone
                                        ? SolvexaColors.successGreen
                                        : SolvexaColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Perbaikan tuntas, uji kelayakan benchmark, & konfirmasi verifikasi dari pelapor.',
                              style: TextStyle(
                                fontSize: 13,
                                color: SolvexaColors.textSub,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Kartu Catatan Lapangan Teknisi
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6FB),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.sticky_note_2_outlined,
                        color: Color(0xFF92400E),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Catatan Lapangan Teknisi',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: SolvexaColors.textHeading,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '“${_currentTicket.fieldNote}”',
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontStyle: FontStyle.italic,
                      color: SolvexaColors.textSub,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Diperbarui: ${_currentTicket.fieldNoteUpdatedAt}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: SolvexaColors.textSub,
                        ),
                      ),
                      InkWell(
                        onTap: _openTechnicianSimulationModal,
                        child: const Row(
                          children: [
                            Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 15,
                              color: SolvexaColors.primaryNavy,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Kirim Pesan',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: SolvexaColors.primaryNavy,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tombol Aksi Bawah: Tambah Bukti & Segarkan Status
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: _addMoreEvidencePhoto,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: SolvexaColors.primaryNavy,
                        side: const BorderSide(color: SolvexaColors.borderLight),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.camera_alt_outlined, size: 19),
                      label: const Text(
                        'Tambah Bukti',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _openTechnicianSimulationModal,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SolvexaColors.primaryNavy,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.refresh_rounded, size: 19),
                      label: const Text(
                        'Segarkan Status',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: SolvexaBottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          context.read<SolvexaProvider>().setTabIndex(index);
          Navigator.popUntil(context, (route) => route.isFirst);
        },
      ),
    );
  }
}
