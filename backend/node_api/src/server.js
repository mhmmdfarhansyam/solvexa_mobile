/**
 * SOLVEXA MOBILE - BACKEND SERVER (Express + SQLite3)
 * Studi Kasus: Universitas Trilogi
 * Catatan: Sesuai PRD, aplikasi Flutter memiliki arsitektur 100% Offline Local-First (sqflite),
 * namun server REST API ini juga disediakan lengkap agar dapat dijalankan secara terpisah
 * maupun disinkronkan dengan front-end mobile/web.
 */
const express = require('express');
const cors = require('cors');
const path = require('path');
const fs = require('fs');
const sqlite3 = require('sqlite3').verbose();

const app = express();
const PORT = process.env.PORT || 3001;
const DB_PATH = path.join(__dirname, '../../database/solvexa_local.db');
const SCHEMA_PATH = path.join(__dirname, '../../database/schema.sql');
const SEED_PATH = path.join(__dirname, '../../database/seed.sql');

app.use(cors());
app.use(express.json());
app.use('/static', express.static(path.join(__dirname, '../../../web_simulator_preview')));

const db = new sqlite3.Database(DB_PATH, (err) => {
  if (err) {
    console.error('Gagal membuka database SQLite:', err.message);
  } else {
    console.log('Terhubung ke SQLite database:', DB_PATH);
  }
});

// Helper query Promise
const dbAll = (sql, params = []) => new Promise((resolve, reject) => {
  db.all(sql, params, (err, rows) => (err ? reject(err) : resolve(rows)));
});
const dbGet = (sql, params = []) => new Promise((resolve, reject) => {
  db.get(sql, params, (err, row) => (err ? reject(err) : resolve(row)));
});
const dbRun = (sql, params = []) => new Promise((resolve, reject) => {
  db.run(sql, params, function (err) {
    if (err) reject(err);
    else resolve({ lastID: this.lastID, changes: this.changes });
  });
});

// 1. Endpoint Dashboard Summary & Locations
app.get('/api/dashboard', async (req, res) => {
  try {
    const activeTickets = await dbAll(
      "SELECT * FROM tickets WHERE status IN ('Dilaporkan', 'Diproses Teknisi') ORDER BY id DESC"
    );
    const completedTickets = await dbAll(
      "SELECT * FROM tickets WHERE status = 'Selesai'"
    );
    const baselineSetting = await dbGet(
      "SELECT value FROM app_settings WHERE key = 'completed_this_month_baseline'"
    );
    const roleSetting = await dbGet(
      "SELECT value FROM app_settings WHERE key = 'active_role'"
    );
    const locations = await dbAll('SELECT * FROM locations ORDER BY id ASC');
    const unreadNotifs = await dbGet(
      'SELECT COUNT(*) as count FROM notifications WHERE is_read = 0'
    );

    const parsedTickets = activeTickets.map((t) => ({
      ...t,
      photo_paths: JSON.parse(t.photo_paths || '[]'),
    }));

    res.json({
      status: 'success',
      data: {
        active_role: roleSetting ? roleSetting.value : 'sivitas',
        active_ticket_count: parsedTickets.length,
        completed_this_month:
          (baselineSetting ? parseInt(baselineSetting.value, 10) : 14) +
          completedTickets.length,
        avg_speed: '2 jam',
        latest_active_ticket: parsedTickets[0] || null,
        active_tickets: parsedTickets,
        locations,
        unread_notifications_count: unreadNotifs ? unreadNotifs.count : 0,
      },
    });
  } catch (err) {
    res.status(500).json({ status: 'error', message: err.message });
  }
});

// 2. Endpoint Daftar Aset & Verifikasi Kode QR
app.get('/api/assets', async (req, res) => {
  try {
    const assets = await dbAll('SELECT * FROM assets ORDER BY id ASC');
    res.json({ status: 'success', data: assets });
  } catch (err) {
    res.status(500).json({ status: 'error', message: err.message });
  }
});

app.get('/api/assets/verify/:qrCode', async (req, res) => {
  try {
    const code = req.params.qrCode.trim().toUpperCase();
    let asset = await dbGet('SELECT * FROM assets WHERE UPPER(qr_code) = ?', [code]);
    if (!asset) {
      // Fallback jika kode baru dipindai saat demo
      asset = {
        id: 99,
        qr_code: code,
        asset_name: `Unit Fasilitas (${code})`,
        category: 'Hardware (PC/Monitor)',
        building_name: 'Gedung Riset Informatika • Lt. 2',
        floor_room: 'Lab Komputer 3 • Gedung B, Lantai 2',
        detail_spot: 'Gedung Riset Sains • Lab 3 (Meja 14)',
        unit_owner: 'Unit TI Trilogi',
        is_verified: 1,
        status: 'Online',
      };
    }
    res.json({ status: 'success', data: asset });
  } catch (err) {
    res.status(500).json({ status: 'error', message: err.message });
  }
});

