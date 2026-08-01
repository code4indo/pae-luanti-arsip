--[[
====================================================================
  MOD: pae_arsip
  MEDIA PEMBELAJARAN: Pengelolaan Arsip Elektronik (PAE)
  MISI 1: "Pengumpulan Bahan Arsip"
--------------------------------------------------------------------
  Tujuan Pembelajaran:
    Siswa belajar MEMILAH dokumen mana yang layak diarsipkan
    secara digital berdasarkan prioritas & nilai informasi.
    (Sesuai tahap "Pengumpulan Bahan" dalam PAE)

  Alur Misi:
    1. Siswa berbicara dengan NPC "Bu Arsi" (Kepala Arsip).
    2. NPC memberi misi: kumpulkan 3 dokumen PRIORITAS dari 5 dokumen
       yang tersebar. Dokumen yang tidak layak arsip = pengecoh.
    3. Siswa klik (punch) dokumen prioritas untuk mengambilnya.
    4. Setelah 3 dokumen prioritas terkumpul, lapor ke NPC -> misi selesai.

  Catatan API: Luanti kini memakai namespace `core`, tapi `minetest`
  tetap tersedia sebagai alias. Di sini kita pakai `core`.
====================================================================
]]

pae_arsip = {}
pae_arsip.players = {}   -- menyimpan progress tiap pemain

-- Konfigurasi misi
local TARGET_PRIORITAS = 3  -- jumlah dokumen prioritas yang harus dikumpulkan

--------------------------------------------------------------------
-- 0. SISTEM HUD OBJEKTIF (persisten di pojok layar)
--    Menampilkan tujuan misi + progress agar siswa tidak bingung.
--    Selalu terlihat selama misi berjalan, update otomatis tiap aksi.
--------------------------------------------------------------------

-- Bangun teks objektif sesuai status pemain
local function teks_objektif(p)
    if not p then return "" end
    if p.selesai then
        return "MISI 1 SELESAI - Bahan arsip terkumpul!"
    elseif p.active then
        if p.terkumpul >= TARGET_PRIORITAS then
            return "Misi: Kembali & lapor ke Bu Arsi (klik kanan)"
        end
        return "Misi: Kumpulkan dokumen PRIORITAS  " ..
               p.terkumpul .. "/" .. TARGET_PRIORITAS ..
               "  (pukul/klik kiri berkasnya)"
    else
        return "Misi: Temui Bu Arsi (klik kanan) untuk memulai"
    end
end

-- Perbarui / buat HUD objektif untuk pemain
function pae_arsip.update_hud(name)
    local player = core.get_player_by_name(name)
    if not player then return end
    local p = pae_arsip.players[name]
    if not p then return end
    local teks = teks_objektif(p)
    local warna = p.selesai and 0x00FFFF or (p.active and 0x7CFC00 or 0xFFD700)

    if p.hud then
        -- Perbarui HUD yang sudah ada
        player:hud_change(p.hud, "text", teks)
        player:hud_change(p.hud, "number", warna)
    else
        -- Buat elemen HUD baru (pojok kiri atas)
        p.hud = player:hud_add({
            hud_elem_type = "text",
            position = {x = 0, y = 0},
            offset = {x = 12, y = 34},
            alignment = {x = 1, y = 1},
            scale = {x = 100, y = 100},
            text = teks,
            number = warna,
        })
    end
end

-- Hapus HUD objektif pemain (mis. saat keluar / reset)
function pae_arsip.clear_hud(name)
    local player = core.get_player_by_name(name)
    local p = pae_arsip.players[name]
    if player and p and p.hud then
        player:hud_remove(p.hud)
    end
    if p then p.hud = nil end
end

--------------------------------------------------------------------
-- 1. DEFINISI ITEM DOKUMEN
--    Ada 2 jenis: PRIORITAS (layak arsip) & BIASA (pengecoh).
--------------------------------------------------------------------

-- Dokumen PRIORITAS (bernilai tinggi / penting untuk diarsipkan)
core.register_craftitem("pae_arsip:dok_prioritas", {
    description = "Dokumen Prioritas (Layak Arsip)\n" ..
                  core.colorize("#7CFC00", "Bernilai penting - wajib diarsipkan"),
    inventory_image = "pae_dok_prioritas.png",
    stack_max = 99,
})

-- Dokumen BIASA (pengecoh - tidak semua bahan layak diarsipkan)
core.register_craftitem("pae_arsip:dok_biasa", {
    description = "Dokumen Biasa (Tidak Prioritas)\n" ..
                  core.colorize("#FF7F7F", "Nilai informasi rendah - tidak perlu diarsipkan"),
    inventory_image = "pae_dok_biasa.png",
    stack_max = 99,
})

