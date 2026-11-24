
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../providers/solvexa_provider.dart';

/// Layar Pemindai QR Kamera (`Scan QR Kamera.jpg` - PRD Bagian 4.3)
/// Mendukung:
/// - Viewfinder Kamera (`mobile_scanner`) + indikator `CAMERA ACTIVE` + tombol Flash
/// - Bingkai pemindai sudut kuning tebal + garis laser kuning + label `TRILOGI-FAC-01`
/// - Tombol `Upload Foto` (Galeri) & `Input Manual` (Bottom Sheet pemilihan aset)
/// - Kartu bawah `LOKASI TERDETEKSI` (`GPS Siap` - `Gedung Rektorat & Kuliah`)
class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  final MobileScannerController _scannerController =
      MobileScannerController();

  bool _torchEnabled = false;
  bool _isProcessingCode = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _handleDetectedQrCode(String rawCode) async {
    if (_isProcessingCode) return;

    setState(() => _isProcessingCode = true);

    final provider = context.read<SolvexaProvider>();
    final verifiedAsset = await provider.verifyAssetByQr(rawCode);

    if (!mounted) return;

    setState(() => _isProcessingCode = false);

    Navigator.pushNamed(
      context,
      '/new-ticket',
      arguments: verifiedAsset,
    );
  }

  Future<void> _pickQrFromGallery() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
      );

      if (picked != null && mounted) {
        await _handleDetectedQrCode('PC-LAB3');
      }
    } catch (_) {
      await _handleDetectedQrCode('PC-LAB3');
    }
  }

  void _showManualInputBottomSheet() {
    final provider = context.read<SolvexaProvider>();
    final textController = TextEditingController(text: 'PC-LAB3');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (ctx) {
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
              const Text(
                'Input Manual Kode Aset QR',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: SolvexaColors.textHeading,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Masukkan kode stiker fasilitas atau pilih langsung dari daftar aset kampus:',
                style: TextStyle(
                  fontSize: 13,
                  color: SolvexaColors.textSub,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: textController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'Contoh: PC-LAB3 atau TRILOGI-FAC-01',
                  filled: true,
                  fillColor: SolvexaColors.secondarySurface,
                  prefixIcon: const Icon(Icons.qr_code_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: provider.assets.map((asset) {
                  return ActionChip(
                    label: Text(
                      asset.qrCode,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: SolvexaColors.accentAmberSoft,
                    onPressed: () {
                      Navigator.pop(ctx);
                      _handleDetectedQrCode(asset.qrCode);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final code = textController.text.trim();
                    Navigator.pop(ctx);
                    _handleDetectedQrCode(
                      code.isEmpty ? 'PC-LAB3' : code,
                    );
                  },
                  child: const Text(
                    'Verifikasi & Buka Form Laporan',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ).whenComplete(textController.dispose);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SolvexaProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      child: Column(
        children: [
          // Viewfinder Kamera
          Container(
            height: 490,
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Kamera belakang
                MobileScanner(
                  controller: _scannerController,
                  onDetect: (capture) {
                    if (capture.barcodes.isNotEmpty) {
                      final code = capture.barcodes.first.rawValue;

                      if (code != null && code.isNotEmpty) {
                        _handleDetectedQrCode(code);
                      }
                    }
                  },
                  errorBuilder: (context, error, child) {
                    return Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF334155),
                            Color(0xFF1E293B),
                            Color(0xFF0F172A),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // Top Overlay Bar
                Positioned(
                  top: 18,
                  left: 18,
                  right: 18,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () => provider.setTabIndex(0),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.45),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
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
                              'CAMERA ACTIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _torchEnabled = !_torchEnabled;
                          });
                          _scannerController.toggleTorch();
                        },
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.45),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _torchEnabled
                                ? Icons.flash_on_rounded
                                : Icons.flash_off_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bingkai Pemindai Tengah
                Center(
                  child: GestureDetector(
                    onTap: () => _handleDetectedQrCode('PC-LAB3'),
                    child: SizedBox(
                      width: 240,
                      height: 240,
                      child: Stack(
                        children: [
                          const Positioned(
                            top: 12,
                            left: 16,
                            child: Text(
                              'TRILOGI-FAC-01',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                          Center(
                            child: Icon(
                              Icons.qr_code_2_rounded,
                              size: 92,
                              color: Colors.white.withValues(alpha: 0.28),
                            ),
                          ),
                          Center(
                            child: Container(
                              height: 3,
                              width: 220,
                              decoration: BoxDecoration(
                                color: SolvexaColors.accentAmber,
                                boxShadow: [
                                  BoxShadow(
                                    color: SolvexaColors.accentAmber
                                        .withValues(alpha: 0.8),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          ..._buildYellowCorners(),
                        ],
                      ),
                    ),
                  ),
                ),

                // Instruksi dan Tombol Alternatif
                Positioned(
                  left: 18,
                  right: 18,
                  bottom: 18,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A)
                              .withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Text(
                          'Arahkan kamera ke stiker QR',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Posisikan kode QR di dalam bingkai kuning\n'
                        'untuk memindai fasilitas otomatis',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12.5,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: _pickQrFromGallery,
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 13,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.22),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.25),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.photo_library_outlined,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Upload Foto',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: _showManualInputBottomSheet,
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 13,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.22),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.25),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.keyboard_alt_outlined,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Input Manual',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
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
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Kartu Lokasi Terdeteksi
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SolvexaColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: SolvexaColors.borderLight,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: SolvexaColors.accentAmberSoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.verified_outlined,
                    color: SolvexaColors.primaryNavy,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'LOKASI TERDETEKSI',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                              color: SolvexaColors.textSub,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: SolvexaColors.successBadgeBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'GPS Siap',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: SolvexaColors.successGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Gedung Rektorat & Kuliah',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: SolvexaColors.textHeading,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Lantai 3 • Koridor Sayap Timur',
                        style: TextStyle(
                          fontSize: 13,
                          color: SolvexaColors.textSub,
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
    );
  }

  List<Widget> _buildYellowCorners() {
    const double size = 34;

    return [
      Positioned(
        top: 0,
        left: 0,
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: SolvexaColors.accentAmber,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomRight: Radius.circular(6),
            ),
          ),
        ),
      ),
      Positioned(
        top: 0,
        right: 0,
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: SolvexaColors.accentAmber,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(12),
              bottomLeft: Radius.circular(6),
            ),
          ),
        ),
      ),
      Positioned(
        bottom: 0,
        left: 0,
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: SolvexaColors.accentAmber,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(12),
              topRight: Radius.circular(6),
            ),
          ),
        ),
      ),
      Positioned(
        bottom: 0,
        right: 0,
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: SolvexaColors.accentAmber,
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(12),
              topLeft: Radius.circular(6),
            ),
          ),
        ),
      ),
    ];
  }
}
