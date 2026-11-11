
  JB Kim Milyoner Olmak Ister - PROFESSIONAL EDITION
  Counter-Strike 1.6  AMX Mod X 1.9+
 
  Ozellikler
   - JailBreak uyumlu T mahkumlari arasinda toplu yarisma
   - CT tarafindan milyoner ile baslatma
   - Adminler icin amx_milyoner startstopreset
   - Cevaplar her soruda karistirilir
   - Cevaplama klasik CS show_menu vote sistemi ile yapilir (1=A, 2=B, 3=C, 4=D)
   - Disconnect  yeni round  map sonu task temizligi
   - Opsiyonel baslangic MP3
   - Soru Director HUD'da; okuma ve cevap asamalarinda duzenli yenilenir
   - Cevap suresi varsayilan 10 saniye
   - Siklar yalniz menu icindedir; soru cevap verirken gorunmeye devam eder
   - CS 1.6 klasik show_menu sistemi ile cevaplama (1=A, 2=B, 3=C, 4=D)
   - Dogru cevapta opsiyonel dogru.wav sesi
   - Joker ve para odulu sistemleri plugin icinden tamamen kaldirildi
   - AMX Mod X 1.10 API ile uyumlu, 1.9+ ile derlenebilir
 

#include amxmodx
#include amxmisc
#include cstrike

native boolfc_ct_game_active()
native fc_ct_game_id()
native boolfc_ct_provider_allowed(game, caller)

#define MAX_PLAYERS 32
#define MAX_QUESTIONS 512
#define ANSWERS 4

#define PHASE_IDLE 0
#define PHASE_SHOW 1
#define PHASE_ANSWER 2
#define PHASE_END 3
#define PHASE_INTRO 4

#define TASK_NEXT 9101
#define TASK_SHOW 9102
#define TASK_END 9103
#define TASK_CLOCK 9104
#define TASK_NEXT_ROUND 9105
#define TASK_HUD 9106
#define TASK_INTRO 9107
#define TASK_RESULT 9108
#define TASK_LOGO 9109

#define ADMIN_FLAG ADMIN_KICK

new const PLUGIN_NAME[] = FeliciaClan Kim Milyoner Olmak Ister
new const PLUGIN_VERSION[] = 4.0.5-CT2
new const PLUGIN_AUTHOR[] = OpenAI

new const CHAT_TAG[] = ^1[ ^3- ^4FeliciaClan ^3- ^1]
new const LOGO_SPRITE[] = spritesFeliciaClanmilyoner_baslangic_v403.spr
new const LOGO_HUD_FILE[] = spritesfc_mil_intro403.txt
new const LOGO_HUD_NAME[] = fc_mil_intro403
#define LOGO_HUD_WEAPON 2  reserved CS HUD id; never given as a real weapon
new g_questions[MAX_QUESTIONS][192]
new g_answers[MAX_QUESTIONS][ANSWERS][96]
new g_correct[MAX_QUESTIONS]
new g_questionCount
new g_questionPath[256]

new g_running
new g_phase
new g_current
new g_current_correct
new g_pool[MAX_QUESTIONS]
new g_pool_pos
new g_question_number
new g_time_left
new g_msgsyncQuestion
new g_msgsyncTimer
new g_answerMenuId
new g_ctMenuId
new Floatg_show_deadline
new Floatg_answer_deadline
new Floatg_nextHudDraw
new g_questionHud[192]
new g_questionHudTop[128], g_questionHudBottom[128]
new Floatg_introEnd
new Floatg_nextIntroDraw
new g_logoIndex
new boolg_introLogoOK[MAX_PLAYERS + 1]
new boolg_logoShown[MAX_PLAYERS + 1], boolg_logoDirty[MAX_PLAYERS + 1]
new g_realWeapon[MAX_PLAYERS + 1], g_realClip[MAX_PLAYERS + 1], g_realFov[MAX_PLAYERS + 1]
new g_logoDefinedWeapon[MAX_PLAYERS + 1]
new boolg_weaponInfoKnown[MAX_PLAYERS + 1][CSW_LAST_WEAPON + 1]
new g_weaponAmmoInfo[MAX_PLAYERS + 1][CSW_LAST_WEAPON + 1][4]
new g_msgWeaponList, g_msgCurWeapon, g_msgSetFov
new Floatg_resultUntil
new g_resultAnswer[128], g_resultLetter[2]
new g_current_answers[ANSWERS][96]
new boolg_participant[MAX_PLAYERS + 1]
new boolg_answered[MAX_PLAYERS + 1]
new g_answer[MAX_PLAYERS + 1]
new boolg_has_start_sound
new boolg_has_correct_sound
new boolg_has_question_sound

new p_show_time
new p_answer_time
new p_min_players
new p_admin_only
new p_auto_start
new p_intro_time, p_debug, p_logo
new g_fwPrepare, g_fwStarted, g_fwFinished

public plugin_natives()
{
    register_library(fc_milyoner)
    set_native_filter(OptionalCTNative)
    register_native(milyoner_start, N_MilyStart)
    register_native(milyoner_stop, N_MilyStop)
    register_native(milyoner_active, N_MilyActive)
    register_native(milyoner_is_player, N_MilyPlayer)
    register_native(milyoner_get_alive, N_MilyAlive)
    register_native(milyoner_reload, N_MilyReload)
}
public OptionalCTNative(const name[], index, trap)
{
    if (!trap && contain(name,fc_ct_) == 0) return PLUGIN_HANDLED
    return PLUGIN_CONTINUE
}
boolNativeCallerOK(id)
{
    return !id  (id = 1 && id = MAX_PLAYERS && is_user_connected(id) &&
        ((is_user_alive(id) && cs_get_user_team(id) == CS_TEAM_CT)  (get_user_flags(id) & ADMIN_FLAG)))
}
public N_MilyStart(plugin,argc)
{
    new id = argc  get_param(1)  0
    if (!NativeCallerOK(id)) return 0
    return StartQuiz(id)
}
public N_MilyStop(plugin,argc)
{
    new id = argc  get_param(1)  0
    if (!NativeCallerOK(id)  !g_running) return 0
    EndQuiz(0,false)
    return 1
}
public N_MilyActive(plugin,argc) { return g_running; }
public N_MilyPlayer(plugin,argc)
{
    new id = get_param(1)
    return id = 1 && id = MAX_PLAYERS && g_running && g_participant[id] && is_user_alive(id) && cs_get_user_team(id) == CS_TEAM_T
}
public N_MilyAlive(plugin,argc) { return CountParticipants(); }
public N_MilyReload(plugin,argc)
{
    new id = argc  get_param(1)  0
    if (!NativeCallerOK(id)  g_running) return 0
    LoadQuestions()
    return g_questionCount
}