--------------------------------------------------------------------
-- 2. NODE DOKUMEN DI DUNIA (yang bisa di-"punch"/klik siswa)
--    Saat dipukul, node hilang & memberi reaksi edukatif.
--------------------------------------------------------------------

-- Node dokumen prioritas (di dunia)
core.register_node("pae_arsip:node_prioritas", {
    description = "Berkas Prioritas",
    tiles = {"pae_node_prioritas.png"},
    groups = {oddly_breakable_by_hand = 3, dig_immediate = 3},
    walkable = true,
    on_punch = function(pos, node, puncher)
        if not puncher or not puncher:is_player() then return end
        local name = puncher:get_player_name()
        local p = pae_arsip.players[name]
        if not p or not p.active then
            core.chat_send_player(name,
                core.colorize("#FFD700", "[PAE] ") ..
                "Bicaralah dulu dengan Bu Arsi (Kepala Arsip) untuk memulai misi!")
            return
        end
        -- Tambah progress
        p.terkumpul = p.terkumpul + 1
        core.remove_node(pos)
        pae_arsip.update_hud(name)  -- perbarui HUD objektif
        core.chat_send_player(name,
            core.colorize("#7CFC00", "[BENAR] ") ..
            "Dokumen prioritas dikumpulkan! (" .. p.terkumpul .. "/" .. TARGET_PRIORITAS .. ")")
        core.sound_play("default_dig_immediate", {pos = pos, gain = 0.5}, true)
        if p.terkumpul >= TARGET_PRIORITAS then
            core.chat_send_player(name,
                core.colorize("#00FFFF", "[PAE] ") ..
                "Semua dokumen prioritas terkumpul! Kembali & lapor ke Bu Arsi.")
        end
    end,
})

-- Node dokumen biasa/pengecoh (di dunia)
core.register_node("pae_arsip:node_biasa", {
    description = "Berkas Biasa",
    tiles = {"pae_node_biasa.png"},
    groups = {oddly_breakable_by_hand = 3, dig_immediate = 3},
    walkable = true,
    on_punch = function(pos, node, puncher)
        if not puncher or not puncher:is_player() then return end
        local name = puncher:get_player_name()
        local p = pae_arsip.players[name]
        if not p or not p.active then return end
        -- Edukasi: dokumen ini TIDAK layak diarsipkan
        core.chat_send_player(name,
            core.colorize("#FF7F7F", "[SALAH] ") ..
            "Dokumen ini bernilai rendah dan TIDAK perlu diarsipkan. " ..
            "Ingat: hanya arsipkan data yang masih relevan & bernilai penting.")
        core.sound_play("default_dug_node", {pos = pos, gain = 0.4}, true)
    end,
})

--------------------------------------------------------------------
-- 3. NPC "BU ARSI" (Kepala Arsip) menggunakan LuaEntity sederhana
--    Saat di-klik (on_rightclick), ia memberi/menyelesaikan misi
--    lewat formspec dialog.
--------------------------------------------------------------------

local function tampil_dialog_mulai(name)
    local fs =
        "size[8,6]" ..
        "bgcolor[#080808BB;true]" ..
        "label[0.3,0.2;" .. core.colorize("#FFD700", "Bu Arsi - Kepala Arsip") .. "]" ..
        "textarea[0.4,0.8;7.4,3.5;;;" ..
        "Selamat datang, calon arsiparis!\n\n" ..
        "Tugas pertamamu adalah PENGUMPULAN BAHAN.\n" ..
        "Kumpulkan " .. TARGET_PRIORITAS .. " DOKUMEN PRIORITAS yang tersebar di ruangan.\n\n" ..
        "INGAT: Tidak semua dokumen layak diarsipkan!\n" ..
        "Pilih hanya yang bernilai penting & relevan.]" ..
        "button_exit[2.5,5;3,0.8;terima;Terima Misi]"
    core.show_formspec(name, "pae_arsip:dialog_mulai", fs)
end

local function tampil_dialog_selesai(name)
    local fs =
        "size[8,5]" ..
        "bgcolor[#080808BB;true]" ..
        "label[0.3,0.2;" .. core.colorize("#00FFFF", "Bu Arsi - Kepala Arsip") .. "]" ..
        "textarea[0.4,0.8;7.4,2.8;;;" ..
        "Kerja bagus! Kamu berhasil memilah dokumen prioritas dengan tepat.\n\n" ..
        "Inilah langkah pertama PAE: mengumpulkan bahan yang benar-benar\n" ..
        "bernilai untuk diarsipkan. Siap lanjut ke misi Pemindaian?]" ..
        "button_exit[2.5,4;3,0.8;ok;Selesai]"
    core.show_formspec(name, "pae_arsip:dialog_selesai", fs)
