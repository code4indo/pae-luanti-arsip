#!/usr/bin/env python3
"""
Generator tekstur placeholder untuk mod pae_arsip.
Membuat 5 file PNG 16x16 warna solid di folder textures/.

Jalankan:
    python3 tools/generate_textures.py

Membutuhkan Pillow:  pip install Pillow
"""
import os

try:
    from PIL import Image
except ImportError:
    raise SystemExit("Pillow belum terpasang. Jalankan: pip install Pillow")

# Folder tujuan (relatif terhadap root repo)
DEST = os.path.join(os.path.dirname(__file__), "..", "mods", "pae_arsip", "textures")
DEST = os.path.abspath(DEST)
os.makedirs(DEST, exist_ok=True)

# Nama file -> warna RGB
WARNA = {
    "pae_dok_prioritas.png":  (60, 200, 60),    # hijau  - dokumen prioritas (item)
    "pae_dok_biasa.png":      (200, 80, 80),     # merah  - dokumen biasa (item)
    "pae_node_prioritas.png": (90, 220, 90),     # hijau muda - berkas prioritas (node)
    "pae_node_biasa.png":     (210, 120, 120),   # merah muda - berkas biasa (node)
    "pae_npc_arsi.png":       (80, 120, 220),    # biru   - NPC Bu Arsi
}

for nama, c in WARNA.items():
    img = Image.new("RGBA", (16, 16), c + (255,))
    img.save(os.path.join(DEST, nama))
    print(f"  dibuat: {nama}  {c}")

print(f"\nSelesai! {len(WARNA)} tekstur placeholder tersimpan di:\n  {DEST}")
print("Silakan ganti dengan ikon yang lebih representatif sesuai selera.")