// 3. Endpoint Tiket (List, Detail, Create, Update Status / Catatan Lapangan Teknisi)
app.get('/api/tickets', async (req, res) => {
  try {
    const rows = await dbAll('SELECT * FROM tickets ORDER BY id DESC');
    const data = rows.map((r) => ({
      ...r,
      photo_paths: JSON.parse(r.photo_paths || '[]'),
    }));
    res.json({ status: 'success', data });
  } catch (err) {
    res.status(500).json({ status: 'error', message: err.message });
  }
});

app.get('/api/tickets/:id', async (req, res) => {
  try {
    const row = await dbGet('SELECT * FROM tickets WHERE id = ? OR ticket_number = ?', [
      req.params.id,
      req.params.id,
    ]);
    if (!row) return res.status(404).json({ status: 'error', message: 'Tiket tidak ditemukan' });
    row.photo_paths = JSON.parse(row.photo_paths || '[]');
    res.json({ status: 'success', data: row });
  } catch (err) {
    res.status(500).json({ status: 'error', message: err.message });
  }
});

app.post('/api/tickets', async (req, res) => {
  try {
    const {
      asset_code = 'PC-LAB3',
      category = 'Hardware (PC/Monitor)',
      description = '',
      urgency = 'Sedang',
      photo_paths = ['monitor_freeze_error.jpg'],
    } = req.body;

    const asset = await dbGet('SELECT * FROM assets WHERE UPPER(qr_code) = ?', [
      asset_code.toUpperCase(),
    ]);
    const countRow = await dbGet('SELECT COUNT(*) as cnt FROM tickets');
    const nextNum = (countRow ? countRow.cnt : 0) + 1;
    const ticketNumber = `#SLV-${String(nextNum).padStart(3, '0')}`;

    const categorySubtitles = {
      'Hardware (PC/Monitor)': 'Unit CPU, layar monitor, periferal',
      'Fasilitas Ruang (AC/Gorden)': 'Pendingin, pencahayaan, ventilasi',
      'Sanitasi (Toilet/Air)': 'Wastafel, kran air, saluran',
    };

    const priorityLabel =
      urgency === 'Darurat'
        ? 'Prioritas Tinggi'
        : urgency === 'Rendah'
        ? 'Prioritas Rendah'
        : 'Prioritas Normal';

    const nowStr = '4 Nov 2026, 09:15';
    const buildingLocation = asset
      ? asset.floor_room
      : 'Lab Komputer 3 • Gedung B, Lantai 2';
    const roomDetail = asset
      ? asset.detail_spot
      : 'Gedung Riset Sains • Lab 3 (Meja 14)';
    const assetName = asset ? asset.asset_name : `Fasilitas ${asset_code}`;

    const result = await dbRun(
      `INSERT INTO tickets (
        ticket_number, asset_code, asset_name, category, category_subtitle,
        building_location, room_detail, description, urgency, priority_label,
        status, photo_paths, technician_id, technician_name, technician_unit,
        technician_phone, estimated_response, estimated_completion,
        field_note, field_note_updated_at, reported_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        ticketNumber,
        asset_code,
        assetName,
        category,
        categorySubtitles[category] || 'Unit fasilitas kampus',
        buildingLocation,
        roomDetail,
        description || 'Monitor blank hitam berulang & indikator kipas PSU berbunyi keras.',
        urgency,
        priorityLabel,
        'Dilaporkan',
        JSON.stringify(photo_paths),
        1,
        'Bima Arya',
        'Unit Hardware',
        '+6281288001122',
        'Maks. 15-30 Menit',
        '~25 MENIT',
        'Tiket baru diterima oleh Pusat Kendali Kampus. Menunggu pemeriksaan awal teknisi di lokasi.',
        '09:15 WIB',
        nowStr,
      ]
    );

    // Buat notifikasi otomatis
    await dbRun(
      `INSERT INTO notifications (
        title, message, notif_type, filter_category, ticket_number,
        location_badge, time_badge, day_group, status_text, is_read, created_at
      ) VALUES (?, ?, 'ticket_new', 'Tiket Saya', ?, 'Gedung B • Lt. 2', 'Baru saja', 'HARI INI', 'Dilaporkan', 0, datetime('now'))`,
      [
        'Laporan Baru Diterima!',
        `Laporan ${asset_code} Anda sedang diproses oleh tim teknisi lab.`,
        ticketNumber,
      ]
    );

    const created = await dbGet('SELECT * FROM tickets WHERE id = ?', [result.lastID]);
    created.photo_paths = JSON.parse(created.photo_paths || '[]');
    res.status(201).json({ status: 'success', data: created });
  } catch (err) {
    res.status(500).json({ status: 'error', message: err.message });
  }
});

// Simulasi Teknisi Operasional: Ubah status tiket & catatan lapangan
app.patch('/api/tickets/:id/status', async (req, res) => {
  try {
    const { status, field_note, estimated_completion, photo_paths } = req.body;
    const ticket = await dbGet('SELECT * FROM tickets WHERE id = ?', [req.params.id]);
    if (!ticket) return res.status(404).json({ status: 'error', message: 'Tiket tidak ditemukan' });

    const newStatus = status || ticket.status;
    const newNote = field_note !== undefined ? field_note : ticket.field_note;
    const newEst = estimated_completion || ticket.estimated_completion;
    const newPhotos = photo_paths
      ? JSON.stringify(photo_paths)
      : ticket.photo_paths;

    let techName = ticket.technician_name;
    let techUnit = ticket.technician_unit;
    if (newStatus === 'Diproses Teknisi') {
      techName = 'Hendra Pratama';
      techUnit = 'Divisi Sarpras & Lab IT';
    }

    await dbRun(
      `UPDATE tickets
       SET status = ?, field_note = ?, field_note_updated_at = '09:22 WIB',
           estimated_completion = ?, photo_paths = ?,
           technician_name = ?, technician_unit = ?,
           processed_at = CASE WHEN ? = 'Diproses Teknisi' THEN '4 Nov 2026, 09:20' ELSE processed_at END,
           completed_at = CASE WHEN ? = 'Selesai' THEN '4 Nov 2026, 09:40' ELSE completed_at END
       WHERE id = ?`,
      [newStatus, newNote, newEst, newPhotos, techName, techUnit, newStatus, newStatus, req.params.id]
    );

    // Tambah notifikasi perubahan status
    await dbRun(
      `INSERT INTO notifications (
        title, message, notif_type, filter_category, ticket_number,
        location_badge, time_badge, day_group, status_text, is_read, created_at
      ) VALUES (?, ?, ?, 'Tiket Saya', ?, 'Gedung B • Lt. 2', 'Baru saja', 'HARI INI', ?, 0, datetime('now'))`,
      [
        newStatus === 'Selesai' ? `Perbaikan ${ticket.asset_code} Selesai` : `Status Tiket Diperbarui`,
        `Tiket ${ticket.ticket_number} (${ticket.asset_code}) kini berstatus: ${newStatus}.`,
        newStatus === 'Selesai' ? 'ticket_done' : 'ticket_new',
        ticket.ticket_number,
        newStatus === 'Selesai' ? 'Telah Diverifikasi' : newStatus,
      ]
    );

    const updated = await dbGet('SELECT * FROM tickets WHERE id = ?', [req.params.id]);
    updated.photo_paths = JSON.parse(updated.photo_paths || '[]');
    res.json({ status: 'success', data: updated });
  } catch (err) {
    res.status(500).json({ status: 'error', message: err.message });
  }
});

// 4. Endpoint Notifikasi
app.get('/api/notifications', async (req, res) => {
  try {
    const filter = req.query.filter || 'Semua';
    let sql = 'SELECT * FROM notifications ORDER BY id ASC';
    let params = [];
    if (filter === 'Belum Dibaca') {
      sql = 'SELECT * FROM notifications WHERE is_read = 0 ORDER BY id ASC';
    } else if (filter === 'Tiket Saya' || filter === 'Kampus') {
      sql = 'SELECT * FROM notifications WHERE filter_category = ? ORDER BY id ASC';
      params = [filter];
    }
    const rows = await dbAll(sql, params);
    const unreadRow = await dbGet('SELECT COUNT(*) as cnt FROM notifications WHERE is_read = 0');
    res.json({
      status: 'success',
      unread_count: unreadRow ? unreadRow.cnt : 0,
      data: rows,
    });
  } catch (err) {
    res.status(500).json({ status: 'error', message: err.message });
  }
});

app.post('/api/notifications/mark-all-read', async (req, res) => {
  try {
    await dbRun('UPDATE notifications SET is_read = 1');
    res.json({ status: 'success', message: 'Semua notifikasi ditandai telah dibaca' });
  } catch (err) {
    res.status(500).json({ status: 'error', message: err.message });
  }
});

// 5. Endpoint Role Switcher & Demo State Reset
app.post('/api/demo/role', async (req, res) => {
  try {
    const { role } = req.body; // 'sivitas' | 'teknisi'
    await dbRun("INSERT OR REPLACE INTO app_settings (key, value) VALUES ('active_role', ?)", [
      role || 'sivitas',
    ]);
    res.json({ status: 'success', active_role: role || 'sivitas' });
  } catch (err) {
    res.status(500).json({ status: 'error', message: err.message });
  }
});

app.post('/api/demo/reset', async (req, res) => {
  try {
    const { mode } = req.body; // 'empty' | 'seeded'
    const schemaSql = fs.readFileSync(SCHEMA_PATH, 'utf-8');
    const seedSql = fs.readFileSync(SEED_PATH, 'utf-8');
    db.serialize(() => {
      db.exec('DROP TABLE IF EXISTS notifications; DROP TABLE IF EXISTS tickets;');
      db.exec(schemaSql);
      db.exec(seedSql);
      if (mode === 'empty') {
        db.exec("DELETE FROM tickets; DELETE FROM notifications;");
      }
      res.json({ status: 'success', mode: mode || 'seeded' });
    });
  } catch (err) {
    res.status(500).json({ status: 'error', message: err.message });
  }
});

app.listen(PORT, () => {
  console.log(`Solvexa Backend API berjalan di http://localhost:${PORT}`);
});
