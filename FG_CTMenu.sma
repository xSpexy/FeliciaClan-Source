/* FeliciaClan CT 2.1.3-FIX: v1.21 reference + retained additions. */
#include <amxmodx>
#include <amxmisc>
#include <reapi>
#include <fakemeta>
#include <engine>
#include <hamsandwich>
#include <nvault>

/*************** Natives ****************/


//*************************** DUZENLENECEKLER ******************************//

new const serverTAG[] = "FeliciaClan";

#define semiclip_cvaraktif

/*
amx_cvar semiclip ayari olmayan semiclip eklentisi kullaniyorsaniz veya 
paneldeki semiclip eklentisini kullaniyorsaniz #define 'nin basina // ekleyin !

Yani >   //#define semiclip_cvaraktif
*/

// MUZIKLER //
new ctmenu_koruma[128] = "ctmenum/omrum.wav";
new ctmenu_ayarlarisifirla[128] = "ctmenum/ayarsifirla_new.wav";
new ctmenu_godmode[128] = "ctmenum/godmode_aktif.wav";
new ctmenu_bildirim[128] = "ctmenum/bildirim.wav";
new ctmenu_freeze_don[128] = "ctmenum/don_new.wav";
new ctmenu_duzff[128] = "ctmenum/duzff.wav";
new ctmenu_silahliff[128] = "ctmenum/silahliff.wav";
new ctmenu_sparta[128] = "ctmenum/sparta_new.wav";
new ctmenu_gomulunce[128] = "ctmenum/gomulunce.wav";
new ctmenu_onsaniye[128] = "ctmenum/onsaniye.wav";
new ctmenu_sirala[128] = "ctmenum/pu_new.wav";
new ctmenu_hucre[128] = "ctmenum/acarmisinkapiyi.wav";
new ctmenu_pubg[128] = "ctmenum/pubg.wav";

new HardKomutSounds[][128] =
{
    "ctmenum/HardKomut1.wav", // 0
    "ctmenum/HardKomut2.wav", // 1
}

new SquidSounds[][128] =
{
    "ctmenum/tp_squidgamenormal.wav", // 0
    "ctmenum/tp_squidgameorta.wav", // 1
    "ctmenum/tp_squidgamehizli.wav", // 2
    "ctmenum/tp_squidgamecokhizli.wav" // 3
}

#if defined semiclip_cvaraktif
    new ctmenu_sikistirma[128] = "ctmenum/sikistirma.wav";
    new semiclip, s_sure, bool:s_player[MAX_CLIENTS+1], bool:s_gerisayim;
#endif

new const ctmenu_rocketfire[] = "weapons/rocketfire1.wav";
new const ctmenu_rocket1[] = "weapons/rocket1.wav";
//---------//

new const defaultHava[] = "l"; 	// Default Hava Ayari
new const aksamHava[] = "d"; 	// Aksam Hava Ayari

enum (+= 100)
{ 
    task_HUD = 1337, task_SIKISTIRMA, task_ROCKET, task_FREEZEOYUNU, task_SURELIGOM, task_SURELIDON,
    task_KORUMA, task_ENFEKSIYON, task_SIRALACIZGI, task_GOZUMEGOZUKME, task_HAYALET, task_GOMULENOLUR
};

new godKontrol,hardkomutKontrol, sureligomSayac, surelidondurSayac, rocketSayac, oylamaSayac, sonOlen, siralamaEksen, siralamaNum, kayitliSayi, yarismaKontrol;

new bool:elbasiKontrol, bool:tamgomKontrol, bool:aref, bool:ffKontrol, bool:takimKontrol, bool:catismaKontrol, bool:hpKontrol, bool:noclipKontrol, bool:uckezgomKontrol, 
bool:freezeKontrol, bool:enfeksiyonKontrol, bool:sarkacKontrol, bool:yakalaKontrol, bool:sayiyibilenKontrol, bool:vatanhainiKontrol;

new Takim[MAX_CLIENTS+1], yardimSayac[MAX_CLIENTS+1], yarismaSayac[MAX_CLIENTS+1];

new bool:g_unAmmo[MAX_CLIENTS+1], bool:g_oylama[MAX_CLIENTS+1], bool:g_hasarAzalt[MAX_CLIENTS+1], bool:g_hasarKatla[MAX_CLIENTS+1],
bool:g_hud[MAX_CLIENTS+1], bool:g_sirala[MAX_CLIENTS+1], bool:g_infect[MAX_CLIENTS+1], bool:g_sarkac[MAX_CLIENTS+1], bool:g_koruma[MAX_CLIENTS+1], 
bool:g_silahKontrol[MAX_CLIENTS+1], bool:g_hiz[MAX_CLIENTS+1], bool:g_hain[MAX_CLIENTS+1], bool:g_glow[MAX_CLIENTS+1];

new mp_freeforall, sv_gravity, bh_enabled, sv_parachute, mp_forcecamera, sv_airaccelerate, mp_infinite_ammo, bool:takimHasar, bool:silahliGom, bool:m249Active, bool:fallDamageCT,
HookChain:h_Dmg, HookChain:h_rSpeed, korumaVoting[5], g_sprs[5], Float:deathOrigin[MAX_CLIENTS+1][3], ScreenFade, DeathMsg, SetFOV, Damage,Float:cvar[2];

new SuankiRound, SiradakiAlinacakEl[2], bool:DahaOnceAldi[2] ,Deger[2];





























































































//Sarkac









//































//












public oyuncuOldur(id) if(is_user_alive(id)) user_kill(id, 1);

#if defined semiclip_cvaraktif 



#endif


























































































new const weapons[][] = { "weapon_usp", "weapon_glock18", "weapon_deagle", "weapon_p228", "weapon_elite", "weapon_fiveseven", "weapon_m3", "weapon_xm1014", "weapon_tmp", "weapon_mac10", "weapon_mp5navy", "weapon_p90", "weapon_ump45", "weapon_famas", "weapon_galil", "weapon_ak47", "weapon_m4a1", "weapon_sg552", "weapon_aug", "weapon_scout", "weapon_sg550", "weapon_awp", "weapon_g3sg1", "weapon_m249" };
















public eksilt() oylamaSayac--;







































//32.03 72.03








































public eskibas() 
    elbasiKontrol=false;




























new const Float:size[][3] = { 
    {0.0, 0.0, 1.0}, {0.0, 0.0, -1.0}, {0.0, 1.0, 0.0}, {0.0, -1.0, 0.0}, {1.0, 0.0, 0.0}, {-1.0, 0.0, 0.0}, {-1.0, 1.0, 1.0}, {1.0, 1.0, 1.0}, {1.0, -1.0, 1.0}, {1.0, 1.0, -1.0}, {-1.0, -1.0, 1.0}, {1.0, -1.0, -1.0}, {-1.0, 1.0, -1.0}, {-1.0, -1.0, -1.0},
    {0.0, 0.0, 2.0}, {0.0, 0.0, -2.0}, {0.0, 2.0, 0.0}, {0.0, -2.0, 0.0}, {2.0, 0.0, 0.0}, {-2.0, 0.0, 0.0}, {-2.0, 2.0, 2.0}, {2.0, 2.0, 2.0}, {2.0, -2.0, 2.0}, {2.0, 2.0, -2.0}, {-2.0, -2.0, 2.0}, {2.0, -2.0, -2.0}, {-2.0, 2.0, -2.0}, {-2.0, -2.0, -2.0},
    {0.0, 0.0, 3.0}, {0.0, 0.0, -3.0}, {0.0, 3.0, 0.0}, {0.0, -3.0, 0.0}, {3.0, 0.0, 0.0}, {-3.0, 0.0, 0.0}, {-3.0, 3.0, 3.0}, {3.0, 3.0, 3.0}, {3.0, -3.0, 3.0}, {3.0, 3.0, -3.0}, {-3.0, -3.0, 3.0}, {3.0, -3.0, -3.0}, {-3.0, 3.0, -3.0}, {-3.0, -3.0, -3.0},
    {0.0, 0.0, 4.0}, {0.0, 0.0, -4.0}, {0.0, 4.0, 0.0}, {0.0, -4.0, 0.0}, {4.0, 0.0, 0.0}, {-4.0, 0.0, 0.0}, {-4.0, 4.0, 4.0}, {4.0, 4.0, 4.0}, {4.0, -4.0, 4.0}, {4.0, 4.0, -4.0}, {-4.0, -4.0, 4.0}, {4.0, -4.0, -4.0}, {-4.0, 4.0, -4.0}, {-4.0, -4.0, -4.0},
    {0.0, 0.0, 5.0}, {0.0, 0.0, -5.0}, {0.0, 5.0, 0.0}, {0.0, -5.0, 0.0}, {5.0, 0.0, 0.0}, {-5.0, 0.0, 0.0}, {-5.0, 5.0, 5.0}, {5.0, 5.0, 5.0}, {5.0, -5.0, 5.0}, {5.0, 5.0, -5.0}, {-5.0, -5.0, 5.0}, {5.0, -5.0, -5.0}, {-5.0, 5.0, -5.0}, {-5.0, -5.0, -5.0}
};













/*
 * FeliciaClan CTMenu 1.2.1 - TEK SMA KAYNAK
 * Ana menu: ShowMain(). Secimlerin islenmesi: H_Main().
 * Diger menuler: ShowGamesHub(), ShowGameList(), ShowGamePanel().
 * Tum ozel fc_*.inc kodlari bu dosyanin icindedir.
 * Derleme: AMX Mod X 1.9/1.10 standart include dosyalari ve ReAPI.
 * Hogwarts/Milyoner oyunlari kendi eklentilerine native ile baglanir.
 * Oyun/HUD/kiralama duzeltmeleri 1.1.0 surumundeki gibi korunur.
 * GPL-3.0-or-later.
 */
/* FeliciaClan CT Menu — fresh implementation, ReAPI / AMXX 1.9+.
 * Menu styling matches FeliciaClan JBMenu. GPL-3.0-or-later.
 * All game state has one owner and is restored before finish notifications.
 */
#pragma semicolon 1
#include <amxmodx>
#include <amxmisc>
#include <reapi>
#include <fakemeta>
#include <engine>
#include <cstrike>
#include <nvault>

/* === Oyun kimlikleri ve native API === */
#if defined _fc_ctmenu_included
    #endinput
#endif
#define _fc_ctmenu_included

enum CTGame {
    CT_GAME_NONE = 0,
    CT_GAME_KNIFE,
    CT_GAME_GUN,
    CT_GAME_TEAMS,
    CT_GAME_INFECTION,
    CT_GAME_RED_LIGHT,
    CT_GAME_HOT_POTATO,
    CT_GAME_REFLEX,
    CT_GAME_NUMBER,
    CT_GAME_BLIND,
    CT_GAME_BIRD,
    CT_GAME_HUNGER,
    CT_GAME_HOGWARTS,
    CT_GAME_MILYONER,
    CT_GAME_ZOMBIE,
    CT_GAME_GHOST,
    CT_GAME_AREF,
    CT_GAME_SPARTA,
    CT_GAME_PENDULUM,
    CT_GAME_FREEZE_CHANCE,
    CT_GAME_BURY_JUMP,
    CT_GAME_REVERSE,
    CT_GAME_LOW_GRAVITY,
    CT_GAME_ONE_HP,
    CT_GAME_DEAGLE,
    CT_GAME_SHOTGUN,
    CT_GAME_SNIPER,
    CT_GAME_COLOR_LUCK,
    CT_GAME_ROCKET,
    CT_GAME_HOMELANDER,
    CT_GAME_TRON,
    CT_GAME_MAGNETIC,
    CT_GAME_SUMO,
    CT_GAME_DODGEBALL
};
enum CTStopReason {
    CT_STOP_MENU = 0, CT_STOP_WIN, CT_STOP_ROUND, CT_STOP_EMPTY,
    CT_STOP_TIME, CT_STOP_PLUGIN
};

// caller=0 is reserved for trusted server plugins.
// No reqlib pragma: a consumer may supply its own optional-native filter.
native fc_ctmenu_open(caller);
native fc_ct_game_start(CTGame:game, caller = 0);
native fc_ct_game_stop(caller = 0);
native bool:fc_ct_game_active();
native bool:fc_lr_active();
native bool:fc_lr_is_player(player);
native fc_lr_stop(caller = 0);
native CTGame:fc_ct_game_id();
native bool:fc_ct_is_player(player);
native fc_ct_get_warden(); // Deprecated: always 0.
native bool:fc_ct_god_active();
native bool:fc_ct_provider_allowed(CTGame:game, caller = 0);
native fc_ct_mode_queue(bool:hard, caller);
native fc_ct_hud_text(player, output[], length);
native bool:fc_ct_hud_visible(player);
native bool:fc_ct_hard_active();
native fc_ct_set_hard(bool:enabled, caller = 0);

// prepare runs before state snapshots, finish after restoration.
forward fc_ct_game_prepare(caller, CTGame:game);
forward fc_ct_game_started(caller, CTGame:game, players);
forward fc_ct_game_finished(CTGame:game, winner, CTStopReason:reason);
forward fc_ct_hard_changed(bool:active);



/* === Milyoner native API === */
#if defined _fc_milyoner_included
    #endinput
#endif
#define _fc_milyoner_included
native milyoner_start(caller = 0);
native milyoner_stop(caller = 0);
native bool:milyoner_active();
native bool:milyoner_is_player(player);
native milyoner_get_alive();
native milyoner_reload(caller = 0);
forward milyoner_prepare(caller, players);
forward milyoner_started(caller, players);
forward milyoner_finished(winner, reason);


native hogwarts_menu(caller);
native hogwarts_start(caller = 0);
native hogwarts_stop(caller = 0);
native hogwarts_state();
native bool:hogwarts_is_player(player);
native fc_get_tl(player);
native fc_set_tl(player, amount);
native fc_add_tl(player, amount);

#define VERSION "2.1.3-FIX"
#define MAXP 32
#define TASK_HEARTBEAT 731100
#define TASK_GAME 731101
#define TASK_CHECK 731102
#define MAX_CRATES 32
#define MAX_ARENA_POINTS 32
#define SNAP_TOOL 0
#define SNAP_GAME 1
#define SNAP_ROCKET 2
#define SNAP_MODES 3

new const CHAT_TAG[] = "^1[ ^3- ^4FeliciaClan ^3- ^1]";
new const LONG_TAG[] = "FeliciaClan";
new const SHORT_TAG[] = "FC";
new const CFG_FILE[] = "addons/amxmodx/configs/FeliciaClan/FeliciaClan_CTMenu.ini";
new const FISTS_MODEL[] = "models/FeliciaClan/v_fists_v120.mdl";
new const CRATE_MODEL[] = "models/FeliciaClan/ct_ikmal_v1.mdl";
new const BEAM_SPRITE[] = "sprites/FeliciaClan_CT/beam.spr";
new const LOOT_CLASS[] = "fc_ct_loot";
new const GAME_NAMES[][] = {
    "Normal Oyun", "Kafes Dövüşü", "Silahlı Çatışma", "Takım Savaşı",
    "Enfeksiyon", "Kırmızı Işık - Yeşil Işık", "Sıcak Patates",
    "Komut Refleksi", "Sayıyı Bul", "Körebe", "Kuş Avı",
    "Açlık Oyunları", "Hogwarts", "Kim Milyoner Olmak İster",
    "Zombi", "Hayalet", "Aref", "300 Sparta", "Sarkaç", "Freeze’lenen Ölür",
    "Gömülen Ölür", "Ters Kontrol", "Düşük Yerçekimi Düellosu", "Tek Can",
    "Deagle Düellosu", "Pompalı Düellosu", "Keskin Nişancı", "Renkli Şans", "Rocket",
    "Homelander (Lazer Gözlü CT)", "Tron (Zehirli Ayak İzleri)",
    "Manyetik Alan (Karadelik)", "Sumo Güreşi (Knockback)", "Dodgeball (Yakan Top)"
};
new const GAME_RULES[][] = {
    "", "Mahkûmlar yumrukla dövüşür. JBMenu kilitlenir; son kalan kazanır.",
    "Mahkûmlara aynı silahlar verilir. Son kalan kazanır.",
    "Kırmızı ve mavi takım dengeli kurulur. Aynı takım birbirine vuramaz.",
    "Yeşil enfekte temasla bulaştırır; her yarım saniye 3 HP kaybeder. Son kalan kazanır.",
    "Yeşilde hareket et, kırmızıda dur. Uyarı süresinden sonra hareket eden elenir.",
    "Mor oyuncu bombayı dokunarak devreder. Süre dolunca taşıyan elenir.",
    "Yeşil SPR: komutu yap. Kırmızı SAHTE: hareket etme. Her tur hızlanır.",
    "Sayıyı ilk bulan kazanır; diğer bütün mahkûmlar slaylanır.",
    "Rastgele ebe kısa süre kör kalır. Mahkûmları bıçakla bulur.",
    "Düşük yerçekiminde mahkûmlar kaçar; CT avcıları tüfekle avlar.",
    "Kutulardan silah topla. Mor çember daralır, dışarıda canın azalır.",
    "Seçmen Şapka haneni belirler. Asa ve büyüler Hogwarts eklentisiyle verilir.",
    "Türkçe soruların cevabını menüden seç. CT şıkları görür, cevap veremez.",
    "T zombiler bıçak ve yüksek canla CT avcılarına saldırır. CT god kapalıdır.",
    "Görünmez CT hayaletler bıçakla, T oyuncuları tüfekle savaşır.",
    "T oyuncuları görünmez Deagle savaşçıları olur. CT normal şekilde karşı koyar.",
    "CT ve T bıçaklarla savaşır. CT 750, T 150 can alır; god verilmez.",
    "Yerçekimi belirli aralıklarla değişir. Her dalgada can azalır; son kalan kazanır.",
    "Rastgele bir mahkûm dondurulur, iki saniye sonra elenir. Son kalan kazanır.",
    "Uyarı gelince üç saniyede zıpla ve tuzaktan kurtul. Zıplamayan elenir.",
    "İleri/geri ve sağ/sol kontrolleri ters çalışır. Bıçakla son kalan kazanır.",
    "Düşük yerçekiminde MP5 ile savaş. Son kalan kazanır.",
    "Herkes bir can ve Deagle alır. Son kalan kazanır.",
    "Herkese Deagle verilir. Son kalan kazanır.",
    "Herkese M3 pompalı verilir. Son kalan kazanır.",
    "Herkese Scout verilir. Son kalan kazanır.",
    "Rastgele mahkûma renk seçilir. Mavi yaşar, kırmızı iki saniye sonra elenir.",
    "Süre seç, TMP ile kaç. Sayaç sonunda mahkûmlar havalanır ve patlar. CT God korunur.",
    "CT komutanı çok yüksek can ve god alır. Nişangâhına bastığı anda kalın, ölümcül lazer gönderir.",
    "Mahkûmlar 400 hızla koşar. Her oyuncunun kendi rengindeki izi diğer mahkûma değerse öldürür.",
    "CT komutanı görüş hattındaki mahkûmları karadeliğe doğru çeker. CT'ye dokunan elenir; duvar arkasındakiler güvendedir.",
    "Mahkûmlar bıçak darbeleriyle birbirini iter. Komutanın bulunduğu noktadaki dairesel arenadan düşen elenir.",
    "Yalnızca mahkûmlar sınırsız el bombası alır. Patlama hasarı yoktur; bombanın gövde/kafa isabeti doğrudan eler."
};
new const bool:GAME_GOD[] = {
    false, false, false, false, false, true, true, true, false, false, true, true, true, true,
    false, false, false, false, false, false, false, false, false, false, false, false, false, false, true,
    true, false, false, false, false
};

enum _:CTConfig {
    CFG_WARDEN_ONLY, CFG_GAME_SECONDS, CFG_GREEN_MIN, CFG_GREEN_MAX,
    CFG_RED_MIN, CFG_RED_MAX, CFG_RED_GRACE, CFG_REFLEX_WINDOW,
    CFG_BOMB_SECONDS, CFG_HUNGER_RADIUS, CFG_HUNGER_MIN, CFG_HUNGER_SHRINK,
    CFG_HUNGER_DAMAGE, CFG_CT_HP, CFG_CT_ARMOR, CFG_RADIO, CFG_WIN_TL,
    CFG_PRICE_HP, CFG_PRICE_AMMO, CFG_PRICE_GRAVITY, CFG_PRICE_REGEN,
    CFG_PRICE_SPEED, CFG_LOCAL_START, CFG_LOCAL_MINUTE, CFG_LOCAL_KILL,
    CFG_SOUNDS, CFG_REFLEX_MIN, CFG_REFLEX_STEP, CFG_REFLEX_FAKE,
    CFG_SUMO_RADIUS, CFG_SUMO_KNOCKBACK, CFG_TOTAL
};
new const CFG_KEYS[][] = {
    "WARDEN_ONLY", "GAME_SECONDS", "GREEN_MIN", "GREEN_MAX", "RED_MIN", "RED_MAX",
    "RED_GRACE_MS", "REFLEX_WINDOW_MS", "BOMB_SECONDS", "HUNGER_RADIUS",
    "HUNGER_MIN_RADIUS", "HUNGER_SHRINK", "HUNGER_DAMAGE", "CT_SPAWN_HP",
    "CT_SPAWN_ARMOR", "RADIO_KEYS", "WINNER_TL", "PRICE_HP", "PRICE_AMMO",
    "PRICE_GRAVITY", "PRICE_REGEN", "PRICE_SPEED", "LOCAL_START_TL",
    "LOCAL_MINUTE_TL", "LOCAL_KILL_TL", "MENU_SOUNDS", "REFLEX_MIN_WINDOW_MS", "REFLEX_SPEEDUP_MS", "REFLEX_FAKE_PERCENT",
    "SUMO_PLATFORM_RADIUS", "SUMO_KNOCKBACK"
};
new const CFG_DEFAULTS[] = {
    0, 180, 3, 6, 2, 4, 750, 2000, 12, 1800, 160, 25, 5, 100,
    100, 1, 0, 100, 100, 100, 100, 100, 30, 2, 5, 1, 1000, 100, 25, 400, 800
};
new g_cfg[CFG_TOTAL];
new CTGame:g_game;
new bool:g_stopping, bool:g_announced;
new g_warden;
new bool:g_hard;
new g_fwPrepare, g_fwStarted, g_fwFinished, g_menuCallback;
new g_fwRocketPrepare,g_fwRocketFinished;
new g_beam, g_lineBeam, g_vault;
#define TASK_LASER_WALL 741320
#define LASER_WALL_HALF_WIDTH 220.0
#define LASER_WALL_TOUCH_DISTANCE 24.0
new bool:g_wallActive[MAXP+1];
new g_wallUsageCount,g_wallUsageAuth[MAXP+1][40];
new bool:g_wallInside[MAXP+1][MAXP+1];
new g_wallOwnerUID[MAXP+1];
new Float:g_wallStart[MAXP+1][3], Float:g_wallEnd[MAXP+1][3];
new Float:g_wallMinZ[MAXP+1], Float:g_wallMaxZ[MAXP+1], Float:g_wallNextDraw[MAXP+1];
new Float:g_pingNext[MAXP+1];
new g_cvarFF, g_cvarFFA, g_cvarInfinite;
new g_oldFF[24], g_oldFFA[24], g_oldInfinite[32];
new bool:g_cvarsSaved;
new bool:g_part[MAXP+1], g_partUID[MAXP+1], g_color[MAXP+1];
new bool:g_ready[MAXP+1], g_prevButtons[MAXP+1];
new g_gameBoss, g_gameBossUID;
new Float:g_nextLaser, Float:g_sumoFloor, Float:g_sumoRadius, Float:g_sumoNextDraw;
new Float:g_sumoCenter[3];
#define TRON_MAX_SEGMENTS 1024
new g_tronHead, g_tronCount, g_tronOwner[TRON_MAX_SEGMENTS], g_tronOwnerUID[TRON_MAX_SEGMENTS];
new Float:g_tronStart[TRON_MAX_SEGMENTS][3], Float:g_tronEnd[TRON_MAX_SEGMENTS][3], Float:g_tronTime[TRON_MAX_SEGMENTS];
new Float:g_tronLast[MAXP+1][3];
new Float:g_gameEnd, Float:g_phaseEnd, Float:g_graceEnd, Float:g_nextSecond;
new Float:g_anchor[MAXP+1][3], Float:g_touchNext[MAXP+1];
new g_phase, g_bomb, g_secret, g_rounds, g_reflexAction;
new bool:g_toolFrozen[MAXP+1], Float:g_thawTime[MAXP+1];
new g_lastDead, g_lastDeadUID;
new g_target[MAXP+1], g_targetUID[MAXP+1], g_input[MAXP+1];
new bool:g_showInfo[MAXP+1];
new bool:g_standaloneHud[MAXP+1];
new g_crates[MAX_CRATES], g_crateCount;
new Float:g_center[3], Float:g_radius, Float:g_nextShrink;
new Float:g_arenaCenter[3], bool:g_hasArena;
new Float:g_arenaPoints[MAX_ARENA_POINTS][3], g_arenaCount;
new g_arenaPath[192], g_lootModel[128];

enum _:CTSnapshot {
    SS_UID, SS_TEAM, SS_FLAGS, SS_MOVETYPE, SS_RENDERFX, SS_RENDERMODE,
    Float:SS_HEALTH, Float:SS_ARMOR, Float:SS_GRAVITY, Float:SS_SPEED,
    Float:SS_DAMAGE, Float:SS_RENDERAMT, Float:SS_COLOR[3], Float:SS_ORIGIN[3],
    SS_KEVLAR, SS_DEFUSER, SS_ACTIVE, SS_COUNT, SS_VALID
};
new g_snap[SNAP_MODES][MAXP+1][CTSnapshot];
new g_savedWeapons[SNAP_MODES][MAXP+1][32];
new g_savedClip[SNAP_MODES][MAXP+1][31];
new g_savedAmmo[SNAP_MODES][MAXP+1][31];
new g_oldView[SNAP_MODES][MAXP+1][128], g_oldHand[SNAP_MODES][MAXP+1][128];
new bool:g_perk[MAXP+1][5], g_localTL[MAXP+1], g_auth[MAXP+1][40];
new Float:g_nextGuess[MAXP+1], Float:g_nextRegen[MAXP+1];


/* === Referans menudeki bildirimler ve islem kisayollari === */
enum { SND_MENU, SND_NOTICE, SND_RESET, SND_GOD, SND_HARD, SND_FREEZE, SND_KNIFE, SND_GUN, SND_SPARTA, SND_TRAP, SND_COUNTDOWN, SND_LINEUP, SND_HOGWARTS, SND_POTATO, SND_POTATO_TICK, SND_POTATO_END, SND_ROCKET_FIRE, SND_ROCKET_BOOM };
new const CT_SOUNDS[][] = {
    "fc_ctmenu_v112/menu.wav", "fc_ctmenu_v112/notice.wav", "fc_ctmenu_v112/reset.wav",
    "fc_ctmenu_v112/god.wav", "fc_ctmenu_v112/hard.wav", "fc_ctmenu_v112/freeze.wav",
    "fc_ctmenu_v112/knives.wav", "fc_ctmenu_v112/guns.wav", "fc_ctmenu_v112/sparta.wav",
    "fc_ctmenu_v112/trap.wav", "fc_ctmenu_v112/countdown.wav", "fc_ctmenu_v112/lineup.wav",
    "fc_ctmenu_v120/hogwarts.wav", "fc_ctmenu_v120/potato.wav", "fc_ctmenu_v120/potato_tick.wav", "fc_ctmenu_v120/potato_boom.wav", "fc_ctmenu_v121/rocket_fire.wav", "fc_ctmenu_v121/rocket_boom.wav"
};
new bool:g_soundReady[sizeof CT_SOUNDS];
new g_soundPath[sizeof CT_SOUNDS][128];
new const CT_ORIGINAL_SOUNDS[][] = {
    "ctmenum/bildirim.wav", "ctmenum/bildirim.wav", "ctmenum/ayarsifirla.wav",
    "ctmenum/godalinca.wav", "ctmenum/bildirim.wav", "ctmenum/don.wav",
    "ctmenum/duzff.wav", "ctmenum/silahliff.wav", "ctmenum/sparta_new.wav",
    "ctmenum/gomulunce.wav", "ctmenum/onsaniye.wav", "ctmenum/bildirim.wav",
    "fc_ctmenu_v120/hogwarts.wav", "fc_ctmenu_v120/potato.wav", "fc_ctmenu_v120/potato_tick.wav", "fc_ctmenu_v120/potato_boom.wav", "weapons/rocketfire1.wav", "weapons/rocket1.wav"
};
new g_requestedAction[MAXP+1];
new g_buriedUID[33],g_buryFlags[33],bool:g_buryFull[33];
new Float:g_buryOrigin[33][3],Float:g_buryUntil[33];
// The reference's timed bury waits first, then buries; it is not a lift timer.
#define TASK_C4_COUNTDOWN 731104
new g_c4CountdownActor,g_c4CountdownUID,g_c4CountdownTargets[33],g_c4CountdownSecond;
new Float:g_c4CountdownEnd;
new g_lastPotatoSecond;

#define TASK_FORMATION 731103
new g_lineAxis[MAXP+1],g_lineSpacing[MAXP+1],g_lineMenu[MAXP+1];

new const REFLEX_HUD_NAMES[][]={"fc_reflex121_up","fc_reflex121_down","fc_reflex121_left","fc_reflex121_right","fc_reflex121_stop","fc_reflex121_fake_up","fc_reflex121_fake_down","fc_reflex121_fake_left","fc_reflex121_fake_right","fc_reflex121_fake_stop"};
new const REFLEX_LABELS[][]={"ZIPLA","EĞİL","SOLA GİT","SAĞA GİT","DUR"};
#define REFLEX_HUD_WEAPON 2
new g_msgReflexList,g_msgReflexWeapon,g_msgReflexFov;
new bool:g_reflexShown[33],bool:g_reflexDirty[33],bool:g_reflexAssetsReady;
new g_reflexWeapon[33],g_reflexClip[33],g_reflexFov[33],g_reflexDefined[33];
new bool:g_reflexAmmoKnown[33][31],g_reflexAmmo[33][31][4];
new bool:g_reflexFake;
new bool:g_reflexStarting,bool:g_reflexSending[33];
new bool:g_reflexLanding[33];
new Float:g_reflexStartEnd;new g_reflexStartSecond;
new Float:g_infectionNextHP[33];
new g_rocketDelay=10,g_rocketSprite,g_rocketLastSecond;
new Float:g_rocketLastZ[33];
#define TASK_ROCKET 731106
new bool:g_rocketActive;new g_rocketPhase,g_rocketTargetUID[33],g_rocketGuardUID[33];
new Float:g_rocketEnd,Float:g_rocketGrace,Float:g_rocketOrigin[33][3];
#define TASK_PROTECTION_VOTE 731105
new const PROTECTION_CHOICES[][]={"T-Sustum","Rocket","Sarkaç","Domates","Oyun"};
new g_protectionActor,g_protectionUID,g_protectionSerial,g_protectionSecond,g_protectionCallback;
new g_protectionVoterUID[33],g_protectionChoice[33],g_protectionVotes[5],g_protectionMenu[33];
new Float:g_protectionEnd;

/* === Ortak HUD cercevesi === */
#if defined _fc_hud_frame_included
    #endinput
#endif
#define _fc_hud_frame_included
// Shared information HUD, inlined to keep each SMA independently compilable.
// White data and outer arrows use channel 4, the team-colored title channel 3,
// yellow inner arrows channel 2. Channel 1 remains available for game messages.
new bool:g_bFCPanelSent[33][5];
new g_iFCPanelSignature[33][5];
new g_iFCPanelWidth[33];
new Float:g_flFCPanelReliable[33][5];






























/* === Sonraki el God ve Hard izinleri === */
// Server-wide, independent three-round intervals. A permit lasts its whole
// round; reset may turn the same permit on again without consuming a new interval.
new g_roundNo, g_godPending=-1, g_hardPending=-1;
new g_godNext, g_hardNext, g_godPermit=-1, g_godUsed=-1, g_hardPermit=-1, g_hardUsed=-1;
new bool:g_godMode;















/* === Hard Komut ve hareket ayarlarinin geri alinmasi === */
// Restore exact cvar values and only the movement plugins paused by this menu.
#define MAX_HARD_CVARS 24
#define MAX_HARD_PLUGINS 16
new g_fwHard, g_hardStatus;
new g_hardCvars[MAX_HARD_CVARS], g_hardValues[MAX_HARD_CVARS][48], g_hardCount;
new g_hardPlugins[MAX_HARD_PLUGINS][96], g_hardPluginCount;
new g_hardNames[512] = "sv_parachute,sv_redbull,rh_enabled,cz_ekstra_ziplama,bh_enabled,bhop_enabled,amx_bhop,amx_bunnyhop";
new g_hardPluginNames[512];
new g_hardUID[MAXP+1], g_hardTeam[MAXP+1];
new Float:g_hardGravity[MAXP+1], Float:g_hardSpeed[MAXP+1];












/* === CT Market === */
// Shares TL with JBMenu when present; nvault is used only in standalone mode.
new const PERK_NAMES[][] = {"+150 Can","Sınırsız Cephane","Hafif Yerçekimi","Can Yenileme","Hız Artışı"};
new const MAX_CLIP[31] = {0,13,0,10,0,7,0,30,30,0,30,20,25,30,35,25,12,20,10,30,100,8,30,30,20,0,7,30,30,0,50};
new g_marketCB;
















/* === Oyuncu ve CT araclari === */
// CT utilities. Target userids are rechecked whenever a menu is selected.
new const GUN_NAMES[][] = {"AK-47","M4A1","MP5","AUG","Scout","M3","AWP","Deagle"};
new const GUN_CLASS[][] = {"weapon_ak47","weapon_m4a1","weapon_mp5navy","weapon_aug","weapon_scout","weapon_m3","weapon_awp","weapon_deagle"};
new const GUN_AMMO[] = {90,90,120,90,90,32,30,35};
new g_cellTargets[256];




































new g_walletSeconds;




/* === Oyun oturumu ve oyuncu durum kayitlari === */






































/* === Dahili oyunlar === */




















// CT/T modes use regular team damage, with CT immunity explicitly disabled.


















/* === Isinlama, daire ve kisiye ozel canli siralama onizlemesi === */
























/* === MENU TASARIMI: ShowMain ve H_Main === */
// Same title, option and chat format as FeliciaClan JBMenu.




















































/* === C4 operations, with explicit origin/slot ownership === */











/* === Fixed 2D command sprites; same working client HUD protocol as Milyoner === */
















/* === Reference-style infection, startup, Rocket and protection vote === */

























// Snapshot tools are undone before LR saves state, so CT god/noclip/freeze
// cannot leak into the duel. The next-round permits and hard state are retained.




/* The reference and extensions share one round, reset path and movement state. */
#define TASK_LEGACY_INFECTION 791220
#define TASK_CT_SPAWN_MENU 791300

new g_externalOwner=-1,g_externalSerial,g_externalToken;
new g_externalName[64];
native fc_pet_admin_open(caller);
#define TASK_CT_LOADOUT 871700
new g_loadoutUID[33],g_loadoutLife[33],g_loadoutTry[33],g_spawnLife[33];
new bool:g_bridgeRoundClosed,bool:g_bridgeResetting,bool:g_bridgeLegacy;
new g_bridgeMenu[MAXP+1],g_bridgeUID[MAXP+1],g_bridgeSpawnUID[MAXP+1];
new g_bridgeGameName[64],g_bridgeActor,g_bridgeInitialT;
new Float:g_bridgeInfectHP,Float:g_bridgeInfectAura;































#pragma semicolon 0
#pragma tabsize 0
public LegacyInit() {

    register_clcmd("say /ctmenu", "ctmenu"); 
    register_clcmd("say_team /ctmenu", "ctmenu");
    register_clcmd("radio2", "ctmenu");
    register_clcmd("radio3", "ctmenu"); 

    register_clcmd("say /af", "afver");
    register_clcmd("say /afver", "afver");

    register_clcmd("say /hucre", "hucrekapisiniac");
    register_clcmd("say /god", "godsoyle");
    register_clcmd("say /godmode", "godsoyle");
    register_clcmd("say /godsoyle", "godsoyle");
    register_clcmd("say /menuler", "menuler");
    register_clcmd("say /revmenu", "revivemenu");
    register_clcmd("say /glow", "glowmenu");
    register_clcmd("say /tm", "glowmenu");
    register_clcmd("say /glowmenu", "glowmenu");
    register_clcmd("say /c4", "c4menu");
    register_clcmd("say /c4menu", "c4menu");
    register_clcmd("say /takimmenu", "takimmenu");
    register_clcmd("say /takimyap", "takimyap");
    register_clcmd("say /takimboz", "takimboz");
    register_clcmd("say /slaymavi", "slaymavi");
    register_clcmd("say /isinlama", "isinlamenu");
    register_clcmd("say /slaykirmizi", "slaykirmizi");
    register_clcmd("say /isinlamavi", "isinlamavi");
    register_clcmd("say /isinlakirmizi", "isinlakirmizi");
    register_clcmd("say /dondur", "dondur");
    register_clcmd("say /coz", "coz");
    register_clcmd("say /freeze", "freezemenu");
    register_clcmd("say /freezemenu", "freezemenu");
    register_clcmd("say /ff", "ffmenu");
    register_clcmd("say /ffmenu", "ffmenu");
    register_clcmd("say /catisma", "catismamenu");
    register_clcmd("say /islemler", "islemlermenu");
    register_clcmd("say /koruma", "korumamenu");
    register_clcmd("say /rocket", "rocketmenu");
    register_clcmd("say /rocketmenu", "rocketmenu");
    register_clcmd("say /roket", "rocketmenu");
    register_clcmd("say /rocket", "rocketmenu");
    register_clcmd("say /gardiyan", "gardiyanyardim");
    register_clcmd("say /sonsec", "sonsecmenu");
    register_clcmd("say /lk", "sonolenrev");
    register_clcmd("say /lastkill","sonolenrev");
    register_clcmd("buyammo2","sonolenrev");
    register_clcmd("say /getir", "CmdBring");
    register_clcmd("say /slay", "slaymenu");
    register_clcmd("say /slaymenu", "slaymenu");
    register_clcmd("say /100", "yuzle");
    register_clcmd("say /daire", "daire");
    register_clcmd("say /sirala", "yansirala");
    register_clcmd("say /silah", "silahmenu");
    register_clcmd("say /adminlik", "adminlik");
    register_clcmd("say /skorlar", "anlikpuan");

    
    register_clcmd("T_HP_BELIRLE", "t_hp");
    register_clcmd("CT_HP_BELIRLE", "ct_hp");
    register_clcmd("Sayiyi_Bilen_Kazanir", "Sayiyi_Bilen_Kazanir_p");

    RegisterHam(Ham_Use, "func_button", "Tusa_Bas");

    DisableHookChain((h_Dmg = RegisterHookChain(RG_CBasePlayer_TakeDamage, "playerTakeDamage", false)));
    DisableHookChain((h_rSpeed = RegisterHookChain(RG_CBasePlayer_ResetMaxSpeed, "resetSpeed", false)));
    
    RegisterHookChain(RG_CBasePlayer_Killed, "playerKilled", true);
    RegisterHookChain(RG_CSGameRules_RestartRound, "roundStart", false);
    RegisterHookChain(RG_CSGameRules_FlPlayerFallDamage, "fallDamage", false);

    register_touch("player", "player", "touch_player");
    register_touch("weaponbox", "player", "touch_weapon");
    register_touch("armoury_entity", "player", "touch_weapon");
    register_touch("weapon_shield", "player", "touch_weapon");
    register_event_ex("CurWeapon", "manualUnammo", RegisterEvent_Single | RegisterEvent_OnlyAlive , "1=1", "3=1");

    bind_pcvar_num(create_cvar("ctmenu_takimHasar", "1", _, _, true, 0.0, true, 1.0), takimHasar); 
                        // Glow renkleri ayni olanlar birbirine hasar veremez == 1

    bind_pcvar_num(create_cvar("ctmenu_silahliGom", "0", _, _, true, 0.0, true, 1.0), silahliGom); 
                        // Silahi Olan Oyuncular Gomulmesin == 1

    bind_pcvar_num(create_cvar("ctmenu_m249Active", "1", _, _, true, 0.0, true, 1.0), m249Active); 
                        // CT Dogunca M249 Verilsin == 1

    bind_pcvar_num(create_cvar("ctmenu_fallDamageCT", "1", _, _, true, 0.0, true, 1.0), fallDamageCT); 
                        // CT Yuksekten Dusunce Can Gitmesin == 1

    bind_pcvar_float(create_cvar("ctmenu_ctcan", "250"), cvar[0]);				//CT Dogunca Canini Yandaki Miktara Ayarlar.
    bind_pcvar_float(create_cvar("ctmenu_ctarmor", "150"), cvar[1]);			//CT Dogunca Armorunu Yandaki Miktara Ayarlar.

    mp_freeforall = get_cvar_pointer("mp_freeforall");
    sv_gravity = get_cvar_pointer("sv_gravity");
    bh_enabled = EnsureLegacyCvar("bh_enabled","1");
    sv_parachute = EnsureLegacyCvar("sv_parachute","1");
    mp_forcecamera = get_cvar_pointer("mp_forcecamera");
    sv_airaccelerate = get_cvar_pointer("sv_airaccelerate");
    mp_infinite_ammo = get_cvar_pointer("mp_infinite_ammo");

    #if defined semiclip_cvaraktif 
        if(!get_cvar_pointer("semiclip")) 
        {
            create_cvar("semiclip", "");
        }

        semiclip = get_cvar_pointer("semiclip");
    #endif

    ScreenFade = get_user_msgid("ScreenFade");
    DeathMsg = get_user_msgid("DeathMsg");
    SetFOV = get_user_msgid("SetFOV");
    Damage = get_user_msgid("Damage");
}

public LegacyCfg() { /* Retired account vault removed. */ }

public LegacyEnd() { /* Current FC wallet is closed by plugin_end. */ }



stock RA_MenuCreate(const szOriginalTitle[],const szHandler[]) {
    new title[512],pattern[128];copy(title,charsmax(title),szOriginalTitle);
    formatex(pattern,charsmax(pattern),"\w%s \d|| ",serverTAG);replace(title,charsmax(title),pattern,"");
    return CTMenu(title,szHandler);
}

stock RA_MenuAddItem(iMenu,const szOriginalText[],const szInfo[],iAccess=0,iCallback=-1) {
    new text[384],clean[384];FC_MenuCleanHints(szOriginalText,clean,charsmax(clean));
    formatex(text,charsmax(text),"\y» %s",clean);
    return menu_additem(iMenu,text,szInfo,iAccess,iCallback);
}















































public Tusa_Bas(ent, id)
{
    if(get_user_team(id) == 1)
    {
        if(aref || godmode_sorgu() || enfeksiyonKontrol || ffKontrol)
        {
            client_print(id,print_center,"Godmode'lu Ellerde ve FF,Aref,Enfeksiyon Oyunlarinda Tuslara Basamazsin.");
            return HAM_SUPERCEDE;
        }
    }
    return HAM_IGNORED;
}

bool:godmode_sorgu() 
{
    new players[MAX_PLAYERS], num; 
    get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_MatchTeam, "CT"); 

    for(new i=0; i<num; i++) 
    {

        if(!get_entvar(players[i], var_takedamage)) 
        {
            return true;
        }
    }
    return false;
}

public afver(const id)
{
    if(get_member(id, m_iTeam) == TEAM_CT || get_user_flags(id) & ADMIN_KICK)
    {
        new players[MAX_PLAYERS], num, ids;  
        get_players_ex(players, num, GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");

        for(new i=0; i<num; i++) {
            ids=players[i];

            if(!is_user_alive(ids))
            {
                rg_round_respawn(ids);
            }
        }
        client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan/yetkili ^1olu mahkumlari ^4revledi.", id);
    }
}

stock LaserWallSendBeam(const Float:start[3], const Float:end[3], red, green, blue, width, life)
{
    if(g_lineBeam<=0) return;
    message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
    write_byte(TE_BEAMPOINTS);
    write_coord_f(start[0]);write_coord_f(start[1]);write_coord_f(start[2]);
    write_coord_f(end[0]);write_coord_f(end[1]);write_coord_f(end[2]);
    write_short(g_lineBeam);
    write_byte(0);write_byte(0);write_byte(life);write_byte(width);write_byte(0);
    write_byte(red);write_byte(green);write_byte(blue);write_byte(255);write_byte(0);
    message_end();
}
stock LaserWallDraw(owner)
{
    if(owner<1 || owner>MaxClients || !g_wallActive[owner]) return;
    new Float:a[3],Float:b[3],Float:ta[3],Float:tb[3];
    new Float:dx=g_wallEnd[owner][0]-g_wallStart[owner][0];
    new Float:dy=g_wallEnd[owner][1]-g_wallStart[owner][1];
    for(new i=0;i<=8;i++) {
        new Float:f=float(i)/8.0;
        a[0]=g_wallStart[owner][0]+dx*f;a[1]=g_wallStart[owner][1]+dy*f;a[2]=g_wallMinZ[owner];
        ta[0]=a[0];ta[1]=a[1];ta[2]=g_wallMaxZ[owner];
        LaserWallSendBeam(a,ta,255,35,35,7,220);
    }
    a[0]=g_wallStart[owner][0];a[1]=g_wallStart[owner][1];a[2]=g_wallMinZ[owner];
    b[0]=g_wallEnd[owner][0];b[1]=g_wallEnd[owner][1];b[2]=g_wallMinZ[owner];
    ta[0]=a[0];ta[1]=a[1];ta[2]=g_wallMaxZ[owner];
    tb[0]=b[0];tb[1]=b[1];tb[2]=g_wallMaxZ[owner];
    LaserWallSendBeam(a,b,255,20,20,8,220);
    LaserWallSendBeam(ta,tb,255,20,20,8,220);
}
stock LaserWallRemove(owner)
{
    if(owner<1 || owner>MaxClients) return;
    g_wallActive[owner]=false;g_wallOwnerUID[owner]=0;g_wallNextDraw[owner]=0.0;
    for(new id=1;id<=MaxClients;id++) g_wallInside[owner][id]=false;
}
stock LaserWallReset()
{
    g_wallUsageCount=0;
    for(new owner=1;owner<=MaxClients;owner++) {
        g_wallActive[owner]=false;g_wallOwnerUID[owner]=0;g_wallNextDraw[owner]=0.0;
        for(new id=1;id<=MaxClients;id++) g_wallInside[owner][id]=false;
    }
}
stock CreateLaserWall(id)
{
    if(!AliveCT(id)) {Chat(id,"Lazer duvarını yalnızca yaşayan gardiyanlar kurabilir.");return;}
    if(g_bridgeRoundClosed || g_game || g_rocketActive) {Chat(id,"Aktif oyun veya round geçişinde lazer duvarı kuramazsın.");return;}
    new authid[40];
    get_user_authid(id,authid,charsmax(authid));
    if(equal(authid,"STEAM_ID_PENDING") || !authid[0])
        formatex(authid,charsmax(authid),"USERID_%d",get_user_userid(id));
    for(new used=0;used<g_wallUsageCount;used++)
        if(equal(g_wallUsageAuth[used],authid))
        {
            Chat(id,"Bu tur lazer duvarı kurma hakkını zaten kullandın.");
            return;
        }
    if(g_wallUsageCount>=MaxClients)
    {
        Chat(id,"Bu tur lazer duvarı kullanım sınırına ulaşıldı.");
        return;
    }
    copy(g_wallUsageAuth[g_wallUsageCount++],charsmax(g_wallUsageAuth[]),authid);
    new aim[3];get_user_origin(id,aim,3);
    new Float:angles[3];get_entvar(id,var_v_angle,angles);
    new Float:yaw=angles[1]+90.0;
    new Float:rx=floatcos(yaw,degrees),Float:ry=floatsin(yaw,degrees);
    g_wallStart[id][0]=float(aim[0])-rx*LASER_WALL_HALF_WIDTH;
    g_wallStart[id][1]=float(aim[1])-ry*LASER_WALL_HALF_WIDTH;
    g_wallEnd[id][0]=float(aim[0])+rx*LASER_WALL_HALF_WIDTH;
    g_wallEnd[id][1]=float(aim[1])+ry*LASER_WALL_HALF_WIDTH;
    g_wallMinZ[id]=float(aim[2])-48.0;g_wallMaxZ[id]=float(aim[2])+112.0;
    g_wallStart[id][2]=g_wallMinZ[id];g_wallEnd[id][2]=g_wallMinZ[id];
    g_wallActive[id]=true;g_wallOwnerUID[id]=get_user_userid(id);
    g_wallNextDraw[id]=get_gametime()+15.0;
    for(new target=1;target<=MaxClients;target++) g_wallInside[id][target]=false;
    LaserWallDraw(id);
    client_print_color(0,id,"^1[^3FeliciaClan^1] ^3%n ^1bir lazer duvarı kurdu! Duvarı geçen mahkûmlar ^3100 HP^1 hasar alır.",id);
}
stock Float:LaserWallDistance2D(const Float:p[3],const Float:a[3],const Float:b[3])
{
    new Float:dx=b[0]-a[0],Float:dy=b[1]-a[1],Float:l=dx*dx+dy*dy;
    if(l<=0.001) return 99999.0;
    new Float:t=((p[0]-a[0])*dx+(p[1]-a[1])*dy)/l;
    t=floatclamp(t,0.0,1.0);
    new Float:x=p[0]-(a[0]+dx*t),Float:y=p[1]-(a[1]+dy*t);
    return floatsqroot(x*x+y*y);
}
public LaserWallThink()
{
    new Float:now=get_gametime();
    for(new owner=1;owner<=MaxClients;owner++) {
        if(!g_wallActive[owner]) continue;
        if(!is_user_connected(owner) || get_user_userid(owner)!=g_wallOwnerUID[owner]) {LaserWallRemove(owner);continue;}
        if(now>=g_wallNextDraw[owner]) {LaserWallDraw(owner);g_wallNextDraw[owner]=now+15.0;}
        for(new target=1;target<=MaxClients;target++) {
            if(!AliveT(target)) {g_wallInside[owner][target]=false;continue;}
            new Float:origin[3];get_entvar(target,var_origin,origin);
            new bool:touch=(origin[2]>=g_wallMinZ[owner]-18.0 && origin[2]<=g_wallMaxZ[owner]+18.0
                && LaserWallDistance2D(origin,g_wallStart[owner],g_wallEnd[owner])<=LASER_WALL_TOUCH_DISTANCE);
            if(touch && !g_wallInside[owner][target]) {
                g_wallInside[owner][target]=true;
                ExecuteHamB(Ham_TakeDamage,target,owner,owner,100.0,DMG_ENERGYBEAM);
            } else if(!touch) g_wallInside[owner][target]=false;
        }
    }
}
stock CTPlacePing(id)
{
    if(!AliveCT(id)) {Chat(id,"Ping göndermek için yaşayan gardiyan olmalısın.");return;}
    if(g_bridgeRoundClosed || g_game || g_rocketActive) return;
    new Float:now=get_gametime();if(now<g_pingNext[id]) return;g_pingNext[id]=now+1.0;
    new aim[3];get_user_origin(id,aim,3);
    new Float:a[3],Float:b[3],Float:l[3],Float:r[3],Float:f[3],Float:bk[3];
    a[0]=float(aim[0]);a[1]=float(aim[1]);a[2]=float(aim[2])+4.0;
    b[0]=a[0];b[1]=a[1];b[2]=a[2]+112.0;
    l[0]=a[0]-24.0;l[1]=a[1];l[2]=a[2]+4.0;r[0]=a[0]+24.0;r[1]=a[1];r[2]=a[2]+4.0;
    f[0]=a[0];f[1]=a[1]-24.0;f[2]=a[2]+4.0;bk[0]=a[0];bk[1]=a[1]+24.0;bk[2]=a[2]+4.0;
    LaserWallSendBeam(a,b,40,220,80,8,25);LaserWallSendBeam(l,r,40,220,80,8,25);LaserWallSendBeam(f,bk,40,220,80,8,25);
    client_print_color(0,id,"^1[^3FeliciaClan^1] ^3%n ^1konuma ping gönderdi.",id);
}
public CmdPing(id) {CTPlacePing(id);return PLUGIN_HANDLED;}
public CmdLaserWall(id) {CreateLaserWall(id);return PLUGIN_HANDLED;}

public ctmenu(id) {
    if(get_member(id, m_iTeam)!=TEAM_CT) client_print_color(id, id, "^1[^3%s^1]^4 CTMenuye sadece ^1gardiyanlar^4 girebilir.",serverTAG);
    else if(!is_user_alive(id)) client_print_color(id, id, "^1[^3%s^1]^4 CTMenuye ^1oluyken^4 giremezsin.",serverTAG);
    else {

        new ndmenu[128];
        formatex(ndmenu, charsmax(ndmenu),"\wPremium JailBreak Modu^n\r»\w TeamSpeak3: \dFeliciaClan");
        new Menu = RA_MenuCreate(ndmenu, "ctmenu2");

        switch(yarismaKontrol) {

            case 1 : RA_MenuAddItem(Menu,"\wGardiyanlara \d(\rGodmode\d) \wve \d(\rHP\d)\w Ver. \r(\wADMINLIK YARISI AKTIF\r)","1");

            default : {
                switch(godKontrol) {
                    case 0 : RA_MenuAddItem(Menu,"\wSonraki El \d(\rGodmode\d)\w Almayı Ac.","1");
                    case 1 : RA_MenuAddItem(Menu,"\wSonraki El \d(\yGodmode\d)\w Alinabilecek.","1");
                    default : RA_MenuAddItem(Menu,"\wGardiyanlara \d(\rGodmode\d) \wve \d(\rHP\d)\w Ver.","1");
                }
            }
        }

        switch(hardkomutKontrol)
        {
            case 0 : RA_MenuAddItem(Menu, fmt("\wSonraki El \d(\rHard Komut\d)\w Almayı Ac.."), "99");
            case 1 : RA_MenuAddItem(Menu, fmt("\wSonraki El \d(\yHard Komut\d)\w Alinabilecek."), "99");
            default : RA_MenuAddItem(Menu, fmt("\yHard Komut \wDurumunu \r%s.", Hard_Komut() ? "KAPAT" : "AC"), "99");
        }

        RA_MenuAddItem(Menu, "\wAyarlari Eski Haline Getir.", "2");
        menu_addblank(Menu, 0);
		

        formatex(ndmenu, charsmax(ndmenu), "%s", (godKontrol!=1) ? "\wOyunlar \d(\rNEW!\d)":"\dOyunlar \r(\wKAPALI\r)" );
        RA_MenuAddItem(Menu, ndmenu, "3");

        RA_MenuAddItem(Menu,"\wMenuler","4");
        RA_MenuAddItem(Menu,"\wKoruma Menusu","5");

        formatex(ndmenu, charsmax(ndmenu), "%s", get_entvar(id, var_takedamage) ? "\wIsinlama Menusu \r(\wKAPALI\r)":"\wIsinlama Menusu");
        RA_MenuAddItem(Menu, ndmenu, "10");

        formatex(ndmenu, charsmax(ndmenu), "%s",yardimSayac[id] ? "\dGardiyan Yardim Menu \r(\wKAPALI\r)":"\wGardiyan Yardim Menu");
        RA_MenuAddItem(Menu, ndmenu, "7");

        RA_MenuAddItem(Menu,"\wSon Olen Oyuncuyu Revle","11");
        RA_MenuAddItem(Menu,"\wHerkesin HP'sini\r 100\y Yap","8");
        RA_MenuAddItem(Menu,"\wHucre Kapisini \rAc\d/\rKapat ","6");
        RA_MenuAddItem(Menu,"\wAdminlik Yarismasi","13");
        RA_MenuAddItem(Menu,"\wMuzikleri \wDurdur.","12");
        RA_MenuAddItem(Menu,"\wAktif Oyunu Durdur","90");
        RA_MenuAddItem(Menu,"\wPet Turnuvası","91");
        RA_MenuAddItem(Menu,"\wLazer Duvarı \d[\yTurda 1 kez\d]","92");
        RA_MenuAddItem(Menu,"\wPing Gönder \d[\ySağ tık\d]","93");

        menu_setprop(Menu, MPROP_NUMBER_COLOR, "\r");
        menu_setprop(Menu, MPROP_NEXTNAME, "\wDiger Sayfa");
        menu_setprop(Menu, MPROP_BACKNAME, "\wOnceki Sayfa");
        menu_setprop(Menu, MPROP_EXITNAME, "\wCikis");
        FC_CTMenuDisplay(id, Menu);
    }

    return PLUGIN_HANDLED;
}

public ctmenu2(id, menu, item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(item == MENU_EXIT || get_member(id, m_iTeam)!=TEAM_CT || !is_user_alive(id)) { menu_destroy(menu); return PLUGIN_HANDLED; }

    new data[6], key; 
    menu_item_getinfo(menu, item, _, data, charsmax(data));
    key = str_to_num(data);

    switch(key) {
        case 91 : {if(LibraryExists("fc_pet",LibType_Library)) fc_pet_admin_open(id);else Chat(id,"Pet Turnuvası plugini yüklü değil.");}
        case 92 : CreateLaserWall(id);
        case 93 : CTPlacePing(id);
        case 90 : {BridgeReset(CT_STOP_MENU,true);ctmenu(id);}
        case 1 : {
            switch(yarismaKontrol) 
            {
                case 1 : {
                    godver();
                    rg_send_audio(0, ctmenu_godmode);

                    client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan tum gardiyanlara ^1 Godmode ve HP^4 verdi. ^1(^3GODLU ADMINLIK YARISI AKTIF !!!^1)", id);
                }
                default : {
                    switch(godKontrol) {
                        case 0 : {
                            if(SuankiRound < SiradakiAlinacakEl[0] && DahaOnceAldi[0]) {
                                client_print_color(id, id, "^1[^3%s^1]^4 Sadece 3 elde bir god alabilirsin.",serverTAG);
                                ctmenu(id);
                                return PLUGIN_HANDLED;
                            }
                            godKontrol=1;
                            DahaOnceAldi[0] = true;
                            Deger[0] = SuankiRound; // Bugun
                            SiradakiAlinacakEl[0] = Deger[0] + 3; // Siradaki El = Bugun + 3
                            rg_send_audio(0, ctmenu_bildirim);

                            client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan diger el^1 Godmode ve HP^4 almayi acti.", id);
                        }
                        case 1 : client_print_color(id, id, "^1[^3%s^1]^4 Diger el ^1Godmode ve HP^4 alabileceksin.",serverTAG);

                        default : {
                            godver();
                            rg_send_audio(0, ctmenu_godmode);

                            client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan tum gardiyanlara ^1 Godmode ve HP^4 verdi.", id);
                        }
                    }
                }
            }
            ctmenu(id);
        } 
        case 2 : {
            ayarsifirla();
            rg_send_audio(0, ctmenu_ayarlarisifirla);

            new num= get_playersnum_ex(GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");
            if(num==1) tdisarmmenu(id);
            else ctmenu(id);
            
            client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1ayarlari ^4eski haline getirdi.", id);
        }
        case 3 : {
            if(godKontrol!=1)
                oyunoncesi(id);

            else {
                ctmenu(id);
                client_print_color(id, id, "^1[^3%s^1]^4 Diger el ^1Godmode ve HP^4 alacagin icin ^3oyunlar menusune^1 giremezsin.", serverTAG);
            }
        }

        case 4 : menuler(id);
        case 5 : korumamenu(id);

        case 6 : {
            hucrekapisiniac(id);
            ctmenu(id);
        }
        case 7 : gardiyanyardim(id);
        case 8 : {
            yuzle(id);
            client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1herkesin hp'sini^3 100 yapti.", id);
            ctmenu(id);
        }
        //case 9 : 
        case 10 : isinlamenu(id);
        case 11 : sonolenrev(id), ctmenu(id);
        case 12 : client_cmd(0, "stopsound"), client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1tum muzikleri^3 durdurdu.", id), ctmenu(id);
        case 13 : adminlik(id);
        case 99 :
        {
            switch(hardkomutKontrol) 
            {
                case 0 :
                {
                    if(SiradakiAlinacakEl[1] > SuankiRound && DahaOnceAldi[1]) {
                        client_print_color(id, id, "^1[^3%s^1]^4 Sadece 3 elde bir hard komut alabilirsin.",serverTAG);
                        ctmenu(id);
                        return PLUGIN_HANDLED;
                    }
                    hardkomutKontrol=1;
                    DahaOnceAldi[1] = true;
                    Deger[1] = SuankiRound; // Bugun
                    SiradakiAlinacakEl[1] = Deger[1] + 3; // Siradaki El = Bugun + 3

                    rg_send_audio(0, HardKomutSounds[1]);

                    client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan diger el^1 Hard Komut^4 acti.", id);
                }
                case 1 : client_print_color(id, id, "^1[^3%s^1]^4 Diger el ^1Hard Komut^4 alabileceksin.",serverTAG);
                default :
                {
                    if(Hard_Komut())
                    {
                        set_pcvar_num(bh_enabled, 1);

                        Hard_KomutKapat()
                        CHard_KomutKapat()
                        client_print_color(0, 0, "^1[^3 %s ^1] ^4Hard Komut ^3%n ^4Adli Gardiyan Tarafindan Kapatildi", serverTAG,id);
                    }
                    else
                    {
                        set_pcvar_num(bh_enabled, 0);

                        Hard_KomutAc()
                        CHard_KomutAc()
                        rg_send_audio(0, HardKomutSounds[0]);
                        client_print_color(0, 0, "^1[^3 %s ^1] ^4Hard Komut ^3%n ^4Adli Gardiyan Tarafindan Acildi", serverTAG,id);
                    }
                }
            }
            ctmenu(id);
        }
    }

    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

public oyunoncesi(id) {

    new ndmenu[128];
    formatex(ndmenu, charsmax(ndmenu),"\w%s \d|| \wOyunlar Giris\d^nTum oyunlar yenilenmis ve guncellenmistir.",serverTAG);
    new Menu = RA_MenuCreate(ndmenu, "oyunoncesi2");

    RA_MenuAddItem(Menu,"\wGod Gerektirmeyen Oyunlar","1");

    formatex(ndmenu, charsmax(ndmenu), "\wGod Gerektiren Oyunlar %s^n", get_entvar(id, var_takedamage) ? "\r[\dKAPALI\r]":"\r[\wACIK\r]");
    RA_MenuAddItem(Menu, ndmenu, "2");

    menu_addtext(Menu, "\dGod \ryokken/varken \dde ilk menuden oyunlar oynatabilirsiniz.");
    menu_addtext(Menu, "\dAma God \ryokken\d ikinci menuden oyun oynatamazsiniz.");

    menu_setprop(Menu, MPROP_EXITNAME, "\wCikis");
    FC_CTMenuDisplay(id, Menu);
}

public oyunoncesi2(id, menu, item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(item == MENU_EXIT || get_member(id, m_iTeam)!=TEAM_CT) { menu_destroy(menu); return PLUGIN_HANDLED; }

    new data[6], key; 
    menu_item_getinfo(menu, item, _, data, charsmax(data));
    key = str_to_num(data);

    switch(key) {
        case 1 : godsuzoyun(id);
        case 2 : {
            if(!get_entvar(id, var_takedamage)) godoyun(id);
            else client_print_color(id, id, "^1[^3%s^1]^4 Bu menuye sadece ^1godmode aktifken^4 girebilirsin.",serverTAG), oyunoncesi(id);
        }
    }

    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

public godsuzoyun(id) {
    new ndmenu[128];
    formatex(ndmenu, charsmax(ndmenu),"\wGelismis Oyunlar^n\dBu oyunlar god gerektirmez ama cogu isyan atilmasini engeller.^nLutfen bunlari COK SIK oynatmayiniz!\r");
    new Menu = RA_MenuCreate(ndmenu, "godsuzoyun2");

    RA_MenuAddItem(Menu,"\wEklenen Oyunlar","90");
    RA_MenuAddItem(Menu,"\wEnfeksiyon Oyunu","1");
    RA_MenuAddItem(Menu,"\wGomulen Olur","3");
    RA_MenuAddItem(Menu,"\wCatisma Menu","9");
    RA_MenuAddItem(Menu,"\wSarkac Oyunu \dAut. EjderYa","4");
    RA_MenuAddItem(Menu,"\wAref","8");
    RA_MenuAddItem(Menu,"\wFreeze'lenen Olur \d(Sans)","11");
    RA_MenuAddItem(Menu,"\w300 Sparta Yeni \d(CT-T Kapisir)","7");
    RA_MenuAddItem(Menu,"\wSayiyi Bilen Kazanir","6");
    RA_MenuAddItem(Menu,"\wZombi Oyunu","2");
    RA_MenuAddItem(Menu,"\wHayalet","5");
    RA_MenuAddItem(Menu,"\wKorebe","10");
    RA_MenuAddItem(Menu,"\wGote Geldik","12");

    menu_setprop(Menu, MPROP_NEXTNAME, "\wDiger Sayfa");
    menu_setprop(Menu, MPROP_BACKNAME, "\wOnceki Sayfa");
    menu_setprop(Menu, MPROP_EXITNAME, "\wCikis");
    FC_CTMenuDisplay(id, Menu);
}

public godsuzoyun2(id, menu, item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(item == MENU_EXIT || get_member(id, m_iTeam)!=TEAM_CT) { menu_destroy(menu); return PLUGIN_HANDLED; }

    new data[6], key; 
    menu_item_getinfo(menu, item, _, data, charsmax(data));
    key = str_to_num(data);
    if(!BridgeLegacyChoice(id,"godsuzoyun2",key)) {menu_destroy(menu);return PLUGIN_HANDLED;}

    switch(key) {
        case 90 : BridgeExtraGames(id,false);
        case 1 : {
            new players[MAX_PLAYERS], num, kontrol=0; 
            get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");

            for(new i=0; i<num; i++) 
                if(g_infect[players[i]]) kontrol++;

            if(num>0 && kontrol<num) {

                new rand=players[random_num(0, num-1)];
                while(g_infect[rand]) { rand=players[random_num(0, num-1)]; }

                #if defined semiclip_cvaraktif 
                    set_pcvar_num(semiclip, 0);
                #endif
                viruskap(rand);
                enfeksiyonKontrol=true;

                client_print_color(0, id, "^1[^3%n^1]^4 adli oyuncuya ^1Enfeksiyon^4 bulasti.", rand);

            } else client_print_color(id, id, "^1[^3%s^1]^4 Enfeksiyon yayacak ^1Mahkum^4 yok.",serverTAG);
        }
        case 2 : zombi(id);

        case 3 : {
            set_pcvar_num(sv_gravity, 250);
            #if defined semiclip_cvaraktif 
                set_pcvar_num(semiclip, 1);
            #endif
            gomulenolur(id);

            client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1Gomulen Olur^4 oyunu baslatti.", id);
        }
        case 4 : {
            if(sarkacKontrol) 
                client_print_color(id, id, "^1[^3%s^1]^4 Sarkac suan zaten aktif.",serverTAG);
            else 
                client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1Sarkac^4 oyununu baslatti.", id), Oyunu_Baslat();
        }

        case 5 : {
            new players[MAX_PLAYERS], num, ids, TeamName:team; 
            get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_ExcludeBots);
            EnableHookChain(h_rSpeed);

            for(new i=0; i<num; i++) {
                ids=players[i];

                team=get_member(ids, m_iTeam);
                switch(team) {
                    case TEAM_TERRORIST : {
                        glowla(ids, 255, 255, 255);
                        set_entvar(ids, var_health, Float:100.0);
                    }
                    case TEAM_CT : {
                        glowla(ids, 0, 0, 255);
                        set_entvar(ids, var_health, Float:5000.0);
                        set_entvar(ids, var_movetype, MOVETYPE_NOCLIP);
                        set_entvar(ids, var_takedamage, DAMAGE_AIM);
                        
                        g_silahKontrol[ids]=true;
                        g_hiz[ids]=true;
                        set_entvar(ids, var_maxspeed, 650.0);
                        set_task_ex(0.1, "hayalet_aura", ids + task_HAYALET, .flags = SetTask_Repeat);
                    }
                    default : { continue; }
                }
                g_glow[ids]=true;
                rg_remove_all_items(ids), rg_give_item(ids, "weapon_knife");
            }

            client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1Hayalet^4 oyunu baslatti.", id);
            hucrekapisiniac(id);
        }
        case 6 : sayiyibilen(id);

        case 7 : {
            new players[MAX_PLAYERS], num, ids, TeamName:team;
            get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_ExcludeBots);
            set_pcvar_num(mp_infinite_ammo, 1);

            for(new i=0; i<num; i++) {
                ids=players[i];

                team=get_member(ids, m_iTeam);
                switch(team) {
                    case TEAM_TERRORIST : set_entvar(ids, var_health, Float:100.0);
                    case TEAM_CT : {
                        set_entvar(ids, var_takedamage, DAMAGE_AIM);
                        set_entvar(ids, var_health, Float:800.0);
                    }
                    default: { continue; }
                }

                g_silahKontrol[id]=true;
                rg_remove_all_items(ids),rg_give_item(ids, "weapon_knife");
                rg_give_item(ids, "weapon_deagle"),rg_give_item(ids, "weapon_shieldgun");
            }

            rg_send_audio(0, ctmenu_sparta);
            client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan^1 300 Sparta Yeni^4 oyununu baslatti. ^3CT-T Kapisacak!", id);
        }
        case 8 : {
            set_pcvar_num(mp_freeforall, 1);
            #if defined semiclip_cvaraktif 
                set_pcvar_num(semiclip, 0);
            #endif
            set_pcvar_num(mp_infinite_ammo, 1);

            new players[MAX_PLAYERS],num,ids; 
            get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");

            for(new i=0; i<num; i++) {
                ids=players[i];
                set_entvar(ids, var_effects, get_entvar(ids, var_effects) | EF_NODRAW); //set_entity_visibility(ids, 0);

                rg_remove_all_items(ids), rg_give_item(ids, "weapon_knife");
                rg_give_item(ids, "weapon_deagle");
            }

            aref = true;

            client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan^1 Aref^4 oyununu baslatti.", id);
        }
        case 9 : catismamenu(id);

        case 10 : {
            #if defined semiclip_cvaraktif 
                set_pcvar_num(semiclip, 1);
            #endif
            set_pcvar_num(mp_infinite_ammo, 1);
            new players[MAX_PLAYERS], num, ids, TeamName:team; 
            get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_ExcludeBots);

            for(new i=0; i<num; i++) {
                ids = players[i];

                team=get_member(ids, m_iTeam);
                switch(team) {
                    case TEAM_TERRORIST : {
                        set_entvar(ids, var_health, Float:100.0);
                        g_silahKontrol[ids]=false;
                        glowla(ids, 0, 255, 0), g_glow[ids]=true;

                        rg_remove_all_items(ids), rg_give_item(ids, "weapon_knife");
                        rg_give_item(ids, "weapon_deagle"), rg_give_item(ids, "weapon_m4a1"), rg_give_item(ids, "weapon_ak47");
                    }
                    case TEAM_CT : {
                        set_entvar(ids, var_takedamage, DAMAGE_AIM);
                        set_entvar(ids, var_health, Float:250.0);

                        rg_remove_all_items(ids), rg_give_item(ids, "weapon_knife");
                        set_entvar(ids, var_effects, get_entvar(ids, var_effects) | EF_NODRAW); //set_entity_visibility(ids, 0);
                        g_silahKontrol[ids]=true;
                    }
                }
            }	
                
            client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan^1 Korebe^4 oyununu baslatti.", id);
        }

        case 11 : {
            freezelenenolur(id);

            client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan^1 Freeze'lenen Olur^4 oyununu baslatti.", id);
        }
        case 12 : {
            gotegeldik(id); 

            client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan^1 Gote Geldik ^4oyununu baslatti.", id); 
        }
    }
    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

public freezelenenolur(id) {
    new ndmenu[128];
    formatex(ndmenu, charsmax(ndmenu),"\w%s \d|| \wFreeze'lenen Olur \d(Sans)", serverTAG);
    new Menu = RA_MenuCreate(ndmenu, "freezelenenolur2");

    RA_MenuAddItem(Menu,"\wRastgele Mahkum Freeze'le \r(Secilen Olecek!)","1");
    RA_MenuAddItem(Menu,"\wSon Mahkum Kalana Kadar Otomatik Freeze'le.","2");
    RA_MenuAddItem(Menu,"\wOyunu Durdur.","3");

    menu_setprop(Menu, MPROP_EXITNAME, "\wCikis");
    FC_CTMenuDisplay(id, Menu);
}

public freezelenenolur2(id, menu, item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(item == MENU_EXIT || get_member(id, m_iTeam)!=TEAM_CT) { menu_destroy(menu); return PLUGIN_HANDLED; }

    new data[6], key; 
    menu_item_getinfo(menu, item, _, data, charsmax(data));
    key = str_to_num(data);

    switch(key) {
        case 1 : {
            new players[MAX_PLAYERS], num; 
            get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");

            if(num>1) {
                new rastgele=players[random_num(0, num-1)];

                oyuncuDondur(rastgele);

                message_begin(MSG_ONE, ScreenFade, {0,0,0}, rastgele);
                write_short(1<<14); write_short(1<<9); write_short(1<<11);
                write_byte( 100 ); write_byte( 200 ); write_byte( 25 ); write_byte( 255 );
                message_end();

                set_task(2.0, "oyuncuOldur", rastgele);
                client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1%n^4 adli oyuncuyu rastgele freeze'ledi.^3 2 saniye sonra oldurulecek!", id, rastgele);
            
            } else client_print_color(id, id, "^1[^3%s^1]^4 Sona bir tane mahkum kaldi.",serverTAG);
        }
        case 2 : {
            new num= get_playersnum_ex(GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");

            if(num>1) {
                client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1Freeze'lenen Olur Otomatik ^4oyununu baslatti.", id);
                remove_task(task_FREEZEOYUNU);
                set_task_ex(2.0, "otoskk", task_FREEZEOYUNU, .flags = SetTask_Repeat);

            } else client_print_color(id, id, "^1[^3%s^1]^4 Bunu kullanabilmek icin en az^1 iki mahkum^4 gereklidir.", serverTAG);
        }
        case 3 : remove_task(task_FREEZEOYUNU), client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1Freeze'lenen Olur^4 oyununu durdurdu.", id);
    }

    freezelenenolur(id);
    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

public otoskk() {
    new players[MAX_PLAYERS], num;
    get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");

    if(num>1) {
        new rastgele=players[random_num(0, num-1)];

        oyuncuDondur(rastgele);

        set_task(1.9, "oyuncuOldur", rastgele);
        client_print_color(0, print_team_blue, "^1[^3%s^1]^4 Freeze'lenen Kisi > ^1%n^4", serverTAG, rastgele);

    } else remove_task(task_FREEZEOYUNU), client_print_color(0, print_team_blue, "^1[^3%s^1]^4 Freeze'lenen Olur oyununu ^1%n^4 kazandi.", serverTAG, players[0]);
}

public sayiyibilen(id) {
    new ndmenu[128];
    formatex(ndmenu, charsmax(ndmenu),"\w%s \d|| \wSayiyi Bilen Kazanir!",serverTAG);
    new Menu = RA_MenuCreate(ndmenu, "sayiyibilen2");

    RA_MenuAddItem(Menu,"\wRastgele Sayi Sec ve Kaydet!^n","1");
    menu_addtext(Menu, "\dIlk menuden rastgele sayiyi yaz kaydolsun.");
    menu_addtext(Menu, "\dSayiyi girdigin zaman oyun otomatik baslatilacaktir.");
    menu_addtext(Menu, "\dOyun kendisi say'dan \ryuksek/dusuk\d komutlari verecektir.");
    menu_addtext(Menu, "\dSayiyi ilk bilen kazanacak. Onun disinda herkes olecek!");

    menu_setprop(Menu, MPROP_EXITNAME, "\wCikis");
    FC_CTMenuDisplay(id, Menu);
}

public sayiyibilen2(id, menu, item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(item == MENU_EXIT || get_member(id, m_iTeam)!=TEAM_CT) { menu_destroy(menu); return PLUGIN_HANDLED; }

    new data[6], key; 
    menu_item_getinfo(menu, item, _, data, charsmax(data));
    key = str_to_num(data);

    if(key==1) 
        client_cmd(id, "messagemode Sayiyi_Bilen_Kazanir");

    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

public Sayiyi_Bilen_Kazanir_p(id) {
    if(!is_user_alive(id) || get_member(id, m_iTeam)!=TEAM_CT) 
        return PLUGIN_HANDLED;

    new say[32]; read_args(say, charsmax(say));
    remove_quotes(say);

    if(!is_str_num(say) || equal(say, ""))
        return PLUGIN_HANDLED;

    kayitliSayi=str_to_num(say);

    if(kayitliSayi<=0) { 
        client_print_color(id, id, "^1[^3%s^1]^4 Lutfen 0'dan buyuk sayi giriniz.",serverTAG);
        client_cmd(id, "messagemode Sayiyi_Bilen_Kazanir");
        return PLUGIN_HANDLED; 
    }

    sayiyibilenKontrol=true;
    client_print_color(id, id, "^1[^3%s^1]^4 Sayi ^1%d^4 olarak kaydedildi.", serverTAG, kayitliSayi);
    client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1Sayiyi Bilen Kazanir^4 oyununu baslatti.^3 Say'dan sayiyi tahmin edin.", id);
    client_print_color(0, id, "^1[^3%s^1]^4 Sayinin dogru cevaptan ^1yuksek/dusuk^3 bilgisi say'dan verecektir.", serverTAG);

    return PLUGIN_HANDLED;
}

public LegacyHookSay(id) {
    if(sayiyibilenKontrol) {
        new say[10]; read_args(say, charsmax(say)); 
        remove_quotes(say);

        if(is_str_num(say)) {
            if(get_member(id, m_iTeam)==TEAM_TERRORIST) {
                new miktar=str_to_num(say);

                if(miktar==kayitliSayi) {
                    client_print_color(0, print_team_blue, "^1[^3%n^1]^4 adli oyuncu ^1Sayiyi Bilen Kazanir^4 oyununu kazandi. ^3Dogru cevap > ^1%d^3.", id, kayitliSayi);

                    new players[MAX_PLAYERS], inum, ids; 
                    get_players_ex(players, inum, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");

                    for(new i=0; i<inum; i++) {
                        ids=players[i];

                        if(ids==id) 
                            continue;

                        kill(id, ids, "deagle");
                        //user_kill(ids, 1);
                    }
                    sayiyibilenKontrol=false;

                } else if(miktar<kayitliSayi) {

                    client_print_color(id, print_team_blue, "^1[^3%s^1]^4 Dogru cevap ^1%d ^4sayisindan daha ^3YUKSEK^4.",serverTAG, miktar);
                    return PLUGIN_HANDLED;
                } else {

                    client_print_color(id, print_team_blue, "^1[^3%s^1]^4 Dogru cevap ^1%d ^4sayisindan daha ^3DUSUK^4.",serverTAG, miktar);
                    return PLUGIN_HANDLED;
                }
            } else client_print_color(id, id, "^1[^3%s^1]^4 Sadece mahkumlar tahminde bulunabilir.",serverTAG);
        }
    }
    return PLUGIN_CONTINUE;
}

public hayalet_aura(id) {
    id = id - task_HAYALET;
    if(is_user_alive(id) && get_member(id, m_iTeam)==TEAM_CT) {

        new Float:origin[3]; get_entvar(id, var_origin, origin);

        message_begin(MSG_ALL, SVC_TEMPENTITY);
        write_byte(TE_DLIGHT);
        write_coord_f(origin[0]);
        write_coord_f(origin[1]);
        write_coord_f(origin[2]);
        write_byte(8);
        write_byte(255); write_byte(255); write_byte(255);
        write_byte(1);
        write_byte(0);
        message_end();

    } else remove_task(id+task_HAYALET);
}

public Oyunu_Baslat(){
    set_pcvar_num(sv_gravity, 800);
    set_pcvar_num(sv_parachute, 0);
    set_lights(aksamHava);
    sarkacKontrol = true;

    new Oyuncular[MAX_PLAYERS], T_Oyuncular; 
    get_players_ex(Oyuncular, T_Oyuncular, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");

    for ( new i ; i < T_Oyuncular ; i++ ) 
        Oyuncuyu_Oyuna_Ekle(Oyuncular[i]);

    Oyundisi_oyuncu_kontrolu();
}

public Oyuncuyu_Oyuna_Ekle(id){
    g_sarkac[id] = true;
    glowla(id, random_num(20, 200), random_num(20, 200), random_num(20, 200)), g_glow[id]=true;

    set_entvar(id, var_health, Float:float(random_num(90, 125)));
    set_task(float(id)/10.0,"Sarkac_Islemleri", id);	
}

public Oyundisi_oyuncu_kontrolu(){
    if(sarkacKontrol){
        new Oyuncular[MAX_PLAYERS],T_Oyuncular; 
        get_players_ex(Oyuncular, T_Oyuncular, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");

        for ( new i ; i < T_Oyuncular ; i++ ) 
            if(!g_sarkac[Oyuncular[i]]) Oyuncuyu_Oyuna_Ekle(Oyuncular[i]);

        set_task(5.0, "Oyundisi_oyuncu_kontrolu");
    }
}

public Sarkac_Islemleri(id){
    if(!sarkacKontrol || !is_user_alive(id))
        return PLUGIN_HANDLED;
    
    new T_Oyuncular = get_playersnum_ex(GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");

    if(T_Oyuncular == 1) {
        client_print_color(0, print_team_blue, "^1[^3%n^1]^4 adli oyuncu ^1Sarkac^4 oyununu kazandi.", id);
        Kazandi(id);
        set_task(1.0, "Kazandi", id);
        set_task(7.0, "Sifirla", id);
        sarkacKontrol = false;

    } else {

        new Float:vHIZ[3]; get_entvar(id, var_velocity, Float:vHIZ);  
        
        if(floatabs(vHIZ[2])>=random_float(1000.0,500.0)){
            if ( random_num( 0,1 ) == random_num( 0,1 ) ) set_entvar(id, var_velocity, Float:{0.0,0.0,0.0});

        } else if(vHIZ[2] == 0 && Duvar_Ici(id,-1.0) && !Duvar_Ici(id,1.0)){

            new Float:Konum[3]; get_entvar(id, var_origin, Konum);
            Konum[2] += 1.0;
            set_entvar(id, var_origin, Konum);
            set_entvar(id, var_velocity, Float:{0.0,0.0,300.0});
        }

        new Float:Cekim; get_entvar(id, var_gravity, Cekim);
        if ( random_num( 0,5 ) == random_num( 0,5 ) ){
            if ( Yerden_Yukseklik(id) > 750 )	Cekim = random_float(0.0,5.0);
            {
        
            if ( random_num(0,6) == random_num(0,5) ) set_entvar(id, var_velocity,	Float:{0.0,0.0,-555.0});
            else					Cekim = random_float(-3.0,5.0);
        
        }
        }
        else
            Cekim = random_float(-1.0,1.0);

        if(random_num(0,3)==random_num(0,3)) {
            new Float:rand=float(random_num(-10,1));
            if(rand>0.0) set_entvar(id, var_health, Float:get_entvar(id, var_health)+rand);
            else if(rand<0.0) {
                if(Float:get_entvar(id, var_health)+(rand)<=0.0) user_kill(id);
                else set_entvar(id, var_health, Float:get_entvar(id, var_health)+rand);
            }
        }
        set_entvar(id, var_gravity, Cekim);
        set_task(random_float(0.2,0.4), "Sarkac_Islemleri", id);
    }
    return PLUGIN_HANDLED;
}

public Kazandi(id){
    set_entvar(id, var_gravity, 0.2);
    set_entvar(id, var_velocity, Float:{0.0,0.0,0.0});
    set_entvar(id, var_takedamage, DAMAGE_NO);
    glowla(id, 20, 200, 20), g_glow[id]=true;

    const UnitSecond = (1<<12);
    message_begin(MSG_ONE_UNRELIABLE, ScreenFade, _, id);
    write_short(UnitSecond*5);
    write_short(UnitSecond*0);
    write_short(0x0000);
    write_byte(0); write_byte(255); write_byte(0);
    write_byte(180);
    message_end();
}

public Sifirla(id){
    
    set_entvar(id, var_health, Float:100.0);
    set_entvar(id, var_gravity, 1.0);
    set_entvar(id, var_takedamage, DAMAGE_AIM);

    if(g_glow[id]) 
        glowla(id, 0, 0, 0), g_glow[id]=false;
}

bool:Duvar_Ici(Id,Float:Sayi) {
    static Float:Origin[3]; get_entvar(Id, var_origin, Origin);
    Origin[2] += Sayi;

    engfunc(EngFunc_TraceHull, Origin, Origin, IGNORE_MONSTERS, pev(Id, pev_flags) & FL_DUCKING ? HULL_HEAD : HULL_HUMAN, 0, 0);
    if (get_tr2(0, TR_StartSolid))
        return true;

    return false;
}

Yerden_Yukseklik(Id) {
    new Yukseklik , Durum;
    for ( new i ; Durum != 1; i++){
        static Float:Origin[3]; get_entvar(Id, var_origin, Origin );
        Origin[2] -= i*10.0;

        engfunc(EngFunc_TraceHull, Origin, Origin, IGNORE_MONSTERS, pev(Id, pev_flags) & FL_DUCKING ? HULL_HEAD : HULL_HUMAN, 0, 0);
        if (get_tr2(0, TR_StartSolid))
            Durum = 1 , Yukseklik = i * 10;
    }
    return Yukseklik;
}

public gomulenolur(id) {
    new ndmenu[128], players[MAX_PLAYERS], num, gomulensayisi=0; 
    get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");

    for(new i=0; i<num; i++) { 
        if(Stuck(players[i])) gomulensayisi++; 
    }
    client_print_color(0, print_team_blue, "^1[^3%s^1]^4 Toplam Yasayan Mahkum : ^1%d ^3-^4 Gomulen Mahkum : ^1%d",serverTAG, num, gomulensayisi);

    formatex(ndmenu, charsmax(ndmenu),"\w%s \d|| \wGomulen Olur^n\dToplam Mahkum : \r%d \w-\d Gomulen Mahkum : \r%d",serverTAG, num, gomulensayisi);
    new Menu = RA_MenuCreate(ndmenu, "gomulenolur2");

    RA_MenuAddItem(Menu,"\wMahkumlari Gom. \rGomulen Olecektir!","1");
    RA_MenuAddItem(Menu,"\wMahkumlari Kaldir.","2");
    RA_MenuAddItem(Menu,"\wOyunu Durdur.^n","3");
    menu_addtext(Menu, "\dGomulen 3 saniye icinde oldurulecektir.");
    menu_addtext(Menu, "\dHerkes gomulurse kaldirarak oyuna devam edebilirsiniz.");
    menu_addtext(Menu, "\dOyunu durdurursan kimse olmeyecektir.");
    menu_addtext(Menu, "\dSona kalan oyunu kazanacaktir.");

    menu_setprop(Menu, MPROP_EXITNAME, "\wCikis");
    FC_CTMenuDisplay(id, Menu);
}

public gomulenolur2(id, menu, item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(item == MENU_EXIT || get_member(id, m_iTeam)!=TEAM_CT) { menu_destroy(menu); return PLUGIN_HANDLED; }

    new data[6], key; 
    menu_item_getinfo(menu, item, _, data, charsmax(data));
    key = str_to_num(data);
    if(!BridgeLegacyChoice(id,"gomulenolur2",key)) {menu_destroy(menu);return PLUGIN_HANDLED;}

    switch(key) {
        case 1 : {
            rg_send_audio(0, ctmenu_gomulunce);

            new players[MAX_PLAYERS], num, ids;
            get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");

            
            for(new i=0; i<num; i++) {
                ids=players[i];
                
                if(!Stuck(ids)) {
                    C4Bury(ids,false,0.0);
                }
            }
            set_pcvar_num(mp_forcecamera, 2);

            set_task(3.2, "gomulenoldur", task_GOMULENOLUR);

            client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1mahkumlari^4 gomdu. ^3Gomulenler^1 3sn ^4icinde olecektir!", id);
        }
        case 2 : {
            kaldir();
            client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1mahkumlari^4 kaldirdi.", id);
        }
        case 3 : remove_task(task_GOMULENOLUR), client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1Gomulen Olur^4 oyununu durdurdu.", id);
    }
    gomulenolur(id);
    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

public gomulenoldur() {
    new players[MAX_PLAYERS], num, ids; 
    get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");

    for(new i=0; i<num; i++) {
        ids=players[i];
        if(Stuck(ids)) {
            user_kill(ids);
            client_print(ids, print_center, "Gomuldugun icin olduruldun.");
        }
    }
}

public zombi(id) {
    new ndmenu[128];
    formatex(ndmenu, charsmax(ndmenu),"\w%s \d|| \wZombi Oyun Menusu\d",serverTAG);
    new Menu = RA_MenuCreate(ndmenu, "zombi2");
        
    RA_MenuAddItem(Menu,"\wKolay Zombi Baslat.\r[\w5000 HP\r]","1");
    RA_MenuAddItem(Menu,"\wOrta Zombi Baslat.\r[\w10000 HP\r]","2");
    RA_MenuAddItem(Menu,"\wZor Zombi Baslat.\r[\w20000 HP\r]","3");

    menu_setprop(Menu, MPROP_EXITNAME, "\wCikis");
    FC_CTMenuDisplay(id, Menu);
}

public zombi2(id, menu, item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(item == MENU_EXIT || get_member(id, m_iTeam)!=TEAM_CT) { menu_destroy(menu); return PLUGIN_HANDLED; }

    new data[6], key, players[MAX_PLAYERS], num, ids, TeamName:team;
    menu_item_getinfo(menu, item, _, data, charsmax(data));
    key = str_to_num(data);
    if(!BridgeLegacyChoice(id,"zombi2",key)) {menu_destroy(menu);return PLUGIN_HANDLED;}

    get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_ExcludeBots);
    set_lights(aksamHava); 
    EnableHookChain(h_rSpeed);
    set_pcvar_num(mp_infinite_ammo, 1);

    switch(key) {
        case 1 : {
            for(new i=0; i<num; i++) {
                ids=players[i];

                
                team=get_member(ids, m_iTeam);
                switch(team) {
                    case TEAM_TERRORIST : {
                        set_entvar(ids, var_health, Float:100.0);
                        rg_give_item(ids, "weapon_m4a1"), rg_give_item(ids, "weapon_ak47"), rg_give_item(ids, "weapon_xm1014");
                        glowla(ids, 255, 0, 0), g_glow[ids]=true;
                    }
                    case TEAM_CT : {
                        set_entvar(ids, var_health, Float:5000.0);
                        glowla(ids, 0, 0, 255), g_glow[ids]=true;
                        rg_remove_all_items(ids), rg_give_item(ids, "weapon_knife");
                        g_silahKontrol[ids]=true;
                        set_entvar(ids, var_takedamage, DAMAGE_AIM);

                        g_hiz[ids]=true;
                        set_entvar(ids, var_maxspeed, 650.0);
                    }
                }
                
            }
            client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1Kolay Zombi^4 oyununu baslatti.^3 CT'nin Cani 5000 HP", id);
        }
        case 2 : {
            for(new i=0; i<num; i++) {
                ids=players[i];

                
                team=get_member(ids, m_iTeam);
                switch(team) {
                    case TEAM_TERRORIST : {
                        set_entvar(ids, var_health, Float:100.0);
                        rg_give_item(ids, "weapon_m4a1"), rg_give_item(ids, "weapon_ak47"), rg_give_item(ids, "weapon_xm1014");
                        glowla(ids, 255, 0, 0), g_glow[ids]=true;
                    }
                    case TEAM_CT : {
                        set_entvar(ids, var_health, Float:10000.0);
                        glowla(ids, 0, 0, 255), g_glow[ids]=true;
                        rg_remove_all_items(ids), rg_give_item(ids, "weapon_knife");
                        g_silahKontrol[ids]=true;
                        set_entvar(ids, var_takedamage, DAMAGE_AIM);

                        g_hiz[ids]=true;
                        set_entvar(ids, var_maxspeed, 650.0);
                    }
                }
                
            

            }
            client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1Orta Zombi^4 oyununu baslatti.^3 CT'nin Cani 10000 HP", id);
        }
        case 3 : {
            for(new i=0; i<num; i++) {
                ids=players[i];

                
                team=get_member(ids, m_iTeam);
                switch(team) {
                    case TEAM_TERRORIST : {
                        set_entvar(ids, var_health, Float:100.0);
                        rg_give_item(ids, "weapon_m4a1"), rg_give_item(ids, "weapon_ak47"), rg_give_item(ids, "weapon_xm1014");
                        glowla(ids, 255, 0, 0), g_glow[ids]=true;
                    }
                    case TEAM_CT : {
                        set_entvar(ids, var_health, Float:20000.0);
                        glowla(ids, 0, 0, 255), g_glow[ids]=true;
                        rg_remove_all_items(ids), rg_give_item(ids, "weapon_knife");
                        g_silahKontrol[ids]=true;
                        set_entvar(ids, var_takedamage, DAMAGE_AIM);
                        g_hiz[ids]=true;
                        set_entvar(ids, var_maxspeed, 650.0);
                    }
                }
                

            }
            client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1Zor Zombi^4 oyununu baslatti.^3 CT'nin Cani 20000 HP", id);
        }
    }
    hucrekapisiniac(id);
    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

public viruskap(id) {
    if(!AliveT(id) || g_infect[id]) return;
    g_infect[id]=true;g_bridgeUID[id]=get_user_userid(id);enfeksiyonKontrol=true;
    glowla(id,0,255,0);g_glow[id]=true;
    message_begin(MSG_ONE_UNRELIABLE,ScreenFade,_,id);write_short(2<<10);write_short(1<<7);write_short(1<<12);
    write_byte(0);write_byte(255);write_byte(0);write_byte(200);message_end();
    if(!task_exists(TASK_LEGACY_INFECTION)) {g_bridgeInfectHP=get_gametime()+0.5;g_bridgeInfectAura=0.0;set_task(0.1,"BridgeInfectionTick",TASK_LEGACY_INFECTION,_,_,"b");}
}

public infect_aura(id) {
    id=id- task_ENFEKSIYON;
    if(is_user_alive(id) && g_infect[id]) {
        new Float:origin[3]; get_entvar(id, var_origin, origin);

        message_begin(MSG_ALL, SVC_TEMPENTITY);
        write_byte(TE_DLIGHT);
        write_coord_f(origin[0]);
        write_coord_f(origin[1]);
        write_coord_f(origin[2]);
        write_byte(12);
        write_byte(0); write_byte(255); write_byte(0);
        write_byte(1);
        write_byte(0);
        message_end();

    }
}

public infect_touch(id) {
    id=id- task_ENFEKSIYON;
    if(is_user_alive(id) && g_infect[id]) {

        new players[MAX_PLAYERS], num, ids, Float:origin1[3], Float:origin2[3], Float:dist;
        get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");

        for(new i=0; i<num; i++) {
            ids=players[i];
            if(ids!=id && !g_infect[ids]) {

                get_entvar(id, var_origin, origin1);
                get_entvar(ids, var_origin, origin2);
                dist = get_distance_f(origin1,origin2);

                if(dist<40.0) 
                    viruskap(ids);
            }
        }

    } else g_infect[id]=false, remove_task(id+task_ENFEKSIYON);
}

public infect_nvg(id) {
    id=id- task_ENFEKSIYON;
    if(is_user_alive(id) && g_infect[id]) {

        if(get_entvar(id, var_health)>3.0) set_entvar(id, var_health, Float:get_entvar(id, var_health)-3.0);
        else user_kill(id);
    }
}

public godoyun(id) {
    new ndmenu[128];
    formatex(ndmenu, charsmax(ndmenu),"\w%s \d|| \wGelismis Oyunlar\d [GODLU] ",serverTAG);
    new Menu = RA_MenuCreate(ndmenu, "godoyun2");

    RA_MenuAddItem(Menu,"\wEklenen Oyunlar","90");
    RA_MenuAddItem(Menu,"\wKus AVI","1");
    RA_MenuAddItem(Menu,"\wSquid Game","34");
    RA_MenuAddItem(Menu,"\wPubg","35");
    RA_MenuAddItem(Menu,"\wUcan Pipi","2");
    RA_MenuAddItem(Menu,"\wKule","4");
    RA_MenuAddItem(Menu,"\wKamikaze","12");
    RA_MenuAddItem(Menu,"\wArkada Kalma","15");	
    RA_MenuAddItem(Menu,"\wHak GG \d(Piclik)","11");
    RA_MenuAddItem(Menu,"\wGozume Gozukme","8");
    RA_MenuAddItem(Menu,"\wEnfeksiyonlu Lazer","14");
    RA_MenuAddItem(Menu,"\w300 Sparta \d(Rastgele mahkum glowlanir onu oldureceksin.)","6");
    RA_MenuAddItem(Menu,"\wGondol","3");
    RA_MenuAddItem(Menu,"\wYakala Mod","5");
    RA_MenuAddItem(Menu,"\wVatan Haini","7");
    #if defined semiclip_cvaraktif 
        RA_MenuAddItem(Menu,"\wSIKISTIRMA","9");
    #endif
    RA_MenuAddItem(Menu,"\wBombaci Mulayim","13");

    menu_setprop(Menu, MPROP_NEXTNAME, "\wDiger Sayfa");
    menu_setprop(Menu, MPROP_BACKNAME, "\wOnceki Sayfa");
    menu_setprop(Menu, MPROP_EXITNAME, "\wCikis");
    FC_CTMenuDisplay(id, Menu);
}

public godoyun2(id, menu, item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(item == MENU_EXIT || get_member(id, m_iTeam)!=TEAM_CT) { menu_destroy(menu); return PLUGIN_HANDLED; }

    new data[6], key; 
    menu_item_getinfo(menu, item, _, data, charsmax(data));
    key = str_to_num(data);
    if(!BridgeLegacyChoice(id,"godoyun2",key)) {menu_destroy(menu);return PLUGIN_HANDLED;}

    if(get_entvar(id, var_takedamage)) godver();
    switch(key) {
        case 90 : BridgeExtraGames(id,true);
        
        case 1 : {
            set_lights(aksamHava);
            set_pcvar_num(sv_gravity, 250);
            #if defined semiclip_cvaraktif 
                set_pcvar_num(semiclip, 1);
            #endif

            new players[MAX_PLAYERS], num, ids, TeamName:team; 
            get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_ExcludeBots);

            for(new i=0; i<num; i++) {
                ids=players[i];

                
                team=get_member(ids, m_iTeam);
                switch(team) {
                    case TEAM_TERRORIST : glowla(ids, 255, 0, 0), g_glow[ids]=true;
                    case TEAM_CT : {
                        rg_give_item(ids, "weapon_g3sg1"), rg_give_item(ids, "weapon_scout");
                        glowla(ids, 0, 0, 255), g_glow[ids]=true;
                    }
                }
                
            }
            client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1Kus AVI^4 oyununu baslatti.", id);
            islemlermenu(id);
        }
        case 2 : {
            set_lights(aksamHava);
            new players[MAX_PLAYERS], num, ids, TeamName:team; 
            get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_ExcludeBots);

            for(new i=0; i<num; i++) {
                ids=players[i];

                
                team=get_member(ids, m_iTeam);
                switch(team) {
                    case TEAM_TERRORIST : glowla(ids, 255, 0, 0), g_glow[ids]=true;
                    case TEAM_CT : {
                        rg_give_item(ids, "weapon_g3sg1"), rg_give_item(ids, "weapon_scout");
                        glowla(ids, 0, 0, 255), g_glow[ids]=true;
                    }
            }
                

            }
            client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1Ucan Pipi^4 oyununu baslatti.", id);
            ucanpipi(id);
        }
        case 3 : {
            set_pcvar_num(sv_parachute, 1);
            gondol(id);
            client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1Gondol^4 oyununu baslatti.", id);
        }

        case 4 : kule(id);
        case 5 : {
            yakalaKontrol=true;
            EnableHookChain(h_rSpeed);
            #if defined semiclip_cvaraktif 
                set_pcvar_num(semiclip, 1);
            #endif
            new players[MAX_PLAYERS], num, ids, TeamName:team;
            get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_ExcludeBots);

            for(new i=0; i<num; i++) {
                ids=players[i];

                
                team=get_member(ids, m_iTeam);
                switch(team) {
                    case TEAM_TERRORIST : {
                        set_entvar(ids, var_health, Float:100.0);
                        glowla(ids, 255, 0, 0);
                    }
                    case TEAM_CT : {
                        g_hiz[ids]=true;
                        set_entvar(ids, var_maxspeed, 650.0);
                        glowla(ids, 0, 0, 255);
                    }
                    default : { continue; }
                }

                g_glow[ids]=true;
                g_silahKontrol[ids]=true;
                rg_remove_all_items(ids), rg_give_item(ids, "weapon_knife");
                

            }

            islemlermenu(id);
            client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1Yakala Mod^4 oyununu baslatti.", id);
        }
        case 6 : {
            new players[MAX_PLAYERS], num, ids;
            get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");

            if(num>0) {
                new rastgele = players[random_num(0, num-1)];

                glowla(rastgele, 255, 255, 255), g_glow[rastgele]=true;

                for(new i=0; i<num; i++) {
                    ids=players[i];

                    
                    set_entvar(ids, var_health, Float:100.0);
                    rg_remove_all_items(ids), rg_give_item(ids, "weapon_knife");
                    rg_give_item(ids, "weapon_deagle"), rg_give_item(ids, "weapon_shieldgun");
                    g_silahKontrol[ids]=true;
                    
                }
                rg_send_audio(0, ctmenu_sparta);

                client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan^1 300 Sparta ^4oyununu baslatti. ^3Glowlu Kisiyi Koruyun!", id);
            
            } else client_print_color(id, id, "^1[^3%s^1]^4 Mahkum yok.",serverTAG);
        }

        case 7 : hainvatan(id);
        case 8 : {
            #if defined semiclip_cvaraktif 
                set_pcvar_num(semiclip, 0);
            #endif
            new players[MAX_PLAYERS], num, ids, TeamName:team; 
            get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_ExcludeBots);

            for(new i=0; i<num; i++) {
                ids = players[i];

                
                team=get_member(ids, m_iTeam);
                if(team==TEAM_TERRORIST) {
                    set_entvar(ids, var_health, Float:100.0);
                    set_entvar(ids, var_effects, get_entvar(ids, var_effects) | EF_NODRAW); //set_entity_visibility(ids, 0);

                } else if(team!=TEAM_CT) { continue; }

                rg_remove_all_items(ids), rg_give_item(ids, "weapon_knife");
                g_silahKontrol[id]=true;
                
            }

            gozumegozukme(id);
            client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan^1 Gozume Gozukme ^4oyununu baslatti.", id);
        }
        #if defined semiclip_cvaraktif 
            case 9 : set_pcvar_num(semiclip, 0), sikistirma(id);
        #endif
        case 11 : {
            #if defined semiclip_cvaraktif 
                set_pcvar_num(semiclip, 1);
            #endif
            set_pcvar_num(sv_parachute, 0);

            new players[MAX_PLAYERS], num, ids; 
            get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");

            for(new i=0; i<num; i++) {
                ids=players[i];

                
                rg_remove_all_items(ids), rg_give_item(ids, "weapon_knife");
                g_silahKontrol[ids]=true;
                
            }
            piclik(id);

            client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan^1 Hak GG (Piclik) ^4oyununu baslatti.", id);
        }
        case 12 : {
            #if defined semiclip_cvaraktif 
                set_pcvar_num(semiclip, 1);
            #endif
            set_pcvar_num(sv_airaccelerate, -101);
            set_pcvar_num(sv_parachute, 0);

            new players[MAX_PLAYERS], num, ids;
            get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");
            
            for(new i=0; i<num; i++) {
                ids = players[i];

                
                set_entvar(ids, var_health, Float:100.0);
        
                g_silahKontrol[ids]=true;
                glowla(ids, 40, 250, 40), g_glow[ids]=true;
                rg_remove_all_items(ids), rg_give_item(ids, "weapon_knife");
                
            }

            hucrekapisiniac(id);
            client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan^1 Kamikaze ^4oyununu baslatti.", id);
        }
        case 13 : {
            new players[MAX_PLAYERS], num, ids, TeamName:team;
            get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_ExcludeBots);

            set_lights(aksamHava);
            for(new i=0; i<num; i++) {
                ids=players[i];

                
                team=get_member(ids, m_iTeam);
                switch(team) {
                    case TEAM_TERRORIST : {
                        set_entvar(ids, var_health, Float:200.0);
                        rg_remove_all_items(ids), rg_give_item(ids, "weapon_knife");

                        g_silahKontrol[ids]=true;
                        glowla(ids, 0, 255, 0), g_glow[ids]=true;
                    }
                    case TEAM_CT : {
                        rg_remove_all_items(ids), rg_give_item(ids, "weapon_knife");

                        rg_give_item(id, "weapon_hegrenade"), rg_set_user_bpammo(id, WEAPON_HEGRENADE, 200);
                    }
                }
            

            }

            islemlermenu(id);
            client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan^1 Bombaci Mulayim ^4oyununu baslatti.", id);
        }
        case 14 : {
            new players[MAX_PLAYERS], num, ids; 
            get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");

            for(new i=0; i<num; i++) {
                ids=players[i];

                
                set_entvar(ids, var_health, Float:225.0);
                glowla(ids, 255, 0, 0), g_glow[ids]=true;
                
            }

            set_lights(aksamHava);
            enfeklazer(id);
            client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan^1 Enfeksiyonlu Lazer ^4oyununu baslatti.", id);
        }
        case 15 : {
            client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan^1 Arkada Kalma ^4oyununu baslatti.", id);

            arkadaKalma(id);
        }
        case 34 : {
            client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan^1 Squid Game ^4oyununu baslatti.", id);

            for(new i = 1; i <= MaxClients; i++) 
            {
                if(is_user_alive(i) && get_member(i, m_iTeam) == TEAM_TERRORIST) {
                    oyuncuDondur(i);
                }
            }

            set_pcvar_num(sv_parachute, 0);
            set_pcvar_num(semiclip, 0);

            Hard_KomutAc();
            CHard_KomutAc();

            squidmenu(id);
        }
        case 35 : {
            hunger_baslat();
            rg_send_audio(0, ctmenu_pubg);
        }
    }
    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

public squidmenu(const id)
{
    new ndmenu[128];
    formatex(ndmenu, charsmax(ndmenu),"\w%s \d|| \wSquid Game",serverTAG);
    new Menu = RA_MenuCreate(ndmenu, "squidmenu2");

    RA_MenuAddItem(Menu,"\wNormal Ayarlarda Baslat","1");
    RA_MenuAddItem(Menu,"\wOrta Ayarlarda Baslat","2");
    RA_MenuAddItem(Menu,"\wHizli Ayarlarda Baslat","3");
    RA_MenuAddItem(Menu,"\wCok Hizli Ayarlarda Baslat","4");

    menu_setprop(Menu, MPROP_EXITNAME, "\wCikis");
    FC_CTMenuDisplay(id, Menu);
}

public squidmenu2(const id, const menu, const item)
{
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(item == MENU_EXIT) { menu_destroy(menu); return PLUGIN_HANDLED; }

    new data[6], key; 
    menu_item_getinfo(menu, item, _, data, charsmax(data));
    key = str_to_num(data);

    switch(key) 
    {
        case 1 : rg_send_audio(0, SquidSounds[0], PITCH_NORM);
        case 2 : rg_send_audio(0, SquidSounds[1], PITCH_NORM);
        case 3 : rg_send_audio(0, SquidSounds[2], PITCH_NORM);
        case 4 : rg_send_audio(0, SquidSounds[3], PITCH_NORM);
    }

    for(new i = 1; i <= MaxClients; i++) 
    {
        if(is_user_alive(i) && get_member(i, m_iTeam) == TEAM_TERRORIST) {
            oyuncuCoz(i);
        }
    }
    squidmenu(id);
    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

public arkadaKalma(id) {
    new ndmenu[128];
    formatex(ndmenu, charsmax(ndmenu),"\w%s \d|| \wArkada Kalma",serverTAG);
    new Menu = RA_MenuCreate(ndmenu, "arkadaKalma2");

    RA_MenuAddItem(Menu,"\wRastgele Oyuncu Sec ve Arkasinda Kalanlari Oldur","1");

    if(freezeKontrol) RA_MenuAddItem(Menu,"\wT'yi Coz. \r[\w/coz\r]^n","3");
    else RA_MenuAddItem(Menu,"\wT'yi Dondur. \r[\w/dondur\r]^n","2");

    RA_MenuAddItem(Menu,"\wHavayi Gunduz \rYap.","4");
    RA_MenuAddItem(Menu,"\wHavayi Aksam \rYap.","5");
    RA_MenuAddItem(Menu,"\wHavayi Tam Karanlik \rYap.^n","6");
        
    menu_addtext(Menu, "\dOyuncularin bir alanda dagilmalarini isteyin.^nHerhangi bir anda tum mahkumlari dondurun.");
    menu_addtext(Menu, "\dRastgele bir oyuncu secin. Bu oyuncunun arkasinda^nkalan kisiler oldurulucektir.");

    menu_setprop(Menu, MPROP_EXITNAME, "\wCikis");
    FC_CTMenuDisplay(id, Menu);
}

public arkadaKalma2(id, menu, item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(item == MENU_EXIT) { menu_destroy(menu); return PLUGIN_HANDLED; }

    new data[6], key; 
    menu_item_getinfo(menu, item, _, data, charsmax(data));
    key = str_to_num(data);

    switch(key) {
        case 1 : {
            new players[MAX_PLAYERS], num, ids; 
            get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_MatchTeam , "TERRORIST");

            new playerArkaci = players[random_num(0, num-1)];

            glowla(playerArkaci, 0, 255, 0); 
            g_glow[playerArkaci] = true;

            client_print_color(0, print_team_blue, "^1[^3%s^1]^4 Rastgele Secilen Oyuncu ^3> ^1%n. ^3Arkasinda kalan herkes ^4olduruldu!", serverTAG, playerArkaci);

            for(new i=0; i<num; i++) {
                ids = players[i]; 

                if(ids != playerArkaci && arkadaMi(playerArkaci, ids)) {
                    kill(playerArkaci, ids, "deagle");
                }
            }

        }
        case 2 : dondur(id);
        case 3 : coz(id);
        case 4 : client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan havayi ^1gunduz^4 yapti.", id), set_lights(defaultHava);
        case 5 : client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan havayi ^1aksam^4 yapti.", id), set_lights(aksamHava);
        case 6 : client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan havayi ^1tam karanlik^4 yapti.", id), set_lights("a");
    }
    arkadaKalma(id);

    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

bool:arkadaMi(id1, id2) {
    
    new kordinat[3] , aimkordinat[3], kordinat2[3];

    get_user_origin(id1, kordinat, 0);
    get_user_origin(id1, aimkordinat, 3);

    get_user_origin(id2, kordinat2, 0);

    if(get_distance(kordinat2, aimkordinat) > get_distance(kordinat, aimkordinat)) 
        return true; // id2 arkada

    return false; // id2 onde
}

public enfeklazer(id) {
    new ndmenu[128];
    formatex(ndmenu, charsmax(ndmenu),"\w%s \d|| \wEnfeksiyonlu Lazer\d",serverTAG);
    new Menu = RA_MenuCreate(ndmenu, "enfeklazer2");
        
    RA_MenuAddItem(Menu,"\wRastgele Enfeksiyon ver.^n","1");
    RA_MenuAddItem(Menu,"\wT'yi Yanina Isinla. \r[\w/getir\r]","2");

    #if defined semiclip_cvaraktif 
        if(get_pcvar_num(semiclip)==1) RA_MenuAddItem(Menu,"\wSemiclip \rKapat.","3");
        else RA_MenuAddItem(Menu,"\wSemiclip \rAC.","1");
    #endif
    menu_addtext(Menu, "\dHerkesi lazere gotur ve dagilsinlar!");
    menu_addtext(Menu, "\d1'e basarak rastgele birine enfeksiyon ver ve oyun baslasin.");
    menu_addtext(Menu, "\dLazerde enfeksiyonludan kacarak olmeden sona kalan kazanir.");

    menu_setprop(Menu, MPROP_EXITNAME, "\wCikis");
    FC_CTMenuDisplay(id, Menu);
}

public enfeklazer2(id, menu, item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(item == MENU_EXIT || get_member(id, m_iTeam)!=TEAM_CT) { menu_destroy(menu); return PLUGIN_HANDLED; }

    new data[6], key; 
    menu_item_getinfo(menu, item, _, data, charsmax(data));
    key = str_to_num(data);
    if(!BridgeLegacyChoice(id,"enfeklazer2",key)) {menu_destroy(menu);return PLUGIN_HANDLED;}

    switch(key) {
        case 1 : {
            new players[MAX_PLAYERS], num, kontrol=0; 
            get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");

            for(new i=0; i<num; i++) 
                if(g_infect[players[i]]) kontrol++;

            if(num>0 && kontrol<num) {
                new rand=players[random_num(0, num-1)];
                while(g_infect[rand]) rand=players[random_num(0, num-1)];

                viruskap(rand);
                enfeksiyonKontrol=true;
                client_print_color(0, id, "^1[^3%n^1]^4 adli oyuncuya ^1Enfeksiyon^4 bulasti.^3 Lazerde olmeden sona kalan kazanir.", rand);
                
            } else client_print_color(id, id, "^1[^3%s^1]^4 Enfeksiyon yayacak ^1Mahkum^4 yok.", serverTAG);
        }
        case 2 : t_isinla(id);

        #if defined semiclip_cvaraktif
            case 3 : {
            
                if(get_pcvar_num(semiclip)==1) set_pcvar_num(semiclip, 0), client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1Semiclip'i^4 kapatti.", id);
                else set_pcvar_num(semiclip, 1), client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1Semiclip'i^4 acti.", id);
            }
        #endif
    }

    enfeklazer(id);
    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

public piclik(id) {
    new ndmenu[128];
    formatex(ndmenu, charsmax(ndmenu),"\w%s \d|| \wHak GG (Piclik)\d",serverTAG);
    new Menu = RA_MenuCreate(ndmenu, "piclik2");
        
    RA_MenuAddItem(Menu,"\wGravity \r[\w-9999\r]\w Yap. \d(Herkes Ucar)","1");
    RA_MenuAddItem(Menu,"\wGravity \r[\w9999\r]\w Yap. \d(Herkes Yere Cakilir)","2");
    RA_MenuAddItem(Menu,"\wGravity \r[\w-9999\r]\w Yap. \d(Sayda 800 yazacak \rTuzak!\d)","3");
    RA_MenuAddItem(Menu,"\wGravity \r[\w9999\r]\w Yap. \d(Sayda 800 yazacak \rTuzak!\d)","4");
    RA_MenuAddItem(Menu,"\wGravity \r[\w800\r]\w Yap. \d(Duzelt)","5");

    menu_setprop(Menu, MPROP_EXITNAME, "\wCikis");
    FC_CTMenuDisplay(id, Menu);
}

public piclik2(id, menu, item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(item == MENU_EXIT || get_member(id, m_iTeam)!=TEAM_CT) { menu_destroy(menu); return PLUGIN_HANDLED; }

    new data[6], key; 
    menu_item_getinfo(menu, item, _, data, charsmax(data));
    key = str_to_num(data);

    switch(key) {
        case 1 : set_pcvar_num(sv_gravity, -9999), client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan piclik oyununda^1 Gravity -9999 ^4yapti.", id);
        case 2 : set_pcvar_num(sv_gravity, 9999), client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan piclik oyununda^1 Gravity 9999 ^4yapti.", id);
        case 3 : set_pcvar_num(sv_gravity, -9999), client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan piclik oyununda^1 Gravity 800 ^4yapti.", id);
        case 4 : set_pcvar_num(sv_gravity, 9999), client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan piclik oyununda^1 Gravity 800 ^4yapti.", id);
        case 5 : set_pcvar_num(sv_gravity, 800), client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan piclik oyununda^1 Gravity 800 ^4yapti.", id);
    }

    piclik(id);
    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

public gotegeldik(id) {
    new ndmenu[128];
    formatex(ndmenu, charsmax(ndmenu),"\w%s \d|| \wGote Geldik\d", serverTAG);
    new Menu = RA_MenuCreate(ndmenu, "gotegeldik2");
        
    RA_MenuAddItem(Menu,"\wAimdeki Kisiyi Rastgele \wGlowla.","1");

    if(freezeKontrol) RA_MenuAddItem(Menu,"\wT'yi Coz. \r[\w/coz\r]^n","3");
    else RA_MenuAddItem(Menu,"\wT'yi Dondur. \r[\w/dondur\r]^n","2");

    menu_addtext(Menu, "\dAimi oyuncuya tutup 1'e basarak rastgele glow ver!");
    menu_addtext(Menu, "\dMavi gelirse yasayacak, kirmizi glow gelirse olecek!");

    menu_setprop(Menu, MPROP_EXITNAME, "\wCikis");
    FC_CTMenuDisplay(id, Menu);
}

public gotegeldik2(id, menu, item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(item == MENU_EXIT || get_member(id, m_iTeam)!=TEAM_CT) { menu_destroy(menu); return PLUGIN_HANDLED; }

    new data[6], key; 
    menu_item_getinfo(menu, item, _, data, charsmax(data));
    key = str_to_num(data);

    switch(key) {
        case 1 : {
            new ids,body; get_user_aiming(id, ids, body);

            if(is_user_alive(ids) && get_member(ids, m_iTeam)==TEAM_TERRORIST) {

                new radnom=random_num(1, 2);
                switch(radnom) {
                    case 1 : {
                        glowla(ids, 255, 0, 0);
                        set_task(2.0, "oyuncuOldur", ids);
                        client_print_color(0, id, "^1[^3%n^1]^4 adli oyuncuya kirmizi glow verildi ^1Gote Geldi^4. 2 saniye icinde oldurulecek!", ids);
                    }
                    case 2 : {
                        glowla(ids, 0, 0, 255); 
                        client_print_color(0, id, "^1[^3%n^1]^4 adli oyuncu ^1Gote Geldik^4 oyununda sansli cikti ^3mavi glow verildi.", ids);
                    }
                }
                g_glow[ids]=true;

            } else client_print_color(id, id, "^1[^3%s^1]^4 Baktigin yerde ^1Oyuncu ^4yok.", serverTAG);
        }

        case 2 : dondur(id);
        case 3 : coz(id);
    }

    gotegeldik(id);
    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

public sikistirma(id) {
    new ndmenu[128];
    formatex(ndmenu, charsmax(ndmenu),"\w%s \d|| \wSIKISTIRMA\d",serverTAG);
    new Menu = RA_MenuCreate(ndmenu, "sikistirma2");
        
    RA_MenuAddItem(Menu,"\wRastgele Mahkum Sec.","1");
    RA_MenuAddItem(Menu,"\wGeri Sayim Baslat.","2");
    RA_MenuAddItem(Menu,"\wSecilen mahkumu oldur.^n","3");

    menu_addtext(Menu, "\dSecilen mahkum geri sayim bitene kadar SIKISMAMALI!");
    menu_addtext(Menu, "\dSIKISIRSA secilen mahkumu oldur tusunu kullan!");
    menu_addtext(Menu, "\dVeya herhangi bir bug vs. yaparsa oldurebilirsin.");

    menu_setprop(Menu, MPROP_EXITNAME, "\wCikis");
    FC_CTMenuDisplay(id, Menu);
}

public sikistirma2(id, menu, item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(item == MENU_EXIT || get_member(id, m_iTeam)!=TEAM_CT) { menu_destroy(menu); return PLUGIN_HANDLED; }

    new data[6], key, players[MAX_PLAYERS], num; 
    menu_item_getinfo(menu, item, _, data, charsmax(data));
    key = str_to_num(data);

    get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");

    switch(key) {
        case 1 : {
            if(num>0) {
                set_pcvar_num(semiclip, 0);

                CHard_KomutAc();

                new rastgele=players[random_num(0, num-1)];

                s_player[rastgele]=true;
                glowla(rastgele, 0, 255, 0), g_glow[rastgele]=true;

                client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan SIKISTIRMA icin ^1%n ^4adli oyuncuyu secti.", id, rastgele);
            
            } else client_print_color(id, id, "^1[^3%s^1]^4 Mahkum yok.", serverTAG);
        }
        case 2 : {
            if(s_gerisayim) client_print_color(id, id, "^1[^3%s^1]^4 Geri sayim suan zaten aktif.", serverTAG), sikistirma(id);
            else {
                new ids, bool:say=false;
                for(new i=0; i<num; i++) {
                    ids = players[i];
                    if(s_player[ids]) say=true;

                    set_entvar(ids, var_health, Float:100.0);
                    rg_remove_all_items(ids), rg_give_item(ids, "weapon_knife");
                }
                if(!say) { 
                    client_print_color(id, id, "^1[^3%s^1]^4 SIKISTIRMAK icin secilen bir^1 Mahkum ^4yok.", serverTAG);
                    sikistirma(id);
                    return PLUGIN_HANDLED; 
                }

                set_pcvar_num(semiclip, 0);
                s_gerisayim=true;

                client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1SIKISTIRMA^4 oyununu baslatti.", id);
                s_sure=22; 

                remove_task(task_SIKISTIRMA);
                set_task_ex(1.0, "sikistirma_end", task_SIKISTIRMA, .flags = SetTask_Repeat);
                rg_send_audio(0, ctmenu_sikistirma);
            }
        }
        case 3 : {
            new ids, bool:say=false;

            for(new i=0; i<num; i++) {
                ids = players[i];
                if(s_player[ids]) {
                    say=true;
                    client_print_color(0, id, "^1[^3%n^1]^4 adli oyuncu ^1SIKISTIRMA^4 oyununu kaybetti.", ids);
                    user_kill(ids);
                }
            }
            if(!say) client_print_color(id, id, "^1[^3%s^1]^4 SIKISTIRMAK icin secilen bir^1 Mahkum ^4yok.", serverTAG);

            remove_task(task_SIKISTIRMA);
            s_gerisayim=false;
            client_cmd(0, "stopsound");
        }
    }

    sikistirma(id);
    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

public sikistirma_end() {
    if(s_gerisayim) {
        if(s_sure>0) {
            s_sure--;
            client_print_color(0, print_team_blue, "^1[^3%s^1]^4 SIKISTIRMA geri sayiminin bitmesine ^1[ ^3%d ^1]^4 saniye kaldi.",serverTAG, s_sure);
        } else {
            new players[MAX_PLAYERS], num, ids; 
            get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");

            for(new i=0; i<num; i++) {
                ids=players[i];
                if(!s_player[ids]) user_kill(ids);
                else client_print_color(0, print_team_blue, "^1[^3%n^1]^4 adli oyuncu ^1SIKISMADIGI^4 icin oyunu kazandi!", ids);
            }

            s_gerisayim=false;
            client_cmd(0, "stopsound");
            remove_task(task_SIKISTIRMA);
        }
    }
}

public gozumegozukme(id) {
    new ndmenu[128];
    formatex(ndmenu, charsmax(ndmenu),"\w%s \d|| \wGozume Gozukme\d", serverTAG);
    new Menu = RA_MenuCreate(ndmenu, "gozumegozukme2");
        
    RA_MenuAddItem(Menu,"\wAim Glow \d(1'e Bas Oyunculari Ara)","1");
    RA_MenuAddItem(Menu,"\wOyunu Kapat.","2");

    formatex(ndmenu, charsmax(ndmenu), "\wCT Noclip %s^n",noclipKontrol ? "\rKapat.":"\rAC.");
    RA_MenuAddItem(Menu, ndmenu, "3");

    menu_addtext(Menu, "\dAim Glow'u kullanarak gizli mahkumlari glowlayacaksin.");
    menu_addtext(Menu, "\dGlowladigin kisi \r3 saniye\d icinde olecek.");
    menu_addtext(Menu, "\dOyunu durdurmak veya bitirmek icin 2. tusu kullanin.");

    menu_setprop(Menu, MPROP_EXITNAME, "\wCikis");
    FC_CTMenuDisplay(id, Menu);
}

public gozumegozukme2(id, menu, item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(item == MENU_EXIT || get_member(id, m_iTeam)!=TEAM_CT) { menu_destroy(menu); return PLUGIN_HANDLED; }

    new data[6], key; 
    menu_item_getinfo(menu, item, _, data, charsmax(data));
    key = str_to_num(data);

    switch(key) {
        case 1 : {
            new ids,body; get_user_aiming(id, ids, body);

            if(is_user_alive(ids) && get_member(ids, m_iTeam)==TEAM_TERRORIST && !task_exists(ids+task_GOZUMEGOZUKME)) {

                glowla(ids, 255, 0, 0), g_glow[ids]=true;
                set_entvar(ids, var_effects, get_entvar(ids, var_effects) & ~EF_NODRAW); //set_entity_visibility(ids, 1);
                set_task(3.0, "gozoldur", ids+task_GOZUMEGOZUKME);

                client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1%n^4 adli oyuncuyu yakaladi.^3 3 saniye icinde olecek.", id, ids);
            
            } else client_print_color(id, id, "^1[^3%s^1]^4 Baktigin yerde secilecek ^1Oyuncu ^4yok.", serverTAG);
        }
        case 2 : {
            new players[MAX_PLAYERS], num, ids; 
            get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");

            for(new i=0; i<num; i++) {
                ids = players[i];
                set_entvar(ids, var_effects, get_entvar(ids, var_effects) & ~EF_NODRAW); //set_entity_visibility(ids, 1);
                remove_task(ids+task_GOZUMEGOZUKME);
            }

            client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1Gozume Gozukme^4 oyununu durdurdu.", id);
        }
        case 3 : {
            new players[MAX_PLAYERS], num; 
            get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "CT");

            if(noclipKontrol) {
                client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1CT Noclip^4 kapatti.", id);
                noclipKontrol=false;

                for(new i=0; i<num; i++) 
                    set_entvar(players[i], var_movetype, MOVETYPE_WALK);

            } else {
                client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1CT Noclip^4 acti.", id);
                noclipKontrol=true;

                for(new i=0; i<num; i++)
                    set_entvar(players[i], var_movetype, MOVETYPE_NOCLIP);
            }
        }
    }

    gozumegozukme(id);
    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

public gozoldur(id) {
    id=id- task_GOZUMEGOZUKME;
    user_kill(id);
    client_print(id, print_center, "Yakalandigin icin olduruldun.");
}

public hainvatan(id) {
    new ndmenu[128];
    formatex(ndmenu, charsmax(ndmenu),"\w%s \d|| \wVatan Hainini Oldur\d", serverTAG);
    new Menu = RA_MenuCreate(ndmenu, "hainvatan2");
    
    RA_MenuAddItem(Menu,"\wRasgele Hain Belirle.","1");
    RA_MenuAddItem(Menu,"\wHaini Yanina ?inla.","2");
    RA_MenuAddItem(Menu,"\wOyunu Baslat.","3");

    menu_setprop(Menu, MPROP_EXITNAME, "\wCikis");
    FC_CTMenuDisplay(id, Menu);
}

public hainvatan2(id, menu, item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(item == MENU_EXIT || get_member(id, m_iTeam)!=TEAM_CT) { menu_destroy(menu); return PLUGIN_HANDLED; }

    new data[6], key, players[MAX_PLAYERS], num; 
    menu_item_getinfo(menu, item, _, data, charsmax(data));
    key = str_to_num(data);

    get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");

    switch(key) {
        case 1 : {
            if(num>0) {
                new rastgele=players[random_num(0, num-1)];

                glowla(rastgele, 255, 0, 0);
                g_hain[rastgele]=true;
                g_glow[rastgele]=true;
                client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan^1 %n ^4adli oyuncuyu ^3Vatan Haini^4 secti.", id, rastgele);
            
            } else client_print_color(id, id, "^1[^3%s^1]^4 Mahkum yok.", serverTAG);
        }
        case 2 : {
            new ids, bool:say=false;

            for(new i=0; i<num; i++) {
                ids=players[i];
                if(g_hain[ids]) {
                    new Float:origin[3]; get_entvar(id, var_origin, origin);
                    say=true;

                    origin[1]+=35.0; 
                    set_entvar(ids, var_origin, origin);
                    checkstuckid(ids);

                    client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan^1 %n ^4adli vatan hainini ^3yanina isinladi.", id, ids);
                }
            }
            if(!say) client_print_color(id, id, "^1[^3%s^1]^4 Hain yok.", serverTAG);
        }
        case 3 : {
            new ids, bool:say=false;

            for(new i=0; i<num; i++) {
                ids = players[i];
                if(g_hain[ids]) {
                    set_entvar(ids, var_health, Float:100.0*float(num-1));
                    say=true;
                }
            }
            if(!say) { 
                client_print_color(id, id, "^1[^3%s^1]^4 Hain yok. Haini sectikten sonra oyunu baslatin!", serverTAG);
                hainvatan(id);
                return PLUGIN_HANDLED; 
            }
            set_pcvar_num(mp_infinite_ammo, 1);
            for(new i=0; i < num; i++) {
                ids = players[i];

                if(!g_hain[ids]) 
                    set_entvar(ids, var_health, Float:100.0);

                rg_remove_all_items(ids), rg_give_item(ids, "weapon_knife");
                rg_give_item(ids, "weapon_m4a1"),rg_give_item(ids, "weapon_ak47");
            }

            client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan^1 Vatan Hainini Oldur ^4oyununu baslatti.", id);
            client_print_color(0, id, "^1[^3%s^1]^4 Vatan Hainini olduren oyunu ^3kazanacak.", serverTAG);

            vatanhainiKontrol=true;
            EnableHookChain(h_Dmg);
            set_pcvar_num(mp_freeforall, 1);
            #if defined semiclip_cvaraktif 
                set_pcvar_num(semiclip, 0);
            #endif
        }
    }
    hainvatan(id);
    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

public kule(id) {
    new ndmenu[128];
    formatex(ndmenu, charsmax(ndmenu),"\w%s \d|| \wKule\d", serverTAG);
    new Menu = RA_MenuCreate(ndmenu, "kule2");
        
    RA_MenuAddItem(Menu,"\wDrugsuz Kule Baslat.","1");
    RA_MenuAddItem(Menu,"\wDruglu Kule Baslat.","2");

    menu_setprop(Menu, MPROP_EXITNAME, "\wCikis");
    FC_CTMenuDisplay(id, Menu);
}

public kule2(id, menu, item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(item == MENU_EXIT || get_member(id, m_iTeam)!=TEAM_CT) { menu_destroy(menu); return PLUGIN_HANDLED; }

    new data[6], key, players[MAX_PLAYERS], num, ids;
    menu_item_getinfo(menu, item, _, data, charsmax(data));
    key = str_to_num(data);

    #if defined semiclip_cvaraktif 
        set_pcvar_num(semiclip, 1);
    #endif
    set_pcvar_num(sv_parachute, 0);
    get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST"); 

    switch(key) {
        case 1 : {
            for(new i=0; i<num; i++) {
                ids=players[i];
                rg_remove_all_items(ids), rg_give_item(ids, "weapon_knife");
                g_silahKontrol[ids]=true;	
            }

            client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1Drugsuz Kule^4 oyununu baslatti.", id);
        }
        case 2 : {
            for(new i=0; i<num; i++) {
                ids=players[i];
                rg_remove_all_items(ids), rg_give_item(ids, "weapon_knife");
                g_silahKontrol[ids]=true;

                message_begin(MSG_ONE, SetFOV, { 0, 0, 0 }, ids);
                write_byte(180);
                message_end();
            }

            client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1Druglu Kule^4 oyununu baslatti.", id);
        }
    }
    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

public gondol(id) {
    new ndmenu[128];
    formatex(ndmenu, charsmax(ndmenu),"\w%s \d|| \wGondol\d", serverTAG);
    new Menu = RA_MenuCreate(ndmenu, "gondol2");
        
    RA_MenuAddItem(Menu,"\wAimdeki Kisiyi \wUcur! \d(Uberslap)","1");
    RA_MenuAddItem(Menu,"\wAimdeki Kisiyi \rGlowla!","2");

    menu_setprop(Menu, MPROP_EXITNAME, "\wCikis");
    FC_CTMenuDisplay(id, Menu);
}

public gondol2(id, menu, item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(item == MENU_EXIT || get_member(id, m_iTeam)!=TEAM_CT) { menu_destroy(menu); return PLUGIN_HANDLED; }

    new data[6], key, ids, body;
    menu_item_getinfo(menu, item, _, data, charsmax(data));
    key = str_to_num(data);
    get_user_aiming(id, ids, body);

    switch(key) {
        case 1 : {
            if(is_user_alive(ids) && get_member(ids, m_iTeam)==TEAM_TERRORIST) {

                glowla(ids, 255, 85, 85), g_glow[ids]=true;
                set_task_ex(0.1, "uberslap", ids, .flags = SetTask_RepeatTimes, .repeat = 100);

                client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1%n^4 adli oyuncuyu ucurdu.", id, ids);
            
            } else client_print_color(id, id, "^1[^3%s^1]^4 Lutfen oyuncuya nisan al.", serverTAG);
        }
        case 2 : {
            if(is_user_connected(ids)) {
                glowla(ids, 0, 225, 0), g_glow[ids]=true;

                message_begin(MSG_ONE, ScreenFade,{ 0,0,0 }, ids);
                write_short(1<<14); write_short(1<<9); write_short(1<<11);
                write_byte(0); write_byte(225); write_byte(0); //Renk
                write_byte(255); message_end();

                client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1%n^4 adli oyuncuyu ^3Gondol ^4icin glowladi.", id, ids);
            
            } else client_print_color(id, id, "^1[^3%s^1]^4 Lutfen oyuncuya nisan al.", serverTAG);
        }
    }

    gondol(id);
    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

public uberslap(id) {
    new Float:cann=get_entvar(id, var_health);

    if(cann > 50.0) set_entvar(id, var_health, Float:50.0);

    if(cann > 1.0) user_slap(id, 1);
    else user_slap(id, 0);
}

public ucanpipi(id) {
    new ndmenu[128];
    formatex(ndmenu, charsmax(ndmenu),"\w%s \d|| \wUcan Pipi\d", serverTAG);
    new Menu = RA_MenuCreate(ndmenu, "ucanpipi2");
        
    RA_MenuAddItem(Menu,"\wGravity \r[\w100\r]","1");
    RA_MenuAddItem(Menu,"\wGravity \r[\w200\r]","2");
    RA_MenuAddItem(Menu,"\wGravity \r[\w300\r]","3");
    RA_MenuAddItem(Menu,"\wGravity \r[\w400\r]","4");
    RA_MenuAddItem(Menu,"\wGravity \r[\w500\r]","5");
    RA_MenuAddItem(Menu,"\wGravity \r[\w800\r]^n","8");
    RA_MenuAddItem(Menu,"\wMahkumlari Siraya Diz.^n\dGravity ayarladiktan sonra \rSiraya Diz\d menusune gidebilirsiniz.","6");

    menu_setprop(Menu, MPROP_EXITNAME, "\wCikis");
    FC_CTMenuDisplay(id, Menu);
}

public ucanpipi2(id, menu, item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(item == MENU_EXIT || get_member(id, m_iTeam)!=TEAM_CT) { menu_destroy(menu); return PLUGIN_HANDLED; }

    new data[6], key; 
    menu_item_getinfo(menu, item, _, data, charsmax(data));
    key = str_to_num(data);

    if(key == 6) {
        yansirala(id);
        return PLUGIN_HANDLED;
    }

    set_pcvar_num(sv_gravity, key*100);
    client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1Gravity %d^4 yapti.", id, key*100);
    ucanpipi(id);

    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

public yuzle(id) {
    if(get_member(id, m_iTeam)!=TEAM_CT) client_print_color(id, id, "^1[^3%s^1]^4 Bu menuyu sadece ^1gardiyanlar^4 kullanabilir.",serverTAG);
    else {
        new players[MAX_PLAYERS], num; 
        get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_ExcludeBots);

        for(new i=0; i<num; i++) 
            set_entvar(players[i], var_health, Float:100.0);
    }
}

public menuler(id) {
    if(get_member(id, m_iTeam)!=TEAM_CT) client_print_color(id, id, "^1[^3%s^1]^4 Bu menuye sadece ^1gardiyanlar^4 girebilir.",serverTAG);
    else if(!is_user_alive(id)) client_print_color(id, id, "^1[^3%s^1]^4 Bu menuye ^1oluyken^4 giremezsin.",serverTAG);
    else {

        new ndmenu[128];
        formatex(ndmenu, charsmax(ndmenu),"\w%s \d|| \wMenuler\d",serverTAG);
        new Menu = RA_MenuCreate(ndmenu, "menuler2");

        formatex(ndmenu, charsmax(ndmenu), "\wFreeze Menu %s", get_entvar(id, var_takedamage) ? "\r[\d KAPALI \r]":"\r[\w /freeze \r]");
        RA_MenuAddItem(Menu, ndmenu, "4");
        formatex(ndmenu, charsmax(ndmenu), "\wSlay Menu %s", get_entvar(id, var_takedamage) ? "\r[\d KAPALI \r]":"\r[\w /slaymenu \r]");
        RA_MenuAddItem(Menu, ndmenu, "9");

        RA_MenuAddItem(Menu,"\wRev Menu \r[\w /revmenu \r]","1");
        RA_MenuAddItem(Menu,"\wC4 Menu \r[\w /c4menu \r]","3");
        RA_MenuAddItem(Menu,"\wFF Menu \r[\w /ffmenu \r]","5");
        RA_MenuAddItem(Menu,"\wGlow Menu \r[\w /glow \r]","2");
        RA_MenuAddItem(Menu,"\wSilah Menu \r[\w /silah \r]","6");
        RA_MenuAddItem(Menu,"\wIslemler Menu \r[\w /islemler \r]","7");
        RA_MenuAddItem(Menu,"\wSon Mahkum Sec \r[\w /sonsec \r]^n","8");

        RA_MenuAddItem(Menu,"\wMahkûm Getirme Menüsü","90");
        RA_MenuAddItem(Menu,"\wAçlık Oyunu Koordinatları","91");
        RA_MenuAddItem(Menu, "\wCikis", "0", 0);
        menu_setprop(Menu, MPROP_PERPAGE, 7);
        FC_CTMenuDisplay(id, Menu);
    }
}

public menuler2(id, menu, item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(item == MENU_EXIT || get_member(id, m_iTeam)!=TEAM_CT || !is_user_alive(id)) { menu_destroy(menu); return PLUGIN_HANDLED; }

    new data[6], key; 
    menu_item_getinfo(menu, item, _, data, charsmax(data));
    key = str_to_num(data);

    switch(key) {
        case 90 : ShowBringMenu(id);
        case 91 : ShowArenaMenu(id);
        case 1 : revivemenu(id);
        case 2 : glowmenu(id);
        case 3 : c4menu(id);
        case 4 : {
            if(!get_entvar(id, var_takedamage)) freezemenu(id);
            else client_print_color(id, print_team_blue, "^1[^3%s^1]^4 Bu menuye sadece ^1godmode aktifken^4 girebilir.", serverTAG), menuler(id);
        }
        case 5 : ffmenu(id);
        case 6 : silahmenu(id);
        case 7 : islemlermenu(id);
        case 8 : sonsecmenu(id);
        case 9 : {
            if(!get_entvar(id, var_takedamage)) slaymenu(id);
            else client_print_color(id, print_team_blue, "^1[^3%s^1]^4 Bu menuye sadece ^1godmode aktifken^4 girebilir.", serverTAG), menuler(id);
        }
    }
    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

public silahmenu(id) {
    if(get_member(id, m_iTeam)!=TEAM_CT) client_print_color(id, id, "^1[^3%s^1]^4 Bu menuye sadece ^1gardiyanlar^4 girebilir.",serverTAG);
    else if(!is_user_alive(id)) client_print_color(id, id, "^1[^3%s^1]^4 Bu menuye ^1oluyken^4 giremezsin.",serverTAG);
    else {

        new ndmenu[128];
        formatex(ndmenu, charsmax(ndmenu),"\w%s \d|| \wSilah Menu\d", serverTAG);
        new Menu = RA_MenuCreate(ndmenu, "silahmenu2");

        RA_MenuAddItem(Menu,"\wAWP al.","1");
        RA_MenuAddItem(Menu,"\wM4A1 al.","2");
        RA_MenuAddItem(Menu,"\wAK47 al.","3");
        RA_MenuAddItem(Menu,"\wM249 al.","4");
        RA_MenuAddItem(Menu,"\wDeagle al.^n","5");
        RA_MenuAddItem(Menu,"\wCTMenu'ye don.","6");

        menu_setprop(Menu, MPROP_EXITNAME, "\wCikis");
        FC_CTMenuDisplay(id, Menu);
    }
}

public silahmenu2(id, menu, item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(item == MENU_EXIT || get_member(id, m_iTeam)!=TEAM_CT || !is_user_alive(id)) { menu_destroy(menu); return PLUGIN_HANDLED; }

    new data[6], key; 
    menu_item_getinfo(menu, item, _, data, charsmax(data));
    key = str_to_num(data);

    silahmenu(id);
    switch(key) {
        case 1 : rg_give_item(id, "weapon_awp"), rg_set_user_bpammo(id, WEAPON_AWP, 200);
        case 2 : rg_give_item(id, "weapon_m4a1"), rg_set_user_bpammo(id, WEAPON_M4A1, 200);
        case 3 : rg_give_item(id, "weapon_ak47"), rg_set_user_bpammo(id, WEAPON_AK47, 200);
        case 4 : rg_give_item(id, "weapon_m249"), rg_set_user_bpammo(id, WEAPON_M249, 200);
        case 5 : rg_give_item(id, "weapon_deagle"), rg_set_user_bpammo(id, WEAPON_DEAGLE, 200);
        case 6 : ctmenu(id);
    }
    
    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

public revivemenu(id) {
    if(get_member(id, m_iTeam)!=TEAM_CT) client_print_color(id, id, "^1[^3%s^1]^4 Bu menuye sadece ^1gardiyanlar^4 girebilir.",serverTAG);
    else {

        new ndmenu[128];
        formatex(ndmenu, charsmax(ndmenu),"\w%s \d|| \wRevive Menusu\d", serverTAG);
        new Menu = RA_MenuCreate(ndmenu, "revivemenu2");

        RA_MenuAddItem(Menu,"\wNormal Revmenu","1");
        RA_MenuAddItem(Menu,"\wHRespawn Menu \d(Oyunculari son oldugu yerde revle)^n","6");

        RA_MenuAddItem(Menu,"\wOlmus Tum Mahkumlari Revle","2");
        RA_MenuAddItem(Menu,"\wOlmus Tum Gardiyanlari Revle^n","3");

        RA_MenuAddItem(Menu,"\wTum Mahkumlari Revle","4");
        RA_MenuAddItem(Menu,"\wTum Gardiyanlari Revle","5");

        menu_setprop(Menu, MPROP_EXITNAME, "\wCikis");
        FC_CTMenuDisplay(id, Menu);
    }
}

public revivemenu2(id, menu, item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(item == MENU_EXIT || get_member(id, m_iTeam)!=TEAM_CT) { menu_destroy(menu); return PLUGIN_HANDLED; }

    new data[6], key; 
    menu_item_getinfo(menu, item, _, data, charsmax(data));
    key = str_to_num(data);

    switch(key) {
        case 1 : revmenu(id);
        case 2 : {
            new players[MAX_PLAYERS], num, ids;  
            get_players_ex(players, num, GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");

            for(new i=0; i<num; i++) {
                ids=players[i];

                if(!is_user_alive(ids))
                {
                    rg_round_respawn(ids);
                }
            }
            client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1olu mahkumlari ^4revledi.", id);
            revivemenu(id);
        }
        case 3 : {
            new players[MAX_PLAYERS], num, ids; 
            get_players_ex(players, num, GetPlayers_ExcludeAlive | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "CT");

            for(new i=0; i<num; i++) {
                ids=players[i];

                rg_round_respawn(ids);
            }
            client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1olu gardiyanlari ^4revledi.", id);
            revivemenu(id);
        }
        case 4 : {
            new players[MAX_PLAYERS], num, ids;  
            get_players_ex(players, num, GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");

            for(new i=0; i<num; i++) {
                ids=players[i];

                rg_round_respawn(ids);
            }
            client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1tum mahkumlari ^4revledi.", id); 
            revivemenu(id);
        }
        case 5 : {
            new players[MAX_PLAYERS], num, ids; 
            get_players_ex(players, num, GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "CT");

            for(new i=0; i<num; i++) {
                ids=players[i];
                
                rg_round_respawn(ids);
            }
            client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1tum gardiyanlari ^4revledi.", id);
            revivemenu(id);
        }

        case 6 : hrevmenu(id);
    }
    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

public hrevmenu(id) {

    new ndmenu[128], szTempid[10], players[MAX_PLAYERS], num, ids;

    formatex(ndmenu, charsmax(ndmenu),"\w%s \d|| \wGelismis HRespawn Menu\d^nOyuncular son oldugu yerde revlenir!",serverTAG);
    new Menu = RA_MenuCreate(ndmenu, "hrevmenu2");

    get_players_ex(players, num, GetPlayers_ExcludeAlive | GetPlayers_ExcludeBots);

    new bool:say=false;
    for(new i=0; i<num; i++) {
        ids=players[i];
        if(deathOrigin[ids][0]) {
            say=true;
            num_to_str(ids, szTempid, charsmax(szTempid));
            formatex(ndmenu, charsmax(ndmenu), "\w%n", ids);
            RA_MenuAddItem(Menu, ndmenu, szTempid);
        }
    }
    if(!say) {
        client_print_color(id, id, "^1[^3%s^1]^4 Farkli konumda olen ^1kimse yok^3!", serverTAG);
        revivemenu(id);
        return;
    }

    menu_setprop(Menu, MPROP_BACKNAME, "\wOnceki Menu");
    menu_setprop(Menu, MPROP_NEXTNAME, "\wDiger Menu");
    menu_setprop(Menu, MPROP_EXITNAME, "\wCikis");
    FC_CTMenuDisplay(id, Menu);
}

public hrevmenu2(id, menu, item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(item == MENU_EXIT || get_member(id, m_iTeam)!=TEAM_CT) { menu_destroy(menu); return PLUGIN_HANDLED; }

    new data[6], key; 
    menu_item_getinfo(menu, item, _, data, charsmax(data));
    key = str_to_num(data);

    if(is_user_connected(key) && !is_user_alive(key)) {
        rg_round_respawn(key);
        set_entvar(key, var_origin, deathOrigin[key]);

        client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1%n^4 adli oyuncuyu ^3son oldugu yere ^4revledi.", id, key);
        hrevmenu(id);
    }

    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

public revmenu(id) {

    new ndmenu[64], szTempid[10], players[MAX_PLAYERS], num1, num2, ids;

    formatex(ndmenu, charsmax(ndmenu),"\w%s \d|| \wRevive Menusu\d",serverTAG);
    new Menu = RA_MenuCreate(ndmenu, "revmenu2");

    get_players_ex(players, num1, GetPlayers_ExcludeAlive | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "CT");
    for(new i=0; i<num1; i++) {
        ids=players[i];
        num_to_str(ids, szTempid, charsmax(szTempid));
        formatex(ndmenu, charsmax(ndmenu), "\w%n \d(\wCT\d)", ids);
        RA_MenuAddItem(Menu, ndmenu, szTempid);
    }

    get_players_ex(players, num2, GetPlayers_ExcludeAlive | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");
    for(new i=0; i<num2; i++) {
        ids=players[i];
        num_to_str(ids, szTempid, charsmax(szTempid));
        formatex(ndmenu, charsmax(ndmenu), "\w%n \d(\rTE\d)", ids);
        RA_MenuAddItem(Menu, ndmenu, szTempid);
    }

    if(num1==0 && num2==0) {
        client_print_color(id, id, "^1[^3%s^1]^4 Olu kimse yok^3!", serverTAG);
        revivemenu(id);
        return;
    }

    menu_setprop(Menu, MPROP_BACKNAME, "\wOnceki Menu");
    menu_setprop(Menu, MPROP_NEXTNAME, "\wDiger Menu");
    menu_setprop(Menu, MPROP_EXITNAME, "\wCikis");
    FC_CTMenuDisplay(id, Menu);
}

public revmenu2(id, menu, item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(item == MENU_EXIT || get_member(id, m_iTeam)!=TEAM_CT) { menu_destroy(menu); return PLUGIN_HANDLED; }

    new data[6], key; 
    menu_item_getinfo(menu, item, _, data, charsmax(data));
    key = str_to_num(data);

    if(is_user_connected(key) && !is_user_alive(key)) {
        rg_round_respawn(key);
        client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1%n^4 adli oyuncuyu revledi.", id, key);
        revmenu(id);
    }

    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

public glowmenu(id) {
    if(get_member(id, m_iTeam)!=TEAM_CT) client_print_color(id, id, "^1[^3%s^1]^4 Bu menuye sadece ^1gardiyanlar^4 girebilir.",serverTAG);
    else if(!is_user_alive(id)) client_print_color(id, id, "^1[^3%s^1]^4 Bu menuye ^1oluyken^4 giremezsin.",serverTAG);
    else {
        new ndmenu[128];
        formatex(ndmenu, charsmax(ndmenu),"\w%s \d|| \wGlow Menu\d",serverTAG);
        new Menu = RA_MenuCreate(ndmenu, "glowmenu2");

        RA_MenuAddItem(Menu,"\wOto Takim Olusturma \r[\w /takimmenu\r ]^n","1");
        RA_MenuAddItem(Menu,"\wAimdeki kisiye \wKirmizi Glow\w Ver.","2");
        RA_MenuAddItem(Menu,"\wAimdeki kisiye \wMavi Glow\w Ver.","3");
        RA_MenuAddItem(Menu,"\wAimdeki kisiye \wYesil Glow\w Ver.","6");
        RA_MenuAddItem(Menu,"\wAimdeki kisiye \wSari Glow\w Ver.","4");
        RA_MenuAddItem(Menu,"\wAimdeki kisiye \wTuruncu Glow\w Ver.","5");
        RA_MenuAddItem(Menu,"\wAimdeki kisiye \wMor Glow\w Ver.","8");
        RA_MenuAddItem(Menu,"\wAimdeki kisiye \wTurkuaz Glow\w Ver.","9");
        RA_MenuAddItem(Menu,"\wAimdeki kisinin \dGlowunu \wKaldir.^n","7");

        RA_MenuAddItem(Menu, "\wCikis", "0", 0);
        menu_setprop(Menu, MPROP_PERPAGE, 0);
        FC_CTMenuDisplay(id, Menu);
    }
}

public glowmenu2(id, menu, item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(item == MENU_EXIT || get_member(id, m_iTeam)!=TEAM_CT || !is_user_alive(id)) { menu_destroy(menu); return PLUGIN_HANDLED; }

    new data[6], key, ids, body;
    menu_item_getinfo(menu, item, _, data, charsmax(data));
    key = str_to_num(data);
    get_user_aiming(id, ids, body);

    switch(key) {
        case 1 : takimmenu(id);
        case 2 : {
            if(is_user_connected(ids)) {
                glowla(ids, 255, 0, 0), g_glow[ids]=true;

                message_begin(MSG_ONE, ScreenFade, { 0,0,0 }, ids);
                write_short(1<<14); write_short(1<<9); write_short(1<<11);
                write_byte(255); write_byte(0); write_byte(0); //Renk
                write_byte(255); message_end();

                Takim[ids]=1;

            } else client_print_color(id, id, "^1[^3%s^1]^4 Lutfen oyuncuya nisan al.", serverTAG);
            glowmenu(id);
        }
        case 3 : {
            if(is_user_connected(ids)) {
                glowla(ids, 0, 0, 255), g_glow[ids]=true;

                message_begin(MSG_ONE, ScreenFade, { 0,0,0 }, ids);
                write_short(1<<14); write_short(1<<9); write_short(1<<11);
                write_byte(0); write_byte(0); write_byte(255); //Renk
                write_byte(255); message_end();

                Takim[ids]=2;

            } else client_print_color(id, id, "^1[^3%s^1]^4 Lutfen oyuncuya nisan al.", serverTAG);
            glowmenu(id);
        }
        case 4 : {
            if(is_user_connected(ids)) {
                glowla(ids, 255, 255, 0), g_glow[ids]=true;

                message_begin(MSG_ONE, ScreenFade, { 0,0,0 }, ids);
                write_short(1<<14); write_short(1<<9); write_short(1<<11);
                write_byte(255); write_byte(255); write_byte(0); //Renk
                write_byte(255); message_end();

                Takim[ids]=3;

            } else client_print_color(id, id, "^1[^3%s^1]^4 Lutfen oyuncuya nisan al.", serverTAG);
            glowmenu(id);
        }
        case 5 : {
            if(is_user_connected(ids)) {
                glowla(ids, 255, 85, 0), g_glow[ids]=true;

                message_begin(MSG_ONE, ScreenFade, { 0,0,0 }, ids);
                write_short(1<<14); write_short(1<<9); write_short(1<<11);
                write_byte(255); write_byte(85); write_byte(0); //Renk
                write_byte(255); message_end();

                Takim[ids]=4;

            } else client_print_color(id, id, "^1[^3%s^1]^4 Lutfen oyuncuya nisan al.", serverTAG);
            glowmenu(id);
        }
        case 6 : {
            if(is_user_connected(ids)) {
                glowla(ids, 0, 255, 0), g_glow[ids]=true;

                message_begin(MSG_ONE, ScreenFade, { 0,0,0 }, ids);
                write_short(1<<14); write_short(1<<9); write_short(1<<11);
                write_byte(0); write_byte(255); write_byte(0); //Renk
                write_byte(255); message_end();

                Takim[ids]=5;

            } else client_print_color(id, id, "^1[^3%s^1]^4 Lutfen oyuncuya nisan al.", serverTAG);
            glowmenu(id);
        }
        case 7 : {
            if(is_user_connected(ids)) {
                if(g_glow[ids]) glowla(ids, 0, 0, 0), g_glow[ids]=false;

                Takim[ids]=0;

            } else client_print_color(id, id, "^1[^3%s^1]^4 Lutfen oyuncuya nisan al.", serverTAG);
            glowmenu(id);
        }
        case 8 : {
            if(is_user_connected(ids)) {
                glowla(ids, 102, 0, 153), g_glow[ids]=true;

                message_begin(MSG_ONE, ScreenFade, { 0,0,0 }, ids);
                write_short(1<<14); write_short(1<<9); write_short(1<<11);
                write_byte(102); write_byte(0); write_byte(153); //Renk
                write_byte(255); message_end();

                Takim[ids]=6;

            } else client_print_color(id, id, "^1[^3%s^1]^4 Lutfen oyuncuya nisan al.", serverTAG);
            glowmenu(id);
        }
        case 9 : {
            if(is_user_connected(ids)) {
                glowla(ids, 48, 213, 200), g_glow[ids]=true;

                message_begin(MSG_ONE, ScreenFade, { 0,0,0 }, ids);
                write_short(1<<14); write_short(1<<9); write_short(1<<11);
                write_byte(48); write_byte(213); write_byte(200); //Renk
                write_byte(255); message_end();

                Takim[ids]=7;

            } else client_print_color(id, id, "^1[^3%s^1]^4 Lutfen oyuncuya nisan al.", serverTAG);
            glowmenu(id);
        }
    }
    EnableHookChain(h_Dmg);
    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

public takimmenu(id) {
    if(get_member(id, m_iTeam)!=TEAM_CT) client_print_color(id, id, "^1[^3%s^1]^4 Bu menuyu sadece ^1gardiyanlar ^4kullanabilir.",serverTAG);
    else if(!is_user_alive(id)) client_print_color(id, id, "^1[^3%s^1]^4 Bu menuye ^1oluyken^4 giremezsin.",serverTAG);
    else {
        new ndmenu[128];
        formatex(ndmenu,charsmax(ndmenu),"\w%s \d|| \wMahkum Takim Olusturma Menusu", serverTAG);
        new Menu = RA_MenuCreate(ndmenu,"takimmenu2");

        RA_MenuAddItem(Menu,"\wTakim Olustur \d[\r/takimyap\d]","1");
        RA_MenuAddItem(Menu,"\wTakim Boz \d[\r/takimboz\d]","2");
        RA_MenuAddItem(Menu,"\wMavi Takimi Slayla \d[\r/slaymavi\d]","3");
        RA_MenuAddItem(Menu,"\wKirmizi Takimi Slayla \d[\r/slaykirmizi\d]","4");
        RA_MenuAddItem(Menu,"\wBaktigin yere \wMavi \wtakimi isinla \d[\r/isinlamavi\d]","5");
        RA_MenuAddItem(Menu,"\wBaktigin yere \wKirmizi \wtakimi isinla \d[\r/isinlakirmizi\d]","6");

        menu_setprop(Menu, MPROP_EXITNAME, "\wCikis");
        FC_CTMenuDisplay(id, Menu, 0);
    }
    return PLUGIN_HANDLED;
}

public takimmenu2(id, menu, item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(item == MENU_EXIT || get_member(id, m_iTeam)!=TEAM_CT || !is_user_alive(id)) { menu_destroy(menu); return PLUGIN_HANDLED; }

    new data[6], key; 
    menu_item_getinfo(menu, item, _, data, charsmax(data));
    key = str_to_num(data);

    switch(key) {
        case 1 : takimyap(id);
        case 2 : takimboz(id);
        case 3 : slaymavi(id);
        case 4 : slaykirmizi(id);
        case 5 : isinlamavi(id);
        case 6 : isinlakirmizi(id);
    }

    takimmenu(id);
    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

public takimyap(id) {
    if(get_member(id, m_iTeam)!=TEAM_CT) client_print_color(id, id, "^1[^3%s^1]^4 Bu menuyu sadece ^1gardiyanlar ^4kullanabilir.",serverTAG);
    else if(!is_user_alive(id)) client_print_color(id, id, "^1[^3%s^1]^4 Bu menuye ^1oluyken^4 giremezsin.",serverTAG);
    else {

        new players[MAX_PLAYERS], num, ids;
        get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");

        if(num<=1) { 
            client_print_color(id, id, "^1[^3%s^1]^4 Mahkumlarin sayisi yeterli degil.",serverTAG); 
            return PLUGIN_HANDLED; 
        }

        for(new i=0; i<num; i++) {
            ids=players[i];
            message_begin(MSG_ONE, ScreenFade,{ 0,0,0 }, ids);
            write_short(1<<14); write_short(1<<9); write_short(1<<11);

            if(i<num/2) { 

                Takim[ids]=2; 
                glowla(ids, 0, 0, 255); 
                write_byte(0); 
                write_byte(0); 
                write_byte(255); 
            } else { 

                Takim[ids]=1; 
                glowla(ids, 255, 0, 0); 
                write_byte(255); write_byte(0); 
                write_byte(0); 
            }

            g_glow[ids]=true;
            write_byte(255); message_end();
        }
        EnableHookChain(h_Dmg);

        client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan otomatik ^1mahkumlardan ^3takim olusturdu.", id);
        takimKontrol=true;
    }
    return PLUGIN_HANDLED;
}

public takimboz(id) {
    if(get_member(id, m_iTeam)!=TEAM_CT) client_print_color(id, id, "^1[^3%s^1]^4 Bu menuyu sadece ^1gardiyanlar ^4kullanabilir.",serverTAG);
    else if(!is_user_alive(id)) client_print_color(id, id, "^1[^3%s^1]^4 Bu menuye ^1oluyken^4 giremezsin.",serverTAG);
    else if(!takimKontrol) client_print_color(id, id, "^1[^3%s^1]^4 Suan takim yok. Olusturmak icin ^1/takimyap^4 komutunu kullanabilirsiniz.",serverTAG);
    else {

        new players[MAX_PLAYERS], num, ids; 
        get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");

        for(new i=0; i<num; i++) {
            ids=players[i];
            if(Takim[ids]!=0) {

                Takim[ids]=0;
                glowla(ids, 0, 0, 0), g_glow[ids]=false;
            }
        }

        client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1mahkumlardan olusturulan ^3takimi bozdu.", id);
        takimKontrol=false;
    }
    return PLUGIN_HANDLED;
}

public slaymavi(id) {
    if(get_member(id, m_iTeam)!=TEAM_CT) client_print_color(id, id, "^1[^3%s^1]^4 Bu menuyu sadece ^1gardiyanlar ^4kullanabilir.",serverTAG);
    else if(!is_user_alive(id)) client_print_color(id, id, "^1[^3%s^1]^4 Bu menuye ^1oluyken^4 giremezsin.",serverTAG);
    else if(!takimKontrol) client_print_color(id, id, "^1[^3%s^1]^4 Suan takim yok. Olusturmak icin ^1/takimyap^4 komutunu kullanabilirsiniz.",serverTAG);
    else {

        new players[MAX_PLAYERS], num, ids;
        get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");

        for(new i=0; i<num; i++) {
            ids=players[i];

            if(Takim[ids]==2) 
                user_kill(ids);
        }

        client_print_color(0, id, "^1[^3%n^1]^4 adli gardinya ^1mavi ^3takimi slayladi.", id);
    }
    return PLUGIN_HANDLED;
}

public slaykirmizi(id) {
    if(get_member(id, m_iTeam)!=TEAM_CT) client_print_color(id, id, "^1[^3%s^1]^4 Bu menuyu sadece ^1gardiyanlar ^4kullanabilir.",serverTAG);
    else if(!is_user_alive(id)) client_print_color(id, id, "^1[^3%s^1]^4 Bu menuye ^1oluyken^4 giremezsin.",serverTAG);
    else if(!takimKontrol) client_print_color(id, id, "^1[^3%s^1]^4 Suan takim yok. Olusturmak icin ^1/takimyap^4 komutunu kullanabilirsiniz.",serverTAG);
    else {

        new players[MAX_PLAYERS], num, ids; 
        get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");

        for(new i=0; i<num; i++) {
            ids=players[i];

            if(Takim[ids]==1) 
                user_kill(ids);
        }

        client_print_color(0, id, "^1[^3%n^1]^4 adli gardinya ^1kirmizi ^3takimi slayladi.", id);
    }
    return PLUGIN_HANDLED;
}

public isinlamavi(id) {
    if(get_member(id, m_iTeam)!=TEAM_CT) client_print_color(id, id, "^1[^3%s^1]^4 Bu menuyu sadece ^1gardiyanlar ^4kullanabilir.",serverTAG);
    else if(!is_user_alive(id)) client_print_color(id, id, "^1[^3%s^1]^4 Bu menuye ^1oluyken^4 giremezsin.",serverTAG);
    else if(!takimKontrol) client_print_color(id, id, "^1[^3%s^1]^4 Suan takim yok. Olusturmak icin ^1/takimyap^4 komutunu kullanabilirsiniz.",serverTAG);
    else {
        new players[MAX_PLAYERS],num,ids,kordinat[3];
        get_user_origin(id,kordinat,3);
        get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");

        new Float:origin[3];
        origin[0] = float(kordinat[0]);
        origin[1] = float(kordinat[1]); 
        origin[2] = float(kordinat[2])+35.0;

        for(new i=0; i<num; i++) {
            ids=players[i];

            if(Takim[ids]==2) 
                set_entvar(ids, var_origin, origin);
        }

        client_print_color(0, id, "^1[^3%n^1]^4 adli gardinya ^1mavi ^3takimi isinladi.", id);
    }
    return PLUGIN_HANDLED;
}

public isinlakirmizi(id) {
    if(get_member(id, m_iTeam)!=TEAM_CT) client_print_color(id, id, "^1[^3%s^1]^4 Bu menuyu sadece ^1gardiyanlar ^4kullanabilir.",serverTAG);
    else if(!is_user_alive(id)) client_print_color(id, id, "^1[^3%s^1]^4 Bu menuye ^1oluyken^4 giremezsin.",serverTAG);
    else if(!takimKontrol) client_print_color(id, id, "^1[^3%s^1]^4 Suan takim yok. Olusturmak icin ^1/takimyap^4 komutunu kullanabilirsiniz.",serverTAG);
    else {

        new players[MAX_PLAYERS], num, ids, kordinat[3];
        get_user_origin(id,kordinat,3); 
        get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");

        new Float:origin[3];
        origin[0] = float(kordinat[0]); 
        origin[1] = float(kordinat[1]); 
        origin[2] = float(kordinat[2])+35.0;

        for(new i=0; i<num; i++) {
            ids=players[i];

            if(Takim[ids]==1) 
                set_entvar(ids, var_origin, origin);
        }

        client_print_color(0, id, "^1[^3%n^1]^4 adli gardinya ^1kirmizi ^3takimi isinladi.", id);
    }
    return PLUGIN_HANDLED;
}

public c4menu(id) {
	if(get_member(id, m_iTeam)!=TEAM_CT) client_print_color(id, id, "^1[^3%s^1]^4 Bu menuye sadece ^1gardiyanlar^4 girebilir.",serverTAG);
	else if(!is_user_alive(id)) client_print_color(id, id, "^1[^3%s^1]^4 Bu menuye ^1oluyken^4 giremezsin.",serverTAG);
	else {

		new ndmenu[128], godmode= get_entvar(id, var_takedamage);
		formatex(ndmenu, charsmax(ndmenu),"\w%s \d|| \wC4 Menu\d",serverTAG);
		new Menu = RA_MenuCreate(ndmenu, "c4menu2");

		if(!godmode) {
			RA_MenuAddItem(Menu,"\wT'yi \rBir Kere \wGom. \w[ACIK]","1");
			RA_MenuAddItem(Menu,"\wT'yi \rTamamen\w Gom.\d (Bug yapamazlar)","2");

		} else RA_MenuAddItem(Menu,"\dT'yi Gom. \d[KAPALI]","1");

		RA_MenuAddItem(Menu,"\wT'yi \rKaldir.","3");

		formatex(ndmenu, charsmax(ndmenu), "%s^n",sureligomSayac ? "\wSureli Gom \rDurdur.":"\wT'yi \rSureli \wGom.");
		RA_MenuAddItem(Menu, ndmenu, "4");

		RA_MenuAddItem(Menu,"\wT'ye \rC4 Ver.","5");

		if(!godmode) {
			RA_MenuAddItem(Menu,"\wT'yi \rDisarmla \w[ACIK]","6");
			RA_MenuAddItem(Menu,"\wAimdeki Kisiyi Gom.","7");
			RA_MenuAddItem(Menu,"\wAimdeki Kisiyi Kaldir.","8");

		} else RA_MenuAddItem(Menu,"\dT'yi Disarm-Aim Menuleri [KAPALI]","6");
		
		RA_MenuAddItem(Menu,"\wCT'ye \rDeagle \wVer.^n","9");
		
		if(!godmode) {
			RA_MenuAddItem(Menu, "\wCikis", "0", 0);
			menu_setprop(Menu, MPROP_PERPAGE, 0);

		} else menu_setprop(Menu, MPROP_EXITNAME, "\wCikis");

		FC_CTMenuDisplay(id, Menu);
	}
}
public c4menu2(id, menu, item) {
    if(id >= 1 && id <= MaxClients && g_bridgeMenu[id] == menu) {
        g_bridgeMenu[id] = -1;
    }

    if(g_bridgeRoundClosed) {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }

    if(item == MENU_EXIT || get_member(id, m_iTeam) != TEAM_CT || !is_user_alive(id)) {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }

    new data[6], key;
    menu_item_getinfo(menu, item, _, data, charsmax(data));
    key = str_to_num(data);

    switch(key) {
        case 1: {
            if(!get_entvar(id, var_takedamage)) {
                rg_send_audio(0, ctmenu_gomulunce);
                normalgom();
                client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1gomulu olmayan mahkumlari^4 gomdu.", id);
            }
            else {
                client_print_color(id, id, "^1[^3%s^1]^4 Godmode kapaliyken bu menuyu kullanamazsin.", serverTAG);
            }

            c4menu(id);
        }

        case 2: {
            tamgom();
            rg_send_audio(0, ctmenu_gomulunce);
            c4menu(id);
            client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1gomulu olmayan mahkumlari^3 tamamen ^4gomdu.", id);
        }

        case 3: {
            kaldir();
            c4menu(id);
            client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1gomulu olan mahkumlari^4 kaldirdi.", id);
        }

        case 4: {
            if(sureligomSayac > 0) {
                remove_task(task_SURELIGOM);
                client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1Sureli Gom^4 durdurdu.", id);
                sureligomSayac = 0;
                tamgomKontrol = false;
                uckezgomKontrol = false;
                c4menu(id);
            }
            else {
                sureligom(id);
            }
        }

        case 5: {
            new players[MAX_PLAYERS], num;
            get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");

            for(new i = 0; i < num; i++) {
                rg_give_item(players[i], "weapon_c4");
            }

            client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan tum mahkumlara ^1C4^4 verdi.", id);
            c4menu(id);
        }

        case 6: {
            if(!get_entvar(id, var_takedamage)) {
                new players[MAX_PLAYERS], num, ids;
                get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");

                for(new i = 0; i < num; i++) {
                    ids = players[i];
                    rg_remove_all_items(ids), rg_give_item(ids, "weapon_knife");
                }

                client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan tum mahkumlari ^1disarmladi.", id);
            }
            else {
                client_print_color(id, id, "^1[^3%s^1]^4 Godmode kapaliyken bu menuyu kullanamazsin.", serverTAG);
            }

            c4menu(id);
        }

        case 7: {
            new ids, body;
            get_user_aiming(id, ids, body);

            if(is_user_alive(ids) && get_member(ids, m_iTeam) == TEAM_TERRORIST && !Stuck(ids)) {
                client_cmd(ids, "-jump;-duck");

                new Float:origin[3];
                get_entvar(ids, var_origin, origin);
                origin[2] -= 35.0;

                set_entvar(ids, var_origin, origin);
                client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1%n ^4adli mahkumu gomdu.", id, ids);
            }
            else {
                client_print_color(id, id, "^1[^3%s^1]^4 Lutfen oyuncuya nisan al.", serverTAG);
            }

            c4menu(id);
        }

        case 8: {
            new ids, body;
            get_user_aiming(id, ids, body);

            if(is_user_alive(ids) && get_member(ids, m_iTeam) == TEAM_TERRORIST && Stuck(ids)) {
                client_cmd(ids, "-jump;-duck");

                new Float:origin[3];
                get_entvar(ids, var_origin, origin);
                origin[2] += 35.0;

                set_entvar(ids, var_origin, origin);
                client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1%n ^4adli mahkumu kaldirdi.", id, ids);
            }
            else {
                client_print_color(id, id, "^1[^3%s^1]^4 Lutfen oyuncuya nisan al.", serverTAG);
            }

            c4menu(id);
        }

        case 9: {
            new players[MAX_PLAYERS], num, ids;
            get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "CT");

            for(new i = 0; i < num; i++) {
                ids = players[i];
                rg_give_item(ids, "weapon_deagle"), rg_set_user_bpammo(ids, WEAPON_DEAGLE, 35);
            }

            client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan tum gardiyanlara ^1deagle^4 verdi.", id);
            c4menu(id);
        }
    }

    menu_destroy(menu);
    return PLUGIN_HANDLED;
}
public normalgom() {
	new players[MAX_PLAYERS], num, ids, silah;
	get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");

	for(new i=0; i<num; i++) {
		ids=players[i];
		if(silahliGom) {
			silah = get_user_weapon(ids);

			if(silah != CSW_KNIFE && silah != CSW_HEGRENADE && silah != CSW_SMOKEGRENADE && silah != CSW_FLASHBANG)
				continue;
		}
		if(!Stuck(ids)) {
			client_cmd(ids, "-jump;-duck");

			new Float:origin[3]; 
			get_entvar(ids, var_origin, origin); 
			origin[2]-=35.0;

			set_entvar(ids, var_origin, origin);
		}
	}
	set_pcvar_num(mp_forcecamera, 2);
}
public kaldir() {
	new players[MAX_PLAYERS],num,ids;
	get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");

	for(new i=0; i<num; i++) {
		ids=players[i];
		if(Stuck(ids)) {
			client_cmd(ids, "-jump;-duck");

			new Float:origin[3]; 
			get_entvar(ids, var_origin, origin); 
			origin[2]+=35.0;

			set_entvar(ids, var_origin, origin);
		}
	}
	set_pcvar_num(mp_forcecamera, 0);
}

public tamgom() {
	new players[MAX_PLAYERS], num, id, Float:origin[3]; 
	get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");

	for(new i=0; i<num; i++) {
		id=players[i];
		client_cmd(id, "-jump;-duck");
		
		while(!Stuck(id)) {
			get_entvar(id, var_origin, origin); 
			origin[2]-=35.0;

			set_entvar(id, var_origin, origin);
		}
	}

	static bool:tamgomc;
	if(!tamgomc) {

		set_task(0.2, "tamgom");
		tamgomc=true;
	} else {

		tamgomc=false;
		set_pcvar_num(mp_forcecamera, 2);
	}

}

public sureligom(id) {
	new ndmenu[128];
	formatex(ndmenu, charsmax(ndmenu),"\w%s \d|| \wSureli Gom Menusu", serverTAG);
	new Menu = menu_create(ndmenu, "sureligom2");

	RA_MenuAddItem(Menu,"\wT'yi \d[\r5 Sn\d] \wSonra Gom.","1");
	RA_MenuAddItem(Menu,"\wT'yi \d[\r10 Sn\d] \wSonra 3 Kere Gom.","2");
	RA_MenuAddItem(Menu,"\wT'yi \d[\r15 Sn\d] \wSonra 3 Kere Gom.","3");
	RA_MenuAddItem(Menu,"\wT'yi \d[\r20 Sn\d] \wSonra 3 Kere Gom.","4");
	RA_MenuAddItem(Menu,"\wT'yi \d[\r30 Sn\d] \wSonra Tamamen Gom.","5");
	RA_MenuAddItem(Menu,"\wT'yi \d[\r40 Sn\d] \wSonra Tamamen Gom.","6");
	RA_MenuAddItem(Menu,"\wT'yi \d[\r60 Sn\d] \wSonra Tamamen Gom.","7");

	menu_setprop(Menu, MPROP_EXITNAME, "\wCikis");
	FC_CTMenuDisplay(id, Menu);
}

public sureligom2(id, menu, item) {
    if(id >= 1 && id <= MaxClients && g_bridgeMenu[id] == menu) {
        g_bridgeMenu[id] = -1;
    }

    if(g_bridgeRoundClosed) {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }

    if(item == MENU_EXIT || get_member(id, m_iTeam) != TEAM_CT) {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }

    new data[6], key;
    menu_item_getinfo(menu, item, _, data, charsmax(data));
    key = str_to_num(data);

    switch(key) {
        case 1: sureligomSayac = 5;
        case 2: sureligomSayac = 10, uckezgomKontrol = true;
        case 3: sureligomSayac = 15, uckezgomKontrol = true;
        case 4: sureligomSayac = 20, uckezgomKontrol = true;
        case 5: sureligomSayac = 30, tamgomKontrol = true;
        case 6: sureligomSayac = 40, tamgomKontrol = true;
        case 7: sureligomSayac = 60, tamgomKontrol = true;
    }

    hucrekapisiniac(id);

    client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1Sureli Gom^4 baslatti.", id);
    //client_print_color(0, id, "^1[^3%s^1]^4 Mahkumlarin Gomulmesine ^1[ ^3%d ^1]^4 saniye kaldi.", serverTAG, sureligomSayac);

    remove_task(task_SURELIGOM);
    set_task_ex(1.0, "sureligom3", task_SURELIGOM, .flags = SetTask_Repeat);
    c4menu(id);

    menu_destroy(menu);
    return PLUGIN_HANDLED;
}
public sureligom3() {
	if(sureligomSayac<=1) {
		remove_task(task_SURELIGOM);
		sureligomSayac=0;
		if(uckezgomKontrol) {
			uckezgomKontrol=false;
			client_print_color(0, 0, "^1[^3%s^1]^4 Mahkumlar^1 3 kere^4 gomuldu!",serverTAG);
			rg_send_audio(0, ctmenu_gomulunce);
			normalgom();
			set_task(0.1, "normalgom");
			set_task(0.2, "normalgom");

		} else if(tamgomKontrol) {
			tamgomKontrol=false;
			tamgom();
			rg_send_audio(0, ctmenu_gomulunce);
			client_print_color(0, 0, "^1[^3%s^1]^4 Mahkumlar ^1tamamen ^4gomuldu!",serverTAG);

		} else {
			rg_send_audio(0, ctmenu_gomulunce);
			normalgom();
			client_print_color(0, 0, "^1[^3%s^1]^4 Mahkumlar ^1bir kere^4 gomuldu!",serverTAG);
		}

	} else {
		sureligomSayac--;
		if(uckezgomKontrol) client_print_color(0, print_team_blue, "^1[^3%s^1]^4 Mahkumlarin^1 3 Kere^4 Gomulmesine ^1[ ^3%d ^1]^4 saniye kaldi.",serverTAG, sureligomSayac);
		else if(tamgomKontrol) client_print_color(0, print_team_blue, "^1[^3%s^1]^4 Mahkumlarin^1 Tamamen ^4Gomulmesine ^1[ ^3%d ^1]^4 saniye kaldi.",serverTAG, sureligomSayac);
		else client_print_color(0, print_team_blue, "^1[^3%s^1]^4 Mahkumlarin Gomulmesine ^1[ ^3%d ^1]^4 saniye kaldi.",serverTAG, sureligomSayac);
	}
}

public freezemenu(id) {
    if(get_member(id, m_iTeam)!=TEAM_CT) client_print_color(id, id, "^1[^3%s^1]^4 Bu menuyu sadece gardiyanlar kullanabilir.",serverTAG);
    else if(!is_user_alive(id)) client_print_color(id, id, "^1[^3%s^1]^4 Bu menuyu ^1oluyken^4 kullanamazsin.",serverTAG);
    else if(get_entvar(id, var_takedamage)) client_print_color(id, id, "^1[^3%s^1]^4 Freeze sadece ^1godmode aktifken^4 kullanilabilir.",serverTAG);
    else {

        new ndmenu[128];
        formatex(ndmenu, charsmax(ndmenu),"\w%s \d|| \wFreeze Menu\d", serverTAG);
        new Menu = RA_MenuCreate(ndmenu, "freezemenu2");

        RA_MenuAddItem(Menu,"\wT'yi \rDondur. \d[\w/dondur\d]","1");
        RA_MenuAddItem(Menu,"\wT'yi \rDuzelt. \d[\w/coz\d]","2");

        formatex(ndmenu, charsmax(ndmenu), "%s^n",surelidondurSayac ? "\wSureli Dondur'u \rDurdur":"\wT'yi \rSureli\w Dondur.");
        RA_MenuAddItem(Menu, ndmenu, "3");

        RA_MenuAddItem(Menu,"\wAimdeki Kisiyi\r Dondur.","4");
        RA_MenuAddItem(Menu,"\wAimdeki Kisiyi\r Duzelt.","5");

        menu_setprop(Menu, MPROP_EXITNAME, "\wCikis");
        FC_CTMenuDisplay(id, Menu);
    }
    return PLUGIN_HANDLED;
}

public freezemenu2(id, menu, item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(item == MENU_EXIT || get_member(id, m_iTeam)!=TEAM_CT || !is_user_alive(id) || get_entvar(id, var_takedamage)) { menu_destroy(menu); return PLUGIN_HANDLED; }

    new data[6], key; 
    menu_item_getinfo(menu, item, _, data, charsmax(data));
    key = str_to_num(data);

    switch(key) {
        case 1 : dondur(id), freezemenu(id);
        case 2 : coz(id), freezemenu(id);
        case 3 : {
            if(surelidondurSayac>0) {
                remove_task(task_SURELIDON);
                client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1Sureli Freeze^4 durdurdu.", id);
                surelidondurSayac=0;
                freezemenu(id);

            } else surelifreeze(id);
        }
        case 4 : {
            new ids,body; get_user_aiming(id, ids, body);

            if(is_user_alive(ids) && get_member(ids, m_iTeam)==TEAM_TERRORIST) {

                oyuncuDondur(ids);
                client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1%n ^4adli mahkumu^3 dondurdu.", id, ids);

            } else client_print_color(id, id, "^1[^3%s^1]^4 Lutfen oyuncuya nisan al.", serverTAG);
            freezemenu(id);
        }
        case 5 : {
            new ids,body; get_user_aiming(id, ids, body);

            if(is_user_alive(ids) && get_member(ids, m_iTeam)==TEAM_TERRORIST) {

                oyuncuCoz(ids);
                client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1%n ^4adli mahkumu^3 cozdu.", id, ids);

            } else client_print_color(id, id, "^1[^3%s^1]^4 Lutfen oyuncuya nisan al.",serverTAG);
            freezemenu(id);
        }
    }
    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

public dondur(id) {
    if(get_member(id, m_iTeam)!=TEAM_CT) client_print_color(id, id, "^1[^3%s^1]^4 Bu menuyu sadece gardiyanlar kullanabilir.",serverTAG);
    else if(!is_user_alive(id)) client_print_color(id, id, "^1[^3%s^1]^4 Bu menuyu ^1oluyken^4 kullanamazsin.",serverTAG);
    else if(get_entvar(id, var_takedamage)) client_print_color(id, id, "^1[^3%s^1]^4 Freeze sadece ^1godmode aktifken^4 kullanilabilir.",serverTAG);
    else {

        new players[MAX_PLAYERS], num, ids;
        get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");

        for(new i=0; i<num; i++) {
            ids=players[i]; 

            oyuncuDondur(ids);
        

        }

        freezeKontrol=true;
        client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1tum mahkumlari^3 dondurdu.", id);
        rg_send_audio(0, ctmenu_freeze_don);
    }
    return PLUGIN_HANDLED;
}

public coz(id) {
    if(get_member(id, m_iTeam)!=TEAM_CT) client_print_color(id, id, "^1[^3%s^1]^4 Bu menuyu sadece gardiyanlar kullanabilir.",serverTAG);
    else if(!is_user_alive(id)) client_print_color(id, id, "^1[^3%s^1]^4 Bu menuyu ^1oluyken^4 kullanamazsin.",serverTAG);
    else if(get_entvar(id, var_takedamage)) client_print_color(id, id, "^1[^3%s^1]^4 Freeze sadece ^1godmode aktifken^4 kullanilabilir.",serverTAG);
    else {

        new players[MAX_PLAYERS], num, ids;
        get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");

        for(new i=0; i<num; i++) {
            ids=players[i]; 
            oyuncuCoz(ids);
        

        }

        freezeKontrol=false;
        client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1tum mahkumlari^3 cozdu.", id);
    }
    return PLUGIN_HANDLED;
}

public oyuncuDondur(const ids) {

    new flags=get_entvar(ids, var_flags);
    if(~flags & FL_FROZEN) {
        set_entvar(ids, var_flags, flags | FL_FROZEN);
        glowla(ids, 0, 100, 200), g_glow[ids]=true;
    }
}

public oyuncuCoz(const ids) {

    new flags=get_entvar(ids, var_flags);
    if(flags & FL_FROZEN){
        set_entvar(ids, var_flags, flags & ~FL_FROZEN);
        glowla(ids, 0, 0, 0), g_glow[ids]=false;
    }
}

public surelifreeze(id) {
    new ndmenu[128];
    formatex(ndmenu, charsmax(ndmenu),"\w%s \d|| \wSureli Freeze Menusu",serverTAG);
    new Menu = RA_MenuCreate(ndmenu, "surelifreeze2");

    RA_MenuAddItem(Menu,"\wT'yi \d[\r5 Saniye\d] \wSonra Dondur.","1");
    RA_MenuAddItem(Menu,"\wT'yi \d[\r10 Saniye\d] \wSonra Dondur.","2");
    RA_MenuAddItem(Menu,"\wT'yi \d[\r15 Saniye\d] \wSonra Dondur.","3");
    RA_MenuAddItem(Menu,"\wT'yi \d[\r20 Saniye\d] \wSonra Dondur.","4");
    RA_MenuAddItem(Menu,"\wT'yi \d[\r30 Saniye\d] \wSonra Dondur.","5");
    RA_MenuAddItem(Menu,"\wT'yi \d[\r40 Saniye\d] \wSonra Dondur.","6");
    RA_MenuAddItem(Menu,"\wT'yi \d[\r60 Saniye\d] \wSonra Dondur.","7");

    menu_setprop(Menu, MPROP_EXITNAME, "\wCikis");
    FC_CTMenuDisplay(id, Menu);
}

public surelifreeze2(id, menu, item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(item == MENU_EXIT || get_member(id, m_iTeam)!=TEAM_CT) { menu_destroy(menu); return PLUGIN_HANDLED; }

    new data[6], key; 
    menu_item_getinfo(menu, item, _, data, charsmax(data));
    key = str_to_num(data);

    switch(key) {
        case 1 : surelidondurSayac=5;
        case 2 : surelidondurSayac=10;
        case 3 : surelidondurSayac=15;
        case 4 : surelidondurSayac=20;
        case 5 : surelidondurSayac=30;
        case 6 : surelidondurSayac=40;
        case 7 : surelidondurSayac=60;
    }

    client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1Sureli Freeze^4 baslatti.", id);
    client_print_color(0, id, "^1[^3%s^1]^4 Mahkumlarin Dondurulmasina ^1[ ^3%d ^1]^4 saniye kaldi.", serverTAG, surelidondurSayac);
    remove_task(task_SURELIDON);
    set_task_ex(1.0, "surelifreeze3", task_SURELIDON, .flags = SetTask_Repeat);
    freezemenu(id);

    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

public surelifreeze3() {
    if(surelidondurSayac<=1) {
        remove_task(task_SURELIDON);
        surelidondurSayac=0;

        new players[MAX_PLAYERS], num, ids;
        get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");

        for(new i=0; i<num; i++) {
            ids=players[i]; 

            oyuncuDondur(ids);
        }
        rg_send_audio(0, ctmenu_freeze_don);
        client_print_color(0, 0, "^1[^3%s^1]^4 Mahkumlar donduruldu!",serverTAG);

    } else {
        surelidondurSayac--;
        client_print_color(0, print_team_blue, "^1[^3%s^1]^4 Mahkumlarin Dondurulmasina ^1[ ^3%d ^1]^4 saniye kaldi.",serverTAG, surelidondurSayac);
    }
}

public ffmenu(id) {
    if(get_member(id, m_iTeam)!=TEAM_CT) client_print_color(id, id, "^1[^3%s^1]^4 Bu menuye sadece ^1gardiyanlar^4 girebilir.", serverTAG);
    else if(!is_user_alive(id)) client_print_color(id, id, "^1[^3%s^1]^4 Bu menuye ^1oluyken^4 giremezsin.", serverTAG);
    else {

        new ndmenu[128];
        formatex(ndmenu, charsmax(ndmenu),"\w%s \d|| \wFF Menu",serverTAG);
        new Menu = RA_MenuCreate(ndmenu, "ffmenu2");

        RA_MenuAddItem(Menu,"\wDuz FF \r[\dSadece Bicak\w 100 HP\r]","1");
        RA_MenuAddItem(Menu,"\wBomba FF \r[\dBomba ve Bicak\w 100 HP\r]","2");
        RA_MenuAddItem(Menu,"\wRastgele FF \r[\dRastgele Silah\w 300 HP\r]^n","6");

        RA_MenuAddItem(Menu,"\wSeri FF \r[\dM4A1 ve AK47\w 500 HP\r]","3");
        RA_MenuAddItem(Menu,"\wPompa FF \r[\dPompalilar\w 500 HP\r]","4");
        RA_MenuAddItem(Menu,"\wDurbun FF \r[\dAWP ve Scout\w 500 HP\r]","5");
        RA_MenuAddItem(Menu,"\wKarisik FF \r[\dTum Silahlar\w 500 HP\r]","7");

        menu_setprop(Menu, MPROP_EXITNAME, "\wCikis");
        FC_CTMenuDisplay(id, Menu);
    }
}

public ffmenu2(id, menu, item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(item == MENU_EXIT || get_member(id, m_iTeam)!=TEAM_CT || !is_user_alive(id)) { menu_destroy(menu); return PLUGIN_HANDLED; }

    new data[6], key, players[MAX_PLAYERS], num, ids;
    menu_item_getinfo(menu, item, _, data, charsmax(data));
    key = str_to_num(data);
    if(!BridgeLegacyChoice(id,"ffmenu2",key)) {menu_destroy(menu);return PLUGIN_HANDLED;} 

    get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");
    switch(key) {
        case 1 : {
            for(new i=0; i<num; i++) {
                ids=players[i];

                rg_remove_all_items(ids);
                // set_entvar(ids, var_health, Float:100.0);
                rg_give_item(ids, "weapon_knife");
            
            }

            ffKontrol=true;

            client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan^1 Duz FF^4 oyunu baslatti.", id);
            rg_send_audio(0, ctmenu_duzff);
        }
        case 2 : {
            for(new i=0; i<num; i++) {
                ids=players[i];

                rg_remove_all_items(ids);
                // set_entvar(ids, var_health, Float:100.0);
                rg_give_item(ids, "weapon_knife");

                rg_give_item(ids, "weapon_hegrenade"),rg_set_user_bpammo(ids, WEAPON_HEGRENADE, 10);
                
            }
            ffKontrol=true;
            client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan^1 Bomba FF^4 oyunu baslatti.", id);
            rg_send_audio(0, ctmenu_silahliff);
        }
        case 3 : {
            for(new i=0; i<num; i++) {
                ids=players[i];

                set_entvar(ids, var_health, Float:500.0);
                rg_give_item(ids, "weapon_m4a1");
                rg_give_item(ids, "weapon_ak47");
                
            }
            ffKontrol=true;
            set_pcvar_num(mp_infinite_ammo, 1);
            client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan^1 Seri FF^4 oyunu baslatti.", id);
            rg_send_audio(0, ctmenu_silahliff);
        }
        case 4 : {
            for(new i=0; i<num; i++) {
                ids=players[i];

                set_entvar(ids, var_health, Float:500.0);
                rg_give_item(ids, "weapon_xm1014");
                rg_give_item(ids, "weapon_m3");
                
            }
            ffKontrol=true;
            set_pcvar_num(mp_infinite_ammo, 1);
            client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan^1 Pompali FF^4 oyunu baslatti.", id);
            rg_send_audio(0, ctmenu_silahliff);
        }
        case 5 : {
            for(new i=0; i<num; i++) {
                ids=players[i];

            
                rg_remove_all_items(ids);
                set_entvar(ids, var_health, Float:500.0);
                rg_give_item(ids, "weapon_knife");
                rg_give_item(ids, "weapon_awp");
                rg_give_item(ids, "weapon_scout");
            
            }
            ffKontrol=true;
            set_pcvar_num(mp_infinite_ammo, 1);
            client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan^1 Durbun FF^4 oyunu baslatti.", id);
            rg_send_audio(0, ctmenu_silahliff);
        }
        case 6 : {
            for(new i=0; i<num; i++) {
                ids=players[i];

                set_entvar(ids, var_health, Float:300.0);

                rg_give_item(ids, weapons[random_num(0, charsmax(weapons))]);
                
                
            }
            set_pcvar_num(mp_infinite_ammo, 1);
            client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan^1 Rastgele FF^4 oyunu baslatti.^3 Iyi Sanslar :)", id);
            rg_send_audio(0, ctmenu_silahliff);
        }
        case 7 : {
            for(new i=0; i<num; i++) {
                ids=players[i];

                set_entvar(ids, var_health, Float:500.0);
                rg_give_item(ids, "weapon_deagle");
                rg_give_item(ids, "weapon_m4a1");
                rg_give_item(ids, "weapon_awp");
                rg_give_item(ids, "weapon_ak47");
                rg_give_item(ids, "weapon_xm1014");
                rg_give_item(ids, "weapon_galil");
                rg_give_item(ids, "weapon_famas");
                
            }
            ffKontrol=true;
            set_pcvar_num(mp_infinite_ammo, 1);
            client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan^1 Karisik FF^4 oyunu baslatti.", id);
            rg_send_audio(0, ctmenu_silahliff);
        }
    }
    set_pcvar_num(mp_freeforall, 1);
    godver();

    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

public catismamenu(id) {
    if(get_member(id, m_iTeam)!=TEAM_CT) client_print_color(id, id, "^1[^3%s^1]^4 Bu menuye sadece ^1gardiyanlar^4 girebilir.",serverTAG);
    else if(!is_user_alive(id)) client_print_color(id, id, "^1[^3%s^1]^4 Bu menuye ^1oluyken^4 giremezsin.",serverTAG);
    else {

        new ndmenu[128];
        formatex(ndmenu, charsmax(ndmenu),"\w%s \d|| \wCatisma Menu", serverTAG);
        new Menu = RA_MenuCreate(ndmenu, "catismamenu2");

        RA_MenuAddItem(Menu,"\wT'nin HP'sini \rbelirle.","1");
        RA_MenuAddItem(Menu,"\wCT'nin HP'sini \rbelirle.^n","2");

        if(catismaKontrol) {
            RA_MenuAddItem(Menu,"\wCatisma 1 >\d T'ye \rAK47 ve M4A1\d, CT'ye \rAWP ve Deagle","3");
            RA_MenuAddItem(Menu,"\wCatisma 2 >\d Herkese Karisik Silah^n","4");
            RA_MenuAddItem(Menu,"\wT'ye unammo \rver.","5");
            RA_MenuAddItem(Menu,"\wCT'ye unammo \rver.","6");
            RA_MenuAddItem(Menu,"\wHerkese unammo \rver.","7");

        } else 
            menu_addtext(Menu, "\dCT'nin HP'sini belirledikten sonra catisma baslar ^nve diger menuler \r(unammo, silahlar vs.) \dacilir.");

        menu_setprop(Menu, MPROP_EXITNAME, "\wCikis");
        FC_CTMenuDisplay(id, Menu);
    }
}

public catismamenu2(id, menu, item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(item == MENU_EXIT || get_member(id, m_iTeam)!=TEAM_CT || !is_user_alive(id)) { menu_destroy(menu); return PLUGIN_HANDLED; }
    
    new data[6], key; 
    menu_item_getinfo(menu, item, _, data, charsmax(data));
    key = str_to_num(data);
    if(!BridgeLegacyChoice(id,"catismamenu2",key)) {menu_destroy(menu);return PLUGIN_HANDLED;}

    switch(key) {
        case 1 : hpKontrol=true, client_cmd(id, "messagemode T_HP_BELIRLE");
        case 2 : hpKontrol=true, client_cmd(id, "messagemode CT_HP_BELIRLE");
        case 3 : {
            new players[MAX_PLAYERS], num, ids, TeamName:team;
            get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_ExcludeBots);

            for(new i=0; i<num; i++) {
                ids=players[i];

                team=get_member(ids, m_iTeam);
                switch(team) {
                    case TEAM_TERRORIST : {
                        rg_give_item(ids, "weapon_m4a1");
                        rg_give_item(ids, "weapon_ak47");

                        rg_set_user_bpammo(ids, WEAPON_M4A1, 250), rg_set_user_bpammo(ids, WEAPON_AK47, 250);
                    }
                    case TEAM_CT : {
                        rg_give_item(ids, "weapon_awp");
                        rg_give_item(ids, "weapon_deagle");

                        rg_set_user_bpammo(ids, WEAPON_AWP, 250), rg_set_user_bpammo(ids, WEAPON_DEAGLE, 250);
                    }
                }
            }

            client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1catisma menusunden ^4T ve CT'lere silah verdi.", id);
            catismamenu(id);
        }
        case 4 : {
            new players[MAX_PLAYERS], num, ids;
            get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_ExcludeBots);

            for(new i=0; i<num; i++) {
                ids=players[i];

                rg_give_item(ids, "weapon_m4a1");
                rg_give_item(ids, "weapon_ak47");
                rg_give_item(ids, "weapon_deagle");
                rg_give_item(ids, "weapon_awp");
                rg_give_item(ids, "weapon_mp5navy");
                rg_give_item(ids, "weapon_galil");
                rg_give_item(ids, "weapon_famas");
                rg_set_user_bpammo(ids, WEAPON_M4A1, 250);
                rg_set_user_bpammo(ids, WEAPON_AK47, 250);
                rg_set_user_bpammo(ids, WEAPON_DEAGLE, 250);
                rg_set_user_bpammo(ids, WEAPON_AWP, 250);
                rg_set_user_bpammo(ids, WEAPON_MP5N, 250);
                rg_set_user_bpammo(ids, WEAPON_GALIL, 250);
                rg_set_user_bpammo(ids, WEAPON_FAMAS, 250);
            }
            
            client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1catisma menusunden ^4T ve CT'lere silah verdi.", id), catismamenu(id);
        }
        case 5 : {
            new players[MAX_PLAYERS],num;
            get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");

            for(new i=0; i<num; i++)
                g_unAmmo[players[i]]=true;

            client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1catisma menusunden ^4T'ye ^3unammo ^4verdi.", id); 
            catismamenu(id);
        }
        case 6 : {
            new players[MAX_PLAYERS], num;
            get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "CT");

            for(new i=0; i<num; i++)
                g_unAmmo[players[i]]=true;

            client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1catisma menusunden ^4CT'ye ^3unammo ^4verdi.", id);
            catismamenu(id);
        }
        case 7 : {
            set_pcvar_num(mp_infinite_ammo, 1);

            client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1catisma menusunden ^4herkese ^3unammo ^4verdi.", id);
            catismamenu(id);
        }
    }
    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

public t_hp(id) {
    if(!is_user_alive(id) || get_member(id, m_iTeam)!=TEAM_CT || !hpKontrol) 
        return PLUGIN_HANDLED;

    new say[16]; 
    read_args(say, charsmax(say)); remove_quotes(say);

    new miktar=str_to_num(say);
    if(!is_str_num(say) || equal(say, "") || miktar<1 || miktar>10000) { 
        client_print_color(id, id, "^1[^3%s^1]^4 1 ile 10000 arasi deger giriniz!", serverTAG);
        catismamenu(id); 
        return PLUGIN_HANDLED; 
    }

    new players[MAX_PLAYERS], num;
    get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");

    for(new i=0; i<num; i++) 
        set_entvar(players[i], var_health, Float:float(miktar));

    hpKontrol=false;
    client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1catisma menusunden ^4T'nin HP'sini ^3%d^4 olarak belirledi.", id, miktar);
    catismamenu(id);

    return PLUGIN_HANDLED;
}

public ct_hp(id) {
    if(!is_user_alive(id) || get_member(id, m_iTeam)!=TEAM_CT || !hpKontrol)
        return PLUGIN_HANDLED;

    new say[16]; 
    read_args(say, charsmax(say)); remove_quotes(say);

    new miktar=str_to_num(say);
    if(!is_str_num(say) || equal(say, "") || miktar<1 || miktar>50000) { 
        client_print_color(id, id, "^1[^3%s^1]^4 1 ile 50000 arasi deger giriniz!",serverTAG);
        catismamenu(id); 
        return PLUGIN_HANDLED; 
    }

    new players[MAX_PLAYERS],num; 
    get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "CT");

    for(new i=0; i<num; i++) 
        set_entvar(players[i], var_health, Float:float(miktar));
    
    catismaKontrol=true;
    hpKontrol=false; 

    client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1catisma menusunden ^4CT'nin HP'sini ^3%d^4 olarak belirledi.^3 Catisma Basladi!", id, miktar);
    catismamenu(id);

    return PLUGIN_HANDLED;
}

public islemlermenu(id) {
    if(get_member(id, m_iTeam)!=TEAM_CT) client_print_color(id, id, "^1[^3%s^1]^4 Bu menuye sadece ^1gardiyanlar^4 girebilir.",serverTAG);
    else if(!is_user_alive(id)) client_print_color(id, id, "^1[^3%s^1]^4 Bu menuye ^1oluyken^4 giremezsin.",serverTAG);
    else {

        new ndmenu[128];
        formatex(ndmenu, charsmax(ndmenu), "\w%s \d|| \wIslemler Menusu\d", serverTAG);
        new Menu = RA_MenuCreate(ndmenu, "islemlermenu2");

        formatex(ndmenu, charsmax(ndmenu), "\wCT Noclip \r%s", noclipKontrol ? "Kapat.":"AC.");
        RA_MenuAddItem(Menu, ndmenu, "3");

        #if defined semiclip_cvaraktif 
            formatex(ndmenu, charsmax(ndmenu), "\wSemiclip \r%s", get_pcvar_num(semiclip) ? "Kapat":"AC");
            RA_MenuAddItem(Menu, ndmenu, "1");
        #endif
        formatex(ndmenu, charsmax(ndmenu), "\wParasut \r%s", get_pcvar_num(sv_parachute) ? "Kapat":"AC");
        RA_MenuAddItem(Menu, ndmenu, "2");

        formatex(ndmenu,charsmax(ndmenu),"\wHud Bilgilendirme \r%s^n^n\dHava Ayarlari", g_hud[id] ? "AC.":"Kapat.");
        RA_MenuAddItem(Menu,ndmenu,"7");

        RA_MenuAddItem(Menu,"\wHavayi Gunduz \rYap.","4");
        RA_MenuAddItem(Menu,"\wHavayi Aksam \rYap.","5");
        RA_MenuAddItem(Menu,"\wHavayi Tam Karanlik \rYap.","6");

        menu_setprop(Menu, MPROP_EXITNAME, "\wCikis");
        FC_CTMenuDisplay(id, Menu);
    }
}

public islemlermenu2(id, menu, item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(item == MENU_EXIT || get_member(id, m_iTeam)!=TEAM_CT || !is_user_alive(id)) { menu_destroy(menu); return PLUGIN_HANDLED; }

    new data[6], key; 
    menu_item_getinfo(menu, item, _, data, charsmax(data));
    key = str_to_num(data);

    switch(key) {
        #if defined semiclip_cvaraktif
            case 1 : {
                
                    if(get_pcvar_num(semiclip)==1) set_pcvar_num(semiclip, 0), client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1Semiclip'i^4 kapatti.", id);
                    else set_pcvar_num(semiclip, 1), client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1Semiclip'i^4 acti.", id);
            }
        #endif

        case 2 : {
            if(get_pcvar_num(sv_parachute)) set_pcvar_num(sv_parachute, 0), client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1Parasut'u^4 kapatti.", id);
            else set_pcvar_num(sv_parachute, 1), client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1Parasut'u^4 acti.", id);
        }
        case 3 : {
            new players[MAX_PLAYERS], num; 
            get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "CT");

            if(noclipKontrol) {
                client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1CT Noclip^4 kapatti.", id);
                noclipKontrol=false;

                for(new i=0; i<num; i++) 
                    set_entvar(players[i], var_movetype, MOVETYPE_WALK);

            } else {
                client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1CT Noclip^4 acti.", id);
                noclipKontrol=true;

                for(new i=0; i<num; i++) 
                    set_entvar(players[i], var_movetype, MOVETYPE_NOCLIP);
            }
        }
        case 4 : client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan havayi ^1gunduz^4 yapti.", id), set_lights(defaultHava);
        case 5 : client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan havayi ^1aksam^4 yapti.", id), set_lights(aksamHava);
        case 6 : client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan havayi ^1tam karanlik^4 yapti.", id), set_lights("a");
    
        case 7 : {
            if(g_hud[id]) g_hud[id]=false, devam(id+task_HUD);
            else g_hud[id]=true;
        }
    }

    islemlermenu(id);
    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

public korumamenu(id) {
    if(get_member(id, m_iTeam)!=TEAM_CT) client_print_color(id, id, "^1[^3%s^1]^4 Bu menuye sadece ^1gardiyanlar^4 girebilir.",serverTAG);
    else if(!is_user_alive(id)) client_print_color(id, id, "^1[^3%s^1]^4 Bu menuye ^1oluyken^4 giremezsin.",serverTAG);
    else {
        new ndmenu[128];
        formatex(ndmenu, charsmax(ndmenu),"\w%s \d|| \wKoruma Menusu\d", serverTAG);
        new Menu = RA_MenuCreate(ndmenu, "korumamenu2");

        formatex(ndmenu, charsmax(ndmenu), "%s", \
        oylamaSayac ? "\wKoruma Oylamasi Devam Ediyor. \rIptal Et.":"\wKoruma Oylamasi Yap \r[\dSustum-Roket-Sarkac...\r]");
        RA_MenuAddItem(Menu, ndmenu, "1");

        RA_MenuAddItem(Menu,"\wRocket Menu \r[\w /rocket\r ] \dOtomatik God Verilir!","2");
        RA_MenuAddItem(Menu,"\wSarkac Baslat^n","5");
        RA_MenuAddItem(Menu,"\wRastgele Mahkum\r Sec.","3");
        RA_MenuAddItem(Menu,"\wIstedigin Korumaya \wIsyan Eli\r Ver.","4");

        menu_setprop(Menu, MPROP_EXITNAME, "\wCikis");
        FC_CTMenuDisplay(id, Menu);
    }
}

public korumamenu2(id, menu, item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(item == MENU_EXIT || get_member(id, m_iTeam)!=TEAM_CT || !is_user_alive(id)) { menu_destroy(menu); return PLUGIN_HANDLED; }

    new data[6], key; 
    menu_item_getinfo(menu, item, _, data, charsmax(data));
    key = str_to_num(data);

    switch(key) {
        case 1 : {
            new players[MAX_PLAYERS], num, ids;
            get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");

            if(oylamaSayac>0) {
                client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan^1 koruma oylamasini^4 durdurdu.", id);
                for(new y=0; y<num; y++) { 
                    ids=players[y]; 
                    show_menu(ids, 0, "");
                    remove_task(ids+task_KORUMA); 
                }

                oylamaSayac=0;
                remove_task(task_KORUMA);

                client_cmd(0, "stopsound");
            } else {

                for(new i=0; i<sizeof(korumaVoting); i++) 
                    korumaVoting[i]=0;

                oylamaSayac=15;

                set_task_ex(1.0, "eksilt", task_KORUMA, .flags = SetTask_Repeat);
                set_task(15.5, "oylamabitir", task_KORUMA);

                for(new x=0; x<num; x++) {
                    ids=players[x];

                    g_oylama[ids]=false;
                    korumaoylamamenu(ids+task_KORUMA);
                    set_task_ex(1.0, "korumaoylamamenu", ids+task_KORUMA, .flags = SetTask_Repeat);	
                }

                client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1koruma oylamasi^4 baslatti.^3 15 saniye^4 sonra oylama bitecektir!", id);
                rg_send_audio(0, ctmenu_koruma);
            }

            korumamenu(id);
        }
        case 2 : rocketmenu(id);

        case 3 : {
            new players[MAX_PLAYERS], num, ids; 
            get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");

            if(num>0) {
                ids=players[random_num(0, num-1)];

                for(new i=0; i<3; i++) 
                    client_print_color(0, id, "^1[^3%s^1]^4 Rastgele secilen mahkum > ^3[^1%n^3]", serverTAG, ids);

            } else client_print_color(id, id, "^1[^3%s^1]^4 Mahkum yok.",serverTAG);
            korumamenu(id);
        }
        case 4 : {

            new players[MAX_PLAYERS],num; 
            get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "CT");

            if(num>1) {
                new ndmenu[128], inum[6], ids;

                formatex(ndmenu, charsmax(ndmenu),"\w%s \d|| \wHangi Korumaya Isyan Eli Verilsin?\d", serverTAG);
                new Menu = RA_MenuCreate(ndmenu, "korumasec");

                for(new i=0; i<num; i++) {
                    ids=players[i];
                    if(ids==id) continue;

                    num_to_str(ids, inum, charsmax(inum));
                    formatex(ndmenu, charsmax(ndmenu),"\wSec \w> \r%n",ids);
                    RA_MenuAddItem(Menu, ndmenu, inum);
                }
                menu_addtext(Menu, "^n\dKorumayi Alan Koruma Olacak");

                menu_setprop(Menu, MPROP_EXITNAME, "\wCikis");
                FC_CTMenuDisplay(id, Menu);

            } else client_print_color(id, id, "^1[^3%s^1]^4 Yasayan koruma olmadigi icin ^1isyan^3 baslatamazsin.",serverTAG), korumamenu(id);
        }
        case 5 : {
            if(sarkacKontrol) client_print_color(id, id, "^1[^3%s^1]^4 Sarkac suan zaten aktif.",serverTAG);
            else client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1Sarkac^4 oyununu baslatti.", id), Oyunu_Baslat();
        }
    }
    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

public korumaoylamamenu(id) {
    id=id- task_KORUMA;
    if(oylamaSayac>0) {
        new ndmenu[128];
        formatex(ndmenu, charsmax(ndmenu),"\w%s \d|| \wKoruma Oylamasi^n\dOylamanin bitmesine son \r%d saniye\d kaldi!",serverTAG,oylamaSayac);
        new Menu = RA_MenuCreate(ndmenu, "korumaoylamamenu2");

        formatex(ndmenu, charsmax(ndmenu), "%sT-Sustum \r[ \w%d Oy\r ]",g_oylama[id] ? "\d":"\w" ,korumaVoting[0]);
        g_oylama[id] ? RA_MenuAddItem(Menu,ndmenu,"6"):RA_MenuAddItem(Menu,ndmenu,"1");

        formatex(ndmenu, charsmax(ndmenu), "%sRocket \r[ \w%d Oy\r ]",g_oylama[id] ? "\d":"\w" ,korumaVoting[1]);
        g_oylama[id] ? RA_MenuAddItem(Menu,ndmenu,"6"):RA_MenuAddItem(Menu,ndmenu,"2");

        formatex(ndmenu, charsmax(ndmenu), "%sSarkac \r[ \w%d Oy\r ]",g_oylama[id] ? "\d":"\w" ,korumaVoting[2]);
        g_oylama[id] ? RA_MenuAddItem(Menu,ndmenu,"6"):RA_MenuAddItem(Menu,ndmenu,"3");

        formatex(ndmenu, charsmax(ndmenu), "%sDomates \r[ \w%d Oy\r ]",g_oylama[id] ? "\d":"\w" ,korumaVoting[3]);
        g_oylama[id] ? RA_MenuAddItem(Menu,ndmenu,"6"):RA_MenuAddItem(Menu,ndmenu,"4");

        formatex(ndmenu, charsmax(ndmenu), "%sOyun \r[ \w%d Oy\r ]^n",g_oylama[id] ? "\d":"\w" ,korumaVoting[4]);
        g_oylama[id] ? RA_MenuAddItem(Menu,ndmenu,"6"):RA_MenuAddItem(Menu,ndmenu,"5");

        menu_addtext(Menu, "\wOylamada Esitlik Olursa Rastgele secilir!");

        menu_setprop(Menu, MPROP_EXITNAME, "\wCikis");
        FC_CTMenuDisplay(id, Menu);

    } else remove_task(id+task_KORUMA), show_menu(id,0,"");
}

public korumaoylamamenu2(id, menu, item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(item == MENU_EXIT) { menu_destroy(menu); return PLUGIN_HANDLED; }

    new data[6], key; 
    menu_item_getinfo(menu, item, _, data, charsmax(data));
    key = str_to_num(data);

    switch(key) {
        case 1 : {
            korumaVoting[key-1]++;
            g_oylama[id]=true;
            client_print_color(0, print_team_grey, "^1[^3%n^1]^4 Adli Oyuncunun Oyu ^3>   [^1T-SUSTUM^3]  ^4  : %d", id, korumaVoting[key-1]);
        }
        case 2 : {
            korumaVoting[key-1]++;
            g_oylama[id]=true;
            client_print_color(0, print_team_grey, "^1[^3%n^1]^4 Adli Oyuncunun Oyu ^3>   [^1ROKET^3]  ^4  : %d", id, korumaVoting[key-1]);
        }
        case 3 : {
            korumaVoting[key-1]++;
            g_oylama[id]=true;
            client_print_color(0, print_team_grey, "^1[^3%n^1]^4 Adli Oyuncunun Oyu ^3>   [^1SARKAC^3]  ^4  : %d", id, korumaVoting[key-1]);
        }
        case 4 : {
            korumaVoting[key-1]++;
            g_oylama[id]=true;
            client_print_color(0, print_team_grey, "^1[^3%n^1]^4 Adli Oyuncunun Oyu ^3>   [^1DOMATES^3]  ^4  : %d", id, korumaVoting[key-1]);
        }
        case 5 : {
            korumaVoting[key-1]++;
            g_oylama[id]=true;
            client_print_color(0, print_team_grey, "^1[^3%n^1]^4 Adli Oyuncunun Oyu ^3>   [^1OYUN^3]  ^4  : %d", id, korumaVoting[key-1]);
        }

        case 6 : client_print_color(id, id, "^1[^3%s^1]^4 Siz oy verdiniz!", serverTAG);
    }

    korumaoylamamenu(id+task_KORUMA);
    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

public oylamabitir() {
    remove_task(task_KORUMA);

    new sonuc = 0, max = korumaVoting[0];
    for(new i=1; i<sizeof(korumaVoting); i++) {

        if((korumaVoting[i] > max) || (korumaVoting[i] == max && random_num(1,2) == 1)) {
            max = korumaVoting[i];
            sonuc = i;
        }
    }

    switch(sonuc) {
        case 0 : for(new i=0; i<5; i++) client_print_color(0, print_team_blue, "^1[^3%s^1]^4 Oylamada ^3[^1T-SUSTUM^3]^4 Kazandi!",serverTAG);
        case 1 : for(new i=0; i<5; i++) client_print_color(0, print_team_blue, "^1[^3%s^1]^4 Oylamada ^3[^1ROCKET^3]^4 Kazandi!",serverTAG);
        case 2 : for(new i=0; i<5; i++) client_print_color(0, print_team_blue, "^1[^3%s^1]^4 Oylamada ^3[^1SARKAC^3]^4 Kazandi!",serverTAG);
        case 3 : for(new i=0; i<5; i++) client_print_color(0, print_team_blue, "^1[^3%s^1]^4 Oylamada ^3[^1DOMATES^3]^4 Kazandi!",serverTAG);
        case 4 : for(new i=0; i<5; i++) client_print_color(0, print_team_blue, "^1[^3%s^1]^4 Oylamada ^3[^1OYUN^3]^4 Kazandi!",serverTAG);
    }
}

public rocketmenu(id) {
    if(get_member(id, m_iTeam)!=TEAM_CT) client_print_color(id, id, "^1[^3%s^1]^4 Bu menuye sadece ^1gardiyanlar^4 girebilir.",serverTAG);
    else if(!is_user_alive(id)) client_print_color(id, id, "^1[^3%s^1]^4 Bu menuye ^1oluyken^4 giremezsin.",serverTAG);
    else {
        new ndmenu[128];
        formatex(ndmenu, charsmax(ndmenu),"\w%s \d|| \wRocket Menu\d",serverTAG);
        new Menu = RA_MenuCreate(ndmenu, "rocketmenu2");

        RA_MenuAddItem(Menu,"\wT'yi \d[\r5 Saniye\d] \wSonra Rocketle.","1");
        RA_MenuAddItem(Menu,"\wT'yi \d[\r10 Saniye\d] \wSonra Rocketle.","2");
        RA_MenuAddItem(Menu,"\wT'yi \d[\r15 Saniye\d] \wSonra Rocketle.","3");
        RA_MenuAddItem(Menu,"\wT'yi \d[\r20 Saniye\d] \wSonra Rocketle.","4");
        RA_MenuAddItem(Menu,"\wT'yi \d[\r30 Saniye\d] \wSonra Rocketle.","5");
        RA_MenuAddItem(Menu,"\wT'yi \d[\r40 Saniye\d] \wSonra Rocketle.","6");
        RA_MenuAddItem(Menu,"\wT'yi \d[\r60 Saniye\d] \wSonra Rocketle.","7");

        menu_setprop(Menu, MPROP_EXITNAME, "\wCikis");
        FC_CTMenuDisplay(id, Menu);
    }
}

public rocketmenu2(id, menu, item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(item == MENU_EXIT || get_member(id, m_iTeam)!=TEAM_CT || !is_user_alive(id)) { menu_destroy(menu); return PLUGIN_HANDLED; }

    new data[6], key; 
    menu_item_getinfo(menu, item, _, data, charsmax(data));
    key = str_to_num(data);
    if(!BridgeLegacyChoice(id,"rocketmenu2",key)) {menu_destroy(menu);return PLUGIN_HANDLED;}

    switch(key) {
        case 1 : rocketSayac=5;
        case 2 : rocketSayac=10;
        case 3 : rocketSayac=15;
        case 4 : rocketSayac=20;
        case 5 : rocketSayac=30;
        case 6 : rocketSayac=40;
        case 7 : rocketSayac=60;
    }
    #if defined semiclip_cvaraktif 
        set_pcvar_num(semiclip, 1);
    #endif
    set_pcvar_num(mp_infinite_ammo, 1);

    new players[MAX_PLAYERS],num,ids;
    get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");

    for(new i=0; i<num; i++) {
        ids=players[i];
        rg_give_item(ids, "weapon_tmp");
    }

    if(rocketSayac==10) 
        rg_send_audio(0, ctmenu_onsaniye);

    client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1Rocket^4 baslatti!", id);
    client_print(0, print_center, "Mahkumlarin Rocketlenmesine [ %d ] Saniye Kaldi.",rocketSayac);

    remove_task(task_ROCKET);
    set_task_ex(1.0, "rocketle", task_ROCKET, .flags = SetTask_Repeat);
    godver();
    hucrekapisiniac(id);
    ctmenu(id);

    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

public rocketle() {
    if(rocketSayac<=1) {
        remove_task(task_ROCKET);
        t_rocketle();
        client_print(0, print_center, "Sure Bitti ve Mahkumlar Rocketlendi!");

    } else {

        if(rocketSayac==11)
            rg_send_audio(0, ctmenu_onsaniye);

        rocketSayac--;
        client_print(0, print_center, "Mahkumlarin Rocketlenmesine [ %d ] Saniye Kaldi.", rocketSayac);
        //client_print_color(0, print_team_blue, "^1[^3%s^1]^4 Mahkumlarin Rocketlenmesine^3 [^1 %d^3 ]^4 Saniye Kaldi.",serverTAG,rocketSayac);
    }
}

public t_rocketle() {
    new players[MAX_PLAYERS], num, id;
    get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");

    for(new i=0; i<num; i++) {
        id=players[i];

        rh_emit_sound2(id, 0, CHAN_WEAPON, ctmenu_rocketfire);
        set_entvar(id, var_maxspeed, 0.01);
        set_task(1.2, "rocket_liftoff", id);
    }
}

public rocket_liftoff(id) { 
    if(is_user_alive(id)) {

        set_entvar(id, var_gravity, -0.50);
        client_cmd(id, "+jump;wait;wait;-jump");
        rh_emit_sound2(id, 0, CHAN_VOICE, ctmenu_rocket1);
        rocket_effects(id);
    }
}

public rocket_effects(id) {
    if(is_user_alive(id)) {
        static origin[3]; get_user_origin(id, origin);

        message_begin(MSG_ONE, Damage, {0,0,0}, id);
        write_byte(30), write_byte(30), write_long(1<<16);
        write_coord(origin[0]), write_coord(origin[1]), write_coord(origin[2]);
        message_end();

        static rocket_z[MAX_CLIENTS+1];

        if(rocket_z[id] == origin[2]) 
            rocket_explode(id);

        rocket_z[id]=origin[2];
        message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
        write_byte(15);
        write_coord(origin[0]), write_coord(origin[1]), write_coord(origin[2]);
        write_coord(origin[0]), write_coord(origin[1]), write_coord(origin[2] - 30);
        write_short(g_sprs[0]);
        write_byte(5), write_byte(1), write_byte(1), write_byte(10), write_byte(5);
        message_end();

        message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
        write_byte(17);
        write_coord(origin[0]), write_coord(origin[1]), write_coord(origin[2] - 30);
        write_short(g_sprs[1]);
        write_byte(15), write_byte(255);
        message_end();

        set_task(0.2, "rocket_effects", id);
    } 
}

public rocket_explode(id) {
    if(is_user_alive(id)) {
        new origin[3]; get_user_origin(id, origin);

        message_begin(MSG_BROADCAST, SVC_TEMPENTITY, origin);
        write_byte(21);
        write_coord(origin[0]); write_coord(origin[1]); write_coord(origin[2] - 10);
        write_coord(origin[0]); write_coord(origin[1]); write_coord(origin[2] + 1910);
        write_short(g_sprs[2]);
        write_byte(0); write_byte(0); write_byte(2); write_byte(16); write_byte(0);
        write_byte(188); write_byte(220); write_byte(255); write_byte(255); write_byte(0);
        message_end();

        message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
        write_byte(12);
        write_coord(origin[0]); write_coord(origin[1]); write_coord(origin[2]);
        write_byte(188); write_byte(10);
        message_end();

        message_begin(MSG_BROADCAST, SVC_TEMPENTITY, origin);
        write_byte(5);
        write_coord(origin[0]); write_coord(origin[1]); write_coord(origin[2]);
        write_short(g_sprs[3]);
        write_byte(2); write_byte(10);
        message_end();

        set_task(random_float(0.01, 0.3), "oyuncuOldur", id);//user_kill(id, 1);

        rh_emit_sound2(id, 0, CHAN_VOICE, ctmenu_rocket1, 0.0, 0.0, (1<<5));
        
        set_entvar(id, var_maxspeed, 1.0);
        set_entvar(id, var_gravity, 1.00);
    }
}

public korumasec(id, menu, item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(item == MENU_EXIT || get_member(id, m_iTeam)!=TEAM_CT) { menu_destroy(menu); return PLUGIN_HANDLED; }

    new data[6], ids; 
    menu_item_getinfo(menu, item, _, data, charsmax(data));
    ids = str_to_num(data);

    ayarsifirla();
    g_koruma[ids]=true;
    glowla(ids, 255, 140, 0), g_glow[ids]=true;

    set_dhudmessage(255, 140, 0, -1.0, 0.3, 2, 0.5, 3.0);
    show_dhudmessage(0, "Isyan Eli Basladi!^n[ %n ] Adli Korumayi olduren Koruma Olacak!", ids);

    client_print_color(0, print_team_blue, "^1[^3%s^1]^4 Isyan eli basladi! ^3[^1%n^3]^4 adli korumayi olduren yeni koruma olacak!", serverTAG, ids);
    hucrekapisiniac(id);

    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

public gardiyanyardim(id) {
    if(get_member(id,m_iTeam)!=TEAM_CT) client_print_color(id,id,"^1[^3%s^1] ^4Bu menuye sadece ^1gardiyanlar^4 girebilir.",serverTAG);
    else if(!is_user_alive(id)) client_print_color(id,id,"^1[^3%s^1] ^4Bu menuye oluyken giris yapamazsin.",serverTAG);
    else if(yardimSayac[id]>0) client_print_color(id,id,"^1[^3%s^1] ^4Bu menuyu^1 3 elde 1^4 kullanabilirsin.",serverTAG), ctmenu(id);
    else {

        new ndmenu[128];
        formatex(ndmenu, charsmax(ndmenu),"\w%s \d|| \wGardiyan Yardim Menu",serverTAG);
        new Menu = RA_MenuCreate(ndmenu, "gardiyanyardim2");

        RA_MenuAddItem(Menu,"\wUnammo Al.","1");
        RA_MenuAddItem(Menu,"\wVerecegin Hasari Ikiye Katla.","2");
        RA_MenuAddItem(Menu,"\wAlacagin Hasari Yariya Dusur.","3");
        RA_MenuAddItem(Menu,"\w+75 HP Al.","4");
        RA_MenuAddItem(Menu,"\w+150 Armor Al.","5");
        RA_MenuAddItem(Menu,"\wT'yi Disarmla.^n","6");
        menu_addtext(Menu, "\dBu menuyu \r3 elde 1\d kullanabilirsin.");

        menu_setprop(Menu, MPROP_EXITNAME, "\wCikis");
        FC_CTMenuDisplay(id, Menu);
    }
}

public gardiyanyardim2(id, menu, item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(item == MENU_EXIT || get_member(id, m_iTeam)!=TEAM_CT || !is_user_alive(id)) { menu_destroy(menu); return PLUGIN_HANDLED; }

    new data[6], key; 
    menu_item_getinfo(menu, item, _, data, charsmax(data));
    key = str_to_num(data);

    switch(key) {
        case 1 : g_unAmmo[id]=true, client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1yardim menusunden^3 Unammo^4 aldi.", id);
        case 2 : {
            EnableHookChain(h_Dmg);
            g_hasarKatla[id]=true;
            client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1yardim menusunden^3 Hasar Katla^4 aldi.", id);
        }
        case 3 : {
            EnableHookChain(h_Dmg);
            g_hasarAzalt[id]=true;
            client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1yardim menusunden^3 Hasar Azalt^4 aldi.", id);
        }
        case 4 : set_entvar(id, var_health, Float:get_entvar(id, var_health)+75.0), client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1yardim menusunden^3 +75 HP^4 aldi.", id);
        case 5 : set_entvar(id, var_armorvalue, Float:get_entvar(id, var_armorvalue)+150.0), client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1yardim menusunden^3 +150 HP^4 aldi.", id);
        case 6 : {
            new players[MAX_PLAYERS],num,ids;
            get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");

            for(new i=0; i<num; i++) {
                ids=players[i];
                rg_remove_all_items(ids), rg_give_item(ids, "weapon_knife");
            }
            client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1yardim menusuyle^4 mahkumlari^3 disarmladi.", id);
        }
    }
    yardimSayac[id]=3;
    ctmenu(id);

    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

public slaymenu(id) {
    if(get_member(id, m_iTeam)!=TEAM_CT) client_print_color(id, print_team_blue, "^1[^3%s^1]^4 Bu menuye sadece ^1gardiyanlar^4 girebilir.",serverTAG);
    else if(get_entvar(id, var_takedamage)) client_print_color(id, print_team_blue, "^1[^3%s^1]^4 Bu menuye sadece ^1godmode aktifken^4 girebilir.",serverTAG),ctmenu(id);
    else {

        new ndmenu[128], inum[6], players[MAX_PLAYERS], num, ids;
        get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_ExcludeBots);

        formatex(ndmenu, charsmax(ndmenu),"\w%s \d|| \wSlay Menu\d",serverTAG);
        new Menu = RA_MenuCreate(ndmenu, "slaymenu2");

        for(new i=0; i<num; i++) {
            ids=players[i];
            if(ids==id) continue;

            num_to_str(ids, inum, charsmax(inum));
            formatex(ndmenu, charsmax(ndmenu),"\wSec \w> \r%n", ids);
            RA_MenuAddItem(Menu, ndmenu, inum);
        }

        menu_setprop(Menu, MPROP_BACKNAME, "\wOnceki Menu");
        menu_setprop(Menu, MPROP_NEXTNAME, "\wDiger Menu");
        menu_setprop(Menu, MPROP_EXITNAME, "\wCikis");
        FC_CTMenuDisplay(id, Menu);
    }
}

public slaymenu2(id, menu, item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(item == MENU_EXIT || get_member(id, m_iTeam)!=TEAM_CT || get_entvar(id, var_takedamage)) { menu_destroy(menu); return PLUGIN_HANDLED; }

    new data[6], ids; 
    menu_item_getinfo(menu, item, _, data, charsmax(data));
    ids = str_to_num(data);

    if(is_user_alive(ids)) {
        user_kill(ids, 1);
        client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1%n^4 adli oyuncuyu ^3slayladi.", id, ids);
        slaymenu(id);

    }
    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

public sonsecmenu(id) {
    if(get_member(id, m_iTeam)!=TEAM_CT) { 
        client_print_color(id, id, "^1[^3%s^1] ^4Bu menuye sadece^1 gardiyanlar ^4girebilir.",serverTAG); 
        return PLUGIN_HANDLED; 
    }

    new players[MAX_PLAYERS], inum; 
    get_players_ex(players, inum, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");

    if(inum<=1) client_print_color(id, id, "^1[^3%s^1] ^4Zaten sona ^1bir tane^4 mahkum kaldi.",serverTAG);
    else if(!is_user_alive(id)) client_print_color(id, id, "^1[^3%s^1] ^4Bu menuye ^1oluyken ^4giremezsin.",serverTAG);
    else {

        new ndmenu[128], sznum[6], ids; 
        get_players_ex(players, inum, GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");

        formatex(ndmenu, charsmax(ndmenu),"\w%s \d|| \wSona kalacak mahkumu sec.^n\dSececegin mahkum revlenir, disinda herkes oldurulur.\d",serverTAG);
        new Menu = RA_MenuCreate(ndmenu, "sonsecmenu2");
    
        for(new i=0; i<inum; i++) {
            ids=players[i];

            num_to_str(ids,sznum,charsmax(sznum)); 
            formatex(ndmenu,charsmax(ndmenu),"\wSec \w> \r%n",ids);
            RA_MenuAddItem(Menu,ndmenu,sznum);
        }

        menu_setprop(Menu, MPROP_BACKNAME, "\wOnceki Menu");
        menu_setprop(Menu, MPROP_NEXTNAME, "\wDiger Menu");
        menu_setprop(Menu, MPROP_EXITNAME, "\wCikis");
        FC_CTMenuDisplay(id, Menu);
    }
    return PLUGIN_HANDLED;
}

public sonsecmenu2(id, menu, item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(item == MENU_EXIT || get_member(id, m_iTeam)!=TEAM_CT || !is_user_alive(id)) { menu_destroy(menu); return PLUGIN_HANDLED; }

    new data[6], uid; 
    menu_item_getinfo(menu, item, _, data, charsmax(data));
    uid = str_to_num(data);

    if(!is_user_connected(uid))
        return PLUGIN_HANDLED;

    rg_round_respawn(uid);
    client_print_color(0, id, "^1[^3%n^1] ^4adli gardiyan, ^1[^3%n^1]^4 adli mahkumu sona birakip diger mahkumlari oldurdu.", id, uid);
    
    new players[MAX_PLAYERS], inum, ids;
    get_players_ex(players, inum, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");

    for(new i=0; i<inum; i++) {
        ids=players[i];

        if(ids==uid) 
            continue;
        
        user_kill(ids, 1);
    }

    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

public isinlamenu(id) {
    if(get_member(id, m_iTeam)!=TEAM_CT) client_print_color(id, print_team_blue, "^1[^3%s^1]^4 Bu menuye sadece ^1gardiyanlar^4 girebilir.",serverTAG);
    else if(get_entvar(id, var_takedamage)) client_print_color(id, print_team_blue, "^1[^3%s^1]^4 Bu menuye sadece ^1godmode aktifken^4 girebilir.",serverTAG),ctmenu(id);
    else {

        new ndmenu[128];
        formatex(ndmenu, charsmax(ndmenu),"\w%s \d|| \wIsinlama Menusu\d",serverTAG);
        new Menu = RA_MenuCreate(ndmenu, "isinlamenu2");

        RA_MenuAddItem(Menu,"\wT'yi Yanina Isinla. \r[\w/getir\r]","1");
        RA_MenuAddItem(Menu,"\wT'yi Sececegin Yonde Sirala Menusu \r[\w/sirala\r]","3");
        RA_MenuAddItem(Menu,"\wT'yi Baktigin Yere Daire seklinde isinla \r[\w/daire\r]^n","2");
        RA_MenuAddItem(Menu,"\wOyuncunun Yanina Isinlan","6");
        RA_MenuAddItem(Menu,"\wOyuncuyu Yanina Isinla^n","7");

        if(freezeKontrol) RA_MenuAddItem(Menu,"\wT'yi Coz. \r[\w/coz\r]","5");
        else RA_MenuAddItem(Menu,"\wT'yi Dondur. \r[\w/dondur\r]","4");

        RA_MenuAddItem(Menu,"\wCtmenu'ye Don.","8");

        menu_setprop(Menu, MPROP_EXITNAME, "\wCikis");
        FC_CTMenuDisplay(id, Menu);
    }
}

public isinlamenu2(id, menu, item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(item == MENU_EXIT || get_member(id, m_iTeam)!=TEAM_CT || get_entvar(id, var_takedamage)) { menu_destroy(menu); return PLUGIN_HANDLED; }

    new data[6], key; 
    menu_item_getinfo(menu, item, _, data, charsmax(data));
    key = str_to_num(data);

    switch(key) {
        case 1 : t_isinla(id), isinlamenu(id);
        case 2 : daire(id), isinlamenu(id);
        case 3 : yansirala(id);
        case 4 : dondur(id), isinlamenu(id);
        case 5 : coz(id), isinlamenu(id);
        case 6 : yaninaisinlan(id);
        case 7 : yaninaisinla(id);
        case 8 : ctmenu(id);
    }
    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

public yaninaisinlan(id) {
    if(get_member(id, m_iTeam)!=TEAM_CT) client_print_color(id, print_team_blue, "^1[^3%s^1]^4 Bu menuye sadece ^1gardiyanlar^4 girebilir.",serverTAG);
    else if(get_entvar(id, var_takedamage)) client_print_color(id, print_team_blue, "^1[^3%s^1]^4 Bu menuye sadece ^1godmode aktifken^4 girebilir.",serverTAG), ctmenu(id);
    else {

        new ndmenu[128], inum[6], players[MAX_PLAYERS], num, ids;
        get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_ExcludeBots);

        formatex(ndmenu, charsmax(ndmenu),"\w%s \d|| \wOyuncunun Yanina ?inlan^n\dSectigin oyuncunun yanina isinlanirsin.",serverTAG);
        new Menu = RA_MenuCreate(ndmenu, "yaninaisinlan2");

        for(new i=0; i<num; i++) {
            ids=players[i];
            if(ids==id) continue;

            num_to_str(ids, inum, charsmax(inum));
            formatex(ndmenu, charsmax(ndmenu),"\wSec \w> \r%n",ids);
            RA_MenuAddItem(Menu, ndmenu, inum);
        }

        menu_setprop(Menu, MPROP_BACKNAME, "\wOnceki Menu");
        menu_setprop(Menu, MPROP_NEXTNAME, "\wDiger Menu");
        menu_setprop(Menu, MPROP_EXITNAME, "\wCikis");
        FC_CTMenuDisplay(id, Menu);
    }
}

public yaninaisinlan2(id, menu, item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(item == MENU_EXIT || get_member(id, m_iTeam)!=TEAM_CT || get_entvar(id, var_takedamage)) { menu_destroy(menu); return PLUGIN_HANDLED; }

    new data[6], ids; 
    menu_item_getinfo(menu, item, _, data, charsmax(data));
    ids = str_to_num(data);

    if(is_user_alive(ids)) {
        new Float:kordinat[3]; 
        get_entvar(ids, var_origin, kordinat); 
        kordinat[0]+=35.0;

        set_entvar(id, var_origin, kordinat);
        checkstuckid(id);
        client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1%n^4 adli oyuncunun yanina ^3isinlandi.", id, ids),isinlamenu(id);
    
    } else client_print_color(id, print_team_blue, "^1[^3%s^1]^4 Bu oyuncu yasamiyor.", serverTAG),isinlamenu(id);
    
    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

public yaninaisinla(id) {
    if(get_member(id, m_iTeam)!=TEAM_CT) client_print_color(id, print_team_blue, "^1[^3%s^1]^4 Bu menuye sadece ^1gardiyanlar^4 girebilir.",serverTAG);
    else if(get_entvar(id, var_takedamage)) client_print_color(id, print_team_blue, "^1[^3%s^1]^4 Bu menuye sadece ^1godmode aktifken^4 girebilir.",serverTAG), ctmenu(id);
    else {
        new ndmenu[128], inum[6], players[MAX_PLAYERS], num, ids;
        get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_ExcludeBots);

        formatex(ndmenu, charsmax(ndmenu),"\w%s \d|| \wOyuncuyu Yanina ?inla^n\dSectigin oyuncu yanina isinlanir.",serverTAG);
        new Menu = RA_MenuCreate(ndmenu, "yaninaisinla2");

        for(new i=0; i<num; i++) {
            ids=players[i];
            if(ids==id) continue;

            num_to_str(ids, inum, charsmax(inum));
            formatex(ndmenu, charsmax(ndmenu),"\wSec \w> \r%n", ids);
            RA_MenuAddItem(Menu, ndmenu, inum);

        }

        menu_setprop(Menu, MPROP_BACKNAME, "\wOnceki Menu");
        menu_setprop(Menu, MPROP_NEXTNAME, "\wDiger Menu");
        menu_setprop(Menu, MPROP_EXITNAME, "\wCikis");
        FC_CTMenuDisplay(id, Menu);
    }
}

public yaninaisinla2(id, menu, item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(item == MENU_EXIT || get_member(id, m_iTeam)!=TEAM_CT || get_entvar(id, var_takedamage)) { menu_destroy(menu); return PLUGIN_HANDLED; }

    new data[6], ids; 
    menu_item_getinfo(menu, item, _, data, charsmax(data));
    ids = str_to_num(data);

    if(is_user_alive(ids)) {
        new Float:kordinat[3]; 
        get_entvar(id, var_origin, kordinat); 
        kordinat[0]+=35.0;

        set_entvar(ids, var_origin, kordinat);
        checkstuckid(ids);
        client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1%n^4 adli oyuncuyu yanina ^3isinladi.", id, ids), isinlamenu(id);
    
    } else client_print_color(id, print_team_blue, "^1[^3%s^1]^4 Bu oyuncu yasamiyor.", serverTAG), isinlamenu(id);
    
    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

public yansirala(id) {
    siralamaNum = get_playersnum_ex(GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");

    if(get_member(id, m_iTeam)!=TEAM_CT) {
        client_print_color(id, id, "^1[^3%s^1]^4 Bu komut ^1gardiyanlara ^4ozeldir.",serverTAG);
        remove_task(id+task_SIRALACIZGI);
        g_sirala[id]=false;

    } else if(get_entvar(id, var_takedamage)) {
        client_print_color(id, id, "^1[^3%s^1]^4 Bu komutu sadece^1 godmode aktifken^4 kullanabilirsin.",serverTAG);
        remove_task(id+task_SIRALACIZGI);
        g_sirala[id]=false;

    } else if(!is_user_alive(id)) {
        client_print_color(id, id, "^1[^3%s^1]^4 Bu komutu sadece^1 yasarken^4 kullanabilirsin.",serverTAG);
        remove_task(id+task_SIRALACIZGI);
        g_sirala[id]=false;

    } else if(siralamaNum<2) {
        client_print_color(id, id, "^1[^3%s^1]^4 Bu menuyu uygulayabilmek icin yasayan en az ^1iki ^4mahkum olmasi gerekir.",serverTAG);
        remove_task(id+task_SIRALACIZGI);
        g_sirala[id]=false;

    } else {

        new ndmenu[128];
        formatex(ndmenu, charsmax(ndmenu),"\w%s \d|| \wSiralama Menu^n\dBaktiginiz yere T'yi sirali sekilde isinlar.",serverTAG);
        new Menu = RA_MenuCreate(ndmenu, "yansirala2");

        switch(siralamaEksen) {
            case 0 : RA_MenuAddItem(Menu,"\wYon degistir. \d|| \wSuan > \r[\w x ekseninde \r]","1");
            case 1 : RA_MenuAddItem(Menu,"\wYon degistir. \d|| \wSuan > \r[\w y ekseninde \r]","1");
            default : RA_MenuAddItem(Menu,"\wYon degistir. \d|| \wSuan > \r[\w Yukari Dogru \r]","1"); 
        }
        RA_MenuAddItem(Menu,"\wT'yi Sirala.^n","2");

        if(freezeKontrol) RA_MenuAddItem(Menu,"\wT'yi Coz. \r[\w/coz\r]","4");
        else RA_MenuAddItem(Menu,"\wT'yi Dondur. \r[\w/dondur\r]","3");

        #if defined semiclip_cvaraktif 
            formatex(ndmenu, charsmax(ndmenu), "\wSemiclip \r%s", get_pcvar_num(semiclip) ? "Kapat":"AC");
            RA_MenuAddItem(Menu, ndmenu, "6");
        #endif

        RA_MenuAddItem(Menu,"\wCtmenu'ye Don.","5");

        menu_setprop(Menu, MPROP_EXITNAME, "\wCikis");
        FC_CTMenuDisplay(id, Menu);

        g_sirala[id]=true; 
        remove_task(id+task_SIRALACIZGI);
        set_task_ex(0.1, "cizgiyansit", id+task_SIRALACIZGI, .flags = SetTask_Repeat);
    }
}

public yansirala2(id, menu, item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(item == MENU_EXIT || get_member(id, m_iTeam)!=TEAM_CT || get_entvar(id, var_takedamage) || !is_user_alive(id)) { 
        remove_task(id+task_SIRALACIZGI);
        g_sirala[id]=false;
        menu_destroy(menu); 
        return PLUGIN_HANDLED; 
    }

    new data[6], key; 
    menu_item_getinfo(menu, item, _, data, charsmax(data));
    key = str_to_num(data);

    switch(key) {
        case 1 : {

            switch(siralamaEksen) {
                case 0 : siralamaEksen=1;
                case 1 : siralamaEksen=2;
                default : siralamaEksen=0;
            }
            yansirala(id);
        }
        case 2 : {
            new players[MAX_PLAYERS], num, ids, dizkordinat[3], Float:diz2kordinat[3], Float:ilk; 
            get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");

            rg_send_audio(0, ctmenu_sirala);

            get_user_origin(id, dizkordinat, 3);
            diz2kordinat[0]=float(dizkordinat[0]);
            diz2kordinat[1]=float(dizkordinat[1]);
            diz2kordinat[2]=float(dizkordinat[2])+35.0;

            switch(siralamaEksen) {
                case 0 : {
                    ilk=diz2kordinat[0];
                    for(new i=0; i<num; i++) {
                        ids=players[i];

                        if(i<=num/2) {
                            set_entvar(ids, var_origin, diz2kordinat);
                            diz2kordinat[0]=diz2kordinat[0]+32.03;
                        } else {
                            ilk=ilk-32.03;
                            diz2kordinat[0]=ilk;
                            set_entvar(ids, var_origin, diz2kordinat);
                        }
                        checkstuckid(ids);
                        
                    }
                }
                case 1 : {
                    ilk=diz2kordinat[1];
                    for(new i=0; i<num; i++) {
                        ids=players[i];

                        if(i<=num/2) {
                            set_entvar(ids, var_origin, diz2kordinat);
                            diz2kordinat[1]=diz2kordinat[1]+32.03;
                        } else {
                            ilk=ilk-32.03;
                            diz2kordinat[1]=ilk;
                            set_entvar(ids, var_origin, diz2kordinat);
                        }
                        checkstuckid(ids);	
                        
                    }
                }
                default : {
                    ilk=diz2kordinat[2];
                    for(new i=0; i<num; i++) {
                        ids=players[i];

                        set_entvar(ids, var_origin, diz2kordinat);
                        diz2kordinat[2]=diz2kordinat[2]+72.03;
                        checkstuckid(ids);
                        
                    }
                    //if(num>18) set_task(0.1, "checkstuck");
                }
            }
            yansirala(id)/*,checkstuck()*/;
            client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan mahkumlari ^1siraya^4 dizdi.", id);
        }
        case 3 : dondur(id), yansirala(id);
        case 4 : coz(id), yansirala(id);
        case 5 : ctmenu(id), remove_task(id+task_SIRALACIZGI), g_sirala[id]=false;

        #if defined semiclip_cvaraktif
            case 6 : {
                
                    if(get_pcvar_num(semiclip)) set_pcvar_num(semiclip, 0), client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1Semiclip'i^4 kapatti.", id);
                    else set_pcvar_num(semiclip, 1), client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1Semiclip'i^4 acti.", id);
                    yansirala(id);
            }
        #endif
    }
    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

public cizgiyansit(id) {
    id=id- task_SIRALACIZGI;
    if(!is_user_alive(id)) remove_task(id+task_SIRALACIZGI), g_sirala[id]=false;
    else if(g_sirala[id] && !is_aiming_at_sky(id)) {	
        new yankordinat[3]; 
        get_user_origin(id, yankordinat, 3);

        message_begin(MSG_BROADCAST, SVC_TEMPENTITY, {0, 0, 0}, id);
        write_byte(TE_BEAMPOINTS);
        switch(siralamaEksen) {
            case 0 : {
                write_coord(yankordinat[0]+16*siralamaNum);   
                write_coord(yankordinat[1]);  
                write_coord(yankordinat[2]+10);  
                write_coord(yankordinat[0]-16*siralamaNum);
                write_coord(yankordinat[1]);	
                write_coord(yankordinat[2]+10);
            }
            case 1 : {
                write_coord(yankordinat[0]);   
                write_coord(yankordinat[1]+16*siralamaNum);  
                write_coord(yankordinat[2]+10);  
                write_coord(yankordinat[0]);
                write_coord(yankordinat[1]-16*siralamaNum);	
                write_coord(yankordinat[2]+10);
            }
            default : {
                write_coord(yankordinat[0]);   
                write_coord(yankordinat[1]);  
                write_coord(yankordinat[2]);  
                write_coord(yankordinat[0]);
                write_coord(yankordinat[1]);	
                write_coord(yankordinat[2]+72*siralamaNum);  
            }
        }
        write_short(g_sprs[4]);     
        write_byte(0);               
        write_byte(1);    
        write_byte(1);
        write_byte(70);
        write_byte(0);
        write_byte(255);    
        write_byte(255);    
        write_byte(0);   
        write_byte(1000);          
        write_byte(0);             
        message_end(); 
    }
}

public daire(id) {
    new players[MAX_PLAYERS], num;
    get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");

    if(get_member(id, m_iTeam)!=TEAM_CT) client_print_color(id, id, "^1[^3%s^1]^4 Bu komut ^1gardiyanlara ^4ozeldir.",serverTAG);
    else if(get_entvar(id, var_takedamage)) client_print_color(id, id, "^1[^3%s^1]^4 Bu komutu sadece^1 godmode aktifken^4 kullanabilirsin.",serverTAG);
    else if(!is_user_alive(id)) client_print_color(id, id, "^1[^3%s^1]^4 Bu komutu sadece^1 yasarken^4 kullanabilirsin.",serverTAG);
    else if(is_aiming_at_sky(id)) client_print_color(id, id, "^1[^3%s^1]^4 Hedefinizi ^1gokyuzunde^4 tutmayiniz.",serverTAG);
    else if(num<2) client_print_color(id, id, "^1[^3%s^1]^4 Bu komutu uygulayabilmek icin yasayan en az ^1iki ^4mahkum olmasi gerekir.",serverTAG);
    else {

        new ids, kordinat[3], Float:yeni_kordinat[3];
        get_user_origin(id, kordinat, 3);
        new r=250;

        for(new i=0; i<num; i++) {
            ids=players[i];

            yeni_kordinat[0] = float(kordinat[0]) + floatround(floatsin(2 * M_PI * i / num, radian) * r, floatround_round);
            yeni_kordinat[1] = float(kordinat[1]) + floatround(floatcos(2 * M_PI * i / num, radian) * r, floatround_round);
            yeni_kordinat[2] = float(kordinat[2]) + 35.0;

            set_entvar(ids, var_origin, yeni_kordinat);
            checkstuckid(ids);
            
        }
        client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan yasayan mahkumlari ^1daire^4 seklinde isinladi.", id);
    }
    return PLUGIN_HANDLED;
}

public t_isinla(id) {
    if(get_member(id, m_iTeam)!=TEAM_CT) client_print_color(id, id, "^1[^3%s^1]^4 Bu komutu sadece^1 gardiyanlar^4 kullanabilir.",serverTAG);
    else if(!is_user_alive(id)) client_print_color(id, id, "^1[^3%s^1]^4 Bu komutu sadece^1 yasarken^4 kullanabilirsin.",serverTAG);
    else if(get_entvar(id, var_takedamage)) client_print_color(id, id, "^1[^3%s^1]^4 Bu komutu sadece^1 godmode aktifken^4 kullanabilirsin.",serverTAG);
    else {

        client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan mahkumlari yanina^1 isinladi.", id);

        new players[MAX_PLAYERS], num, Float:kordinat[3], ids;
        get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");

        get_entvar(id, var_origin, kordinat); 
        kordinat[0]+=35.0;
        
        for(new i=0; i<num; i++) {
            ids=players[i]; 

            set_entvar(ids, var_origin, kordinat); 
            
            //set_task(0.1, "checkstuckid", ids);// checkstuckid(ids);
        }
    }
}

public sonolenrev(id) {
    if(get_member(id, m_iTeam)==TEAM_CT) {

        switch(sonOlen) {
            case -1 : client_print_color(id, id, "^1[^3%s^1] ^4Son oyuncuyu zaten revledin.",serverTAG);
            case 0 : client_print_color(id, id, "^1[^3%s^1] ^4Henuz kimse olmedi.",serverTAG);

            default : {
                if(is_user_alive(sonOlen)) 
                    client_print_color(id, id, "^1[^3%s^1]^4Son olen oyuncu suanda yasiyor.",serverTAG);

                else if(is_user_connected(sonOlen)) {

                    rg_round_respawn(sonOlen);
                    rg_remove_all_items(sonOlen);
                    rg_give_item(sonOlen, "weapon_knife");
                    client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1en son olen^3 %n^4 adli oyuncuyu revledi.", id, sonOlen);
                    sonOlen=-1;
                }
            }
        }

    } else client_print_color(id, id, "^1[^3%s^1] ^4Bu menuye sadece^1 gardiyanlar ^4girebilir.",serverTAG);
}

public adminlik(id) {
    if(get_member(id, m_iTeam)==TEAM_CT) {
        new ndmenu[128];
        if(!yarismaKontrol) {

            formatex(ndmenu, charsmax(ndmenu),"\w%s \d|| \wAdminlik Yarisi. \d[KAPALI]",serverTAG);
            new Menu = RA_MenuCreate(ndmenu, "adminlik2");

            RA_MenuAddItem(Menu,"\wGodlu Yaris Baslat!\d (Her El God Secenegi Aktif Olur)","1");
            RA_MenuAddItem(Menu,"\wIsyanli Yaris Baslat!^n","2");
            RA_MenuAddItem(Menu,"\wCtmenu Don \r[\w/ctmenu\r]","6");

            menu_setprop(Menu, MPROP_EXITNAME, "\wCikis");
            FC_CTMenuDisplay(id, Menu);
        } else {

            if(yarismaKontrol==1) formatex(ndmenu, charsmax(ndmenu),"\w%s \d|| \wAdminlik Yarisi \r[\wGODLU Aktif\r]",serverTAG);
            else formatex(ndmenu, charsmax(ndmenu),"\w%s \d|| \wAdminlik Yarisi \r[\wISYANLI Aktif\r]",serverTAG);
            new Menu = RA_MenuCreate(ndmenu, "adminlik2");

            RA_MenuAddItem(Menu,"\wAnlik Puan Durumu \r[\w/skorlar\r]","3");
            //RA_MenuAddItem(Menu,"\wPuan Ver","4");
            RA_MenuAddItem(Menu,"\wYarisi Bitir\d (Kazanani belirlemeden basma!)^n","5");
            RA_MenuAddItem(Menu,"\wCtmenu Don \r[\w/ctmenu\r]","6");

            if(yarismaKontrol==1) menu_addtext(Menu,"\dGodlu yarismada sonuncu mahkumla \rLR atilacak\d ve"), menu_addtext(Menu,"Kac CT'yi oldururse o kadar puan\w otomatik\d eklenecek.");
            else menu_addtext(Menu,"\dCT'yi olduren mahkumlara \wotomatik \r+1 Puan\d eklenir."), menu_addtext(Menu,"LR atarsaniz da Kac CT'yi oldururse o kadar puan\w otomatik\d eklenecek.");

            menu_addtext(Menu,"\dServerden cikis yapanlarin puanlari sifirlanir!");

            menu_setprop(Menu, MPROP_EXITNAME, "\wCikis");
            FC_CTMenuDisplay(id, Menu);
        }

    } else client_print_color(id, id, "^1[^3%s^1]^4 Bu menuye sadece ^1gardiyanlar^4 girebilir.",serverTAG);
}

public adminlik2(id, menu, item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(item == MENU_EXIT || get_member(id, m_iTeam)!=TEAM_CT) { menu_destroy(menu); return PLUGIN_HANDLED; }

    new data[6], key; 
    menu_item_getinfo(menu, item, _, data, charsmax(data));
    key = str_to_num(data);

    switch(key) {
        case 1 : {
            yarismaKontrol=1;
            adminlik(id);
            rg_send_audio(0, ctmenu_bildirim);

            for(new i=0; i<5; i++) 
                client_print_color(id, id, "^1[^3%n^1] ^4adli gardiyan ^1Godlu Adminlik Yarismasi^4 baslatti!", id);

            new players[MAX_PLAYERS],num; get_players_ex(players, num, GetPlayers_ExcludeBots);

            for(new i=0; i<num; i++) 
                yarismaSayac[players[i]]=0;
        }
        case 2 : {
            yarismaKontrol=2;
            adminlik(id);
            rg_send_audio(0, ctmenu_bildirim);

            for(new i=0; i<5; i++) 
                client_print_color(id, id, "^1[^3%n^1] ^4adli gardiyan ^1Isyanli Adminlik Yarismasi^4 baslatti!", id);

            new players[MAX_PLAYERS],num;  get_players_ex(players, num, GetPlayers_ExcludeBots);

            for(new i=0; i<num; i++) 
                yarismaSayac[players[i]]=0;
        }
        case 3 : anlikpuan(id);
        //case 4 : puanver(id);
        case 5 : {
            yarismaKontrol=0;
            ctmenu(id);
            rg_send_audio(0, ctmenu_bildirim);

            for(new i=0; i<5; i++) 
                client_print_color(id, id, "^1[^3%n^1] ^4adli gardiyan ^1Adminlik Yarisini^4 sonlandirdi!", id);
        }
        case 6 : ctmenu(id);
    }
    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

public anlikpuan(id) {
    if(yarismaKontrol) {
        new ndmenu[128];
        formatex(ndmenu, charsmax(ndmenu),"\w%s \d|| \wAnlik Puan Durumu\d",serverTAG);
        new Menu = RA_MenuCreate(ndmenu, "anlikpuan2");

        new TeamName:team=get_member(id, m_iTeam);
        switch(team) {
            case TEAM_TERRORIST : RA_MenuAddItem(Menu, "JBMenu'ye Don.^n", "1");
            case TEAM_CT : RA_MenuAddItem(Menu, "Adminlik Yarisi Menusune Don.^n", "1");
        }

        new players[MAX_PLAYERS], num, ids, bool:topla=false; 
        get_players_ex(players, num, GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");

        for(new i=0; i<num; i++) {
            ids=players[i];
            if(yarismaSayac[ids]<1) continue;

            formatex(ndmenu, charsmax(ndmenu),"\w%n \w>\d [\r%d Puan\d]", ids, yarismaSayac[ids]);
            RA_MenuAddItem(Menu, ndmenu, "2");

            if(!topla) 
                topla=true;
        }

        if(!topla) 
            menu_addtext(Menu, "\wPuani Olan Kimse Yok!");

        menu_setprop(Menu, MPROP_BACKNAME, "\wOnceki Menu");
        menu_setprop(Menu, MPROP_NEXTNAME, "\wDiger Menu");
        menu_setprop(Menu, MPROP_EXITNAME, "\wCikis");
        FC_CTMenuDisplay(id, Menu);

    } else client_print_color(id, print_team_blue, "^1[^3%s^1]^4 Bu menuye sadece ^1adminlik yarisi aktifken^4 girebilirsin.",serverTAG);
}

public anlikpuan2(id, menu, item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(item == MENU_EXIT) { menu_destroy(menu); return PLUGIN_HANDLED; }

    new data[6], key; 
    menu_item_getinfo(menu, item, _, data, charsmax(data));
    key = str_to_num(data);

    switch(key) {
        case 1 : {
            new TeamName:team=get_member(id, m_iTeam);
            switch(team) {	
                case TEAM_TERRORIST : client_cmd(id, "say /jbmenu");
                case TEAM_CT : adminlik(id);
            }
        }
        case 2 : anlikpuan(id);
    }
    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

public godsoyle(id) {
    new players[MAX_PLAYERS], num; 
    get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "CT"); 

    for(new i=0; i<num; i++) {

        if(!get_entvar(players[i], var_takedamage)) {
            client_print_color(id, print_team_blue, "^1[^3%s^1]^4 Suanda Godmode > ^3[ ^1ACIK^3 ]", serverTAG);
            return;
        }
    }
    client_print_color(id, print_team_blue, "^1[^3%s^1]^4 Suanda Godmode > ^3[ ^1KAPALI^3 ]", serverTAG);
}

public godver() {
    g_godMode=true;g_godPermit=g_roundNo;
    new players[MAX_PLAYERS], num, ids;
    get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "CT");

    for(new i=0; i<num; i++) {
        ids=players[i];

        set_entvar(ids, var_takedamage, DAMAGE_NO);
        set_entvar(ids, var_health, Float:10000.0);
        g_unAmmo[ids]=true;
    }
}

public tdisarmmenu(id) {
    new ndmenu[128];
    formatex(ndmenu, charsmax(ndmenu),"\w%s \d|| \wMahkumlarin Silahlari Alinsin mi?",serverTAG);
    new Menu = RA_MenuCreate(ndmenu, "tdisarmmenu2");

    RA_MenuAddItem(Menu,"\wEvet \d(T Disarmla)","1");
    RA_MenuAddItem(Menu,"\wHayir \d(T Disarmlama)","2");

    menu_setprop(Menu, MPROP_EXITNAME, "\wCikis");
    FC_CTMenuDisplay(id, Menu);
}

public tdisarmmenu2(id, menu, item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(item == MENU_EXIT || get_member(id, m_iTeam)!=TEAM_CT) { menu_destroy(menu); return PLUGIN_HANDLED; }

    new data[6], key, players[MAX_PLAYERS], num; 
    menu_item_getinfo(menu, item, _, data, charsmax(data));
    key = str_to_num(data);

    get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");

    switch(key) {
        case 1 : {		
            new ids;
            for(new i=0; i<num; i++) {
                ids=players[i];
                rg_remove_all_items(ids), rg_give_item(ids, "weapon_knife");
            }
            client_print_color(0, id, "^1[^3%s^1]^4 Mahkumlarin silahlari alindi.",serverTAG);
        }
        case 2 : client_print_color(0, id, "^1[^3%s^1]^4 Mahkumlarin silahlari alinmadi.",serverTAG);
    }
    if(num==1) {

        num = get_playersnum_ex(GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "CT");
        if(num>1) korumaswapsor(id);
    } else ctmenu(id);

    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

public korumaswapsor(id) {
    new ndmenu[128];
    formatex(ndmenu, charsmax(ndmenu),"\w%s \d|| \wKorumayi Alan Otomatik Koruma Olsun mu?",serverTAG);
    new Menu = RA_MenuCreate(ndmenu, "korumaswapsor2");

    RA_MenuAddItem(Menu,"\wEvet, olsun.","1");
    RA_MenuAddItem(Menu,"\wHayir, olmasin.","2");

    menu_setprop(Menu, MPROP_EXITNAME, "\wCikis");
    FC_CTMenuDisplay(id, Menu);
}

public korumaswapsor2(id, menu, item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(item == MENU_EXIT || get_member(id, m_iTeam)!=TEAM_CT) { menu_destroy(menu); return PLUGIN_HANDLED; }

    new data[6], key; 
    menu_item_getinfo(menu, item, _, data, charsmax(data));
    key = str_to_num(data);

    switch(key) {
        case 1 : {
            new players[MAX_PLAYERS], num, ids; 
            get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "CT");

            for(new i=0; i<num; i++) {
                ids=players[i];
                if(id==ids) continue;

                g_koruma[ids]=true;
            }

            client_print_color(0, id, "^1[^3%s^1]^4 Mahkum korumayi alirsa ^1otomatik koruma^3 olacak.",serverTAG);
        }
        case 2 : client_print_color(0, id, "^1[^3%s^1]^4 Korumayi alan ^1otomatik koruma^3 olmayacak.",serverTAG);
    }
    ctmenu(id);

    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

public hucrekapisiniac(id) {

    if( get_member(id, m_iTeam) == TEAM_CT ) 
    {
        client_print_color(0, id, "^1[^3%n^1]^4 adli gardiyan ^1hucre kapisini^4 acti^3/^4kapatti.", id);
        rg_send_audio(0, ctmenu_hucre);

        new Float:radius = 200.0, Float:origin[3], ent = 1, ent2 = 1, ent3, name[32], pos;
        static found[10];

        while((pos <= sizeof(found)) && (ent = engfunc(EngFunc_FindEntityByString, ent, "classname", "info_player_deathmatch"))) {
            get_entvar(ent, var_origin, origin);
            while((ent2 = engfunc(EngFunc_FindEntityInSphere, ent2, origin, radius))) {
                if(is_entity(ent2) && !FClassnameIs(ent2, "func_door")) continue;

                get_entvar(ent2, var_targetname, name, charsmax(name)); ent3=engfunc(EngFunc_FindEntityByString, 0, "target", name);
                if(is_entity(ent3) && (in_array(ent3, found, sizeof(found)) < 0)) {
                    dllfunc(DLLFunc_Use, ent3, 0, 0, 1, 1.0),pos++;
                    break;
                }
            }
        }
    }
    return PLUGIN_HANDLED; //pos;
}

in_array(needle, data[], sized) {
    for(new i=0; i<sized; i++) 
        if(data[i] == needle) 
            return i;

    return -1;
}

public fallDamage(const id) {
    if(get_member(id,m_iTeam)==TEAM_CT) {
        SetHookChainReturn(ATYPE_FLOAT,0.0);
        return HC_SUPERCEDE;
    }
    return HC_CONTINUE;
}

kill(killer, victim, weapon[]) {
    user_silentkill(victim);
    message_begin(MSG_ALL, DeathMsg, {0,0,0}, 0);
    write_byte(killer);
    write_byte(victim);
    write_byte(0);
    write_string(weapon);
    message_end();
}

public touch_player(ent, id) {
    if(yakalaKontrol) {
        new TeamName:team1=get_member(ent, m_iTeam), TeamName:team2=get_member(id, m_iTeam);

        if(team1==TEAM_CT && team2==TEAM_TERRORIST && is_user_alive(id)) {

                kill(ent, id, "deagle");

        } else if(team1==TEAM_TERRORIST && team2==TEAM_CT && is_user_alive(ent)) {

                kill(id, ent, "deagle");

        }
    }	
}

public touch_weapon(ent, id) {

    return g_silahKontrol[id] ? PLUGIN_HANDLED : PLUGIN_CONTINUE;
}

public LegacyReset() {
    DisableHookChain(h_Dmg);
    DisableHookChain(h_rSpeed);

    hunger_bitir();

    Hard_KomutKapat();
    CHard_KomutKapat();

    set_pcvar_num(bh_enabled, 1);
    set_pcvar_num(sv_parachute, 1);
    set_pcvar_num(sv_gravity, 800);
    set_pcvar_num(mp_freeforall, 0);
    set_pcvar_num(mp_forcecamera, 0);
    set_pcvar_num(mp_infinite_ammo, 0);
    set_pcvar_num(sv_airaccelerate, 101);

    #if defined semiclip_cvaraktif 
        s_gerisayim=false;
        set_pcvar_num(semiclip, 1); 
        remove_task(task_SIKISTIRMA);
    #endif

    set_lights(defaultHava);
    remove_task(task_ROCKET);
    remove_task(task_FREEZEOYUNU);

    if(sureligomSayac>0) {

        remove_task(task_SURELIGOM);

        sureligomSayac=0;
        tamgomKontrol=false;
        uckezgomKontrol=false;
    }

    remove_task(task_SURELIDON);
    surelidondurSayac=0;

    oylamaSayac=0;
    remove_task(task_KORUMA);

    aref=false;
    ffKontrol=false;
    freezeKontrol=false;
    yakalaKontrol=false;
    sarkacKontrol=false;
    catismaKontrol=false;
    enfeksiyonKontrol=false;
    vatanhainiKontrol=false;
    sayiyibilenKontrol=false;

    new players[MAX_PLAYERS], num, ids;
    get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_ExcludeBots);

    for(new i=0; i<num; i++) {
        ids=players[i];
        g_unAmmo[ids]=false;

        g_infect[ids]=false;
        remove_task(ids+task_ENFEKSIYON);

        oyuncuCoz(ids);

        if(g_glow[ids]) {

            glowla(ids, 0, 0, 0);
            g_glow[ids]=false; 
        }

        set_entvar(ids, var_takedamage, DAMAGE_AIM);
        set_entvar(ids, var_movetype, MOVETYPE_WALK);
        set_entvar(ids, var_effects, get_entvar(ids, var_effects) & ~EF_NODRAW); //set_entity_visibility(ids, 1);
        

        Takim[ids]=0;
        set_entvar(ids, var_gravity, 1.0);
        set_entvar(ids, var_maxspeed, 250.0);
        //set_entvar(ids, var_health, Float:100.0);

        g_oylama[ids]=false;
        remove_task(ids+task_KORUMA);

        g_koruma[ids]=false;
        remove_task(ids+task_GOZUMEGOZUKME);
        remove_task(ids+task_SIRALACIZGI);
        remove_task(ids+task_HAYALET);
        remove_task(ids);
        
        g_hiz[ids]=false;
        g_hain[ids]=false;
        g_sarkac[ids] = false;
        g_silahKontrol[ids]=false;

        #if defined semiclip_cvaraktif 
            s_player[ids]=false;
        #endif

        if(get_member(ids, m_iTeam)==TEAM_CT) {
            
            g_sirala[ids]=false;
            g_hasarKatla[ids]=false;
            g_hasarAzalt[ids]=false;
        }
    }
}

public LegacyDisconnect(ids) {
    remove_task(ids);
    remove_task(ids+task_KORUMA);
    remove_task(ids+task_HAYALET);
    remove_task(ids+task_SIRALACIZGI);
    remove_task(ids+task_GOZUMEGOZUKME);
    
    if(g_infect[ids]) {

        g_infect[ids]=false;
        remove_task(ids+task_ENFEKSIYON);
    }
}

public roundStart() {
    LaserWallReset();
    g_bridgeRoundClosed=false;
    BridgeReset(CT_STOP_ROUND,false);
    elbasiKontrol=true;set_task(0.5,"eskibas",791230);
    SuankiRound++;g_roundNo=SuankiRound;
    if(hardkomutKontrol==1) {hardkomutKontrol=2;set_task(2.0,"hardReklam",791231);} else if(hardkomutKontrol==2) hardkomutKontrol=0;
    if(godKontrol==1) {godKontrol=2;set_task(2.0,"godReklam",791232);} else if(godKontrol==2) godKontrol=0;
    g_godPermit=godKontrol==2?g_roundNo:-1;g_hardPermit=hardkomutKontrol==2?g_roundNo:-1;
    takimKontrol=false;sonOlen=0;g_lastDead=0;
    for(new id=1;id<=MaxClients;id++) {arrayset(g_perk[id],false,5);g_snap[0][id][SS_VALID]=g_snap[1][id][SS_VALID]=0;}
}

public hardReklam() { Chat(0,"Bu el gardiyanlar menüden ^3Hard Komut ^1alabilir."); }

public godReklam() { Chat(0,"Bu el gardiyanlar menüden ^3Godmode ^1alabilir."); }

public playerSpawn(id) {
    if(!is_user_alive(id)) 
        return HC_CONTINUE;

    if(elbasiKontrol) {
        if(yardimSayac[id]>0) 
            yardimSayac[id]--;

    } else {
        if(g_infect[id]) {
            g_infect[id]=false;
            remove_task(id+task_ENFEKSIYON);
        }

        if(g_glow[id]) glowla(id, 0, 0, 0), g_glow[id]=false;

        Takim[id]=0;
        g_unAmmo[id]=false;
    }
    

    return HC_CONTINUE;
}

public silahver(iTaskim) {
    new iPlayer = iTaskim - 1707;
    rg_remove_all_items(iPlayer), rg_give_item(iPlayer,"weapon_knife");
    rg_give_item(iPlayer, "weapon_deagle"), rg_set_user_bpammo(iPlayer, WEAPON_DEAGLE, 200);
    rg_give_item(iPlayer, "weapon_m4a1"), rg_set_user_bpammo(iPlayer, WEAPON_M4A1, 200);
    rg_give_item(iPlayer, "weapon_awp"), rg_set_user_bpammo(iPlayer, WEAPON_AWP, 200);
    rg_give_item(iPlayer, "weapon_ak47"), rg_set_user_bpammo(iPlayer, WEAPON_AK47, 200);

    if(m249Active)
        rg_give_item(iPlayer, "weapon_m249"), rg_set_user_bpammo(iPlayer, WEAPON_M249, 200);

    spawnctmenu(iPlayer);
    set_entvar(iPlayer, var_health, cvar[0]);
    set_entvar(iPlayer, var_armorvalue, cvar[1]);

}

public LegacyPut(id) { 

    g_hud[id]=false;
    yarismaSayac[id]=0;
}

public devam(id) { /* The shared JB/CT HUD owns this panel. */ }

public spawnctmenu(id) { ctmenu(id); }

public spawnctmenu2(id, menu, item) {
    if(item == MENU_EXIT || get_member(id, m_iTeam)!=TEAM_CT) { menu_destroy(menu); return PLUGIN_HANDLED; }

    new data[6], key; 
    menu_item_getinfo(menu, item, _, data, charsmax(data));
    key = str_to_num(data);

    if(key==1) 
        ctmenu(id);

    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

public playerTakeDamage(victim, inflictor, attacker, Float:damage, damage_bits) {
    if(is_user_connected(attacker) && is_user_connected(victim) && victim != attacker) {

        if(get_pcvar_num(mp_freeforall)==1 && get_member(victim, m_iTeam)==TEAM_TERRORIST && get_member(attacker, m_iTeam)==TEAM_TERRORIST) {

            if(takimHasar && Takim[attacker]!=0 && Takim[attacker]==Takim[victim] ) {

                SetHookChainArg(4, ATYPE_FLOAT, 0.0);
            }

            if(vatanhainiKontrol && !g_hain[victim] && !g_hain[attacker]) 
                SetHookChainArg(4, ATYPE_FLOAT, 0.0);
        }
        
        if(g_hasarAzalt[victim]) 
            SetHookChainArg(4, ATYPE_FLOAT, damage*0.5);

        if(g_hasarKatla[attacker]) 
            SetHookChainArg(4, ATYPE_FLOAT, damage*2.0);
    }
}

public manualUnammo(id) {
    if(!is_user_alive(id) || !g_unAmmo[id] || get_pcvar_num(mp_infinite_ammo)) return;
    new weapon=get_member(id,m_pActiveItem);if(is_nullent(weapon)) return;
    new wid=get_member(weapon,m_iId);if(wid!=read_data(2) || !HasClip(wid)) return;
    set_member(weapon,m_Weapon_iClip,rg_get_weapon_info(WeaponIdType:wid,WI_GUN_CLIP_SIZE));
}

public resetSpeed(id) {
    if(g_hiz[id]) {

        set_entvar(id, var_maxspeed, 650.0);
        return HC_SUPERCEDE;
    }
    return HC_CONTINUE;
}

public playerKilled(olen, saldiran) {
    if(!is_user_connected(saldiran) || !is_user_connected(olen)) return;

    // show_menu(olen, 0, "");
    sonOlen=olen;

    // rg_send_audio(saldiran, ctmenu_olunce);

    set_task(0.2, "oyuncuCoz", olen);
    new TeamName:team1=get_member(olen, m_iTeam), TeamName:team2=get_member(saldiran, m_iTeam);

    get_entvar(olen, var_origin, deathOrigin[olen]);

    if(g_koruma[olen] && team1==TEAM_CT && team2==TEAM_TERRORIST) {

        rg_set_user_team(olen,TEAM_TERRORIST);
        rg_set_user_team(saldiran,TEAM_CT);
        rg_round_respawn(olen);
        rg_round_respawn(saldiran);
        user_kill(olen,1);
        g_koruma[olen]=false;
        client_print_color(0, print_team_blue, "^1[^3%s^1] %n ^4adli mahkum, ^1%n^4 adli korumayi oldurdugu icin ^3yeni koruma oldu.", serverTAG, saldiran, olen);
    }

    new players[MAX_PLAYERS],num,ids;
    get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_MatchTeam | GetPlayers_ExcludeBots, "TERRORIST");

    if(vatanhainiKontrol) {
        if(g_hain[saldiran] && saldiran==olen) client_print_color(0, print_team_blue, "^1[^3%n^1]^4 adli ^1Hain^4 kendi kendine oldu!", olen);
        else if(!g_hain[saldiran] && g_hain[olen] && team2==TEAM_TERRORIST) {

            set_pcvar_num(mp_freeforall, 0);
            vatanhainiKontrol = false;
            for(new i=0; i<num; i++) {
                ids = players[i];

                if(ids==saldiran) {
                    client_print_color(0, print_team_blue, "^1[^3%n^1]^4 adli oyuncu ^1Haini oldurdu^4 ve oyunu kazandi", saldiran); 
                    continue; 
                } else kill(saldiran, ids, "deagle");//user_kill(ids);
            }

        } else if(g_hain[olen] && team2==TEAM_CT) 
            client_print_color(0, print_team_blue, "^1[^3%n^1]^4 adli gardiyan ^1Haini oldurdu^4. Oyunu tekrar baslatabilirsiniz", saldiran); 
    }
    if(num<2) {
        if(enfeksiyonKontrol) {
            for(new i=0; i<num; i++) {
                ids=players[i];
                enfeksiyonKontrol=false;
                g_infect[ids]=false;
                glowla(ids, 0, 0, 0);
                g_glow[ids]=false;
                remove_task(ids+task_ENFEKSIYON);

                client_print_color(0, print_team_blue, "^1[^3%n^1]^4 adli mahkum enfeksiyon oyununda sona kaldi ve kazandi. ^3Oyun durduruldu!", ids);
            }
        }
        get_players_ex(players, num, GetPlayers_ExcludeDead | GetPlayers_ExcludeBots);
        for(new i=0; i<num; i++) {
            ids=players[i];

            g_hasarAzalt[ids]=false;
            g_hasarKatla[ids]=false;
            g_unAmmo[ids]=false;
        }
    }

    if(yarismaKontrol && team2==TEAM_TERRORIST && team1==TEAM_CT) {

        yarismaSayac[saldiran]++;
        client_print_color(saldiran, print_team_blue, "^1[^3%s^1] ^4Skorunuza ^1+1 Puan ^4eklendi!",serverTAG);
        client_print_color(0, print_team_blue, "^1[^3%n^1] ^4adli oyuncunun skoru ^3[^1 %d^3 ]^4 oldu!^3 Tum skorlari ^4say'a ^1/skorlar^4 yazarak gorebilirsiniz.", saldiran, yarismaSayac[saldiran]);
    }
}

glowla(const id, const bir=0, const iki=0, const uc=0) {
    new Float:RenderColor[3];
    RenderColor[0]=float(bir);
    RenderColor[1]=float(iki);
    RenderColor[2]=float(uc);

    set_entvar(id, var_renderfx, kRenderFxGlowShell);
    set_entvar(id, var_rendercolor, RenderColor);
    set_entvar(id, var_rendermode, kRenderNormal);
    set_entvar(id, var_renderamt, 30.0);
}

bool:Stuck(id) {

    static Float:Origin[3]; 
    get_entvar(id, var_origin, Origin);

    engfunc(EngFunc_TraceHull, Origin, Origin, IGNORE_MONSTERS, get_entvar(id, var_flags) & FL_DUCKING ? HULL_HEAD : HULL_HUMAN, 0, 0);

    return bool:get_tr2(0, TR_StartSolid);
}

public checkstuckid(id) {
    static Float:origin[3]; get_entvar(id, var_origin, origin);
    
    if(!is_hull_vacant(origin, id) && get_entvar(id, var_movetype)!=MOVETYPE_NOCLIP && !(get_entvar(id, var_solid) & SOLID_NOT)) {
        
        static Float:mins[3],Float:vec[3];
        get_entvar(id, var_mins, mins); vec[2]=origin[2];
        new sizes= sizeof(size);
        
        for(new o=0; o<sizes; ++o) {
            vec[0]= origin[0]-mins[0]*size[o][0]; 
            vec[1]= origin[1]-mins[1]*size[o][1]; 
            vec[2]= origin[2]-mins[2]*size[o][2];
        
            if(is_hull_vacant(vec, id)) {
                set_entvar(id, var_origin, vec);
                set_entvar(id, var_velocity, Float:{0.0,0.0,0.0});
                break;
            }
        }
        
        set_task(0.1, "checkstuckid", id);
    }
}

bool:is_hull_vacant(const Float:origin[3], id) {
    new ignore=IGNORE_MONSTERS;
    
    #if defined semiclip_cvaraktif 
        if(!get_pcvar_num(semiclip)) ignore=0;
    #endif
    
    static tr; 
    engfunc(EngFunc_TraceHull, origin, origin, ignore, (get_entvar(id, var_flags) & FL_DUCKING) ? HULL_HEAD:HULL_HUMAN, id, tr);
    
    return (!get_tr2(0, TR_StartSolid) || !get_tr2(0, TR_AllSolid)) ? true:false;
}

bool:is_aiming_at_sky(id) {
    // Author : AdaskoMX!

    new kordinat[3], Float:origin[3]; get_user_origin(id, kordinat, 3);
    
    origin[0] = float(kordinat[0]);
    origin[1] = float(kordinat[1]);
    origin[2] = float(kordinat[2]);

    return engfunc(EngFunc_PointContents, origin) == CONTENTS_SKY;
}



public LegacyPrecache() {
    BridgeLegacyAudio();

    g_sprs[0] = precache_model("sprites/blueflare2.spr");
    g_sprs[1] = precache_model("sprites/muzzleflash.spr");
    g_sprs[2] = precache_model("sprites/white.spr");
    g_sprs[3] = precache_model("sprites/steam1.spr");
    g_sprs[4] = precache_model("sprites/laserbeam.spr");

    for(new i = 0; i < sizeof(SquidSounds); i++)
    {
        precache_sound(SquidSounds[i]);
    }

    for(new i = 0; i < sizeof(HardKomutSounds); i++)
    {
        precache_sound(HardKomutSounds[i]);
    }

    precache_sound(ctmenu_rocketfire);
    precache_sound(ctmenu_rocket1);
    precache_sound(ctmenu_koruma);
    precache_sound(ctmenu_ayarlarisifirla);
    precache_sound(ctmenu_godmode);
    precache_sound(ctmenu_bildirim);
    precache_sound(ctmenu_freeze_don);
    precache_sound(ctmenu_duzff);
    precache_sound(ctmenu_silahliff);
    precache_sound(ctmenu_sparta);
    precache_sound(ctmenu_gomulunce);
    precache_sound(ctmenu_onsaniye);
    precache_sound(ctmenu_sirala);
    precache_sound(ctmenu_hucre);
    precache_sound(ctmenu_pubg);
    #if defined semiclip_cvaraktif 
        precache_sound(ctmenu_sikistirma);
    #endif
}

BridgeLegacyAudio() {
    if(!file_exists("sound/ctmenum/omrum.wav")) copy(ctmenu_koruma,charsmax(ctmenu_koruma),"fc_ctmenu_v112/notice.wav");
    if(!file_exists("sound/ctmenum/ayarsifirla_new.wav")) copy(ctmenu_ayarlarisifirla,charsmax(ctmenu_ayarlarisifirla),"fc_ctmenu_v112/reset.wav");
    if(!file_exists("sound/ctmenum/godmode_aktif.wav")) copy(ctmenu_godmode,charsmax(ctmenu_godmode),"fc_ctmenu_v112/god.wav");
    if(!file_exists("sound/ctmenum/bildirim.wav")) copy(ctmenu_bildirim,charsmax(ctmenu_bildirim),"fc_ctmenu_v112/notice.wav");
    if(!file_exists("sound/ctmenum/don_new.wav")) copy(ctmenu_freeze_don,charsmax(ctmenu_freeze_don),"fc_ctmenu_v112/freeze.wav");
    if(!file_exists("sound/ctmenum/duzff.wav")) copy(ctmenu_duzff,charsmax(ctmenu_duzff),"fc_ctmenu_v112/knives.wav");
    if(!file_exists("sound/ctmenum/silahliff.wav")) copy(ctmenu_silahliff,charsmax(ctmenu_silahliff),"fc_ctmenu_v112/guns.wav");
    if(!file_exists("sound/ctmenum/sparta_new.wav")) copy(ctmenu_sparta,charsmax(ctmenu_sparta),"fc_ctmenu_v112/sparta.wav");
    if(!file_exists("sound/ctmenum/gomulunce.wav")) copy(ctmenu_gomulunce,charsmax(ctmenu_gomulunce),"fc_ctmenu_v112/trap.wav");
    if(!file_exists("sound/ctmenum/onsaniye.wav")) copy(ctmenu_onsaniye,charsmax(ctmenu_onsaniye),"fc_ctmenu_v112/countdown.wav");
    if(!file_exists("sound/ctmenum/pu_new.wav")) copy(ctmenu_sirala,charsmax(ctmenu_sirala),"fc_ctmenu_v112/lineup.wav");
    if(!file_exists("sound/ctmenum/acarmisinkapiyi.wav")) copy(ctmenu_hucre,charsmax(ctmenu_hucre),"fc_ctmenu_v112/notice.wav");
    if(!file_exists("sound/ctmenum/pubg.wav")) copy(ctmenu_pubg,charsmax(ctmenu_pubg),"fc_ctmenu_v112/notice.wav");
    if(!file_exists("sound/ctmenum/sikistirma.wav")) copy(ctmenu_sikistirma,charsmax(ctmenu_sikistirma),"fc_ctmenu_v112/notice.wav");
    if(!file_exists("sound/ctmenum/HardKomut1.wav")) copy(HardKomutSounds[0],charsmax(HardKomutSounds[]),"fc_ctmenu_v112/notice.wav");
    if(!file_exists("sound/ctmenum/HardKomut2.wav")) copy(HardKomutSounds[1],charsmax(HardKomutSounds[]),"fc_ctmenu_v112/notice.wav");
    if(!file_exists("sound/ctmenum/tp_squidgamenormal.wav")) copy(SquidSounds[0],charsmax(SquidSounds[]),"fc_ctmenu_v112/notice.wav");
    if(!file_exists("sound/ctmenum/tp_squidgameorta.wav")) copy(SquidSounds[1],charsmax(SquidSounds[]),"fc_ctmenu_v112/notice.wav");
    if(!file_exists("sound/ctmenum/tp_squidgamehizli.wav")) copy(SquidSounds[2],charsmax(SquidSounds[]),"fc_ctmenu_v112/notice.wav");
    if(!file_exists("sound/ctmenum/tp_squidgamecokhizli.wav")) copy(SquidSounds[3],charsmax(SquidSounds[]),"fc_ctmenu_v112/notice.wav");
}
/* === RETAINED FELICIACLAN EXTENSIONS AND PUBLIC API === */
stock FC_ResetPanelHud(id) {
    if(id<1 || id>MaxClients) return;
    g_iFCPanelWidth[id]=0;
    for(new ch=1;ch<=4;ch++) {
        g_bFCPanelSent[id][ch]=false;
        g_flFCPanelReliable[id][ch]=0.0;
    }
}

stock FC_PanelTextWidth(const text[]) {
    new widest,width;
    for(new i;text[i];i++) {
        if(text[i]=='^n') {widest=max(widest,width);width=0;}
        else if((text[i]&0xC0)!=0x80) width+=FC_PanelGlyphWidth(text[i]);
    }
    return max(widest,width);
}

stock FC_PanelPacketText(const text[],out[],len,columnWidth) {
    new first;while(text[first] && text[first]!='^n') first++;
    new width;for(new i;i<first;i++) if((text[i]&0xC0)!=0x80) width+=FC_PanelGlyphWidth(text[i]);
    new pad=clamp(floatround(float(columnWidth-width)/7.0),0,max(0,len-strlen(text)));
    new used;for(new i;i<first && used<len;i++) out[used++]=text[i];
    for(new i;i<pad && used<len;i++) out[used++]=' ';
    copy(out[used],len-used,text[first]);
}

stock FC_SendPanelHud(id,const text[],r,g,b,Float:x,Float:y,channel,Float:hold=2.2) {
    if(id<1 || id>MaxClients || channel<1 || channel>4
        || !is_user_connected(id) || is_user_bot(id) || is_user_hltv(id)) return;
    new px=floatround(x*8192.0,floatround_tozero);
    new py=floatround(y*8192.0,floatround_tozero);
    // Keep layers apart after client coordinate quantization. The visible
    // displacement stays under four pixels at 1920px, with channel 4 anchored.
    if(channel==2) px+=16;
    else if(channel==3) px-=16;
    new packet[512];
    if(channel>=2 && text[0]) FC_PanelPacketText(text,packet,charsmax(packet),max(340,g_iFCPanelWidth[id]));
    else copy(packet,charsmax(packet),text);
    new ticks=floatround(hold*256.0,floatround_tozero),signature=5381;
    for(new i;packet[i];i++) signature=((signature<<5)+signature)^packet[i];
    signature=(((signature*33+px)*33+py)*33+r)*33+g;
    signature=(signature*33+b)*33+ticks;
    new Float:now=get_gametime();
    new bool:keyframe=!g_bFCPanelSent[id][channel]
        || now<g_flFCPanelReliable[id][channel]
        || now-g_flFCPanelReliable[id][channel]>=0.9;
    // A reliable keyframe keeps the panel alive through a lost animation datagram.
    // Unchanged decoration/body layers do not need another 20 Hz packet.
    if(text[0] && !keyframe && signature==g_iFCPanelSignature[id][channel]) return;
    new bool:reliable=keyframe || !text[0];
    message_begin(reliable?MSG_ONE:MSG_ONE_UNRELIABLE,SVC_TEMPENTITY,_,id);
    write_byte(TE_TEXTMESSAGE);write_byte(channel);
    write_short(px);write_short(py);
    write_byte(0);
    write_byte(r);write_byte(g);write_byte(b);write_byte(0);
    write_byte(r);write_byte(g);write_byte(b);write_byte(0);
    write_short(0);write_short(0);write_short(ticks);
    write_string(packet);message_end();
    g_bFCPanelSent[id][channel]=(text[0]!=0);
    g_iFCPanelSignature[id][channel]=signature;
    if(reliable) g_flFCPanelReliable[id][channel]=now;
}

stock FC_PanelGlyphWidth(ch) {
    // Space-relative metrics keep digits, narrow letters and capitals centered.
    // They approximate standard HUD fonts; no client font or INC is required.
    static const widths[] = {7,9,11,15,14,21,18,6,9,9,10,16,7,8,7,7,14,14,14,14,14,14,14,14,14,14,8,8,16,16,16,14,22,17,17,16,17,15,15,18,17,7,11,17,14,20,17,18,16,18,17,16,15,17,16,23,16,16,15,9,7,9,16,12,9,14,15,13,15,14,9,15,15,7,7,14,7,22,15,15,15,15,10,13,9,15,14,19,13,14,12,12,7,12,16};
    return ch>=32 && ch<=126?widths[ch-32]:14;
}

stock FC_WrapPanelText(const text[],out[],len) {
    new start,end,space,width,used;
    while(text[start] && used<len) {
        end=start;space=-1;width=0;
        while(text[end] && text[end]!='^n') {
            new nextWidth=FC_PanelGlyphWidth(text[end]);
            if(width+nextWidth>300 && end>start) break;
            width+=nextWidth;if(text[end]==' ') space=end;
            end++;while((text[end]&0xC0)==0x80) end++;
        }
        if(text[end] && text[end]!='^n' && space>start) end=space;
        for(new i=start;i<end;) {
            new next=i+1;while(next<end && (text[next]&0xC0)==0x80) next++;
            if(used+next-i>len) {out[used]=0;return used;}
            while(i<next) out[used++]=text[i++];
        }
        start=end;if(text[start]=='^n') start++;
        while(text[start]==' ') start++;
        if(text[start] && used<len) out[used++]='^n';
    }
    out[used]=0;return used;
}

stock FC_InfoBody(const text[],out[],len,bool:fixedLayout=false) {
    new plain[432],line[48],start,end,used;
    while(text[start] && used<charsmax(plain)) {
        end=start;while(text[end] && text[end]!='^n') end++;
        copyc(line,charsmax(line),text[start],'^n');trim(line);
        // The native API keeps its existing clan line; the renderer moves it to
        // the colored heading instead of repeating it between UID and stats.
        if(line[0] && !equali(line,"FeliciaClan") && !equali(line,"FeliciaClan | CT")) {
            if(used) plain[used++]='^n';
            for(new i=start;i<end;) {
                new next=i+1;while(next<end && (text[next]&0xC0)==0x80) next++;
                if(used+next-i>charsmax(plain)) break;
                while(i<next) plain[used++]=text[i++];
            }
        }
        start=end;if(text[start]=='^n') start++;
    }
    plain[used]=0;if(fixedLayout) return copy(out,len,plain);return FC_WrapPanelText(plain,out,len);
}

stock FC_HeaderPad(out[],&used,len,pixels) {
    new width;for(new i;i<used;i++) width+=FC_PanelGlyphWidth(out[i]);
    new spaces=max(0,floatround(float(pixels-width)/7.0));
    for(new i;i<spaces && used<len;i++) out[used++]=' ';
}

stock FC_HeaderWidth() {
    new title;static const name[]="FeliciaClan";
    for(new i;name[i];i++) title+=FC_PanelGlyphWidth(name[i]);
    return title+4*FC_PanelGlyphWidth('>')+4*FC_PanelGlyphWidth(' ');
}

stock FC_BuildInfoHud(const text[],outBody[],outWord[],outInner[],&Float:x,&Float:y,bool:fixedLayout=false) {
    if(x<0.55 || x>0.78) x=0.73;
    if(y<0.0 || y>0.65) y=0.61;
    new wrapped[400],data[416],body[480],word[192],inner[192];
    FC_InfoBody(text,wrapped,charsmax(wrapped),fixedLayout);
    new at,lineStart,lineEnd,lines,width,widest;
    // Each data row gets the reference's short decoration; retain room for its
    // closing marks and never split a UTF-8 character at the packet limit.
    while(wrapped[lineStart] && at<charsmax(data)-8) {
        lineEnd=lineStart;while(wrapped[lineEnd] && wrapped[lineEnd]!='^n') lineEnd++;
        if(lines) data[at++]='^n';
        at+=copy(data[at],charsmax(data)-at,"[ - ");
        for(new i=lineStart;i<lineEnd;) {
            new next=i+1;while(next<lineEnd && (wrapped[next]&0xC0)==0x80) next++;
            if(at+next-i>charsmax(data)-4) break;
            while(i<next) data[at++]=wrapped[i++];
        }
        at+=copy(data[at],charsmax(data)-at," - ]");
        lines++;lineStart=lineEnd;if(wrapped[lineStart]=='^n') lineStart++;
    }
    data[at]=0;
    for(new i;data[i];i++) {
        if(data[i]=='^n') {widest=max(widest,width);width=0;}
        else if((data[i]&0xC0)!=0x80) width+=FC_PanelGlyphWidth(data[i]);
    }
    widest=max(widest,width);
    // Three colors need three fixed messages. The outer white arrows share
    // channel 4 with the white data; channel 1 stays free for CT game messages.
    new headerWidth=FC_HeaderWidth();
    new columnWidth=fixedLayout?340:max(widest,headerWidth);
    new headerLeft=max(0,(columnWidth-headerWidth)/2),bodyAt,wordAt,innerAt;
    new arrow=FC_PanelGlyphWidth('>'),gap=FC_PanelGlyphWidth(' ');
    FC_HeaderPad(body,bodyAt,charsmax(body),headerLeft);body[bodyAt++]='>';
    FC_HeaderPad(body,bodyAt,charsmax(body),headerLeft+headerWidth-arrow);body[bodyAt++]='<';
    body[bodyAt++]='^n';body[bodyAt++]='^n';
    // Center each decorated row over the same column, rather than anchoring
    // short UID/XP rows and long profession rows to a common left edge.
    lineStart=0;
    while(data[lineStart]) {
        lineEnd=lineStart;width=0;
        while(data[lineEnd] && data[lineEnd]!='^n') {
            if((data[lineEnd]&0xC0)!=0x80) width+=FC_PanelGlyphWidth(data[lineEnd]);
            lineEnd++;
        }
        new pad=clamp(floatround(float(columnWidth-width)/14.0),0,24);
        if(bodyAt+pad+lineEnd-lineStart+1>charsmax(body)) break;
        if(lineStart) body[bodyAt++]='^n';
        for(new i;i<pad;i++) body[bodyAt++]=' ';
        while(lineStart<lineEnd) body[bodyAt++]=data[lineStart++];
        if(data[lineStart]=='^n') lineStart++;
    }
    body[bodyAt]=0;
    new titleLeft=headerLeft+2*(arrow+gap);
    FC_HeaderPad(word,wordAt,charsmax(word),titleLeft);
    wordAt+=copy(word[wordAt],charsmax(word)-wordAt,"FeliciaClan");
    FC_HeaderPad(inner,innerAt,charsmax(inner),headerLeft+arrow+gap);inner[innerAt++]='>';
    FC_HeaderPad(inner,innerAt,charsmax(inner),headerLeft+headerWidth-2*arrow-gap);inner[innerAt++]='<';
    // Match the exact line count, including the gap below the heading.
    // This also keeps the three layers together if the client clamps the HUD.
    new rows=1;for(new i;body[i];i++) if(body[i]=='^n') rows++;
    for(new i=1;i<rows;i++) {word[wordAt++]='^n';inner[innerAt++]='^n';}
    word[wordAt++]=' ';word[wordAt]=0;
    inner[innerAt++]=' ';inner[innerAt]=0;
    y=floatmin(y,floatmax(0.35,0.89-float(rows)*0.028));
    copy(outBody,479,body);copy(outWord,191,word);copy(outInner,191,inner);
}

stock FC_ShowInfoHud(id,const text[],r,g,b,Float:x,Float:y,ar,ag,ab) {
    new body[480],word[192],inner[192];FC_BuildInfoHud(text,body,word,inner,x,y);
    g_iFCPanelWidth[id]=max(340,FC_PanelTextWidth(body));
    FC_SendPanelHud(id,body,r,g,b,x,y,4);
    FC_SendPanelHud(id,word,ar,ag,ab,x,y,3);
    FC_SendPanelHud(id,inner,255,210,0,x,y,2);
}

stock FC_ClearInfoHud(id) {
    // Clear both heading colors, the outer arrows and the data on HUD/team changes.
    for(new ch=2;ch<=4;ch++) FC_SendPanelHud(id,"",235,235,235,0.73,0.61,ch,0.1);
}

stock bool:CTConnected() {
    for(new id=1;id<=MaxClients;id++) if(is_user_connected(id) && get_member(id,m_iTeam)==TEAM_CT) return true;
    return false;
}

QueueMode(bool:hard,caller) {return BridgeQueueMode(hard,caller);}

bool:ModeReady(bool:hard) {
    return hard?g_hardPermit==g_roundNo:g_godPermit==g_roundNo;
}

TakeMode(bool:hard,caller) {
    if(!AliveCT(caller) || !ToolsAllowed(caller)) return 0;
    if(!ModeReady(hard)) {Chat(caller,"Bu özellik önceki el seçilmeli; izin sadece uygun el boyunca geçerlidir.");return 0;}
    if(hard?g_hard:g_godMode) {Chat(caller,"Bu el ^4%s ^1zaten aktif.",hard?"Hard Komut":"Godmode");return 1;}
    if(hard) {
        if(!SetHard(true,caller)) return 0;
        PlayCTSound(SND_HARD);return 1;
    }
    if(g_godUsed!=g_roundNo) {g_godUsed=g_roundNo;g_godNext=g_roundNo+3;}
    g_godMode=true;
    for(new id=1;id<=MaxClients;id++) ApplyRoundGod(id);
    PlayCTSound(SND_GOD);Chat(0,"^3%n ^1bu elin ^4Godmode ^1hakkını aldı. Sonraki kullanım: ^3%d. el^1.",caller,g_godNext);
    return 1;
}

RequestMode(bool:hard,caller) {return ModeReady(hard)?TakeMode(hard,caller):QueueMode(hard,caller);}

stock ModeLabel(bool:hard,out[],len) {
    new pending=hard?g_hardPending:g_godPending, earliest=hard?g_hardNext:g_godNext;
    new bool:active=hard?g_hard:g_godMode;
    if(active) copy(out,len,"Bu El Aktif");
    else if(ModeReady(hard)) copy(out,len,"Bu El Alabilirsin");
    else if(pending==g_roundNo+1) copy(out,len,"Sonraki El İzinli");
    else if(earliest>g_roundNo+1) formatex(out,len,"%d El Sonra",earliest-g_roundNo);
    else copy(out,len,"Seçilebilir");
}

ApplyRoundGod(id) {
    if(!g_godMode || !AliveCT(id)) return;
    SaveState(id,SNAP_TOOL);set_entvar(id,var_takedamage,DAMAGE_NO);set_entvar(id,var_health,10000.0);
}

stock AdvanceModes() {
    g_roundNo++;g_godPermit=g_hardPermit=-1;
    if(!CTConnected()) {g_godPending=g_hardPending=-1;return;}
    if(g_godPending==g_roundNo) {
        g_godPermit=g_roundNo;
        Chat(0,"Bu el ^4Godmode ^1alınabilir. Açmak için ^3CT Menü → 1. Godmode Al^1.");
    }
    if(g_hardPending==g_roundNo) {
        g_hardPermit=g_roundNo;
        Chat(0,"Bu el ^4Hard Komut ^1alınabilir. Açmak için ^3CT Menü → 2. Hard Komut Al^1.");
    }
    g_godPending=g_hardPending=-1;
}

bool:ProviderAllowed(CTGame:game,caller) {
    return g_externalToken<=0 && !g_bridgeRoundClosed && !g_bridgeLegacy && !g_rocketActive && HasControl(caller) && g_godMode && (g_game==CT_GAME_NONE || g_game==game) && HasCT();
}

HudModeLabel(bool:hard,out[],len) {
    new modeState=hard?hardkomutKontrol:godKontrol;
    if(hard?g_hard:g_godMode) copy(out,len,"Açık");else if(modeState==2) copy(out,len,"Alınabilir");else if(modeState==1) copy(out,len,"Sonraki El");else copy(out,len,"Seçilmedi");
}

BuildCTInfo(id,out[],len) {
    new gameName[64];if(g_game) copy(gameName,charsmax(gameName),GAME_NAMES[_:g_game]);else if(g_externalToken>0) copy(gameName,charsmax(gameName),g_externalName);else if(g_bridgeLegacy) copy(gameName,charsmax(gameName),g_bridgeGameName);else copy(gameName,charsmax(gameName),"Normal");
    new god[24],hard[24];HudModeLabel(false,god,charsmax(god));HudModeLabel(true,hard,charsmax(hard));
    formatex(out,len,"FeliciaClan | CT^nHP: %d | TL: %d^nOyun: %s^nGod: %s^nHard: %s^nMahkûm: %d | El: %d",get_user_health(id),Wallet(id),gameName,god,hard,CountT(),g_roundNo);
}

public CmdHard(id) {
    if(AliveCT(id)) {RequestMode(true,id);ShowMain(id);}
    return PLUGIN_HANDLED;
}

public CmdHardFeature(id) {
    if(g_hard && AliveT(id)) {Chat(id,"Hard Komut açıkken Redbull ve paraşüt kapalıdır.");return PLUGIN_HANDLED;}
    return PLUGIN_CONTINUE;
}

public N_Hard(plugin,argc) {return g_hard;}

public N_SetHard(plugin,argc) {
    new caller=argc>=2?get_param(2):0;
    return NativeAllowed(plugin,caller)?SetHard(get_param(1)!=0,caller):0;
}

bool:Listed(const list[],const name[]) {
    new at,token[96],n;
    while(list[at]) {
        n=0;while(list[at] && list[at]!=',') {if(n<charsmax(token)) token[n++]=list[at];at++;}
        token[n]=0;trim(token);if(equali(token,name)) return true;
        if(list[at]==',') at++;
    }
    return false;
}

bool:MovementPlugin(const filename[],const title[]) {
    // This bunny consumes the Hard cvar/forward itself and must keep receiving
    // state changes. Legacy bunny plugins still use pause/unpause below.
    if(equali(title,"FeliciaClan BunnyHop")) return false;
    new full[224];formatex(full,charsmax(full),"%s %s",filename,title);strtolower(full);
    if(contain(full,"jbmenu")!=-1 || contain(full,"ctmenu")!=-1 || contain(full,"ct menu")!=-1 ||
        contain(full,"jailbreak")!=-1 || contain(full,"hogwarts")!=-1 || contain(full,"milyoner")!=-1) return false;
    return Listed(g_hardPluginNames,filename) || contain(full,"redbull")!=-1 ||
        contain(full,"red bull")!=-1 || contain(full,"parachute")!=-1 ||
        contain(full,"parasute")!=-1 || contain(full,"bunny")!=-1 ||
        contain(full,"bhop")!=-1 || contain(full,"multi_jump")!=-1 || contain(full,"multijump")!=-1;
}

HardCvarsOn() {
    g_hardCount=0;new at,token[64],n;
    while(g_hardNames[at] && g_hardCount<MAX_HARD_CVARS) {
        n=0;while(g_hardNames[at] && g_hardNames[at]!=',') {if(n<charsmax(token)) token[n++]=g_hardNames[at];at++;}
        token[n]=0;trim(token);if(g_hardNames[at]==',') at++;
        if(!token[0]) continue;new ptr=get_cvar_pointer(token);if(!ptr) continue;
        new bool:duplicate=false;for(new i=0;i<g_hardCount;i++) if(g_hardCvars[i]==ptr) duplicate=true;
        if(duplicate) continue;
        g_hardCvars[g_hardCount]=ptr;get_pcvar_string(ptr,g_hardValues[g_hardCount],charsmax(g_hardValues[]));
        set_pcvar_num(ptr,0);g_hardCount++;
    }
}

HardPluginsOn() {
    g_hardPluginCount=0;new filename[96],title[128],status[24];
    for(new i=0;i<get_pluginsnum() && g_hardPluginCount<MAX_HARD_PLUGINS;i++) {
        get_plugin(i,filename,charsmax(filename),title,charsmax(title),_,_,_,_,status,charsmax(status));
        if(!equali(status,"running") || !MovementPlugin(filename,title)) continue;
        if(pause("ac",filename)) {copy(g_hardPlugins[g_hardPluginCount++],charsmax(g_hardPlugins[]),filename);log_amx("Hard Komut paused %s",filename);}
    }
}

SetHard(bool:enabled,caller) {
    if(enabled && g_externalToken>0) return 0;
    if(enabled && LibraryExists("fc_lr",LibType_Library) && fc_lr_active()) return 0;
    if(enabled==g_hard) return 1;
    if(g_game || (caller && !HasControl(caller))) {
        if(g_game && caller) Chat(caller,"Hard Komut'u değiştirmeden önce aktif oyunu durdur.");
        return 0;
    }
    if(enabled && g_hardPermit!=g_roundNo) {if(caller) Chat(caller,"Hard Komut önceki el seçilmeli; bu el için izin yok.");return 0;}
    new ret;
    if(enabled) {
        if(g_hardUsed!=g_roundNo) {g_hardUsed=g_roundNo;g_hardNext=g_roundNo+3;}
        g_hard=true;set_pcvar_num(g_hardStatus,1);HardCvarsOn();HardPluginsOn();
        for(new id=1;id<=MaxClients;id++) {
            g_hardUID[id]=0;
            if(is_user_alive(id)) {
                g_hardUID[id]=get_user_userid(id);g_hardTeam[id]=_:get_member(id,m_iTeam);
                get_entvar(id,var_gravity,g_hardGravity[id]);get_entvar(id,var_maxspeed,g_hardSpeed[id]);
                set_entvar(id,var_gravity,1.0);rg_reset_maxspeed(id);
            }
        }
        ExecuteForward(g_fwHard,ret,1);
    } else {
        g_hard=false;set_pcvar_num(g_hardStatus,0);
        for(new i=0;i<g_hardCount;i++) set_pcvar_string(g_hardCvars[i],g_hardValues[i]);
        g_hardCount=0;
        for(new i=0;i<g_hardPluginCount;i++) unpause("ac",g_hardPlugins[i]);
        g_hardPluginCount=0;ExecuteForward(g_fwHard,ret,0);
        for(new id=1;id<=MaxClients;id++) {
            if(g_hardUID[id] && is_user_alive(id) && get_user_userid(id)==g_hardUID[id] && _:get_member(id,m_iTeam)==g_hardTeam[id]) {
                set_entvar(id,var_gravity,g_hardGravity[id]);rg_reset_maxspeed(id);set_entvar(id,var_maxspeed,g_hardSpeed[id]);
            }
            g_hardUID[id]=0;ApplyCTPerks(id);
        }
    }
    if(caller) Chat(0,"^3%n ^1Hard Komut'u ^4%s ^1yaptı. Paraşüt, bunny, çift zıplama ve Redbull ^3%s^1.",caller,enabled?"açık":"kapalı",enabled?"kapalı":"önceki ayarlarında");
    return 1;
}

bool:UsingJBWallet(id) {return is_user_connected(id) && LibraryExists("feliciaclan_jbmenu",LibType_Library);}

Wallet(id) {return UsingJBWallet(id)?max(0,fc_get_tl(id)):max(0,g_localTL[id]);}

AddWallet(id,amount) {
    if(UsingJBWallet(id)) fc_add_tl(id,amount);
    else {g_localTL[id]=max(0,g_localTL[id]+amount);SaveWallet(id);}
}

LoadWallet(id) {
    if(g_vault<0 || !is_user_connected(id)) return;
    get_user_authid(id,g_auth[id],charsmax(g_auth[]));
    if(!g_auth[id][0] || equal(g_auth[id],"STEAM_ID_PENDING") || equal(g_auth[id],"VALVE_ID_PENDING") || equal(g_auth[id],"BOT") || equal(g_auth[id],"HLTV")) {g_auth[id][0]=0;return;}
    new data[40],timestamp;
    if(nvault_lookup(g_vault,g_auth[id],data,charsmax(data),timestamp)) g_localTL[id]=max(0,str_to_num(data));
    else {g_localTL[id]=g_cfg[CFG_LOCAL_START];SaveWallet(id);}
}

SaveWallet(id) {
    if(g_vault<0 || !g_auth[id][0] || UsingJBWallet(id)) return;
    new data[32];num_to_str(max(0,g_localTL[id]),data,charsmax(data));nvault_set(g_vault,g_auth[id],data);
}

public CmdMarket(id) {
    if(!AliveCT(id)) {Chat(id,"CT Market yalnız yaşayan CT oyuncuları içindir.");return PLUGIN_HANDLED;}
    ShowCTMarket(id);return PLUGIN_HANDLED;
}

ShowCTMarket(id) {
    new title[192];formatex(title,charsmax(title),"\wCT Market^n\dBakiye: \y%d TL^n\dGüçlendirmeler bu el için geçerlidir.",Wallet(id));
    new menu=CTMenu(title,"H_CTMarket"),line[160],info[8];
    for(new i=0;i<sizeof PERK_NAMES;i++) {
        if(g_perk[id][i]) formatex(line,charsmax(line),"\d%s \w[\rAktif\w]",PERK_NAMES[i]);
        else formatex(line,charsmax(line),"\w%s \w[\r%d TL\w]",PERK_NAMES[i],g_cfg[CFG_PRICE_HP+i]);
        num_to_str(i,info,charsmax(info));CTItem(menu,line,info,g_marketCB);
    }
    FC_CTMenuDisplay(id,menu);
}

public CB_CTPerk(id,menu,item) {
    new perk=ReadMenu(menu,item);
    return AliveCT(id) && !g_game && !g_hard && perk>=0 && perk<5 && !g_perk[id][perk]?ITEM_ENABLED:ITEM_DISABLED;
}

public H_CTMarket(id,menu,item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(!MenuActor(id,menu,item,false)) return PLUGIN_HANDLED;
    new perk=ReadMenu(menu,item);menu_destroy(menu);
    if(perk<0 || perk>=5 || g_perk[id][perk]) {ShowCTMarket(id);return PLUGIN_HANDLED;}
    if((LibraryExists("fc_lr",LibType_Library) && fc_lr_active()) || g_game || g_hard) {Chat(id,"Oyun veya Hard Komut açıkken CT Market kapalıdır.");ShowCTMarket(id);return PLUGIN_HANDLED;}
    new price=g_cfg[CFG_PRICE_HP+perk];
    if(Wallet(id)<price) {Chat(id,"Yeterli TL yok. Gerekli: ^3%d TL^1.",price);ShowCTMarket(id);return PLUGIN_HANDLED;}
    AddWallet(id,-price);g_perk[id][perk]=true;
    if(perk==0) {new Float:hp;get_entvar(id,var_health,hp);set_entvar(id,var_health,hp+150.0);}
    ApplyCTPerks(id);Chat(id,"^4%s ^1bu el için alındı. Kalan: ^3%d TL^1.",PERK_NAMES[perk],Wallet(id));
    ShowCTMarket(id);return PLUGIN_HANDLED;
}

ApplyCTPerks(id) {
    if(g_bridgeLegacy) return;
    if(!AliveCT(id) || g_game || g_hard) return;
    if(g_perk[id][2]) set_entvar(id,var_gravity,0.60);
    if(g_perk[id][4]) rg_reset_maxspeed(id);
    if(g_perk[id][1]) RefillClip(id);
}

public OnWeapon(id) {
    if((AliveCT(id) && !g_game && !g_hard && g_perk[id][1]) || (g_rocketActive && !g_rocketPhase && RocketTarget(id))) RefillClip(id);
}

RefillClip(id) {
    new wid=get_user_weapon(id);if(wid<1 || wid>30 || MAX_CLIP[wid]<=0) return;
    new classname[32];get_weaponname(wid,classname,charsmax(classname));new ent=find_ent_by_owner(-1,classname,id);
    if(ent>0) set_member(ent,m_Weapon_iClip,MAX_CLIP[wid]);
    rg_set_user_bpammo(id,WeaponIdType:wid,200);
}

public CmdCredit(id,level,cid) {
    if(!cmd_access(id,level,cid,3)) return PLUGIN_HANDLED;
    new text[40],amount[24];read_argv(1,text,charsmax(text));read_argv(2,amount,charsmax(amount));
    new target=cmd_target(id,text,CMDTARGET_ALLOW_SELF);if(!target) return PLUGIN_HANDLED;
    new value=clamp(str_to_num(amount),-100000,100000);AddWallet(target,value);
    console_print(id,"[FeliciaClan] %n TL: %d",target,Wallet(target));return PLUGIN_HANDLED;
}

GiveCTLoadout(id,bool:spawn=false,bool:refill=true) {
    if(!AliveCT(id) || (g_game && (!spawn || CTBattle())) || g_rocketActive
        || (LibraryExists("fc_lr",LibType_Library) && fc_lr_active() && fc_lr_is_player(id))) return;
    // GT_APPEND is intentional: replacing the primary slot would leave only AWP.
    // Reuse owned entities, so repeated reset never drops or duplicates a gun.
    if(find_ent_by_owner(-1,"weapon_usp",id)>0) rg_remove_item(id,"weapon_usp",true);
    new const classes[][]={"weapon_ak47","weapon_m4a1","weapon_m249","weapon_awp","weapon_deagle"};
    new const WeaponIdType:ids[]={WEAPON_AK47,WEAPON_M4A1,WEAPON_M249,WEAPON_AWP,WEAPON_DEAGLE};
    new const ammo[]={90,90,200,30,35};
    for(new i;i<sizeof classes;i++) {
        new ent=find_ent_by_owner(-1,classes[i],id);
        if(ent>0 && !refill) continue;
        if(ent<=0) ent=rg_give_item(id,classes[i],GT_APPEND);
        if(ent>0 && !is_nullent(ent)) {
            set_member(ent,m_Weapon_iClip,MAX_CLIP[_:ids[i]]);
            rg_set_user_bpammo(id,ids[i],ammo[i]);
        }
    }
}

GiveGun(id,gun) {
    if(!is_user_alive(id) || gun<0 || gun>=sizeof GUN_CLASS) return;
    rg_remove_items_by_slot(id,gun==7?PISTOL_SLOT:PRIMARY_WEAPON_SLOT);
    rg_give_item(id,GUN_CLASS[gun]);
    rg_set_user_bpammo(id,WeaponIdType:get_weaponid(GUN_CLASS[gun]),GUN_AMMO[gun]);
}

public CmdPlayers(id) {
    if(HasControl(id) && AliveCT(id)) {g_requestedAction[id]=1;ShowTargetScope(id);}
    return PLUGIN_HANDLED;
}

public CmdTools(id) {if(HasControl(id) && AliveCT(id)) ShowControlMenus(id);return PLUGIN_HANDLED;}

public CmdProtection(id) {if(AliveCT(id)) ShowProtectionMenu(id);return PLUGIN_HANDLED;}

public CmdCells(id) {if(HasControl(id) && AliveCT(id)) ToggleCells(id);return PLUGIN_HANDLED;}

public CmdGodStatus(id) {
    if(AliveCT(id)) {RequestMode(false,id);ShowMain(id);}
    return PLUGIN_HANDLED;
}

public CmdStop(id) {if(AliveCT(id)) BridgeReset(CT_STOP_MENU,true);return PLUGIN_HANDLED;}

public CmdHud(id) {
    if(AliveCT(id)) {
        g_showInfo[id]=!g_showInfo[id];
        if(!g_showInfo[id] && !LibraryExists("feliciaclan_jbmenu",LibType_Library)) FC_ClearInfoHud(id);
    }
    return PLUGIN_HANDLED;
}

public CmdStatus(id,level,cid) {
    if(!cmd_access(id,level,cid,1)) return PLUGIN_HANDLED;
    console_print(id,"[FeliciaClan] v%s | Oyun: %s | Mahkum: %d | Hard: %d | Hogwarts: %d | Milyoner: %d",VERSION,GAME_NAMES[_:g_game],CountEntrants(),g_hard,ExternalReady(CT_GAME_HOGWARTS),ExternalReady(CT_GAME_MILYONER));
    return PLUGIN_HANDLED;
}

bool:ToolsAllowed(id) {
    if(!HasControl(id)) return false;
    if(g_rocketActive) {Chat(id,"Önce Rocket işlemini durdur.");return false;}
    if(LibraryExists("fc_lr",LibType_Library) && fc_lr_active()) {Chat(id,"LR devam ediyor; oyuncu ayarları kilitli.");return false;}
    if(g_game) {Chat(id,"Oyuncu ayarlarını değiştirmek için önce ^3aktif oyunu durdur^1.");return false;}
    return true;
}

ShowTargetScope(id) {
    new menu=CTMenu("\wOyuncu Seçimi","H_Scope");
    CTItem(menu,"\wYaşayan Bütün Mahkûmlar","1");CTItem(menu,"\wNişangâhtaki Mahkûm","2");CTItem(menu,"\wListeden Oyuncu Seç","3");
    FC_CTMenuDisplay(id,menu);
}

public H_Scope(id,menu,item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(!MenuActor(id,menu,item)) return PLUGIN_HANDLED;
    new op=ReadMenu(menu,item);menu_destroy(menu);
    if(!ToolsAllowed(id)) return PLUGIN_HANDLED;
    if(op==1) {g_target[id]=0;g_targetUID[id]=0;ContinueTargetSelection(id);}
    else if(op==2) {
        new target,body;get_user_aiming(id,target,body,9999);
        if(target>=1 && target<=MaxClients && is_user_connected(target) && get_member(target,m_iTeam)==TEAM_TERRORIST) {g_target[id]=target;g_targetUID[id]=get_user_userid(target);ContinueTargetSelection(id);}
        else {Chat(id,"Nişangâhını bir ^3mahkûma ^1doğrult.");ShowTargetScope(id);}
    }
    else ShowPlayerList(id);
    return PLUGIN_HANDLED;
}

ShowPlayerList(id) {
    new menu=CTMenu("\wMahkûm Seç","H_PlayerList"),line[128],info[24],nick[32];
    for(new target=1;target<=MaxClients;target++) if(is_user_connected(target) && get_member(target,m_iTeam)==TEAM_TERRORIST) {
        get_user_name(target,nick,charsmax(nick));formatex(line,charsmax(line),"\w%s \d[%s]",nick,is_user_alive(target)?"Yaşıyor":"Ölü");
        num_to_str(get_user_userid(target),info,charsmax(info));CTItem(menu,line,info);
    }
    FC_CTMenuDisplay(id,menu);
}

public H_PlayerList(id,menu,item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(!MenuActor(id,menu,item)) return PLUGIN_HANDLED;
    new uid=ReadMenu(menu,item);menu_destroy(menu);
    new target=find_player("k",uid);
    if(!ToolsAllowed(id) || !target || get_member(target,m_iTeam)!=TEAM_TERRORIST) {Chat(id,"Oyuncu artık bu listede değil.");return PLUGIN_HANDLED;}
    g_target[id]=target;g_targetUID[id]=uid;ContinueTargetSelection(id);return PLUGIN_HANDLED;
}

bool:TargetValid(id) {
    new target=g_target[id];
    return !target || (target<=MaxClients && is_user_connected(target) && get_user_userid(target)==g_targetUID[id] && get_member(target,m_iTeam)==TEAM_TERRORIST);
}

bool:TargetMatches(caller,target,bool:alive=true) {
    return TargetValid(caller) && (!g_target[caller] || g_target[caller]==target) && is_user_connected(target) && get_member(target,m_iTeam)==TEAM_TERRORIST && (!alive || is_user_alive(target));
}

ShowPlayerActions(id) {
    if(!TargetValid(id)) {Chat(id,"Oyuncu ayrıldı veya takım değiştirdi.");ShowTargetScope(id);return;}
    new nick[32],title[192];if(g_target[id]) get_user_name(g_target[id],nick,charsmax(nick));else copy(nick,charsmax(nick),"Bütün Mahkûmlar");
    formatex(title,charsmax(title),"\wOyuncu İşlemleri^n\y%s",nick);
    new menu=CTMenu(title,"H_PlayerActions");
    CTItem(menu,"\wCanlandır","1");CTItem(menu,"\wSilahları Al / Bıçak Bırak","2");CTItem(menu,"\wSilah Ver","3");
    CTItem(menu,"\wDondur / Çöz","4");CTItem(menu,"\wCan Miktarını Ayarla","5");CTItem(menu,"\wYerçekimini Ayarla","6");
    CTItem(menu,"\wYanıma Getir \d[God]","7");CTItem(menu,"\wGod Aç / Kapat","8");CTItem(menu,"\wGlow Rengi Ver","9");
    CTItem(menu,"\wNoclip Aç / Kapat","10");FC_CTMenuDisplay(id,menu);
}

public H_PlayerActions(id,menu,item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(!MenuActor(id,menu,item)) return PLUGIN_HANDLED;
    new op=ReadMenu(menu,item);menu_destroy(menu);
    return RunPlayerAction(id,op);
}

RunPlayerAction(id,op) {
    if(!AliveCT(id) || !ToolsAllowed(id) || !TargetValid(id)) return PLUGIN_HANDLED;
    if(op==7) {BringPrisoners(id);ShowPlayerActions(id);return PLUGIN_HANDLED;}
    if(op==3) {ShowWeapons(id);return PLUGIN_HANDLED;}
    if(op==5 || op==6) {g_input[id]=op;client_cmd(id,"messagemode fc_ct_value");Chat(id,op==5?"^3 1-5000 ^1arasında can gir.":"Yerçekimi katsayısı gir: ^3 0.1 - 3.0 ^1(normal: 1.0).");return PLUGIN_HANDLED;}
    new changed;
    for(new target=1;target<=MaxClients;target++) if(TargetMatches(id,target,op!=1)) {
        if(op==1) {
            if(!is_user_alive(target)) {rg_round_respawn(target);changed++;}
            continue;
        }
        SaveState(target,SNAP_TOOL);changed++;
        switch(op) {
            case 2: {rg_remove_all_items(target);rg_give_item(target,"weapon_knife");}
            case 4: {g_toolFrozen[target]=!g_toolFrozen[target];g_thawTime[target]=0.0;GameFreeze(target,g_toolFrozen[target]);}
            case 8: {new Float:damage;get_entvar(target,var_takedamage,damage);set_entvar(target,var_takedamage,damage==DAMAGE_NO?DAMAGE_AIM:DAMAGE_NO);}
            case 9:Glow(target,random_num(80,255),random_num(80,255),random_num(80,255));
            case 10:set_entvar(target,var_movetype,get_entvar(target,var_movetype)==MOVETYPE_NOCLIP?MOVETYPE_WALK:MOVETYPE_NOCLIP);
        }
    }
    Chat(id,"^3%d ^1oyuncuya işlem uygulandı.",changed);ShowPlayerActions(id);return PLUGIN_HANDLED;
}

public CmdValue(id) {
    new op=g_input[id];g_input[id]=0;
    if(!op || !AliveCT(id) || !ToolsAllowed(id) || !TargetValid(id)) return PLUGIN_HANDLED;
    new text[40];read_args(text,charsmax(text));remove_quotes(text);trim(text);
    new dots,digits;
    for(new i=0;text[i];i++) {
        if(text[i]>='0' && text[i]<='9') {digits++;continue;}
        if(text[i]=='.' && ++dots==1) continue;
        Chat(id,"Geçerli bir sayı gir; ondalık değer için nokta kullan.");return PLUGIN_HANDLED;
    }
    if(!digits) return PLUGIN_HANDLED;
    new Float:value=str_to_float(text);
    if((op==5 && (value<1.0 || value>5000.0)) || (op==6 && (value<0.1 || value>3.0))) {Chat(id,"Miktar izin verilen aralıkta değil.");return PLUGIN_HANDLED;}
    for(new target=1;target<=MaxClients;target++) if(TargetMatches(id,target)) {SaveState(target,SNAP_TOOL);set_entvar(target,op==5?var_health:var_gravity,value);}
    ShowPlayerActions(id);return PLUGIN_HANDLED;
}

ShowWeapons(id) {
    new menu=CTMenu("\wSilah Seç","H_Weapons"),line[64],info[8];
    for(new i=0;i<sizeof GUN_NAMES;i++) {formatex(line,charsmax(line),"\w%s",GUN_NAMES[i]);num_to_str(i,info,charsmax(info));CTItem(menu,line,info);}
    FC_CTMenuDisplay(id,menu);
}

public H_Weapons(id,menu,item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(!MenuActor(id,menu,item)) return PLUGIN_HANDLED;
    new gun=ReadMenu(menu,item);menu_destroy(menu);
    if(!ToolsAllowed(id) || !TargetValid(id) || gun<0 || gun>=sizeof GUN_NAMES) return PLUGIN_HANDLED;
    for(new target=1;target<=MaxClients;target++) if(TargetMatches(id,target)) {SaveState(target,SNAP_TOOL);GiveGun(target,gun);}
    ShowPlayerActions(id);return PLUGIN_HANDLED;
}

ShowTools(id) {
    new menu=CTMenu("\wCT Araçları","H_Tools");
    CTItem(menu,"\wMahkûm / Silah / Konum İşlemleri","1");CTItem(menu,"\wBütün Ölü Mahkûmları Canlandır","2");
    CTItem(menu,"\wMahkûmlara 3 Saniye Donma Süresi","3");CTItem(menu,"\wMahkûmların Silahlarını Al","4");
    CTItem(menu,"\wSon Ölen Mahkûmu Canlandır","5");CTItem(menu,"\wHücreleri Aç / Kapat","6");
    CTItem(menu,"\wAçlık Oyunları Alanını Düzenle","7");FC_CTMenuDisplay(id,menu);
}

public H_Tools(id,menu,item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(!MenuActor(id,menu,item)) return PLUGIN_HANDLED;
    new op=ReadMenu(menu,item);menu_destroy(menu);
    if(op==7) {ShowArenaMenu(id);return PLUGIN_HANDLED;}
    else if(op==6) ToggleCells(id);
    else if(op==5) {if(ToolsAllowed(id)) ReviveLast(id);}
    else if(op==1) {g_requestedAction[id]=0;ShowTargetScope(id);return PLUGIN_HANDLED;}
    else if(ToolsAllowed(id)) for(new target=1;target<=MaxClients;target++) if(is_user_connected(target) && get_member(target,m_iTeam)==TEAM_TERRORIST) {
        if(op==2) {if(!is_user_alive(target)) rg_round_respawn(target);continue;}
        if(!is_user_alive(target)) continue;SaveState(target,SNAP_TOOL);
        if(op==3) {g_toolFrozen[target]=true;g_thawTime[target]=get_gametime()+3.0;GameFreeze(target,true);}
        if(op==4) {rg_remove_all_items(target);rg_give_item(target,"weapon_knife");}
    }
    ShowTools(id);return PLUGIN_HANDLED;
}

ToggleCells(id) {
    new used[64],count,ent=-1,at,n,key[64];
    // Explicit map targetnames have priority; never activate every map button.
    while(g_cellTargets[at] && count<sizeof used) {
        n=0;while(g_cellTargets[at] && g_cellTargets[at]!=',') {if(n<charsmax(key)) key[n++]=g_cellTargets[at];at++;}
        key[n]=0;trim(key);if(g_cellTargets[at]==',') at++;
        if(!key[0]) continue;ent=-1;
        while(count<sizeof used && (ent=find_ent_by_tname(ent,key))>0) UseCellOnce(id,ent,used,count);
    }
    if(!g_cellTargets[0]) {
        new spawn=-1,Float:origin[3],classname[32],targetname[64];
        while(count<sizeof used && (spawn=find_ent_by_class(spawn,"info_player_deathmatch"))>0) {
            entity_get_vector(spawn,EV_VEC_origin,origin);ent=-1;
            while(count<sizeof used && (ent=find_ent_in_sphere(ent,origin,300.0))>0) {
                entity_get_string(ent,EV_SZ_classname,classname,charsmax(classname));
                if(!equal(classname,"func_door") && !equal(classname,"func_door_rotating")) continue;
                entity_get_string(ent,EV_SZ_targetname,targetname,charsmax(targetname));
                new button=targetname[0]?find_ent_by_target(-1,targetname):0;
                UseCellOnce(id,button>0?button:ent,used,count);
            }
        }
    }
    if(count) Chat(0,"^3%n ^1hücreleri açtı / kapattı. ^4%d ^1hücre kontrolü kullanıldı.",id,count);
    else Chat(id,"Hücre kontrolü bulunamadı. INI'deki ^3CELL_TARGETS ^1alanına haritanın düğme/kapı targetname değerini gir.");
}

UseCellOnce(id,ent,used[],&count) {
    for(new i=0;i<count;i++) if(used[i]==ent) return;
    if(count>=64 || !is_valid_ent(ent)) return;
    used[count++]=ent;force_use(id,ent);
}

ReviveLast(id) {
    if(!ToolsAllowed(id)) return;
    if(g_lastDead<1 || !is_user_connected(g_lastDead) || get_user_userid(g_lastDead)!=g_lastDeadUID || get_member(g_lastDead,m_iTeam)!=TEAM_TERRORIST || is_user_alive(g_lastDead)) {Chat(id,"Canlandırılabilecek son mahkûm bulunamadı.");return;}
    rg_round_respawn(g_lastDead);Chat(0,"^3%n ^1tarafından ^4%n ^1canlandırıldı.",id,g_lastDead);
}

ResetTools() {
    StopRocket();
    if(LibraryExists("fc_lr",LibType_Library) && fc_lr_active()) return;
    CancelProtectionVote();
    CancelC4Countdown();
    for(new id=1;id<=MaxClients;id++) C4Lift(id);
    g_godMode=false;
    SetHard(false,0);
    for(new id=1;id<=MaxClients;id++) {RestoreState(id,SNAP_TOOL,true);g_toolFrozen[id]=false;g_thawTime[id]=0.0;g_input[id]=0;if(AliveCT(id)) ApplyCTPerks(id);}
}

ShowSettings(id) {
    new title[256];formatex(title,charsmax(title),"\wDurum^n\dSürüm: \w%s^n\dHogwarts: \y%s \d| Milyoner: \y%s",VERSION,ExternalReady(CT_GAME_HOGWARTS)?"Yüklü":"Eksik",ExternalReady(CT_GAME_MILYONER)?"Yüklü":"Eksik");
    new menu=CTMenu(title,"H_Settings");CTItem(menu,g_showInfo[id]?"\wCT HUD \w[\rAçık\w]":"\wCT HUD \w[\rKapalı\w]","1");CTItem(menu,"\wINI Yapılandırmasını Yenile","2");CTItem(menu,"\wAktif Oyunu Durdur / Ayarları Geri Al","3");CTItem(menu,"\wSesleri Durdur","4");FC_CTMenuDisplay(id,menu);
}

public H_Settings(id,menu,item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(!MenuActor(id,menu,item)) return PLUGIN_HANDLED;
    new op=ReadMenu(menu,item);menu_destroy(menu);
    if(op==1) {g_showInfo[id]=!g_showInfo[id];if(!g_showInfo[id] && !LibraryExists("feliciaclan_jbmenu",LibType_Library)) FC_ClearInfoHud(id);}
    if(op==2 && !g_game && !g_hard) {LoadCTConfig();LoadArena();Chat(id,"CT menü INI dosyaları yenilendi.");}
    else if(op==2) Chat(id,"Yenilemeden önce aktif oyunu ve Hard Komut'u kapat.");
    if(op==3) ResetSettings(id);
    if(op==4) client_cmd(0,"stopsound");
    ShowSettings(id);return PLUGIN_HANDLED;
}

LoadArena() {
    g_hasArena=false;g_arenaCount=0;new map[64];get_mapname(map,charsmax(map));
    formatex(g_arenaPath,charsmax(g_arenaPath),"addons/amxmodx/configs/FeliciaClan/ct_arenas/%s.ini",map);
    new f=fopen(g_arenaPath,"rt");if(!f) return;new line[192],key[24],x[40],y[40],z[40];
    while(!feof(f)) {
        fgets(f,line,charsmax(line));trim(line);if(!line[0] || line[0]==';' || line[0]=='#') continue;
        if(parse(line,key,charsmax(key),x,charsmax(x),y,charsmax(y),z,charsmax(z))!=4) continue;
        if(equali(key,"CENTER")) {g_arenaCenter[0]=str_to_float(x);g_arenaCenter[1]=str_to_float(y);g_arenaCenter[2]=str_to_float(z);g_hasArena=true;}
        else if(equali(key,"CRATE") && g_arenaCount<MAX_ARENA_POINTS) {g_arenaPoints[g_arenaCount][0]=str_to_float(x);g_arenaPoints[g_arenaCount][1]=str_to_float(y);g_arenaPoints[g_arenaCount][2]=str_to_float(z);g_arenaCount++;}
    }
    fclose(f);
}

SaveArena() {
    new f=fopen(g_arenaPath,"wt");if(!f) return 0;
    fprintf(f,"; FeliciaClan CTMenu - haritaya özel Açlık Oyunları alanı^n");
    if(g_hasArena) fprintf(f,"CENTER %.2f %.2f %.2f^n",g_arenaCenter[0],g_arenaCenter[1],g_arenaCenter[2]);
    for(new i=0;i<g_arenaCount;i++) fprintf(f,"CRATE %.2f %.2f %.2f^n",g_arenaPoints[i][0],g_arenaPoints[i][1],g_arenaPoints[i][2]);
    fclose(f);return 1;
}

ShowArenaMenu(id) {
    if(!AliveCT(id) || !ToolsAllowed(id)) return;
    new title[160];formatex(title,charsmax(title),"\wAçlık Oyunları Alanı^n\dMerkez: \y%s \d| Kutu: \y%d/32",g_hasArena?"Kayıtlı":"Otomatik",g_arenaCount);
    new menu=CTMenu(title,"H_Arena");CTItem(menu,"\wBulunduğum Yeri Alan Merkezi Yap","1");CTItem(menu,"\wBulunduğum Yere İkmal Kutusu Ekle","2");
    CTItem(menu,"\wSon Kutu Noktasını Sil","3");CTItem(menu,"\wINI Dosyasına Kaydet","4");CTItem(menu,"\wOtomatik Alanı Kullan / Noktaları Sil","5");FC_CTMenuDisplay(id,menu);
}

public H_Arena(id,menu,item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(!MenuActor(id,menu,item)) return PLUGIN_HANDLED;
    new op=ReadMenu(menu,item);menu_destroy(menu);if(!ToolsAllowed(id)) return PLUGIN_HANDLED;
    new Float:p[3];get_entvar(id,var_origin,p);p[2]-=30.0;
    if(op==1) {g_hasArena=true;for(new j=0;j<3;j++) g_arenaCenter[j]=p[j];}
    if(op==2 && g_arenaCount<MAX_ARENA_POINTS) {for(new j=0;j<3;j++) g_arenaPoints[g_arenaCount][j]=p[j];g_arenaCount++;}
    if(op==3 && g_arenaCount) g_arenaCount--;
    if(op==4) Chat(id,SaveArena()?"Harita alanı INI dosyasına kaydedildi.":"INI dosyasına yazılamadı. ct_arenas klasörünü kontrol et.");
    if(op==5) {g_hasArena=false;g_arenaCount=0;}
    ShowArenaMenu(id);return PLUGIN_HANDLED;
}

public Heartbeat() {
    BridgeMaintenance();
    new Float:now=get_gametime();g_walletSeconds++;
    new bool:jbLoaded=bool:LibraryExists("feliciaclan_jbmenu",LibType_Library);
    for(new id=1;id<=MaxClients;id++) if(is_user_connected(id)) {
        if(g_buriedUID[id] && g_buryUntil[id]>0.0 && now>=g_buryUntil[id]) C4Lift(id);
        if(g_toolFrozen[id] && g_thawTime[id]>0.0 && now>=g_thawTime[id]) {GameFreeze(id,false);g_toolFrozen[id]=false;g_thawTime[id]=0.0;}
        if(AliveCT(id)) {
            if(!g_game && g_perk[id][3] && now>=g_nextRegen[id]) {new Float:hp;get_entvar(id,var_health,hp);new Float:limit=float(g_cfg[CFG_CT_HP]+(g_perk[id][0]?150:0));if(hp<limit) set_entvar(id,var_health,floatmin(limit,hp+3.0));g_nextRegen[id]=now+1.0;}
            if(g_walletSeconds>=60 && !g_game && !UsingJBWallet(id)) {g_localTL[id]+=g_cfg[CFG_LOCAL_MINUTE];SaveWallet(id);}
            // JBMenu owns the shared panel when installed: one writer per player.
            if(!jbLoaded && g_showInfo[id] && g_game!=CT_GAME_HOGWARTS && g_game!=CT_GAME_MILYONER) {
                new text[384];BuildCTInfo(id,text,charsmax(text));
                FC_ShowInfoHud(id,text,235,235,235,0.73,0.61,0,80,255);
                g_standaloneHud[id]=true;
            }
            else if(!jbLoaded && g_standaloneHud[id]) {FC_ClearInfoHud(id);g_standaloneHud[id]=false;}

        }
        else if(!jbLoaded && g_standaloneHud[id]) {FC_ClearInfoHud(id);g_standaloneHud[id]=false;}
    }
    if(g_walletSeconds>=60) g_walletSeconds=0;
}

bool:HasAmmo(wid) {return wid>=1 && wid<=30 && wid!=2 && wid!=CSW_KNIFE && wid!=CSW_C4;}

bool:HasClip(wid) {return HasAmmo(wid) && wid!=CSW_HEGRENADE && wid!=CSW_SMOKEGRENADE && wid!=CSW_FLASHBANG;}

SaveState(id,mode) {
    if(!is_user_alive(id) || g_snap[mode][id][SS_VALID]) return;
    g_snap[mode][id][SS_VALID]=1;g_snap[mode][id][SS_UID]=get_user_userid(id);
    g_snap[mode][id][SS_TEAM]=_:get_member(id,m_iTeam);
    g_snap[mode][id][SS_FLAGS]=get_entvar(id,var_flags);g_snap[mode][id][SS_MOVETYPE]=get_entvar(id,var_movetype);
    g_snap[mode][id][SS_RENDERFX]=get_entvar(id,var_renderfx);g_snap[mode][id][SS_RENDERMODE]=get_entvar(id,var_rendermode);
    get_entvar(id,var_health,g_snap[mode][id][SS_HEALTH]);get_entvar(id,var_armorvalue,g_snap[mode][id][SS_ARMOR]);
    get_entvar(id,var_gravity,g_snap[mode][id][SS_GRAVITY]);get_entvar(id,var_maxspeed,g_snap[mode][id][SS_SPEED]);
    get_entvar(id,var_takedamage,g_snap[mode][id][SS_DAMAGE]);get_entvar(id,var_renderamt,g_snap[mode][id][SS_RENDERAMT]);
    get_entvar(id,var_rendercolor,g_snap[mode][id][SS_COLOR]);get_entvar(id,var_origin,g_snap[mode][id][SS_ORIGIN]);
    get_entvar(id,var_viewmodel,g_oldView[mode][id],charsmax(g_oldView[][]));
    get_entvar(id,var_weaponmodel,g_oldHand[mode][id],charsmax(g_oldHand[][]));
    g_snap[mode][id][SS_KEVLAR]=_:get_member(id,m_iKevlar);g_snap[mode][id][SS_DEFUSER]=get_member(id,m_bHasDefuser);
    g_snap[mode][id][SS_ACTIVE]=get_user_weapon(id);
    get_user_weapons(id,g_savedWeapons[mode][id],g_snap[mode][id][SS_COUNT]);
    arrayset(g_savedClip[mode][id],0,31);arrayset(g_savedAmmo[mode][id],0,31);
    new classname[32];
    for(new i=0;i<g_snap[mode][id][SS_COUNT];i++) {
        new wid=g_savedWeapons[mode][id][i];if(!HasAmmo(wid)) continue;
        get_weaponname(wid,classname,charsmax(classname));
        if(HasClip(wid)) {new ent=find_ent_by_owner(-1,classname,id);if(ent>0) g_savedClip[mode][id][wid]=get_member(ent,m_Weapon_iClip);}
        g_savedAmmo[mode][id][wid]=rg_get_user_bpammo(id,WeaponIdType:wid);
    }
}

RestoreState(id,mode,bool:inventory=true) {
    if(!g_snap[mode][id][SS_VALID]) return;
    g_snap[mode][id][SS_VALID]=0;
    if(!is_user_connected(id) || get_user_userid(id)!=g_snap[mode][id][SS_UID] || !is_user_alive(id)) return;
    if(_:get_member(id,m_iTeam)!=g_snap[mode][id][SS_TEAM]) {
        // A team switch must never transfer CT god, speed or a CT weapon to T.
        set_entvar(id,var_flags,get_entvar(id,var_flags)&~FL_FROZEN);
        set_entvar(id,var_movetype,MOVETYPE_WALK);set_entvar(id,var_gravity,1.0);set_entvar(id,var_takedamage,DAMAGE_AIM);
        ClearGlow(id);rg_reset_maxspeed(id);return;
    }
    new flags=get_entvar(id,var_flags);
    if(g_snap[mode][id][SS_FLAGS]&FL_FROZEN) flags|=FL_FROZEN;else flags&=~FL_FROZEN;
    set_entvar(id,var_flags,flags);set_entvar(id,var_movetype,g_snap[mode][id][SS_MOVETYPE]);
    set_entvar(id,var_health,g_snap[mode][id][SS_HEALTH]);set_entvar(id,var_armorvalue,g_snap[mode][id][SS_ARMOR]);
    set_entvar(id,var_gravity,g_snap[mode][id][SS_GRAVITY]);set_entvar(id,var_maxspeed,g_snap[mode][id][SS_SPEED]);
    set_entvar(id,var_takedamage,g_snap[mode][id][SS_DAMAGE]);
    set_entvar(id,var_renderfx,g_snap[mode][id][SS_RENDERFX]);set_entvar(id,var_rendermode,g_snap[mode][id][SS_RENDERMODE]);
    set_entvar(id,var_renderamt,g_snap[mode][id][SS_RENDERAMT]);set_entvar(id,var_rendercolor,g_snap[mode][id][SS_COLOR]);
    set_member(id,m_iKevlar,g_snap[mode][id][SS_KEVLAR]);set_member(id,m_bHasDefuser,g_snap[mode][id][SS_DEFUSER]);
    if(inventory) {
        rg_remove_all_items(id);
        new classname[32];
        for(new i=0;i<g_snap[mode][id][SS_COUNT];i++) {
            new wid=g_savedWeapons[mode][id][i];if(wid<1 || wid>30 || wid==2) continue;
            get_weaponname(wid,classname,charsmax(classname));new ent=rg_give_item(id,classname);
            if(ent>0 && HasClip(wid)) set_member(ent,m_Weapon_iClip,g_savedClip[mode][id][wid]);
            if(HasAmmo(wid)) rg_set_user_bpammo(id,WeaponIdType:wid,g_savedAmmo[mode][id][wid]);
        }
        new active=g_snap[mode][id][SS_ACTIVE];
        if(active>=1 && active<=30 && active!=2 && user_has_weapon(id,active)) {get_weaponname(active,classname,charsmax(classname));engclient_cmd(id,classname);}
        set_entvar(id,var_viewmodel,g_oldView[mode][id]);set_entvar(id,var_weaponmodel,g_oldHand[mode][id]);
    }
}

Glow(id,r,g,b) {
    new Float:rgb[3];rgb[0]=float(r);rgb[1]=float(g);rgb[2]=float(b);
    set_entvar(id,var_renderfx,kRenderFxGlowShell);set_entvar(id,var_rendercolor,rgb);
    set_entvar(id,var_rendermode,kRenderNormal);set_entvar(id,var_renderamt,20.0);
}

ClearGlow(id) {
    set_entvar(id,var_renderfx,kRenderFxNone);set_entvar(id,var_rendermode,kRenderNormal);
    set_entvar(id,var_renderamt,0.0);set_entvar(id,var_rendercolor,Float:{255.0,255.0,255.0});
}

GameFreeze(id,bool:frozen) {
    new flags=get_entvar(id,var_flags);
    if(frozen) flags|=FL_FROZEN;else flags&=~FL_FROZEN;
    set_entvar(id,var_flags,flags);
}

SaveCvars() {
    if(g_cvarsSaved) return;g_cvarsSaved=true;
    if(g_cvarFF) get_pcvar_string(g_cvarFF,g_oldFF,charsmax(g_oldFF));
    if(g_cvarFFA) get_pcvar_string(g_cvarFFA,g_oldFFA,charsmax(g_oldFFA));
    if(g_cvarInfinite) {get_pcvar_string(g_cvarInfinite,g_oldInfinite,charsmax(g_oldInfinite));set_pcvar_string(g_cvarInfinite,"1");}
}

RestoreCvars() {
    if(!g_cvarsSaved) return;g_cvarsSaved=false;
    if(g_cvarFF) set_pcvar_string(g_cvarFF,g_oldFF);
    if(g_cvarFFA) set_pcvar_string(g_cvarFFA,g_oldFFA);
    if(g_cvarInfinite) set_pcvar_string(g_cvarInfinite,g_oldInfinite);
}

bool:CTBattle() {return g_game==CT_GAME_ZOMBIE || g_game==CT_GAME_GHOST || g_game==CT_GAME_AREF || g_game==CT_GAME_SPARTA;}

bool:CombatGame() {return g_game==CT_GAME_KNIFE || g_game==CT_GAME_GUN || g_game==CT_GAME_TEAMS || g_game==CT_GAME_HUNGER || g_game==CT_GAME_SUMO || CTBattle() || g_game==CT_GAME_REVERSE || g_game==CT_GAME_LOW_GRAVITY || g_game==CT_GAME_ONE_HP || g_game==CT_GAME_DEAGLE || g_game==CT_GAME_SHOTGUN || g_game==CT_GAME_SNIPER;}

BeginSession(CTGame:game,caller) {
    StopRocket();
    CancelProtectionVote();g_reflexStarting=false;
    arrayset(g_reflexLanding,false,sizeof g_reflexLanding);
    CancelC4Countdown();
    for(new id=1;id<=MaxClients;id++) C4Lift(id);
    g_game=game;g_announced=false;g_gameBoss=caller;g_gameBossUID=caller>=1 && caller<=MaxClients && is_user_connected(caller)?get_user_userid(caller):0;
    g_nextLaser=0.0;g_sumoNextDraw=0.0;g_tronHead=-1;g_tronCount=0;
    for(new id=1;id<=MaxClients;id++) if(g_standaloneHud[id]) {FC_ClearInfoHud(id);g_standaloneHud[id]=false;}
    g_phase=0;g_rounds=0;g_bomb=0;g_secret=0;g_crateCount=0;
    g_gameEnd=get_gametime()+float(g_cfg[CFG_GAME_SECONDS]);g_phaseEnd=0.0;g_graceEnd=0.0;g_nextSecond=0.0;
    for(new id=1;id<=MaxClients;id++) {
        g_part[id]=AliveT(id);g_partUID[id]=g_part[id]?get_user_userid(id):0;
        g_color[id]=0;g_ready[id]=false;g_prevButtons[id]=0;g_touchNext[id]=0.0;g_infectionNextHP[id]=0.0;
        g_snap[SNAP_GAME][id][SS_VALID]=0;
    }
    // Other plugins settle crate payments/end timed effects before snapshots.
    new ret;ExecuteForward(g_fwPrepare,ret,caller,_:game);
    SaveCvars();
    for(new id=1;id<=MaxClients;id++) {
        if(AliveCT(id)) {
            SaveState(id,SNAP_GAME);
            if(GAME_GOD[_:game]) {
                if(game==CT_GAME_HOMELANDER && id!=caller) set_entvar(id,var_takedamage,DAMAGE_AIM);
                else {set_entvar(id,var_takedamage,DAMAGE_NO);set_entvar(id,var_health,10000.0);}
            }
        }
        else if(IsEntrant(id) && game!=CT_GAME_HOGWARTS) {
            SaveState(id,SNAP_GAME);GameFreeze(id,false);set_entvar(id,var_gravity,1.0);
            set_entvar(id,var_movetype,MOVETYPE_WALK);set_entvar(id,var_takedamage,DAMAGE_AIM);
            ClearGlow(id);
            if(game!=CT_GAME_MILYONER) {rg_remove_all_items(id);rg_give_item(id,"weapon_knife");set_entvar(id,var_health,100.0);set_entvar(id,var_armorvalue,0.0);}
        }
    }
    if(g_cvarFFA && game!=CT_GAME_HOGWARTS) set_pcvar_num(g_cvarFFA,CombatGame() && !CTBattle()?1:0);
    if(g_cvarFF && game!=CT_GAME_HOGWARTS) set_pcvar_num(g_cvarFF,CombatGame() && !CTBattle()?1:0);
}

StartCTGame(CTGame:game,caller) {
    if(g_externalToken>0 || g_bridgeRoundClosed || g_bridgeLegacy) {if(caller) Chat(caller,"Önce aktif oyunu durdur.");return 0;}
    if(game==CT_GAME_ROCKET) {if(caller) ShowRocketMenu(caller);return 0;}
    if(g_rocketActive) {if(caller) Chat(caller,"Önce Rocket işlemini durdur.");return 0;}
    if(LibraryExists("fc_lr",LibType_Library) && fc_lr_active()) {if(caller) Chat(caller,"LR devam ediyor; yeni oyun başlatılamaz.");return 0;}
    if(game<=CT_GAME_NONE || _:game>=sizeof GAME_NAMES || !HasControl(caller)) return 0;
    if((game==CT_GAME_HOMELANDER || game==CT_GAME_MAGNETIC || game==CT_GAME_SUMO) && !AliveCT(caller)) {if(caller) Chat(caller,"Bu oyun için yaşayan CT komutanı olarak başlatmalısın.");return 0;}
    if(GAME_GOD[_:game] && !g_godMode) {if(caller) Chat(caller,"Godmode önceki el seçilmedi veya bu el kapalı. Bu oyun açılamaz.");return 0;}
    if(g_game!=CT_GAME_NONE || (ExternalReady(CT_GAME_HOGWARTS) && hogwarts_state()) || (ExternalReady(CT_GAME_MILYONER) && milyoner_active())) {
        if(caller) Chat(caller,"Bir oyun zaten aktif. Önce mevcut oyunu durdur.");return 0;
    }
    new minimum=game==CT_GAME_MILYONER?1:2;
    if(CountT()<minimum || !HasCT()) {if(caller) Chat(caller,"En az ^3%d yaşayan mahkûm ^1ve ^3 1 yaşayan CT ^1gerekir.",minimum);return 0;}
    if(!ExternalReady(game)) {if(caller) Chat(caller,"Bu oyunun eklentisi yüklenmedi.");return 0;}
    if(game==CT_GAME_REFLEX && (!g_reflexAssetsReady || !g_msgReflexList || !g_msgReflexWeapon || !g_msgReflexFov)) {if(caller) Chat(caller,"Refleks SPR dosyaları eksik. Yeni sprites dosyalarını yükleyip haritayı değiştir.");return 0;}
    StopAllFormations();BeginSession(game,caller);
    new success=1;
    if(game==CT_GAME_HOGWARTS) success=hogwarts_start(caller);
    else if(game==CT_GAME_MILYONER) success=milyoner_start(caller);
    else InitInternalGame();
    if(!success) {StopCTGame(0,CT_STOP_EMPTY);if(caller) Chat(caller,"Oyun başlayamadı; değiştirilen ayarlar geri alındı.");return 0;}
    set_task(game==CT_GAME_REFLEX?0.1:0.25,"GameTick",TASK_GAME,"",0,"b");
    AnnounceSession(caller);return 1;
}

AnnounceSession(caller) {
    if(!g_game || g_announced) return;
    switch(g_game) {
        case CT_GAME_KNIFE:PlayCTSound(SND_KNIFE);
        case CT_GAME_HOGWARTS:PlayCTSound(SND_HOGWARTS);
        case CT_GAME_HOT_POTATO:PlayCTSound(SND_POTATO);
        case CT_GAME_GUN,CT_GAME_DEAGLE,CT_GAME_SHOTGUN,CT_GAME_SNIPER:PlayCTSound(SND_GUN);
        case CT_GAME_SPARTA:PlayCTSound(SND_SPARTA);
        case CT_GAME_BURY_JUMP:PlayCTSound(SND_TRAP);
        case CT_GAME_FREEZE_CHANCE:PlayCTSound(SND_FREEZE);
        default:PlayCTSound(SND_NOTICE);
    }
    g_announced=true;new ret;ExecuteForward(g_fwStarted,ret,caller,_:g_game,CountEntrants());
    Chat(0,"^4%s ^1başladı. ^3%d mahkûm ^1katılıyor.",GAME_NAMES[_:g_game],CountEntrants());
}

StopCTGame(winner,CTStopReason:reason) {
    if(g_game==CT_GAME_NONE || g_stopping) return 0;
    g_stopping=true;g_reflexStarting=false;new CTGame:ended=g_game;
    arrayset(g_reflexLanding,false,sizeof g_reflexLanding);
    remove_task(TASK_GAME);remove_task(TASK_CHECK);
    if(ended==CT_GAME_HOGWARTS && ExternalReady(ended) && hogwarts_state()) hogwarts_stop(0);
    if(ended==CT_GAME_MILYONER && ExternalReady(ended) && milyoner_active()) milyoner_stop(0);
    RemoveCrates();
    for(new id=1;id<=MaxClients;id++) ClearReflexSprite(id);
    for(new id=1;id<=MaxClients;id++) if(is_user_connected(id)) FC_SendPanelHud(id,"",235,235,235,0.03,0.16,1,0.1);
    // Clear the active game before reset-speed hooks are called by restoration.
    g_game=CT_GAME_NONE;
    for(new id=1;id<=MaxClients;id++) {
        C4Lift(id);g_part[id]=false;g_partUID[id]=0;g_color[id]=0;
        RestoreState(id,SNAP_GAME,true);
        if(is_user_connected(id)) {
            if(ended==CT_GAME_BLIND || ended==CT_GAME_INFECTION) ClearBlind(id);
            ApplyCTPerks(id);
        }
    }
    RestoreCvars();
    g_gameBoss=0;g_gameBossUID=0;g_tronCount=0;g_tronHead=-1;g_sumoRadius=0.0;
    new ret;ExecuteForward(g_fwFinished,ret,_:ended,winner,_:reason);
    g_stopping=false;g_bomb=0;
    if(reason==CT_STOP_WIN && winner>0 && is_user_connected(winner)) {
        Chat(0,"^4%s ^1kazananı: ^3%n^1. Tebrikler!",GAME_NAMES[_:ended],winner);
        if(g_cfg[CFG_WIN_TL]>0 && LibraryExists("feliciaclan_jbmenu",LibType_Library)) fc_add_tl(winner,g_cfg[CFG_WIN_TL]);
    }
    else if(reason==CT_STOP_TIME) Chat(0,"^4%s ^1süresi doldu. Kalan oyuncular kazandı.",GAME_NAMES[_:ended]);
    else if(reason==CT_STOP_MENU) Chat(0,"^4%s ^1durduruldu. Ayarlar geri alındı.",GAME_NAMES[_:ended]);
    return 1;
}

DropEntrant(id,bool:restore) {
    if(id<1 || id>MaxClients) return;
    if(restore) RestoreState(id,SNAP_GAME,false);else g_snap[SNAP_GAME][id][SS_VALID]=0;
    g_part[id]=false;g_color[id]=0;
}

CountEntrants() {new n;for(new id=1;id<=MaxClients;id++) if(IsEntrant(id)) n++;return n;}

RandomEntrant(except=0) {
    new list[MAXP],n;for(new id=1;id<=MaxClients;id++) if(IsEntrant(id) && id!=except) list[n++]=id;
    return n?list[random_num(0,n-1)]:0;
}

Eliminate(id,const reason[]) {
    if(!IsEntrant(id)) return;
    Chat(0,"^3%n ^1elendi: ^4%s",id,reason);g_part[id]=false;GameFreeze(id,false);ClearGlow(id);ClearBlind(id);
    user_kill(id,1);ScheduleWinnerCheck();
}

ScheduleWinnerCheck() {if(g_game && !task_exists(TASK_CHECK)) set_task(0.1,"CheckWinner",TASK_CHECK);}

public CheckWinner() {
    if(!g_game || g_stopping) return;
    if(!HasCT()) {
        if(CTBattle()) {Chat(0,"Mahkûmlar kazandı!");StopCTGame(0,CT_STOP_WIN);}
        else {StopCTGame(0,CT_STOP_EMPTY);}
        return;
    }
    if(g_game==CT_GAME_HOGWARTS || g_game==CT_GAME_MILYONER) return;
    new alive,last,reds,blues;
    for(new id=1;id<=MaxClients;id++) if(IsEntrant(id)) {alive++;last=id;if(g_color[id]==1) reds++;else if(g_color[id]==2) blues++;}
    if(!alive) {
        if(CTBattle()) {Chat(0,"Gardiyanlar kazandı!");StopCTGame(0,CT_STOP_WIN);}
        else {StopCTGame(0,CT_STOP_EMPTY);}
        return;
    }
    if(CTBattle()) {return;}
    if(alive==1) {StopCTGame(last,CT_STOP_WIN);return;}
    if(g_game==CT_GAME_TEAMS && (!reds || !blues)) {Chat(0,"^4%s takım ^1Takım Savaşı'nı kazandı.",reds?"Kırmızı":"Mavi");StopCTGame(0,CT_STOP_WIN);}
    // Infection keeps draining HP even if everyone is infected; last prisoner wins.
}

public OnRound() {roundStart();}

public OnSpawn(id) {
    // Spawn has already established a new life: discard the previous flight's
    // snapshot without restoring its weapons or teleporting to its launch spot.
    CancelLoadout(id);g_spawnLife[id]++;
    g_snap[SNAP_GAME][id][SS_VALID]=0;g_part[id]=false;g_partUID[id]=0;
    g_reflexLanding[id]=false;g_color[id]=0;
    RocketDrop(id,false);
    g_protectionVoterUID[id]=0;
    g_c4CountdownTargets[id]=0;
    ClearReflexSprite(id,false);g_buriedUID[id]=0;g_buryFull[id]=false;g_buryUntil[id]=0.0;
    if(!is_user_alive(id)) return;
    g_snap[SNAP_TOOL][id][SS_VALID]=0;g_toolFrozen[id]=false;
    if(AliveCT(id)) {
        GiveCTLoadout(id,true);QueueLoadout(id);
        set_entvar(id,var_health,float(g_cfg[CFG_CT_HP]));set_entvar(id,var_armorvalue,float(g_cfg[CFG_CT_ARMOR]));
        if(g_game && GAME_GOD[_:g_game]) {
            if(g_game==CT_GAME_HOMELANDER && id!=g_gameBoss) set_entvar(id,var_takedamage,DAMAGE_AIM);
            else {SaveState(id,SNAP_GAME);set_entvar(id,var_takedamage,DAMAGE_NO);set_entvar(id,var_health,10000.0);}
        }
        else if(CTBattle()) {SaveState(id,SNAP_GAME);SetupBattleCT(id);}
        else {ApplyCTPerks(id);ApplyRoundGod(id);}
    }
    playerSpawn(id);
    if(AliveCT(id)) {
        if(!g_godMode && !g_game) {set_entvar(id,var_health,cvar[0]);set_entvar(id,var_armorvalue,cvar[1]);}
        BridgeQueueSpawnMenu(id);
    }
    if(g_reflexStarting) GameFreeze(id,true);
    if(g_hard) {g_hardUID[id]=get_user_userid(id);g_hardTeam[id]=_:get_member(id,m_iTeam);get_entvar(id,var_gravity,g_hardGravity[id]);get_entvar(id,var_maxspeed,g_hardSpeed[id]);set_entvar(id,var_gravity,1.0);rg_reset_maxspeed(id);}
    if(g_rocketActive) {if(AliveCT(id)) RocketGuard(id);else if(AliveT(id) && !g_rocketPhase) RocketJoin(id,true);}
}

public OnTeam() {
    new id=read_data(1);if(id<1 || id>MaxClients || !is_user_connected(id)) return;
    if(id==g_protectionActor && !AliveCT(id)) CancelProtectionVote();
    if(!AliveT(id)) {g_protectionVoterUID[id]=0;if(g_game==CT_GAME_INFECTION) ClearBlind(id);}
    if(id==g_c4CountdownActor && !AliveCT(id)) CancelC4Countdown();
    if(!AliveT(id)) g_c4CountdownTargets[id]=0;
    if(!AliveT(id)) C4Lift(id);
    ClearReflexSprite(id);
    if(g_part[id] && !AliveT(id)) {DropEntrant(id,true);ScheduleWinnerCheck();}
    if(g_snap[SNAP_TOOL][id][SS_VALID] && _:get_member(id,m_iTeam)!=g_snap[SNAP_TOOL][id][SS_TEAM]) RestoreState(id,SNAP_TOOL,false);
    if(g_snap[SNAP_GAME][id][SS_VALID] && _:get_member(id,m_iTeam)!=g_snap[SNAP_GAME][id][SS_TEAM]) RestoreState(id,SNAP_GAME,false);
    if(!AliveCT(id)) {StopFormation(id);g_requestedAction[id]=0;g_input[id]=0;if(g_warden==id) g_warden=0;if(g_standaloneHud[id]) {FC_ClearInfoHud(id);g_standaloneHud[id]=false;}}
    else if(!g_game) {ApplyCTPerks(id);ApplyRoundGod(id);}
    if(g_rocketActive) {
        if(g_snap[SNAP_ROCKET][id][SS_VALID] && _:get_member(id,m_iTeam)!=g_snap[SNAP_ROCKET][id][SS_TEAM]) RocketDrop(id);
        if(AliveCT(id)) RocketGuard(id);
    }
}

public OnKilled(victim,killer,gib) {
    RocketDrop(victim);
    if(victim==g_protectionActor) CancelProtectionVote();g_protectionVoterUID[victim]=0;
    if(g_game==CT_GAME_INFECTION) ClearBlind(victim);
    if(victim==g_c4CountdownActor) CancelC4Countdown();
    g_c4CountdownTargets[victim]=0;
    ClearReflexSprite(victim);g_buriedUID[victim]=0;g_buryFull[victim]=false;g_buryUntil[victim]=0.0;
    StopFormation(victim);
    if(victim>=1 && victim<=MaxClients && get_member(victim,m_iTeam)==TEAM_TERRORIST) {g_lastDead=victim;g_lastDeadUID=get_user_userid(victim);}
    if(g_warden==victim) g_warden=0;
    if(!g_game && AliveCT(killer) && killer!=victim && get_member(victim,m_iTeam)==TEAM_TERRORIST && !UsingJBWallet(killer)) {g_localTL[killer]+=g_cfg[CFG_LOCAL_KILL];SaveWallet(killer);}
    ScheduleWinnerCheck();
}

public OnDamage(victim,inflictor,attacker,Float:damage,bits) {
    if(victim>=1 && victim<=MaxClients && AliveCT(victim) && (bits&DMG_FALL)) {SetHookChainReturn(ATYPE_INTEGER,0);return HC_SUPERCEDE;}
    if(g_rocketActive && AliveCT(victim)) {SetHookChainReturn(ATYPE_INTEGER,0);return HC_SUPERCEDE;}
    if(!g_game || g_game==CT_GAME_HOGWARTS || victim<1 || victim>MaxClients) return HC_CONTINUE;
    if(AliveCT(victim) && GAME_GOD[_:g_game] && (g_game!=CT_GAME_HOMELANDER || victim==g_gameBoss)) {SetHookChainReturn(ATYPE_INTEGER,0);return HC_SUPERCEDE;}
    if(g_game==CT_GAME_DODGEBALL) {SetHookChainReturn(ATYPE_INTEGER,0);return HC_SUPERCEDE;}
    if(!IsEntrant(victim)) return HC_CONTINUE;
    if(g_game==CT_GAME_TRON) {SetHookChainReturn(ATYPE_INTEGER,0);return HC_SUPERCEDE;}
    if(g_game==CT_GAME_SUMO) {
        if(IsEntrant(attacker) && attacker!=victim) SumoKnockback(attacker,victim);
        SetHookChainReturn(ATYPE_INTEGER,0);return HC_SUPERCEDE;
    }
    if(g_game==CT_GAME_MILYONER || g_game==CT_GAME_RED_LIGHT || g_game==CT_GAME_HOT_POTATO || g_game==CT_GAME_REFLEX || g_game==CT_GAME_NUMBER || g_game==CT_GAME_INFECTION || g_game==CT_GAME_PENDULUM || g_game==CT_GAME_FREEZE_CHANCE || g_game==CT_GAME_COLOR_LUCK || g_game==CT_GAME_BURY_JUMP) {
        if(g_game==CT_GAME_HOT_POTATO && attacker==g_bomb && IsEntrant(attacker) && attacker!=victim) PassBomb(victim);
        SetHookChainReturn(ATYPE_INTEGER,0);return HC_SUPERCEDE;
    }
    if(g_game==CT_GAME_BLIND && (!IsEntrant(attacker) || attacker!=g_bomb || g_phase==0)) {SetHookChainReturn(ATYPE_INTEGER,0);return HC_SUPERCEDE;}
    if(g_game==CT_GAME_TEAMS && IsEntrant(attacker) && attacker!=victim && g_color[victim]==g_color[attacker]) {SetHookChainReturn(ATYPE_INTEGER,0);return HC_SUPERCEDE;}
    return HC_CONTINUE;
}

public OnSpeed(id) {
    if(g_bridgeLegacy || (id>=1 && id<=MaxClients && g_hiz[id])) return;
    if(LibraryExists("fc_lr",LibType_Library) && fc_lr_is_player(id)) return;
    if(!is_user_alive(id)) return;
    if(g_game==CT_GAME_TRON && IsEntrant(id)) {set_entvar(id,var_maxspeed,400.0);return;}
    if(RocketTarget(id) && g_rocketPhase) set_entvar(id,var_maxspeed,0.01);
    else if(!g_game && !g_hard && AliveCT(id) && g_perk[id][4]) set_entvar(id,var_maxspeed,320.0);
}

public OnPickup(id,item) {
    if(RocketTarget(id)) {
        new WeaponIdType:weapon=get_member(item,m_iId);
        if(weapon==WEAPON_KNIFE || weapon==WEAPON_TMP) return HC_CONTINUE;
        SetHookChainReturn(ATYPE_INTEGER,0);return HC_SUPERCEDE;
    }
    if(IsEntrant(id) && g_game!=CT_GAME_HOGWARTS && g_game!=CT_GAME_MILYONER && get_member(item,m_iId)!=WEAPON_KNIFE && (g_game==CT_GAME_KNIFE || g_game==CT_GAME_REVERSE || g_game==CT_GAME_SUMO || (g_game==CT_GAME_ZOMBIE || g_game==CT_GAME_SPARTA) || !CombatGame())) {SetHookChainReturn(ATYPE_INTEGER,0);return HC_SUPERCEDE;}
    return HC_CONTINUE;
}

public OnDrop(id,const name[]) {
    if(RocketTarget(id)) {SetHookChainReturn(ATYPE_INTEGER,0);return HC_SUPERCEDE;}
    if(IsEntrant(id) && g_game!=CT_GAME_HOGWARTS && g_game!=CT_GAME_MILYONER) {SetHookChainReturn(ATYPE_INTEGER,0);return HC_SUPERCEDE;}
    return HC_CONTINUE;
}

public hogwarts_prepare(caller,players) {
    if(!g_game && !g_stopping) {BeginSession(CT_GAME_HOGWARTS,caller);set_task(0.25,"GameTick",TASK_GAME,"",0,"b");}
}

public hogwarts_finished(winner,reason) {
    if(g_game==CT_GAME_HOGWARTS && !g_stopping) StopCTGame(0,reason==1?CT_STOP_WIN:CT_STOP_MENU);
}

public hogwarts_started(caller,players) {if(g_game==CT_GAME_HOGWARTS) AnnounceSession(caller);}

public milyoner_prepare(caller,players) {
    if(!g_game && !g_stopping) {BeginSession(CT_GAME_MILYONER,caller);set_task(0.25,"GameTick",TASK_GAME,"",0,"b");}
}

public milyoner_finished(winner,reason) {
    if(g_game==CT_GAME_MILYONER && !g_stopping) StopCTGame(winner,reason==1?CT_STOP_WIN:CT_STOP_MENU);
}

public milyoner_started(caller,players) {if(g_game==CT_GAME_MILYONER) AnnounceSession(caller);}

InitInternalGame() {
    switch(g_game) {
        case CT_GAME_KNIFE: {for(new id=1;id<=MaxClients;id++) if(IsEntrant(id)) {engclient_cmd(id,"weapon_knife");set_entvar(id,var_viewmodel,FISTS_MODEL);set_entvar(id,var_weaponmodel,"");}}
        case CT_GAME_GUN,CT_GAME_TEAMS: {
            new list[MAXP],n;for(new id=1;id<=MaxClients;id++) if(IsEntrant(id)) list[n++]=id;
            for(new i=n-1;i>0;i--) {new j=random_num(0,i),tmp=list[i];list[i]=list[j];list[j]=tmp;}
            for(new i=0;i<n;i++) {
                new id=list[i];GiveGun(id,0);
                if(g_game==CT_GAME_TEAMS) {g_color[id]=i%2+1;Glow(id,g_color[id]==1?230:70,60,g_color[id]==1?65:255);}
            }
        }
        case CT_GAME_INFECTION: {
            new infected=RandomEntrant();
            for(new id=1;id<=MaxClients;id++) if(IsEntrant(id)) g_color[id]=2;
            g_bomb=infected;g_phase=1;g_graceEnd=get_gametime();InfectPlayer(infected);
        }
        case CT_GAME_RED_LIGHT: {g_phase=0;g_phaseEnd=get_gametime()+float(random_num(g_cfg[CFG_GREEN_MIN],g_cfg[CFG_GREEN_MAX]));}
        case CT_GAME_HOT_POTATO: {g_lastPotatoSecond=-1;g_phaseEnd=get_gametime()+float(g_cfg[CFG_BOMB_SECONDS]);PassBomb(RandomEntrant());}
        case CT_GAME_REFLEX: {g_phase=0;g_reflexFake=false;g_reflexStarting=true;g_reflexStartEnd=get_gametime()+3.0;g_reflexStartSecond=-1;for(new id=1;id<=MaxClients;id++) if(is_user_alive(id)) GameFreeze(id,true);TickReflexStart(get_gametime());}
        case CT_GAME_NUMBER: {g_secret=random_num(1,100);Chat(0,"Sohbete ^3 1-100 ^1arasında sayı yaz. Büyük/küçük ipucu yalnız sana gösterilir.");}
        case CT_GAME_BLIND: {
            g_bomb=RandomEntrant();g_phase=0;g_phaseEnd=get_gametime()+5.0;
            GameFreeze(g_bomb,true);Blind(g_bomb);Glow(g_bomb,200,70,250);set_entvar(g_bomb,var_health,300.0);
            if(g_cvarFF) set_pcvar_num(g_cvarFF,1);if(g_cvarFFA) set_pcvar_num(g_cvarFFA,1);
            Chat(0,"Ebe ^3%n^1. Saklanmak için ^4 5 saniyeniz ^1var!",g_bomb);
        }
        case CT_GAME_BIRD: {
            for(new id=1;id<=MaxClients;id++) {
                if(IsEntrant(id)) {set_entvar(id,var_gravity,0.30);Glow(id,220,65,70);}
                else if(AliveCT(id)) GiveGun(id,4);
            }
        }
        case CT_GAME_ZOMBIE,CT_GAME_GHOST,CT_GAME_AREF,CT_GAME_SPARTA: InitCTBattle();
        case CT_GAME_PENDULUM: {g_phaseEnd=get_gametime()+3.0;g_phase=0;}
        case CT_GAME_FREEZE_CHANCE,CT_GAME_COLOR_LUCK: {g_phase=0;g_phaseEnd=get_gametime()+4.0;}
        case CT_GAME_BURY_JUMP: {g_phase=0;g_phaseEnd=get_gametime()+3.0;for(new id=1;id<=MaxClients;id++) if(IsEntrant(id)) {g_ready[id]=false;C4Bury(id,false,0.0);Glow(id,235,75,60);}}
        case CT_GAME_LOW_GRAVITY,CT_GAME_ONE_HP,CT_GAME_DEAGLE,CT_GAME_SHOTGUN,CT_GAME_SNIPER: {
            for(new id=1;id<=MaxClients;id++) if(IsEntrant(id)) {
                GiveGun(id,g_game==CT_GAME_LOW_GRAVITY?2:g_game==CT_GAME_SHOTGUN?5:g_game==CT_GAME_SNIPER?4:7);
                if(g_game==CT_GAME_ONE_HP) set_entvar(id,var_health,1.0);
                if(g_game==CT_GAME_LOW_GRAVITY) set_entvar(id,var_gravity,0.35);
            }
        }
        case CT_GAME_HUNGER: InitHunger();
        case CT_GAME_HOMELANDER: {
            if(AliveCT(g_gameBoss)) {
                set_entvar(g_gameBoss,var_health,10000.0);
                set_entvar(g_gameBoss,var_armorvalue,1000.0);
                set_entvar(g_gameBoss,var_takedamage,DAMAGE_NO);
                rg_remove_all_items(g_gameBoss);rg_give_item(g_gameBoss,"weapon_knife");
                Chat(0,"^3%n ^1Homelander oldu! Nişangâhına basılı tutarak lazer gönder.",g_gameBoss);
            }
        }
        case CT_GAME_TRON: {
            for(new id=1;id<=MaxClients;id++) if(IsEntrant(id)) {
                g_color[id]=random_num(1,6);
                new rr,gg,bb;TronColor(id,rr,gg,bb);Glow(id,rr,gg,bb);
                get_entvar(id,var_origin,g_tronLast[id]);set_entvar(id,var_maxspeed,400.0);
                rg_remove_all_items(id);rg_give_item(id,"weapon_knife");
            }
            Chat(0,"Mahkûmlar 400 hızla koşun! Başka oyuncunun renkli izine dokunmak elenmenize neden olur.");
        }
        case CT_GAME_MAGNETIC: {
            if(AliveCT(g_gameBoss)) {
                Glow(g_gameBoss,28,28,38);
                Chat(0,"^3%n ^1Karadelik oldu! Görüş hattındaki mahkûmlar çekilecek; duvarlar korur.",g_gameBoss);
            }
        }
        case CT_GAME_SUMO: InitSumoArena();
        case CT_GAME_DODGEBALL: {
            for(new id=1;id<=MaxClients;id++) if(IsEntrant(id)) {
                rg_remove_all_items(id);rg_give_item(id,"weapon_hegrenade");
                rg_set_user_bpammo(id,WEAPON_HEGRENADE,1);engclient_cmd(id,"weapon_hegrenade");
            }
            Chat(0,"Yakan Top başladı! Yalnızca mahkûmlar bomba kullanır. Patlama hasarsız; doğrudan isabet eler.");
        }
    }
}

public GameTick() {
    if(!g_game || g_stopping) return;
    if(!HasCT()) {CheckWinner();return;}
    if((g_game==CT_GAME_HOMELANDER || g_game==CT_GAME_MAGNETIC) && (!AliveCT(g_gameBoss) || get_user_userid(g_gameBoss)!=g_gameBossUID)) {StopCTGame(0,CT_STOP_EMPTY);return;}
    if(g_game==CT_GAME_HOGWARTS) {if(!ExternalReady(g_game) || !hogwarts_state()) StopCTGame(0,CT_STOP_EMPTY);return;}
    if(g_game==CT_GAME_MILYONER) {if(!ExternalReady(g_game) || !milyoner_active()) StopCTGame(0,CT_STOP_EMPTY);return;}
    new Float:now=get_gametime();
    for(new id=1;id<=MaxClients;id++) if(g_part[id] && !IsEntrant(id)) DropEntrant(id,false);
    CheckWinner();if(!g_game) return;
    if(now>=g_gameEnd) {StopCTGame(0,CT_STOP_TIME);return;}
    if(g_game==CT_GAME_REFLEX && g_reflexStarting) {TickReflexStart(now);return;}
    switch(g_game) {
        case CT_GAME_INFECTION: TickInfection(now);
        case CT_GAME_RED_LIGHT: TickRedLight(now);
        case CT_GAME_PENDULUM: TickPendulum(now);
        case CT_GAME_FREEZE_CHANCE,CT_GAME_COLOR_LUCK: TickFreezeChance(now);
        case CT_GAME_BURY_JUMP: TickBuryJump(now);
        case CT_GAME_HOT_POTATO: {
            if(!IsEntrant(g_bomb)) PassBomb(RandomEntrant());
            new seconds=max(0,floatround(g_phaseEnd-now,floatround_ceil));
            if(seconds!=g_lastPotatoSecond) {g_lastPotatoSecond=seconds;if(seconds>0 && seconds<=5) PlayCTSound(SND_POTATO_TICK);}
            if(now>=g_phaseEnd) {
                PlayCTSound(SND_POTATO_END);
                new holder=g_bomb;if(IsEntrant(holder)) Eliminate(holder,"Bomba üzerinde patladı");
                g_bomb=0;g_phaseEnd=now+float(g_cfg[CFG_BOMB_SECONDS]);
                if(CountEntrants()>1) PassBomb(RandomEntrant());
            }
        }
        case CT_GAME_REFLEX: {if(g_reflexStarting) TickReflexStart(now);else TickReflex(now);}
        case CT_GAME_BLIND: {
            if(!IsEntrant(g_bomb)) {StopCTGame(0,CT_STOP_EMPTY);return;}
            if(g_phase==0 && now>=g_phaseEnd) {g_phase=1;GameFreeze(g_bomb,false);ClearBlind(g_bomb);Chat(0,"Körebe başladı! ^3%n ^1mahkûmları arıyor.",g_bomb);}
        }
        case CT_GAME_TRON: TickTron(now);
        case CT_GAME_MAGNETIC: TickMagnetic(now);
        case CT_GAME_SUMO: TickSumoArena(now);
        case CT_GAME_DODGEBALL: TickDodgeball();
    }
    if(g_game==CT_GAME_HOT_POTATO || (g_game==CT_GAME_INFECTION && g_phase)) CheckNearbyContacts();
    if(now>=g_nextSecond) {
        g_nextSecond=now+1.0;
        if(g_game==CT_GAME_HUNGER) TickHunger(now);
        if(g_game) DrawGameHud();
    }
}

TickRedLight(Float:now) {
    if(now>=g_phaseEnd) {
        g_phase=1-g_phase;
        g_phaseEnd=now+float(g_phase?random_num(g_cfg[CFG_RED_MIN],g_cfg[CFG_RED_MAX]):random_num(g_cfg[CFG_GREEN_MIN],g_cfg[CFG_GREEN_MAX]));
        g_graceEnd=now+float(g_cfg[CFG_RED_GRACE])/1000.0;
        for(new id=1;id<=MaxClients;id++) if(IsEntrant(id)) get_entvar(id,var_origin,g_anchor[id]);
        DrawGameHud();
    }
    if(!g_phase) return;
    for(new id=1;id<=MaxClients;id++) if(IsEntrant(id)) {
        new Float:origin[3];get_entvar(id,var_origin,origin);
        if(now<=g_graceEnd) {for(new j=0;j<3;j++) g_anchor[id][j]=origin[j];continue;}
        if(vector_distance(origin,g_anchor[id])>4.0) Eliminate(id,"Kırmızı ışıkta hareket etti");
    }
}

public OnCmdStart(id,uc,seed) {
    if(id<1 || id>MaxClients || !is_user_alive(id)) return FMRES_IGNORED;
    new buttons=get_uc(uc,UC_Buttons),rising=buttons&~g_prevButtons[id];
    g_prevButtons[id]=buttons;
    if(AliveCT(id) && (rising&IN_ATTACK2) && !g_game && !g_rocketActive)
        CTPlacePing(id);
    if(!g_game && !g_hard && !g_rocketActive && !g_buriedUID[id]) return FMRES_IGNORED;
    // Normal C4 burial does not alter jump input or bunny velocity. The old
    // jump-key C4Lift shortcut is absent; only explicit CT controls release it.
    if(g_reflexStarting) {set_uc(uc,UC_Buttons,0);set_uc(uc,UC_ForwardMove,0.0);set_uc(uc,UC_SideMove,0.0);return FMRES_IGNORED;}
    if(RocketTarget(id) && g_rocketPhase) {set_uc(uc,UC_ForwardMove,0.0);set_uc(uc,UC_SideMove,0.0);buttons&=~(IN_ATTACK|IN_ATTACK2|IN_JUMP);set_uc(uc,UC_Buttons,buttons);}
    if(g_hard && AliveT(id)) {
        // A held jump key cannot generate auto-bunny; fresh ordinary jumps remain.
        if((buttons&IN_JUMP) && !(rising&IN_JUMP)) {buttons&=~IN_JUMP;set_uc(uc,UC_Buttons,buttons);}
    }
    if(g_game==CT_GAME_HOMELANDER && id==g_gameBoss) {
        if((buttons&IN_ATTACK) && get_gametime()>=g_nextLaser) {g_nextLaser=get_gametime()+0.30;HomelanderFire(id);}
        buttons&=~(IN_ATTACK|IN_ATTACK2);set_uc(uc,UC_Buttons,buttons);
        return FMRES_IGNORED;
    }
    if(g_game==CT_GAME_DODGEBALL && IsEntrant(id) && get_user_weapon(id)!=CSW_HEGRENADE) {
        buttons&=~(IN_ATTACK|IN_ATTACK2);set_uc(uc,UC_Buttons,buttons);
    }
    if(!IsEntrant(id)) return FMRES_IGNORED;
    if(g_game==CT_GAME_REVERSE) {
        new Float:forwardMove,Float:sideMove;
        get_uc(uc,UC_ForwardMove,forwardMove);get_uc(uc,UC_SideMove,sideMove);
        set_uc(uc,UC_ForwardMove,forwardMove*-1.0);set_uc(uc,UC_SideMove,sideMove*-1.0);
    }
    if(g_game==CT_GAME_BURY_JUMP && !g_phase && (rising&IN_JUMP)) {g_ready[id]=true;C4Lift(id);ClearGlow(id);}
    if(g_game==CT_GAME_REFLEX && g_phase==1) ReflexInput(id,uc,buttons,rising);
    if(g_game==CT_GAME_RED_LIGHT || g_game==CT_GAME_REFLEX || g_game==CT_GAME_NUMBER || g_game==CT_GAME_INFECTION || g_game==CT_GAME_FREEZE_CHANCE || g_game==CT_GAME_COLOR_LUCK || g_game==CT_GAME_BURY_JUMP || g_game==CT_GAME_PENDULUM) {
        buttons&=~(IN_ATTACK|IN_ATTACK2);set_uc(uc,UC_Buttons,buttons);
    }
    return FMRES_IGNORED;
}

public OnTouchPlayers(a,b) {
    if(a==b) return;
    if(g_game==CT_GAME_MAGNETIC) {
        if(a==g_gameBoss && IsEntrant(b)) {Eliminate(b,"Karadeliğin merkezine dokundu");return;}
        if(b==g_gameBoss && IsEntrant(a)) {Eliminate(a,"Karadeliğin merkezine dokundu");return;}
    }
    if(!IsEntrant(a) || !IsEntrant(b)) return;
    if(g_game==CT_GAME_HOT_POTATO) {if(a==g_bomb) PassBomb(b);else if(b==g_bomb) PassBomb(a);}
    else if(g_game==CT_GAME_INFECTION) {
        if(get_gametime()<g_graceEnd) return;
        new target=g_color[a]==1 && g_color[b]==2?b:(g_color[b]==1 && g_color[a]==2?a:0);
        if(target && get_gametime()>=g_touchNext[target]) {
            g_touchNext[target]=get_gametime()+0.75;InfectPlayer(target);ScheduleWinnerCheck();
        }
    }
}

CheckNearbyContacts() {
    // Semiclip servers may suppress engine player touches. Read each origin
    // once per 250 ms and use a small contact distance, with no idle timer.
    new players[MAXP],n,Float:positions[MAXP][3];
    for(new id=1;id<=MaxClients;id++) if(IsEntrant(id)) {players[n]=id;get_entvar(id,var_origin,positions[n]);n++;}
    for(new a=0;a<n;a++) for(new b=a+1;b<n;b++) {
        if(g_game==CT_GAME_HOT_POTATO && players[a]!=g_bomb && players[b]!=g_bomb) continue;
        if(g_game==CT_GAME_INFECTION && g_color[players[a]]==g_color[players[b]]) continue;
        new Float:dx=positions[a][0]-positions[b][0],Float:dy=positions[a][1]-positions[b][1],Float:dz=positions[a][2]-positions[b][2];
        if(g_game==CT_GAME_INFECTION) {if(dx*dx+dy*dy+dz*dz<1600.0) OnTouchPlayers(players[a],players[b]);}
        else if(g_game==CT_GAME_SUMO) {if(dx*dx+dy*dy<2500.0 && floatabs(dz)<=56.0) OnTouchPlayers(players[a],players[b]);}
        else if(dx*dx+dy*dy<=1296.0 && floatabs(dz)<=56.0) OnTouchPlayers(players[a],players[b]);
    }
}


/* === Yeni CT oyunları === */
stock bool:GameBossValid() {
    return g_gameBoss>=1 && g_gameBoss<=MaxClients && is_user_connected(g_gameBoss)
        && get_user_userid(g_gameBoss)==g_gameBossUID && AliveCT(g_gameBoss);
}
stock DrawBeamLine(const Float:start[3],const Float:end[3],width,r,g,b,life) {
    if(!g_beam) return;
    message_begin(MSG_BROADCAST,SVC_TEMPENTITY);write_byte(TE_BEAMPOINTS);
    write_coord(floatround(start[0]));write_coord(floatround(start[1]));write_coord(floatround(start[2]));
    write_coord(floatround(end[0]));write_coord(floatround(end[1]));write_coord(floatround(end[2]));
    write_short(g_beam);write_byte(0);write_byte(10);write_byte(life);write_byte(width);write_byte(0);
    write_byte(r);write_byte(g);write_byte(b);write_byte(220);write_byte(0);message_end();
}
stock HomelanderFire(id) {
    if(!GameBossValid() || id!=g_gameBoss) return;
    new start[3],finish[3],target,body;get_user_origin(id,start,1);get_user_origin(id,finish,3);
    new Float:a[3],Float:b[3];for(new i=0;i<3;i++){a[i]=float(start[i]);b[i]=float(finish[i]);}
    DrawBeamLine(a,b,24,255,35,20,5);get_user_aiming(id,target,body,8192);
    if(IsEntrant(target)) Eliminate(target,"Homelander lazerine yakalandı");
}
stock TronColor(id,&r,&g,&b) {
    switch(g_color[id]) {
        case 1:{r=255;g=45;b=45;} case 2:{r=45;g=105;b=255;}
        case 3:{r=45;g=255;b=90;} case 4:{r=255;g=220;b=45;}
        case 5:{r=230;g=45;b=255;} default:{r=35;g=235;b=255;}
    }
}
stock Float:PointSegmentDistanceSq(const Float:p[3],const Float:a[3],const Float:b[3]) {
    new Float:vx=b[0]-a[0],Float:vy=b[1]-a[1],Float:vz=b[2]-a[2];
    new Float:wx=p[0]-a[0],Float:wy=p[1]-a[1],Float:wz=p[2]-a[2];
    new Float:len=vx*vx+vy*vy+vz*vz;
    new Float:t=0.0;
    if(len>0.001) t=(wx*vx+wy*vy+wz*vz)/len;
    t=floatmax(0.0,floatmin(1.0,t));
    new Float:dx=p[0]-(a[0]+t*vx),Float:dy=p[1]-(a[1]+t*vy),Float:dz=p[2]-(a[2]+t*vz);
    return dx*dx+dy*dy+dz*dz;
}
stock AddTronSegment(id,const Float:from[3],const Float:to[3],Float:now) {
    g_tronHead=(g_tronHead+1)%TRON_MAX_SEGMENTS;new idx=g_tronHead;
    if(g_tronCount<TRON_MAX_SEGMENTS) g_tronCount++;
    g_tronOwner[idx]=id;g_tronOwnerUID[idx]=get_user_userid(id);g_tronTime[idx]=now;
    for(new i=0;i<3;i++){g_tronStart[idx][i]=from[i];g_tronEnd[idx][i]=to[i];}
    new r,g,b;TronColor(id,r,g,b);DrawBeamLine(from,to,8,r,g,b,65);
}
stock TickTron(Float:now) {
    new Float:pos[MAXP+1][3];
    for(new id=1;id<=MaxClients;id++) if(IsEntrant(id)) {
        set_entvar(id,var_maxspeed,400.0);get_entvar(id,var_origin,pos[id]);
        new Float:dx=pos[id][0]-g_tronLast[id][0],Float:dy=pos[id][1]-g_tronLast[id][1],Float:dz=pos[id][2]-g_tronLast[id][2];
        if(dx*dx+dy*dy+dz*dz>=324.0) {AddTronSegment(id,g_tronLast[id],pos[id],now);for(new j=0;j<3;j++)g_tronLast[id][j]=pos[id][j];}
    }
    for(new id=1;id<=MaxClients;id++) if(IsEntrant(id)) {
        for(new step=0;step<g_tronCount;step++) {
            new idx=g_tronHead-step;if(idx<0)idx+=TRON_MAX_SEGMENTS;
            if(now-g_tronTime[idx]>8.0) continue;
            if(g_tronOwner[idx]==id && g_tronOwnerUID[idx]==get_user_userid(id)) continue;
            if(PointSegmentDistanceSq(pos[id],g_tronStart[idx],g_tronEnd[idx])<=576.0) {Eliminate(id,"Başka bir oyuncunun zehirli Tron izine değdi");break;}
        }
    }
}
stock bool:MagnetLineClear(const Float:start[3],const Float:finish[3]) {
    new tr=create_tr2();engfunc(EngFunc_TraceLine,start,finish,IGNORE_MONSTERS,0,tr);
    new Float:fraction;get_tr2(tr,TR_flFraction,fraction);free_tr2(tr);return fraction>=0.98;
}
stock DrawMagnetRing(id) {
    if(!GameBossValid() || id!=g_gameBoss) return;
    new Float:center[3];get_entvar(id,var_origin,center);center[2]+=24.0;
    new Float:prev[3],Float:next[3];
    for(new i=0;i<24;i++) {
        new Float:a=float(i)*15.0,Float:b=float(i+1)*15.0;
        prev[0]=center[0]+floatcos(a,degrees)*54.0;prev[1]=center[1]+floatsin(a,degrees)*54.0;prev[2]=center[2];
        next[0]=center[0]+floatcos(b,degrees)*54.0;next[1]=center[1]+floatsin(b,degrees)*54.0;next[2]=center[2];
        DrawBeamLine(prev,next,7,90,25,150,18);
    }
}
stock TickMagnetic(Float:now) {
    if(!GameBossValid()) {StopCTGame(0,CT_STOP_EMPTY);return;}
    new Float:boss[3],Float:start[3];get_entvar(g_gameBoss,var_origin,boss);
    start[0]=boss[0];start[1]=boss[1];start[2]=boss[2]+24.0;
    if(now>=g_sumoNextDraw){DrawMagnetRing(g_gameBoss);g_sumoNextDraw=now+1.0;}
    for(new id=1;id<=MaxClients;id++) if(IsEntrant(id)) {
        new Float:target[3];get_entvar(id,var_origin,target);target[2]+=20.0;
        new Float:dx=boss[0]-target[0],Float:dy=boss[1]-target[1],Float:dz=boss[2]+24.0-target[2];
        new Float:dist=dx*dx+dy*dy+dz*dz;
        if(dist>1800.0*1800.0 || !MagnetLineClear(start,target)) continue;
        if(dist<55.0*55.0) {Eliminate(id,"Karadeliğin merkezine dokundu");continue;}
        if(dist<1.0) continue;
        new Float:length=floatsqroot(dist),Float:force=dist<62500.0?720.0:500.0;
        new Float:velocity[3];velocity[0]=dx/length*force;velocity[1]=dy/length*force;velocity[2]=dz/length*force+90.0;
        set_entvar(id,var_velocity,velocity);
    }
}
stock InitSumoArena() {
    if(!GameBossValid()) return;
    new Float:start[3],Float:finish[3],Float:ground[3];get_entvar(g_gameBoss,var_origin,start);
    finish[0]=start[0];finish[1]=start[1];finish[2]=start[2]-320.0;start[2]+=64.0;
    new tr=create_tr2();engfunc(EngFunc_TraceLine,start,finish,IGNORE_MONSTERS,g_gameBoss,tr);
    new Float:fraction;get_tr2(tr,TR_flFraction,fraction);
    if(fraction<1.0)get_tr2(tr,TR_vecEndPos,ground);
    else{ground[0]=start[0];ground[1]=start[1];ground[2]=finish[2];}
    free_tr2(tr);g_sumoCenter[0]=ground[0];g_sumoCenter[1]=ground[1];g_sumoFloor=ground[2];
    g_sumoRadius=float(g_cfg[CFG_SUMO_RADIUS]);g_sumoNextDraw=0.0;
    new count=CountEntrants(),index;
    new Float:spawnRadius=floatmin(180.0,floatmax(90.0,g_sumoRadius*0.45));
    for(new id=1;id<=MaxClients;id++) if(IsEntrant(id)) {
        new Float:angle=360.0*float(index)/float(max(1,count));index++;
        new Float:dest[3];dest[0]=g_sumoCenter[0]+floatcos(angle,degrees)*spawnRadius;
        dest[1]=g_sumoCenter[1]+floatsin(angle,degrees)*spawnRadius;dest[2]=g_sumoFloor+36.0;
        set_entvar(id,var_origin,dest);set_entvar(id,var_velocity,Float:{0.0,0.0,0.0});
        rg_remove_all_items(id);rg_give_item(id,"weapon_knife");engclient_cmd(id,"weapon_knife");
    }
    DrawSumoRing();Chat(0,"Sumo arenası kuruldu. Yarıçap: ^3%d^1 | İtme gücü: ^3%d",g_cfg[CFG_SUMO_RADIUS],g_cfg[CFG_SUMO_KNOCKBACK]);
}
stock DrawSumoRing() {
    if(g_sumoRadius<=0.0)return;
    new Float:prev[3],Float:next[3];
    for(new i=0;i<40;i++) {
        new Float:a=float(i)*9.0,Float:b=float(i+1)*9.0;
        prev[0]=g_sumoCenter[0]+floatcos(a,degrees)*g_sumoRadius;prev[1]=g_sumoCenter[1]+floatsin(a,degrees)*g_sumoRadius;prev[2]=g_sumoFloor+4.0;
        next[0]=g_sumoCenter[0]+floatcos(b,degrees)*g_sumoRadius;next[1]=g_sumoCenter[1]+floatsin(b,degrees)*g_sumoRadius;next[2]=g_sumoFloor+4.0;
        DrawBeamLine(prev,next,5,255,185,35,18);
    }
}
stock TickSumoArena(Float:now) {
    if(now>=g_sumoNextDraw){DrawSumoRing();g_sumoNextDraw=now+1.5;}
    new Float:limit=g_sumoRadius+18.0,Float:limitSq=limit*limit;
    for(new id=1;id<=MaxClients;id++)if(IsEntrant(id)){
        new Float:origin[3];get_entvar(id,var_origin,origin);
        new Float:dx=origin[0]-g_sumoCenter[0],Float:dy=origin[1]-g_sumoCenter[1];
        if(dx*dx+dy*dy>limitSq || origin[2]<g_sumoFloor-42.0)Eliminate(id,"Sumo platformundan düştü");
    }
}
stock SumoKnockback(attacker,victim) {
    if(g_game!=CT_GAME_SUMO || !IsEntrant(attacker) || !IsEntrant(victim) || attacker==victim)return;
    new Float:now=get_gametime();if(now<g_touchNext[victim])return;g_touchNext[victim]=now+0.18;
    new Float:a[3],Float:b[3],Float:velocity[3];get_entvar(attacker,var_origin,a);get_entvar(victim,var_origin,b);
    new Float:dx=b[0]-a[0],Float:dy=b[1]-a[1],Float:length=floatsqroot(dx*dx+dy*dy);
    if(length<1.0){dx=1.0;dy=0.0;length=1.0;}
    new Float:power=float(g_cfg[CFG_SUMO_KNOCKBACK]);
    velocity[0]=dx/length*power;velocity[1]=dy/length*power;velocity[2]=floatmax(160.0,power*0.22);
    set_entvar(victim,var_velocity,velocity);
}
stock GiveDodgeball(id) {
    if(!IsEntrant(id))return;
    if(!user_has_weapon(id,CSW_HEGRENADE))rg_give_item(id,"weapon_hegrenade");
    rg_set_user_bpammo(id,WEAPON_HEGRENADE,1);
}
stock TickDodgeball(){for(new id=1;id<=MaxClients;id++)if(IsEntrant(id))GiveDodgeball(id);}
public OnDodgeballGrenadeTouch(grenade,other) {
    if(g_game!=CT_GAME_DODGEBALL || !pev_valid(grenade) || !IsEntrant(other))return;
    new owner=pev(grenade,pev_owner);
    if(!IsEntrant(owner) || owner==other)return;
    Eliminate(other,"Yakan top doğrudan gövde/kafa isabeti aldı");
    if(pev_valid(grenade))engfunc(EngFunc_RemoveEntity,grenade);
}
PassBomb(target) {
    if(!IsEntrant(target) || target==g_bomb) return;
    new Float:now=get_gametime();
    if(g_bomb && now<g_touchNext[g_bomb]) return;
    if(IsEntrant(g_bomb)) ClearGlow(g_bomb);
    g_bomb=target;g_touchNext[target]=now+0.70;Glow(target,190,65,255);
    Chat(target,"^4Bomba sende! ^1Bir mahkûma dokunarak bombayı devret.");
}

public HookSay(id) {
    if(sayiyibilenKontrol) return LegacyHookSay(id);
    new text[192];read_args(text,charsmax(text));remove_quotes(text);trim(text);
    if(g_hard && AliveT(id) && (equali(text,"/redbull") || equali(text,"/rb") || equali(text,"/parachute"))) {Chat(id,"Hard Komut açıkken bu özellik kapalı.");return PLUGIN_HANDLED;}
    if(g_game!=CT_GAME_NUMBER || !IsEntrant(id) || !text[0]) return PLUGIN_CONTINUE;
    for(new i=0;text[i];i++) if(text[i]<'0' || text[i]>'9') return PLUGIN_CONTINUE;
    if(get_gametime()<g_nextGuess[id]) return PLUGIN_HANDLED;
    g_nextGuess[id]=get_gametime()+0.5;
    new guess=str_to_num(text);
    if(guess<1 || guess>100) Chat(id,"^3 1-100 ^1arasında bir sayı yaz.");
    else if(guess==g_secret) {
        Chat(0,"Doğru sayı: ^4%d^1. ^3%n ^1ilk doğru tahmini yaptı!",g_secret,id);
        // Finish first: late death hooks cannot replace the recorded winner.
        StopCTGame(id,CT_STOP_WIN);
        for(new target=1;target<=MaxClients;target++) if(target!=id && AliveT(target)) user_kill(target,1);
    }
    else Chat(id,"Gizli sayı ^3%d ^1sayısından ^4%s^1.",guess,guess<g_secret?"büyük":"küçük");
    return PLUGIN_HANDLED;
}

DrawGameHud() {
    if(!g_game || g_game==CT_GAME_HOGWARTS || g_game==CT_GAME_MILYONER) return;
    new detail[192],nick[32],r=184,g=88,b=255;
    switch(g_game) {
        case CT_GAME_RED_LIGHT: {copy(detail,charsmax(detail),g_phase?"KIRMIZI IŞIK — DUR!":"YEŞİL IŞIK — HAREKET ET!");r=g_phase?255:65;g=g_phase?65:235;b=75;}
        case CT_GAME_PENDULUM:formatex(detail,charsmax(detail),"Yerçekimi dalgası: %d^nSon kalan kazanır.",g_rounds);
        case CT_GAME_FREEZE_CHANCE: {if(IsEntrant(g_bomb)) get_user_name(g_bomb,nick,charsmax(nick));formatex(detail,charsmax(detail),"%s: %s^nKalan: %d saniye",g_phase?"Seçilen mahkûm":"Yeni çekiliş",g_phase?nick:"Bekleniyor",max(0,floatround(g_phaseEnd-get_gametime(),floatround_ceil)));}
        case CT_GAME_BURY_JUMP:copy(detail,charsmax(detail),g_phase?"Yeni tuzağı bekle...":"ÜÇ SANİYE İÇİNDE ZIPLA!");
        case CT_GAME_HOT_POTATO: {if(IsEntrant(g_bomb)) get_user_name(g_bomb,nick,charsmax(nick));formatex(detail,charsmax(detail),"Bomba: %s^nPatlama: %d saniye",nick,max(0,floatround(g_phaseEnd-get_gametime(),floatround_ceil)));}
        case CT_GAME_REFLEX: {if(g_reflexStarting) formatex(detail,charsmax(detail),"OYUN BAŞLIYOR: %d",max(0,floatround(g_reflexStartEnd-get_gametime(),floatround_ceil)));else if(g_phase==1) formatex(detail,charsmax(detail),"%s%s^nTur: %d | Cevap: %.1f sn",g_reflexFake?"SAHTE — DUR! ":"KOMUT: ",REFLEX_LABELS[g_reflexAction],g_rounds+1,ReflexWindow());else copy(detail,charsmax(detail),"Yeni komutu bekle...");}
        case CT_GAME_NUMBER:copy(detail,charsmax(detail),"Sohbete 1-100 arasında sayı yaz.");
        case CT_GAME_HUNGER:formatex(detail,charsmax(detail),"Güvenli alan: %d birim^nKutulardan silah topla.",floatround(g_radius));
        case CT_GAME_HOMELANDER:copy(detail,charsmax(detail),"CT komutanı: ateş tuşunu basılı tutarak lazer gönder.");
        case CT_GAME_TRON:copy(detail,charsmax(detail),"400 hız | Başka oyuncunun renkli izine değme!");
        case CT_GAME_MAGNETIC:copy(detail,charsmax(detail),"Karadeliğe yaklaşma; duvar arkasına saklan.");
        case CT_GAME_SUMO:formatex(detail,charsmax(detail),"Platform yarıçapı: %d | Bıçakla it, arenadan düşme.",floatround(g_sumoRadius));
        case CT_GAME_DODGEBALL:copy(detail,charsmax(detail),"Sınırsız bomba | Patlama hasarsız | Doğrudan isabet ölümcül.");
        case CT_GAME_TEAMS: {
            new red,blue;for(new id=1;id<=MaxClients;id++) if(IsEntrant(id)) {if(g_color[id]==1) red++;else blue++;}
            formatex(detail,charsmax(detail),"Kırmızı: %d | Mavi: %d",red,blue);
        }
        default:copy(detail,charsmax(detail),GAME_RULES[_:g_game]);
    }
    new text[432];formatex(text,charsmax(text),"FELICIACLAN | %s^n%s^nKalan: %d | Süre: %d sn",GAME_NAMES[_:g_game],detail,CountEntrants(),max(0,floatround(g_gameEnd-get_gametime(),floatround_ceil)));
    for(new id=1;id<=MaxClients;id++) if(is_user_connected(id)) FC_SendPanelHud(id,text,r,g,b,0.03,0.16,1);
}

Blind(id) {
    if(!is_user_connected(id)) return;
    message_begin(MSG_ONE_UNRELIABLE,get_user_msgid("ScreenFade"),_,id);
    write_short(1<<12);write_short(5<<12);write_short(1<<2);write_byte(0);write_byte(0);write_byte(0);write_byte(255);message_end();
}

ClearBlind(id) {
    if(!is_user_connected(id)) return;
    message_begin(MSG_ONE_UNRELIABLE,get_user_msgid("ScreenFade"),_,id);
    write_short(1);write_short(0);write_short(0);write_byte(0);write_byte(0);write_byte(0);write_byte(0);message_end();
}

InitHunger() {
    if(g_hasArena) for(new j=0;j<3;j++) g_center[j]=g_arenaCenter[j];
    else {
        new n;g_center[0]=g_center[1]=g_center[2]=0.0;
        for(new id=1;id<=MaxClients;id++) if(IsEntrant(id)) {new Float:p[3];get_entvar(id,var_origin,p);for(new j=0;j<3;j++) g_center[j]+=p[j];n++;}
        for(new j=0;j<3;j++) g_center[j]/=float(max(1,n));g_center[2]-=30.0;
    }
    g_radius=float(g_cfg[CFG_HUNGER_RADIUS]);
    if(!g_hasArena) for(new id=1;id<=MaxClients;id++) if(IsEntrant(id)) {new Float:p[3];get_entvar(id,var_origin,p);g_radius=floatmax(g_radius,FlatDistance(p,g_center)+200.0);}
    g_nextShrink=get_gametime()+5.0;
    if(g_arenaCount) {for(new i=0;i<g_arenaCount;i++) CreateLoot(g_arenaPoints[i]);}
    else {
        for(new id=1;id<=MaxClients;id++) if(IsEntrant(id) && g_crateCount<MAX_CRATES) {
            new Float:p[3];get_entvar(id,var_origin,p);p[0]+=48.0;p[2]-=20.0;CreateLoot(p);
        }
    }
    Chat(0,"^4Mor çember ^1güvenli alandır. Çemberin dışında ^3can kaybedersin^1.");
}

Float:FlatDistance(const Float:a[3],const Float:b[3]) {return floatsqroot((a[0]-b[0])*(a[0]-b[0])+(a[1]-b[1])*(a[1]-b[1]));}

CreateLoot(const Float:position[3]) {
    if(g_crateCount>=MAX_CRATES) return 0;
    new ent=create_entity("info_target");if(!is_valid_ent(ent)) return 0;
    entity_set_string(ent,EV_SZ_classname,LOOT_CLASS);entity_set_model(ent,g_lootModel);
    entity_set_size(ent,Float:{-15.0,-15.0,-12.0},Float:{15.0,15.0,12.0});entity_set_origin(ent,position);
    entity_set_int(ent,EV_INT_movetype,MOVETYPE_TOSS);entity_set_int(ent,EV_INT_solid,SOLID_TRIGGER);
    entity_set_float(ent,EV_FL_gravity,1.0);drop_to_floor(ent);Glow(ent,184,88,255);
    g_crates[g_crateCount++]=ent;return ent;
}

public OnLoot(ent,id) {
    if(g_game!=CT_GAME_HUNGER || !IsEntrant(id) || !is_valid_ent(ent)) return;
    new index=-1;for(new i=0;i<g_crateCount;i++) if(g_crates[i]==ent) {index=i;break;}
    if(index<0) return;
    g_crates[index]=0;remove_entity(ent);GiveGun(id,random_num(0,7));Chat(id,"İkmal kutusundan ^4silah ve cephane ^1aldın.");
}

RemoveCrates() {
    new classname[32];
    for(new i=0;i<g_crateCount;i++) {
        new ent=g_crates[i];if(is_valid_ent(ent)) {entity_get_string(ent,EV_SZ_classname,classname,charsmax(classname));if(equal(classname,LOOT_CLASS)) remove_entity(ent);}
        g_crates[i]=0;
    }
    g_crateCount=0;
}

TickHunger(Float:now) {
    if(now>=g_nextShrink) {g_nextShrink=now+1.0;g_radius=floatmax(float(g_cfg[CFG_HUNGER_MIN]),g_radius-float(g_cfg[CFG_HUNGER_SHRINK]));}
    DrawRing(g_center,g_radius,184,88,255);
    for(new id=1;id<=MaxClients;id++) if(IsEntrant(id)) {
        new Float:origin[3];get_entvar(id,var_origin,origin);
        if(FlatDistance(origin,g_center)<=g_radius) continue;
        new Float:hp;get_entvar(id,var_health,hp);
        if(hp<=float(g_cfg[CFG_HUNGER_DAMAGE])) Eliminate(id,"Güvenli alanın dışında kaldı");
        else {set_entvar(id,var_health,hp-float(g_cfg[CFG_HUNGER_DAMAGE]));client_print(id,print_center,"GÜVENLİ ALANA DÖN!");}
    }
}

DrawRing(const Float:origin[3],Float:radius,r,g,b) {
    if(!g_beam) return;
    for(new i=0;i<16;i++) {
        new Float:a=float(i)*6.2831853/16.0,Float:next=float(i+1)*6.2831853/16.0;
        message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
        write_byte(TE_BEAMPOINTS);
        write_coord(floatround(origin[0]+floatcos(a)*radius));write_coord(floatround(origin[1]+floatsin(a)*radius));write_coord(floatround(origin[2]+4.0));
        write_coord(floatround(origin[0]+floatcos(next)*radius));write_coord(floatround(origin[1]+floatsin(next)*radius));write_coord(floatround(origin[2]+4.0));
        write_short(g_beam);write_byte(0);write_byte(0);write_byte(12);write_byte(8);write_byte(0);
        write_byte(r);write_byte(g);write_byte(b);write_byte(200);write_byte(0);message_end();
    }
}

InitCTBattle() {
    for(new id=1;id<=MaxClients;id++) {
        if(AliveCT(id)) {
            SetupBattleCT(id);
        } else if(IsEntrant(id)) {
            if(g_game==CT_GAME_ZOMBIE) {set_entvar(id,var_health,1000.0);Glow(id,65,210,75);}
            else if(g_game==CT_GAME_GHOST) GiveGun(id,0);
            else if(g_game==CT_GAME_AREF) {GiveGun(id,7);set_entvar(id,var_rendermode,kRenderTransAlpha);set_entvar(id,var_renderamt,18.0);}
            else set_entvar(id,var_health,150.0);
        }
    }
}

TickPendulum(Float:now) {
    if(now<g_phaseEnd) return;
    g_phase=1-g_phase;g_phaseEnd=now+3.0;g_rounds++;
    for(new id=1;id<=MaxClients;id++) if(IsEntrant(id)) {
        set_entvar(id,var_gravity,g_phase?0.35:1.80);
        new Float:hp;get_entvar(id,var_health,hp);
        if(hp<=5.0) Eliminate(id,"Sarkaç dalgasında canı bitti");else set_entvar(id,var_health,hp-5.0);
    }
}

TickFreezeChance(Float:now) {
    if(now<g_phaseEnd) return;
    if(g_phase) {
        if(IsEntrant(g_bomb)) {
            if(g_game!=CT_GAME_COLOR_LUCK || g_secret==1) {Eliminate(g_bomb,"Şans çekilişinde elendi");}
            else {ClearGlow(g_bomb);}
        }
        g_bomb=0;g_phase=0;g_phaseEnd=now+4.0;
    }
    else {
        g_bomb=RandomEntrant();if(!g_bomb) return;
        g_phase=1;g_phaseEnd=now+2.0;
        if(g_game==CT_GAME_COLOR_LUCK) {g_secret=random_num(1,2);Glow(g_bomb,g_secret==1?255:70,80,g_secret==1?60:255);Chat(0,"^3%n ^1için renk: ^4%s^1.",g_bomb,g_secret==1?"Kırmızı - elenecek":"Mavi - şanslı");return;}
        GameFreeze(g_bomb,true);Glow(g_bomb,90,170,255);
        Chat(0,"^3%n ^1donduruldu. ^4%d saniye ^1sonra elenecek.",g_bomb,2);
    }
}

TickBuryJump(Float:now) {
    if(now<g_phaseEnd) return;
    if(!g_phase) {
        for(new id=1;id<=MaxClients;id++) if(IsEntrant(id) && !g_ready[id]) Eliminate(id,"Tuzaktan zıplayarak kurtulamadı");
        g_phase=1;g_phaseEnd=now+4.0;
    } else {
        g_phase=0;g_phaseEnd=now+3.0;
        for(new id=1;id<=MaxClients;id++) if(IsEntrant(id)) {g_ready[id]=false;C4Bury(id,false,0.0);Glow(id,230,100,50);}
        Chat(0,"Tuzak açıldı: ^4%d saniye ^1içinde zıpla!",3);
    }
}

SetupBattleCT(id) {
    set_entvar(id,var_takedamage,DAMAGE_AIM);set_entvar(id,var_health,g_game==CT_GAME_SPARTA?750.0:g_game==CT_GAME_GHOST?250.0:200.0);
    rg_remove_all_items(id);rg_give_item(id,"weapon_knife");
    if(g_game==CT_GAME_GHOST) {set_entvar(id,var_renderfx,kRenderFxNone);set_entvar(id,var_rendermode,kRenderTransAlpha);set_entvar(id,var_renderamt,18.0);}
    else if(g_game!=CT_GAME_SPARTA) GiveGun(id,0);
}

PlayCTSound(which,id=0) {
    if(!g_cfg[CFG_SOUNDS] || which<0 || which>=sizeof CT_SOUNDS || !g_soundReady[which]) return;
    if(id && !is_user_connected(id)) return;
    rg_send_audio(id,g_soundPath[which]);
}

ResetSettings(id) { if(AliveCT(id)) {BridgeReset(CT_STOP_MENU,true);PlayCTSound(SND_RESET);Chat(0,"^3%n ^1ayarları eski haline getirdi.",id);} }

ShowGamesHub(id) { oyunoncesi(id); }

public H_GamesHub(id,menu,item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(!MenuActor(id,menu,item)) return PLUGIN_HANDLED;
    new op=ReadMenu(menu,item);menu_destroy(menu);
    switch(op) {
        case 1:ShowGameList(id,false);
        case 2:ShowGameList(id,true);
        case 3:{StopCTGame(0,CT_STOP_MENU);ShowGamesHub(id);}
        case 4:ShowMain(id);
    }
    return PLUGIN_HANDLED;
}

ShowControlMenus(id) {
    g_requestedAction[id]=0;new menu=CTMenu("\wMenüler","H_ControlMenus");
    CTItem(menu,"\wCanlandırma Menüsü","1");CTItem(menu,"\wSilah Verme Menüsü","2");
    CTItem(menu,"\wSilahları Alma Menüsü","3");CTItem(menu,"\wDondurma / Çözme Menüsü","4");
    CTItem(menu,"\wCan / Yerçekimi / God / Noclip İşlemleri","5");CTItem(menu,"\wGlow Menüsü","6");
    CTItem(menu,"\wGetir Menüsü \w[\r/getir\w] \d[God]","10");
    CTItem(menu,"\wRocket Menüsü \w[\r/rocket\w]","11");
    CTItem(menu,"\wIşınlama / Sıralama Menüsü","7");CTItem(menu,"\wSon Ölen Mahkûmu Canlandır","8");
    CTItem(menu,"\wAçlık Oyunları / Koordinat Ayarları","12");
    CTItem(menu,"\wAna Menüye Dön","9");FC_CTMenuDisplay(id,menu);
}

public H_ControlMenus(id,menu,item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(!MenuActor(id,menu,item)) return PLUGIN_HANDLED;
    new op=ReadMenu(menu,item);menu_destroy(menu);
    if(op==9) {ShowMain(id);return PLUGIN_HANDLED;}
    if(op==12) {ShowArenaMenu(id);return PLUGIN_HANDLED;}
    if(op==10) {ShowBringMenu(id);return PLUGIN_HANDLED;}
    if(op==11) {ShowRocketMenu(id);return PLUGIN_HANDLED;}
    if(op==7) {ShowTeleportMenu(id);return PLUGIN_HANDLED;}
    if(op==8) {ReviveLast(id);ShowControlMenus(id);return PLUGIN_HANDLED;}
    if(!ToolsAllowed(id)) return PLUGIN_HANDLED;
    switch(op) {
        case 1:g_requestedAction[id]=1;
        case 2:g_requestedAction[id]=3;
        case 3:g_requestedAction[id]=2;
        case 4:g_requestedAction[id]=4;
        case 5:g_requestedAction[id]=0;
        case 6:g_requestedAction[id]=9;
        default:return PLUGIN_HANDLED;
    }
    ShowTargetScope(id);return PLUGIN_HANDLED;
}

ContinueTargetSelection(id) {
    new action=g_requestedAction[id];g_requestedAction[id]=0;
    if(action) RunPlayerAction(id,action);else ShowPlayerActions(id);
}

SetAllHealth(id) {
    if(!ToolsAllowed(id)) return;
    for(new target=1;target<=MaxClients;target++) if(is_user_alive(target)) {SaveState(target,SNAP_TOOL);set_entvar(target,var_health,100.0);}
    Chat(0,"^3%n ^1yaşayan oyuncuların canını ^4%d ^1yaptı.",id,100);PlayCTSound(SND_NOTICE);
}

public CmdBring(id) {if(AliveCT(id)) ShowBringMenu(id);return PLUGIN_HANDLED;}

bool:BringAllowed(id)
{
    if(!AliveCT(id) || !ToolsAllowed(id)) return false;
    if(!g_godMode) {Chat(id,"Getir menüsü için bu el Godmode açık olmalı.");return false;}
    return true;
}

ShowBringMenu(id)
{
    if(!BringAllowed(id)) return;
    new menu=CTMenu("\wGetir Menüsü \d[God]","H_Bring");
    CTItem(menu,"\wYaşayan Bütün Mahkûmları Yanıma Getir","1");
    CTItem(menu,"\wYaşayan Oyuncu Seç","2");
    CTItem(menu,"\wMenüler Bölümüne Dön","3");FC_CTMenuDisplay(id,menu);
}

public H_Bring(id,menu,item)
{
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(!MenuActor(id,menu,item)) return PLUGIN_HANDLED;
    new op=ReadMenu(menu,item);menu_destroy(menu);
    if(!BringAllowed(id)) return PLUGIN_HANDLED;
    if(op==3) {ShowControlMenus(id);return PLUGIN_HANDLED;}
    if(op==2) {ShowBringPlayers(id);return PLUGIN_HANDLED;}
    if(op==1) {g_target[id]=0;g_targetUID[id]=0;BringPrisoners(id);}
    ShowBringMenu(id);return PLUGIN_HANDLED;
}

ShowBringPlayers(id)
{
    if(!BringAllowed(id)) return;
    new menu=CTMenu("\wGetir / Yaşayan Mahkûm Seç","H_BringPlayer"),name[32],line[96],info[32],count;
    for(new target=1;target<=MaxClients;target++) if(AliveT(target)) {
        get_user_name(target,name,charsmax(name));formatex(line,charsmax(line),"\w%s",name);
        formatex(info,charsmax(info),"%d %d",target,get_user_userid(target));CTItem(menu,line,info);count++;
    }
    if(!count) {menu_destroy(menu);Chat(id,"Getirilecek yaşayan mahkûm yok.");ShowBringMenu(id);return;}
    FC_CTMenuDisplay(id,menu);
}

public H_BringPlayer(id,menu,item)
{
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(!MenuActor(id,menu,item)) return PLUGIN_HANDLED;
    new info[32],player[8],uid[12],access,callback;menu_item_getinfo(menu,item,access,info,charsmax(info),_,_,callback);menu_destroy(menu);
    if(!BringAllowed(id)) return PLUGIN_HANDLED;
    parse(info,player,charsmax(player),uid,charsmax(uid));new target=str_to_num(player);
    if(target<1 || target>MaxClients || !AliveT(target) || get_user_userid(target)!=str_to_num(uid)) {Chat(id,"Seçilen mahkûm artık kullanılabilir değil.");ShowBringPlayers(id);return PLUGIN_HANDLED;}
    g_target[id]=target;g_targetUID[id]=get_user_userid(target);BringPrisoners(id);ShowBringMenu(id);return PLUGIN_HANDLED;
}

BringPrisoners(id)
{
    if(!BringAllowed(id) || !TargetValid(id)) return 0;
    new Float:origin[3],Float:dest[3],changed;
    get_entvar(id,var_origin,origin);
    // Everyone receives the exact same destination, rather than formation offsets.
    dest[0]=origin[0]+64.0;
    dest[1]=origin[1];
    dest[2]=origin[2];
    for(new target=1;target<=MaxClients;target++) if(TargetMatches(id,target)) {
        SaveState(target,SNAP_TOOL);
        engfunc(EngFunc_SetOrigin,target,dest);
        set_entvar(target,var_velocity,Float:{0.0,0.0,0.0});
        changed++;
    }
    Chat(0,"^3%n ^1yanına ^4%d yaşayan mahkûm ^1getirdi.",id,changed);return changed;
}

ShowTeleportMenu(id) {
    StopFormation(id);
    new menu=CTMenu("\wIşınlama Menüsü","H_Teleport");
    CTItem(menu,"\wMahkûmları Yanıma Getir \d[God]","1");CTItem(menu,"\wMahkûmları Baktığım Yerde Sırala","2");
    CTItem(menu,"\wBaktığım Yerde Daire Oluştur","3");CTItem(menu,"\wListeden Oyuncu / Konum İşlemleri","4");
    CTItem(menu,"\wMahkûmları Dondur","5");CTItem(menu,"\wMahkûmları Çöz","6");
    CTItem(menu,"\wAna Menüye Dön","7");FC_CTMenuDisplay(id,menu);
}

public CmdTeleport(id) {if(AliveCT(id)) ShowTeleportMenu(id);return PLUGIN_HANDLED;}

public CmdLineup(id) {if(AliveCT(id)) ShowLineupMenu(id);return PLUGIN_HANDLED;}

public H_Teleport(id,menu,item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(!MenuActor(id,menu,item)) return PLUGIN_HANDLED;
    new op=ReadMenu(menu,item);menu_destroy(menu);
    if(op==7) {ShowMain(id);return PLUGIN_HANDLED;}
    if(!ToolsAllowed(id)) return PLUGIN_HANDLED;
    switch(op) {
        case 1:{g_target[id]=0;g_targetUID[id]=0;RunPlayerAction(id,7);}
        case 2:{ShowLineupMenu(id);return PLUGIN_HANDLED;}
        case 3:PlaceFormation(id,true);
        case 4:{g_requestedAction[id]=0;ShowTargetScope(id);return PLUGIN_HANDLED;}
        case 5:FreezePrisoners(id,true);
        case 6:FreezePrisoners(id,false);
    }
    ShowTeleportMenu(id);return PLUGIN_HANDLED;
}

ShowLineupMenu(id) {
    if(!AliveCT(id) || !ToolsAllowed(id)) {StopFormation(id);return;}
    new title[256],direction[48];
    switch(g_lineAxis[id]) {case 0:copy(direction,charsmax(direction),"X Ekseni");case 1:copy(direction,charsmax(direction),"Y Ekseni");case 3:copy(direction,charsmax(direction),"Dikey");default:copy(direction,charsmax(direction),"Bakışa Göre");}
    if(g_lineSpacing[id]<40) g_lineSpacing[id]=48;
    formatex(title,charsmax(title),"\wSıralama Menüsü^n\dYere nişan al. Çizgi sıranın yerini gösterir.^n\dYön: \y%s \d| Aralık: \y%d",direction,g_lineSpacing[id]);
    new menu=CTMenu(title,"H_Lineup");CTItem(menu,"\wYönü Değiştir","1");CTItem(menu,"\wOyuncu Aralığını Değiştir","2");
    CTItem(menu,"\wMahkûmları Sırala","3");CTItem(menu,"\wMahkûmları Dondur","4");
    CTItem(menu,"\wMahkûmları Çöz","5");CTItem(menu,"\wIşınlama Menüsüne Dön","6");
    g_lineMenu[id]=menu;FC_CTMenuDisplay(id,menu);
    if(!task_exists(TASK_FORMATION)) set_task(0.2,"FormationPreview",TASK_FORMATION,"",0,"b");
}

public H_Lineup(id,menu,item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    new bool:owned=g_lineMenu[id]==menu;if(owned) g_lineMenu[id]=-1;
    if(!owned || !MenuActor(id,menu,item)) {if(!owned) menu_destroy(menu);return PLUGIN_HANDLED;}
    if(!ToolsAllowed(id)) {menu_destroy(menu);return PLUGIN_HANDLED;}
    new op=ReadMenu(menu,item);menu_destroy(menu);
    switch(op) {
        case 1:g_lineAxis[id]=(g_lineAxis[id]+1)%4;
        case 2:g_lineSpacing[id]=g_lineSpacing[id]==40?48:g_lineSpacing[id]==48?64:40;
        case 3:PlaceFormation(id,false);
        case 4:FreezePrisoners(id,true);
        case 5:FreezePrisoners(id,false);
        case 6:{ShowTeleportMenu(id);return PLUGIN_HANDLED;}
    }
    ShowLineupMenu(id);return PLUGIN_HANDLED;
}

StopFormation(id) {g_lineMenu[id]=-1;}

StopAllFormations() {arrayset(g_lineMenu,-1,sizeof g_lineMenu);remove_task(TASK_FORMATION);}

bool:FormationAim(id,Float:point[3]) {
    new origin[3];get_user_origin(id,origin,3);
    if(abs(origin[0])>4090 || abs(origin[1])>4090 || abs(origin[2])>4090) return false;
    for(new j;j<3;j++) point[j]=float(origin[j]);
    new Float:start[3],Float:finish[3];for(new j;j<3;j++) start[j]=finish[j]=point[j];
    start[2]+=48.0;finish[2]-=128.0;
    new tr=create_tr2();engfunc(EngFunc_TraceLine,start,finish,IGNORE_MONSTERS,id,tr);
    new Float:fraction;get_tr2(tr,TR_flFraction,fraction);
    new bool:valid=!get_tr2(tr,TR_StartSolid) && !get_tr2(tr,TR_AllSolid) && fraction<1.0;
    if(valid) get_tr2(tr,TR_vecEndPos,point);free_tr2(tr);return valid;
}

FormationBasis(id,Float:direction[3]) {
    direction[0]=direction[1]=direction[2]=0.0;
    switch(g_lineAxis[id]) {
        case 0:direction[0]=1.0;
        case 1:direction[1]=1.0;
        case 3:direction[2]=1.0;
        default:{new Float:angles[3];get_entvar(id,var_v_angle,angles);direction[0]=-floatsin(angles[1],degrees);direction[1]=floatcos(angles[1],degrees);}
    }
}

bool:FreeFormationPoint(id,caller,const Float:point[3]) {
    for(new j;j<3;j++) if(floatabs(point[j])>4090.0) return false;
    new tr=create_tr2();engfunc(EngFunc_TraceHull,point,point,IGNORE_MONSTERS,HULL_HUMAN,id,tr);
    new bool:clear=!get_tr2(tr,TR_StartSolid) && !get_tr2(tr,TR_AllSolid);free_tr2(tr);
    if(!clear) return false;
    for(new other=1;other<=MaxClients;other++) if(is_user_alive(other) && !AliveT(other)) {
        new Float:origin[3];get_entvar(other,var_origin,origin);
        if(floatabs(origin[0]-point[0])<34.0 && floatabs(origin[1]-point[1])<34.0 && floatabs(origin[2]-point[2])<74.0) return false;
    }
    return AliveCT(caller) && AliveT(id);
}

PlaceFormation(id,bool:circle) {
    if(!AliveCT(id) || !ToolsAllowed(id)) return 0;
    new count=CountT();if(count<2) {Chat(id,"Sıralamak için en az ^3%d yaşayan mahkûm ^1gerekir.",2);return 0;}
    new Float:point[3];if(!FormationAim(id,point)) {Chat(id,"Güvenli bir zemin bulunamadı; yere nişan al.");return 0;}
    new Float:direction[3];FormationBasis(id,direction);
    new Float:spacing=float(max(40,g_lineSpacing[id]));if(g_lineAxis[id]==3) spacing=80.0;
    new changed,index;new Float:radius=floatmax(80.0,float(count)*spacing/6.2831853);
    for(new target=1;target<=MaxClients;target++) if(AliveT(target)) {
        new Float:dest[3];for(new j;j<3;j++) dest[j]=point[j];
        if(circle) {new Float:angle=360.0*float(index)/float(count);dest[0]+=floatcos(angle,degrees)*radius;dest[1]+=floatsin(angle,degrees)*radius;dest[2]+=36.0;}
        else {new Float:offset=g_lineAxis[id]==3?float(index)*spacing:(float(index)-float(count-1)*0.5)*spacing;for(new j;j<3;j++) dest[j]+=direction[j]*offset;dest[2]+=36.0;}
        index++;
        if(!FreeFormationPoint(target,id,dest)) continue;
        SaveState(target,SNAP_TOOL);set_entvar(target,var_origin,dest);set_entvar(target,var_velocity,Float:{0.0,0.0,0.0});changed++;
    }
    Chat(0,"^3%n ^1mahkûmları ^4%s ^1yerleştirdi: ^3%d/%d^1. Engelli konumlar atlandı.",id,circle?"daire şeklinde":"sıraya",changed,count);
    if(changed) PlayCTSound(SND_LINEUP);return changed;
}

FreezePrisoners(id,bool:frozen) {
    if(!ToolsAllowed(id)) return;
    for(new target=1;target<=MaxClients;target++) if(AliveT(target)) {SaveState(target,SNAP_TOOL);g_toolFrozen[target]=frozen;g_thawTime[target]=0.0;GameFreeze(target,frozen);}
    Chat(0,"^3%n ^1mahkûmları ^4%s^1.",id,frozen?"dondurdu":"çözdü");PlayCTSound(SND_FREEZE);
}

public FormationPreview() {
    if(!g_lineBeam) return;
    new active;
    for(new id=1;id<=MaxClients;id++) if(g_lineMenu[id]>=0) {
        new old,current,page;
        if(!AliveCT(id) || g_game || !player_menu_info(id,old,current,page) || current!=g_lineMenu[id]) {StopFormation(id);continue;}
        active++;new Float:point[3];if(!FormationAim(id,point)) continue;
        new Float:direction[3];FormationBasis(id,direction);
        new Float:half=floatmax(24.0,float(max(0,CountT()-1))*float(max(40,g_lineSpacing[id]))*0.5);
        if(g_lineAxis[id]==3) half=floatmax(40.0,float(max(0,CountT()-1))*40.0);
        new Float:a[3],Float:b[3];for(new j;j<3;j++) {a[j]=point[j]-direction[j]*half;b[j]=point[j]+direction[j]*half;}
        if(g_lineAxis[id]==3) {a[2]=point[2];b[2]=point[2]+half*2.0;}
        a[2]+=10.0;b[2]+=10.0;
        message_begin(MSG_ONE_UNRELIABLE,SVC_TEMPENTITY,_,id);write_byte(TE_BEAMPOINTS);
        for(new j;j<3;j++) write_coord(clamp(floatround(a[j]),-4090,4090));
        for(new j;j<3;j++) write_coord(clamp(floatround(b[j]),-4090,4090));
        write_short(g_lineBeam);write_byte(0);write_byte(0);write_byte(4);write_byte(30);write_byte(0);
        write_byte(184);write_byte(88);write_byte(255);write_byte(255);write_byte(0);message_end();
    }
    if(!active) remove_task(TASK_FORMATION);
}

CTMenu(const title[], const handler[]) {
    new full[512],clean[432];FC_MenuCleanHints(title,clean,charsmax(clean));formatex(full,charsmax(full),"\r%s \y» %s",LONG_TAG,clean);
    new menu=menu_create(full,handler);
    menu_setprop(menu,MPROP_NUMBER_COLOR,"\r");
    menu_setprop(menu,MPROP_BACKNAME,"\wÖnceki");menu_setprop(menu,MPROP_NEXTNAME,"\wSonraki");
    menu_setprop(menu,MPROP_EXITNAME,"\wGeri / Kapat");return menu;
}

CTItem(menu,const text[],const key[],callback=-1) {
    new line[256],clean[240];FC_MenuCleanHints(text,clean,charsmax(clean));formatex(line,charsmax(line),"\r%s \y» %s",SHORT_TAG,clean);
    return menu_additem(menu,line,key,0,callback);
}

Chat(id,const fmt[],any:...) {
    new text[158];vformat(text,charsmax(text),fmt,3);
    client_print_color(id,id,"%s ^1%s",CHAT_TAG,text);
}

ReadMenu(menu,item) {
    new info[24],access,callback;menu_item_getinfo(menu,item,access,info,charsmax(info),_,_,callback);
    return str_to_num(info);
}

bool:MenuActor(id,menu,item,bool:control=true) {
    if(g_bridgeRoundClosed || item==MENU_EXIT || !AliveCT(id) || (control && !HasControl(id))) {
        menu_destroy(menu);return false;
    }
    return true;
}

public CmdMenu(id) {
    StopFormation(id);
    if(!AliveCT(id)) {Chat(id,"Bu menüyü yalnız yaşayan ^3CT ^1oyuncuları kullanabilir.");return PLUGIN_HANDLED;}
    PlayCTSound(SND_MENU,id);ShowMain(id);return PLUGIN_HANDLED;
}

public CmdRadio(id) {
    if(!AliveCT(id) || !g_cfg[CFG_RADIO]) return PLUGIN_CONTINUE;
    StopFormation(id);PlayCTSound(SND_MENU,id);ShowMain(id);return PLUGIN_HANDLED;
}

ShowMain(id) { ctmenu(id); }

public CB_ModeItem(id,menu,item) {
    new key=ReadMenu(menu,item),pending=key==2?g_hardPending:g_godPending,next=key==2?g_hardNext:g_godNext;
    if(ModeReady(key==2)) return AliveCT(id) && !g_game && !g_rocketActive?ITEM_ENABLED:ITEM_DISABLED;
    return AliveCT(id) && pending!=g_roundNo+1 && next<=g_roundNo+1?ITEM_ENABLED:ITEM_DISABLED;
}

public H_Main(id,menu,item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(!MenuActor(id,menu,item)) return PLUGIN_HANDLED;
    new key=ReadMenu(menu,item);menu_destroy(menu);
    switch(key) {
        case 1:RequestMode(false,id);
        case 2:RequestMode(true,id);
        case 3:ResetSettings(id);
        case 4:{ShowGamesHub(id);return PLUGIN_HANDLED;}
        case 5:{ShowControlMenus(id);return PLUGIN_HANDLED;}
        case 6:{ShowProtectionMenu(id);return PLUGIN_HANDLED;}
        case 7:{ShowTeleportMenu(id);return PLUGIN_HANDLED;}
        case 8:{ShowCTMarket(id);return PLUGIN_HANDLED;}
        case 9:ReviveLast(id);
        case 10:SetAllHealth(id);
        case 11:ToggleCells(id);
        case 12:{ShowSettings(id);return PLUGIN_HANDLED;}
        case 13:StopCTGame(0,CT_STOP_MENU);
        case 14:{client_cmd(0,"stopsound");Chat(0,"^3%n ^1sesleri durdurdu.",id);}
        case 15:{ShowC4Menu(id);return PLUGIN_HANDLED;}
    }
    ShowMain(id);return PLUGIN_HANDLED;
}

ShowGameList(id,bool:god) {
    new title[160];formatex(title,charsmax(title),"\w%s^n\d%s",god?"God Gerektiren Oyunlar":"God Gerektirmeyen Oyunlar",god?"Bu elin Godmode izniyle oynatılır.":"God verilmez; oyunun kuralları içeride yazılıdır.");
    new menu=CTMenu(title,"H_GameList"),line[160],info[8];
    for(new i=1;i<sizeof GAME_NAMES;i++) {
        if(i==_:CT_GAME_ROCKET) continue;
        if(GAME_GOD[i]!=god) continue;
        if(!ExternalReady(CTGame:i)) formatex(line,charsmax(line),"\d%s \w[\rEklenti yüklenmedi\w]",GAME_NAMES[i]);
        else if(_:g_game==i) formatex(line,charsmax(line),"\r%s \w[\rAktif\w]",GAME_NAMES[i]);
        else formatex(line,charsmax(line),"\w%s",GAME_NAMES[i]);
        num_to_str(i,info,charsmax(info));CTItem(menu,line,info,g_menuCallback);
    }
    FC_CTMenuDisplay(id,menu);
}

public CB_GameItem(id,menu,item) {
    new key=ReadMenu(menu,item);
    return AliveCT(id) && key>0 && key<sizeof GAME_NAMES && ExternalReady(CTGame:key) && (!GAME_GOD[key] || g_godMode || key==_:CT_GAME_HUNGER)?ITEM_ENABLED:ITEM_DISABLED;
}

public H_GameList(id,menu,item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(!MenuActor(id,menu,item)) return PLUGIN_HANDLED;
    new key=ReadMenu(menu,item);menu_destroy(menu);
    if(key>0 && key<sizeof GAME_NAMES && (!GAME_GOD[key] || g_godMode || key==_:CT_GAME_HUNGER)) ShowGamePanel(id,CTGame:key);
    return PLUGIN_HANDLED;
}

ShowGamePanel(id,CTGame:game) {
    if(game==CT_GAME_ROCKET) {ShowRocketMenu(id);return;}
    new title[512],info[16];formatex(title,charsmax(title),"\w%s^n\d%s",GAME_NAMES[_:game],GAME_RULES[_:game]);
    new menu=CTMenu(title,"H_GamePanel");
    formatex(info,charsmax(info),"%d",_:game*10+1);CTItem(menu,"\wOyunu Başlat",info);
    formatex(info,charsmax(info),"%d",_:game*10+2);CTItem(menu,"\rOyunu Durdur",info);
    if(game==CT_GAME_HOGWARTS) {formatex(info,charsmax(info),"%d",_:game*10+3);CTItem(menu,"\wHogwarts / Nişandaki Oyuncuyu Haneye Ata",info);}
    if(game==CT_GAME_MILYONER) {formatex(info,charsmax(info),"%d",_:game*10+4);CTItem(menu,"\wSoru INI Dosyasını Yenile",info);}
    if(game==CT_GAME_INFECTION && g_game==game) {formatex(info,charsmax(info),"%d",_:game*10+5);CTItem(menu,"\wBir Mahkûmu Daha Enfekte Et",info);}
    if(game==CT_GAME_HUNGER) {formatex(info,charsmax(info),"%d",_:game*10+6);CTItem(menu,"\wAlan / İkmal Kutusu Koordinatlarını Ayarla",info);}
    FC_CTMenuDisplay(id,menu);
}

public H_GamePanel(id,menu,item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(!MenuActor(id,menu,item)) return PLUGIN_HANDLED;
    new key=ReadMenu(menu,item),CTGame:game=CTGame:(key/10),op=key%10;menu_destroy(menu);
    if(game<CT_GAME_KNIFE || _:game>=sizeof GAME_NAMES || !ExternalReady(game)) return PLUGIN_HANDLED;
    if(op==6 && game==CT_GAME_HUNGER) {ShowArenaMenu(id);return PLUGIN_HANDLED;}
    if(op==1) StartCTGame(game,id);
    else if(op==2) {if(g_game==game) StopCTGame(0,CT_STOP_MENU);else Chat(id,"Bu oyun aktif değil.");}
    else if(op==3 && game==CT_GAME_HOGWARTS) {hogwarts_menu(id);return PLUGIN_HANDLED;}
    else if(op==4 && game==CT_GAME_MILYONER) {new n=milyoner_reload(id);Chat(id,"INI dosyasından ^3%d ^1geçerli soru okundu.",n);}
    else if(op==5 && game==CT_GAME_INFECTION && g_game==game) {new candidates[MAXP],n;for(new target=1;target<=MaxClients;target++) if(IsEntrant(target) && g_color[target]!=1) candidates[n++]=target;if(n) InfectPlayer(candidates[random_num(0,n-1)]);else Chat(id,"Enfekte olmayan mahkûm kalmadı.");}
    ShowGamePanel(id,game);return PLUGIN_HANDLED;
}

LoadCTConfig() {
    for(new i=0;i<CFG_TOTAL;i++) g_cfg[i]=CFG_DEFAULTS[i];
    new f=fopen(CFG_FILE,"rt");if(!f) return;
    new line[768],key[64],value[512];
    while(!feof(f)) {
        fgets(f,line,charsmax(line));trim(line);
        if(!line[0] || line[0]==';' || line[0]=='#' || line[0]=='[') continue;
        strtok(line,key,charsmax(key),value,charsmax(value),'=');trim(key);trim(value);
        if(equali(key,"HARD_CVARS")) {copy(g_hardNames,charsmax(g_hardNames),value);continue;}
        if(equali(key,"HARD_PLUGINS")) {copy(g_hardPluginNames,charsmax(g_hardPluginNames),value);continue;}
        if(equali(key,"CELL_TARGETS")) {copy(g_cellTargets,charsmax(g_cellTargets),value);continue;}
        for(new i=0;i<CFG_TOTAL;i++) if(equali(key,CFG_KEYS[i])) {g_cfg[i]=clamp(str_to_num(value),0,100000);break;}
    }
    fclose(f);
    g_cfg[CFG_GAME_SECONDS]=clamp(g_cfg[CFG_GAME_SECONDS],30,1800);
    g_cfg[CFG_GREEN_MIN]=clamp(g_cfg[CFG_GREEN_MIN],1,20);g_cfg[CFG_GREEN_MAX]=max(g_cfg[CFG_GREEN_MIN],clamp(g_cfg[CFG_GREEN_MAX],1,30));
    g_cfg[CFG_RED_MIN]=clamp(g_cfg[CFG_RED_MIN],1,20);g_cfg[CFG_RED_MAX]=max(g_cfg[CFG_RED_MIN],clamp(g_cfg[CFG_RED_MAX],1,30));
    g_cfg[CFG_REFLEX_MIN]=clamp(g_cfg[CFG_REFLEX_MIN],1000,5000);g_cfg[CFG_REFLEX_STEP]=clamp(g_cfg[CFG_REFLEX_STEP],0,500);g_cfg[CFG_REFLEX_FAKE]=clamp(g_cfg[CFG_REFLEX_FAKE],0,50);
    g_cfg[CFG_RED_GRACE]=clamp(g_cfg[CFG_RED_GRACE],250,2000);g_cfg[CFG_REFLEX_WINDOW]=clamp(g_cfg[CFG_REFLEX_WINDOW],2000,5000);g_cfg[CFG_REFLEX_MIN]=min(g_cfg[CFG_REFLEX_MIN],g_cfg[CFG_REFLEX_WINDOW]);
    g_cfg[CFG_BOMB_SECONDS]=clamp(g_cfg[CFG_BOMB_SECONDS],5,60);
    g_cfg[CFG_HUNGER_RADIUS]=clamp(g_cfg[CFG_HUNGER_RADIUS],300,8000);g_cfg[CFG_HUNGER_MIN]=clamp(g_cfg[CFG_HUNGER_MIN],100,g_cfg[CFG_HUNGER_RADIUS]);
    g_cfg[CFG_HUNGER_SHRINK]=clamp(g_cfg[CFG_HUNGER_SHRINK],1,100);g_cfg[CFG_HUNGER_DAMAGE]=clamp(g_cfg[CFG_HUNGER_DAMAGE],1,100);
    g_cfg[CFG_CT_HP]=clamp(g_cfg[CFG_CT_HP],100,1000);g_cfg[CFG_CT_ARMOR]=clamp(g_cfg[CFG_CT_ARMOR],0,1000);
    g_cfg[CFG_SUMO_RADIUS]=clamp(g_cfg[CFG_SUMO_RADIUS],200,1200);g_cfg[CFG_SUMO_KNOCKBACK]=clamp(g_cfg[CFG_SUMO_KNOCKBACK],200,2500);
}

public plugin_natives() {
    register_library("fc_ct_view");
    register_native("fc_ct_fov_locked","N_FovLocked");
    register_native("fc_ct_external_begin","N_ExternalBegin");
    register_native("fc_ct_external_end","N_ExternalEnd");
    register_library("fc_ctmenu");
    register_library("fc_ct_rocket");
    set_native_filter("NativeFilter");
    register_native("fc_ctmenu_open", "N_Open");
    register_native("fc_ct_game_start", "N_Start");
    register_native("fc_ct_game_stop", "N_Stop");
    register_native("fc_ct_game_active", "N_Active");
    register_native("fc_ct_game_id", "N_GameID");
    register_native("fc_ct_is_player", "N_Player");
    register_native("fc_ct_rocket_active","N_RocketActive");
    register_native("fc_ct_rocket_is_player","N_RocketPlayer");
    register_native("fc_ct_get_warden", "N_Warden");
    register_native("fc_ct_hard_active", "N_Hard");
    register_native("fc_ct_set_hard", "N_SetHard");
    register_native("fc_ct_god_active", "N_God");
    register_native("fc_ct_provider_allowed", "N_ProviderAllowed");
    register_native("fc_ct_mode_queue", "N_Queue");
    register_native("fc_ct_hud_text", "N_HudText");
    register_native("fc_ct_hud_visible", "N_HudVisible");
}

public NativeFilter(const name[], index, trap) {
    if(!trap && (contain(name,"hogwarts_")==0 || contain(name,"milyoner_")==0 || contain(name,"fc_")==0)) return PLUGIN_HANDLED;
    return PLUGIN_CONTINUE;
}

public plugin_precache() {
    LegacyPrecache();
    precache_model(FISTS_MODEL);ReflexPrecache();
    g_rocketSprite=precache_model(file_exists("sprites/fc_hogwarts/fire.spr")?"sprites/fc_hogwarts/fire.spr":"sprites/zerogxplode.spr");
    precache_sound("fc_ctmenu_v120/fists/draw_hit.wav");
    precache_sound("fc_ctmenu_v120/fists/knife_deploy1.wav");
    precache_sound("fc_ctmenu_v120/fists/knife_hit1.wav");
    precache_sound("fc_ctmenu_v120/fists/knife_hit2.wav");
    precache_sound("fc_ctmenu_v120/fists/knife_hit3.wav");
    precache_sound("fc_ctmenu_v120/fists/knife_hit4.wav");
    precache_sound("fc_ctmenu_v120/fists/knife_hitwall1.wav");
    precache_sound("fc_ctmenu_v120/fists/knife_hitwall2.wav");
    precache_sound("fc_ctmenu_v120/fists/knife_slash-1.wav");
    precache_sound("fc_ctmenu_v120/fists/knife_slash1.wav");
    precache_sound("fc_ctmenu_v120/fists/knife_slash2.wav");
    precache_sound("fc_ctmenu_v120/fists/knife_stab.wav");

    if(file_exists(CRATE_MODEL)) copy(g_lootModel,charsmax(g_lootModel),CRATE_MODEL);
    else copy(g_lootModel,charsmax(g_lootModel),"models/w_c4.mdl");
    new path[160];for(new i;i<sizeof CT_SOUNDS;i++) {
        formatex(path,charsmax(path),"sound/%s",CT_ORIGINAL_SOUNDS[i]);
        if(file_exists(path)) copy(g_soundPath[i],charsmax(g_soundPath[]),CT_ORIGINAL_SOUNDS[i]);
        else copy(g_soundPath[i],charsmax(g_soundPath[]),CT_SOUNDS[i]);
        formatex(path,charsmax(path),"sound/%s",g_soundPath[i]);
        if(file_exists(path)) {precache_sound(g_soundPath[i]);g_soundReady[i]=true;}
    }
    precache_model(g_lootModel);
    g_beam=precache_model(file_exists(BEAM_SPRITE) ? BEAM_SPRITE : "sprites/laserbeam.spr");
    g_lineBeam=precache_model("sprites/laserbeam.spr");
}

public plugin_init() {
    LegacyInit();arrayset(g_bridgeMenu,-1,sizeof g_bridgeMenu);
    register_logevent("BridgeRoundEnd",2,"1=Round_End");
    arrayset(g_lineMenu,-1,sizeof g_lineMenu);ReflexInitMessages();
    arrayset(g_protectionMenu,-1,sizeof g_protectionMenu);arrayset(g_protectionChoice,-1,sizeof g_protectionChoice);g_protectionCallback=menu_makecallback("CB_ProtectionVote");
    register_plugin("FeliciaClan CT Menu",VERSION,"n.dgn, LyNcH / FeliciaClan");
     
    register_clcmd("say /ct","CmdMenu");
    register_clcmd("say /ping","CmdPing");
    register_clcmd("say_team /ping","CmdPing");
    register_clcmd("say /lazerduvari","CmdLaserWall");
    register_clcmd("say_team /lazerduvari","CmdLaserWall");  
    register_clcmd("say /ctstop","CmdStop");
    register_clcmd("say /ctmarket","CmdMarket"); register_clcmd("CTMARKET","CmdMarket");
     
    register_clcmd("say /cthud","CmdHud");
    register_clcmd("say /hardkomut","CmdHard");
    register_clcmd("say_team /sirala","CmdLineup");
    register_clcmd("say_team /getir","CmdBring");
    
    
    
    register_clcmd("say_team /c4","CmdC4");register_clcmd("say_team /c4menu","CmdC4");
    register_clcmd("say_team /rocket","CmdRocket");
    register_clcmd("say /korumaoy","CmdProtectionVote");register_clcmd("say_team /korumaoy","CmdProtectionVote");
    register_clcmd("radio1","CmdHardFeature"); register_clcmd("+parachute","CmdHardFeature");
    register_clcmd("say","HookSay"); register_clcmd("say_team","HookSay");
    register_clcmd("fc_ct_value","CmdValue");
    register_concmd("amx_ctcredit","CmdCredit",ADMIN_RCON,"<oyuncu> <miktar>");
    register_concmd("amx_ctmenu_status","CmdStatus",ADMIN_KICK);
    
    register_event("TeamInfo","OnTeam","a");
    RegisterHookChain(RG_CBasePlayer_Spawn,"OnSpawn",true);
    RegisterHookChain(RG_CBasePlayer_Killed,"OnKilled",true);
    RegisterHookChain(RG_CBasePlayer_TakeDamage,"OnDamage",false);
    RegisterHookChain(RG_CBasePlayer_ResetMaxSpeed,"OnSpeed",true);
    RegisterHookChain(RG_CBasePlayer_AddPlayerItem,"OnPickup",false);
    RegisterHookChain(RG_CBasePlayer_DropPlayerItem,"OnDrop",false);
    RegisterHookChain(RG_CBasePlayerWeapon_DefaultDeploy,"OnFistsDeploy",true);
    register_forward(FM_CmdStart,"OnCmdStart");
    set_task(0.05,"LaserWallThink",TASK_LASER_WALL,"",0,"b");
    register_touch("player","player","OnTouchPlayers");
    register_touch("grenade","player","OnDodgeballGrenadeTouch");
    register_touch(LOOT_CLASS,"player","OnLoot");
    register_event("CurWeapon","OnWeapon","be","1=1");
    g_menuCallback=menu_makecallback("CB_GameItem");
    
    g_marketCB=menu_makecallback("CB_CTPerk");
    g_cvarFF=get_cvar_pointer("mp_friendlyfire");
    g_cvarFFA=get_cvar_pointer("mp_freeforall");
    g_cvarInfinite=get_cvar_pointer("mp_round_infinite");
    g_fwPrepare=CreateMultiForward("fc_ct_game_prepare",ET_IGNORE,FP_CELL,FP_CELL);
    g_fwRocketPrepare=CreateMultiForward("fc_ct_rocket_prepare",ET_IGNORE,FP_CELL,FP_CELL);
    g_fwRocketFinished=CreateMultiForward("fc_ct_rocket_finished",ET_IGNORE);
    g_fwStarted=CreateMultiForward("fc_ct_game_started",ET_IGNORE,FP_CELL,FP_CELL,FP_CELL);
    g_fwFinished=CreateMultiForward("fc_ct_game_finished",ET_IGNORE,FP_CELL,FP_CELL,FP_CELL);
    g_fwHard=CreateMultiForward("fc_ct_hard_changed",ET_IGNORE,FP_CELL);
    g_hardStatus=register_cvar("fc_ct_hard","0");set_pcvar_num(g_hardStatus,0);
    g_vault=nvault_open("FeliciaClan_CTWallet");
    for(new id=1;id<=MaxClients;id++) g_showInfo[id]=true;
    set_task(1.0,"Heartbeat",TASK_HEARTBEAT,"",0,"b");
}

public plugin_cfg() {LegacyCfg(); LoadCTConfig(); LoadArena(); }

public plugin_end() {
    BridgeReset(CT_STOP_PLUGIN,false);LegacyEnd();
    StopAllFormations();StopCTGame(0,CT_STOP_PLUGIN); ResetTools();
    remove_task(TASK_HEARTBEAT); remove_task(TASK_CHECK); remove_task(TASK_LASER_WALL);
    if(g_vault>=0) nvault_close(g_vault);
    DestroyForward(g_fwPrepare); DestroyForward(g_fwStarted); DestroyForward(g_fwFinished);
    DestroyForward(g_fwRocketPrepare);DestroyForward(g_fwRocketFinished);
    DestroyForward(g_fwHard);
}

public client_putinserver(id) {
    CancelLoadout(id);g_spawnLife[id]++;
    LegacyPut(id);BridgeClearSlot(id);g_prevButtons[id]=0;g_pingNext[id]=0.0;
    FC_ResetPanelHud(id);g_standaloneHud[id]=false;
    g_reflexShown[id]=g_reflexDirty[id]=false;g_reflexWeapon[id]=g_reflexClip[id]=g_reflexFov[id]=0;g_reflexDefined[id]=-1;
    arrayset(g_reflexAmmoKnown[id],false,sizeof g_reflexAmmoKnown[]);g_buriedUID[id]=0;g_buryFull[id]=false;g_buryUntil[id]=0.0;
    g_requestedAction[id]=0;g_lineMenu[id]=-1;g_lineAxis[id]=2;g_lineSpacing[id]=48;
    g_part[id]=false; g_partUID[id]=0; g_color[id]=0; g_toolFrozen[id]=false;
    g_snap[0][id][SS_VALID]=g_snap[1][id][SS_VALID]=g_snap[SNAP_ROCKET][id][SS_VALID]=0;
    g_rocketTargetUID[id]=g_rocketGuardUID[id]=0;
    g_target[id]=0;g_targetUID[id]=0;g_input[id]=0;g_showInfo[id]=true;
    arrayset(g_perk[id],false,5); g_localTL[id]=g_cfg[CFG_LOCAL_START];g_auth[id][0]=0;
    g_nextGuess[id]=g_nextRegen[id]=g_touchNext[id]=0.0;
    g_hardUID[id]=0;LoadWallet(id);
}

public client_authorized(id) { LoadWallet(id); }

public client_disconnected(id) {
    CancelLoadout(id);g_spawnLife[id]++;
    LaserWallRemove(id);g_pingNext[id]=0.0;g_prevButtons[id]=0;
    LegacyDisconnect(id);BridgeClearSlot(id);
    RocketDrop(id);
    if(id==g_protectionActor) CancelProtectionVote();g_protectionVoterUID[id]=0;
    if(g_protectionMenu[id]>=0) {menu_destroy(g_protectionMenu[id]);g_protectionMenu[id]=-1;}
    if(id==g_c4CountdownActor) CancelC4Countdown();
    g_c4CountdownTargets[id]=0;
    g_reflexShown[id]=g_reflexDirty[id]=false;g_buriedUID[id]=0;g_buryFull[id]=false;g_buryUntil[id]=0.0;
    StopFormation(id);g_requestedAction[id]=0;SaveWallet(id); DropEntrant(id,false);
    if(g_warden==id) g_warden=0;
    if(g_lastDead==id) g_lastDead=0;
    g_input[id]=0; g_toolFrozen[id]=false;
    g_snap[0][id][SS_VALID]=g_snap[1][id][SS_VALID]=0;
    ScheduleWinnerCheck();
}

bool:AliveCT(id) { return id>=1 && id<=MaxClients && is_user_alive(id) && get_member(id,m_iTeam)==TEAM_CT; }

bool:AliveT(id) { return id>=1 && id<=MaxClients && is_user_alive(id) && get_member(id,m_iTeam)==TEAM_TERRORIST; }

bool:HasControl(id) {
    if(g_externalToken>0 && id) return false;
    if(g_bridgeRoundClosed) return false;
    if(!id) return true;
    if(!AliveCT(id)) return false;
    return true;
}

bool:IsEntrant(id) {
    return id>=1 && id<=MaxClients && g_part[id] && AliveT(id) && get_user_userid(id)==g_partUID[id];
}

CountT() { new n;for(new id=1;id<=MaxClients;id++) if(AliveT(id)) n++;return n; }

bool:HasCT() { for(new id=1;id<=MaxClients;id++) if(AliveCT(id)) return true;return false; }

bool:ExternalReady(CTGame:game) {
    if(game==CT_GAME_HOGWARTS) return bool:LibraryExists("fc_hogwarts",LibType_Library);
    if(game==CT_GAME_MILYONER) return bool:LibraryExists("fc_milyoner",LibType_Library);
    return true;
}

bool:NativeAllowed(plugin, caller) {
    if(!caller) return true;
    if(!HasControl(caller)) { log_amx("CT native denied: plugin=%d caller=%d",plugin,caller);return false; }
    return true;
}

public N_Open(plugin,argc) { new id=get_param(1);if(!AliveCT(id)) return 0;ShowMain(id);return 1; }

public N_Start(plugin,argc) { new id=argc>=2?get_param(2):0;return NativeAllowed(plugin,id)?StartCTGame((CTGame:get_param(1)),id):0; }

public N_Stop(plugin,argc) {new id=argc?get_param(1):0;if(id && !AliveCT(id)) return 0;BridgeReset(CT_STOP_MENU,true);return 1;}

public N_Active(plugin,argc) {return g_externalToken>0 || g_game!=CT_GAME_NONE || g_bridgeLegacy;}

public N_GameID(plugin,argc) {return g_externalToken>0?1001:g_bridgeLegacy?1000:_:g_game;}

public N_Player(plugin,argc) {new id=get_param(1);if(g_externalToken>0) return id>=1 && id<=MaxClients && is_user_alive(id);return id>=1 && id<=MaxClients && is_user_connected(id) && (g_bridgeLegacy?(g_bridgeUID[id]==get_user_userid(id) && AliveT(id)):(g_game!=CT_GAME_NONE && g_part[id] && get_user_userid(id)==g_partUID[id]));}

public N_RocketActive(plugin,argc) {return g_rocketActive;}

public N_RocketPlayer(plugin,argc) {new id=get_param(1);return g_rocketActive && id>=1 && id<=MaxClients && is_user_connected(id) && (get_user_userid(id)==g_rocketTargetUID[id] || get_user_userid(id)==g_rocketGuardUID[id]);}

public N_Warden(plugin,argc) { return 0; }

public N_God(plugin,argc) {return g_godMode;}

public N_ProviderAllowed(plugin,argc) {return ProviderAllowed(CTGame:get_param(1),get_param(2));}

public N_Queue(plugin,argc) {return BridgeQueueMode(bool:get_param(1),get_param(2));}

public N_HudVisible(plugin,argc) {new id=get_param(1);return id>=1 && id<=MaxClients && g_showInfo[id];}

public N_HudText(plugin,argc) {new text[384],id=get_param(1);if(id<1 || id>MaxClients) return 0;BuildCTInfo(id,text,charsmax(text));set_string(2,text,get_param(3));return 1;}

public CmdC4(id) {if(AliveCT(id)) ShowC4Menu(id);return PLUGIN_HANDLED;}

ShowC4Menu(id)
{
    if(!AliveCT(id)) return;
    new menu=CTMenu("\wC4 Menü","H_C4");menu_setprop(menu,MPROP_PERPAGE,0);menu_setprop(menu,MPROP_EXIT,MEXIT_FORCE);menu_setprop(menu,MPROP_EXITNAME,"\wÇıkış");
    CTItem(menu,"\wMahkûmları Göm","1");CTItem(menu,"\wTamamen Göm \d[God]","2");
    CTItem(menu,"\wMahkûmları Kaldır","3");CTItem(menu,g_c4CountdownEnd>0.0?"\rSüreli Gömü Durdur":"\wSüreli Göm","4");
    CTItem(menu,"\wMahkûmlara C4 Ver","5");CTItem(menu,"\wDisarm / Bıçak Bırak","6");
    CTItem(menu,"\wNişangâhtaki Mahkûmu Göm","7");CTItem(menu,"\wNişangâhtaki Mahkûmu Kaldır","8");
    CTItem(menu,"\wCT Takımına Deagle Ver","9");FC_CTMenuDisplay(id,menu);
}

public H_C4(id,menu,item)
{
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(!MenuActor(id,menu,item)) return PLUGIN_HANDLED;
    new op=ReadMenu(menu,item);menu_destroy(menu);
    if(!ToolsAllowed(id)) return PLUGIN_HANDLED;
    if(op==2 && !g_godMode) {Chat(id,"Tamamen göm için bu el Godmode açık olmalı.");ShowC4Menu(id);return PLUGIN_HANDLED;}
    if(op==4) {
        if(g_c4CountdownEnd>0.0) {CancelC4Countdown();Chat(0,"^3%n ^1süreli göm geri sayımını durdurdu.",id);ShowC4Menu(id);}
        else ShowC4Time(id);
        return PLUGIN_HANDLED;
    }
    if(op==1 || op==2 || op==3) CancelC4Countdown();
    if(op==7 || op==8) {new target,body;get_user_aiming(id,target,body);if(AliveT(target)) {if(op==7) C4Bury(target,false,0.0);else C4Lift(target);}else Chat(id,"Yaşayan bir mahkûma nişan al.");}
    else for(new target=1;target<=MaxClients;target++) {
        if(AliveT(target)) {
            if(op==1 || op==2) C4Bury(target,op==2,0.0);
            else if(op==3) C4Lift(target);
            else if(op==5) {SaveState(target,SNAP_TOOL);if(!user_has_weapon(target,CSW_C4)) rg_give_item(target,"weapon_c4");}
            else if(op==6) {SaveState(target,SNAP_TOOL);rg_remove_all_items(target);rg_give_item(target,"weapon_knife");}
        }
        if(op==9 && AliveCT(target)) {SaveState(target,SNAP_TOOL);rg_give_item(target,"weapon_deagle",GT_REPLACE);rg_set_user_bpammo(target,WEAPON_DEAGLE,35);}
    }
    Chat(0,"^3%n ^1C4 menüsündeki işlemi uyguladı.",id);PlayCTSound(SND_NOTICE);ShowC4Menu(id);return PLUGIN_HANDLED;
}

ShowC4Time(id)
{
    new menu=CTMenu("\wSüreli Göm","H_C4Time");
    CTItem(menu,"\w5 Saniye Sonra Göm","5");CTItem(menu,"\w10 Saniye Sonra Göm","10");CTItem(menu,"\w20 Saniye Sonra Göm","20");CTItem(menu,"\w30 Saniye Sonra Göm","30");CTItem(menu,"\wGeri Sayımı Durdur / Gömülenleri Kaldır","0");FC_CTMenuDisplay(id,menu);
}

public H_C4Time(id,menu,item)
{
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(!MenuActor(id,menu,item)) return PLUGIN_HANDLED;
    new seconds=ReadMenu(menu,item);menu_destroy(menu);
    if(!ToolsAllowed(id)) return PLUGIN_HANDLED;
    if(seconds!=0 && seconds!=5 && seconds!=10 && seconds!=20 && seconds!=30) return PLUGIN_HANDLED;
    if(!seconds) {CancelC4Countdown();for(new target=1;target<=MaxClients;target++) C4Lift(target);}
    else StartC4Countdown(id,seconds);
    ShowC4Menu(id);return PLUGIN_HANDLED;
}

StartC4Countdown(id,seconds)
{
    if(g_protectionEnd>0.0) {Chat(id,"Önce koruma oylamasını durdur.");return 0;}
    if(!AliveCT(id) || !ToolsAllowed(id) || seconds<1) return 0;
    CancelC4Countdown();new targets;
    for(new target=1;target<=MaxClients;target++) if(AliveT(target)) {g_c4CountdownTargets[target]=get_user_userid(target);targets++;}
    if(!targets) {Chat(id,"Süreli göm için yaşayan mahkûm bulunamadı.");return 0;}
    g_c4CountdownActor=id;g_c4CountdownUID=get_user_userid(id);g_c4CountdownEnd=get_gametime()+float(seconds);g_c4CountdownSecond=-1;
    Chat(0,"^3%n ^1süreli göm başlattı. Mahkûmlar ^4%d saniye sonra ^1gömülecek.",id,seconds);
    PlayCTSound(SND_COUNTDOWN);set_task(0.1,"C4CountdownTick",TASK_C4_COUNTDOWN,"",0,"b");C4CountdownTick();return 1;
}

CancelC4Countdown()
{
    remove_task(TASK_C4_COUNTDOWN);
    if(g_c4CountdownEnd>0.0) for(new id=1;id<=MaxClients;id++) if(is_user_connected(id)) FC_SendPanelHud(id,"",255,110,40,-1.0,0.28,1,0.1);
    g_c4CountdownEnd=0.0;g_c4CountdownActor=g_c4CountdownUID=0;g_c4CountdownSecond=-1;arrayset(g_c4CountdownTargets,0,sizeof g_c4CountdownTargets);
}

public C4CountdownTick()
{
    if(g_c4CountdownEnd<=0.0) {remove_task(TASK_C4_COUNTDOWN);return;}
    if(g_game || !AliveCT(g_c4CountdownActor) || get_user_userid(g_c4CountdownActor)!=g_c4CountdownUID) {CancelC4Countdown();return;}
    new Float:remaining=g_c4CountdownEnd-get_gametime();
    if(remaining<=0.0) {
        new buried;
        for(new target=1;target<=MaxClients;target++) if(g_c4CountdownTargets[target] && AliveT(target) && get_user_userid(target)==g_c4CountdownTargets[target]) buried+=C4Bury(target,false,0.0);
        CancelC4Countdown();
        Chat(0,"Süreli göm tamamlandı. ^4%d mahkûm ^1gömüldü.",buried);if(buried) PlayCTSound(SND_TRAP);return;
    }
    new seconds=floatround(remaining,floatround_ceil);if(seconds==g_c4CountdownSecond) return;
    g_c4CountdownSecond=seconds;new text[144];formatex(text,charsmax(text),"SÜRELİ GÖM^nMahkûmlar %d saniye sonra gömülecek!",seconds);
    for(new id=1;id<=MaxClients;id++) if(is_user_connected(id)) FC_SendPanelHud(id,text,255,110,40,-1.0,0.28,1,1.2);
}

C4Bury(id,bool:full,Float:until)
{
    if(!AliveT(id)) return 0;
    if(g_buriedUID[id]==get_user_userid(id)) {if(until>0.0) g_buryUntil[id]=until;return 0;}
    g_buriedUID[id]=get_user_userid(id);get_entvar(id,var_origin,g_buryOrigin[id]);
    g_buryFlags[id]=get_entvar(id,var_flags);g_buryUntil[id]=until;
    new Float:origin[3],Float:viewOffset[3],Float:mins[3];for(new axis;axis<3;axis++) origin[axis]=g_buryOrigin[id][axis];
    get_entvar(id,var_view_ofs,viewOffset);get_entvar(id,var_mins,mins);
    new Float:depth=full?40.0:35.0,Float:eyeLimit=viewOffset[2]-mins[2]-6.0;
    if(eyeLimit>0.0) depth=floatmin(depth,eyeLimit);
    origin[2]-=depth;
    // Preserve bunnyhop momentum across the teleport used for burying.
    // SetOrigin can disturb the player's current movement state.
    new Float:buryVelocity[3];
    if(!full) get_entvar(id,var_velocity,buryVelocity);
    engfunc(EngFunc_SetOrigin,id,origin);
    if(!full) set_entvar(id,var_velocity,buryVelocity);
    // Only the explicit full-bury action owns a movement lock.
    if(full) {set_entvar(id,var_velocity,Float:{0.0,0.0,0.0});g_buryFull[id]=true;GameFreeze(id,true);}
    return 1;
}

C4Lift(id)
{
    if(id<1 || id>MaxClients) return;
    new uid=g_buriedUID[id];g_buriedUID[id]=0;g_buryUntil[id]=0.0;
    if(uid && is_user_alive(id) && get_user_userid(id)==uid) {
        if(g_buryFull[id]) {
            engfunc(EngFunc_SetOrigin,id,g_buryOrigin[id]);set_entvar(id,var_velocity,Float:{0.0,0.0,0.0});
            GameFreeze(id,(g_buryFlags[id]&FL_FROZEN)!=0 || g_toolFrozen[id]);
        } else {
            // If the player has already jumped out of the ground, do not
            // teleport upward on a later Lift command.
            new Float:currentPos[3];
            get_entvar(id,var_origin,currentPos);
            // Do not lift a jumping player or treat an old airborne
            // burial position as proof that the player is still embedded.
            // Only a player buried while grounded and still grounded can be raised.
            if(!(g_buryFlags[id]&FL_ONGROUND) || !(get_entvar(id,var_flags)&FL_ONGROUND) || currentPos[2]>=g_buryOrigin[id][2]-8.0) {
                g_buryFull[id]=false;
                return;
            }
            // A jumping/moving player may have travelled since being buried.
            // Lift vertically only; never rewind XY, lower an airborne player,
            // or overwrite the velocity accumulated before/during the jump.
            new Float:origin[3];get_entvar(id,var_origin,origin);
            // Restore only the burial displacement, not the old airborne height.
            // The saved Z may be high if the player was bunnyhopping when buried.
            if(origin[2]<g_buryOrigin[id][2]-8.0) {
                origin[2]+=35.0;
                engfunc(EngFunc_SetOrigin,id,origin);
            }
        }
    }
    g_buryFull[id]=false;
}

ReflexPrecache()
{
    g_reflexAssetsReady=true;new txt[128],spr[128];
    for(new i;i<sizeof REFLEX_HUD_NAMES;i++) {
        formatex(txt,charsmax(txt),"sprites/%s.txt",REFLEX_HUD_NAMES[i]);
        formatex(spr,charsmax(spr),"sprites/FeliciaClan_CT/%s.spr",REFLEX_HUD_NAMES[i]);
        if(file_exists(txt) && file_exists(spr)) {precache_generic(txt);precache_generic(spr);}
        else {g_reflexAssetsReady=false;log_amx("[FC] Refleks SPR eksik: %s",spr);}
    }
}

ReflexInitMessages()
{
    g_msgReflexList=get_user_msgid("WeaponList");g_msgReflexWeapon=get_user_msgid("CurWeapon");g_msgReflexFov=get_user_msgid("SetFOV");
    if(g_msgReflexList) register_message(g_msgReflexList,"ReflexTrackList");
    if(g_msgReflexWeapon) register_message(g_msgReflexWeapon,"ReflexTrackWeapon");
    if(g_msgReflexFov) register_message(g_msgReflexFov,"ReflexTrackFov");
    for(new i;i<sizeof REFLEX_HUD_NAMES;i++) register_clcmd(REFLEX_HUD_NAMES[i],"IgnoreReflexWeapon");
}

public IgnoreReflexWeapon(id) {return PLUGIN_HANDLED;}

public ReflexTrackList(msg,dest,id)
{
    if(id<1 || id>MaxClients || g_reflexSending[id] || get_msg_args()!=9) return PLUGIN_CONTINUE;
    new weapon=get_msg_arg_int(8);if(weapon<1 || weapon>30 || weapon==2) return PLUGIN_CONTINUE;
    for(new i;i<4;i++) g_reflexAmmo[id][weapon][i]=get_msg_arg_int(i+2);
    g_reflexAmmoKnown[id][weapon]=true;
    if(g_reflexShown[id]) {g_reflexDefined[id]=-1;g_reflexDirty[id]=true;}
    return PLUGIN_CONTINUE;
}

public ReflexTrackWeapon(msg,dest,id)
{
    if(id<1 || id>MaxClients || g_reflexSending[id] || get_msg_args()!=3 || !get_msg_arg_int(1)) return PLUGIN_CONTINUE;
    new weapon=get_msg_arg_int(2);if(weapon<1 || weapon>30 || weapon==2) return PLUGIN_CONTINUE;
    g_reflexWeapon[id]=weapon;g_reflexClip[id]=get_msg_arg_int(3);
    if(g_game==CT_GAME_REFLEX && g_phase==1) {if(g_reflexShown[id]) set_msg_arg_int(1,ARG_BYTE,0);g_reflexDirty[id]=true;}
    return PLUGIN_CONTINUE;
}

public ReflexTrackFov(msg,dest,id)
{
    if(id>=1 && id<=MaxClients && !g_reflexSending[id] && get_msg_args()==1) {g_reflexFov[id]=get_msg_arg_int(1);if(g_game==CT_GAME_REFLEX) g_reflexDirty[id]=true;}
    return PLUGIN_CONTINUE;
}

ReflexFov(id,value) {g_reflexSending[id]=true;message_begin(MSG_ONE,g_msgReflexFov,{0,0,0},id);write_byte(value);message_end();g_reflexSending[id]=false;}

ReflexWeapon(id,active,weapon,clip) {g_reflexSending[id]=true;message_begin(MSG_ONE,g_msgReflexWeapon,{0,0,0},id);write_byte(active);write_byte(weapon);write_byte(clip&255);message_end();g_reflexSending[id]=false;}

ClearReflexSprite(id,bool:restore=true)
{
    new bool:shown=g_reflexShown[id];g_reflexShown[id]=false;g_reflexDirty[id]=false;g_reflexDefined[id]=-1;
    if(!shown || !is_user_connected(id)) return;
    if(restore) ReflexFov(id,g_reflexFov[id]);
    if(is_user_alive(id)) {new clip,ammo,weapon=get_user_weapon(id,clip,ammo);ReflexWeapon(id,weapon>0,weapon,clip);}
    else ReflexWeapon(id,0,0,0);
}

DrawReflexSprites()
{
    for(new id=1;id<=MaxClients;id++) {
        if(!g_reflexAssetsReady || g_reflexStarting || g_game!=CT_GAME_REFLEX || g_phase!=1 || (!IsEntrant(id) && !AliveCT(id))) {ClearReflexSprite(id);continue;}
        if(!g_msgReflexList || !g_msgReflexWeapon || !g_msgReflexFov || is_user_bot(id) || is_user_hltv(id)) continue;
        if(!g_reflexShown[id]) {new clip,ammo;g_reflexWeapon[id]=get_user_weapon(id,clip,ammo);g_reflexClip[id]=clip;g_reflexDirty[id]=true;}
        new weapon=g_reflexWeapon[id],drawing=g_reflexAction+(g_reflexFake?5:0);
        if(weapon<1 || weapon>30 || weapon==2) continue;
        if(g_reflexDefined[id]!=drawing) g_reflexDirty[id]=true;
        if(!g_reflexDirty[id]) continue;
        message_begin(MSG_ONE,g_msgReflexList,{0,0,0},id);write_string(REFLEX_HUD_NAMES[drawing]);
        for(new i;i<4;i++) write_byte(g_reflexAmmoKnown[id][weapon]?g_reflexAmmo[id][weapon][i]:255);
        write_byte(0);write_byte(0);write_byte(REFLEX_HUD_WEAPON);write_byte(0);message_end();
        ReflexFov(id,89);ReflexWeapon(id,1,REFLEX_HUD_WEAPON,g_reflexClip[id]);ReflexFov(id,g_reflexFov[id]);
        g_reflexShown[id]=true;g_reflexDirty[id]=false;g_reflexDefined[id]=drawing;
    }
}

Float:ReflexWindow() {return float(max(g_cfg[CFG_REFLEX_MIN],g_cfg[CFG_REFLEX_WINDOW]-(g_rounds/3)*g_cfg[CFG_REFLEX_STEP]))/1000.0;}

bool:ReflexAwaitLanding()
{
    new bool:waiting;
    for(new id=1;id<=MaxClients;id++) if(g_reflexLanding[id]) {
        if(!IsEntrant(id) || (get_entvar(id,var_flags)&FL_ONGROUND)) g_reflexLanding[id]=false;
        else waiting=true;
    }
    return waiting;
}

TickReflex(Float:now)
{
    if(now<g_phaseEnd) {DrawReflexSprites();return;}
    if(g_phase==1) {
        for(new id=1;id<=MaxClients;id++) if(IsEntrant(id) && !g_ready[id]) Eliminate(id,"Komutu zamanında yapmadı");
        g_rounds++;g_phase=0;g_phaseEnd=now+floatmax(0.8,1.1-float(g_rounds)*0.02);
        for(new id=1;id<=MaxClients;id++) ClearReflexSprite(id);
    }
    else {
        // A correct late jump must finish before a Stop/Fake or another cue.
        if(ReflexAwaitLanding()) return;
        g_reflexAction=random_num(0,4);g_reflexFake=random_num(1,100)<=g_cfg[CFG_REFLEX_FAKE];g_phase=1;
        g_graceEnd=now+0.5;g_phaseEnd=g_graceEnd+ReflexWindow();
        for(new id=1;id<=MaxClients;id++) {g_ready[id]=g_reflexFake || g_reflexAction==4;if(IsEntrant(id)) get_entvar(id,var_origin,g_anchor[id]);}
        DrawReflexSprites();DrawGameHud();
    }
}

ReflexInput(id,uc,buttons,rising)
{
    new Float:forwardMove,Float:sideMove,Float:now=get_gametime();
    get_uc(uc,UC_ForwardMove,forwardMove);get_uc(uc,UC_SideMove,sideMove);
    if(now>g_phaseEnd) return;
    if(g_reflexFake || g_reflexAction==4) {
        new Float:origin[3];get_entvar(id,var_origin,origin);
        if(now<=g_graceEnd) {for(new axis;axis<3;axis++) g_anchor[id][axis]=origin[axis];return;}
        if((buttons&(IN_JUMP|IN_DUCK)) || floatabs(forwardMove)>30.0 || floatabs(sideMove)>30.0 || vector_distance(origin,g_anchor[id])>4.0) Eliminate(id,g_reflexFake?"Sahte komuta uydu":"Dur komutunda hareket etti");
        return;
    }
    if(g_reflexAction==0 && (rising&IN_JUMP)) {g_ready[id]=true;g_reflexLanding[id]=true;}
    else if(g_reflexAction==1 && (rising&IN_DUCK)) g_ready[id]=true;
    else if(g_reflexAction==2 && sideMove< -30.0) g_ready[id]=true;
    else if(g_reflexAction==3 && sideMove>30.0) g_ready[id]=true;
    if(now>g_graceEnd && ((g_reflexAction!=0 && (rising&IN_JUMP)) || (g_reflexAction!=1 && (rising&IN_DUCK)) || (g_reflexAction==2 && sideMove>30.0) || (g_reflexAction==3 && sideMove< -30.0))) Eliminate(id,"Yanlış komutu yaptı");
}

public OnFistsDeploy(weapon)
{
    new id=get_member(weapon,m_pPlayer);
    if(g_game==CT_GAME_KNIFE && IsEntrant(id) && get_member(weapon,m_iId)==WEAPON_KNIFE) {set_entvar(id,var_viewmodel,FISTS_MODEL);set_entvar(id,var_weaponmodel,"");}
}

InfectPlayer(id)
{
    if(g_game!=CT_GAME_INFECTION || !IsEntrant(id) || g_color[id]==1) return 0;
    g_color[id]=1;g_infectionNextHP[id]=get_gametime()+0.5;Glow(id,0,255,0);
    message_begin(MSG_ONE_UNRELIABLE,get_user_msgid("ScreenFade"),_,id);
    write_short(2<<10);write_short(1<<7);write_short(1<<12);write_byte(0);write_byte(255);write_byte(0);write_byte(200);message_end();
    Chat(0,"^3%n ^1enfekte oldu. Yeşil oyuncuya yaklaşma!",id);return 1;
}

TickInfection(Float:now)
{
    for(new id=1;id<=MaxClients;id++) if(IsEntrant(id) && g_color[id]==1 && now>=g_infectionNextHP[id]) {
        new ticks=1+max(0,floatround((now-g_infectionNextHP[id])/0.5,floatround_floor));g_infectionNextHP[id]+=float(ticks)*0.5;
        new Float:hp;get_entvar(id,var_health,hp);hp-=float(ticks*3);
        if(hp<=0.0) {Eliminate(id,"Enfeksiyon canını tüketti");CheckWinner();if(g_game!=CT_GAME_INFECTION) return;continue;}
        set_entvar(id,var_health,hp);new Float:origin[3];get_entvar(id,var_origin,origin);
        new area[3];for(new axis;axis<3;axis++) area[axis]=floatround(origin[axis]);
        message_begin(MSG_PVS,SVC_TEMPENTITY,area);write_byte(TE_DLIGHT);
        write_coord_f(origin[0]);write_coord_f(origin[1]);write_coord_f(origin[2]);write_byte(12);write_byte(0);write_byte(255);write_byte(0);write_byte(5);write_byte(0);message_end();
    }
}

TickReflexStart(Float:now)
{
    new seconds=max(0,floatround(g_reflexStartEnd-now,floatround_ceil));
    if(seconds==g_reflexStartSecond) return;g_reflexStartSecond=seconds;
    if(!seconds) {
        g_reflexStarting=false;
        for(new id=1;id<=MaxClients;id++) if(is_user_alive(id)) {GameFreeze(id,false);g_prevButtons[id]=0;}
        g_phase=0;g_phaseEnd=now;TickReflex(now);
    }
    new text[96];formatex(text,charsmax(text),seconds?"FELICIACLAN^nOYUN BAŞLIYOR^n%d":"FELICIACLAN^n0 — BAŞLA!",seconds);
    for(new id=1;id<=MaxClients;id++) if(is_user_connected(id)) FC_SendPanelHud(id,text,255,210,0,-1.0,0.32,1,seconds?1.2:0.35);
}

public CmdRocket(id) {if(AliveCT(id)) ShowRocketMenu(id);return PLUGIN_HANDLED;}

ShowRocketMenu(id)
{
    if(!AliveCT(id)) return;
    new title[160];formatex(title,charsmax(title),"\wRocket Menü^n\dİşlem boyunca CT'ye otomatik koruma verilir.^n\dSon süre: \y%d saniye",g_rocketDelay);
    new menu=CTMenu(title,"H_Rocket"),line[96],info[8];
    static const seconds[]={5,10,15,20,30,40,60};
    for(new i;i<sizeof seconds;i++) {formatex(line,charsmax(line),"\w%d Saniye Sonra Rocketle",seconds[i]);num_to_str(seconds[i],info,charsmax(info));CTItem(menu,line,info);}
    CTItem(menu,"\rRocket İşlemini Durdur","0");FC_CTMenuDisplay(id,menu);
}

public H_Rocket(id,menu,item)
{
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(!MenuActor(id,menu,item)) return PLUGIN_HANDLED;
    new seconds=ReadMenu(menu,item);menu_destroy(menu);
    if(!seconds) {if(StopRocket()) Chat(0,"^3%n ^1Rocket işlemini durdurdu.",id);}
    else StartRocket(id,seconds);
    ShowRocketMenu(id);return PLUGIN_HANDLED;
}

bool:RocketTarget(id) {return g_rocketActive && AliveT(id) && g_rocketTargetUID[id]==get_user_userid(id);}

RocketGuard(id)
{
    if(!g_rocketActive || !AliveCT(id)) return;
    SaveState(id,SNAP_ROCKET);g_rocketGuardUID[id]=get_user_userid(id);
    set_entvar(id,var_takedamage,DAMAGE_NO);set_entvar(id,var_health,10000.0);
}

RocketJoin(id,bool:notify)
{
    if(!g_rocketActive || g_rocketPhase || !AliveT(id)) return;
    g_rocketTargetUID[id]=get_user_userid(id);
    if(notify) {new ret;ExecuteForward(g_fwRocketPrepare,ret,0,id);}
    SaveState(id,SNAP_ROCKET);rg_give_item(id,"weapon_tmp");rg_set_user_bpammo(id,WEAPON_TMP,120);engclient_cmd(id,"weapon_tmp");
}

RocketDrop(id,bool:restore=true)
{
    if(id<1 || id>MaxClients) return;
    new uid=g_rocketTargetUID[id];g_rocketTargetUID[id]=g_rocketGuardUID[id]=0;
    if(uid && is_user_connected(id) && get_user_userid(id)==uid) {
        message_begin(MSG_BROADCAST,SVC_TEMPENTITY);write_byte(TE_KILLBEAM);write_short(id);message_end();
        if(restore && g_rocketPhase==2 && AliveT(id)) {engfunc(EngFunc_SetOrigin,id,g_rocketOrigin[id]);set_entvar(id,var_velocity,Float:{0.0,0.0,0.0});}
    }
    if(restore) RestoreState(id,SNAP_ROCKET,true);
    else g_snap[SNAP_ROCKET][id][SS_VALID]=0;
}

StartRocket(id,seconds)
{
    if(!AliveCT(id) || !HasControl(id) || (seconds!=5 && seconds!=10 && seconds!=15 && seconds!=20 && seconds!=30 && seconds!=40 && seconds!=60)) return 0;
    if(g_rocketActive) StopRocket();
    if(!ToolsAllowed(id)) return 0;
    if((ExternalReady(CT_GAME_HOGWARTS) && hogwarts_state()) || (ExternalReady(CT_GAME_MILYONER) && milyoner_active())) {Chat(id,"Önce aktif oyunu durdur.");return 0;}
    if(!CountT()) {Chat(id,"Rocket için yaşayan mahkûm bulunamadı.");return 0;}
    CancelProtectionVote();CancelC4Countdown();StopAllFormations();
    for(new p=1;p<=MaxClients;p++) C4Lift(p);
    g_rocketActive=true;g_rocketPhase=0;g_rocketDelay=seconds;g_rocketEnd=get_gametime()+float(seconds);g_rocketLastSecond=-1;
    for(new p=1;p<=MaxClients;p++) if(AliveT(p)) g_rocketTargetUID[p]=get_user_userid(p);
    new ret;ExecuteForward(g_fwRocketPrepare,ret,id,0);
    for(new p=1;p<=MaxClients;p++) {if(AliveT(p)) RocketJoin(p,false);else if(AliveCT(p)) RocketGuard(p);}
    set_task(0.1,"RocketTick",TASK_ROCKET,"",0,"b");
    Chat(0,"^3%n ^1Rocket başlattı. Mahkûmlar ^4%d saniye sonra ^1rocketlenecek.",id,seconds);
    PlayCTSound(SND_COUNTDOWN);RocketTick();return 1;
}

StopRocket()
{
    if(!g_rocketActive) return 0;
    g_rocketActive=false;remove_task(TASK_ROCKET);
    for(new id=1;id<=MaxClients;id++) {
        RocketDrop(id);
        if(is_user_connected(id)) FC_SendPanelHud(id,"",255,205,60,-1.0,0.28,1,0.1);
    }
    g_rocketPhase=0;g_rocketEnd=0.0;g_rocketGrace=0.0;g_rocketLastSecond=-1;
    new ret;ExecuteForward(g_fwRocketFinished,ret);return 1;
}

public RocketTick()
{
    if(!g_rocketActive) {remove_task(TASK_ROCKET);return;}
    if(!HasCT() || g_game || (LibraryExists("fc_lr",LibType_Library) && fc_lr_active())) {StopRocket();return;}
    new count;for(new id=1;id<=MaxClients;id++) if(g_rocketTargetUID[id]) {if(RocketTarget(id)) count++;else RocketDrop(id);}
    if(!count) {StopRocket();return;}
    new Float:now=get_gametime();
    if(!g_rocketPhase) {
        new seconds=max(0,floatround(g_rocketEnd-now,floatround_ceil));
        if(seconds!=g_rocketLastSecond) {
            g_rocketLastSecond=seconds;new text[128];formatex(text,charsmax(text),"FELICIACLAN | ROCKET^nMahkûmların rocketlenmesine %d saniye kaldı.",seconds);
            for(new id=1;id<=MaxClients;id++) if(is_user_connected(id)) FC_SendPanelHud(id,text,255,205,60,-1.0,0.28,1,1.2);
        }
        if(now<g_rocketEnd) return;
        g_rocketPhase=1;g_rocketEnd=now+1.2;PlayCTSound(SND_ROCKET_FIRE);
        for(new id=1;id<=MaxClients;id++) if(RocketTarget(id)) {GameFreeze(id,true);set_entvar(id,var_maxspeed,0.01);}
        return;
    }
    if(g_rocketPhase==1) {
        if(now<g_rocketEnd) return;
        g_rocketPhase=2;g_rocketGrace=now+0.4;g_rocketEnd=now+1.8;
        for(new id=1;id<=MaxClients;id++) if(RocketTarget(id)) {
            get_entvar(id,var_origin,g_rocketOrigin[id]);g_rocketLastZ[id]=g_rocketOrigin[id][2];
            set_entvar(id,var_flags,get_entvar(id,var_flags)&~(FL_FROZEN|FL_ONGROUND));
            set_entvar(id,var_gravity,-0.5);set_entvar(id,var_velocity,Float:{0.0,0.0,360.0});set_entvar(id,var_maxspeed,0.01);
            message_begin(MSG_BROADCAST,SVC_TEMPENTITY);write_byte(TE_BEAMFOLLOW);write_short(id);write_short(g_beam);write_byte(10);write_byte(4);write_byte(255);write_byte(150);write_byte(40);write_byte(220);message_end();
        }
        return;
    }
    for(new id=1;id<=MaxClients;id++) if(RocketTarget(id)) {
        new Float:origin[3];get_entvar(id,var_origin,origin);
        if(now>=g_rocketEnd || (now>=g_rocketGrace && floatabs(origin[2]-g_rocketLastZ[id])<0.5)) {
            message_begin(MSG_BROADCAST,SVC_TEMPENTITY);write_byte(TE_EXPLOSION);write_coord_f(origin[0]);write_coord_f(origin[1]);write_coord_f(origin[2]);write_short(g_rocketSprite);write_byte(18);write_byte(15);write_byte(TE_EXPLFLAG_NOSOUND);message_end();
            set_entvar(id,var_gravity,1.0);set_entvar(id,var_velocity,Float:{0.0,0.0,0.0});PlayCTSound(SND_ROCKET_BOOM,id);
            user_kill(id,1);RocketDrop(id);
        } else g_rocketLastZ[id]=origin[2];
    }
    count=0;for(new id=1;id<=MaxClients;id++) if(RocketTarget(id)) count++;
    if(!count) StopRocket();
}

ShowProtectionMenu(id)
{
    if(!AliveCT(id)) return;
    new menu=CTMenu("\wKoruma Menüsü","H_ProtectionMenu");
    CTItem(menu,g_protectionEnd>0.0?"\rKoruma Oylamasını Durdur":"\wKoruma Oylaması Yap","1");
    CTItem(menu,"\wRocket Menü \w[\r/rocket\w]","2");CTItem(menu,"\wKoruma / CT Araçları","3");
    CTItem(menu,"\wOyunlar","4");CTItem(menu,"\wC4 Menü","5");FC_CTMenuDisplay(id,menu);
}

public H_ProtectionMenu(id,menu,item)
{
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(!MenuActor(id,menu,item)) return PLUGIN_HANDLED;
    new key=ReadMenu(menu,item);menu_destroy(menu);
    if(key==1) {
        if(g_protectionEnd>0.0) {CancelProtectionVote();Chat(0,"^3%n ^1koruma oylamasını durdurdu.",id);}
        else StartProtectionVote(id);
        ShowProtectionMenu(id);
    }
    else if(key==2) ShowRocketMenu(id);else if(key==3) ShowTools(id);else if(key==4) ShowGamesHub(id);else if(key==5) ShowC4Menu(id);
    return PLUGIN_HANDLED;
}

public CmdProtectionVote(id)
{
    if(AliveCT(id)) {if(g_protectionEnd>0.0) ShowProtectionMenu(id);else {StartProtectionVote(id);ShowProtectionMenu(id);}}
    else if(AliveT(id) && g_protectionEnd>0.0) ShowProtectionVote(id);
    return PLUGIN_HANDLED;
}

StartProtectionVote(id)
{
    if(!AliveCT(id) || !ToolsAllowed(id) || g_protectionEnd>0.0) return 0;
    if(g_c4CountdownEnd>0.0) {Chat(id,"Önce süreli göm geri sayımını durdur.");return 0;}
    CancelProtectionVote();new voters;
    for(new target=1;target<=MaxClients;target++) if(AliveT(target)) {g_protectionVoterUID[target]=get_user_userid(target);voters++;}
    if(!voters) {Chat(id,"Oy verecek yaşayan mahkûm bulunamadı.");return 0;}
    g_protectionActor=id;g_protectionUID=get_user_userid(id);g_protectionSerial=g_protectionSerial>=1000000?1:g_protectionSerial+1;
    g_protectionEnd=get_gametime()+15.0;g_protectionSecond=-1;
    for(new target=1;target<=MaxClients;target++) if(g_protectionVoterUID[target] || AliveCT(target)) ShowProtectionVote(target);
    Chat(0,"^3%n ^1koruma oylamasını başlattı. ^4 15 saniye ^1içinde oyunu seç.",id);PlayCTSound(SND_NOTICE);
    set_task(1.0,"ProtectionVoteTick",TASK_PROTECTION_VOTE,"",0,"b");return 1;
}

ProtectionVoteTitle(out[],len)
{
    formatex(out,len,"\wFeliciaClan \y» \wKoruma Oylaması^n\dKalan: \y%d sn \d| Mahkûm başına bir oy",max(0,floatround(g_protectionEnd-get_gametime(),floatround_ceil)));
}

ShowProtectionVote(id)
{
    if(!is_user_connected(id) || g_protectionEnd<=get_gametime()) return;
    CloseProtectionVoteMenu(id);
    new title[256],line[128],info[24];ProtectionVoteTitle(title,charsmax(title));
    new menu=menu_create(title,"H_ProtectionVote");g_protectionMenu[id]=menu;
    menu_setprop(menu,MPROP_NUMBER_COLOR,"\r");menu_setprop(menu,MPROP_EXITNAME,"\wÇıkış");
    for(new i;i<sizeof PROTECTION_CHOICES;i++) {formatex(line,charsmax(line),"\wFeliciaClan \y» \w%s \w[\y%d Oy\w]",PROTECTION_CHOICES[i],g_protectionVotes[i]);num_to_str(g_protectionSerial*8+i,info,charsmax(info));menu_additem(menu,line,info,0,g_protectionCallback);}
    FC_CTMenuDisplay(id,menu);
}

public CB_ProtectionVote(id,menu,item)
{
    return g_protectionEnd>get_gametime() && AliveT(id) && g_protectionVoterUID[id]==get_user_userid(id) && g_protectionChoice[id]<0?ITEM_ENABLED:ITEM_DISABLED;
}

public H_ProtectionVote(id,menu,item)
{
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    new key=item==MENU_EXIT?-1:ReadMenu(menu,item);if(g_protectionMenu[id]==menu) g_protectionMenu[id]=-1;menu_destroy(menu);
    if(key<0 || key/8!=g_protectionSerial || key%8>=sizeof PROTECTION_CHOICES || !AliveT(id) || g_protectionEnd<=get_gametime() || g_protectionVoterUID[id]!=get_user_userid(id) || g_protectionChoice[id]>=0) return PLUGIN_HANDLED;
    new choice=key%8;g_protectionChoice[id]=choice;g_protectionVotes[choice]++;
    Chat(id,"Oyun ^4%s ^1için kaydedildi. Her mahkûmun bir oy hakkı var.",PROTECTION_CHOICES[choice]);ShowProtectionVote(id);return PLUGIN_HANDLED;
}

CloseProtectionVoteMenu(id)
{
    new menu=g_protectionMenu[id];g_protectionMenu[id]=-1;if(menu<0) return;
    new old,current=-1,page;if(is_user_connected(id)) player_menu_info(id,old,current,page);
    if(current==menu) menu_cancel(id);else menu_destroy(menu);
}

CancelProtectionVote()
{
    remove_task(TASK_PROTECTION_VOTE);g_protectionEnd=0.0;g_protectionActor=g_protectionUID=0;
    for(new id=1;id<=MaxClients;id++) CloseProtectionVoteMenu(id);
    arrayset(g_protectionVoterUID,0,sizeof g_protectionVoterUID);arrayset(g_protectionChoice,-1,sizeof g_protectionChoice);arrayset(g_protectionVotes,0,sizeof g_protectionVotes);
}

public ProtectionVoteTick()
{
    if(g_protectionEnd<=0.0) {remove_task(TASK_PROTECTION_VOTE);return;}
    if(!AliveCT(g_protectionActor) || get_user_userid(g_protectionActor)!=g_protectionUID || g_game) {CancelProtectionVote();return;}
    if(get_gametime()>=g_protectionEnd) {
        new maximum,candidates[5],n,total;
        for(new i;i<5;i++) {total+=g_protectionVotes[i];maximum=max(maximum,g_protectionVotes[i]);}
        for(new i;i<5;i++) if(g_protectionVotes[i]==maximum) candidates[n++]=i;
        new winner=candidates[random_num(0,n-1)];CancelProtectionVote();
        if(total) Chat(0,"Koruma oylaması: ^4%s ^1kazandı. ^3%d oy ^1/ toplam ^3%d^1. Eşitlikte rastgele seçilir.",PROTECTION_CHOICES[winner],maximum,total);
        else Chat(0,"Koruma oylaması bitti; oy kullanılmadı.");return;
    }
    new seconds=floatround(g_protectionEnd-get_gametime(),floatround_ceil);if(seconds==g_protectionSecond) return;g_protectionSecond=seconds;
    new title[256],line[128];ProtectionVoteTitle(title,charsmax(title));
    for(new id=1;id<=MaxClients;id++) if(g_protectionMenu[id]>=0 && is_user_connected(id)) {
        new old,current,page;player_menu_info(id,old,current,page);if(current!=g_protectionMenu[id]) continue;
        menu_setprop(current,MPROP_TITLE,title);
        for(new i;i<5;i++) {formatex(line,charsmax(line),"\wFeliciaClan \y» \w%s \w[\y%d Oy\w]",PROTECTION_CHOICES[i],g_protectionVotes[i]);menu_item_setname(current,i,line);}
        FC_CTMenuDisplay(id,current,page);
    }
}

public fc_lr_prepare(t,ct,mode) {
    CancelProtectionVote();CancelC4Countdown();StopAllFormations();
    new players[2];players[0]=t;players[1]=ct;
    for(new s;s<2;s++) {
        new id=players[s];if(id<1 || id>MaxClients) continue;
        C4Lift(id);RestoreState(id,SNAP_TOOL,false);g_toolFrozen[id]=false;g_thawTime[id]=0.0;
    }
}

public fc_lr_finished(t,ct,mode,winner) {
    if(AliveCT(ct)) {ApplyCTPerks(ct);ApplyRoundGod(ct);}
}
EnsureLegacyCvar(const name[],const fallback[]) {
    new ptr=get_cvar_pointer(name);return ptr?ptr:register_cvar(name,fallback);
}

Hard_Komut() {return g_hard;}

Hard_KomutAc() {g_hardPermit=g_roundNo;return SetHard(true,0);}

Hard_KomutKapat() {return SetHard(false,0);}

stock CHard_Komut() {return g_hard;}

CHard_KomutAc() {return Hard_KomutAc();}

CHard_KomutKapat() {return Hard_KomutKapat();}

hunger_baslat() {return StartCTGame(CT_GAME_HUNGER,g_bridgeActor);}

hunger_bitir() {if(g_game==CT_GAME_HUNGER) StopCTGame(0,CT_STOP_MENU);}









FC_MenuCleanHints(const source[],dest[],len) {
    new i,n;
    while(source[i] && n<len) {
        if(source[i]=='[' || source[i]=='(') {
            new stop=source[i]=='['?']':')',at=i+1;
            while(source[at]) {
                if(source[at]==' ') at++;
                else if(source[at]==92 && (source[at+1]=='r' || source[at+1]=='w' || source[at+1]=='d' || source[at+1]=='y')) at+=2;
                else break;
            }
            if(source[at]=='/') {
                while(source[at] && source[at]!=stop && at-i<80) at++;
                if(source[at]==stop) {i=at+1;continue;}
            }
        }
        dest[n++]=source[i++];
    }
    dest[n]=0;trim(dest);return n;
}

FC_CTMenuDisplay(id,menu,page=0,seconds=-1) {
    if(id<1 || id>MaxClients || !is_user_connected(id) || g_bridgeRoundClosed) {menu_destroy(menu);return 0;}
    g_bridgeMenu[id]=menu;
    return menu_display(id,menu,page,seconds);
}

BridgeCloseMenus() {
    for(new id=1;id<=MaxClients;id++) {
        new old,current,page;
        if(g_bridgeMenu[id]>=0 && is_user_connected(id) && player_menu_info(id,old,current,page) && current==g_bridgeMenu[id]) menu_cancel(id);
        g_bridgeMenu[id]=-1;
        remove_task(TASK_CT_SPAWN_MENU+id);g_bridgeSpawnUID[id]=0;
    }
}

BridgeClearSlot(id) {
    remove_task(TASK_CT_SPAWN_MENU+id);g_bridgeSpawnUID[id]=0;g_bridgeUID[id]=0;g_bridgeMenu[id]=-1;
    g_infect[id]=g_glow[id]=g_sirala[id]=g_sarkac[id]=g_hain[id]=g_hiz[id]=g_silahKontrol[id]=g_unAmmo[id]=false;
    g_hasarAzalt[id]=g_hasarKatla[id]=g_koruma[id]=g_oylama[id]=false;Takim[id]=0;
}

BridgeQueueSpawnMenu(id) {
    if(g_bridgeRoundClosed || !AliveCT(id)) return;
    remove_task(TASK_CT_SPAWN_MENU+id);g_bridgeSpawnUID[id]=get_user_userid(id);
    set_task(0.25,"BridgeSpawnMenu",TASK_CT_SPAWN_MENU+id);
}

public BridgeSpawnMenu(task) {
    new id=task-TASK_CT_SPAWN_MENU;
    if(!g_bridgeRoundClosed && AliveCT(id) && g_bridgeSpawnUID[id]==get_user_userid(id)) ctmenu(id);
}

public BridgeRoundEnd() {
    g_bridgeRoundClosed=true;BridgeCloseMenus();BridgeReset(CT_STOP_ROUND,false);
}

public ayarsifirla() {BridgeReset(CT_STOP_MENU,true);}

BridgeReset(CTStopReason:reason,bool:refill) {
    if(g_bridgeResetting) return;
    g_bridgeResetting=true;new bool:legacyEnded=g_bridgeLegacy;
    StopCTGame(0,reason);StopRocket();StopAllFormations();
    // Directly started provider games are stopped as well, even if their local
    // CT session was already cleared after an aborted start or callback.
    if(LibraryExists("fc_hogwarts",LibType_Library) && hogwarts_state()) hogwarts_stop(0);
    if(LibraryExists("fc_milyoner",LibType_Library) && milyoner_active()) milyoner_stop(0);
    for(new id=1;id<=MaxClients;id++) if(g_infect[id] && is_user_connected(id)) ClearBlind(id);
    ResetTools();LegacyReset();
    remove_task(TASK_LEGACY_INFECTION);remove_task(task_GOMULENOLUR);
    remove_task(0);remove_task(791230);remove_task(791231);remove_task(791232);
    for(new id=1;id<=MaxClients;id++) {
        CancelLoadout(id);
        remove_task(id);remove_task(id+task_ENFEKSIYON);remove_task(id+task_HAYALET);
        remove_task(id+task_KORUMA);remove_task(id+task_GOZUMEGOZUKME);remove_task(id+task_SIRALACIZGI);
        remove_task(id+task_HUD);remove_task(id+1707);
        if(g_infect[id] && is_user_connected(id)) ClearBlind(id);
        g_infect[id]=g_glow[id]=g_sirala[id]=g_sarkac[id]=g_hain[id]=g_hiz[id]=g_silahKontrol[id]=g_unAmmo[id]=false;
        g_hasarAzalt[id]=g_hasarKatla[id]=g_koruma[id]=g_oylama[id]=false;Takim[id]=0;g_bridgeUID[id]=0;
        if(refill && !g_bridgeRoundClosed && AliveCT(id)) {GiveCTLoadout(id);QueueLoadout(id);}
    }
    g_bridgeLegacy=false;
    if(legacyEnded) {new ret;ExecuteForward(g_fwFinished,ret,1000,0,_:reason);}
    g_bridgeLegacy=false;g_bridgeGameName[0]=0;g_bridgeInitialT=0;g_bridgeActor=0;
    CTEndExternal(reason);
    g_bridgeResetting=false;
}

BridgeQueueMode(bool:hard,id) {
    if(!AliveCT(id) || g_bridgeRoundClosed) return 0;
    new slot=hard?1:0,modeState=hard?hardkomutKontrol:godKontrol;
    if(modeState==2) {
        if(hard) {if(g_hard) Hard_KomutKapat();else Hard_KomutAc();}
        else godver();
        return 1;
    }
    if(modeState==1) {Chat(id,"Bu özellik sonraki el alınabilecek.");return 0;}
    if(DahaOnceAldi[slot] && SuankiRound<SiradakiAlinacakEl[slot]) {Chat(id,"Bu özellik üç elde bir seçilebilir.");return 0;}
    DahaOnceAldi[slot]=true;Deger[slot]=SuankiRound;SiradakiAlinacakEl[slot]=SuankiRound+3;
    if(hard) hardkomutKontrol=1;else godKontrol=1;
    Chat(0,"^3%n ^1sonraki el için ^3%s ^1almayı açtı.",id,hard?"Hard Komut":"Godmode");return 1;
}

bool:BridgeLegacyChoice(id,const handler[],key) {
    if(g_externalToken>0 || g_bridgeRoundClosed || !AliveCT(id)) return false;
    g_bridgeActor=id;
    if(key==90 || key==0) return true;
    if(equal(handler,"godoyun2") && get_entvar(id,var_takedamage)!=DAMAGE_NO) {Chat(id,"Bu menü Godmode açıkken kullanılabilir.");return false;}
    if(equal(handler,"godoyun2") && (key==35 || key==34)) return true;
    if(equal(handler,"godsuzoyun2") && (key==2 || key==3 || key==9)) return true;
    if(equal(handler,"gomulenolur2") && key!=1) return true;
    if(equal(handler,"enfeklazer2") && key!=1) return true;
    if(g_game!=CT_GAME_NONE || (LibraryExists("fc_lr",LibType_Library) && fc_lr_active())) {Chat(id,"Önce aktif oyunu durdur.");return false;}
    new label[64];
    if(equal(handler,"godsuzoyun2")) {
        switch(key) {
            case 1:copy(label,charsmax(label),"Enfeksiyon");case 4:copy(label,charsmax(label),"Sarkaç");
            case 5:copy(label,charsmax(label),"Hayalet");case 6:copy(label,charsmax(label),"Sayıyı Bilen");
            case 7:copy(label,charsmax(label),"300 Sparta");case 8:copy(label,charsmax(label),"Aref");
            case 10:copy(label,charsmax(label),"Körebe");case 11:copy(label,charsmax(label),"Freeze'lenen Ölür");
            default:copy(label,charsmax(label),"Referans Oyunu");
        }
    } else if(equal(handler,"zombi2")) copy(label,charsmax(label),"Zombi");
    else if(equal(handler,"gomulenolur2")) copy(label,charsmax(label),"Gömülen Ölür");
    else if(equal(handler,"enfeklazer2")) copy(label,charsmax(label),"Enfeksiyon Lazer");
    else if(equal(handler,"ffmenu2")) copy(label,charsmax(label),"FF");
    else if(equal(handler,"catismamenu2")) copy(label,charsmax(label),"Çatışma");
    else if(equal(handler,"rocketmenu2")) copy(label,charsmax(label),"Roket");
    else copy(label,charsmax(label),"Godlu Referans Oyunu");
    if(g_bridgeLegacy && !equal(label,g_bridgeGameName)) {Chat(id,"Önce aktif oyunu durdur veya ayarları sıfırla.");return false;}
    if(!g_bridgeLegacy) {
        g_bridgeLegacy=true;copy(g_bridgeGameName,charsmax(g_bridgeGameName),label);g_bridgeInitialT=CountT();
        for(new p=1;p<=MaxClients;p++) if(AliveT(p)) g_bridgeUID[p]=get_user_userid(p);
        new ret;ExecuteForward(g_fwPrepare,ret,id,1000);
        ExecuteForward(g_fwStarted,ret,id,1000,g_bridgeInitialT);
    }
    return true;
}

public BridgeInfectionTick() {
    if(!enfeksiyonKontrol || g_bridgeRoundClosed) {remove_task(TASK_LEGACY_INFECTION);return;}
    new players[32],count;get_players_ex(players,count,GetPlayers_ExcludeDead|GetPlayers_ExcludeBots|GetPlayers_MatchTeam,"TERRORIST");
    new Float:pos[33][3];for(new i;i<count;i++) get_entvar(players[i],var_origin,pos[players[i]]);
    new Float:now=get_gametime(),bool:drain=now>=g_bridgeInfectHP,bool:aura=now>=g_bridgeInfectAura;
    if(drain) g_bridgeInfectHP=now+0.5;if(aura) g_bridgeInfectAura=now+0.2;
    for(new i;i<count;i++) {
        new id=players[i];if(!g_infect[id]) continue;
        if(g_bridgeUID[id]!=get_user_userid(id)) {g_infect[id]=false;continue;}
        if(aura) {
            engfunc(EngFunc_MessageBegin,MSG_PVS,SVC_TEMPENTITY,pos[id],0);write_byte(TE_DLIGHT);
            write_coord_f(pos[id][0]);write_coord_f(pos[id][1]);write_coord_f(pos[id][2]);
            write_byte(12);write_byte(0);write_byte(255);write_byte(0);write_byte(3);write_byte(0);message_end();
        }
        if(drain) {new Float:hp;get_entvar(id,var_health,hp);if(hp>3.0) set_entvar(id,var_health,hp-3.0);else {user_kill(id);continue;}}
        for(new j;j<count;j++) {
            new target=players[j];if(target==id || g_infect[target]) continue;
            new Float:x=pos[id][0]-pos[target][0],Float:y=pos[id][1]-pos[target][1],Float:z=pos[id][2]-pos[target][2];
            if(x*x+y*y+z*z<1600.0) viruskap(target);
        }
    }
}

BridgeMaintenance() {
    if(g_bridgeLegacy && g_bridgeInitialT>1 && CountT()<2 && !g_bridgeRoundClosed) {
        new winner;for(new id=1;id<=MaxClients;id++) if(AliveT(id)) {winner=id;break;}
        if(winner) Chat(0,"^3%s ^1oyununu ^3%n ^1kazandı.",g_bridgeGameName,winner);
        BridgeReset(CT_STOP_WIN,false);
    }
    for(new id=1;id<=MaxClients;id++) if(g_buriedUID[id] && !g_buryFull[id] && is_user_alive(id)) {
        new Float:origin[3];get_entvar(id,var_origin,origin);
        if(origin[2]>=g_buryOrigin[id][2]-8.0) {g_buriedUID[id]=0;g_buryUntil[id]=0.0;}
    }
}

BridgeExtraGames(id,bool:god) {
    if(!AliveCT(id)) return;
    new menu=CTMenu(god?"\wEklenen Godlu Oyunlar":"\wEklenen Oyunlar","BridgeExtraHandler");
    for(new i=1;i<sizeof GAME_NAMES;i++) {
        if(GAME_GOD[i]!=god) continue;
        if(i==_:CT_GAME_INFECTION || i==_:CT_GAME_ZOMBIE || i==_:CT_GAME_GHOST || i==_:CT_GAME_AREF || i==_:CT_GAME_SPARTA || i==_:CT_GAME_PENDULUM || i==_:CT_GAME_FREEZE_CHANCE || i==_:CT_GAME_BURY_JUMP || i==_:CT_GAME_NUMBER || i==_:CT_GAME_BLIND || i==_:CT_GAME_ROCKET) continue;
        new key[8];num_to_str(i,key,charsmax(key));CTItem(menu,GAME_NAMES[i],key);
    }
    FC_CTMenuDisplay(id,menu);
}

public BridgeExtraHandler(id,menu,item) {
    if(id>=1 && id<=MaxClients && g_bridgeMenu[id]==menu) g_bridgeMenu[id]=-1;
    if(g_bridgeRoundClosed) {menu_destroy(menu);return PLUGIN_HANDLED;}
    
    if(!MenuActor(id,menu,item,false)) return PLUGIN_HANDLED;
    new value=ReadMenu(menu,item);menu_destroy(menu);StartCTGame(CTGame:value,id);return PLUGIN_HANDLED;
}

/* Owned external session: no equipment or legacy game mutations on release. */
public N_ExternalBegin(plugin,argc) {
    if(argc<2 || g_externalToken>0 || g_bridgeRoundClosed || g_game || g_bridgeLegacy || g_rocketActive || g_c4CountdownEnd>0.0 || sureligomSayac>0) return 0;
    new caller=get_param(1);
    if(caller && (!is_user_connected(caller) || (!AliveCT(caller) && !(get_user_flags(caller)&ADMIN_KICK)))) return 0;
    if(LibraryExists("fc_lr",LibType_Library) && fc_lr_active()) return 0;
    if(LibraryExists("fc_hogwarts",LibType_Library) && hogwarts_state()) return 0;
    if(LibraryExists("fc_milyoner",LibType_Library) && milyoner_active()) return 0;
    g_externalOwner=plugin;g_externalSerial++;if(g_externalSerial<=0) g_externalSerial=1;g_externalToken=g_externalSerial;
    get_string(2,g_externalName,charsmax(g_externalName));if(!g_externalName[0]) copy(g_externalName,charsmax(g_externalName),"Harici Oyun");
    new ret;ExecuteForward(g_fwPrepare,ret,caller,1001);ExecuteForward(g_fwStarted,ret,caller,1001,CountT());
    return g_externalToken;
}
public N_ExternalEnd(plugin,argc) {
    if(!g_externalToken || plugin!=g_externalOwner || get_param(1)!=g_externalToken) return 0;
    CTEndExternal(CT_STOP_MENU);return 1;
}
CTEndExternal(CTStopReason:reason) {
    if(!g_externalToken) return;
    g_externalToken=0;g_externalOwner=-1;g_externalName[0]=0;
    new ret;ExecuteForward(g_fwFinished,ret,1001,0,_:reason);
}

// Bounded spawn retries cover late map equipment without touching an active duel.
CancelLoadout(id) {
    remove_task(TASK_CT_LOADOUT+id);g_loadoutUID[id]=0;g_loadoutTry[id]=0;
}
QueueLoadout(id) {
    CancelLoadout(id);if(!AliveCT(id)) return;
    g_loadoutUID[id]=get_user_userid(id);g_loadoutLife[id]=g_spawnLife[id];
    set_task(0.15,"LoadoutRetry",TASK_CT_LOADOUT+id);
}
public LoadoutRetry(task) {
    new id=task-TASK_CT_LOADOUT;
    if(id<1 || id>MaxClients || !AliveCT(id) || g_bridgeRoundClosed
        || g_loadoutUID[id]!=get_user_userid(id) || g_loadoutLife[id]!=g_spawnLife[id]) return;
    if(g_game || g_bridgeLegacy || g_externalToken || g_rocketActive) return;
    if(LibraryExists("fc_lr",LibType_Library) && fc_lr_active() && fc_lr_is_player(id)) return;
    GiveCTLoadout(id,false,false);
    if(++g_loadoutTry[id]<2) set_task(0.5,"LoadoutRetry",task);
    else g_loadoutUID[id]=0;
}
public N_FovLocked(plugin,argc) {
    new id=get_param(1);
    return id>=1 && id<=MaxClients && is_user_alive(id) && g_game==CT_GAME_REFLEX;
}
