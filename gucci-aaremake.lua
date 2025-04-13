local requirements = {
    ffi = require("ffi"),
    vector = require("vector"),
    bit = require("bit"),
    antiaim_funcs = require("gamesense/antiaim_funcs"),
    csgo_weapons = require("gamesense/csgo_weapons"),
    clipboard = require("gamesense/clipboard"),
    surface = require("gamesense/surface"),
    base64 = require 'gamesense/base64',
    obex_data = obex_fetch and obex_fetch() or {username = 'peti', build = 'source'},
    images = "gamesense/images",
ent = require "gamesense/entity"


}

local bit_band, client_camera_angles, client_color_log, client_create_interface, client_delay_call, client_exec, client_eye_position, client_key_state, client_log, client_random_int, client_scale_damage, client_screen_size, client_set_event_callback, client_trace_bullet, client_userid_to_entindex, database_read, database_write, entity_get_local_player, entity_get_player_weapon, entity_get_players, entity_get_prop, entity_hitbox_position, entity_is_alive, entity_is_enemy, math_abs, math_atan2, require, error, globals_absoluteframetime, globals_curtime, globals_realtime, math_atan, math_cos, math_deg, math_floor, math_max, math_min, math_rad, math_sin, math_sqrt, print, renderer_circle_outline, renderer_gradient, renderer_measure_text, renderer_rectangle, renderer_text, renderer_triangle, string_find, string_gmatch, string_gsub, string_lower, table_insert, table_remove, ui_get, ui_new_checkbox, ui_new_color_picker, ui_new_hotkey, ui_new_multiselect, ui_reference, tostring, ui_is_menu_open, ui_mouse_position, ui_new_combobox, ui_new_slider, ui_set, ui_set_callback, ui_set_visible, tonumber, pcall = bit.band, client.camera_angles, client.color_log, client.create_interface, client.delay_call, client.exec, client.eye_position, client.key_state, client.log, client.random_int, client.scale_damage, client.screen_size, client.set_event_callback, client.trace_bullet, client.userid_to_entindex, database.read, database.write, entity.get_local_player, entity.get_player_weapon, entity.get_players, entity.get_prop, entity.hitbox_position, entity.is_alive, entity.is_enemy, math.abs, math.atan2, require, error, globals.absoluteframetime, globals.curtime, globals.realtime, math.atan, math.cos, math.deg, math.floor, math.max, math.min, math.rad, math.sin, math.sqrt, print, renderer.circle_outline, renderer.gradient, renderer.measure_text, renderer.rectangle, renderer.text, renderer.triangle, string.find, string.gmatch, string.gsub, string.lower, table.insert, table.remove, ui.get, ui.new_checkbox, ui.new_color_picker, ui.new_hotkey, ui.new_multiselect, ui.reference, tostring, ui.is_menu_open, ui.mouse_position, ui.new_combobox, ui.new_slider, ui.set, ui.set_callback, ui.set_visible, tonumber, pcall
local ui_menu_position, ui_menu_size, math_pi, renderer_indicator, entity_is_dormant, client_set_clan_tag, client_trace_line, entity_get_all, entity_get_classname = ui.menu_position, ui.menu_size, math.pi, renderer.indicator, entity.is_dormant, client.set_clan_tag, client.trace_line, entity.get_all, entity.get_classname
local ffi = require('ffi')
local ffi_cast = ffi.cast
local http = require "gamesense/http"
local images = require 'gamesense/images'
-- https://pastebin.com/raw/4wABtEb2

ref_aa_enabled = ui.reference("AA", "Anti-aimbot angles", "Enabled")
legsmovement = ui.reference("AA", "Other", "Leg movement")

function ioset()
    ui.set(ref_aa_enabled, true)
end

manipulation_tick = function(a, b, time, delay)
    local tick = globals.tickcount()
    local period = delay + time
    
    if tick % period < time then
        return a
    else
        return b
    end
end;

manipulation_break = function(a, b, time)
    return (time / 2 <= (globals.tickcount() % time)) and a or b --print
end

a = 5

ffi.cdef [[
typedef int(__thiscall* get_clipboard_text_count)(void*);
typedef void(__thiscall* set_clipboard_text)(void*, const char*, int);
typedef void(__thiscall* get_clipboard_text)(void*, int, const char*, int);
]]
local VGUI_System010 =  client_create_interface("vgui2.dll", "VGUI_System010") or print( "Error finding VGUI_System010")
local VGUI_System = ffi_cast(ffi.typeof('void***'), VGUI_System010 )
local get_clipboard_text_count = ffi_cast( "get_clipboard_text_count", VGUI_System[ 0 ][ 7 ] ) or print( "get_clipboard_text_count Invalid")
local set_clipboard_text = ffi_cast( "set_clipboard_text", VGUI_System[ 0 ][ 9 ] ) or print( "set_clipboard_text Invalid")
local get_clipboard_text = ffi_cast( "get_clipboard_text", VGUI_System[ 0 ][ 11 ] ) or print( "get_clipboard_text Invalid")

function string_anim(text, frac)
    return string.sub(text,1, math.ceil(string.len(text) * frac))
  end

function RGBAtoHEX(redArg, greenArg, blueArg, alphaArg)
    return string.format('%.2x%.2x%.2x%.2x', redArg, greenArg, blueArg, alphaArg)
end

function RGBtoHEX(redArg, greenArg, blueArg)
    return string.format('%.2x%.2x%.2x', redArg, greenArg, blueArg)
end

local hitgroup_names = {'generic', 'head', 'chest', 'stomach', 'left arm', 'right arm', 'left leg', 'right leg', 'neck', '?', 'gear'}
function fired(e)
    stored_shot = {
        damage = e.damage,
        hitbox = hitgroup_names[e.hitgroup + 1],
        lagcomp = e.teleported,
        backtrack = globals.tickcount() - e.tick
    }
end
client.set_event_callback("aim_fire", fired)

local animations = {anim_list = {}}

animations.math_clamp = function(value, min, max)
    return math.min(max, math.max(min, value))
end

animations.math_lerp = function(a, b_, t)
    -- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    local t = animations.math_clamp(2/50, 0, 1)

    if type(a) == 'userdata' then
        r, g, b, a = a.r, a.g, a.b, a.a
        e_r, e_g, e_b, e_a = b_.r, b_.g, b_.b, b_.a
        r = animations.math_lerp(r, e_r, t)
        g = animations.math_lerp(g, e_g, t)
        b = animations.math_lerp(b, e_b, t)
        a = animations.math_lerp(a, e_a, t)
        return color(r, g, b, a)
    end

    local d = b_ - a
    d = d * t
    d = d + a

    if b_ == 0 and d < 0.01 and d > -0.01 then
        d = 0
    elseif b_ == 1 and d < 1.01 and d > 0.99 then
        d = 1
    end

    return d
end

animations.vector_lerp = function(vecSource, vecDestination, flPercentage)
    return vecSource + (vecDestination - vecSource) * flPercentage
end

animations.anim_new = function(name, new, remove, speed)
    if not animations.anim_list[name] then
        animations.anim_list[name] = {}
        animations.anim_list[name].color = 0, 0, 0, 0
        animations.anim_list[name].number = 0
        animations.anim_list[name].call_frame = true
    end

    if remove == nil then
        animations.anim_list[name].call_frame = true
    end

    if speed == nil then
        speed = 0.100
    end

    if type(new) == 'userdata' then
        lerp = animations.math_lerp(animations.anim_list[name].color, new, speed)
        animations.anim_list[name].color = lerp

        return lerp
    end

    lerp = animations.math_lerp(animations.anim_list[name].number, new, speed)
    animations.anim_list[name].number = lerp

    return lerp
end

function countLetters(str)
     count = 0
    for i = 1, #str do
         char = str:sub(i, i)
        if char:match("%a") or char == " " then  -- %a matches alphabetic characters, or a space
            count = count + 1
        end
    end
    return count
end

local angle3d_struct = ffi.typeof("struct { float pitch; float yaw; float roll; }")
local vec_struct = ffi.typeof("struct { float x; float y; float z; }")

function getTime()
     hours = math.floor(globals.realtime() / 3600) % 24
     minutes = math.floor((globals.realtime() % 3600) / 60)
    return string.format("%02d:%02d", hours, minutes)
end

L29 = ffi.typeof('void***')
L30 = client.create_interface('client.dll', 'VClientEntityList003') or error('VClientEntityList003 wasnt found', 2)
L31 = ffi.cast(L29, L30) or error('rawientitylist is nil', 2)
L32 = ffi.cast('void*(__thiscall*)(void*, int)', L31[0][3]) or error('get_client_entity is nil', 2)

ffi.cdef([[
    struct animation_layer_t {
        char  pad_0000[20];
        uint32_t m_nOrder; //0x0014
        uint32_t m_nSequence; //0x0018
        float m_flPrevCycle; //0x001C
        float m_flWeight; //0x0020
        float m_flWeightDeltaRate; //0x0024
        float m_flPlaybackRate; //0x0028
        float m_flCycle; //0x002C
        void *m_pOwner; //0x0030 // player's thisptr
        char  pad_0038[4]; //0x0034
    };

    struct animstate_t1 {
        char pad[ 3 ];
        char m_bForceWeaponUpdate; //0x4
        char pad1[ 91 ];
        void* m_pBaseEntity; //0x60
        void* m_pActiveWeapon; //0x64
        void* m_pLastActiveWeapon; //0x68
        float m_flLastClientSideAnimationUpdateTime; //0x6C
        int m_iLastClientSideAnimationUpdateFramecount; //0x70
        float m_flAnimUpdateDelta; //0x74
        float m_flEyeYaw; //0x78
        float m_flPitch; //0x7C
        float m_flGoalFeetYaw; //0x80
        float m_flCurrentFeetYaw; //0x84
        float m_flCurrentTorsoYaw; //0x88
        float m_flUnknownVelocityLean; //0x8C
        float m_flLeanAmount; //0x90
        char pad2[ 4 ];
        float m_flFeetCycle; //0x98
        float m_flFeetYawRate; //0x9C
        char pad3[ 4 ];
        float m_fDuckAmount; //0xA4
        float m_fLandingDuckAdditiveSomething; //0xA8
        char pad4[ 4 ];
        float m_vOriginX; //0xB0
        float m_vOriginY; //0xB4
        float m_vOriginZ; //0xB8
        float m_vLastOriginX; //0xBC
        float m_vLastOriginY; //0xC0
        float m_vLastOriginZ; //0xC4
        float m_vVelocityX; //0xC8
        float m_vVelocityY; //0xCC
        char pad5[ 4 ];
        float m_flUnknownFloat1; //0xD4
        char pad6[ 8 ];
        float m_flUnknownFloat2; //0xE0
        float m_flUnknownFloat3; //0xE4
        float m_flUnknown; //0xE8
        float m_flSpeed2D; //0xEC
        float m_flUpVelocity; //0xF0
        float m_flSpeedNormalized; //0xF4
        float m_flFeetSpeedForwardsOrSideWays; //0xF8
        float m_flFeetSpeedUnknownForwardOrSideways; //0xFC
        float m_flTimeSinceStartedMoving; //0x100
        float m_flTimeSinceStoppedMoving; //0x104
        bool m_bOnGround; //0x108
        bool m_bInHitGroundAnimation; //0x109
        char m_pad[2];
        float m_flJumpToFall;
        float m_flTimeSinceInAir; //0x10A
        float m_flLastOriginZ; //0x10E
        float m_flHeadHeightOrOffsetFromHittingGroundAnimation; //0x112
        float m_flStopToFullRunningFraction; //0x116
        char pad7[ 4 ]; //0x11A
        float m_flMagicFraction; //0x11E
        char pad8[ 60 ]; //0x122
        float m_flWorldForce; //0x15E
        char pad9[ 462 ]; //0x162
        float m_flMaxYaw; //0x334
    };

]])


L63 = ffi.typeof("struct { float pitch; float yaw; float roll; }")
L64 = ffi.typeof("struct { float x; float y; float z; }")
ffi.typeof([[
    struct
    {
        uintptr_t vfptr;
        int command_number;
        int tick_count;
        $ viewangles;
        $ aimdirection;
        float forwardmove;
        float sidemove;
        float upmove;
        int buttons;
        uint8_t impulse;
        int weaponselect;
        int weaponsubtype;
        int random_seed;
        short mousedx;
        short mousedy;
        bool hasbeenpredicted;
        $ headangles;
        $ headoffset;
    }
]], L63, L64, L63, L64)

local cUserCmd =
ffi.typeof(
[[
struct
{
    uintptr_t vfptr;
    int command_number;
    int tick_count;
    $ viewangles;
    $ aimdirection;
    float forwardmove;
    float sidemove;
    float upmove;
    int buttons;
    uint8_t impulse;
    int weaponselect;
    int weaponsubtype;
    int random_seed;
    short mousedx;
    short mousedy;
    bool hasbeenpredicted;
    $ headangles;
    $ headoffset;
    bool send_packet; 
}
]],
angle3d_struct,
vec_struct,
angle3d_struct,
vec_struct
)

local printc do
    ffi.cdef[[
        typedef struct { uint8_t r; uint8_t g; uint8_t b; uint8_t a; } color_struct_t;
    ]]

	local print_interface = ffi.cast("void***", client.create_interface("vstdlib.dll", "VEngineCvar007"))
	local color_print_fn = ffi.cast("void(__cdecl*)(void*, const color_struct_t&, const char*, ...)", print_interface[0][25])

    -- 
    local hex_to_rgb = function (hex)
        return tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16), tonumber(hex:sub(7, 8), 16)
    end
	
	local raw = function(text, r, g, b, a)
		local col = ffi.new("color_struct_t")
		col.r, col.g, col.b, col.a = r or 217, g or 217, b or 217, a or 255
	
		color_print_fn(print_interface, col, tostring(text))
	end

	printc = function (...)
		for i, v in ipairs{...} do
			local r = "\aD9D9D9"..v
			for col, text in r:gmatch("\a(%x%x%x%x%x%x)([^\a]*)") do
				raw(text, hex_to_rgb(col))
			end
		end
		raw "\n"
	end
end

local draw_logs = function()
    local name = {
"",
"",
"",
"                    \affffffYou have loaded \a26d0ffgucci.lua                    ",
"               \a878787[nothing new....]",
" ",                                                                                                                                                                                              
--O.G. L.E.A.K.S.
    }

    client.exec("clear")
	
    for _, line in pairs(name) do
        printc(line) 
        --client.color_log(255 / 6 * _, 8 / 6 * _, 5/ 6 * _, line)
    end


    client.exec("con_filter_enable 1")
    client.exec("con_filter_text IrWL5106TZZKNFPz4P4Gl3pSN?J370f5hi373ZjPg%VOVh6lN")
end
draw_logs()

local data = database.read("db1") or {}

local L26 = { absoluteframetime = globals.absoluteframetime, chokedcommands = globals.chokedcommands, commandack = globals.commandack, curtime = globals.curtime, framecount = globals.framecount, frametime = globals.frametime, lastoutgoingcommand = globals.lastoutgoingcommand, mapname = globals.mapname, maxplayers = globals.maxplayers, oldcommandack = globals.oldcommandack, realtime = globals.realtime, tickcount = globals.tickcount, tickinterval = globals.tickinterval }


data.load_count = (data.load_count or 0) + 1

local client_sig = client.find_signature("client.dll", "\xB9\xCC\xCC\xCC\xCC\x8B\x40\x38\xFF\xD0\x84\xC0\x0F\x85") or error("client.dll!:input not found.")
local get_cUserCmd = ffi.typeof("$* (__thiscall*)(uintptr_t ecx, int nSlot, int sequence_number)", cUserCmd)
local input_vtbl = ffi.typeof([[struct{uintptr_t padding[8];$ GetUserCmd;}]],get_cUserCmd)
local input = ffi.typeof([[struct{$* vfptr;}*]], input_vtbl)
local get_input = ffi.cast(input,ffi.cast("uintptr_t**",tonumber(ffi.cast("uintptr_t", client_sig)) + 1)[0])
local function clipboard_import( )
    local clipboard_text_length = get_clipboard_text_count( VGUI_System )
    local clipboard_data = ""

    if clipboard_text_length > 0 then
        buffer = ffi.new("char[?]", clipboard_text_length)
        size = clipboard_text_length * ffi.sizeof("char[?]", clipboard_text_length)

        get_clipboard_text( VGUI_System, 0, buffer, size )

        clipboard_data = ffi.string( buffer, clipboard_text_length-1 )
    end
    return clipboard_data
end

reducer = function(L133, L134, L135)
    return L133 + (L134 - L133) * L135
end;

rgba_to_hex = function(b,c,d,e)
    return string.format('%02x%02x%02x%02x',b,c,d,e)
end
text_fade_animation = function(speed, r, g, b, a, text)
     final_text = ''
     curtime = globals.curtime()
    for i=0, #text do
         color = rgba_to_hex(r, g, b, a*math.abs(1*math.cos(2*speed*curtime/4+i*5/30)))
        final_text = final_text..'\a'..color..text:sub(i, i)
    end
    return final_text
end

local function clipboard_export(string)
    if string then
        set_clipboard_text(VGUI_System, string, string:len())
    end
end
--Important Functions
local function contains(table, value)

    if table == nil then
        return false
    end

    table = ui.get(table)
    for i=0, #table do
        if table[i] == value then
            return true
        end
    end
    return false
end

local spinix = function(L107, L108, L109)
    return math.max(math.min(L107, L109), L108)
end


local function SetTableVisibility(table, state)
    for i = 1, #table do
        ui.set_visible(table[i], state)
    end
end

L1 = requirements.bit
 L21 = { arshift = L1.arshift, band = L1.band, bnot = L1.bnot, bor = L1.bor, bswap = L1.bswap, bxor = L1.bxor, lshift = L1.lshift, rol = L1.rol, ror = L1.ror, rshift = L1.rshift, tobit = L1.tobit, tohex = L1.tohex }
 L61 = vtable_bind("vgui2.dll", "VGUI_System010", 22, "bool(__thiscall*)(void*, const char*)")
 L62 = { attack = L21.lshift(1, 0), use = L21.lshift(1, 5) }
 L63 = ffi.typeof("struct { float pitch; float yaw; float roll; }")
 L64 = ffi.typeof("struct { float x; float y; float z; }")
 yaw_increment_spin2 = 0
 yaw_increment_spin3 = 0
 L65 = ffi.typeof([[
        struct
        {
            uintptr_t vfptr;
            int command_number;
            int tick_count;
            $ viewangles;
            $ aimdirection;
            float forwardmove;
            float sidemove;
            float upmove;
            int buttons;
            uint8_t impulse;
            int weaponselect;
            int weaponsubtype;
            int random_seed;
            short mousedx;
            short mousedy;
            bool hasbeenpredicted;
            $ headangles;
            $ headoffset;
        }
        ]], L63, L64, L63, L64)
 L66 = ffi.typeof("$* (__thiscall*)(uintptr_t ecx, int nSlot, int sequence_number)", L65)
 L67 = ffi.typeof([[
        struct
        {
            uintptr_t padding[8];
            $ GetUserCmd;
        }
        ]], L66)
 L68 = ffi.typeof([[
        struct
        {
            $* vfptr;
        }*
        ]], L67)
 L69 = ffi.cast(L68, ffi.cast("uintptr_t**", tonumber(ffi.cast("uintptr_t", client.find_signature("client.dll", "\xB9\xCC\xCC\xCC\xCC\x8B\x40\x38\xFF\xD0\x84\xC0\x0F\x85") or error("client.dll!:input not found."))) + 1)[0])
local L70 = { reset_once = false, hitgroup_names = { [0] = "body", "head", "chest", "stomach", "left arm", "right arm", "left leg", "right leg", "neck", "?", "gear" }, fire_total_hits = 0, post_total_hits = 0, current_condition = "", mode = "back", is_defensive_running = false, banana = false, old_tick_count = 0, yaw_increment_spin = 0, tickbase_max, tickbase_diff, current_cmd, bomb_defused = false, bomb_exploded = false, pulse = 240, started = 10, smooth_wraith = 0, smooth_dt = 0, smooth_os = 0, smooth_pc = 0, smooth_bo = 0, current_desync = 0, fake_fakelag = 0, cur = 0, is_defusing = false, desync_rect_dist = 0, dt_os_text_anim = 0, current_cond_text_anim = 0, smooth_wraith_recode = 0, smooth_dt_2 = 0, smooth_stance = 0, dt_vertical_dist = 0, jumping = false, on_ground = false, rage_fired = false, last_jump_ducked = false, landing = false, waiting_scan_text = 0, hittable = false, defensive_risk = 0, smooth_defensive_bar = 0, smooth_left_arrow = 0, smooth_right_arrow = 0, smooth_up_arrow = 0, smooth_arrow_alpha = 0 }

local function oppositefix(c)
    local desync_amount = antiaim_funcs.get_desync(2)
    if math.abs(desync_amount) < 15 or c.chokedcommands ~= 0 then
        return
    end
end

--References
local ref = {
    pitch = {ui.reference("AA", "Anti-aimbot angles", "Pitch")},
    yaw_base = ui.reference("AA", "Anti-aimbot angles", "Yaw base"),
    yaw = {ui.reference("AA", "Anti-aimbot angles", "Yaw")},
    jitter = {ui.reference("AA", "Anti-aimbot angles", "Yaw jitter")},
    byaw = {ui.reference("AA", "Anti-aimbot angles", "Body yaw")},
    fby = ui.reference("AA", "Anti-aimbot angles", "Freestanding body yaw"),
    edge = ui.reference("AA", "Anti-aimbot angles", "Edge yaw"),
    freestanding = {ui.reference("AA", "Anti-aimbot angles", "Freestanding")},
    roll = ui.reference("AA", "Anti-aimbot angles", "Roll"),
    os = {ui.reference("AA", "Other", "On shot anti-aim")},
    dt = {ui.reference("RAGE", "Aimbot", "Double tap")},
    slowwalk = {ui.reference("AA","Other","Slow motion")},
    lm = ui.reference("AA","Other","Leg movement"),
    rollskeet = ui.reference("AA","Anti-aimbot angles", "Roll"),
    fake_duck = ui.reference("RAGE","Other","Duck peek assist"),
    enablefl = ui.reference("AA","Fake lag","Enabled"),
    enablexxx = ui.reference("AA","Anti-aimbot angles","Enabled"),
    fl_amount = ui.reference("AA", "Fake lag", "Amount"),
    fl_limit = ui.reference("AA","Fake lag","Limit"),
    fl_var = ui.reference("AA", "fake lag", "variance"),
    sp_key = ui.reference("RAGE", "Aimbot", "Force safe point"),
    baim_key = ui.reference("RAGE", "Aimbot", "Force body aim"),
    quickpeek = {ui.reference("RAGE", "Other", "Quick peek assist")},
    bt = {ui.reference("RAGE","Other","Accuracy boost")},
    force_safe_point = ui.reference("RAGE", "Aimbot", "Force safe point"),
    mindmg = ui.reference("RAGE", "Aimbot", "Minimum damage"),
    safepoint = ui.reference("RAGE", "Aimbot", "Force safe point"),
    forcebaim = ui.reference("RAGE", "Aimbot", "Force body aim"),
}