public plugin_init()
{
    register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)
    g_fwPrepare = CreateMultiForward(milyoner_prepare,ET_IGNORE,FP_CELL,FP_CELL)
    g_fwStarted = CreateMultiForward(milyoner_started,ET_IGNORE,FP_CELL,FP_CELL)
    g_fwFinished = CreateMultiForward(milyoner_finished,ET_IGNORE,FP_CELL,FP_CELL)

    register_clcmd(say milyoner, cmdStart)
    register_clcmd(say_team milyoner, cmdStart)
    register_clcmd(LOGO_HUD_NAME, IgnoreIntroWeapon)

    g_msgWeaponList = get_user_msgid(WeaponList)
    g_msgCurWeapon = get_user_msgid(CurWeapon)
    g_msgSetFov = get_user_msgid(SetFOV)
    if (g_msgWeaponList) register_message(g_msgWeaponList, TrackLogoWeaponInfo)
    if (g_msgCurWeapon) register_message(g_msgCurWeapon, TrackLogoCurWeapon)
    if (g_msgSetFov) register_message(g_msgSetFov, TrackLogoFov)

    register_concmd(amx_milyoner, cmdAdmin, ADMIN_FLAG, startstopresetreloadstatus)


    register_event(HLTV, EventNewRound, a, 1=0, 2=0)

    p_show_time = register_cvar(jb_milyoner_show_time, 7.0)  Soru HUD on gosterim 7 sn
    p_answer_time = register_cvar(jb_milyoner_answer_time, 10.0)  Sorucevap muzigi + menu 10 sn
    p_min_players = register_cvar(jb_milyoner_min_players, 1)
    p_admin_only = register_cvar(jb_milyoner_admin_only, 0)
    p_auto_start = register_cvar(jb_milyoner_auto_start, 0)
    p_intro_time = register_cvar(jb_milyoner_intro_time, 13.0)
    p_logo = register_cvar(jb_milyoner_logo, 1)
    p_debug = register_cvar(jb_milyoner_debug, 1)
    register_cvar(jb_milyoner_prefix, FeliciaClan)  eski CFG uyumu; tag JBMenu ile sabit

    g_msgsyncQuestion = CreateHudSyncObj()
    g_msgsyncTimer = CreateHudSyncObj()

    g_answerMenuId = register_menuid(Cevabinizi secin)
    register_menucmd(g_answerMenuId, MENU_KEY_1MENU_KEY_2MENU_KEY_3MENU_KEY_4, MilyonerAnswerMenu)
    g_ctMenuId = register_menuid(FeliciaClan Milyoner CT)
    register_menucmd(g_ctMenuId, 1023, MilyonerCtMenu)
    new configs[192]
    get_configsdir(configs, charsmax(configs))
    formatex(g_questionPath, charsmax(g_questionPath), %sFeliciaClanjb_milyoner_sorular.ini, configs)
}


public plugin_precache()
{
    p_logo = register_cvar(jb_milyoner_logo, 1)
    if (get_pcvar_num(p_logo) && file_exists(LOGO_SPRITE) && file_exists(LOGO_HUD_FILE))
    {
         HUD sprites are client resources, not world modelsserver edicts.
        precache_generic(LOGO_SPRITE)
        precache_generic(LOGO_HUD_FILE)
        g_logoIndex = 1
    }
    if (file_exists(soundjb_milyonerbasliyor.mp3))
    {
        precache_generic(soundjb_milyonerbasliyor.mp3)
        g_has_start_sound = true
    }

    if (file_exists(soundjb_milyonerdogru.wav))
    {
        precache_sound(jb_milyonerdogru.wav)
        g_has_correct_sound = true
    }

    if (file_exists(soundjb_milyonersoru.wav))
    {
        precache_sound(jb_milyonersoru.wav)
        g_has_question_sound = true
    }
}

public plugin_cfg()
{
    TraceStage(v%s MAP_READY, PLUGIN_VERSION)
    LoadQuestions()
    TraceStage(INI_READY questions=%d SPR_index=%d, g_questionCount, g_logoIndex)
    if (get_pcvar_num(p_auto_start)  0)
        server_print([Milyoner] Otomatik başlatma açık yeni round sonrası başlar.)
}

public EventNewRound()
{
    TraceStage(NEW_ROUND running=%d phase=%d, g_running, g_phase)
    if (g_running)
        EndQuiz(0, false)

    ResetQuizState(true)

    if (get_pcvar_num(p_auto_start)  0)
    {
        remove_task(TASK_NEXT)
        set_task(3.0, AutoStartQuiz, TASK_NEXT)
    }
}

public AutoStartQuiz()
{
    if (g_running)
        return

    if (CountAliveTerrorists()  get_pcvar_num(p_min_players))
        return

    StartQuiz(0)
}

public client_putinserver(id)
{
    g_participant[id] = false
    g_answered[id] = false
    g_answer[id] = 0
    ResetLogoClient(id)
}

public client_disconnected(id, booldrop, message[], maxlen)
{
    #pragma unused drop, message, maxlen
    g_participant[id] = false
    g_answered[id] = false
    g_answer[id] = 0
    ResetLogoClient(id)

    if (g_running && CountParticipants()  get_pcvar_num(p_min_players))
        EndQuiz(0, false)
}

public cmdStart(id)
{
    if (!is_user_connected(id))
        return PLUGIN_HANDLED

    if (get_pcvar_num(p_admin_only) && !(get_user_flags(id) & ADMIN_FLAG))
    {
        PrintChat(id, Bu komut sadece yetkililere açık.)
        return PLUGIN_HANDLED
    }

    if (cs_get_user_team(id) != CS_TEAM_CT && !(get_user_flags(id) & ADMIN_FLAG))
    {
        PrintChat(id, Yarışmayı yalnız CT tarafı veya yetkililer başlatabilir.)
        return PLUGIN_HANDLED
    }

    if (g_running)
    {
        PrintChat(id, Yarışma zaten devam ediyor.)
        return PLUGIN_HANDLED
    }

    if (CountAliveTerrorists()  get_pcvar_num(p_min_players))
    {
        PrintChat(id, Yarışma için en az ^4%d ^1canlı T gerekiyor., get_pcvar_num(p_min_players))
        return PLUGIN_HANDLED
    }

    StartQuiz(id)
    return PLUGIN_HANDLED
}

