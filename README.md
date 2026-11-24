# Solvexa Mobile – Sistem Layanan Pengaduan Sarana & Prasarana Kampus
**Studi Kasus:** Universitas Trilogi  
**Platform:** Mobile App (Flutter Android `.apk` & iOS) + Local-First SQLite Backend + REST API Server + Interactive Web Simulator  
**Versi:** 1.0  

## Struktur Direktori Paket ZIP
Setelah mengekstrak arsip `Solvexa_Mobile_Trilogi_Fullstack.zip`, Anda mendapatkan struktur lengkap Front-End dan Back-End berikut:

```text
Solvexa_Mobile_Trilogi_Fullstack/
├── README.md                              # Dokumentasi utama & panduan cepat
├── docs/
│   ├── PRD_Solvexa_Mobile.md              # Dokumen Product Requirements Document (PRD)
│   └── ui_references/                     # 9 gambar referensi desain UI/UX asli
├── frontend_flutter/                      # FRONT-END & LOCAL BACKEND UTAMA (Flutter + sqflite)
│   ├── pubspec.yaml                       # Konfigurasi dependensi (sqflite, provider, mobile_scanner, image_picker, dll.)
│   ├── android/                           # Konfigurasi Android & AndroidManifest.xml (Camera, Storage, Dialer)
│   ├── assets/
│   │   ├── solvexa_seed.db                # Database SQLite awal (pre-seeded)
│   │   └── images/                        # Aset gambar & referensi
│   └── lib/
│       ├── main.dart                      # Entry point aplikasi & routing
│       ├── core/theme/                    # Design System (Palet Navy #0F1D33, Amber #F5B400, Plus Jakarta Sans)
│       ├── data/models/                   # Model data (CampusLocation, CampusAsset, TicketModel, NotificationItem)
│       ├── data/local_db/                 # BACK-END LOKAL 100% OFFLINE (DatabaseHelper sqflite + CRUD + Seeder)
│       ├── providers/                     # State Management & Role Switcher (Sivitas Akademika vs Teknisi Operasional)
│       ├── widgets/                       # Top App Bar & Bottom Navigation Bar (FAB Scan QR Kuning)
│       └── screens/                       # Implementasi seluruh 9 layar sesuai PRD & referensi UI
├── backend/                               # BACK-END SERVER EKSTERNAL & DATABASE SQLITE
│   ├── database/
│   │   ├── schema.sql                     # DDL Skema Tabel (locations, technicians, assets, tickets, notifications)
│   │   ├── seed.sql                       # Data awal Universitas Trilogi
│   │   └── solvexa_local.db               # File biner SQLite3 siap pakai
│   ├── python_api/
│   │   └── app.py                         # Zero-dependency Python REST API + SQLite Server (tanpa perlu install library)
│   └── node_api/
│       ├── package.json                   # Node.js Express + SQLite3 REST API
│       └── src/server.js                  # Endpoint REST API lengkap (/api/dashboard, /api/assets, /api/tickets, dll.)
└── web_simulator_preview/                 # SIMULATOR INTERAKTIF LANGSUNG BUKA DI BROWSER
    ├── index.html                         # Buka langsung (double-click) untuk demo interaktif seluruh 9 layar
    ├── styles.css                         # Styling sesuai Design System PRD
    └── app.js                             # Logika interaktif, Role Switcher, & simulasi Teknisi
```

## Cara Menjalankan Proyek

### 1. Menjalankan Aplikasi Mobile Flutter (`frontend_flutter/`)
Aplikasi Flutter telah dilengkapi **100% Offline Local Database (`sqflite`)** beserta fitur **Role Switcher (Sivitas Akademika & Teknisi Operasional)** di dalam aplikasi:
```bash
cd frontend_flutter
flutter pub get
flutter run
```
Untuk membangun berkas instalasi Android `.apk`:
```bash
flutter build apk --release
```

### 2. Menjalankan Simulator Interaktif Secara Instan (`web_simulator_preview/`)
Apabila Anda ingin mendemonstrasikan seluruh 9 layar beserta alur pemindaian QR, pembuatan tiket, dan simulasi Teknisi Operasional langsung di laptop/komputer tanpa emulator:
- Buka langsung berkas `web_simulator_preview/index.html` di browser, **ATAU**
- Jalankan server Backend Python + SQLite (tanpa perlu instalasi paket tambahan):
```bash
cd backend/python_api
python3 app.py
```
Lalu buka `http://localhost:8080` di browser.

### 3. Menjalankan Backend Node.js Express + SQLite (`backend/node_api/`)
```bash
cd backend/node_api
npm install
npm start
```
Server REST API akan berjalan di `http://localhost:3001` dengan database `backend/database/solvexa_local.db`.
