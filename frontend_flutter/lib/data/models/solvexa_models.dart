import 'dart:convert';

/// Model Lokasi / Zona Gedung Terpantau (Tabel `locations`)
class CampusLocation {
  final int id;
  final String code;
  final String buildingName;
  final String floorArea;
  final String statusLabel;
  final String statusType;
  final String gpsZone;
  final String updatedAt;

  const CampusLocation({
    required this.id,
    required this.code,
    required this.buildingName,
    required this.floorArea,
    required this.statusLabel,
    required this.statusType,
    required this.gpsZone,
    required this.updatedAt,
  });

  factory CampusLocation.fromMap(Map<String, dynamic> map) {
    return CampusLocation(
      id: map['id'] as int? ?? 0,
      code: map['code'] as String? ?? '',
      buildingName: map['building_name'] as String? ?? '',
      floorArea: map['floor_area'] as String? ?? '',
      statusLabel: map['status_label'] as String? ?? '',
      statusType: map['status_type'] as String? ?? 'normal',
      gpsZone: map['gps_zone'] as String? ?? '',
      updatedAt: map['updated_at'] as String? ?? 'Update 10m lalu',
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'code': code,
        'building_name': buildingName,
        'floor_area': floorArea,
        'status_label': statusLabel,
        'status_type': statusType,
        'gps_zone': gpsZone,
        'updated_at': updatedAt,
      };
}

/// Model Aset Kampus / Stiker Kode QR (Tabel `assets`)
class CampusAsset {
  final int id;
  final String qrCode;
  final String assetName;
  final String category;
  final String buildingName;
  final String floorRoom;
  final String detailSpot;
  final String unitOwner;
  final bool isVerified;
  final String status;

  const CampusAsset({
    required this.id,
    required this.qrCode,
    required this.assetName,
    required this.category,
    required this.buildingName,
    required this.floorRoom,
    required this.detailSpot,
    required this.unitOwner,
    this.isVerified = true,
    this.status = 'Online',
  });

  factory CampusAsset.fromMap(Map<String, dynamic> map) {
    return CampusAsset(
      id: map['id'] as int? ?? 0,
      qrCode: map['qr_code'] as String? ?? 'PC-LAB3',
      assetName: map['asset_name'] as String? ?? '',
      category: map['category'] as String? ?? 'Hardware (PC/Monitor)',
      buildingName: map['building_name'] as String? ?? 'Gedung Riset Informatika • Lt. 2',
      floorRoom: map['floor_room'] as String? ?? 'Lab Komputer 3 • Gedung B, Lantai 2',
      detailSpot: map['detail_spot'] as String? ?? 'Gedung Riset Sains • Lab 3 (Meja 14)',
      unitOwner: map['unit_owner'] as String? ?? 'Unit TI Trilogi',
      isVerified: (map['is_verified'] as int? ?? 1) == 1,
      status: map['status'] as String? ?? 'Online',
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'qr_code': qrCode,
        'asset_name': assetName,
        'category': category,
        'building_name': buildingName,
        'floor_room': floorRoom,
        'detail_spot': detailSpot,
        'unit_owner': unitOwner,
        'is_verified': isVerified ? 1 : 0,
        'status': status,
      };
}

/// Model Tiket Laporan Kerusakan (Tabel `tickets`)
class TicketModel {
  final int? id;
  final String ticketNumber;
  final String assetCode;
  final String assetName;
  final String category;
  final String categorySubtitle;
  final String buildingLocation;
  final String roomDetail;
  final String description;
  final String urgency; // 'Rendah', 'Sedang', 'Darurat'
  final String priorityLabel;
  final String status; // 'Dilaporkan', 'Diproses Teknisi', 'Selesai'
  final List<String> photoPaths;
  final String technicianName;
  final String technicianUnit;
  final String technicianPhone;
  final String estimatedResponse;
  final String estimatedCompletion;
  final String fieldNote;
  final String fieldNoteUpdatedAt;
  final String reportedAt;
  final String? processedAt;
  final String? completedAt;

  const TicketModel({
    this.id,
    required this.ticketNumber,
    required this.assetCode,
    required this.assetName,
    required this.category,
    required this.categorySubtitle,
    required this.buildingLocation,
    required this.roomDetail,
    required this.description,
    required this.urgency,
    required this.priorityLabel,
    required this.status,
    required this.photoPaths,
    required this.technicianName,
    required this.technicianUnit,
    required this.technicianPhone,
    required this.estimatedResponse,
    required this.estimatedCompletion,
    required this.fieldNote,
    required this.fieldNoteUpdatedAt,
    required this.reportedAt,
    this.processedAt,
    this.completedAt,
  });

  bool get isActive => status == 'Dilaporkan' || status == 'Diproses Teknisi';

