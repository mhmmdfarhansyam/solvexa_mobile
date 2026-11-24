/**
 * SOLVEXA MOBILE - INTERACTIVE FULLSTACK SIMULATOR (9 LAYAR PRD)
 * Studi Kasus: Universitas Trilogi
 */
const state = {
  role: 'sivitas', // 'sivitas' | 'teknisi'
  currentScreen: 'home_empty',
  dropdownOpen: false,
  selectedCategory: 'Hardware (PC/Monitor)',
  selectedUrgency: 'Sedang',
  descriptionText: '',
  uploadedPhotos: ['bukti_lab3_01.jpg'],
  notifFilter: 'Semua',
  scannedAsset: {
    qrCode: 'PC-LAB3',
    name: 'PC Workstation Lab 3 #14',
    building: 'Gedung Riset Informatika • Lt. 2',
    room: 'Lab Komputer 3 • Gedung B, Lantai 2',
    spot: 'Gedung Riset Sains • Lab 3 (Meja 14)',
  },
  activeTicket: {
    ticketNumber: '#SLV-001',
    cardId: '#TRL-2024-089',
    assetCode: 'PC-LAB3',
    category: 'Hardware (PC / Monitor)',
    buildingLocation: 'Lab Komputer 3 • Gedung B, Lantai 2',
    roomDetail: 'Gedung Riset Sains • Lab 3 (Meja 14)',
    description: 'Monitor blank hitam berulang & indikator kipas PSU berbunyi keras.',
    urgency: 'Sedang',
    priorityLabel: 'Prioritas Normal',
    status: 'Diproses Teknisi', // 'Dilaporkan' | 'Diproses Teknisi' | 'Selesai'
    estimatedCompletion: '~25 MENIT',
    fieldNote: 'Sedang dilakukan pengecekan kabel daya dan komponen GPU. Indikasi awal thermal throttling atau kabel PCIe kendor. Akan dilakukan pergantian pasta pendingin.',
    fieldNoteUpdatedAt: '09:22 WIB',
    reportedAt: '4 Nov 2026, 09:15',
  },
  notifications: [
    {
      id: 1,
      title: 'Laporan Baru Diterima!',
      message: 'Laporan <b>PC-LAB3</b> Anda sedang diproses oleh tim teknisi lab.',
      type: 'ticket_new',
      category: 'Tiket Saya',
      ticketNumber: 'Tiket #TRL-8821',
      location: 'Gedung B • Lt. 2',
      time: '10 mnt lalu',
      group: 'HARI INI',
      unread: true,
    },
    {
      id: 2,
      title: 'Inspeksi Lift Terjadwal',
      message: 'Lift Utama Gedung A dinonaktifkan sementara untuk pengujian sensor beban. Gunakan tangga darurat timur.',
      type: 'campus_schedule',
      category: 'Kampus',
      ticketNumber: null,
      location: '13:00 - 15:30 WIB',
      time: '1 jam lalu',
      group: 'HARI INI',
      unread: true,
    },
    {
      id: 3,
      title: 'Pemeliharaan AC Selesai',
      message: 'Perbaikan filter AC di Gedung Rektorat Lt. 3 telah diselesaikan oleh Teknisi Sarpras.',
      type: 'ticket_done',
      category: 'Tiket Saya',
      ticketNumber: 'Tiket #TRL-8790 >',
      location: 'Telah Diverifikasi',
      time: 'Kemarin, 16:40',
      group: 'KEMARIN',
      unread: false,
    },
    {
      id: 4,
      title: 'Proyektor Ruang Seminar',
      message: 'Kabel HDMI & kalibrasi optik proyektor telah rampung dan siap digunakan untuk perkuliahan.',
      type: 'ticket_done',
      category: 'Kampus',
      ticketNumber: 'Gedung C • Ruang 102',
      location: 'Selesai',
      time: 'Kemarin, 11:15',
      group: 'KEMARIN',
      unread: false,
    },
  ],
};

function setRole(role) {
  state.role = role;
  document.getElementById('btnRoleSivitas').classList.toggle('active', role === 'sivitas');
  document.getElementById('btnRoleTeknisi').classList.toggle('active', role === 'teknisi');
  render();
}

function jumpToScreen(screenName) {
  if (screenName === 'form_dropdown') {
    state.dropdownOpen = true;
    state.currentScreen = 'form_default';
  } else if (screenName === 'form_default') {
    state.dropdownOpen = false;
    state.currentScreen = 'form_default';
  } else {
    state.currentScreen = screenName;
  }
  render();
}

function navigateTab(tab) {
  if (tab === 'home') {
    state.currentScreen = state.currentScreen === 'home_active' ? 'home_active' : 'home_empty';
  } else if (tab === 'scan') {
    state.currentScreen = 'scan_qr';
  } else if (tab === 'updates') {
    state.currentScreen = 'notif_list';
  }
  render();
}

function updateTicketStatus(newStatus) {
  state.activeTicket.status = newStatus;
  if (newStatus === 'Selesai') {
    state.activeTicket.estimatedCompletion = 'SELESAI';
    state.activeTicket.fieldNote = 'Pergantian pasta pendingin GPU dan pengencangan konektor PCIe selesai dilakukan. Uji kelayakan benchmark stabil.';
  } else if (newStatus === 'Diproses Teknisi') {
    state.activeTicket.estimatedCompletion = '~25 MENIT';
    state.activeTicket.fieldNote = 'Sedang dilakukan pengecekan kabel daya dan komponen GPU. Indikasi awal thermal throttling atau kabel PCIe kendor. Akan dilakukan pergantian pasta pendingin.';
  }
  state.currentScreen = 'ticket_timeline';
  render();
}

