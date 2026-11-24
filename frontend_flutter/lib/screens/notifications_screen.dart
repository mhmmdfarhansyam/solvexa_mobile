import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../data/models/solvexa_models.dart';
import '../providers/solvexa_provider.dart';

/// Layar Pusat Notifikasi (`Notifikasi - Ada Pesan.png` & `Notifikasi - Kosong.png` - PRD Bagian 4.7)
/// Mendukung:
/// - Filter Tab (`Semua`, `Belum Dibaca [2]`, `Tiket Saya`, `Kampus`) & tombol `✓✓ Tandai dibaca`
/// - Daftar pesan dikelompokkan berdasarkan waktu (`HARI INI` dan `KEMARIN`)
/// - Banner Bawah `SOLVEXA QUICK HELP – Ada Kerusakan Baru?` dengan tombol kuning QR
/// - Tampilan Kondisi Kosong (`Notifikasi - Kosong.png`) lengkap dengan ilustrasi lonceng centang,
///   `Semuanya Beres!`, `Periksa Pembaruan`, `Riwayat Laporan`, dan `Pemberitahuan Instan Aktif`
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SolvexaProvider>();
    final items = provider.filteredNotifications;

    if (items.isEmpty) {
      return _EmptyNotificationView(
        selectedFilter: provider.selectedNotificationFilter,
        onFilterChanged: provider.setNotificationFilter,
        onRestoreNotifications: provider.restoreNotifications,
        onOpenHistory: () {
          if (provider.latestActiveTicket != null) {
            Navigator.pushNamed(
              context,
              '/ticket-timeline',
              arguments: provider.latestActiveTicket,
            );
          } else {
            provider.setTabIndex(0);
          }
        },
      );
    }

    final todayItems = items.where((n) => n.dayGroup == 'HARI INI').toList();
    final yesterdayItems = items.where((n) => n.dayGroup == 'KEMARIN').toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris Filter Atas: Semua • | Belum Dibaca (2) | ✓✓ Tandai dibaca
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _FilterPillButton(
                      label: 'Semua',
                      showDot: true,
                      selected: provider.selectedNotificationFilter == 'Semua',
                      onTap: () => provider.setNotificationFilter('Semua'),
                    ),
                    _FilterPillButton(
                      label: 'Belum Dibaca',
                      badgeCount: provider.unreadNotificationCount,
                      selected:
                          provider.selectedNotificationFilter == 'Belum Dibaca',
                      onTap: () =>
                          provider.setNotificationFilter('Belum Dibaca'),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () => provider.markAllNotificationsAsRead(),
                onLongPress: () => provider.toggleEmptyNotificationDemo(),
                child: const Row(
                  children: [
                    Icon(
                      Icons.done_all_rounded,
                      size: 16,
                      color: SolvexaColors.primaryNavy,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Tandai dibaca',
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
          const SizedBox(height: 10),
          // Baris Filter Tambahan (Tiket Saya / Kampus / Simulasi Kosong)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ActionChip(
                  label: const Text('Tiket Saya', style: TextStyle(fontSize: 11.5)),
                  backgroundColor:
                      provider.selectedNotificationFilter == 'Tiket Saya'
                          ? SolvexaColors.accentAmberSoft
                          : SolvexaColors.surface,
                  onPressed: () => provider.setNotificationFilter('Tiket Saya'),
                ),
                const SizedBox(width: 8),
                ActionChip(
                  label: const Text('Kampus', style: TextStyle(fontSize: 11.5)),
                  backgroundColor:
                      provider.selectedNotificationFilter == 'Kampus'
                          ? SolvexaColors.accentAmberSoft
                          : SolvexaColors.surface,
                  onPressed: () => provider.setNotificationFilter('Kampus'),
                ),
                const SizedBox(width: 8),
                ActionChip(
                  avatar: const Icon(Icons.notifications_off_outlined, size: 15),
                  label: const Text(
                    'Lihat Mode Kosong',
                    style: TextStyle(fontSize: 11.5),
                  ),
                  backgroundColor: SolvexaColors.surface,
                  onPressed: () => provider.toggleEmptyNotificationDemo(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // KELOMPOK 1: HARI INI
          if (todayItems.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'HARI INI',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: SolvexaColors.textSub,
                  ),
                ),
                Text(
                  '${todayItems.length} Pembaruan',
                  style: const TextStyle(
                    fontSize: 12,
                    color: SolvexaColors.textSub,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...todayItems.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _NotificationCard(
                  item: item,
                  onTap: () {
                    if (provider.latestActiveTicket != null) {
                      Navigator.pushNamed(
                        context,
                        '/ticket-timeline',
                        arguments: provider.latestActiveTicket,
                      );
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],

          // KELOMPOK 2: KEMARIN
          if (yesterdayItems.isNotEmpty) ...[
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'KEMARIN',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: SolvexaColors.textSub,
                  ),
                ),
                Text(
                  'Selesai Ditangani',
                  style: TextStyle(
                    fontSize: 12,
                    color: SolvexaColors.textSub,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...yesterdayItems.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _NotificationCard(item: item),
              ),
            ),
          ],
          const SizedBox(height: 10),

          // Banner Bawah: SOLVEXA QUICK HELP - Ada Kerusakan Baru?
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: SolvexaColors.activeStatusGradient,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SOLVEXA QUICK HELP',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: SolvexaColors.accentAmber,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Ada Kerusakan\nBaru?',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Pindai QR kode barcode pada meja atau perangkat lab untuk respon kilat.',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFFCBD5E1),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () => provider.setTabIndex(1),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: SolvexaColors.accentAmber,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.qr_code_scanner_rounded,
                      color: SolvexaColors.primaryNavy,
                      size: 26,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterPillButton extends StatelessWidget {
  final String label;
  final bool showDot;
  final int badgeCount;
  final bool selected;
  final VoidCallback onTap;

  const _FilterPillButton({
    required this.label,
    this.showDot = false,
    this.badgeCount = 0,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: selected
                    ? SolvexaColors.textHeading
                    : SolvexaColors.textSub,
              ),
            ),
            if (showDot) ...[
              const SizedBox(width: 5),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: SolvexaColors.accentAmber,
                  shape: BoxShape.circle,
                ),
              ),
            ],
            if (badgeCount > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: SolvexaColors.accentAmber,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: SolvexaColors.primaryNavy,
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

class _NotificationCard extends StatelessWidget {
  final NotificationItem item;
  final VoidCallback? onTap;

  const _NotificationCard({required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isTicketNew = item.notifType == 'ticket_new';
    final isCampusSchedule = item.notifType == 'campus_schedule';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isTicketNew && !item.isRead
              ? const Color(0xFFE8EEFF)
              : SolvexaColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: SolvexaColors.borderLight),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ikon Kiri Sesuai Jenis Notifikasi
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isTicketNew
                        ? SolvexaColors.primaryNavy
                        : isCampusSchedule
                            ? SolvexaColors.accentAmber
                            : const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isTicketNew
                        ? Icons.desktop_windows_rounded
                        : isCampusSchedule
                            ? Icons.elevator_outlined
                            : item.title.contains('AC')
                                ? Icons.air_rounded
                                : Icons.videocam_outlined,
                    color: isTicketNew
                        ? Colors.white
                        : isCampusSchedule
                            ? SolvexaColors.primaryNavy
                            : item.title.contains('AC')
                                ? SolvexaColors.successGreen
                                : SolvexaColors.primaryNavy,
                    size: 22,
                  ),
                ),
                if (!item.isRead)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: isTicketNew
                            ? SolvexaColors.accentAmber
                            : const Color(0xFF78350F),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            // Konten Teks & Badge
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                item.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: SolvexaColors.textHeading,
                                ),
                              ),
                            ),
                            if (!item.isRead) ...[
                              const SizedBox(width: 6),
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: isTicketNew
                                      ? SolvexaColors.primaryNavy
                                      : SolvexaColors.accentAmber,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        item.timeBadge,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: SolvexaColors.textSub,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.message,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: SolvexaColors.textSub,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Baris Bawah Badge
                  if (item.dayGroup == 'HARI INI')
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isTicketNew
                                ? Colors.white
                                : const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            item.ticketNumber != null
                                ? '🔄 Tiket ${item.ticketNumber}'
                                : item.locationBadge,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: SolvexaColors.textHeading,
                            ),
                          ),
                        ),
                        if (item.ticketNumber != null) ...[
                          const SizedBox(width: 10),
                          Text(
                            item.locationBadge,
                            style: const TextStyle(
                              fontSize: 12,
                              color: SolvexaColors.textSub,
                            ),
                          ),
                        ],
                      ],
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: SolvexaColors.successGreen,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              item.statusText ?? 'Selesai',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: SolvexaColors.successGreen,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          item.ticketNumber != null
                              ? '${item.ticketNumber} >'
                              : item.locationBadge,
                          style: const TextStyle(
                            fontSize: 12,
                            color: SolvexaColors.textSub,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ============================================================================
/// TAMPILAN NOTIFIKASI KOSONG (`Notifikasi - Kosong.png` - PRD Bagian 4.7)
/// ============================================================================
class _EmptyNotificationView extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;
  final VoidCallback onRestoreNotifications;
  final VoidCallback onOpenHistory;

  const _EmptyNotificationView({
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.onRestoreNotifications,
    required this.onOpenHistory,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
      child: Column(
        children: [
          // Sub-Header: < | Notifikasi (Pusat Layanan Fasilitas) | Filter Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => context.read<SolvexaProvider>().setTabIndex(0),
                icon: const Icon(Icons.chevron_left_rounded, size: 28),
              ),
              const Column(
                children: [
                  Text(
                    'Notifikasi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: SolvexaColors.textHeading,
                    ),
                  ),
                  Text(
                    'Pusat Layanan Fasilitas',
                    style: TextStyle(
                      fontSize: 12,
                      color: SolvexaColors.textSub,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: onRestoreNotifications,
                icon: const Icon(Icons.tune_rounded, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Segmented Tab: Semua | Tiket Saya | Kampus
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFE8EEFF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: ['Semua', 'Tiket Saya', 'Kampus'].map((tab) {
                final active = selectedFilter == tab;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onFilterChanged(tab),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: active ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          tab,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                            color: active
                                ? SolvexaColors.textHeading
                                : SolvexaColors.textSub,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 36),

          // Ilustrasi Lingkaran Lonceng Disilang dengan Badge Kuning Centang
          Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              shape: BoxShape.circle,
              border: Border.all(
                color: SolvexaColors.accentAmberSoft,
                width: 6,
              ),
            ),
            child: Center(
              child: Container(
                width: 112,
                height: 112,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.notifications_off_outlined,
                      size: 46,
                      color: SolvexaColors.primaryNavy,
                    ),
                    Positioned(
                      top: 26,
                      right: 26,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: SolvexaColors.accentAmber,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 15,
                          color: SolvexaColors.primaryNavy,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Semuanya Beres!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: SolvexaColors.textHeading,
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Belum ada notifikasi baru. Pembaruan tiket dan perawatan fasilitas akan muncul di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.5,
                color: SolvexaColors.textSub,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 26),

          // Tombol Periksa Pembaruan & Riwayat Laporan
          SizedBox(
            width: 240,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: onRestoreNotifications,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text(
                'Periksa Pembaruan',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 240,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: onOpenHistory,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: SolvexaColors.primaryNavy,
                side: const BorderSide(color: SolvexaColors.borderLight),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(
                Icons.history_rounded,
                size: 20,
                color: SolvexaColors.accentAmber,
              ),
              label: const Text(
                'Riwayat Laporan',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 36),

          // Kartu Bawah: Pemberitahuan Instan Aktif
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SolvexaColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: SolvexaColors.borderLight),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.mark_email_read_outlined,
                    color: SolvexaColors.primaryNavy,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pemberitahuan Instan Aktif',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: SolvexaColors.textHeading,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Update gedung & perbaikan teknis',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: SolvexaColors.textSub,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF92400E),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shield_outlined,
                size: 14,
                color: SolvexaColors.textMuted,
              ),
              SizedBox(width: 6),
              Text(
                'Biro Sarana & Prasarana Universitas Trilogi',
                style: TextStyle(
                  fontSize: 11.5,
                  color: SolvexaColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