public cmdAdmin(id, level, cid)
{
    if (!cmd_access(id, level, cid, 2))
        return PLUGIN_HANDLED

    new arg[16]
    read_argv(1, arg, charsmax(arg))

    if (equali(arg, start))
    {
        if (!g_running)
            StartQuiz(id)
        else
            console_print(id, [Milyoner] Zaten aktif.)
    }
    else if (equali(arg, stop))
    {
        if (g_running)
            EndQuiz(0, false)
        else
            console_print(id, [Milyoner] Zaten kapalı.)
    }
    else if (equali(arg, reset))
    {
        if (g_running)
            EndQuiz(0, false)
        ResetQuizState()
        console_print(id, [Milyoner] Durum sıfırlandı.)
    }
    else if (equali(arg, reload))
    {
        if (g_running)
            console_print(id, [FeliciaClan] Oyun aktif; INI sonraki yarışmada yeniden okunacak.)
        else
            console_print(id, [FeliciaClan] INI'den %d geçerli soru yüklendi., LoadQuestions())
    }
    else if (equali(arg, status))
        console_print(id, [FeliciaClan] Milyoner v%s  aktif=%d  soru=%d  SPR=%d  %s, PLUGIN_VERSION, g_running, g_questionCount, g_logoIndex  0 && get_pcvar_num(p_logo)  0, g_questionPath)
    else
    {
        console_print(id, Kullanım amx_milyoner startstopresetreloadstatus)
    }

    return PLUGIN_HANDLED
}

StartQuiz(caller = 0)
{
    if(LibraryExists(fc_ctmenu,LibType_Library) && !fc_ct_provider_allowed(13,caller)) {
        if(caller) PrintChat(caller,Bu oyun için önceki el Godmode seçilmiş ve bu el açık olmalıdır.)
        return 0
    }
    if (g_running) return 0
    if (LibraryExists(fc_ctmenu,LibType_Library) && fc_ct_game_active() && fc_ct_game_id() != 13)
    {
        if (caller) PrintChat(caller,Önce CT menüsündeki aktif oyunu durdur.)
        return 0
    }
    if (CountAliveTerrorists()  get_pcvar_num(p_min_players)) return 0
    TraceStage(START_REQUEST)
    if (!LoadQuestions())
    {
        TraceStage(START_CANCEL no_valid_questions)
        PrintChatAll(Soru dosyasında geçerli soru yok. ^4jb_milyoner_sorular.ini ^1dosyasını kontrol edin.)
        return 0
    }
    TraceStage(START_INI_READY questions=%d, g_questionCount)
    new prepareResult
    ExecuteForward(g_fwPrepare,prepareResult,caller,CountAliveTerrorists())
    ClearCorrectResult()
    g_running = 1
    CloseAnswerMenus()
    g_phase = PHASE_INTRO
    g_current = -1
    g_current_correct = 0
    g_pool_pos = 0
    g_question_number = 0

    remove_task(TASK_NEXT)
    remove_task(TASK_SHOW)
    remove_task(TASK_END)
    remove_task(TASK_CLOCK)
    remove_task(TASK_HUD)
    StopIntro()

    for (new i = 1; i = MAX_PLAYERS; i++)
    {
        g_participant[i] = false
        g_answered[i] = false
        g_answer[i] = 0

        if (is_user_alive(i) && cs_get_user_team(i) == CS_TEAM_T)
            g_participant[i] = true
    }

    if (CountParticipants()  get_pcvar_num(p_min_players))
    {
        TraceStage(START_CANCEL insufficient_players)
        g_running = 0
        return 0
    }

    ShuffleQuestions()

    if (g_has_start_sound)
    {
        client_cmd(0, mp3 stop)
        client_cmd(0, mp3 play soundjb_milyonerbasliyor.mp3)
    }

    PrintChatAll(^4Kim Milyoner Olmak İster ^1başlıyor! Mahkûmlar cevap menüsünden seçim yapabilir.)

    new FloatintroTime = floatclamp(get_pcvar_float(p_intro_time), 1.0, 30.0)
    if (g_has_start_sound) introTime = floatmax(introTime, 13.0)
    g_introEnd = get_gametime() + introTime
    g_nextIntroDraw = 0.0
    TraceStage(INTRO_BEGIN participants=%d, CountParticipants())
    IntroLogoTick()
    IntroTick()
    set_task(0.5, IntroTick, TASK_INTRO, , 0, b)
    if (g_logoIndex  0 && get_pcvar_num(p_logo))
        set_task(0.1, IntroLogoTick, TASK_LOGO, , 0, b)
    set_task(introTime, StartFirstQuestion, TASK_NEXT)
    new startedResult
    ExecuteForward(g_fwStarted,startedResult,caller,CountParticipants())
    return 1
}

public StartFirstQuestion()
{
    if (!g_running  g_phase != PHASE_INTRO)
        return

    TraceStage(INTRO_END)
    StopIntro()
    NextQuestion()
}

ShuffleQuestions()
{
    for (new i = 0; i  g_questionCount; i++)
        g_pool[i] = i

    for (new i = g_questionCount - 1; i  0; i--)
    {
        new j = random_num(0, i)
        new tmp = g_pool[i]
        g_pool[i] = g_pool[j]
        g_pool[j] = tmp
    }
}

PrepareCurrentQuestion()
{
    new order[ANSWERS] = {0, 1, 2, 3}

    for (new i = ANSWERS - 1; i  0; i--)
    {
        new j = random_num(0, i)
        new tmp = order[i]
        order[i] = order[j]
        order[j] = tmp
    }

    g_current_correct = 0

    for (new i = 0; i  ANSWERS; i++)
    {
        copy(g_current_answers[i], charsmax(g_current_answers[]), g_answers[g_current][order[i]])

        if (order[i] + 1 == g_correct[g_current])
            g_current_correct = i + 1
    }
}

public NextQuestion()
{
    if (!g_running)
        return

    new alive = CountParticipants()

    if (alive  get_pcvar_num(p_min_players))
    {
        EndQuiz(0, false)
        return
    }

     Tum sorular kullanildiysa ve birden fazla mahkum hala hayattaysa,
     havuzu yeniden karistirip yarismayi son mahkum kalana kadar surdur.
     Boylece soru sayisi mahkum sayisina bagli olarak yarismayi erken bitirmez.
    if (g_pool_pos = g_questionCount)
    {
        ShuffleQuestions()
        g_pool_pos = 0
    }

    g_current = g_pool[g_pool_pos++]
    g_question_number++
    TraceStage(QUESTION_BEGIN number=%d index=%d participants=%d, g_question_number, g_current, alive)
    g_phase = PHASE_SHOW
    g_time_left = 0

    for (new i = 1; i = MAX_PLAYERS; i++)
    {
        g_answered[i] = false
        g_answer[i] = 0
    }

    PrepareCurrentQuestion()
    WrapQuestion(g_questions[g_current], g_questionHud, charsmax(g_questionHud))
    SplitQuestionHud()
    g_nextHudDraw = 0.0
    new FloatshowTime = floatclamp(get_pcvar_float(p_show_time), 1.0, 30.0)
    g_show_deadline = get_gametime() + showTime
    ShowQuestion()

    remove_task(TASK_SHOW)
    set_task(showTime, BeginAnswerPhase, TASK_SHOW)
    remove_task(TASK_HUD)
    set_task(0.5, RefreshQuestionHud, TASK_HUD, , 0, b)
}

ShowQuestion()
{
    RefreshQuestionHud()

     Soru HUD'u gelir gelmez soru.wav baslar. Ses 10 saniyedir.
    if (g_has_question_sound)
        client_cmd(0, spk jb_milyonersoru)
}

 Count UTF-8 characters, not continuation bytes, when wrapping lines.
WrapQuestion(const text[], output[], maxlen)
{
    new out, column, lastSpace = -1
    for (new i = 0; text[i] && out  maxlen; i++)
    {
        output[out] = text[i]
        if (text[i] == ' ') lastSpace = out
        out++
        if ((text[i] & 0xC0) != 0x80) column++
        if (column = 42 && lastSpace = 0)
        {
            output[lastSpace] = '^n'
            column = 0
            for (new j = lastSpace + 1; j  out; j++)
                if ((output[j] & 0xC0) != 0x80) column++
            lastSpace = -1
        }
    }
    output[out] = 0
}

Utf8Cut(const text[], limit)
{
    new count = min(strlen(text), limit)
    while (count  0 && (text[count] & 0xC0) == 0x80) count--
    return count
}

SplitQuestionHud()
{
    g_questionHudBottom[0] = 0
    if (strlen(g_questionHud) = 120)
    {
        copy(g_questionHudTop, charsmax(g_questionHudTop), g_questionHud)
        return
    }
    new cut = Utf8Cut(g_questionHud, 120), split = cut
    new minimum = max(40, strlen(g_questionHud)-120)
    for (new i = split; i = minimum; i--)
        if (g_questionHud[i] == '^n') { split = i; break; }
    if (split == cut)
        for (new i = split; i = minimum; i--)
            if (g_questionHud[i] == ' ') { split = i; break; }
    copy(g_questionHudTop, split, g_questionHud)
    if (g_questionHud[split] == '^n'  g_questionHud[split] == ' ') split++
    copy(g_questionHudBottom, charsmax(g_questionHudBottom), g_questionHud[split])
}

public RefreshQuestionHud()
{
    if (!g_running  (g_phase != PHASE_SHOW && g_phase != PHASE_ANSWER))
    {
        remove_task(TASK_HUD)
        return
    }
    if (CountParticipants()  get_pcvar_num(p_min_players))
    {
        EndQuiz(0, false)
        return
    }

     Director HUD uses a separate stack, independent of normal JB HUD
     channels. Short messages are refreshed, not left on screen for 20s.
     Title + up to two body blocks at most six director entries overlap.
    new Floatnow = get_gametime()
     Phase changes may call this at the same time as the repeating task.
     Update the status immediately, but do not duplicate a question card.
    if (now = g_nextHudDraw)
    {
        set_dhudmessage(255, 215, 55, -1.0, 0.10, 0, 0.0, 0.6, 0.0, 0.0)
        show_dhudmessage(0, FELICIACLAN  SORU %d, g_question_number)
        set_dhudmessage(255, 235, 175, -1.0, 0.19, 0, 0.0, 0.6, 0.0, 0.0)
        show_dhudmessage(0, %s, g_questionHudTop)
        if (g_questionHudBottom[0])
        {
            set_dhudmessage(255, 235, 175, -1.0, 0.38, 0, 0.0, 0.6, 0.0, 0.0)
            show_dhudmessage(0, %s, g_questionHudBottom)
        }
        g_nextHudDraw = now + 0.45
        ShowCtAnswerMenus(now)
    }
    if (g_phase == PHASE_ANSWER)
        g_time_left = floatround(floatmax(0.0, g_answer_deadline - now), floatround_ceil)
    for (new id = 1; id = MAX_PLAYERS; id++)
        if (is_user_connected(id)) ShowPlayerStatus(id, now)
}

ShowPlayerStatus(id, Floatnow)
{
    new boolplaying = g_participant[id] && is_user_alive(id) && cs_get_user_team(id) == CS_TEAM_T
    if (g_phase == PHASE_SHOW)
    {
        new remaining = floatround(floatmax(0.0, g_show_deadline - now), floatround_ceil)
        set_hudmessage(100, 185, 255, -1.0, 0.59, 0, 0.0, 0.6, 0.0, 0.0, -1)
        ShowSyncHudMsg(id, g_msgsyncTimer, SORUYU OKU  %d sn^nCevap menüsü birazdan açılacak., remaining)
    }
    else if (playing && g_answered[id])
    {
        new letter[2]
        letter[0] = 'A' + g_answer[id] - 1
        set_hudmessage(80, 255, 125, -1.0, 0.59, 0, 0.0, 0.6, 0.0, 0.0, -1)
        ShowSyncHudMsg(id, g_msgsyncTimer, CEVABIN %s  Kalan %d sn^nCevabın kaydedildi., letter, g_time_left)
    }
    else
    {
        set_hudmessage(255, g_time_left = 3  75  215, 55, -1.0, 0.59, 0, 0.0, 0.6, 0.0, 0.0, -1)
        if (playing)
            ShowSyncHudMsg(id, g_msgsyncTimer, CEVAP SÜRESİ  %d sn^nMenüden cevabını seç., g_time_left)
        else
            ShowSyncHudMsg(id, g_msgsyncTimer, CEVAPLAR BEKLENİYOR  %d sn, g_time_left)
    }
}

public BeginAnswerPhase()
{
    if (!g_running  g_phase != PHASE_SHOW)
        return

    g_phase = PHASE_ANSWER
    TraceStage(ANSWER_BEGIN number=%d, g_question_number)
    new FloatanswerTime = floatclamp(get_pcvar_float(p_answer_time), 1.0, 60.0)
    g_answer_deadline = get_gametime() + answerTime
    g_time_left = floatround(answerTime, floatround_ceil)

    
      Keep the question visible during answering. Only the choices are
      in the classic menu; no chat copy and no second choices HUD.
     
    ClearSyncHud(0, g_msgsyncQuestion)
    RefreshQuestionHud()

    remove_task(TASK_CLOCK)
    set_task(1.0, TickClock, TASK_CLOCK, , 0, b)

    ShowAnswerMenus()

    remove_task(TASK_END)
    set_task(answerTime, EvaluateAnswers, TASK_END)
}

public TickClock()
{
    if (!g_running  g_phase != PHASE_ANSWER)
    {
        remove_task(TASK_CLOCK)
        return
    }

    g_time_left = floatround(floatmax(0.0, g_answer_deadline - get_gametime()), floatround_ceil)

    if (g_time_left  0)
        ShowAnswerMenus()
}

public MilyonerAnswerMenu(id, key)
{
    if (!g_running  g_phase != PHASE_ANSWER)
        return PLUGIN_HANDLED

    if (id  1  id  MAX_PLAYERS  key  0  key = ANSWERS)
        return PLUGIN_HANDLED

    if (get_gametime() = g_answer_deadline)
        return PLUGIN_HANDLED

    if (!is_user_alive(id)  !g_participant[id]  cs_get_user_team(id) != CS_TEAM_T)
        return PLUGIN_HANDLED

    if (g_answered[id])
        return PLUGIN_HANDLED

    new answer = key + 1
    HandleAnswer(id, answer)
    return PLUGIN_HANDLED
}

public MilyonerCtMenu(id, key)
{
    #pragma unused id, key
     Only the hidden 0 key is enabled so CS renders the information menu.
     Every callback is ignored; CT never submits a quiz answer.
    return PLUGIN_HANDLED
}

ShowAnswerMenus()
{
    new menuText[1024]
    new time = g_time_left
    BuildAnswerMenu(menuText, charsmax(menuText), false, time)
    new keys = MENU_KEY_1MENU_KEY_2MENU_KEY_3MENU_KEY_4

    for (new id = 1; id = MAX_PLAYERS; id++)
    {
        if (is_user_alive(id) && g_participant[id] && cs_get_user_team(id) == CS_TEAM_T && !g_answered[id])
            show_menu(id, keys, menuText, time, Cevabinizi secin)
    }
}

ShowCtAnswerMenus(Floatnow)
{
    new menuText[1024]
    new remaining = floatround(floatmax(0.0, (g_phase == PHASE_SHOW  g_show_deadline  g_answer_deadline)-now), floatround_ceil)
    BuildAnswerMenu(menuText, charsmax(menuText), true, remaining)
    for (new id = 1; id = MAX_PLAYERS; id++)
    {
        if (!is_user_connected(id)) continue
        if (cs_get_user_team(id) == CS_TEAM_CT)
             A zero key mask CLOSES ShowMenu on the client. Keep only 0
             enabled; ABCD (1234) remain disabled, with no exit row.
            show_menu(id, MENU_KEY_0, menuText, max(1, remaining), FeliciaClan Milyoner CT)
        else
        {
            new menuId, keys
            get_user_menu(id, menuId, keys)
            if (menuId == g_ctMenuId) show_menu(id, 0, ^n, 1)
        }
    }
}

BuildAnswerMenu(menuText[], maxlen, boolobserver, remaining)
{
    new colors[ANSWERS][3], title[32]
    copy(title, charsmax(title), observer  ŞIKLAR  CT  CEVABINIZI SEÇİN)
    for (new i = 0; i  ANSWERS; i++)
        copy(colors[i], charsmax(colors[]), observer && i+1 == g_current_correct  r  w)
    formatex(menuText, maxlen, ySORU %d  %sw^n%s^n^nrA-)%s %s^nrB-)%s %s^nrC-)%s %s^nrD-)%s %s^n^nyKalan süre r%dw saniye,
        g_question_number, title, g_questionHud,
        colors[0], g_current_answers[0], colors[1], g_current_answers[1],
        colors[2], g_current_answers[2], colors[3], g_current_answers[3], remaining)
     Keep all four options inside the stock 511-byte ShowMenu limit.
    if (strlen(menuText)  510)
        formatex(menuText, maxlen, yFELICIACLAN  SORU %dw^ny%sw^n^nrA-)%s %s^nrB-)%s %s^nrC-)%s %s^nrD-)%s %s^n^nyKalan süre r%dw sn,
            g_question_number, title,
            colors[0], g_current_answers[0], colors[1], g_current_answers[1],
            colors[2], g_current_answers[2], colors[3], g_current_answers[3], remaining)
}