username = "admin"
build = "1.45alpha"
ui.new_label("AA", "Anti-aimbot angles", "» gucci ~\a878787ff "..build)
ui.new_label("AA", "Anti-aimbot angles", "    ")
ui.new_label("AA", "Anti-aimbot angles", "user : \a878787ff"..username)
ui.new_label("AA", "Anti-aimbot angles", "times loaded : \a878787ff"..data.load_count)
ui.new_label("AA", "Anti-aimbot angles", " ")
local menu = {
    retard = ui.new_combobox("AA", "Anti-aimbot angles", "[selection]", "\a878787ffhome","\a878787ffanti-aim", "\a878787ffvisuals"),
    ui.new_label("AA", "Anti-aimbot angles", "    "),
    ui.new_label("AA", "Anti-aimbot angles", "      "),
    ui.new_label("AA", "Anti-aimbot angles", "    "),

    hometext = ui.new_label("aa", "anti-aimbot angles","gucci ~ \a878787ffjoin our discord below"), --\a878787ff
    discords = ui.new_button("aa", "anti-aimbot angles", "DISCORD" , function()
        panorama.loadstring("SteamOverlayAPI.OpenExternalBrowserURL('https://discord.gg/BkCcRjzCqR');")()
    end),
    subtab_antiaim = ui.new_combobox("AA", "Anti-aimbot angles", "\a878787ff‹ gucci.shop ›", "main", "phases", "settings"),
    presets = ui.new_combobox("AA", "Anti-aimbot angles", "\a878787ffgucci.shop ⭒\aFFFFFFFF antiaim", "None", "Dynamic", "Builder"),
    cannotview = ui.new_label("AA", "Anti-aimbot angles", "currently using preset ~"),
    
    indclrtext = ui.new_label("AA", "Anti-aimbot angles", "\a878787ffgucci.shop ⭒\aFFFFFFFF indicators color"),
    main_clr = ui.new_color_picker("AA", "Anti-aimbot angles", "\a878787ffgucci.shop ⭒\aFFFFFFFF indicators color", 255,255,255, 255),
    main_clr2 = ui.new_color_picker("AA", "Anti-aimbot angles", "\a878787ffgucci.shop ⭒\aFFFFFFFF indicators color [2]", 255,255,255, 255),
    
    watermarkenable = ui.new_checkbox("AA", "Anti-aimbot angles", "\a878787ffgucci.shop ⭒\aFFFFFFFF watermark"),
    
    defensiveindicator = ui.new_checkbox("AA", "Anti-aimbot angles", "\a878787ffgucci.shop ⭒\aFFFFFFFF defensive indicator"),
    cdzenable = ui.new_checkbox("AA", "Anti-aimbot angles", "\a878787ffgucci.shop ⭒\aFFFFFFFF cool text"),
    cdz_custom = ui.new_textbox('AA', 'Anti-aimbot angles', "CDZ Text", "sa nu muncesc in zadar"),
    
    crossindicators = ui.new_checkbox("AA", "Anti-aimbot angles", "\a878787ffgucci.shop ⭒\aFFFFFFFF cross indicator"),
    dmgind = ui.new_checkbox("AA", "Anti-aimbot angles", "\a878787ffgucci.shop ⭒\aFFFFFFFF damage indicator"),
    killind = ui.new_checkbox("AA", "Anti-aimbot angles", "\a878787ffgucci.shop ⭒\aFFFFFFFF gucci killz"),
    dmgindcol = ui.new_color_picker("AA", "Anti-aimbot angles", "\a878787ffgucci.shop ⭒\aFFFFFFFF damage indicator color", 101, 219, 75, 255),
    logsss = ui.new_checkbox("AA", "Anti-aimbot angles", "\a878787ffgucci.shop ⭒\aFFFFFFFF enable logs"),
    notifys = ui.new_multiselect('AA', 'Anti-aimbot angles', '\a878787ffgucci.shop ⭒\aFFFFFFFF logs', "Hit", "Misses", "Switches"),
    consolelogs = ui.new_checkbox("AA", "Anti-aimbot angles", "\a878787ffgucci.shop ⭒\aFFFFFFFF console logs"),
    fs_toggle = ui.new_hotkey("AA", "Anti-aimbot angles", "\a878787ffgucci.shop ⭒\aFFFFFFFF freestanding"),
    lagcomp = ui.new_checkbox("AA", "Anti-aimbot angles", "\a878787ffgucci.shop ⭒\aFFFFFFFF low fl when hideshots"),
    arrows = ui.new_checkbox("AA", "Anti-aimbot angles", "\a878787ffgucci.shop ⭒\aFFFFFFFF manual arrows"),
    breaker_switch = ui.new_checkbox("AA", "Anti-aimbot angles", "\a878787ffgucci.shop ⭒\aFFFFFFFF defensive"),
    ctagenable = ui.new_checkbox("AA", "Anti-aimbot angles", "\a878787ffgucci.shop ⭒\aFFFFFFFF clantag"),
    checkbox = ui.new_checkbox("AA", "Anti-aimbot angles", "\a878787ffgucci.shop ⭒\aFFFFFFFF lean jumps"),
    checkbox2 = ui.new_checkbox("AA", "Anti-aimbot angles", "\a878787ffgucci.shop ⭒\aFFFFFFFF leg breaker"),
    antibrute_switch = ui_new_checkbox("AA", "Anti-aimbot angles", "\a878787ffgucci.shop ⭒\aFFFFFFFF anti-bruteforce"),
    contains = ui.new_combobox("AA", "Anti-aimbot angles", "\a878787ffgucci.shop ⭒\aFFFFFFFF antibrute settings", "Default", "Random", "RDS Exploit", "Custom"),
    bruteforce = {
        phases = ui.new_combobox("AA", "Anti-aimbot angles", "\a878787ffgucci.shop ⭒\aFFFFFFFF phase", "Phase 1", "Phase 2", "Phase 3", "Phase 4", "Phase 5"),
    },
    exploits = {
    yaw_1st = ui.new_slider("AA", "Anti-aimbot angles", "[\a878787ffBreaker\aFFFFFFFF] Yaw on first tick", -180, 180, 0),
    yaw_2nd = ui.new_slider("AA", "Anti-aimbot angles", "[\a878787ffBreaker\aFFFFFFFF] Yaw on second tick", -180, 180, 0),
        pitch = ui.new_combobox("AA", "Anti-aimbot angles", "[\a878787ffBreaker\aFFFFFFFF] Pitch", "Up", "Down", "Random"),
        bodyyaw = ui.new_slider("AA", "Anti-aimbot angles", "[\a878787ffBreaker\aFFFFFFFF] Body yaw", -180, 180, 0),	
    },
    localanimz = ui.new_checkbox("AA", "Anti-aimbot angles", "\a878787ffgucci.shop ⭒\aFFFFFFFF local animations"),
    animfucker = ui.new_multiselect('AA', 'Anti-aimbot angles', '\a878787ffgucci.shop ⭒\aFFFFFFFF animation breakers', 'Static legs in air', 'Zero pitch on land', 'Backward legs', "mj walk-air", 'abi walk'),
    knife_hotkey = ui.new_checkbox("AA", "Anti-aimbot angles", "\a878787ffgucci.shop ⭒\aFFFFFFFF avoid backstab"),
    knife_distance = ui.new_slider("AA", "Anti-aimbot angles", "\a878787ffgucci.shop ⭒\aFFFFFFFF avoid backstab radius",0,300,150,true,"u"),
}

cactu = 0

function stateupd()
    if globals.tickcount() % 4 < 2 and globals.chokedcommands() == 0 then
        cactu = cactu + 1
    end
end

 newaa = {
    yaw_type = ui.new_combobox("AA", "Anti-aimbot angles", "\a878787ffgucci.shop ⭒\aFFFFFFFF yaw", "static", "center", "jitter"),
    yaw = ui.new_slider("AA", "Anti-aimbot angles", " ", 0, 180, 0),
    yaw2 = ui.new_slider("AA", "Anti-aimbot angles", " ", -180, 180, 0),

    yawjitter1 = ui.new_slider("AA", "Anti-aimbot angles", "    ", -180, 180, 0),
    yawjitter2 = ui.new_slider("AA", "Anti-aimbot angles", "   ", -180, 180, 0),

    yawspeed = ui.new_slider("AA", "Anti-aimbot angles", "\a878787ffgucci.shop ⭒\aFFFFFFFF pace", 1, 4, 1, true, "", 1, {"Slower", "Normal","Faster", "Reductant"}),
    calc_yaw = ui.new_combobox("AA", "Anti-aimbot angles", "\a878787ffgucci.shop ⭒\aFFFFFFFF calculation", "randomize", "by pace", "tick", "invert", "valor", "triple"),
    safehead_e = ui.new_checkbox("AA", "Anti-aimbot angles", "\a878787ffgucci.shop ⭒\aFFFFFFFF safe head"),
    bodyyaw = ui.new_combobox("AA", "Anti-aimbot angles", "\a878787ffgucci.shop ⭒\aFFFFFFFF body yaw", "off", "static", "opposite", "jitter", "playa", "vanguard"),
    bodyyaw_v = ui.new_slider("AA", "Anti-aimbot angles", " ", -180, 180, 0),
}

function player_state()
    vx, vy = entity.get_prop(entity.get_local_player(), 'm_vecVelocity')
    player_standing = math.sqrt(vx ^ 2 + vy ^ 2) < 2
    player_jumping = bit.band(entity.get_prop(entity.get_local_player(), 'm_fFlags'), 1) == 0
    player_duck_peek_assist = ui.get(ref.fake_duck)
    player_crouching = entity.get_prop(entity.get_local_player(), "m_flDuckAmount") > 0.5 and not player_duck_peek_assist
    player_slow_motion = ui.get(ref.slowwalk[1]) and ui.get(ref.slowwalk[2])
    is_exploiting = ui.get(ref.dt[2]) or ui.get(ref.os[2])
    
    
    if player_duck_peek_assist then
        return 'fakeduck'
    elseif player_slow_motion and is_exploiting and not antibrute_active  then
        return 'slowmotion'
    elseif player_crouching and is_exploiting and not player_jumping and not antibrute_active  then
        return 'crouch'
    elseif player_jumping and not player_crouching and is_exploiting  and not antibrute_active then
        return 'jump'
    elseif player_jumping and player_crouching and is_exploiting and not antibrute_active  then
        return "duckjump"
    elseif player_standing and is_exploiting and not antibrute_active  then
        return 'stand'
    elseif not player_standing and is_exploiting and not antibrute_active  then
        return 'move'
    elseif not is_exploiting  and not antibrute_active then
        return "fakelag"
    end
    end

function xxx()
    yawtypeget = ui.get(newaa.yaw_type)
    calculation = ui.get(newaa.calc_yaw)
    vs = ui.get(menu.retard) == "\a878787ffanti-aim" and ui.get(menu.subtab_antiaim) == "main" and ui.get(menu.presets) == "Builder"
    ui.set_visible(newaa.yaw_type, vs and true or false)
    ui.set_visible(newaa.yaw, (vs and (yawtypeget == "center")) and true or false)
    ui.set_visible(newaa.yaw2, (vs and (yawtypeget == "static")) and true or false)

    ui.set_visible(newaa.yawjitter1, (vs and yawtypeget == "jitter") and true or false)
    ui.set_visible(newaa.yawjitter2, (vs and yawtypeget == "jitter") and true or false)

    ui.set_visible(newaa.yawspeed, (vs and yawtypeget == "center" and calculation == "by pace") and true or false)
    ui.set_visible(newaa.calc_yaw, (vs and (yawtypeget == "center" or yawtypeget == "jitter")) and true or false)
    ui.set_visible(newaa.bodyyaw, vs and true or false)
    ui.set_visible(newaa.bodyyaw_v, vs and true or false)
    ui.set_visible(newaa.safehead_e, vs and true or false)
end

function ctag_en()
    count = round(math.floor(math.abs(math.sin(globals.realtime()) *2) * 10))
    name = "gucci.lua"
    if ui.get(menu.ctagenable) then
        client.set_clan_tag(name:sub(1, count))
    end
end
yaw_increment_spin4 = 0
yaw_increment_spin5 = 0
function testaa()
    builderon = ui.get(menu.presets) == "Builder"
    getyaw = ui.get(newaa.yaw)
    getyaw2 = ui.get(newaa.yaw2)
    centeron = ui.get(newaa.yaw_type) == "center"
    staticyaw = ui.get(newaa.yaw_type) == "static"
    yawjitter = ui.get(newaa.yaw_type) == "jitter"
    byawx = ui.get(newaa.bodyyaw)
    byawx2 = ui.get(newaa.bodyyaw_v)

    calculation = ui.get(newaa.calc_yaw)

    -- speed confirmation

    speed = 0
    if ui.get(newaa.yawspeed) == 1 then
        speed = 2
    elseif ui.get(newaa.yawspeed) == 2 then
        speed = 5
    elseif ui.get(newaa.yawspeed) == 3 then
        speed = 8
    end
    yaw_increment_spin4 = yaw_increment_spin4 + 3 +speed;
    if yaw_increment_spin4 >= 1080 then
        yaw_increment_spin4 = 0
    end;    
    yaw_increment_spin5 = yaw_increment_spin5 + 19;
    if yaw_increment_spin4 >= 1080 then
        yaw_increment_spin5 = 0
    end;     

    value = 0
    if calculation == "randomize" then
        value = math.random(1,2)
    elseif calculation == "by pace" then
        value = spinix(raddx(yaw_increment_spin4), 1, 2) 
    elseif calculation == "tick" then
    value = manipulation_tick(1,2,1,2)
    elseif calculation == "break" then
    value = manipulation_break(1,2,10)
    elseif calculation == "invert" then
    value = manipulation_break(1,2,math.random(7,10))
    elseif calculation == "valor" then
    value = spinix(raddx(yaw_increment_spin5), 1, 2) 
    elseif calculation == "triple" then
    value = manipulation_tick(1,2,1,2)
    end

    ui.set(ref.jitter[1], "Off")
    ui.set(ref.yaw[1],"180")
    -- [[ Y  A  W ]]

    if builderon and centeron then
        if value == 1 then
            ui.set(ref.yaw[2],-getyaw)
        else 
            ui.set(ref.yaw[2],getyaw)
        end
    end
    value2 = 0
    if builderon and yawjitter then
        if not calculation == "triple" then
            if value == 1 then
                ui.set(ref.yaw[2], ui.get(newaa.yawjitter1))
            else
                ui.set(ref.yaw[2], ui.get(newaa.yawjitter2))
            end
        else
            if value == 1 then
                ui.set(ref.yaw[2], ui.get(newaa.yawjitter1))
            elseif value == 2 then
                ui.set(ref.yaw[2], ui.get(newaa.yawjitter2))
            end
            if math.random(1,2) == 1 then ui.set(ref.yaw[2], 0) end
        end
    end

    if builderon and staticyaw then
        ui.set(ref.yaw[2],getyaw2)
    end
    value2x = manipulation_break(1,2,10)
    value2x2 = manipulation_break(1,2,3)
    -- value playa
    playa_value = 0
    if value2x == 1 then
        playa_value = -byawx2
    else
        playa_value = byawx2
    end
    if builderon then
        if byawx == "playa" then
            ui.set(ref.byaw[1], "static")
            ui.set(ref.byaw[2], playa_value )
        elseif byawx == "vanguard" then
            ui.set(ref.byaw[1], value2x2 == 1 and "static" or "off")
            ui.set(ref.byaw[2], playa_value )
        elseif not byawx == "playa" or not byawx == "vanguard" then
            ui.set(ref.byaw[1], byawx)
            ui.set(ref.byaw[2], byawx2)
        end
    end
    condition = player_state() == 'jump' or player_state() == 'duckjump'
    if ui.get(newaa.safehead_e) == true then 
        if condition == true then
            ui.set(ref.yaw[2],0)
        end
    end

end


client.set_event_callback("paint", xxx)
client.set_event_callback("paint", testaa)
client.set_event_callback("paint", ctag_en)

-- glowmudle

rec = function(x, y, w, h, radius, color)
    radius = math.min(x/2, y/2, radius)
     r, g, b, a = unpack(color)
    renderer.rectangle(x, y + radius, w, h - radius*2, r, g, b, a)
    renderer.rectangle(x + radius, y, w - radius*2, radius, r, g, b, a)
    renderer.rectangle(x + radius, y + h - radius, w - radius*2, radius, r, g, b, a)
    renderer.circle(x + radius, y + radius, r, g, b, a, radius, 180, 0.25)
    renderer.circle(x - radius + w, y + radius, r, g, b, a, radius, 90, 0.25)
    renderer.circle(x - radius + w, y - radius + h, r, g, b, a, radius, 0, 0.25)
    renderer.circle(x + radius, y - radius + h, r, g, b, a, radius, -90, 0.25)
end

rec_outline = function(x, y, w, h, radius, thickness, color)
    radius = math.min(w/2, h/2, radius)
     r, g, b, a = unpack(color)
    if radius == 1 then
        renderer.rectangle(x, y, w, thickness, r, g, b, a)
        renderer.rectangle(x, y + h - thickness, w , thickness, r, g, b, a)
    else
        renderer.rectangle(x + radius, y, w - radius*2, thickness, r, g, b, a)
        renderer.rectangle(x + radius, y + h - thickness, w - radius*2, thickness, r, g, b, a)
        renderer.rectangle(x, y + radius, thickness, h - radius*2, r, g, b, a)
        renderer.rectangle(x + w - thickness, y + radius, thickness, h - radius*2, r, g, b, a)
        renderer.circle_outline(x + radius, y + radius, r, g, b, a, radius, 180, 0.25, thickness)
        renderer.circle_outline(x + radius, y + h - radius, r, g, b, a, radius, 90, 0.25, thickness)
        renderer.circle_outline(x + w - radius, y + radius, r, g, b, a, radius, -90, 0.25, thickness)
        renderer.circle_outline(x + w - radius, y + h - radius, r, g, b, a, radius, 0, 0.25, thickness)
    end
end

glow_module = function(x, y, w, h, width, rounding, accent, accent_inner)
    local thickness = 1
    local offset = 1
    local r, g, b, a = unpack(accent)
    if accent_inner then
        rec(x , y, w, h + 1, rounding, accent_inner)
        --renderer.blur(x , y, w, h)
        --m_render.rec_outline(x + width*thickness - width*thickness, y + width*thickness - width*thickness, w - width*thickness*2 + width*thickness*2, h - width*thickness*2 + width*thickness*2, color(r, g, b, 255), rounding, thickness)
    end
    for k = 0, width do
        if a * (k/width)^(1) > 5 then
            local accent = {r, g, b, a * (k/width)^(2)}
            rec_outline(x + (k - width - offset)*thickness, y + (k - width - offset) * thickness, w - (k - width - offset)*thickness*2, h + 1 - (k - width - offset)*thickness*2, rounding + thickness * (width - k + offset), thickness, accent)
        end
    end
end

math_clamp = function(val, min, max)
    return math.min(max, math.max(min, val))
end

 function get_velocity(player)
     x,y,z = entity.get_prop(player, "m_vecVelocity")
    if x == nil then return end
    return math.sqrt(x*x + y*y + z*z)
end

-- kz = 0

alpha = 0
fade_start_time = 0
hold_duration = 0.5 -- seconds to hold full alpha
fade_duration = 1.0 -- seconds to fade out
last_kill_time = -1

-- Called when a player dies
client.set_event_callback("player_death", function(event)
    local_player = entity.get_local_player()
   if not local_player then return end

    attacker = client.userid_to_entindex(event.attacker)
   if attacker == local_player then
       alpha = 1
       last_kill_time = globals.realtime()
   end
end)


function killtracker()
    if not ui.get(menu.killind) then return end
    time = globals.realtime()
    elapsed = time - last_kill_time
    x,y = client.screen_size()

    if last_kill_time >= 0 then
        if elapsed > hold_duration then
             fade_elapsed = elapsed - hold_duration*2
             fade_factor = math.max(1 - (fade_elapsed / fade_duration), 0)
            alpha = fade_factor
        end
    end

    r2,g2,b2,a2 = ui.get(menu.main_clr)

    getalpha = animations.anim_new('gotkillalpha', alpha > 0 and 1 or 0)
    getalpha2 = animations.anim_new('gotkillalpha2', alpha > 0.9 and 1 or 0)
    -- r,g,b,a = 29+(r2-29)*getalpha,29+(g2-29)*getalpha,29+(b2-29)*getalpha,255
    r,g,b,a = 29+(r2-29)*getalpha2,29+(g2-29)*getalpha2,29+(b2-29)*getalpha2,255*getalpha

    -- 1 kill\
    bl = 20*getalpha
    renderer.circle(x/2, y/3, 17,17,17, a, bl, 100, 100)
    renderer.circle_outline(x/2, y/3, r,g,b,a, bl, 100, 100, 2)

    -- 2 kills
    x2 = x/2-18
    y2 = y/3+18
    renderer.circle(x2, y2, 17,17,17, a, bl, 100, 100)
    renderer.circle_outline(x2, y2, r,g,b,a, bl, 100, 100, 2)

    -- 3 kills
    x2 = x/2+18
    y2 = y/3+18
    renderer.circle(x2, y2, 17,17,17, a, bl, 100, 100)
    renderer.circle_outline(x2, y2, r,g,b,a, bl, 100, 100, 2)

    -- 4 kills
    x2 = x/2
    y2 = y/3+36
    renderer.circle(x2, y2, 17,17,17, a, bl, 100, 100)
    renderer.circle_outline(x2, y2, r,g,b,a, bl, 100, 100, 2)

    x,y = client.screen_size()

    local svg = {
        40,
        40,
        '<svg version="1.1" xmlns="http://www.w3.org/2000/svg" width="50" height="40" viewBox="0 0 32 32"><title>Color-Fill-5-1</title><path fill="#fff" d="M10.048 5.325c-2.778 0.576-4.301 1.293-5.926 2.803-3.034 2.816-4.198 7.283-2.893 11.2 0.538 1.6 1.267 2.752 2.611 4.109 1.408 1.421 2.445 2.086 4.224 2.701 1.178 0.41 1.267 0.422 3.328 0.422 2.112 0 2.112 0 3.494-0.486 1.267-0.435 1.421-0.461 1.728-0.294 0.666 0.346 2.15 0.717 3.264 0.832 2.15 0.218 4.467-0.294 6.49-1.434 1.203-0.678 2.957-2.394 3.622-3.546 2.138-3.699 2.163-7.654 0.064-11.2-0.64-1.088-2.56-3.034-3.584-3.635-2.842-1.664-6.003-1.971-9.203-0.896l-1.126 0.384-1.126-0.384c-0.614-0.205-1.498-0.448-1.958-0.512-0.806-0.141-2.483-0.166-3.008-0.064zM13.222 7.565l0.73 0.154-0.742 0.781c-0.397 0.435-0.96 1.126-1.242 1.549-0.499 0.755-1.344 2.534-1.344 2.842 0 0.128 0.294 0.166 1.062 0.166h1.075l0.461-0.947c0.461-0.934 1.754-2.47 2.534-3.034l0.384-0.269 0.525 0.358c0.794 0.55 1.6 1.536 2.253 2.765l0.602 1.126h1.062c1.216 0 1.19 0.026 0.73-1.114-0.486-1.229-1.178-2.291-2.061-3.238-0.448-0.474-0.819-0.896-0.819-0.922 0-0.038 0.346-0.141 0.768-0.23 1.062-0.23 3.29-0.102 4.352 0.243 2.483 0.794 4.723 3.034 5.517 5.517 0.333 1.024 0.474 3.354 0.256 4.365-0.627 3.021-2.995 5.606-5.965 6.515-1.165 0.358-2.739 0.461-3.802 0.269-1.229-0.243-1.242-0.269-0.486-1.050 0.819-0.858 1.574-1.933 2.061-2.97 0.397-0.858 0.883-2.598 0.883-3.187v-0.358h-4.992v2.035l2.445 0.077-0.474 0.96c-0.563 1.126-2.368 3.072-2.854 3.072-0.461 0-2.176-1.818-2.739-2.893-0.256-0.512-0.474-0.986-0.474-1.062 0-0.090 0.41-0.141 1.216-0.141h1.216v-2.048h-2.56c-2.138 0-2.56 0.026-2.56 0.179 0 0.102 0.090 0.589 0.192 1.075 0.41 1.958 1.344 3.776 2.675 5.21 0.461 0.499 0.666 0.794 0.563 0.845-0.371 0.23-1.869 0.397-2.88 0.32-3.482-0.269-6.502-2.624-7.539-5.888-1.536-4.813 1.242-9.779 6.157-11.034 0.819-0.205 2.88-0.218 3.814-0.038z"></path></svg>',
    }
    local svg = renderer.load_svg(svg[3], 40 , 40 )
    renderer.texture(svg,x/2-20,y/3,40 ,40 ,r,g,b,a)