function renderHeader() {
  const header = document.getElementById('appHeader');
  const isNewTicketFlow = ['form_default', 'ticket_success'].includes(state.currentScreen);

  if (isNewTicketFlow) {
    header.innerHTML = `
      <div class="appbar-left">
        <button class="icon-btn" onclick="jumpToScreen('scan_qr')">❮</button>
        <div class="appbar-title">New Ticket</div>
      </div>
      <span class="pill-amber">${state.role === 'teknisi' ? '🛠️ Mode Teknisi' : '🎓 Sivitas'}</span>
    `;
    return;
  }

  let pageTitle = 'Home';
  if (state.currentScreen === 'scan_qr') pageTitle = 'Scan Qr';
  if (state.currentScreen.startsWith('notif')) pageTitle = 'Notifications';

  header.innerHTML = `
    <div class="appbar-left">
      <div class="navy-logo-box">🔧</div>
      <div>
        <div class="appbar-uni">UNIVERSITAS TRILOGI</div>
        <div class="appbar-title">${pageTitle}</div>
      </div>
    </div>
    <div style="display:flex;align-items:center;gap:10px;">
      <button class="icon-btn" title="Cari Aset Kampus" onclick="openAssetModal()">🔍</button>
    </div>
  `;
}

function render() {
  renderHeader();
  const unreadCount = state.notifications.filter((n) => n.unread).length;
  const badge = document.getElementById('navBadge');
  badge.textContent = unreadCount;
  badge.style.display = unreadCount > 0 ? 'inline-block' : 'none';

  const container = document.getElementById('screenContainer');
  const s = state.currentScreen;

  if (s === 'home_empty') {
    container.innerHTML = `
      <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:16px;">
        <div style="background:#EEF2FF;border:1px solid #E2E8F0;border-radius:8px;padding:6px 12px;font-size:12px;font-weight:700;">💻 Verified</div>
        <div style="display:flex;gap:8px;align-items:center;">
          <button onclick="jumpToScreen('notif_list')" style="width:40px;height:40px;border-radius:50%;border:none;background:#EEF2FF;cursor:pointer;">🔔</button>
          <div style="width:40px;height:40px;border-radius:50%;background:#0F1D33;color:#FFF;display:flex;align-items:center;justify-content:center;font-weight:800;font-size:13px;">ST</div>
        </div>
      </div>
      <div style="font-size:12.5px;font-weight:700;color:#475569;margin-bottom:6px;">📅 Rabu, 4 November 2026</div>
      <h1 style="font-size:25px;font-weight:800;margin-bottom:6px;">Halo, Sivitas Trilogi! 👋</h1>
      <p style="font-size:13.5px;color:#475569;line-height:1.45;margin-bottom:18px;">Pantau dan jaga kenyamanan sarana kampus kita bersama.</p>

      <div class="grid-2">
        <div class="card" style="margin-bottom:0;">
          <div style="display:flex;justify-content:space-between;font-size:10.5px;font-weight:700;color:#475569;">
            <span>LAPORAN AKTIF</span><span>📋</span>
          </div>
          <div style="margin:8px 0;"><span style="font-size:28px;font-weight:800;">0</span> <span style="font-size:13px;color:#475569;">tiket</span></div>
          <div style="font-size:11.5px;font-weight:700;color:#10B981;">● Semua tertangani</div>
        </div>
        <div class="card" style="margin-bottom:0;">
          <div style="display:flex;justify-content:space-between;font-size:10.5px;font-weight:700;color:#475569;">
            <span>SELESAI BULAN INI</span><span>✅</span>
          </div>
          <div style="margin:8px 0;"><span style="font-size:28px;font-weight:800;">14</span> <span style="font-size:13px;color:#475569;">fasilitas</span></div>
          <div style="font-size:11.5px;font-weight:600;color:#475569;">📈 Kecepatan avg. 2 jam</div>
        </div>
      </div>

      <div class="card" style="text-align:center;padding:24px 18px;">
        <div style="width:72px;height:72px;border-radius:50%;background:#EEF2FF;margin:0 auto 14px;display:flex;align-items:center;justify-content:center;font-size:30px;position:relative;">
          📋
          <span style="position:absolute;top:-2px;right:-2px;background:#F5B400;border-radius:50%;width:24px;height:24px;font-size:13px;display:flex;align-items:center;justify-content:center;">✓</span>
        </div>
        <div style="display:inline-block;background:#EEF2FF;padding:5px 12px;border-radius:20px;font-size:11.5px;font-weight:700;color:#0F1D33;margin-bottom:12px;">
          <span style="color:#10B981;">●</span> Sistem Siaga Operasional
        </div>
        <h3 style="font-size:17px;font-weight:800;margin-bottom:8px;">Belum ada laporan kerusakan.<br/>Fasilitas aman!</h3>
        <p style="font-size:12.5px;color:#475569;line-height:1.45;margin-bottom:14px;">
          Terima kasih telah merawat kampus kita. Menemukan AC mati, proyektor bermasalah, atau fasilitas rusak?
        </p>
        <a href="javascript:void(0)" onclick="jumpToScreen('home_active')" style="font-size:12.5px;font-weight:800;color:#92400E;text-decoration:none;">
          Panduan pelaporan sarana kampus →
        </a>
      </div>

      <div style="display:flex;justify-content:space-between;align-items:center;margin:16px 0 10px;">
        <span style="font-size:15px;font-weight:800;">Zona Terpantau Hari Ini</span>
        <span style="font-size:11.5px;color:#475569;">Update 10m lalu</span>
      </div>
      <div class="zone-scroll">
        <div class="zone-card">
          <div style="font-size:11.5px;color:#475569;">Gedung Rektorat</div>
          <div style="font-size:13.5px;font-weight:800;margin:4px 0;">Lt. 1 - 4 Normal</div>
          <div style="font-size:11px;font-weight:700;color:#10B981;">● Kondusif</div>
        </div>
        <div class="zone-card">
          <div style="font-size:11.5px;color:#475569;">Lab Komputer</div>
          <div style="font-size:13.5px;font-weight:800;margin:4px 0;">Lab A, B, & C</div>
          <div style="font-size:11px;font-weight:700;color:#10B981;">● Siap Digunakan</div>
        </div>
        <div class="zone-card">
          <div style="font-size:11.5px;color:#475569;">Perpustakaan</div>
          <div style="font-size:13.5px;font-weight:800;margin:4px 0;">Ruang Koleksi</div>
          <div style="font-size:11px;font-weight:700;color:#10B981;">● AC Stabil 22°C</div>
        </div>
      </div>

      <button class="btn-amber-full" onclick="jumpToScreen('scan_qr')">⛶ Scan QR Lapor</button>
    `;
  } else if (s === 'home_active') {
    container.innerHTML = `
      <div style="font-size:11px;font-weight:800;color:#475569;letter-spacing:0.7px;margin-bottom:6px;">🛡️ LAYANAN SARANA KAMPUS</div>
      <h1 style="font-size:25px;font-weight:800;margin-bottom:6px;">Halo, Sivitas Trilogi!</h1>
      <p style="font-size:13.5px;color:#475569;line-height:1.45;margin-bottom:18px;">Pantau status perbaikan dan kebutuhan inventaris fasilitas Anda secara realtime.</p>

      <div class="status-navy-card" onclick="jumpToScreen('ticket_timeline')">
        <div style="padding:18px;display:flex;justify-content:space-between;align-items:flex-start;">
          <div>
            <div style="font-size:10.5px;font-weight:800;color:#F5B400;letter-spacing:0.8px;">STATUS PENANGANAN</div>
            <div style="margin:6px 0;"><span style="font-size:30px;font-weight:800;">1</span> <span style="font-size:19px;font-weight:800;">Laporan Aktif</span></div>
            <div style="font-size:12.5px;color:#CBD5E1;">Tiket dalam antrean respon prioritas fasilitas.</div>
          </div>
          <div style="width:48px;height:48px;border-radius:50%;background:rgba(255,255,255,0.1);display:flex;align-items:center;justify-content:center;font-size:22px;">📋</div>
        </div>
        <div style="background:rgba(0,0,0,0.25);padding:11px 18px;display:flex;justify-content:space-between;font-size:12px;font-weight:700;">
          <span><span style="color:#F5B400;">●</span> Est. Waktu Penanganan: &lt; 30 mnt</span>
          <span>❯</span>
        </div>
      </div>

      <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:10px;">
        <span style="font-size:16px;font-weight:800;">Laporan Terbaru</span>
        <a href="javascript:void(0)" onclick="jumpToScreen('ticket_timeline')" style="font-size:12.5px;font-weight:700;color:#475569;text-decoration:none;">Riwayat Semua →</a>
      </div>

      <div class="card" style="cursor:pointer;" onclick="jumpToScreen('ticket_timeline')">
        <div style="display:flex;align-items:center;gap:10px;margin-bottom:12px;">
          <div style="width:40px;height:40px;border-radius:10px;background:#EEF2FF;display:flex;align-items:center;justify-content:center;">🖥️</div>
          <div style="flex:1;overflow:hidden;">
            <div style="font-size:14px;font-weight:800;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">${state.activeTicket.assetCode} | Hardware...</div>
            <div style="font-size:11.5px;color:#475569;">ID: ${state.activeTicket.cardId}</div>
          </div>
          <span class="pill-amber">● Menunggu Teknisi</span>
        </div>
        <div style="height:140px;border-radius:12px;background:linear-gradient(180deg,#334155,#0F172A);position:relative;display:flex;align-items:flex-end;padding:12px;color:#FFF;font-size:12px;font-weight:700;margin-bottom:10px;">
          📍 ${state.activeTicket.roomDetail}
        </div>
        <div style="display:flex;justify-content:space-between;font-size:11.5px;color:#475569;">
          <span>🕒 Baru saja dilaporkan</span>
          <span style="font-weight:700;color:#0F172A;">🛡️ Unit TI Trilogi</span>
        </div>
      </div>

      <div style="display:flex;justify-content:space-between;font-size:11.5px;font-weight:700;color:#475569;margin:16px 0 10px;">
        <span>AKSI CEPAT</span><span>Bantuan 24/7</span>
      </div>
      <button class="btn-amber-full" style="margin-bottom:12px;" onclick="jumpToScreen('scan_qr')">⛶ Scan QR Lapor</button>

      <div class="grid-2">
        <div class="card" style="background:#F4F6FB;border:none;cursor:pointer;margin-bottom:0;" onclick="openAssetModal()">
          <div style="width:36px;height:36px;border-radius:10px;background:#FFF;display:flex;align-items:center;justify-content:center;margin-bottom:10px;">📦</div>
          <div style="font-size:13.5px;font-weight:800;">Cek Aset Lab</div>
          <div style="font-size:11.5px;color:#475569;">Database barang ruang</div>
        </div>
        <div class="card" style="background:#F4F6FB;border:none;cursor:pointer;margin-bottom:0;" onclick="alert('Menghubungi Helpdesk Sarpras Universitas Trilogi: (021) 798-0011')">
          <div style="width:36px;height:36px;border-radius:10px;background:#FFF;display:flex;align-items:center;justify-content:center;margin-bottom:10px;">🎧</div>
          <div style="font-size:13.5px;font-weight:800;">Kontak Helpdesk</div>
          <div style="font-size:11.5px;color:#475569;">Layanan siaga cepat</div>
        </div>
      </div>
    `;
  } else if (s === 'scan_qr') {
    container.innerHTML = `
      <div style="background:linear-gradient(180deg,#334155 0%,#0F172A 100%);border-radius:24px;padding:18px;color:#FFF;height:460px;display:flex;flex-direction:column;justify-content:space-between;position:relative;margin-bottom:16px;">
        <div style="display:flex;justify-content:space-between;align-items:center;">
          <button onclick="jumpToScreen('home_empty')" style="width:38px;height:38px;border-radius:50%;border:none;background:rgba(0,0,0,0.45);color:#FFF;cursor:pointer;">←</button>
          <div style="background:rgba(0,0,0,0.55);padding:6px 14px;border-radius:20px;font-size:11px;font-weight:700;letter-spacing:0.8px;">
            <span style="color:#10B981;">●</span> CAMERA ACTIVE
          </div>
          <button onclick="alert('Flash kamera diaktifkan')" style="width:38px;height:38px;border-radius:50%;border:none;background:rgba(0,0,0,0.45);color:#FFF;cursor:pointer;">⚡</button>
        </div>

        <div onclick="jumpToScreen('form_default')" title="Klik untuk simulasi QR Terpindai" style="width:210px;height:210px;margin:0 auto;border:4px solid #F5B400;border-radius:18px;position:relative;display:flex;align-items:center;justify-content:center;cursor:pointer;">
          <span style="position:absolute;top:10px;left:12px;font-size:11px;color:rgba(255,255,255,0.6);">TRILOGI-FAC-01</span>
          <div style="font-size:64px;opacity:0.3;">⛶</div>
          <div style="position:absolute;left:8px;right:8px;height:3px;background:#F5B400;box-shadow:0 0 12px #F5B400;"></div>
        </div>

        <div style="text-align:center;">
          <div style="display:inline-block;background:rgba(15,23,42,0.85);padding:8px 18px;border-radius:20px;font-size:14px;font-weight:800;margin-bottom:6px;">
            Arahkan kamera ke stiker QR
          </div>
          <div style="font-size:11.5px;color:#CBD5E1;margin-bottom:14px;">
            Posisikan kode QR di dalam bingkai kuning untuk memindai fasilitas otomatis
          </div>
          <div class="grid-2" style="margin-bottom:0;">
            <button onclick="jumpToScreen('form_default')" style="padding:11px;border-radius:12px;border:1px solid rgba(255,255,255,0.25);background:rgba(255,255,255,0.2);color:#FFF;font-weight:700;cursor:pointer;">🖼️ Upload Foto</button>
            <button onclick="openAssetModal()" style="padding:11px;border-radius:12px;border:1px solid rgba(255,255,255,0.25);background:rgba(255,255,255,0.2);color:#FFF;font-weight:700;cursor:pointer;">⌨️ Input Manual</button>
          </div>
        </div>
      </div>

      <div class="card" style="display:flex;align-items:center;gap:14px;">
        <div style="width:48px;height:48px;border-radius:14px;background:#FEF3C7;display:flex;align-items:center;justify-content:center;font-size:22px;">🏵️</div>
        <div style="flex:1;">
          <div style="display:flex;justify-content:space-between;align-items:center;">
            <span style="font-size:10.5px;font-weight:700;color:#475569;">LOKASI TERDETEKSI</span>
            <span class="pill-green">GPS Siap</span>
          </div>
          <div style="font-size:15px;font-weight:800;margin:2px 0;">Gedung Rektorat & Kuliah</div>
          <div style="font-size:12px;color:#475569;">Lantai 3 • Koridor Sayap Timur</div>
        </div>
      </div>
    `;
  } else if (s === 'form_default') {
    const isDrop = state.dropdownOpen;
    container.innerHTML = `
      ${
        isDrop
          ? `<div class="card" style="background:#EEF2FF;border:none;display:flex;align-items:center;gap:12px;">
              <div style="width:40px;height:40px;border-radius:10px;background:#0F1D33;color:#FFF;display:flex;align-items:center;justify-content:center;">🏢</div>
              <div style="flex:1;">
                <div style="font-size:10px;font-weight:700;color:#475569;">LOKASI TERPILIH</div>
                <div style="font-size:13.5px;font-weight:800;">Gedung Riset Sains • Lt. 3</div>
              </div>
              <span style="color:#F5B400;">●</span>
            </div>`
          : `<div style="margin-bottom:14px;">
              <span class="pill-amber">⚡ KAMPUS PINTAR • RUANG LAB</span>
              <p style="font-size:12.5px;color:#475569;margin-top:8px;line-height:1.45;">
                Lengkapi detail insiden fasilitas di bawah ini agar teknisi operasional dapat segera menindaklanjuti.
              </p>
            </div>`
      }

      <div class="card">
        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:10px;">
          <span style="font-size:12.5px;font-weight:700;color:#475569;">${isDrop ? 'ID Fasilitas' : 'ID Fasilitas Terpindai'}</span>
          ${isDrop ? '<span style="font-size:11.5px;color:#475569;">Terverifikasi otomatis</span>' : '<span class="pill-green">✓ Terverifikasi</span>'}
        </div>
        <div style="background:#EEF2FF;padding:12px;border-radius:12px;display:flex;align-items:center;gap:12px;">
          <div style="width:38px;height:38px;border-radius:10px;background:#0F1D33;color:#FFF;display:flex;align-items:center;justify-content:center;">🖥️</div>
          <div style="flex:1;">
            <div style="font-size:15px;font-weight:800;">${state.scannedAsset.qrCode}</div>
            <div style="font-size:12px;color:#475569;">${state.scannedAsset.building}</div>
          </div>
          <span>${isDrop ? '<span class="pill-green">● Online</span>' : '🔒'}</span>
        </div>
      </div>

      <div class="card">
        <div style="display:flex;justify-content:space-between;margin-bottom:8px;">
          <span style="font-size:13px;font-weight:800;">Kategori Kerusakan</span>
          <span style="font-size:11.5px;font-weight:700;color:${isDrop ? '#B45309' : '#EF4444'};">${isDrop ? 'Wajib dipilih' : '*Wajib'}</span>
        </div>
        <div onclick="state.dropdownOpen=!state.dropdownOpen;render();" style="background:#F1F5F9;padding:13px;border-radius:12px;display:flex;justify-content:space-between;align-items:center;cursor:pointer;font-weight:700;font-size:13.5px;">
          <span>${state.selectedCategory || 'Pilih Kategori'}</span>
          <span>${isDrop ? '▲' : '▼'}</span>
        </div>
        ${
          isDrop
            ? `<div style="margin-top:10px;border:1px solid #E2E8F0;border-radius:14px;overflow:hidden;">
                ${[
                  ['Hardware (PC/Monitor)', 'Unit CPU, layar monitor, periferal', '💻'],
                  ['Fasilitas Ruang (AC/Gorden)', 'Pendingin, pencahayaan, ventilasi', '❄️'],
                  ['Sanitasi (Toilet/Air)', 'Wastafel, kran air, saluran', '💧'],
                ]
                  .map(
                    ([title, sub, ic]) => `
                  <div onclick="state.selectedCategory='${title}';render();" style="padding:12px;display:flex;align-items:center;gap:10px;border-bottom:1px solid #F1F5F9;cursor:pointer;">
                    <div style="width:36px;height:36px;border-radius:8px;background:#EEF2FF;display:flex;align-items:center;justify-content:center;">${ic}</div>
                    <div style="flex:1;">
                      <div style="font-size:13.5px;font-weight:800;">${title}</div>
                      <div style="font-size:11.5px;color:#475569;">${sub}</div>
                    </div>
                    ${state.selectedCategory === title ? '<span style="color:#F5B400;font-weight:800;">✓</span>' : ''}
                  </div>
                `
                  )
                  .join('')}
              </div>`
            : ''
        }
      </div>

      ${
        !isDrop
          ? `<div class="card">
              <div style="display:flex;justify-content:space-between;margin-bottom:8px;">
                <span style="font-size:13px;font-weight:800;">Deskripsi Kendala</span>
                <span style="font-size:11.5px;color:#94A3B8;">${state.descriptionText.length} / 250</span>
              </div>
              <textarea oninput="state.descriptionText=this.value" maxlength="250" rows="3" placeholder="Jelaskan detail kendala atau kerusakan yang dialami..." style="width:100%;border:none;background:#F1F5F9;border-radius:12px;padding:12px;font-family:inherit;font-size:13px;">${state.descriptionText}</textarea>
              <div style="font-size:11.5px;color:#475569;margin-top:8px;">ⓘ Contoh: Monitor tidak menyala, kipas PSU berbunyi keras.</div>
            </div>

            <div class="card">
              <div style="display:flex;justify-content:space-between;margin-bottom:10px;">
                <span style="font-size:13px;font-weight:800;">Unggah Foto Bukti</span>
                <span style="font-size:11.5px;color:#475569;">Opsional</span>
              </div>
              <div onclick="state.dropdownOpen=true;render();" style="background:#EEF2FF;border-radius:14px;padding:20px;text-align:center;cursor:pointer;">
                <div style="width:44px;height:44px;border-radius:50%;background:#FEF3C7;margin:0 auto 8px;display:flex;align-items:center;justify-content:center;">📷</div>
                <div style="font-size:13.5px;font-weight:800;">Ketuk untuk Mengunggah Foto</div>
                <div style="font-size:11.5px;color:#475569;">Format JPG, PNG maks. 5MB</div>
              </div>
            </div>

            <div class="card">
              <div style="font-size:13px;font-weight:800;margin-bottom:10px;">Tingkat Urgensi</div>
              <div style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:8px;">
                ${[
                  ['Rendah', '#CBD5E1'],
                  ['Sedang', '#F5B400'],
                  ['Darurat', '#EF4444'],
                ]
                  .map(
                    ([u, c]) => `
                  <div onclick="state.selectedUrgency='${u}';render();" style="padding:12px;border-radius:12px;text-align:center;cursor:pointer;background:${state.selectedUrgency === u ? '#EEF2FF' : '#F1F5F9'};border:1.5px solid ${state.selectedUrgency === u ? '#93C5FD' : 'transparent'};">
                    <div style="color:${c};font-size:14px;">●</div>
                    <div style="font-size:12.5px;font-weight:700;margin-top:4px;">${u}</div>
                  </div>
                `
                  )
                  .join('')}
              </div>
            </div>`
          : `<div class="grid-2">
              <div class="card" style="text-align:center;margin-bottom:0;cursor:pointer;">
                <div style="font-size:24px;margin-bottom:6px;">📷</div>
                <div style="font-size:12.5px;font-weight:800;">Ambil / Unggah</div>
                <div style="font-size:11px;color:#475569;">Maksimal 3 foto</div>
              </div>
              <div class="card" style="background:linear-gradient(135deg,#1E293B,#0F172A);color:#FFF;display:flex;align-items:flex-end;justify-content:space-between;margin-bottom:0;font-size:11px;font-weight:700;">
                <span>bukti_lab3_01.jpg</span><span>✓</span>
              </div>
            </div>
            <div class="card" style="background:#EEF2FF;border:none;font-size:12px;color:#475569;line-height:1.45;">
              ⓘ Laporan masuk akan segera dialokasikan kepada teknisi gedung yang bertugas hari ini. Mohon pastikan perangkat tidak diutak-atik lebih lanjut demi keamanan.
            </div>`
      }

      <button class="btn-navy-full" onclick="jumpToScreen('ticket_success')">Kirim Laporan ➤</button>
    `;
  } else if (s === 'ticket_success') {
    container.innerHTML = `
      <div style="text-align:center;padding:12px 0 18px;">
        <div style="width:94px;height:94px;border-radius:50%;background:#059669;color:#FFF;margin:0 auto 14px;display:flex;align-items:center;justify-content:center;font-size:42px;position:relative;box-shadow:0 0 0 12px #D1FAE5;">
          ✓
          <span style="position:absolute;top:-4px;right:-14px;background:#F5B400;color:#0F1D33;font-size:10.5px;font-weight:800;padding:3px 8px;border-radius:12px;">⚡ Kilat</span>
        </div>
        <div style="display:inline-block;background:#EEF2FF;padding:5px 14px;border-radius:20px;font-size:12px;font-weight:800;margin-bottom:12px;">
          <span style="color:#F5B400;">●</span> ${state.activeTicket.ticketNumber} • Prioritas Normal
        </div>
        <h2 style="font-size:21px;font-weight:800;margin-bottom:6px;">Laporan Berhasil Terkirim!</h2>
        <p style="font-size:13.5px;color:#475569;">Laporan <b>${state.activeTicket.assetCode}</b> telah masuk ke antrean teknisi kampus.</p>
      </div>

      <div class="card">
        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:12px;">
          <div style="display:flex;gap:10px;align-items:center;">
            <div style="width:38px;height:38px;border-radius:10px;background:#EEF2FF;display:flex;align-items:center;justify-content:center;">🕒</div>
            <div>
              <div style="font-size:11.5px;color:#475569;">Estimasi Respon</div>
              <div style="font-size:14.5px;font-weight:800;">Maks. 15-30 Menit</div>
            </div>
          </div>
          <span style="background:#EEF2FF;padding:4px 10px;border-radius:12px;font-size:11px;font-weight:700;">Otomatis</span>
        </div>
        <div style="height:6px;background:#EEF2FF;border-radius:6px;overflow:hidden;margin-bottom:12px;">
          <div style="width:48%;height:100%;background:#059669;"></div>
        </div>
        <div style="display:flex;justify-content:space-between;font-size:12px;color:#475569;">
          <span>🏢 Gedung Teknik Lt. 2</span>
          <span>🖥️ Lab Komputer B</span>
        </div>
      </div>

      <div class="card" style="background:#EEF2FF;border:none;display:flex;align-items:center;gap:12px;">
        <div style="width:42px;height:42px;border-radius:50%;background:#0F1D33;color:#FFF;display:flex;align-items:center;justify-content:center;font-weight:800;font-size:13px;">BA</div>
        <div style="flex:1;">
          <div style="font-size:11.5px;color:#475569;">Teknisi Bertugas</div>
          <div style="font-size:14px;font-weight:800;">Bima Arya (Unit Hardware)</div>
        </div>
        <button onclick="alert('Membuka chat dengan Bima Arya')" style="width:36px;height:36px;border-radius:50%;border:none;background:#FFF;cursor:pointer;">💬</button>
      </div>

      <div class="card">
        <div style="display:flex;justify-content:space-between;font-size:12.5px;margin-bottom:10px;">
          <b>Lampiran Bukti Masalah</b>
          <span style="color:#475569;">1 Berkas Foto</span>
        </div>
        <div style="height:96px;border-radius:12px;background:linear-gradient(135deg,#0F172A,#1D4ED8);color:#FFF;display:flex;align-items:center;justify-content:space-between;padding:0 14px;font-size:12.5px;font-weight:700;">
          <span>🖼️ monitor_freeze_error.jpg</span>
          <span>👁️</span>
        </div>
      </div>

      <button class="btn-navy-full" style="margin-bottom:10px;" onclick="jumpToScreen('ticket_timeline')">📈 Lacak Status Laporan</button>
      <button class="btn-outline-full" onclick="jumpToScreen('home_active')">🏠 Kembali ke Beranda</button>
    `;
  } else if (s === 'ticket_timeline') {
    const st = state.activeTicket.status;
    container.innerHTML = `
      <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:14px;">
        <button onclick="jumpToScreen('home_active')" style="border:none;background:#EEF2FF;padding:6px 12px;border-radius:16px;font-weight:800;font-size:12px;cursor:pointer;">← Kembali</button>
        <span class="pill-amber" style="background:#F5B400;color:#0F1D33;">PRIORITAS TINGGI</span>
      </div>

      <div class="card">
        <div style="display:flex;justify-content:space-between;align-items:center;font-size:11.5px;margin-bottom:10px;">
          <span><b style="background:#EEF2FF;padding:3px 8px;border-radius:6px;">ID: ${state.activeTicket.ticketNumber}</b> &nbsp;Aset: <b>${state.activeTicket.assetCode}</b></span>
          <span style="color:#475569;">🕒 ${state.activeTicket.reportedAt}</span>
        </div>
        <div style="font-size:18px;font-weight:800;margin-bottom:4px;">${state.activeTicket.category}</div>
        <div style="font-size:12.5px;color:#475569;margin-bottom:12px;">🏢 ${state.activeTicket.buildingLocation}</div>
        <div style="background:#EEF2FF;padding:10px;border-radius:12px;display:flex;gap:10px;align-items:center;">
          <div style="width:42px;height:42px;border-radius:8px;background:#0F1D33;color:#FFF;display:flex;align-items:center;justify-content:center;">🖥️</div>
          <div style="overflow:hidden;">
            <div style="font-size:10px;font-weight:700;color:#475569;">GEJALA MASALAH</div>
            <div style="font-size:12.5px;font-weight:800;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">${state.activeTicket.description}</div>
          </div>
        </div>
      </div>

      <div class="card">
        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:16px;">
          <span style="font-size:16px;font-weight:800;">Alur Penanganan</span>
          <span class="pill-green">ESTIMASI: ${state.activeTicket.estimatedCompletion}</span>
        </div>

        <div style="border-left:2.5px solid #10B981;padding-left:14px;margin-left:10px;padding-bottom:18px;">
          <div style="font-size:14px;font-weight:800;">✅ Dilaporkan <span style="font-size:11.5px;font-weight:600;color:#475569;">09:15 WIB</span></div>
          <div style="font-size:12px;color:#475569;margin:4px 0;">Tiket berhasil dibuat oleh sivitas akademika via Solvexa Mobile</div>
          <div style="font-size:11px;font-weight:700;color:#92400E;">🛡️ Terverifikasi Otomatis Sistem</div>
        </div>

        <div style="border-left:2px dashed #CBD5E1;padding-left:14px;margin-left:10px;padding-bottom:18px;">
          <div style="display:flex;align-items:center;gap:8px;">
            <span style="font-size:14px;font-weight:800;">🛠️ Diproses Teknisi</span>
            <span class="pill-amber" style="background:#F5B400;color:#0F1D33;">● ${st === 'Selesai' ? 'Selesai Dikerjakan' : 'Sedang Dikerjakan'}</span>
          </div>
          <div style="font-size:12px;font-weight:600;margin:6px 0 10px;">Teknisi Bpk. Hendra sedang menuju lokasi dan memeriksa perangkat.</div>
          <div style="background:#EEF2FF;padding:10px;border-radius:12px;display:flex;align-items:center;justify-content:space-between;">
            <div>
              <div style="font-size:13px;font-weight:800;">Hendra Pratama</div>
              <div style="font-size:11px;color:#475569;">Divisi Sarpras & Lab IT</div>
            </div>
            <button onclick="alert('Menghubungi Teknisi Hendra Pratama')" style="width:32px;height:32px;border-radius:50%;border:none;background:#FFF;cursor:pointer;">📞</button>
          </div>
        </div>

        <div style="padding-left:14px;margin-left:10px;">
          <div style="font-size:14px;font-weight:800;color:${st === 'Selesai' ? '#10B981' : '#64748B'};">
            ${st === 'Selesai' ? '✅ Selesai (Terverifikasi)' : '⚪ Selesai (Menunggu)'}
          </div>
          <div style="font-size:12px;color:#475569;margin-top:4px;">Perbaikan tuntas, uji kelayakan benchmark, & konfirmasi verifikasi dari pelapor.</div>
        </div>
      </div>

      <div class="card" style="background:#F4F6FB;border:none;">
        <div style="font-size:14px;font-weight:800;margin-bottom:8px;">📝 Catatan Lapangan Teknisi</div>
        <p style="font-size:12.5px;font-style:italic;color:#475569;line-height:1.45;margin-bottom:10px;">
          “${state.activeTicket.fieldNote}”
        </p>
        <div style="display:flex;justify-content:space-between;font-size:11.5px;font-weight:700;">
          <span style="color:#475569;">Diperbarui: ${state.activeTicket.fieldNoteUpdatedAt}</span>
          <a href="javascript:void(0)" onclick="openTechModal()" style="color:#0F1D33;text-decoration:none;">💬 Kirim Pesan / Edit Teknisi</a>
        </div>
      </div>

      <div class="grid-2" style="margin-bottom:0;">
        <button class="btn-outline-full" onclick="alert('Bukti tambahan berhasil diunggah ke tiket SQLite!')">📷 Tambah Bukti</button>
        <button class="btn-navy-full" onclick="openTechModal()">↻ Segarkan Status</button>
      </div>
    `;
  } else if (s === 'notif_list') {
    const items = state.notifications.filter((n) => {
      if (state.notifFilter === 'Belum Dibaca') return n.unread;
      if (state.notifFilter === 'Tiket Saya' || state.notifFilter === 'Kampus') return n.category === state.notifFilter;
      return true;
    });

    container.innerHTML = `
      <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:14px;">
        <div style="background:#EEF2FF;padding:4px;border-radius:20px;display:flex;gap:4px;">
          <button onclick="state.notifFilter='Semua';render();" style="border:none;padding:6px 12px;border-radius:16px;background:${state.notifFilter === 'Semua' ? '#FFF' : 'transparent'};font-weight:800;font-size:12px;cursor:pointer;">Semua ●</button>
          <button onclick="state.notifFilter='Belum Dibaca';render();" style="border:none;padding:6px 12px;border-radius:16px;background:${state.notifFilter === 'Belum Dibaca' ? '#FFF' : 'transparent'};font-weight:700;font-size:12px;cursor:pointer;">Belum Dibaca <span style="background:#F5B400;padding:1px 6px;border-radius:10px;font-weight:800;">${unreadCount}</span></button>
        </div>
        <button onclick="state.notifications.forEach(n=>n.unread=false);render();" style="border:none;background:none;font-size:12px;font-weight:800;color:#0F1D33;cursor:pointer;">✓✓ Tandai dibaca</button>
      </div>

      <div style="display:flex;justify-content:space-between;font-size:11px;font-weight:800;color:#475569;margin-bottom:10px;">
        <span>HARI INI</span><span>2 Pembaruan</span>
      </div>
      ${items
        .filter((i) => i.group === 'HARI INI')
        .map(
          (i) => `
        <div class="card" style="background:${i.unread && i.type === 'ticket_new' ? '#E8EEFF' : '#FFF'};" onclick="jumpToScreen('ticket_timeline')">
          <div style="display:flex;justify-content:space-between;font-size:13.5px;font-weight:800;margin-bottom:4px;">
            <span>${i.title}</span>
            <span style="font-size:11px;font-weight:600;color:#475569;">${i.time}</span>
          </div>
          <div style="font-size:12.5px;color:#475569;line-height:1.4;margin-bottom:10px;">${i.message}</div>
          <div style="font-size:11px;font-weight:800;">
            <span style="background:#FFF;padding:3px 8px;border-radius:10px;">${i.ticketNumber || i.location}</span>
            ${i.ticketNumber ? `<span style="color:#475569;font-weight:600;margin-left:6px;">${i.location}</span>` : ''}
          </div>
        </div>
      `
        )
        .join('')}

      <div style="display:flex;justify-content:space-between;font-size:11px;font-weight:800;color:#475569;margin:14px 0 10px;">
        <span>KEMARIN</span><span>Selesai Ditangani</span>
      </div>
      ${items
        .filter((i) => i.group === 'KEMARIN')
        .map(
          (i) => `
        <div class="card">
          <div style="display:flex;justify-content:space-between;font-size:13.5px;font-weight:800;margin-bottom:4px;">
            <span>${i.title}</span>
            <span style="font-size:11px;font-weight:600;color:#475569;">${i.time}</span>
          </div>
          <div style="font-size:12.5px;color:#475569;line-height:1.4;margin-bottom:10px;">${i.message}</div>
          <div style="display:flex;justify-content:space-between;font-size:11.5px;">
            <span style="color:#10B981;font-weight:800;">● ${i.location}</span>
            <span style="color:#475569;">${i.ticketNumber}</span>
          </div>
        </div>
      `
        )
        .join('')}

      <div class="status-navy-card" style="padding:18px;display:flex;align-items:center;justify-content:space-between;margin-top:12px;" onclick="jumpToScreen('scan_qr')">
        <div>
          <div style="font-size:10px;font-weight:800;color:#F5B400;letter-spacing:0.8px;">SOLVEXA QUICK HELP</div>
          <div style="font-size:17px;font-weight:800;margin:4px 0;">Ada Kerusakan Baru?</div>
          <div style="font-size:11.5px;color:#CBD5E1;">Pindai QR kode barcode pada meja atau perangkat lab untuk respon kilat.</div>
        </div>
        <div style="width:48px;height:48px;border-radius:50%;background:#F5B400;color:#0F1D33;display:flex;align-items:center;justify-content:center;font-weight:800;font-size:20px;flex-shrink:0;">⛶</div>
      </div>
    `;
  } else if (s === 'notif_empty') {
    container.innerHTML = `
      <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:14px;">
        <button class="icon-btn" onclick="jumpToScreen('notif_list')">❮</button>
        <div style="text-align:center;">
          <div style="font-size:16px;font-weight:800;">Notifikasi</div>
          <div style="font-size:11px;color:#475569;">Pusat Layanan Fasilitas</div>
        </div>
        <button class="icon-btn" onclick="jumpToScreen('notif_list')">⚙️</button>
      </div>

      <div style="background:#E8EEFF;padding:4px;border-radius:14px;display:grid;grid-template-columns:1fr 1fr 1fr;margin-bottom:28px;text-align:center;font-size:12.5px;font-weight:700;">
        <div style="background:#FFF;padding:8px;border-radius:10px;">Semua</div>
        <div style="padding:8px;color:#475569;cursor:pointer;" onclick="jumpToScreen('notif_list')">Tiket Saya</div>
        <div style="padding:8px;color:#475569;cursor:pointer;" onclick="jumpToScreen('notif_list')">Kampus</div>
      </div>

      <div style="text-align:center;padding:12px 10px 24px;">
        <div style="width:136px;height:136px;border-radius:50%;background:#EEF2FF;border:5px solid #FEF3C7;margin:0 auto 18px;display:flex;align-items:center;justify-content:center;font-size:44px;">
          🔕
        </div>
        <h2 style="font-size:20px;font-weight:800;margin-bottom:8px;">Semuanya Beres!</h2>
        <p style="font-size:13px;color:#475569;line-height:1.45;margin-bottom:22px;">
          Belum ada notifikasi baru. Pembaruan tiket dan perawatan fasilitas akan muncul di sini.
        </p>
        <button class="btn-navy-full" style="margin-bottom:10px;" onclick="jumpToScreen('notif_list')">↻ Periksa Pembaruan</button>
        <button class="btn-outline-full" onclick="jumpToScreen('ticket_timeline')">🕒 Riwayat Laporan</button>
      </div>

      <div class="card" style="display:flex;align-items:center;gap:12px;">
        <div style="width:40px;height:40px;border-radius:10px;background:#EEF2FF;display:flex;align-items:center;justify-content:center;">📩</div>
        <div style="flex:1;">
          <div style="font-size:13px;font-weight:800;">Pemberitahuan Instan Aktif</div>
          <div style="font-size:11.5px;color:#475569;">Update gedung & perbaikan teknis</div>
        </div>
        <span>❯</span>
      </div>
      <div style="text-align:center;font-size:11px;color:#94A3B8;margin-top:8px;">🛡️ Biro Sarana & Prasarana Universitas Trilogi</div>
    `;
  }
}