CloseAnswerMenus()
{
    for (new id = 1; id = MAX_PLAYERS; id++)
        CloseAnswerMenu(id)
}

CloseAnswerMenu(id)
{
    if (!is_user_connected(id)) return
    new menuId, keys
    get_user_menu(id, menuId, keys)
     Close only this plugin's voting or CT information menu.
    if (menuId == g_answerMenuId  menuId == g_ctMenuId)
        show_menu(id, 0, ^n, 1)
}

HandleAnswer(id, answer)
{
    if (!g_running  g_phase != PHASE_ANSWER)
        return PLUGIN_CONTINUE

    if (!is_user_alive(id)  !g_participant[id]  cs_get_user_team(id) != CS_TEAM_T)
        return PLUGIN_CONTINUE

    if (g_answered[id])
    {
        client_print(id, print_center, Cevabın zaten kaydedildi!)
        return PLUGIN_HANDLED
    }

    g_answered[id] = true
    g_answer[id] = answer

    new letter[2]
    letter[0] = 'A' + answer - 1
    letter[1] = 0

     Confirmation has its own HUD; the question card stays visible.
    g_time_left = floatround(floatmax(0.0, g_answer_deadline - get_gametime()), floatround_ceil)
    ShowPlayerStatus(id, get_gametime())
    CloseAnswerMenu(id)
    client_print(id, print_center, İşaretlenen şık %s - Cevabınız kaydedildi., letter)

    return PLUGIN_HANDLED
}

