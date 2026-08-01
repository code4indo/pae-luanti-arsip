# PAE Arsip - Media Pembelajaran Pengelolaan Arsip Elektronik (Luanti)

Mod Luanti untuk pembelajaran **Pengelolaan Arsip Elektronik (PAE)** berbasis
game dengan NPC dan sistem misi.

## Misi 1: Pengumpulan Bahan Arsip

**Tujuan pembelajaran:** Siswa belajar memilah dokumen mana yang layak
diarsipkan secara digital (prioritas & bernilai) vs yang tidak perlu.

### Alur Permainan
1. Siswa menemui NPC **Bu Arsi** (Kepala Arsip) dan klik kanan untuk bicara.
2. NPC memberi misi: kumpulkan **3 dokumen prioritas** yang tersebar.
3. Siswa memukul (klik kiri) berkas. Jika prioritas -> benar; jika biasa -> feedback edukatif.
4. Setelah 3 dokumen prioritas terkumpul, siswa lapor ke Bu Arsi -> misi selesai.

## Cara Instalasi
1. Install Luanti (https://www.luanti.org). Di Ubuntu bisa via PPA/AppImage.
2. Salin folder `pae_arsip` ke direktori mods Luanti:
   - Global: `~/.minetest/mods/`  (atau `~/.luanti/mods/`)
3. Buat sebuah World baru (game "Minetest Game" dasar).
4. Aktifkan mod `pae_arsip` pada menu "Select Mods" saat konfigurasi world.
5. Masuk ke world.

## Cara Menjalankan Misi (untuk Guru)
Berikan diri Anda privilege server, lalu ketik di chat:
```
/pae_setup
```
Perintah ini akan memunculkan NPC Bu Arsi dan menyebar dokumen di sekitar Anda.

Untuk mengulang: `/pae_reset` (mereset progress misi Anda).

## Struktur File
```
pae_arsip/
├── mod.conf          # metadata mod
├── init.lua          # seluruh logika misi (item, node, NPC, dialog, command)
├── README.md         # dokumen ini
└── textures/         # gambar (placeholder 16x16, ganti sesuai selera)
    ├── pae_dok_prioritas.png
    ├── pae_dok_biasa.png
    ├── pae_node_prioritas.png
    ├── pae_node_biasa.png
    └── pae_npc_arsi.png
```

## Catatan Teknis
- Mod memakai namespace `core` (Luanti modern). Alias `minetest` juga tetap valid.
- Tekstur yang disertakan adalah placeholder warna solid. Ganti dengan
  gambar/ikon yang lebih representatif (mis. ikon dokumen, karakter guru).

## Roadmap Misi Berikutnya
- Misi 2: Pemindaian (scan 600 dpi / format TIFF)
- Misi 3: Manipulasi & Entry Data (TIFF -> PDF, metadata & kata kunci)
- Misi 4: Penataan & Indeksasi (folder /Tahun/Unit/Kode/)
- Misi 5: Penyimpanan & Backup (server, RAID, backup off-site)
- Misi Final: Penyusutan & Retensi Arsip