end

core.register_entity("pae_arsip:npc_arsi", {
    initial_properties = {
        hp_max = 20,
        physical = true,
        collide_with_objects = true,
        collisionbox = {-0.35, -1.0, -0.35, 0.35, 0.8, 0.35},
        -- Model 3D humanoid (memakai model bawaan Minetest Game: character.b3d)
        visual = "mesh",
        mesh = "character.b3d",
        textures = {"pae_npc_arsi.png"},  -- skin humanoid layout 64x32
        visual_size = {x = 1, y = 1},
        static_save = true,
        infotext = "Bu Arsi (Kepala Arsip)\nKlik kanan untuk bicara",
    },
    on_activate = function(self, staticdata)
        self.object:set_armor_groups({immortal = 1})  -- NPC tak bisa dibunuh
        -- Animasi "berdiri" (stand) dari model character.b3d: frame 0-79
        self.object:set_animation({x = 0, y = 79}, 30, 0, true)
        -- Hindari NPC jatuh/terdorong gravitasi berlebih
        self.object:set_acceleration({x = 0, y = -9.8, z = 0})
    end,
    on_rightclick = function(self, clicker)
        if not clicker or not clicker:is_player() then return end
        local name = clicker:get_player_name()
        local p = pae_arsip.players[name]
        if not p then
            pae_arsip.players[name] = {active = false, terkumpul = 0, selesai = false}
            p = pae_arsip.players[name]
        end
        -- Pastikan HUD objektif tampil sejak interaksi pertama
        pae_arsip.update_hud(name)
        if p.selesai then
            core.chat_send_player(name,
                core.colorize("#00FFFF", "[Bu Arsi] ") ..
                "Terima kasih! Misi Pengumpulan Bahan sudah kamu selesaikan.")
        elseif p.active and p.terkumpul >= TARGET_PRIORITAS then
            p.selesai = true
            p.active = false
            pae_arsip.update_hud(name)  -- perbarui HUD ke status selesai
            tampil_dialog_selesai(name)
        elseif p.active then
            -- Instruksi BISA DIAKSES ULANG: tampilkan lagi cara main + progress
            core.chat_send_player(name,
                core.colorize("#FFD700", "[Bu Arsi] ") ..
                "Progresmu: " .. p.terkumpul .. "/" .. TARGET_PRIORITAS .. " dokumen prioritas.")
            core.chat_send_player(name,
                core.colorize("#FFD700", "[Cara Main] ") ..
                "Cari berkas PRIORITAS lalu PUKUL (klik kiri) untuk mengambilnya. " ..
                "Hindari berkas biasa/pengecoh. Lihat objektif di pojok kiri atas layar.")
        else
            tampil_dialog_mulai(name)
        end
    end,
})

-- Handler tombol formspec
core.register_on_player_receive_fields(function(player, formname, fields)
    local name = player:get_player_name()
    if formname == "pae_arsip:dialog_mulai" and fields.terima then
        local prev = pae_arsip.players[name]
        pae_arsip.players[name] = {active = true, terkumpul = 0, selesai = false, hud = prev and prev.hud or nil}
        pae_arsip.update_hud(name)  -- tampilkan objektif misi di HUD
        core.chat_send_player(name,
            core.colorize("#7CFC00", "[MISI DIMULAI] ") ..
            "Kumpulkan " .. TARGET_PRIORITAS .. " dokumen prioritas dengan MEMUKUL (klik kiri) berkasnya.")
    end
end)

--------------------------------------------------------------------
-- 4. SPAWN ARENA MISI (fungsi bersama) + PERINTAH GURU
--    Dipakai oleh auto-spawn (saat pemain masuk) & perintah /pae_setup.
--------------------------------------------------------------------

-- Cek apakah sudah ada NPC Bu Arsi di sekitar posisi (anti-dobel).
local function ada_npc_didekat(pos, radius)
    for _, obj in ipairs(core.get_objects_inside_radius(pos, radius or 24)) do
        local le = obj:get_luaentity()
        if le and le.name == "pae_arsip:npc_arsi" then
            return true
        end
    end
    return false
end

