import 'package:flutter/material.dart';
import '../data/local_db/database_helper.dart';
import '../data/models/solvexa_models.dart';

enum UserRole {
  sivitas, // Sivitas Akademika (Pelapor Default)
  teknisi, // Teknisi Operasional (Mode Simulasi / Demo)
}

class SolvexaProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  // Navigasi Bottom Navigation Bar (0: Home, 1: Scan QR, 2: Updates)
  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;

  // Peran Pengguna (Role Switcher sesuai PRD Bagian 2)
  UserRole _activeRole = UserRole.sivitas;
  UserRole get activeRole => _activeRole;
  bool get isTechnicianMode => _activeRole == UserRole.teknisi;

  // Data dari SQLite
  List<CampusLocation> _locations = [];
  List<CampusLocation> get locations => _locations;

  List<CampusAsset> _assets = [];
  List<CampusAsset> get assets => _assets;

  List<TicketModel> _tickets = [];
  List<TicketModel> get tickets => _tickets;

  List<TicketModel> get activeTickets =>
      _tickets.where((t) => t.isActive).toList();

  TicketModel? get latestActiveTicket =>
      activeTickets.isNotEmpty ? activeTickets.first : null;

  int get completedThisMonthCount =>
      14 + _tickets.where((t) => t.status == 'Selesai').length;

  List<NotificationItem> _notifications = [];
  List<NotificationItem> get notifications => _notifications;

  String _selectedNotificationFilter = 'Semua';
  String get selectedNotificationFilter => _selectedNotificationFilter;

  bool _forceEmptyNotificationState = false;
  bool get forceEmptyNotificationState => _forceEmptyNotificationState;

  int get unreadNotificationCount =>
      _notifications.where((n) => !n.isRead).length;

  List<NotificationItem> get filteredNotifications {
    if (_forceEmptyNotificationState) return [];
    switch (_selectedNotificationFilter) {
      case 'Belum Dibaca':
        return _notifications.where((n) => !n.isRead).toList();
      case 'Tiket Saya':
        return _notifications.where((n) => n.filterCategory == 'Tiket Saya').toList();
      case 'Kampus':
        return _notifications.where((n) => n.filterCategory == 'Kampus').toList();
      case 'Semua':
      default:
        return _notifications;
    }
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    await refreshAll();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshAll() async {
    _locations = await _db.getLocations();
    _assets = await _db.getAssets();
    _tickets = await _db.getTickets();
    _notifications = await _db.getNotifications();
    notifyListeners();
  }

  void setTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  void toggleRole() {
    _activeRole = _activeRole == UserRole.sivitas
        ? UserRole.teknisi
        : UserRole.sivitas;
    notifyListeners();
  }

  void setRole(UserRole role) {
    _activeRole = role;
    notifyListeners();
  }

  void setNotificationFilter(String filter) {
    _selectedNotificationFilter = filter;
    notifyListeners();
  }

  void toggleEmptyNotificationDemo() {
    _forceEmptyNotificationState = !_forceEmptyNotificationState;
    notifyListeners();
  }

  Future<void> markAllNotificationsAsRead() async {
    await _db.markAllNotificationsRead();
    _notifications = await _db.getNotifications();
    notifyListeners();
  }

  Future<void> restoreNotifications() async {
    _forceEmptyNotificationState = false;
    await _db.restoreDefaultNotifications();
    _notifications = await _db.getNotifications();
    notifyListeners();
  }

  Future<CampusAsset> verifyAssetByQr(String qrCode) async {
    return _db.verifyQrCode(qrCode);
  }

  Future<TicketModel> submitNewTicket({
    required CampusAsset asset,
    required String category,
    required String description,
    required String urgency,
    required List<String> photoPaths,
  }) async {
    final nextNum = _tickets.length + 1;
    final ticketNumber = '#SLV-${nextNum.toString().padLeft(3, '0')}';

    final subtitles = <String, String>{
      'Hardware (PC/Monitor)': 'Unit CPU, layar monitor, periferal',
      'Fasilitas Ruang (AC/Gorden)': 'Pendingin, pencahayaan, ventilasi',
      'Sanitasi (Toilet/Air)': 'Wastafel, kran air, saluran',
    };

    final priorityLabel = urgency == 'Darurat'
        ? 'Prioritas Tinggi'
        : urgency == 'Rendah'
            ? 'Prioritas Rendah'
            : 'Prioritas Normal';

    final newTicket = TicketModel(
      ticketNumber: ticketNumber,
      assetCode: asset.qrCode,
      assetName: asset.assetName,
      category: category,
      categorySubtitle: subtitles[category] ?? 'Fasilitas Kampus',
      buildingLocation: asset.floorRoom,
      roomDetail: asset.detailSpot,
      description: description.trim().isEmpty
          ? 'Monitor blank hitam berulang & indikator kipas PSU berbunyi keras.'
          : description.trim(),
      urgency: urgency,
      priorityLabel: priorityLabel,
      status: 'Dilaporkan',
      photoPaths: photoPaths.isEmpty ? ['monitor_freeze_error.jpg'] : photoPaths,
      technicianName: 'Bima Arya',
      technicianUnit: 'Unit Hardware',
      technicianPhone: '+6281288001122',
      estimatedResponse: 'Maks. 15-30 Menit',
      estimatedCompletion: '~25 MENIT',
      fieldNote:
          'Sedang dilakukan pengecekan kabel daya dan komponen GPU. Indikasi awal thermal throttling atau kabel PCIe kendor. Akan dilakukan pergantian pasta pendingin.',
      fieldNoteUpdatedAt: '09:22 WIB',
      reportedAt: '4 Nov 2026, 09:15',
    );

    final saved = await _db.insertTicket(newTicket);
    await refreshAll();
    return saved;
  }

  Future<TicketModel> advanceOrUpdateTicketStatus({
    required TicketModel ticket,
    String? targetStatus,
    String? customFieldNote,
    String? customEstimation,
    List<String>? updatedPhotos,
  }) async {
    String nextStatus = targetStatus ?? ticket.status;
    if (targetStatus == null) {
      if (ticket.status == 'Dilaporkan') {
        nextStatus = 'Diproses Teknisi';
      } else if (ticket.status == 'Diproses Teknisi') {
        nextStatus = 'Selesai';
      } else {
        nextStatus = 'Dilaporkan';
      }
    }

    String defaultNote = ticket.fieldNote;
    if (customFieldNote != null && customFieldNote.trim().isNotEmpty) {
      defaultNote = customFieldNote.trim();
    } else if (nextStatus == 'Diproses Teknisi') {
      defaultNote =
          'Sedang dilakukan pengecekan kabel daya dan komponen GPU. Indikasi awal thermal throttling atau kabel PCIe kendor. Akan dilakukan pergantian pasta pendingin.';
    } else if (nextStatus == 'Selesai') {
      defaultNote =
          'Pergantian pasta pendingin GPU dan pengencangan konektor PCIe selesai dilakukan. Hasil uji benchmark 30 menit stabil tanpa gejala blank hitam.';
    }

    final updated = await _db.updateTicketStatus(
      ticketId: ticket.id ?? 1,
      newStatus: nextStatus,
      fieldNote: defaultNote,
      estimatedCompletion: customEstimation ?? (nextStatus == 'Selesai' ? 'SELESAI' : '~25 MENIT'),
      updatedPhotos: updatedPhotos,
    );
    await refreshAll();
    return updated;
  }

  Future<void> switchHomeDemoState({required bool showActiveTicket}) async {
    await _db.setDemoMode(hasActiveTicket: showActiveTicket);
    await refreshAll();
  }
}