end

client.set_event_callback("paint", killtracker)

thanks = false
thanks2= false
 client_eye_position, client_trace_line, entity_get_local_player, entity_get_players, entity_hitbox_position, renderer_circle, renderer_world_to_screen = client.eye_position, client.trace_line, entity.get_local_player, entity.get_players, entity.hitbox_position, renderer.circle, renderer.world_to_screen

 function asasss()
	 local_player = entity_get_local_player()
	 eye_x, eye_y, eye_z = client_eye_position()

	-- get all alive, non-dormant enemy players
	 enemies = entity_get_players(true)

	for i=1, #enemies do
		 entindex = enemies[i]
         xas = 255

		-- get the world coordinates of the head hitbox of the enemy
		 head_x, head_y, head_z = entity_hitbox_position(entindex, 14)
         vad = 80
         head_x, head_y, head_z = head_x-(vad+20), head_y, head_z
         head_x2, head_y2, head_z2 = entity_hitbox_position(entindex, 0)
         head_x3, head_y3, head_z3 = entity_hitbox_position(entindex, 15)
         head_x3, head_y3, head_z3 = head_x3+(vad+20), head_y3, head_z3

		-- transform world coordinates to screen coordinates
        wx, wy = renderer_world_to_screen(head_x, head_y, head_z)
		 wx2, wy2 = renderer_world_to_screen(head_x3, head_y3, head_z3)
          x1, y1, x2, y2 = entity.get_bounding_box(entindex)
          name = entity.get_player_name(entindex)
          y_add = name == '' and -8 or 0
          if (x1 or y1 or x2 or y2) == nil or entity.is_alive(local_player) == false then
            x1, y1, x2, y2 = 1,1,1,1
            xas = 0
          end

         if entindex == nil or entity.is_alive(local_player) == false then
            thanks = false
            thanks2 = true
         end
		-- make sure to always check if the screen coordinates are valid. it's enough to only check wx
		if wx ~= nil then
			 r, g, b, a = 255, 255, 255, 100
             thanks = false
             thanks2=true


			-- ray trace from your eye position to the enemy head, ignoring our local player, to determine if it's visible
			 fraction, entindex_hit = client_trace_line(local_player, eye_x, eye_y, eye_z, head_x, head_y, head_z)
             fraction2, entindex_hit2 = client_trace_line(local_player, eye_x, eye_y, eye_z, head_x2, head_y2, head_z2)
             fraction3, entindex_hit3 = client_trace_line(local_player, eye_x, eye_y, eye_z, head_x3, head_y3, head_z3)

            if (entindex_hit == entindex or fraction == 1) or (entindex_hit2 == entindex or fraction2 == 1) or (entindex_hit3 == entindex or fraction3 == 1) then
				-- the trace either hit the enemy or hit nothing, meaning the head is visible, so we change the color
				r, g, b, a = 255, 16, 16, 255
                thanks = true
            else
                thanks = false
			end

            if client.visible(head_x, head_y, head_z) then
                thanks2=false
            else
                thanks2=true
            end
            

			-- draw circle with radius 4, so we offset the x and y by -2
		end
	end
end
client.set_event_callback("paint", asasss)

client.set_event_callback("player_death", function()
    thanks = false
    pl_kills = 0
end)

-- local local_player = entity_get_local_player()
-- local eye_x, eye_y, eye_z = client_eye_position()

-- -- get all alive, non-dormant enemy players
-- local enemies = entity_get_players(true)

-- for i=1, #enemies do
--     local entindex = enemies[i]

--     -- get the world coordinates of the head hitbox of the enemy
--     local head_x, head_y, head_z = entity_hitbox_position(entindex, 0)

--     -- transform world coordinates to screen coordinates
--     local wx, wy = renderer_world_to_screen(head_x, head_y, head_z)

--     -- make sure to always check if the screen coordinates are valid. it's enough to only check wx
--     if wx ~= nil then
--         local r, g, b, a = 255, 255, 255, 100

--         -- ray trace from your eye position to the enemy head, ignoring our local player, to determine if it's visible
--         local fraction, entindex_hit = client_trace_line(local_player, eye_x, eye_y, eye_z, head_x, head_y, head_z)

--         if entindex_hit == entindex or fraction == 1 then
--             -- the trace either hit the enemy or hit nothing, meaning the head is visible, so we change the color
--             r, g, b, a = 255, 16, 16, 255
--         end

--         -- draw circle with radius 4, so we offset the x and y by -2
--         renderer_circle(wx-2, wy-2, r, g, b, a, 4, 0, 1)
--     end
-- end



local render = {}
render.notifications = {}
render.notifications.table_text = {}
render.notifications.c_var = {
    screen = {client.screen_size()},

}
function render:lerp(start, vend, time)
    return start + (vend - start) * time
end
local solus_render = (function()
    local solus_m = {};
    local RoundedRect = function(x, y, w, h, radius, r, g, b, a)
        renderer.rectangle(x + radius, y, w - radius * 2, radius, r, g, b, a)
        renderer.rectangle(x, y + radius, radius, h - radius * 2, r, g, b, a)
        renderer.rectangle(x + radius, y + h - radius, w - radius * 2, radius,
                        r, g, b, a)
        renderer.rectangle(x + w - radius, y + radius, radius, h - radius * 2,
                        r, g, b, a)
        renderer.rectangle(x + radius, y + radius, w - radius * 2,
                        h - radius * 2, r, g, b, a)
        renderer.circle(x + radius, y + radius, r, g, b, a, radius, 180, 0.25)
        renderer.circle(x + w - radius, y + radius, r, g, b, a, radius, 90, 0.25)
        renderer.circle(x + radius, y + h - radius, r, g, b, a, radius, 270,
                        0.25)
        renderer.circle(x + w - radius, y + h - radius, r, g, b, a, radius, 0,
                        0.25)
    end;
    local rounding = 4;
    local rad = rounding + 2;
    local n = 45;
    local o = 20;
    local OutlineGlow = function(x, y, w, h, radius, r, g, b, a)
        renderer.rectangle(x + 2, y + radius + rad, 1, h - rad * 2 - radius * 2,
                        r, g, b, a)
        renderer.rectangle(x + w - 3, y + radius + rad, 1,
                        h - rad * 2 - radius * 2, r, g, b, a)
        renderer.rectangle(x + radius + rad, y + 2, w - rad * 2 - radius * 2, 1,
                        r, g, b, a)
        renderer.rectangle(x + radius + rad, y + h - 3,
                        w - rad * 2 - radius * 2, 1, r, g, b, a)
        renderer.circle_outline(x + radius + rad, y + radius + rad, r, g, b, a,
                                radius + rounding, 180, 0.25, 1)
        renderer.circle_outline(x + w - radius - rad, y + radius + rad, r, g, b,
                                a, radius + rounding, 270, 0.25, 1)
        renderer.circle_outline(x + radius + rad, y + h - radius - rad, r, g, b,
                                a, radius + rounding, 90, 0.25, 1)
        renderer.circle_outline(x + w - radius - rad, y + h - radius - rad, r,
                                g, b, a, radius + rounding, 0, 0.25, 1)
    end;
    local FadedRoundedRect = function(x, y, w, h, radius, r, g, b, a, glow)
        local n = a / 255 * n;
        renderer.rectangle(x + radius, y, w - radius * 2, 1, r, g, b, a)
        renderer.circle_outline(x + radius, y + radius, r, g, b, a, radius, 180,
                                0.25, 1)
        renderer.circle_outline(x + w - radius, y + radius, r, g, b, a, radius,
                                270, 0.25, 1)
        renderer.gradient(x, y + radius, 1, h - radius * 2, r, g, b, a, r, g, b,
                        n, false)
        renderer.gradient(x + w - 1, y + radius, 1, h - radius * 2, r, g, b, a,
                        r, g, b, n, false)
        renderer.circle_outline(x + radius, y + h - radius, r, g, b, n, radius,
                                90, 0.25, 1)
        renderer.circle_outline(x + w - radius, y + h - radius, r, g, b, n,
                                radius, 0, 0.25, 1)
        renderer.rectangle(x + radius, y + h - 1, w - radius * 2, 1, r, g, b, n)
            for radius = 4, glow do
                local radius = radius / 2;
                OutlineGlow(x - radius, y - radius, w + radius * 2,
                            h + radius * 2, radius, r, g, b, glow - radius * 2)
            end
        
    end;
    local HorizontalFadedRoundedRect = function(x, y, w, h, radius, r, g, b, a,
                                                glow, r1, g1, b1)
        local n = a / 255 * n;
        renderer.rectangle(x, y + radius, 1, h - radius * 2, r, g, b, a)
        renderer.circle_outline(x + radius, y + radius, r, g, b, a, radius, 180,
                                0.25, 1)
        renderer.circle_outline(x + radius, y + h - radius, r, g, b, a, radius,
                                90, 0.25, 1)
        renderer.gradient(x + radius, y, w / 3.5 - radius * 2, 1, r, g, b, a, 0,
                        0, 0, n / 0, true)
        renderer.gradient(x + radius, y + h - 1, w / 3.5 - radius * 2, 1, r, g,
                        b, a, 0, 0, 0, n / 0, true)
        renderer.rectangle(x + radius, y + h - 1, w - radius * 2, 1, r1, g1, b1,
                        n)
        renderer.rectangle(x + radius, y, w - radius * 2, 1, r1, g1, b1, n)
        renderer.circle_outline(x + w - radius, y + radius, r1, g1, b1, n,
                                radius, -90, 0.25, 1)
        renderer.circle_outline(x + w - radius, y + h - radius, r1, g1, b1, n,
                                radius, 0, 0.25, 1)
        renderer.rectangle(x + w - 1, y + radius, 1, h - radius * 2, r1, g1, b1,
                        n)
            for radius = 4, glow do
                local radius = radius / 2;
                OutlineGlow(x - radius, y - radius, w + radius * 2,
                            h + radius * 2, radius, r1, g1, b1,
                            glow - radius * 2)
            end
        
    end;
    local FadedRoundedGlow = function(x, y, w, h, radius, r, g, b, a, glow, r1,
                                    g1, b1)
        local n = a / 255 * n;
        renderer.rectangle(x + radius, y, w - radius * 2, 1, r, g, b, n)
        renderer.circle_outline(x + radius, y + radius, r, g, b, n, radius, 180,
                                0.25, 1)
        renderer.circle_outline(x + w - radius, y + radius, r, g, b, n, radius,
                                270, 0.25, 1)
        renderer.rectangle(x, y + radius, 1, h - radius * 2, r, g, b, n)
        renderer.rectangle(x + w - 1, y + radius, 1, h - radius * 2, r, g, b, n)
        renderer.circle_outline(x + radius, y + h - radius, r, g, b, n, radius,
                                90, 0.25, 1)
        renderer.circle_outline(x + w - radius, y + h - radius, r, g, b, n,
                                radius, 0, 0.25, 1)
        renderer.rectangle(x + radius, y + h - 1, w - radius * 2, 1, r, g, b, n)
        if true then
            for radius = 4, glow do
                local radius = radius / 2;
                OutlineGlow(x - radius, y - radius, w + radius * 2,
                            h + radius * 2, radius, r1, g1, b1,
                            glow - radius * 2)
            end
        end
    end;
    solus_m.linear_interpolation = function(start, _end, time)
        return (_end - start) * time + start
    end
    solus_m.clamp = function(value, minimum, maximum)
        if minimum > maximum then
            return math.min(math.max(value, maximum), minimum)
        else
            return math.min(math.max(value, minimum), maximum)
        end
    end
    solus_m.lerp = function(start, _end, time)
        time = time or 0.005;
        time = solus_m.clamp(globals.frametime() * time * 175.0, 0.01, 1.0)
        local a = solus_m.linear_interpolation(start, _end, time)
        if _end == 0.0 and a < 0.01 and a > -0.01 then
            a = 0.0
        elseif _end == 1.0 and a < 1.01 and a > 0.99 then
            a = 1.0
        end
        return a
    end
    solus_m.outlined_glow = function(x, y, w, h, radius, r, g, b, a,glow)

        for radius = 4, glow do
            local radius = radius / 2;
            OutlineGlow(x - radius, y - radius, w + radius * 2,
                        h + radius * 2, radius, r, g, b,
                        glow - radius * 2)
        end
    end

    solus_m.container = function(x, y, w, h, r, g, b, a, alpha, fn)
        if a > 0 then
            renderer.blur(x, y, w, h)
        end

        local a2 = a-50
        if a2 < 0 then
            a2 = 0
        end
        rag,gab,bag = 8,58,33
        rag,gab,bag = r,g,b
        RoundedRect(x -2, y-2, w +4, h +4, rounding, rag,gab,bag, a2)
        RoundedRect(x -1, y-1, w +2, h +2, rounding, 161,28,29, a2)
        RoundedRect(x , y, w, h, rounding, rag,gab,bag, a2)
        RoundedRect(x+2, y+2, w-4, h-4, rounding, 17,17,17, a)
        if not fn then return end
        fn(x + rounding, y + rounding, w - rounding * 2, h - rounding * 2.0)
    end;
    solus_m.container2 = function(x, y, w, h, rounding, r, g, b, a)
        RoundedRect(x, y, w, h, rounding, r, g, b, a)
    end;
    solus_m.container3 = function(x, y, w, h, r, g, b, a, alpha, fn)

        local a2 = a-50
        if a2 < 0 then
            a2 = 0
        end
        ra,ga,ba,aa = ui.get(menu.main_clr)
        RoundedRect(x, y, w, h, r, g,b,a, alpha)
        FadedRoundedGlow(x,y,w,h, r,g,b,a, alpha, 3, r,g,b)
        
        if not fn then return end
        fn(x + rounding, y + rounding, w - rounding * 2, h - rounding * 2.0)
    end;
    solus_m.container4 = function(x, y, w, h, r, g, b, a, alpha, fn)
        if a > 0 then
            renderer.blur(x, y, w, h)
        end

        local a2 = a-50
        if a2 < 0 then
            a2 = 0
        end
        ra,ga,ba,aa = ui.get(menu.main_clr)
        RoundedRect(x, y, w, h, r, g,b,a, alpha)
        FadedRoundedGlow(x,y,w,h, r,g,b,a, alpha, 3, r,g,b)
        
        if not fn then return end
        fn(x + rounding, y + rounding, w - rounding * 2, h - rounding * 2.0)
    end;
    solus_m.container5 = function(x, y, w, h, r, g, b, a, alpha, fn)

        local a2 = a-50
        if a2 < 0 then
            a2 = 0
        end
        alpha = a

        renderer.rectangle(x,y,w,h-1, 29,29,29,alpha)
        renderer.gradient(x+1,y+1,w-2,h-1, 17,17,17,alpha,8,8,8,alpha, false)
        renderer.gradient(x,y+h-1,w/3,1, 29,29,29,alpha,8,8,8,alpha, true)
        renderer.gradient(x+(w/3)*2,y+h-1,w/3,1, 8,8,8,alpha,29,29,29,alpha, true)
        x=x-4
        y=y-1
        w=w+8
        h=h+2
        
        -- renderer.rectangle(x,y,w,h-1, 29,29,29,a)
        -- renderer.gradient(x+1,y+1,w-2,h-1, 17,17,17,a,8,8,8,a, false)
        -- renderer.gradient(x,y+h-1,w/3,1, 29,29,29,a,8,8,8,a, true)
        -- renderer.gradient(x+(w/3)*2,y+h-1,w/3,1, 8,8,8,a,29,29,29,a, true)




        -- local svg = {
        --     20,
        --     20,
        --     '<svg version="1.1" xmlns="http://www.w3.org/2000/svg" width="50" height="40" viewBox="0 0 32 32"><title>Color-Fill-5-1</title><path fill="#fff" d="M10.048 5.325c-2.778 0.576-4.301 1.293-5.926 2.803-3.034 2.816-4.198 7.283-2.893 11.2 0.538 1.6 1.267 2.752 2.611 4.109 1.408 1.421 2.445 2.086 4.224 2.701 1.178 0.41 1.267 0.422 3.328 0.422 2.112 0 2.112 0 3.494-0.486 1.267-0.435 1.421-0.461 1.728-0.294 0.666 0.346 2.15 0.717 3.264 0.832 2.15 0.218 4.467-0.294 6.49-1.434 1.203-0.678 2.957-2.394 3.622-3.546 2.138-3.699 2.163-7.654 0.064-11.2-0.64-1.088-2.56-3.034-3.584-3.635-2.842-1.664-6.003-1.971-9.203-0.896l-1.126 0.384-1.126-0.384c-0.614-0.205-1.498-0.448-1.958-0.512-0.806-0.141-2.483-0.166-3.008-0.064zM13.222 7.565l0.73 0.154-0.742 0.781c-0.397 0.435-0.96 1.126-1.242 1.549-0.499 0.755-1.344 2.534-1.344 2.842 0 0.128 0.294 0.166 1.062 0.166h1.075l0.461-0.947c0.461-0.934 1.754-2.47 2.534-3.034l0.384-0.269 0.525 0.358c0.794 0.55 1.6 1.536 2.253 2.765l0.602 1.126h1.062c1.216 0 1.19 0.026 0.73-1.114-0.486-1.229-1.178-2.291-2.061-3.238-0.448-0.474-0.819-0.896-0.819-0.922 0-0.038 0.346-0.141 0.768-0.23 1.062-0.23 3.29-0.102 4.352 0.243 2.483 0.794 4.723 3.034 5.517 5.517 0.333 1.024 0.474 3.354 0.256 4.365-0.627 3.021-2.995 5.606-5.965 6.515-1.165 0.358-2.739 0.461-3.802 0.269-1.229-0.243-1.242-0.269-0.486-1.050 0.819-0.858 1.574-1.933 2.061-2.97 0.397-0.858 0.883-2.598 0.883-3.187v-0.358h-4.992v2.035l2.445 0.077-0.474 0.96c-0.563 1.126-2.368 3.072-2.854 3.072-0.461 0-2.176-1.818-2.739-2.893-0.256-0.512-0.474-0.986-0.474-1.062 0-0.090 0.41-0.141 1.216-0.141h1.216v-2.048h-2.56c-2.138 0-2.56 0.026-2.56 0.179 0 0.102 0.090 0.589 0.192 1.075 0.41 1.958 1.344 3.776 2.675 5.21 0.461 0.499 0.666 0.794 0.563 0.845-0.371 0.23-1.869 0.397-2.88 0.32-3.482-0.269-6.502-2.624-7.539-5.888-1.536-4.813 1.242-9.779 6.157-11.034 0.819-0.205 2.88-0.218 3.814-0.038z"></path></svg>',
        -- }
        -- local svg2 = {
        --     17,
        --     17,
        --     '<svg version="1.1" xmlns="http://www.w3.org/2000/svg" width="50" height="40" viewBox="0 0 32 32"><title>Color-Fill-5-1</title><path fill="#fff" d="M10.048 5.325c-2.778 0.576-4.301 1.293-5.926 2.803-3.034 2.816-4.198 7.283-2.893 11.2 0.538 1.6 1.267 2.752 2.611 4.109 1.408 1.421 2.445 2.086 4.224 2.701 1.178 0.41 1.267 0.422 3.328 0.422 2.112 0 2.112 0 3.494-0.486 1.267-0.435 1.421-0.461 1.728-0.294 0.666 0.346 2.15 0.717 3.264 0.832 2.15 0.218 4.467-0.294 6.49-1.434 1.203-0.678 2.957-2.394 3.622-3.546 2.138-3.699 2.163-7.654 0.064-11.2-0.64-1.088-2.56-3.034-3.584-3.635-2.842-1.664-6.003-1.971-9.203-0.896l-1.126 0.384-1.126-0.384c-0.614-0.205-1.498-0.448-1.958-0.512-0.806-0.141-2.483-0.166-3.008-0.064zM13.222 7.565l0.73 0.154-0.742 0.781c-0.397 0.435-0.96 1.126-1.242 1.549-0.499 0.755-1.344 2.534-1.344 2.842 0 0.128 0.294 0.166 1.062 0.166h1.075l0.461-0.947c0.461-0.934 1.754-2.47 2.534-3.034l0.384-0.269 0.525 0.358c0.794 0.55 1.6 1.536 2.253 2.765l0.602 1.126h1.062c1.216 0 1.19 0.026 0.73-1.114-0.486-1.229-1.178-2.291-2.061-3.238-0.448-0.474-0.819-0.896-0.819-0.922 0-0.038 0.346-0.141 0.768-0.23 1.062-0.23 3.29-0.102 4.352 0.243 2.483 0.794 4.723 3.034 5.517 5.517 0.333 1.024 0.474 3.354 0.256 4.365-0.627 3.021-2.995 5.606-5.965 6.515-1.165 0.358-2.739 0.461-3.802 0.269-1.229-0.243-1.242-0.269-0.486-1.050 0.819-0.858 1.574-1.933 2.061-2.97 0.397-0.858 0.883-2.598 0.883-3.187v-0.358h-4.992v2.035l2.445 0.077-0.474 0.96c-0.563 1.126-2.368 3.072-2.854 3.072-0.461 0-2.176-1.818-2.739-2.893-0.256-0.512-0.474-0.986-0.474-1.062 0-0.090 0.41-0.141 1.216-0.141h1.216v-2.048h-2.56c-2.138 0-2.56 0.026-2.56 0.179 0 0.102 0.090 0.589 0.192 1.075 0.41 1.958 1.344 3.776 2.675 5.21 0.461 0.499 0.666 0.794 0.563 0.845-0.371 0.23-1.869 0.397-2.88 0.32-3.482-0.269-6.502-2.624-7.539-5.888-1.536-4.813 1.242-9.779 6.157-11.034 0.819-0.205 2.88-0.218 3.814-0.038z"></path></svg>',
        -- }
        -- local svg = renderer.load_svg(svg[3], 20 , 20 )
        -- local svg2 = renderer.load_svg(svg2[3], 16 , 16 )
        -- renderer.texture(svg,x+w/2-10,y-15,20 ,20 ,17,17,17,125*alp)
        -- renderer.texture(svg2,x+w/2-8,y-13,16 ,16 ,247,165,55,a)

        
        local c = {10, 60, 40, 40, 40, 60, 20}
        -- for i = 0,6,1 do
        --     renderer.gradient(x- i-4, y+ i, 3, h- (i * 2), r,g,b,a-155, c[i + 1], c[i + 1], c[i + 1], r,g,b,a-155, false)
        -- end
        if not fn then return end
        fn(x + rounding, y + rounding, w - rounding * 2, h - rounding * 2.0)
    end;
    solus_m.horizontal_container = function(x, y, w, h, r, g, b, a, alpha, r1,
                                            g1, b1, fn)
        if alpha * 255 > 0 then renderer.blur(x, y, w, h) end
        RoundedRect(x, y, w, h, rounding, 17, 17, 17, a)
        HorizontalFadedRoundedRect(x, y, w, h, rounding, r, g, b, alpha * 255,
                                alpha * o, r1, g1, b1)
        if not fn then return end
        fn(x + rounding, y + rounding, w - rounding * 2, h - rounding * 2.0)
    end;
    solus_m.container_glow = function(x, y, w, h, r, g, b, a, alpha, r1, g1, b1,
                                    fn)
        if alpha * 255 > 0 then renderer.blur(x, y, w, h) end
        RoundedRect(x, y, w, h, rounding, 17, 17, 17, a)
        FadedRoundedGlow(x, y, w, h, rounding, r, g, b, alpha * 255, alpha * o,
                        r1, g1, b1)
        if not fn then return end
        fn(x + rounding, y + rounding, w - rounding * 2, h - rounding * 2.0)
    end;
    solus_m.measure_multitext = function(flags, _table)
        local a = 0;
        for b, c in pairs(_table) do
            c.flags = c.flags or ''
            a = a + renderer.measure_text(c.flags, c.text)
        end
        return a
    end
    solus_m.multitext = function(x, y, _table)
        for a, b in pairs(_table) do
            b.flags = b.flags or ''
            b.limit = b.limit or 0;
            b.color = b.color or {255, 255, 255, 255}
            b.color[4] = b.color[4] or 255;
            renderer.text(x, y, b.color[1], b.color[2], b.color[3], b.color[4],
                        b.flags, b.limit, b.text)
            x = x + renderer.measure_text(b.flags, b.text)
        end
    end
    return solus_m
end)()