-- Bangun arena Misi 1 (NPC + dokumen) di sekitar posisi tertentu.
-- Mengembalikan false bila dilewati karena NPC sudah ada di dekatnya.
function pae_arsip.spawn_arena(pos, force)
    if not pos then return false end
    -- Anti-dobel: jangan spawn NPC baru bila sudah ada di sekitar
    if not force and ada_npc_didekat(pos, 24) then
        return false
    end

    -- Spawn NPC Bu Arsi 2 blok di depan pemain
    local npc_pos = {x = pos.x + 2, y = pos.y, z = pos.z}
    core.add_entity(npc_pos, "pae_arsip:npc_arsi")

    -- Sebar 3 dokumen prioritas + 2 pengecoh di sekitar
    local titik_prioritas = {
        {x = pos.x + 4, y = pos.y, z = pos.z},
        {x = pos.x - 3, y = pos.y, z = pos.z + 2},
        {x = pos.x + 1, y = pos.y, z = pos.z - 4},
    }
    local titik_biasa = {
        {x = pos.x - 2, y = pos.y, z = pos.z - 2},
        {x = pos.x + 3, y = pos.y, z = pos.z + 3},
    }
    for _, tp in ipairs(titik_prioritas) do
        core.set_node(tp, {name = "pae_arsip:node_prioritas"})
    end
    for _, tb in ipairs(titik_biasa) do
        core.set_node(tb, {name = "pae_arsip:node_biasa"})
    end
    return true
end

core.register_chatcommand("pae_setup", {
    description = "Setup arena Misi 1 PAE (NPC + dokumen) di sekitar pemain",
    privs = {server = true},
    func = function(name)
        local player = core.get_player_by_name(name)
        if not player then return false, "Pemain tidak ditemukan." end
        -- force = true: guru selalu boleh membuat/mengatur ulang arena
        pae_arsip.spawn_arena(player:get_pos(), true)
        return true, "[PAE] Arena Misi 1 siap! Temui Bu Arsi & mulai mengumpulkan bahan."
    end,
})

-- Perintah reset progress pemain (untuk uji coba)
core.register_chatcommand("pae_reset", {
    description = "Reset progress misi PAE milik sendiri",
    func = function(name)
        local prev = pae_arsip.players[name]
        pae_arsip.players[name] = {active = false, terkumpul = 0, selesai = false, hud = prev and prev.hud or nil}
        pae_arsip.update_hud(name)  -- perbarui HUD ke status awal
        return true, "[PAE] Progress misimu telah direset."
    end,
})

-- Bersihkan referensi HUD saat pemain keluar (agar tidak menumpuk saat login lagi)
core.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    local p = pae_arsip.players[name]
    if p then p.hud = nil end
end)

--------------------------------------------------------------------
-- 5. AUTO-SPAWN SAAT PEMAIN MASUK (Opsi D)
--    Pemain langsung menemukan arena tanpa perlu tahu perintah apa pun:
--      - NPC + dokumen otomatis muncul di dekat pemain (anti-dobel).
--      - Pesan sambutan berpetunjuk dikirim ke chat.
--      - HUD objektif langsung aktif di pojok kiri atas.
--------------------------------------------------------------------

core.register_on_joinplayer(function(player)
    local name = player:get_player_name()

    -- Siapkan state pemain (pertahankan progress bila sudah ada)
    if not pae_arsip.players[name] then
        pae_arsip.players[name] = {active = false, terkumpul = 0, selesai = false}
    else
        pae_arsip.players[name].hud = nil  -- HUD lama tak berlaku sesudah login ulang
    end

    -- Beri jeda agar posisi & map di sekitar pemain sudah termuat penuh
    core.after(2.0, function()
        local pl = core.get_player_by_name(name)
        if not pl then return end
        local p = pae_arsip.players[name]

        -- Tampilkan HUD objektif untuk semua pemain
        pae_arsip.update_hud(name)

        -- Auto-spawn arena hanya bila misi belum diselesaikan pemain ini
        if p and not p.selesai then
            local dibuat = pae_arsip.spawn_arena(pl:get_pos(), false)
            core.chat_send_player(name,
                core.colorize("#FFD700", "[PAE] ") ..
                "Selamat datang di Misi 1: Pengumpulan Bahan Arsip!")
            if dibuat then
                core.chat_send_player(name,
                    core.colorize("#7CFC00", "[Petunjuk] ") ..
                    "Bu Arsi (Kepala Arsip) ada di dekatmu - klik kanan untuk memulai. " ..
                    "Ikuti objektif di pojok kiri atas layar.")
            else
                core.chat_send_player(name,
                    core.colorize("#7CFC00", "[Petunjuk] ") ..
                    "Cari Bu Arsi (Kepala Arsip) di sekitarmu - klik kanan untuk memulai. " ..
                    "Ikuti objektif di pojok kiri atas layar.")
            end
        end
    end)
end)

core.log("action", "[pae_arsip] Mod Misi 1 (Pengumpulan Bahan Arsip) berhasil dimuat.")
