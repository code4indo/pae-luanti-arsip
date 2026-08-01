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
        visual = "upright_sprite",
        visual_size = {x = 1, y = 2},
        textures = {"pae_npc_arsi.png"},
        static_save = true,
        infotext = "Bu Arsi (Kepala Arsip)\nKlik kanan untuk bicara",
    },
    on_activate = function(self, staticdata)
        self.object:set_armor_groups({immortal = 1})  -- NPC tak bisa dibunuh
    end,
    on_rightclick = function(self, clicker)
        if not clicker or not clicker:is_player() then return end
        local name = clicker:get_player_name()
        local p = pae_arsip.players[name]
        if not p then
            pae_arsip.players[name] = {active = false, terkumpul = 0, selesai = false}
            p = pae_arsip.players[name]
        end
        if p.selesai then
            core.chat_send_player(name,
                core.colorize("#00FFFF", "[Bu Arsi] ") ..
                "Terima kasih! Misi Pengumpulan Bahan sudah kamu selesaikan.")
        elseif p.active and p.terkumpul >= TARGET_PRIORITAS then
            p.selesai = true
            p.active = false
            tampil_dialog_selesai(name)
        elseif p.active then
            core.chat_send_player(name,
                core.colorize("#FFD700", "[Bu Arsi] ") ..
                "Kamu baru mengumpulkan " .. p.terkumpul .. "/" .. TARGET_PRIORITAS ..
                " dokumen prioritas. Lanjutkan!")
        else
            tampil_dialog_mulai(name)
        end
    end,
})

-- Handler tombol formspec
core.register_on_player_receive_fields(function(player, formname, fields)
    local name = player:get_player_name()
    if formname == "pae_arsip:dialog_mulai" and fields.terima then
        pae_arsip.players[name] = {active = true, terkumpul = 0, selesai = false}
        core.chat_send_player(name,
            core.colorize("#7CFC00", "[MISI DIMULAI] ") ..
            "Kumpulkan " .. TARGET_PRIORITAS .. " dokumen prioritas dengan MEMUKUL (klik kiri) berkasnya.")
    end
end)

--------------------------------------------------------------------
-- 4. PERINTAH CHAT UNTUK GURU (setup cepat arena misi)
--    /pae_setup  -> memunculkan NPC + menyebar dokumen di sekitar guru
--------------------------------------------------------------------

core.register_chatcommand("pae_setup", {
    description = "Setup arena Misi 1 PAE (NPC + dokumen) di sekitar pemain",
    privs = {server = true},
    func = function(name)
        local player = core.get_player_by_name(name)
        if not player then return false, "Pemain tidak ditemukan." end
        local pos = player:get_pos()

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

        return true, "[PAE] Arena Misi 1 siap! Temui Bu Arsi & mulai mengumpulkan bahan."
    end,
})

-- Perintah reset progress pemain (untuk uji coba)
core.register_chatcommand("pae_reset", {
    description = "Reset progress misi PAE milik sendiri",
    func = function(name)
        pae_arsip.players[name] = {active = false, terkumpul = 0, selesai = false}
        return true, "[PAE] Progress misimu telah direset."
    end,
})

core.log("action", "[pae_arsip] Mod Misi 1 (Pengumpulan Bahan Arsip) berhasil dimuat.")