public EvaluateAnswers()
{
    if (!g_running  g_phase != PHASE_ANSWER)
        return

    TraceStage(EVALUATE_BEGIN number=%d, g_question_number)
    remove_task(TASK_CLOCK)
    remove_task(TASK_HUD)
    ClearSyncHud(0, g_msgsyncTimer)
    CloseAnswerMenus()
    if (g_has_question_sound)
        client_cmd(0, spk stop)
    g_phase = PHASE_IDLE

    new survivors = 0
    new last = 0

    for (new i = 1; i = MAX_PLAYERS; i++)
    {
        if (!g_participant[i])
            continue

        if (!is_user_connected(i)  !is_user_alive(i)  cs_get_user_team(i) != CS_TEAM_T)
        {
            g_participant[i] = false
            continue
        }

        if (!g_answered[i]  g_answer[i] != g_current_correct)
        {
            TraceStage(ELIMINATE player=%d, i)
            user_kill(i, 1)
            g_participant[i] = false
        }
        else
        {
            survivors++
            last = i
        }
    }
    TraceStage(EVALUATE_END survivors=%d, survivors)

    if (survivors = 0)
    {
        EndQuiz(0, false, true)
        return
    }

    if (g_has_correct_sound)
        client_cmd(0, spk jb_milyonerdogru)  dogru.wav 2 saniye, sonraki soru 2 sn sonra

    if (survivors == 1)
    {
        EndQuiz(last, true)
        return
    }

     Soru havuzu bittiginde NextQuestion() havuzu yeniden karistirir.
     Burada yarismayi bitirmiyoruz; son mahkum kalana kadar devam ediyor.

    set_hudmessage(0, 255, 80, -1.0, 0.34, 0, 0.1, 2.0, 0.1, 0.1, -1)
    ShowSyncHudMsg(0, g_msgsyncQuestion, %d mahkûm doğru cevap verdi!^nDOĞRU BİLDİNİZ!^nYeni soru geliyor..., survivors)

    remove_task(TASK_NEXT)
    set_task(2.0, NextQuestion, TASK_NEXT)
}

