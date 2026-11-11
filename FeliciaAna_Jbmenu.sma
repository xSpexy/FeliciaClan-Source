#include <amxmodx>
#include <amxmisc>
#include <nvault>
#include <reapi>
#include <fakemeta>
#include <engine>
#include <hamsandwich>

/* === fc_hogwarts: SMA icine alinmis kod === */
#if defined _fc_hogwarts_included
    #endinput
#endif
#define _fc_hogwarts_included
#pragma reqlib fc_hogwarts

enum HogwartsHouse {
    HW_NONE = 0,
    HW_GRYFFINDOR,
    HW_SLYTHERIN,
    HW_RAVENCLAW,
    HW_HUFFLEPUFF
};
enum HogwartsState { HW_OFF = 0, HW_SORTING, HW_BATTLE };
enum HogwartsStopReason { HW_STOP_MENU = 0, HW_STOP_WIN, HW_STOP_ROUND, HW_STOP_EMPTY };

// Trusted server plugins may use caller=0. CT menu permissions are checked otherwise.
native hogwarts_menu(caller);
native hogwarts_start(caller = 0);
native hogwarts_stop(caller = 0);
native hogwarts_assign(player, HogwartsHouse:house, caller = 0);
native HogwartsState:hogwarts_state();
native HogwartsHouse:hogwarts_house(player);
native bool:hogwarts_is_player(player);
native hogwarts_get_alive(HogwartsHouse:house = HW_NONE);
native Float:hogwarts_cooldown(player);

// Notifications. All values are server indices; house 0 means no winner.
// Called before snapshots, allowing the JB plugin to finish paid crate rolls safely.
forward hogwarts_prepare(caller, players);
forward hogwarts_started(caller, players);
forward hogwarts_battle_started(players);
forward hogwarts_house_changed(player, HogwartsHouse:oldhouse, HogwartsHouse:newhouse);
forward hogwarts_spell_hit(attacker, victim, HogwartsHouse:house, Float:damage, killed);
forward hogwarts_finished(HogwartsHouse:winner, HogwartsStopReason:reason);


native fc_lr_active();
native fc_lr_is_player(player);
native fc_lr_account_changed(player);
native fc_ctmenu_open(caller);
native fc_ct_hud_text(player, output[], length);
native bool:fc_ct_hud_visible(player);
native fc_ct_game_id();
native bool:fc_ct_rocket_is_player(player);
native bool:fc_ct_rocket_active();
new bool:g_bRocketAPI;

/* === fc_hud_frame: SMA icine alinmis kod === */
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
stock FC_SendPanelHud(id,const text[],r,g,b,Float:x,Float:y,channel,Float:hold=3.0) {
    if(id<1 || id>MaxClients || channel<1 || channel>4
        || !is_user_connected(id) || is_user_bot(id) || is_user_hltv(id)) return;
    new px=floatround(x*8192.0,floatround_tozero);
    new py=floatround(y*8192.0,floatround_tozero);
    // Keep layers apart after client coordinate quantization. The visible
    // displacement stays under four pixels at 1920px, with channel 4 anchored.
    if(channel==2) px+=16;
    else if(channel==3) px-=16;
    new packet[512];
    copy(packet,charsmax(packet),text);
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
    new columnWidth=max(widest,headerWidth);
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









#pragma semicolon 1
#pragma dynamic 32768

#define PLUGIN  "FeliciaClan ReAPI JBMenu"
#define VERSION "8.0-MainMarket"
#define AUTHOR "FeliciaClan"

#define MAX_CFG 640
#define MAX_CFG_KEY 64
#define MAX_CFG_VAL 256

#define TASK_SPAWN_MENU 5000
#define TASK_NOCT_JOIN 13000
#define TASK_NOCT_MENUS 913007
#define NOCT_CELL_ACTION 18
new g_iNoCTJoinUID[33],g_iNoCTJoinTries[33];
new bool:g_bNoCTFirstTeam[33],bool:g_bNoCTHadCT;
new g_iNoCTMenu[33],g_iNoCTMenuKind[33];
new g_szNoCTCellTargets[256];
new Float:g_flNoCTCellNext;
#define TASK_GOD 6000
#define TASK_NOCLIP 6100
#define TASK_INVIS 6200
#define TASK_HUD 9100
#define JB_HUD_CHANNEL 4
#define JB_HUD_TITLE_CHANNEL 3
#define JB_HUD_RIGHT_CHANNEL 2
#define TASK_CRATE 10000
#define TASK_LUCKY_REVIVE 11000
#define TASK_PROF_ROBBERY 872000
#define TASK_PROF_ZHONYA 873000

#define MAX_RANKS 20
#define TASK_COUNT 5

new const CHAT_TAG[] = "^1[ ^3- ^4FeliciaClan ^3- ^1]";
new const LONG_TAG[] = "FeliciaClan";
new const SHORT_TAG[] = "FG";
new const CFG_FILE[] = "addons/amxmodx/configs/FeliciaClan/FeliciaClan_JBMenu.ini";
new const VAULT_NAME[] = "FeliciaClan_JBMenu";
new const LOG_FILE[] = "FeliciaClan_JBMenu_V5.log";

#define TOP_LIST_SIZE 15
#define MOTD_HTML_SIZE 8191


// ============================================================
// MENU TASARIMI
//
// SADECE EN USTTEKI 3 SABITI DEGISTIRMEN YETERLI:
// CHAT_TAG  -> tum sohbet bildirimleri
// LONG_TAG  -> tum menu basliklari
// SHORT_TAG -> tum menu secenekleri
//
// Gorunum:
// [ FeliciaClan ] Marketler
// [ FC ] ? Can Market
// [ FC ] ? Saldiri Menusu
// ============================================================

FC_MenuCreate(const rawTitle[], const handler[])
{
    new full[768];

    // Tum menu basliklari yalnizca LONG_TAG ile uretilir.
    formatex(full, charsmax(full), "\r%s \y» %s", LONG_TAG, rawTitle);
    new menu = FC_OptMenuCreate(full, handler);
    menu_setprop(menu, MPROP_NUMBER_COLOR, "\d");
    return menu;
}

FC_MenuAddItem(menu, const text[], const info[])
{
    new line[256];

    // Kompakt gorunum: [FC] Ana Market
    // SHORT_TAG hala tek merkezden degisir.
    formatex(line, charsmax(line), "\r%s \y» %s", SHORT_TAG, text);
    return FC_OptMenuAdd(menu, line, info);
}

FC_MenuAddItemCB(menu, const text[], const info[], callback)
{
    new line[256];
    formatex(line, charsmax(line), "\r%s \y» %s", SHORT_TAG, text);
    return FC_OptMenuAdd(menu, line, info, 0, callback);
}

FC_MenuSetProp(menu, property, const text[])
{
    new line[128];

    // Navigasyon secenekleri sade kalir: Geri / Kapat / Onceki / Sonraki.
    formatex(line, charsmax(line), "\w%s", text);
    return menu_setprop(menu, property, line);
}

// ============================================================
// HESAP SISTEMI NATIVELERI - accoundsystem_FeliciaClan.sma
// ============================================================

native nForwardLogin(iPlayer);
native nForwardRegister(iPlayer);
native nForwardExit(iPlayer);
native nCreateAccount(iPlayer, szUserName[], szUserPassword[]);
native nGetUidByID(iPlayer);
native nIsUidOnline(iUID);
native nGetUidByName(const szName[]);
native nIsValidUid(iUID);
native nGetLastUid();
native nSetUidStatus(iUID, iStatus);
native nGetUidStatus(iUID);
native nUidLastName(iUID, szData[], iLen);
native nUidGetUName(iUID, szData[], iLen);
native nChangePassword(iPlayer);

// ============================================================
// SABIT MENU ISKELETI
// INI sadece fiyat/model/degerleri yonetir. Menu varligi/sirasi SMA'dadir.
// ============================================================

enum _:TimedRole
{
    ROLE_PRIME = 0,
    ROLE_ISYANTEAM,
    ROLE_MANAGER,
    ROLE_COUNT
};

enum _:DisplayTagMode
{
    TAGMODE_AUTO = 0,
    TAGMODE_ISYANTEAM,
    TAGMODE_PRIME,
    TAGMODE_MULTI,
    TAGMODE_MANAGER,
    TAGMODE_COUNT
};

enum _:HudMode
{
    HUDMODE_FULL = 0,
    HUDMODE_COMPACT,
    HUDMODE_OFF,
    HUDMODE_COUNT
};

enum _:CTTLOperation
{
    CTTL_NONE = 0,
    CTTL_GIVE,
    CTTL_TAKE
};

enum _:CosKind
{
    COS_KNIFE = 0,
    COS_PLAYER,
    COS_RETIRED_PET, // Pet (eski nVault tur ID korunur).
    COS_WING,
    COS_KILLFX,
    COS_RETIRED_AURA, // Eski nVault kayitlari icin ayrilmis; kullanilamaz.
    COS_TRAIL,
    COS_KIND_COUNT
};

enum _:CosSource
{
    SOURCE_PRIME_MENU = 0,
    SOURCE_COIN_NORMAL
};

enum _:ProfessionType
{
    PROF_NONE = 0,
    PROF_PUNISHER,
    PROF_BOMBACI,
    PROF_TERMINATOR,
    PROF_LUCKY,
    PROF_HOUSEWIFE,
    PROF_HPTHIEF,
    PROF_EXCHANGE,
    PROF_ROBBER,
    PROF_ZHONYA,
    PROF_COUNT
};

enum _:CrateType
{
    CRATE_BRONZE = 0,
    CRATE_SILVER,
    CRATE_GOLD,
    CRATE_COUNT
};

enum _:AdminOp
{
    AOP_NONE = 0,
    AOP_ROLE_PRIME,
    AOP_ROLE_ISYAN,
    AOP_ROLE_MANAGER,
    AOP_BAN,
    AOP_UNBAN,
    AOP_TL,
    AOP_COIN,
    AOP_XP,
    AOP_COS_GIVE,
    AOP_COS_TAKE
};

// Slot numaralari nVault kayitlariyla ayni kalir. Kaldirilan turlerin bos
// slotlari satin alinmis diger urunlerin ID'lerini kaydirmamak icin tutulur.
new const g_CosPrefix[][] = {
    // Prime Market
    "PRIME_KNIFE1", "PRIME_KNIFE2",
    "PRIME_PLAYER1", "PRIME_PLAYER2",
    "PRIME_PET1", "PRIME_PET2",
    "PRIME_WING1", "PRIME_WING2",
    "PRIME_KILLFX1", "PRIME_KILLFX2",
    "", "", // Eski 10-11 slotlari kullanilmaz.
    "PRIME_TRAIL1", "PRIME_TRAIL2",

    // Normal Coin Market
    "COIN_N_KNIFE1", "COIN_N_KNIFE2",
    "COIN_N_PLAYER1", "COIN_N_PLAYER2",
    "COIN_N_PET1", "COIN_N_PET2",
    "COIN_N_WING1", "COIN_N_WING2",
    "COIN_N_KILLFX1", "COIN_N_KILLFX2",
    "", "", // Eski 24-25 slotlari kullanilmaz.
    "COIN_N_TRAIL1", "COIN_N_TRAIL2",
    "PRIME_PET3", "COIN_N_PET3" // Sona eklendi: eski nVault urun IDleri korunur.
};

new const g_CosKind[] = {
    COS_KNIFE,COS_KNIFE,COS_PLAYER,COS_PLAYER,COS_RETIRED_PET,COS_RETIRED_PET,COS_WING,COS_WING,COS_KILLFX,COS_KILLFX,COS_RETIRED_AURA,COS_RETIRED_AURA,COS_TRAIL,COS_TRAIL,
    COS_KNIFE,COS_KNIFE,COS_PLAYER,COS_PLAYER,COS_RETIRED_PET,COS_RETIRED_PET,COS_WING,COS_WING,COS_KILLFX,COS_KILLFX,COS_RETIRED_AURA,COS_RETIRED_AURA,COS_TRAIL,COS_TRAIL,
    COS_RETIRED_PET,COS_RETIRED_PET
};

new const g_CosSource[] = {
    SOURCE_PRIME_MENU,SOURCE_PRIME_MENU,SOURCE_PRIME_MENU,SOURCE_PRIME_MENU,SOURCE_PRIME_MENU,SOURCE_PRIME_MENU,SOURCE_PRIME_MENU,SOURCE_PRIME_MENU,SOURCE_PRIME_MENU,SOURCE_PRIME_MENU,SOURCE_PRIME_MENU,SOURCE_PRIME_MENU,SOURCE_PRIME_MENU,SOURCE_PRIME_MENU,
    SOURCE_COIN_NORMAL,SOURCE_COIN_NORMAL,SOURCE_COIN_NORMAL,SOURCE_COIN_NORMAL,SOURCE_COIN_NORMAL,SOURCE_COIN_NORMAL,SOURCE_COIN_NORMAL,SOURCE_COIN_NORMAL,SOURCE_COIN_NORMAL,SOURCE_COIN_NORMAL,SOURCE_COIN_NORMAL,SOURCE_COIN_NORMAL,SOURCE_COIN_NORMAL,SOURCE_COIN_NORMAL,
    SOURCE_PRIME_MENU,SOURCE_COIN_NORMAL
};

#define COS_ITEM_COUNT sizeof(g_CosPrefix)


new const g_DefaultRankNames[MAX_RANKS][] = {
    "Cirak Isyanci",
    "Direnis Yolcusu",
    "Bagimsiz Kahraman",
    "Asi Bilge",
    "Ozgurluk Savascisi",
    "Isyanin Simgesi",
    "Mucadeleci",
    "Gelisen Isyanci",
    "Direnme Ustasi",
    "Kahramanlik Nidasi",
    "Devrim Lideri",
    "Ozgur Ruh",
    "Isyanin Gozcusu",
    "Yildiz Isyanci",
    "Efsanevi Kahraman",
    "Isyanin Efendisi",
    "Direnis Onderi",
    "Kahramanlik Isigi",
    "Isyanin Kudreti",
    "Ozgurluk Krali"
};

new const g_DefaultRankXP[MAX_RANKS] = {
    0, 100, 250, 450, 700, 1000, 1400, 1900, 2500, 3200,
    4000, 5000, 6200, 7600, 9200, 11000, 13000, 15500, 18500, 22000
};

new const g_ProfessionNames[PROF_COUNT][] = {
    "Secilmedi",
    "Punisher",
    "Bombaci",
    "Terminator",
    "Sansli Adam",
    "Ev Hanimi",
    "HP Hirsizi",
    "Döviz Bürosu",
    "Soyguncu",
    "Zhonya"
};

new const g_CrateNames[CRATE_COUNT][] = {
    "Bronz Kasa",
    "Gumus Kasa",
    "Altin Kasa"
};

new const g_CrateRollNames[][] = {
    "25 TL", "50 TL", "100 TL", "Coin", "+50 HP", "+100 HP",
    "1 Mermili Deagle", "M4A1", "AK-47", "HE Bomba", "Bomba Seti"
};

// ============================================================
// CONFIG CACHE
// ============================================================

new g_CfgCount;
new g_CfgKey[MAX_CFG][MAX_CFG_KEY];
new g_CfgVal[MAX_CFG][MAX_CFG_VAL];

// ============================================================
// PLAYER DATA
// ============================================================

new _:g_iVault = _:INVALID_HANDLE;
new g_iUID[33];
new g_iTL[33];
new g_iCoin[33];
new bool:g_bDonateMediaEnabled[33];
new bool:g_bSoundMenuEnabled[33],bool:g_bKnifeSoundsEnabled[33],bool:g_bSoundSentRound[33];
new bool:g_bChatMessagesEnabled[33];
new bool:g_bKnifeSkinsVisible[33],bool:g_bPlayerModelsVisible[33],bool:g_bPrisonerPlayersVisible[33];
new bool:g_bTrailsVisible[33],bool:g_bDeathEffectsVisible[33];
new g_iDefaultPKnifeModel;
new g_iBaseKnifePModelIndex[5];
new Array:g_aSoundMenuNames = Invalid_Array;
new Array:g_aSoundMenuPaths = Invalid_Array;
new Array:g_aSoundMenuPrices = Invalid_Array;
new Array:g_aSoundMenuReady = Invalid_Array;
new g_iSoundSpeakerSprite;
new Float:g_flSoundSpeakerUntil[33];
new const SOUND_MENU_INI[]="addons/amxmodx/configs/FeliciaClan/Ses_Menu.ini";
#define TASK_SOUND_SPEAKER 775800

#define DONATE_HISTORY_LIMIT 100
#define DONATE_MESSAGE_LEN 127
#define TASK_DONATE_SPRITE 779000
#define TASK_DONATE_REFRESH 779100

enum _:DonateCurrencyType
{
    DONATE_CURRENCY_TL = 0,
    DONATE_CURRENCY_COIN,
    DONATE_CURRENCY_COUNT
};

new g_iDonateCurrency[33];
new g_iDonateAmount[33];
new g_szDonateMessage[33][DONATE_MESSAGE_LEN + 1];
new bool:g_bDonateUsedRound[33];
new bool:g_bDonateSpriteActive[33];
new bool:g_bDonateSpriteSending[33];
new g_iDonateSpriteCurrency[33];
new g_iDonateSpriteTier[33];
new g_iDonateHistorySerial;
new g_iDonateHudSync;
new g_iDonateAmountHudSync;
new g_iDonateMsgWeaponList;
new g_iDonateMsgCurWeapon;
new g_iDonateMsgSetFov;

new g_iDonateTierFirstMax[DONATE_CURRENCY_COUNT];
new g_iDonateTierSecondMax[DONATE_CURRENCY_COUNT];
new g_iDonateMaxAmount[DONATE_CURRENCY_COUNT];
new g_szDonateSpriteName[DONATE_CURRENCY_COUNT][3][96];
new g_szDonateSoundName[DONATE_CURRENCY_COUNT][3][96];
new g_szDonateWeaponName[DONATE_CURRENCY_COUNT][3][32];
new bool:g_bDonateSpriteReady[DONATE_CURRENCY_COUNT][3];
new bool:g_bDonateSoundReady[DONATE_CURRENCY_COUNT][3];

new g_iPlayRewardMinutes[33];
#define PLAY_REWARD_TASK 28000
#define PLAY_REWARD_MINUTES 30
#define PLAY_REWARD_COINS 100
#define TASK_PREVIEW 12000
new g_iTLSpent[33],g_iCoinEarned[33],g_iCoinSpent[33],g_iExchangeRemainder[33];
new g_iHPBought[33],g_iJBRoundStamp;
new g_iBonusDailyNext[33],g_iBonusPlayStamp[33],bool:g_bBonusRound[33];
// A normal studio entity uses its actual modelindex. Player slots use userinfo
// models in the client renderer, so substituting ES_ModelIndex cannot preview them.
enum { PREV_IDLE, PREV_WALK, PREV_RUN, PREV_DUCK_IDLE, PREV_DUCK_WALK, PREV_POSES };
#define PREVIEW_EDICT_CACHE 8192
new g_iPreviewPrivateOwner[PREVIEW_EDICT_CACHE];
new g_iPreviewController[COS_ITEM_COUNT][4],g_iPreviewBlend[COS_ITEM_COUNT][PREV_POSES][2];
new bool:g_bPreviewModelMeta[COS_ITEM_COUNT];
new g_iPreviewSeq[COS_ITEM_COUNT][PREV_POSES],g_iPreviewFrames[COS_ITEM_COUNT][PREV_POSES];
new Float:g_flPreviewFPS[COS_ITEM_COUNT][PREV_POSES];
new g_iPreviewPose[33];new Float:g_flPreviewPoseStart[33];
#define TASK_DETAIL_ANIM 913005
#define TASK_DETAIL_START 913006
#define DETAIL_FIELDS 15
new const DETAIL_KEYS[][]={"Uyelik:","UID:","HP:","TL:","Coin:","Rank:","XP:","Meslek:","Oyun:","God:","Hard:","Mahkûm:","El:","Zipla:","JBMenu:"};
new bool:g_bDetailHud[33];
new g_iDetailRound;
new g_iDetailStamp[33],g_iDetailHash[33][DETAIL_FIELDS];
new Float:g_flDetailIntro[33],Float:g_flDetailUntil[33],Float:g_flDetailChange[33][DETAIL_FIELDS];
new g_szDetailBody[33][480],g_szDetailWord[33][192],g_szDetailInner[33][192];
new Float:g_flDetailX[33],Float:g_flDetailY[33];
new g_iDetailColor[33][6];
new g_iPreviewCount;
new g_iPreviewCos[33],g_iPreviewUID[33],g_iPreviewCamera[33],g_iPreviewProp[33],g_iPreviewOldWeapon[33];
new Float:g_flPreviewEnd[33],Float:g_flPreviewNextFX[33];
new g_szPreviewOldView[33][128],g_szPreviewAsset[COS_ITEM_COUNT][128],g_iPreviewAssetIndex[COS_ITEM_COUNT];
new g_iRoleExpiry[33][ROLE_COUNT];
new g_iCosExpiry[33][COS_ITEM_COUNT];
new g_iHudTeam[33],g_iRentalMenu[33],g_iRentalMinute[33];
new bool:g_bInfoHudShown[33];
new bool:g_bRentalRefresh[33],bool:g_bRentalOwned[33];
new g_iLeaseBase;new Float:g_flLeaseBase;
new g_iSelectedCos[33][COS_KIND_COUNT];
new g_iBaseKnife[33]; // 0 T, 1 CT, 2 -2 TL #1, 3 -2 TL #2, 4 Testere
new bool:g_bSpecialKnifeBought[33];
new bool:g_bMainAdUsed[33]; // Ana market reklaminin bu round/life icinde kullanilma durumu
new bool:g_bDoubleDamage[33];
new bool:g_bDamageShield[33];
new bool:g_bSilentSteps[33];
new bool:g_bVampire[33];
new bool:g_bPanelAuth[33];
new bool:g_bGuestMode[33]; // Hesaba giris yapmadan devam eden oyuncu
new g_iWingEnt[33];
new g_iPetEnt[33];
new bool:g_bHidePets[33]; // Her oyuncunun kendi gorunurluk tercihi
new bool:g_bTrailActive[33];
new Float:g_flTrailExpiresAt[33];
new Float:g_flTrailLife[33];
new Float:g_vecTrailParticleOrigin[33][3];
new bool:g_bCosmeticPlayerModel[33];
new g_iLastCosmeticTeam[33];
new g_iSpriteIndex[COS_ITEM_COUNT];
new g_iDailyStamp[33];
new g_iDailyKills[33];
new g_iPlayMinutes[33];
new g_iCTMinutes[33];
new g_iCTKills[33];
new g_iRebelKills[33];
new g_iLastRewardKill[33][33];
new g_iLastStatKill[33][33];
new g_szMotd[MOTD_HTML_SIZE + 1];
new g_iMarketCosCallback;
new g_iAdminCosCallback;

new g_iRank[33];
new g_iXP[33];
new g_iProfession[33];
new bool:g_bProfessionZhonyaActive[33];
new bool:g_bProfessionZhonyaAddedFrozen[33];
new Float:g_flProfessionZhonyaNextUse[33];
new g_iProfessionZhonyaOldRenderFx[33];
new g_iProfessionZhonyaOldRenderMode[33];
new Float:g_flProfessionZhonyaOldRenderColor[33][3];
new Float:g_flProfessionZhonyaOldRenderAmt[33];
new g_iRobberyTarget[33], g_iRobberyThief[33];
new g_iRobberyOwnerUserid[33], g_iRobberyTargetUserid[33];
new Float:g_flRobberyStart[33], Float:g_flRobberyDuration[33];
new Float:g_vecRobberyStartOrigin[33][3];
new g_iProfessionRobberyHudSync, g_iProfessionWarningHudSync;
new bool:g_bProfileLoaded[33];
new g_iLifeSerial[33],g_iSpawnMenuLife[33],g_iSpawnMenuSession[33];
new g_iProfessionLife[33],g_iProfessionSession[33],g_iProfessionApplied[33];
#define TASK_PROFESSION_SPAWN 871800
new bool:g_bProfessionChosenRound[33];
new bool:g_bLuckyUsedRound[33];
new g_iLastProfessionTick[33];
new g_iAirJumps[33];
new g_iAirJumpLimit[33]; // Normal/Isyan/Misafir: 2X, Prime/Yonetici: 3X
new g_iDisplayTagMode[33];
new bool:g_bClanTagEnabled[33];
new bool:g_bRankTagEnabled[33];
new g_iClanBridgePlugin = -1;
new g_iClanInfoFunction = -1;
new g_iClanMenuFunction = -1;
new g_iHudMode[33];
new bool:g_bForceHud[33];

new g_iDailyPlayMinutes[33];
new g_iDailyCrates[33];
new g_iDailyPurchases[33];
new g_iDailySurvives[33];
new g_iTaskClaimMask[33];

new g_iCrateType[33];
new g_iCrateTick[33];

// Satin alma akisi
new g_iPendingCos[33];

// Admin akisi
new g_iAdminOp[33];
new g_iAdminTargetUID[33];
new g_iAdminCos[33];
new bool:g_bAdminTake[33];
new bool:g_bAdminCosmeticTargetFlow[33];

// CT TL verme/alma akisi
new g_iCTTLFilter[33]; // 1=tum mahkumlar, 2=hayatta olan mahkumlar
new g_iCTTLTarget[33];
new g_iCTTLOperation[33];
new g_iSpawnMenuTry[33];

// Son mahkum kilidi: round icinde en az 2 T gorulduktan sonra 1 T kalirsa JBMenu kapanir.
new bool:g_bHadMultipleTThisRound;
// Remember entrants until finish, including after the provider clears a dead player.
new bool:g_bHWJoined[33];
new Float:g_fcActivityTime=-1.0,g_fcActivitySerial;
new bool:g_fcFrameCT,bool:g_fcFrameLR,bool:g_fcFrameRocket,HogwartsState:g_fcFrameHog;
new g_fcActivityStamp[33],bool:g_fcActivityResult[33],g_fcExpiryCheck[33];
new bool:g_bCTJoined[33], bool:g_bCTHard;

// ============================================================
// FELICIACLAN CEKILIS SISTEMI - V7
// UID bazli katilim, nVault kaliciligi ve cevrimdisi odul kuyrugu.
// ============================================================
#define FC_RAFFLE_MAX 128
#define FC_RAFFLE_PARTICIPANTS 64
#define FC_RAFFLE_TASK 28971
#define FC_RAFFLE_TITLE_LEN 48
#define FC_RAFFLE_NAME_LEN 32

enum _:FCRaffleReward {
    RF_REWARD_TL = 1,
    RF_REWARD_COIN,
    RF_REWARD_PRIME,
    RF_REWARD_COSMETIC
};
enum _:FCRaffleFee {
    RF_FEE_FREE = 0,
    RF_FEE_TL,
    RF_FEE_COIN
};
enum _:FCRaffleEndMode {
    RF_END_TIME = 1,
    RF_END_PARTICIPANTS
};

new g_iRaffleCount;
new bool:g_bRaffleActive[FC_RAFFLE_MAX];
new g_iRaffleCreatorUID[FC_RAFFLE_MAX];
new g_szRaffleCreator[FC_RAFFLE_MAX][FC_RAFFLE_NAME_LEN];
new g_szRaffleTitle[FC_RAFFLE_MAX][FC_RAFFLE_TITLE_LEN];
new g_iRaffleRewardType[FC_RAFFLE_MAX];
new g_iRaffleRewardAmount[FC_RAFFLE_MAX];
new g_iRaffleRewardCosmetic[FC_RAFFLE_MAX];
new g_iRaffleFeeType[FC_RAFFLE_MAX];
new g_iRaffleFeeAmount[FC_RAFFLE_MAX];
new g_iRaffleEndMode[FC_RAFFLE_MAX];
new g_iRaffleEndValue[FC_RAFFLE_MAX];
new g_iRaffleCreatedAt[FC_RAFFLE_MAX];
new g_iRaffleEndsAt[FC_RAFFLE_MAX];
new g_iRaffleFinishedAt[FC_RAFFLE_MAX];
new g_iRaffleParticipantCount[FC_RAFFLE_MAX];
new g_iRaffleParticipantUID[FC_RAFFLE_MAX][FC_RAFFLE_PARTICIPANTS];
new g_szRaffleParticipantName[FC_RAFFLE_MAX][FC_RAFFLE_PARTICIPANTS][FC_RAFFLE_NAME_LEN];
new g_iRaffleWinnerUID[FC_RAFFLE_MAX];
new g_szRaffleWinnerName[FC_RAFFLE_MAX][FC_RAFFLE_NAME_LEN];
new bool:g_bRaffleRewardDelivered[FC_RAFFLE_MAX];

new g_iRaffleBackPage[33];
new g_iRaffleReturnMode[33];
new g_iRaffleDraftReward[33];
new g_iRaffleDraftAmount[33];
new g_iRaffleDraftCosmetic[33];
new g_iRaffleDraftFee[33];
new g_iRaffleDraftFeeAmount[33];
new g_iRaffleDraftEndMode[33];
new g_iRaffleDraftEndValue[33];
new g_szRaffleDraftTitle[33][FC_RAFFLE_TITLE_LEN];


// ============================================================
// DIS PLUGIN API
// ============================================================

public plugin_natives()
{
    set_native_filter("OptionalCTMenuNative");
    register_library("feliciaclan_jbmenu");
    register_library("feliciaclan_lr_wallet");
    register_native("fc_lr_wallet_hold","N_LRHold");
    register_native("fc_lr_wallet_settle","N_LRSettle");
    register_native("fc_get_uid", "N_GetUID");
    register_native("fc_get_tl", "N_GetTL");
    register_native("fc_set_tl", "N_SetTL");
    register_native("fc_add_tl", "N_AddTL");
    register_native("fc_get_coin", "N_GetCoin");
    register_native("fc_set_coin", "N_SetCoin");
    register_native("fc_add_coin", "N_AddCoin");
    register_native("fc_is_prime", "N_IsPrime");
    register_native("fc_is_isyanteam", "N_IsIsyan");
    register_native("fc_is_manager", "N_IsManager");
    register_native("fc_get_rank", "N_GetRank");
    register_native("fc_get_xp", "N_GetXP");
    register_native("fc_add_xp", "N_AddXP");
    register_native("fc_get_profession", "N_GetProfession");
    register_native("fc_donate_media_enabled", "N_DonateMediaEnabled");
}
public OptionalCTMenuNative(const name[], index, trap)
{
    if(!trap && (contain(name,"fc_ct_")==0 || contain(name,"fc_lr_")==0)) return PLUGIN_HANDLED;
    return PLUGIN_CONTINUE;
}

public N_GetUID(plugin, params) { return g_iUID[get_param(1)]; }
public N_GetTL(plugin, params) { return g_iTL[get_param(1)]; }
public N_GetCoin(plugin, params) { return g_iCoin[get_param(1)]; }
public N_DonateMediaEnabled(plugin, params)
{
    new id = get_param(1);
    if(id < 1 || id > MaxClients || !is_user_connected(id)) return 1;
    return g_bDonateMediaEnabled[id] ? 1 : 0;
}
public N_IsPrime(plugin, params) { return HasRole(get_param(1), ROLE_PRIME); }
public N_IsIsyan(plugin, params) { return HasRole(get_param(1), ROLE_ISYANTEAM); }
public N_IsManager(plugin, params) { return HasRole(get_param(1), ROLE_MANAGER); }
public N_GetRank(plugin, params) { return g_iRank[get_param(1)]; }
public N_GetXP(plugin, params) { return g_iXP[get_param(1)]; }
public N_GetProfession(plugin, params) { return g_iProfession[get_param(1)]; }
public N_AddXP(plugin, params)
{
    new id = get_param(1);
    new amount = get_param(2);
    AddXP(id, amount);
    SavePlayer(id);
    return g_iXP[id];
}

public N_SetTL(plugin, params)
{
    new id = get_param(1);
    new value=max(0,get_param(2));FC_RecordTLSpend(id,max(0,g_iTL[id]-value));g_iTL[id]=value;
    SavePlayer(id);
    return g_iTL[id];
}

public N_AddTL(plugin, params)
{
    new id = get_param(1);
    new value=max(0,g_iTL[id]+get_param(2));FC_RecordTLSpend(id,max(0,g_iTL[id]-value));g_iTL[id]=value;
    SavePlayer(id);
    return g_iTL[id];
}

public N_SetCoin(plugin, params)
{
    new id = get_param(1);
    FC_CoinChange(id,max(0,get_param(2))-g_iCoin[id]);
    SavePlayer(id);
    return g_iCoin[id];
}

public N_AddCoin(plugin, params)
{
    new id = get_param(1);
    FC_CoinChange(id,get_param(2));
    SavePlayer(id);
    return g_iCoin[id];
}

// ============================================================
// STARTUP
// ============================================================

public plugin_precache()
{
    LoadConfig();
    LoadSoundMenuConfig();
    g_iDefaultPKnifeModel = precache_model("models/p_knife.mdl");
    if(file_exists("sprites/voiceicon.spr")) g_iSoundSpeakerSprite=precache_model("sprites/voiceicon.spr");
    else if(file_exists("sprites/voice.spr")) g_iSoundSpeakerSprite=precache_model("sprites/voice.spr");
    DonatePrecacheMedia();
    PrecacheNotificationSounds();
    PrecacheConfiguredAssets();
}

// Matematik quiz sistemi
#define QUIZ_START_TASK 789321
#define QUIZ_END_TASK 789322
new g_iQuizAnswer = -1;
new bool:g_bQuizActive = false;
new g_pQuizInterval, g_pQuizReward, g_pQuizTLReward;
new bool:g_bQuizTL = false;
new bool:g_bQuizInfo = false;
new g_iQuizRound = 0, g_iQuizQuestion = -1;
new bool:g_bQuizUsed[100];
new g_iQuizUsedCount = 0;
new g_iQuizQuestionCount = 0;
new g_szQuizQuestions[100][128], g_szQuizAnswers[100][128];

QuizLoadQuestions()
{
    g_iQuizQuestionCount = 0;
    new key[32], question[128], answer[128];
    for(new i = 0; i < 100; i++)
    {
        formatex(key, charsmax(key), "QUIZ_Q_%03d", i+1);
        CfgStr(key, question, charsmax(question), "");
        formatex(key, charsmax(key), "QUIZ_A_%03d", i+1);
        CfgStr(key, answer, charsmax(answer), "");
        if(!question[0] || !answer[0]) continue;
        copy(g_szQuizQuestions[g_iQuizQuestionCount], 127, question);
        copy(g_szQuizAnswers[g_iQuizQuestionCount], 127, answer);
        g_iQuizQuestionCount++;
    }
    arrayset(g_bQuizUsed, false, sizeof g_bQuizUsed);
    g_iQuizUsedCount = 0;
}

QuizChooseQuestion()
{
    if(!g_iQuizQuestionCount) return -1;
    if(g_iQuizUsedCount >= g_iQuizQuestionCount)
    {
        arrayset(g_bQuizUsed, false, sizeof g_bQuizUsed);
        g_iQuizUsedCount = 0;
    }
    new index;
    do { index = random(g_iQuizQuestionCount); } while(g_bQuizUsed[index]);
    g_bQuizUsed[index] = true;
    g_iQuizUsedCount++;
    return index;
}

QuizNormalize(const source[], output[], length)
{
    copy(output, length, source);
    trim(output);
    strtolower(output);
    // Turkce harfleri ASCII karsiliklariyla esitle.
    replace_all(output, length, "ç", "c");
    replace_all(output, length, "Ç", "c");
    replace_all(output, length, "ğ", "g");
    replace_all(output, length, "Ğ", "g");
    replace_all(output, length, "ı", "i");
    replace_all(output, length, "İ", "i");
    replace_all(output, length, "ö", "o");
    replace_all(output, length, "Ö", "o");
    replace_all(output, length, "ş", "s");
    replace_all(output, length, "Ş", "s");
    replace_all(output, length, "ü", "u");
    replace_all(output, length, "Ü", "u");
    replace_all(output, length, " ", "");
    replace_all(output, length, ".", "");
    replace_all(output, length, "'", "");
}

public QuizStart()
{
    g_bQuizActive = true;
    g_iQuizRound++;
    g_bQuizInfo = (g_iQuizQuestionCount > 0 && g_iQuizRound % 3 == 0);
    if(g_bQuizInfo)
    {
        g_iQuizQuestion = QuizChooseQuestion();
        client_print_color(0, print_team_default, "^3[Felicia Quiz] ^1Bilgi Sorusu: ^4%s", g_szQuizQuestions[g_iQuizQuestion]);
        client_print_color(0, print_team_default, "^3[Felicia Quiz] ^1Odul: ^4%d Coin", 250);
        remove_task(QUIZ_END_TASK);
        set_task(20.0, "QuizFinish", QUIZ_END_TASK);
        return;
    }
    g_bQuizTL = !g_bQuizTL; // Matematik: TL, Coin sirali
    new reward = g_bQuizTL ? max(0,get_pcvar_num(g_pQuizTLReward)) : max(0,get_pcvar_num(g_pQuizReward));
    new rewardName[8];
    copy(rewardName, charsmax(rewardName), g_bQuizTL ? "TL" : "Coin");
    new a, b, op = random_num(0, 2);
    switch(op)
    {
        case 0: { a = random_num(1,50); b = random_num(1,50); g_iQuizAnswer = a+b; client_print_color(0, print_team_default, "^3[Felicia Quiz] ^1%s Sorusu: ^4%d + %d = ? ^1Odul: ^4%d %s", rewardName,a,b,reward,rewardName); }
        case 1: { a = random_num(1,10); b = random_num(1,10); g_iQuizAnswer = a*b; client_print_color(0, print_team_default, "^3[Felicia Quiz] ^1%s Sorusu: ^4%d x %d = ? ^1Odul: ^4%d %s", rewardName,a,b,reward,rewardName); }
        case 2: { a = random_num(30,50); b = random_num(1,30); g_iQuizAnswer = a-b; client_print_color(0, print_team_default, "^3[Felicia Quiz] ^1%s Sorusu: ^4%d - %d = ? ^1Odul: ^4%d %s", rewardName,a,b,reward,rewardName); }
    }
    remove_task(QUIZ_END_TASK);
    set_task(20.0, "QuizFinish", QUIZ_END_TASK);
}

public QuizFinish()
{
    if(g_bQuizActive)
        if(g_bQuizInfo)
            client_print_color(0, print_team_default, "^3[Felicia Quiz] ^1Sure bitti! Dogru cevap: ^4%s", g_szQuizAnswers[g_iQuizQuestion]);
        else
            client_print_color(0, print_team_default, "^3[Felicia Quiz] ^1Sure bitti! Dogru cevap: ^4%d", g_iQuizAnswer);
    g_bQuizActive = false;
    g_iQuizAnswer = -1;
    remove_task(QUIZ_START_TASK);
    set_task(float(max(1,get_pcvar_num(g_pQuizInterval))), "QuizStart", QUIZ_START_TASK);
}

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);
    g_pQuizInterval = register_cvar("fc_quiz_suresi", "200");
    g_pQuizReward = register_cvar("fc_quiz_coin", "150");
    g_pQuizTLReward = register_cvar("fc_quiz_tl", "20");
    QuizLoadQuestions();
    set_task(20.0, "QuizStart", QUIZ_START_TASK);
    set_task(0.03, "TaskPetFollow", 198734, _, _, "b");
    g_bRocketAPI=bool:LibraryExists("fc_ct_rocket",LibType_Library);
    g_bCTHard = get_cvar_num("fc_ct_hard") != 0;

    register_clcmd("say", "CmdSay");
    register_clcmd("say_team", "CmdSay");
    register_clcmd("nightvision", "CmdJBMenu");

    register_clcmd("FC_Panel_Sifre", "CmdPanelPassword");
    register_clcmd("FC_Admin_UID", "CmdAdminUID");
    register_clcmd("FC_Admin_Miktar", "CmdAdminAmount");
    register_clcmd("FC_UID_Ara", "CmdUIDSearch");
    register_clcmd("FC_CT_TL_Miktar", "CmdCTTLAmount");
    register_clcmd("FC_Raffle_Name", "CmdRaffleName");
    register_clcmd("FC_Raffle_RewardAmount", "CmdRaffleRewardAmount");
    register_clcmd("FC_Raffle_FeeAmount", "CmdRaffleFeeAmount");
    register_clcmd("FC_Raffle_EndValue", "CmdRaffleEndValue");
    register_clcmd("FC_DonateAmount", "CmdDonateAmount");
    register_clcmd("FC_DonateMessage", "CmdDonateMessage");

    RegisterHookChain(RG_CBasePlayer_Spawn, "HC_Spawn_Post", true);
    RegisterHookChain(RG_HandleMenu_ChooseAppearance,"HC_NoCTAppearance_Post",true);
    RegisterHookChain(RG_CBasePlayer_Killed, "HC_Killed_Post", true);
    RegisterHookChain(RG_CBasePlayer_TakeDamage, "HC_TakeDamage_Pre", false);
    RegisterHookChain(RG_CBasePlayerWeapon_DefaultDeploy, "HC_Deploy_Pre", false);
    register_forward(FM_PlayerPreThink, "Fwd_PlayerPreThink");
    register_forward(FM_EmitSound, "Fwd_EmitSound_Pre", false);
    register_forward(FM_AddToFullPack,"PreviewPackPre",false);
    register_forward(FM_AddToFullPack,"PreviewPackPost",true);
    register_forward(FM_CmdStart,"PreviewCmdStart");
    register_forward(FM_PlayerPostThink,"PreviewPostThink",true);
    g_iJBRoundStamp=get_systime();

    register_logevent("EventRoundStart", 2, "1=Round_Start");
    register_logevent("EventRoundEnd", 2, "1=Round_End");
    register_event("TeamInfo", "EventCosmeticTeamInfo", "a");
    register_event("CurWeapon", "EventDonateCurWeapon", "be", "1=1");
    register_event("SetFOV", "EventDonateSetFOV", "be");

    g_iDonateMsgWeaponList = get_user_msgid("WeaponList");
    g_iDonateMsgCurWeapon = get_user_msgid("CurWeapon");
    g_iDonateMsgSetFov = get_user_msgid("SetFOV");
    g_iDonateHudSync = CreateHudSyncObj();
    g_iDonateAmountHudSync = CreateHudSyncObj();
    g_iProfessionRobberyHudSync = CreateHudSyncObj();
    g_iProfessionWarningHudSync = CreateHudSyncObj();

    g_iMarketCosCallback = menu_makecallback("CB_MarketCosmetic");
    g_bNoCTHadCT=NoCTHasGuard();
    g_iAdminCosCallback = menu_makecallback("CB_AdminCosmetic");

    set_task(180.0, "TaskPetHideNotice", 9010, "", 0, "b");
    set_task(60.0, "TaskPlayMinute", 9001, "", 0, "b");
    set_task(0.25, "TaskVisualRefresh", 9002, "", 0, "b");
    set_task(1.0, "TaskHud", TASK_HUD, "", 0, "b");

    g_iVault = nvault_open(VAULT_NAME);
    if(g_iVault == INVALID_HANDLE)
        set_fail_state("FeliciaClan JBMenu nVault acilamadi.");
    DonateLoadHistoryCounter();
    RaffleLoadAll();
    set_task(1.0, "RaffleTick", FC_RAFFLE_TASK, "", 0, "b");
}

public TaskPetHideNotice()
{
    client_print_color(0, print_team_default, "^3(^4Felicia^3) ^1Pet modellerini gizlemek icin /petgizle yazmaniz yeterlidir.");
}

public plugin_end()
{
    // Map degisimi / plugin kapanisi oncesi online hesaplari son kez kaydet.
    for(new id = 1; id <= MaxClients; id++)
    {
        StopPreview(id,false);
        if(is_user_connected(id) && g_iUID[id] > 0)
            SavePlayer(id);
    }

    if(g_iVault != INVALID_HANDLE)
        nvault_close(g_iVault);
    if(g_aSoundMenuNames != Invalid_Array) ArrayDestroy(g_aSoundMenuNames);
    if(g_aSoundMenuPaths != Invalid_Array) ArrayDestroy(g_aSoundMenuPaths);
    if(g_aSoundMenuPrices != Invalid_Array) ArrayDestroy(g_aSoundMenuPrices);
    if(g_aSoundMenuReady != Invalid_Array) ArrayDestroy(g_aSoundMenuReady);
}

// ============================================================
// ACCOUNT FORWARDS
// ============================================================

public client_putinserver(id)
{
    ResetRuntime(id);
    g_bDonateUsedRound[id] = false;
    g_iPlayRewardMinutes[id] = 0;
    remove_task(PLAY_REWARD_TASK + id);
    set_task(60.0, "TaskPlayReward", PLAY_REWARD_TASK + id, _, _, "b");
    g_iNoCTJoinUID[id]=get_user_userid(id);g_bNoCTFirstTeam[id]=true;
    NoCTRefreshLater();
}

public client_disconnected(id)
{
    CancelProfessionActions(id);
    remove_task(PLAY_REWARD_TASK + id);
    remove_task(id + TASK_DONATE_SPRITE);
    remove_task(id + TASK_DONATE_REFRESH);
    g_bDonateSpriteActive[id] = false;
    g_bDonateSpriteSending[id] = false;
    g_bDonateUsedRound[id] = false;
    g_iPlayRewardMinutes[id] = 0;
    StopPreview(id,false);
    if(g_iUID[id] > 0)
        SavePlayer(id);

    RemoveCosmeticEntities(id);
    ResetRuntime(id);
    NoCTRefreshLater();
}

public TaskPlayReward(taskid)
{
    new id = taskid - PLAY_REWARD_TASK;
    if(!is_user_connected(id) || is_user_bot(id) || is_user_hltv(id)) return;

    // Hesaba giris yapilmadan Coin verilmez; sure sadece giris yapildiginda ilerler.
    if(g_iUID[id] <= 0 || !g_bProfileLoaded[id] || g_bGuestMode[id]) return;

    g_iPlayRewardMinutes[id]++;
    if(g_iPlayRewardMinutes[id] < PLAY_REWARD_MINUTES) return;

    g_iPlayRewardMinutes[id] = 0;
    FC_CoinChange(id, PLAY_REWARD_COINS);
    SavePlayer(id);
    Chat(id, "Oyunda 30 dakika kaldigin icin ^4+100 Coin^1 kazandin!");
}

public pUserLogged(id)
{
    new uid=nGetUidByID(id);if(uid<=0) return;
    if(g_iUID[id]>0 && g_iUID[id]!=uid) {
        if(LibraryExists("fc_lr",LibType_Library)) fc_lr_account_changed(id);
        StopPreview(id,false);SavePlayer(id);ResetRuntime(id);
    }
    g_bGuestMode[id]=false;
    if(g_iUID[id]!=uid || !g_bProfileLoaded[id]) {g_iUID[id]=uid;LoadPlayer(id);}
    // Duplicate account forwards cannot reload stale progression or reset a profession.
    CleanupExpired(id);
    ValidateSelectedCosmetics(id);
    RaffleDeliverPending(id);

    // AutoLogin bazen oyuncu dogduktan sonra tamamlanabilir.
    // Secili kozmetiklerin cik-gir sonrasi tekrar aktif kalmasi icin hemen uygula.
    if(is_user_alive(id))
    {
        QueueProfessionSpawn(id,0.15);
        remove_task(id);
        set_task(0.25, "TaskApplyCosmetics", id);

        // AutoLogin spawn'dan sonra tamamlanirsa Ana Market yine otomatik acilsin.
        if(get_member(id, m_iTeam) == TEAM_TERRORIST)
        {
            QueueSpawnMenu(id,0.35);
        }
    }

    Chat(id, "Hesabin yuklendi. ^3UID: %d", g_iUID[id]);
}

public pUserRegistered(id)
{
    // Hesap sistemi hemen arkasindan pUserLogged forwardunu da calistirir.
    Chat(id, "Hesabin olusturuldu.");
}

public pUserExit(id)
{
    CancelProfessionActions(id);
    if(LibraryExists("fc_lr",LibType_Library)) fc_lr_account_changed(id);
    StopPreview(id,false);
    g_bGuestMode[id] = false;

    if(g_iUID[id] > 0)
        SavePlayer(id);

    CancelSpawnWork(id);g_bProfileLoaded[id]=false;
    g_iProfession[id]=PROF_NONE;g_iProfessionApplied[id]=-1;
    g_bProfessionChosenRound[id]=false;
    g_iUID[id] = 0;g_iHudTeam[id]=-1;g_iRentalMenu[id]=-1;g_bClanTagEnabled[id]=false;g_bRankTagEnabled[id]=true;
    g_bDonateMediaEnabled[id] = true;
    g_bSoundMenuEnabled[id]=true;g_bKnifeSoundsEnabled[id]=true;g_bSoundSentRound[id]=false;
    g_bChatMessagesEnabled[id]=true;
    g_bKnifeSkinsVisible[id]=true;
    g_bPlayerModelsVisible[id]=true;
    g_bPrisonerPlayersVisible[id]=true;
    g_bTrailsVisible[id]=true;
    g_bDeathEffectsVisible[id]=true;
    if(is_user_connected(id)) client_cmd(id,"hud_saytext 1");
    g_flSoundSpeakerUntil[id]=0.0;
    g_bInfoHudShown[id]=false;g_bRentalRefresh[id]=false;
    g_iTL[id] = 0;
    g_iCoin[id] = 0;
    RemoveCosmeticEntities(id);
}

public pUserLoggedMulti(id)
{
    pUserExit(id);
}

ResetRuntime(id)
{
    CancelProfessionActions(id);
    g_flProfessionZhonyaNextUse[id] = 0.0;
    g_iRobberyThief[id] = 0;
    CancelSpawnWork(id);g_iLifeSerial[id]++;g_bProfileLoaded[id]=false;
    g_iProfessionApplied[id]=-1;
    FC_ResetPanelHud(id);
    NoCTForgetJoin(id);g_iNoCTMenu[id]=-1;g_iNoCTMenuKind[id]=0;
    if(LibraryExists("fc_lr",LibType_Library)) fc_lr_account_changed(id);
    g_bHWJoined[id] = false;
    g_bCTJoined[id] = false;
    g_iUID[id] = 0;
    g_iTL[id] = 0;
    g_iCoin[id] = 0;
    g_bDonateMediaEnabled[id] = true;
    g_bSoundMenuEnabled[id]=true;g_bKnifeSoundsEnabled[id]=true;g_bSoundSentRound[id]=false;
    g_bChatMessagesEnabled[id]=true;
    g_bKnifeSkinsVisible[id]=true;
    g_bPlayerModelsVisible[id]=true;
    g_bPrisonerPlayersVisible[id]=true;
    g_bTrailsVisible[id]=true;
    g_bDeathEffectsVisible[id]=true;
    if(is_user_connected(id)) client_cmd(id,"hud_saytext 1");
    g_flSoundSpeakerUntil[id]=0.0;
    g_iDonateCurrency[id] = DONATE_CURRENCY_TL;
    g_iDonateAmount[id] = 0;
    g_szDonateMessage[id][0] = 0;
    remove_task(id + TASK_DONATE_SPRITE);
    remove_task(id + TASK_DONATE_REFRESH);
    g_bDonateSpriteActive[id] = false;
    g_bDonateSpriteSending[id] = false;
    g_iTLSpent[id]=g_iCoinEarned[id]=g_iCoinSpent[id]=g_iExchangeRemainder[id]=0;
    g_iHPBought[id]=g_iBonusDailyNext[id]=g_iBonusPlayStamp[id]=0;g_bBonusRound[id]=false;
    g_iPreviewCos[id]=-1;g_iPreviewUID[id]=g_iPreviewCamera[id]=g_iPreviewProp[id]=0;g_iPreviewPose[id]=-1;g_flPreviewPoseStart[id]=0.0;g_bDetailHud[id]=false;g_iDetailStamp[id]=-1;
    g_flPreviewEnd[id]=g_flPreviewNextFX[id]=0.0;
    g_iBaseKnife[id] = -1;
    g_bSpecialKnifeBought[id] = false;
    g_bMainAdUsed[id] = false;
    g_bDoubleDamage[id] = false;
    g_bDamageShield[id] = false;
    g_bSilentSteps[id] = false;
    g_bVampire[id] = false;
    g_bPanelAuth[id] = false;
    g_bGuestMode[id] = false;
    g_iWingEnt[id] = 0;
    g_iPetEnt[id] = 0;
    g_bHidePets[id] = false;
    g_bTrailActive[id] = false;
    g_flTrailExpiresAt[id] = 0.0;
    g_flTrailLife[id] = 0.0;
    arrayset(g_vecTrailParticleOrigin[id], 0, 3);
    g_bCosmeticPlayerModel[id] = false;
    g_iLastCosmeticTeam[id] = _:TEAM_UNASSIGNED;
    g_iDailyStamp[id] = 0;
    g_iDailyKills[id] = 0;
    g_iPlayMinutes[id] = 0;
    g_iCTMinutes[id] = 0;
    g_iCTKills[id] = 0;
    g_iRebelKills[id] = 0;
    g_iDailyPlayMinutes[id] = 0;
    g_iDailyCrates[id] = 0;
    g_iDailyPurchases[id] = 0;
    g_iDailySurvives[id] = 0;
    g_iTaskClaimMask[id] = 0;
    g_iRank[id] = 0;
    g_iXP[id] = 0;
    g_iProfession[id] = PROF_NONE;
    g_bProfessionChosenRound[id] = false;
    g_bLuckyUsedRound[id] = false;
    g_iLastProfessionTick[id] = 0;
    g_iAirJumps[id] = 0;
    g_iAirJumpLimit[id] = 1;
    g_iDisplayTagMode[id] = TAGMODE_AUTO;
    g_bClanTagEnabled[id] = false;
    g_bRankTagEnabled[id] = true;
    g_iHudMode[id] = HUDMODE_FULL;
    g_bForceHud[id] = false;
    g_iCrateType[id] = -1;
    g_iCrateTick[id] = 0;
    g_iPendingCos[id] = -1;
    g_iAdminOp[id] = AOP_NONE;
    g_iAdminTargetUID[id] = 0;
    g_iAdminCos[id] = -1;
    g_bAdminTake[id] = false;
    g_bAdminCosmeticTargetFlow[id] = false;
    g_iCTTLFilter[id] = 0;
    g_iCTTLTarget[id] = 0;
    g_iCTTLOperation[id] = CTTL_NONE;
    g_iSpawnMenuTry[id] = 0;

    for(new p; p <= MaxClients; p++)
    {
        g_iLastRewardKill[id][p] = 0;
        g_iLastStatKill[id][p] = 0;
        g_iLastRewardKill[p][id] = 0;
        g_iLastStatKill[p][id] = 0;
    }

    for(new r; r < ROLE_COUNT; r++)
        g_iRoleExpiry[id][r] = -1;

    for(new i; i < COS_ITEM_COUNT; i++)
        g_iCosExpiry[id][i] = -1;

    for(new k; k < COS_KIND_COUNT; k++)
        g_iSelectedCos[id][k] = -1;
}

// ============================================================
// SAVE / LOAD - UID TEMELLI
// ============================================================

LoadPlayer(id)
{
    if(g_iUID[id] <= 0)
        return;

    g_iTL[id] = UIDGetInt(g_iUID[id], "tl", 0);
    g_iCoin[id] = UIDGetInt(g_iUID[id], "coin", 0);
    LRRecover(id);
    g_iTLSpent[id]=max(0,UIDGetInt(g_iUID[id],"total_tl_spent",0));
    g_iCoinEarned[id]=max(0,UIDGetInt(g_iUID[id],"total_coin_earned",0));
    g_iCoinSpent[id]=max(0,UIDGetInt(g_iUID[id],"total_coin_spent",0));
    g_iExchangeRemainder[id]=clamp(UIDGetInt(g_iUID[id],"exchange_remainder",0),0,9);
    g_iBonusDailyNext[id]=UIDGetInt(g_iUID[id],"bonus_daily_next",0);
    g_iBonusPlayStamp[id]=UIDGetInt(g_iUID[id],"bonus_play_stamp",0);
    new sameRound=UIDGetInt(g_iUID[id],"market_round_stamp",0)==g_iJBRoundStamp;
    g_iHPBought[id]=sameRound?clamp(UIDGetInt(g_iUID[id],"hp_bought",0),0,3):0;
    g_bBonusRound[id]=sameRound?(bool:UIDGetInt(g_iUID[id],"bonus_round",0)):false;

    g_iRoleExpiry[id][ROLE_PRIME] = UIDGetInt(g_iUID[id], "role_prime", -1);
    g_iRoleExpiry[id][ROLE_ISYANTEAM] = UIDGetInt(g_iUID[id], "role_isyan", -1);
    g_iRoleExpiry[id][ROLE_MANAGER] = UIDGetInt(g_iUID[id], "role_manager", -1);

    g_iDailyStamp[id] = UIDGetInt(g_iUID[id], "daily_stamp", 0);
    g_iDailyKills[id] = UIDGetInt(g_iUID[id], "daily_kills", 0);
    g_iPlayMinutes[id] = UIDGetInt(g_iUID[id], "play_minutes", 0);
    g_iCTMinutes[id] = UIDGetInt(g_iUID[id], "ct_minutes", 0);
    g_iCTKills[id] = UIDGetInt(g_iUID[id], "ct_kills", 0);
    g_iRebelKills[id] = UIDGetInt(g_iUID[id], "rebel_kills", 0);
    g_iDailyPlayMinutes[id] = UIDGetInt(g_iUID[id], "daily_play_minutes", 0);
    g_iDailyCrates[id] = UIDGetInt(g_iUID[id], "daily_crates", 0);
    g_iDailyPurchases[id] = UIDGetInt(g_iUID[id], "daily_purchases", 0);
    g_iDailySurvives[id] = UIDGetInt(g_iUID[id], "daily_survives", 0);
    g_iTaskClaimMask[id] = UIDGetInt(g_iUID[id], "task_claim_mask", 0);
    g_iXP[id] = clamp(UIDGetInt(g_iUID[id], "xp", 0), 0, GetMaxRankXP());
    g_iRank[id] = GetRankByXP(g_iXP[id]);
    g_iProfession[id] = clamp(UIDGetInt(g_iUID[id], "profession", PROF_NONE), PROF_NONE, PROF_COUNT-1);
    g_bProfileLoaded[id]=true;
    g_iDisplayTagMode[id] = clamp(UIDGetInt(g_iUID[id], "display_tag_mode", TAGMODE_AUTO), TAGMODE_AUTO, TAGMODE_COUNT-1);
    g_bClanTagEnabled[id] = bool:UIDGetInt(g_iUID[id], "clan_tag_enabled", 0);
    g_bRankTagEnabled[id] = bool:UIDGetInt(g_iUID[id], "rank_tag_enabled", 1);
    g_iHudMode[id] = clamp(UIDGetInt(g_iUID[id], "hud_mode", HUDMODE_FULL), HUDMODE_FULL, HUDMODE_COUNT-1);
    g_bDonateMediaEnabled[id] = bool:UIDGetInt(g_iUID[id], "donate_media", 1);
    g_bSoundMenuEnabled[id] = bool:UIDGetInt(g_iUID[id], "sound_menu_enabled", 1);
    g_bKnifeSoundsEnabled[id] = bool:UIDGetInt(g_iUID[id], "knife_sounds_enabled", 1);
    g_bChatMessagesEnabled[id] = bool:UIDGetInt(g_iUID[id], "chat_messages_enabled", 1);
    g_bKnifeSkinsVisible[id] = bool:UIDGetInt(g_iUID[id], "knife_skins_visible", 1);
    g_bPlayerModelsVisible[id] = bool:UIDGetInt(g_iUID[id], "player_models_visible", 1);
    g_bPrisonerPlayersVisible[id] = bool:UIDGetInt(g_iUID[id], "prisoner_players_visible", 1);
    g_bTrailsVisible[id] = bool:UIDGetInt(g_iUID[id], "trails_visible", 1);
    g_bDeathEffectsVisible[id] = bool:UIDGetInt(g_iUID[id], "death_effects_visible", 1);
    client_cmd(id, "hud_saytext %d", g_bChatMessagesEnabled[id] ? 1 : 0);
    g_bSoundSentRound[id] = UIDGetInt(g_iUID[id],"sound_round_stamp",0)==g_iJBRoundStamp;
    g_bDonateUsedRound[id] = UIDGetInt(g_iUID[id], "donate_round_stamp", 0) == g_iJBRoundStamp;

    for(new i; i < COS_ITEM_COUNT; i++)
    {
        new suffix[48];
        formatex(suffix, charsmax(suffix), "cos_%d", i);
        g_iCosExpiry[id][i] = UIDGetInt(g_iUID[id], suffix, -1);
    }

    for(new k; k < COS_KIND_COUNT; k++)
    {
        new suffix[48];
        formatex(suffix, charsmax(suffix), "selected_%d", k);
        g_iSelectedCos[id][k] = UIDGetInt(g_iUID[id], suffix, -1);
    }

    CleanupExpired(id);
    ValidateSelectedCosmetics(id);
    ValidateDisplayTagMode(id);
    CheckDailyReset(id);
}

SavePlayer(id)
{
    if(g_iUID[id] <= 0 || g_iVault == INVALID_HANDLE)
        return;

    // TL kaydi INI'deki TL_MAX_KAYIT ile sinirlanabilir.
    // 0 veya daha kucuk deger = limitsiz kayit.
    new saveTL = g_iTL[id];
    new maxTL = CfgInt("TL_MAX_KAYIT", 50000);
    if(maxTL > 0 && saveTL > maxTL)
        saveTL = maxTL;

    UIDSetInt(g_iUID[id], "tl", saveTL);

    // Coin icin maksimum kayit YOKTUR; eldeki Coin'in tamami kaydedilir.
    UIDSetInt(g_iUID[id], "coin", g_iCoin[id]);
    UIDSetInt(g_iUID[id],"total_tl_spent",g_iTLSpent[id]);
    UIDSetInt(g_iUID[id],"total_coin_earned",g_iCoinEarned[id]);
    UIDSetInt(g_iUID[id],"total_coin_spent",g_iCoinSpent[id]);
    UIDSetInt(g_iUID[id],"exchange_remainder",g_iExchangeRemainder[id]);
    UIDSetInt(g_iUID[id],"bonus_daily_next",g_iBonusDailyNext[id]);
    UIDSetInt(g_iUID[id],"bonus_play_stamp",g_iBonusPlayStamp[id]);
    UIDSetInt(g_iUID[id],"market_round_stamp",g_iJBRoundStamp);
    UIDSetInt(g_iUID[id],"hp_bought",g_iHPBought[id]);
    UIDSetInt(g_iUID[id],"bonus_round",g_bBonusRound[id]);

    UIDSetInt(g_iUID[id], "role_prime", g_iRoleExpiry[id][ROLE_PRIME]);
    UIDSetInt(g_iUID[id], "role_isyan", g_iRoleExpiry[id][ROLE_ISYANTEAM]);
    UIDSetInt(g_iUID[id], "role_manager", g_iRoleExpiry[id][ROLE_MANAGER]);

    UIDSetInt(g_iUID[id], "daily_stamp", g_iDailyStamp[id]);
    UIDSetInt(g_iUID[id], "daily_kills", g_iDailyKills[id]);
    UIDSetInt(g_iUID[id], "play_minutes", g_iPlayMinutes[id]);
    UIDSetInt(g_iUID[id], "ct_minutes", g_iCTMinutes[id]);
    UIDSetInt(g_iUID[id], "ct_kills", g_iCTKills[id]);
    UIDSetInt(g_iUID[id], "rebel_kills", g_iRebelKills[id]);
    UIDSetInt(g_iUID[id], "daily_play_minutes", g_iDailyPlayMinutes[id]);
    UIDSetInt(g_iUID[id], "daily_crates", g_iDailyCrates[id]);
    UIDSetInt(g_iUID[id], "daily_purchases", g_iDailyPurchases[id]);
    UIDSetInt(g_iUID[id], "daily_survives", g_iDailySurvives[id]);
    UIDSetInt(g_iUID[id], "task_claim_mask", g_iTaskClaimMask[id]);
    UIDSetInt(g_iUID[id], "rank", g_iRank[id]);
    UIDSetInt(g_iUID[id], "xp", g_iXP[id]);
    UIDSetInt(g_iUID[id], "profession", g_iProfession[id]);
    UIDSetInt(g_iUID[id], "display_tag_mode", g_iDisplayTagMode[id]);
    UIDSetInt(g_iUID[id], "clan_tag_enabled", g_bClanTagEnabled[id]);
    UIDSetInt(g_iUID[id], "rank_tag_enabled", g_bRankTagEnabled[id]);
    UIDSetInt(g_iUID[id], "hud_mode", g_iHudMode[id]);
    UIDSetInt(g_iUID[id], "donate_media", g_bDonateMediaEnabled[id]);
    UIDSetInt(g_iUID[id], "sound_menu_enabled", g_bSoundMenuEnabled[id]);
    UIDSetInt(g_iUID[id], "knife_sounds_enabled", g_bKnifeSoundsEnabled[id]);
    UIDSetInt(g_iUID[id], "chat_messages_enabled", g_bChatMessagesEnabled[id]);
    UIDSetInt(g_iUID[id], "knife_skins_visible", g_bKnifeSkinsVisible[id]);
    UIDSetInt(g_iUID[id], "player_models_visible", g_bPlayerModelsVisible[id]);
    UIDSetInt(g_iUID[id], "prisoner_players_visible", g_bPrisonerPlayersVisible[id]);
    UIDSetInt(g_iUID[id], "trails_visible", g_bTrailsVisible[id]);
    UIDSetInt(g_iUID[id], "death_effects_visible", g_bDeathEffectsVisible[id]);
    UIDSetInt(g_iUID[id], "sound_round_stamp", g_bSoundSentRound[id] ? g_iJBRoundStamp : 0);

    for(new i; i < COS_ITEM_COUNT; i++)
    {
        new suffix[48];
        formatex(suffix, charsmax(suffix), "cos_%d", i);
        UIDSetInt(g_iUID[id], suffix, g_iCosExpiry[id][i]);
    }

    for(new k; k < COS_KIND_COUNT; k++)
    {
        new suffix[48];
        formatex(suffix, charsmax(suffix), "selected_%d", k);
        UIDSetInt(g_iUID[id], suffix, g_iSelectedCos[id][k]);
    }
}

UIDGetInt(uid, const suffix[], defaultValue)
{
    if(g_iVault == INVALID_HANDLE || uid <= 0)
        return defaultValue;

    new key[96], data[32];
    formatex(key, charsmax(key), "%d>%s", uid, suffix);

    if(!nvault_get(g_iVault, key, data, charsmax(data)))
        return defaultValue;

    return str_to_num(data);
}

UIDSetInt(uid, const suffix[], value)
{
    if(g_iVault == INVALID_HANDLE || uid <= 0)
        return;

    new key[96], data[32];
    formatex(key, charsmax(key), "%d>%s", uid, suffix);
    num_to_str(value, data, charsmax(data));
    nvault_set(g_iVault, key, data);
}

// ============================================================
// SAY / MAIN ENTRY
// ============================================================

public CmdSay(id)
{
    new text[192], cmd[16];
    read_args(text, charsmax(text));
    remove_quotes(text);
    trim(text);
    read_argv(0, cmd, charsmax(cmd));

    if(!text[0])
        return PLUGIN_HANDLED;

    // Quick access to the raffle hub; no dependency on menu page navigation.
    if(equali(text, "/cekilis") || equali(text, "/çekiliş"))
    {
        if(!CanUseJBMenu(id, true))
            return PLUGIN_HANDLED;
        if(g_iUID[id] <= 0 || !g_bProfileLoaded[id] || g_bGuestMode[id])
            ShowAccountMenu(id);
        else
            RaffleShowHub(id);
        return PLUGIN_HANDLED;
    }

    if(g_bQuizActive && g_bQuizInfo && g_iQuizQuestion >= 0)
    {
        new normalized[192], correct[128];
        QuizNormalize(text, normalized, charsmax(normalized));
        QuizNormalize(g_szQuizAnswers[g_iQuizQuestion], correct, charsmax(correct));
        if(equal(normalized, correct))
        {
            if(g_iUID[id] <= 0 || !g_bProfileLoaded[id] || g_bGuestMode[id])
            {
                client_print_color(id, print_team_default, "^3[Felicia Quiz] ^1Cevap dogru, ancak Coin kazanmak icin hesaba giris yapmalisin!");
                return PLUGIN_HANDLED;
            }
            g_bQuizActive = false;
            remove_task(QUIZ_END_TASK);
            FC_CoinChange(id, 250);
            SavePlayer(id);
            client_print_color(0, print_team_default, "^3[Felicia Quiz] ^4%n ^1bilgi sorusunu bildi! Cevap: ^4%s", id, g_szQuizAnswers[g_iQuizQuestion]);
            client_print_color(0, print_team_default, "^3[Felicia Quiz] ^1Odul: ^4%d Coin", 250);
            remove_task(QUIZ_START_TASK);
            set_task(float(max(1,get_pcvar_num(g_pQuizInterval))), "QuizStart", QUIZ_START_TASK);
            return PLUGIN_HANDLED;
        }
    }
    if(g_bQuizActive && !g_bQuizInfo && text[0] >= '0' && text[0] <= '9')
    {
        new bool:digits = true;
        for(new i = 0; text[i]; i++)
            if(text[i] < '0' || text[i] > '9') { digits = false; break; }
        if(digits && str_to_num(text) == g_iQuizAnswer && g_iUID[id] > 0 && g_bProfileLoaded[id] && !g_bGuestMode[id])
        {
            g_bQuizActive = false;
            remove_task(QUIZ_END_TASK);
            new reward = g_bQuizTL ? max(0,get_pcvar_num(g_pQuizTLReward)) : max(0,get_pcvar_num(g_pQuizReward));
            if(g_bQuizTL) g_iTL[id] = FC_CountAdd(g_iTL[id], reward);
            else FC_CoinChange(id, reward);
            SavePlayer(id);
            client_print_color(0, print_team_default, "^3[Felicia Quiz] ^4%n ^1dogru cevabi bildi! Cevap: ^4%d ^1Odul: ^4%d %s", id,g_iQuizAnswer,reward,g_bQuizTL ? "TL" : "Coin");
            g_iQuizAnswer = -1;
            remove_task(QUIZ_START_TASK);
            set_task(float(max(1,get_pcvar_num(g_pQuizInterval))), "QuizStart", QUIZ_START_TASK);
            return PLUGIN_HANDLED;
        }
    }
    if(equali(text,"/petgizle"))
    {
        g_bHidePets[id] = !g_bHidePets[id];
        Chat(id, g_bHidePets[id] ? "Pet modelleri sadece senin ekraninda gizlendi. Tekrar /petgizle yazarak acabilirsin." : "Pet modelleri tekrar gorunur oldu.");
        return PLUGIN_HANDLED;
    }
    if(equali(text,"/bonus")) {ShowBonusMenu(id);return PLUGIN_HANDLED;}
    if(equali(text,"/incele") || equali(text,"/skinincele")) {ShowPreviewMenu(id);return PLUGIN_HANDLED;}
    // CT icin hizli TL verme/alma komutlari.
    if(equali(text, "/mg") || equali(text, "/mgver") || equali(text, "/tl") || equali(text, "/tlver"))
    {
        if(get_member(id, m_iTeam) != TEAM_CT)
        {
            Chat(id, "Bu TL verme/alma komutlarini sadece ^4CT takimi ^1kullanabilir.");
            return PLUGIN_HANDLED;
        }

        ShowCTTLMenu(id);
        return PLUGIN_HANDLED;
    }

    if(equali(text, "/jb") || equali(text, "/jbmenu"))
        return CmdJBMenu(id);

    if(equali(text, "/coin") || equali(text, "/bakiye"))
    {
        PrintProfileLine(id);
        return PLUGIN_HANDLED;
    }

    if(equali(text, "/top15time") || equali(text, "/top15sure"))
    {
        if(g_iUID[id] <= 0) ShowAccountMenu(id);
        else ShowTopTimeMotd(id);
        return PLUGIN_HANDLED;
    }

    if(equali(text, "/topgardiyan") || equali(text, "/topct"))
    {
        if(g_iUID[id] <= 0) ShowAccountMenu(id);
        else ShowTopGuardsMotd(id);
        return PLUGIN_HANDLED;
    }

    if(equali(text, "/topisyan") || equali(text, "/topisyanci"))
    {
        if(g_iUID[id] <= 0) ShowAccountMenu(id);
        else ShowTopRebelsMotd(id);
        return PLUGIN_HANDLED;
    }

    if(equali(text, "/jbhud"))
    {
        EnableJBHud(id);
        return PLUGIN_HANDLED;
    }

    if(equali(text, "/hud"))
    {
        CycleHudMode(id);
        return PLUGIN_HANDLED;
    }

    if(equali(text, "/chattemizle") || equali(text, "/clearchat"))
    {
        if(HasRole(id, ROLE_MANAGER) || g_bPanelAuth[id])
            ClearServerChat(id);
        else
            Chat(id, "Bu komut sadece ^4Yonetici ^1hesaplar icindir.");
        return PLUGIN_HANDLED;
    }

    if(equali(text, "/yonetici") || equali(text, "/adminmenu"))
    {
        RequestPanel(id);
        return PLUGIN_HANDLED;
    }

    if(equali(text, "/coinver", 8))
    {
        HandleCoinTransfer(id, text);
        return PLUGIN_HANDLED;
    }

    if(equali(text, "/meslek"))
    {
        if(CanUseJBMenu(id, true))
            ShowProfessionMenu(id);
        return PLUGIN_HANDLED;
    }

    if(equali(text, "/rank"))
    {
        if(!CanUseJBMenu(id, true))
            return PLUGIN_HANDLED;

        if(g_iUID[id] > 0) ShowRankMenu(id);
        else Chat(id, "Rank sistemi icin hesaba giris yapmalisin.");
        return PLUGIN_HANDLED;
    }

    if(equali(text, "/gorev") || equali(text, "/gorevler"))
    {
        if(!CanUseJBMenu(id, true))
            return PLUGIN_HANDLED;

        if(g_iUID[id] > 0) ShowRewardMenu(id);
        else Chat(id, "Gorev sistemi icin hesaba giris yapmalisin.");
        return PLUGIN_HANDLED;
    }

    if(equali(text, "/kasa"))
    {
        if(!CanUseJBMenu(id, true))
            return PLUGIN_HANDLED;

        if(g_iUID[id] > 0) ShowCrateMenu(id);
        else Chat(id, "Kasa sistemi icin hesaba giris yapmalisin.");
        return PLUGIN_HANDLED;
    }

    // /, !, . ve @ ile baslayan komutlari diger pluginlere birak.
    if(text[0] == '/' || text[0] == '!' || text[0] == '.' || text[0] == '@')
        return PLUGIN_CONTINUE;

    new bool:isTeamChat = equali(cmd, "say_team") ? true : false;
    HandleCustomChat(id, text, isTeamChat);
    return PLUGIN_HANDLED;
}

public CmdJBMenu(id)
{
    if(is_user_connected(id) && get_member(id, m_iTeam) == TEAM_CT)
    {
        if(LibraryExists("fc_ctmenu",LibType_Library)) fc_ctmenu_open(id);
        else hogwarts_menu(id);
        return PLUGIN_HANDLED;
    }
    if(!CanUseJBMenu(id, true))
        return PLUGIN_HANDLED;

    if(g_iUID[id] <= 0 && !g_bGuestMode[id])
    {
        ShowAccountMenu(id);
        return PLUGIN_HANDLED;
    }

    if(g_iUID[id] > 0)
        CleanupExpired(id);

    ShowMainMenu(id);
    return PLUGIN_HANDLED;
}

ShowAccountMenu(id)
{
    new menu = FC_MenuCreate("\wHesap Sistemi", "H_Account");
    NoCTAddCellItem(id,menu);
    FC_MenuAddItem(menu, "\wGiris Yap", "1");
    FC_MenuAddItem(menu, "\wKayit Ol", "2");
    FC_MenuAddItem(menu, "\wOtomatik Hesap Olustur", "3");
    FC_MenuAddItem(menu, "\yGiris Yapmadan Devam Et", "4");
    FC_MenuSetProp(menu, MPROP_EXITNAME, "Kapat");
    NoCTTrackMenu(id,menu,2);menu_display(id, menu);
}

public H_Account(id, menu, item)
{
    NoCTReleaseMenu(id,menu);
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }

    new info[8], name[64], access, cb;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), cb);
    new key = str_to_num(info);
    menu_destroy(menu);

    switch(key)
    {
        case NOCT_CELL_ACTION: {NoCTOpenCells(id);ShowAccountMenu(id);}
        case 1: nForwardLogin(id);
        case 2: nForwardRegister(id);
        case 3:
        {
            new user[22], pass[22];
            formatex(user, charsmax(user), "fc_%d", get_systime());
            formatex(pass, charsmax(pass), "fc_%d", random_num(10000,99999));
            nCreateAccount(id, user, pass);
        }
        case 4:
        {
            // Misafir modunda UID/Coin/uyelik/kozmetik sistemi kapali kalir.
            // TL yalnizca mevcut sunucu oturumunda tutulur.
            g_bGuestMode[id] = true;
            g_iUID[id] = 0;
            g_iTL[id] = 0;
            g_iCoin[id] = 0;
            Chat(id, "Misafir moduna gectin. Coin, Prime ve IsyanTeam ozellikleri gizlendi.");

            if(is_user_alive(id) && get_member(id, m_iTeam) == TEAM_TERRORIST)
                ShowMainMarket(id);
            else
                ShowMainMenu(id);
        }
    }

    return PLUGIN_HANDLED;
}

ShowMainMenu(id)
{
    if(!CanUseJBMenu(id, true))
        return;

    if(g_bGuestMode[id] && g_iUID[id] <= 0)
    {
        new guestTitle[256];
        formatex(guestTitle, charsmax(guestTitle),
            "\wJailBreak^n\dDurum: \wMisafir \d| \y%d TL^n\dCoin / Rank / Gorev icin hesap girisi gerekir",
            g_iTL[id]);

        new guestMenu = FC_MenuCreate(guestTitle, "H_Main");
        NoCTAddCellItem(id,guestMenu);
        new cbGuestMainMarket = menu_makecallback("CB_MainMarket");
        new guestMarketLabel[64];
        if(g_bSpecialKnifeBought[id] && g_bMainAdUsed[id])
            copy(guestMarketLabel, charsmax(guestMarketLabel), "\dAna Market \d[\rKullanıldı\d]");
        else if(g_bSpecialKnifeBought[id])
            copy(guestMarketLabel, charsmax(guestMarketLabel), "\wAna Market \d[\yExtra\d]");
        else
            copy(guestMarketLabel, charsmax(guestMarketLabel), "\wAna Market");
        FC_MenuAddItemCB(guestMenu, guestMarketLabel, "1", cbGuestMainMarket);
        FC_MenuAddItem(guestMenu, "\wMarketler", "2");
        FC_MenuAddItem(guestMenu, "\wExtra Özellikler", "21");
        FC_MenuAddItem(guestMenu, "\wMeslek Sistemi", "5");
        FC_MenuAddItem(guestMenu, "\wFPS Seçenekleri", "20");
        FC_MenuAddItem(guestMenu, "\yHesap Sistemine Don", "15");
        FC_MenuSetProp(guestMenu, MPROP_EXITNAME, "Kapat");
        NoCTTrackMenu(id,guestMenu,1);menu_display(id, guestMenu);
        return;
    }

    new role[24], rank[48], title[320];
    GetRoleName(id, role, charsmax(role));
    GetRankName(g_iRank[id], rank, charsmax(rank));

    formatex(title, charsmax(title),
        "\wJailBreak^n\dUID: \w%d \d| \y%d TL \d| \r%d Coin^n\dRank: \w%s \d| Uyelik: \w%s",
        g_iUID[id], g_iTL[id], g_iCoin[id], rank, role);

    new menu = FC_MenuCreate(title, "H_Main");
    NoCTAddCellItem(id,menu);

    new cbMainMarket = menu_makecallback("CB_MainMarket");
    new mainMarketLabel[64];
    if(g_bSpecialKnifeBought[id] && g_bMainAdUsed[id])
        copy(mainMarketLabel, charsmax(mainMarketLabel), "\dAna Market \d[\rKullanıldı\d]");
    else if(g_bSpecialKnifeBought[id])
        copy(mainMarketLabel, charsmax(mainMarketLabel), "\wAna Market \d[\yExtra\d]");
    else
        copy(mainMarketLabel, charsmax(mainMarketLabel), "\wAna Market");
    FC_MenuAddItemCB(menu, mainMarketLabel, "1", cbMainMarket);
    FC_MenuAddItem(menu, "\wMarketler", "2");
    FC_MenuAddItem(menu, "\wExtra Özellikler", "21");
    FC_MenuAddItem(menu, "\wMeslek Sistemi", "5");
    FC_MenuAddItem(menu, "\wOdul & Gorev Merkezi", "6");
    FC_MenuAddItem(menu, "\wKasa Sistemi", "7");

    if(HasRole(id, ROLE_ISYANTEAM))
        FC_MenuAddItem(menu, "\wIsyanTeam Menusu", "8");
    else
        FC_MenuAddItem(menu, "\dIsyanTeam Menusu", "8");

    FC_MenuAddItem(menu, "\wKozmetik Menusu", "9");
    FC_MenuAddItem(menu, "\wBilgiler Menusu", "13");
    FC_MenuAddItem(menu, "\wBonus Menü", "16");
    FC_MenuAddItem(menu, "\wKlan Sistemi", "17");
    FC_MenuAddItem(menu, "\wÇekiliş Merkezi", "19");
    FC_MenuAddItem(menu, "\wFPS Seçenekleri", "20");

    if(HasRole(id, ROLE_MANAGER))
        FC_MenuAddItem(menu, "\wYonetici Menusu", "14");
    else
        FC_MenuAddItem(menu, "\dYonetici Menusu", "14");

    FC_MenuSetProp(menu, MPROP_BACKNAME, "Onceki Sayfa");
    FC_MenuSetProp(menu, MPROP_NEXTNAME, "Sonraki Sayfa");
    FC_MenuSetProp(menu, MPROP_EXITNAME, "Kapat");
    NoCTTrackMenu(id,menu,1);
    menu_display(id, menu);
}

public CB_MainMarket(id, menu, item)
{
    return (g_bSpecialKnifeBought[id] && g_bMainAdUsed[id]) ? ITEM_DISABLED : ITEM_ENABLED;
}

public H_Main(id, menu, item)
{
    NoCTReleaseMenu(id,menu);
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }

    if(!CanUseJBMenu(id, true))
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }

    new info[8], name[64], access, cb;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), cb);
    new key = str_to_num(info);
    menu_destroy(menu);

    switch(key)
    {
        case 1: ShowMainMarket(id);
        case 2: ShowStandardMarkets(id);
        case 3: ShowAttackMenu(id);
        case 4: ShowAmmoMenu(id);
        case 5: ShowProfessionMenu(id);
        case 6:
        {
            if(g_iUID[id] <= 0) ShowAccountMenu(id);
            else ShowRewardMenu(id);
        }
        case 7:
        {
            if(g_iUID[id] <= 0) ShowAccountMenu(id);
            else ShowCrateMenu(id);
        }
        case 8:
        {
            if(g_iUID[id] <= 0) { ShowAccountMenu(id); return PLUGIN_HANDLED; }
            if(HasRole(id, ROLE_ISYANTEAM)) ShowIsyanTeamMenu(id);
            else Chat(id, "Bu menu sadece ^4IsyanTeam ^1uyelerine ozeldir.");
        }
        case 9:
        {
            if(g_iUID[id] <= 0) ShowAccountMenu(id);
            else ShowCosmeticHub(id);
        }
        case 10:
        {
            if(g_iUID[id] <= 0) ShowAccountMenu(id);
            else ShowCoinMarket(id);
        }
        case 11:
        {
            if(g_iUID[id] <= 0) ShowAccountMenu(id);
            else ShowInventoryMenu(id);
        }
        case 13:
        {
            if(g_iUID[id] <= 0) ShowAccountMenu(id);
            else ShowInfoMenu(id);
        }
        case 14:
        {
            if(g_iUID[id] <= 0) ShowAccountMenu(id);
            else RequestPanel(id);
        }
        case 15: ShowAccountMenu(id);
        case 16: ShowBonusMenu(id);
        case 17: OpenClanMenuFromJB(id);
        case 19:
        {
            if(g_iUID[id] <= 0 || !g_bProfileLoaded[id] || g_bGuestMode[id])
                ShowAccountMenu(id);
            else
                RaffleShowHub(id);
        }
        case 20: ShowFPSOptionsMenu(id);
        case 21: ShowExtraFeaturesMenu(id);
        case NOCT_CELL_ACTION: {NoCTOpenCells(id);ShowMainMenu(id);}
    }

    return PLUGIN_HANDLED;
}



// ============================================================
// DONATE SISTEMI - JBMenu icinde, harici plugin gerektirmez.
// TL/Coin bakiyesinden dusurur; aliciya bakiye aktarimi yapmaz.
// ============================================================

DonateCurrencyName(currency, output[], outputLen)
{
    copy(output, outputLen, currency == DONATE_CURRENCY_COIN ? "Coin" : "TL");
}

DonateLoadHistoryCounter()
{
    if(g_iVault == INVALID_HANDLE) return;
    new value[32];
    g_iDonateHistorySerial = nvault_get(g_iVault, "DONATE_HISTORY_COUNT", value, charsmax(value))
        ? max(0, str_to_num(value)) : 0;
}

DonatePrecacheMedia()
{
    new key[64], path[192], spriteName[96], soundName[96], prefix[8];
    new const weaponNames[DONATE_CURRENCY_COUNT][3][32] =
    {
        { "weapon_fcdonate_tl1", "weapon_fcdonate_tl2", "weapon_fcdonate_tl3" },
        { "weapon_fcdonate_coin1", "weapon_fcdonate_coin2", "weapon_fcdonate_coin3" }
    };

    for(new currency = 0; currency < DONATE_CURRENCY_COUNT; currency++)
    {
        copy(prefix, charsmax(prefix), currency == DONATE_CURRENCY_COIN ? "COIN" : "TL");

        formatex(key, charsmax(key), "DONATE_%s_TIER1_MAX", prefix);
        g_iDonateTierFirstMax[currency] = max(0, CfgInt(key, 10));
        formatex(key, charsmax(key), "DONATE_%s_TIER2_MAX", prefix);
        g_iDonateTierSecondMax[currency] = max(g_iDonateTierFirstMax[currency], CfgInt(key, 50));
        formatex(key, charsmax(key), "DONATE_%s_MAX_AMOUNT", prefix);
        g_iDonateMaxAmount[currency] = max(0, CfgInt(key, 0));

        for(new tier = 0; tier < 3; tier++)
        {
            copy(g_szDonateWeaponName[currency][tier], charsmax(g_szDonateWeaponName[][]), weaponNames[currency][tier]);

            formatex(key, charsmax(key), "DONATE_%s_TIER%d_SPRITE", prefix, tier + 1);
            CfgStr(key, spriteName, charsmax(spriteName), "FeliciaClan/donate_money");
            copy(g_szDonateSpriteName[currency][tier], charsmax(g_szDonateSpriteName[][]), spriteName);

            formatex(path, charsmax(path), "sprites/%s.spr", spriteName);
            if(file_exists(path))
            {
                if(DonateWriteWeaponDefinition(g_szDonateWeaponName[currency][tier], spriteName))
                {
                    precache_generic(path);
                    g_bDonateSpriteReady[currency][tier] = true;
                }
            }

            formatex(key, charsmax(key), "DONATE_%s_TIER%d_SOUND", prefix, tier + 1);
            CfgStr(key, soundName, charsmax(soundName), "FeliciaClan/donate_money.wav");
            copy(g_szDonateSoundName[currency][tier], charsmax(g_szDonateSoundName[][]), soundName);

            formatex(path, charsmax(path), "sound/%s", soundName);
            if(soundName[0] && file_exists(path))
            {
                precache_sound(soundName);
                g_bDonateSoundReady[currency][tier] = true;
            }
        }
    }
}

// GoldSrc weapon HUD definition: the sprite is drawn by the client's
// crosshair renderer at a fixed upper-right screen offset. Weapon ID 2 is
// unused by Counter-Strike and is only sent to the client during the notice.
bool:DonateWriteWeaponDefinition(const weaponName[], const spriteName[])
{
    new path[128];
    formatex(path, charsmax(path), "sprites/%s.txt", weaponName);

    new file = fopen(path, "wt");
    if(!file) return false;

    fputs(file, "2^n");
    fprintf(file, "crosshair 320 %s 90 -60 128 80^n", spriteName);
    fprintf(file, "crosshair 640 %s 230 -120 128 80^n", spriteName);
    fclose(file);

    precache_generic(path);
    return true;
}

DonateGetTier(currency, amount)
{
    if(amount <= g_iDonateTierFirstMax[currency]) return 0;
    if(amount <= g_iDonateTierSecondMax[currency]) return 1;
    return 2;
}

DonateGetFov(id)
{
    new Float:fov;
    pev(id, pev_fov, fov);
    if(fov < 1.0) return 90;
    return clamp(floatround(fov), 1, 180);
}

DonateSendFov(id, fov)
{
    if(!g_iDonateMsgSetFov) return;
    message_begin(MSG_ONE, g_iDonateMsgSetFov, _, id);
    write_byte(fov);
    message_end();
}

DonateSendSprite(id)
{
    if(id < 1 || id > MaxClients || !is_user_connected(id)
        || !g_bDonateSpriteActive[id] || !g_bDonateMediaEnabled[id]) return;

    new currency = g_iDonateSpriteCurrency[id];
    new tier = g_iDonateSpriteTier[id];
    if(currency < 0 || currency >= DONATE_CURRENCY_COUNT || tier < 0 || tier > 2
        || !g_bDonateSpriteReady[currency][tier] || !is_user_alive(id)) return;

    new fov = DonateGetFov(id);
    // Do not override a live sniper/AUG/SG552 scope. The SetFOV hook
    // will redraw the sprite when the player returns to normal FOV.
    if(fov < 90) return;

    g_bDonateSpriteSending[id] = true;

    message_begin(MSG_ONE, g_iDonateMsgWeaponList, _, id);
    write_string(g_szDonateWeaponName[currency][tier]);
    write_byte(-1);
    write_byte(0);
    write_byte(-1);
    write_byte(0);
    write_byte(0);
    write_byte(11);
    write_byte(2);
    write_byte(0);
    message_end();

    DonateSendFov(id, 89);

    message_begin(MSG_ONE, g_iDonateMsgCurWeapon, _, id);
    write_byte(1);
    write_byte(2);
    write_byte(0);
    message_end();

    DonateSendFov(id, fov);
    g_bDonateSpriteSending[id] = false;
}

DonateRestoreWeaponHud(id)
{
    if(id < 1 || id > MaxClients || !is_user_connected(id)) return;

    new clip, backpack, weapon = get_user_weapon(id, clip, backpack);
    new fov = DonateGetFov(id);

    g_bDonateSpriteSending[id] = true;
    if(weapon > 0 && g_iDonateMsgCurWeapon)
    {
        message_begin(MSG_ONE, g_iDonateMsgCurWeapon, _, id);
        write_byte(1);
        write_byte(weapon);
        write_byte(clip);
        message_end();
    }
    DonateSendFov(id, fov);
    g_bDonateSpriteSending[id] = false;
}

DonateClearSprite(id)
{
    if(id < 1 || id > MaxClients) return;
    remove_task(id + TASK_DONATE_SPRITE);
    remove_task(id + TASK_DONATE_REFRESH);

    new bool:wasActive = g_bDonateSpriteActive[id];
    g_bDonateSpriteActive[id] = false;
    if(wasActive) DonateRestoreWeaponHud(id);
}

DonateShowSprite(id, currency, tier)
{
    if(id < 1 || id > MaxClients || !is_user_connected(id)
        || !g_bDonateMediaEnabled[id]) return;
    if(!g_bDonateSpriteReady[currency][tier]) return;

    g_iDonateSpriteCurrency[id] = currency;
    g_iDonateSpriteTier[id] = tier;
    g_bDonateSpriteActive[id] = true;

    remove_task(id + TASK_DONATE_SPRITE);
    remove_task(id + TASK_DONATE_REFRESH);
    DonateSendSprite(id);
    set_task(4.0, "TaskDonateClearSprite", id + TASK_DONATE_SPRITE);
}

public TaskDonateClearSprite(taskid)
{
    new id = taskid - TASK_DONATE_SPRITE;
    if(id < 1 || id > MaxClients) return;
    DonateClearSprite(id);
}

public TaskDonateRefreshSprite(taskid)
{
    new id = taskid - TASK_DONATE_REFRESH;
    if(id < 1 || id > MaxClients || !g_bDonateSpriteActive[id]) return;
    DonateSendSprite(id);
}

public EventDonateCurWeapon(id)
{
    if(id < 1 || id > MaxClients || !g_bDonateSpriteActive[id]
        || g_bDonateSpriteSending[id] || !g_bDonateMediaEnabled[id]) return;
    if(read_data(2) == 2) return;
    DonateSendSprite(id);
}

public EventDonateSetFOV(id)
{
    if(id < 1 || id > MaxClients || !g_bDonateSpriteActive[id]
        || g_bDonateSpriteSending[id] || !g_bDonateMediaEnabled[id]) return;

    if(read_data(1) >= 90)
    {
        remove_task(id + TASK_DONATE_REFRESH);
        set_task(0.05, "TaskDonateRefreshSprite", id + TASK_DONATE_REFRESH);
    }
}

DonateHistorySave(id, amount, currency, const donorName[], const message[])
{
    if(g_iVault == INVALID_HANDLE) return;

    g_iDonateHistorySerial++;
    new slot = (g_iDonateHistorySerial - 1) % DONATE_HISTORY_LIMIT;
    new key[96], value[192];

    formatex(key, charsmax(key), "DONATE_%d_NAME", slot);
    nvault_set(g_iVault, key, donorName);

    formatex(key, charsmax(key), "DONATE_%d_UID", slot);
    num_to_str(g_iUID[id], value, charsmax(value));
    nvault_set(g_iVault, key, value);

    formatex(key, charsmax(key), "DONATE_%d_MESSAGE", slot);
    nvault_set(g_iVault, key, message);

    formatex(key, charsmax(key), "DONATE_%d_AMOUNT", slot);
    num_to_str(amount, value, charsmax(value));
    nvault_set(g_iVault, key, value);

    formatex(key, charsmax(key), "DONATE_%d_CURRENCY", slot);
    num_to_str(currency, value, charsmax(value));
    nvault_set(g_iVault, key, value);

    formatex(key, charsmax(key), "DONATE_%d_TIME", slot);
    num_to_str(get_systime(), value, charsmax(value));
    nvault_set(g_iVault, key, value);

    num_to_str(g_iDonateHistorySerial, value, charsmax(value));
    nvault_set(g_iVault, "DONATE_HISTORY_COUNT", value);
}

DonateHistoryRead(serial, const field[], output[], outputLen)
{
    output[0] = 0;
    if(g_iVault == INVALID_HANDLE || serial < 1 || serial > g_iDonateHistorySerial) return;

    new slot = (serial - 1) % DONATE_HISTORY_LIMIT;
    new key[96];
    formatex(key, charsmax(key), "DONATE_%d_%s", slot, field);
    nvault_get(g_iVault, key, output, outputLen);
}

ShowDonateMainMenu(id)
{
    if(!CanUseJBMenu(id, true)) return;

    new menu = FC_MenuCreate("\wDonate Sistemi", "H_DonateMain");
    if(get_member(id, m_iTeam) == TEAM_TERRORIST)
        FC_MenuAddItem(menu, "\wBağış Gönder", "1");
    if(HasRole(id, ROLE_MANAGER))
        FC_MenuAddItem(menu, "\wGeçmiş Bağışlar", "2");

    if(get_member(id, m_iTeam) != TEAM_TERRORIST && !HasRole(id, ROLE_MANAGER))
        FC_MenuAddItem(menu, "\dBağış göndermek için Mahkûm olmalısın", "0");

    FC_MenuSetProp(menu, MPROP_EXITNAME, "Geri");
    menu_display(id, menu);
}

public H_DonateMain(id, menu, item)
{
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        ShowExtraFeaturesMenu(id);
        return PLUGIN_HANDLED;
    }

    new info[8], name[64], access, callback;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), callback);
    new key = str_to_num(info);
    menu_destroy(menu);

    if(key == 1)
    {
        if(get_member(id, m_iTeam) != TEAM_TERRORIST)
        {
            Chat(id, "Bağış göndermek için Mahkûm takımında olmalısın.");
            ShowDonateMainMenu(id);
            return PLUGIN_HANDLED;
        }
        if(g_iUID[id] <= 0 || !g_bProfileLoaded[id] || g_bGuestMode[id])
        {
            Chat(id, "Bağış göndermek için hesabına giriş yapmalısın.");
            ShowAccountMenu(id);
            return PLUGIN_HANDLED;
        }
        if(g_bDonateUsedRound[id])
        {
            Chat(id, "Bu rauntta zaten bağış gönderdin. Yeni rauntta tekrar gönderebilirsin.");
            ShowDonateMainMenu(id);
            return PLUGIN_HANDLED;
        }
        ShowDonateCurrencyMenu(id);
    }
    else if(key == 2)
    {
        if(HasRole(id, ROLE_MANAGER)) ShowDonateHistoryMenu(id);
        else ShowDonateMainMenu(id);
    }

    return PLUGIN_HANDLED;
}

ShowDonateCurrencyMenu(id)
{
    if(!CanUseJBMenu(id, true) || get_member(id, m_iTeam) != TEAM_TERRORIST) return;
    if(g_bDonateUsedRound[id])
    {
        Chat(id, "Bu rauntta zaten bağış gönderdin.");
        ShowDonateMainMenu(id);
        return;
    }

    new menu = FC_MenuCreate("\wBağış Para Birimi", "H_DonateCurrency");
    new line[96];
    formatex(line, charsmax(line), "\wTL \y[ %d TL ]", g_iTL[id]);
    FC_MenuAddItem(menu, line, "1");
    formatex(line, charsmax(line), "\wCoin \y[ %d Coin ]", g_iCoin[id]);
    FC_MenuAddItem(menu, line, "2");
    FC_MenuSetProp(menu, MPROP_EXITNAME, "Geri");
    menu_display(id, menu);
}

public H_DonateCurrency(id, menu, item)
{
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        ShowDonateMainMenu(id);
        return PLUGIN_HANDLED;
    }

    new info[8], name[64], access, callback;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), callback);
    new key = str_to_num(info);
    menu_destroy(menu);

    if(get_member(id, m_iTeam) != TEAM_TERRORIST || g_bDonateUsedRound[id])
    {
        ShowDonateMainMenu(id);
        return PLUGIN_HANDLED;
    }

    g_iDonateCurrency[id] = key == 2 ? DONATE_CURRENCY_COIN : DONATE_CURRENCY_TL;
    g_iDonateAmount[id] = 0;
    g_szDonateMessage[id][0] = 0;
    Chat(id, "Bağış miktarını rakamla yaz.");
    client_cmd(id, "messagemode FC_DonateAmount");
    return PLUGIN_HANDLED;
}

public CmdDonateAmount(id)
{
    if(!is_user_connected(id)) return PLUGIN_HANDLED;
    if(get_member(id, m_iTeam) != TEAM_TERRORIST || g_bDonateUsedRound[id])
    {
        ShowDonateMainMenu(id);
        return PLUGIN_HANDLED;
    }

    new input[32];
    read_args(input, charsmax(input));
    remove_quotes(input);
    trim(input);

    if(!input[0])
    {
        Chat(id, "Miktarı Belirleyin.");
        client_cmd(id, "messagemode FC_DonateAmount");
        return PLUGIN_HANDLED;
    }

    for(new i; input[i]; i++)
    {
        if(input[i] < '0' || input[i] > '9')
        {
            Chat(id, "Miktarı Belirleyin. Sadece rakam kullan.");
            client_cmd(id, "messagemode FC_DonateAmount");
            return PLUGIN_HANDLED;
        }
    }

    new amount = str_to_num(input);
    if(amount <= 0)
    {
        Chat(id, "Miktarı Belirleyin.");
        client_cmd(id, "messagemode FC_DonateAmount");
        return PLUGIN_HANDLED;
    }

    new currency = g_iDonateCurrency[id];
    if(currency < 0 || currency >= DONATE_CURRENCY_COUNT) currency = DONATE_CURRENCY_TL;

    if(g_iDonateMaxAmount[currency] > 0 && amount > g_iDonateMaxAmount[currency])
    {
        Chat(id, "Bu para biriminde tek bağış üst sınırı: %d.", g_iDonateMaxAmount[currency]);
        client_cmd(id, "messagemode FC_DonateAmount");
        return PLUGIN_HANDLED;
    }

    new balance = currency == DONATE_CURRENCY_COIN ? g_iCoin[id] : g_iTL[id];
    if(amount > balance)
    {
        Chat(id, "Yeterli %s yok. Bakiyen: %d.", currency == DONATE_CURRENCY_COIN ? "Coin" : "TL", balance);
        ShowDonateCurrencyMenu(id);
        return PLUGIN_HANDLED;
    }

    g_iDonateAmount[id] = amount;
    Chat(id, "Bağış mesajını yaz.");
    client_cmd(id, "messagemode FC_DonateMessage");
    return PLUGIN_HANDLED;
}

public CmdDonateMessage(id)
{
    if(!is_user_connected(id)) return PLUGIN_HANDLED;
    if(get_member(id, m_iTeam) != TEAM_TERRORIST || g_bDonateUsedRound[id])
    {
        ShowDonateMainMenu(id);
        return PLUGIN_HANDLED;
    }

    new message[DONATE_MESSAGE_LEN + 1];
    read_args(message, charsmax(message));
    remove_quotes(message);
    trim(message);
    replace_all(message, charsmax(message), "^n", " ");
    replace_all(message, charsmax(message), "^r", " ");
    trim(message);

    if(!message[0])
    {
        Chat(id, "Mesajı Girin.");
        client_cmd(id, "messagemode FC_DonateMessage");
        return PLUGIN_HANDLED;
    }

    copy(g_szDonateMessage[id], charsmax(g_szDonateMessage[]), message);
    ShowDonateConfirmMenu(id);
    return PLUGIN_HANDLED;
}

ShowDonateConfirmMenu(id)
{
    if(!CanUseJBMenu(id, true)) return;
    if(g_iDonateAmount[id] <= 0 || !g_szDonateMessage[id][0])
    {
        Chat(id, g_iDonateAmount[id] <= 0 ? "Miktarı Belirleyin." : "Mesajı Girin.");
        ShowDonateCurrencyMenu(id);
        return;
    }

    new currencyName[12], title[256];
    DonateCurrencyName(g_iDonateCurrency[id], currencyName, charsmax(currencyName));

    // Bagis tutari ve mesaj secenek olarak degil,
    // onay menusunun ust bilgilendirme alaninda gosterilir.
    formatex(title, charsmax(title),
        "\wBağışı Onayla^n^n\rBağış Miktarı: \r%d %s^n\rMesajın: \r%s",
        g_iDonateAmount[id], currencyName, g_szDonateMessage[id]);

    new menu = FC_MenuCreate(title, "H_DonateConfirm");
    FC_MenuAddItem(menu, "\wOnayla", "1");
    FC_MenuAddItem(menu, "\wVazgeç", "2");
    FC_MenuSetProp(menu, MPROP_EXITNAME, "Geri");
    menu_display(id, menu);
}

public H_DonateConfirm(id, menu, item)
{
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        ShowDonateMainMenu(id);
        return PLUGIN_HANDLED;
    }

    new info[8], name[64], access, callback;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), callback);
    new key = str_to_num(info);
    menu_destroy(menu);

    if(key == 1) DonateCommit(id);
    else ShowDonateMainMenu(id);
    return PLUGIN_HANDLED;
}

DonateCommit(id)
{
    if(!is_user_connected(id) || !CanUseJBMenu(id, true)) return;
    if(get_member(id, m_iTeam) != TEAM_TERRORIST)
    {
        Chat(id, "Bağış göndermek için Mahkûm olmalısın.");
        return;
    }
    if(g_bDonateUsedRound[id])
    {
        Chat(id, "Bu rauntta zaten bağış gönderdin.");
        return;
    }
    if(g_iUID[id] <= 0 || !g_bProfileLoaded[id] || g_bGuestMode[id])
    {
        ShowAccountMenu(id);
        return;
    }

    new currency = g_iDonateCurrency[id];
    new amount = g_iDonateAmount[id];
    if(currency < 0 || currency >= DONATE_CURRENCY_COUNT || amount <= 0)
    {
        Chat(id, "Miktarı Belirleyin.");
        ShowDonateCurrencyMenu(id);
        return;
    }
    if(!g_szDonateMessage[id][0])
    {
        Chat(id, "Mesajı Girin.");
        client_cmd(id, "messagemode FC_DonateMessage");
        return;
    }
    if(g_iDonateMaxAmount[currency] > 0 && amount > g_iDonateMaxAmount[currency])
    {
        Chat(id, "Bağış miktarı üst sınırı aşıyor.");
        ShowDonateCurrencyMenu(id);
        return;
    }

    if(currency == DONATE_CURRENCY_TL)
    {
        if(g_iTL[id] < amount)
        {
            Chat(id, "Yeterli TL yok.");
            ShowDonateCurrencyMenu(id);
            return;
        }
        g_iTL[id] -= amount;
        FC_RecordTLSpend(id, amount);
    }
    else
    {
        if(g_iCoin[id] < amount)
        {
            Chat(id, "Yeterli Coin yok.");
            ShowDonateCurrencyMenu(id);
            return;
        }
        FC_CoinChange(id, -amount);
    }

    g_bDonateUsedRound[id] = true;
    UIDSetInt(g_iUID[id], "donate_round_stamp", g_iJBRoundStamp);
    SavePlayer(id);

    new donorName[32], currencyName[12];
    get_user_name(id, donorName, charsmax(donorName));
    DonateCurrencyName(currency, currencyName, charsmax(currencyName));
    DonateHistorySave(id, amount, currency, donorName, g_szDonateMessage[id]);

    client_print_color(0, print_team_default,
        "^3[FeliciaClan] ^4%s ^1bağış yaptı: ^3%d %s ^1- ^4%s",
        donorName, amount, currencyName, g_szDonateMessage[id]);

    new tier = DonateGetTier(currency, amount);
    DonateBroadcastMedia(donorName, g_szDonateMessage[id], amount, currency, tier);

    g_iDonateAmount[id] = 0;
    g_szDonateMessage[id][0] = 0;
    ShowDonateMainMenu(id);
}

DonateBroadcastMedia(const donorName[], const message[], amount, currency, tier)
{
    new currencyName[12], text[192], amountText[64];
    DonateCurrencyName(currency, currencyName, charsmax(currencyName));
    formatex(text, charsmax(text), "%s^n%s", donorName, message);
    formatex(amountText, charsmax(amountText), "%d %s Bağışlandı", amount, currencyName);

    for(new target = 1; target <= MaxClients; target++)
    {
        if(!is_user_connected(target)) continue;

        // Donor/message sit above the sprite; the amount/currency line sits below it.
        // The personal media preference controls only SPR and WAV independently.
        set_hudmessage(255, 255, 255, 0.73, 0.025, 0, 0.0, 4.0, 0.05, 0.1, -1);
        ShowSyncHudMsg(target, g_iDonateHudSync, "%s", text);
        set_hudmessage(255, 220, 80, 0.76, 0.42, 0, 0.0, 4.0, 0.05, 0.1, -1);
        ShowSyncHudMsg(target, g_iDonateAmountHudSync, "%s", amountText);

        if(!g_bDonateMediaEnabled[target]) continue;

        DonateShowSprite(target, currency, tier);
        if(g_bDonateSoundReady[currency][tier])
            client_cmd(target, "spk %s", g_szDonateSoundName[currency][tier]);
    }
}

ShowDonateHistoryMenu(id)
{
    if(!CanUseJBMenu(id, true) || !HasRole(id, ROLE_MANAGER))
    {
        Chat(id, "Bağış geçmişini yalnızca yönetici üyeliği görüntüleyebilir.");
        return;
    }

    new menu = FC_MenuCreate("\wGeçmiş Bağışlar", "H_DonateHistory");
    new count = min(g_iDonateHistorySerial, 20);
    new line[160], info[16], donor[40], amountText[24], currencyText[12], serial;

    if(!count)
        FC_MenuAddItem(menu, "\dHenüz bağış kaydı yok", "0");

    for(new i; i < count; i++)
    {
        serial = g_iDonateHistorySerial - i;
        DonateHistoryRead(serial, "NAME", donor, charsmax(donor));
        DonateHistoryRead(serial, "AMOUNT", amountText, charsmax(amountText));
        DonateHistoryRead(serial, "CURRENCY", currencyText, charsmax(currencyText));
        new currency = clamp(str_to_num(currencyText), 0, DONATE_CURRENCY_COUNT - 1);
        new currencyName[12];
        DonateCurrencyName(currency, currencyName, charsmax(currencyName));
        formatex(line, charsmax(line), "\w%s \y- %s %s", donor, amountText, currencyName);
        num_to_str(serial, info, charsmax(info));
        FC_MenuAddItem(menu, line, info);
    }

    FC_MenuSetProp(menu, MPROP_EXITNAME, "Geri");
    menu_display(id, menu);
}

public H_DonateHistory(id, menu, item)
{
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        ShowDonateMainMenu(id);
        return PLUGIN_HANDLED;
    }

    if(!HasRole(id, ROLE_MANAGER))
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }

    new info[16], name[64], access, callback;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), callback);
    new serial = str_to_num(info);
    menu_destroy(menu);

    if(serial > 0) ShowDonateHistoryDetail(id, serial);
    else ShowDonateHistoryMenu(id);
    return PLUGIN_HANDLED;
}

ShowDonateHistoryDetail(id, serial)
{
    if(!HasRole(id, ROLE_MANAGER)) return;

    new donor[40], message[DONATE_MESSAGE_LEN + 1], amountText[24], currencyText[12], timeText[40];
    DonateHistoryRead(serial, "NAME", donor, charsmax(donor));
    DonateHistoryRead(serial, "MESSAGE", message, charsmax(message));
    DonateHistoryRead(serial, "AMOUNT", amountText, charsmax(amountText));
    DonateHistoryRead(serial, "CURRENCY", currencyText, charsmax(currencyText));
    DonateHistoryRead(serial, "TIME", timeText, charsmax(timeText));

    new currency = clamp(str_to_num(currencyText), 0, DONATE_CURRENCY_COUNT - 1);
    new currencyName[12], date[40], title[512];
    DonateCurrencyName(currency, currencyName, charsmax(currencyName));
    format_time(date, charsmax(date), "%d.%m.%Y %H:%M", str_to_num(timeText));

    formatex(title, charsmax(title),
        "\wBağış Detayı^n^n\yBağışçı: \w%s^n\yMiktar: \w%s %s^n\yTarih: \w%s^n^n\yMesaj: \w%s",
        donor, amountText, currencyName, date, message);

    new menu = FC_MenuCreate(title, "H_DonateHistoryDetail");
    FC_MenuAddItem(menu, "\wBağış Geçmişine Dön", "1");
    FC_MenuSetProp(menu, MPROP_EXITNAME, "Geri");
    menu_display(id, menu);
}

public H_DonateHistoryDetail(id, menu, item)
{
    menu_destroy(menu);
    if(HasRole(id, ROLE_MANAGER)) ShowDonateHistoryMenu(id);
    else ShowDonateMainMenu(id);
}

// ============================================================
// EXTRA OZELLIKLER
// Harici sistem menuleri burada toplanir.
// Yeni secenekler eklenecegi zaman bu submenuye yeni item + handler key eklenir.
// ============================================================

ShowExtraFeaturesMenu(id)
{
    if(!CanUseJBMenu(id, true)) return;

    new menu = FC_MenuCreate("\wExtra Özellikler", "H_ExtraFeatures");
    FC_MenuAddItem(menu, "\wDonate Sistemi", "1");
    if(get_member(id,m_iTeam)==TEAM_TERRORIST)
        FC_MenuAddItem(menu, "\wSes Gönder", "2");
    FC_MenuSetProp(menu, MPROP_EXITNAME, "Geri");
    menu_display(id, menu);
}

public H_ExtraFeatures(id, menu, item)
{
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        ShowMainMenu(id);
        return PLUGIN_HANDLED;
    }

    if(!CanUseJBMenu(id, true))
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }

    new info[8], name[64], access, cb;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), cb);
    new key = str_to_num(info);
    menu_destroy(menu);

    switch(key)
    {
        case 1:
        {
            ShowDonateMainMenu(id);
        }
        case 2:
        {
            ShowSoundMenu(id);
        }
    }

    return PLUGIN_HANDLED;
}

// ============================================================
// FPS SECENEKLERI
// Yeni kisiye ozel istemci/gorsel ayarlari bu submenuye eklenebilir.
// ============================================================

ShowFPSOptionsMenu(id)
{
    if(!CanUseJBMenu(id, true)) return;

    new menu = FC_MenuCreate("\wFPS Seçenekleri", "H_FPSOptions");
    new label[128], hudMode[24];

    if(g_bDonateMediaEnabled[id])
        formatex(label, charsmax(label), "\wBağış Medyası \d[ \yGöster \d]");
    else
        formatex(label, charsmax(label), "\wBağış Medyası \d[ \rGizle \d]");
    FC_MenuAddItem(menu, label, "1");

    if(g_bSoundMenuEnabled[id])
        formatex(label, charsmax(label), "\wSes Menüsü \d[ \yAçık \d]");
    else
        formatex(label, charsmax(label), "\wSes Menüsü \d[ \rKapalı \d]");
    FC_MenuAddItem(menu, label, "2");

    if(g_bKnifeSoundsEnabled[id])
        formatex(label, charsmax(label), "\wBıçak Sesleri \d[ \yAçık \d]");
    else
        formatex(label, charsmax(label), "\wBıçak Sesleri \d[ \rKapalı \d]");
    FC_MenuAddItem(menu, label, "3");

    if(g_bChatMessagesEnabled[id])
        formatex(label, charsmax(label), "\wSohbet Mesajları \d[ \yAçık \d]");
    else
        formatex(label, charsmax(label), "\wSohbet Mesajları \d[ \rKapalı \d]");
    FC_MenuAddItem(menu, label, "4");

    if(g_bHidePets[id])
        formatex(label, charsmax(label), "\wPet Sistemi \d[ \yGöster \d]");
    else
        formatex(label, charsmax(label), "\wPet Sistemi \d[ \yGizle \d]");
    FC_MenuAddItem(menu, label, "5");

    if(g_bKnifeSkinsVisible[id])
        formatex(label, charsmax(label), "\wBıçak Skinleri \d[ \yGöster \d]");
    else
        formatex(label, charsmax(label), "\wBıçak Skinleri \d[ \rGizle \d]");
    FC_MenuAddItem(menu, label, "6");

    if(g_bPlayerModelsVisible[id])
        formatex(label, charsmax(label), "\wOyuncu Modelleri \d[ \yGöster \d]");
    else
        formatex(label, charsmax(label), "\wOyuncu Modelleri \d[ \rGizle \d]");
    FC_MenuAddItem(menu, label, "7");

    if(g_bPrisonerPlayersVisible[id])
        formatex(label, charsmax(label), "\wMahkûm Oyuncuları \d[ \yGöster \d]");
    else
        formatex(label, charsmax(label), "\wMahkûm Oyuncuları \d[ \rGizle \d]");
    FC_MenuAddItem(menu, label, "8");

    if(g_bTrailsVisible[id])
        formatex(label, charsmax(label), "\wTrail Efektleri \d[ \yGöster \d]");
    else
        formatex(label, charsmax(label), "\wTrail Efektleri \d[ \rGizle \d]");
    FC_MenuAddItem(menu, label, "9");

    if(g_bDeathEffectsVisible[id])
        formatex(label, charsmax(label), "\wÖlüm Efektleri \d[ \yGöster \d]");
    else
        formatex(label, charsmax(label), "\wÖlüm Efektleri \d[ \rGizle \d]");
    FC_MenuAddItem(menu, label, "10");

    // HUD secenegi bilerek en alta.
    switch(g_iHudMode[id])
    {
        case HUDMODE_FULL: copy(hudMode, charsmax(hudMode), "Detaylı");
        case HUDMODE_COMPACT: copy(hudMode, charsmax(hudMode), "Kompakt");
        case HUDMODE_OFF: copy(hudMode, charsmax(hudMode), "Kapalı");
        default: copy(hudMode, charsmax(hudMode), "Detaylı");
    }
    formatex(label, charsmax(label), "\wBilgi HUD'u \d[ \y%s \d]", hudMode);
    FC_MenuAddItem(menu, label, "11");

    FC_MenuSetProp(menu, MPROP_EXITNAME, "Geri");
    menu_display(id, menu);
}

public H_FPSOptions(id, menu, item)
{
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        ShowMainMenu(id);
        return PLUGIN_HANDLED;
    }

    if(!CanUseJBMenu(id, true))
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }

    new info[8], name[64], access, cb;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), cb);
    new key = str_to_num(info);
    menu_destroy(menu);

    if(key == 1)
    {
        g_bDonateMediaEnabled[id] = !g_bDonateMediaEnabled[id];
        if(!g_bDonateMediaEnabled[id]) DonateClearSprite(id);
        if(g_iUID[id] > 0 && g_bProfileLoaded[id])
            UIDSetInt(g_iUID[id], "donate_media", g_bDonateMediaEnabled[id]);
        Chat(id, "Bağış medyası artık %s.", g_bDonateMediaEnabled[id] ? "açık" : "kapalı");
    }
    else if(key == 2)
    {
        g_bSoundMenuEnabled[id]=!g_bSoundMenuEnabled[id];
        if(g_iUID[id]>0 && g_bProfileLoaded[id])
            UIDSetInt(g_iUID[id],"sound_menu_enabled",g_bSoundMenuEnabled[id]);
        Chat(id,"Ses Menüsü artık %s.",g_bSoundMenuEnabled[id]?"açık":"kapalı");
    }
    else if(key == 3)
    {
        g_bKnifeSoundsEnabled[id]=!g_bKnifeSoundsEnabled[id];
        if(g_iUID[id]>0 && g_bProfileLoaded[id])
            UIDSetInt(g_iUID[id],"knife_sounds_enabled",g_bKnifeSoundsEnabled[id]);
        Chat(id,"Bıçak sesleri artık %s.",g_bKnifeSoundsEnabled[id]?"açık":"kapalı");
    }
    else if(key == 4)
    {
        g_bChatMessagesEnabled[id]=!g_bChatMessagesEnabled[id];
        if(g_iUID[id]>0 && g_bProfileLoaded[id])
            UIDSetInt(g_iUID[id],"chat_messages_enabled",g_bChatMessagesEnabled[id]);
        client_cmd(id,"hud_saytext %d",g_bChatMessagesEnabled[id] ? 1 : 0);
        if(g_bChatMessagesEnabled[id])
            Chat(id,"Sohbet mesajları açıldı.");
        else
            client_print(id,print_center,"Sohbet mesajları kapatıldı.");
    }
    else if(key == 5)
    {
        g_bHidePets[id]=!g_bHidePets[id];
        Chat(id,g_bHidePets[id] ? "Pet modelleri senin ekranında gizlendi." : "Pet modelleri tekrar gösteriliyor.");
    }
    else if(key == 6)
    {
        g_bKnifeSkinsVisible[id]=!g_bKnifeSkinsVisible[id];
        if(g_iUID[id]>0 && g_bProfileLoaded[id])
            UIDSetInt(g_iUID[id],"knife_skins_visible",g_bKnifeSkinsVisible[id]);
        if(is_user_alive(id) && get_user_weapon(id)==CSW_KNIFE)
            RefreshActiveKnifeModels(id);
        Chat(id,"Bıçak skinleri artık %s.",g_bKnifeSkinsVisible[id]?"görünüyor":"gizli");
    }
    else if(key == 7)
    {
        g_bPlayerModelsVisible[id]=!g_bPlayerModelsVisible[id];
        if(g_iUID[id]>0 && g_bProfileLoaded[id])
            UIDSetInt(g_iUID[id],"player_models_visible",g_bPlayerModelsVisible[id]);
        Chat(id,"Özel oyuncu modelleri artık %s.",g_bPlayerModelsVisible[id]?"görünüyor":"gizli");
    }
    else if(key == 8)
    {
        g_bPrisonerPlayersVisible[id]=!g_bPrisonerPlayersVisible[id];
        if(g_iUID[id]>0 && g_bProfileLoaded[id])
            UIDSetInt(g_iUID[id],"prisoner_players_visible",g_bPrisonerPlayersVisible[id]);
        Chat(id,"Mahkûm oyuncular artık %s.",g_bPrisonerPlayersVisible[id]?"görünüyor":"gizli");
    }
    else if(key == 9)
    {
        g_bTrailsVisible[id]=!g_bTrailsVisible[id];
        if(g_iUID[id]>0 && g_bProfileLoaded[id])
            UIDSetInt(g_iUID[id],"trails_visible",g_bTrailsVisible[id]);
        if(g_bTrailsVisible[id])
            RefreshTrailsForClient(id);
        else
            ClearTrailsForClient(id);
        Chat(id,"Trail efektleri artık %s.",g_bTrailsVisible[id]?"görünüyor":"gizli");
    }
    else if(key == 10)
    {
        g_bDeathEffectsVisible[id]=!g_bDeathEffectsVisible[id];
        if(g_iUID[id]>0 && g_bProfileLoaded[id])
            UIDSetInt(g_iUID[id],"death_effects_visible",g_bDeathEffectsVisible[id]);
        Chat(id,"Ölüm efektleri artık %s.",g_bDeathEffectsVisible[id]?"görünüyor":"gizli");
    }
    else if(key == 11)
    {
        CycleHudMode(id);
    }

    ShowFPSOptionsMenu(id);
    return PLUGIN_HANDLED;
}

// ============================================================
// SES GONDERME - Ses_Menu.ini'den dinamik liste
// Satir formati: "Menu Ismi" "TL Ucreti" "sound/ klasorune gore dosya yolu"
// ============================================================
LoadSoundMenuConfig()
{
    g_aSoundMenuNames=ArrayCreate(64,1);
    g_aSoundMenuPaths=ArrayCreate(128,1);
    g_aSoundMenuPrices=ArrayCreate(1,1);
    g_aSoundMenuReady=ArrayCreate(1,1);

    new file=fopen(SOUND_MENU_INI,"rt");
    if(!file)
    {
        log_amx("[FeliciaClan] Ses_Menu.ini bulunamadi: %s",SOUND_MENU_INI);
        return;
    }

    new line[256],menuName[64],priceText[16],soundPath[128],fullPath[192];
    while(!feof(file))
    {
        line[0]=0;
        fgets(file,line,charsmax(line));
        trim(line);
        if(!line[0] || line[0]==';' || line[0]=='#') continue;
        menuName[0]=priceText[0]=soundPath[0]=0;
        if(parse(line,menuName,charsmax(menuName),priceText,charsmax(priceText),soundPath,charsmax(soundPath))<3)
            continue;
        if(!menuName[0] || !soundPath[0]) continue;

        new price=max(0,str_to_num(priceText));
        formatex(fullPath,charsmax(fullPath),"sound/%s",soundPath);
        new ready=file_exists(fullPath) ? 1 : 0;
        if(ready) precache_sound(soundPath);
        else log_amx("[FeliciaClan] Ses dosyasi bulunamadi: %s",fullPath);

        ArrayPushString(g_aSoundMenuNames,menuName);
        ArrayPushString(g_aSoundMenuPaths,soundPath);
        ArrayPushCell(g_aSoundMenuPrices,price);
        ArrayPushCell(g_aSoundMenuReady,ready);
    }
    fclose(file);
    log_amx("[FeliciaClan] Ses_Menu.ini: %d ses yuklendi.",ArraySize(g_aSoundMenuNames));
}

ShowSoundMenu(id)
{
    if(!CanUseJBMenu(id,true)) return;
    if(!is_user_alive(id) || get_member(id,m_iTeam)!=TEAM_TERRORIST)
    {
        Chat(id,"Ses göndermek için yaşayan mahkûm olmalısın.");
        ShowExtraFeaturesMenu(id);
        return;
    }
    if(g_bSoundSentRound[id])
    {
        Chat(id,"Bu tur ses gönderme hakkını zaten kullandın.");
        ShowExtraFeaturesMenu(id);
        return;
    }

    new menu=FC_MenuCreate("\wSes Gönder","H_SoundMenu");
    new line[160],name[64],info[16],price;
    new count=ArraySize(g_aSoundMenuNames);
    if(!count) FC_MenuAddItem(menu,"\dSes_Menu.ini dosyasına ses eklenmemiş.","-1");

    for(new i=0;i<count;i++)
    {
        ArrayGetString(g_aSoundMenuNames,i,name,charsmax(name));
        price=ArrayGetCell(g_aSoundMenuPrices,i);
        if(ArrayGetCell(g_aSoundMenuReady,i))
            formatex(line,charsmax(line),"\w%s \d[\y%d TL\d]",name,price);
        else
            formatex(line,charsmax(line),"\d%s [Ses dosyası bulunamadı]",name);
        num_to_str(i,info,charsmax(info));
        FC_MenuAddItem(menu,line,info);
    }
    FC_MenuSetProp(menu,MPROP_EXITNAME,"Geri");
    menu_display(id,menu);
}

public H_SoundMenu(id,menu,item)
{
    if(item==MENU_EXIT)
    {
        menu_destroy(menu);
        ShowExtraFeaturesMenu(id);
        return PLUGIN_HANDLED;
    }
    if(!CanUseJBMenu(id,true))
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }
    new info[16],name[64],access,callback;
    menu_item_getinfo(menu,item,access,info,charsmax(info),name,charsmax(name),callback);
    new index=str_to_num(info);
    menu_destroy(menu);

    if(!is_user_alive(id) || get_member(id,m_iTeam)!=TEAM_TERRORIST)
    {
        Chat(id,"Sesleri yalnızca yaşayan mahkûmlar gönderebilir.");
        return PLUGIN_HANDLED;
    }
    if(g_bSoundSentRound[id])
    {
        Chat(id,"Bu tur ses gönderme hakkını zaten kullandın.");
        return PLUGIN_HANDLED;
    }
    if(index<0 || index>=ArraySize(g_aSoundMenuNames))
    {
        ShowExtraFeaturesMenu(id);
        return PLUGIN_HANDLED;
    }
    if(!ArrayGetCell(g_aSoundMenuReady,index))
    {
        Chat(id,"Bu ses dosyası sunucuda bulunamadı.");
        ShowSoundMenu(id);
        return PLUGIN_HANDLED;
    }

    new price=ArrayGetCell(g_aSoundMenuPrices,index);
    if(g_iTL[id]<price)
    {
        Chat(id,"Bu sesi göndermek için %d TL gerekiyor. Bakiyen: %d TL.",price,g_iTL[id]);
        ShowSoundMenu(id);
        return PLUGIN_HANDLED;
    }

    ArrayGetString(g_aSoundMenuNames,index,name,charsmax(name));
    new soundPath[128];
    ArrayGetString(g_aSoundMenuPaths,index,soundPath,charsmax(soundPath));
    if(price>0)
    {
        FC_RecordTLSpend(id,price);
        g_iTL[id]-=price;
    }
    SavePlayer(id);
    g_bSoundSentRound[id]=true;

    for(new target=1;target<=MaxClients;target++)
        if(is_user_connected(target) && g_bSoundMenuEnabled[target])
            client_cmd(target,"spk %s",soundPath);

    g_flSoundSpeakerUntil[id]=get_gametime()+2.5;
    remove_task(TASK_SOUND_SPEAKER+id);
    TaskSoundSpeakerIcon(TASK_SOUND_SPEAKER+id);
    set_task(0.35,"TaskSoundSpeakerIcon",TASK_SOUND_SPEAKER+id,_,_,"b");

    client_print_color(0,id,"^1[^3FeliciaClan^1] ^3%n ^1ses gönderdi: ^4%s",id,name);
    if(price>0) Chat(id,"^4%s ^1sesi için ^3%d TL^1 ödendi. Kalan: ^3%d TL^1.",name,price,g_iTL[id]);
    return PLUGIN_HANDLED;
}

public TaskSoundSpeakerIcon(taskid)
{
    new id=taskid-TASK_SOUND_SPEAKER;
    if(id<1 || id>MaxClients || !is_user_connected(id) || get_gametime()>=g_flSoundSpeakerUntil[id])
    {
        remove_task(taskid);
        return;
    }
    if(g_iSoundSpeakerSprite<=0) return;
    new Float:origin[3];
    get_entvar(id,var_origin,origin);
    origin[2]+=38.0;
    message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
    write_byte(TE_SPRITE);
    write_coord_f(origin[0]);write_coord_f(origin[1]);write_coord_f(origin[2]);
    write_short(g_iSoundSpeakerSprite);
    write_byte(5);write_byte(255);
    message_end();
}

public Fwd_EmitSound_Pre(entity,channel,const sample[],Float:volume,Float:attenuation,flags,pitch)
{
    if(containi(sample,"knife")==-1)
        return FMRES_IGNORED;

    // Bıçak sesi kapalı olan istemcilere ses gönderilmez.
    // Açık olanlara istemci tarafindan caldirilir; bozuk SVC_STOPSOUND paketi kullanilmaz.
    for(new target=1;target<=MaxClients;target++)
    {
        if(!is_user_connected(target) || !g_bKnifeSoundsEnabled[target])
            continue;

        client_cmd(target,"spk ^"%s^"",sample);
    }

    return FMRES_SUPERCEDE;
}

// ============================================================
// CEKILIS SISTEMI - nVault veri katmani
// ============================================================

stock RaffleMakeKey(raffleId, const field[], key[], keyLen)
{
    formatex(key, keyLen, "FC_RAFFLE_%d_%s", raffleId, field);
}
stock RaffleReadInt(raffleId, const field[], defaultValue)
{
    if(g_iVault == INVALID_HANDLE) return defaultValue;
    new key[96], value[32];
    RaffleMakeKey(raffleId, field, key, charsmax(key));
    if(!nvault_get(g_iVault, key, value, charsmax(value))) return defaultValue;
    return str_to_num(value);
}
stock RaffleWriteInt(raffleId, const field[], value)
{
    if(g_iVault == INVALID_HANDLE) return;
    new key[96], data[32];
    RaffleMakeKey(raffleId, field, key, charsmax(key));
    num_to_str(value, data, charsmax(data));
    nvault_set(g_iVault, key, data);
}
stock RaffleReadString(raffleId, const field[], output[], outputLen)
{
    output[0] = 0;
    if(g_iVault == INVALID_HANDLE) return;
    new key[96];
    RaffleMakeKey(raffleId, field, key, charsmax(key));
    nvault_get(g_iVault, key, output, outputLen);
}
stock RaffleWriteString(raffleId, const field[], const value[])
{
    if(g_iVault == INVALID_HANDLE) return;
    new key[96];
    RaffleMakeKey(raffleId, field, key, charsmax(key));
    nvault_set(g_iVault, key, value);
}
stock RaffleSaveOne(raffleId)
{
    if(raffleId < 1 || raffleId > g_iRaffleCount) return;
    new i = raffleId - 1, field[32], data[32];
    RaffleWriteInt(raffleId, "active", g_bRaffleActive[i]);
    RaffleWriteInt(raffleId, "creator_uid", g_iRaffleCreatorUID[i]);
    RaffleWriteString(raffleId, "creator_name", g_szRaffleCreator[i]);
    RaffleWriteString(raffleId, "title", g_szRaffleTitle[i]);
    RaffleWriteInt(raffleId, "reward_type", g_iRaffleRewardType[i]);
    RaffleWriteInt(raffleId, "reward_amount", g_iRaffleRewardAmount[i]);
    RaffleWriteInt(raffleId, "reward_cos", g_iRaffleRewardCosmetic[i]);
    RaffleWriteInt(raffleId, "fee_type", g_iRaffleFeeType[i]);
    RaffleWriteInt(raffleId, "fee_amount", g_iRaffleFeeAmount[i]);
    RaffleWriteInt(raffleId, "end_mode", g_iRaffleEndMode[i]);
    RaffleWriteInt(raffleId, "end_value", g_iRaffleEndValue[i]);
    RaffleWriteInt(raffleId, "created_at", g_iRaffleCreatedAt[i]);
    RaffleWriteInt(raffleId, "ends_at", g_iRaffleEndsAt[i]);
    RaffleWriteInt(raffleId, "finished_at", g_iRaffleFinishedAt[i]);
    RaffleWriteInt(raffleId, "participant_count", g_iRaffleParticipantCount[i]);
    RaffleWriteInt(raffleId, "winner_uid", g_iRaffleWinnerUID[i]);
    RaffleWriteString(raffleId, "winner_name", g_szRaffleWinnerName[i]);
    RaffleWriteInt(raffleId, "reward_delivered", g_bRaffleRewardDelivered[i]);

    for(new p; p < g_iRaffleParticipantCount[i]; p++)
    {
        formatex(field, charsmax(field), "p%d_uid", p);
        num_to_str(g_iRaffleParticipantUID[i][p], data, charsmax(data));
        RaffleWriteString(raffleId, field, data);
        formatex(field, charsmax(field), "p%d_name", p);
        RaffleWriteString(raffleId, field, g_szRaffleParticipantName[i][p]);
    }
    new countData[16];
    num_to_str(g_iRaffleCount, countData, charsmax(countData));
    nvault_set(g_iVault, "FC_RAFFLE_COUNT", countData);
}
stock RaffleLoadAll()
{
    if(g_iVault == INVALID_HANDLE) return;
    new countData[16];
    g_iRaffleCount = nvault_get(g_iVault, "FC_RAFFLE_COUNT", countData, charsmax(countData))
        ? clamp(str_to_num(countData), 0, FC_RAFFLE_MAX) : 0;

    for(new id = 1; id <= g_iRaffleCount; id++)
    {
        new i = id - 1, field[32], data[32];
        g_bRaffleActive[i] = bool:RaffleReadInt(id, "active", 0);
        g_iRaffleCreatorUID[i] = RaffleReadInt(id, "creator_uid", 0);
        RaffleReadString(id, "creator_name", g_szRaffleCreator[i], FC_RAFFLE_NAME_LEN - 1);
        RaffleReadString(id, "title", g_szRaffleTitle[i], FC_RAFFLE_TITLE_LEN - 1);
        g_iRaffleRewardType[i] = RaffleReadInt(id, "reward_type", RF_REWARD_TL);
        g_iRaffleRewardAmount[i] = RaffleReadInt(id, "reward_amount", 0);
        g_iRaffleRewardCosmetic[i] = RaffleReadInt(id, "reward_cos", -1);
        g_iRaffleFeeType[i] = RaffleReadInt(id, "fee_type", RF_FEE_FREE);
        g_iRaffleFeeAmount[i] = RaffleReadInt(id, "fee_amount", 0);
        g_iRaffleEndMode[i] = RaffleReadInt(id, "end_mode", RF_END_TIME);
        g_iRaffleEndValue[i] = RaffleReadInt(id, "end_value", 0);
        g_iRaffleCreatedAt[i] = RaffleReadInt(id, "created_at", 0);
        g_iRaffleEndsAt[i] = RaffleReadInt(id, "ends_at", 0);
        g_iRaffleFinishedAt[i] = RaffleReadInt(id, "finished_at", 0);
        g_iRaffleParticipantCount[i] = clamp(RaffleReadInt(id, "participant_count", 0), 0, FC_RAFFLE_PARTICIPANTS);
        g_iRaffleWinnerUID[i] = RaffleReadInt(id, "winner_uid", 0);
        RaffleReadString(id, "winner_name", g_szRaffleWinnerName[i], FC_RAFFLE_NAME_LEN - 1);
        g_bRaffleRewardDelivered[i] = bool:RaffleReadInt(id, "reward_delivered", 0);

        for(new p; p < g_iRaffleParticipantCount[i]; p++)
        {
            formatex(field, charsmax(field), "p%d_uid", p);
            data[0] = 0;
            RaffleReadString(id, field, data, charsmax(data));
            g_iRaffleParticipantUID[i][p] = str_to_num(data);
            formatex(field, charsmax(field), "p%d_name", p);
            RaffleReadString(id, field, g_szRaffleParticipantName[i][p], FC_RAFFLE_NAME_LEN - 1);
        }
    }
    for(new id = 1; id <= g_iRaffleCount; id++)
        RaffleDeliverPendingByUID(g_iRaffleWinnerUID[id - 1]);
}
stock RaffleSaveAll()
{
    for(new id = 1; id <= g_iRaffleCount; id++)
        RaffleSaveOne(id);
}
stock RaffleFindByID(raffleId)
{
    if(raffleId < 1 || raffleId > g_iRaffleCount) return -1;
    return raffleId - 1;
}
stock RaffleFindParticipant(index, uid)
{
    if(index < 0 || index >= g_iRaffleCount || uid <= 0) return -1;
    for(new p; p < g_iRaffleParticipantCount[index]; p++)
        if(g_iRaffleParticipantUID[index][p] == uid) return p;
    return -1;
}
stock bool:RaffleIsManager(id)
{
    return id >= 1 && id <= MaxClients && g_iUID[id] > 0
        && g_bProfileLoaded[id] && !g_bGuestMode[id] && HasRole(id, ROLE_MANAGER);
}
stock bool:RaffleRequireManager(id)
{
    if(RaffleIsManager(id)) return true;
    Chat(id, "Bu bolum yalnizca ^4Yonetici ^1uyeligine aciktir.");
    return false;
}
stock RaffleGetPrizeText(index, output[], outputLen)
{
    new cosmeticName[64];
    switch(g_iRaffleRewardType[index])
    {
        case RF_REWARD_TL:
            formatex(output, outputLen, "%d TL", g_iRaffleRewardAmount[index]);
        case RF_REWARD_COIN:
            formatex(output, outputLen, "%d Coin", g_iRaffleRewardAmount[index]);
        case RF_REWARD_PRIME:
            formatex(output, outputLen, "Prime Uyelik - %d gun", g_iRaffleRewardAmount[index]);
        case RF_REWARD_COSMETIC:
        {
            new idx = g_iRaffleRewardCosmetic[index];
            if(idx >= 0 && idx < COS_ITEM_COUNT)
            {
                CosCfgStr(idx, "NAME", cosmeticName, charsmax(cosmeticName), g_CosPrefix[idx]);
                formatex(output, outputLen, "%s (Kalici)", cosmeticName);
            }
            else copy(output, outputLen, "Kozmetik odulu");
        }
        default: copy(output, outputLen, "Bilinmeyen odul");
    }
}
stock RaffleGetFeeText(index, output[], outputLen)
{
    switch(g_iRaffleFeeType[index])
    {
        case RF_FEE_TL: formatex(output, outputLen, "%d TL", g_iRaffleFeeAmount[index]);
        case RF_FEE_COIN: formatex(output, outputLen, "%d Coin", g_iRaffleFeeAmount[index]);
        default: copy(output, outputLen, "Ucretsiz");
    }
}
stock RaffleGetCollected(index, &tl, &coin)
{
    tl = coin = 0;
    if(g_iRaffleFeeType[index] == RF_FEE_TL)
        tl = g_iRaffleParticipantCount[index] * g_iRaffleFeeAmount[index];
    else if(g_iRaffleFeeType[index] == RF_FEE_COIN)
        coin = g_iRaffleParticipantCount[index] * g_iRaffleFeeAmount[index];
}
stock RaffleGetRemaining(index, output[], outputLen)
{
    if(g_iRaffleEndMode[index] == RF_END_PARTICIPANTS)
    {
        formatex(output, outputLen, "%d / %d kisi", g_iRaffleParticipantCount[index], g_iRaffleEndValue[index]);
        return;
    }
    new remaining = max(0, g_iRaffleEndsAt[index] - get_systime());
    if(remaining >= 86400)
        formatex(output, outputLen, "%d gun %d saat", remaining / 86400, (remaining % 86400) / 3600);
    else if(remaining >= 3600)
        formatex(output, outputLen, "%d saat %d dakika", remaining / 3600, (remaining % 3600) / 60);
    else
        formatex(output, outputLen, "%d dakika", max(1, remaining / 60));
}
stock RafflePayReward(uid, rewardType, amount, cosmetic)
{
    if(uid <= 0) return;
    new id;
    for(new player = 1; player <= MaxClients; player++)
        if(is_user_connected(player) && g_iUID[player] == uid && g_bProfileLoaded[player])
        {
            id = player;
            break;
        }

    if(id)
    {
        switch(rewardType)
        {
            case RF_REWARD_TL:
            {
                g_iTL[id] = max(0, g_iTL[id] + amount);
                SavePlayer(id);
            }
            case RF_REWARD_COIN:
            {
                FC_CoinChange(id, amount);
                SavePlayer(id);
            }
            case RF_REWARD_PRIME:
            {
                new current = g_iRoleExpiry[id][ROLE_PRIME];
                if(current != 0)
                {
                    new base = current > get_systime() ? current : get_systime();
                    g_iRoleExpiry[id][ROLE_PRIME] = base + amount * 86400;
                }
                SavePlayer(id);
            }
            case RF_REWARD_COSMETIC:
            {
                if(cosmetic >= 0 && cosmetic < COS_ITEM_COUNT && IsCosmeticEnabled(cosmetic))
                {
                    g_iCosExpiry[id][cosmetic] = 0;
                    SavePlayer(id);
                    ValidateSelectedCosmetics(id);
                }
            }
        }
        Chat(id, "Cekilis odulun hesabina eklendi!");
        return;
    }

    // Cevrimdisi hesap odulu UID nVault kaydina yazilir; oyuncu girisinde teslim edilir.
    switch(rewardType)
    {
        case RF_REWARD_TL:
        {
            new value = max(0, UIDGetInt(uid, "tl", 0) + amount);
            new limit = CfgInt("TL_MAX_KAYIT", 50000);
            if(limit > 0) value = min(value, limit);
            UIDSetInt(uid, "tl", value);
        }
        case RF_REWARD_COIN:
            UIDSetInt(uid, "coin", max(0, UIDGetInt(uid, "coin", 0) + amount));
        case RF_REWARD_PRIME:
        {
            new current = UIDGetInt(uid, "role_prime", -1);
            if(current != 0)
            {
                new base = current > get_systime() ? current : get_systime();
                UIDSetInt(uid, "role_prime", base + amount * 86400);
            }
        }
        case RF_REWARD_COSMETIC:
        {
            if(cosmetic >= 0 && cosmetic < COS_ITEM_COUNT && IsCosmeticEnabled(cosmetic))
            {
                new field[24];
                formatex(field, charsmax(field), "cos_%d", cosmetic);
                UIDSetInt(uid, field, 0);
            }
        }
    }
}
stock RaffleDeliverPendingByUID(uid)
{
    if(uid <= 0) return;
    new player;
    for(new id = 1; id <= MaxClients; id++)
        if(is_user_connected(id) && g_iUID[id] == uid && g_bProfileLoaded[id])
        {
            player = id;
            break;
        }
    if(!player) return;

    for(new raffleId = 1; raffleId <= g_iRaffleCount; raffleId++)
    {
        new i = raffleId - 1;
        if(g_iRaffleWinnerUID[i] != uid || g_bRaffleRewardDelivered[i]) continue;
        RafflePayReward(uid, g_iRaffleRewardType[i], g_iRaffleRewardAmount[i], g_iRaffleRewardCosmetic[i]);
        g_bRaffleRewardDelivered[i] = true;
        RaffleSaveOne(raffleId);
    }
}
stock RaffleDeliverPending(id)
{
    if(id < 1 || id > MaxClients || g_iUID[id] <= 0 || !g_bProfileLoaded[id]) return;
    RaffleDeliverPendingByUID(g_iUID[id]);
}
stock RaffleFinish(raffleId)
{
    new index = RaffleFindByID(raffleId);
    if(index < 0 || !g_bRaffleActive[index]) return;
    g_bRaffleActive[index] = false;
    g_iRaffleFinishedAt[index] = get_systime();
    g_iRaffleWinnerUID[index] = 0;
    g_szRaffleWinnerName[index][0] = 0;

    if(g_iRaffleParticipantCount[index] > 0)
    {
        new winnerPos = random_num(0, g_iRaffleParticipantCount[index] - 1);
        g_iRaffleWinnerUID[index] = g_iRaffleParticipantUID[index][winnerPos];
        copy(g_szRaffleWinnerName[index], FC_RAFFLE_NAME_LEN - 1,
            g_szRaffleParticipantName[index][winnerPos]);
    }
    RaffleSaveOne(raffleId);

    if(g_iRaffleWinnerUID[index] > 0)
    {
        new prize[128];
        RaffleGetPrizeText(index, prize, charsmax(prize));
        client_print_color(0, print_team_default,
            "^3[FeliciaClan] ^1Cekilis ^4%s ^1sonuclandi! Kazanan: ^4%s ^1| Odul: ^3%s",
            g_szRaffleTitle[index], g_szRaffleWinnerName[index], prize);
        RaffleDeliverPendingByUID(g_iRaffleWinnerUID[index]);
    }
    else
        client_print_color(0, print_team_default,
            "^3[FeliciaClan] ^1Cekilis ^4%s ^1katilim olmadigi icin odulsuz kapatildi.",
            g_szRaffleTitle[index]);
}
public RaffleTick()
{
    new now = get_systime();
    for(new i; i < g_iRaffleCount; i++)
    {
        if(!g_bRaffleActive[i]) continue;
        if(g_iRaffleEndMode[i] == RF_END_TIME && now >= g_iRaffleEndsAt[i])
            RaffleFinish(i + 1);
        else if(g_iRaffleEndMode[i] == RF_END_PARTICIPANTS
            && g_iRaffleParticipantCount[i] >= g_iRaffleEndValue[i])
            RaffleFinish(i + 1);
    }
}

// ============================================================
// CEKILIS SISTEMI - oyuncu menuleri
// ============================================================

RaffleShowHub(id)
{
    if(g_iUID[id] <= 0 || !g_bProfileLoaded[id] || g_bGuestMode[id])
    {
        ShowAccountMenu(id);
        return;
    }
    new menu = FC_MenuCreate("\wCekilis Merkezi", "H_RaffleHub");
    FC_MenuAddItem(menu, "\wAktif Çekilişler", "1");
    FC_MenuAddItem(menu, "\wTamamlanmış Çekilişler", "2");
    if(RaffleIsManager(id))
        FC_MenuAddItem(menu, "\yYönetici Çekiliş Paneli", "3");
    FC_MenuSetProp(menu, MPROP_EXITNAME, "Ana Menu");
    menu_display(id, menu);
}
public H_RaffleHub(id, menu, item)
{
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        ShowMainMenu(id);
        return PLUGIN_HANDLED;
    }
    if(g_iUID[id] <= 0 || !g_bProfileLoaded[id] || g_bGuestMode[id])
    {
        menu_destroy(menu);
        ShowAccountMenu(id);
        return PLUGIN_HANDLED;
    }
    new info[8], name[64], access, cb;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), cb);
    new key = str_to_num(info);
    menu_destroy(menu);
    switch(key)
    {
        case 1: RaffleShowActiveList(id);
        case 2: RaffleShowCompletedList(id);
        case 3:
        {
            if(RaffleRequireManager(id)) RaffleShowManager(id);
        }
    }
    return PLUGIN_HANDLED;
}
RaffleShowActiveList(id)
{
    new menu = FC_MenuCreate("\wAktif Cekilisler", "H_RaffleActiveList");
    new line[160], info[16], added;
    for(new i; i < g_iRaffleCount; i++)
    {
        if(!g_bRaffleActive[i]) continue;
        if(RaffleFindParticipant(i, g_iUID[id]) >= 0)
            formatex(line, charsmax(line), "\w%s \y[Katıldın]", g_szRaffleTitle[i]);
        else
            formatex(line, charsmax(line), "\w%s", g_szRaffleTitle[i]);
        num_to_str(i + 1, info, charsmax(info));
        FC_MenuAddItem(menu, line, info);
        added++;
    }
    if(!added) FC_MenuAddItem(menu, "\dSu anda aktif cekilis yok.", "0");
    FC_MenuSetProp(menu, MPROP_EXITNAME, "Geri");
    menu_display(id, menu);
}
public H_RaffleActiveList(id, menu, item)
{
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        RaffleShowHub(id);
        return PLUGIN_HANDLED;
    }
    new info[16], name[64], access, cb;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), cb);
    new raffleId = str_to_num(info);
    menu_destroy(menu);
    if(raffleId > 0)
    {
        g_iRaffleReturnMode[id] = 1;
        RaffleShowDetail(id, raffleId);
    }
    else RaffleShowActiveList(id);
    return PLUGIN_HANDLED;
}
RaffleShowCompletedList(id)
{
    new menu = FC_MenuCreate("\wTamamlanmis Cekilisler", "H_RaffleCompletedList");
    new line[192], info[16], added;
    for(new i = g_iRaffleCount - 1; i >= 0; i--)
    {
        if(g_bRaffleActive[i]) continue;
        if(g_iRaffleWinnerUID[i] > 0)
            formatex(line, charsmax(line), "\w%s \d- Kazanan: \y%s", g_szRaffleTitle[i], g_szRaffleWinnerName[i]);
        else
            formatex(line, charsmax(line), "\d%s \w[Odulsuz kapandi]", g_szRaffleTitle[i]);
        num_to_str(i + 1, info, charsmax(info));
        FC_MenuAddItem(menu, line, info);
        added++;
    }
    if(!added) FC_MenuAddItem(menu, "\dHenuz tamamlanmis cekilis yok.", "0");
    FC_MenuSetProp(menu, MPROP_EXITNAME, "Geri");
    menu_display(id, menu);
}
public H_RaffleCompletedList(id, menu, item)
{
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        RaffleShowHub(id);
        return PLUGIN_HANDLED;
    }
    new info[16], name[64], access, cb;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), cb);
    new raffleId = str_to_num(info);
    menu_destroy(menu);
    if(raffleId > 0)
    {
        g_iRaffleReturnMode[id] = 2;
        RaffleShowDetail(id, raffleId);
    }
    else RaffleShowCompletedList(id);
    return PLUGIN_HANDLED;
}
RaffleShowDetail(id, raffleId)
{
    new index = RaffleFindByID(raffleId);
    if(index < 0) return;
    new prize[128], fee[64], remaining[64], title[384], line[192];
    RaffleGetPrizeText(index, prize, charsmax(prize));
    RaffleGetFeeText(index, fee, charsmax(fee));
    RaffleGetRemaining(index, remaining, charsmax(remaining));
    formatex(title, charsmax(title), "\w%s^n\dOdul: \y%s^n\dOlusturan: \w%s^n\dKatilim: \w%d \d| Ucret: \y%s",
        g_szRaffleTitle[index], prize, g_szRaffleCreator[index], g_iRaffleParticipantCount[index], fee);
    if(g_bRaffleActive[index])
        formatex(line, charsmax(line), "\dBitis: \w%s", remaining);
    else if(g_iRaffleWinnerUID[index] > 0)
        formatex(line, charsmax(line), "\yKazanan: \w%s \d(UID: %d)", g_szRaffleWinnerName[index], g_iRaffleWinnerUID[index]);
    else
        copy(line, charsmax(line), "\dKatilim olmadigi icin odulsuz kapandi.");
    new menu = FC_MenuCreate(title, "H_RaffleDetail");
    FC_MenuAddItem(menu, line, "0");
    if(g_bRaffleActive[index])
    {
        if(RaffleFindParticipant(index, g_iUID[id]) >= 0)
            FC_MenuAddItem(menu, "\dÇekilişe zaten katıldınız", "0");
        else
            FC_MenuAddItem(menu, "\yÇekilişe Katıl", "1");
    }
    FC_MenuSetProp(menu, MPROP_EXITNAME, "Geri");
    menu_setprop(menu, MPROP_BACKNAME, "Geri");
    menu_display(id, menu);
    g_iRaffleBackPage[id] = raffleId;
}
public H_RaffleDetail(id, menu, item)
{
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        if(g_iRaffleReturnMode[id] == 2) RaffleShowCompletedList(id);
        else RaffleShowActiveList(id);
        return PLUGIN_HANDLED;
    }
    new info[8], name[64], access, cb;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), cb);
    new key = str_to_num(info);
    new raffleId = g_iRaffleBackPage[id];
    menu_destroy(menu);
    if(key == 1) RaffleShowJoinConfirm(id, raffleId);
    else RaffleShowDetail(id, raffleId);
    return PLUGIN_HANDLED;
}
RaffleShowJoinConfirm(id, raffleId)
{
    new index = RaffleFindByID(raffleId);
    if(index < 0 || !g_bRaffleActive[index]) return;
    new fee[64], title[256];
    RaffleGetFeeText(index, fee, charsmax(fee));
    formatex(title, charsmax(title), "\w%s^n\dKatilim ucreti: \y%s^n\dÇekilişe katılmak istediğinize emin misiniz?",
        g_szRaffleTitle[index], fee);
    new menu = FC_MenuCreate(title, "H_RaffleJoinConfirm");
    FC_MenuAddItem(menu, "\yEvet, katil", "1");
    FC_MenuAddItem(menu, "\wHayir", "2");
    FC_MenuSetProp(menu, MPROP_EXITNAME, "Geri");
    menu_display(id, menu);
    g_iRaffleBackPage[id] = raffleId;
}
public H_RaffleJoinConfirm(id, menu, item)
{
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        RaffleShowDetail(id, g_iRaffleBackPage[id]);
        return PLUGIN_HANDLED;
    }
    new info[8], name[64], access, cb;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), cb);
    new key = str_to_num(info), raffleId = g_iRaffleBackPage[id];
    menu_destroy(menu);
    if(key == 1) RaffleJoin(id, raffleId);
    else RaffleShowDetail(id, raffleId);
    return PLUGIN_HANDLED;
}
RaffleJoin(id, raffleId)
{
    new index = RaffleFindByID(raffleId);
    if(index < 0 || !g_bRaffleActive[index] || g_iUID[id] <= 0
        || !g_bProfileLoaded[id] || g_bGuestMode[id])
    {
        Chat(id, "Bu cekilise katilamazsin. Hesabini kontrol et.");
        RaffleShowHub(id);
        return;
    }
    if(RaffleFindParticipant(index, g_iUID[id]) >= 0)
    {
        Chat(id, "Bu cekilise zaten katildin.");
        RaffleShowDetail(id, raffleId);
        return;
    }
    if(g_iRaffleParticipantCount[index] >= FC_RAFFLE_PARTICIPANTS)
    {
        Chat(id, "Bu cekilisin katilim kapasitesi doldu.");
        RaffleShowDetail(id, raffleId);
        return;
    }
    if(g_iRaffleFeeType[index] == RF_FEE_TL && g_iTL[id] < g_iRaffleFeeAmount[index])
    {
        Chat(id, "Cekilise katilmak icin yeterli TL yok.");
        RaffleShowDetail(id, raffleId);
        return;
    }
    if(g_iRaffleFeeType[index] == RF_FEE_COIN && g_iCoin[id] < g_iRaffleFeeAmount[index])
    {
        Chat(id, "Cekilise katilmak icin yeterli Coin yok.");
        RaffleShowDetail(id, raffleId);
        return;
    }

    new pos = g_iRaffleParticipantCount[index], playerName[FC_RAFFLE_NAME_LEN];
    get_user_name(id, playerName, charsmax(playerName));
    g_iRaffleParticipantUID[index][pos] = g_iUID[id];
    copy(g_szRaffleParticipantName[index][pos], FC_RAFFLE_NAME_LEN - 1, playerName);
    g_iRaffleParticipantCount[index]++;
    RaffleSaveOne(raffleId);

    if(g_iRaffleFeeType[index] == RF_FEE_TL)
    {
        g_iTL[id] -= g_iRaffleFeeAmount[index];
        FC_RecordTLSpend(id, g_iRaffleFeeAmount[index]);
        SavePlayer(id);
    }
    else if(g_iRaffleFeeType[index] == RF_FEE_COIN)
    {
        FC_CoinChange(id, -g_iRaffleFeeAmount[index]);
        SavePlayer(id);
    }
    Chat(id, "^4%s ^1cekilisine katildin!", g_szRaffleTitle[index]);
    client_print_color(0, print_team_default, "^3[FeliciaClan] ^4%n ^1bir cekilise katildi. ^3%s", id, g_szRaffleTitle[index]);

    if(g_iRaffleEndMode[index] == RF_END_PARTICIPANTS
        && g_iRaffleParticipantCount[index] >= g_iRaffleEndValue[index])
        RaffleFinish(raffleId);
    else
        RaffleShowDetail(id, raffleId);
}

// ============================================================
// CEKILIS SISTEMI - yonetici paneli
// ============================================================

RaffleShowManager(id)
{
    if(!RaffleRequireManager(id)) return;
    new active, completed, totalTL, totalCoin;
    for(new i; i < g_iRaffleCount; i++)
    {
        if(g_bRaffleActive[i]) active++;
        else completed++;
        if(g_iRaffleFeeType[i] == RF_FEE_TL)
            totalTL += g_iRaffleParticipantCount[i] * g_iRaffleFeeAmount[i];
        else if(g_iRaffleFeeType[i] == RF_FEE_COIN)
            totalCoin += g_iRaffleParticipantCount[i] * g_iRaffleFeeAmount[i];
    }
    new title[256];
    formatex(title, charsmax(title), "\wYonetici Cekilis Paneli^n\dToplam: \w%d \d| Aktif: \y%d \d| Tamamlanan: \y%d^n\dToplanan: \w%d TL \d/ \y%d Coin",
        g_iRaffleCount, active, completed, totalTL, totalCoin);
    new menu = FC_MenuCreate(title, "H_RaffleManager");
    FC_MenuAddItem(menu, "\yCekilis Olustur", "1");
    FC_MenuAddItem(menu, "\wCekilislerim", "2");
    FC_MenuAddItem(menu, "\wKatilim Listeleri", "3");
    FC_MenuSetProp(menu, MPROP_EXITNAME, "Geri");
    menu_display(id, menu);
}
public H_RaffleManager(id, menu, item)
{
    if(!RaffleRequireManager(id))
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        RaffleShowHub(id);
        return PLUGIN_HANDLED;
    }
    new info[8], name[64], access, cb;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), cb);
    new key = str_to_num(info);
    menu_destroy(menu);
    switch(key)
    {
        case 1: RaffleCreateStart(id);
        case 2: RaffleShowMyList(id);
        case 3: RaffleShowParticipationList(id);
    }
    return PLUGIN_HANDLED;
}
RaffleShowMyList(id)
{
    if(!RaffleRequireManager(id)) return;
    new menu = FC_MenuCreate("\wCekilislerim", "H_RaffleMyList");
    new line[160], info[16], added;
    for(new i = g_iRaffleCount - 1; i >= 0; i--)
    {
        if(g_iRaffleCreatorUID[i] != g_iUID[id]) continue;
        if(g_bRaffleActive[i])
            formatex(line, charsmax(line), "\w%s \y[AKTIF] \d- %d kisi", g_szRaffleTitle[i], g_iRaffleParticipantCount[i]);
        else
            formatex(line, charsmax(line), "\d%s \w[Tamamlandi]", g_szRaffleTitle[i]);
        num_to_str(i + 1, info, charsmax(info));
        FC_MenuAddItem(menu, line, info);
        added++;
    }
    if(!added) FC_MenuAddItem(menu, "\dHenuz cekilis olusturmadin.", "0");
    FC_MenuSetProp(menu, MPROP_EXITNAME, "Geri");
    menu_display(id, menu);
}
public H_RaffleMyList(id, menu, item)
{
    if(!RaffleRequireManager(id))
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        RaffleShowManager(id);
        return PLUGIN_HANDLED;
    }
    new info[16], name[64], access, cb;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), cb);
    new raffleId = str_to_num(info);
    menu_destroy(menu);
    if(raffleId > 0) RaffleShowManagerTools(id, raffleId);
    else RaffleShowMyList(id);
    return PLUGIN_HANDLED;
}
RaffleShowParticipationList(id)
{
    if(!RaffleRequireManager(id)) return;
    new menu = FC_MenuCreate("\wAktif Cekilis Katilimlari", "H_RaffleParticipation");
    new line[160], info[16], added;
    for(new i; i < g_iRaffleCount; i++)
    {
        if(!g_bRaffleActive[i]) continue;
        formatex(line, charsmax(line), "\w%s \d- %d katilimci", g_szRaffleTitle[i], g_iRaffleParticipantCount[i]);
        num_to_str(i + 1, info, charsmax(info));
        FC_MenuAddItem(menu, line, info);
        added++;
    }
    if(!added) FC_MenuAddItem(menu, "\dAktif cekilis yok.", "0");
    FC_MenuSetProp(menu, MPROP_EXITNAME, "Geri");
    menu_display(id, menu);
}
public H_RaffleParticipation(id, menu, item)
{
    if(!RaffleRequireManager(id))
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        RaffleShowManager(id);
        return PLUGIN_HANDLED;
    }
    new info[16], name[64], access, cb;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), cb);
    new raffleId = str_to_num(info);
    menu_destroy(menu);
    if(raffleId > 0)
    {
        g_iRaffleReturnMode[id] = 4;
        RaffleShowParticipants(id, raffleId);
    }
    else RaffleShowParticipationList(id);
    return PLUGIN_HANDLED;
}
RaffleShowManagerTools(id, raffleId)
{
    if(!RaffleRequireManager(id)) return;
    new index = RaffleFindByID(raffleId);
    if(index < 0 || g_iRaffleCreatorUID[index] != g_iUID[id])
    {
        Chat(id, "Bu cekilis sana ait degil.");
        RaffleShowMyList(id);
        return;
    }
    new prize[128], fee[64], title[320], collectedTL, collectedCoin;
    RaffleGetPrizeText(index, prize, charsmax(prize));
    RaffleGetFeeText(index, fee, charsmax(fee));
    RaffleGetCollected(index, collectedTL, collectedCoin);
    formatex(title, charsmax(title), "\w%s^n\dOdul: \y%s^n\dKatilim: \w%d \d| Ucret: \y%s^n\dToplanan: \w%d TL \d/ \y%d Coin",
        g_szRaffleTitle[index], prize, g_iRaffleParticipantCount[index], fee, collectedTL, collectedCoin);
    new menu = FC_MenuCreate(title, "H_RaffleManagerTools");
    FC_MenuAddItem(menu, "\wKatilimci Listesini Gor", "1");
    if(g_bRaffleActive[index])
    {
        if(g_iRaffleParticipantCount[index] > 0)
            FC_MenuAddItem(menu, "\rCekilisi Simdi Bitir ve Kazanan Sec", "2");
        else
            FC_MenuAddItem(menu, "\dCekilisi Bitir (katilimci yok)", "0");
    }
    else if(g_iRaffleWinnerUID[index] > 0)
    {
        new winnerLine[128];
        formatex(winnerLine, charsmax(winnerLine), "\yKazanan: \w%s \d(UID: %d)",
            g_szRaffleWinnerName[index], g_iRaffleWinnerUID[index]);
        FC_MenuAddItem(menu, winnerLine, "0");
    }
    else
        FC_MenuAddItem(menu, "\dKatilim olmadan kapandi.", "0");
    FC_MenuSetProp(menu, MPROP_EXITNAME, "Geri");
    menu_display(id, menu);
    g_iRaffleBackPage[id] = raffleId;
}
public H_RaffleManagerTools(id, menu, item)
{
    if(!RaffleRequireManager(id))
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        RaffleShowMyList(id);
        return PLUGIN_HANDLED;
    }
    new info[8], name[64], access, cb;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), cb);
    new key = str_to_num(info), raffleId = g_iRaffleBackPage[id];
    menu_destroy(menu);
    if(key == 1)
    {
        g_iRaffleReturnMode[id] = 3;
        RaffleShowParticipants(id, raffleId);
    }
    else if(key == 2)
        RaffleShowFinishConfirm(id, raffleId);
    else
        RaffleShowManagerTools(id, raffleId);
    return PLUGIN_HANDLED;
}
RaffleShowParticipants(id, raffleId)
{
    if(!RaffleRequireManager(id)) return;
    new index = RaffleFindByID(raffleId);
    if(index < 0) return;
    new title[256], line[96], info[16], collectedTL, collectedCoin;
    RaffleGetCollected(index, collectedTL, collectedCoin);
    formatex(title, charsmax(title), "\w%s^n\dKatilimci: \y%d \d| Toplanan: \w%d TL \d/ \y%d Coin",
        g_szRaffleTitle[index], g_iRaffleParticipantCount[index], collectedTL, collectedCoin);
    new menu = FC_MenuCreate(title, "H_RaffleParticipants");
    for(new p; p < g_iRaffleParticipantCount[index]; p++)
    {
        formatex(line, charsmax(line), "\w%s \d(UID: %d)",
            g_szRaffleParticipantName[index][p], g_iRaffleParticipantUID[index][p]);
        num_to_str(p + 1, info, charsmax(info));
        FC_MenuAddItem(menu, line, info);
    }
    if(!g_iRaffleParticipantCount[index])
        FC_MenuAddItem(menu, "\dHenuz katilim yok.", "0");
    FC_MenuSetProp(menu, MPROP_EXITNAME, "Geri");
    menu_display(id, menu);
    g_iRaffleBackPage[id] = raffleId;
}
public H_RaffleParticipants(id, menu, item)
{
    if(!RaffleRequireManager(id))
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        if(g_iRaffleReturnMode[id] == 3)
            RaffleShowManagerTools(id, g_iRaffleBackPage[id]);
        else
            RaffleShowManager(id);
        return PLUGIN_HANDLED;
    }
    new info[16], name[64], access, cb;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), cb);
    menu_destroy(menu);
    // Katilimci menusu yalnizca goruntuleme amaclidir.
    RaffleShowParticipants(id, g_iRaffleBackPage[id]);
    return PLUGIN_HANDLED;
}
RaffleShowFinishConfirm(id, raffleId)
{
    if(!RaffleRequireManager(id)) return;
    new menu = FC_MenuCreate("\wCekilisi simdi bitirmek istiyor musun?^n\dKazanan katilimcilar arasindan rastgele secilecek.", "H_RaffleFinishConfirm");
    FC_MenuAddItem(menu, "\rEvet, cekilisi bitir", "1");
    FC_MenuAddItem(menu, "\wHayir", "2");
    FC_MenuSetProp(menu, MPROP_EXITNAME, "Geri");
    menu_display(id, menu);
    g_iRaffleBackPage[id] = raffleId;
}
public H_RaffleFinishConfirm(id, menu, item)
{
    if(!RaffleRequireManager(id))
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        RaffleShowManagerTools(id, g_iRaffleBackPage[id]);
        return PLUGIN_HANDLED;
    }
    new info[8], name[64], access, cb;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), cb);
    new key = str_to_num(info), raffleId = g_iRaffleBackPage[id];
    menu_destroy(menu);
    new index = RaffleFindByID(raffleId);
    if(key == 1 && index >= 0 && g_bRaffleActive[index]
        && g_iRaffleCreatorUID[index] == g_iUID[id] && g_iRaffleParticipantCount[index] > 0)
    {
        RaffleFinish(raffleId);
        Chat(id, "Cekilis tamamlandi ve kazanan secildi.");
    }
    RaffleShowManagerTools(id, raffleId);
    return PLUGIN_HANDLED;
}

// ============================================================
// CEKILIS SISTEMI - olusturma sihirbazi
// ============================================================

RaffleCreateStart(id)
{
    if(!RaffleRequireManager(id)) return;
    g_iRaffleDraftReward[id] = RF_REWARD_TL;
    g_iRaffleDraftAmount[id] = 0;
    g_iRaffleDraftCosmetic[id] = -1;
    g_iRaffleDraftFee[id] = RF_FEE_FREE;
    g_iRaffleDraftFeeAmount[id] = 0;
    g_iRaffleDraftEndMode[id] = RF_END_TIME;
    g_iRaffleDraftEndValue[id] = 0;
    g_szRaffleDraftTitle[id][0] = 0;
    client_cmd(id, "messagemode FC_Raffle_Name");
    Chat(id, "Cekilis adini yaz ve Enter'a bas.");
}
public CmdRaffleName(id)
{
    if(!RaffleRequireManager(id)) return PLUGIN_HANDLED;
    read_args(g_szRaffleDraftTitle[id], FC_RAFFLE_TITLE_LEN - 1);
    remove_quotes(g_szRaffleDraftTitle[id]);
    trim(g_szRaffleDraftTitle[id]);
    if(!g_szRaffleDraftTitle[id][0])
    {
        Chat(id, "Cekilis adi bos olamaz.");
        RaffleCreateStart(id);
        return PLUGIN_HANDLED;
    }
    RaffleShowRewardType(id);
    return PLUGIN_HANDLED;
}
RaffleShowRewardType(id)
{
    if(!RaffleRequireManager(id)) return;
    new menu = FC_MenuCreate("\wCekilis Odul Turu", "H_RaffleReward");
    FC_MenuAddItem(menu, "\wTL", "1");
    FC_MenuAddItem(menu, "\yCoin", "2");
    FC_MenuAddItem(menu, "\wPrime Uyelik", "3");
    FC_MenuAddItem(menu, "\wKozmetik Urun", "4");
    FC_MenuSetProp(menu, MPROP_EXITNAME, "Iptal");
    menu_display(id, menu);
}
public H_RaffleReward(id, menu, item)
{
    if(!RaffleRequireManager(id))
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        RaffleShowManager(id);
        return PLUGIN_HANDLED;
    }
    new info[8], name[64], access, cb;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), cb);
    new key = str_to_num(info);
    menu_destroy(menu);
    switch(key)
    {
        case 1, 2:
        {
            g_iRaffleDraftReward[id] = key == 1 ? RF_REWARD_TL : RF_REWARD_COIN;
            client_cmd(id, "messagemode FC_Raffle_RewardAmount");
            Chat(id, key == 1 ? "Verilecek TL miktarini yaz." : "Verilecek Coin miktarini yaz.");
        }
        case 3: RaffleShowPrimeDuration(id);
        case 4: RaffleShowCosmeticRewards(id);
    }
    return PLUGIN_HANDLED;
}
public CmdRaffleRewardAmount(id)
{
    if(!RaffleRequireManager(id)) return PLUGIN_HANDLED;
    new input[32];
    read_args(input, charsmax(input));
    remove_quotes(input);
    trim(input);
    if(!is_str_num(input) || str_to_num(input) <= 0 || str_to_num(input) > 100000000)
    {
        Chat(id, "Gecerli ve sifirdan buyuk bir odul miktari yaz.");
        client_cmd(id, "messagemode FC_Raffle_RewardAmount");
        return PLUGIN_HANDLED;
    }
    g_iRaffleDraftAmount[id] = str_to_num(input);
    RaffleShowFeeType(id);
    return PLUGIN_HANDLED;
}
RaffleShowPrimeDuration(id)
{
    if(!RaffleRequireManager(id)) return;
    new menu = FC_MenuCreate("\wPrime Uyelik Suresi", "H_RafflePrimeDuration");
    FC_MenuAddItem(menu, "\w1 Gunluk Prime", "1");
    FC_MenuAddItem(menu, "\w1 Haftalik Prime", "7");
    FC_MenuAddItem(menu, "\y1 Aylik Prime (30 gun)", "30");
    FC_MenuSetProp(menu, MPROP_EXITNAME, "Geri");
    menu_display(id, menu);
}
public H_RafflePrimeDuration(id, menu, item)
{
    if(!RaffleRequireManager(id))
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        RaffleShowRewardType(id);
        return PLUGIN_HANDLED;
    }
    new info[16], name[64], access, cb;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), cb);
    g_iRaffleDraftReward[id] = RF_REWARD_PRIME;
    g_iRaffleDraftAmount[id] = str_to_num(info);
    menu_destroy(menu);
    RaffleShowFeeType(id);
    return PLUGIN_HANDLED;
}
RaffleShowCosmeticRewards(id)
{
    if(!RaffleRequireManager(id)) return;
    new menu = FC_MenuCreate("\wCekilis Kozmetik Odulu", "H_RaffleCosmeticReward");
    new itemName[64], line[128], info[16], added;
    for(new idx; idx < COS_ITEM_COUNT; idx++)
    {
        if(!IsCosmeticEnabled(idx)) continue;
        CosCfgStr(idx, "NAME", itemName, charsmax(itemName), g_CosPrefix[idx]);
        formatex(line, charsmax(line), "\w%s", itemName);
        num_to_str(idx, info, charsmax(info));
        FC_MenuAddItem(menu, line, info);
        added++;
    }
    if(!added) FC_MenuAddItem(menu, "\dAktif kozmetik urun bulunamadi.", "-1");
    FC_MenuSetProp(menu, MPROP_EXITNAME, "Geri");
    menu_display(id, menu);
}
public H_RaffleCosmeticReward(id, menu, item)
{
    if(!RaffleRequireManager(id))
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        RaffleShowRewardType(id);
        return PLUGIN_HANDLED;
    }
    new info[16], name[64], access, cb;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), cb);
    new idx = str_to_num(info);
    menu_destroy(menu);
    if(idx < 0 || idx >= COS_ITEM_COUNT || !IsCosmeticEnabled(idx))
    {
        RaffleShowCosmeticRewards(id);
        return PLUGIN_HANDLED;
    }
    g_iRaffleDraftReward[id] = RF_REWARD_COSMETIC;
    g_iRaffleDraftCosmetic[id] = idx;
    g_iRaffleDraftAmount[id] = 0;
    RaffleShowFeeType(id);
    return PLUGIN_HANDLED;
}
RaffleShowFeeType(id)
{
    if(!RaffleRequireManager(id)) return;
    new menu = FC_MenuCreate("\wCekilis Katilim Ucreti", "H_RaffleFeeType");
    FC_MenuAddItem(menu, "\wUcretsiz", "1");
    FC_MenuAddItem(menu, "\wTL ile katilim", "2");
    FC_MenuAddItem(menu, "\yCoin ile katilim", "3");
    FC_MenuSetProp(menu, MPROP_EXITNAME, "Iptal");
    menu_display(id, menu);
}
public H_RaffleFeeType(id, menu, item)
{
    if(!RaffleRequireManager(id))
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        RaffleShowManager(id);
        return PLUGIN_HANDLED;
    }
    new info[8], name[64], access, cb;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), cb);
    new key = str_to_num(info);
    menu_destroy(menu);
    if(key == 1)
    {
        g_iRaffleDraftFee[id] = RF_FEE_FREE;
        g_iRaffleDraftFeeAmount[id] = 0;
        RaffleShowEndType(id);
    }
    else
    {
        g_iRaffleDraftFee[id] = key == 2 ? RF_FEE_TL : RF_FEE_COIN;
        client_cmd(id, "messagemode FC_Raffle_FeeAmount");
        Chat(id, key == 2 ? "Katilim icin alinacak TL miktarini yaz." : "Katilim icin alinacak Coin miktarini yaz.");
    }
    return PLUGIN_HANDLED;
}
public CmdRaffleFeeAmount(id)
{
    if(!RaffleRequireManager(id)) return PLUGIN_HANDLED;
    new input[32];
    read_args(input, charsmax(input));
    remove_quotes(input);
    trim(input);
    if(!is_str_num(input) || str_to_num(input) <= 0 || str_to_num(input) > 100000000)
    {
        Chat(id, "Gecerli ve sifirdan buyuk bir katilim ucreti yaz.");
        client_cmd(id, "messagemode FC_Raffle_FeeAmount");
        return PLUGIN_HANDLED;
    }
    g_iRaffleDraftFeeAmount[id] = str_to_num(input);
    RaffleShowEndType(id);
    return PLUGIN_HANDLED;
}
RaffleShowEndType(id)
{
    if(!RaffleRequireManager(id)) return;
    new menu = FC_MenuCreate("\wCekilis Bitis Kosulu", "H_RaffleEndType");
    FC_MenuAddItem(menu, "\wSure dolunca bitir", "1");
    FC_MenuAddItem(menu, "\yKatilimci sayisina ulasinca bitir", "2");
    FC_MenuSetProp(menu, MPROP_EXITNAME, "Iptal");
    menu_display(id, menu);
}
public H_RaffleEndType(id, menu, item)
{
    if(!RaffleRequireManager(id))
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        RaffleShowManager(id);
        return PLUGIN_HANDLED;
    }
    new info[8], name[64], access, cb;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), cb);
    new key = str_to_num(info);
    menu_destroy(menu);
    g_iRaffleDraftEndMode[id] = key == 1 ? RF_END_TIME : RF_END_PARTICIPANTS;
    client_cmd(id, "messagemode FC_Raffle_EndValue");
    Chat(id, key == 1 ? "Cekilis suresini saat olarak yaz (1-720)." : "Cekilisin kac katilimciya ulasinca bitecegini yaz (2-64).");
    return PLUGIN_HANDLED;
}
public CmdRaffleEndValue(id)
{
    if(!RaffleRequireManager(id)) return PLUGIN_HANDLED;
    new input[32];
    read_args(input, charsmax(input));
    remove_quotes(input);
    trim(input);
    if(!is_str_num(input))
    {
        Chat(id, "Gecerli bir sayi gir.");
        client_cmd(id, "messagemode FC_Raffle_EndValue");
        return PLUGIN_HANDLED;
    }
    new value = str_to_num(input);
    if((g_iRaffleDraftEndMode[id] == RF_END_TIME && (value < 1 || value > 720))
        || (g_iRaffleDraftEndMode[id] == RF_END_PARTICIPANTS
            && (value < 2 || value > FC_RAFFLE_PARTICIPANTS)))
    {
        Chat(id, "Deger secilen bitis kosulunun sinirlari disinda.");
        client_cmd(id, "messagemode FC_Raffle_EndValue");
        return PLUGIN_HANDLED;
    }
    g_iRaffleDraftEndValue[id] = value;
    RaffleCreateFinish(id);
    return PLUGIN_HANDLED;
}
RaffleCreateFinish(id)
{
    if(!RaffleRequireManager(id)) return;
    if(g_iRaffleCount >= FC_RAFFLE_MAX)
    {
        Chat(id, "Cekilis kayit limiti doldu. Eski kayitlari arsivlemeden yeni cekilis olusturulamiyor.");
        RaffleShowManager(id);
        return;
    }
    new raffleId = ++g_iRaffleCount, i = raffleId - 1;
    g_bRaffleActive[i] = true;
    g_iRaffleCreatorUID[i] = g_iUID[id];
    get_user_name(id, g_szRaffleCreator[i], FC_RAFFLE_NAME_LEN - 1);
    copy(g_szRaffleTitle[i], FC_RAFFLE_TITLE_LEN - 1, g_szRaffleDraftTitle[id]);
    g_iRaffleRewardType[i] = g_iRaffleDraftReward[id];
    g_iRaffleRewardAmount[i] = g_iRaffleDraftAmount[id];
    g_iRaffleRewardCosmetic[i] = g_iRaffleDraftCosmetic[id];
    g_iRaffleFeeType[i] = g_iRaffleDraftFee[id];
    g_iRaffleFeeAmount[i] = g_iRaffleDraftFeeAmount[id];
    g_iRaffleEndMode[i] = g_iRaffleDraftEndMode[id];
    g_iRaffleEndValue[i] = g_iRaffleDraftEndValue[id];
    g_iRaffleCreatedAt[i] = get_systime();
    g_iRaffleEndsAt[i] = g_iRaffleEndMode[i] == RF_END_TIME
        ? g_iRaffleCreatedAt[i] + g_iRaffleEndValue[i] * 3600 : 0;
    g_iRaffleFinishedAt[i] = 0;
    g_iRaffleParticipantCount[i] = 0;
    g_iRaffleWinnerUID[i] = 0;
    g_szRaffleWinnerName[i][0] = 0;
    g_bRaffleRewardDelivered[i] = false;
    RaffleSaveOne(raffleId);
    client_print_color(0, print_team_default,
        "^3[FeliciaClan] ^4%n ^1yeni bir cekilis olusturdu: ^3%s", id, g_szRaffleTitle[i]);
    Chat(id, "Cekilis olusturuldu ve aktif edildi.");
    RaffleShowManagerTools(id, raffleId);
}

// ============================================================
// STANDART MARKETLER - CAN / SALDIRI / CEPHANE TEK SECENEK ALTINDA
// ============================================================

ShowStandardMarkets(id)
{
    new menu = FC_MenuCreate("\wMarketler", "H_StandardMarkets");
    FC_MenuAddItem(menu, "\wCan Market", "1");
    FC_MenuAddItem(menu, "\wSaldiri Menusu", "2");
    FC_MenuAddItem(menu, "\wCephane Menusu", "3");
    FC_MenuSetProp(menu, MPROP_EXITNAME, "Geri");
    menu_display(id, menu);
}

public H_StandardMarkets(id, menu, item)
{
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        ShowMainMenu(id);
        return PLUGIN_HANDLED;
    }

    if(!CanUseJBMenu(id, true))
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }

    new info[8], name[64], access, cb;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), cb);
    new key = str_to_num(info);
    menu_destroy(menu);

    switch(key)
    {
        case 1: ShowHealthMarket(id);
        case 2: ShowAttackMenu(id);
        case 3: ShowAmmoMenu(id);
    }
    return PLUGIN_HANDLED;
}

// ============================================================
// 1) ANA MARKET - DEFAULT T/CT GIZLI, -2 TL BICAK + TESTERE
// ============================================================
ShowMainMarket(id)
{
    if(!is_user_alive(id))
    {
        Chat(id, "Ana Market icin hayatta olmalisin.");
        return;
    }

    new menu = FC_MenuCreate("\wAna Market", "H_MainMarket");
    new line[192], itemName[64], price;
    new knifeCallback = menu_makecallback("CB_MainSpecialKnife");
    new adCallback = menu_makecallback("CB_MainAdvertisement");

    CfgStr("MAIN_MINUS2_NAME", itemName, charsmax(itemName), "Fps Knife");
    price = CfgInt("MAIN_MINUS2_TL", -2);
    if(price > 0) price = CalcPrice(id, price);
    if(g_bSpecialKnifeBought[id])
        formatex(line, charsmax(line), "\d%s \y[ \d- \wBu El Kullanildi \d- \y]", itemName);
    else if(price < 0)
        formatex(line, charsmax(line), "\w%s \y[ \d- \r+%d TL \d- \y]", itemName, -price);
    else if(price == 0)
        formatex(line, charsmax(line), "\w%s \y[ \d- \rUcretsiz \d- \y]", itemName);
    else
        formatex(line, charsmax(line), "\w%s \y[ \d- \r%d TL \d- \y]", itemName, price);
    FC_MenuAddItemCB(menu, line, "2", knifeCallback);

    CfgStr("MAIN_MINUS2_2_NAME", itemName, charsmax(itemName), "Ekstra Fps Knife");
    price = CfgInt("MAIN_MINUS2_2_TL", -2);
    if(price > 0) price = CalcPrice(id, price);
    if(g_bSpecialKnifeBought[id])
        formatex(line, charsmax(line), "\d%s \y[ \d- \wBu El Kullanildi \d- \y]", itemName);
    else if(price < 0)
        formatex(line, charsmax(line), "\w%s \y[ \d- \r+%d TL \d- \y]", itemName, -price);
    else if(price == 0)
        formatex(line, charsmax(line), "\w%s \y[ \d- \rUcretsiz \d- \y]", itemName);
    else
        formatex(line, charsmax(line), "\w%s \y[ \d- \r%d TL \d- \y]", itemName, price);
    FC_MenuAddItemCB(menu, line, "3", knifeCallback);

    CfgStr("MAIN_SAW_NAME", itemName, charsmax(itemName), "Testere");
    price = CfgInt("MAIN_SAW_TL", 50);
    if(price > 0) price = CalcPrice(id, price);
    if(g_bSpecialKnifeBought[id])
        formatex(line, charsmax(line), "\d%s \y[ \d- \wBu El Kullanildi \d- \y]", itemName);
    else if(price < 0)
        formatex(line, charsmax(line), "\w%s \y[ \d- \r+%d TL \d- \y]", itemName, -price);
    else if(price == 0)
        formatex(line, charsmax(line), "\w%s \y[ \d- \rUcretsiz \d- \y]", itemName);
    else
        formatex(line, charsmax(line), "\w%s \y[ \d- \r%d TL \d- \y]", itemName, price);
    FC_MenuAddItemCB(menu, line, "4", knifeCallback);

    new adName[64];
    CfgStr("MAIN_AD_NAME", adName, charsmax(adName), "Reklam At");
    price = CfgInt("MAIN_AD_TL", -3);
    if(price > 0) price = CalcPrice(id, price);

    // Reklam, bicaklardan sonra yalnizca gorunur bir boslukla ayrilir.
    menu_addblank(menu, 0);

    if(g_bMainAdUsed[id])
        formatex(line, charsmax(line), "\d%s \y[ \d- \wBu El Kullanildi \d- \y]", adName);
    else if(price < 0)
        formatex(line, charsmax(line), "\w%s \y[ \d- \r+%d TL \d- \y]", adName, -price);
    else if(price == 0)
        formatex(line, charsmax(line), "\w%s \y[ \d- \rUcretsiz \d- \y]", adName);
    else
        formatex(line, charsmax(line), "\w%s \y[ \d- \r%d TL \d- \y]", adName, price);

    FC_MenuAddItemCB(menu, line, "5", adCallback);
    // 0 Kapat seçeneğini 10. slota taşımak için boşluklar
    for(new i = 0; i < 5; i++)
    {
        menu_addblank2(menu);
    }

    // Sayfalama kapalı
    menu_setprop(menu, MPROP_PERPAGE, 0);

    // Kapat seçeneğini zorla göster
    menu_setprop(menu, MPROP_EXIT, MEXIT_FORCE);
    
    FC_MenuSetProp(menu, MPROP_EXITNAME, "Kapat");

    menu_display(id, menu);

}

public CB_MainSpecialKnife(id, menu, item)
{
    return g_bSpecialKnifeBought[id] ? ITEM_DISABLED : ITEM_ENABLED;
}

public CB_MainAdvertisement(id, menu, item)
{
    return g_bMainAdUsed[id] ? ITEM_DISABLED : ITEM_ENABLED;
}

public H_MainMarket(id, menu, item)
{
    if(item == MENU_EXIT)
	{
    menu_destroy(menu);
    return PLUGIN_HANDLED;
	}

    if(!CanUseJBMenu(id, true))
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }

    new info[8], name[64], access, cb;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), cb);
    new action = str_to_num(info);
    menu_destroy(menu);

    if(action == 5)
        BuyMainAdvertisement(id);
    else if(action >= 2 && action <= 4)
        BuyMainKnife(id, action);

    return PLUGIN_HANDLED;
}

BuyMainAdvertisement(id)
{
    if(!is_user_alive(id) || g_bMainAdUsed[id])
        return;

    new price = CfgInt("MAIN_AD_TL", -3);
    if(price > 0)
        price = CalcPrice(id, price);

    if(price > 0 && g_iTL[id] < price)
    {
        Chat(id, "Reklam icin yeterli TL yok. Gereken: ^3%d TL", price);
        ShowMainMarket(id);
        return;
    }

    // Pozitif deger TL keser, negatif deger oyuncuya TL kazandirir.
    g_iTL[id] -= price;
    if(price > 0)
        FC_RecordTLSpend(id, price);

    g_bMainAdUsed[id] = true;
    SavePlayer(id);

    new adText[256], playerName[32];
    CfgStr("MAIN_AD_TEXT", adText, charsmax(adText),
        "{PLAYER} FeliciaClan JailBreak sunucumuza herkesi bekliyor!");
    if(!adText[0])
        copy(adText, charsmax(adText), "{PLAYER} FeliciaClan sunucusuna herkesi bekliyor!");

    get_user_name(id, playerName, charsmax(playerName));
    replace_all(adText, charsmax(adText), "{PLAYER}", playerName);

    // INI'deki ^^1 / ^^3 / ^^4 iki karakterli yazimini SayText renk koduna cevir.
    replace_all(adText, charsmax(adText), "^^1", "^1");
    replace_all(adText, charsmax(adText), "^^2", "^2");
    replace_all(adText, charsmax(adText), "^^3", "^3");
    replace_all(adText, charsmax(adText), "^^4", "^4");

    client_print_color(0, print_team_default, "^1%s", adText);

    if(price < 0)
        Chat(id, "Reklamin yayinlandi. ^3+%d TL ^1kazandin. Bakiye: ^3%d TL", -price, g_iTL[id]);
    else if(price > 0)
        Chat(id, "Reklamin yayinlandi. ^3-%d TL ^1harcadin. Bakiye: ^3%d TL", price, g_iTL[id]);
    else
        Chat(id, "Reklamin ucretsiz yayinlandi.");

    ShowMainMarket(id);
}

BuyMainKnife(id, knife)
{
    if(!is_user_alive(id))
        return;

    new TeamName:team = get_member(id, m_iTeam);
    if(knife < 2 || knife > 4 || team != TEAM_TERRORIST)
    {
        Chat(id, "Ana Market bicaklari sadece T takimi icindir.");
        ShowMainMarket(id);
        return;
    }

    if(g_bSpecialKnifeBought[id])
    {
        Chat(id, "Bu el zaten ozel bicak satin aldin.");
        ShowMainMarket(id);
        return;
    }

    new price;
    switch(knife)
    {
        case 2: price = CfgInt("MAIN_MINUS2_TL", -2);
        case 3: price = CfgInt("MAIN_MINUS2_2_TL", -2);
        case 4: price = CfgInt("MAIN_SAW_TL", 50);
        default: return;
    }

    if(price > 0)
        price = CalcPrice(id, price);

    if(price > 0 && g_iTL[id] < price)
    {
        Chat(id, "Yeterli TL yok. Gereken: ^3%d TL", price);
        ShowMainMarket(id);
        return;
    }

    g_iTL[id] -= price;
    if(price > 0)
        FC_RecordTLSpend(id, price);
    g_iBaseKnife[id] = knife;
    g_bSpecialKnifeBought[id] = true;

    rg_give_item(id, "weapon_knife", GT_REPLACE);
    SavePlayer(id);

    new product[64];
    switch(knife)
    {
        case 2: CfgStr("MAIN_MINUS2_NAME", product, charsmax(product), "Fps Knife");
        case 3: CfgStr("MAIN_MINUS2_2_NAME", product, charsmax(product), "Ekstra Fps Knife");
        case 4: CfgStr("MAIN_SAW_NAME", product, charsmax(product), "Testere");
    }
    PurchaseSuccess(id, product);

    if(price < 0)
        Chat(id, "Bu secimden ^3%d TL ^1kazandin. Yeni bakiye: ^3%d TL", -price, g_iTL[id]);
}


// ============================================================
// 2) CAN MARKET - SABIT 100 / 200 / 300 / 400 / 500 HP
// ============================================================

ShowHealthMarket(id)
{
    new title[128];formatex(title,charsmax(title),"\wCan Market^n\dBu el: \y%d / 3",g_iHPBought[id]);
    new menu = FC_MenuCreate(title, "H_Health");
    AddPriceItem(menu, id, "+100 Can", "HP100_TL", 20, "100");
    AddPriceItem(menu, id, "+200 Can", "HP200_TL", 35, "200");
    AddPriceItem(menu, id, "+300 Can", "HP300_TL", 50, "300");
    AddPriceItem(menu, id, "+400 Can", "HP400_TL", 65, "400");
    AddPriceItem(menu, id, "+500 Can", "HP500_TL", 80, "500");
    FC_MenuSetProp(menu, MPROP_EXITNAME, "Geri");
    menu_display(id, menu);
}

public H_Health(id, menu, item)
{
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        ShowStandardMarkets(id);
        return PLUGIN_HANDLED;
    }

    if(!CanUseJBMenu(id, true))
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }

    new info[8], name[64], access, cb;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), cb);
    new hp = str_to_num(info);
    menu_destroy(menu);

    if(!is_user_alive(id) || get_member(id, m_iTeam) != TEAM_TERRORIST)
    {
        Chat(id, "Can Market sadece hayattaki T oyuncular icindir.");
        return PLUGIN_HANDLED;
    }

    if(hp!=100 && hp!=200 && hp!=300 && hp!=400 && hp!=500) return PLUGIN_HANDLED;
    if(g_iHPBought[id]>=3) {Chat(id,"Can Market'ten bir elde en fazla ^3 3 kez ^1satın alabilirsin.");ShowHealthMarket(id);return PLUGIN_HANDLED;}
    new key[24];
    formatex(key, charsmax(key), "HP%d_TL", hp);
    if(!PayTL(id, CfgInt(key, 20+(hp/100-1)*15)))
    {
        ShowHealthMarket(id);
        return PLUGIN_HANDLED;
    }

    new Float:health;
    get_entvar(id, var_health, health);
    set_entvar(id, var_health, health + float(hp));
    g_iHPBought[id]++;SavePlayer(id);

    new product[48];
    formatex(product, charsmax(product), "+%d Can", hp);
    PurchaseSuccess(id, product);
    return PLUGIN_HANDLED;
}

// ============================================================
// 3) SALDIRI MENUSU
// ============================================================

ShowAttackMenu(id)
{
    new menu = FC_MenuCreate("\wSaldiri Menusu", "H_Attack");
    new line[160], sec, price;

    sec = CfgInt("ATTACK_NOCLIP_SECONDS", 5); price = CalcPrice(id, CfgInt("ATTACK_NOCLIP_TL", 80));
    formatex(line, charsmax(line), "\w%d Sn Noclip \y- %d TL", sec, price); FC_MenuAddItem(menu, line, "1");

    sec = CfgInt("ATTACK_GOD_SECONDS", 3); price = CalcPrice(id, CfgInt("ATTACK_GOD_TL", 100));
    formatex(line, charsmax(line), "\w%d Sn Godmode \y- %d TL", sec, price); FC_MenuAddItem(menu, line, "2");

    sec = CfgInt("ATTACK_INVIS_SECONDS", 5); price = CalcPrice(id, CfgInt("ATTACK_INVIS_TL", 70));
    formatex(line, charsmax(line), "\w%d Sn Gorunmezlik \y- %d TL", sec, price); FC_MenuAddItem(menu, line, "3");

    price = CalcPrice(id, CfgInt("ATTACK_SILENT_TL", 55));
    formatex(line, charsmax(line), "\wSessiz Adimlar \y- %d TL", price); FC_MenuAddItem(menu, line, "4");

    price = CalcPrice(id, CfgInt("ATTACK_VAMPIRE_TL", 85));
    formatex(line, charsmax(line), "\wVampir \y- %d TL", price); FC_MenuAddItem(menu, line, "5");

    price = CalcPrice(id, CfgInt("ATTACK_DOUBLE_TL", 120));
    formatex(line, charsmax(line), "\wCift Hasar \y- %d TL", price); FC_MenuAddItem(menu, line, "6");

    price = CalcPrice(id, CfgInt("ATTACK_SHIELD_TL", 100));
    formatex(line, charsmax(line), "\wHasar Kalkani \y- %d TL", price); FC_MenuAddItem(menu, line, "7");

    FC_MenuSetProp(menu, MPROP_EXITNAME, "Geri");
    menu_display(id, menu);
}

public H_Attack(id, menu, item)
{
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        ShowStandardMarkets(id);
        return PLUGIN_HANDLED;
    }

    if(!CanUseJBMenu(id, true))
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }

    new info[8], name[64], access, cb;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), cb);
    new key = str_to_num(info);
    menu_destroy(menu);

    if(!is_user_alive(id) || get_member(id, m_iTeam) != TEAM_TERRORIST)
    {
        Chat(id, "Saldiri Menusu sadece hayattaki T oyuncular icindir.");
        return PLUGIN_HANDLED;
    }

    new product[64];

    switch(key)
    {
        case 1:
        {
            if(!PayTL(id, CfgInt("ATTACK_NOCLIP_TL", 80))) return PLUGIN_HANDLED;
            formatex(product, charsmax(product), "%d Sn Noclip", CfgInt("ATTACK_NOCLIP_SECONDS",5));
            set_entvar(id, var_movetype, MOVETYPE_NOCLIP);
            remove_task(id + TASK_NOCLIP);
            set_task(float(CfgInt("ATTACK_NOCLIP_SECONDS", 5)), "TaskRemoveNoclip", id + TASK_NOCLIP);
        }
        case 2:
        {
            if(!PayTL(id, CfgInt("ATTACK_GOD_TL", 100))) return PLUGIN_HANDLED;
            formatex(product, charsmax(product), "%d Sn Godmode", CfgInt("ATTACK_GOD_SECONDS",3));
            set_entvar(id, var_takedamage, DAMAGE_NO);
            remove_task(id + TASK_GOD);
            set_task(float(CfgInt("ATTACK_GOD_SECONDS", 3)), "TaskRemoveGod", id + TASK_GOD);
        }
        case 3:
        {
            if(!PayTL(id, CfgInt("ATTACK_INVIS_TL", 70))) return PLUGIN_HANDLED;
            formatex(product, charsmax(product), "%d Sn Gorunmezlik", CfgInt("ATTACK_INVIS_SECONDS",5));
            set_entvar(id, var_effects, get_entvar(id, var_effects) | EF_NODRAW);
            remove_task(id + TASK_INVIS);
            set_task(float(CfgInt("ATTACK_INVIS_SECONDS", 5)), "TaskRemoveInvis", id + TASK_INVIS);
        }
        case 4:
        {
            if(!PayTL(id, CfgInt("ATTACK_SILENT_TL", 55))) return PLUGIN_HANDLED;
            copy(product, charsmax(product), "Sessiz Adimlar");
            g_bSilentSteps[id] = true;
            rg_set_user_footsteps(id, true);
        }
        case 5:
        {
            if(!PayTL(id, CfgInt("ATTACK_VAMPIRE_TL", 85))) return PLUGIN_HANDLED;
            copy(product, charsmax(product), "Vampir");
            g_bVampire[id] = true;
        }
        case 6:
        {
            if(!PayTL(id, CfgInt("ATTACK_DOUBLE_TL", 120))) return PLUGIN_HANDLED;
            copy(product, charsmax(product), "Cift Hasar");
            g_bDoubleDamage[id] = true;
        }
        case 7:
        {
            if(!PayTL(id, CfgInt("ATTACK_SHIELD_TL", 100))) return PLUGIN_HANDLED;
            copy(product, charsmax(product), "Hasar Kalkani");
            g_bDamageShield[id] = true;
        }
    }

    PurchaseSuccess(id, product);
    return PLUGIN_HANDLED;
}

public TaskRemoveNoclip(taskid)
{
    new id = taskid - TASK_NOCLIP;
    if(is_user_connected(id)) set_entvar(id, var_movetype, MOVETYPE_WALK);
}
public TaskRemoveGod(taskid)
{
    new id = taskid - TASK_GOD;
    if(is_user_connected(id)) set_entvar(id, var_takedamage, DAMAGE_AIM);
}
public TaskRemoveInvis(taskid)
{
    new id = taskid - TASK_INVIS;
    if(is_user_connected(id)) set_entvar(id, var_effects, get_entvar(id, var_effects) & ~EF_NODRAW);
}

// ============================================================
// 4) CEPHANE MENUSU
// ============================================================

ShowAmmoMenu(id)
{
    new menu = FC_MenuCreate("\wCephane Menusu", "H_Ammo");
    AddPriceItem(menu, id, "1 Mermili Deagle", "AMMO_DEAGLE_TL", 35, "1");
    AddPriceItem(menu, id, "AK-47", "AMMO_AK47_TL", 70, "2");
    AddPriceItem(menu, id, "M4A1", "AMMO_M4A1_TL", 75, "3");
    AddPriceItem(menu, id, "1 Mermili AWP", "AMMO_AWP_TL", 100, "4");
    AddPriceItem(menu, id, "HE Bomba", "AMMO_HE_TL", 15, "5");
    AddPriceItem(menu, id, "Flash", "AMMO_FLASH_TL", 10, "6");
    FC_MenuSetProp(menu, MPROP_EXITNAME, "Geri");
    menu_display(id, menu);
}

public H_Ammo(id, menu, item)
{
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        ShowStandardMarkets(id);
        return PLUGIN_HANDLED;
    }

    if(!CanUseJBMenu(id, true))
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }

    new info[8], name[64], access, cb;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), cb);
    new key = str_to_num(info);
    menu_destroy(menu);

    if(!is_user_alive(id) || get_member(id, m_iTeam) != TEAM_TERRORIST)
    {
        Chat(id, "Cephane Menusu sadece hayattaki T oyuncular icindir.");
        return PLUGIN_HANDLED;
    }

    new product[64];

    switch(key)
    {
        case 1:
        {
            if(!PayTL(id, CfgInt("AMMO_DEAGLE_TL", 35))) return PLUGIN_HANDLED;
            copy(product, charsmax(product), "1 Mermili Deagle");
            GiveWeaponClip(id, "weapon_deagle", 1);
        }
        case 2:
        {
            if(!PayTL(id, CfgInt("AMMO_AK47_TL", 70))) return PLUGIN_HANDLED;
            copy(product, charsmax(product), "AK-47");
            rg_give_item(id, "weapon_ak47");
        }
        case 3:
        {
            if(!PayTL(id, CfgInt("AMMO_M4A1_TL", 75))) return PLUGIN_HANDLED;
            copy(product, charsmax(product), "M4A1");
            rg_give_item(id, "weapon_m4a1");
        }
        case 4:
        {
            if(!PayTL(id, CfgInt("AMMO_AWP_TL", 100))) return PLUGIN_HANDLED;
            copy(product, charsmax(product), "1 Mermili AWP");
            GiveWeaponClip(id, "weapon_awp", 1);
        }
        case 5:
        {
            if(!PayTL(id, CfgInt("AMMO_HE_TL", 15))) return PLUGIN_HANDLED;
            copy(product, charsmax(product), "HE Bomba");
            rg_give_item(id, "weapon_hegrenade");
        }
        case 6:
        {
            if(!PayTL(id, CfgInt("AMMO_FLASH_TL", 10))) return PLUGIN_HANDLED;
            copy(product, charsmax(product), "Flash");
            rg_give_item(id, "weapon_flashbang");
        }
    }

    PurchaseSuccess(id, product);
    return PLUGIN_HANDLED;
}

GiveWeaponClip(id, const weapon[], clip)
{
    new ent = rg_give_item(id, weapon);
    if(!is_nullent(ent))
        set_member(ent, m_Weapon_iClip, clip);
}

// ============================================================
// 5) ISYANTEAM MENUSU - SADECE UYELER
// ============================================================

ShowIsyanTeamMenu(id)
{
    if(!HasRole(id, ROLE_ISYANTEAM))
    {
        Chat(id, "IsyanTeam uyeligin yok.");
        return;
    }

    new menu = FC_MenuCreate("\wIsyanTeam Menusu", "H_IsyanTeam");
    AddPriceItem(menu, id, "Tum T 100 HP", "ISYAN_ALL_HP100_TL", 100, "1");
    AddPriceItem(menu, id, "Tum T 1 Mermili Deagle", "ISYAN_ALL_DEAGLE1_TL", 140, "2");
    AddPriceItem(menu, id, "Tum T 100 Armor", "ISYAN_ALL_ARMOR100_TL", 120, "3");
    AddPriceItem(menu, id, "Tum T HE Bomba", "ISYAN_ALL_HE_TL", 90, "4");
    AddPriceItem(menu, id, "Tum T Flash", "ISYAN_ALL_FLASH_TL", 70, "5");
    AddPriceItem(menu, id, "Tum T +50 HP", "ISYAN_ALL_ADD50_TL", 80, "6");
    FC_MenuSetProp(menu, MPROP_EXITNAME, "Geri");
    menu_display(id, menu);
}

public H_IsyanTeam(id, menu, item)
{
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        ShowMainMenu(id);
        return PLUGIN_HANDLED;
    }

    if(!CanUseJBMenu(id, true))
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }

    new info[8], name[64], access, cb;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), cb);
    new key = str_to_num(info);
    menu_destroy(menu);

    if(!HasRole(id, ROLE_ISYANTEAM) || !is_user_alive(id))
        return PLUGIN_HANDLED;

    new priceKey[40];
    switch(key)
    {
        case 1: copy(priceKey, charsmax(priceKey), "ISYAN_ALL_HP100_TL");
        case 2: copy(priceKey, charsmax(priceKey), "ISYAN_ALL_DEAGLE1_TL");
        case 3: copy(priceKey, charsmax(priceKey), "ISYAN_ALL_ARMOR100_TL");
        case 4: copy(priceKey, charsmax(priceKey), "ISYAN_ALL_HE_TL");
        case 5: copy(priceKey, charsmax(priceKey), "ISYAN_ALL_FLASH_TL");
        case 6: copy(priceKey, charsmax(priceKey), "ISYAN_ALL_ADD50_TL");
    }

    if(!PayTL(id, CfgInt(priceKey, 100)))
        return PLUGIN_HANDLED;

    for(new p = 1; p <= MaxClients; p++)
    {
        if(!is_user_alive(p) || get_member(p, m_iTeam) != TEAM_TERRORIST || HW_Player(p))
            continue;

        switch(key)
        {
            case 1: set_entvar(p, var_health, 100.0);
            case 2: GiveWeaponClip(p, "weapon_deagle", 1);
            case 3: set_entvar(p, var_armorvalue, 100.0);
            case 4: rg_give_item(p, "weapon_hegrenade");
            case 5: rg_give_item(p, "weapon_flashbang");
            case 6:
            {
                new Float:hp;
                get_entvar(p, var_health, hp);
                set_entvar(p, var_health, hp + 50.0);
            }
        }
    }

    new product[64];
    switch(key)
    {
        case 1: copy(product, charsmax(product), "Tum T 100 HP");
        case 2: copy(product, charsmax(product), "Tum T 1 Mermili Deagle");
        case 3: copy(product, charsmax(product), "Tum T 100 Armor");
        case 4: copy(product, charsmax(product), "Tum T HE Bomba");
        case 5: copy(product, charsmax(product), "Tum T Flash");
        case 6: copy(product, charsmax(product), "Tum T +50 HP");
    }

    PurchaseSuccess(id, product);
    Chat(0, "^4%n ^1IsyanTeam menusunden tum T takimina destek aldi.", id);
    return PLUGIN_HANDLED;
}

// ============================================================
// KOZMETIK MENUSU - COIN MARKET / PRIME MARKET / ENVANTER
// ============================================================

ShowCosmeticHub(id)
{
    if(!CanUseCosmeticMenu(id, true))
        return;

    new menu = FC_MenuCreate("\wKozmetik Menusu", "H_CosmeticHub");
    FC_MenuAddItem(menu, "\rCoin Market", "1");

    if(HasPrimeMarketAccess(id))
        FC_MenuAddItem(menu, "\yPrime Market", "2");
    else
        FC_MenuAddItem(menu, "\dPrime Market", "2");

    FC_MenuAddItem(menu, "\wKozmetik Envanterim", "3");
    FC_MenuAddItem(menu, "\wChat Tagim", "4");
    FC_MenuAddItem(menu, "\wSkin İnceleme \y[3 sn]", "5");
    FC_MenuSetProp(menu, MPROP_EXITNAME, "Geri");
    menu_display(id, menu);
}

public H_CosmeticHub(id, menu, item)
{
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        ShowMainMenu(id);
        return PLUGIN_HANDLED;
    }

    if(!CanUseJBMenu(id, true) || !CanUseCosmeticMenu(id, true))
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }

    new info[8], name[64], access, cb;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), cb);
    new key = str_to_num(info);
    menu_destroy(menu);

    switch(key)
    {
        case 1: ShowCoinMarket(id);
        case 2:
        {
            if(HasPrimeMarketAccess(id)) ShowPrimeMenu(id);
            else Chat(id, "Prime Market sadece ^4Prime ^1ve ^4Yonetici ^1hesaplara ozeldir.");
        }
        case 3: ShowInventoryMenu(id);
        case 4: ShowChatTagMenu(id);
        case 5: ShowPreviewMenu(id);
    }
    return PLUGIN_HANDLED;
}


// ============================================================
// CHAT / MENU UYELIK ETIKETI SECIMI
// ============================================================

ShowChatTagMenu(id)
{
    if(g_iUID[id] <= 0)
    {
        ShowAccountMenu(id);
        return;
    }

    ValidateDisplayTagMode(id);

    new current[24], title[160], menu, line[128];
    GetRoleName(id, current, charsmax(current));
    formatex(title, charsmax(title), "\wChat Tagim^n\dGorunen Uyelik: \y%s", current);
    menu = FC_MenuCreate(title, "H_ChatTagMenu");

    if(HasRole(id, ROLE_ISYANTEAM))
    {
        formatex(line, charsmax(line), "\wIsyanTeam Uyeligini Kullan %s",
            g_iDisplayTagMode[id] == TAGMODE_ISYANTEAM ? "\r[AKTIF]" : "\d[KAPALI]");
        FC_MenuAddItem(menu, line, "1");
    }

    if(HasRole(id, ROLE_PRIME))
    {
        formatex(line, charsmax(line), "\wPrime Uyeligini Kullan %s",
            g_iDisplayTagMode[id] == TAGMODE_PRIME ? "\r[AKTIF]" : "\d[KAPALI]");
        FC_MenuAddItem(menu, line, "2");
    }

    if(HasRole(id, ROLE_PRIME) && HasRole(id, ROLE_ISYANTEAM))
    {
        formatex(line, charsmax(line), "\wMulti Uyelik Kullan %s",
            g_iDisplayTagMode[id] == TAGMODE_MULTI ? "\r[AKTIF]" : "\d[KAPALI]");
        FC_MenuAddItem(menu, line, "3");
    }

    if(HasRole(id, ROLE_MANAGER))
    {
        formatex(line, charsmax(line), "\wYonetici Uyeligini Kullan %s",
            g_iDisplayTagMode[id] == TAGMODE_MANAGER ? "\r[AKTIF]" : "\d[KAPALI]");
        FC_MenuAddItem(menu, line, "4");
    }

    formatex(line, charsmax(line), "\wOtomatik Uyelik Etiketi %s",
        g_iDisplayTagMode[id] == TAGMODE_AUTO ? "\r[AKTIF]" : "\d[KAPALI]");
    FC_MenuAddItem(menu, line, "5");

    formatex(line, charsmax(line), "\wRank Etiketini Kullan %s",
        g_bRankTagEnabled[id] ? "\r[AKTIF]" : "\d[KAPALI]");
    FC_MenuAddItem(menu, line, "7");

    new clanName[64], clanLevel = GetClanInfoFromPlugin(id, clanName, charsmax(clanName));
    if(clanLevel > 0 && clanName[0])
    {
        formatex(line, charsmax(line), "\wKlan Etiketini Kullan %s",
            g_bClanTagEnabled[id] ? "\r[AKTIF]" : "\d[KAPALI]");
        FC_MenuAddItem(menu, line, "6");
    }
    else FC_MenuAddItem(menu, "\dKlan Etiketi [Klanin yok]", "6");

    FC_MenuSetProp(menu, MPROP_EXITNAME, "Geri");
    menu_display(id, menu);
}

public H_ChatTagMenu(id, menu, item)
{
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        ShowCosmeticHub(id);
        return PLUGIN_HANDLED;
    }

    if(!CanUseJBMenu(id, true))
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }

    new info[8], name[64], access, cb;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), cb);
    new choice = str_to_num(info);
    menu_destroy(menu);

    new mode = TAGMODE_AUTO;
    switch(choice)
    {
        case 1: mode = TAGMODE_ISYANTEAM;
        case 2: mode = TAGMODE_PRIME;
        case 3: mode = TAGMODE_MULTI;
        case 4: mode = TAGMODE_MANAGER;
        case 5: mode = TAGMODE_AUTO;
        case 6:
        {
            new clanName[64], clanLevel = GetClanInfoFromPlugin(id, clanName, charsmax(clanName));
            if(clanLevel <= 0 || !clanName[0])
                Chat(id, "Klan etiketini kullanmak icin bir klana uye olmalisin.");
            else
            {
                g_bClanTagEnabled[id] = !g_bClanTagEnabled[id];
                SavePlayer(id);
                Chat(id, "Klan etiketi: ^4%s", g_bClanTagEnabled[id] ? "Aktif" : "Kapali");
            }
            ShowChatTagMenu(id);
            return PLUGIN_HANDLED;
        }
        case 7:
        {
            g_bRankTagEnabled[id] = !g_bRankTagEnabled[id];
            SavePlayer(id);
            Chat(id, "Rank etiketi: ^4%s", g_bRankTagEnabled[id] ? "Aktif" : "Gizli");
            ShowChatTagMenu(id);
            return PLUGIN_HANDLED;
        }
        default: return PLUGIN_HANDLED;
    }

    if(mode != TAGMODE_AUTO && !CanDisplayTagMode(id, mode))
    {
        Chat(id, "Bu uyelik etiketini kullanma yetkin yok.");
        return PLUGIN_HANDLED;
    }

    // Ayni ozel etikete tekrar basilirsa manuel secim kapanir ve otomatik moda doner.
    if(mode != TAGMODE_AUTO && g_iDisplayTagMode[id] == mode)
        g_iDisplayTagMode[id] = TAGMODE_AUTO;
    else
        g_iDisplayTagMode[id] = mode;

    SavePlayer(id);

    new shown[24];
    GetRoleName(id, shown, charsmax(shown));
    Chat(id, "Chat/menu uyelik etiketin ^4%s ^1olarak ayarlandi.", shown);
    ShowChatTagMenu(id);
    return PLUGIN_HANDLED;
}

// ============================================================
// 6) PRIME MENUSU - COIN ILE SATIN AL / KIRALA, SADECE PRIME
// ============================================================

ShowPrimeMenu(id)
{
    if(!CanUseCosmeticMenu(id, true))
        return;

    if(!HasPrimeMarketAccess(id))
    {
        Chat(id, "Prime Market icin Prime veya Yonetici hesabi gerekli.");
        return;
    }

    new menu = FC_MenuCreate("\wPrime Market", "H_PrimeMenu");
    FC_MenuAddItem(menu, "\wBicak Skinleri", "0");
    FC_MenuAddItem(menu, "\wKarakter Modelleri", "1");
    if(HasConfiguredPet(SOURCE_PRIME_MENU)) FC_MenuAddItem(menu, "\wPetler", "2");
    if(HasConfiguredWing(SOURCE_PRIME_MENU))
        FC_MenuAddItem(menu, "\wKanatlar", "3");
    FC_MenuAddItem(menu, "\wOldurme Efektleri", "4");
    FC_MenuAddItem(menu, "\wTrail", "6");
    FC_MenuSetProp(menu, MPROP_EXITNAME, "Geri");
    menu_display(id, menu);
}

public H_PrimeMenu(id, menu, item)
{
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        ShowCosmeticHub(id);
        return PLUGIN_HANDLED;
    }

    if(!CanUseJBMenu(id, true) || !CanUseCosmeticMenu(id, true))
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }

    new info[8], name[64], access, cb;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), cb);
    new kind = str_to_num(info);
    menu_destroy(menu);

    if(!HasPrimeMarketAccess(id))
        return PLUGIN_HANDLED;

    ShowCosmeticList(id, SOURCE_PRIME_MENU, kind);
    return PLUGIN_HANDLED;
}

// ============================================================
// 7) COIN MARKET - SADECE NORMAL COIN URUNLERI
// ============================================================

ShowCoinMarket(id)
{
    if(!CanUseCosmeticMenu(id, true))
        return;

    new menu = FC_MenuCreate("\wCoin Market", "H_CoinCategory");
    FC_MenuAddItem(menu, "\wBicak Market", "0");
    FC_MenuAddItem(menu, "\wKarakter Model Market", "1");
    if(HasConfiguredPet(SOURCE_COIN_NORMAL)) FC_MenuAddItem(menu, "\wPet Market", "2");
    if(HasConfiguredWing(SOURCE_COIN_NORMAL))
        FC_MenuAddItem(menu, "\wKanat Market", "3");
    FC_MenuAddItem(menu, "\wOldurme Efekti Market", "4");
    FC_MenuAddItem(menu, "\wTrail Market", "6");
    FC_MenuSetProp(menu, MPROP_EXITNAME, "Geri");
    menu_display(id, menu);
}

public H_CoinCategory(id, menu, item)
{
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        ShowCosmeticHub(id);
        return PLUGIN_HANDLED;
    }

    if(!CanUseJBMenu(id, true) || !CanUseCosmeticMenu(id, true))
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }

    new info[8], name[64], access, cb;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), cb);
    new kind = str_to_num(info);
    menu_destroy(menu);

    // Coin Market artik yalnizca normal Coin urunlerini gosterir.
    // Prime urunleri ayri Prime Market'tedir.
    ShowCosmeticList(id, SOURCE_COIN_NORMAL, kind);
    return PLUGIN_HANDLED;
}

// ============================================================
// KOZMETIK LIST / KIRALAMA
// ============================================================

ShowCosmeticList(id, source, kind)
{
    if(!CanUseCosmeticMenu(id, true))
        return;
    if(!IsCosmeticKindEnabled(kind))
        return;
    if(source == SOURCE_PRIME_MENU && !HasPrimeMarketAccess(id))
        return;

    CleanupExpired(id);
    new title[128];
    formatex(title, charsmax(title), "\w%s", CosKindName(kind));
    new menu = FC_MenuCreate(title, "H_CosList");
    new itemName[64], line[192], info[16], added;

    for(new i; i < COS_ITEM_COUNT; i++)
    {
        if(!IsCosmeticEnabled(i) || g_CosSource[i] != source || g_CosKind[i] != kind)
            continue;

        CosCfgStr(i, "NAME", itemName, charsmax(itemName), g_CosPrefix[i]);
        num_to_str(i, info, charsmax(info));
        if(OwnsCosmetic(id, i))
        {
            if(g_iCosExpiry[id][i] == 0)
                formatex(line, charsmax(line), "\d%s \w[\rEnvanterinde\w]", itemName);
            else
            {
                new remaining[32];
                FormatCosmeticRentalTime(g_iCosExpiry[id][i], remaining, charsmax(remaining));
                formatex(line, charsmax(line), "\d%s \w[\yKiralık %s\w]", itemName, remaining);
            }
        }
        else
            formatex(line, charsmax(line), "\w%s", itemName);

        FC_MenuAddItemCB(menu, line, info, g_iMarketCosCallback);
        added++;
    }
    if(!added)
        FC_MenuAddItemCB(menu, "\dBu bolumde sabit slot bulunamadi.", "-1", g_iMarketCosCallback);

    FC_MenuSetProp(menu, MPROP_EXITNAME, "Geri");
    g_iRentalMenu[id]=menu;g_iRentalMinute[id]=LeaseNow()/60;g_bRentalOwned[id]=false;
    menu_display(id, menu);
}

public CB_MarketCosmetic(id, menu, item)
{
    new info[16], name[64], access, cb;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), cb);
    new idx = str_to_num(info);
    if(!IsCosmeticEnabled(idx) || !CanUseCosmeticMenu(id, false) || !CanUseJBMenu(id, false))
        return ITEM_DISABLED;
    if(g_CosSource[idx] == SOURCE_PRIME_MENU && !HasPrimeMarketAccess(id))
        return ITEM_DISABLED;
    return OwnsCosmetic(id, idx) ? ITEM_DISABLED : ITEM_ENABLED;
}

// Hem kalici satin alim hem aktif kiralama markette yeniden secimi engeller.
bool:MarketCosmeticAlreadyOwned(id, idx)
{
    if(!OwnsCosmetic(id, idx))
        return false;
    g_iPendingCos[id] = -1;
    if(g_iCosExpiry[id][idx] == 0)
        Chat(id, "Bu urun ^4envanterinde^1. Takmak/cikarmak icin kozmetik envanterini kullan.");
    else
    {
        new remaining[32];
        FormatCosmeticRentalTime(g_iCosExpiry[id][idx], remaining, charsmax(remaining));
        Chat(id, "Bu urunu ^4kiraladin^1. Kalan sure: ^4%s^1. Kozmetik envanterinden takabilir/cikarabilirsin.", remaining);
    }
    ShowCosmeticList(id, g_CosSource[idx], g_CosKind[idx]);
    return true;
}

public H_CosList(id, menu, item)
{
    if(g_bRentalRefresh[id]) return PLUGIN_HANDLED;
    g_iRentalMenu[id]=-1;
    if(!CanUseJBMenu(id, true) || !CanUseCosmeticMenu(id, true))
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }

    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        ShowMainMenu(id);
        return PLUGIN_HANDLED;
    }

    new info[16], name[64], access, cb;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), cb);
    new idx = str_to_num(info);
    menu_destroy(menu);

    if(!IsCosmeticEnabled(idx))
        return PLUGIN_HANDLED;

    if(g_CosSource[idx] == SOURCE_PRIME_MENU && !HasPrimeMarketAccess(id))
    {
        Chat(id, "Bu urun Prime ve Yonetici hesaplara ozeldir.");
        return PLUGIN_HANDLED;
    }

    if(MarketCosmeticAlreadyOwned(id, idx))
        return PLUGIN_HANDLED;

    g_iPendingCos[id] = idx;
    ShowCosmeticAction(id);
    return PLUGIN_HANDLED;
}

ShowCosmeticAction(id)
{
    if(!CanUseCosmeticMenu(id, true))
        return;

    new idx = g_iPendingCos[id];
    if(!IsCosmeticEnabled(idx))
        return;
    if(g_CosSource[idx] == SOURCE_PRIME_MENU && !HasPrimeMarketAccess(id))
        return;
    if(MarketCosmeticAlreadyOwned(id, idx))
        return;

    new itemName[64], title[160], line[128];
    CosCfgStr(idx, "NAME", itemName, charsmax(itemName), g_CosPrefix[idx]);

    formatex(title, charsmax(title), "\w%s", itemName);
    new menu = FC_MenuCreate(title, "H_CosAction");

    formatex(line, charsmax(line), "\ySatin Al \r- %d Coin",
        CalcPrice(id, CosBasePrice(idx)));
    FC_MenuAddItem(menu, line, "1");

    FC_MenuAddItem(menu, "\wKirala", "2");

    FC_MenuSetProp(menu, MPROP_EXITNAME, "Geri");
    menu_display(id, menu);
}

public H_CosAction(id, menu, item)
{
    if(!CanUseJBMenu(id, true) || !CanUseCosmeticMenu(id, true))
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }

    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        new pending = g_iPendingCos[id];
        if(IsCosmeticEnabled(pending))
            ShowCosmeticList(id, g_CosSource[pending], g_CosKind[pending]);
        else
            ShowCosmeticHub(id);
        return PLUGIN_HANDLED;
    }

    new info[8], name[64], access, cb;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), cb);
    new action = str_to_num(info);
    menu_destroy(menu);

    new idx = g_iPendingCos[id];
    if(!IsCosmeticEnabled(idx))
        return PLUGIN_HANDLED;
    if(MarketCosmeticAlreadyOwned(id, idx))
        return PLUGIN_HANDLED;

    if((g_CosSource[idx] == SOURCE_PRIME_MENU) && !HasPrimeMarketAccess(id))
    {
        Chat(id, "Bu urun Prime ve Yonetici hesaplara ozeldir.");
        return PLUGIN_HANDLED;
    }

    if(action == 1)
    {
        new price = CalcPrice(id, CosBasePrice(idx));

        if(g_iCoin[id] < price)
        {
            Chat(id, "Yeterli Coin yok. Gereken: ^4%d Coin", price);
            PlayFailSound(id);
            return PLUGIN_HANDLED;
        }

        FC_CoinChange(id,-price);
        SetExpiry(g_iCosExpiry[id][idx], 0);
        g_iSelectedCos[id][g_CosKind[idx]] = idx;
        SavePlayer(id);
        ApplyCosmetics(id);

        new itemName[64];
        CosCfgStr(idx, "NAME", itemName, charsmax(itemName), g_CosPrefix[idx]);
        PurchaseSuccess(id, itemName);
        g_iPendingCos[id] = -1;
        ShowCosmeticList(id, g_CosSource[idx], g_CosKind[idx]);
        return PLUGIN_HANDLED;
    }

    if(action == 2) ShowRentDuration(id);
    return PLUGIN_HANDLED;
}

ShowRentDuration(id)
{
    if(!CanUseCosmeticMenu(id, true))
        return;

    new idx = g_iPendingCos[id];
    if(!IsCosmeticEnabled(idx))
        return;
    if(g_CosSource[idx] == SOURCE_PRIME_MENU && !HasPrimeMarketAccess(id))
        return;
    if(MarketCosmeticAlreadyOwned(id, idx))
        return;

    new name[64], title[128], line[128];
    CosCfgStr(idx, "NAME", name, charsmax(name), g_CosPrefix[idx]);
    formatex(title, charsmax(title), "\w%s - Kirala", name);

    new menu = FC_MenuCreate(title, "H_RentDuration");
    new base = CosBasePrice(idx);

    formatex(line, charsmax(line), "\w1 Gun \r- %d Coin",
        CalcRentPrice(id, base, CfgInt("RENT_1D_X100",15)));
    FC_MenuAddItem(menu, line, "1");

    formatex(line, charsmax(line), "\w7 Gun \r- %d Coin",
        CalcRentPrice(id, base, CfgInt("RENT_7D_X100",40)));
    FC_MenuAddItem(menu, line, "7");

    formatex(line, charsmax(line), "\w1 Ay \r- %d Coin",
        CalcRentPrice(id, base, CfgInt("RENT_30D_X100",70)));
    FC_MenuAddItem(menu, line, "30");

    FC_MenuSetProp(menu, MPROP_EXITNAME, "Geri");
    menu_display(id, menu);
}

public H_RentDuration(id, menu, item)
{
    if(!CanUseJBMenu(id, true) || !CanUseCosmeticMenu(id, true))
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }

    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        ShowCosmeticAction(id);
        return PLUGIN_HANDLED;
    }

    new info[8], name[64], access, cb;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), cb);
    new days = str_to_num(info);
    menu_destroy(menu);

    new idx = g_iPendingCos[id];
    if(!IsCosmeticEnabled(idx))
        return PLUGIN_HANDLED;
    if(MarketCosmeticAlreadyOwned(id, idx))
        return PLUGIN_HANDLED;

    if(g_CosSource[idx] == SOURCE_PRIME_MENU && !HasPrimeMarketAccess(id))
        return PLUGIN_HANDLED;

    new mult;
    switch(days)
    {
        case 1: mult = CfgInt("RENT_1D_X100",15);
        case 7: mult = CfgInt("RENT_7D_X100",40);
        case 30: mult = CfgInt("RENT_30D_X100",70);
        default: return PLUGIN_HANDLED;
    }

    new price = CalcRentPrice(id, CosBasePrice(idx), mult);

    if(g_iCoin[id] < price)
    {
        Chat(id, "Yeterli Coin yok. Gereken: ^4%d Coin", price);
        PlayFailSound(id);
        return PLUGIN_HANDLED;
    }

    FC_CoinChange(id,-price);
    SetExpiry(g_iCosExpiry[id][idx], days);
    g_iSelectedCos[id][g_CosKind[idx]] = idx;
    SavePlayer(id);
    ApplyCosmetics(id);

    new itemName[64];
    CosCfgStr(idx, "NAME", itemName, charsmax(itemName), g_CosPrefix[idx]);
    RentSuccess(id, itemName, days);
    g_iPendingCos[id] = -1;
    ShowCosmeticList(id, g_CosSource[idx], g_CosKind[idx]);

    return PLUGIN_HANDLED;
}


// ============================================================
// KOZMETIK ENVANTERI
// ============================================================

ShowInventoryMenu(id)
{
    if(!CanUseCosmeticMenu(id, true))
        return;

    new menu = FC_MenuCreate("\wKozmetik Envanterim", "H_InventoryMenu");
    FC_MenuAddItem(menu, "\wBicak Skinlerim", "0");
    FC_MenuAddItem(menu, "\wKarakter Modellerim", "1");
    if(HasConfiguredPet()) FC_MenuAddItem(menu, "\wPetlerim", "2");
    if(HasConfiguredWing())
        FC_MenuAddItem(menu, "\wKanatlarim", "3");
    FC_MenuAddItem(menu, "\wOldurme Efektlerim", "4");
    FC_MenuAddItem(menu, "\wTraillerim", "6");
    FC_MenuSetProp(menu, MPROP_EXITNAME, "Geri");
    menu_display(id, menu);
}

public H_InventoryMenu(id, menu, item)
{
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        ShowCosmeticHub(id);
        return PLUGIN_HANDLED;
    }

    if(!CanUseJBMenu(id, true) || !CanUseCosmeticMenu(id, true))
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }

    new info[8], name[64], access, cb;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), cb);
    new kind = str_to_num(info);
    menu_destroy(menu);

    ShowOwnedCosmetics(id, kind);
    return PLUGIN_HANDLED;
}

ShowOwnedCosmetics(id, kind)
{
    if(!CanUseCosmeticMenu(id, true))
        return;

    if(!IsCosmeticKindEnabled(kind))
        return;

    CleanupExpired(id);

    new title[96];
    formatex(title, charsmax(title), "\w%s Envanteri", CosKindName(kind));
    new menu = FC_MenuCreate(title, "H_OwnedCosmetics");

    new info[16], itemName[64], line[160], added;
    for(new i; i < COS_ITEM_COUNT; i++)
    {
        if(g_CosKind[i] != kind || !OwnsCosmetic(id, i))
            continue;

        CosCfgStr(i, "NAME", itemName, charsmax(itemName), g_CosPrefix[i]);
        num_to_str(i, info, charsmax(info));

        new bool:active = (g_iSelectedCos[id][kind] == i);
        if(g_iCosExpiry[id][i] > 0)
        {
            new remaining[32];
            FormatCosmeticRentalTime(g_iCosExpiry[id][i], remaining, charsmax(remaining));
            formatex(line, charsmax(line), "%s%s \w[\y%s %s\w]", active ? "\r" : "\w", itemName,
                active ? "Aktif" : "Kiralık", remaining);
        }
        else if(active)
            formatex(line, charsmax(line), "\r%s \w[\rAktif\w]", itemName);
        else
            formatex(line, charsmax(line), "\w%s", itemName);

        FC_MenuAddItem(menu, line, info);
        added++;
    }

    if(!added)
        FC_MenuAddItem(menu, "\dBu kategoride urunun yok.", "-1");

    FC_MenuSetProp(menu, MPROP_EXITNAME, "Geri");
    g_iRentalMenu[id]=menu;g_iRentalMinute[id]=LeaseNow()/60;g_bRentalOwned[id]=true;
    menu_display(id, menu);
}

public H_OwnedCosmetics(id, menu, item)
{
    if(g_bRentalRefresh[id]) return PLUGIN_HANDLED;
    g_iRentalMenu[id]=-1;
    if(!CanUseJBMenu(id, true) || !CanUseCosmeticMenu(id, true))
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }

    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        ShowInventoryMenu(id);
        return PLUGIN_HANDLED;
    }

    new info[16], name[64], access, cb;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), cb);
    new idx = str_to_num(info);
    menu_destroy(menu);

    if(idx < 0 || idx >= COS_ITEM_COUNT || !OwnsCosmetic(id, idx))
        return PLUGIN_HANDLED;

    new kind = g_CosKind[idx];
    g_iSelectedCos[id][kind] = (g_iSelectedCos[id][kind] == idx) ? -1 : idx;
    SavePlayer(id);
    ApplyCosmetics(id);
    PlayEquipSound(id);

    Chat(id, "Kozmetik secimin guncellendi.");
    ShowOwnedCosmetics(id, kind);
    return PLUGIN_HANDLED;
}


// ============================================================
// 5) MESLEK SISTEMI - ROUND BOYUNCA 1 SECIM
// ============================================================

ShowProfessionMenu(id)
{
    if(get_member(id, m_iTeam) != TEAM_TERRORIST)
    {
        Chat(id, "Meslek sistemi sadece T oyuncular icindir.");
        return;
    }

    new title[160];
    formatex(title, charsmax(title), "\wMeslek Sistemi^n\dAktif: \y%s %s",
        g_ProfessionNames[g_iProfession[id]], g_bProfessionChosenRound[id] ? "\d[\rBU ROUND SECILDI\d]" : "");

    new menu = FC_MenuCreate(title, "H_Profession");
    FC_MenuAddItem(menu,"\wDöviz Bürosu \d- Harcanan her 10 TL için +1 Coin","7");
    new line[160];

    formatex(line, charsmax(line), "\wPunisher \d- Her CT kill +%d TL", CfgInt("PROF_PUNISHER_KILL_TL",2));
    FC_MenuAddItem(menu, line, "1");

    FC_MenuAddItem(menu, "\wBombaci \d- Her dogusta rastgele bomba", "2");

    formatex(line, charsmax(line), "\wTerminator \d- %d HP / %d Armor",
        CfgInt("PROF_TERMINATOR_HP",150), CfgInt("PROF_TERMINATOR_ARMOR",100));
    FC_MenuAddItem(menu, line, "3");

    formatex(line, charsmax(line), "\wSansli Adam \d- 1/%d tekrar dogma sansi",
        CfgInt("PROF_LUCKY_CHANCE",5));
    FC_MenuAddItem(menu, line, "4");

    formatex(line, charsmax(line), "\wEv Hanimi \d- %d dk'da +%d TL",
        CfgInt("PROF_HOUSEWIFE_MINUTES",3), CfgInt("PROF_HOUSEWIFE_TL",4));
    FC_MenuAddItem(menu, line, "5");

    formatex(line, charsmax(line), "\wHP Hirsizi \d- %d sn'de +%d HP",
        CfgInt("PROF_HPTHIEF_SECONDS",8), CfgInt("PROF_HPTHIEF_HP",5));
    FC_MenuAddItem(menu, line, "6");

    if(HasRole(id, ROLE_PRIME))
    {
        formatex(line, charsmax(line), "\wSoyguncu \d- %d sn icinde +%d TL cal",
            clamp(CfgInt("PROF_ROBBERY_SECONDS",5),1,15), clamp(CfgInt("PROF_ROBBERY_TL",5),1,1000));
        FC_MenuAddItem(menu, line, "8");

        formatex(line, charsmax(line), "\wZhonya \y[Prime] \w[E] \d- %d sn koruma / %d sn bekleme",
            clamp(CfgInt("PROF_ZHONYA_SECONDS",5),1,15), clamp(CfgInt("PROF_ZHONYA_COOLDOWN",30),1,180));
        FC_MenuAddItem(menu, line, "9");
    }

    FC_MenuSetProp(menu, MPROP_EXITNAME, "Geri");
    menu_display(id, menu);
}

public H_Profession(id, menu, item)
{
    if(!CanUseJBMenu(id, true))
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }

    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        ShowMainMenu(id);
        return PLUGIN_HANDLED;
    }

    if(g_bProfessionChosenRound[id])
    {
        menu_destroy(menu);
        Chat(id, "Her round sadece ^4 1 kez ^1meslek secebilirsin.");
        return PLUGIN_HANDLED;
    }

    new info[8], name[64], access, cb;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), cb);
    new prof = str_to_num(info);
    menu_destroy(menu);

    if(prof <= PROF_NONE || prof >= PROF_COUNT)
        return PLUGIN_HANDLED;

    if((prof == PROF_ROBBER || prof == PROF_ZHONYA) && !HasRole(id, ROLE_PRIME))
    {
        Chat(id, "Soyguncu ve Zhonya meslekleri sadece ^4Prime ^1uyelerine ozeldir.");
        return PLUGIN_HANDLED;
    }

    g_iProfession[id] = prof;
    g_bProfessionChosenRound[id] = true;
    g_iLastProfessionTick[id] = get_systime();
    SavePlayer(id);
    ApplyProfessionSpawn(id);
    Chat(id, "Meslegin ^4%s ^1olarak secildi.", g_ProfessionNames[prof]);
    return PLUGIN_HANDLED;
}

ApplyProfessionSpawn(id)
{
    if(HW_Player(id)) return;
    if(!is_user_alive(id) || get_member(id, m_iTeam) != TEAM_TERRORIST)
        return;

    if(g_iProfession[id]<=PROF_NONE || g_iProfessionApplied[id]==g_iProfession[id]) return;
    g_iProfessionApplied[id]=g_iProfession[id];
    g_iLastProfessionTick[id]=get_systime();
    switch(g_iProfession[id])
    {
        case PROF_BOMBACI:
        {
            if(random_num(0,1)) rg_give_item(id, "weapon_hegrenade");
            else rg_give_item(id, "weapon_flashbang");
        }
        case PROF_TERMINATOR:
        {
            set_entvar(id, var_health, float(CfgInt("PROF_TERMINATOR_HP",150)));
            set_entvar(id, var_armorvalue, float(CfgInt("PROF_TERMINATOR_ARMOR",100)));
        }
    }
}


// ============================================================
// PRIME MESLEKLERI: SOYGUNCU + ZHONYA
// ============================================================

bool:IsPrimeProfession(id, profession)
{
    return id >= 1 && id <= MaxClients
        && is_user_connected(id)
        && HasRole(id, ROLE_PRIME)
        && g_iProfession[id] == profession;
}

StartProfessionRobbery(id)
{
    if(!IsPrimeProfession(id, PROF_ROBBER) || !is_user_alive(id)
        || get_member(id, m_iTeam) != TEAM_TERRORIST || HW_Player(id))
        return;

    if(g_iRobberyTarget[id] > 0)
    {
        Chat(id, "Zaten bir soygun deniyorsun.");
        return;
    }

    if(g_iRobberyThief[id] > 0)
    {
        Chat(id, "Soyulurken baska bir oyuncuyu soymaya calisamazsin.");
        return;
    }

    new target, body;
    get_user_aiming(id, target, body, clamp(CfgInt("PROF_ROBBERY_RANGE",120),64,256));

    if(target < 1 || target > MaxClients || target == id
        || !is_user_alive(target)
        || get_member(target, m_iTeam) != TEAM_TERRORIST)
    {
        Chat(id, "Soymak icin yakinindaki bir takim arkadasina nisan alip E tusuna bas.");
        return;
    }

    if(g_iRobberyThief[target] > 0)
    {
        Chat(id, "Bu oyuncu zaten soyulmaya calisiliyor.");
        return;
    }

    g_iRobberyTarget[id] = target;
    g_iRobberyThief[target] = id;
    g_iRobberyOwnerUserid[id] = get_user_userid(id);
    g_iRobberyTargetUserid[id] = get_user_userid(target);
    g_flRobberyStart[id] = get_gametime();
    g_flRobberyDuration[id] = float(clamp(CfgInt("PROF_ROBBERY_SECONDS",5),1,15));
    get_entvar(target, var_origin, g_vecRobberyStartOrigin[id]);

    remove_task(id + TASK_PROF_ROBBERY);
    set_task(0.1, "TaskProfessionRobbery", id + TASK_PROF_ROBBERY, _, _, "b");
    Chat(id, "^4%n ^1adli takim arkadasini soymaya basladin. Hareket ederse iptal olur.", target);
}

public TaskProfessionRobbery(taskid)
{
    new id = taskid - TASK_PROF_ROBBERY;
    if(id < 1 || id > MaxClients)
        return;

    new target = g_iRobberyTarget[id];
    if(target < 1 || target > MaxClients
        || !is_user_alive(id) || !is_user_alive(target)
        || get_user_userid(id) != g_iRobberyOwnerUserid[id]
        || get_user_userid(target) != g_iRobberyTargetUserid[id]
        || !IsPrimeProfession(id, PROF_ROBBER)
        || get_member(id, m_iTeam) != TEAM_TERRORIST
        || get_member(target, m_iTeam) != TEAM_TERRORIST
        || HW_Player(id) || HW_Player(target))
    {
        CancelProfessionRobbery(id, false);
        return;
    }

    new Float:targetOrigin[3], Float:thiefOrigin[3];
    get_entvar(target, var_origin, targetOrigin);
    get_entvar(id, var_origin, thiefOrigin);

    new Float:moveLimit = float(clamp(CfgInt("PROF_ROBBERY_MOVE_TOLERANCE",8),2,64));
    if(get_distance_f(targetOrigin, g_vecRobberyStartOrigin[id]) > moveLimit)
    {
        CancelProfessionRobbery(id, true);
        return;
    }

    new Float:range = float(clamp(CfgInt("PROF_ROBBERY_RANGE",120),64,256));
    if(get_distance_f(thiefOrigin, targetOrigin) > range + 32.0)
    {
        CancelProfessionRobbery(id, true);
        return;
    }

    new Float:elapsed = get_gametime() - g_flRobberyStart[id];
    new Float:duration = g_flRobberyDuration[id];
    if(duration < 0.1) duration = 0.1;
    new Float:remaining = duration - elapsed;

    if(elapsed >= duration)
    {
        new amount = clamp(CfgInt("PROF_ROBBERY_TL",5),1,1000);
        StopProfessionRobbery(id);

        if(g_iTL[target] < amount)
        {
            Chat(id, "^4%n ^1adli oyuncunun soyulabilecek kadar TL'si yok.", target);
            Chat(target, "Soygun basarisiz oldu; yeterli TL'n yoktu.");
            return;
        }

        g_iTL[target] -= amount;
        g_iTL[id] = FC_CountAdd(g_iTL[id], amount);
        SavePlayer(target);
        SavePlayer(id);

        Chat(id, "Soygun basarili! ^3+%d TL ^1kazandin.", amount);
        Chat(target, "^4%n ^1senden ^3%d TL ^1caldi!", id, amount);
        return;
    }

    new filled = clamp(floatround((elapsed / duration) * 20.0, floatround_floor),0,20);
    new bar[24];
    for(new i; i < 20; i++)
        bar[i] = i < filled ? '|' : '-';
    bar[20] = 0;

    new tenths = max(0, floatround(remaining * 10.0, floatround_floor));
    new count = max(1, floatround(remaining, floatround_ceil));

    set_hudmessage(255, 205, 30, -1.0, 0.43, 0, 0.0, 0.14, 0.0, 0.0, 3);
    ShowSyncHudMsg(id, g_iProfessionRobberyHudSync, "SOYGUN^n[%s]^n%d.%d sn", bar, tenths / 10, tenths % 10);

    set_hudmessage(255, 35, 35, -1.0, 0.36, 0, 0.0, 0.14, 0.0, 0.0, 4);
    ShowSyncHudMsg(target, g_iProfessionWarningHudSync, "SOYULUYORSUN!^nHAREKET ET!^n%d", count);
}

StopProfessionRobbery(id)
{
    if(id < 1 || id > MaxClients)
        return;

    new target = g_iRobberyTarget[id];
    remove_task(id + TASK_PROF_ROBBERY);
    g_iRobberyTarget[id] = 0;
    g_iRobberyOwnerUserid[id] = 0;
    g_iRobberyTargetUserid[id] = 0;
    g_flRobberyStart[id] = 0.0;
    g_flRobberyDuration[id] = 0.0;

    if(is_user_connected(id))
        ClearSyncHud(id, g_iProfessionRobberyHudSync);

    if(target >= 1 && target <= MaxClients)
    {
        if(g_iRobberyThief[target] == id)
            g_iRobberyThief[target] = 0;
        if(is_user_connected(target))
            ClearSyncHud(target, g_iProfessionWarningHudSync);
    }
}

CancelProfessionRobbery(id, bool:notify = true)
{
    if(id < 1 || id > MaxClients || g_iRobberyTarget[id] <= 0)
        return;

    new target = g_iRobberyTarget[id];
    StopProfessionRobbery(id);

    if(notify)
    {
        if(is_user_connected(id))
            Chat(id, "Soygun iptal edildi; oyunculardan biri hareket etti veya mesafe acildi.");
        if(target >= 1 && target <= MaxClients && is_user_connected(target))
            Chat(target, "Soyulma iptal edildi; oyunculardan biri hareket etti.");
    }
}

CancelProfessionActions(id)
{
    if(id < 1 || id > MaxClients)
        return;

    new thief = g_iRobberyThief[id];
    if(g_iRobberyTarget[id] > 0)
        CancelProfessionRobbery(id, false);
    if(thief >= 1 && thief <= MaxClients && g_iRobberyTarget[thief] == id)
        CancelProfessionRobbery(thief, false);

    EndProfessionZhonya(id, false);
}

StartProfessionZhonya(id)
{
    if(!IsPrimeProfession(id, PROF_ZHONYA) || !is_user_alive(id)
        || get_member(id, m_iTeam) != TEAM_TERRORIST || HW_Player(id))
        return;

    if(g_bProfessionZhonyaActive[id])
        return;

    new Float:now = get_gametime();
    if(now < g_flProfessionZhonyaNextUse[id])
    {
        new wait = max(1, floatround(g_flProfessionZhonyaNextUse[id] - now, floatround_ceil));
        Chat(id, "Zhonya tekrar kullanilabilir: ^3%d sn", wait);
        return;
    }

    new seconds = clamp(CfgInt("PROF_ZHONYA_SECONDS",5),1,15);
    new cooldown = clamp(CfgInt("PROF_ZHONYA_COOLDOWN",30),seconds,180);
    g_flProfessionZhonyaNextUse[id] = now + float(cooldown);
    g_bProfessionZhonyaActive[id] = true;

    new flags = get_entvar(id, var_flags);
    g_bProfessionZhonyaAddedFrozen[id] = !(flags & FL_FROZEN);
    if(g_bProfessionZhonyaAddedFrozen[id])
        set_entvar(id, var_flags, flags | FL_FROZEN);

    g_iProfessionZhonyaOldRenderFx[id] = get_entvar(id, var_renderfx);
    g_iProfessionZhonyaOldRenderMode[id] = get_entvar(id, var_rendermode);
    g_flProfessionZhonyaOldRenderAmt[id] = get_entvar(id, var_renderamt);
    get_entvar(id, var_rendercolor, g_flProfessionZhonyaOldRenderColor[id]);

    new Float:gold[3] = {255.0, 215.0, 0.0};
    rg_set_user_rendering(id, kRenderFxGlowShell, gold, kRenderNormal, 22.0);

    // Zhonya etkinlesince oyuncuya hafif, yari saydam sari ekran efekti.
    message_begin(MSG_ONE, get_user_msgid("ScreenFade"), _, id);
    write_short(1<<8);
    write_short(seconds * (1<<12));
    write_short(4);
    write_byte(255);
    write_byte(225);
    write_byte(80);
    write_byte(85);
    message_end();

    new Float:zero[3] = {0.0, 0.0, 0.0};
    set_entvar(id, var_velocity, zero);
    remove_task(id + TASK_PROF_ZHONYA);
    set_task(float(seconds), "TaskEndProfessionZhonya", id + TASK_PROF_ZHONYA);

    Chat(id, "Zhonya aktif! ^3%d saniye ^1boyunca hareket edemez, hasar veremez ve hasar alamazsin.", seconds);
}

public TaskEndProfessionZhonya(taskid)
{
    EndProfessionZhonya(taskid - TASK_PROF_ZHONYA, true);
}

EndProfessionZhonya(id, bool:notify = false)
{
    if(id < 1 || id > MaxClients)
        return;

    remove_task(id + TASK_PROF_ZHONYA);
    if(!g_bProfessionZhonyaActive[id])
        return;

    g_bProfessionZhonyaActive[id] = false;

    if(is_user_connected(id))
    {
        if(g_bProfessionZhonyaAddedFrozen[id])
        {
            new flags = get_entvar(id, var_flags);
            set_entvar(id, var_flags, flags & ~FL_FROZEN);
        }

        set_entvar(id, var_renderfx, g_iProfessionZhonyaOldRenderFx[id]);
        set_entvar(id, var_rendermode, g_iProfessionZhonyaOldRenderMode[id]);
        set_entvar(id, var_renderamt, g_flProfessionZhonyaOldRenderAmt[id]);
        set_entvar(id, var_rendercolor, g_flProfessionZhonyaOldRenderColor[id]);

        // Zhonya bitince sari ekran efektini temizle.
        message_begin(MSG_ONE, get_user_msgid("ScreenFade"), _, id);
        write_short(1<<10);
        write_short(0);
        write_short(1);
        write_byte(0);
        write_byte(0);
        write_byte(0);
        write_byte(0);
        message_end();

        if(notify && is_user_alive(id))
            Chat(id, "Zhonya etkisi sona erdi.");
    }

    g_bProfessionZhonyaAddedFrozen[id] = false;
}

public TaskLuckyRespawn(taskid)
{
    if(hogwarts_state() != HW_OFF) return;
    new id = taskid - TASK_LUCKY_REVIVE;
    if(!is_user_connected(id) || is_user_alive(id) || get_member(id, m_iTeam) != TEAM_TERRORIST)
        return;

    // Sans zaten olum aninda cekildi. Burada sadece respawn uygula.
    rg_round_respawn(id);
}

// ============================================================
// 6) ODUL / GOREV SISTEMI
// ============================================================

ShowRewardMenu(id)
{
    if(g_iUID[id] <= 0)
    {
        ShowAccountMenu(id);
        return;
    }

    CheckDailyReset(id);
    new menu = FC_MenuCreate("\wOdul & Gorev Merkezi", "H_Reward");

    AddTaskItem(menu, id, 0, "CT Avcisi", g_iDailyKills[id], CfgInt("TASK_KILL_TARGET",5), "1");
    AddTaskItem(menu, id, 1, "Aktif Oyuncu", g_iDailyPlayMinutes[id], CfgInt("TASK_PLAY_TARGET",20), "2");
    AddTaskItem(menu, id, 2, "Kasa Ustasi", g_iDailyCrates[id], CfgInt("TASK_CRATE_TARGET",3), "3");
    AddTaskItem(menu, id, 3, "Alisveris Uzmani", g_iDailyPurchases[id], CfgInt("TASK_BUY_TARGET",3), "4");
    AddTaskItem(menu, id, 4, "Hayatta Kal", g_iDailySurvives[id], CfgInt("TASK_SURVIVE_TARGET",3), "5");

    new done = CountClaimedTasks(id);
    new line[160];
    formatex(line, charsmax(line), "\yTum Gorev Bonusu \d%d/%d %s", done, TASK_COUNT,
        (g_iTaskClaimMask[id] & (1<<TASK_COUNT)) ? "\d[ALINDI]" : (done >= TASK_COUNT ? "\r[HAZIR]" : ""));
    FC_MenuAddItem(menu, line, "6");

    FC_MenuSetProp(menu, MPROP_EXITNAME, "Geri");
    menu_display(id, menu);
}

AddTaskItem(menu, id, bit, const label[], progress, target, const info[])
{
    new line[192];
    new bool:claimed = bool:(g_iTaskClaimMask[id] & (1<<bit));
    formatex(line, charsmax(line), "\w%s \d%d/%d %s", label, min(progress,target), target,
        claimed ? "\d[ALINDI]" : (progress >= target ? "\r[ODUL HAZIR]" : ""));
    FC_MenuAddItem(menu, line, info);
}

public H_Reward(id, menu, item)
{
    if(!CanUseJBMenu(id, true))
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }

    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        ShowMainMenu(id);
        return PLUGIN_HANDLED;
    }

    new info[8], name[64], access, cb;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), cb);
    new task = str_to_num(info)-1;
    menu_destroy(menu);

    if(task == TASK_COUNT)
        ClaimAllTasksBonus(id);
    else
        ClaimTask(id, task);

    ShowRewardMenu(id);
    return PLUGIN_HANDLED;
}

ClaimTask(id, task)
{
    if(task < 0 || task >= TASK_COUNT)
        return;

    if(g_iTaskClaimMask[id] & (1<<task))
    {
        Chat(id, "Bu gorevin odulunu zaten aldin.");
        return;
    }

    new progress, target, tl, coin, xp;
    switch(task)
    {
        case 0:
        {
            progress = g_iDailyKills[id]; target = CfgInt("TASK_KILL_TARGET",5);
            tl=CfgInt("TASK_KILL_REWARD_TL",25); coin=CfgInt("TASK_KILL_REWARD_COIN",2); xp=CfgInt("TASK_KILL_REWARD_XP",80);
        }
        case 1:
        {
            progress = g_iDailyPlayMinutes[id]; target = CfgInt("TASK_PLAY_TARGET",20);
            tl=CfgInt("TASK_PLAY_REWARD_TL",20); coin=CfgInt("TASK_PLAY_REWARD_COIN",2); xp=CfgInt("TASK_PLAY_REWARD_XP",60);
        }
        case 2:
        {
            progress = g_iDailyCrates[id]; target = CfgInt("TASK_CRATE_TARGET",3);
            tl=CfgInt("TASK_CRATE_REWARD_TL",30); coin=CfgInt("TASK_CRATE_REWARD_COIN",3); xp=CfgInt("TASK_CRATE_REWARD_XP",100);
        }
        case 3:
        {
            progress = g_iDailyPurchases[id]; target = CfgInt("TASK_BUY_TARGET",3);
            tl=CfgInt("TASK_BUY_REWARD_TL",20); coin=CfgInt("TASK_BUY_REWARD_COIN",2); xp=CfgInt("TASK_BUY_REWARD_XP",75);
        }
        case 4:
        {
            progress = g_iDailySurvives[id]; target = CfgInt("TASK_SURVIVE_TARGET",3);
            tl=CfgInt("TASK_SURVIVE_REWARD_TL",25); coin=CfgInt("TASK_SURVIVE_REWARD_COIN",2); xp=CfgInt("TASK_SURVIVE_REWARD_XP",90);
        }
    }

    if(progress < target)
    {
        Chat(id, "Gorev henuz tamamlanmadi. ^3%d/%d", progress, target);
        return;
    }

    g_iTaskClaimMask[id] |= (1<<task);
    g_iTL[id] += tl;
    FC_CoinChange(id,coin);
    AddXP(id, xp);
    SavePlayer(id);
    Chat(id, "Gorev odulu: ^3+%d TL ^1/ ^4+%d Coin ^1/ ^3+%d XP", tl, coin, xp);
    PlaySuccessSound(id);
}

ClaimAllTasksBonus(id)
{
    if(g_iTaskClaimMask[id] & (1<<TASK_COUNT))
    {
        Chat(id, "Tum gorev bonusunu zaten aldin.");
        return;
    }

    if(CountClaimedTasks(id) < TASK_COUNT)
    {
        Chat(id, "Once tum gunluk gorevlerin odulunu almalisin.");
        return;
    }

    new tl = CfgInt("TASK_ALL_BONUS_TL",50);
    new coin = CfgInt("TASK_ALL_BONUS_COIN",5);
    new xp = CfgInt("TASK_ALL_BONUS_XP",150);
    g_iTaskClaimMask[id] |= (1<<TASK_COUNT);
    g_iTL[id] += tl;
    FC_CoinChange(id,coin);
    AddXP(id, xp);
    SavePlayer(id);
    Chat(id, "Tum gunluk gorevler tamam! Bonus: ^3+%d TL ^1/ ^4+%d Coin ^1/ ^3+%d XP", tl, coin, xp);
    PlaySuccessSound(id);
}

CountClaimedTasks(id)
{
    new count;
    for(new i; i < TASK_COUNT; i++)
        if(g_iTaskClaimMask[id] & (1<<i)) count++;
    return count;
}

// ============================================================
// 7) KASA SISTEMI - 3 KASA + HUD ANIMASYON
// ============================================================

ShowCrateMenu(id)
{
    if(g_iUID[id] <= 0)
    {
        ShowAccountMenu(id);
        return;
    }

    new menu = FC_MenuCreate("\wKasa Sistemi", "H_Crate");
    new line[160];

    formatex(line, charsmax(line), "\wBronz Kasa \y- %d TL", CalcPrice(id, CfgInt("CRATE_BRONZE_TL",50)));
    FC_MenuAddItem(menu, line, "0");
    formatex(line, charsmax(line), "\wGumus Kasa \r- %d Coin", CalcPrice(id, CfgInt("CRATE_SILVER_COIN",10)));
    FC_MenuAddItem(menu, line, "1");
    formatex(line, charsmax(line), "\yAltin Kasa \r- %d Coin", CalcPrice(id, CfgInt("CRATE_GOLD_COIN",25)));
    FC_MenuAddItem(menu, line, "2");

    FC_MenuSetProp(menu, MPROP_EXITNAME, "Geri");
    menu_display(id, menu);
}

public H_Crate(id, menu, item)
{
    if(!CanUseJBMenu(id, true))
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }

    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        ShowMainMenu(id);
        return PLUGIN_HANDLED;
    }

    new info[8], name[64], access, cb;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), cb);
    new type = str_to_num(info);
    menu_destroy(menu);

    if(!is_user_alive(id))
    {
        Chat(id, "Kasa acmak icin hayatta olmalisin.");
        return PLUGIN_HANDLED;
    }

    if(type == CRATE_BRONZE)
    {
        if(!PayTL(id, CfgInt("CRATE_BRONZE_TL",50))) return PLUGIN_HANDLED;
    }
    else if(type == CRATE_SILVER)
    {
        if(!PayCoin(id, CfgInt("CRATE_SILVER_COIN",10))) return PLUGIN_HANDLED;
    }
    else if(type == CRATE_GOLD)
    {
        if(!PayCoin(id, CfgInt("CRATE_GOLD_COIN",25))) return PLUGIN_HANDLED;
    }
    else return PLUGIN_HANDLED;

    StartCrateAnimation(id, type);
    return PLUGIN_HANDLED;
}

StartCrateAnimation(id, type)
{
    remove_task(id + TASK_CRATE);
    g_iCrateType[id] = type;
    g_iCrateTick[id] = 0;
    TaskCrateSpin(id + TASK_CRATE);
    set_task(0.18, "TaskCrateSpin", id + TASK_CRATE, "", 0, "b");
}

public TaskCrateSpin(taskid)
{
    new id = taskid - TASK_CRATE;
    if(HW_Player(id) || g_iCrateType[id] < 0 || g_iCrateType[id] >= CRATE_COUNT)
    {
        remove_task(taskid);
        return;
    }
    if(!is_user_connected(id))
    {
        remove_task(taskid);
        return;
    }

    g_iCrateTick[id]++;

    new a = random_num(0, sizeof(g_CrateRollNames)-1);
    new b = random_num(0, sizeof(g_CrateRollNames)-1);
    new c = random_num(0, sizeof(g_CrateRollNames)-1);

    set_hudmessage(210, 210, 255, -1.0, 0.38, 0, 0.0, 0.30, 0.0, 0.0, 1);
    show_hudmessage(id,
        "%s Kasa^n^n   %s^n>> %s <<^n   %s^n^nKasa: %s", LONG_TAG,
        g_CrateRollNames[a], g_CrateRollNames[b], g_CrateRollNames[c], g_CrateNames[g_iCrateType[id]]);

    if((g_iCrateTick[id] % 3) == 0)
        PlayConfigSound(id, "CRATE_SPIN_SOUND", "buttons/blip1.wav");

    if(g_iCrateTick[id] >= CfgInt("CRATE_ANIM_TICKS",24))
    {
        remove_task(taskid);
        GiveCrateReward(id, g_iCrateType[id]);
        g_iCrateType[id] = -1;
        g_iCrateTick[id] = 0;
    }
}

GiveCrateReward(id, type)
{
    if(!is_user_connected(id))
        return;

    new reward = ChooseCrateReward(type);
    new rewardText[96];

    switch(reward)
    {
        case 0:
        {
            new amount = CfgInt("CRATE_REWARD_TL_SMALL",25);
            g_iTL[id] += amount;
            formatex(rewardText, charsmax(rewardText), "+%d TL", amount);
        }
        case 1:
        {
            new amount = CfgInt("CRATE_REWARD_TL_BIG",100);
            g_iTL[id] += amount;
            formatex(rewardText, charsmax(rewardText), "+%d TL", amount);
        }
        case 2:
        {
            new amount = CfgInt("CRATE_REWARD_COIN_SMALL",2);
            FC_CoinChange(id,amount);
            formatex(rewardText, charsmax(rewardText), "+%d Coin", amount);
        }
        case 3:
        {
            new amount = CfgInt("CRATE_REWARD_COIN_BIG",8);
            FC_CoinChange(id,amount);
            formatex(rewardText, charsmax(rewardText), "+%d Coin", amount);
        }
        case 4:
        {
            new amount = CfgInt("CRATE_REWARD_HP_SMALL",50);
            if(is_user_alive(id))
            {
                new Float:hp; get_entvar(id,var_health,hp);
                set_entvar(id,var_health,hp + float(amount));
            }
            formatex(rewardText, charsmax(rewardText), "+%d HP", amount);
        }
        case 5:
        {
            new amount = CfgInt("CRATE_REWARD_HP_BIG",100);
            if(is_user_alive(id))
            {
                new Float:hp; get_entvar(id,var_health,hp);
                set_entvar(id,var_health,hp + float(amount));
            }
            formatex(rewardText, charsmax(rewardText), "+%d HP", amount);
        }
        case 6:
        {
            if(is_user_alive(id)) GiveWeaponClip(id, "weapon_deagle", 1);
            copy(rewardText, charsmax(rewardText), "1 Mermili Deagle");
        }
        case 7:
        {
            if(is_user_alive(id)) rg_give_item(id, "weapon_m4a1");
            copy(rewardText, charsmax(rewardText), "M4A1");
        }
        case 8:
        {
            if(is_user_alive(id)) rg_give_item(id, "weapon_ak47");
            copy(rewardText, charsmax(rewardText), "AK-47");
        }
        case 9:
        {
            if(is_user_alive(id)) rg_give_item(id, "weapon_hegrenade");
            copy(rewardText, charsmax(rewardText), "HE Bomba");
        }
        case 10:
        {
            if(is_user_alive(id))
            {
                rg_give_item(id, "weapon_hegrenade");
                rg_give_item(id, "weapon_flashbang");
                rg_give_item(id, "weapon_smokegrenade");
            }
            copy(rewardText, charsmax(rewardText), "Bomba Seti");
        }
    }

    CheckDailyReset(id);
    g_iDailyCrates[id]++;
    SavePlayer(id);

    set_hudmessage(120, 255, 120, -1.0, 0.42, 1, 0.1, 2.5, 0.1, 0.2, 1);
    show_hudmessage(id, "KASA ACILDI!^n%s", rewardText);
    Chat(id, "^4%s ^1kasasindan ^3%s ^1cikti!", g_CrateNames[type], rewardText);
    PlayConfigSound(id, "CRATE_WIN_SOUND", "fvox/bell.wav");
}

ChooseCrateReward(type)
{
    new roll = random_num(1,100);

    switch(type)
    {
        case CRATE_BRONZE:
        {
            if(roll <= 30) return 0;
            if(roll <= 45) return 4;
            if(roll <= 58) return 9;
            if(roll <= 70) return 6;
            if(roll <= 82) return 2;
            if(roll <= 92) return 7;
            return 1;
        }
        case CRATE_SILVER:
        {
            if(roll <= 20) return 1;
            if(roll <= 35) return 2;
            if(roll <= 50) return 5;
            if(roll <= 65) return 6;
            if(roll <= 78) return 7;
            if(roll <= 90) return 10;
            return 3;
        }
        case CRATE_GOLD:
        {
            if(roll <= 18) return 3;
            if(roll <= 34) return 1;
            if(roll <= 48) return 5;
            if(roll <= 62) return 7;
            if(roll <= 78) return 8;
            if(roll <= 92) return 10;
            return 6;
        }
    }
    return 0;
}


// ============================================================
// 8) RANK / XP SISTEMI
// ============================================================

ShowRankMenu(id)
{
    if(g_iUID[id] <= 0)
    {
        ShowAccountMenu(id);
        return;
    }

    new current[48], title[256];
    GetRankName(g_iRank[id], current, charsmax(current));

    if(g_iRank[id] >= MAX_RANKS-1)
        formatex(title, charsmax(title), "\wRank Sistemi^n\dAktif: \y%s \d| \w%d XP \r[MAX]", current, g_iXP[id]);
    else
        formatex(title, charsmax(title), "\wRank Sistemi^n\dAktif: \y%s \d| \w%d/%d XP", current, g_iXP[id], GetRankNeedXP(g_iRank[id]+1));

    new menu = FC_MenuCreate(title, "H_Rank");
    new rankName[48], line[160], info[8];
    for(new i; i < MAX_RANKS; i++)
    {
        GetRankName(i, rankName, charsmax(rankName));
        formatex(line, charsmax(line), "%s%s",
            i == g_iRank[id] ? "\y" : "\w", rankName);
        num_to_str(i, info, charsmax(info));
        FC_MenuAddItem(menu, line, info);
    }
    FC_MenuSetProp(menu, MPROP_EXITNAME, "Geri");
    menu_display(id, menu);
}

public H_Rank(id, menu, item)
{
    menu_destroy(menu);
    ShowMainMenu(id);
    return PLUGIN_HANDLED;
}

AddXP(id, amount)
{
    if(g_iUID[id] <= 0 || amount <= 0)
        return;

    new maxXP = GetMaxRankXP();
    new oldXP = clamp(g_iXP[id], 0, maxXP);
    new oldRank = GetRankByXP(oldXP);

    g_iXP[id] = clamp(oldXP + amount, 0, maxXP);
    g_iRank[id] = GetRankByXP(g_iXP[id]);

    // Atlanan her rankin Coin odulunu bir kez ver.
    if(g_iRank[id] > oldRank)
    {
        for(new rank = oldRank + 1; rank <= g_iRank[id]; rank++)
        {
            new reward = GetRankRewardCoin(rank);
            FC_CoinChange(id,reward);

            new rankName[48];
            GetRankName(rank, rankName, charsmax(rankName));
            Chat(id, "Rank atladin! Yeni rank: ^4%s ^1| Odul: ^4+%d Coin", rankName, reward);
        }

        PlaySuccessSound(id);
    }
}

GetRankName(rank, out[], len)
{
    rank = clamp(rank, 0, MAX_RANKS-1);
    new key[32];
    formatex(key, charsmax(key), "RANK_%d_NAME", rank);
    CfgStr(key, out, len, g_DefaultRankNames[rank]);
}

GetRankNeedXP(rank)
{
    rank = clamp(rank, 0, MAX_RANKS-1);
    new key[32];
    formatex(key, charsmax(key), "RANK_%d_XP", rank);
    return CfgInt(key, g_DefaultRankXP[rank]);
}

GetMaxRankXP()
{
    return max(0, GetRankNeedXP(MAX_RANKS - 1));
}

GetRankByXP(xp)
{
    xp = clamp(xp, 0, GetMaxRankXP());

    new rank = 0;
    for(new i = 1; i < MAX_RANKS; i++)
    {
        if(xp < GetRankNeedXP(i))
            break;

        rank = i;
    }

    return rank;
}

GetRankRewardCoin(rank)
{
    if(rank <= 0) return 0;
    new key[32];
    formatex(key, charsmax(key), "RANK_%d_COIN", rank);
    return CfgInt(key, rank * 2);
}

// ============================================================
// KLAN PLUGINI DINAMIK BAGLANTISI
// Dosya adina veya client userinfo alanlarina bagimli degildir.
// FC_ClanInfoForPlayer ve FC_OpenClanMenu public fonksiyonlarini
// yuklu pluginler arasinda bulur. Böylece .amxx adi degisse de calisir.
// ============================================================
ResolveClanBridge()
{
    if(g_iClanBridgePlugin >= 0)
    {
        if(g_iClanInfoFunction >= 0 && g_iClanMenuFunction >= 0
            && get_func_id("FC_ClanInfoForPlayer", g_iClanBridgePlugin) == g_iClanInfoFunction
            && get_func_id("FC_OpenClanMenu", g_iClanBridgePlugin) == g_iClanMenuFunction)
            return g_iClanBridgePlugin;

        g_iClanBridgePlugin = -1;
        g_iClanInfoFunction = -1;
        g_iClanMenuFunction = -1;
    }

    new pluginCount = get_pluginsnum();
    for(new index = 0; index < pluginCount; index++)
    {
        new filename[64];
        if(get_plugin(index, filename, charsmax(filename)) < 0)
            continue;

        // get_func_id expects the internal plugin id returned by find_plugin_byfile.
        new pluginId = find_plugin_byfile(filename);
        if(pluginId < 0)
            continue;

        new infoFunction = get_func_id("FC_ClanInfoForPlayer", pluginId);
        if(infoFunction < 0)
            continue;

        new menuFunction = get_func_id("FC_OpenClanMenu", pluginId);
        if(menuFunction < 0)
            continue;

        g_iClanBridgePlugin = pluginId;
        g_iClanInfoFunction = infoFunction;
        g_iClanMenuFunction = menuFunction;
        return pluginId;
    }

    return -1;
}

GetClanInfoFromPlugin(id, name[], len)
{
    name[0] = 0;
    if(id < 1 || id > MaxClients || !is_user_connected(id) || len <= 0)
        return 0;

    new pluginId = ResolveClanBridge();
    if(pluginId < 0 || callfunc_begin_i(g_iClanInfoFunction, pluginId) != 1)
        return 0;

    // Public signature: FC_ClanInfoForPlayer(id, name[], len).
    callfunc_push_int(id);
    callfunc_push_array(name, len, true);
    callfunc_push_int(len);

    new clanLevel = callfunc_end();
    if(clanLevel <= 0 || !name[0])
    {
        name[0] = 0;
        return 0;
    }

    return clanLevel;
}

GetClanHudLine(id, output[], len)
{
    new clanName[64], level = GetClanInfoFromPlugin(id, clanName, charsmax(clanName));
    if(level <= 0 || !clanName[0]) copy(output, len, "Klan yok");
    else formatex(output, len, "%s | %d Lvl", clanName, level);
}

public FC_SetClanTagEnabled(id, enabled)
{
    if(id < 1 || id > MaxClients)
        return 0;
    g_bClanTagEnabled[id] = bool:enabled;
    if(g_iUID[id] > 0)
        SavePlayer(id);
    return 1;
}

OpenClanMenuFromJB(id)
{
    if(g_iUID[id] <= 0 || g_bGuestMode[id])
    {
        Chat(id, "Klan sistemi icin once hesabina giris yapmalisin.");
        return;
    }

    new pluginId = ResolveClanBridge();
    if(pluginId < 0 || callfunc_begin_i(g_iClanMenuFunction, pluginId) != 1)
    {
        Chat(id, "Klan eklentisi bulunamadi. Sunucu eklenti listesinden klan sisteminin aktif oldugunu kontrol et.");
        return;
    }

    callfunc_push_int(id);
    new result = callfunc_end();
    if(!result)
        Chat(id, "Klan merkezi acilamadi. Hesap girisini ve klan eklentisinin loglarini kontrol et.");
}

// ============================================================
// CHAT SISTEMI
// ============================================================

HandleCustomChat(id, const message[], bool:teamOnly)
{
    if(!is_user_connected(id))
        return;

    new role[24],rank[48],rankTag[64],clanName[64],clanTag[80],name[32],out[191];
    GetChatRoleName(id,role,charsmax(role));
    if(g_iUID[id]>0 && !g_bGuestMode[id] && g_bRankTagEnabled[id]) {
        GetRankName(g_iRank[id],rank,charsmax(rank));
        formatex(rankTag,charsmax(rankTag),"^1[^3%s^1]",rank);
    }
    if(g_bClanTagEnabled[id])
    {
        new clanLevel = GetClanInfoFromPlugin(id, clanName, charsmax(clanName));
        if(clanLevel > 0 && clanName[0])
            formatex(clanTag,charsmax(clanTag)," ^1[^4%s^1]",clanName);
        else
        {
            g_bClanTagEnabled[id] = false;
            SavePlayer(id);
        }
    }
    get_user_name(id,name,charsmax(name));
    new bool:green=bool:(get_user_flags(id)&ADMIN_RESERVATION);
    formatex(out,charsmax(out),"%s %s%s^1[^4%s^1]%s%s ^3%s ^1: %s%s",
        CHAT_TAG,is_user_alive(id)?"":"^1[^3X^1] ",rankTag,role,clanTag,
        teamOnly?" ^1(Takım)":"",name,green?"^4":"^1",message);

    new TeamName:senderTeam = get_member(id, m_iTeam);
    for(new p = 1; p <= MaxClients; p++)
    {
        if(!is_user_connected(p))
            continue;

        if(teamOnly && get_member(p, m_iTeam) != senderTeam)
            continue;

        client_print_color(p, id, "%s", out);
    }
}

GetChatRoleName(id, out[], len)
{
    if(g_bGuestMode[id] || g_iUID[id] <= 0)
    {
        copy(out, len, "Misafir");
        return;
    }

    GetRoleName(id, out, len);
    if(equali(out, "Normal Uye"))
        copy(out, len, "Uye");
}

// ============================================================
// 8) BILGILER MENUSU / PROFIL / LOCAL TOP15
// MySQL / web sitesi YOK. Tum siralamalar JBMenu nVault + UID kayitlarindan okunur.
// ============================================================

ShowInfoMenu(id)
{
    new menu = FC_MenuCreate("\wBilgiler Menusu", "H_InfoMenu");
    FC_MenuAddItem(menu, "\wSuanki Profil Bilgilerim", "1");
    FC_MenuAddItem(menu, "\wTop 15 Time", "2");
    FC_MenuAddItem(menu, "\wEn Iyi Gardiyanlar", "3");
    FC_MenuAddItem(menu, "\wEn Iyi Isyancilar", "4");
    FC_MenuAddItem(menu, "\wHesap Ayarlari", "5");
    FC_MenuSetProp(menu, MPROP_EXITNAME, "Geri");
    menu_display(id, menu);
}

public H_InfoMenu(id, menu, item)
{
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        ShowMainMenu(id);
        return PLUGIN_HANDLED;
    }

    if(!CanUseJBMenu(id, true))
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }

    new info[8], name[64], access, cb;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), cb);
    new key = str_to_num(info);
    menu_destroy(menu);

    switch(key)
    {
        case 1: ShowMyProfileMotd(id);
        case 2: ShowTopTimeMotd(id);
        case 3: ShowTopGuardsMotd(id);
        case 4: ShowTopRebelsMotd(id);
        case 5: ShowAccountSettingsMenu(id);
    }

    return PLUGIN_HANDLED;
}

ShowAccountSettingsMenu(id)
{
    new menu = FC_MenuCreate("\wHesap Ayarlari", "H_AccountSettings");
    FC_MenuAddItem(menu, "\wBakiye Bilgisini Sohbete Yaz", "1");
    FC_MenuAddItem(menu, "\wSifremi Degistir", "2");
    FC_MenuAddItem(menu, "\wHesaptan Cikis Yap", "3");
    FC_MenuAddItem(menu, "\wHUD Modunu Degistir", "4");
    FC_MenuSetProp(menu, MPROP_EXITNAME, "Geri");
    menu_display(id, menu);
}

public H_AccountSettings(id, menu, item)
{
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        ShowInfoMenu(id);
        return PLUGIN_HANDLED;
    }

    new info[8], name[64], access, cb;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), cb);
    new key = str_to_num(info);
    menu_destroy(menu);

    switch(key)
    {
        case 1: PrintProfileLine(id);
        case 2: nChangePassword(id);
        case 3: nForwardExit(id);
        case 4:
        {
            CycleHudMode(id);
            ShowAccountSettingsMenu(id);
        }
    }
    return PLUGIN_HANDLED;
}

ShowMyProfileMotd(id)
{
    if(g_iUID[id] <= 0)
    {
        ShowAccountMenu(id);
        return;
    }

    SaveAllOnlineStats();

    new name[32], safeName[96], role[32], rank[48], totalTime[48], ctTime[48];
    get_user_name(id, name, charsmax(name));
    HtmlEscape(name, safeName, charsmax(safeName));
    GetRoleName(id, role, charsmax(role));
    GetRankName(g_iRank[id], rank, charsmax(rank));
    FormatMinutesLong(g_iPlayMinutes[id], totalTime, charsmax(totalTime));
    FormatMinutesLong(g_iCTMinutes[id], ctTime, charsmax(ctTime));

    MotdBegin("Profil Bilgilerim");
    MotdAdd("<div class='card'>");
    MotdAddFmt("<div class='big'>%s</div>", safeName);
    MotdAddFmt("<div class='sub'>UID #%d   •   %s</div>", g_iUID[id], role);
    MotdAdd("</div>");
    MotdAdd("<table><tr><th>Bilgi</th><th>Deger</th></tr>");
    MotdAddFmt("<tr><td>Rank</td><td>%s</td></tr>", rank);
    MotdAddFmt("<tr><td>XP</td><td>%d</td></tr>", g_iXP[id]);
    MotdAddFmt("<tr><td>Meslek</td><td>%s</td></tr>", g_ProfessionNames[g_iProfession[id]]);
    MotdAddFmt("<tr><td>TL / Coin</td><td>%d TL / %d Coin</td></tr>", g_iTL[id], g_iCoin[id]);
    MotdAddFmt("<tr><td>Toplam Harcanan TL</td><td>%d TL</td></tr>",g_iTLSpent[id]);
    MotdAddFmt("<tr><td>Toplam Kazanılan Coin</td><td>%d Coin</td></tr>",g_iCoinEarned[id]);
    MotdAddFmt("<tr><td>Toplam Harcanan Coin</td><td>%d Coin</td></tr>",g_iCoinSpent[id]);
    MotdAdd("<tr><td colspan='2'>Toplamlar, harcama kaydı tutulmaya başlandığından itibaren hesaplanır.</td></tr>");
    MotdAddFmt("<tr><td>Toplam Oynama</td><td>%s</td></tr>", totalTime);
    MotdAddFmt("<tr><td>CT Oynama</td><td>%s</td></tr>", ctTime);
    MotdAddFmt("<tr><td>Gardiyan Kill</td><td>%d</td></tr>", g_iCTKills[id]);
    MotdAddFmt("<tr><td>Isyanci Kill (T > CT)</td><td>%d</td></tr>", g_iRebelKills[id]);
    MotdAdd("</table>");
    MotdEnd();

    new motdTitle[96]; formatex(motdTitle, charsmax(motdTitle), "%s - Profil Bilgilerim", LONG_TAG); show_motd(id, g_szMotd, motdTitle);
}

ShowTopTimeMotd(id)
{
    new uids[TOP_LIST_SIZE], values[TOP_LIST_SIZE], extras[TOP_LIST_SIZE], count;
    BuildTopList(0, uids, values, extras, count);

    MotdBegin("Top 15 Time");
    MotdAdd("<div class='sub'>Sunucuda en fazla sure geciren hesaplar</div>");
    MotdAdd("<table><tr><th>#</th><th>Oyuncu</th><th>Toplam Sure</th></tr>");

    new playerName[32], safeName[96], timeText[48];
    for(new i; i < count; i++)
    {
        GetUIDDisplayName(uids[i], playerName, charsmax(playerName));
        HtmlEscape(playerName, safeName, charsmax(safeName));
        FormatMinutesLong(values[i], timeText, charsmax(timeText));
        MotdAddFmt("<tr><td>%d</td><td>%s</td><td>%s</td></tr>", i+1, safeName, timeText);
    }

    if(!count)
        MotdAdd("<tr><td colspan='3'>Henuz siralama verisi yok.</td></tr>");

    MotdAdd("</table>");
    MotdEnd();
    new motdTitle[96]; formatex(motdTitle, charsmax(motdTitle), "%s - Top 15 Time", LONG_TAG); show_motd(id, g_szMotd, motdTitle);
}

ShowTopGuardsMotd(id)
{
    new uids[TOP_LIST_SIZE], values[TOP_LIST_SIZE], extras[TOP_LIST_SIZE], count;
    BuildTopList(1, uids, values, extras, count);

    MotdBegin("En Iyi Gardiyanlar");
    MotdAdd("<div class='sub'>CT takiminda gecirilen sureye gore siralanir</div>");
    MotdAdd("<table><tr><th>#</th><th>Gardiyan</th><th>CT Sure</th><th>Kill</th></tr>");

    new playerName[32], safeName[96], timeText[48];
    for(new i; i < count; i++)
    {
        GetUIDDisplayName(uids[i], playerName, charsmax(playerName));
        HtmlEscape(playerName, safeName, charsmax(safeName));
        FormatMinutesLong(values[i], timeText, charsmax(timeText));
        MotdAddFmt("<tr><td>%d</td><td>%s</td><td>%s</td><td>%d</td></tr>", i+1, safeName, timeText, extras[i]);
    }

    if(!count)
        MotdAdd("<tr><td colspan='4'>Henuz gardiyan verisi yok.</td></tr>");

    MotdAdd("</table>");
    MotdEnd();
    new motdTitle[96]; formatex(motdTitle, charsmax(motdTitle), "%s - En Iyi Gardiyanlar", LONG_TAG); show_motd(id, g_szMotd, motdTitle);
}

ShowTopRebelsMotd(id)
{
    new uids[TOP_LIST_SIZE], values[TOP_LIST_SIZE], extras[TOP_LIST_SIZE], count;
    BuildTopList(2, uids, values, extras, count);

    MotdBegin("En Iyi Isyancilar");
    MotdAdd("<div class='sub'>T takimindayken oldurulen CT sayisina gore siralanir</div>");
    MotdAdd("<table><tr><th>#</th><th>Isyanci</th><th>CT Kill</th></tr>");

    new playerName[32], safeName[96];
    for(new i; i < count; i++)
    {
        GetUIDDisplayName(uids[i], playerName, charsmax(playerName));
        HtmlEscape(playerName, safeName, charsmax(safeName));
        MotdAddFmt("<tr><td>%d</td><td>%s</td><td>%d</td></tr>", i+1, safeName, values[i]);
    }

    if(!count)
        MotdAdd("<tr><td colspan='3'>Henuz isyanci verisi yok.</td></tr>");

    MotdAdd("</table>");
    MotdEnd();
    new motdTitle[96]; formatex(motdTitle, charsmax(motdTitle), "%s - En Iyi Isyancilar", LONG_TAG); show_motd(id, g_szMotd, motdTitle);
}

// mode 0: toplam sure, 1: CT sure (extra CT kill), 2: T > CT kill
BuildTopList(mode, uids[TOP_LIST_SIZE], values[TOP_LIST_SIZE], extras[TOP_LIST_SIZE], &count)
{
    SaveAllOnlineStats();

    count = 0;
    for(new i; i < TOP_LIST_SIZE; i++)
    {
        uids[i] = 0;
        values[i] = 0;
        extras[i] = 0;
    }

    new lastUid = nGetLastUid();
    if(lastUid < 1000)
        return;

    for(new uid = 1000; uid <= lastUid; uid++)
    {
        if(!nIsValidUid(uid))
            continue;

        new value, extra;
        switch(mode)
        {
            case 0: value = UIDGetInt(uid, "play_minutes", 0);
            case 1:
            {
                value = UIDGetInt(uid, "ct_minutes", 0);
                extra = UIDGetInt(uid, "ct_kills", 0);
            }
            case 2: value = UIDGetInt(uid, "rebel_kills", 0);
        }

        if(value <= 0)
            continue;

        TopInsert(uid, value, extra, uids, values, extras, count);
    }
}

TopInsert(uid, value, extra, uids[TOP_LIST_SIZE], values[TOP_LIST_SIZE], extras[TOP_LIST_SIZE], &count)
{
    new pos = count;

    if(pos >= TOP_LIST_SIZE)
        pos = TOP_LIST_SIZE - 1;

    for(new i; i < count && i < TOP_LIST_SIZE; i++)
    {
        if(value > values[i] || (value == values[i] && extra > extras[i]))
        {
            pos = i;
            break;
        }
    }

    if(count >= TOP_LIST_SIZE && pos == TOP_LIST_SIZE - 1)
    {
        if(value < values[pos] || (value == values[pos] && extra <= extras[pos]))
            return;
    }

    new last = min(count, TOP_LIST_SIZE - 1);
    for(new i = last; i > pos; i--)
    {
        uids[i] = uids[i-1];
        values[i] = values[i-1];
        extras[i] = extras[i-1];
    }

    uids[pos] = uid;
    values[pos] = value;
    extras[pos] = extra;

    if(count < TOP_LIST_SIZE)
        count++;
}

SaveAllOnlineStats()
{
    for(new id = 1; id <= MaxClients; id++)
    {
        if(is_user_connected(id) && g_iUID[id] > 0)
            SavePlayer(id);
    }
}

GetUIDDisplayName(uid, out[], len)
{
    nUidLastName(uid, out, len);
    if(!out[0])
        formatex(out, len, "UID #%d", uid);
}

FormatMinutesLong(minutes, out[], len)
{
    if(minutes < 0)
        minutes = 0;

    new days = minutes / 1440;
    new hours = (minutes % 1440) / 60;
    new mins = minutes % 60;

    if(days > 0)
        formatex(out, len, "%d gun %d sa %d dk", days, hours, mins);
    else if(hours > 0)
        formatex(out, len, "%d sa %d dk", hours, mins);
    else
        formatex(out, len, "%d dk", mins);
}

HtmlEscape(const input[], output[], len)
{
    copy(output, len, input);
    replace_all(output, len, "&", "&amp;");
    replace_all(output, len, "<", "&lt;");
    replace_all(output, len, ">", "&gt;");
    replace_all(output, len, "^"", "&quot;");
}

MotdBegin(const title[])
{
    g_szMotd[0] = 0;

    add(g_szMotd, MOTD_HTML_SIZE, "<html><head><meta charset='UTF-8'><style>");
    add(g_szMotd, MOTD_HTML_SIZE, "body{background:#0b0b0d;color:#ddd;font-family:Verdana,Arial;font-size:12px;margin:10px}");
    add(g_szMotd, MOTD_HTML_SIZE, "h2{color:#c68cff;margin:0 0 8px 0}");
    add(g_szMotd, MOTD_HTML_SIZE, ".brand{color:#fff;font-size:18px;font-weight:bold}.accent{color:#c68cff}");
    add(g_szMotd, MOTD_HTML_SIZE, ".sub{color:#999;margin:5px 0 10px 0}.card{border:1px solid #2b2b31;background:#141419;padding:10px;margin-bottom:8px}");
    add(g_szMotd, MOTD_HTML_SIZE, ".big{font-size:16px;color:#fff;font-weight:bold}");
    add(g_szMotd, MOTD_HTML_SIZE, "table{width:100%;border-collapse:collapse;background:#121216}");
    add(g_szMotd, MOTD_HTML_SIZE, "th{background:#201a26;color:#d7a5ff;text-align:left;padding:6px;border-bottom:1px solid #3a3040}");
    add(g_szMotd, MOTD_HTML_SIZE, "td{padding:6px;border-bottom:1px solid #24242a}");
    add(g_szMotd, MOTD_HTML_SIZE, "tr:nth-child(even){background:#16161c}");
    add(g_szMotd, MOTD_HTML_SIZE, "</style></head><body>");

    MotdAddFmt("<div class='brand'>%s <span class='accent'>?</span> %s</div>", LONG_TAG, title);
}

MotdAdd(const text[])
{
    if(strlen(g_szMotd) + strlen(text) + 1 < MOTD_HTML_SIZE)
        add(g_szMotd, MOTD_HTML_SIZE, text);
}

MotdAddFmt(const fmt[], any:...)
{
    new temp[512];
    vformat(temp, charsmax(temp), fmt, 2);
    MotdAdd(temp);
}

MotdEnd()
{
    MotdAddFmt("<div class='sub'>%s JailBreak • Veriler UID bazli nVault kaydindan okunur.</div></body></html>", LONG_TAG);
}

PrintProfileLine(id)
{
    if(g_iUID[id] <= 0)
    {
        if(g_bGuestMode[id])
            Chat(id, "Misafir Modu | ^3%d TL ^1| Coin ve uyelik sistemi icin hesaba giris yap.", g_iTL[id]);
        else
            Chat(id, "Hesaba giris yapmadin.");
        return;
    }

    new role[24], rank[48];
    GetRoleName(id, role, charsmax(role));
    GetRankName(g_iRank[id], rank, charsmax(rank));
    Chat(id, "UID: ^3%d ^1| %s | Rank: ^3%s ^1| ^3%d TL ^1| ^4%d Coin", g_iUID[id], role, rank, g_iTL[id], g_iCoin[id]);
}

HandleCoinTransfer(id, const text[])
{
    if(g_iUID[id] <= 0)
    {
        if(g_bGuestMode[id]) Chat(id, "Coin transferi icin hesaba giris yapmalisin.");
        return;
    }

    new cmd[16], targetName[64], amountText[16];
    parse(text, cmd, charsmax(cmd), targetName, charsmax(targetName), amountText, charsmax(amountText));

    new amount = str_to_num(amountText);
    if(!targetName[0] || amount <= 0)
    {
        Chat(id, "Kullanim: ^4/coinver ^3^"isim^" miktar");
        return;
    }

    new target = cmd_target(id, targetName, CMDTARGET_ALLOW_SELF);
    if(!target || target == id || g_iUID[target] <= 0)
    {
        Chat(id, "Gecerli bir hesapli oyuncu sec.");
        return;
    }

    if(g_iCoin[id] < amount)
    {
        Chat(id, "Yeterli Coin yok.");
        return;
    }

    FC_CoinChange(id,-amount);
    FC_CoinChange(target,amount);
    SavePlayer(id);
    SavePlayer(target);

    Chat(id, "^4%n ^1adli oyuncuya ^3%d Coin ^1gonderdin.", target, amount);
    Chat(target, "^4%n ^1sana ^3%d Coin ^1gonderdi.", id, amount);
    log_to_file(LOG_FILE, "COIN TRANSFER: %n(%d) -> %n(%d): %d", id,g_iUID[id],target,g_iUID[target],amount);
}

// ============================================================
// 9) YONETICI PANELI - FLAG YOK, OTURUM BASINA TEK SIFRE
// ============================================================

RequestPanel(id)
{
    if(g_iUID[id] <= 0 || g_bGuestMode[id])
    {
        Chat(id, "Yonetici paneli icin once hesaba giris yapmalisin.");
        ShowAccountMenu(id);
        return;
    }

    // Yonetici uyeligine sahip hesaplar panel sifresini tekrar girmez.
    if(HasRole(id, ROLE_MANAGER))
    {
        g_bPanelAuth[id] = true;
        ShowAdminMenu(id);
        return;
    }

    if(g_bPanelAuth[id])
    {
        ShowAdminMenu(id);
        return;
    }

    client_cmd(id, "messagemode FC_Panel_Sifre");
    Chat(id, "Yonetici paneli icin sifreyi gir. Bu baglantida bir kez sorulur.");
}

public CmdPanelPassword(id)
{
    new input[64], password[64];
    read_args(input, charsmax(input));
    remove_quotes(input);
    trim(input);
    CfgStr("ADMIN_PASSWORD", password, charsmax(password), "xxx");

    if(equal(input, password))
    {
        if(g_iUID[id] <= 0)
        {
            Chat(id, "Panel sifresi icin once hesaba giris yapmalisin.");
            return PLUGIN_HANDLED;
        }

        g_bPanelAuth[id] = true;

        // Sifreyi dogru bilen hesap otomatik olarak kalici Yonetici hesabi olur.
        g_iRoleExpiry[id][ROLE_MANAGER] = 0;
        SavePlayer(id);

        Chat(id, "Panel sifresi dogru. Hesabin ^4Yonetici ^1olarak aktif edildi.");
        log_to_file(LOG_FILE, "PANEL LOGIN OK + MANAGER: %n UID:%d", id, g_iUID[id]);
        ShowAdminMenu(id);
    }
    else
    {
        Chat(id, "Panel sifresi hatali.");
        log_to_file(LOG_FILE, "PANEL LOGIN FAIL: %n UID:%d", id, g_iUID[id]);
    }

    return PLUGIN_HANDLED;
}

ShowAdminMenu(id)
{
    g_bAdminCosmeticTargetFlow[id] = false;
    if(!g_bPanelAuth[id] && !HasRole(id, ROLE_MANAGER))
    {
        RequestPanel(id);
        return;
    }

    new menu = FC_MenuCreate("\wYonetici Menusu", "H_AdminMain");
    FC_MenuAddItem(menu, "\wHesabi Prime Yap / Al", "1");
    FC_MenuAddItem(menu, "\wHesabi IsyanTeam Yap / Al", "2");
    FC_MenuAddItem(menu, "\wHesabi Yonetici Yap / Al", "3");
    FC_MenuAddItem(menu, "\rHesabi Banla / Ban Kaldir", "4");
    FC_MenuAddItem(menu, "\wUID Ara", "5");
    FC_MenuAddItem(menu, "\wTL Ver / Al", "6");
    FC_MenuAddItem(menu, "\wCoin Ver / Al", "7");
    FC_MenuAddItem(menu, "\wXP Ver / Al", "11");
    FC_MenuAddItem(menu, "\wKozmetik Ver / Al", "8");
    FC_MenuAddItem(menu, "\wINI Fiyatlarini Yenile", "9");
    FC_MenuAddItem(menu, "\rSohbeti Temizle", "10");
    FC_MenuSetProp(menu, MPROP_EXITNAME, "Geri");
    menu_display(id, menu);
}

public H_AdminMain(id, menu, item)
{
    if(!CanManageCosmetics(id))
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        ShowMainMenu(id);
        return PLUGIN_HANDLED;
    }

    new info[8], name[64], access, cb;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), cb);
    new key = str_to_num(info);
    menu_destroy(menu);

    switch(key)
    {
        case 1: g_iAdminOp[id] = AOP_ROLE_PRIME, ShowAdminGiveTake(id);
        case 2: g_iAdminOp[id] = AOP_ROLE_ISYAN, ShowAdminGiveTake(id);
        case 3: g_iAdminOp[id] = AOP_ROLE_MANAGER, ShowAdminGiveTake(id);
        case 4: ShowBanChoice(id);
        case 5:
        {
            client_cmd(id, "messagemode FC_UID_Ara");
            Chat(id, "UID veya oyuncunun son adini yaz.");
        }
        case 6: g_iAdminOp[id] = AOP_TL, ShowAdminTargetChoice(id);
        case 7: g_iAdminOp[id] = AOP_COIN, ShowAdminTargetChoice(id);
        case 11: g_iAdminOp[id] = AOP_XP, ShowAdminTargetChoice(id);
        case 8: StartAdminCosmeticFlow(id);
        case 9:
        {
            LoadConfig();
            QuizLoadQuestions();
            Chat(id, "INI degerleri yeniden okundu. Yeni model yolu icin map degisimi gerekir.");
            ShowAdminMenu(id);
        }
        case 10:
        {
            ClearServerChat(id);
            ShowAdminMenu(id);
        }
    }

    return PLUGIN_HANDLED;
}

ShowAdminGiveTake(id)
{
    new menu = FC_MenuCreate("\wUyelik Islemi", "H_AdminGiveTake");
    FC_MenuAddItem(menu, "\wUyelik Ver", "1");
    FC_MenuAddItem(menu, "\rUyelik Al", "2");
    FC_MenuSetProp(menu, MPROP_EXITNAME, "Geri");
    menu_display(id, menu);
}

public H_AdminGiveTake(id, menu, item)
{
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        ShowAdminMenu(id);
        return PLUGIN_HANDLED;
    }

    new info[8], name[64], access, cb;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), cb);
    g_bAdminTake[id] = (str_to_num(info) == 2);
    menu_destroy(menu);
    ShowAdminTargetChoice(id);
    return PLUGIN_HANDLED;
}

ShowBanChoice(id)
{
    new menu = FC_MenuCreate("\wHesap Ban Islemi", "H_BanChoice");
    FC_MenuAddItem(menu, "\rHesabi Banla", "1");
    FC_MenuAddItem(menu, "\wBan Kaldir", "2");
    FC_MenuSetProp(menu, MPROP_EXITNAME, "Geri");
    menu_display(id, menu);
}

public H_BanChoice(id, menu, item)
{
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        ShowAdminMenu(id);
        return PLUGIN_HANDLED;
    }

    new info[8], name[64], access, cb;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), cb);
    g_iAdminOp[id] = (str_to_num(info) == 1) ? AOP_BAN : AOP_UNBAN;
    menu_destroy(menu);
    ShowAdminTargetChoice(id);
    return PLUGIN_HANDLED;
}

bool:CanManageCosmetics(id)
{
    return is_user_connected(id) && (g_bPanelAuth[id] || HasRole(id, ROLE_MANAGER));
}

StartAdminCosmeticFlow(id)
{
    if(!CanManageCosmetics(id))
        return;
    g_bAdminCosmeticTargetFlow[id] = true;
    g_iAdminOp[id] = AOP_NONE;
    g_iAdminTargetUID[id] = 0;
    g_iAdminCos[id] = -1;
    ShowAdminTargetChoice(id);
}

ShowAdminCosAction(id)
{
    if(!CanManageCosmetics(id) || !nIsValidUid(g_iAdminTargetUID[id]))
        return;
    new title[128];
    formatex(title, charsmax(title), "\wKozmetik Islemi \d- UID:%d", g_iAdminTargetUID[id]);
    new menu = FC_MenuCreate(title, "H_AdminCosAction");
    FC_MenuAddItem(menu, "\wKozmetik Ver", "1");
    FC_MenuAddItem(menu, "\rKozmetik Al", "2");
    FC_MenuSetProp(menu, MPROP_EXITNAME, "Oyuncu Secimine Don");
    menu_display(id, menu);
}

public H_AdminCosAction(id, menu, item)
{
    if(!CanManageCosmetics(id))
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        StartAdminCosmeticFlow(id);
        return PLUGIN_HANDLED;
    }
    new info[8], name[64], access, cb;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), cb);
    new key = str_to_num(info);
    menu_destroy(menu);
    if(key != 1 && key != 2)
        return PLUGIN_HANDLED;
    g_iAdminOp[id] = (key == 1) ? AOP_COS_GIVE : AOP_COS_TAKE;
    ShowAdminCosList(id);
    return PLUGIN_HANDLED;
}

ShowAdminCosList(id)
{
    new uid = g_iAdminTargetUID[id];
    if(!CanManageCosmetics(id) || !nIsValidUid(uid))
        return;
    if(g_iAdminOp[id] != AOP_COS_GIVE && g_iAdminOp[id] != AOP_COS_TAKE)
        return;

    new bool:take = (g_iAdminOp[id] == AOP_COS_TAKE);
    new title[128], name[64], line[192], info[8], added, now = get_systime();
    formatex(title, charsmax(title), "\wKozmetik %s \d- UID:%d", take ? "Al" : "Ver", uid);
    new menu = FC_MenuCreate(title, "H_AdminCosList");
    for(new i; i < COS_ITEM_COUNT; i++)
    {
        if(!IsCosmeticEnabled(i))
            continue;
        new expiry = GetUIDCosExpiry(uid, i);
        if(take && expiry != 0 && expiry <= now)
            continue;

        CosCfgStr(i, "NAME", name, charsmax(name), g_CosPrefix[i]);
        if(expiry == 0)
            formatex(line, charsmax(line), "%s%s \w[\rSahip\w]", take ? "\w" : "\d", name);
        else if(expiry > now)
        {
            new remaining = expiry - now;
            new days = remaining / 86400 + ((remaining % 86400) ? 1 : 0);
            formatex(line, charsmax(line), "\w%s \w[\yKirali - %d gun kaldi\w]", name, days);
        }
        else
            formatex(line, charsmax(line), "\w%s", name);

        num_to_str(i, info, charsmax(info));
        FC_MenuAddItemCB(menu, line, info, g_iAdminCosCallback);
        added++;
    }
    if(!added)
        FC_MenuAddItemCB(menu, "\dOyuncunun envanterinde kozmetik yok.", "-1", g_iAdminCosCallback);
    FC_MenuSetProp(menu, MPROP_EXITNAME, "Geri");
    menu_display(id, menu);
}

public CB_AdminCosmetic(id, menu, item)
{
    new uid = g_iAdminTargetUID[id];
    if(!CanManageCosmetics(id) || !nIsValidUid(uid))
        return ITEM_DISABLED;
    new info[16], name[64], access, cb;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), cb);
    new idx = str_to_num(info);
    if(!IsCosmeticEnabled(idx))
        return ITEM_DISABLED;
    new expiry = GetUIDCosExpiry(uid, idx);
    if(g_iAdminOp[id] == AOP_COS_GIVE)
        return expiry == 0 ? ITEM_DISABLED : ITEM_ENABLED;
    if(g_iAdminOp[id] == AOP_COS_TAKE)
        return (expiry == 0 || expiry > get_systime()) ? ITEM_ENABLED : ITEM_DISABLED;
    return ITEM_DISABLED;
}

public H_AdminCosList(id, menu, item)
{
    if(!CanManageCosmetics(id))
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        ShowAdminCosAction(id);
        return PLUGIN_HANDLED;
    }
    new info[8], name[64], access, cb;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), cb);
    g_iAdminCos[id] = str_to_num(info);
    menu_destroy(menu);
    if(!IsCosmeticEnabled(g_iAdminCos[id]))
        return PLUGIN_HANDLED;
    ContinueAdminOperation(id);
    return PLUGIN_HANDLED;
}

ShowAdminTargetChoice(id)
{
    new menu = FC_MenuCreate("\wHedef Sec", "H_AdminTargetChoice");
    FC_MenuAddItem(menu, "\wOnline Oyuncu Sec", "1");
    FC_MenuAddItem(menu, "\wUID Gir", "2");
    FC_MenuSetProp(menu, MPROP_EXITNAME, "Geri");
    menu_display(id, menu);
}

public H_AdminTargetChoice(id, menu, item)
{
    if(!CanManageCosmetics(id))
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        ShowAdminMenu(id);
        return PLUGIN_HANDLED;
    }

    new info[8], name[64], access, cb;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), cb);
    new key = str_to_num(info);
    menu_destroy(menu);

    if(key == 1)
        ShowOnlineTargets(id);
    else
    {
        client_cmd(id, "messagemode FC_Admin_UID");
        Chat(id, "Hedef UID'yi yaz.");
    }

    return PLUGIN_HANDLED;
}

ShowOnlineTargets(id)
{
    new menu = FC_MenuCreate("\wOnline Hesaplar", "H_OnlineTarget");
    new name[64], line[96], info[8];

    for(new p = 1; p <= MaxClients; p++)
    {
        if(!is_user_connected(p) || g_iUID[p] <= 0)
            continue;

        get_user_name(p, name, charsmax(name));
        formatex(line, charsmax(line), "\w%s \d- UID:%d", name, g_iUID[p]);
        num_to_str(g_iUID[p], info, charsmax(info));
        FC_MenuAddItem(menu, line, info);
    }

    FC_MenuSetProp(menu, MPROP_EXITNAME, "Geri");
    menu_display(id, menu);
}

public H_OnlineTarget(id, menu, item)
{
    if(!CanManageCosmetics(id))
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        ShowAdminMenu(id);
        return PLUGIN_HANDLED;
    }

    new info[8], name[64], access, cb;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), cb);
    g_iAdminTargetUID[id] = str_to_num(info);
    menu_destroy(menu);
    ContinueAdminOperation(id);
    return PLUGIN_HANDLED;
}

public CmdAdminUID(id)
{
    if(!g_bPanelAuth[id] && !HasRole(id, ROLE_MANAGER))
        return PLUGIN_HANDLED;

    new text[32];
    read_args(text, charsmax(text));
    remove_quotes(text);
    trim(text);

    new uid = str_to_num(text);
    if(!nIsValidUid(uid))
    {
        Chat(id, "Gecersiz UID.");
        return PLUGIN_HANDLED;
    }

    g_iAdminTargetUID[id] = uid;
    ContinueAdminOperation(id);
    return PLUGIN_HANDLED;
}

ContinueAdminOperation(id)
{
    if(!CanManageCosmetics(id))
        return;
    if((g_iAdminOp[id] == AOP_COS_GIVE || g_iAdminOp[id] == AOP_COS_TAKE)
        && !IsCosmeticEnabled(g_iAdminCos[id]))
        return;

    new uid = g_iAdminTargetUID[id];
    if(!nIsValidUid(uid))
    {
        Chat(id, "Gecersiz UID.");
        return;
    }

    if(g_bAdminCosmeticTargetFlow[id])
    {
        g_bAdminCosmeticTargetFlow[id] = false;
        ShowAdminCosAction(id);
        return;
    }

    switch(g_iAdminOp[id])
    {
        case AOP_ROLE_PRIME, AOP_ROLE_ISYAN, AOP_ROLE_MANAGER:
        {
            if(g_bAdminTake[id])
            {
                SetUIDRoleExpiry(uid, AdminOpToRole(g_iAdminOp[id]), -1);
                LogAdmin(id, uid, "UYELIK ALINDI");
                Chat(id, "Uyelik UID %d hesabindan alindi.", uid);
                ShowAdminMenu(id);
            }
            else ShowAdminDuration(id);
        }
        case AOP_BAN:
        {
            SetAccountBan(uid, true);
            LogAdmin(id, uid, "HESAP BAN");
            Chat(id, "UID %d banlandi.", uid);
            ShowAdminMenu(id);
        }
        case AOP_UNBAN:
        {
            SetAccountBan(uid, false);
            LogAdmin(id, uid, "HESAP UNBAN");
            Chat(id, "UID %d bani kaldirildi.", uid);
            ShowAdminMenu(id);
        }
        case AOP_TL, AOP_COIN, AOP_XP:
        {
            client_cmd(id, "messagemode FC_Admin_Miktar");
            Chat(id, "Miktari yaz. Vermek icin pozitif, almak icin negatif deger kullan. Ornek: 500 veya -500");
        }
        case AOP_COS_GIVE:
        {
            if(GetUIDCosExpiry(uid, g_iAdminCos[id]) == 0)
            {
                Chat(id, "Oyuncu bu urune zaten ^4kalici olarak sahip^1.");
                ShowAdminCosList(id);
                return;
            }
            ShowAdminDuration(id);
        }
        case AOP_COS_TAKE:
        {
            new expiry = GetUIDCosExpiry(uid, g_iAdminCos[id]);
            if(expiry != 0 && expiry <= get_systime())
            {
                ShowAdminCosList(id);
                return;
            }
            SetUIDCosExpiry(uid, g_iAdminCos[id], -1);
            ClearUIDSelectedIfMatches(uid, g_iAdminCos[id]);
            LogAdmin(id, uid, "KOZMETIK ALINDI");
            Chat(id, "Kozmetik UID %d hesabindan alindi.", uid);
            ShowAdminCosList(id);
        }
    }
}

ShowAdminDuration(id)
{
    new menu = FC_MenuCreate("\wSure Sec", "H_AdminDuration");
    FC_MenuAddItem(menu, "\w1 Gun", "1");
    FC_MenuAddItem(menu, "\w1 Hafta", "7");
    FC_MenuAddItem(menu, "\w1 Ay", "30");
    FC_MenuAddItem(menu, "\yKalici", "0");
    FC_MenuSetProp(menu, MPROP_EXITNAME, "Geri");
    menu_display(id, menu);
}

public H_AdminDuration(id, menu, item)
{
    if(!CanManageCosmetics(id))
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        if(g_iAdminOp[id] == AOP_COS_GIVE) ShowAdminCosList(id);
        else ShowAdminMenu(id);
        return PLUGIN_HANDLED;
    }
    new info[8], name[64], access, cb;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), cb);
    new days = str_to_num(info);
    menu_destroy(menu);
    if(days != 0 && days != 1 && days != 7 && days != 30)
        return PLUGIN_HANDLED;

    new uid = g_iAdminTargetUID[id], expiry;
    if(!nIsValidUid(uid))
        return PLUGIN_HANDLED;
    SetExpiry(expiry, days);

    if(g_iAdminOp[id] == AOP_COS_GIVE)
    {
        new idx = g_iAdminCos[id];
        if(!IsCosmeticEnabled(idx))
            return PLUGIN_HANDLED;
        new previous = GetUIDCosExpiry(uid, idx);
        if(previous == 0)
        {
            Chat(id, "Oyuncu bu urune zaten ^4kalici olarak sahip^1.");
            ShowAdminCosList(id);
            return PLUGIN_HANDLED;
        }
        // Aktif kiralamaya sure eklerken kalan sure kaybolmaz.
        if(days > 0 && previous > get_systime())
            expiry = previous + days * 86400;
        SetUIDCosExpiry(uid, idx, expiry);
        LogAdmin(id, uid, "KOZMETIK VERILDI");
        Chat(id, "Kozmetik UID %d hesabina verildi.", uid);
        ShowAdminCosList(id);
        return PLUGIN_HANDLED;
    }
    if(g_iAdminOp[id] != AOP_ROLE_PRIME && g_iAdminOp[id] != AOP_ROLE_ISYAN && g_iAdminOp[id] != AOP_ROLE_MANAGER)
        return PLUGIN_HANDLED;
    SetUIDRoleExpiry(uid, AdminOpToRole(g_iAdminOp[id]), expiry);
    LogAdmin(id, uid, "UYELIK VERILDI");
    Chat(id, "Uyelik UID %d hesabina verildi.", uid);
    ShowAdminMenu(id);
    return PLUGIN_HANDLED;
}

public CmdAdminAmount(id)
{
    if(!g_bPanelAuth[id] && !HasRole(id, ROLE_MANAGER))
        return PLUGIN_HANDLED;

    new text[32];
    read_args(text, charsmax(text));
    remove_quotes(text);
    new amount = str_to_num(text);
    new uid = g_iAdminTargetUID[id];

    if(!nIsValidUid(uid) || amount == 0)
    {
        Chat(id, "Gecersiz UID veya miktar.");
        return PLUGIN_HANDLED;
    }

    if(g_iAdminOp[id] == AOP_TL)
    {
        new value = max(0, UIDGetInt(uid, "tl", 0) + amount);
        UIDSetInt(uid, "tl", value);
        SyncOnlineMoney(uid);
        LogAdmin(id, uid, "TL DEGISIMI");
        Chat(id, "UID %d yeni TL: %d", uid, value);
    }
    else if(g_iAdminOp[id] == AOP_COIN)
    {
        new value = max(0, UIDGetInt(uid, "coin", 0) + amount);
        UIDSetInt(uid, "coin", value);
        SyncOnlineMoney(uid);
        LogAdmin(id, uid, "COIN DEGISIMI");
        Chat(id, "UID %d yeni Coin: %d", uid, value);
    }
    else if(g_iAdminOp[id] == AOP_XP)
    {
        new oldXP = clamp(UIDGetInt(uid, "xp", 0), 0, GetMaxRankXP());
        new oldRank = GetRankByXP(oldXP);
        new newXP = clamp(oldXP + amount, 0, GetMaxRankXP());
        new newRank = GetRankByXP(newXP);

        UIDSetInt(uid, "xp", newXP);
        UIDSetInt(uid, "rank", newRank);

        // XP vererek rank atlatildiysa normal rank Coin odulleri de uygulanir.
        new rewardTotal = 0;
        if(newRank > oldRank)
        {
            for(new rank = oldRank + 1; rank <= newRank; rank++)
                rewardTotal += GetRankRewardCoin(rank);

            if(rewardTotal > 0)
            {
                new newCoin = max(0, UIDGetInt(uid, "coin", 0) + rewardTotal);
                UIDSetInt(uid, "coin", newCoin);
            }
        }

        SyncOnlineRankXP(uid);

        LogAdmin(id, uid, "XP DEGISIMI");

        new rankName[48];
        GetRankName(newRank, rankName, charsmax(rankName));
        Chat(id, "UID %d yeni XP: ^3%d/%d ^1| Rank: ^4%s", uid, newXP, GetMaxRankXP(), rankName);

        if(rewardTotal > 0)
            Chat(id, "Rank atlama odulu olarak hesaba ^4+%d Coin ^1eklendi.", rewardTotal);

        new online = nIsUidOnline(uid);
        if(online > 0 && is_user_connected(online))
        {
            if(amount > 0)
                Chat(online, "Yonetici tarafindan ^3%d XP ^1verildi. Yeni XP: ^3%d/%d", amount, newXP, GetMaxRankXP());
            else
                Chat(online, "Yonetici tarafindan ^3%d XP ^1alindi. Yeni XP: ^3%d/%d", -amount, newXP, GetMaxRankXP());
        }
    }

    ShowAdminMenu(id);
    return PLUGIN_HANDLED;
}

public CmdUIDSearch(id)
{
    if(!g_bPanelAuth[id] && !HasRole(id, ROLE_MANAGER))
        return PLUGIN_HANDLED;

    new text[64];
    read_args(text, charsmax(text));
    remove_quotes(text);
    trim(text);

    new uid = str_to_num(text);
    if(uid < 1000 || !nIsValidUid(uid))
        uid = nGetUidByName(text);

    if(!nIsValidUid(uid))
    {
        Chat(id, "Hesap bulunamadi.");
        return PLUGIN_HANDLED;
    }

    new lastName[32];
    nUidLastName(uid, lastName, charsmax(lastName));

    new p[48], i[48], m[48];
    FormatExpiry(UIDGetInt(uid,"role_prime",-1), p, charsmax(p));
    FormatExpiry(UIDGetInt(uid,"role_isyan",-1), i, charsmax(i));
    FormatExpiry(UIDGetInt(uid,"role_manager",-1), m, charsmax(m));

    new statusText[16];
    if(nGetUidStatus(uid)) copy(statusText, charsmax(statusText), "Aktif");
    else copy(statusText, charsmax(statusText), "Banli");
    Chat(id, "UID:^3%d ^1Ad:^4%s ^1Durum:^3%s", uid, lastName, statusText);
    Chat(id, "TL:^3%d ^1Coin:^4%d ^1| Prime:%s | Isyan:%s | Yonetici:%s",
        UIDGetInt(uid,"tl",0), UIDGetInt(uid,"coin",0), p,i,m);

    new searchXP = clamp(UIDGetInt(uid, "xp", 0), 0, GetMaxRankXP());
    new searchRank = GetRankByXP(searchXP);
    new searchRankName[48];
    GetRankName(searchRank, searchRankName, charsmax(searchRankName));
    Chat(id, "Rank:^4%s ^1| XP:^3%d/%d", searchRankName, searchXP, GetMaxRankXP());

    return PLUGIN_HANDLED;
}

AdminOpToRole(op)
{
    switch(op)
    {
        case AOP_ROLE_PRIME: return ROLE_PRIME;
        case AOP_ROLE_ISYAN: return ROLE_ISYANTEAM;
        case AOP_ROLE_MANAGER: return ROLE_MANAGER;
    }
    return ROLE_PRIME;
}

SetAccountBan(uid, bool:ban)
{
    nSetUidStatus(uid, ban ? 0 : 1);

    if(ban)
    {
        new online = nIsUidOnline(uid);
        if(online > 0 && is_user_connected(online))
        {
            nForwardExit(online);
            server_cmd("kick #%d ^"FeliciaClan: Hesabiniz yasaklandi.^"", get_user_userid(online));
        }
    }
}

SetUIDRoleExpiry(uid, role, expiry)
{
    new suffix[32];
    switch(role)
    {
        case ROLE_PRIME: copy(suffix, charsmax(suffix), "role_prime");
        case ROLE_ISYANTEAM: copy(suffix, charsmax(suffix), "role_isyan");
        case ROLE_MANAGER: copy(suffix, charsmax(suffix), "role_manager");
    }

    UIDSetInt(uid, suffix, expiry);

    new online = nIsUidOnline(uid);
    if(online > 0 && is_user_connected(online))
    {
        g_iRoleExpiry[online][role] = expiry;
        ValidateDisplayTagMode(online);
        SavePlayer(online);
    }
}

GetUIDCosExpiry(uid, idx)
{
    if(!IsCosmeticEnabled(idx) || uid <= 0)
        return -1;
    new online = nIsUidOnline(uid);
    if(online > 0 && online <= MaxClients && is_user_connected(online) && g_iUID[online] == uid)
        return g_iCosExpiry[online][idx];
    new suffix[48];
    formatex(suffix, charsmax(suffix), "cos_%d", idx);
    return UIDGetInt(uid, suffix, -1);
}

SetUIDCosExpiry(uid, idx, expiry)
{
    if(!IsCosmeticEnabled(idx))
        return;

    new suffix[48];
    formatex(suffix, charsmax(suffix), "cos_%d", idx);
    UIDSetInt(uid, suffix, expiry);

    new online = nIsUidOnline(uid);
    if(online > 0 && is_user_connected(online))
        g_iCosExpiry[online][idx] = expiry;
}

ClearUIDSelectedIfMatches(uid, cosIdx)
{
    if(!IsCosmeticEnabled(cosIdx))
        return;

    new kind = g_CosKind[cosIdx];
    new suffix[48];
    formatex(suffix, charsmax(suffix), "selected_%d", kind);

    if(UIDGetInt(uid, suffix, -1) == cosIdx)
        UIDSetInt(uid, suffix, -1);

    new online = nIsUidOnline(uid);
    if(online > 0 && is_user_connected(online) && g_iSelectedCos[online][kind] == cosIdx)
    {
        g_iSelectedCos[online][kind] = -1;
        ApplyCosmetics(online);
    }
}

SyncOnlineMoney(uid)
{
    new online = nIsUidOnline(uid);
    if(online > 0 && is_user_connected(online))
    {
        g_iTL[online] = UIDGetInt(uid, "tl", 0);
        g_iCoin[online] = UIDGetInt(uid, "coin", 0);
    }
}

SyncOnlineRankXP(uid)
{
    new online = nIsUidOnline(uid);
    if(online > 0 && is_user_connected(online))
    {
        g_iXP[online] = clamp(UIDGetInt(uid, "xp", 0), 0, GetMaxRankXP());
        g_iRank[online] = GetRankByXP(g_iXP[online]);
        g_iCoin[online] = UIDGetInt(uid, "coin", 0);
        SavePlayer(online);
    }
}

LogAdmin(admin, uid, const action[])
{
    log_to_file(LOG_FILE, "%s | Admin:%n UID:%d | Hedef UID:%d", action, admin, g_iUID[admin], uid);
}


// ============================================================
// CT TL VER / AL MENUSU
// /mg /mgver /tl /tlver
// ============================================================

ShowCTTLMenu(id)
{
    if(get_member(id, m_iTeam) != TEAM_CT)
    {
        Chat(id, "Bu menu sadece ^4CT takimi ^1icindir.");
        return;
    }

    new menu = FC_MenuCreate("\wTL Ver / Al", "H_CTTLFilter");
    FC_MenuAddItem(menu, "\wTum Mahkumlar", "1");
    FC_MenuAddItem(menu, "\wHayatta Olan Mahkumlar", "2");
    FC_MenuSetProp(menu, MPROP_EXITNAME, "Kapat");
    menu_display(id, menu);
}

public H_CTTLFilter(id, menu, item)
{
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }

    if(get_member(id, m_iTeam) != TEAM_CT)
    {
        menu_destroy(menu);
        Chat(id, "Bu menu sadece ^4CT takimi ^1icindir.");
        return PLUGIN_HANDLED;
    }

    new info[8], name[64], access, cb;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), cb);
    g_iCTTLFilter[id] = str_to_num(info);
    menu_destroy(menu);

    ShowCTTLPlayerList(id);
    return PLUGIN_HANDLED;
}

ShowCTTLPlayerList(id)
{
    new menu = FC_MenuCreate("\wMahkum Sec", "H_CTTLPlayer");
    new info[8], name[32], line[96], added;

    for(new p = 1; p <= MaxClients; p++)
    {
        if(!is_user_connected(p) || get_member(p, m_iTeam) != TEAM_TERRORIST)
            continue;

        if(g_iCTTLFilter[id] == 2 && !is_user_alive(p))
            continue;

        get_user_name(p, name, charsmax(name));
        num_to_str(p, info, charsmax(info));
        formatex(line, charsmax(line), "\w%s %s", name, is_user_alive(p) ? "\yCANLI" : "\rOLU");
        FC_MenuAddItem(menu, line, info);
        added++;
    }

    if(!added)
        FC_MenuAddItem(menu, "\dUygun mahkum bulunamadi.", "0");

    FC_MenuSetProp(menu, MPROP_EXITNAME, "Geri");
    menu_display(id, menu);
}

public H_CTTLPlayer(id, menu, item)
{
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        ShowCTTLMenu(id);
        return PLUGIN_HANDLED;
    }

    new info[8], name[64], access, cb;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), cb);
    new target = str_to_num(info);
    menu_destroy(menu);

    if(target < 1 || target > MaxClients || !is_user_connected(target) || get_member(target, m_iTeam) != TEAM_TERRORIST)
    {
        Chat(id, "Secilen mahkum artik kullanilabilir degil.");
        return PLUGIN_HANDLED;
    }

    g_iCTTLTarget[id] = target;
    ShowCTTLOperation(id);
    return PLUGIN_HANDLED;
}

ShowCTTLOperation(id)
{
    new target = g_iCTTLTarget[id];
    if(!is_user_connected(target))
        return;

    new name[32], title[128];
    get_user_name(target, name, charsmax(name));
    formatex(title, charsmax(title), "\w%s - TL Islemi", name);

    new menu = FC_MenuCreate(title, "H_CTTLOperation");
    FC_MenuAddItem(menu, "\wTL Ver", "1");
    FC_MenuAddItem(menu, "\rTL Al", "2");
    FC_MenuSetProp(menu, MPROP_EXITNAME, "Geri");
    menu_display(id, menu);
}

public H_CTTLOperation(id, menu, item)
{
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        ShowCTTLPlayerList(id);
        return PLUGIN_HANDLED;
    }

    new info[8], name[64], access, cb;
    menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), cb);
    g_iCTTLOperation[id] = str_to_num(info) == 1 ? CTTL_GIVE : CTTL_TAKE;
    menu_destroy(menu);

    if(get_member(id, m_iTeam) != TEAM_CT || !is_user_connected(g_iCTTLTarget[id]))
        return PLUGIN_HANDLED;

    client_cmd(id, "messagemode FC_CT_TL_Miktar");
    Chat(id, "Miktari yaz. Ornek: ^4 100");
    return PLUGIN_HANDLED;
}

public CmdCTTLAmount(id)
{
    if(get_member(id, m_iTeam) != TEAM_CT)
        return PLUGIN_HANDLED;

    new target = g_iCTTLTarget[id];
    if(target < 1 || target > MaxClients || !is_user_connected(target) || get_member(target, m_iTeam) != TEAM_TERRORIST)
    {
        Chat(id, "Hedef mahkum artik sunucuda degil.");
        return PLUGIN_HANDLED;
    }

    new input[24];
    read_args(input, charsmax(input));
    remove_quotes(input);
    trim(input);

    new amount = str_to_num(input);
    if(amount <= 0)
    {
        Chat(id, "Miktar ^4 0'dan buyuk ^1olmali.");
        return PLUGIN_HANDLED;
    }

    new guardName[32], prisonerName[32];
    get_user_name(id, guardName, charsmax(guardName));
    get_user_name(target, prisonerName, charsmax(prisonerName));

    if(g_iCTTLOperation[id] == CTTL_GIVE)
    {
        g_iTL[target] += amount;
        SavePlayer(target);
        Chat(0, "^4%s ^1gardiyan ^4%s ^1mahkuma ^3%d TL ^1verdi.", guardName, prisonerName, amount);
    }
    else if(g_iCTTLOperation[id] == CTTL_TAKE)
    {
        if(g_iTL[target] < amount)
        {
            Chat(id, "^4%s ^1adli mahkumda sadece ^3%d TL ^1var.", prisonerName, g_iTL[target]);
            return PLUGIN_HANDLED;
        }

        g_iTL[target] -= amount;
        SavePlayer(target);
        Chat(0, "^4%s ^1gardiyan ^4%s ^1mahkumdan ^3%d TL ^1aldi.", guardName, prisonerName, amount);
    }

    g_iCTTLOperation[id] = CTTL_NONE;
    g_iCTTLTarget[id] = 0;
    return PLUGIN_HANDLED;
}

// ============================================================
// ROLE HELPERS
// ============================================================

bool:HasRole(id, role)
{
    if(id < 1 || id > MaxClients || g_iUID[id] <= 0)
        return false;

    new exp = g_iRoleExpiry[id][role];
    return (exp == 0 || exp > LeaseNow());
}

bool:HasPrimeMarketAccess(id)
{
    return (HasRole(id, ROLE_PRIME) || HasRole(id, ROLE_MANAGER));
}

RefreshJumpLimit(id)
{
    if(id < 1 || id > MaxClients || !is_user_connected(id))
        return;

    g_iAirJumpLimit[id] = g_bCTHard ? 0 : ((HasRole(id, ROLE_PRIME) || HasRole(id, ROLE_MANAGER)) ? 2 : 1);
}

bool:CanDisplayTagMode(id, mode)
{
    switch(mode)
    {
        case TAGMODE_ISYANTEAM: return HasRole(id, ROLE_ISYANTEAM);
        case TAGMODE_PRIME: return HasRole(id, ROLE_PRIME);
        case TAGMODE_MULTI: return HasRole(id, ROLE_PRIME) && HasRole(id, ROLE_ISYANTEAM);
        case TAGMODE_MANAGER: return HasRole(id, ROLE_MANAGER);
    }
    return true;
}

ValidateDisplayTagMode(id)
{
    if(g_iDisplayTagMode[id] < TAGMODE_AUTO || g_iDisplayTagMode[id] >= TAGMODE_COUNT)
        g_iDisplayTagMode[id] = TAGMODE_AUTO;

    if(g_iDisplayTagMode[id] != TAGMODE_AUTO && !CanDisplayTagMode(id, g_iDisplayTagMode[id]))
        g_iDisplayTagMode[id] = TAGMODE_AUTO;
}

GetRoleName(id, out[], len)
{
    if(g_bGuestMode[id] || g_iUID[id] <= 0)
    {
        copy(out, len, "Misafir");
        return;
    }

    ValidateDisplayTagMode(id);

    switch(g_iDisplayTagMode[id])
    {
        case TAGMODE_ISYANTEAM:
        {
            copy(out, len, "IsyanTeam");
            return;
        }
        case TAGMODE_PRIME:
        {
            copy(out, len, "Prime");
            return;
        }
        case TAGMODE_MULTI:
        {
            copy(out, len, "Multi");
            return;
        }
        case TAGMODE_MANAGER:
        {
            copy(out, len, "Yonetici");
            return;
        }
    }

    // Otomatik gorunum: Yonetici > Multi > IsyanTeam > Prime > Uye.
    if(HasRole(id, ROLE_MANAGER)) copy(out, len, "Yonetici");
    else if(HasRole(id, ROLE_PRIME) && HasRole(id, ROLE_ISYANTEAM)) copy(out, len, "Multi");
    else if(HasRole(id, ROLE_ISYANTEAM)) copy(out, len, "IsyanTeam");
    else if(HasRole(id, ROLE_PRIME)) copy(out, len, "Prime");
    else copy(out, len, "Normal Uye");
}

// Absolute Unix deadlines remain unchanged on save/load. A monotonic in-map
// fallback keeps leases advancing even during a backwards/frozen clock adjustment.
LeaseNow() {
    new wall=get_systime();new Float:game=get_gametime();
    if(!g_iLeaseBase || game<g_flLeaseBase) {g_iLeaseBase=wall;g_flLeaseBase=game;}
    new elapsed=g_iLeaseBase+max(0,floatround(game-g_flLeaseBase,floatround_floor));
    if(wall>elapsed) {g_iLeaseBase=wall;g_flLeaseBase=game;return wall;}
    return elapsed;
}

// Only repaint the menu that is still ours, preserving the current page.
RefreshRentalMenu(id) {
    if(g_iRentalMenu[id]<0 || g_bRentalRefresh[id] || HW_Player(id)) return;
    new now=LeaseNow()/60;if(now==g_iRentalMinute[id]) return;
    g_iRentalMinute[id]=now;
    new oldmenu,menu,page;player_menu_info(id,oldmenu,menu,page);
    if(menu!=g_iRentalMenu[id]) {g_iRentalMenu[id]=-1;return;}
    new info[16],name[64],access,cb,line[192],itemName[64],remaining[32];
    for(new row=0;row<menu_items(menu);row++) {
        menu_item_getinfo(menu,row,access,info,charsmax(info),name,charsmax(name),cb);
        new idx=str_to_num(info);if(!IsCosmeticEnabled(idx)) continue;
        CosCfgStr(idx,"NAME",itemName,charsmax(itemName),g_CosPrefix[idx]);
        if(!OwnsCosmetic(id,idx)) formatex(line,charsmax(line),g_bRentalOwned[id]?"\d%s \w[\rSüresi Doldu\w]":"\w%s",itemName);
        else if(g_iCosExpiry[id][idx]>0) {
            FormatCosmeticRentalTime(g_iCosExpiry[id][idx],remaining,charsmax(remaining));
            new bool:active=g_bRentalOwned[id] && g_iSelectedCos[id][g_CosKind[idx]]==idx;
            formatex(line,charsmax(line),"%s%s \w[\y%s %s\w]",g_bRentalOwned[id]?(active?"\r":"\w"):"\d",itemName,active?"Aktif":"Kiralık",remaining);
        } else if(g_bRentalOwned[id]) formatex(line,charsmax(line),g_iSelectedCos[id][g_CosKind[idx]]==idx?"\r%s \w[\rAktif\w]":"\w%s",itemName);
        else formatex(line,charsmax(line),"\d%s \w[\rEnvanterinde\w]",itemName);
        new tagged[256];formatex(tagged,charsmax(tagged),"\r%s \y• %s",SHORT_TAG,line);
        menu_item_setname(menu,row,tagged);
    }
    g_bRentalRefresh[id]=true;menu_display(id,menu,page);g_bRentalRefresh[id]=false;
}

SetExpiry(&dest, days)
{
    if(days <= 0) dest = 0;
    else dest = LeaseNow() + days * 86400;
}

CosmeticRentalDaysLeft(expiry)
{
    new remaining = max(0, expiry - LeaseNow());
    // Son gunun bir kismi da kalsa 1 gun goster; kalici sahiplikte kullanilmaz.
    return remaining / 86400 + ((remaining % 86400) ? 1 : 0);
}

FormatCosmeticRentalTime(expiry, out[], len)
{
    new remaining = max(0, expiry - LeaseNow());
    if(remaining <= 0) {copy(out,len,"Süresi Doldu");return;}
    if(remaining >= 86400)
        formatex(out, len, "%d gün", CosmeticRentalDaysLeft(expiry));
    else if(remaining >= 3600)
        formatex(out, len, "%d saat", remaining / 3600);
    else
        formatex(out, len, "%d dakika", max(1, remaining / 60));
}

FormatExpiry(expiry, out[], len)
{
    if(expiry < 0)
    {
        copy(out, len, "Yok");
        return;
    }
    if(expiry == 0)
    {
        copy(out, len, "Kalici");
        return;
    }

    new left = expiry - LeaseNow();
    if(left <= 0)
    {
        copy(out, len, "Suresi Doldu");
        return;
    }

    new days = left / 86400;
    new hours = (left % 86400) / 3600;
    if(days > 0) formatex(out, len, "%d gun %d saat", days, hours);
    else formatex(out, len, "%d saat", max(1,hours));
}

CleanupExpired(id,bool:background=false)
{
    if(g_iUID[id] <= 0)
        return;

    new now = LeaseNow();
    if(background && g_fcExpiryCheck[id]==now) return;
    g_fcExpiryCheck[id]=now;
    new bool:changed;

    for(new r; r < ROLE_COUNT; r++)
    {
        if(g_iRoleExpiry[id][r] > 0 && g_iRoleExpiry[id][r] <= now)
        {
            g_iRoleExpiry[id][r] = -1;
            changed = true;
        }
    }

    for(new i; i < COS_ITEM_COUNT; i++)
    {
        if(g_iCosExpiry[id][i] > 0 && g_iCosExpiry[id][i] <= now)
        {
            g_iCosExpiry[id][i] = -1;
            if(g_iSelectedCos[id][g_CosKind[i]] == i)
                g_iSelectedCos[id][g_CosKind[i]] = -1;
            changed = true;
        }
    }

    if(changed)
    {
        ValidateDisplayTagMode(id);
        SavePlayer(id);
        ApplyCosmetics(id);
    }
}

ValidateSelectedCosmetics(id)
{
    if(g_iUID[id] <= 0)
        return;

    new bool:changed;
    for(new kind; kind < COS_KIND_COUNT; kind++)
    {
        new idx = g_iSelectedCos[id][kind];

        if(idx < 0)
            continue;

        if(idx >= COS_ITEM_COUNT || g_CosKind[idx] != kind || !OwnsCosmetic(id, idx))
        {
            g_iSelectedCos[id][kind] = -1;
            changed = true;
        }
    }

    if(changed)
        SavePlayer(id);
}

bool:OwnsCosmetic(id, idx)
{
    if(!IsCosmeticEnabled(idx))
        return false;

    new exp = g_iCosExpiry[id][idx];
    return (exp == 0 || exp > LeaseNow());
}


GetAliveTCount()
{
    new players[32], num;
    get_players(players, num, "ae", "TERRORIST");
    return num;
}

bool:CanUseJBMenu(id, bool:notify)
{
    if(HW_Player(id))
    {
        if(notify) Chat(id, "Aktif CT oyununda JBMenu geçici olarak kapalı.");
        return false;
    }
    if(g_bHadMultipleTThisRound && GetAliveTCount() == 1 && NoCTHasGuard())
    {
        if(notify && is_user_connected(id))
            Chat(id, "Tek mahkum varken ^4JBMenu kullanilamaz^1.");
        return false;
    }
    return true;
}

// ============================================================
// ECONOMY / DISCOUNT
// ============================================================

CalcPrice(id, base)
{
    if(base <= 0)
        return base;

    if(HasRole(id, ROLE_PRIME))
    {
        new Float:divider = CfgFloat("PRIME_PRICE_DIVIDER", 1.30);
        if(divider > 1.0)
            return floatround(float(base) / divider, floatround_ceil);
    }

    return base;
}

CalcRentPrice(id, base, multiplierX100)
{
    new price = (base * multiplierX100 + 99) / 100;
    return CalcPrice(id, price);
}

bool:PayTL(id, base)
{
    if(!CanUseJBMenu(id, true))
        return false;

    new price = CalcPrice(id, base);
    if(g_iTL[id] < price)
    {
        Chat(id, "Yeterli TL yok. Gereken: ^3%d TL", price);
        PlayFailSound(id);
        return false;
    }

    g_iTL[id] -= price;
    FC_RecordTLSpend(id,price);
    SavePlayer(id);
    return true;
}

bool:PayCoin(id, base)
{
    if(!CanUseJBMenu(id, true))
        return false;

    new price = CalcPrice(id, base);
    if(g_iCoin[id] < price)
    {
        Chat(id, "Yeterli Coin yok. Gereken: ^4%d Coin", price);
        PlayFailSound(id);
        return false;
    }

    FC_CoinChange(id,-price);
    SavePlayer(id);
    return true;
}

AddPriceItem(menu, id, const label[], const cfgKey[], defaultPrice, const info[])
{
    new line[160];
    formatex(line, charsmax(line), "\w%s \y- %d TL", label, CalcPrice(id, CfgInt(cfgKey, defaultPrice)));
    FC_MenuAddItem(menu, line, info);
}


// ============================================================
// BILDIRIM / HUD
// ============================================================

PurchaseSuccess(id, const itemName[])
{
    Chat(id, "^4%s ^1Basari Ile Satin Alindi.", itemName);
    PlaySuccessSound(id);

    if(g_iUID[id] > 0 && !equali(itemName, "T Ana Bicak") && !equali(itemName, "CT Ana Bicak"))
    {
        CheckDailyReset(id);
        g_iDailyPurchases[id]++;
        SavePlayer(id);
    }
}

RentSuccess(id, const itemName[], days)
{
    if(days == 1)
        Chat(id, "^4%s ^1Başarı İle ^3 1 Gün ^1Kiralandı.", itemName);
    else if(days == 7)
        Chat(id, "^4%s ^1Başarı İle ^3 7 Gün ^1Kiralandı.", itemName);
    else
        Chat(id, "^4%s ^1Başarı İle ^3 1 Ay ^1Kiralandı.", itemName);

    PlayRentSound(id);

    if(g_iUID[id] > 0)
    {
        CheckDailyReset(id);
        g_iDailyPurchases[id]++;
        SavePlayer(id);
    }
}

PlayConfigSound(id, const key[], const defaultSound[])
{
    new sound[96];
    CfgStr(key, sound, charsmax(sound), defaultSound);

    if(sound[0] && !equali(sound,"-") && !equali(sound,"xxx"))
        client_cmd(id, "spk ^"%s^"", sound);
}

PlaySuccessSound(id)
{
    PlayConfigSound(id, "PURCHASE_SUCCESS_SOUND", "fvox/activated.wav");
}

PlayRentSound(id)
{
    PlayConfigSound(id, "RENT_SUCCESS_SOUND", "fvox/bell.wav");
}

PlayEquipSound(id)
{
    PlayConfigSound(id, "EQUIP_SOUND", "buttons/button3.wav");
}

PlayFailSound(id)
{
    PlayConfigSound(id, "PURCHASE_FAIL_SOUND", "buttons/button2.wav");
}

public TaskHud()
{
    new hardNow = get_cvar_num("fc_ct_hard");
    if((hardNow != 0) != g_bCTHard) fc_ct_hard_changed(hardNow);
    new bool:hudEnabled = bool:CfgInt("HUD_ENABLE", 1);
    new now = get_systime();
    new aliveT = g_bHadMultipleTThisRound ? GetAliveTCount() : 0;
    new bool:lastPrisonerLocked = (g_bHadMultipleTThisRound && aliveT == 1 && NoCTHasGuard());

    new Float:x = 0.73, Float:y = 0.61, r = 235, g = 235, b = 235;
    if(hudEnabled)
    {
        x = CfgFloat("HUD_X", 0.73);
        y = CfgFloat("HUD_Y", 0.61);
        r = CfgInt("HUD_R", 235);
        g = CfgInt("HUD_G", 235);
        b = CfgInt("HUD_B", 235);
    }
    if(x < -1.0 || x > 0.80) x = 0.73;
    if(y < -1.0 || y > 0.65) y = 0.61;
    // Migrate the last release's default stored positions.
    if(floatabs(x-0.68)<0.001) x=0.73;
    if(floatabs(y-0.50)<0.001) y=0.61;
    r = clamp(r, 0, 255); g = clamp(g, 0, 255); b = clamp(b, 0, 255);
    if(r == 0 && g == 0 && b == 0) r = g = b = 235;

    new fr = clamp(CfgInt("HUD_T_TITLE_R", 255), 0, 255);
    new fg = clamp(CfgInt("HUD_T_TITLE_G", 0), 0, 255);
    new fb = clamp(CfgInt("HUD_T_TITLE_B", 0), 0, 255);
    if(fr == 0 && fg == 0 && fb == 0) fr = 255, fg = 0, fb = 0;

    new cr=clamp(CfgInt("HUD_CT_TITLE_R",0),0,255),cg=clamp(CfgInt("HUD_CT_TITLE_G",80),0,255),cb=clamp(CfgInt("HUD_CT_TITLE_B",255),0,255);
    if(!cr && !cg && !cb) cr=0,cg=80,cb=255;

    new hpThiefSec = CfgInt("PROF_HPTHIEF_SECONDS", 8);
    new hpThiefAdd = CfgInt("PROF_HPTHIEF_HP", 5);
    new hpThiefMax = CfgInt("PROF_HPTHIEF_MAXHP", 250);

    for(new id = 1; id <= MaxClients; id++)
    {
        if(!is_user_connected(id))
            continue;

        new clanLine[96];
        GetClanHudLine(id, clanLine, charsmax(clanLine));
        CleanupExpired(id,true);
        RefreshRentalMenu(id);
        new TeamName:team=get_member(id,m_iTeam);
        if(g_iHudTeam[id]!=_:team) {ClearJBHud(id);g_iHudTeam[id]=_:team;}
        if(HW_Player(id) && team!=TEAM_CT) {if(g_bInfoHudShown[id]) ClearJBHud(id);continue;}
        if(team!=TEAM_TERRORIST && team!=TEAM_CT) {if(g_bInfoHudShown[id]) ClearJBHud(id);continue;}
        if(team==TEAM_CT && LibraryExists("fc_ctmenu",LibType_Library)) {
            if((!hudEnabled && !g_bForceHud[id]) || g_iHudMode[id]==HUDMODE_OFF) {if(g_bInfoHudShown[id]) ClearJBHud(id);continue;}
            new ctGame=fc_ct_game_id();
            if(ctGame==12 || ctGame==13) {if(g_bInfoHudShown[id]) ClearJBHud(id);continue;}
            if(!fc_ct_hud_visible(id)) {if(g_bInfoHudShown[id]) ClearJBHud(id);continue;}
            new ctText[384],ctRole[24],ctPanel[432];GetRoleName(id,ctRole,charsmax(ctRole));
            fc_ct_hud_text(id,ctText,charsmax(ctText));
            if(g_iUID[id]>0) formatex(ctPanel,charsmax(ctPanel),"Uyelik: %s^nUID: %d^n%s^n%s",ctRole,g_iUID[id],clanLine,ctText);
            else formatex(ctPanel,charsmax(ctPanel),"Uyelik: Misafir^nUID: -^n%s^n%s",clanLine,ctText);
            ShowJBHud(id,ctPanel,r,g,b,x,y,cr,cg,cb);continue;
        }

        // 2X/3X sonucu PreThink'te her frame hesaplanmaz; saniyede bir cache edilir.
        g_iAirJumpLimit[id] = g_bCTHard ? 0 : ((HasRole(id, ROLE_PRIME) || HasRole(id, ROLE_MANAGER)) ? 2 : 1);

        // HP Hirsizi meslegi ayni server tick'inde calisir; ikinci repeating timer yoktur.
        if(is_user_alive(id) && get_member(id, m_iTeam) == TEAM_TERRORIST && g_iProfession[id] == PROF_HPTHIEF)
        {
            if(hpThiefSec > 0 && now - g_iLastProfessionTick[id] >= hpThiefSec)
            {
                g_iLastProfessionTick[id] = now;

                new Float:professionHp;
                get_entvar(id, var_health, professionHp);

                if(floatround(professionHp) < hpThiefMax)
                    set_entvar(id, var_health, float(min(hpThiefMax, floatround(professionHp) + hpThiefAdd)));
            }
        }

        if((!hudEnabled && !g_bForceHud[id]) || g_iHudMode[id] == HUDMODE_OFF) {if(g_bInfoHudShown[id]) ClearJBHud(id);continue;}

        new hp = 0;
        if(is_user_alive(id))
        {
            new Float:currentHealth;
            get_entvar(id, var_health, currentHealth);
            hp = floatround(currentHealth);
        }
        new jumpCount = g_iAirJumpLimit[id] + 1;
        new lockLine[48], hudText[384];

        if(lastPrisonerLocked)
            copy(lockLine, charsmax(lockLine), "^nJBMenu: KILITLI [Son Mahkum]");
        else
            lockLine[0] = 0;

        // Bir saniyelik yenilemede tek bir kayip/gecikmis paket HUD'u sondurmez.
        // Normal HUD kullanilir; DHUD soru/cekilis mesajlarinin yuvalari tuketilmez.

        if(g_iUID[id] <= 0)
        {
            if(g_iHudMode[id] == HUDMODE_COMPACT)
                formatex(hudText, charsmax(hudText),
                    "Uyelik: Misafir^nUID: -^n%s^nHP: %d | TL: %d^nMeslek: %s^nZipla: %dX%s",
                    clanLine, hp, g_iTL[id], g_ProfessionNames[g_iProfession[id]], jumpCount, lockLine);
            else
                formatex(hudText, charsmax(hudText),
                    "Uyelik: Misafir^nUID: -^n%s^nHP: %d | TL: %d^nMeslek: %s^nZipla: %dX%s",
                    clanLine, hp, g_iTL[id], g_ProfessionNames[g_iProfession[id]], jumpCount, lockLine);

            ShowJBHud(id, hudText, r, g, b, x, y, fr, fg, fb);
            continue;
        }

        new role[24], rank[48], xpLine[64], progress = 100;
        GetRoleName(id, role, charsmax(role));
        GetRankName(g_iRank[id], rank, charsmax(rank));

        if(g_iRank[id] >= MAX_RANKS-1)
            copy(xpLine, charsmax(xpLine), "MAX");
        else
        {
            new currentNeed = GetRankNeedXP(g_iRank[id]);
            new nextNeed = GetRankNeedXP(g_iRank[id]+1);
            new span = max(1, nextNeed - currentNeed);
            progress = clamp((g_iXP[id] - currentNeed) * 100 / span, 0, 100);
            formatex(xpLine, charsmax(xpLine), "%d/%d (%d%%)", g_iXP[id], nextNeed, progress);
        }

        if(g_iHudMode[id] == HUDMODE_COMPACT)
            formatex(hudText, charsmax(hudText),
                "Uyelik: %s^nUID: %d^n%s^nHP:%d | TL:%d^nCoin: %d^n%s%s",
                role, g_iUID[id], clanLine, hp, g_iTL[id], g_iCoin[id], rank, lockLine);
        else
            formatex(hudText, charsmax(hudText),
                "Uyelik: %s^nUID: %d^n%s^nHP: %d | TL: %d^nCoin: %d^nRank: %s^nXP: %s^nMeslek: %s%s",
                role, g_iUID[id], clanLine, hp, g_iTL[id], g_iCoin[id], rank, xpLine,
                g_ProfessionNames[g_iProfession[id]], lockLine);

        ShowJBHud(id, hudText, r, g, b, x, y, fr, fg, fb);
    }
}


ShowJBHud(id, const text[], r, g, b, Float:x, Float:y, fr, fg, fb) {
    if(g_iHudMode[id]==HUDMODE_FULL) QueueDetailHud(id,text,r,g,b,x,y,fr,fg,fb);
    else {g_bDetailHud[id]=false;FC_ShowInfoHud(id,text,r,g,b,x,y,fr,fg,fb);}
    g_bInfoHudShown[id]=true;
}
ClearJBHud(id) {g_bDetailHud[id]=false;g_iDetailStamp[id]=-1;FC_ClearInfoHud(id);g_bInfoHudShown[id]=false;}

EnableJBHud(id)
{
    if(!is_user_connected(id))
        return;
    ClearJBHud(id);
    g_iHudMode[id] = HUDMODE_FULL;
    g_bForceHud[id] = true;
    SavePlayer(id);
    Chat(id, "Sag alt HUD ^4acildi^1. Gorunumu degistirmek icin ^4/hud^1 kullan.");
    TaskHud();
}

CycleHudMode(id)
{
    ClearJBHud(id);

    g_iHudMode[id]++;
    if(g_iHudMode[id] >= HUDMODE_COUNT)
        g_iHudMode[id] = HUDMODE_FULL;

    new mode[24];
    switch(g_iHudMode[id])
    {
        case HUDMODE_FULL: copy(mode, charsmax(mode), "Detayli");
        case HUDMODE_COMPACT: copy(mode, charsmax(mode), "Kompakt");
        case HUDMODE_OFF: copy(mode, charsmax(mode), "Kapali");
    }

    SavePlayer(id);
    Chat(id, "HUD modu: ^4%s", mode);
}

PrecacheNotificationSounds()
{
    new sound[96], full[128];

    CfgStr("PURCHASE_SUCCESS_SOUND", sound, charsmax(sound), "fvox/activated.wav");
    if(sound[0] && !equali(sound,"-") && !equali(sound,"xxx"))
    {
        formatex(full, charsmax(full), "sound/%s", sound);
        if(file_exists(full))
            precache_sound(sound);
    }

    CfgStr("PURCHASE_FAIL_SOUND", sound, charsmax(sound), "buttons/button2.wav");
    if(sound[0] && !equali(sound,"-") && !equali(sound,"xxx"))
    {
        formatex(full, charsmax(full), "sound/%s", sound);
        if(file_exists(full))
            precache_sound(sound);
    }

    CfgStr("RENT_SUCCESS_SOUND", sound, charsmax(sound), "fvox/bell.wav");
    if(sound[0] && !equali(sound,"-") && !equali(sound,"xxx"))
    {
        formatex(full, charsmax(full), "sound/%s", sound);
        if(file_exists(full))
            precache_sound(sound);
    }

    CfgStr("EQUIP_SOUND", sound, charsmax(sound), "buttons/button3.wav");
    if(sound[0] && !equali(sound,"-") && !equali(sound,"xxx"))
    {
        formatex(full, charsmax(full), "sound/%s", sound);
        if(file_exists(full))
            precache_sound(sound);
    }

    CfgStr("CRATE_SPIN_SOUND", sound, charsmax(sound), "buttons/blip1.wav");
    if(sound[0] && !equali(sound,"-") && !equali(sound,"xxx"))
    {
        formatex(full, charsmax(full), "sound/%s", sound);
        if(file_exists(full)) precache_sound(sound);
    }

    CfgStr("CRATE_WIN_SOUND", sound, charsmax(sound), "fvox/bell.wav");
    if(sound[0] && !equali(sound,"-") && !equali(sound,"xxx"))
    {
        formatex(full, charsmax(full), "sound/%s", sound);
        if(file_exists(full)) precache_sound(sound);
    }
}

// ============================================================
// SPAWN / DAMAGE / KILL / KNIFE
// ============================================================

public EventRoundStart()
{
    // Keep the HUD state across rounds instead of clearing and replaying it.
    g_iDetailRound++;
    for(new hudId=1;hudId<=MaxClients;hudId++) {if(g_bDetailHud[hudId]) g_iDetailStamp[hudId]=g_iDetailRound;}
    remove_task(TASK_DETAIL_START);
    set_task(0.1,"TaskHud",TASK_DETAIL_START);
    g_bHadMultipleTThisRound = false;
    g_iJBRoundStamp=max(g_iJBRoundStamp+1,get_systime());

    for(new id = 1; id <= MaxClients; id++)
    {
        if(!is_user_connected(id))
            continue;

        CancelProfessionActions(id);
        g_bDonateUsedRound[id] = false;
        g_bSoundSentRound[id] = false;
        g_bSpecialKnifeBought[id] = false;
        g_bMainAdUsed[id] = false;
        g_bDoubleDamage[id] = false;
        g_bDamageShield[id] = false;
        g_bSilentSteps[id] = false;
        g_bVampire[id] = false;
        if(is_user_alive(id)) rg_set_user_footsteps(id, false);
        // Only the per-round change permission resets; the selected profession
        // stays attached to the loaded account and is saved unchanged.
        g_bProfessionChosenRound[id] = false;
        if(g_iUID[id]>0 && g_bProfileLoaded[id]) UIDSetInt(g_iUID[id],"profession",g_iProfession[id]);
        g_iHPBought[id]=0;g_bBonusRound[id]=false;StopPreview(id,false);
        g_bLuckyUsedRound[id] = false;
        remove_task(id + TASK_LUCKY_REVIVE);
        CleanupExpired(id);
    }
}

public EventRoundEnd()
{
    for(new id = 1; id <= MaxClients; id++)
    {
        if(g_iUID[id] <= 0 || !is_user_alive(id))
            continue;

        if(get_member(id, m_iTeam) == TEAM_TERRORIST)
        {
            CheckDailyReset(id);
            g_iDailySurvives[id]++;
            SavePlayer(id);
        }
    }
}

public HC_Spawn_Post(id)
{
    CancelProfessionActions(id);
    if(is_user_alive(id) && (get_member(id,m_iTeam)==TEAM_TERRORIST || get_member(id,m_iTeam)==TEAM_CT)) NoCTForgetJoin(id);
    StopPreview(id,false);CancelSpawnWork(id);g_iLifeSerial[id]++;g_iProfessionApplied[id]=-1;
    FC_InvalidateActivityCache();
    if(!LibraryExists("fc_ctmenu",LibType_Library) || (fc_ct_game_id()<=0
        && !(g_bRocketAPI && fc_ct_rocket_active() && fc_ct_rocket_is_player(id)))) g_bCTJoined[id]=false;
    if(hogwarts_state()==HW_OFF) g_bHWJoined[id]=false;
    if(HW_Player(id)) {
        // A revived player is a fresh life even while the active game owns UI.
        if(LibraryExists("fc_ctmenu",LibType_Library) && fc_ct_game_id()>0) g_bCTJoined[id]=true;
        g_bSpecialKnifeBought[id]=g_bMainAdUsed[id]=g_bDoubleDamage[id]=g_bDamageShield[id]=false;
        g_bSilentSteps[id]=g_bVampire[id]=false;g_iAirJumps[id]=0;
        g_iBaseKnife[id]=get_member(id,m_iTeam)==TEAM_TERRORIST?0:get_member(id,m_iTeam)==TEAM_CT?1:-1;
        return;
    }
    if(!is_user_alive(id))
        return;

    g_bSpecialKnifeBought[id] = false;
    g_bMainAdUsed[id] = false;
    g_bDoubleDamage[id] = false;
    g_bDamageShield[id] = false;
    g_bSilentSteps[id] = false;
    g_bVampire[id] = false;
    g_iAirJumps[id] = 0;
    RefreshJumpLimit(id);

    rg_set_user_footsteps(id, false);
    set_entvar(id, var_gravity, 1.0);
    set_entvar(id, var_takedamage, DAMAGE_AIM);
    rg_set_user_rendering(id);

    switch(get_member(id, m_iTeam))
    {
        case TEAM_TERRORIST: g_iBaseKnife[id] = 0;
        case TEAM_CT: g_iBaseKnife[id] = 1;
        default: g_iBaseKnife[id] = -1;
    }

    if(GetAliveTCount() >= 2)
        g_bHadMultipleTThisRound = true;

    rg_give_item(id, "weapon_knife", GT_REPLACE);
    QueueProfessionSpawn(id,0.4);
    set_task(0.35, "TaskApplyCosmetics", id);

    // T oyuncusu her dogdugunda Ana Market otomatik acilir.
    // AutoLogin hesabi 2-3 saniye sonra yuklenebildigi icin hesap hazir degilse kisa sure retry yapilir.
    if(get_member(id, m_iTeam) == TEAM_TERRORIST)
    {
        menu_cancel(id);g_iRentalMenu[id]=-1;ClearJBHud(id);
        QueueSpawnMenu(id,0.85);
    }
}

public TaskSpawnMenu(taskid)
{
    new id = taskid - TASK_SPAWN_MENU;
    if(id<1 || id>MaxClients || !is_user_connected(id) || g_iSpawnMenuSession[id]!=get_user_userid(id) || g_iSpawnMenuLife[id]!=g_iLifeSerial[id]) return;
    if(HW_Player(id)) return;

    if(!is_user_alive(id) || get_member(id, m_iTeam) != TEAM_TERRORIST)
        return;

    if(g_iUID[id] > 0 || g_bGuestMode[id])
    {
        if(CanUseJBMenu(id, false))
            ShowMainMarket(id);

        g_iSpawnMenuTry[id] = 0;
        return;
    }

    // AutoLogin henuz tamamlanmadiysa en fazla 5 kez daha dene.
    if(++g_iSpawnMenuTry[id] <= 5)
        set_task(0.75, "TaskSpawnMenu", id + TASK_SPAWN_MENU);
}

public Fwd_PlayerPreThink(id)
{
    if(HW_Player(id)) return FMRES_IGNORED;
    if(!is_user_alive(id))
    {
        if(id >= 1 && id <= MaxClients)
            g_iAirJumps[id] = 0;
        return FMRES_IGNORED;
    }

    if(g_bProfessionZhonyaActive[id])
    {
        new Float:zero[3] = {0.0, 0.0, 0.0};
        set_entvar(id, var_velocity, zero);
        g_iAirJumps[id] = 0;
        return FMRES_IGNORED;
    }

    if(g_bCTHard) return FMRES_IGNORED;
    if(get_entvar(id, var_movetype) != MOVETYPE_WALK)
        return FMRES_IGNORED;

    new flags = get_entvar(id, var_flags);
    if(flags & FL_FROZEN) {g_iAirJumps[id]=0;return FMRES_IGNORED;}
    if(flags & FL_ONGROUND)
    {
        g_iAirJumps[id] = 0;
        return FMRES_IGNORED;
    }

    new buttons = get_entvar(id, var_button);
    new oldbuttons = get_entvar(id, var_oldbuttons);

    // Normal/Misafir/IsyanTeam = toplam 2X (1 hava ziplamasi)
    // Prime veya Yonetici = toplam 3X (2 hava ziplamasi)
    new maxAirJumps = g_iAirJumpLimit[id] > 0 ? g_iAirJumpLimit[id] : 1;

    if((buttons & IN_JUMP) && !(oldbuttons & IN_JUMP) && g_iAirJumps[id] < maxAirJumps)
    {
        new Float:velocity[3];
        get_entvar(id, var_velocity, velocity);
        velocity[2] = CfgFloat("DOUBLE_JUMP_POWER", 285.0);
        set_entvar(id, var_velocity, velocity);
        g_iAirJumps[id]++;
    }

    return FMRES_IGNORED;
}

public HC_Deploy_Pre(const weapon, szViewModel[], szWeaponModel[], anim, szAnimExt[], skiplocal)
{
    new id = get_member(weapon, m_pPlayer);
    if(!is_user_alive(id) || get_member(weapon, m_iId) != WEAPON_KNIFE)
        return;

    if(HW_Player(id)) return;

    new v[96], p[96];
    new base = (get_member(id, m_iTeam) == TEAM_CT) ? 1 : g_iBaseKnife[id];
    if(base < 0 || base > 4)
        base = (get_member(id, m_iTeam) == TEAM_CT) ? 1 : 0;

    // Skin incelemesi aciksa ve kullanici skinleri gosteriyorsa preview kullan.
    if(g_bKnifeSkinsVisible[id] && g_iPreviewCos[id]>=0
        && g_CosKind[g_iPreviewCos[id]]==COS_KNIFE)
    {
        SetHookChainArg(2,ATYPE_STRING,g_szPreviewAsset[g_iPreviewCos[id]]);
        return;
    }

    // Kisisel ayar kapaliysa envanter kozmetik skinini atla.
    // Ana Market'ten satin alinmis bicak modeli base olarak uygulanmaya devam eder.
    new cos = g_iSelectedCos[id][COS_KNIFE];
    if(g_bKnifeSkinsVisible[id] && cos >= 0
        && OwnsCosmetic(id, cos) && CanUseCosmetic(id, cos))
    {
        CosCfgStr(cos, "VMODEL", v, charsmax(v), "xxx");
        CosCfgStr(cos, "PMODEL", p, charsmax(p), "xxx");

        if(IsRealAsset(v)) SetHookChainArg(2, ATYPE_STRING, v);
        if(IsRealAsset(p)) SetHookChainArg(3, ATYPE_STRING, p);
        return;
    }

    // Skin gizliyken veya oyuncu bir kozmetik skin kullanmiyorken Ana Market bicagi.
    BaseKnifeModels(base, v, charsmax(v), p, charsmax(p));
    if(IsRealAsset(v)) SetHookChainArg(2, ATYPE_STRING, v);
    if(IsRealAsset(p)) SetHookChainArg(3, ATYPE_STRING, p);
}

public HC_TakeDamage_Pre(victim, inflictor, attacker, Float:damage, bits)
{
    if(victim >= 1 && victim <= MaxClients && g_bProfessionZhonyaActive[victim])
    {
        SetHookChainReturn(ATYPE_INTEGER, 0);
        return HC_SUPERCEDE;
    }

    if(attacker >= 1 && attacker <= MaxClients && g_bProfessionZhonyaActive[attacker])
    {
        SetHookChainReturn(ATYPE_INTEGER, 0);
        return HC_SUPERCEDE;
    }

    if(HW_Player(victim) || HW_Player(attacker)) return HC_CONTINUE;
    if(attacker < 1 || attacker > MaxClients || victim < 1 || victim > MaxClients || attacker == victim)
        return HC_CONTINUE;

    if(g_bDoubleDamage[attacker]) damage *= 2.0;
    if(g_bDamageShield[victim]) damage *= 0.5;

    if(get_user_weapon(attacker) == CSW_KNIFE && g_iBaseKnife[attacker] >= 0)
    {
        new baseDamage = BaseKnifeDamage(g_iBaseKnife[attacker]);
        if(baseDamage > 0)
        {
            new bool:head = (get_member(victim, m_LastHitGroup) == HIT_HEAD);
            damage = float(baseDamage + (head ? CfgInt("KNIFE_HEAD_BONUS",15) : 0));
        }
    }

    if(g_bVampire[attacker] && is_user_alive(attacker))
    {
        new percent = clamp(CfgInt("ATTACK_VAMPIRE_PERCENT",25), 1, 100);
        new maxhp = max(100, CfgInt("ATTACK_VAMPIRE_MAXHP",200));
        new heal = max(1, floatround(damage * float(percent) / 100.0));
        new Float:hp;
        get_entvar(attacker, var_health, hp);
        if(floatround(hp) < maxhp)
            set_entvar(attacker, var_health, float(min(maxhp, floatround(hp) + heal)));
    }

    SetHookChainArg(4, ATYPE_FLOAT, damage);
    return HC_CONTINUE;
}

public HC_Killed_Post(victim, attacker)
{
    CancelProfessionActions(victim);
    if(victim>=1 && victim<=MaxClients) NoCTForgetJoin(victim);
    StopPreview(victim,false);CancelSpawnWork(victim);
    if(HW_Player(victim) || HW_Player(attacker)) return;
    if(victim >= 1 && victim <= MaxClients && is_user_connected(victim) && get_member(victim, m_iTeam) == TEAM_TERRORIST)
    {
        new luckyChance = max(1, CfgInt("PROF_LUCKY_CHANCE",5));
        if(g_iProfession[victim] == PROF_LUCKY && !g_bLuckyUsedRound[victim] && random_num(1,luckyChance) == 1)
        {
            g_bLuckyUsedRound[victim] = true;
            set_task(1.5, "TaskLuckyRespawn", victim + TASK_LUCKY_REVIVE);
            Chat(victim, "^4Sansli Adam ^1meslegi devreye girdi. Tekrar doguyorsun!");
        }
    }

    if(attacker < 1 || attacker > MaxClients || attacker == victim || !is_user_connected(attacker))
        return;

    // Gardiyan istatistigi: CT takimindayken T oldurme.
    if(get_member(attacker, m_iTeam) == TEAM_CT && get_member(victim, m_iTeam) == TEAM_TERRORIST)
    {
        if(g_iUID[attacker] > 0 && LegitStatKill(attacker, victim))
        {
            g_iCTKills[attacker]++;
            SavePlayer(attacker);
        }

        PlayKillEffect(attacker, victim);
        return;
    }

    // JailBreak ekonomisi / Isyanci istatistigi: sadece T'nin CT oldurmesi.
    if(get_member(attacker, m_iTeam) != TEAM_TERRORIST || get_member(victim, m_iTeam) != TEAM_CT)
    {
        PlayKillEffect(attacker, victim);
        return;
    }

    if(!LegitRewardKill(attacker, victim))
    {
        PlayKillEffect(attacker, victim);
        return;
    }

    // Misafir: sadece TL kazanir; Coin/gorev/uyelik/kalici kayit yoktur.
    if(g_bGuestMode[attacker] && g_iUID[attacker] <= 0)
    {
        new guestTL = CfgInt("KILL_TL", 3);
        g_iTL[attacker] += guestTL;
        g_iLastRewardKill[attacker][victim] = get_systime();
        Chat(attacker, "Kill odulu: ^3+%d TL ^1[Misafir]", guestTL);
        return;
    }

    new addTL = CfgInt("KILL_TL", 3);
    new addCoin = CfgInt("KILL_COIN", 0);

    g_iRebelKills[attacker]++;
    g_iTL[attacker] += addTL;
    FC_CoinChange(attacker,addCoin);
    g_iLastRewardKill[attacker][victim] = get_systime();

    CheckDailyReset(attacker);
    g_iDailyKills[attacker]++;

    new killXP = CfgInt("RANK_KILL_XP", 20);
    AddXP(attacker, killXP);

    if(g_iProfession[attacker] == PROF_PUNISHER)
    {
        new extraTL = CfgInt("PROF_PUNISHER_KILL_TL", 2);
        g_iTL[attacker] += extraTL;
        Chat(attacker, "Punisher bonusu: ^3+%d TL", extraTL);
    }

    SavePlayer(attacker);
    Chat(attacker, "Kill odulu: ^3+%d TL ^1/ ^4+%d Coin ^1/ ^3+%d XP", addTL, addCoin, killXP);
    PlayKillEffect(attacker, victim);
}

bool:LegitRewardKill(attacker, victim)
{
    new anti = CfgInt("ANTI_FARM_SECONDS",30);
    new now = get_systime();

    if(anti > 0 && now - g_iLastRewardKill[attacker][victim] < anti)
        return false;

    new ipa[32], ipv[32];
    get_user_ip(attacker, ipa, charsmax(ipa), 1);
    get_user_ip(victim, ipv, charsmax(ipv), 1);
    if(ipa[0] && equal(ipa, ipv))
        return false;

    return true;
}

bool:LegitStatKill(attacker, victim)
{
    new anti = CfgInt("ANTI_FARM_SECONDS",30);
    new now = get_systime();

    if(anti > 0 && now - g_iLastStatKill[attacker][victim] < anti)
        return false;

    new ipa[32], ipv[32];
    get_user_ip(attacker, ipa, charsmax(ipa), 1);
    get_user_ip(victim, ipv, charsmax(ipv), 1);

    if(ipa[0] && equal(ipa, ipv))
        return false;

    g_iLastStatKill[attacker][victim] = now;
    return true;
}
BaseKnifeDamage(index)
{
    switch(index)
    {
        case 0: return CfgInt("MAIN_T_DAMAGE",15);
        case 1: return CfgInt("MAIN_CT_DAMAGE",80);
        case 2: return CfgInt("MAIN_MINUS2_DAMAGE",30);
        case 3: return CfgInt("MAIN_MINUS2_2_DAMAGE",30);
        case 4: return CfgInt("MAIN_SAW_DAMAGE",200);
    }
    return 0;
}
BaseKnifeModels(index, v[], vlen, p[], plen)
{
    switch(index)
    {
        case 0:
        {
            CfgStr("MAIN_T_VMODEL",v,vlen,"xxx");
            CfgStr("MAIN_T_PMODEL",p,plen,"xxx");
        }
        case 1:
        {
            CfgStr("MAIN_CT_VMODEL",v,vlen,"xxx");
            CfgStr("MAIN_CT_PMODEL",p,plen,"xxx");
        }
        case 2:
        {
            CfgStr("MAIN_MINUS2_VMODEL",v,vlen,"xxx");
            CfgStr("MAIN_MINUS2_PMODEL",p,plen,"xxx");
        }
        case 3:
        {
            CfgStr("MAIN_MINUS2_2_VMODEL",v,vlen,"xxx");
            CfgStr("MAIN_MINUS2_2_PMODEL",p,plen,"xxx");
        }
        case 4:
        {
            CfgStr("MAIN_SAW_VMODEL",v,vlen,"xxx");
            CfgStr("MAIN_SAW_PMODEL",p,plen,"xxx");
        }
        default:
        {
            copy(v,vlen,"xxx");
            copy(p,plen,"xxx");
        }
    }
}

// ============================================================
// COSMETIC APPLY
// ============================================================

public EventCosmeticTeamInfo()
{
    new id = read_data(1);
    if(id>=1 && id<=MaxClients && is_user_connected(id)) {ClearJBHud(id);g_iHudTeam[id]=-1;g_iRentalMenu[id]=-1;}
    if(id < 1 || id > MaxClients || !is_user_connected(id))
        return;

    NoCTQueueJoin(id);NoCTRefreshLater();

    StopPreview(id,false);
    new team = get_member(id, m_iTeam);
    if(team == g_iLastCosmeticTeam[id])
        return;

    g_iLastCosmeticTeam[id] = team;
    if(team != _:TEAM_TERRORIST)
        CancelProfessionActions(id);
    if(HW_Player(id))
        return;

    remove_task(id);
    g_bSpecialKnifeBought[id] = false;
    g_bMainAdUsed[id] = false;
    switch(team)
    {
        case TEAM_TERRORIST: g_iBaseKnife[id] = 0;
        case TEAM_CT: g_iBaseKnife[id] = 1;
        default: g_iBaseKnife[id] = -1;
    }

    // T disina cikinca gorunen varliklar ve model ayni olayda temizlenir.
    // T'ye donuste ekipman secimleri kayitlardan silinmeden geri uygulanir.
    if(team != _:TEAM_TERRORIST)
        ApplyCosmetics(id);
    else
        set_task(0.15, "TaskApplyCosmetics", id);
}

public TaskApplyCosmetics(id)
{
    if(is_user_connected(id))
        ApplyCosmetics(id);
}

ApplyCosmetics(id)
{
    if(HW_Player(id)) return;
    if(!is_user_connected(id))
        return;

    RemoveCosmeticEntities(id);
    if(!is_user_alive(id) || get_member(id, m_iTeam) != TEAM_TERRORIST)
    {
        ResetCosmeticPlayerModel(id);
        RefreshActiveKnifeModels(id);
        return;
    }

    CleanupExpired(id);
    rg_set_user_rendering(id);

    // Player model
    new idx = g_iSelectedCos[id][COS_PLAYER];
    if(idx >= 0 && OwnsCosmetic(id,idx) && CanUseCosmetic(id,idx))
    {
        new modelName[64];
        CosCfgStr(idx, "MODELNAME", modelName, charsmax(modelName), "xxx");
        if(modelName[0] && !equali(modelName,"xxx") && !equali(modelName,"..."))
        {
            rg_set_user_model(id, modelName);
            g_bCosmeticPlayerModel[id] = true;
        }
        else
            ResetCosmeticPlayerModel(id);
    }
    else
        ResetCosmeticPlayerModel(id);

    // Pet: oyuncunun yaninda serbestce takip eden 3D model.
    idx = g_iSelectedCos[id][COS_RETIRED_PET];
    if(idx >= 0 && OwnsCosmetic(id,idx) && CanUseCosmetic(id,idx))
        CreatePetCosmetic(id,idx);

    // Wing
    idx = g_iSelectedCos[id][COS_WING];
    if(idx >= 0 && OwnsCosmetic(id,idx) && CanUseCosmetic(id,idx))
        CreateWingCosmetic(id, idx);

    EmitTrail(id);
    RefreshActiveKnifeModels(id);
}

ResetCosmeticPlayerModel(id)
{
    if(!g_bCosmeticPlayerModel[id])
        return;

    rg_reset_user_model(id);
    g_bCosmeticPlayerModel[id] = false;
}

RefreshActiveKnifeModels(id)
{
    if(HW_Player(id) || !is_user_alive(id) || get_user_weapon(id) != CSW_KNIFE)
        return;

    new v[96], p[96];
    new base = (get_member(id, m_iTeam) == TEAM_CT) ? 1 : g_iBaseKnife[id];
    if(base < 0 || base > 4)
        base = (get_member(id, m_iTeam) == TEAM_CT) ? 1 : 0;
    BaseKnifeModels(base, v, charsmax(v), p, charsmax(p));

    // Envanter skinini yalnizca kullanici skinleri goruyorsa uygula.
    new idx = g_iSelectedCos[id][COS_KNIFE];
    if(g_bKnifeSkinsVisible[id] && OwnsCosmetic(id, idx) && CanUseCosmetic(id, idx))
    {
        new custom[96];
        CosCfgStr(idx, "VMODEL", custom, charsmax(custom), "xxx");
        if(IsRealAsset(custom)) copy(v, charsmax(v), custom);
        CosCfgStr(idx, "PMODEL", custom, charsmax(custom), "xxx");
        if(IsRealAsset(custom)) copy(p, charsmax(p), custom);
    }

    if(!IsRealAsset(v)) copy(v, charsmax(v), "models/v_knife.mdl");
    if(!IsRealAsset(p)) copy(p, charsmax(p), "models/p_knife.mdl");
    set_entvar(id, var_viewmodel, v);
    set_entvar(id, var_weaponmodel, p);
}

bool:CanUseCosmeticMenu(id, bool:notify)
{
    if(is_user_connected(id) && get_member(id, m_iTeam) == TEAM_TERRORIST)
        return CanUseJBMenu(id,notify);

    if(notify && is_user_connected(id))
        Chat(id, "Kozmetik menusu sadece ^4T takimi ^1icindir.");
    return false;
}

bool:CanUseCosmetic(id, idx)
{
    if(!IsCosmeticEnabled(idx) || !is_user_connected(id)
        || get_member(id, m_iTeam) != TEAM_TERRORIST)
        return false;

    if(g_CosSource[idx] == SOURCE_PRIME_MENU)
        return HasPrimeMarketAccess(id);

    return true;
}

CreateWingCosmetic(id, idx)
{
    new model[96];
    CosCfgStr(idx, "MODEL", model, charsmax(model), "xxx");
    if(!IsRealAsset(model))
        return;

    new ent = create_entity("info_target");
    if(!is_valid_ent(ent))
        return;

    entity_set_string(ent, EV_SZ_classname, "fc_wing");
    entity_set_model(ent, model);
    entity_set_int(ent, EV_INT_movetype, MOVETYPE_FOLLOW);
    entity_set_edict(ent, EV_ENT_aiment, id);
    entity_set_edict(ent, EV_ENT_owner, id);
    entity_set_int(ent, EV_INT_solid, SOLID_NOT);

    g_iWingEnt[id] = ent;
}

new g_iPetAnim[33];
new bool:g_bPetMoving[33];

CreatePetCosmetic(id, idx)
{
    new model[96];
    CosCfgStr(idx, "MODEL", model, charsmax(model), "xxx");
    if(!IsRealAsset(model)) return;

    new ent = create_entity("info_target");
    if(!is_valid_ent(ent)) return;
    entity_set_string(ent, EV_SZ_classname, "fc_pet");
    entity_set_model(ent, model);
    entity_set_int(ent, EV_INT_movetype, MOVETYPE_NOCLIP);
    entity_set_int(ent, EV_INT_solid, SOLID_NOT);
    entity_set_edict(ent, EV_ENT_owner, id);
    new Float:origin[3];
    entity_get_vector(id, EV_VEC_origin, origin);
    origin[0] += 35.0;
    new Float:floorStart[3], Float:floorEnd[3], Float:floorHit[3];
    floorStart[0] = origin[0]; floorStart[1] = origin[1]; floorStart[2] = origin[2] + 48.0;
    floorEnd[0] = origin[0]; floorEnd[1] = origin[1]; floorEnd[2] = origin[2] - 160.0;
    engfunc(EngFunc_TraceLine, floorStart, floorEnd, IGNORE_MONSTERS, id, 0);
    get_tr2(0, TR_vecEndPos, floorHit);
    new heightCfg[32];
    CosCfgStr(idx, "HEIGHT_OFFSET", heightCfg, charsmax(heightCfg), "2.0");
    origin[2] = floorHit[2] + str_to_float(heightCfg);
    entity_set_origin(ent, origin);
    entity_set_int(ent, EV_INT_sequence, 0);
    entity_set_float(ent, EV_FL_frame, 0.0);
    entity_set_float(ent, EV_FL_animtime, get_gametime());
    entity_set_float(ent, EV_FL_framerate, 1.0);
    g_iPetAnim[id] = -1;
    g_bPetMoving[id] = false;
    g_iPetEnt[id] = ent;
}

// Smooth, ground-aware companion movement. Per-model offsets and sequences live in INI.
public TaskPetFollow()
{
    for(new id = 1; id <= MaxClients; id++)
    {
        new ent = g_iPetEnt[id];
        if(ent <= 0 || !is_valid_ent(ent)) continue;
        if(!is_user_alive(id) || get_member(id, m_iTeam) != TEAM_TERRORIST || HW_Player(id))
        {
            remove_entity(ent);
            g_iPetEnt[id] = 0;
            g_iPetAnim[id] = -1;
            g_bPetMoving[id] = false;
            continue;
        }

        new idx = g_iSelectedCos[id][COS_RETIRED_PET];
        if(idx < 0 || idx >= COS_ITEM_COUNT) continue;

        new Float:pos[3], Float:ang[3], Float:pet[3], Float:target[3];
        entity_get_vector(id, EV_VEC_origin, pos);
        entity_get_vector(id, EV_VEC_v_angle, ang);
        entity_get_vector(ent, EV_VEC_origin, pet);
        new Float:yaw = ang[1];
        target[0] = pos[0] - floatsin(yaw, degrees) * 48.0 - floatcos(yaw, degrees) * 34.0;
        target[1] = pos[1] + floatcos(yaw, degrees) * 48.0 - floatsin(yaw, degrees) * 34.0;

        // Trace vertically to the actual floor instead of using the player's origin Z.
        new Float:start[3], Float:finish[3], Float:ground[3];
        start[0] = target[0]; start[1] = target[1]; start[2] = pos[2] + 48.0;
        finish[0] = target[0]; finish[1] = target[1]; finish[2] = pos[2] - 160.0;
        engfunc(EngFunc_TraceLine, start, finish, IGNORE_MONSTERS, id, 0);
        get_tr2(0, TR_vecEndPos, ground);
        new cfg[32];
        CosCfgStr(idx, "HEIGHT_OFFSET", cfg, charsmax(cfg), "2.0");
        new Float:heightOffset = str_to_float(cfg);
        target[2] = ground[2] + heightOffset;

        new Float:dx = target[0] - pet[0];
        new Float:dy = target[1] - pet[1];
        new Float:horizontal = floatsqroot(dx * dx + dy * dy);
        new Float:dist = get_distance_f(pet, target);
        new Float:vel[3];
        // Hysteresis prevents switching idle/walk every tick near the player.
        new moving = g_bPetMoving[id] ? (horizontal > 15.0) : (horizontal > 26.0);
        g_bPetMoving[id] = bool:moving;
        if(dist > 450.0)
        {
            entity_set_origin(ent, target);
            vel[0] = 0.0; vel[1] = 0.0; vel[2] = 0.0;
            moving = 0;
        }
        else
        {
            // Velocity is interpolated by the GoldSrc engine between timer ticks.
            // Proportional speed catches up quickly but slows near the owner.
            CosCfgStr(idx, "FOLLOW_SPEED", cfg, charsmax(cfg), "320.0");
            new Float:maxSpeed = floatmax(80.0, str_to_float(cfg));
            new Float:speed = floatmin(maxSpeed, horizontal * 5.0);
            if(moving && horizontal > 0.01)
            {
                vel[0] = dx / horizontal * speed;
                vel[1] = dy / horizontal * speed;
            }
            else { vel[0] = 0.0; vel[1] = 0.0; }
            // Vertical velocity follows steps without repeated teleports.
            vel[2] = floatmax(-180.0, floatmin(180.0, (target[2] - pet[2]) * 7.0));
        }
        entity_set_vector(ent, EV_VEC_velocity, vel);

        if(moving)
        {
            new Float:direction[3];
            direction[0] = dx; direction[1] = dy; direction[2] = 0.0;
            vector_to_angle(direction, ang);
            CosCfgStr(idx, "ANGLE_OFFSET", cfg, charsmax(cfg), "0");
            ang[0] = 0.0; ang[1] += str_to_float(cfg); ang[2] = 0.0;
            entity_set_vector(ent, EV_VEC_angles, ang);
        }

        CosCfgStr(idx, moving ? "WALK_SEQUENCE" : "IDLE_SEQUENCE", cfg, charsmax(cfg), moving ? "1" : "0");
        new seq = max(0, str_to_num(cfg));
        if(g_iPetAnim[id] != seq)
        {
            entity_set_int(ent, EV_INT_sequence, seq);
            entity_set_float(ent, EV_FL_frame, 0.0);
            entity_set_float(ent, EV_FL_animtime, get_gametime());
            entity_set_float(ent, EV_FL_framerate, 1.0);
            g_iPetAnim[id] = seq;
        }
    }
}

RemoveCosmeticEntities(id)
{
    if(g_iPetEnt[id] > 0 && is_valid_ent(g_iPetEnt[id])) remove_entity(g_iPetEnt[id]);
    g_iPetEnt[id] = 0;
    g_bPetMoving[id] = false;
    g_iPetAnim[id] = -1;
    if(g_iWingEnt[id] > 0 && is_valid_ent(g_iWingEnt[id])) remove_entity(g_iWingEnt[id]);
    g_iWingEnt[id] = 0;
    KillTrail(id);
}

KillTrail(id)
{
    if(id < 1 || id > MaxClients || !g_bTrailActive[id])
        return;

    // Her istemcide bu oyuncuya ait mevcut trail'i temizle.
    for(new target=1;target<=MaxClients;target++)
    {
        if(!is_user_connected(target))
            continue;

        message_begin(MSG_ONE_UNRELIABLE,SVC_TEMPENTITY,{0,0,0},target);
        write_byte(TE_KILLBEAM);
        write_short(id);
        message_end();
    }

    g_bTrailActive[id] = false;
    g_flTrailExpiresAt[id] = 0.0;
}

public TaskVisualRefresh()
{
    new Float:now = get_gametime();
    for(new id = 1; id <= MaxClients; id++)
    {
        if(HW_Player(id))
            continue;

        if(!is_user_alive(id) || get_member(id, m_iTeam) != TEAM_TERRORIST)
        {
            KillTrail(id);
            continue;
        }

        new idx = g_iSelectedCos[id][COS_TRAIL];
        if(idx >= 0 && OwnsCosmetic(id,idx) && CanUseCosmetic(id,idx))
        {
            new bool:refresh = !g_bTrailActive[id];
            if(g_bTrailActive[id])
            {
                // BeamFollow yeni bir parca eklemek icin yaklasik 32 birim hareket
                // bekler. Hareket eden oyuncunun izini surekli kesip yeniden cizmeyiz.
                new Float:origin[3], Float:distanceSq;
                get_entvar(id, var_origin, origin);
                for(new axis; axis < 3; axis++)
                {
                    new Float:delta = origin[axis] - g_vecTrailParticleOrigin[id][axis];
                    distanceSq += delta * delta;
                }
                if(distanceSq >= 1024.0)
                {
                    if(now >= g_flTrailExpiresAt[id])
                        refresh = true;
                    else
                    {
                        for(new axis; axis < 3; axis++)
                            g_vecTrailParticleOrigin[id][axis] = origin[axis];
                        g_flTrailExpiresAt[id] = now + g_flTrailLife[id];
                    }
                }
            }

            // Durunca butun parcaciklar solup istemcideki beam de bitebilir.
            // Yeniden hareket edince yenile; sabit duran oyuncuya tekrar tekrar
            // paket gonderme ve istemcide beam biriktirme.
            if(refresh)
            {
                KillTrail(id);
                EmitTrail(id);
            }
        }
        else
        {
            KillTrail(id);
        }
    }
}

stock SendTrailToClient(owner,target,idx,trailLife,r,g,b)
{
    if(!is_user_connected(target) || !g_bTrailsVisible[target])
        return;

    message_begin(MSG_ONE_UNRELIABLE,SVC_TEMPENTITY,{0,0,0},target);
    write_byte(TE_BEAMFOLLOW);
    write_short(owner);
    write_short(g_iSpriteIndex[idx]);
    write_byte(trailLife);
    write_byte(6);
    write_byte(r);
    write_byte(g);
    write_byte(b);
    write_byte(180);
    message_end();
}

stock ClearTrailsForClient(target)
{
    if(target<1 || target>MaxClients || !is_user_connected(target))
        return;

    for(new owner=1;owner<=MaxClients;owner++)
    {
        if(!g_bTrailActive[owner])
            continue;

        message_begin(MSG_ONE_UNRELIABLE,SVC_TEMPENTITY,{0,0,0},target);
        write_byte(TE_KILLBEAM);
        write_short(owner);
        message_end();
    }
}

stock RefreshTrailsForClient(target)
{
    if(target<1 || target>MaxClients || !is_user_connected(target)
        || !g_bTrailsVisible[target])
        return;

    for(new owner=1;owner<=MaxClients;owner++)
    {
        if(!g_bTrailActive[owner] || !is_user_alive(owner)
            || get_member(owner,m_iTeam)!=TEAM_TERRORIST || HW_Player(owner))
            continue;

        new idx=g_iSelectedCos[owner][COS_TRAIL];
        if(idx<0 || !OwnsCosmetic(owner,idx) || !CanUseCosmetic(owner,idx)
            || g_iSpriteIndex[idx]<=0)
            continue;

        new rgb[48],r,g,b;
        CosCfgStr(idx,"RGB",rgb,charsmax(rgb),"170,0,255");
        ParseRGB(rgb,r,g,b);
        new trailLife=clamp(floatround(CfgFloat("TRAIL_LIFE_SECONDS",1.5)*10.0),3,50);
        SendTrailToClient(owner,target,idx,trailLife,r,g,b);
    }
}

EmitTrail(id)
{
    if(HW_Player(id)) return;
    new idx = g_iSelectedCos[id][COS_TRAIL];
    if(idx < 0 || !OwnsCosmetic(id,idx) || !CanUseCosmetic(id,idx) || g_iSpriteIndex[idx] <= 0)
        return;

    new rgb[48], r,g,b;
    CosCfgStr(idx, "RGB", rgb, charsmax(rgb), "170,0,255");
    ParseRGB(rgb,r,g,b);

    // TE_BEAMFOLLOW omru 0.1 saniye birimindedir; sadece iz segmentleri solar.
    new trailLife = clamp(floatround(CfgFloat("TRAIL_LIFE_SECONDS", 1.5) * 10.0), 3, 50);

    for(new target=1;target<=MaxClients;target++)
        SendTrailToClient(id,target,idx,trailLife,r,g,b);

    g_bTrailActive[id] = true;
    g_flTrailLife[id] = float(trailLife) / 10.0;
    g_flTrailExpiresAt[id] = get_gametime() + g_flTrailLife[id];
    get_entvar(id, var_origin, g_vecTrailParticleOrigin[id]);
}

PlayKillEffect(attacker, victim)
{
    if(HW_Player(victim) || HW_Player(attacker)) return;
    if(attacker < 1 || attacker > MaxClients || victim < 1 || victim > MaxClients)
        return;

    new idx = g_iSelectedCos[attacker][COS_KILLFX];
    if(idx < 0 || !OwnsCosmetic(attacker,idx) || !CanUseCosmetic(attacker,idx) || g_iSpriteIndex[idx] <= 0)
        return;

    new Float:origin[3];
    get_entvar(victim, var_origin, origin);

    for(new target=1;target<=MaxClients;target++)
    {
        if(!is_user_connected(target) || !g_bDeathEffectsVisible[target])
            continue;

        message_begin(MSG_ONE_UNRELIABLE,SVC_TEMPENTITY,origin,target);
        write_byte(TE_EXPLOSION);
        write_coord_f(origin[0]);
        write_coord_f(origin[1]);
        write_coord_f(origin[2] + 20.0);
        write_short(g_iSpriteIndex[idx]);
        write_byte(8);
        write_byte(12);
        write_byte(TE_EXPLFLAG_NOSOUND | TE_EXPLFLAG_NODLIGHTS);
        message_end();
    }
}

// ============================================================
// DAILY / PLAYTIME
// ============================================================

CheckDailyReset(id)
{
    if(g_iUID[id] <= 0)
        return;

    new date[16];
    get_time("%Y%m%d", date, charsmax(date));
    new stamp = str_to_num(date);

    if(g_iDailyStamp[id] != stamp)
    {
        g_iDailyStamp[id] = stamp;
        g_iDailyKills[id] = 0;
        g_iDailyPlayMinutes[id] = 0;
        g_iDailyCrates[id] = 0;
        g_iDailyPurchases[id] = 0;
        g_iDailySurvives[id] = 0;
        g_iTaskClaimMask[id] = 0;
        SavePlayer(id);
    }
}

public TaskPlayMinute()
{
    for(new id = 1; id <= MaxClients; id++)
    {
        if(!is_user_connected(id))
            continue;

        CleanupExpired(id);
        RefreshRentalMenu(id);
        g_iPlayMinutes[id]++;

        // Misafirin meslek odulleri sadece oturumluk TL olarak calisabilir.
        if(g_iProfession[id] == PROF_HOUSEWIFE)
        {
            new interval = CfgInt("PROF_HOUSEWIFE_MINUTES", 3);
            if(interval > 0 && (g_iPlayMinutes[id] % interval) == 0)
            {
                new tl = CfgInt("PROF_HOUSEWIFE_TL", 4);
                g_iTL[id] += tl;
                Chat(id, "Ev Hanimi meslek odulu: ^3+%d TL", tl);
            }
        }

        if(g_iUID[id] <= 0)
            continue;

        if(get_member(id, m_iTeam) == TEAM_CT)
            g_iCTMinutes[id]++;

        CheckDailyReset(id);
        g_iDailyPlayMinutes[id]++;

        SavePlayer(id);
    }
}

// ============================================================
// COSMETIC META / CONFIG
// ============================================================

bool:IsCosmeticKindEnabled(kind)
{
    return (kind >= 0 && kind < COS_KIND_COUNT
        && kind != COS_RETIRED_AURA);
}

bool:IsCosmeticEnabled(idx)
{
    if(idx < 0 || idx >= COS_ITEM_COUNT || !IsCosmeticKindEnabled(g_CosKind[idx]))
        return false;
    if(idx >= 28 && g_CosKind[idx] == COS_PLAYER)
    {
        new model[128], modelname[64];
        CosCfgStr(idx, "MODELFILE", model, charsmax(model), "xxx");
        CosCfgStr(idx, "MODELNAME", modelname, charsmax(modelname), "xxx");
        return IsRealAsset(model) && IsRealAsset(modelname);
    }
    // Modeli tanimlanmamis kanatlar bos market/envanter/inceleme satiri uretmez.
    if(g_CosKind[idx] == COS_WING || g_CosKind[idx] == COS_RETIRED_PET)
    {
        new model[96];
        CosCfgStr(idx, "MODEL", model, charsmax(model), "");
        return (model[0] && !equali(model,"xxx") && !equali(model,"...") && !equali(model,"-"));
    }
    return true;
}

bool:HasConfiguredPet(source = -1)
{
    for(new i; i < COS_ITEM_COUNT; i++)
        if(g_CosKind[i] == COS_RETIRED_PET && (source < 0 || g_CosSource[i] == source) && IsCosmeticEnabled(i))
            return true;
    return false;
}

bool:HasConfiguredWing(source = -1)
{
    for(new i; i < COS_ITEM_COUNT; i++)
        if(g_CosKind[i] == COS_WING && (source < 0 || g_CosSource[i] == source) && IsCosmeticEnabled(i))
            return true;
    return false;
}

CosBasePrice(idx)
{
    new key[96];
    formatex(key, charsmax(key), "%s_PRICE", g_CosPrefix[idx]);
    return CfgInt(key, 100);
}


CosCfgStr(idx, const suffix[], out[], len, const def[])
{
    new key[96];
    formatex(key, charsmax(key), "%s_%s", g_CosPrefix[idx], suffix);
    CfgStr(key, out, len, def);
}

CosKindName(kind)
{
    static text[32];
    switch(kind)
    {
        case COS_KNIFE: copy(text, charsmax(text), "Bicak Skinleri");
        case COS_PLAYER: copy(text, charsmax(text), "Karakter Modelleri");
        case COS_WING: copy(text, charsmax(text), "Kanatlar");
        case COS_RETIRED_PET: copy(text, charsmax(text), "Petler");
        case COS_KILLFX: copy(text, charsmax(text), "Oldurme Efektleri");
        case COS_TRAIL: copy(text, charsmax(text), "Trail");
        default: copy(text, charsmax(text), "Kozmetik");
    }
    return text;
}

ParseRGB(const text[], &r, &g, &b)
{
    new temp[64], sr[8], sg[8], sb[8];
    copy(temp, charsmax(temp), text);
    replace_all(temp, charsmax(temp), ",", " ");
    parse(temp, sr,7,sg,7,sb,7);
    r = clamp(str_to_num(sr),0,255);
    g = clamp(str_to_num(sg),0,255);
    b = clamp(str_to_num(sb),0,255);
}

bool:IsRealAsset(const path[])
{
    if(!path[0] || equali(path,"xxx") || equali(path,"...") || equali(path,"-"))
        return false;
    return file_exists(path) ? true : false;
}

PrecacheConfiguredAssets()
{
    new path[128];
    precache_model("models/w_usp.mdl");

    // Ana bicak modelleri
    new const knifeKeys[][] = {
        "MAIN_T_VMODEL","MAIN_T_PMODEL","MAIN_CT_VMODEL","MAIN_CT_PMODEL",
        "MAIN_MINUS2_VMODEL","MAIN_MINUS2_PMODEL",
        "MAIN_MINUS2_2_VMODEL","MAIN_MINUS2_2_PMODEL",
        "MAIN_SAW_VMODEL","MAIN_SAW_PMODEL"
    };

    for(new i; i < sizeof knifeKeys; i++)
    {
        CfgStr(knifeKeys[i], path, charsmax(path), "xxx");
        if(IsRealAsset(path)) precache_model(path);
    }

    // Ana Market bicaklarinin ucuncu sahis P-model indeksleri.
    for(new base=0; base<5; base++)
    {
        new vModel[96], pModel[96];
        BaseKnifeModels(base, vModel, charsmax(vModel), pModel, charsmax(pModel));
        if(IsRealAsset(pModel))
            g_iBaseKnifePModelIndex[base] = engfunc(EngFunc_ModelIndex, pModel);
        else
            g_iBaseKnifePModelIndex[base] = g_iDefaultPKnifeModel;
    }

    for(new i; i < COS_ITEM_COUNT; i++)
    {
        g_iSpriteIndex[i] = 0;g_iPreviewAssetIndex[i]=0;g_szPreviewAsset[i][0]=0;

        if(!IsCosmeticEnabled(i))
            continue;

        switch(g_CosKind[i])
        {
            case COS_KNIFE:
            {
                CosCfgStr(i,"VMODEL",path,charsmax(path),"xxx"); if(IsRealAsset(path)) {g_iPreviewAssetIndex[i]=precache_model(path);copy(g_szPreviewAsset[i],charsmax(g_szPreviewAsset[]),path);}
                CosCfgStr(i,"PMODEL",path,charsmax(path),"xxx"); if(IsRealAsset(path)) precache_model(path);
            }
            case COS_PLAYER:
            {
                CosCfgStr(i,"MODELFILE",path,charsmax(path),"xxx");
                if(IsRealAsset(path)) {
                    new index=precache_model(path);
                    if(ReadPreviewModelMeta(i,path)) {g_iPreviewAssetIndex[i]=index;copy(g_szPreviewAsset[i],charsmax(g_szPreviewAsset[]),path);}
                    else log_amx("Player preview disabled: invalid/no local animation metadata: %s",path);
                }
            }
            case COS_WING, COS_RETIRED_PET:
            {
                CosCfgStr(i,"MODEL",path,charsmax(path),"xxx"); if(IsRealAsset(path)) {g_iPreviewAssetIndex[i]=precache_model(path);copy(g_szPreviewAsset[i],charsmax(g_szPreviewAsset[]),path);}
            }
            case COS_KILLFX, COS_TRAIL:
            {
                CosCfgStr(i,"SPRITE",path,charsmax(path),"xxx");
                if(IsRealAsset(path)) {g_iSpriteIndex[i]=precache_model(path);g_iPreviewAssetIndex[i]=g_iSpriteIndex[i];copy(g_szPreviewAsset[i],charsmax(g_szPreviewAsset[]),path);}
            }
        }
    }
}

// ============================================================
// CONFIG PARSER - TEK INI
// ============================================================

LoadConfig()
{
    g_CfgCount = 0;

    new fp = fopen(CFG_FILE, "rt");
    if(!fp)
    {
        log_amx("[FC JBMenu] Config bulunamadi: %s", CFG_FILE);
        return;
    }

    new line[320], key[MAX_CFG_KEY], value[MAX_CFG_VAL];

    while(!feof(fp) && g_CfgCount < MAX_CFG)
    {
        fgets(fp, line, charsmax(line));
        trim(line);

        if(!line[0] || line[0] == ';' || line[0] == '#' || (line[0]=='/' && line[1]=='/'))
            continue;

        key[0] = 0;
        value[0] = 0;
        parse(line, key, charsmax(key), value, charsmax(value));

        if(!key[0])
            continue;

        copy(g_CfgKey[g_CfgCount], MAX_CFG_KEY-1, key);
        copy(g_CfgVal[g_CfgCount], MAX_CFG_VAL-1, value);
        g_CfgCount++;
    }

    fclose(fp);
    NoCTLoadCellTargets();
}

CfgStr(const key[], out[], len, const def[])
{
    for(new i; i < g_CfgCount; i++)
    {
        if(equali(g_CfgKey[i], key))
        {
            copy(out, len, g_CfgVal[i]);
            return;
        }
    }
    copy(out, len, def);
}

CfgInt(const key[], def)
{
    new value[64];
    CfgStr(key, value, charsmax(value), "");
    return value[0] ? str_to_num(value) : def;
}

Float:CfgFloat(const key[], Float:def)
{
    new value[64];
    CfgStr(key, value, charsmax(value), "");
    return value[0] ? str_to_float(value) : def;
}

// ============================================================
// SOHBET TEMIZLEME
// CS 1.6 eski chat satirlarini fiziksel olarak silemez.
// Bos satirlar gonderilerek mevcut reklam/spam mesaji gorunen chat alanindan itilir.
// ============================================================

ClearServerChat(admin)
{
    new lines = clamp(CfgInt("CHAT_CLEAR_LINES", 28), 12, 40);

    for(new i; i < lines; i++)
        client_print(0, print_chat, " ");

    new adminName[32];
    get_user_name(admin, adminName, charsmax(adminName));

    Chat(0, "Sohbet ^4%s ^1tarafindan temizlendi.", adminName);
    log_to_file(LOG_FILE, "CHAT CLEAR: %n UID:%d", admin, g_iUID[admin]);
}

// ============================================================
// MISC
// ============================================================

Chat(id, const fmt[], any:...)
{
    new msg[190];
    vformat(msg, charsmax(msg), fmt, 3);
    client_print_color(id, id, "%s ^1%s", CHAT_TAG, msg);
}

stock rg_set_user_rendering(const index, const fx = kRenderFxNone, const {Float,_}:color[3] = {0.0,0.0,0.0}, const render = kRenderNormal, const Float:amount = 0.0)
{
    set_entvar(index, var_renderfx, fx);
    set_entvar(index, var_rendercolor, color);
    set_entvar(index, var_rendermode, render);
    set_entvar(index, var_renderamt, amount);
}


// ============================================================
// HOGWARTS BRIDGE — fc_hogwarts.amxx must load before this plugin.
// ============================================================
bool:HW_Player(id)
{
    if(id<1 || id>MaxClients || !is_user_connected(id)) return false;
    if(g_bCTJoined[id]) return true;
    new Float:now=get_gametime();
    if(now!=g_fcActivityTime)
    {
        g_fcActivityTime=now;g_fcActivitySerial++;
        g_fcFrameCT=LibraryExists("fc_ctmenu",LibType_Library) && fc_ct_game_id()>0;
        g_fcFrameLR=LibraryExists("fc_lr",LibType_Library) && fc_lr_active();
        g_fcFrameRocket=g_bRocketAPI && LibraryExists("fc_ctmenu",LibType_Library) && fc_ct_rocket_active();
        g_fcFrameHog=HogwartsState:hogwarts_state();
    }
    if(g_fcActivityStamp[id]==g_fcActivitySerial) return g_fcActivityResult[id];
    g_fcActivityStamp[id]=g_fcActivitySerial;
    new bool:active=g_fcFrameCT;
    if(!active && g_fcFrameLR) active=fc_lr_is_player(id)!=0;
    if(!active && g_fcFrameRocket) active=fc_ct_rocket_is_player(id);
    if(!active && g_fcFrameHog!=HW_OFF) active=g_bHWJoined[id] || hogwarts_is_player(id);
    g_fcActivityResult[id]=active;return active;
}

PrepareCTGamePlayer(id)
{
    CancelProfessionActions(id);
    StopPreview(id,false);
    // Settle paid rolls before the provider saves health, weapons and model.
    if(task_exists(id + TASK_CRATE))
    {
        remove_task(id + TASK_CRATE);
        if(g_iCrateType[id] >= 0 && g_iCrateType[id] < CRATE_COUNT)
        {
            GiveCrateReward(id, g_iCrateType[id]);
            Chat(id, "CT oyunu başladığı için ödediğin kasanın sonucu hemen verildi.");
        }
        g_iCrateType[id] = -1;
        g_iCrateTick[id] = 0;
    }
    // End timed attack effects before snapshots; no old timer can unfreeze
    // the sorting phase or change the participants' movement/visibility.
    if(task_exists(id + TASK_GOD))
    {
        remove_task(id + TASK_GOD);
        set_entvar(id, var_takedamage, DAMAGE_AIM);
    }
    if(task_exists(id + TASK_NOCLIP))
    {
        remove_task(id + TASK_NOCLIP);
        set_entvar(id, var_movetype, MOVETYPE_WALK);
    }
    if(task_exists(id + TASK_INVIS))
    {
        remove_task(id + TASK_INVIS);
        set_entvar(id, var_effects, get_entvar(id, var_effects) & ~EF_NODRAW);
    }
    remove_task(id + TASK_LUCKY_REVIVE);
    remove_task(id + TASK_SPAWN_MENU);
    remove_task(id); // delayed TaskApplyCosmetics belongs to this plugin
    RemoveCosmeticEntities(id);
    rg_set_user_rendering(id);
    rg_set_user_footsteps(id, false);
    g_iAirJumps[id] = 0;
    ClearJBHud(id);
    FC_SendPanelHud(id,"",235,235,235,-1.0,0.38,1,0.1);
    g_iRentalMenu[id]=-1;menu_cancel(id);
    show_menu(id, 0, "^n", 1);
}

public hogwarts_prepare(caller, players)
{
    FC_InvalidateActivityCache();
    for(new id = 1; id <= MaxClients; id++)
    {
        if(!is_user_alive(id) || get_member(id, m_iTeam) != TEAM_TERRORIST) continue;
        g_bHWJoined[id] = true;
        PrepareCTGamePlayer(id);
    }
}

public fc_ct_game_prepare(caller, game)
{
    FC_InvalidateActivityCache();
    for(new id = 1; id <= MaxClients; id++)
    {
        g_bCTJoined[id] = is_user_alive(id) && (get_member(id,m_iTeam) == TEAM_TERRORIST || get_member(id,m_iTeam) == TEAM_CT);
        if(!g_bCTJoined[id]) continue;
        if(get_member(id,m_iTeam) == TEAM_TERRORIST) PrepareCTGamePlayer(id);
        else {ClearJBHud(id);remove_task(id);RemoveCosmeticEntities(id);}
    }
}

public fc_ct_rocket_prepare(caller,target)
{
    FC_InvalidateActivityCache();
    for(new id=1;id<=MaxClients;id++) {
        if(target && id!=target) continue;
        if(!is_user_alive(id) || (get_member(id,m_iTeam)!=TEAM_TERRORIST && get_member(id,m_iTeam)!=TEAM_CT)) continue;
        g_bCTJoined[id]=true;
        if(get_member(id,m_iTeam)==TEAM_TERRORIST) PrepareCTGamePlayer(id);
        else {ClearJBHud(id);remove_task(id);RemoveCosmeticEntities(id);}
    }
}
public fc_ct_rocket_finished() {
    FC_InvalidateActivityCache();fc_ct_game_finished(0,0,0);}

public fc_ct_game_finished(game, winner, reason)
{
    FC_InvalidateActivityCache();
    for(new id = 1; id <= MaxClients; id++)
    {
        new bool:joined = g_bCTJoined[id];
        g_bCTJoined[id] = false;
        if(!joined || !is_user_alive(id)) continue;
        g_iAirJumps[id] = 0;
        g_iLastProfessionTick[id] = get_systime();
        if(get_member(id,m_iTeam) == TEAM_TERRORIST) rg_set_user_footsteps(id,g_bSilentSteps[id]);
        ApplyCosmetics(id);
    }
}

public fc_ct_hard_changed(active)
{
    FC_InvalidateActivityCache();
    g_bCTHard = active != 0;
    for(new id = 1; id <= MaxClients; id++)
    {
        g_iAirJumps[id] = 0;
        g_iAirJumpLimit[id] = g_bCTHard ? 0 : ((HasRole(id,ROLE_PRIME) || HasRole(id,ROLE_MANAGER)) ? 2 : 1);
    }
}

public hogwarts_finished(HogwartsHouse:winner, HogwartsStopReason:reason)
{
    FC_InvalidateActivityCache();
    for(new id = 1; id <= MaxClients; id++)
    {
        new bool:joined = g_bHWJoined[id];
        g_bHWJoined[id] = false;
        if(!joined || !is_user_alive(id)) continue;
        // The provider has already restored living players' state.
        g_iAirJumps[id] = 0;
        g_iLastProfessionTick[id] = get_systime();
        if(get_member(id, m_iTeam) == TEAM_TERRORIST)
            rg_set_user_footsteps(id, g_bSilentSteps[id]);
        ApplyCosmetics(id);
    }
}


// Lifetime counters start at this update; old account balances are preserved.
FC_CountAdd(current, amount) {return current + min(max(0,amount),2147483647-max(0,current));}
FC_CoinChange(id, amount)
{
    new old=g_iCoin[id], value;
    if(amount>=0) value=FC_CountAdd(old,amount);
    else value=max(0,old+amount);
    g_iCoin[id]=value;
    if(value>old) g_iCoinEarned[id]=FC_CountAdd(g_iCoinEarned[id],value-old);
    else g_iCoinSpent[id]=FC_CountAdd(g_iCoinSpent[id],old-value);
    return value;
}
FC_RecordTLSpend(id, amount)
{
    if(amount<=0) return;
    g_iTLSpent[id]=FC_CountAdd(g_iTLSpent[id],amount);
    if(g_iUID[id]<=0 || get_member(id,m_iTeam)!=TEAM_TERRORIST || g_iProfession[id]!=PROF_EXCHANGE) return;
    new coins=amount/10, rest=g_iExchangeRemainder[id]+amount%10;
    coins+=rest/10;g_iExchangeRemainder[id]=rest%10;
    if(coins>0) {FC_CoinChange(id,coins);Chat(id,"Döviz Bürosu: ^4+%d Coin^1.",coins);}
}

ShowBonusMenu(id)
{
    if(!CanUseJBMenu(id,true) || !CanUseCosmeticMenu(id,true)) return;
    if(g_iUID[id]<=0) {ShowAccountMenu(id);return;}
    new title[192],line[160];
    formatex(title,charsmax(title),"\wBonus Menü^n\dGünlük oynama: \y%d dakika",g_iDailyPlayMinutes[id]);
    new menu=FC_MenuCreate(title,"H_Bonus");
    formatex(line,charsmax(line),"\wGünlük Hediye \y[%d TL + %d Coin] %s",max(0,CfgInt("BONUS_DAILY_TL",20)),max(0,CfgInt("BONUS_DAILY_COIN",1)),get_systime()<g_iBonusDailyNext[id]?"\d[Alındı]":"");
    FC_MenuAddItem(menu,line,"1");
    formatex(line,charsmax(line),"\w%d Dakika Oynama \y[+%d Coin] %s",max(1,CfgInt("BONUS_PLAY_MINUTES",30)),max(0,CfgInt("BONUS_PLAY_COIN",3)),g_iBonusPlayStamp[id]==g_iDailyStamp[id]?"\d[Alındı]":"");
    FC_MenuAddItem(menu,line,"2");
    FC_MenuAddItem(menu,g_bBonusRound[id]?"\dCan / Zırh Bonusu [Bu el alındı]":"\wCan / Zırh Bonusu \y[+25 HP / +25 Zırh]","3");
    FC_MenuAddItem(menu,g_bBonusRound[id]?"\dHE Bonusu [Bu el alındı]":"\wHE Bonusu \y[1 El Bombası]","4");
    FC_MenuSetProp(menu,MPROP_EXITNAME,"Geri");menu_display(id,menu);
}
public H_Bonus(id,menu,item)
{
    if(item==MENU_EXIT) {menu_destroy(menu);ShowMainMenu(id);return PLUGIN_HANDLED;}
    new info[8],name[64],access,cb;
    menu_item_getinfo(menu,item,access,info,charsmax(info),name,charsmax(name),cb);
    new key=str_to_num(info);menu_destroy(menu);
    if(!CanUseJBMenu(id,true) || !CanUseCosmeticMenu(id,true) || g_iUID[id]<=0) return PLUGIN_HANDLED;
    CheckDailyReset(id);new now=get_systime();
    switch(key) {
        case 1: {
            if(now<g_iBonusDailyNext[id]) Chat(id,"Günlük bonus için ^3%d dakika ^1bekle.",max(1,(g_iBonusDailyNext[id]-now+59)/60));
            else {g_iBonusDailyNext[id]=now+86400;g_iTL[id]=FC_CountAdd(g_iTL[id],CfgInt("BONUS_DAILY_TL",20));FC_CoinChange(id,max(0,CfgInt("BONUS_DAILY_COIN",1)));Chat(id,"Günlük hediyen hesabına eklendi.");}
        }
        case 2: {
            if(g_iBonusPlayStamp[id]==g_iDailyStamp[id]) Chat(id,"Oynama bonusunu bugün aldın.");
            else if(g_iDailyPlayMinutes[id]<max(1,CfgInt("BONUS_PLAY_MINUTES",30))) Chat(id,"Oynama süren henüz yeterli değil.");
            else {g_iBonusPlayStamp[id]=g_iDailyStamp[id];FC_CoinChange(id,max(0,CfgInt("BONUS_PLAY_COIN",3)));Chat(id,"Oynama bonusu hesabına eklendi.");}
        }
        case 3,4: {
            if(!is_user_alive(id)) Chat(id,"El bonusu için hayatta olmalısın.");
            else if(g_bBonusRound[id]) Chat(id,"Bu elin bonusunu zaten seçtin.");
            else if(key==4 && rg_get_user_bpammo(id,WEAPON_HEGRENADE)>0) Chat(id,"Zaten HE bomban var; can / zırh bonusunu seçebilirsin.");
            else {
                g_bBonusRound[id]=true;
                if(key==3) {new Float:hp,Float:armor;get_entvar(id,var_health,hp);get_entvar(id,var_armorvalue,armor);set_entvar(id,var_health,hp+25.0);set_entvar(id,var_armorvalue,floatmin(100.0,armor+25.0));set_member(id,m_iKevlar,ARMOR_KEVLAR);}
                else rg_give_item(id,"weapon_hegrenade");
                Chat(id,"Bu elin bonusu verildi.");
            }
        }
    }
    SavePlayer(id);ShowBonusMenu(id);return PLUGIN_HANDLED;
}

// Catalog access never checks ownership or Prime entitlement.
ShowPreviewMenu(id)
{
    if(!CanUseJBMenu(id,true) || !CanUseCosmeticMenu(id,true)) return;
    new menu=FC_MenuCreate("\wSkin İnceleme^n\dYalnız sen görürsün | 3 saniye","H_Preview"),line[160],name[96],info[8];
    for(new idx;idx<COS_ITEM_COUNT;idx++) {
        if(!IsCosmeticEnabled(idx) || g_CosKind[idx]==COS_TRAIL) continue;
        CosCfgStr(idx,"NAME",name,charsmax(name),g_CosPrefix[idx]);
        formatex(line,charsmax(line),"%s%s \d[%s]",g_iPreviewAssetIndex[idx]>0?"\w":"\d",name,g_iPreviewAssetIndex[idx]>0?"3 sn":"Model yok");
        num_to_str(idx,info,charsmax(info));FC_MenuAddItem(menu,line,info);
    }
    FC_MenuSetProp(menu,MPROP_EXITNAME,"Geri");menu_display(id,menu);
}
public H_Preview(id,menu,item)
{
    if(item==MENU_EXIT) {menu_destroy(menu);ShowCosmeticHub(id);return PLUGIN_HANDLED;}
    new info[8],name[64],access,cb;
    menu_item_getinfo(menu,item,access,info,charsmax(info),name,charsmax(name),cb);
    new idx=str_to_num(info);menu_destroy(menu);
    StartPreview(id,idx);return PLUGIN_HANDLED;
}
StartPreview(id,idx)
{
    if(!CanUseJBMenu(id,true) || !CanUseCosmeticMenu(id,true) || !is_user_alive(id)) return 0;
    if(!IsCosmeticEnabled(idx) || g_CosKind[idx]==COS_TRAIL || g_iPreviewAssetIndex[idx]<=0) {Chat(id,"Bu ürünün dosyası bu haritada yüklenmemiş.");ShowPreviewMenu(id);return 0;}
    StopPreview(id,false);
    g_iPreviewPose[id]=-1;g_flPreviewPoseStart[id]=get_gametime();
    g_iPreviewCos[id]=idx;g_iPreviewCount++;g_iPreviewUID[id]=get_user_userid(id);g_flPreviewEnd[id]=get_gametime()+3.0;
    g_iPreviewOldWeapon[id]=get_user_weapon(id);get_entvar(id,var_viewmodel,g_szPreviewOldView[id],charsmax(g_szPreviewOldView[]));
    if(g_CosKind[idx]==COS_KNIFE) {
        if(!user_has_weapon(id,CSW_KNIFE)) {StopPreview(id,false);Chat(id,"Bıçak incelemek için elinde bıçak bulunmalı.");return 0;}
        engclient_cmd(id,"weapon_knife");set_entvar(id,var_viewmodel,g_szPreviewAsset[idx]);
    }
    else {
        new ent=create_entity("info_target");
        if(!is_valid_ent(ent)) {StopPreview(id,false);return 0;}
        g_iPreviewCamera[id]=ent;if(ent<PREVIEW_EDICT_CACHE) g_iPreviewPrivateOwner[ent]=id;entity_set_string(ent,EV_SZ_classname,"fc_private_camera");
        entity_set_model(ent,"models/w_usp.mdl");
        new Float:cameraSize[3];entity_set_size(ent,cameraSize,cameraSize);
        set_entvar(ent,var_solid,SOLID_NOT);set_entvar(ent,var_movetype,MOVETYPE_NOCLIP);set_entvar(ent,var_owner,id);
        set_entvar(ent,var_takedamage,DAMAGE_NO);set_entvar(ent,var_gravity,0.0);
        // EF_NODRAW makes AddToFullPack discard the camera, including for its owner.
        // Keep its position networked; zero alpha hides the model while PackPre hides it from others.
        set_entvar(ent,var_effects,0);set_entvar(ent,var_rendermode,kRenderTransColor);
        set_entvar(ent,var_renderamt,0.0);set_entvar(ent,var_renderfx,kRenderFxNone);
        if(g_CosKind[idx]==COS_PLAYER || g_CosKind[idx]==COS_WING) {
            new prop=create_entity("info_target");
            if(!is_valid_ent(prop)) {StopPreview(id,false);return 0;}
            g_iPreviewProp[id]=prop;if(prop<PREVIEW_EDICT_CACHE) g_iPreviewPrivateOwner[prop]=id;entity_set_string(prop,EV_SZ_classname,"fc_private_preview");entity_set_model(prop,g_szPreviewAsset[idx]);
            set_entvar(prop,var_owner,id);set_entvar(prop,var_solid,SOLID_NOT);
            if(g_CosKind[idx]==COS_PLAYER) {
                // Never FOLLOW/merge the default player's skeleton into a different skin.
                set_entvar(prop,var_movetype,MOVETYPE_NONE);set_entvar(prop,var_aiment,0);
                set_entvar(prop,var_effects,0);set_entvar(prop,var_rendermode,kRenderNormal);set_entvar(prop,var_renderamt,255.0);
                set_entvar(prop,var_renderfx,kRenderFxNone);set_entvar(prop,var_scale,1.0);
                set_entvar(prop,var_body,0);set_entvar(prop,var_skin,0);
                set_entvar(prop,var_controller,g_iPreviewController[idx]);
                new Float:bodyMins[3]={-16.0,-16.0,-36.0},Float:bodyMaxs[3]={16.0,16.0,36.0};
                entity_set_size(prop,bodyMins,bodyMaxs);UpdatePreviewBody(id);
            } else {set_entvar(prop,var_movetype,MOVETYPE_FOLLOW);set_entvar(prop,var_aiment,id);}
        }
        UpdatePreviewCamera(id);engfunc(EngFunc_SetView,id,ent);
        if(g_CosKind[idx]==COS_KILLFX) {DrawPreviewEffect(id,idx);g_flPreviewNextFX[id]=get_gametime()+0.75;}
    }
    // Only the three-second end/knife/effect watchdog uses a task. Camera/body
    // follow post-physics player frames, like engine set_view; no 20 Hz stair-step.
    set_task(0.1,"TaskPreview",id+TASK_PREVIEW,"",0,"b");
    Chat(id,"Önizleme ^3 3 saniye^1. Görünüm yalnız sana gösterilir.");return 1;
}
public TaskPreview(taskid)
{
    new id=taskid-TASK_PREVIEW;
    if(id<1 || id>MaxClients) return;
    if(!is_user_alive(id) || get_user_userid(id)!=g_iPreviewUID[id] || get_member(id,m_iTeam)!=TEAM_TERRORIST || HW_Player(id)) {StopPreview(id,false);return;}
    if(get_gametime()>=g_flPreviewEnd[id]) {StopPreview(id,true);return;}
    if(g_iPreviewCamera[id]>0) {if(g_CosKind[g_iPreviewCos[id]]==COS_KILLFX && get_gametime()>=g_flPreviewNextFX[id]) {DrawPreviewEffect(id,g_iPreviewCos[id]);g_flPreviewNextFX[id]=get_gametime()+0.75;}}
    else if(g_iPreviewCos[id]>=0 && get_user_weapon(id)==CSW_KNIFE) set_entvar(id,var_viewmodel,g_szPreviewAsset[g_iPreviewCos[id]]);
}
UpdatePreviewCamera(id)
{
    new ent=g_iPreviewCamera[id];if(!is_valid_ent(ent)) return;
    new Float:eye[3],Float:angles[3],Float:cameraForward[3],Float:goal[3],Float:end[3],Float:offset[3];
    get_entvar(id,var_origin,eye);get_entvar(id,var_view_ofs,offset);get_entvar(id,var_v_angle,angles);
    for(new axis;axis<3;axis++) eye[axis]+=offset[axis];
    engfunc(EngFunc_MakeVectors,angles);global_get(glb_v_forward,cameraForward);
    for(new axis;axis<3;axis++) goal[axis]=eye[axis]-cameraForward[axis]*150.0;
    new tr=create_tr2();engfunc(EngFunc_TraceLine,eye,goal,IGNORE_MONSTERS,id,tr);get_tr2(tr,TR_vecEndPos,end);free_tr2(tr);
    for(new axis;axis<3;axis++) end[axis]+=cameraForward[axis]*8.0;
    engfunc(EngFunc_SetOrigin,ent,end);set_entvar(ent,var_angles,angles);
}
StopPreview(id,bool:menuBack)
{
    remove_task(id+TASK_PREVIEW);
    new idx=g_iPreviewCos[id];g_iPreviewCos[id]=-1;if(idx>=0) g_iPreviewCount=max(0,g_iPreviewCount-1);
    if(idx>=0 && is_user_connected(id) && get_user_userid(id)==g_iPreviewUID[id]) {
        if(g_iPreviewCamera[id]>0) engfunc(EngFunc_SetView,id,id);
        if(is_user_alive(id) && g_CosKind[idx]==COS_KNIFE) {
            new weapon=g_iPreviewOldWeapon[id],classname[32];
            if(weapon>0 && user_has_weapon(id,weapon)) {get_weaponname(weapon,classname,charsmax(classname));engclient_cmd(id,classname);}
            if(get_user_weapon(id)==weapon) set_entvar(id,var_viewmodel,g_szPreviewOldView[id]);
            RefreshActiveKnifeModels(id);
        }
    }
    if(g_iPreviewCamera[id]>0 && g_iPreviewCamera[id]<PREVIEW_EDICT_CACHE) g_iPreviewPrivateOwner[g_iPreviewCamera[id]]=0;
    if(g_iPreviewCamera[id]>0 && is_valid_ent(g_iPreviewCamera[id])) remove_entity(g_iPreviewCamera[id]);
    if(g_iPreviewProp[id]>0 && g_iPreviewProp[id]<PREVIEW_EDICT_CACHE) g_iPreviewPrivateOwner[g_iPreviewProp[id]]=0;
    if(g_iPreviewProp[id]>0 && is_valid_ent(g_iPreviewProp[id])) remove_entity(g_iPreviewProp[id]);
    g_iPreviewCamera[id]=g_iPreviewProp[id]=g_iPreviewUID[id]=0;g_iPreviewPose[id]=-1;g_flPreviewPoseStart[id]=0.0;g_flPreviewEnd[id]=g_flPreviewNextFX[id]=0.0;
    if(menuBack && is_user_alive(id) && CanUseJBMenu(id,false) && get_member(id,m_iTeam)==TEAM_TERRORIST) ShowPreviewMenu(id);
}
public PreviewPackPre(es,e,ent,host,flags,player,pSet)
{
    // Sadece host icin petlerin ag paketini engelle; diger oyuncular gormeye devam eder.
    if(host >= 1 && host <= MaxClients && g_bHidePets[host] && ent > MaxClients)
    {
        for(new owner = 1; owner <= MaxClients; owner++)
        {
            if(g_iPetEnt[owner] == ent)
            {
                forward_return(FMV_CELL, 0);
                return FMRES_SUPERCEDE;
            }
        }
    }
    if(!g_iPreviewCount) return FMRES_IGNORED;
    if(ent>MaxClients) {
        new owner=ent<PREVIEW_EDICT_CACHE?g_iPreviewPrivateOwner[ent]:get_entvar(ent,var_owner);
        if(owner>=1 && owner<=MaxClients && (ent==g_iPreviewCamera[owner] || ent==g_iPreviewProp[owner]) && host!=owner) {forward_return(FMV_CELL,0);return FMRES_SUPERCEDE;}
    }
    return FMRES_IGNORED;
}
public PreviewPackPost(es,e,ent,host,flags,player,pSet)
{
    if(host<1 || host>MaxClients || !is_user_connected(host))
        return FMRES_IGNORED;

    // Kisisel gorunurluk filtreleri: AddToFullPack her izleyici icin ayri paket uretir.
    if(player && ent>=1 && ent<=MaxClients && is_user_connected(ent))
    {
        if(ent!=host && !g_bPrisonerPlayersVisible[host]
            && get_member(ent,m_iTeam)==TEAM_TERRORIST)
        {
            set_es(es,ES_Effects,get_es(es,ES_Effects)|EF_NODRAW);
        }
        else if(!g_bPlayerModelsVisible[host] && g_bCosmeticPlayerModel[ent])
        {
            // Oyuncu modelleri ayari yalnizca FeliciaClan karakter skinlerini gizler.
            set_es(es,ES_Effects,get_es(es,ES_Effects)|EF_NODRAW);
        }

        // Skinleri gizleyen izleyiciye oyuncunun Ana Market bicagi gosterilir.
        if(!g_bKnifeSkinsVisible[host] && is_user_alive(ent)
            && get_user_weapon(ent)==CSW_KNIFE)
        {
            new base = (get_member(ent,m_iTeam)==TEAM_CT) ? 1 : g_iBaseKnife[ent];
            if(base < 0 || base > 4)
                base = (get_member(ent,m_iTeam)==TEAM_CT) ? 1 : 0;

            new modelIndex = g_iBaseKnifePModelIndex[base];
            if(modelIndex <= 0)
                modelIndex = g_iDefaultPKnifeModel;
            if(modelIndex > 0)
                set_es(es,ES_WeaponModel,modelIndex);
        }
    }

    if(!g_iPreviewCount || g_iPreviewCos[host]<0)
        return FMRES_IGNORED;
    if(!((player && ent==host) || (ent>0 && ent==g_iWingEnt[host])))
        return FMRES_IGNORED;
    if(g_iPreviewUID[host]!=get_user_userid(host))
        return FMRES_IGNORED;

    new idx=g_iPreviewCos[host];
    if(player && ent==host && g_CosKind[idx]==COS_PLAYER && is_valid_ent(g_iPreviewProp[host]))
    {
        // Owner sees the private normal studio entity; all other viewers keep
        // the real server player, original costume, weapon and live animation.
        set_es(es,ES_Effects,get_es(es,ES_Effects)|EF_NODRAW);
        set_es(es,ES_RenderMode,kRenderTransTexture);
        set_es(es,ES_RenderAmt,0);
        set_es(es,ES_WeaponModel,0);
    }
    if(ent==g_iWingEnt[host] && g_CosKind[idx]==COS_WING)
        set_es(es,ES_Effects,get_es(es,ES_Effects)|EF_NODRAW);

    return FMRES_IGNORED;
}
public PreviewCmdStart(id,uc,seed)
{
    if(id < 1 || id > MaxClients || !is_user_connected(id))
        return FMRES_IGNORED;

    new buttons = get_uc(uc, UC_Buttons);
    new oldbuttons = get_entvar(id, var_oldbuttons);

    if(g_bProfessionZhonyaActive[id])
    {
        buttons &= ~(IN_ATTACK | IN_ATTACK2 | IN_JUMP | IN_DUCK | IN_FORWARD
            | IN_BACK | IN_MOVELEFT | IN_MOVERIGHT | IN_USE | IN_RELOAD);
        set_uc(uc, UC_Buttons, buttons);
        return FMRES_IGNORED;
    }

    if(is_user_alive(id) && (buttons & IN_USE) && !(oldbuttons & IN_USE) && !HW_Player(id))
    {
        if(g_iProfession[id] == PROF_ROBBER)
        {
            StartProfessionRobbery(id);
            if(g_iRobberyTarget[id] > 0)
                buttons &= ~IN_USE;
        }
        else if(g_iProfession[id] == PROF_ZHONYA)
        {
            StartProfessionZhonya(id);
            if(g_bProfessionZhonyaActive[id])
                buttons &= ~IN_USE;
        }
    }

    if(g_bProfessionZhonyaActive[id])
        buttons &= ~(IN_ATTACK | IN_ATTACK2 | IN_JUMP | IN_DUCK | IN_FORWARD
            | IN_BACK | IN_MOVELEFT | IN_MOVERIGHT | IN_USE | IN_RELOAD);

    if(g_iPreviewCos[id] >= 0)
        buttons &= ~(IN_ATTACK | IN_ATTACK2);

    set_uc(uc, UC_Buttons, buttons);
    return FMRES_IGNORED;
}
DrawPreviewEffect(id,idx)
{
    new Float:origin[3];get_entvar(id,var_origin,origin);
    message_begin(MSG_ONE_UNRELIABLE,SVC_TEMPENTITY,{0,0,0},id);write_byte(TE_EXPLOSION);
    write_coord_f(origin[0]);write_coord_f(origin[1]);write_coord_f(origin[2]+20.0);
    write_short(g_iPreviewAssetIndex[idx]);write_byte(8);write_byte(12);write_byte(TE_EXPLFLAG_NOSOUND|TE_EXPLFLAG_NODLIGHTS);message_end();
}


// LR money is reserved without purchase counters; only a settled loss is spent.
// Interrupted reservations survive server crashes and are refunded on login.
new g_lrHeld[33],g_lrAccount[33],g_lrSession[33];
LRRecover(id)
{
    new uid=g_iUID[id];if(uid<=0) return;
    new held=UIDGetInt(uid,"lr_escrow",0);if(held<=0) return;
    for(new p=1;p<=MaxClients;p++) if(g_lrHeld[p]>0 && g_lrAccount[p]==uid) return;
    g_iTL[id]=FC_CountAdd(g_iTL[id],held);
    UIDSetInt(uid,"lr_escrow",0);UIDSetInt(uid,"tl",g_iTL[id]);
}
public N_LRHold(plugin,params)
{
    if(params!=2) return 0;
    new id=get_param(1),amount=get_param(2);
    if(id<1 || id>MaxClients || !is_user_connected(id) || amount<1 || amount>100000 || g_lrHeld[id] || g_iTL[id]<amount) return 0;
    if(g_iUID[id]>0 && UIDGetInt(g_iUID[id],"lr_escrow",0)>0) return 0;
    g_lrHeld[id]=amount;g_lrAccount[id]=g_iUID[id];g_lrSession[id]=get_user_userid(id);
    g_iTL[id]-=amount;
    if(g_iUID[id]>0) UIDSetInt(g_iUID[id],"lr_escrow",amount);
    SavePlayer(id);return 1;
}
public N_LRSettle(plugin,params)
{
    if(params!=5) return 0;
    new uid=get_param(1),id=get_param(2),session=get_param(3),stake=get_param(4),mul=get_param(5);
    if(id<1 || id>MaxClients || stake<1 || mul<0 || mul>2 || g_lrHeld[id]!=stake || g_lrAccount[id]!=uid || g_lrSession[id]!=session) return 0;
    g_lrHeld[id]=g_lrAccount[id]=g_lrSession[id]=0;
    if(uid>0) UIDSetInt(uid,"lr_escrow",0);
    new target;
    for(new p=1;p<=MaxClients;p++) if(is_user_connected(p) && ((uid>0 && g_iUID[p]==uid) || (uid==0 && p==id && get_user_userid(p)==session && g_iUID[p]==0))) {target=p;break;}
    if(target) {
        g_iTL[target]=FC_CountAdd(g_iTL[target],stake*mul);
        if(mul==0) FC_RecordTLSpend(target,stake);
        SavePlayer(target);
    } else if(uid>0) {
        UIDSetInt(uid,"tl",FC_CountAdd(UIDGetInt(uid,"tl",0),stake*mul));
        if(mul==0) UIDSetInt(uid,"total_tl_spent",FC_CountAdd(UIDGetInt(uid,"total_tl_spent",0),stake));
    }
    return 1;
}
public fc_lr_prepare(t,ct,mode)
{
    FC_InvalidateActivityCache();
    if(t>=1 && t<=MaxClients && is_user_alive(t)) PrepareCTGamePlayer(t);
    if(ct>=1 && ct<=MaxClients && is_user_alive(ct)) PrepareCTGamePlayer(ct);
}
public fc_lr_finished(t,ct,mode,winner)
{
    FC_InvalidateActivityCache();
    new players[2];players[0]=t;players[1]=ct;
    for(new s;s<2;s++) {
        new id=players[s];if(id<1 || id>MaxClients || !is_user_alive(id)) continue;
        g_iAirJumps[id]=0;g_iLastProfessionTick[id]=get_systime();
        if(get_member(id,m_iTeam)==TEAM_TERRORIST) rg_set_user_footsteps(id,g_bSilentSteps[id]);
        ApplyCosmetics(id);
    }
}


public PreviewPostThink(id)
{
    if(!g_iPreviewCount || id<1 || id>MaxClients || g_iPreviewCos[id]<0 || g_iPreviewCamera[id]<=0) return FMRES_IGNORED;
    if(!is_user_alive(id) || get_user_userid(id)!=g_iPreviewUID[id] || get_member(id,m_iTeam)!=TEAM_TERRORIST || HW_Player(id)) {StopPreview(id,false);return FMRES_IGNORED;}
    if(get_gametime()>=g_flPreviewEnd[id]) {StopPreview(id,true);return FMRES_IGNORED;}
    UpdatePreviewCamera(id);UpdatePreviewBody(id);return FMRES_IGNORED;
}
UpdatePreviewBody(id)
{
    new idx=g_iPreviewCos[id],prop=g_iPreviewProp[id];
    if(idx<0 || g_CosKind[idx]!=COS_PLAYER || !is_valid_ent(prop) || !g_bPreviewModelMeta[idx]) return;
    new Float:origin[3],Float:angle[3],Float:velocity[3];
    get_entvar(id,var_origin,origin);get_entvar(id,var_angles,angle);get_entvar(id,var_velocity,velocity);
    // StudioDrawModel expects ordinary entity pitch, not the player's -pitch/3.
    // Neutral pitch/roll prevents upper-body bending on third-person cameras.
    angle[0]=angle[2]=0.0;entity_set_origin(prop,origin);set_entvar(prop,var_angles,angle);
    new Float:speed=floatsqroot(velocity[0]*velocity[0]+velocity[1]*velocity[1]),pose;
    if(get_entvar(id,var_flags)&FL_DUCKING) pose=speed>8.0?PREV_DUCK_WALK:PREV_DUCK_IDLE;
    else pose=speed>150.0?PREV_RUN:speed>8.0?PREV_WALK:PREV_IDLE;
    new Float:now=get_gametime();
    if(g_iPreviewPose[id]<0 || g_iPreviewSeq[idx][pose]!=g_iPreviewSeq[idx][g_iPreviewPose[id]]) {
        g_flPreviewPoseStart[id]=now;set_entvar(prop,var_sequence,g_iPreviewSeq[idx][pose]);
    }
    g_iPreviewPose[id]=pose;set_entvar(prop,var_blending,g_iPreviewBlend[idx][pose]);
    new frames=g_iPreviewFrames[idx][pose];new Float:frame;
    if(frames>1) {
        frame=(now-g_flPreviewPoseStart[id])*g_flPreviewFPS[idx][pose]*256.0/float(frames-1);
        frame-=float(floatround(frame/256.0,floatround_floor))*256.0;
    }
    set_entvar(prop,var_frame,frame);set_entvar(prop,var_animtime,now);set_entvar(prop,var_framerate,1.0);
}

// Read only once at map precache. The viewer never does disk I/O per frame.
// GoldSrc IDST v10: header numseq/index at 164/168; seqdesc size 176.
// Only local group-0 looping animations are used, avoiding missing external seq files.
ReadPreviewModelMeta(idx,const path[])
{
    g_bPreviewModelMeta[idx]=false;
    new size=file_size(path);if(size<244) return 0;
    new file=fopen(path,"rb");if(!file) return 0;
    new magic,version,count,base;
    if(!FileReadInt32(file,magic) || !FileReadInt32(file,version) || magic!=0x54534449 || version!=10) {fclose(file);return 0;}
    new controllers,controllerBase;fseek(file,148,SEEK_SET);
    if(!FileReadInt32(file,controllers) || !FileReadInt32(file,controllerBase) || controllers<0 || controllers>64 || (controllers && (controllerBase<244 || controllerBase>size-controllers*24))) {fclose(file);return 0;}
    arrayset(g_iPreviewController[idx],0,4);
    for(new c;c<controllers;c++) {
        new ctrl[6];fseek(file,controllerBase+c*24,SEEK_SET);
        if(fread_blocks(file,ctrl,6,BLOCK_INT)!=6) {fclose(file);return 0;}
        if(ctrl[5]>=0 && ctrl[5]<4) g_iPreviewController[idx][ctrl[5]]=clamp(ctrl[4],0,255);
    }
    fseek(file,164,SEEK_SET);
    if(!FileReadInt32(file,count) || !FileReadInt32(file,base) || count<1 || count>2048 || base<244 || base>size-count*176) {fclose(file);return 0;}
    new best[PREV_POSES];arrayset(best,-1,PREV_POSES);
    new fallback=-1,fallbackFrames;new Float:fallbackFPS;
    for(new seq;seq<count;seq++) {
        new data[44];fseek(file,base+seq*176,SEEK_SET);
        if(fread_blocks(file,data,44,BLOCK_INT)!=44) {fclose(file);return 0;}
        new Float:fps=Float:data[8],frames=data[14];
        if(data[39]!=0 || !(data[9]&1) || frames<1 || frames>8192 || !(fps>0.0) || fps>300.0) continue;
        if(fallback<0) {fallback=seq;fallbackFrames=frames;fallbackFPS=fps;}
        new label[33];for(new b;b<32;b++) label[b]=(data[b/4]>>((b%4)*8))&255;label[32]=0;
        strtolower(label);new score[PREV_POSES];arrayset(score,-1,PREV_POSES);
        if(data[10]==1) score[PREV_IDLE]=80;
        if(data[10]==3) score[PREV_WALK]=80;
        if(data[10]==4) score[PREV_RUN]=80;
        if(data[10]==18) score[PREV_DUCK_IDLE]=80;
        if(data[10]==17) score[PREV_DUCK_WALK]=80;
        if(equal(label,"idle1") || equal(label,"idle")) score[PREV_IDLE]=100;
        if(equal(label,"ref_aim_knife")) score[PREV_IDLE]=110;
        if(equal(label,"walk")) score[PREV_WALK]=100;
        if(equal(label,"run")) score[PREV_RUN]=100;
        if(equal(label,"crouch_idle") || equal(label,"crouch_aim_knife")) score[PREV_DUCK_IDLE]=100;
        if(equal(label,"crouch_walk")) score[PREV_DUCK_WALK]=100;
        for(new pose;pose<PREV_POSES;pose++) if(score[pose]>best[pose]) {
            best[pose]=score[pose];g_iPreviewSeq[idx][pose]=seq;g_iPreviewFrames[idx][pose]=frames;g_flPreviewFPS[idx][pose]=fps;
            for(new b;b<2;b++) {
                new Float:start=Float:data[34+b],Float:end=Float:data[36+b];
                g_iPreviewBlend[idx][pose][b]=data[32+b] && floatabs(end-start)>0.001?clamp(floatround(-start*255.0/(end-start)),0,255):0;
            }
        }
    }
    fclose(file);if(fallback<0) return 0;
    if(best[PREV_IDLE]<0) {g_iPreviewSeq[idx][PREV_IDLE]=fallback;g_iPreviewFrames[idx][PREV_IDLE]=fallbackFrames;g_flPreviewFPS[idx][PREV_IDLE]=fallbackFPS;}
    for(new pose=1;pose<PREV_POSES;pose++) if(best[pose]<0) {
        g_iPreviewSeq[idx][pose]=g_iPreviewSeq[idx][PREV_IDLE];
        g_iPreviewFrames[idx][pose]=g_iPreviewFrames[idx][PREV_IDLE];
        g_flPreviewFPS[idx][pose]=Float:g_flPreviewFPS[idx][PREV_IDLE];
        for(new b;b<2;b++) g_iPreviewBlend[idx][pose][b]=g_iPreviewBlend[idx][PREV_IDLE][b];
    }
    g_bPreviewModelMeta[idx]=true;return 1;
}


// Detailed HUD: three existing channels. White stationary text on channel 4,
// team-colored typewriter sweep plus the title on 3, yellow decorations on 2.
// Channel 1 remains free for CT games. There is one short-lived global task.
DetailSpan(const text[],field,&first,&last)
{
    first=contain(text,DETAIL_KEYS[field]);if(first<0) return 0;
    first+=strlen(DETAIL_KEYS[field]);while(text[first]==' ') first++;
    last=first;while(text[last] && text[last]!='^n' && text[last]!='|') last++;
    new close=last;
    for(new i=first;i+3<last;i++) if(text[i]==' ' && text[i+1]=='-' && text[i+2]==' ' && text[i+3]==']') {close=i;break;}
    last=close;while(last>first && text[last-1]==' ') last--;
    return last>first;
}
DetailHash(const text[],start,end)
{
    new hash=5381;for(new i=start;i<end;i++) hash=((hash<<5)+hash)^text[i];return hash;
}
DetailChars(const text[],start,end)
{
    new count;for(new i=start;i<end;i++) if((text[i]&0xC0)!=0x80 && text[i]!=' ') count++;return count;
}

QueueDetailHud(id,const text[],r,g,b,Float:x,Float:y,fr,fg,fb)
{
    new Float:now=get_gametime();new padded[480];copy(padded,charsmax(padded),text);
    new bool:intro=!g_bDetailHud[id] || g_iDetailStamp[id]!=g_iDetailRound;
    new previous[480];if(!intro) copy(previous,charsmax(previous),g_szDetailBody[id]);
    FC_BuildInfoHud(padded,g_szDetailBody[id],g_szDetailWord[id],g_szDetailInner[id],x,y,true);
    // Gereksiz bosluklari koruyan eski girinti islemi kaldirildi.
    new panelWidth=max(340,FC_PanelTextWidth(g_szDetailBody[id]));
    g_iFCPanelWidth[id]=intro?panelWidth:max(g_iFCPanelWidth[id],panelWidth);
    g_flDetailX[id]=x;g_flDetailY[id]=y;g_iDetailColor[id][0]=r;g_iDetailColor[id][1]=g;g_iDetailColor[id][2]=b;
    g_iDetailColor[id][3]=fr;g_iDetailColor[id][4]=fg;g_iDetailColor[id][5]=fb;
    if(intro) {g_flDetailIntro[id]=now;g_flDetailUntil[id]=now+float(DetailChars(g_szDetailBody[id],0,strlen(g_szDetailBody[id])))*0.012+0.25;}
    for(new field;field<DETAIL_FIELDS;field++) {
        new first,last;if(!DetailSpan(g_szDetailBody[id],field,first,last)) continue;
        new hash=DetailHash(g_szDetailBody[id],first,last);
        if(!intro && hash!=g_iDetailHash[id][field]) {
            g_flDetailChange[id][field]=now;
            g_flDetailUntil[id]=floatmax(g_flDetailUntil[id],now+float(DetailChars(g_szDetailBody[id],first,last))*0.055+0.23);
        } else if(intro) g_flDetailChange[id][field]=0.0;
        g_iDetailHash[id][field]=hash;
    }
    g_bDetailHud[id]=true;g_iDetailStamp[id]=g_iDetailRound;
    RenderDetailHud(id,now);
    if(g_flDetailUntil[id]>now && !task_exists(TASK_DETAIL_ANIM)) set_task(0.05,"TaskDetailHud",TASK_DETAIL_ANIM,"",0,"b");
}
public TaskDetailHud()
{
    new active;new Float:now=get_gametime();
    for(new id=1;id<=MaxClients;id++) if(g_bDetailHud[id] && is_user_connected(id) && g_iHudMode[id]==HUDMODE_FULL && g_flDetailUntil[id]>0.0) {
        RenderDetailHud(id,now);
        if(g_flDetailUntil[id]>=now) active++;
        else g_flDetailUntil[id]=0.0;
    }
    if(!active) remove_task(TASK_DETAIL_ANIM);
}
DetailAppendSpace(out[],&used,len,units)
{
    new count=floatround(float(units)/7.0);for(new n;n<count && used<len;n++) out[used++]=' ';
}
RenderDetailHud(id,Float:now)
{
    new color[480],white[480],mask[480],full[480];copy(full,charsmax(full),g_szDetailBody[id]);
    new ordinal;
    // Mask codes: 0 invisible, 1 final white, 2 team-colored arriving letter.
    for(new i;full[i];i++) {
        mask[i]=1;if((full[i]&0xC0)==0x80 || full[i]==' ' || full[i]=='^n') continue;
        new Float:age=now-g_flDetailIntro[id]-float(ordinal++)*0.012;
        if(age<0.0) mask[i]=0;else if(age<0.20) mask[i]=2;
    }
    for(new field;field<DETAIL_FIELDS;field++) if(g_flDetailChange[id][field]>g_flDetailIntro[id]) {
        new first,last;if(!DetailSpan(full,field,first,last)) continue;ordinal=0;
        for(new i=first;i<last;i++) {
            if((full[i]&0xC0)==0x80 || full[i]==' ') continue;
            new Float:age=now-g_flDetailChange[id][field]-float(ordinal++)*0.055;
            mask[i]=age<0.0?0:age<0.20?2:1;
        }
    }
    new wu,cu,whiteUnits,colorUnits;
    for(new i;full[i];) {
        if(full[i]=='^n') {if(wu<charsmax(white)) white[wu++]='^n';if(cu<charsmax(color)) color[cu++]='^n';whiteUnits=colorUnits=0;i++;continue;}
        new next=i+1;while((full[next]&0xC0)==0x80) next++;
        new width=FC_PanelGlyphWidth(full[i]);
        if(mask[i]==1 && full[i]!=' ') {DetailAppendSpace(white,wu,charsmax(white),whiteUnits);whiteUnits=0;for(new a=i;a<next && wu<charsmax(white);a++) white[wu++]=full[a];}
        else whiteUnits+=width;
        if(mask[i]==2 && full[i]!=' ') {DetailAppendSpace(color,cu,charsmax(color),colorUnits);colorUnits=0;for(new a=i;a<next && cu<charsmax(color);a++) color[cu++]=full[a];}
        else colorUnits+=width;
        i=next;
    }
    white[wu]=0;color[cu]=0;
    // Replace the first line of the colored body with the permanent clan title.
    // It is never replayed for a money/HP/status update.
    new overlay[480],heading[192],start;copyc(heading,charsmax(heading),g_szDetailWord[id],'^n');
    new introLetters=clamp(floatround((now-g_flDetailIntro[id])/0.04,floatround_floor),0,11),seen;
    for(new i;heading[i];i++) if(heading[i]!=' ' && ++seen>introLetters) heading[i]=' ';
    while(color[start] && color[start]!='^n') start++;
    formatex(overlay,charsmax(overlay),"%s%s",heading,color[start]);
    // Information text stays white; clan title color remains unchanged.
    FC_SendPanelHud(id,white,255,255,255,g_flDetailX[id],g_flDetailY[id],4);
    FC_SendPanelHud(id,overlay,g_iDetailColor[id][3],g_iDetailColor[id][4],g_iDetailColor[id][5],g_flDetailX[id],g_flDetailY[id],3);
    FC_SendPanelHud(id,g_szDetailInner[id],255,210,0,g_flDetailX[id],g_flDetailY[id],2);
}


// No-CT convenience tools. A connected dead guard still owns the CT side.
// The action's stable menu key does not depend on its displayed row number.
bool:NoCTHasGuard()
{
    for(new p=1;p<=MaxClients;p++)
        if(is_user_connected(p) && get_member(p,m_iTeam)==TEAM_CT) return true;
    return false;
}
bool:NoCTGameBusy()
{
    if(LibraryExists("fc_ctmenu",LibType_Library) && fc_ct_game_id()>0) return true;
    if(g_bRocketAPI && fc_ct_rocket_active()) return true;
    if(LibraryExists("fc_lr",LibType_Library) && fc_lr_active()) return true;
    return hogwarts_state()!=HW_OFF;
}
NoCTAddCellItem(id,menu)
{
    if(is_user_connected(id) && get_member(id,m_iTeam)==TEAM_TERRORIST && !NoCTHasGuard())
        FC_MenuAddItemCB(menu,"\wHücre Kapısını Aç","18",menu_makecallback("CB_NoCTCellItem"));
}
public CB_NoCTCellItem(id,menu,item)
{
    return is_user_alive(id) && get_member(id,m_iTeam)==TEAM_TERRORIST && !NoCTHasGuard() && !NoCTGameBusy()?ITEM_ENABLED:ITEM_DISABLED;
}
NoCTTrackMenu(id,menu,kind) {g_iNoCTMenu[id]=menu;g_iNoCTMenuKind[id]=kind;}
NoCTReleaseMenu(id,menu) {if(g_iNoCTMenu[id]==menu) {g_iNoCTMenu[id]=-1;g_iNoCTMenuKind[id]=0;}}
NoCTRefreshLater()
{
    if(!task_exists(TASK_NOCT_MENUS)) set_task(0.1,"TaskNoCTMenus",TASK_NOCT_MENUS);
}
public TaskNoCTMenus()
{
    new bool:hasCT=NoCTHasGuard();if(hasCT==g_bNoCTHadCT) return;
    g_bNoCTHadCT=hasCT;
    for(new p=1;p<=MaxClients;p++) if(is_user_connected(p) && g_iNoCTMenuKind[p]) {
        new old,active,page;player_menu_info(p,old,active,page);
        if(active!=g_iNoCTMenu[p]) {g_iNoCTMenu[p]=-1;g_iNoCTMenuKind[p]=0;continue;}
        new kind=g_iNoCTMenuKind[p];g_iNoCTMenuKind[p]=0;g_iNoCTMenu[p]=-1;
        menu_cancel(p);
        if(get_member(p,m_iTeam)!=TEAM_TERRORIST || !CanUseJBMenu(p,false)) continue;
        if(kind==2) ShowAccountMenu(p);else ShowMainMenu(p);
    }
}
NoCTForgetJoin(id)
{
    remove_task(id+TASK_NOCT_JOIN);g_bNoCTFirstTeam[id]=false;
    g_iNoCTJoinUID[id]=0;g_iNoCTJoinTries[id]=0;
}
NoCTQueueJoin(id)
{
    if(!g_bNoCTFirstTeam[id]) return;
    if(!is_user_connected(id) || get_user_userid(id)!=g_iNoCTJoinUID[id]) {NoCTForgetJoin(id);return;}
    new TeamName:team=get_member(id,m_iTeam);
    if(team==TEAM_UNASSIGNED) return;
    if(team!=TEAM_TERRORIST || is_user_alive(id) || NoCTHasGuard() || NoCTGameBusy()) {NoCTForgetJoin(id);return;}
    if(!task_exists(id+TASK_NOCT_JOIN)) {
        g_iNoCTJoinTries[id]=0;set_task(0.35,"TaskNoCTJoin",id+TASK_NOCT_JOIN);
    }
}
public HC_NoCTAppearance_Post(id,model) {NoCTQueueJoin(id);}
public TaskNoCTJoin(taskid)
{
    new id=taskid-TASK_NOCT_JOIN;
    if(id<1 || id>MaxClients || !g_bNoCTFirstTeam[id]) return;
    if(!is_user_connected(id) || get_user_userid(id)!=g_iNoCTJoinUID[id] || get_member(id,m_iTeam)!=TEAM_TERRORIST || is_user_alive(id) || NoCTHasGuard() || NoCTGameBusy()) {NoCTForgetJoin(id);return;}
    // TeamInfo precedes model selection/GetIntoGame. Do not spawn an unfinished
    // player; retry briefly and let the appearance hook re-arm a slow join.
    if(get_member(id,m_iJoiningState)!=JOINED || get_member(id,m_iMenu)==Menu_ChooseAppearance || get_member_game(m_bRoundTerminating)) {
        if(++g_iNoCTJoinTries[id]<12) set_task(0.25,"TaskNoCTJoin",taskid);
        return;
    }
    NoCTForgetJoin(id);rg_round_respawn(id);
    if(is_user_alive(id)) Chat(id,"CT takımında oyuncu olmadığı için canlandırıldın.");
}
NoCTLoadCellTargets()
{
    CfgStr("NO_CT_CELL_TARGETS",g_szNoCTCellTargets,charsmax(g_szNoCTCellTargets),"");trim(g_szNoCTCellTargets);
    if(g_szNoCTCellTargets[0]) return;
    // Reuse the existing CT configuration when it names this map's controls.
    new f=fopen("addons/amxmodx/configs/FeliciaClan/FeliciaClan_CTMenu.ini","rt");if(!f) return;
    new line[512],key[64],value[256];
    while(!feof(f)) {
        fgets(f,line,charsmax(line));trim(line);
        if(!line[0] || line[0]==';' || line[0]=='#' || line[0]=='[') continue;
        strtok(line,key,charsmax(key),value,charsmax(value),'=');trim(key);trim(value);
        if(equali(key,"CELL_TARGETS")) {remove_quotes(value);copy(g_szNoCTCellTargets,charsmax(g_szNoCTCellTargets),value);break;}
    }
    fclose(f);
}
NoCTQueueEntity(ent,queue[],&size)
{
    if(ent<=MaxClients || !is_valid_ent(ent) || size>=128) return;
    for(new i;i<size;i++) if(queue[i]==ent) return;
    queue[size++]=ent;
}
NoCTOpenDoor(id,ent)
{
    // Use AMXX's named gamedata, never platform-specific hardcoded offsets.
    // DoorUse may toggle even with USE_ON, so explicitly skip an open gate.
    new doorState=get_ent_data(ent,"CBaseToggle","m_toggle_state");
    new flags=get_entvar(ent,var_spawnflags),bool:startOpen=bool:(flags&1);
    if(!startOpen && (doorState==0 || doorState==2)) return 0; // top / going up
    if(startOpen && (doorState==1 || doorState==3)) return 0; // bottom / going down
    if(startOpen) {
        if(doorState==2) set_ent_data(ent,"CBaseToggle","m_toggle_state",0);
        set_entvar(ent,var_spawnflags,flags|32); // allow return to start-open end
    } else if(doorState==3) set_ent_data(ent,"CBaseToggle","m_toggle_state",1);
    ExecuteHamB(Ham_Use,ent,id,id,startOpen?USE_OFF:USE_ON,1.0);
    if(startOpen && is_valid_ent(ent)) set_entvar(ent,var_spawnflags,flags);
    return 1;
}
NoCTOpenCells(id)
{
    if(!is_user_alive(id) || get_member(id,m_iTeam)!=TEAM_TERRORIST) return;
    if(NoCTHasGuard()) {Chat(id,"CT varken hücre kapısını bu menüden açamazsın.");return;}
    if(NoCTGameBusy()) {Chat(id,"Aktif oyun sırasında hücre kapısı açılamaz.");return;}
    new Float:now=get_gametime();if(now<g_flNoCTCellNext) return;g_flNoCTCellNext=now+0.8;
    new queue[128],size,at,n,key[64],ent=-1;
    while(g_szNoCTCellTargets[at]) {
        n=0;while(g_szNoCTCellTargets[at] && g_szNoCTCellTargets[at]!=',') {if(n<charsmax(key)) key[n++]=g_szNoCTCellTargets[at];at++;}
        key[n]=0;trim(key);if(g_szNoCTCellTargets[at]==',') at++;
        if(!key[0]) continue;ent=-1;
        while((ent=find_ent_by_tname(ent,key))>0) NoCTQueueEntity(ent,queue,size);
    }
    if(!g_szNoCTCellTargets[0]) {
        new spawn=-1,Float:point[3],classname[32];
        while((spawn=find_ent_by_class(spawn,"info_player_deathmatch"))>0) {
            entity_get_vector(spawn,EV_VEC_origin,point);ent=-1;
            while((ent=find_ent_in_sphere(ent,point,300.0))>0) {
                entity_get_string(ent,EV_SZ_classname,classname,charsmax(classname));
                if(equal(classname,"func_door") || equal(classname,"func_door_rotating")) NoCTQueueEntity(ent,queue,size);
            }
        }
    }
    new found,opened,classname[32],target[64],child;
    for(new i;i<size;i++) {
        ent=queue[i];if(!is_valid_ent(ent) || pev_valid(ent)!=2) continue;
        entity_get_string(ent,EV_SZ_classname,classname,charsmax(classname));
        if(equal(classname,"func_door") || equal(classname,"func_door_rotating")) {found++;opened+=NoCTOpenDoor(id,ent);continue;}
        if(equal(classname,"multi_manager")) {
            new count=clamp(get_ent_data(ent,"CMultiManager","m_cTargets"),0,16);
            for(new k;k<count;k++) {
                new str=get_ent_data(ent,"CMultiManager","m_iTargetName",k);if(!str) continue;
                engfunc(EngFunc_SzFromIndex,str,target,charsmax(target));if(!target[0]) continue;child=-1;
                while((child=find_ent_by_tname(child,target))>0) NoCTQueueEntity(child,queue,size);
            }
        } else if(equal(classname,"func_button") || equal(classname,"func_rot_button") || equal(classname,"trigger_relay")) {
            entity_get_string(ent,EV_SZ_target,target,charsmax(target));if(!target[0]) continue;child=-1;
            while((child=find_ent_by_tname(child,target))>0) NoCTQueueEntity(child,queue,size);
        }
    }
    if(opened) Chat(0,"^3%n ^1hücre kapılarını açtı. ^4%d ^1kapı açılıyor.",id,opened);
    else if(found) Chat(id,"Hücre kapıları zaten açık.");
    else Chat(id,"Hücre kapısı bulunamadı; yöneticine bildir.");
}

stock FC_InvalidateActivityCache() {g_fcActivityTime=-1.0;g_fcActivitySerial++;}

stock FC_OptCleanHints(const source[],dest[],len) {
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

stock FC_OptMenuCreate(const title[],const handler[],ml=0) {
    new clean[768];FC_OptCleanHints(title,clean,charsmax(clean));return menu_create(clean,handler,ml);
}
stock FC_OptMenuAdd(menu,const text[],const info[]="",access=0,callback=-1) {
    new clean[512];FC_OptCleanHints(text,clean,charsmax(clean));return menu_additem(menu,clean,info,access,callback);
}

CancelSpawnWork(id) {
    remove_task(id);remove_task(id+TASK_SPAWN_MENU);remove_task(id+TASK_PROFESSION_SPAWN);
    remove_task(id+TASK_LUCKY_REVIVE);g_iSpawnMenuSession[id]=0;g_iProfessionSession[id]=0;
}
QueueSpawnMenu(id,Float:delay) {
    remove_task(id+TASK_SPAWN_MENU);g_iSpawnMenuTry[id]=0;
    g_iSpawnMenuSession[id]=get_user_userid(id);g_iSpawnMenuLife[id]=g_iLifeSerial[id];
    set_task(delay,"TaskSpawnMenu",id+TASK_SPAWN_MENU);
}
QueueProfessionSpawn(id,Float:delay) {
    remove_task(id+TASK_PROFESSION_SPAWN);
    g_iProfessionSession[id]=get_user_userid(id);g_iProfessionLife[id]=g_iLifeSerial[id];
    set_task(delay,"TaskProfessionSpawn",id+TASK_PROFESSION_SPAWN);
}
public TaskProfessionSpawn(task) {
    new id=task-TASK_PROFESSION_SPAWN;
    if(id<1 || id>MaxClients || !is_user_alive(id) || g_iProfessionSession[id]!=get_user_userid(id)
        || g_iProfessionLife[id]!=g_iLifeSerial[id]) return;
    ApplyProfessionSpawn(id);
}
