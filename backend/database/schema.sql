-- ============================================================================
-- SOLVEXA MOBILE - DATABASE SCHEMA (SQLite 3)
-- Studi Kasus: Sistem Layanan Pengaduan Sarana & Prasarana Universitas Trilogi
-- ============================================================================

PRAGMA foreign_keys = ON;

-- 1. Tabel Lokasi / Zona Gedung Kampus (Zona Terpantau Hari Ini)
CREATE TABLE IF NOT EXISTS locations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    code TEXT NOT NULL UNIQUE,
    building_name TEXT NOT NULL,
    floor_area TEXT NOT NULL,
    status_label TEXT NOT NULL,
    status_type TEXT NOT NULL DEFAULT 'normal', -- 'normal', 'warning', 'danger'
    gps_zone TEXT NOT NULL,
    updated_at TEXT NOT NULL
);

-- 2. Tabel Teknisi Operasional
CREATE TABLE IF NOT EXISTS technicians (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    unit_division TEXT NOT NULL,
    specialization TEXT NOT NULL,
    phone TEXT NOT NULL,
    avatar_initials TEXT NOT NULL,
    is_available INTEGER NOT NULL DEFAULT 1
);

-- 3. Tabel Aset & Fasilitas Kampus (Stiker QR)
CREATE TABLE IF NOT EXISTS assets (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    qr_code TEXT NOT NULL UNIQUE,
    asset_name TEXT NOT NULL,
    category TEXT NOT NULL, -- 'Hardware (PC/Monitor)', 'Fasilitas Ruang (AC/Gorden)', 'Sanitasi (Toilet/Air)'
    building_name TEXT NOT NULL,
    floor_room TEXT NOT NULL,
    detail_spot TEXT NOT NULL,
    unit_owner TEXT NOT NULL,
    is_verified INTEGER NOT NULL DEFAULT 1,
    status TEXT NOT NULL DEFAULT 'Online' -- 'Online', 'Maintenance', 'Rusak'
);

-- 4. Tabel Tiket Pengaduan Kerusakan
CREATE TABLE IF NOT EXISTS tickets (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ticket_number TEXT NOT NULL UNIQUE,
    asset_code TEXT NOT NULL,
    asset_name TEXT NOT NULL,
    category TEXT NOT NULL,
    category_subtitle TEXT NOT NULL,
    building_location TEXT NOT NULL,
    room_detail TEXT NOT NULL,
    description TEXT NOT NULL,
    urgency TEXT NOT NULL DEFAULT 'Sedang', -- 'Rendah', 'Sedang', 'Darurat'
    priority_label TEXT NOT NULL DEFAULT 'Prioritas Normal',
    status TEXT NOT NULL DEFAULT 'Dilaporkan', -- 'Dilaporkan', 'Diproses Teknisi', 'Selesai'
    photo_paths TEXT NOT NULL DEFAULT '[]', -- JSON array nama/path berkas foto bukti
    technician_id INTEGER,
    technician_name TEXT NOT NULL DEFAULT 'Bima Arya',
    technician_unit TEXT NOT NULL DEFAULT 'Unit Hardware',
    technician_phone TEXT NOT NULL DEFAULT '+6281290001234',
    estimated_response TEXT NOT NULL DEFAULT 'Maks. 15-30 Menit',
    estimated_completion TEXT NOT NULL DEFAULT '~25 MENIT',
    field_note TEXT NOT NULL DEFAULT '',
    field_note_updated_at TEXT NOT NULL DEFAULT '',
    reported_at TEXT NOT NULL,
    processed_at TEXT,
    completed_at TEXT,
    reporter_name TEXT NOT NULL DEFAULT 'Sivitas Trilogi',
    reporter_initials TEXT NOT NULL DEFAULT 'ST',
    FOREIGN KEY (technician_id) REFERENCES technicians(id)
);

-- 5. Tabel Riwayat Notifikasi & Pembaruan Kampus
CREATE TABLE IF NOT EXISTS notifications (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    notif_type TEXT NOT NULL, -- 'ticket_new', 'campus_schedule', 'ticket_done'
    filter_category TEXT NOT NULL, -- 'Tiket Saya', 'Kampus'
    ticket_number TEXT,
    location_badge TEXT NOT NULL,
    time_badge TEXT NOT NULL,
    day_group TEXT NOT NULL DEFAULT 'HARI INI', -- 'HARI INI', 'KEMARIN'
    status_text TEXT,
    is_read INTEGER NOT NULL DEFAULT 0,
    created_at TEXT NOT NULL
);

-- 6. Tabel Pengaturan Aplikasi & Simulasi Peran Lokal
CREATE TABLE IF NOT EXISTS app_settings (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL
);