function openAssetModal() {
  const modal = document.getElementById('modalOverlay');
  const body = document.getElementById('modalBody');
  body.innerHTML = `
    <h3 style="font-size:16px;font-weight:800;margin-bottom:6px;">Database Aset & Input Manual QR</h3>
    <p style="font-size:12px;color:#475569;margin-bottom:12px;">Pilih kode stiker fasilitas Universitas Trilogi di bawah ini:</p>
    ${[
      ['PC-LAB3', 'Gedung Riset Informatika • Lt. 2'],
      ['TRILOGI-FAC-01', 'Gedung Rektorat & Kuliah • Lt. 3'],
      ['PROJ-SEM-102', 'Gedung C • Ruang Seminar 102'],
    ]
      .map(
        ([code, loc]) => `
      <div onclick="state.scannedAsset.qrCode='${code}';state.scannedAsset.building='${loc}';closeModal();jumpToScreen('form_default');" style="padding:10px;background:#F1F5F9;border-radius:10px;margin-bottom:8px;cursor:pointer;display:flex;justify-content:space-between;align-items:center;">
        <div>
          <div style="font-size:13px;font-weight:800;">${code}</div>
          <div style="font-size:11px;color:#475569;">${loc}</div>
        </div>
        <span class="pill-green">Pilih</span>
      </div>
    `
      )
      .join('')}
  `;
  modal.classList.remove('hidden');
}

