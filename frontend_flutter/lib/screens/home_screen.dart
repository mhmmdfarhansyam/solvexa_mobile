import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme/app_colors.dart';
import '../data/models/solvexa_models.dart';
import '../providers/solvexa_provider.dart';

/// Layar Beranda Solvexa Mobile (PRD Bagian 4.1 & 4.2)
/// Otomatis menampilkan:
/// - `Beranda - Kosong` apabila belum ada tiket laporan aktif di SQLite
/// - `Beranda - Laporan Aktif` apabila terdapat minimal 1 tiket laporan aktif
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SolvexaProvider>();
    final hasActive = provider.activeTickets.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: hasActive
          ? _ActiveReportHomeView(
              ticket: provider.latestActiveTicket!,
              activeCount: provider.activeTickets.length,
              onScanQr: () => provider.setTabIndex(1),
            )
          : _EmptyHomeView(
              completedCount: provider.completedThisMonthCount,
              locations: provider.locations,
              onScanQr: () => provider.setTabIndex(1),
              onOpenNotifications: () => provider.setTabIndex(2),
            ),
    );
  }
}

/// ============================================================================
/// 4.1 BERANDA - KONDISI KOSONG (`Beranda - Kosong.png`)
/// ============================================================================
class _EmptyHomeView extends StatelessWidget {
  final int completedCount;
  final List<CampusLocation> locations;
  final VoidCallback onScanQr;
  final VoidCallback onOpenNotifications;

