-- ============================================================================
-- SOLVEXA MOBILE - INITIAL SEED DATA (Universitas Trilogi)
-- ============================================================================

INSERT OR REPLACE INTO app_settings (key, value) VALUES
('active_role', 'sivitas'), -- 'sivitas' atau 'teknisi'
('completed_this_month_baseline', '14'),
('avg_resolution_speed', '2 jam'),
('helpdesk_phone', '+62217980011'),
('helpdesk_whatsapp', '62811980011');

INSERT OR REPLACE INTO locations (id, code, building_name, floor_area, status_label, status_type, gps_zone, updated_at) VALUES
(1, 'LOC-REKTORAT', 'Gedung Rektorat', 'Lt. 1 - 4 Normal', 'Kondusif', 'normal', 'Lantai 3 • Koridor Sayap Timur', 'Update 10m lalu'),
(2, 'LOC-LABKOM', 'Lab Komputer', 'Lab A, B, & C', 'Siap Digunakan', 'normal', 'Gedung Riset Informatika • Lt. 2', 'Update 10m lalu'),
(3, 'LOC-PERPUS', 'Perpustakaan', 'Ruang Koleksi', 'AC Stabil 22°C', 'normal', 'Gedung Perpustakaan Pusat • Lt. 2', 'Update 10m lalu'),
(4, 'LOC-RISET', 'Gedung Riset Sains', 'Lab 1 - 4', 'Operasional', 'normal', 'Gedung Riset Sains • Lt. 3', 'Update 5m lalu');

INSERT OR REPLACE INTO technicians (id, code, name, unit_division, specialization, phone, avatar_initials, is_available) VALUES
(1, 'TECH-01', 'Bima Arya', 'Unit Hardware', 'Hardware (PC/Monitor)', '+6281288001122', 'BA', 1),
(2, 'TECH-02', 'Hendra Pratama', 'Divisi Sarpras & Lab IT', 'Hardware & Jaringan Lab', '+6281299003344', 'HP', 1),
(3, 'TECH-03', 'Rizal Kurniawan', 'Teknisi Sarpras Gedung', 'Fasilitas Ruang (AC/Gorden)', '+6281377005566', 'RK', 1),
(4, 'TECH-04', 'Dedi Suryadi', 'Unit Utilitas & Sanitasi', 'Sanitasi (Toilet/Air)', '+6281366007788', 'DS', 1);

INSERT OR REPLACE INTO assets (id, qr_code, asset_name, category, building_name, floor_room, detail_spot, unit_owner, is_verified, status) VALUES
(1, 'PC-LAB3', 'PC Workstation Lab 3 #14', 'Hardware (PC/Monitor)', 'Gedung Riset Informatika • Lt. 2', 'Lab Komputer 3 • Gedung B, Lantai 2', 'Gedung Riset Sains • Lab 3 (Meja 14)', 'Unit TI Trilogi', 1, 'Online'),
(2, 'TRILOGI-FAC-01', 'AC Central Koridor Timur', 'Fasilitas Ruang (AC/Gorden)', 'Gedung Rektorat & Kuliah', 'Lantai 3 • Koridor Sayap Timur', 'Gedung Rektorat • Lt. 3 Sayap Timur', 'Biro Sarpras Trilogi', 1, 'Online'),
(3, 'PROJ-SEM-102', 'Proyektor Epson EB-X500', 'Hardware (PC/Monitor)', 'Gedung C Perkuliahan', 'Gedung C • Ruang 102', 'Ruang Seminar 102 (Plafon Tengah)', 'Unit TI Trilogi', 1, 'Online'),
(4, 'AC-REKT-301', 'AC Split Daikin 2 PK', 'Fasilitas Ruang (AC/Gorden)', 'Gedung Rektorat', 'Gedung Rektorat Lt. 3', 'Ruang Rapat Utama Lt. 3', 'Biro Sarpras Trilogi', 1, 'Online'),
(5, 'SAN-GDB-204', 'Wastafel & Kran Sensor', 'Sanitasi (Toilet/Air)', 'Gedung B Fakultas Teknik', 'Gedung B • Lantai 2 Barat', 'Toilet Mahasiswa Lt. 2', 'Unit Utilitas Kampus', 1, 'Online'),
(6, 'PC-LABB-08', 'PC Dekstop Core i7 Lab B', 'Hardware (PC/Monitor)', 'Gedung Teknik Lt. 2', 'Lab Komputer B', 'Gedung Teknik Lt. 2 • Lab Komputer B (Meja 08)', 'Unit TI Trilogi', 1, 'Online');