function openTechModal() {
  const modal = document.getElementById('modalOverlay');
  const body = document.getElementById('modalBody');
  body.innerHTML = `
    <h3 style="font-size:16px;font-weight:800;margin-bottom:6px;">Simulasi Teknisi Operasional (SQLite)</h3>
    <p style="font-size:12px;color:#475569;margin-bottom:12px;">Ubah status penanganan & Catatan Lapangan Teknisi:</p>
    <textarea id="techNoteInput" rows="3" style="width:100%;padding:10px;border-radius:10px;border:1px solid #CBD5E1;font-family:inherit;font-size:12.5px;margin-bottom:12px;">${state.activeTicket.fieldNote}</textarea>
    <div style="display:flex;gap:6px;margin-bottom:12px;">
      <button class="tech-btn" onclick="state.activeTicket.fieldNote=document.getElementById('techNoteInput').value;updateTicketStatus('Dilaporkan');closeModal();">Dilaporkan</button>
      <button class="tech-btn" onclick="state.activeTicket.fieldNote=document.getElementById('techNoteInput').value;updateTicketStatus('Diproses Teknisi');closeModal();">Diproses</button>
      <button class="tech-btn" onclick="state.activeTicket.fieldNote=document.getElementById('techNoteInput').value;updateTicketStatus('Selesai');closeModal();">Selesai</button>
    </div>
  `;
  modal.classList.remove('hidden');
}

function closeModal() {
  document.getElementById('modalOverlay').classList.add('hidden');
}

window.addEventListener('DOMContentLoaded', () => {
  render();
});