EndQuiz(winner, boolcompleted, boolallFailed = false)
{
    if (!g_running)
        return

    TraceStage(END winner=%d completed=%d, winner, completed)
    new correctAnswer[96], letter[2]
    if (allFailed && g_current = 0 && g_current_correct = 1 && g_current_correct = ANSWERS)
    {
        copy(correctAnswer, charsmax(correctAnswer), g_current_answers[g_current_correct-1])
        letter[0] = 'A'+g_current_correct-1
    }
    g_running = 0
    g_phase = PHASE_END

    remove_task(TASK_NEXT)
    remove_task(TASK_SHOW)
    remove_task(TASK_END)
    remove_task(TASK_CLOCK)
    remove_task(TASK_NEXT_ROUND)
    remove_task(TASK_HUD)
    StopIntro()
    ClearSyncHud(0, g_msgsyncTimer)

    CloseAnswerMenus()

    if (g_has_start_sound)
        client_cmd(0, mp3 stop)
    if (g_has_question_sound)
        client_cmd(0, spk stop)

    if (winner  0 && is_user_connected(winner))
    {
        new name[32]
        get_user_name(winner, name, charsmax(name))

        set_hudmessage(255, 215, 0, -1.0, 0.23, 0, 0.2, 6.0, 0.1, 0.2, -1)
        ShowSyncHudMsg(0, g_msgsyncQuestion, FELICIACLAN  KAZANAN^n^n%s^nTEBRİKLER!, name)
        PrintChatAll(^4Kazanan ^3%s^1. Tebrikler!, name)
    }
    else if (completed)
    {
        new count = 0
        for (new i = 1; i = MAX_PLAYERS; i++)
        {
            if (g_participant[i] && is_user_connected(i))
                count++
        }

        set_hudmessage(255, 215, 0, -1.0, 0.23, 0, 0.2, 6.0, 0.1, 0.2, -1)
        ShowSyncHudMsg(0, g_msgsyncQuestion, FELICIACLAN  FİNAL^n^n%d YARIŞMACI KALDI!, count)
        PrintChatAll(Yarışma tamamlandı.)
    }
    else if (!correctAnswer[0])
    {
        set_hudmessage(255, 80, 80, -1.0, 0.23, 0, 0.2, 5.0, 0.1, 0.2, -1)
        ShowSyncHudMsg(0, g_msgsyncQuestion, FELICIACLAN  KİM MİLYONER^n^nYarışma sona erdi!^nKazanan yok.)
        PrintChatAll(Yarışma sona erdi. Kazanan yok.)
    }

    ResetQuizState()
    if (correctAnswer[0])
    {
        WrapQuestion(correctAnswer, g_resultAnswer, charsmax(g_resultAnswer))
        copy(g_resultLetter, charsmax(g_resultLetter), letter)
        g_resultUntil = get_gametime()+5.0
        PrintChatAll(Herkes elendi. Doğru cevap ekranda gösteriliyor.)
        RefreshCorrectResult()
        set_task(0.5, RefreshCorrectResult, TASK_RESULT, , 0, b)
    }
    new finishedResult
    ExecuteForward(g_fwFinished,finishedResult,winner,completed  1  0)
}

public RefreshCorrectResult()
{
    if (g_running  get_gametime() = g_resultUntil) { ClearCorrectResult(); return; }
    set_dhudmessage(255, 215, 55, -1.0, 0.23, 0, 0.0, 0.6, 0.0, 0.0)
    show_dhudmessage(0, HERKES ELENDİ!^nDOĞRU CEVAP %s-), g_resultLetter)
    set_dhudmessage(255, 75, 75, -1.0, 0.42, 0, 0.0, 0.6, 0.0, 0.0)
    show_dhudmessage(0, %s, g_resultAnswer)
}

ClearCorrectResult()
{
    remove_task(TASK_RESULT)
    g_resultUntil = 0.0
    g_resultAnswer[0] = 0
    g_resultLetter[0] = 0
}

CountParticipants()
{
    new count = 0

    for (new i = 1; i = MAX_PLAYERS; i++)
    {
        if (g_participant[i] && is_user_connected(i) && is_user_alive(i) && cs_get_user_team(i) == CS_TEAM_T)
            count++
    }

    return count
}

CountAliveTerrorists()
{
    new count = 0

    for (new i = 1; i = MAX_PLAYERS; i++)
    {
        if (is_user_alive(i) && cs_get_user_team(i) == CS_TEAM_T)
            count++
    }

    return count
}

PrintChat(id, const fmt[], any...)
{
    new message[158]
    vformat(message, charsmax(message), fmt, 3)
    client_print_color(id, id, %s ^1%s, CHAT_TAG, message)
}

