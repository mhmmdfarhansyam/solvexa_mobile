import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../models/solvexa_models.dart';

/// DatabaseHelper mengelola penyimpanan 100% Offline Local-First SQLite (`sqflite`)
/// sesuai spesifikasi PRD Solvexa Mobile Universitas Trilogi.
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  DatabaseHelper._internal();

  static Database? _database;

  // Fallback in-memory storage jika dijalankan di Flutter Web
  bool _useMemoryFallback = kIsWeb;
  final List<CampusLocation> _memLocations = [];
  final List<CampusAsset> _memAssets = [];
  final List<TicketModel> _memTickets = [];
  final List<NotificationItem> _memNotifications = [];
  bool _memInitialized = false;

  Future<Database?> get database async {
    if (_useMemoryFallback) {
      if (!_memInitialized) _seedMemory();
      return null;
    }
    if (_database != null) return _database!;
    try {
      final dbPath = await getDatabasesPath();
      final path = p.join(dbPath, 'solvexa_trilogi_v1.db');
      _database = await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
      );
      return _database;
    } catch (e) {
      debugPrint('SQLite fallback ke in-memory: $e');
      _useMemoryFallback = true;
      _seedMemory();
      return null;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE locations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT NOT NULL UNIQUE,
        building_name TEXT NOT NULL,
        floor_area TEXT NOT NULL,
        status_label TEXT NOT NULL,
        status_type TEXT NOT NULL DEFAULT 'normal',
        gps_zone TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE assets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        qr_code TEXT NOT NULL UNIQUE,
        asset_name TEXT NOT NULL,
        category TEXT NOT NULL,
        building_name TEXT NOT NULL,
        floor_room TEXT NOT NULL,
        detail_spot TEXT NOT NULL,
        unit_owner TEXT NOT NULL,
        is_verified INTEGER NOT NULL DEFAULT 1,
        status TEXT NOT NULL DEFAULT 'Online'
      )
    ''');

    await db.execute('''
      CREATE TABLE tickets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ticket_number TEXT NOT NULL UNIQUE,
        asset_code TEXT NOT NULL,
        asset_name TEXT NOT NULL,
        category TEXT NOT NULL,
        category_subtitle TEXT NOT NULL,
        building_location TEXT NOT NULL,
        room_detail TEXT NOT NULL,
        description TEXT NOT NULL,
        urgency TEXT NOT NULL DEFAULT 'Sedang',
        priority_label TEXT NOT NULL DEFAULT 'Prioritas Normal',
        status TEXT NOT NULL DEFAULT 'Dilaporkan',
        photo_paths TEXT NOT NULL DEFAULT '[]',
        technician_name TEXT NOT NULL DEFAULT 'Bima Arya',
        technician_unit TEXT NOT NULL DEFAULT 'Unit Hardware',
        technician_phone TEXT NOT NULL DEFAULT '+6281299003344',
        estimated_response TEXT NOT NULL DEFAULT 'Maks. 15-30 Menit',
        estimated_completion TEXT NOT NULL DEFAULT '~25 MENIT',
        field_note TEXT NOT NULL DEFAULT '',
        field_note_updated_at TEXT NOT NULL DEFAULT '',
        reported_at TEXT NOT NULL,
        processed_at TEXT,
        completed_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        notif_type TEXT NOT NULL,
        filter_category TEXT NOT NULL,
        ticket_number TEXT,
        location_badge TEXT NOT NULL,
        time_badge TEXT NOT NULL,
        day_group TEXT NOT NULL DEFAULT 'HARI INI',
        status_text TEXT,
        is_read INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    await _seedDatabase(db, includeSampleActiveTicket: false);
  }

  Future<void> _seedDatabase(Database db, {bool includeSampleActiveTicket = false}) async {
    final initialLocations = _defaultLocations();
    for (final loc in initialLocations) {
      await db.insert('locations', loc.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }

    final initialAssets = _defaultAssets();
    for (final asset in initialAssets) {
      await db.insert('assets', asset.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }

    final initialNotifs = _defaultNotifications();
    for (final notif in initialNotifs) {
      await db.insert('notifications', notif.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }

    if (includeSampleActiveTicket) {
      await db.insert('tickets', _sampleActiveTicket().toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  void _seedMemory({bool includeSampleActiveTicket = false}) {
    _memLocations
      ..clear()
      ..addAll(_defaultLocations());
    _memAssets
      ..clear()
      ..addAll(_defaultAssets());
    _memNotifications
      ..clear()
      ..addAll(_defaultNotifications());
    _memTickets.clear();
    if (includeSampleActiveTicket) {
      _memTickets.add(_sampleActiveTicket());
    }
    _memInitialized = true;
  }

  List<CampusLocation> _defaultLocations() => const [
        CampusLocation(
          id: 1,
          code: 'LOC-REKTORAT',
          buildingName: 'Gedung Rektorat',
          floorArea: 'Lt. 1 - 4 Normal',
          statusLabel: 'Kondusif',
          statusType: 'normal',
          gpsZone: 'Lantai 3 • Koridor Sayap Timur',
          updatedAt: 'Update 10m lalu',
        ),
        CampusLocation(
          id: 2,
          code: 'LOC-LABKOM',
          buildingName: 'Lab Komputer',
          floorArea: 'Lab A, B, & C',
          statusLabel: 'Siap Digunakan',
          statusType: 'normal',
          gpsZone: 'Gedung Riset Informatika • Lt. 2',
          updatedAt: 'Update 10m lalu',
        ),
        CampusLocation(
          id: 3,
          code: 'LOC-PERPUS',
          buildingName: 'Perpustakaan',
          floorArea: 'Ruang Koleksi',
          statusLabel: 'AC Stabil 22°C',
          statusType: 'normal',
          gpsZone: 'Gedung Perpustakaan Pusat • Lt. 2',
          updatedAt: 'Update 10m lalu',
        ),
      ];

  List<CampusAsset> _defaultAssets() => const [
        CampusAsset(
          id: 1,
          qrCode: 'PC-LAB3',
          assetName: 'PC Workstation Lab 3 #14',
          category: 'Hardware (PC/Monitor)',
          buildingName: 'Gedung Riset Informatika • Lt. 2',
          floorRoom: 'Lab Komputer 3 • Gedung B, Lantai 2',
          detailSpot: 'Gedung Riset Sains • Lab 3 (Meja 14)',
          unitOwner: 'Unit TI Trilogi',
        ),
        CampusAsset(
          id: 2,
          qrCode: 'TRILOGI-FAC-01',
          assetName: 'AC Central Koridor Timur',
          category: 'Fasilitas Ruang (AC/Gorden)',
          buildingName: 'Gedung Rektorat & Kuliah',
          floorRoom: 'Lantai 3 • Koridor Sayap Timur',
          detailSpot: 'Gedung Rektorat • Lt. 3 Sayap Timur',
          unitOwner: 'Biro Sarpras Trilogi',
        ),
        CampusAsset(
          id: 3,
          qrCode: 'PROJ-SEM-102',
          assetName: 'Proyektor Epson EB-X500',
          category: 'Hardware (PC/Monitor)',
          buildingName: 'Gedung C Perkuliahan',
          floorRoom: 'Gedung C • Ruang 102',
          detailSpot: 'Ruang Seminar 102 (Plafon Tengah)',
          unitOwner: 'Unit TI Trilogi',
        ),
        CampusAsset(
          id: 4,
          qrCode: 'AC-REKT-301',
          assetName: 'AC Split Daikin 2 PK',
          category: 'Fasilitas Ruang (AC/Gorden)',
          buildingName: 'Gedung Rektorat',
          floorRoom: 'Gedung Rektorat Lt. 3',
          detailSpot: 'Ruang Rapat Utama Lt. 3',
          unitOwner: 'Biro Sarpras Trilogi',
        ),
        CampusAsset(
          id: 5,
          qrCode: 'SAN-GDB-204',
          assetName: 'Wastafel & Kran Sensor',
          category: 'Sanitasi (Toilet/Air)',
          buildingName: 'Gedung B Fakultas Teknik',
          floorRoom: 'Gedung B • Lantai 2 Barat',
          detailSpot: 'Toilet Mahasiswa Lt. 2',
          unitOwner: 'Unit Utilitas Kampus',
        ),
      ];

  TicketModel _sampleActiveTicket() => const TicketModel(
        id: 1,
        ticketNumber: '#SLV-001',
        assetCode: 'PC-LAB3',
        assetName: 'PC Workstation Lab 3 #14',
        category: 'Hardware (PC / Monitor)',
        categorySubtitle: 'Unit CPU, layar monitor, periferal',
        buildingLocation: 'Lab Komputer 3 • Gedung B, Lantai 2',
        roomDetail: 'Gedung Riset Sains • Lab 3 (Meja 14)',
        description: 'Monitor blank hitam berulang & indikator kipas PSU berbunyi keras saat praktikum.',
        urgency: 'Sedang',
        priorityLabel: 'Prioritas Normal',
        status: 'Diproses Teknisi',
        photoPaths: ['monitor_freeze_error.jpg', 'bukti_lab3_01.jpg'],
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

  List<NotificationItem> _defaultNotifications() => const [
        NotificationItem(
          id: 1,
          title: 'Laporan Baru Diterima!',
          message: 'Laporan PC-LAB3 Anda sedang diproses oleh tim teknisi lab.',
          notifType: 'ticket_new',
          filterCategory: 'Tiket Saya',
          ticketNumber: '#TRL-8821',
          locationBadge: 'Gedung B • Lt. 2',
          timeBadge: '10 mnt lalu',
          dayGroup: 'HARI INI',
          statusText: 'Diproses',
          isRead: false,
          createdAt: '2026-11-04T09:15:00',
        ),
        NotificationItem(
          id: 2,
          title: 'Inspeksi Lift Terjadwal',
          message:
              'Lift Utama Gedung A dinonaktifkan sementara untuk pengujian sensor beban. Gunakan tangga darurat timur.',
          notifType: 'campus_schedule',
          filterCategory: 'Kampus',
          ticketNumber: null,
          locationBadge: '13:00 - 15:30 WIB',
          timeBadge: '1 jam lalu',
          dayGroup: 'HARI INI',
          statusText: 'Terjadwal',
          isRead: false,
          createdAt: '2026-11-04T08:30:00',
        ),
        NotificationItem(
          id: 3,
          title: 'Pemeliharaan AC Selesai',
          message:
              'Perbaikan filter AC di Gedung Rektorat Lt. 3 telah diselesaikan oleh Teknisi Sarpras.',
          notifType: 'ticket_done',
          filterCategory: 'Tiket Saya',
          ticketNumber: 'Tiket #TRL-8790',
          locationBadge: 'Gedung Rektorat Lt. 3',
          timeBadge: 'Kemarin, 16:40',
          dayGroup: 'KEMARIN',
          statusText: 'Telah Diverifikasi',
          isRead: true,
          createdAt: '2026-11-03T16:40:00',
        ),
        NotificationItem(
          id: 4,
          title: 'Proyektor Ruang Seminar',
          message:
              'Kabel HDMI & kalibrasi optik proyektor telah rampung dan siap digunakan untuk perkuliahan.',
          notifType: 'ticket_done',
          filterCategory: 'Kampus',
          ticketNumber: null,
          locationBadge: 'Gedung C • Ruang 102',
          timeBadge: 'Kemarin, 11:15',
          dayGroup: 'KEMARIN',
          statusText: 'Selesai',
          isRead: true,
          createdAt: '2026-11-03T11:15:00',
        ),
      ];

  // ==================== CRUD QUERIES ====================

  Future<List<CampusLocation>> getLocations() async {
    final db = await database;
    if (db == null) return List.unmodifiable(_memLocations);
    final rows = await db.query('locations', orderBy: 'id ASC');
    return rows.map((r) => CampusLocation.fromMap(r)).toList();
  }

  Future<List<CampusAsset>> getAssets() async {
    final db = await database;
    if (db == null) return List.unmodifiable(_memAssets);
    final rows = await db.query('assets', orderBy: 'id ASC');
    return rows.map((r) => CampusAsset.fromMap(r)).toList();
  }

  Future<CampusAsset> verifyQrCode(String qrCode) async {
    final cleanCode = qrCode.trim().toUpperCase();
    final assets = await getAssets();
    for (final a in assets) {
      if (a.qrCode.toUpperCase() == cleanCode) return a;
    }
    return CampusAsset(
      id: 99,
      qrCode: cleanCode.isEmpty ? 'PC-LAB3' : cleanCode,
      assetName: 'Unit Fasilitas ($cleanCode)',
      category: 'Hardware (PC/Monitor)',
      buildingName: 'Gedung Riset Informatika • Lt. 2',
      floorRoom: 'Lab Komputer 3 • Gedung B, Lantai 2',
      detailSpot: 'Gedung Riset Sains • Lab 3 (Meja 14)',
      unitOwner: 'Unit TI Trilogi',
    );
  }

  Future<List<TicketModel>> getTickets() async {
    final db = await database;
    if (db == null) return List.unmodifiable(_memTickets);
    final rows = await db.query('tickets', orderBy: 'id DESC');
    return rows.map((r) => TicketModel.fromMap(r)).toList();
  }

  Future<TicketModel> insertTicket(TicketModel ticket) async {
    final db = await database;
    final newNotif = NotificationItem(
      title: 'Laporan Baru Diterima!',
      message: 'Laporan ${ticket.assetCode} Anda sedang diproses oleh tim teknisi lab.',
      notifType: 'ticket_new',
      filterCategory: 'Tiket Saya',
      ticketNumber: ticket.ticketNumber,
      locationBadge: 'Gedung B • Lt. 2',
      timeBadge: 'Baru saja',
      dayGroup: 'HARI INI',
      statusText: 'Dilaporkan',
      isRead: false,
      createdAt: DateTime.now().toIso8601String(),
    );

    if (db == null) {
      final created = ticket.copyWith(id: _memTickets.length + 1);
      _memTickets.insert(0, created);
      _memNotifications.insert(0, newNotif);
      return created;
    }

    final id = await db.insert('tickets', ticket.toMap());
    await db.insert('notifications', newNotif.toMap());
    return ticket.copyWith(id: id);
  }

  Future<TicketModel> updateTicketStatus({
    required int ticketId,
    required String newStatus,
    required String fieldNote,
    required String estimatedCompletion,
    List<String>? updatedPhotos,
  }) async {
    final db = await database;
    final String techName =
        newStatus == 'Diproses Teknisi' ? 'Hendra Pratama' : 'Bima Arya';
    final String techUnit = newStatus == 'Diproses Teknisi'
        ? 'Divisi Sarpras & Lab IT'
        : 'Unit Hardware';

    if (db == null) {
      final idx = _memTickets.indexWhere((t) => t.id == ticketId);
      if (idx != -1) {
        final updated = _memTickets[idx].copyWith(
          status: newStatus,
          fieldNote: fieldNote,
          fieldNoteUpdatedAt: '09:22 WIB',
          estimatedCompletion: estimatedCompletion,
          photoPaths: updatedPhotos ?? _memTickets[idx].photoPaths,
          technicianName: techName,
          technicianUnit: techUnit,
          processedAt: newStatus == 'Diproses Teknisi' ? '4 Nov 2026, 09:20' : _memTickets[idx].processedAt,
          completedAt: newStatus == 'Selesai' ? '4 Nov 2026, 09:40' : _memTickets[idx].completedAt,
        );
        _memTickets[idx] = updated;
        return updated;
      }
      return _sampleActiveTicket();
    }

    final updateMap = <String, dynamic>{
      'status': newStatus,
      'field_note': fieldNote,
      'field_note_updated_at': '09:22 WIB',
      'estimated_completion': estimatedCompletion,
      'technician_name': techName,
      'technician_unit': techUnit,
    };
    if (updatedPhotos != null) {
      updateMap['photo_paths'] = jsonEncode(updatedPhotos);
    }
    if (newStatus == 'Diproses Teknisi') {
      updateMap['processed_at'] = '4 Nov 2026, 09:20';
    } else if (newStatus == 'Selesai') {
      updateMap['completed_at'] = '4 Nov 2026, 09:40';
    }

    await db.update('tickets', updateMap, where: 'id = ?', whereArgs: [ticketId]);
    final rows = await db.query('tickets', where: 'id = ?', whereArgs: [ticketId]);
    return TicketModel.fromMap(rows.first);
  }

  Future<List<NotificationItem>> getNotifications() async {
    final db = await database;
    if (db == null) return List.unmodifiable(_memNotifications);
    final rows = await db.query('notifications', orderBy: 'id ASC');
    return rows.map((r) => NotificationItem.fromMap(r)).toList();
  }

  Future<void> markAllNotificationsRead() async {
    final db = await database;
    if (db == null) {
      for (int i = 0; i < _memNotifications.length; i++) {
        final item = _memNotifications[i];
        _memNotifications[i] = NotificationItem(
          id: item.id,
          title: item.title,
          message: item.message,
          notifType: item.notifType,
          filterCategory: item.filterCategory,
          ticketNumber: item.ticketNumber,
          locationBadge: item.locationBadge,
          timeBadge: item.timeBadge,
          dayGroup: item.dayGroup,
          statusText: item.statusText,
          isRead: true,
          createdAt: item.createdAt,
        );
      }
      return;
    }
    await db.update('notifications', {'is_read': 1});
  }

  Future<void> clearNotificationsForDemo() async {
    final db = await database;
    if (db == null) {
      _memNotifications.clear();
      return;
    }
    await db.delete('notifications');
  }

  Future<void> restoreDefaultNotifications() async {
    final db = await database;
    if (db == null) {
      _memNotifications
        ..clear()
        ..addAll(_defaultNotifications());
      return;
    }
    await db.delete('notifications');
    for (final n in _defaultNotifications()) {
      await db.insert('notifications', n.toMap());
    }
  }

  Future<void> setDemoMode({required bool hasActiveTicket}) async {
    final db = await database;
    if (db == null) {
      _seedMemory(includeSampleActiveTicket: hasActiveTicket);
      return;
    }
    await db.delete('tickets');
    if (hasActiveTicket) {
      await db.insert('tickets', _sampleActiveTicket().toMap());
    }
  }
}
