# Product Requirements Document (PRD)
**Nama Produk:** Solvexa Mobile – Sistem Layanan Pengaduan Sarana & Prasarana Kampus  
**Studi Kasus:** Universitas Trilogi  
**Platform:** Mobile App (Android `.apk` & iOS) berbasis Flutter  
**Arsitektur Sistem:** Standalone Local-First (100% Offline menggunakan SQLite Lokal tanpa REST API)  
**Versi Dokumen:** 1.0  

---

## 1. Ringkasan Eksekutif & Tujuan Produk
Solvexa Mobile adalah aplikasi layanan sivitas akademika Universitas Trilogi untuk memantau, melaporkan, dan melacak penanganan kerusakan fasilitas kampus secara terstruktur. Aplikasi ini mengandalkan pemindaian stiker kode QR pada tiap aset atau ruangan (seperti unit PC laboratorium, AC, proyektor, dan sanitasi) untuk mempercepat identifikasi lokasi dan penugasan teknisi.

Agar ramah bagi pengembangan proyek mahasiswa dan bebas dari biaya maupun kendala infrastruktur server, aplikasi ini dibangun dengan arsitektur **100% Offline Local Database (`sqflite`)**. Seluruh proses dari pemindaian QR, unggah foto bukti, pembuatan tiket, notifikasi, hingga simulasi pembaruan status oleh teknisi berjalan langsung di dalam penyimpanan perangkat.

---

## 2. Peran Pengguna & Mekanisme Simulasi Tanpa API
Karena sistem tidak menggunakan *backend* eksternal untuk menghubungkan dua perangkat berbeda, aplikasi menerapkan fitur **Role Switcher (Simulasi Peran Lokal)** di dalam satu aplikasi:

* **Sivitas Akademika (Pelapor Default):** Memindai kode QR fasilitas, mengisi form kendala beserta foto bukti, memantau *timeline* progres perbaikan, dan melihat notifikasi pemeliharaan kampus.
* **Teknisi Operasional (Mode Simulasi / Demo):** Mengubah status tiket yang masuk (*Dilaporkan* $\rightarrow$ *Diproses Teknisi* $\rightarrow$ *Selesai*), memperbarui estimasi waktu, dan menambahkan *Catatan Lapangan Teknisi* secara langsung dari halaman detail tiket untuk kebutuhan demonstrasi aplikasi.

---

## 3. Sistem Desain & Panduan UI/UX (Design System)

### 3.1 Palet Warna (Color Palette)
* **Primary Navy:** `#0F1D33` — Digunakan pada logo header, avatar inisial (`ST`), kartu status penanganan aktif, dan tombol aksi utama (*Kirim Laporan*, *Lacak Status Laporan*, *Periksa Pembaruan*, *Segarkan Status*).
* **Accent Amber / Gold:** `#F5B400` — Digunakan pada tombol utama **Scan QR Lapor**, tombol mengambang (FAB) tengah di *Bottom Navigation Bar*, dan indikator prioritas.
* **Background & Surface:** `#F8FAFC` (latar belakang layar utama), `#FFFFFF` (permukaan kartu), dan `#F1F5F9` (latar *input field* & kartu sekunder).
* **Semantic Status Colors:**
  * **Success / Normal / Terverifikasi:** `#10B981` (Teks/Ikon) & `#D1FAE5` (Badge Background).
  * **Warning / Menunggu / Sedang:** `#F59E0B` (Teks/Ikon) & `#FEF3C7` (Badge Background).
  * **Danger / Darurat:** `#EF4444` (Indikator titik urgensi darurat).
  * **Text Hierarchy:** `#0F172A` (Heading utama), `#475569` (Sub-judul & deskripsi), `#94A3B8` (Teks *placeholder* & keterangan waktu).

