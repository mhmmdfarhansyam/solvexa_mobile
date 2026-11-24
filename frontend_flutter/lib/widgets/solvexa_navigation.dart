import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../providers/solvexa_provider.dart';

/// Top App Bar standar Solvexa Mobile:
/// Ikon kunci pas (wrench) di dalam kotak navy bulat, teks kecil `UNIVERSITAS TRILOGI`,
/// judul halaman tebal (`Home`, `Scan Qr`, `Notifications`), tombol Role/Demo Switcher,
/// dan ikon pencarian di sisi kanan.
class SolvexaTopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onSearchTap;
  final VoidCallback? onRoleBadgeTap;

  const SolvexaTopAppBar({
    super.key,
    required this.title,
    this.onSearchTap,
    this.onRoleBadgeTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SolvexaProvider>();

    return Container(
      decoration: const BoxDecoration(
        color: SolvexaColors.surface,
        border: Border(
          bottom: BorderSide(color: SolvexaColors.borderLight, width: 1),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              // Logo Kotak Navy Bulat dengan Ikon Wrench di dalam Lingkaran
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: SolvexaColors.primaryNavy,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.6),
                    ),
                    child: const Icon(
                      Icons.build_rounded,
                      color: Colors.white,
                      size: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Teks UNIVERSITAS TRILOGI & Judul Halaman
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'UNIVERSITAS TRILOGI',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w600,
                        color: SolvexaColors.textSub,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: SolvexaColors.textHeading,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
              // Tombol Role Switcher (Simulasi Peran Lokal sesuai PRD Bagian 2)
              GestureDetector(
                onTap: onRoleBadgeTap ?? () => _showDemoControlSheet(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: provider.isTechnicianMode
                        ? SolvexaColors.accentAmberSoft
                        : SolvexaColors.secondarySurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: provider.isTechnicianMode
                          ? SolvexaColors.accentAmber
                          : SolvexaColors.borderLight,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        provider.isTechnicianMode
                            ? Icons.engineering_rounded
                            : Icons.school_rounded,
                        size: 14,
                        color: provider.isTechnicianMode
                            ? const Color(0xFFB45309)
                            : SolvexaColors.primaryNavy,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        provider.isTechnicianMode ? 'Teknisi' : 'Sivitas',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: provider.isTechnicianMode
                              ? const Color(0xFFB45309)
                              : SolvexaColors.primaryNavy,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: onSearchTap ?? () => _showAssetSearchDialog(context),
                icon: const Icon(
                  Icons.search_rounded,
                  color: SolvexaColors.textSub,
                  size: 26,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDemoControlSheet(BuildContext context) {
    final provider = context.read<SolvexaProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Consumer<SolvexaProvider>(
          builder: (context, state, _) {
            return Padding(
              padding: const EdgeInsets.all(24),
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
                          Icons.tune_rounded,
                          color: Color(0xFFB45309),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Panel Simulasi & Role Switcher',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: SolvexaColors.textHeading,
                              ),
                            ),
                            Text(
                              '100% Offline SQLite Local-First Mode',
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
                  const SizedBox(height: 20),
                  const Text(
                    '1. Pilih Peran Pengguna Aktif:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: SolvexaColors.textHeading,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _RoleOptionCard(
                          title: 'Sivitas Akademika',
                          subtitle: 'Pelapor Default',
                          icon: Icons.person_outline_rounded,
                          selected: !state.isTechnicianMode,
                          onTap: () => provider.setRole(UserRole.sivitas),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _RoleOptionCard(
                          title: 'Teknisi Operasional',
                          subtitle: 'Mode Simulasi / Demo',
                          icon: Icons.engineering_outlined,
                          selected: state.isTechnicianMode,
                          onTap: () => provider.setRole(UserRole.teknisi),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    '2. Beralih Kondisi Layar Beranda (SQLite State):',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: SolvexaColors.textHeading,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await provider.switchHomeDemoState(showActiveTicket: false);
                            if (ctx.mounted) Navigator.pop(ctx);
                          },
                          icon: const Icon(Icons.check_circle_outline, size: 18),
                          label: const Text('Beranda Kosong'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await provider.switchHomeDemoState(showActiveTicket: true);
                            if (ctx.mounted) Navigator.pop(ctx);
                          },
                          icon: const Icon(Icons.assignment_late_outlined, size: 18),
                          label: const Text('Ada Tiket Aktif'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAssetSearchDialog(BuildContext context) {
    final provider = context.read<SolvexaProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.85,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Database Aset & Stiker QR Kampus',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: SolvexaColors.textHeading,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Ketuk salah satu aset untuk langsung membuka Form Laporan Baru:',
                    style: TextStyle(fontSize: 13, color: SolvexaColors.textSub),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: provider.assets.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final asset = provider.assets[index];
                        return ListTile(
                          tileColor: SolvexaColors.secondarySurface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          leading: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: SolvexaColors.primaryNavy,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.qr_code_2_rounded,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            '${asset.qrCode} • ${asset.assetName}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: SolvexaColors.textHeading,
                            ),
                          ),
                          subtitle: Text(
                            '${asset.buildingName} (${asset.category})',
                            style: const TextStyle(
                              fontSize: 12,
                              color: SolvexaColors.textSub,
                            ),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: SolvexaColors.successBadgeBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              asset.status,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: SolvexaColors.successGreen,
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(ctx);
                            Navigator.pushNamed(
                              context,
                              '/new-ticket',
                              arguments: asset,
                            );
                          },
                        );
                      },
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
}

class _RoleOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _RoleOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? SolvexaColors.unreadCardBg : SolvexaColors.secondarySurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? SolvexaColors.primaryNavy : SolvexaColors.borderLight,
            width: selected ? 1.8 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: SolvexaColors.primaryNavy, size: 22),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: SolvexaColors.textHeading,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: SolvexaColors.textSub,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom Navigation Bar Solvexa Mobile (PRD Bagian 3.2):
/// 1. Home (Ikon rumah)
/// 2. Scan QR (Tombol bulat kuning menonjol / FAB di tengah)
/// 3. Updates (Ikon lonceng notifikasi)
class SolvexaBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const SolvexaBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final unread = context.watch<SolvexaProvider>().unreadNotificationCount;

    return Container(
      height: 84,
      decoration: BoxDecoration(
        color: SolvexaColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Menu 1: Home
              _NavTabItem(
                icon: currentIndex == 0 ? Icons.home_rounded : Icons.home_outlined,
                label: 'Home',
                selected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              const SizedBox(width: 72), // Ruang untuk FAB tengah
              // Menu 3: Updates
              _NavTabItem(
                icon: currentIndex == 2
                    ? Icons.notifications_rounded
                    : Icons.notifications_none_rounded,
                label: 'Updates',
                selected: currentIndex == 2,
                badgeCount: unread,
                onTap: () => onTap(2),
              ),
            ],
          ),
          // Menu 2: Scan QR (Tombol Bulat Kuning Menonjol di Tengah)
          Positioned(
            top: -18,
            child: GestureDetector(
              onTap: () => onTap(1),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: SolvexaColors.accentAmber,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: SolvexaColors.accentAmber.withOpacity(0.42),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.qr_code_scanner_rounded,
                      color: SolvexaColors.primaryNavy,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Scan QR',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: currentIndex == 1 ? FontWeight.w800 : FontWeight.w600,
                      color: currentIndex == 1
                          ? SolvexaColors.primaryNavy
                          : SolvexaColors.textSub,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTabItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final int badgeCount;
  final VoidCallback onTap;

  const _NavTabItem({
    required this.icon,
    required this.label,
    required this.selected,
    this.badgeCount = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? SolvexaColors.primaryNavy : SolvexaColors.textSub;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: color, size: 26),
                if (badgeCount > 0)
                  Positioned(
                    right: -6,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: SolvexaColors.accentAmber,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: SolvexaColors.primaryNavy,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