-- Contoh Tiket Aktif Default (Dapat di-reset ke Kosong atau di-load untuk Demo)
INSERT OR REPLACE INTO tickets (
    id, ticket_number, asset_code, asset_name, category, category_subtitle,
    building_location, room_detail, description, urgency, priority_label,
    status, photo_paths, technician_id, technician_name, technician_unit,
    technician_phone, estimated_response, estimated_completion,
    field_note, field_note_updated_at, reported_at, processed_at, completed_at
) VALUES
(
    1,
    '#SLV-001',
    'PC-LAB3',
    'PC Workstation Lab 3 #14',
    'Hardware (PC / Monitor)',
    'Unit CPU, layar monitor, periferal',
    'Lab Komputer 3 • Gedung B, Lantai 2',
    'Gedung Riset Sains • Lab 3 (Meja 14)',
    'Monitor blank hitam berulang & indikator kipas PSU berbunyi keras saat digunakan praktikum.',
    'Sedang',
    'Prioritas Normal',
    'Diproses Teknisi',
    '["monitor_freeze_error.jpg", "bukti_lab3_01.jpg"]',
    2,
    'Hendra Pratama',
    'Divisi Sarpras & Lab IT',
    '+6281299003344',
    'Maks. 15-30 Menit',
    '~25 MENIT',
    'Sedang dilakukan pengecekan kabel daya dan komponen GPU. Indikasi awal thermal throttling atau kabel PCIe kendor. Akan dilakukan pergantian pasta pendingin.',
    '09:22 WIB',
    '4 Nov 2026, 09:15',
    '4 Nov 2026, 09:20',
    NULL
);

INSERT OR REPLACE INTO notifications (
    id, title, message, notif_type, filter_category, ticket_number,
    location_badge, time_badge, day_group, status_text, is_read, created_at
) VALUES
(
    1,
    'Laporan Baru Diterima!',
    'Laporan PC-LAB3 Anda sedang diproses oleh tim teknisi lab.',
    'ticket_new',
    'Tiket Saya',
    '#TRL-8821',
    'Gedung B • Lt. 2',
    '10 mnt lalu',
    'HARI INI',
    'Diproses',
    0,
    '2026-11-04T09:15:00'
),
(
    2,
    'Inspeksi Lift Terjadwal',
    'Lift Utama Gedung A dinonaktifkan sementara untuk pengujian sensor beban. Gunakan tangga darurat timur.',
    'campus_schedule',
    'Kampus',
    NULL,
    '13:00 - 15:30 WIB',
    '1 jam lalu',
    'HARI INI',
    'Terjadwal',
    0,
    '2026-11-04T08:30:00'
),
(
    3,
    'Pemeliharaan AC Selesai',
    'Perbaikan filter AC di Gedung Rektorat Lt. 3 telah diselesaikan oleh Teknisi Sarpras.',
    'ticket_done',
    'Tiket Saya',
    '#TRL-8790',
    'Gedung Rektorat Lt. 3',
    'Kemarin, 16:40',
    'KEMARIN',
    'Telah Diverifikasi',
    1,
    '2026-11-03T16:40:00'
),
(
    4,
    'Proyektor Ruang Seminar',
    'Kabel HDMI & kalibrasi optik proyektor telah rampung dan siap digunakan untuk perkuliahan.',
    'ticket_done',
    'Kampus',
    '#TRL-8742',
    'Gedung C • Ruang 102',
    'Kemarin, 11:15',
    'KEMARIN',
    'Selesai',
    1,
    '2026-11-03T11:15:00'
);
