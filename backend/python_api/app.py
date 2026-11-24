#!/usr/bin/env python3
"""
SOLVEXA MOBILE - ZERO-DEPENDENCY PYTHON REST API & SQLITE BACKEND SERVER
Studi Kasus: Universitas Trilogi
Dapat dijalankan langsung tanpa instalasi library tambahan:
    python3 app.py
Menyediakan REST API lengkap (/api/*) sekaligus melayani Web Simulator di http://localhost:8080
"""
import json
import os
import sqlite3
from http.server import SimpleHTTPRequestHandler, HTTPServer
from urllib.parse import urlparse, parse_qs

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DB_PATH = os.path.abspath(os.path.join(BASE_DIR, "../database/solvexa_local.db"))
SCHEMA_PATH = os.path.abspath(os.path.join(BASE_DIR, "../database/schema.sql"))
SEED_PATH = os.path.abspath(os.path.join(BASE_DIR, "../database/seed.sql"))
WEB_DIR = os.path.abspath(os.path.join(BASE_DIR, "../../web_simulator_preview"))

def get_conn():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn

class SolvexaAPIHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=WEB_DIR, **kwargs)

    def _send_json(self, data, status=200):
        raw = json.dumps(data, ensure_ascii=False).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, PATCH, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.send_header("Content-Length", str(len(raw)))
        self.end_headers()
        self.wfile.write(raw)

    def do_OPTIONS(self):
        self._send_json({"status": "ok"})

    def do_GET(self):
        parsed = urlparse(self.path)
        path = parsed.path
        query = parse_qs(parsed.query)

        if path == "/api/dashboard":
            conn = get_conn()
            active = [dict(r) for r in conn.execute(
                "SELECT * FROM tickets WHERE status IN ('Dilaporkan', 'Diproses Teknisi') ORDER BY id DESC"
            ).fetchall()]
            for t in active:
                t["photo_paths"] = json.loads(t.get("photo_paths") or "[]")
            completed_cnt = conn.execute("SELECT COUNT(*) FROM tickets WHERE status = 'Selesai'").fetchone()[0]
            locations = [dict(r) for r in conn.execute("SELECT * FROM locations ORDER BY id ASC").fetchall()]
            unread_cnt = conn.execute("SELECT COUNT(*) FROM notifications WHERE is_read = 0").fetchone()[0]
            role_row = conn.execute("SELECT value FROM app_settings WHERE key = 'active_role'").fetchone()
            conn.close()
            return self._send_json({
                "status": "success",
                "data": {
                    "active_role": role_row[0] if role_row else "sivitas",
                    "active_ticket_count": len(active),
                    "completed_this_month": 14 + completed_cnt,
                    "avg_speed": "2 jam",
                    "latest_active_ticket": active[0] if active else None,
                    "active_tickets": active,
                    "locations": locations,
                    "unread_notifications_count": unread_cnt,
                }
            })

        if path == "/api/assets":
            conn = get_conn()
            assets = [dict(r) for r in conn.execute("SELECT * FROM assets ORDER BY id ASC").fetchall()]
            conn.close()
            return self._send_json({"status": "success", "data": assets})

        if path.startswith("/api/assets/verify/"):
            code = path.split("/api/assets/verify/")[-1].strip().upper()
            conn = get_conn()
            row = conn.execute("SELECT * FROM assets WHERE UPPER(qr_code) = ?", (code,)).fetchone()
            conn.close()
            if row:
                asset = dict(row)
            else:
                asset = {
                    "id": 99,
                    "qr_code": code,
                    "asset_name": f"Unit Fasilitas ({code})",
                    "category": "Hardware (PC/Monitor)",
                    "building_name": "Gedung Riset Informatika • Lt. 2",
                    "floor_room": "Lab Komputer 3 • Gedung B, Lantai 2",
                    "detail_spot": "Gedung Riset Sains • Lab 3 (Meja 14)",
                    "unit_owner": "Unit TI Trilogi",
                    "is_verified": 1,
                    "status": "Online",
                }
            return self._send_json({"status": "success", "data": asset})

        if path == "/api/tickets":
            conn = get_conn()
            rows = [dict(r) for r in conn.execute("SELECT * FROM tickets ORDER BY id DESC").fetchall()]
            for r in rows:
                r["photo_paths"] = json.loads(r.get("photo_paths") or "[]")
            conn.close()
            return self._send_json({"status": "success", "data": rows})

        if path == "/api/notifications":
            flt = query.get("filter", ["Semua"])[0]
            conn = get_conn()
            if flt == "Belum Dibaca":
                rows = conn.execute("SELECT * FROM notifications WHERE is_read = 0 ORDER BY id ASC").fetchall()
            elif flt in ("Tiket Saya", "Kampus"):
                rows = conn.execute("SELECT * FROM notifications WHERE filter_category = ? ORDER BY id ASC", (flt,)).fetchall()
            else:
                rows = conn.execute("SELECT * FROM notifications ORDER BY id ASC").fetchall()
            unread_cnt = conn.execute("SELECT COUNT(*) FROM notifications WHERE is_read = 0").fetchone()[0]
            data = [dict(r) for r in rows]
            conn.close()
            return self._send_json({"status": "success", "unread_count": unread_cnt, "data": data})

        return super().do_GET()

    def do_POST(self):
        parsed = urlparse(self.path)
        path = parsed.path
        length = int(self.headers.get("Content-Length", 0))
        body = json.loads(self.rfile.read(length).decode("utf-8")) if length > 0 else {}

        if path == "/api/tickets":
            conn = get_conn()
            asset_code = body.get("asset_code", "PC-LAB3")
            category = body.get("category", "Hardware (PC/Monitor)")
            description = body.get("description", "Monitor blank hitam berulang & indikator kipas PSU berbunyi keras.")
            urgency = body.get("urgency", "Sedang")
            photos = body.get("photo_paths", ["monitor_freeze_error.jpg"])

            cnt = conn.execute("SELECT COUNT(*) FROM tickets").fetchone()[0] + 1
            ticket_num = f"#SLV-{cnt:03d}"
            priority = "Prioritas Tinggi" if urgency == "Darurat" else ("Prioritas Rendah" if urgency == "Rendah" else "Prioritas Normal")

            cur = conn.execute(
                """INSERT INTO tickets (
                    ticket_number, asset_code, asset_name, category, category_subtitle,
                    building_location, room_detail, description, urgency, priority_label,
                    status, photo_paths, technician_id, technician_name, technician_unit,
                    technician_phone, estimated_response, estimated_completion,
                    field_note, field_note_updated_at, reported_at
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'Dilaporkan', ?, 1, 'Bima Arya', 'Unit Hardware',
                          '+6281288001122', 'Maks. 15-30 Menit', '~25 MENIT',
                          'Tiket berhasil dibuat oleh sivitas akademika via Solvexa Mobile. Menunggu pemeriksaan awal teknisi.',
                          '09:15 WIB', '4 Nov 2026, 09:15')""",
                (
                    ticket_num,
                    asset_code,
                    f"Unit {asset_code}",
                    category,
                    "Unit CPU, layar monitor, periferal",
                    "Lab Komputer 3 • Gedung B, Lantai 2",
                    "Gedung Riset Sains • Lab 3 (Meja 14)",
                    description,
                    urgency,
                    priority,
                    json.dumps(photos),
                )
            )
            conn.commit()
            row = dict(conn.execute("SELECT * FROM tickets WHERE id = ?", (cur.lastrowid,)).fetchone())
            row["photo_paths"] = json.loads(row["photo_paths"])
            conn.close()
            return self._send_json({"status": "success", "data": row}, 201)

        if path == "/api/notifications/mark-all-read":
            conn = get_conn()
            conn.execute("UPDATE notifications SET is_read = 1")
            conn.commit()
            conn.close()
            return self._send_json({"status": "success"})

        if path == "/api/demo/reset":
            mode = body.get("mode", "seeded")
            conn = get_conn()
            with open(SCHEMA_PATH, "r", encoding="utf-8") as f:
                conn.executescript(f.read())
            with open(SEED_PATH, "r", encoding="utf-8") as f:
                conn.executescript(f.read())
            if mode == "empty":
                conn.executescript("DELETE FROM tickets; DELETE FROM notifications;")
            conn.commit()
            conn.close()
            return self._send_json({"status": "success", "mode": mode})

        return self._send_json({"status": "error", "message": "Endpoint tidak ditemukan"}, 404)

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8080))
    print(f"============================================================")
    print(f" SOLVEXA MOBILE BACKEND & WEB SIMULATOR")
    print(f" Server berjalan di: http://localhost:{port}")
    print(f" Database SQLite   : {DB_PATH}")
    print(f"============================================================")
    HTTPServer(("0.0.0.0", port), SolvexaAPIHandler).serve_forever()