function round(x)
    return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5)
end

raddx = function(L137)
    while L137 > 180 do
        L137 = L137 - 360
    end;
    while L137 < -180 do
        L137 = L137 + 360
    end;
    return L137
end

function make_positive(number)
    return math.abs(number)
end

function best_solus(x,y,w,h,alpha)
	renderer.rectangle(x,y,w,h-1, 29,29,29,alpha)
	renderer.gradient(x+1,y+1,w-2,h-1, 17,17,17,alpha,8,8,8,alpha, false)
	renderer.gradient(x,y+h-1,w/3,1, 29,29,29,alpha,8,8,8,alpha, true)
	renderer.gradient(x+(w/3)*2,y+h-1,w/3,1, 8,8,8,alpha,29,29,29,alpha, true)
end

function info_watermark()
    x,y = client.screen_size()
    r,g,b,a = ui.get(menu.main_clr)
    lr,lg,lb,la = 93,89,105,255



    player = entity.get_local_player()
    local avatar = images.get_steam_avatar(entity.get_steam64(player))
    
    playername = ""..entity.get_player_name(player)..""
    
    local mx, my = renderer_measure_text("b", playername) -- 70
    addxname = 0
    if mx >= 76 then
        addxname = make_positive(70-mx)
    else
        addxname = 0
    end

    
    alpha2 = 1
    -- new watermarkso


    initial_position_x = 12
    initial_position_y2 = y/2-3
    initial_position_y = y/2
    w = 50
    h = 25
    curtime = globals.curtime()
    string1 = "gucci"
    ver_alpha = animations.anim_new('xxxxxxxx_alpha', ui.get(menu.watermarkenable) and 1 or 0)
    local textwidth, texty = renderer_measure_text("b", text_fade_animation(1.4, r,g,b,255, string1).." \a"..RGBAtoHEX(25,25,25,255*ver_alpha).."| ad \a"..RGBAtoHEX(70,70,70,255*ver_alpha)..""..playername.." · "..version.." · "..getTime()) -- 70
    w = textwidth+7
    local textwidth2, texty2 = renderer_measure_text("b", text_fade_animation(1.4, r,g,b,255, string1).." \a"..RGBAtoHEX(25,25,25,255*ver_alpha).."| ")
    
    best_solus((x-w)-10, 10, w, h, 255*ver_alpha)
    renderer.text((x-w)-5, 15, 255,255,255,255*ver_alpha, 0, "b", text_fade_animation(1.4, r,g,b,255*ver_alpha, string1).." \a"..RGBAtoHEX(25,25,25,255*ver_alpha).."| \a"..RGBAtoHEX(0,0,0,0).."ad \a"..RGBAtoHEX(70,70,70,255*ver_alpha)..""..playername.." · "..version.." · "..getTime())
    avatar:draw((x-w)-5+textwidth2, 15 ,12 ,12, 255, 255, 255, 255*ver_alpha, 0)
end

client.set_event_callback("paint", info_watermark)

function minimumdmgindc()
    local x, y = client_screen_size()
    
    local r,g,b,a = ui.get(menu.dmgindcol)
    local md = ui.reference("rage", "aimbot", "minimum damage")
    local mdo = {ui.reference("rage", "aimbot", "minimum damage override")}
    local me = entity.get_local_player()

    if not entity.is_alive(me) then return end
    local user = entity.get_player_name(me)

    local nnn = animations.anim_new('xxx', ui.get(mdo[2]) and ui.get(mdo[3]) or ui.get(md))
    local nnn = round(nnn)

    local mx, my = renderer_measure_text("b", "- "..nnn.." -")

    if ui.get(mdo[2]) and ui.get(menu.dmgind) then
        renderer_text(x/2-mx/2, y/2.4, r, g, b, 255, "b", 0, "\a"..RGBAtoHEX(255,255,255,255).."- \a"..RGBAtoHEX(r,g,b,255)..""..nnn.."\a"..RGBAtoHEX(255,255,255,255).." -")
    end
end

function dtmanager()
    local x, y = client_screen_size()
    local mx, my = renderer_measure_text("b", "gucci.shop ~ defensive")
    local r,g,b,a = ui.get(menu.main_clr)
     me = entity.get_local_player()

    local cacatu = ui.get(menu.breaker_switch)
    local y2 = y+15
    local x2 = x/2
    if not entity.is_alive(me) then return end
     user = entity.get_player_name(me)

    

    local alpha2 = animations.anim_new('sadasdsfxxsa', (ui.get(menu.defensiveindicator) and thanks and cacatu or ui.is_menu_open() and ui.get(menu.defensiveindicator)) and 1 or 0)
    local wwx = animations.anim_new('sadasdsfsdasxxsa', (ui.get(menu.defensiveindicator) and thanks and cacatu or ui.is_menu_open() and ui.get(menu.defensiveindicator)) and 165 or 0)
    local mxx = animations.anim_new('sadasdsfxxsxa', (ui.get(menu.defensiveindicator) and thanks and cacatu or ui.is_menu_open() and ui.get(menu.defensiveindicator)) and mx or 0)
    local nnn = animations.anim_new('asxsadadxsaz', (ui.get(menu.defensiveindicator) and thanks and cacatu or ui.is_menu_open() and ui.get(menu.defensiveindicator)) and 100 or 0)

    local myself  = entity.get_local_player()

    local next_attack = entity.get_prop(myself, "m_flNextAttack") or 0
    local next_primary_attack = entity.get_prop(entity.get_player_weapon(myself), "m_flNextPrimaryAttack") or 0
    local dt_toggled = ref.dt[1] and ref.dt[2]
    local dt_active = not(math.max(next_primary_attack, next_attack) > globals.curtime())

    ai = false
    ina = false
    activedt = 0
    inactivedt = 0

    if dt_toggled and dt_active then
        activedt = math_clamp(activedt + globals.frametime()/0.175, 0, 2)
        ai = true
            else
        activedt = math_clamp(activedt - globals.frametime()/0.175, 0, 2)
        ai = false
    end

    if dt_toggled and not dt_active then
        inactivedt = math_clamp(inactivedt + globals.frametime()/0.15, 0, 2)
        ina = true
            else
        inactivedt = math_clamp(inactivedt - globals.frametime()/0.15, 0, 2)
        ina = false
    end

    local aszz2 = animations.anim_new('zsadsax2', ai and 1 or 0)
    local aszz = animations.anim_new('zsadsax', ai and 5 or 0)
    local azssz = animations.anim_new('sxxsxad', ina and 7 or 0)
    local azssz2 = animations.anim_new('sxxsxad2', ina and 1 or 0)

    local aA = {
        {r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * globals.curtime()/4 + 80 / 30))*alpha2},
        {r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * globals.curtime()/4 + 75 / 30))*alpha2},
        {r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * globals.curtime()/4 + 70 / 30))*alpha2},
        {r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * globals.curtime()/4 + 65 / 30))*alpha2},
        {r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * globals.curtime()/4 + 60 / 30))*alpha2},
        {r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * globals.curtime()/4 + 55 / 30))*alpha2},
        {r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * globals.curtime()/4 + 50 / 30))*alpha2},
        {r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * globals.curtime()/4 + 45 / 30))*alpha2},
        {r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * globals.curtime()/4 + 40 / 30))*alpha2},
        {r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * globals.curtime()/4 + 35 / 30))*alpha2},
        {r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * globals.curtime()/4 + 30 / 30))*alpha2},
        {r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * globals.curtime()/4 + 25 / 30))*alpha2},
        {r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * globals.curtime()/4 + 20 / 30))*alpha2},
        {r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * globals.curtime()/4 + 15 / 30))*alpha2},
        {r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * globals.curtime()/4 + 10 / 30))*alpha2},
        {r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * globals.curtime()/4 + 5 / 30))*alpha2},
        {r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * globals.curtime()/4 + 0 / 30))*alpha2}
    }

    
     redo = math.floor(math.abs(math.sin(globals.realtime()) * 4) * 125)
    if redo > 125*4 then
        redo = 125*4
    end

    -- renderer.rectangle(x2-51, y2/3+44, 102, 4, 0,0,0, 255*alpha2)
    -- renderer.rectangle(x2-50, y2/3+45, thanks and math.abs(1 * math.cos(2 * math.pi * (globals.curtime() /2)*4 )) * 100 or 100, 2, 255,255,255,255*alpha2)

    oo = "\a"..RGBAtoHEX(255,255,255,155*alpha2).."defensive dt "


    x,y = client.screen_size()


    sx = "COMP"
    sx2 = "UNSAFE"


    renderer_text(x/2-mx/2, y2/3+29, 255, 255, 255, 255*alpha2, "b", 0, string.format("gucci.shop ~ "..text_fade_animation(11, r,g,b,255*alpha2, "defensive")))
    -- renderer.circle_outline(x/2+mx/2+8, y2/3+36, r,g,b,255*alpha2, 4, math.random(0,180), 0.5, 2)
end

function goanadupabani()
     x, y = client_screen_size()
    is_enabled = ui.get(menu.cdzenable)
    if not is_enabled then return end
    vafle = ui.get(menu.cdz_custom)
    if countLetters(vafle) == 0 then
vafle = "sunt smecheru vostru"
    end
     mx, my = renderer_measure_text("s", vafle)
    renderer_text(x/2+2,y/2-my, 255,255,255,255, 's', 0, vafle)
end

client.set_event_callback("paint", dtmanager)
client.set_event_callback("paint", goanadupabani)
client.set_event_callback("paint", minimumdmgindc)

yaw_increment_spin5 = 0
-- changenotif
 function noti()
     y = render.notifications.c_var.screen[2] - 100

    
    for i, info in ipairs(render.notifications.table_text) do
        if i > 5 then
            table.remove(render.notifications.table_text,i)
        end
        if info.text ~= nil and info ~= "" then
             text_size = {renderer.measure_text(nil,info.text)}
             r,g,b,a = ui.get(menu.main_clr)
            if info.timer + 3.8 < globals.realtime() then
    
                info.box_left = render:lerp(info.box_left,text_size[1],globals.frametime() * 1)
                info.box_right = render:lerp(info.box_right,text_size[1],globals.frametime() * 1)
                info.box_left_1 = render:lerp(info.box_left_1,0,globals.frametime() * 1)
                info.box_right_1 = render:lerp(info.box_right_1,0 ,globals.frametime() * 1)
                info.smooth_y = render:lerp(info.smooth_y,render.notifications.c_var.screen[2] + 100,globals.frametime() * 2)
                info.alpha = render:lerp(info.alpha,0,globals.frametime() * 4)
                info.alpha2 = render:lerp(info.alpha2,0,globals.frametime() * 4)
                info.alpha3 = render:lerp(info.alpha3,0,globals.frametime() * 4)

            else
                info.alpha = render:lerp(info.alpha,a,globals.frametime() * 4) 
                info.alpha2 = render:lerp(info.alpha2,1,globals.frametime() * 4)
                info.alpha3 = render:lerp(info.alpha3,255,globals.frametime() * 4)

                info.smooth_y = render:lerp(info.smooth_y,y,globals.frametime() * 5)
            
                info.box_left = render:lerp(info.box_left,text_size[1] - text_size[1] /2 -2,globals.frametime() * 1)
                info.box_right = render:lerp(info.box_right,text_size[1]  - text_size[1] /2 +4,globals.frametime() * 1)
                info.box_left_1 = render:lerp(info.box_left_1,text_size[1] +13,globals.frametime() * 2)
                info.box_right_1 = render:lerp(info.box_right_1,text_size[1] +14 ,globals.frametime() * 2)
            end

            -- local me = entity.get_local_player()


            -- local steam_id = entity.get_steam64(me)
            -- local avatar = images.get_steam_avatar(steam_id)

            -- if info.image ~= nil then
            --     info.image = avatar
            -- end

             add_y = math.floor(info.smooth_y)
             alpha = info.alpha
             alpha2 = info.alpha2
             alpha3 = info.alpha3

             left_box = math.floor(info.box_left)
             right_box = math.floor(info.box_right)
             left_box_1 = math.floor(info.box_left_1)
             right_box_1 = math.floor(info.box_right_1)

            if info.type == nil then
                info.type = false 
            end

            if info.red == nil then
                info.red = r
            end
            if info.green == nil then
                info.green = g
            end
            if info.blue == nil then
                info.blue = b
            end

            r,g,b = info.red,info.green,info.blue

            if info.type == false then
                solus_render.container5(render.notifications.c_var.screen[1] / 2 - text_size[1] / 2 - 4 + 5,add_y - 21,text_size[1] +8 + 4 - 7 + 4 ,text_size[2] + 7 ,r,g,b,alpha,alpha2 )

                -- local svg = {
                --     32,
                --     32,
                --     '<svg version="1.1" xmlns="http://www.w3.org/2000/svg" width="50" height="40" viewBox="0 0 32 32"><title>Color-Fill-5-1</title><path fill="#fff" d="M10.048 5.325c-2.778 0.576-4.301 1.293-5.926 2.803-3.034 2.816-4.198 7.283-2.893 11.2 0.538 1.6 1.267 2.752 2.611 4.109 1.408 1.421 2.445 2.086 4.224 2.701 1.178 0.41 1.267 0.422 3.328 0.422 2.112 0 2.112 0 3.494-0.486 1.267-0.435 1.421-0.461 1.728-0.294 0.666 0.346 2.15 0.717 3.264 0.832 2.15 0.218 4.467-0.294 6.49-1.434 1.203-0.678 2.957-2.394 3.622-3.546 2.138-3.699 2.163-7.654 0.064-11.2-0.64-1.088-2.56-3.034-3.584-3.635-2.842-1.664-6.003-1.971-9.203-0.896l-1.126 0.384-1.126-0.384c-0.614-0.205-1.498-0.448-1.958-0.512-0.806-0.141-2.483-0.166-3.008-0.064zM13.222 7.565l0.73 0.154-0.742 0.781c-0.397 0.435-0.96 1.126-1.242 1.549-0.499 0.755-1.344 2.534-1.344 2.842 0 0.128 0.294 0.166 1.062 0.166h1.075l0.461-0.947c0.461-0.934 1.754-2.47 2.534-3.034l0.384-0.269 0.525 0.358c0.794 0.55 1.6 1.536 2.253 2.765l0.602 1.126h1.062c1.216 0 1.19 0.026 0.73-1.114-0.486-1.229-1.178-2.291-2.061-3.238-0.448-0.474-0.819-0.896-0.819-0.922 0-0.038 0.346-0.141 0.768-0.23 1.062-0.23 3.29-0.102 4.352 0.243 2.483 0.794 4.723 3.034 5.517 5.517 0.333 1.024 0.474 3.354 0.256 4.365-0.627 3.021-2.995 5.606-5.965 6.515-1.165 0.358-2.739 0.461-3.802 0.269-1.229-0.243-1.242-0.269-0.486-1.050 0.819-0.858 1.574-1.933 2.061-2.97 0.397-0.858 0.883-2.598 0.883-3.187v-0.358h-4.992v2.035l2.445 0.077-0.474 0.96c-0.563 1.126-2.368 3.072-2.854 3.072-0.461 0-2.176-1.818-2.739-2.893-0.256-0.512-0.474-0.986-0.474-1.062 0-0.090 0.41-0.141 1.216-0.141h1.216v-2.048h-2.56c-2.138 0-2.56 0.026-2.56 0.179 0 0.102 0.090 0.589 0.192 1.075 0.41 1.958 1.344 3.776 2.675 5.21 0.461 0.499 0.666 0.794 0.563 0.845-0.371 0.23-1.869 0.397-2.88 0.32-3.482-0.269-6.502-2.624-7.539-5.888-1.536-4.813 1.242-9.779 6.157-11.034 0.819-0.205 2.88-0.218 3.814-0.038z"></path></svg>',
                -- }
                
                -- local svg_3 = renderer.load_svg(svg[3], 20 , 20 )

                -- renderer.texture(svg_3,render.notifications.c_var.screen[1] / 2 - text_size[1] / 2  + 5,add_y - 22 + 1,20 ,20 ,r,g,b,alpha)
                -- renderer.texture(svg_2,render.notifications.c_var.screen[1] / 2 - text_size[1] / 2  + 5,add_y - 22 + 1,19 ,19 ,0,255,0,alpha3)
                





        
                y = y - 25
                renderer.text(
                    render.notifications.c_var.screen[1] / 2 - text_size[1] / 2  + 5,add_y - 19 + 1,
                    246,164,60, 255,nil,0,"\affffffff"..info.text
                )

            else
                local bx ,by = client.screen_size()

                local letter_anim = animations.anim_new('sadasdsfsaxxx', alpha2 > 0 and 12 or 0)
                local letter_anim2 = animations.anim_new('sadasdsfsaxxxx', alpha2 > 0 and 8 or 0)
                text = "gucci"
                text2 = "[ ]"

                -- local svg = {
                --     30,
                --     30,
                --     '<svg version="1.1" xmlns="http://www.w3.org/2000/svg" width="50" height="40" viewBox="0 0 32 32"><title>Color-Fill-5-1</title><path fill="#fff" d="M10.048 5.325c-2.778 0.576-4.301 1.293-5.926 2.803-3.034 2.816-4.198 7.283-2.893 11.2 0.538 1.6 1.267 2.752 2.611 4.109 1.408 1.421 2.445 2.086 4.224 2.701 1.178 0.41 1.267 0.422 3.328 0.422 2.112 0 2.112 0 3.494-0.486 1.267-0.435 1.421-0.461 1.728-0.294 0.666 0.346 2.15 0.717 3.264 0.832 2.15 0.218 4.467-0.294 6.49-1.434 1.203-0.678 2.957-2.394 3.622-3.546 2.138-3.699 2.163-7.654 0.064-11.2-0.64-1.088-2.56-3.034-3.584-3.635-2.842-1.664-6.003-1.971-9.203-0.896l-1.126 0.384-1.126-0.384c-0.614-0.205-1.498-0.448-1.958-0.512-0.806-0.141-2.483-0.166-3.008-0.064zM13.222 7.565l0.73 0.154-0.742 0.781c-0.397 0.435-0.96 1.126-1.242 1.549-0.499 0.755-1.344 2.534-1.344 2.842 0 0.128 0.294 0.166 1.062 0.166h1.075l0.461-0.947c0.461-0.934 1.754-2.47 2.534-3.034l0.384-0.269 0.525 0.358c0.794 0.55 1.6 1.536 2.253 2.765l0.602 1.126h1.062c1.216 0 1.19 0.026 0.73-1.114-0.486-1.229-1.178-2.291-2.061-3.238-0.448-0.474-0.819-0.896-0.819-0.922 0-0.038 0.346-0.141 0.768-0.23 1.062-0.23 3.29-0.102 4.352 0.243 2.483 0.794 4.723 3.034 5.517 5.517 0.333 1.024 0.474 3.354 0.256 4.365-0.627 3.021-2.995 5.606-5.965 6.515-1.165 0.358-2.739 0.461-3.802 0.269-1.229-0.243-1.242-0.269-0.486-1.050 0.819-0.858 1.574-1.933 2.061-2.97 0.397-0.858 0.883-2.598 0.883-3.187v-0.358h-4.992v2.035l2.445 0.077-0.474 0.96c-0.563 1.126-2.368 3.072-2.854 3.072-0.461 0-2.176-1.818-2.739-2.893-0.256-0.512-0.474-0.986-0.474-1.062 0-0.090 0.41-0.141 1.216-0.141h1.216v-2.048h-2.56c-2.138 0-2.56 0.026-2.56 0.179 0 0.102 0.090 0.589 0.192 1.075 0.41 1.958 1.344 3.776 2.675 5.21 0.461 0.499 0.666 0.794 0.563 0.845-0.371 0.23-1.869 0.397-2.88 0.32-3.482-0.269-6.502-2.624-7.539-5.888-1.536-4.813 1.242-9.779 6.157-11.034 0.819-0.205 2.88-0.218 3.814-0.038z"></path></svg>',
                -- }
                -- local svg2 = {
                --     26,
                --     26,
                --     '<svg version="1.1" xmlns="http://www.w3.org/2000/svg" width="50" height="40" viewBox="0 0 32 32"><title>Color-Fill-5-1</title><path fill="#fff" d="M10.048 5.325c-2.778 0.576-4.301 1.293-5.926 2.803-3.034 2.816-4.198 7.283-2.893 11.2 0.538 1.6 1.267 2.752 2.611 4.109 1.408 1.421 2.445 2.086 4.224 2.701 1.178 0.41 1.267 0.422 3.328 0.422 2.112 0 2.112 0 3.494-0.486 1.267-0.435 1.421-0.461 1.728-0.294 0.666 0.346 2.15 0.717 3.264 0.832 2.15 0.218 4.467-0.294 6.49-1.434 1.203-0.678 2.957-2.394 3.622-3.546 2.138-3.699 2.163-7.654 0.064-11.2-0.64-1.088-2.56-3.034-3.584-3.635-2.842-1.664-6.003-1.971-9.203-0.896l-1.126 0.384-1.126-0.384c-0.614-0.205-1.498-0.448-1.958-0.512-0.806-0.141-2.483-0.166-3.008-0.064zM13.222 7.565l0.73 0.154-0.742 0.781c-0.397 0.435-0.96 1.126-1.242 1.549-0.499 0.755-1.344 2.534-1.344 2.842 0 0.128 0.294 0.166 1.062 0.166h1.075l0.461-0.947c0.461-0.934 1.754-2.47 2.534-3.034l0.384-0.269 0.525 0.358c0.794 0.55 1.6 1.536 2.253 2.765l0.602 1.126h1.062c1.216 0 1.19 0.026 0.73-1.114-0.486-1.229-1.178-2.291-2.061-3.238-0.448-0.474-0.819-0.896-0.819-0.922 0-0.038 0.346-0.141 0.768-0.23 1.062-0.23 3.29-0.102 4.352 0.243 2.483 0.794 4.723 3.034 5.517 5.517 0.333 1.024 0.474 3.354 0.256 4.365-0.627 3.021-2.995 5.606-5.965 6.515-1.165 0.358-2.739 0.461-3.802 0.269-1.229-0.243-1.242-0.269-0.486-1.050 0.819-0.858 1.574-1.933 2.061-2.97 0.397-0.858 0.883-2.598 0.883-3.187v-0.358h-4.992v2.035l2.445 0.077-0.474 0.96c-0.563 1.126-2.368 3.072-2.854 3.072-0.461 0-2.176-1.818-2.739-2.893-0.256-0.512-0.474-0.986-0.474-1.062 0-0.090 0.41-0.141 1.216-0.141h1.216v-2.048h-2.56c-2.138 0-2.56 0.026-2.56 0.179 0 0.102 0.090 0.589 0.192 1.075 0.41 1.958 1.344 3.776 2.675 5.21 0.461 0.499 0.666 0.794 0.563 0.845-0.371 0.23-1.869 0.397-2.88 0.32-3.482-0.269-6.502-2.624-7.539-5.888-1.536-4.813 1.242-9.779 6.157-11.034 0.819-0.205 2.88-0.218 3.814-0.038z"></path></svg>',
                -- }
                -- local svg = renderer.load_svg(svg[3], 30 , 30 )
                -- local svg2 = renderer.load_svg(svg2[3], 26 , 26 )
                -- renderer.texture(svg,bx/2, by/2 ,30 ,30 ,17,17,17,125)
                -- renderer.texture(svg2,bx/2+2, by/2+2 ,26 ,26 ,r,g,b,255)

                renderer.rectangle(0,0,bx,by, 0,0,0,55*alpha2)
                local better = math.abs(1 * math.cos(2 * math.pi * (globals.curtime() + 3) / 6)) * 90
                local better2 = math.abs(1 * math.cos(2 * math.pi * (globals.curtime() + 3) / 6)) * 100
                local text_size = {renderer.measure_text('d++',text:sub(1, letter_anim))}
                local text_size2 = {renderer.measure_text('b',"\a878787ff[DEBUG]")}
                -- renderer.text(
                --     bx/2-16,by/2-95,
                --     255, 255, 255, 255*alpha2,'d++',0,text:sub(1, letter_anim)
                -- )

                -- renderer.text(
                --     bx/2-text_size2[1]/2, by/2-30,
                --     255, 255, 255, 255*alpha2,'b',0,""..text2:sub(1, letter_anim2)
                -- )
            end
            if info.timer + 4 < globals.realtime() then
                table.remove(render.notifications.table_text,i)
            end
        end
    end
    
