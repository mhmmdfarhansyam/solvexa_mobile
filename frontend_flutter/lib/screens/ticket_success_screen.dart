import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../data/models/solvexa_models.dart';
import '../providers/solvexa_provider.dart';

/// Layar Konfirmasi Laporan Terkirim (`Laporan Berhasil Terkirim.png` - PRD Bagian 4.5)
/// Menampilkan:
/// - Lingkaran hijau besar dengan centang putih & badge kuning `⚡ Kilat`
/// - Pill `#SLV-001 • Prioritas Normal`
/// - Judul `Laporan Berhasil Terkirim!` & sub-judul `Laporan PC-LAB3 telah masuk ke antrean teknisi kampus.`
/// - Kartu Estimasi Respon (`Maks. 15-30 Menit`, badge `Otomatis`, progress bar hijau, `Gedung Teknik Lt. 2` & `Lab Komputer B`)
/// - Kartu Teknisi Bertugas (`Bima Arya (Unit Hardware)`)
/// - Lampiran Bukti Masalah (`monitor_freeze_error.jpg` + ikon mata preview penuh)
/// - Tombol `Lacak Status Laporan` & `Kembali ke Beranda`
class TicketSuccessScreen extends StatelessWidget {
  final TicketModel? ticket;

  const TicketSuccessScreen({super.key, this.ticket});