  const _EmptyHomeView({
    required this.completedCount,
    required this.locations,
    required this.onScanQr,
    required this.onOpenNotifications,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sub-Header Profil: Thumbnail ilustrasi di kiri, lonceng & avatar ST di kanan
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 68,
              height: 36,
              decoration: BoxDecoration(
                color: SolvexaColors.secondarySurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: SolvexaColors.borderLight),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.laptop_mac_rounded, size: 18, color: SolvexaColors.primaryNavy),
                  SizedBox(width: 4),
                  Icon(Icons.verified_rounded, size: 14, color: SolvexaColors.successGreen),
                ],
              ),
            ),
            Row(
              children: [
                InkWell(
                  onTap: onOpenNotifications,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEEF2FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      color: SolvexaColors.primaryNavy,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: SolvexaColors.primaryNavy,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      'ST',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Sapaan & Tanggal Berjalan
        const Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 15,
              color: Color(0xFFB45309),
            ),
            SizedBox(width: 6),
            Text(
              'Rabu, 4 November 2026',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: SolvexaColors.textSub,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Halo, Sivitas Trilogi! 👋',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: SolvexaColors.textHeading,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Pantau dan jaga kenyamanan sarana kampus kita bersama.',
          style: TextStyle(
            fontSize: 15,
            color: SolvexaColors.textSub,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 22),

        // Kartu Ringkasan (2 Kolom)
        Row(
          children: [
            // Kolom 1: Laporan Aktif
            Expanded(
              child: Container(
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
                          'LAPORAN AKTIF',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: SolvexaColors.textSub,
                            letterSpacing: 0.4,
                          ),
                        ),
                        Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEEF2FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.assignment_outlined,
                            size: 16,
                            color: SolvexaColors.primaryNavy,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '0',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: SolvexaColors.textHeading,
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'tiket',
                          style: TextStyle(
                            fontSize: 14,
                            color: SolvexaColors.textSub,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: SolvexaColors.successGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Expanded(
                          child: Text(
                            'Semua tertangani',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: SolvexaColors.successGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Kolom 2: Selesai Bulan Ini
            Expanded(
              child: Container(
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
                        const Expanded(
                          child: Text(
                            'SELESAI BULAN INI',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: SolvexaColors.textSub,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                        Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(
                            color: SolvexaColors.accentAmberSoft,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle_outline_rounded,
                            size: 16,
                            color: Color(0xFFB45309),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$completedCount',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: SolvexaColors.textHeading,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'fasilitas',
                          style: TextStyle(
                            fontSize: 14,
                            color: SolvexaColors.textSub,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Row(
                      children: [
                        Icon(
                          Icons.trending_up_rounded,
                          size: 15,
                          color: Color(0xFFB45309),
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Kecepatan avg. 2 jam',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: SolvexaColors.textSub,
                            ),
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
        const SizedBox(height: 20),

        // Kartu Hero Empty State
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: BoxDecoration(
            color: SolvexaColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: SolvexaColors.borderLight),
          ),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 82,
                    height: 82,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEEF2FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.assignment_turned_in_outlined,
                      size: 38,
                      color: SolvexaColors.primaryNavy,
                    ),
                  ),
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: SolvexaColors.accentAmber,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified_outlined,
                        size: 16,
                        color: SolvexaColors.primaryNavy,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
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
                        color: SolvexaColors.successGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Sistem Siaga Operasional',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: SolvexaColors.primaryNavy,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Belum ada laporan kerusakan.\nFasilitas aman!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: SolvexaColors.textHeading,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Terima kasih telah merawat kampus kita. Menemukan AC mati, proyektor bermasalah, atau fasilitas rusak?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  color: SolvexaColors.textSub,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              InkWell(
                onTap: () => _showGuideDialog(context),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Panduan pelaporan sarana kampus',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF92400E),
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: Color(0xFF92400E),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Horizontal List - Zona Terpantau Hari Ini
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Zona Terpantau Hari Ini',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: SolvexaColors.textHeading,
              ),
            ),
            Text(
              'Update 10m lalu',
              style: TextStyle(
                fontSize: 12,
                color: SolvexaColors.textSub,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: locations.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final loc = locations[index];
              return Container(
                width: 156,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: SolvexaColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: SolvexaColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      loc.buildingName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: SolvexaColors.textSub,
                      ),
                    ),
                    Text(
                      loc.floorArea,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: SolvexaColors.textHeading,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: SolvexaColors.successGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            loc.statusLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: SolvexaColors.successGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 22),

        // CTA Utama: Tombol penuh kuning #F5B400 Scan QR Lapor
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: onScanQr,
            style: ElevatedButton.styleFrom(
              backgroundColor: SolvexaColors.accentAmber,
              foregroundColor: SolvexaColors.primaryNavy,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.qr_code_scanner_rounded, size: 22),
            label: const Text(
              'Scan QR Lapor',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showGuideDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Panduan Pelaporan Sarana Kampus'),
        content: const Text(
          '1. Temukan stiker QR Solvexa pada perangkat lab, AC, proyektor, atau ruangan.\n'
          '2. Ketuk tombol kuning "Scan QR Lapor" atau gunakan fitur Input Manual.\n'
          '3. Pilih kategori kerusakan, deskripsikan kendala, unggah foto bukti, lalu kirim.\n'
          '4. Pantau progres teknisi secara real-time di halaman Alur Penanganan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }
}

/// ============================================================================
/// 4.2 BERANDA - KONDISI ADA LAPORAN AKTIF (`Beranda - Laporan Aktif.png`)
/// ============================================================================
class _ActiveReportHomeView extends StatelessWidget {
  final TicketModel ticket;
  final int activeCount;
  final VoidCallback onScanQr;

  const _ActiveReportHomeView({
    required this.ticket,
    required this.activeCount,
    required this.onScanQr,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label Atas: Ikon perisai centang + LAYANAN SARANA KAMPUS
        const Row(
          children: [
            Icon(
              Icons.verified_user_outlined,
              size: 16,
              color: SolvexaColors.textHeading,
            ),
            SizedBox(width: 6),
            Text(
              'LAYANAN SARANA KAMPUS',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: SolvexaColors.textSub,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Halo, Sivitas Trilogi!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: SolvexaColors.textHeading,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Pantau status perbaikan dan kebutuhan inventaris fasilitas Anda secara realtime.',
          style: TextStyle(
            fontSize: 14.5,
            color: SolvexaColors.textSub,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),

        // Kartu Status Penanganan (Dark Navy Gradient)
        GestureDetector(
          onTap: () => Navigator.pushNamed(
            context,
            '/ticket-timeline',
            arguments: ticket,
          ),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: SolvexaColors.activeStatusGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: SolvexaColors.primaryNavy.withOpacity(0.22),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'STATUS PENANGANAN',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: SolvexaColors.accentAmber,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '$activeCount',
                                  style: const TextStyle(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Laporan Aktif',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Tiket dalam antrean respon prioritas fasilitas.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFFCBD5E1),
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.pending_actions_rounded,
                          color: SolvexaColors.accentAmber,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.22),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          color: SolvexaColors.accentAmber,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Est. Waktu Penanganan: < 30 mnt',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.white70,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Bagian Laporan Terbaru
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Laporan Terbaru',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: SolvexaColors.textHeading,
              ),
            ),
            InkWell(
              onTap: () => Navigator.pushNamed(
                context,
                '/ticket-timeline',
                arguments: ticket,
              ),
              child: const Row(
                children: [
                  Text(
                    'Riwayat Semua',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: SolvexaColors.textSub,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, size: 15, color: SolvexaColors.textSub),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Kartu Tiket Terbaru
        GestureDetector(
          onTap: () => Navigator.pushNamed(
            context,
            '/ticket-timeline',
            arguments: ticket,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SolvexaColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: SolvexaColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.desktop_windows_rounded,
                        color: SolvexaColors.primaryNavy,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${ticket.assetCode} | ${ticket.category}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: SolvexaColors.textHeading,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'ID: ${ticket.ticketNumber == '#SLV-001' ? '#TRL-2024-089' : ticket.ticketNumber}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: SolvexaColors.textSub,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: SolvexaColors.warningBadgeBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: SolvexaColors.warningAmber,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            ticket.status == 'Dilaporkan'
                                ? 'Menunggu Teknisi'
                                : ticket.status,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF92400E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Foto Bukti dengan Overlay Lokasi
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    children: [
                      Container(
                        height: 165,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFF1E293B),
                              Color(0xFF0F172A),
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.computer_rounded,
                            size: 64,
                            color: Colors.white24,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 12,
                        bottom: 12,
                        right: 12,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                ticket.roomDetail,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 15,
                          color: SolvexaColors.textSub,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Baru saja dilaporkan',
                          style: TextStyle(
                            fontSize: 12,
                            color: SolvexaColors.textSub,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          size: 15,
                          color: SolvexaColors.successGreen,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Unit TI Trilogi',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: SolvexaColors.textHeading,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Aksi Cepat
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'AKSI CEPAT',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: SolvexaColors.textSub,
              ),
            ),
            Text(
              'Bantuan 24/7',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: SolvexaColors.textSub,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: onScanQr,
            style: ElevatedButton.styleFrom(
              backgroundColor: SolvexaColors.accentAmber,
              foregroundColor: SolvexaColors.primaryNavy,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.qr_code_scanner_rounded, size: 22),
            label: const Text(
              'Scan QR Lapor',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // 2 Kartu Menu Berdampingan: Cek Aset Lab & Kontak Helpdesk
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _showAssetDatabaseModal(context),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F6FB),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.inventory_2_outlined,
                          color: SolvexaColors.primaryNavy,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Cek Aset Lab',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: SolvexaColors.textHeading,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Database barang ruang',
                        style: TextStyle(
                          fontSize: 12,
                          color: SolvexaColors.textSub,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: InkWell(
                onTap: () => _launchHelpdesk(context),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F6FB),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.headset_mic_outlined,
                          color: SolvexaColors.primaryNavy,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Kontak Helpdesk',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: SolvexaColors.textHeading,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Layanan siaga cepat',
                        style: TextStyle(
                          fontSize: 12,
                          color: SolvexaColors.textSub,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showAssetDatabaseModal(BuildContext context) {
    final assets = context.read<SolvexaProvider>().assets;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Database Barang & Aset Ruang (SQLite Lokal)',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: SolvexaColors.textHeading,
              ),
            ),
            const SizedBox(height: 12),
            ...assets.map(
              (a) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFEEF2FF),
                  child: Icon(Icons.qr_code_rounded, color: SolvexaColors.primaryNavy),
                ),
                title: Text(
                  '${a.qrCode} — ${a.assetName}',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                ),
                subtitle: Text('${a.buildingName} • ${a.unitOwner}'),
                trailing: TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pushNamed(context, '/new-ticket', arguments: a);
                  },
                  child: const Text('Lapor'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchHelpdesk(BuildContext context) async {
    final uri = Uri.parse('tel:+62217980011');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Menghubungi Helpdesk Biro Sarpras Trilogi: (021) 798-0011'),
        ),
      );
    }
  }
}