end

client.set_event_callback("paint_ui", function()
    menuopen = ui.is_menu_open()
    bx ,by = client.screen_size()
    menux, menuy = ui.menu_position()
    menusx, menusy = ui.menu_size()
    alpha2 = animations.anim_new('asdasddsaxxdd', menuopen and 1 or 0)

    -- decorations

    if menuopen then

        renderer.rectangle(menux,menuy+menusy,menusx,6, 8,58,33,255)
        renderer.rectangle(menux,menuy+menusy,menusx,4, 159,29,29,255)
        renderer.rectangle(menux,menuy+menusy,menusx,3, 8,58,33,255)
    end
end)

local save_antibrute = function()
    local settings = {}
    
    pcall(function()
    for key, value in pairs(antibrute) do
        if value then
            settings[key] = {}
    
            if type(value) == 'table' then
                for k, v in pairs(value) do
                    settings[key][k] = ui.get(v)
            end
            else
                settings[key] = ui.get(value)
            end
        end
    end
    
    
    if ui.get(menu.consolelogs) then
        printc("\a"..RGBtoHEX(r,g,b).."gucci ~ \affffff".."SAvedd anti-bruteforce phases to clipboard")
    end
    data.phases_saved = requirements.base64.encode(json.stringify(settings), base64)
    table.insert(render.notifications.table_text, {
        text = " SAvedd anti-bruteforce phases to clipboard",
        timer = globals.realtime(),
    
        smooth_y = render.notifications.c_var.screen[2] + 100,
        alpha = 0,
        alpha2 = 0,
        alpha3 = 0,
    
    
        box_left = 0,
        box_right = 0,
    
        box_left_1 = 0,
        box_right_1 = 0
    }) 
    
    end)
    end
    
    function createlog(text)
        table.insert(render.notifications.table_text, {
            text = ""..text,
            timer = globals.realtime(),
        
            smooth_y = render.notifications.c_var.screen[2] + 100,
            alpha = 0,
            alpha2 = 0,
            alpha3 = 0,
        
        
            box_left = 0,
            box_right = 0,
        
            box_left_1 = 0,
            box_right_1 = 0,
    
            type = true
        }) 
end

local brute = {
    yaw_status = "default",
    fs_side = 0,
    last_miss = 0,
    best_angle = 0,
    misses = { },
    hp = 0,
    misses_ind = { },
    can_hit_head = 0,
    can_hit = 0,
    hit_reverse = { },
    phase = 0,
    jitter = 0,
}

local best_enemy = nil


local ingore = false
local laa = 0
local raa = 0
local mantimer = 0
local function normalize_yaw(yaw)
    while yaw > 180 do yaw = yaw - 360 end
        while yaw < -180 do yaw = yaw + 360 end
            return yaw
        end

        local function calc_angle(local_x, local_y, enemy_x, enemy_y)
            local ydelta = local_y - enemy_y
            local xdelta = local_x - enemy_x
            local relativeyaw = math.atan( ydelta / xdelta )
            relativeyaw = normalize_yaw( relativeyaw * 180 / math.pi )
            if xdelta >= 0 then
                relativeyaw = normalize_yaw(relativeyaw + 180)
            end
            return relativeyaw
        end

        local function ang_on_screen(x, y)
            if x == 0 and y == 0 then return 0 end

            return math.deg(math.atan2(y, x))
        end

        local function angle_vector(angle_x, angle_y)
            local sy = math.sin(math.rad(angle_y))
            local cy = math.cos(math.rad(angle_y))
            local sp = math.sin(math.rad(angle_x))
            local cp = math.cos(math.rad(angle_x))
            return cp * cy, cp * sy, -sp
        end

        local function get_damage(me, enemy, x, y,z)
            local ex = { }
            local ey = { }
            local ez = { }
            ex[0], ey[0], ez[0] = entity.hitbox_position(enemy, 1)
            ex[1], ey[1], ez[1] = ex[0] + 40, ey[0], ez[0]
            ex[2], ey[2], ez[2] = ex[0], ey[0] + 40, ez[0]
            ex[3], ey[3], ez[3] = ex[0] - 40, ey[0], ez[0]
            ex[4], ey[4], ez[4] = ex[0], ey[0] - 40, ez[0]
            ex[5], ey[5], ez[5] = ex[0], ey[0], ez[0] + 40
            ex[6], ey[6], ez[6] = ex[0], ey[0], ez[0] - 40
            local bestdamage = 0
            local bent = nil
            for i=0, 6 do
                local ent, damage = client.trace_bullet(enemy, ex[i], ey[i], ez[i], x, y, z)
                if damage > bestdamage then
                    bent = ent
                    bestdamage = damage
                end
            end
            return bent == nil and client.scale_damage(me, 1, bestdamage) or bestdamage
        end

        local function get_best_enemy()
            best_enemy = nil

            local enemies = entity.get_players(true)
            local best_fov = 180

            local lx, ly, lz = client.eye_position()
            local view_x, view_y, roll = client.camera_angles()

            for i=1, #enemies do
                local cur_x, cur_y, cur_z = entity.get_prop(enemies[i], "m_vecOrigin")
                local cur_fov = math.abs(normalize_yaw(ang_on_screen(lx - cur_x, ly - cur_y) - view_y + 180))
                if cur_fov < best_fov then
                    best_fov = cur_fov
                    best_enemy = enemies[i]
                end
            end
        end

        local function extrapolate_position(xpos,ypos,zpos,ticks,player)
            local x,y,z = entity.get_prop(player, "m_vecVelocity")
            for i=0, ticks do
                xpos =  xpos + (x*globals.tickinterval())
                ypos =  ypos + (y*globals.tickinterval())
                zpos =  zpos + (z*globals.tickinterval())
            end
            return xpos,ypos,zpos
        end

        local function get_velocity(player)
            local x,y,z = entity.get_prop(player, "m_vecVelocity")
            if x == nil then return end
            return math.sqrt(x*x + y*y + z*z)
        end

        local function get_body_yaw(player)
            local _, model_yaw = entity.get_prop(player, "m_angAbsRotation")
            local _, eye_yaw = entity.get_prop(player, "m_angEyeAngles")
            if model_yaw == nil or eye_yaw ==nil then return 0 end
            return normalize_yaw(model_yaw - eye_yaw)
        end

        local function get_best_angle()
            local me = entity.get_local_player()

            if best_enemy == nil then return end

            local origin_x, origin_y, origin_z = entity.get_prop(best_enemy, "m_vecOrigin")
            if origin_z == nil then return end
            origin_z = origin_z + 64

            local extrapolated_x, extrapolated_y, extrapolated_z = extrapolate_position(origin_x, origin_y, origin_z, 20, best_enemy)

            local lx,ly,lz = client.eye_position()
            local hx,hy,hz = entity.hitbox_position(entity.get_local_player(), 0)
            local _, head_dmg = client.trace_bullet(best_enemy, origin_x, origin_y, origin_z, hx, hy, hz, true)

            if head_dmg ~= nil and head_dmg > 1 then
                brute.can_hit_head = 1
            else
                brute.can_hit_head = 0
            end

            local view_x, view_y, roll = client.camera_angles()

            local e_x, e_y, e_z = entity.hitbox_position(best_enemy, 0)

            local yaw = calc_angle(lx, ly, e_x, e_y)
            local rdir_x, rdir_y, rdir_z = angle_vector(0, (yaw + 90))
            local rend_x = lx + rdir_x * 10
            local rend_y = ly + rdir_y * 10

            local ldir_x, ldir_y, ldir_z = angle_vector(0, (yaw - 90))
            local lend_x = lx + ldir_x * 10
            local lend_y = ly + ldir_y * 10

            local r2dir_x, r2dir_y, r2dir_z = angle_vector(0, (yaw + 90))
            local r2end_x = lx + r2dir_x * 100
            local r2end_y = ly + r2dir_y * 100

            local l2dir_x, l2dir_y, l2dir_z = angle_vector(0, (yaw - 90))
            local l2end_x = lx + l2dir_x * 100
            local l2end_y = ly + l2dir_y * 100

            local ldamage = get_damage(me, best_enemy, rend_x, rend_y, lz)
            local rdamage = get_damage(me, best_enemy, lend_x, lend_y, lz)

            local l2damage = get_damage(me, best_enemy, r2end_x, r2end_y, lz)
            local r2damage = get_damage(me, best_enemy, l2end_x, l2end_y, lz)

            if l2damage > r2damage or ldamage > rdamage or l2damage > ldamage then
                if ui.get(ref.freestanding[2]) then
                    brute.best_angle = (brute.hit_reverse[best_enemy] == nil and 1 or 2)
                else
                    brute.best_angle = 1
                end
            elseif r2damage > l2damage or rdamage > ldamage or r2damage > rdamage then
                if ui.get(ref.freestanding[2]) then
                    brute.best_angle = (brute.hit_reverse[best_enemy] == nil and 2 or 1)
                else
                    brute.best_angle = 2
                end
            end
        end
        

        local function hitxx(e)
            local r,g,b,a = ui.get(menu.main_clr)
            if ui.get(menu.consolelogs) then
                printc("\a"..RGBtoHEX(r,g,b).."gucci ~ \affffff"..string.format(" Hit "..RGBAtoHEX(r,g,b,255).."%s for %s in the %s [hc: %s, bt: %s, lc: %s] ", string.lower(entity.get_player_name(e.target)), e.damage, hitgroup_names[e.hitgroup + 1] or '?', math.floor(e.hit_chance).."%", stored_shot.backtrack, stored_shot.lagcomp))
            end

            if not ui.get(menu.logsss) or not contains(menu.notifys, "Hit")  then return end
            local clr = "" -- \a6cd977ff
            local clr2 = "\affffffff" -- \a6cd977ff
            local dflt = "\affffffff"
            table.insert(render.notifications.table_text, {
                text = string.format("\affffffffHit %s's \a"..RGBAtoHEX(r,g,b,255).."%s for \ab9d4b4ff%s\affffffff (%s) [bt: \a"..RGBAtoHEX(r,g,b,255).."%s\affffffff | lc: \a"..RGBAtoHEX(r,g,b,255).."%s\affffffff]", string.lower(entity.get_player_name(e.target)), hitgroup_names[e.hitgroup + 1] or '?',e.damage, e.damage, stored_shot.backtrack, stored_shot.lagcomp),
                timer = globals.realtime(),
            
                smooth_y = render.notifications.c_var.screen[2] + 100,
                alpha = 0,
                alpha2 = 0,
                alpha3 = 0,
            
            
                box_left = 0,
                box_right = 0,
            
                box_left_1 = 0,
                box_right_1 = 0
            }) 
        end

        local function missxx(e)
            local r,g,b,a = ui.get(menu.main_clr)
            if ui.get(menu.consolelogs) then
                printc("\a"..RGBtoHEX(r,g,b).."gucci ~ \affffff"..string.format(" Missed %s's %s due to %s [dmg: %s, bt: %s, lc: %s] ", string.lower(entity.get_player_name(e.target)), stored_shot.hitbox, e.reason, stored_shot.damage, stored_shot.lagcomp, stored_shot.backtrack))
            end

            if not ui.get(menu.logsss) or not contains(menu.notifys, "Misses")  then return end

            table.insert(render.notifications.table_text, {
                text = string.format("Missed %s's %s due to %s [dmg: %s, bt: %s, lc: %s]", string.lower(entity.get_player_name(e.target)), stored_shot.hitbox, e.reason, stored_shot.damage, stored_shot.lagcomp, stored_shot.backtrack),
                timer = globals.realtime(),
            
                smooth_y = render.notifications.c_var.screen[2] + 100,
                alpha = 0,
                alpha2 = 0,
                alpha3 = 0,
            
            
                box_left = 0,
                box_right = 0,
            
                box_left_1 = 0,
                box_right_1 = 0
            }) 
        end

        local function brute_impact(e)
            if (not ui.get(menu.antibrute_switch) and not ui.get(menu.logsss)) and not contains(menu.notifys, "Switches")  then return end
            local me = entity.get_local_player()

            if not entity.is_alive(me) then return end

            local shooter_id = e.userid
            local shooter = client.userid_to_entindex(shooter_id)

            if not entity.is_enemy(shooter) or entity.is_dormant(shooter) then return end

            local lx, ly, lz = entity.hitbox_position(me, "head_0")

            local ox, oy, oz = entity.get_prop(me, "m_vecOrigin")
            local ex, ey, ez = entity.get_prop(shooter, "m_vecOrigin")
            local r,g,b,a = ui.get(menu.main_clr)
            local target = entity.get_player_name(client.current_threat())

            local dist = ((e.y - ey)*lx - (e.x - ex)*ly + e.x*ey - e.y*ex) / math.sqrt((e.y-ey)^2 + (e.x - ex)^2)

            if math.abs(dist) <= 80 and globals.curtime() - brute.last_miss > 0.015 then
                
                if ui.get(menu.contains) == "Default" and contains(menu.notifys, "Switches") then
                    if ui.get(menu.consolelogs) then
                        printc("\a"..RGBtoHEX(r,g,b).."gucci ~ \affffff".."Switched side due to shot [target: "..target.."]")
                    end
                    table.insert(render.notifications.table_text, {
                        text = "Switched target: \a"..RGBAtoHEX(r,g,b,255).."side\affffff7a due to shot [target: \a"..RGBAtoHEX(r,g,b,255)..""..target.."\affffff7a]",
                        timer = globals.realtime(),
                    
                        smooth_y = render.notifications.c_var.screen[2] + 100,
                        alpha = 0,
                        alpha2 = 0,
                        alpha3 = 0,
                    
                    
                        box_left = 0,
                        box_right = 0,
                    
                        box_left_1 = 0,
                        box_right_1 = 0
                    }) -- byaw
                    
                elseif ui.get(menu.contains) == "Random" and contains(menu.notifys, "Switches") and ui.get(menu.logsss) then
                    brute.jitter = math.random(60, 75)
                    ui.set(ref.jitter[2], brute.jitter)
                    if ui.get(menu.consolelogs) then
                        printc("\a"..RGBtoHEX(r,g,b).."gucci ~ \affffff".."Generated \a"..RGBAtoHEX(r,g,b,255).."random\affffffff jitter [target: \a"..RGBAtoHEX(r,g,b,255).."%s"..target.."\affffffff | jitter: \a"..RGBAtoHEX(r,g,b,255)..""..brute.jitter.."\affffffff]")
                    end
                    table.insert(render.notifications.table_text, {
                        text = "Generated \a"..RGBAtoHEX(r,g,b,255).."random\affffffff jitter [target: \a"..RGBAtoHEX(r,g,b,255)..""..target.."\affffffff | jitter: \a"..RGBAtoHEX(r,g,b,255)..""..brute.jitter.."\affffffff]",
                        timer = globals.realtime(),
                    
                        smooth_y = render.notifications.c_var.screen[2] + 100,
                        alpha = 0,
                        alpha2 = 0,
                        alpha3 = 0,
                    
                    
                        box_left = 0,
                        box_right = 0,
                    
                        box_left_1 = 0,
                        box_right_1 = 0
                    }) 
                elseif ui.get(menu.contains) == "RDS Exploit" and contains(menu.notifys, "Switches") and ui.get(menu.logsss) then
                    brute.jitter = math.random(15, 75)
                    ui.set(ref.byaw[2], brute.jitter)
                    brute.jitter2 = math.random(60, 75)
                    ui.set(ref.jitter[2], brute.jitter2)
                    if ui.get(menu.consolelogs) then
                        printc("\a"..RGBtoHEX(r,g,b).."gucci ~ \affffff".."Generated brute [target: "..target.." | jitter: "..brute.jitter.."]")
                    end
                    table.insert(render.notifications.table_text, {
                        text = "Generated brute [target: "..target.." | jitter: "..brute.jitter.."]",
                        timer = globals.realtime(),
                    
                        smooth_y = render.notifications.c_var.screen[2] + 100,
                        alpha = 0,
                        alpha2 = 0,
                        alpha3 = 0,
                    
                    
                        box_left = 0,
                        box_right = 0,
                    
                        box_left_1 = 0,
                        box_right_1 = 0
                    }) 

                else
                    if contains(menu.notifys, "Switches") and ui.get(menu.logsss) and ui.get(menu.logsss) then
                    brute.phase = brute.phase + 1
                    local r,g,b,a = ui.get(menu.main_clr)
                    if ui.get(menu.consolelogs) then
                        printc("\a"..RGBtoHEX(r,g,b).."gucci ~ \affffff".."Switched side due to shot [target: "..target.." | phase "..brute.phase.."]")
                    end
                    table.insert(render.notifications.table_text, {
                        text = "Switched side due to shot [target: "..target.." | phase "..brute.phase.."]",
                        timer = globals.realtime(),
                    
                        smooth_y = render.notifications.c_var.screen[2] + 100,
                        alpha = 0,
                        alpha2 = 0,
                        alpha3 = 0,
                    
                    
                        box_left = 0,
                        box_right = 0,
                    
                        box_left_1 = 0,
                        box_right_1 = 0
                    }) 
                end
                end
                brute.last_miss = globals.curtime()
                if brute.misses[shooter] == nil then
                    brute.misses[shooter] = 1
                    brute.misses_ind[shooter] = 1
                elseif brute.misses[shooter] >= 2 then
                    brute.misses[shooter] = nil
                else
                    brute.misses_ind[shooter] = brute.misses_ind[shooter] + 1
                    brute.misses[shooter] = brute.misses[shooter] + 1
                end
            end
        end

        brute.reset = function()
        brute.fs_side = 0
        brute.last_miss = 0
        brute.best_angle = 0
        brute.misses_ind = { }
        brute.misses = { }
        brute.phase = 0
        if ui.get(menu.antibrute_switch)  and contains(menu.notifys, "Switches") and ui.get(menu.logsss)  then
            local r,g,b,a = ui.get(menu.main_clr)
            if ui.get(menu.consolelogs) then
                printc("\a"..RGBtoHEX(r,g,b).."gucci ~ \affffff".."Anti-bruteforce data has been reset")
            end
            table.insert(render.notifications.table_text, {
                text = "Anti-bruteforce data has been reset",
                timer = globals.realtime(),
            
                smooth_y = render.notifications.c_var.screen[2] + 100,
                alpha = 0,
                alpha2 = 0,
                alpha3 = 0,
            
            
                box_left = 0,
                box_right = 0,
            
                box_left_1 = 0,
                box_right_1 = 0
            }) 

        end
    end

    local function brute_death(e)

        local victim_id = e.userid
        local victim = client.userid_to_entindex(victim_id)

        if victim ~= entity.get_local_player() then return end

        local attacker_id = e.attacker
        local attacker = client.userid_to_entindex(attacker_id)

        if not entity.is_enemy(attacker) then return end

        if not e.headshot then return end

        if brute.misses[attacker] == nil or (globals.curtime() - brute.last_miss < 0.06 and brute.misses[attacker] == 1) then
            if brute.hit_reverse[attacker] == nil then
                brute.hit_reverse[attacker] = true
            else
                brute.hit_reverse[attacker] = nil
            end
        end
    end


    local import_antibrute = function(to_import)
    pcall(function()
    local num_tbl = {}
    local settings = json.parse(requirements.base64.decode(clipboard_import(), base64))

    for key, value in pairs(settings) do
        if type(value) == 'table' then
            for k, v in pairs(value) do
                if type(k) == 'number' then
                    table.insert(num_tbl, v)
                    ui.set(antibrute[key], num_tbl)
                else
                    ui.set(antibrute[key][k], v)
                end
            end
        else
            ui.set(antibrute[key], value)
        end
    end
    



    local r,g,b,a = ui.get(menu.main_clr)
    if ui.get(menu.consolelogs) then
        printc("\a"..RGBtoHEX(r,g,b).."gucci ~ \affffff".."Loaded anti-bruteforce phases")
    end
    table.insert(render.notifications.table_text, {
        text = " Loaded anti-bruteforce phases",
        timer = globals.realtime(),
    
        smooth_y = render.notifications.c_var.screen[2] + 100,
        alpha = 0,
        alpha2 = 0,
        alpha3 = 0,
    
    
        box_left = 0,
        box_right = 0,
    
        box_left_1 = 0,
        box_right_1 = 0
    }) 

    end)