  @override
  Widget build(BuildContext context) {
    final activeTicket = ticket ??
        context.watch<SolvexaProvider>().latestActiveTicket ??
        const TicketModel(
          id: 1,
          ticketNumber: '#SLV-001',
          assetCode: 'PC-LAB3',
          assetName: 'PC Workstation Lab 3 #14',
          category: 'Hardware (PC / Monitor)',
          categorySubtitle: 'Unit CPU, layar monitor, periferal',
          buildingLocation: 'Lab Komputer 3 • Gedung B, Lantai 2',
          roomDetail: 'Gedung Riset Sains • Lab 3 (Meja 14)',
          description: 'Monitor blank hitam berulang & indikator kipas PSU berbunyi keras.',
          urgency: 'Sedang',
          priorityLabel: 'Prioritas Normal',
          status: 'Dilaporkan',
          photoPaths: ['monitor_freeze_error.jpg'],
          technicianName: 'Bima Arya',
          technicianUnit: 'Unit Hardware',
          technicianPhone: '+6281288001122',
          estimatedResponse: 'Maks. 15-30 Menit',
          estimatedCompletion: '~25 MENIT',
          fieldNote:
              'Sedang dilakukan pengecekan kabel daya dan komponen GPU. Indikasi awal thermal throttling atau kabel PCIe kendor.',
          fieldNoteUpdatedAt: '09:22 WIB',
          reportedAt: '4 Nov 2026, 09:15',
        );

    final firstPhoto = activeTicket.photoPaths.isNotEmpty
        ? activeTicket.photoPaths.first
        : 'monitor_freeze_error.jpg';

    return Scaffold(
      backgroundColor: SolvexaColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 30),
          onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
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
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          children: [
            // Visual Sukses: Lingkaran Hijau Besar + Centang Putih + Badge Kuning ⚡ Kilat
            Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(
                      color: SolvexaColors.successGreen.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 84,
                        height: 84,
                        decoration: const BoxDecoration(
                          color: Color(0xFF059669),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 46,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: SolvexaColors.accentAmber,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.bolt_rounded,
                            size: 13,
                            color: SolvexaColors.primaryNavy,
                          ),
                          SizedBox(width: 2),
                          Text(
                            'Kilat',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: SolvexaColors.primaryNavy,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Pill Nomor Tiket (#SLV-001 • Prioritas Normal)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: SolvexaColors.accentAmber,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    activeTicket.ticketNumber,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: SolvexaColors.textHeading,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    '•',
                    style: TextStyle(color: SolvexaColors.textMuted),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    activeTicket.priorityLabel,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: SolvexaColors.textSub,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Judul & Sub-judul
            const Text(
              'Laporan Berhasil Terkirim!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: SolvexaColors.textHeading,
              ),
            ),
            const SizedBox(height: 8),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 14.5,
                  color: SolvexaColors.textSub,
                  height: 1.4,
                ),
                children: [
                  const TextSpan(text: 'Laporan '),
                  TextSpan(
                    text: activeTicket.assetCode,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: SolvexaColors.textHeading,
                    ),
                  ),
                  const TextSpan(text: ' telah masuk ke antrean teknisi kampus.'),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Kartu 1: Estimasi Respon
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: SolvexaColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: SolvexaColors.borderLight),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.access_time_rounded,
                          color: SolvexaColors.primaryNavy,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Estimasi Respon',
                              style: TextStyle(
                                fontSize: 12,
                                color: SolvexaColors.textSub,
                              ),
                            ),
                            Text(
                              activeTicket.estimatedResponse,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: SolvexaColors.textHeading,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Text(
                          'Otomatis',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: SolvexaColors.primaryNavy,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: const LinearProgressIndicator(
                      value: 0.48,
                      minHeight: 7,
                      backgroundColor: Color(0xFFEEF2FF),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF059669),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.apartment_rounded,
                            size: 16,
                            color: SolvexaColors.textSub,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Gedung Teknik Lt. 2',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: SolvexaColors.textSub,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.desktop_windows_outlined,
                            size: 16,
                            color: SolvexaColors.textSub,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Lab Komputer B',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: SolvexaColors.textSub,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Kartu 2: Teknisi Bertugas (Bima Arya - Unit Hardware)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: SolvexaColors.primaryNavy,
                        child: Text(
                          'BA',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 13,
                          height: 13,
                          decoration: BoxDecoration(
                            color: SolvexaColors.successGreen,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Teknisi Bertugas',
                          style: TextStyle(
                            fontSize: 12,
                            color: SolvexaColors.textSub,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Bima Arya (Unit Hardware)',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: SolvexaColors.textHeading,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Membuka pesan langsung ke Teknisi Bima Arya (Unit Hardware)...',
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chat_outlined,
                        color: SolvexaColors.primaryNavy,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Kartu 3: Lampiran Bukti Masalah (monitor_freeze_error.jpg)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SolvexaColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: SolvexaColors.borderLight),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Lampiran Bukti Masalah',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: SolvexaColors.textHeading,
                        ),
                      ),
                      Text(
                        '${activeTicket.photoPaths.length} Berkas Foto',
                        style: const TextStyle(
                          fontSize: 12,
                          color: SolvexaColors.textSub,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () => _showFullImagePreview(context, firstPhoto),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF0F172A), Color(0xFF1D4ED8)],
                          ),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Center(
                              child: Icon(
                                Icons.desktop_windows_outlined,
                                size: 48,
                                color: Colors.white.withValues(alpha: 0.25),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.image_outlined,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        firstPhoto,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Icon(
                                    Icons.visibility_outlined,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tombol Navigasi: Lacak Status Laporan & Kembali ke Beranda
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacementNamed(
                    context,
                    '/ticket-timeline',
                    arguments: activeTicket,
                  );
                },
                icon: const Icon(Icons.timeline_rounded, size: 20),
                label: const Text(
                  'Lacak Status Laporan',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {
                  context.read<SolvexaProvider>().setTabIndex(0);
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: SolvexaColors.primaryNavy,
                  side: const BorderSide(color: SolvexaColors.borderLight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.home_outlined, size: 20),
                label: const Text(
                  'Kembali ke Beranda',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullImagePreview(BuildContext context, String fileName) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                fileName,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1D4ED8)],
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.monitor_rounded, color: Colors.white, size: 54),
                      SizedBox(height: 8),
                      Text(
                        'Pratinjau Bukti Foto Kerusakan',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Tutup Pratinjau'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