PrintChatAll(const fmt[], any...)
{
    new message[158]
    vformat(message, charsmax(message), fmt, 2)
    client_print_color(0, 0, %s ^1%s, CHAT_TAG, message)
}

 No per-frame logging. These phase boundaries locate the last completed
 server operation if a provider's native crash happens outside Pawn.
TraceStage(const fmt[], any...)
{
    if (!p_debug  !get_pcvar_num(p_debug)) return
    new text[192]
    vformat(text, charsmax(text), fmt, 2)
    log_to_file(jb_milyoner_debug.log, %s, text)
}

ResetQuizState(boolpreserveResult = false)
{
    new wasRunning = g_running
    remove_task(TASK_NEXT)
    remove_task(TASK_SHOW)
    remove_task(TASK_END)
    remove_task(TASK_CLOCK)
    remove_task(TASK_NEXT_ROUND)
    remove_task(TASK_HUD)
    StopIntro()
    if (!preserveResult) ClearCorrectResult()
    ClearSyncHud(0, g_msgsyncTimer)

    g_running = 0
    CloseAnswerMenus()
    g_phase = PHASE_IDLE
    g_current = -1
    g_current_correct = 0
    g_pool_pos = 0
    g_question_number = 0
    g_time_left = 0

    for (new i = 1; i = MAX_PLAYERS; i++)
    {
        g_participant[i] = false
        g_answered[i] = false
        g_answer[i] = 0
    }
    if (wasRunning)
    {
        new result
        ExecuteForward(g_fwFinished,result,0,2)
    }
}

public plugin_end()
{
    if (g_running) ResetQuizState()
    remove_task(TASK_NEXT)
    remove_task(TASK_SHOW)
    remove_task(TASK_END)
    remove_task(TASK_CLOCK)
    remove_task(TASK_NEXT_ROUND)
    remove_task(TASK_HUD)
    StopIntro()
    ClearCorrectResult()
    DestroyForward(g_fwPrepare)
    DestroyForward(g_fwStarted)
    DestroyForward(g_fwFinished)
}

 Standard editable INI one section per question, key=value lines.