end

local load_antibrute = function(to_import)
    pcall(function()
        local num_tbl = {}
        local settings = json.parse(requirements.base64.decode(data.phases_saved, base64))

        -- Ensure settings is valid
        if not settings then
            print("Error: data.saved_phases is undefined")
            return
        end

        -- Iterate through the settings
        for key, value in pairs(settings) do
            if value then
                if type(value) == 'table' then
                    -- Process values that are tables
                    for k, v in pairs(value) do
                        if type(k) == 'number' then
                            -- Handle numeric keys
                            table.insert(num_tbl, v)
                        else
                            -- Check if antibrute[key] and antibrute[key][k] exist
                            if antibrute[key] and antibrute[key][k] then
                                ui.set(antibrute[key][k], v)
                            else
                                print("Error: Invalid key or element at antibrute["..key.."]["..k.."]")
                            end
                        end
                    end

                    -- If num_tbl has values, set it to antibrute[key]
                    if #num_tbl > 0 and antibrute[key] then
                        ui.set(antibrute[key], num_tbl)
                    end
                else
                    -- If value is not a table, set it directly
                    if antibrute[key] then
                        ui.set(antibrute[key], value)
                    else
                        print("Error: Invalid key at antibrute["..key.."]")
                    end
                end
            end
        end

        -- Fetch color settings and display logs
        local r, g, b, a = ui.get(menu.main_clr)
        if ui.get(menu.consolelogs) then
            printc("\a"..RGBtoHEX(r, g, b).."gucci ~ \affffff".."Loaded anti-bruteforce phases")
        end

        -- Add notification (ensure render.notifications.table_text exists)
        if render.notifications and render.notifications.table_text then
            table.insert(render.notifications.table_text, {
                text = " Loaded anti-bruteforce phases",
                timer = globals.realtime(),
                smooth_y = render.notifications.c_var.screen[2] + 100,
                alpha = 0,
                alpha2 = 0,
                alpha3 = 0,
                box_left = 0,
                box_right = 0,
                box_left_1 = 0,
                box_right_1 = 0
            })
        else
            print("Error: render.notifications.table_text is undefined")
        end
    end)
end

local export_antibrute = function()
local settings = {}

pcall(function()
for key, value in pairs(antibrute) do
    if value then
        settings[key] = {}

        if type(value) == 'table' then
            for k, v in pairs(value) do
                settings[key][k] = ui.get(v)
        end
        else
            settings[key] = ui.get(value)
        end
    end
end


if ui.get(menu.consolelogs) then
    printc("\a"..RGBtoHEX(r,g,b).."gucci ~ \affffff".."Exported anti-bruteforce phases to clipboard")
end
clipboard_export(requirements.base64.encode(json.stringify(settings), base64))
table.insert(render.notifications.table_text, {
    text = " Exported anti-bruteforce phases to clipboard",
    timer = globals.realtime(),

    smooth_y = render.notifications.c_var.screen[2] + 100,
    alpha = 0,
    alpha2 = 0,
    alpha3 = 0,


    box_left = 0,
    box_right = 0,

    box_left_1 = 0,
    box_right_1 = 0
}) 

end)
end

function createlog(text)
    table.insert(render.notifications.table_text, {
        text = ""..text,
        timer = globals.realtime(),
    
        smooth_y = render.notifications.c_var.screen[2] + 100,
        alpha = 0,
        alpha2 = 0,
        alpha3 = 0,
    
    
        box_left = 0,
        box_right = 0,
    
        box_left_1 = 0,
        box_right_1 = 0,

        type = true
    }) 
end

local export_antibrute = function()
local settings = {}

pcall(function()
for key, value in pairs(antibrute) do
    if value then
        settings[key] = {}

        if type(value) == 'table' then
            for k, v in pairs(value) do
                settings[key][k] = ui.get(v)
        end
        else
            settings[key] = ui.get(value)
        end
    end
end


if ui.get(menu.consolelogs) then
    printc("\a"..RGBtoHEX(r,g,b).."gucci ~ \affffff".."Exported anti-bruteforce phases to clipboard")
end
clipboard_export(requirements.base64.encode(json.stringify(settings), base64))
table.insert(render.notifications.table_text, {
    text = " Exported anti-bruteforce phases to clipboard",
    timer = globals.realtime(),

    smooth_y = render.notifications.c_var.screen[2] + 100,
    alpha = 0,
    alpha2 = 0,
    alpha3 = 0,


    box_left = 0,
    box_right = 0,

    box_left_1 = 0,
    box_right_1 = 0
}) 

end)
end

function createlog(text)
    table.insert(render.notifications.table_text, {
        text = ""..text,
        timer = globals.realtime(),
    
        smooth_y = render.notifications.c_var.screen[2] + 100,
        alpha = 0,
        alpha2 = 0,
        alpha3 = 0,
    
    
        box_left = 0,
        box_right = 0,
    
        box_left_1 = 0,
        box_right_1 = 0,

        type = true
    }) 
end

version = "debug"
local var = {
p_state = 1,
}

local function player_state()
vx, vy = entity.get_prop(entity.get_local_player(), 'm_vecVelocity')
player_standing = math.sqrt(vx ^ 2 + vy ^ 2) < 2
player_jumping = bit.band(entity.get_prop(entity.get_local_player(), 'm_fFlags'), 1) == 0
player_duck_peek_assist = ui.get(ref.fake_duck)
player_crouching = entity.get_prop(entity.get_local_player(), "m_flDuckAmount") > 0.5 and not player_duck_peek_assist
player_slow_motion = ui.get(ref.slowwalk[1]) and ui.get(ref.slowwalk[2])
is_exploiting = ui.get(ref.dt[2]) or ui.get(ref.os[2])
antibrute_active = brute.last_miss + 3 > globals.curtime() and ui.get(menu.antibrute_switch)


if antibrute_active then
    return 'antibrute'
elseif player_duck_peek_assist and not antibrute_active then
    return 'fakeduck'
elseif player_slow_motion and is_exploiting and not antibrute_active  then
    var.p_state = 6
    return 'slowmotion'
elseif player_crouching and is_exploiting and not player_jumping and not antibrute_active  then
    var.p_state = 5
    return 'crouch'
elseif player_jumping and not player_crouching and is_exploiting  and not antibrute_active then
    var.p_state = 3
    return 'jump'
elseif player_jumping and player_crouching and is_exploiting and not antibrute_active  then
    var.p_state = 4
    return "duckjump"
elseif player_standing and is_exploiting and not antibrute_active  then
    var.p_state = 1
    return 'stand'
elseif not player_standing and is_exploiting and not antibrute_active  then
    var.p_state = 2
    return 'move'
elseif not is_exploiting  and not antibrute_active then
    var.p_state = 7
    return "fakelag"
end
end

local numtotext = {
[1] = "Standing",
[2] = "Moving",
[3] = "Air",
[4] = "Air+crouch",
[5] = "Crouch",
[6] = "Slowwalk",
[7] = "Fakelag",
[8] = "Global",
}
 brutenumtotext = {
    [1] = "Phase 1",
    [2] = "Phase 2",
    [3] = "Phase 3",
    [4] = "Phase 4",
    [5] = "Phase 5",
}
anti_aim = {}
current_stage3 = 0
function stateupddd()
    if globals.tickcount() % 4 < 2 and globals.chokedcommands() > 0  then
        current_stage3 = current_stage3 + 1
    end
end

client.set_event_callback("setup_command", stateupddd)

antibrute = {}
for i = 1, 5 do
antibrute[i] = {
    yaw_mode = ui.new_combobox("AA", "Anti-aimbot angles", "\aFFFFFFFF‹\a9784b3ff"..i.."\aFFFFFFFF›\abcbcbdFF yaw mode", "Default", "sway", "Superior", "3 Way", "5 Way"),
    yaw_default = ui.new_slider("AA", "Anti-aimbot angles", "\aFFFFFFFF‹\a9784b3ff"..i.."\aFFFFFFFF›\abcbcbdFF yaw add", -90, 90, 0),
    yaw_superior = ui.new_slider("AA", "Anti-aimbot angles", "\aFFFFFFFF‹\a9784b3ff"..i.."\aFFFFFFFF›\abcbcbdFF superior yaw add", -90, 90, 0),
    yaw_left = ui.new_slider("AA", "Anti-aimbot angles", "\aFFFFFFFF‹\a9784b3ff"..i.."\aFFFFFFFF›\abcbcbdFF yaw add left", -90, 90, 0),
    yaw_right = ui.new_slider("AA", "Anti-aimbot angles", "\aFFFFFFFF‹\a9784b3ff"..i.."\aFFFFFFFF›\abcbcbdFF yaw add right", -90, 90, 0),
    fiveway_yaw_add = ui.new_slider("AA", "Anti-aimbot angles", "\aFFFFFFFF‹\a9784b3ff"..i.."\aFFFFFFFF›\abcbcbdFF 3-way yaw add", -90, 90, 0),
    threeway_yaw_add = ui.new_slider("AA", "Anti-aimbot angles", "\aFFFFFFFF‹\a9784b3ff"..i.."\aFFFFFFFF›\abcbcbdFF 5-way yaw add", -90, 90, 0),
    jitter = ui.new_combobox("AA", "Anti-aimbot angles", "\aFFFFFFFF‹\a9784b3ff"..i.."\aFFFFFFFF›\abcbcbdFF jitter", "Off", "Offset", "Center", "Random", "Skitter"),
    jitter_mode = ui.new_combobox("AA", "Anti-aimbot angles", "\aFFFFFFFF‹\a9784b3ff"..i.."\aFFFFFFFF›\abcbcbdFF jitter mode", "normal", "sway"),
    left_jitter_val = ui.new_slider("AA", "Anti-aimbot angles", "\aFFFFFFFF‹\a9784b3ff"..i.."\aFFFFFFFF›\abcbcbdFF left jitter value", -90, 90, 0),
    right_jitter_val = ui.new_slider("AA", "Anti-aimbot angles", "\aFFFFFFFF‹\a9784b3ff"..i.."\aFFFFFFFF›\abcbcbdFF right jitter value", -90, 90, 0),
    jitter_val = ui.new_slider("AA", "Anti-aimbot angles", "\aFFFFFFFF‹\a9784b3ff"..i.."\aFFFFFFFF›\abcbcbdFF jitter value", -90, 90, 0),
    body_yaw = ui.new_combobox("AA", "Anti-aimbot angles", "\aFFFFFFFF‹\a9784b3ff"..i.."\aFFFFFFFF›\abcbcbdFF body yaw", "Off", "Opposite", "Jitter", "Static"),
    body_yaw_mode = ui.new_combobox("AA", "Anti-aimbot angles", "\aFFFFFFFF‹\a9784b3ff"..i.."\aFFFFFFFF›\abcbcbdFF body yaw mode", "normal", "sway"),
    body_yaw_val = ui.new_slider("AA", "Anti-aimbot angles", "\aFFFFFFFF‹\a9784b3ff"..i.."\aFFFFFFFF›\abcbcbdFF body yaw value", -180, 180, 0),
    left_byaw_val = ui.new_slider("AA", "Anti-aimbot angles", "\aFFFFFFFF‹\a9784b3ff"..i.."\aFFFFFFFF›\abcbcbdFF left body yaw value", -90, 90, 0),
    right_byaw_val = ui.new_slider("AA", "Anti-aimbot angles", "\aFFFFFFFF‹\a9784b3ff"..i.."\aFFFFFFFF›\abcbcbdFF right body yaw value", -90, 90, 0),
    lolway_yaw_add = ui.new_slider("AA", "Anti-aimbot angles", "\aFFFFFFFF‹\a9784b3ff"..i.."\aFFFFFFFF›\abcbcbdFF meta jitter value", -90, 90, 0),
    threeway_jitter_val = ui.new_slider("AA", "Anti-aimbot angles", "\aFFFFFFFF‹\a9784b3ff"..i.."\aFFFFFFFF›\abcbcbdFF 5-way jitter value", -90, 90, 0),
}
end










function gradient_text_anim(rr, gg, bb, aa, rrr, ggg, bbb, aaa, text, speed)
r1, g1, b1, a1 = rr, gg, bb, aa
r2, g2, b2, a2 = rrr, ggg, bbb, aaa
highlight_fraction =  (globals.realtime() / 2 % 1.2 * speed) - 1.2
output = ""
for idx = 1, #text do
    local character = text:sub(idx, idx)
    local character_fraction = idx / #text

    local r, g, b, a = r1, g1, b1, a1
    local highlight_delta = (character_fraction - highlight_fraction)
    if highlight_delta >= 0 and highlight_delta <= 1.4 then
        if highlight_delta > 0.7 then
            highlight_delta = 1.4 - highlight_delta
        end
        local r_fraction, g_fraction, b_fraction, a_fraction = r2 - r, g2 - g, b2 - b
        r = r + r_fraction * highlight_delta / 0.8
        g = g + g_fraction * highlight_delta / 0.8
        b = b + b_fraction * highlight_delta / 0.8
    end
    output = output .. ('\a%02x%02x%02x%02x%s'):format(r, g, b, 255, text:sub(idx, idx))
