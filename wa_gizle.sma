#include <amxmodx>
#include <fakemeta>

new bool:gorunmezlik[33],semiclip,hudmod,hudgor

public plugin_init( )
{
	register_plugin( "takim arkadasini gorunmez yap", "1.2", "Yek'-ta"); /* Semiclip Bug Fix : Necati Dogan | Hud : ByBuLuT */
	register_forward( FM_AddToFullPack, "fwdAddToFullPack_Post", 1 );
	register_clcmd( "say /gizle", "degistir" );
	register_clcmd( "say /goster", "degistir" );
	register_clcmd( "say /sakla", "degistir" );
	register_clcmd( "say /degis", "degistir" );
	semiclip = get_cvar_pointer("semiclip");
	hudmod = register_cvar("gizle_hudmod","1");   /* HUDUN DHUD VEYA HUD OLMASI || 0 = HUD -- 1 = DHUD */
	hudgor = register_cvar("gizle_hud","1");      /* HUD ACIK VEYA KAPALI || 0 = KAPALI -- 1 = ACIK */
}

public client_putinserver(id)
{
	gorunmezlik[id]=false;
}

public fwdAddToFullPack_Post( es_handle, e, ent, host, hostflags, player, pset )
{
	if(player && get_pcvar_num(semiclip)==1){
		if(is_user_alive(host) && gorunmezlik[host] && host != ent && is_user_alive(ent) && get_user_team(host)==get_user_team(ent)){
			set_es( es_handle, ES_Origin, { 999999999.0, 999999999.0, 999999999.0 } );
		}
	}
}

public degistir(id)
{
	if(is_user_connected(id) && is_user_alive(id)){
		if(get_pcvar_num(semiclip)!=1) {
		if(get_pcvar_num(hudgor) && get_pcvar_num(hudmod)) set_dhudmessage(255, 0, 0, -1.0, 0.16, 2, 2.0, 4.0, 0.1, 3.5 ),show_dhudmessage(id, "[ Semiclip Kapaliyken Bu Komutu Kullanamazsin..! ]");
		if(get_pcvar_num(hudgor) && !get_pcvar_num(hudmod)) set_hudmessage(255, 0, 0, -1.0, 0.16, 2, 2.0, 4.0, 0.1, 3.5 ),show_hudmessage(id, "[ Semiclip Kapaliyken Bu Komutu Kullanamazsin..! ]");
		client_print_color(id, print_team_red, "- ^3Semiclip kapaliyken bu komutu kullanamazsin.")
		} else if(gorunmezlik[id]) {
		gorunmezlik[id]=false;
		if(get_pcvar_num(hudgor) && get_pcvar_num(hudmod)) set_dhudmessage(255, 0, 255, -1.0, 0.16, 2, 2.0, 4.0, 0.1, 3.5 ),show_dhudmessage(id, "^n[ Takimini Gorme Acik Gizlemek icin /degis & /gizle Yaz ]");
		if(get_pcvar_num(hudgor) && !get_pcvar_num(hudmod)) set_hudmessage(255, 0, 255, -1.0, 0.16, 2, 2.0, 4.0, 0.1, 3.5 ),show_hudmessage(id, "^n[ Takimini Gorme Acik Gizlemek icin /degis & /gizle Yaz ]");
		client_print_color(id, print_team_red, "- ^3Takim arkadaslarini ^1gorunur ^3yaptin.")
		} else {
		gorunmezlik[id]=true;
		if(get_pcvar_num(hudgor) && get_pcvar_num(hudmod)) set_dhudmessage(0, 255, 0, -1.0, 0.16, 2, 2.0, 4.0, 0.1, 3.5 ),show_dhudmessage(id, "^n^n[ Takimini Gorme KAPALI Acmak icin /degis & /goster Yaz ]");
		if(get_pcvar_num(hudgor) && !get_pcvar_num(hudmod)) set_hudmessage(0, 255, 0, -1.0, 0.16, 2, 2.0, 4.0, 0.1, 3.5 ),show_hudmessage(id, "^n^n[ Takimini Gorme KAPALI Acmak icin /degis & /goster Yaz ]");
		client_print_color(id, print_team_grey, "- ^3Takim arkadaslarini ^1gorunmez ^3yaptin.")
		}
	}
	return PLUGIN_HANDLED;
}