### 3.2 Tipografi & Komponen Navigasi
* **Font Family:** *Plus Jakarta Sans* atau *Inter* (`google_fonts`).
* **Top App Bar:** Menampilkan ikon kunci pas (*wrench*) di dalam kotak *navy* bulat, teks kecil `UNIVERSITAS TRILOGI`, judul halaman tebal (`Home`, `Scan Qr`, `Notifications`), dan ikon pencarian di sisi kanan.
* **Bottom Navigation Bar:** Terdiri dari 3 menu tetap:
  1. **Home** (Ikon rumah)
  2. **Scan QR** (Tombol bulat kuning menonjol / FAB di tengah)
  3. **Updates** (Ikon lonceng notifikasi)

---

## 4. Spesifikasi Fungsional Per Layar (Berdasarkan Referensi UI)

### 4.1 Beranda – Kondisi Kosong (`Beranda - Kosong`)
Ditampilkan ketika belum ada tiket laporan berstatus aktif (`Dilaporkan` atau `Diproses Teknisi`) di SQLite:
* **Sub-Header Profil:** Thumbnail ilustrasi di kiri, tombol ikon lonceng notifikasi, dan avatar lingkaran `#0F1D33` bertuliskan `ST`.
* **Sapaan & Tanggal:** Menampilkan tanggal berjalan (contoh: `Rabu, 4 November 2026`), judul `Halo, Sivitas Trilogi! 👋`, dan sub-teks `Pantau dan jaga kenyamanan sarana kampus kita bersama.`
* **Kartu Ringkasan (2 Kolom):**
  * **Laporan Aktif:** `0 tiket` dengan indikator titik hijau `Semua tertangani`.
  * **Selesai Bulan Ini:** Menghitung jumlah tiket berstatus `Selesai` di SQLite (contoh: `14 fasilitas`) dengan keterangan `Kecepatan avg. 2 jam`.
* **Kartu Hero Empty State:** Ikon papan klip centang dengan *badge* `Sistem Siaga Operasional`, teks `Belum ada laporan kerusakan. Fasilitas aman!`, dan tautan teks `Panduan pelaporan sarana kampus ->`.
* **Horizontal List – Zona Terpantau Hari Ini:** Menampilkan kartu status gedung dari tabel `locations`:
  * *Gedung Rektorat:* `Lt. 1 - 4 Normal` (`Kondusif`).
  * *Lab Komputer:* `Lab A, B, & C` (`Siap Digunakan`).
  * *Perpustakaan:* `Ruang Koleksi` (`AC Stabil 22°C`).
* **CTA Utama:** Tombol penuh berwarna kuning `#F5B400` bertuliskan `Scan QR Lapor`.

### 4.2 Beranda – Kondisi Ada Laporan Aktif (`Beranda - Laporan Aktif`)
Ditampilkan otomatis setelah pengguna mengirim minimal 1 tiket laporan yang belum berstatus `Selesai`:
* **Label Atas:** Ikon perisai centang dengan teks `LAYANAN SARANA KAMPUS`.
* **Kartu Status Penanganan (Dark Navy Gradient):** Menampilkan jumlah laporan aktif (contoh: `1 Laporan Aktif`), sub-teks `Tiket dalam antrean respon prioritas fasilitas`, dan *footer bar* `Est. Waktu Penanganan: < 30 mnt`.
* **Bagian Laporan Terbaru:** Menampilkan kartu tiket terbaru yang berisi:
  * Ikon kategori, judul kode aset & kategori (`PC-LAB3 | Hardware...`), nomor tiket (`ID: #TRL-2024-089`), dan *badge* kuning `Menunggu Teknisi`.
  * Foto bukti kerusakan dengan *overlay* lokasi `Gedung Riset Sains • Lab 3 (Meja 14)`.
  * Keterangan waktu (`Baru saja dilaporkan`) dan *badge* `Unit TI Trilogi`.