  TicketModel copyWith({
    int? id,
    String? ticketNumber,
    String? status,
    List<String>? photoPaths,
    String? technicianName,
    String? technicianUnit,
    String? estimatedCompletion,
    String? fieldNote,
    String? fieldNoteUpdatedAt,
    String? processedAt,
    String? completedAt,
  }) {
    return TicketModel(
      id: id ?? this.id,
      ticketNumber: ticketNumber ?? this.ticketNumber,
      assetCode: assetCode,
      assetName: assetName,
      category: category,
      categorySubtitle: categorySubtitle,
      buildingLocation: buildingLocation,
      roomDetail: roomDetail,
      description: description,
      urgency: urgency,
      priorityLabel: priorityLabel,
      status: status ?? this.status,
      photoPaths: photoPaths ?? this.photoPaths,
      technicianName: technicianName ?? this.technicianName,
      technicianUnit: technicianUnit ?? this.technicianUnit,
      technicianPhone: technicianPhone,
      estimatedResponse: estimatedResponse,
      estimatedCompletion: estimatedCompletion ?? this.estimatedCompletion,
      fieldNote: fieldNote ?? this.fieldNote,
      fieldNoteUpdatedAt: fieldNoteUpdatedAt ?? this.fieldNoteUpdatedAt,
      reportedAt: reportedAt,
      processedAt: processedAt ?? this.processedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  factory TicketModel.fromMap(Map<String, dynamic> map) {
    List<String> parsedPhotos = [];
    final rawPhotos = map['photo_paths'];
    if (rawPhotos is String && rawPhotos.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawPhotos) as List<dynamic>;
        parsedPhotos = decoded.map((e) => e.toString()).toList();
      } catch (_) {
        parsedPhotos = [rawPhotos];
      }
    } else if (rawPhotos is List) {
      parsedPhotos = rawPhotos.map((e) => e.toString()).toList();
    }

    return TicketModel(
      id: map['id'] as int?,
      ticketNumber: map['ticket_number'] as String? ?? '#SLV-001',
      assetCode: map['asset_code'] as String? ?? 'PC-LAB3',
      assetName: map['asset_name'] as String? ?? 'PC Workstation Lab 3 #14',
      category: map['category'] as String? ?? 'Hardware (PC / Monitor)',
      categorySubtitle: map['category_subtitle'] as String? ?? 'Unit CPU, layar monitor, periferal',
      buildingLocation: map['building_location'] as String? ?? 'Lab Komputer 3 • Gedung B, Lantai 2',
      roomDetail: map['room_detail'] as String? ?? 'Gedung Riset Sains • Lab 3 (Meja 14)',
      description: map['description'] as String? ?? '',
      urgency: map['urgency'] as String? ?? 'Sedang',
      priorityLabel: map['priority_label'] as String? ?? 'Prioritas Normal',
      status: map['status'] as String? ?? 'Dilaporkan',
      photoPaths: parsedPhotos,
      technicianName: map['technician_name'] as String? ?? 'Bima Arya',
      technicianUnit: map['technician_unit'] as String? ?? 'Unit Hardware',
      technicianPhone: map['technician_phone'] as String? ?? '+6281299003344',
      estimatedResponse: map['estimated_response'] as String? ?? 'Maks. 15-30 Menit',
      estimatedCompletion: map['estimated_completion'] as String? ?? '~25 MENIT',
      fieldNote: map['field_note'] as String? ?? '',
      fieldNoteUpdatedAt: map['field_note_updated_at'] as String? ?? '09:22 WIB',
      reportedAt: map['reported_at'] as String? ?? '4 Nov 2026, 09:15',
      processedAt: map['processed_at'] as String?,
      completedAt: map['completed_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'ticket_number': ticketNumber,
        'asset_code': assetCode,
        'asset_name': assetName,
        'category': category,
        'category_subtitle': categorySubtitle,
        'building_location': buildingLocation,
        'room_detail': roomDetail,
        'description': description,
        'urgency': urgency,
        'priority_label': priorityLabel,
        'status': status,
        'photo_paths': jsonEncode(photoPaths),
        'technician_name': technicianName,
        'technician_unit': technicianUnit,
        'technician_phone': technicianPhone,
        'estimated_response': estimatedResponse,
        'estimated_completion': estimatedCompletion,
        'field_note': fieldNote,
        'field_note_updated_at': fieldNoteUpdatedAt,
        'reported_at': reportedAt,
        'processed_at': processedAt,
        'completed_at': completedAt,
      };
}

/// Model Notifikasi & Pembaruan Kampus (Tabel `notifications`)
class NotificationItem {
  final int? id;
  final String title;
  final String message;
  final String notifType; // 'ticket_new', 'campus_schedule', 'ticket_done'
  final String filterCategory; // 'Tiket Saya', 'Kampus'
  final String? ticketNumber;
  final String locationBadge;
  final String timeBadge;
  final String dayGroup; // 'HARI INI', 'KEMARIN'
  final String? statusText;
  final bool isRead;
  final String createdAt;

  const NotificationItem({
    this.id,
    required this.title,
    required this.message,
    required this.notifType,
    required this.filterCategory,
    this.ticketNumber,
    required this.locationBadge,
    required this.timeBadge,
    required this.dayGroup,
    this.statusText,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationItem.fromMap(Map<String, dynamic> map) {
    return NotificationItem(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '',
      message: map['message'] as String? ?? '',
      notifType: map['notif_type'] as String? ?? 'ticket_new',
      filterCategory: map['filter_category'] as String? ?? 'Tiket Saya',
      ticketNumber: map['ticket_number'] as String?,
      locationBadge: map['location_badge'] as String? ?? '',
      timeBadge: map['time_badge'] as String? ?? '',
      dayGroup: map['day_group'] as String? ?? 'HARI INI',
      statusText: map['status_text'] as String?,
      isRead: (map['is_read'] as int? ?? 0) == 1,
      createdAt: map['created_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'title': title,
        'message': message,
        'notif_type': notifType,
        'filter_category': filterCategory,
        'ticket_number': ticketNumber,
        'location_badge': locationBadge,
        'time_badge': timeBadge,
        'day_group': dayGroup,
        'status_text': statusText,
        'is_read': isRead ? 1 : 0,
        'created_at': createdAt,
      };
}