end
return output
end








                
                local Mode = "Off"
                local last_sim_time = 0
                local defensive_until = 0
                local leftReady = false
                local rightReady = false
                local forwardReady = false

                local function is_defensive_active()
                    local tickcount = globals.tickcount()
                    local local_player = entity.get_local_player()
                    local sim_time = toticks(entity.get_prop(local_player, "m_flSimulationTime"))
                    local sim_diff = sim_time - last_sim_time

                    if sim_diff < 0 then
                        defensive_until = tickcount + math.abs(sim_diff) - toticks(client.latency())
                    end

                    last_sim_time = sim_time

                    return defensive_until > tickcount
                end



                local last_press_t_dir = 0
                local yaw_direction = 0
                local antibrute_active = false
                local breaker_active = false
                local aa_tbl = {
                    jitter = 0,
                    fakeyaw = 0,
                    yaw = 0,
                    bodyyaw = 0,
                }
                misc = {}

                    misc.knife_isactive = false
                    
                    misc.anti_knife_dist = function (x1, y1, z1, x2, y2, z2)
                        return math.sqrt((x2 - x1)^2 + (y2 - y1)^2 + (z2 - z1)^2)
                    end
                    
                    misc.anti_knife = function()
                        if ui.get(menu.knife_hotkey) then
                            local players = entity.get_players(true)
                            local lx, ly, lz = entity.get_prop(entity.get_local_player(), "m_vecOrigin")
                    
                            for i=1, #players do
                                local x, y, z = entity.get_prop(players[i], "m_vecOrigin")
                                local distance = misc.anti_knife_dist(lx, ly, lz, x, y, z)
                                local weapon = entity.get_player_weapon(players[i])
                                if entity.get_classname(weapon) == "CKnife" and distance <= ui.get(menu.knife_distance) then
                                    misc.knife_isactive = true
                                    ui.set(ref.yaw[2],180)
                                    ui.set(ref.pitch[1],"Off")
                                else
                                    misc.knife_isactive = false
                                    --ui.set(ref.pitch[1],"Minimal")
                                end
                            end
                        end
                    end   
                    
                    local current_phase = 1
                    local current_phase_jit = 1
                    local current_phase_yaw = 1
                    local increment = 1
                    local increment1 = 1
                    local increment2 = 1
                    

                    local function apply_tickbase(cmd, ticks_to_shift)
                        local usrcmd = get_input.vfptr.GetUserCmd(ffi.cast("uintptr_t", get_input), 0, cmd.command_number)
                    
                        if cmd.chokedcommands == 0 then return end
                    
                        cmd.no_choke = true
                        cmd.allow_send_packet = true
                        usrcmd.send_packet = true
                    --	usrcmd.tick_count = globals.tickcount() + ticks_to_shift
                        return
                    end
                client.set_event_callback("setup_command", function(c)
                    misc.anti_knife()

                local bodyyaw = entity.get_prop(entity.get_local_player(), "m_flPoseParameter", 11) * 120 - 60
                local side = bodyyaw > 0 and 1 or -1
                if brute.phase > 5 then
                    brute.phase = 0
                end
        
                if brute.last_miss + 3 > globals.curtime() and brute.phase > 0 and misc.knife_isactive == false then
                    if ui.get(menu.contains) == "Custom" then
                        ui.set(ref.yaw[1], 180)
if c.chokedcommands ~= 0 then
else
if ui.get(antibrute[brute.phase].yaw_mode) == "Default" then
ui.set(ref.yaw[2], yaw_direction == 0 and ui.get(antibrute[brute.phase].yaw_default) or yaw_direction)
elseif ui.get(antibrute[brute.phase].yaw_mode) == "sway" then
ui.set(ref.yaw[2], (yaw_direction == 0 and (side == 1 and ui.get(antibrute[brute.phase].yaw_left) or ui.get(antibrute[brute.phase].yaw_right)) or yaw_direction))
elseif ui.get(antibrute[brute.phase].yaw_mode) == "Superior" then
ui.set(ref.yaw[2], yaw_direction == 0 and client.random_int(ui.get(antibrute[brute.phase].yaw_superior), ui.get(antibrute[brute.phase].yaw_superior)+client.random_int(-10, 10) or yaw_direction))
elseif ui.get(antibrute[brute.phase].yaw_mode) == "3 Way" then
local yaw_list = { -ui.get(antibrute[brute.phase].fiveway_yaw_add), 0, ui.get(antibrute[brute.phase].fiveway_yaw_add)}
current_phase = current_phase + increment
if current_phase > 3 then
    increment = -increment
end
if current_phase <= 1 then
    increment = math.abs(increment)
end
ui.set(ref.yaw[2], yaw_direction == 0 and yaw_list[current_phase] or yaw_direction)
else
local yaw_list = { -ui.get(antibrute[brute.phase].threeway_yaw_add), -ui.get(antibrute[brute.phase].threeway_yaw_add)/2, 0, ui.get(antibrute[brute.phase].threeway_yaw_add)/2, ui.get(antibrute[brute.phase].threeway_yaw_add)}
current_phase = current_phase + increment
if current_phase > 5 then
    increment = -increment
end
if current_phase <= 1 then
    increment = math.abs(increment)
end
ui.set(ref.yaw[2], yaw_direction == 0 and yaw_list[current_phase] or yaw_direction)
end
end 
ui.set(ref.byaw[1], ui.get(antibrute[brute.phase].body_yaw))

if ui.get(antibrute[brute.phase].body_yaw_mode) == "normal" then
    ui.set(ref.byaw[1], ui.get(antibrute[brute.phase].body_yaw))
    ui.set(ref.byaw[2], ui.get(antibrute[brute.phase].body_yaw_val))
else
    ui.set(ref.byaw[1], ui.get(antibrute[brute.phase].body_yaw))
    ui.set(ref.byaw[2], (side == 1 and ui.get(antibrute[brute.phase].left_byaw_val) or ui.get(antibrute[brute.phase].right_byaw_val)))
end

if ui.get(antibrute[brute.phase].jitter_mode) == "normal" then
if ui.get(antibrute[brute.phase].jitter) == "Random Center" then
    ui.set(ref.jitter[1], "Center")
    ui.set(ref.jitter[2], client.random_int(ui.get(antibrute[brute.phase].jitter_val), ui.get(antibrute[brute.phase].jitter_val)+client.random_int(-12, 18)))
elseif ui.get(antibrute[brute.phase].jitter) == "lol" then
    local jitter_list = { -ui.get(antibrute[brute.phase].lolway_yaw_add)/2, -ui.get(antibrute[brute.phase].lolway_yaw_add), ui.get(antibrute[brute.phase].lolway_yaw_add)/2, ui.get(antibrute[brute.phase].lolway_yaw_add)}
    ui.set(ref.jitter[2], jitter_list[current_phase_jit])
elseif ui.get(antibrute[brute.phase].jitter) == "5 Way" then
    local jitter_list = { -ui.get(antibrute[brute.phase].threeway_jitter_val), -ui.get(antibrute[brute.phase].threeway_jitter_val)/2, 0, ui.get(antibrute[brute.phase].threeway_jitter_val)/2, ui.get(antibrute[brute.phase].threeway_jitter_val)}
    current_phase_jit = current_phase_jit + increment1
    if current_phase_jit > 5 then
        increment1 = -increment1
    end
    if current_phase_jit <= 1 then
        increment1 = math.abs(increment1)
    end
    ui.set(ref.jitter[2], jitter_list[current_phase_jit])
else
    ui.set(ref.jitter[2], ui.get(antibrute[brute.phase].jitter_val))
    ui.set(ref.jitter[1], ui.get(antibrute[brute.phase].jitter))
end
else
if ui.get(antibrute[brute.phase].jitter) == "Random Center" then
    ui.set(ref.jitter[1], "Center")
    ui.set(ref.jitter[2], client.random_int(ui.get(antibrute[brute.phase].jitter_val), ui.get(antibrute[brute.phase].jitter_val)+client.random_int(-12, 18)))

elseif ui.get(antibrute[brute.phase].jitter) == "lol" then
    local current_val = side == 1 and ui.get(antibrute[brute.phase].left_jitter_val) or ui.get(antibrute[brute.phase].right_jitter_val)
    local jitter_list = { -current_val/2, current_val, current_val/2, -current_val}
    current_phase_jit = current_phase_jit + increment1
    if current_phase_jit > 4 then
        increment1 = -increment1
    end
    if current_phase_jit <= 4 then
        increment1 = math.abs(increment1)
    end
    ui.set(ref.jitter[2], jitter_list[current_phase_jit])
elseif ui.get(antibrute[brute.phase].jitter) == "5 Way" then
    local current_val = side == 1 and ui.get(antibrute[brute.phase].left_jitter_val) or ui.get(antibrute[brute.phase].right_jitter_val)
    local jitter_list = { -current_val, -current_val/2, 0, current_val/2, current_val}
    current_phase_jit = current_phase_jit + increment1
    if current_phase_jit > 5 then
        increment1 = -increment1
    end
    if current_phase_jit <= 1 then
        increment1 = math.abs(increment1)
    end
    ui.set(ref.jitter[2], jitter_list[current_phase_jit])
else
    ui.set(ref.jitter[1], ui.get(antibrute[brute.phase].jitter))
    ui.set(ref.jitter[2], side == 1 and ui.get(antibrute[brute.phase].left_jitter_val) or ui.get(antibrute[brute.phase].right_jitter_val))
end
end


                    end
                end
                if brute.last_miss + 3 > globals.curtime() and contains(menu.contains, "RDS Exploit") or contains(menu.contains, "Jitter") then
                    antibrute_active = true
                else
                    antibrute_active = false
                end
                player_state()
                    if ui.get(menu.presets) == "Dynamic" and brute.last_miss + 3 < globals.curtime() and misc.knife_isactive == false then
                        if globals.tickcount() % 20 == 1 then
                            aa_tbl = {
                                jitter = math.random(50, 60),
                                fakeyaw = math.random(50, 60),
                                yaw = math.random(-10,10),
                                bodyyaw = 0,
                            }
                        end
                            ui.set(ref.yaw[1], "180")
                                ui.set(ref.yaw[2], aa_tbl.yaw)
                                    ui.set(ref.byaw[2], aa_tbl.bodyyaw)
                            ui.set(ref.byaw[1], "Jitter")
                                ui.set(ref.jitter[1], "Center")
                            ui.set(ref.jitter[2], aa_tbl.jitter)
                    elseif ui.get(menu.presets) == "Three-heads" and brute.last_miss + 3 < globals.curtime() and misc.knife_isactive == false then
                        if globals.tickcount() % 20 == 1 then
                            aa_tbl = {
                                jitter = math.random(35, 60),
                                fakeyaw = math.random(25, 55),
                                yaw = math.random(-10,10),
                                bodyyaw = 0,
                            }
                        end
                            ui.set(ref.yaw[1], "180")
                                ui.set(ref.yaw[2], aa_tbl.yaw)
                                    ui.set(ref.byaw[2], aa_tbl.bodyyaw)
                            ui.set(ref.byaw[1], "Jitter")
                                ui.set(ref.jitter[1], "Skitter")
                            ui.set(ref.jitter[2], aa_tbl.jitter)
                    elseif ui.get(menu.presets) == "Defensive-jitter" and brute.last_miss + 3 < globals.curtime() and misc.knife_isactive == false then
                        if globals.tickcount() % 20 == 1 then
                            aa_tbl = {
                                jitter = math.random(35, 60),
                                fakeyaw = math.random(35, 60),
                                yaw = math.random(-20,20),
                                bodyyaw = 0,
                            }
                        end
                            ui.set(ref.yaw[1], "180")
                                ui.set(ref.yaw[2], aa_tbl.yaw)
                                    ui.set(ref.byaw[2], aa_tbl.bodyyaw)
                            ui.set(ref.byaw[1], "Jitter")
                                ui.set(ref.jitter[1], "Center")
                            ui.set(ref.jitter[2], aa_tbl.jitter)
                        elseif ui.get(menu.presets) == "\a428df5FFPUBLIC: \aFFFFFFFFcaisa" and brute.last_miss + 3 < globals.curtime() and misc.knife_isactive == false then
                            if globals.tickcount() % 20 == 1 then
                                aa_tbl = {
                                    jitter = -21,
                                    fakeyaw = math.random(35, 60),
                                    yaw = math.random(-20,20),
                                    bodyyaw = 0,
                                }
                            end
                                ui.set(ref.yaw[1], "180")
                                    ui.set(ref.yaw[2], aa_tbl.yaw)
                                        ui.set(ref.byaw[2], aa_tbl.bodyyaw)
                                ui.set(ref.byaw[1], "Off")
                                    ui.set(ref.jitter[1], "Center")
                                ui.set(ref.jitter[2], aa_tbl.jitter)
                    end
                    local defensive_active = is_defensive_active()
                    if ui.get(menu.checkbox)  then
                    --if c.command_number % 16 < 2 then

                        if player_state() ~= "duckjump" or player_state() ~= "jump" then
                            c.force_defensive = true
                        end
                    end
                    if ui.get(menu.checkbox2) then
    
                        ui.set(legsmovement, math.random(1,2) == 1 and "Always slide" or "Never slide")
                    else
                        ui.set(legsmovement, "Off")
                    end

                    
                    

                    if (ui.get(menu.fs_toggle)) then
                        yaw_direction = 0
                        last_press_t_dir = 0
                        Mode = "Off"
                    else
                        if last_press_t_dir > globals.curtime() then
                            Mode = "Off"
                            last_press_t_dir = globals.curtime()
                            yaw_direction = 0
                        end
                    end




                    if ui.get(menu.lagcomp) and ui.get(ref.os[2]) and not ui.get(ref.fake_duck) then
                        ui.set(ref.enablefl, false)
                        ui.set(ref.fl_limit, 1)
                    elseif ui.get(menu.lagcomp) and ui.get(ref.os[2]) and ui.get(ref.fake_duck) then
                        ui.set(ref.enablefl, true)
                        ui.set(ref.fl_limit, 14)
                    elseif ui.get(menu.lagcomp) and not ui.get(ref.os[2]) then
                        ui.set(ref.enablefl, true)
                        ui.set(ref.fl_limit, 14)
                    else
                        ui.set(ref.enablefl, true)
                        ui.set(ref.fl_limit, 14)
                    end
                    if ui.get(menu.fs_toggle) then
                        ui.set(ref.freestanding[2], "Always on")
                        ui.set(ref.freestanding[1], true)
                    else
                        ui.set(ref.freestanding[2], "On hotkey")
                        ui.set(ref.freestanding[1], false)
                    end
                    end)	


                     native_GetClientEntity = vtable_bind("client.dll", "VClientEntityList003", 3, "uintptr_t(__thiscall*)(void*, int)");
                    do_defensive = function ()
                        local player = entity.get_local_player( )
                    
                        if player == nil then
                            return
                        end
                    
                        local ptr = native_GetClientEntity(player);
                    
                        local m_flSimulationTime = entity.get_prop(player, "m_flSimulationTime");
                        local m_flOldSimulationTime = ffi.cast("float*", ptr + 0x26C)[0];
                    
                        if (m_flSimulationTime - m_flOldSimulationTime < 0) then
                            respectds = globals.tickcount() + toticks(.200);
                        end
                    end
                    client.set_event_callback( "net_update_start", function(  )
                        do_defensive()
                    end)
                local increment3 = 1
                    client.set_event_callback("setup_command", function(cmd)
                        
                        
                        local me = requirements.ent.get_local_player()
                        local m_fFlags = me:get_prop("m_fFlags")
                        local is_onground = bit.band(m_fFlags, 1) ~= 0

                        local nn_list = { -150, -90, 0, 90, 150 }
                        current_phase_yaw = current_phase_yaw + increment3
                        if current_phase_yaw > 5 then
                            current_phase_yaw = 1
                        end
                        if current_phase_yaw < 1 then
                            current_phase_yaw = 1
                        end
                        if misc.knife_isactive == false then
                            if is_onground then
                                ui.set(ref.pitch[1], "Down")
                            end
        -- Obținem tickcount-ul curent din globals
        local tickcount = globals.tickcount()

        -- Obținem tickbase-ul din entity-ul local (jucătorul curent)
        local local_player = entity.get_local_player()
        local current_tickbase = entity.get_prop(local_player, "m_nTickBase")

        -- Calculăm diferența dintre tickcount și tickbase
        L498 = function(L497)
            L70.current_cmd = cmd.command_number
        end;
        L501 = function()
            if cmdnbms == L70.current_cmd then
                cmdnbms = nil;
                local L500 = entity.get_prop(entity.get_local_player(), "m_nTickBase")
                
                L70.tickbase_max = math.max(L500, L70.tickbase_max or -1)

                tickbase_diff = L500 - (L70.current_cmd ~= nil or 1)
            end
            return tickbase_diff
        end;
        tickbase_diff = L501()
        L70.tickbase_diff = L501()
         lastTapTime = 0
 doubleTapThreshold = 0.3  -- Timpul maxim (în secunde) pentru un double tap
 doactiveaa = false

  myself  = entity.get_local_player()

  next_attack = entity.get_prop(myself, "m_flNextAttack") or 0
  next_primary_attack = entity.get_prop(entity.get_player_weapon(myself), "m_flNextPrimaryAttack") or 0
  dt_toggled = ref.dt[1] and ref.dt[2]
  dt_active = not(math.max(next_primary_attack, next_attack) > globals.curtime())




        -- Afișăm valoarea pentru debugging sau pentru utilizare ulterioară

                            if ui.get(menu.breaker_switch) then
                                invest = 0
                                if respectds == nil then invest = 0 else invest = respectds end
                                thanks3 = invest > globals.tickcount() %2
                                if dt_active and dt_toggled and thanks then
                                    breaker_active = true
                                    L70.yaw_increment_spin = L70.yaw_increment_spin + 35;
                                    if L70.yaw_increment_spin >= 1080 then
                                        L70.yaw_increment_spin = 0
                                    end;
                                    yaw_increment_spin5 = yaw_increment_spin5 + 19;
                                    if yaw_increment_spin5 >= 1080 then
                                        yaw_increment_spin5 = 0
                                    end; 

                                    ui.set(ref.pitch[1], "Custom")
                                    ui.set(ref.jitter[1], "Off")
                                    ui.set(ref.pitch[2], math.random(1,3) == 1 and -45 or 0)
                                    valuexxx = manipulation_tick(0,90,1,2)
                                    ui.set(ref.yaw[2], math.random(1,2) == 1 and valuexxx or -valuexxx)
                                else
                                    ui.set(ref.pitch[1], "Down")
                                end
                            end
                        end
                    end)
                    

                    client.set_event_callback("bullet_impact", function(e)
                    brute_impact(e)
                    end)

                    client.set_event_callback("aim_hit", function(e)
                    hitxx(e)
                    end)

                    client.set_event_callback("aim_miss", function(e)
                    missxx(e)
                    end)

                    client.set_event_callback("player_death", function(e)
                    brute_death(e)
                    if client.userid_to_entindex(e.userid) == entity.get_local_player() then
                        brute.reset()
                    end
                    end)

                    client.set_event_callback("client_disconnect", function()
                    brute.reset()
                    end)

                    client.set_event_callback("game_newmap", function()
                    brute.reset()
                    end)

                    client.set_event_callback("csaliename_disconnected", function()
                    brute.reset()
                    end)

                    local fakelag = ui.reference("AA", "Fake lag", "Limit")
                    local ground_ticks, end_time = 1, 0

                    

                    client.set_event_callback("pre_render", function()
                        if not entity.get_local_player() then return end
                    if contains(menu.animfucker, 'Static legs in air') then
                        entity.set_prop(entity.get_local_player(), "m_flPoseParameter", 1, 6)
                    end

                    if contains(menu.animfucker, 'Backward legs') then
                        entity.set_prop(entity.get_local_player(), "m_flPoseParameter", 1, 0) 
                        ui.set(legsmovement, "Always slide")
                    end

                    if contains(menu.animfucker, 'abi walk') then
                        ui.set(legsmovement, math.random(1,2) == 1 and "Always slide" or "Never slide")
                        entity.set_prop(entity.get_local_player(), "m_flPoseParameter", 1 - client.random_float(0.5, 1), 0)
                    end

                    if entity.is_alive(entity.get_local_player()) then

                        if contains(menu.animfucker, 'Zero pitch on land') then
                            local on_ground = bit.band(entity.get_prop(entity.get_local_player(), "m_fFlags"), 1)

                            if on_ground == 1 then
                                ground_ticks = ground_ticks + 1
                            else
                                ground_ticks = 0
                                end_time = globals.curtime() + 1
                            end

                            if ground_ticks > ui.get(fakelag)+1 and end_time > globals.curtime() then
                                entity.set_prop(entity.get_local_player(), "m_flPoseParameter", 0.5, 12)
                            end

                        end
                    end
                    if contains(menu.animfucker, "mj walk-air") then
                        local me = requirements.ent.get_local_player()
                    local m_fFlags = me:get_prop("m_fFlags")
                    local is_onground = bit.band(m_fFlags, 1) ~= 0
                    if not is_onground then
                        local my_animlayer = me:get_anim_overlay(6) -- MOVEMENT_MOVE
                        my_animlayer.weight = 1
                        entity.set_prop(entity.get_local_player(), "m_flPoseParameter", 0, 7)
            end
                    end
                    end)

                    local function doubletap_charged()
                        if not ui.get(ref.dt[1]) or not ui.get(ref.dt[2]) or ui.get(ref.fake_duck) then return false end
                        if not entity.is_alive(entity.get_local_player()) or entity.get_local_player() == nil then return end
                        local weapon = entity.get_prop(entity.get_local_player(), "m_hActiveWeapon")
                        if weapon == nil then return false end
                        local next_attack = entity.get_prop(entity.get_local_player(), "m_flNextAttack") + 0.25
                        local checkcheck = entity.get_prop(weapon, "m_flNextPrimaryAttack")
                        if checkcheck == nil then return end
                        local next_primary_attack = checkcheck + 0.5
                        if next_attack == nil or next_primary_attack == nil then return false end
                        return next_attack - globals.curtime() < 0 and next_primary_attack - globals.curtime() < 0
                    end


                    local function arrows()
                        local localp = entity.get_local_player()
                        local x, y = client.screen_size()

                        local me = entity.get_local_player()

                        if not entity.is_alive(me) then return end
                        local mr2,mg2,mb2,ma2 = ui.get(menu.main_clr)

                        local bodyyaw = entity.get_prop(localp, "m_flPoseParameter", 11) * 120 - 60

                        if ui.get(menu.arrows) then
                            renderer.text(x / 2 + 55, y / 2 -8, bodyyaw < -1 and mr2 or 255,bodyyaw < -1 and mg2 or 255,bodyyaw < -1 and mb2 or 255,255, "b", 0, "〉")
                            renderer.text(x / 2 - 55, y / 2 -8, bodyyaw > 1 and mr2 or 255,bodyyaw > 1 and mg2 or 255,bodyyaw > 1 and mb2 or 255,255, "b", 0, "〈")
                        end
                    end


                    local function color(desync)
                        local r, g, b = 255, 0, 0
                        if desync < 0 then
                            r, g = 0, 255
                        end
                        return r, g, b
                    end
                    
                    local function gradient_text(rr, gg, bb, aa, rrr, ggg, bbb, aaa, text)
                        local r1, g1, b1, a1 = rr, gg, bb, aa
                        local r2, g2, b2, a2 = rrr, ggg, bbb, aaa
                        local highlight_fraction = (globals.realtime() / 2 % 1.2 * speed) - 1.2
                        local output = ""
                        for idx = 1, #text do
                            local character = text:sub(idx, idx)
                            local character_fraction = idx / #text
                            local r, g, b, a = r1, g1, b1, a1
                            local highlight_delta = (character_fraction - highlight_fraction)
                            if highlight_delta >= 0 and highlight_delta <= 1.4 then
                                if highlight_delta > 0.7 then
                                    highlight_delta = 1.4 - highlight_delta
                                end
                                local r_fraction, g_fraction, b_fraction, a_fraction = r2 - r, g2 - g, b2 - b
                                r = r + r_fraction * highlight_delta / 0.8
                                g = g + g_fraction * highlight_delta / 0.8
                                b = b + b_fraction * highlight_delta / 0.8
                            end
                            output = output .. ('\a%02x%02x%02x%02x%s'):format(r, g, b, 255, text:sub(idx, idx))
                        end
                        return output
                    end
                    
                    
                      
                      
                      
                    local fs_a = 100
                    local os_a = 100
                    local dt_a = 100
                    local add_x = 0
                    local add_x1 = 0
                    local function animation(check, name, value, speed)
                        if check then
                            return name + (value - name) * globals.frametime() * speed
                        else
                            return name - (value + name) * globals.frametime() * speed

                        end
                    end
                    
                    
                    
                    
                      
                      
                      
                      
                    client.set_event_callback("paint_ui", function()

                    ui.set_visible(ref.enablexxx, false)
                    SetTableVisibility({ref.pitch[1], ref.pitch[2], ref.yaw[1], ref.yaw[2], ref.yaw_base, ref.byaw[1], ref.byaw[2], ref.jitter[1], ref.jitter[2], ref.fby, ref.edge, ref.freestanding[1], ref.freestanding[2], ref.roll}, false)
                    if ui.get(menu.retard) == "\a878787ffhome" then
                    SetTableVisibility({menu.discords, menu.hometext, menu.hometext2}, true)
                    else
                    SetTableVisibility({menu.discords, menu.hometext, menu.hometext2}, false)
                    end
                    if ui.get(menu.retard) == "\a878787ffvisuals" then
                    SetTableVisibility({menu.main_clr,menu.crossindicators, menu.logsss, menu.cdzenable, menu.localanimz, menu.watermarkenable, menu.defensiveindicator, menu.main_clr2, menu.indclrtext, menu.dmgind, menu.killind, menu.dmgindcol, menu.ctagenable}, true)
                    ui.set_visible(menu.notifys, (true and ui.get(menu.logsss)))
                    ui.set_visible(menu.consolelogs, (true and ui.get(menu.logsss)))
                    ui.set_visible(menu.animfucker, (true and ui.get(menu.localanimz)))
                    ui.set_visible(menu.cdz_custom, (true and ui.get(menu.cdzenable)))
                    SetTableVisibility({menu.arrows}, true)
                    else
                    SetTableVisibility({menu.main_clr,menu.crossindicators, menu.logsss, menu.cdzenable, menu.localanimz, menu.watermarkenable, menu.defensiveindicator, menu.main_clr2, menu.cdz_custom, menu.arrows, menu.indclrtext, menu.notifys, menu.ctagenable, menu.consolelogs, menu.dmgind, menu.killind, menu.dmgindcol, menu.animfucker}, false)
                    end
                    if ui.get(menu.retard) == "\a878787ffanti-aim" then
                
                    SetTableVisibility({menu.subtab_antiaim, menu.presets}, true)
                    SetTableVisibility({menu.presets}, true)
                    SetTableVisibility({ export_btn, import_btn, load_aa, save_aa}, ui.get(menu.subtab_antiaim) ~= "Keybinds" and ui.get(menu.presets) == "Builder")
                    SetTableVisibility({ menu.fs_toggle, menu.checkbox,menu.checkbox2, menu.lagcomp}, ui.get(menu.subtab_antiaim) == "settings")
                    SetTableVisibility({menu.checkbox,menu.checkbox2, menu.breaker_switch, menu.knife_hotkey}, ui.get(menu.subtab_antiaim) == "settings")
                    SetTableVisibility({menu.knife_distance}, ui.get(menu.knife_hotkey) and ui.get(menu.subtab_antiaim) == "settings")
                    else
                    SetTableVisibility({menu.subtab_antiaim, menu.presets, export_btn, import_btn, load_aa, save_aa, menu.fs_toggle, menu.checkbox,menu.checkbox2, menu.breaker_switch, menu.knife_hotkey, menu.knife_distance, menu.lagcomp}, false)
                    end
                    if ui.get(menu.retard) == "Misc" then
                    SetTableVisibility({menu.exploits.yaw_1st, menu.exploits.yaw_2nd, menu.exploits.pitch, menu.exploits.bodyyaw}, false)
                    else
                    SetTableVisibility({menu.exploits.yaw_1st, menu.exploits.yaw_2nd, menu.exploits.pitch, menu.exploits.bodyyaw}, false)
                    end

                    if ui.get(menu.retard) == "\a878787ffanti-aim" and ui.get(menu.subtab_antiaim) == "Keybinds"then
                        SetTableVisibility({ menu.presets}, false)
                    else

                    end

                    if ui.get(menu.retard) == "\a878787ffanti-aim" and ui.get(menu.subtab_antiaim) == "settings"then
                        SetTableVisibility({ menu.presets, import_btn,export_btn}, false)
                    else

                    end

                    if ui.get(menu.retard) == "\a878787ffanti-aim" and ui.get(menu.subtab_antiaim) == "phases"then
                        SetTableVisibility({ menu.presets}, false)
                        for i = 1, 5 do
                
                            ui.set_visible(antibrute[i].yaw_mode, ui.get(menu.bruteforce.phases) == brutenumtotext[i] and ui.get(menu.contains) == "Custom" and ui.get(menu.antibrute_switch))
                            ui.set_visible(antibrute[i].yaw_default, ui.get(menu.bruteforce.phases) == brutenumtotext[i] and ui.get(antibrute[i].yaw_mode) == "Default" and ui.get(menu.contains) == "Custom" and ui.get(menu.antibrute_switch))
                            ui.set_visible(antibrute[i].yaw_superior, ui.get(menu.bruteforce.phases) == brutenumtotext[i] and ui.get(antibrute[i].yaw_mode) == "Superior" and ui.get(menu.contains) == "Custom" and ui.get(menu.antibrute_switch))
                            ui.set_visible(antibrute[i].fiveway_yaw_add, ui.get(menu.bruteforce.phases) == brutenumtotext[i] and ui.get(antibrute[i].yaw_mode) == "3 Way" and ui.get(menu.contains) == "Custom" and ui.get(menu.antibrute_switch))
                            ui.set_visible(antibrute[i].lolway_yaw_add, ui.get(menu.bruteforce.phases) == brutenumtotext[i] and ui.get(antibrute[i].jitter) == "lol" and ui.get(antibrute[i].jitter_mode) == "normal" and ui.get(menu.antibrute_switch))
                            ui.set_visible(antibrute[i].threeway_yaw_add, ui.get(menu.bruteforce.phases) == brutenumtotext[i] and ui.get(antibrute[i].yaw_mode) == "5 Way" and ui.get(menu.contains) == "Custom" and ui.get(menu.antibrute_switch))
                            ui.set_visible(antibrute[i].yaw_left, ui.get(menu.bruteforce.phases) == brutenumtotext[i] and ui.get(antibrute[i].yaw_mode) == "sway" and ui.get(menu.contains) == "Custom" and ui.get(menu.antibrute_switch))
                            ui.set_visible(antibrute[i].yaw_right, ui.get(menu.bruteforce.phases) == brutenumtotext[i] and ui.get(antibrute[i].yaw_mode) == "sway"and ui.get(menu.contains) == "Custom" and ui.get(menu.antibrute_switch)) 
                            ui.set_visible(antibrute[i].body_yaw, ui.get(menu.bruteforce.phases) == brutenumtotext[i] and ui.get(menu.contains) == "Custom" and ui.get(menu.antibrute_switch))
                            ui.set_visible(antibrute[i].body_yaw_mode, ui.get(menu.bruteforce.phases) == brutenumtotext[i] and ui.get(antibrute[i].body_yaw) ~= "Off" and ui.get(menu.contains) == "Custom" and ui.get(menu.antibrute_switch))
                            ui.set_visible(antibrute[i].body_yaw_val, ui.get(menu.bruteforce.phases) == brutenumtotext[i] and ui.get(antibrute[i].body_yaw_mode) ~= "sway" and ui.get(menu.contains) == "Custom" and ui.get(antibrute[i].body_yaw) ~= "Off" and ui.get(menu.antibrute_switch))
                            ui.set_visible(antibrute[i].left_byaw_val, ui.get(menu.bruteforce.phases) == brutenumtotext[i] and ui.get(antibrute[i].body_yaw_mode) == "sway" and ui.get(menu.contains) == "Custom" and ui.get(menu.antibrute_switch))
                            ui.set_visible(antibrute[i].right_byaw_val, ui.get(menu.bruteforce.phases) == brutenumtotext[i] and ui.get(antibrute[i].body_yaw_mode) == "sway" and ui.get(menu.contains) == "Custom" and ui.get(menu.antibrute_switch))
                            ui.set_visible(antibrute[i].jitter, ui.get(menu.bruteforce.phases) == brutenumtotext[i] and ui.get(menu.contains) == "Custom" and ui.get(menu.antibrute_switch))
                            ui.set_visible(antibrute[i].jitter_mode, ui.get(menu.bruteforce.phases) == brutenumtotext[i] and ui.get(antibrute[i].jitter) ~= "Off" and ui.get(menu.contains) == "Custom" and ui.get(menu.antibrute_switch))
                            ui.set_visible(antibrute[i].jitter_val, ui.get(menu.bruteforce.phases) == brutenumtotext[i] and ui.get(antibrute[i].jitter_mode) ~= "sway" and ui.get(menu.contains) == "Custom" and ui.get(antibrute[i].jitter) ~= "5 Way" and ui.get(antibrute[i].jitter) ~= "Off" and ui.get(antibrute[i].jitter) ~= "lol" and ui.get(menu.antibrute_switch))
                            ui.set_visible(antibrute[i].left_jitter_val, ui.get(menu.bruteforce.phases) == brutenumtotext[i] and ui.get(antibrute[i].jitter_mode) == "sway" and ui.get(menu.contains) == "Custom" and ui.get(menu.antibrute_switch))
                            ui.set_visible(antibrute[i].right_jitter_val, ui.get(menu.bruteforce.phases) == brutenumtotext[i] and ui.get(antibrute[i].jitter_mode) == "sway" and ui.get(menu.contains) == "Custom" and ui.get(menu.antibrute_switch))
                            
                            ui.set_visible(antibrute[i].threeway_jitter_val, ui.get(menu.bruteforce.phases) == brutenumtotext[i] and ui.get(antibrute[i].jitter) == "5 Way" and ui.get(antibrute[i].jitter_mode) ~= "sway" and ui.get(menu.contains) == "Custom" and ui.get(menu.antibrute_switch))
                    
                        end
                        SetTableVisibility({import_antibrute, export_antibrute, load_antibrute, save_antibrute, menu.antibrute_switch}, true)
                        SetTableVisibility({import_antibrute, export_antibrute, load_antibrute, save_antibrute}, ui.get(menu.antibrute_switch) and ui.get(menu.contains) == "Custom")
                        SetTableVisibility({menu.contains}, ui.get(menu.antibrute_switch))
                        SetTableVisibility({import_btn,export_btn}, false)
                        SetTableVisibility({menu.bruteforce.phases}, ui.get(menu.antibrute_switch) and ui.get(menu.contains) == "Custom")
                    else
                        SetTableVisibility({menu.contains, import_antibrute, export_antibrute, load_antibrute, save_antibrute, menu.antibrute_switch, menu.bruteforce.phases}, false)
                        for i = 1, 5 do
                            ui.set_visible(antibrute[i].yaw_left, false)
                            ui.set_visible(antibrute[i].yaw_mode, false)
                            ui.set_visible(antibrute[i].yaw_default, false)
                            ui.set_visible(antibrute[i].yaw_superior, false)
                            ui.set_visible(antibrute[i].threeway_yaw_add, false)
                            ui.set_visible(antibrute[i].yaw_right, false)
                            ui.set_visible(antibrute[i].body_yaw, false)
                            ui.set_visible(antibrute[i].body_yaw_val, false)
                            ui.set_visible(antibrute[i].lolway_yaw_add, false)
                            ui.set_visible(antibrute[i].left_byaw_val, false)
                            ui.set_visible(antibrute[i].right_byaw_val, false)
                            ui.set_visible(antibrute[i].jitter, false)
                            ui.set_visible(antibrute[i].jitter_val, false)
                            ui.set_visible(antibrute[i].left_jitter_val, false)
                            ui.set_visible(antibrute[i].right_jitter_val, false)
                            ui.set_visible(antibrute[i].fiveway_yaw_add, false)
                            ui.set_visible(antibrute[i].threeway_jitter_val, false)
                            ui.set_visible(antibrute[i].jitter_mode, false)
                            ui.set_visible(antibrute[i].body_yaw_mode, false)
                        end
                    end

                    if ui.get(menu.retard) == "\a878787ffanti-aim" and ui.get(menu.subtab_antiaim) == "main" and (ui.get(menu.presets) == "Dynamic" or ui.get(menu.presets) == "Three-heads" or ui.get(menu.presets) == "Defensive-jitter") then
                        ui.set_visible(menu.cannotview, true)
                    else
                        ui.set_visible(menu.cannotview, false)
                    end
                
                    
                    end)
                
                    client.set_event_callback("shutdown", function()
                    SetTableVisibility({ref.pitch[1], ref.yaw[1], ref.yaw[2], ref.yaw_base, ref.byaw[1], ref.byaw[2], ref.jitter[1], ref.jitter[2], ref.fby, ref.edge, ref.freestanding[1], ref.freestanding[2], ref.roll}, true)
                    database.write("db1", data)
                    end)
                    
                      
                      
                      

                      

                      




                
                    
                    local function animation(check, name, value, speed)
                        if check then
                            return name + (value - name) * globals.frametime() * speed
                        else
                            return name - (value + name) * globals.frametime() * speed

                        end
                    end


                    local lolpos1 = 0
                    local lolpos2 = 0
                    local xpos = 0
                    local xpos2 = 0
                    local xpos3 = 0
                    local xpos4 = 0
                    local xpos5 = 0
                    local indi_anim = 0
                    local flag = "c-"
                    local deez = 0
                    local fs_a, body_a, sp_a = 150, 150, 150
                    local ypos  = 0
                    local alpha1 = 0
                    local dt_r, dt_g, dt_b, dt_a = 0, 0, 0, 0
                    local value2 = 0
                    local hitler = {}

                    hitler.lerp = function(start, vend, time)
                            return start + (vend - start) * time
                    end
                    function RoundedRectFancy(x, y, w, h, r, col)
                        solus_render.container2(x, y, w, h, r, col[1], col[2], col[3], col[4])
                    end
                    client.set_event_callback("paint", function()
                    arrows()
                    --state_panel()
                    

                

                    local lp = entity.get_local_player()
                    local bodyyaw = entity.get_prop(entity.get_local_player(), "m_flPoseParameter", 11) * 120 - 60
                    local side = bodyyaw > 0 and 1 or -1		
                    local sr, sg, sb, sa = (side == 1 and 142 or 255), (side == 1 and 165 or 255), (side == 1 and 229 or 255), 255
                    local lr, lg, lb, la = (side == 1 and 255 or 142), (side == 1 and 255 or 165), (side == 1 and 255 or 229), 255
                     bgColor        = {22, 23, 25, 240}       -- background
                     headerColor    = {38, 45, 55, 255}       -- header
                     accentColor    = {91, 105, 135, 255}     -- accent line
                     buttonColor    = {34, 36, 40, 220}       -- button
                     shadowColor    = {0, 0, 0, 100}          -- subtle shadow
                     x, y = client.screen_size()
                    local screenX, screenY = client.screen_size()
                    local uiX, uiY = screenX / 2 - 150, screenY / 2 - 100
                    local uiW, uiH = 300, 200
                    local borderRadius = 12
                    local me = entity.get_local_player()

                    local scoped = entity.get_prop(me, 'm_bIsScoped')
                    local me = entity.get_local_player()
                    local wpn = entity.get_player_weapon(me)

                    local scope_level = entity.get_prop(wpn, 'm_zoomLevel')
                    local scoped = entity.get_prop(me, 'm_bIsScoped') == 1
                    local resume_zoom = entity.get_prop(me, 'm_bResumeZoom') == 1

                    local is_valid = entity.is_alive(me) and wpn ~= nil and scope_level ~= nil
                    local act = is_valid and scope_level > 0 and scoped and not resume_zoom
                    if not entity.is_alive(me) then return end
                    if me == nil then return end
                    if act then

                        flag = "-"
                    else
                        flag = "c-"
                    end
                     myself  = entity.get_local_player()

                     next_attack = entity.get_prop(myself, "m_flNextAttack") or 0
                     next_primary_attack = entity.get_prop(entity.get_player_weapon(myself), "m_flNextPrimaryAttack") or 0
                     dt_toggled = ref.dt[1] and ref.dt[2]
                     dt_active = not(math.max(next_primary_attack, next_attack) > globals.curtime())
                    local r,g,b,a = ui.get(menu.main_clr)
                    local r2,g2,b2,a2 = 255,35,0,a
                    local dt_r = animations.anim_new('dt_r', (dt_active) and r or 255)
                    local dt_g = animations.anim_new('dt_g', (dt_active) and g or 0)
                    local dt_b = animations.anim_new('dt_b', (dt_active) and b or 0)
                    


                    local hsax = animations.anim_new('a2', (ui.get(ref.os[2])) and 255 or 0)
                    local dtax = 255
                    dtaxzz = animations.anim_new('ax444', (ui.get(ref.dt[2])) and 11 or 0)
                    dtname = "DOUBLETAP"
                    local deez2 = animations.anim_new('asdasdddxxxd', (ui.get(ref.dt[2]) or ui.get(ref.os[2])) and -11 or 0)
                    local alpha = animations.anim_new('asdasdddd', ui.get(menu.crossindicators)   and 1 or 0)
                    ca = 255
                    ca = dt_r
                    ca2 = dt_g
                    ca3 = dt_b
                    name = dtname:sub(1, dtaxzz)
                    expalpha = dtax
                    if ui.get(ref.dt[2]) and ui.get(ref.os[2]) then
                        name = dt_active and dtname:sub(1, dtaxzz) or text_fade_animation(3, 255,0,0,255, dtname:sub(1, dtaxzz))
                        expalpha = dtax
                        ca = dt_r
                        ca2 = dt_g
                        ca3 = dt_b
                    elseif ui.get(ref.dt[2]) and not ui.get(ref.os[2]) then
                        name = dt_active and dtname:sub(1, dtaxzz) or text_fade_animation(3, 255,0,0,255, dtname:sub(1, dtaxzz))
                        expalpha = dtax
                        ca = dt_r
                        ca2 = dt_g
                        ca3 = dt_b
                    elseif not ui.get(ref.dt[2]) and  ui.get(ref.os[2]) then
                        name = "OS"
                        expalpha = hsax
                        ca = 255
                        ca2 = 255
                        ca3 = 255
                    end
                    local aA = {
                        {255,255,255,255*alpha},
                        {r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * globals.curtime()/4 + 75 / 30))*alpha},
                        {r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * globals.curtime()/4 + 70 / 30))*alpha},
                        {r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * globals.curtime()/4 + 65 / 30))*alpha},
                        {r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * globals.curtime()/4 + 60 / 30))*alpha},
                        {r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * globals.curtime()/4 + 55 / 30))*alpha},
                        {255,255,255,255*alpha},
                        {r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * globals.curtime()/4 + 45 / 30))*alpha},
                        {r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * globals.curtime()/4 + 40 / 30))*alpha},
                        {r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * globals.curtime()/4 + 35 / 30))*alpha},
                        {r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * globals.curtime()/4 + 30 / 30))*alpha},
                        {r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * globals.curtime()/4 + 25 / 30))*alpha},
                        {r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * globals.curtime()/4 + 20 / 30))*alpha},
                        {r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * globals.curtime()/4 + 15 / 30))*alpha},
                        {r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * globals.curtime()/4 + 10 / 30))*alpha},
                        {r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * globals.curtime()/4 + 5 / 30))*alpha},
                        {r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * globals.curtime()/4 + 0 / 30))*alpha}
                    }
                    vertext = "g u c c i"
                    y = y+10
                    local measure = renderer.measure_text("b", vertext:upper())
                    yaw_indc = ui.get(newaa.calc_yaw):upper()
                    measure_indc, measure_indcy = renderer.measure_text("-s", "*"..yaw_indc.."*")

                    lr,  lg, lb, la = 93,89,105,255
                    la = la/255
                    if ui.get(menu.crossindicators) then
                        
                        -- renderer.text(x/2-measure/2+aaxs, y/2+2, r, g, b, 200-math.abs(1 * math.cos(2 * math.pi * (globals.curtime() /2)*2 )) * 100, 's', 0,  "★")
                        -- renderer.text(x/2+measure/2-4+aaxs, y/2+10, lr, lg, lb, 255 - math.abs(1 * math.cos(2 * math.pi * (globals.curtime() /2)*4 )) * 100, 's', 0,  "★")
                        renderer.text(x/2-measure_indc/2, y/2+19, 255,255,255, 125, '-s', 0,  "*"..yaw_indc.."*")
                        renderer.text(x/2-measure/2, y/2+28, r,g,b, 255, 'b', 0,  vertext:upper())

                        -- dt settings
                        indicatoranim_dtno = animations.anim_new('indicatoranim_dtx', not dt_active and ui.get(ref.dt[2]) and 1 or 0)
                        indicatoranim_dtyes = animations.anim_new('indicatoranim_dtxx', dt_active and ui.get(ref.dt[2]) and 1 or 0)
                        justdt = animations.anim_new('indicatoranim_dtxxx', ui.get(ref.dt[2]) and 1 or 0)
                        nodt = "recharging"
                        yesdt = "ready"
                        valet2 = text_fade_animation(1, 120, 245, 66,255, yesdt:sub(1, 6*indicatoranim_dtyes))
                        valet = text_fade_animation(3, 255,0,0,255, nodt:sub(1, 11*indicatoranim_dtno))
                        ivalet = nodt:sub(1, 11*indicatoranim_dtno)
                        ivalet2 = yesdt:sub(1, 6*indicatoranim_dtyes)
                        -- dtstate = ""
                        -- if indicatoranim_dtno > 0 then
                        --     dtstate = valet
                        -- elseif indicatoranim_dtyes > 0 then
                        --     dtstate = valet2
                        -- end
                        dtstate = "\a"..RGBAtoHEX(120, 245, 66,255*justdt)..""..valet2..""..valet
                        dtstate2 = "\a"..RGBAtoHEX(255,255,255,255*justdt)..""..ivalet2.."\a"..RGBAtoHEX(150, 150, 150,255*justdt)..""..ivalet
                        dt_n = "\a"..RGBAtoHEX(255,255,255,255*justdt).."dt "..dtstate
                        dt_n2 = "\a"..RGBAtoHEX(255,255,255,255*justdt).."dt "..dtstate2
                        -- yes
                        measure_indc, measure_indcy = renderer.measure_text("-s", dt_n:upper())
                        renderer.text(x/2-measure_indc/2, y/2+30+measure_indcy, 194, 194, 194, 255*justdt, '-s', 0,  dt_n2:upper())
                        renderer.text(x/2-measure_indc/2, y/2+30+measure_indcy, 255-135*indicatoranim_dtyes,255-10*indicatoranim_dtyes,255-195*indicatoranim_dtyes, (125+135*indicatoranim_dtyes)*justdt, '-s', 0,  dt_n:upper())

                        solus_render.container2(uiX + 2, uiY + 2, uiW, uiH, borderRadius, shadowColor)

                        -- Main background
                        solus_render.container2(uiX, uiY, uiW, uiH, borderRadius, bgColor)
                    
                        -- Header bar
                        solus_render.container2(uiX, uiY, uiW, 32, borderRadius, headerColor)
                    
                        -- Accent underline
                        solus_render.container2(uiX + 12, uiY + 32, uiW - 24, 1, 0, accentColor)
                    
                        -- Button (no label)
                        local btnX, btnY, btnW, btnH = uiX + 20, uiY + 60, uiW - 40, 36
                        solus_render.container2(btnX, btnY, btnW, btnH, 8, buttonColor)
                    end
                    local r,g,b,a = ui.get(menu.main_clr)


                        -- Get the center of the screen
                        local screen_width, screen_height = client.screen_size()
                        local center_x, center_y = screen_width / 2, screen_height / 2
                      
                        -- Get the desync value
                        local desync = math.abs(requirements.antiaim_funcs.get_body_yaw(2))
                      
                        -- Round up desync to an integer value
                        desync = math.ceil(desync)
                      
                        -- Set the text color based on the desync value
                        local text_color = {255, 255, 255}
                    
                      
                        -- Calculate the gradient color based on the desync value
                        local gradient_color = {255, 255, 255}
                      
                      
                        -- Calculate the size and position of the indicator based on screen size
                        local text = "gucci " .. requirements.obex_data.build:upper()
                        local text_width, text_height = renderer.measure_text(requirements.obex_data.build:upper(), "gucci ")

                        local indicator_width = text_width + 25
                        local indicator_height = screen_height * 0.006
                      
                        local scoped = entity.get_prop(me, 'm_bIsScoped')
                        local me = entity.get_local_player()
                        local wpn = entity.get_player_weapon(me)

                        local scope_level = entity.get_prop(wpn, 'm_zoomLevel')
                        local scoped = entity.get_prop(me, 'm_bIsScoped') == 1
                        local resume_zoom = entity.get_prop(me, 'm_bResumeZoom') == 1

                        local is_valid = entity.is_alive(me) and wpn ~= nil and scope_level ~= nil
                        local act = is_valid and scope_level > 0 and scoped and not resume_zoom

                    end)

                    local import_cfg = function(to_import)
                    pcall(function()
                    local num_tbl = {}
                    local settings = json.parse(requirements.base64.decode(clipboard_import(), base64))

                    for key, value in pairs(settings) do
                        if type(value) == 'table' then
                            for k, v in pairs(value) do
                                if type(k) == 'number' then
                                    table.insert(num_tbl, v)
                                    ui.set(newaa[key], num_tbl)
                                else
                                    ui.set(newaa[key][k], v)
                                end
                            end
                        else
                            ui.set(newaa[key], value)
                        end
                    end



                    table.insert(render.notifications.table_text, {
                        text = text_fade_animation(9,r,g,b,a, ' Imported anti-aim settings'),
                        timer = globals.realtime(),
                    
                        smooth_y = render.notifications.c_var.screen[2] + 100,
                        alpha = 0,
                        alpha2 = 0,
                        alpha3 = 0,
                    
                    
                        box_left = 0,
                        box_right = 0,
                    
                        box_left_1 = 0,
                        box_right_1 = 0
                    }) 
                    
                    end)
                end

                local export_cfg = function()
                local settings = {}

                pcall(function()
                for key, value in pairs(newaa) do
                    if value then
                        settings[key] = {}

                        if type(value) == 'table' then
                            for k, v in pairs(value) do
                                settings[key][k] = ui.get(v)
                            end
                        else
                            settings[key] = ui.get(value)
                        end
                    end
                end
                local r,g,b,a = ui.get(menu.main_clr)

                clipboard_export(requirements.base64.encode(json.stringify(settings), base64))
                table.insert(render.notifications.table_text, {
                    text = text_fade_animation(9,r,g,b,a, ' Exported anti-aim config to clipboard'),
                    timer = globals.realtime(),
                
                    smooth_y = render.notifications.c_var.screen[2] + 100,
                    alpha = 0,
                    alpha2 = 0,
                    alpha3 = 0,
                
                
                    box_left = 0,
                    box_right = 0,
                
                    box_left_1 = 0,
                    box_right_1 = 0
                }) 
                
                end)
            end

                local export_cfg2 = function()
                    local settings = {}
    
                    pcall(function()
                    for key, value in pairs(newaa) do
                        if value then
                            settings[key] = {}
    
                            if type(value) == 'table' then
                                for k, v in pairs(value) do
                                    settings[key][k] = ui.get(v)
                                end
                            else
                                settings[key] = ui.get(value)
                            end
                        end
                    end
                    local r,g,b,a = ui.get(menu.main_clr)
    
                    data.aasaved = requirements.base64.encode(json.stringify(settings), base64)
                    table.insert(render.notifications.table_text, {
                        text = text_fade_animation(9,r,g,b,a, ' Saved anti-aim config '),
                        timer = globals.realtime(),
                    
                        smooth_y = render.notifications.c_var.screen[2] + 100,
                        alpha = 0,
                        alpha2 = 0,
                        alpha3 = 0,
                    
                    
                        box_left = 0,
                        box_right = 0,
                    
                        box_left_1 = 0,
                        box_right_1 = 0
                    }) 
                    
                    end)
            end
            local import_cfg2 = function(to_import)
                pcall(function()
                local num_tbl = {}
                local settings = json.parse(requirements.base64.decode(data.aasaved, base64))

                for key, value in pairs(settings) do
                    if type(value) == 'table' then
                        for k, v in pairs(value) do
                            if type(k) == 'number' then
                                table.insert(num_tbl, v)
                                ui.set(newaa[key], num_tbl)
                            else
                                ui.set(newaa[key][k], v)
                            end
                        end
                    else
                        ui.set(newaa[key], value)
                    end
                end



                table.insert(render.notifications.table_text, {
                    text = text_fade_animation(9,r,g,b,a, ' Loaded anti-aim settings'),
                    timer = globals.realtime(),
                
                    smooth_y = render.notifications.c_var.screen[2] + 100,
                    alpha = 0,
                    alpha2 = 0,
                    alpha3 = 0,
                
                
                    box_left = 0,
                    box_right = 0,
                
                    box_left_1 = 0,
                    box_right_1 = 0
                }) 
                
                end)
            end
            import_btn = ui.new_button("AA", "Anti-aimbot angles", "Import settings", import_cfg)
            export_btn = ui.new_button("AA", "Anti-aimbot angles", "Export settings", export_cfg)
            import_antibrute = ui.new_button("AA", "Anti-aimbot angles", "Import phases", import_antibrute)
            export_antibrute = ui.new_button("AA", "Anti-aimbot angles", "Export phases", export_antibrute)
            save_antibrute = ui.new_button("AA", "Anti-aimbot angles", "Save phases", save_antibrute)
            load_antibrute = ui.new_button("AA", "Anti-aimbot angles", "Load phases", load_antibrute)
            save_aa = ui.new_button("AA", "Anti-aimbot angles", "Save anti-aim settings", export_cfg2)
            load_aa = ui.new_button("AA", "Anti-aimbot angles", "Load anti-aim settings", import_cfg2)


            client.set_event_callback("paint_ui",noti)