* **Aksi Cepat:** Tombol kuning `Scan QR Lapor` diikuti 2 kartu menu berdampingan:
  * **Cek Aset Lab:** `Database barang ruang` (membuka daftar aset lokal di SQLite).
  * **Kontak Helpdesk:** `Layanan siaga cepat` (membuka *dialer* telepon/WhatsApp via `url_launcher`).

### 4.3 Pemindai QR Kamera (`Scan QR Kamera`)
* **Viewfinder Kamera:** Mengakses kamera belakang menggunakan `mobile_scanner` dengan indikator *pill* hijau `CAMERA ACTIVE`, tombol kembali di kiri atas, dan tombol *flash/blitz* di kanan atas.
* **Bingkai Pemindai:** Kotak transparan bersudut kuning tebal dengan garis laser horizontal kuning di tengah dan label bayangan kode (contoh: `TRILOGI-FAC-01`).
* **Aksi Alternatif (Di Dalam Kamera):**
  * **Upload Foto:** Memilih gambar kode QR dari galeri ponsel.
  * **Input Manual:** Membuka *bottom sheet* untuk mengetik atau memilih langsung kode aset (seperti `PC-LAB3` atau `TRILOGI-FAC-01`) jika kamera tidak digunakan saat pengujian di emulator.
* **Kartu Lokasi Terdeteksi (Bawah):** Menampilkan *badge* hijau `GPS Siap`, nama gedung (`Gedung Rektorat & Kuliah`), dan detail lantai (`Lantai 3 • Koridor Sayap Timur`).

### 4.4 Form Laporan Baru (`Form Laporan - Default` & `Dropdown Terbuka`)
Halaman **New Ticket** terbuka otomatis setelah kode QR berhasil diverifikasi:
* **Kartu Identitas Aset Terpindai:**
  * Menampilkan kode aset (`PC-LAB3`), lokasi (`Gedung Riset Informatika • Lt. 2` / `Gedung Riset Sains • Lt. 3`), serta *badge* hijau `Terverifikasi` / `Online` dan ikon gembok (*read-only*).
* **Dropdown Kategori Kerusakan (`*Wajib`):**
  * Pilihan kustom dengan ikon dan sub-deskripsi:
    1. **Hardware (PC/Monitor):** `Unit CPU, layar monitor, periferal`
    2. **Fasilitas Ruang (AC/Gorden):** `Pendingin, pencahayaan, ventilasi`
    3. **Sanitasi (Toilet/Air):** `Wastafel, kran air, saluran`
* **Input Deskripsi Kendala:** *Text area* dengan penghitung karakter `0 / 250`, *placeholder* `Jelaskan detail kendala atau kerusakan yang dialami...`, dan kotak info contoh pengisian.
* **Unggah Foto Bukti (`Opsional`):**
  * Menggunakan `image_picker` (maksimal 3 foto, format JPG/PNG).
  * Ketika foto dipilih, tampilkan kotak tombol `Ambil / Unggah` di sebelah kiri dan *thumbnail* pratinjau foto (contoh: `bukti_lab3_01.jpg`) dengan tanda centang di sebelah kanan.
* **Pemilih Tingkat Urgensi:** 3 tombol pilihan (*segmented card*):
  * `Rendah` (Titik abu-abu)
  * `Sedang` (Titik kuning – *default*)
  * `Darurat` (Titik merah)
* **Tombol Submit:** Tombol *navy* penuh `Kirim Laporan` yang menyimpan data ke tabel `tickets` dan `notifications` di SQLite.

