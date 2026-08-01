# 🗂️ PAE Luanti Arsip

**Media Pembelajaran Interaktif Pengelolaan Arsip Elektronik (PAE)** berbasis game [Luanti](https://www.luanti.org) (dulu Minetest), lengkap dengan **NPC** dan **sistem misi**.

Proyek ini mengubah materi PAE yang cenderung teoretis menjadi pengalaman belajar yang interaktif dan menyenangkan — cocok untuk siswa/mahasiswa bidang kearsipan.

---

## 🎯 Misi yang Tersedia

### ✅ Misi 1: Pengumpulan Bahan Arsip
- **Tujuan:** Siswa belajar **memilah** dokumen mana yang layak diarsipkan (prioritas & bernilai) vs yang tidak perlu.
- **NPC:** Bu Arsi (Kepala Arsip) yang memberi misi lewat dialog.
- **Mekanik:** Kumpulkan 3 dokumen prioritas, hindari dokumen pengecoh. Ada feedback edukatif untuk setiap pilihan.

### 🔜 Roadmap Misi Berikutnya
| Misi | Topik | Konsep PAE |
|------|-------|------------|
| Misi 2 | Pemindaian | Resolusi 600 dpi, format TIFF |
| Misi 3 | Manipulasi & Entry Data | TIFF→PDF, metadata & kata kunci |
| Misi 4 | Penataan & Indeksasi | Struktur folder /Tahun/Unit/Kode/ |
| Misi 5 | Penyimpanan & Backup | Server, RAID, backup off-site |
| Final | Penyusutan & Retensi | Jadwal retensi arsip |

---

## 📥 Cara Download & Instalasi

### 1. Download Mod
**Opsi A — Git clone:**
```bash
git clone https://github.com/code4indo/pae-luanti-arsip.git
```

**Opsi B — Download ZIP:** Klik tombol hijau **Code → Download ZIP** di halaman repo ini.

### 2. Install ke Luanti
1. Pastikan [Luanti](https://www.luanti.org) sudah terinstal.
2. Salin folder `mods/pae_arsip` ke direktori mods Luanti Anda:
   - Linux: `~/.minetest/mods/` atau `~/.luanti/mods/`
   - Windows: `%APPDATA%\Minetest\mods\`
3. Buat **World baru** (game dasar "Minetest Game").
4. Saat konfigurasi world, aktifkan mod **`pae_arsip`** pada menu *Select Mods*.
5. Masuk ke world.

### 3. Menjalankan Misi (untuk Guru)
Berikan diri Anda privilege server, lalu ketik di chat game:
```
/pae_setup
```
Perintah ini memunculkan NPC Bu Arsi dan menyebar dokumen di sekitar Anda.

Untuk mengulang misi: `/pae_reset`

---

## 🎮 Cara Bermain (untuk Siswa)
1. Temui NPC **Bu Arsi** → klik kanan untuk bicara.
2. Terima misi.
3. Kumpulkan **3 dokumen prioritas** dengan memukul (klik kiri) berkasnya.
4. Hindari dokumen biasa/pengecoh (akan muncul peringatan edukatif).
5. Kembali & lapor ke Bu Arsi untuk menyelesaikan misi.

---

## 📁 Struktur Proyek
```
pae-luanti-arsip/
└── mods/
    └── pae_arsip/
        ├── mod.conf          # metadata mod
        ├── init.lua          # logika misi (item, node, NPC, dialog, command)
        ├── README.md         # dokumentasi mod
        └── textures/         # tekstur (placeholder, silakan ganti)
```

---

## 🛠️ Catatan Teknis
- Mod memakai namespace `core` (Luanti modern). Alias `minetest` juga tetap valid.
- Tekstur bawaan adalah placeholder warna solid — silakan ganti dengan ikon yang lebih representatif.

---

## 🤝 Kontribusi
Kontribusi sangat diterima! Silakan buka *issue* atau *pull request* untuk menambahkan misi baru, memperbaiki bug, atau meningkatkan tekstur.

## 📄 Lisensi
Dirilis di bawah lisensi **MIT** — bebas digunakan, dimodifikasi, dan disebarkan untuk keperluan pendidikan.

---

*Dibuat oleh [code4indo](https://github.com/code4indo) — untuk pembelajaran kearsipan digital di Indonesia.* 🇮🇩