LoadQuestions()
{
    g_questionCount = 0
    new file = fopen(g_questionPath, rt)
    if (!file)
    {
        log_to_file(jb_milyoner.log, Soru dosyası açılamadı %s, g_questionPath)
        return 0
    }
    new line[768], question[192], options[4][96], correct, lineNumber
    new boolsection, boolbad, sectionLine
    while (!feof(file))
    {
        line[0] = 0
        if (!fgets(file, line, charsmax(line))) break
        lineNumber++
        if (lineNumber == 1 && (line[0] & 255) == 0xEF && (line[1] & 255) == 0xBB && (line[2] & 255) == 0xBF)
            copy(line, charsmax(line), line[3])
        trim(line)
        if (!line[0]  line[0] == ';'  line[0] == '#') continue
        if (line[0] == '[')
        {
            if (section) StoreQuestion(question, options, correct, bad, sectionLine)
            section = true
            bad = line[strlen(line)-1] != ']'
            sectionLine = lineNumber
            question[0] = 0
            correct = 0
            for (new i = 0; i  4; i++) options[i][0] = 0
            continue
        }
        if (!section) continue
        new eq = contain(line, =)
        if (eq  1) { bad = true; continue; }
        new value[768]
        copy(value, charsmax(value), line[eq+1])
        line[eq] = 0
        trim(line)
        trim(value)
        remove_quotes(value)
        if (equali(line, soru))
        {
            if (strlen(value)  charsmax(question)) bad = true
            else copy(question, charsmax(question), value)
        }
        else if (equali(line, dogru)  equali(line, doğru))
        {
            if (value[1]) { bad = true; continue; }
            new letter = toupper(value[0])
            correct = letter = 'A' && letter = 'D'  letter-'A'+1  letter = '1' && letter = '4'  letter-'1'+1  0
        }
        else if (!line[1] && toupper(line[0]) = 'A' && toupper(line[0]) = 'D')
        {
            new slot = toupper(line[0])-'A'
            if (strlen(value)  charsmax(options[])) bad = true
            else copy(options[slot], charsmax(options[]), value)
        }
    }
    if (section) StoreQuestion(question, options, correct, bad, sectionLine)
    fclose(file)
    server_print([FeliciaClan] Milyoner INI'den %d geçerli soru yüklendi., g_questionCount)
    return g_questionCount
}

StoreQuestion(const question[], const options[4][96], correct, boolbad, line)
{
    if (bad  !question[0]  correct  1  correct  4  !options[0][0]  !options[1][0]  !options[2][0]  !options[3][0])
    {
        log_to_file(jb_milyoner.log, Geçersizeksik soru atlandı; bölüm başlangıcı satır %d., line)
        return
    }
    if (g_questionCount = MAX_QUESTIONS)
    {
        log_to_file(jb_milyoner.log, Azami %d soru sınırı aşıldı; satır %d atlandı., MAX_QUESTIONS, line)
        return
    }
    copy(g_questions[g_questionCount], charsmax(g_questions[]), question)
    for (new i = 0; i  4; i++)
        copy(g_answers[g_questionCount][i], charsmax(g_answers[][]), options[i])
    g_correct[g_questionCount++] = correct
}

 Fixed 2D HUD via the client's own crosshair sprite renderer.
 Protocol WeaponList(id 2), temporary SetFOV(89), CurWeapon, restored FOV.
 The FOV pair is sent together; the actual player FOVweapon is never changed.
 No world sprite, entity, camera coordinates or per-frame packet edits.
 Method reference HamletEagle, Sprites on Hud, AlliedModders t=353126.
StopIntro()
{
    remove_task(TASK_INTRO)
    remove_task(TASK_LOGO)
    for (new id = 1; id = MAX_PLAYERS; id++) ClearIntroLogo(id)
    g_introEnd = 0.0
}

public IntroLogoTick()
{
    if (!g_running  g_phase != PHASE_INTRO  g_introEnd = get_gametime()
         !g_logoIndex  !get_pcvar_num(p_logo)
         !g_msgWeaponList  !g_msgCurWeapon  !g_msgSetFov)
    {
        remove_task(TASK_LOGO)
        for (new id = 1; id = MAX_PLAYERS; id++) ClearIntroLogo(id)
        return
    }
    for (new id = 1; id = MAX_PLAYERS; id++)
    {
        if (!is_user_alive(id)  (g_realFov[id]  0 && g_realFov[id]  90))
        {
             A scope has priority. Deadspectating clients use the text HUD.
            ClearIntroLogo(id)
            continue
        }
        if (!g_logoShown[id])
        {
            new clip, ammo, weapon = get_user_weapon(id, clip, ammo)
            if (!ValidLogoWeapon(weapon)) continue
            g_realWeapon[id] = weapon
            g_realClip[id] = clip & 255
            g_logoDirty[id] = true
        }
         Movement never needs a resend the client draws the same screen sprite.
        if (!g_logoDirty[id]) continue
        new weapon = g_realWeapon[id]
        if (!ValidLogoWeapon(weapon)) continue
        if (g_logoDefinedWeapon[id] != weapon)
        {
            SendIntroWeaponList(id, weapon)
            g_logoDefinedWeapon[id] = weapon
        }
        SendLogoFov(id, 89)
        SendLogoCurWeapon(id, 1, LOGO_HUD_WEAPON, g_realClip[id])
        SendLogoFov(id, g_realFov[id])
        g_logoShown[id] = true
        g_introLogoOK[id] = true
        g_logoDirty[id] = false
    }
}

boolValidLogoWeapon(weapon)
{
    return weapon = 1 && weapon = CSW_LAST_WEAPON && weapon != LOGO_HUD_WEAPON
}

ResetLogoClient(id)
{
    g_introLogoOK[id] = false
    g_logoShown[id] = false
    g_logoDirty[id] = false
    g_realWeapon[id] = 0
    g_realClip[id] = 255
    g_realFov[id] = 0
    g_logoDefinedWeapon[id] = 0
    arrayset(g_weaponInfoKnown[id], false, sizeof g_weaponInfoKnown[])
}

public IgnoreIntroWeapon(id)
{
    #pragma unused id
    return PLUGIN_HANDLED
}

public TrackLogoWeaponInfo(msgid, dest, id)
{
    #pragma unused msgid, dest
    if (id  1  id  MAX_PLAYERS  get_msg_args() != 9) return PLUGIN_CONTINUE
    new weapon = get_msg_arg_int(8)
    if (ValidLogoWeapon(weapon))
    {
        for (new i = 0; i  4; i++) g_weaponAmmoInfo[id][weapon][i] = get_msg_arg_int(i+2)
        g_weaponInfoKnown[id][weapon] = true
        if (g_logoShown[id] && weapon == g_realWeapon[id])
        {
            g_logoDefinedWeapon[id] = 0
            g_logoDirty[id] = true
        }
    }
    return PLUGIN_CONTINUE
}

public TrackLogoCurWeapon(msgid, dest, id)
{
    #pragma unused msgid, dest
    if (id  1  id  MAX_PLAYERS  get_msg_args() != 3) return PLUGIN_CONTINUE
    new weapon = get_msg_arg_int(2)
    if (!get_msg_arg_int(1)  !ValidLogoWeapon(weapon)) return PLUGIN_CONTINUE
    g_realWeapon[id] = weapon
    g_realClip[id] = get_msg_arg_int(3)
    if (g_running && g_phase == PHASE_INTRO && g_logoIndex && get_pcvar_num(p_logo)
        && is_user_alive(id) && (!g_realFov[id]  g_realFov[id] = 90))
    {
         Keep real clip data flowing, without replacing the intro crosshair.
         Resending is deferred to the task; no nested messages inside a hook.
        if (g_logoShown[id]) set_msg_arg_int(1, ARG_BYTE, 0)
        g_logoDirty[id] = true
    }
    return PLUGIN_CONTINUE
}

public TrackLogoFov(msgid, dest, id)
{
    #pragma unused msgid, dest
    if (id  1  id  MAX_PLAYERS  get_msg_args() != 1) return PLUGIN_CONTINUE
    g_realFov[id] = get_msg_arg_int(1)
    if (g_running && g_phase == PHASE_INTRO) g_logoDirty[id] = true
    return PLUGIN_CONTINUE
}

SendIntroWeaponList(id, weapon)
{
    message_begin(MSG_ONE, g_msgWeaponList, {0,0,0}, id)
    write_string(LOGO_HUD_NAME)
    for (new i = 0; i  4; i++)
        write_byte(g_weaponInfoKnown[id][weapon]  g_weaponAmmoInfo[id][weapon][i]  255)
    write_byte(0)
    write_byte(0)
    write_byte(LOGO_HUD_WEAPON)
    write_byte(0)
    message_end()
}

SendLogoFov(id, fov)
{
    message_begin(MSG_ONE, g_msgSetFov, {0,0,0}, id)
    write_byte(fov)
    message_end()
}

SendLogoCurWeapon(id, active, weapon, clip)
{
    message_begin(MSG_ONE, g_msgCurWeapon, {0,0,0}, id)
    write_byte(active)
    write_byte(weapon)
    write_byte(clip)
    message_end()
}

ClearIntroLogo(id)
{
    new boolrestore = g_logoShown[id]
    g_logoShown[id] = false
    g_introLogoOK[id] = false
    g_logoDirty[id] = false
    if (!restore  !is_user_connected(id)) return
    SendLogoFov(id, g_realFov[id])
    if (is_user_alive(id))
    {
        new clip, ammo, weapon = get_user_weapon(id, clip, ammo)
        if (!ValidLogoWeapon(weapon))
        {
            weapon = g_realWeapon[id]
            clip = g_realClip[id]
        }
        if (ValidLogoWeapon(weapon)) SendLogoCurWeapon(id, 1, weapon, clip & 255)
        else SendLogoCurWeapon(id, 0, 0, 0)
    }
    else SendLogoCurWeapon(id, 0, 0, 0)
}

public IntroTick()
{
    if (!g_running  g_phase != PHASE_INTRO) { StopIntro(); return; }
    new Floatnow = get_gametime(), Floatleft = g_introEnd-now
    if (left = 0.0  now  g_nextIntroDraw  left = 0.65) return
    g_nextIntroDraw = now+0.45
    set_dhudmessage(255, 215, 55, -1.0, 0.15, 0, 0.0, 0.6, 0.0, 0.0)
    show_dhudmessage(0, BAŞLIYOR!^nHazır mısın  %d sn, floatround(left, floatround_ceil))
    for (new id = 1; id = MAX_PLAYERS; id++)
        if (is_user_connected(id) && !g_introLogoOK[id])
        {
            set_dhudmessage(220, 165, 255, -1.0, 0.40, 0, 0.0, 0.6, 0.0, 0.0)
            show_dhudmessage(id, FELICIACLAN^nKİM MİLYONER OLMAK^nİSTER)
        }
}