### 4.5 Konfirmasi Laporan Terkirim (`Laporan Berhasil Terkirim`)
* **Visual Sukses:** Lingkaran hijau besar dengan centang putih dan *badge* kuning `⚡ Kilat`, diikuti *pill* nomor tiket `#SLV-001 • Prioritas Normal`.
* **Judul & Sub-judul:** `Laporan Berhasil Terkirim!` — `Laporan PC-LAB3 telah masuk ke antrean teknisi kampus.`
* **Kartu Estimasi Respon:** Menampilkan `Maks. 15-30 Menit` dengan *badge* `Otomatis`, *progress bar* hijau, serta info lokasi (`Gedung Teknik Lt. 2` & `Lab Komputer B`).
* **Kartu Teknisi Bertugas:** Menampilkan foto avatar teknisi, nama `Bima Arya (Unit Hardware)`, dan tombol ikon pesan di kanan.
* **Lampiran Bukti Masalah:** Pratinjau gambar yang diunggah beserta nama file (`monitor_freeze_error.jpg`) dan ikon mata (lihat gambar penuh).
* **Tombol Navigasi:** `Lacak Status Laporan` (mengarahkan ke layar *Timeline*) dan `Kembali ke Beranda`.

### 4.6 Pelacakan Status Laporan (`Status Laporan - Timeline`)
* **Baris Navigasi Atas:** Tombol `<- Kembali`, *badge* kuning `PRIORITAS TINGGI`, dan tombol *share*.
* **Kartu Header Tiket:** Menampilkan `ID: #SLV-001`, `Aset: PC-LAB3`, stempel waktu `4 Nov 2026, 09:15`, judul kategori `Hardware (PC / Monitor)`, lokasi `Lab Komputer 3 • Gedung B, Lantai 2`, dan kotak ringkasan `GEJALA MASALAH` beserta *thumbnail* foto.
* **Kartu Alur Penanganan (Stepper Vertikal):**
  1. **Dilaporkan (`09:15 WIB`):** Ikon centang hijau. `Tiket berhasil dibuat oleh sivitas akademika via Solvexa Mobile` (`Terverifikasi Otomatis Sistem`).
  2. **Diproses Teknisi (`Sedang Dikerjakan`):** Ikon teknisi biru tua. `Teknisi Bpk. Hendra sedang menuju lokasi dan memeriksa perangkat.` Dilengkapi kartu kontak `Hendra Pratama (Divisi Sarpras & Lab IT)` dan tombol telepon.
  3. **Selesai (`Menunggu`):** Ikon centang abu-abu. `Perbaikan tuntas, uji kelayakan benchmark, & konfirmasi verifikasi dari pelapor.`
* **Kartu Catatan Lapangan Teknisi:** Menampilkan kutipan diagnosa teknis dari kolom `field_note` di SQLite, jam pembaruan (`Diperbarui: 09:22 WIB`), dan tautan `Kirim Pesan`.
* **Tombol Aksi Bawah:** `Tambah Bukti` (menambah foto baru ke tiket) dan `Segarkan Status` (pada mode demo offline, menekan/menahan tombol ini dapat membuka dialog simulasi teknisi untuk memajukan status dari *Dilaporkan* $\rightarrow$ *Diproses Teknisi* $\rightarrow$ *Selesai*).

### 4.7 Pusat Notifikasi (`Notifikasi - Kosong` & `Notifikasi - Ada Pesan`)
* **Filter Tab:** Mendukung pemfilteran daftar notifikasi (`Semua`, `Belum Dibaca` dengan *badge* angka kuning, `Tiket Saya`, dan `Kampus`) serta tombol `Tandai dibaca`.
* **Kondisi Ada Pesan:** Dikelompokkan berdasarkan waktu (`HARI INI` dan `KEMARIN`):
  * *Update Tiket Baru:* `Laporan Baru Diterima!` (`Tiket #TRL-8821`).
  * *Pengumuman Kampus:* `Inspeksi Lift Terjadwal` (`13:00 - 15:30 WIB`).
  * *Riwayat Selesai:* `Pemeliharaan AC Selesai` (`Telah Diverifikasi • Tiket #TRL-8790`) dan `Proyektor Ruang Seminar` (`Selesai • Gedung C • Ruang 102`).
  * *Banner Bawah:* Kartu *navy* `SOLVEXA QUICK HELP – Ada Kerusakan Baru?` dengan tombol bulat kuning menuju kamera QR.