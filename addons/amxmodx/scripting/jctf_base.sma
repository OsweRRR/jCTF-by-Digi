/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#include <engine>
#include <cstrike>
#include <fun>
#include <jctf>

const ADMIN_RETURN =				ADMIN_RCON	// access required for admins to return flags (full list in includes/amxconst.inc)
const ADMIN_RETURNWAIT =			15		// time the flag needs to stay dropped before it can be returned by command

new const Float:BASE_HEAL_DISTANCE =		96.0		// healing distance for flag

new const FLAG_SAVELOCATION[] =			"maps/%s.ctf" // you can change where .ctf files are saved/loaded from

new const INFO_TARGET[] =			"info_target"

new const BASE_CLASSNAME[] =			"ctf_flagbase"
new const Float:BASE_THINK =			0.25

new const TASK_CLASSNAME[] =			"ctf_think_task"
new const Float:TASK_THINK = 			1.0

const LIMIT_ADRENALINE = 			200

new const FLAG_CLASSNAME[] =			"ctf_flag"
new const FLAG_MODEL[] =				"models/jctf/ctf_flag.mdl"

new const Float:FLAG_THINK =			0.1
const FLAG_SKIPTHINK =				20 /* FLAG_THINK * FLAG_SKIPTHINK = 2.0 seconds ! */

new const Float:FLAG_HULL_MIN[3] =		{-2.0, -2.0, 0.0}
new const Float:FLAG_HULL_MAX[3] =		{2.0, 2.0, 16.0}

new const Float:FLAG_SPAWN_VELOCITY[3] =		{0.0, 0.0, -500.0}
new const Float:FLAG_SPAWN_ANGLES[3] =		{0.0, 0.0, 0.0}

new const Float:FLAG_DROP_VELOCITY[3] =		{0.0, 0.0, 50.0}

new const Float:FLAG_PICKUPDISTANCE =		80.0

const FLAG_ANI_DROPPED =			0
const FLAG_ANI_STAND =				1
const FLAG_ANI_BASE =				2

const FLAG_HOLD_BASE =				33
const FLAG_HOLD_DROPPED =			34

new const CHAT_PREFIX[] =			"^1[^4CTF^1] "
new const CONSOLE_PREFIX[] =			"[CTF] "

#define NULL					""

#define HUD_HINT				255, 255, 255, 0.15, -0.3, 0, 0.0, 10.0
#define HUD_HELP				255, 255, 0, -1.0, 0.2, 2, 1.0, 1.5, .fadeintime = 0.03
#define HUD_HELP2				255, 255, 0, -1.0, 0.25, 2, 1.0, 1.5, .fadeintime = 0.03
#define HUD_ANNOUNCE				-1.0, 0.3, 2, 1.0, 3.0, .fadeintime = 0.03
#define HUD_RESPAWN				0, 255, 0, -1.0, 0.6, 2, 1.0, 0.8, .fadeintime = 0.03
#define HUD_PROTECTION				255, 255, 0, -1.0, 0.6, 2, 1.0, 0.8, .fadeintime = 0.03

#define get_opTeam(%1)				(%1 == TEAM_BLUE ? TEAM_RED : (%1 == TEAM_RED ? TEAM_BLUE : 0))

#define VERSION					"1.33o"
#define AUTHOR					"Digi"

enum
{
	x,
	y,
	z
}

enum
{
	TEAM_NONE = 0,
	TEAM_RED,
	TEAM_BLUE,
	TEAM_SPEC
}

new const g_szCSTeams[][] =
{
	NULL,
	"TERRORIST",
	"CT",
	"SPECTATOR"
}

new const g_szTeamName[][] =
{
	NULL,
	"Red",
	"Blue",
	"Spectator"
}

new const g_szMLFlagTeam[][] =
{
	NULL,
	"FLAG_RED",
	"FLAG_BLUE",
	NULL
}

enum
{
	REWARD_CAPTURED = 15,
	REWARD_RETURNED = 10,
	REWARD_STOLEN = 5,
	REWARD_FRAG = 3,
	REWARD_KILL_FLAGHOLDER = 20,
	
	PENALTY_SUICIDE = 20,
	PENALTY_DROP = 15
}

enum
{
	FLAG_STOLEN = 0,
	FLAG_PICKED,
	FLAG_DROPPED,
	FLAG_MANUALDROP,
	FLAG_RETURNED,
	FLAG_CAPTURED,
	FLAG_AUTORETURN,
	FLAG_ADMINRETURN
}

enum
{
	EVENT_TAKEN = 0,
	EVENT_DROPPED,
	EVENT_RETURNED,
	EVENT_SCORE,
}

enum _:STRUCT_WEAPONS
{
	WEAPON_NAME[20],
	WEAPON_ENT[20],
	WEAPON_TYPE[20],
	WEAPON_CSW,
	WEAPON_AMMO
}

new const g_szSounds[][][] =
{
	{ NULL, "red_flag_taken", "blue_flag_taken" },
	{ NULL, "red_flag_dropped", "blue_flag_dropped" },
	{ NULL, "red_flag_returned", "blue_flag_returned" },
	{ NULL, "red_team_scores", "blue_team_scores" }
}

new const g_szListWeapons[][STRUCT_WEAPONS] = 
{
	{ "SIG-Sauer P228", "weapon_p228", "MSG_TYPE_WEAPON_1", CSW_P228, 52 },
	{ "Beretta 92", "weapon_elite", "MSG_TYPE_WEAPON_1", CSW_ELITE, 120 },
	{ "FN Five-seven", "weapon_fiveseven", "MSG_TYPE_WEAPON_1", CSW_FIVESEVEN, 100 },
	{ "USP .45 Tactical", "weapon_usp", "MSG_TYPE_WEAPON_1", CSW_USP, 100 },
	{ "Glock 18", "weapon_glock18", "MSG_TYPE_WEAPON_1", CSW_GLOCK18, 120 },
	{ "Desert Eagle", "weapon_deagle", "MSG_TYPE_WEAPON_1", CSW_DEAGLE, 35 },
	
	{ "M3 Super 90", "weapon_m3", "MSG_TYPE_WEAPON_2", CSW_M3, 32 },
	{ "XM1014", "weapon_xm1014", "MSG_TYPE_WEAPON_2", CSW_XM1014, 32 },
	
	{ "MAC-10", "weapon_mac10", "MSG_TYPE_WEAPON_3", CSW_MAC10, 100 },
	{ "UMP45", "weapon_ump45", "MSG_TYPE_WEAPON_3", CSW_UMP45, 100 },
	{ "MP5", "weapon_mp5navy", "MSG_TYPE_WEAPON_3", CSW_MP5NAVY, 120 },
	{ "Steyr TMP", "weapon_tmp", "MSG_TYPE_WEAPON_3", CSW_TMP, 120 },
	{ "P90", "weapon_p90", "MSG_TYPE_WEAPON_3", CSW_P90, 100 },
	
	{ "AUG", "weapon_aug", "MSG_TYPE_WEAPON_4", CSW_AUG, 90 },
	{ "Galil", "weapon_galil", "MSG_TYPE_WEAPON_4", CSW_GALIL, 90 },
	{ "Famas", "weapon_famas", "MSG_TYPE_WEAPON_4", CSW_FAMAS, 90 },
	{ "Colt M4A1 Carbine", "weapon_m4a1", "MSG_TYPE_WEAPON_4", CSW_M4A1, 90 },
	{ "AK-47", "weapon_ak47", "MSG_TYPE_WEAPON_4", CSW_AK47, 90 },
	{ "SG-552", "weapon_sg552", "MSG_TYPE_WEAPON_4", CSW_SG552, 90 },
	{ "FN M249", "weapon_m249", "MSG_TYPE_WEAPON_4", CSW_M249, 200 }
}

new g_iScore[3]
new g_iSync[4]
new g_iFlagHolder[3]
new g_iFlagEntity[3]
new g_iBaseEntity[3]
new g_iTeam[MAX_PLAYERS]
new Float:g_fFlagDropped[3]

new bool:g_bRestarting
new bool:g_bAssisted[MAX_PLAYERS][3]
new bool:g_bProtected[MAX_PLAYERS]

new g_bRespawn[MAX_PLAYERS]
new g_bProtecting[MAX_PLAYERS]
new g_bAdrenaline[MAX_PLAYERS]
new g_bPlayerName[MAX_PLAYERS][MAX_NAME_LENGTH]

new Float:g_fFlagBase[3][3]
new Float:g_fFlagLocation[3][3]
new Float:g_fLastDrop[MAX_PLAYERS]

new pCvar_ctf_flagheal
new pCvar_ctf_flagreturn
new pCvar_ctf_respawntime
new pCvar_ctf_protection
new pCvar_ctf_glows

new pCvar_ctf_sound[4]

new gMsg_RoundTime
new gMsg_HostageK
new gMsg_HostagePos
new gMsg_TeamScore

new forward_ObjSpawn
new gSpr_regeneration
new handle_JctfFlag

public plugin_precache()
{
	precache_model(FLAG_MODEL)
	
	gSpr_regeneration = precache_model("sprites/th_jctf_heal.spr")
	
	for(new i = 0; i < sizeof g_szSounds; i++)
	{
		for(new t = 1; t <= 2; t++)
		{
			precache_generic(fmt("sound/jctf/%s.mp3", g_szSounds[i][t]))
		}
	}
	forward_ObjSpawn = register_forward(FM_Spawn, "pfn_ObjSpawn")
}

public pfn_ObjSpawn(ent)
{
	if(!pev_valid(ent))
	{
		return FMRES_IGNORED
	}
	
	new sClass[24], i
	pev(ent, pev_classname, sClass, charsmax(sClass))
	
	new const sEntitys[][] = 
	{
		"armoury_entity",
		"func_bomb_target",
		"info_bomb_target",
		"hostage_entity",
		"monster_scientist",
		"func_hostage_rescue",
		"info_hostage_rescue",
		"info_vip_start",
		"func_vip_safetyzone",
		"func_escapezone",
		"info_map_parameters"
	}
	
	for(i = 0; i < sizeof sEntitys; i++)
	{
		if(equal(sClass, sEntitys[i]))
		{
			engfunc(EngFunc_RemoveEntity, ent)
			return FMRES_SUPERCEDE
		}
	}
	return FMRES_IGNORED
}

public plugin_init()
{
	register_plugin("Just Capture the Flag", VERSION, AUTHOR)
	register_cvar("jctf_version", VERSION, (FCVAR_SERVER|FCVAR_SPONLY))
	
	register_touch(FLAG_CLASSNAME, "player", "flag_touch")
	
	register_think(FLAG_CLASSNAME, "flag_think")
	register_think(BASE_CLASSNAME, "base_think")
	register_think(TASK_CLASSNAME, "task_think")
	
	register_forward(FM_GetGameDescription, "pfn_GameDescription", 0)
	register_forward(FM_ClientKill, "pfn_pAutoKilled", 0)
	unregister_forward(FM_Spawn, forward_ObjSpawn)
	
	new iEnt = create_entity(INFO_TARGET)
	if(iEnt)
	{
		entity_set_string(iEnt, EV_SZ_classname, TASK_CLASSNAME)
		entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + TASK_THINK)
	}
	
	register_logevent("event_restartGame", 2, "1&Restart_Round", "1&Game_Commencing")
	
	register_event_ex("HLTV", "event_roundStart", RegisterEvent_Global, "1=0", "2=0")
	register_event_ex("DeathMsg", "event_playerKilled", RegisterEvent_Global)
	register_event_ex("TeamInfo", "player_joinTeam", RegisterEvent_Global)
	
	new sWeaponName[32]
	for(new i = 1; i <= CSW_P90; i++)
	{
		if(get_weaponname(i, sWeaponName, charsmax(sWeaponName)))
		{
			RegisterHam(Ham_Weapon_PrimaryAttack, sWeaponName, "player_useWeapon", 1)
		}
	}
	RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_knife", "player_useWeapon", 1)
	RegisterHam(Ham_Spawn, "player", "pfn_pSpawn", true)
	RegisterHam(Ham_TraceAttack, "player", "pfn_pTraceAttack", false)
	
	register_clcmd("ctf_moveflag", "admin_cmd_moveFlag", ADMIN_RCON, "<red/blue> - Moves team's flag base to your origin (for map management)")
	register_clcmd("ctf_save", "admin_cmd_saveFlags", ADMIN_RCON)
	register_clcmd("ctf_return", "admin_cmd_returnFlag", ADMIN_RETURN)
	
	register_clcmd("say /dropflag", "player_cmd_dropFlag")
	
	register_clcmd("radio1", "player_cmd_dropFlag")
	register_clcmd("radio2", "player_cmd_dropFlag")
	register_clcmd("radio3", "player_cmd_dropFlag")
	
	gMsg_HostagePos = get_user_msgid("HostagePos")
	gMsg_HostageK = get_user_msgid("HostageK")
	gMsg_RoundTime = get_user_msgid("RoundTime")
	gMsg_TeamScore = get_user_msgid("TeamScore")
	
	register_message(gMsg_RoundTime, "msg_roundTime")
	register_message(gMsg_TeamScore, "msg_teamScore")
	
	set_msg_block(get_user_msgid("ClCorpse"), BLOCK_SET)
	
	pCvar_ctf_flagheal = register_cvar("ctf_flagheal", "1")
	pCvar_ctf_flagreturn = register_cvar("ctf_flagreturn", "200")
	pCvar_ctf_respawntime = register_cvar("ctf_respawntime", "8")
	pCvar_ctf_protection = register_cvar("ctf_protection", "6")
	pCvar_ctf_glows = register_cvar("ctf_glows", "1")
	
	pCvar_ctf_sound[EVENT_TAKEN] = register_cvar("ctf_sound_taken", "1")
	pCvar_ctf_sound[EVENT_DROPPED] = register_cvar("ctf_sound_dropped", "1")
	pCvar_ctf_sound[EVENT_RETURNED] = register_cvar("ctf_sound_returned", "1")
	pCvar_ctf_sound[EVENT_SCORE] = register_cvar("ctf_sound_score", "1")
	
	handle_JctfFlag = CreateMultiForward("jctf_flag", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL, FP_CELL)
	
	g_iSync[0] = CreateHudSyncObj()
	g_iSync[1] = CreateHudSyncObj()
	g_iSync[2] = CreateHudSyncObj()
	g_iSync[3] = CreateHudSyncObj()
	
	register_dictionary("jctf.txt")
}

public plugin_cfg()
{
	new szFile[44], szMap[32]
	
	get_mapname(szMap, charsmax(szMap))
	formatex(szFile, charsmax(szFile), FLAG_SAVELOCATION, szMap)
	
	new hFile = fopen(szFile, "rt")
	if(hFile)
	{
		new iFlagTeam = TEAM_RED
		new szData[24]
		new szOrigin[3][6]
		
		while(fgets(hFile, szData, charsmax(szData)))
		{
			if(iFlagTeam > TEAM_BLUE)
				break
			
			trim(szData)
			parse(szData, szOrigin[x], charsmax(szOrigin[]), szOrigin[y], charsmax(szOrigin[]), szOrigin[z], charsmax(szOrigin[]))
			
			g_fFlagBase[iFlagTeam][x] = str_to_float(szOrigin[x])
			g_fFlagBase[iFlagTeam][y] = str_to_float(szOrigin[y])
			g_fFlagBase[iFlagTeam][z] = str_to_float(szOrigin[z])
			
			iFlagTeam++
		}
		fclose(hFile)
	}
	flag_spawn(TEAM_RED)
	flag_spawn(TEAM_BLUE)
	
	set_task(5.0, "plugin_cfg_post")
}

public plugin_cfg_post()
{
	set_cvar_num("mp_buytime", 0)
	set_cvar_num("mp_refill_bpammo_weapons", 2)
	set_cvar_num("mp_item_staytime", 15)
	set_cvar_string("mp_round_infinite", "f")
}

public client_infochanged(id)
{
	if(!is_user_connected(id))
	{
		return PLUGIN_CONTINUE
	}
	
	static sName[32]
	get_user_info(id, "name", sName, charsmax(sName))
	
	if(!equal(g_bPlayerName[id], sName))
	{
		copy(g_bPlayerName[id], charsmax(g_bPlayerName[]), sName)
	}
	return PLUGIN_CONTINUE
}

public plugin_natives()
{
	register_library("jctf")
	register_native("jctf_get_flagcarrier", "native_get_flagcarrier")
	
	register_native("get_user_adrenaline", "native_get_adrenaline")
	register_native("set_user_adrenaline", "native_set_adrenaline")
}

public native_get_adrenaline(iPlugin, iParams)
{
	return g_bAdrenaline[get_param(1)]
}

public native_set_adrenaline(iPlugin, iParams)
{
	g_bAdrenaline[get_param(1)] = get_param(2)
}

public plugin_end()
{
	DestroyForward(handle_JctfFlag)
}

public native_get_flagcarrier(iPlugin, iParams)
{
	new id = get_param(1)
	return g_iFlagHolder[get_opTeam(g_iTeam[id])] == id
}

public jctf_flag(iEvent, iPlayer, iFlagTeam, bool:bAssist)
{
	switch(iEvent)
	{
		case FLAG_CAPTURED: g_bAdrenaline[iPlayer] = clamp(g_bAdrenaline[iPlayer] + REWARD_CAPTURED, 0, LIMIT_ADRENALINE)
		case FLAG_RETURNED: g_bAdrenaline[iPlayer] = clamp(g_bAdrenaline[iPlayer] + REWARD_RETURNED, 0, LIMIT_ADRENALINE)
		case FLAG_STOLEN: g_bAdrenaline[iPlayer] = clamp(g_bAdrenaline[iPlayer] + REWARD_STOLEN, 0, LIMIT_ADRENALINE)
	}
	return PLUGIN_HANDLED
}

public flag_spawn(iFlagTeam)
{
	if(g_fFlagBase[iFlagTeam][x] == 0.0 && g_fFlagBase[iFlagTeam][y] == 0.0 && g_fFlagBase[iFlagTeam][z] == 0.0)
	{
		new iFindSpawn = find_ent_by_class(MaxClients, iFlagTeam == TEAM_BLUE ? "info_player_start" : "info_player_deathmatch")

		if(iFindSpawn)
		{
			entity_get_vector(iFindSpawn, EV_VEC_origin, g_fFlagBase[iFlagTeam])
			
			server_print("[CTF] %s flag origin not defined, set on player spawn.", g_szTeamName[iFlagTeam])
			log_error(AMX_ERR_NOTFOUND, "[CTF] %s flag origin not defined, set on player spawn.", g_szTeamName[iFlagTeam])
		}
		else
		{
			server_print("[CTF] WARNING: player spawn for ^"%s^" team does not exist !", g_szTeamName[iFlagTeam])
			log_error(AMX_ERR_NOTFOUND, "[CTF] WARNING: player spawn for ^"%s^" team does not exist !", g_szTeamName[iFlagTeam])
			set_fail_state("Player spawn unexistent!")
			
			return PLUGIN_CONTINUE
		}
	}
	else
		server_print("[CTF] %s flag and base spawned at: %.1f %.1f %.1f", g_szTeamName[iFlagTeam], g_fFlagBase[iFlagTeam][x], g_fFlagBase[iFlagTeam][y], g_fFlagBase[iFlagTeam][z])
	
	new ent
	new Float:fGameTime = get_gametime()
	
	// the FLAG
	
	ent = create_entity(INFO_TARGET)
	if(!ent)
		return flag_spawn(iFlagTeam)
	
	entity_set_model(ent, FLAG_MODEL)
	entity_set_string(ent, EV_SZ_classname, FLAG_CLASSNAME)
	entity_set_int(ent, EV_INT_body, 1)
	entity_set_int(ent, EV_INT_skin, iFlagTeam == 1 ? 1 : 2)
	entity_set_int(ent, EV_INT_sequence, FLAG_ANI_STAND)
	DispatchSpawn(ent)
	entity_set_origin(ent, g_fFlagBase[iFlagTeam])
	entity_set_size(ent, FLAG_HULL_MIN, FLAG_HULL_MAX)
	entity_set_vector(ent, EV_VEC_velocity, FLAG_SPAWN_VELOCITY)
	entity_set_vector(ent, EV_VEC_angles, FLAG_SPAWN_ANGLES)
	entity_set_edict(ent, EV_ENT_aiment, 0)
	entity_set_int(ent, EV_INT_movetype, MOVETYPE_TOSS)
	entity_set_int(ent, EV_INT_solid, SOLID_TRIGGER)
	entity_set_float(ent, EV_FL_framerate, 1.0)
	entity_set_float(ent, EV_FL_gravity, 2.0)
	entity_set_float(ent, EV_FL_nextthink, fGameTime + FLAG_THINK)
	
	g_iFlagEntity[iFlagTeam] = ent
	g_iFlagHolder[iFlagTeam] = FLAG_HOLD_BASE
	
	// flag BASE
	
	ent = create_entity(INFO_TARGET)
	if(!ent)
		return flag_spawn(iFlagTeam)
	
	entity_set_string(ent, EV_SZ_classname, BASE_CLASSNAME)
	entity_set_model(ent, FLAG_MODEL)
	entity_set_int(ent, EV_INT_body, 0)
	entity_set_int(ent, EV_INT_sequence, FLAG_ANI_BASE)
	DispatchSpawn(ent)
	entity_set_origin(ent, g_fFlagBase[iFlagTeam])
	entity_set_vector(ent, EV_VEC_velocity, FLAG_SPAWN_VELOCITY)
	entity_set_int(ent, EV_INT_movetype, MOVETYPE_TOSS)
	
	if(get_pcvar_num(pCvar_ctf_glows))
		entity_set_int(ent, EV_INT_renderfx, kRenderFxGlowShell)
	
	entity_set_float(ent, EV_FL_renderamt, 100.0)
	entity_set_float(ent, EV_FL_nextthink, fGameTime + BASE_THINK)
	
	if(iFlagTeam == TEAM_RED)
		entity_set_vector(ent, EV_VEC_rendercolor, Float:{150.0, 0.0, 0.0})
	else
		entity_set_vector(ent, EV_VEC_rendercolor, Float:{0.0, 0.0, 150.0})
	
	g_iBaseEntity[iFlagTeam] = ent
	return PLUGIN_CONTINUE
}

public flag_think(ent)
{
	if(!is_valid_ent(ent))
		return
	
	entity_set_float(ent, EV_FL_nextthink, get_gametime() + FLAG_THINK)
	
	static id
	static iStatus
	static iFlagTeam
	static iSkip[3]
	static Float:fOrigin[3]
	static Float:fPlayerOrigin[3]

	iFlagTeam = (ent == g_iFlagEntity[TEAM_BLUE] ? TEAM_BLUE : TEAM_RED)

	if(g_iFlagHolder[iFlagTeam] == FLAG_HOLD_BASE)
		fOrigin = g_fFlagBase[iFlagTeam]
	else
		entity_get_vector(ent, EV_VEC_origin, fOrigin)

	g_fFlagLocation[iFlagTeam] = fOrigin

	iStatus = 0

	if(++iSkip[iFlagTeam] >= FLAG_SKIPTHINK)
	{
		iSkip[iFlagTeam] = 0
		
		if(1 <= g_iFlagHolder[iFlagTeam] <= MaxClients)
		{
			id = g_iFlagHolder[iFlagTeam]
			
			set_hudmessage(HUD_HELP)
			ShowSyncHudMsg(id, g_iSync[0], "%L", id, "HUD_YOUHAVEFLAG")
			
			iStatus = 1
		}
		else if(g_iFlagHolder[iFlagTeam] == FLAG_HOLD_DROPPED)
			iStatus = 2
		
		message_begin(MSG_BROADCAST, gMsg_HostagePos)
		write_byte(0)
		write_byte(iFlagTeam)
		engfunc(EngFunc_WriteCoord, fOrigin[x])
		engfunc(EngFunc_WriteCoord, fOrigin[y])
		engfunc(EngFunc_WriteCoord, fOrigin[z])
		message_end()
		
		message_begin(MSG_BROADCAST, gMsg_HostageK)
		write_byte(iFlagTeam)
		message_end()
		
		static iStuck[3]
		
		if(g_iFlagHolder[iFlagTeam] >= FLAG_HOLD_BASE && !(entity_get_int(ent, EV_INT_flags) & FL_ONGROUND))
		{
			if(++iStuck[iFlagTeam] > 4)
			{
				flag_autoReturn(ent)
				log_message("^"%s^" flag is outside world, auto-returned.", g_szTeamName[iFlagTeam])
				
				return
			}
		}
		else
			iStuck[iFlagTeam] = 0
	}

	for(id = 1; id <= MaxClients; id++)
	{
		if(!is_user_connected(id) || g_iTeam[id] == TEAM_NONE)
			continue
		
		/* Check flag proximity for pickup */
		if(g_iFlagHolder[iFlagTeam] >= FLAG_HOLD_BASE)
		{
			entity_get_vector(id, EV_VEC_origin, fPlayerOrigin)
			
			if(get_distance_f(fOrigin, fPlayerOrigin) <= FLAG_PICKUPDISTANCE)
				flag_touch(ent, id)
		}
		
		/* If iFlagTeam's flag is stolen or dropped, constantly warn team players */
		if(iStatus && g_iTeam[id] == iFlagTeam)
		{
			set_hudmessage(HUD_HELP2)
			ShowSyncHudMsg(id, g_iSync[0], "%L", id, (iStatus == 1 ? "HUD_ENEMYHASFLAG" : "HUD_RETURNYOURFLAG"))
		}
	}
}

public task_think(ent)
{
	if(!is_valid_ent(ent))
		return
	
	set_hudmessage(HUD_RESPAWN)
	for(new i = 1; i <= MaxClients; i++)
	{
		if(!(TEAM_RED <= g_iTeam[i] <= TEAM_BLUE))
		{
			continue
		}
		
		switch(bool:is_user_alive(i))
		{
			case true:
			{
				if(g_bProtected[i])
				{
					new iTime = g_bProtecting[i] - get_systime()
					switch(bool:(iTime <= 0))
					{
						case true: player_removeProtection(i, "PROTECTION_EXPIRED")
						case false: ShowSyncHudMsg(i, g_iSync[1], "%L", i, "PROTECTION_LEFT", iTime)
					}
				}
			}
			case false:
			{
				new iTime = g_bRespawn[i] - get_systime()
				switch(bool:(iTime <= 0))
				{
					case true: ExecuteHamB(Ham_CS_RoundRespawn, i)
					case false: ShowSyncHudMsg(i, g_iSync[1], "%L", i, "RESPAWNING_IN", iTime)
				}
			}
		}
	}
	entity_set_float(ent, EV_FL_nextthink, get_gametime() + TASK_THINK)
}

flag_sendHome(iFlagTeam)
{
	new ent = g_iFlagEntity[iFlagTeam]

	entity_set_edict(ent, EV_ENT_aiment, 0)
	entity_set_origin(ent, g_fFlagBase[iFlagTeam])
	entity_set_int(ent, EV_INT_sequence, FLAG_ANI_STAND)
	entity_set_int(ent, EV_INT_movetype, MOVETYPE_TOSS)
	entity_set_int(ent, EV_INT_solid, SOLID_TRIGGER)
	entity_set_vector(ent, EV_VEC_velocity, FLAG_SPAWN_VELOCITY)
	entity_set_vector(ent, EV_VEC_angles, FLAG_SPAWN_ANGLES)

	g_iFlagHolder[iFlagTeam] = FLAG_HOLD_BASE
}

flag_take(iFlagTeam, id)
{
	if(g_bProtected[id])
		player_removeProtection(id, "PROTECTION_TOUCHFLAG")
	
	new ent = g_iFlagEntity[iFlagTeam]
	
	entity_set_edict(ent, EV_ENT_aiment, id)
	entity_set_int(ent, EV_INT_movetype, MOVETYPE_FOLLOW)
	entity_set_int(ent, EV_INT_solid, SOLID_NOT)
	
	g_iFlagHolder[iFlagTeam] = id
}

public flag_touch(ent, id)
{
	if(!is_user_alive(id))
		return

	new iFlagTeam = (g_iFlagEntity[TEAM_BLUE] == ent ? TEAM_BLUE : TEAM_RED)

	if(1 <= g_iFlagHolder[iFlagTeam] <= MaxClients) // if flag is carried we don't care
		return

	new Float:fGameTime = get_gametime()
	
	if(g_fLastDrop[id] > fGameTime)
		return
	
	new iTeam = g_iTeam[id]
	
	if(!(TEAM_RED <= iTeam <= TEAM_BLUE))
		return
	
	new iFlagTeamOp = get_opTeam(iFlagTeam)
	
	if(iTeam == iFlagTeam) // If the PLAYER is on the same team as the FLAG
	{
		if(g_iFlagHolder[iFlagTeam] == FLAG_HOLD_DROPPED) // if the team's flag is dropped, return it to base
		{
			flag_sendHome(iFlagTeam)
			remove_task(ent)
			
			ExecuteForward(handle_JctfFlag, _, FLAG_RETURNED, id, iFlagTeam, false)
			
			new iAssists = 0
			for(new i = 1; i <= MaxClients; i++)
			{
				if(is_user_connected(i) && i != id && g_bAssisted[i][iFlagTeam] && g_iTeam[i] == iFlagTeam)
				{
					ExecuteForward(handle_JctfFlag, _, FLAG_RETURNED, i, iFlagTeam, true)
					
					iAssists++
				}
				g_bAssisted[i][iFlagTeam] = false
			}
			
			if(1 <= g_iFlagHolder[iFlagTeamOp] <= MaxClients)
				g_bAssisted[id][iFlagTeamOp] = true
			
			if(iAssists)
				game_announce(EVENT_RETURNED, iFlagTeam, fmt("%s + %d assists", g_bPlayerName[id], iAssists))
			else
				game_announce(EVENT_RETURNED, iFlagTeam, g_bPlayerName[id])
			
			log_message("<%s>%s returned the ^"%s^" flag.", g_szTeamName[iTeam], g_bPlayerName[id], g_szTeamName[iFlagTeam])
			
			set_hudmessage(HUD_HELP)
			ShowSyncHudMsg(id, g_iSync[0], "%L", id, "HUD_RETURNEDFLAG")
			
			if(g_bProtected[id])
				player_removeProtection(id, "PROTECTION_TOUCHFLAG")
		}
		else if(g_iFlagHolder[iFlagTeam] == FLAG_HOLD_BASE && g_iFlagHolder[iFlagTeamOp] == id) // if the PLAYER has the ENEMY FLAG and the FLAG is in the BASE make SCORE
		{
			ExecuteForward(handle_JctfFlag, _, FLAG_CAPTURED, id, iFlagTeamOp, false)
			
			new iAssists = 0

			for(new i = 1; i <= MaxClients; i++)
			{
				if(is_user_connected(i) && i != id && g_iTeam[i] == iTeam)
				{
					if(g_bAssisted[i][iFlagTeamOp])
					{
						ExecuteForward(handle_JctfFlag, _, FLAG_CAPTURED, i, iFlagTeamOp, true)
						iAssists++
					}
				}
				g_bAssisted[i][iFlagTeamOp] = false
			}

			set_hudmessage(HUD_HELP)
			ShowSyncHudMsg(id, g_iSync[0], "%L", id, "HUD_CAPTUREDFLAG")

			if(iAssists)
			{
				game_announce(EVENT_SCORE, iFlagTeam, fmt("%s + %d assists", g_bPlayerName[id], iAssists))
			}
			else
				game_announce(EVENT_SCORE, iFlagTeam, g_bPlayerName[id])

			log_message("<%s>%s captured the ^"%s^" flag. (%d assists)", g_szTeamName[iTeam], g_bPlayerName[id], g_szTeamName[iFlagTeamOp], iAssists)

			emessage_begin(MSG_BROADCAST, gMsg_TeamScore)
			ewrite_string(g_szCSTeams[iFlagTeam])
			ewrite_short(++g_iScore[iFlagTeam])
			emessage_end()

			flag_sendHome(iFlagTeamOp)

			g_fLastDrop[id] = fGameTime + 3.0

			if(g_bProtected[id])
				player_removeProtection(id, "PROTECTION_TOUCHFLAG")
			// Podria colisionar con el item de invisiblidad
			//else
				//player_updateRender(id)
		}
	}
	else
	{
		if(g_iFlagHolder[iFlagTeam] == FLAG_HOLD_BASE)
		{
			ExecuteForward(handle_JctfFlag, _, FLAG_STOLEN, id, iFlagTeam, false)
			
			log_message("<%s>%s stole the ^"%s^" flag.", g_szTeamName[iTeam], g_bPlayerName[id], g_szTeamName[iFlagTeam])
		}
		else
		{
			ExecuteForward(handle_JctfFlag, _, FLAG_PICKED, id, iFlagTeam, false)
			
			log_message("<%s>%s picked up the ^"%s^" flag.", g_szTeamName[iTeam], g_bPlayerName[id], g_szTeamName[iFlagTeam])
		}

		set_hudmessage(HUD_HELP)
		ShowSyncHudMsg(id, g_iSync[0], "%L", id, "HUD_YOUHAVEFLAG")

		flag_take(iFlagTeam, id)

		g_bAssisted[id][iFlagTeam] = true

		remove_task(ent)

		if(g_bProtected[id])
			player_removeProtection(id, "PROTECTION_TOUCHFLAG")
		// Podria colisionar con el item de invisiblidad
		//else
			//player_updateRender(id)

		game_announce(EVENT_TAKEN, iFlagTeam, g_bPlayerName[id])
	}
}

public flag_autoReturn(ent)
{
	remove_task(ent)
	
	new iFlagTeam = (g_iFlagEntity[TEAM_BLUE] == ent ? TEAM_BLUE : (g_iFlagEntity[TEAM_RED] == ent ? TEAM_RED : 0))
	
	if(!iFlagTeam)
		return
	
	flag_sendHome(iFlagTeam)
	
	ExecuteForward(handle_JctfFlag, _, FLAG_AUTORETURN, 0, iFlagTeam, false)
	
	game_announce(EVENT_RETURNED, iFlagTeam, NULL)
	
	log_message("^"%s^" flag returned automatically", g_szTeamName[iFlagTeam])
}

public base_think(ent)
{
	if(!is_valid_ent(ent))
		return
	
	if(!get_pcvar_num(pCvar_ctf_flagheal))
	{
		entity_set_float(ent, EV_FL_nextthink, get_gametime() + 10.0) /* recheck each 10s seconds */
		return
	}
	
	entity_set_float(ent, EV_FL_nextthink, get_gametime() + BASE_THINK)
	
	new iFlagTeam = (g_iBaseEntity[TEAM_BLUE] == ent ? TEAM_BLUE : TEAM_RED)
	
	if(g_iFlagHolder[iFlagTeam] != FLAG_HOLD_BASE)
		return
	
	static id
	static iHealth
	
	id = -1
	while((id = find_ent_in_sphere(id, g_fFlagBase[iFlagTeam], BASE_HEAL_DISTANCE)) != 0)
	{
		if(1 <= id <= MaxClients && is_user_alive(id) && g_iTeam[id] == iFlagTeam)
		{
			iHealth = get_user_health(id)
			if(iHealth < 100)
			{
				player_healingEffect(id)
				set_user_health(id, iHealth + 1)
			}
		}
		
		if(id >= MaxClients)
			break
	}
}

public client_putinserver(id)
{
	get_user_name(id, g_bPlayerName[id], charsmax(g_bPlayerName[])) 
	
	g_bProtected[id] = false
	g_bAdrenaline[id] = 0
	
	g_iTeam[id] = TEAM_SPEC
}

public client_disconnected(id)
{
	player_dropFlag(id)
	remove_task(id)
	
	g_iTeam[id] = TEAM_NONE
	g_bRespawn[id] = get_systime() + get_pcvar_num(pCvar_ctf_respawntime)
	
	g_bAssisted[id][TEAM_RED] = false
	g_bAssisted[id][TEAM_BLUE] = false
}

public player_joinTeam()
{
	static szTeam[3]
	static id
	
	id = read_data(1)
	read_data(2, szTeam, charsmax(szTeam))
	
	switch(szTeam[0])
	{
		case 'T': g_iTeam[id] = TEAM_RED
		case 'C': g_iTeam[id] = TEAM_BLUE
		case 'U': g_iTeam[id] = TEAM_NONE
		default: g_iTeam[id] = TEAM_SPEC
	}
}

public player_useWeapon(ent)
{
	if(!is_valid_ent(ent))
	{
		return
	}
	
	static id
	id = entity_get_edict(ent, EV_ENT_owner)
	
	if(1 <= id <= MaxClients && is_user_alive(id))
	{
		if(g_bProtected[id])
		{
			player_removeProtection(id, "PROTECTION_WEAPONUSE")
		}
	}
}

public pfn_pTraceAttack(victim, attacker, Float:damage, Float:direction[3], trace, bits)
{
	if(1 <= attacker <= MaxClients)
	{
		if(g_bProtected[victim])
		{
			return HAM_SUPERCEDE
		}
	}
	return HAM_IGNORED
}

public pfn_pSpawn(id)
{
	if(!is_user_alive(id))
	{
		return HAM_IGNORED
	}
	
	set_ent_data(id, "CBasePlayer", "m_iRadioMessages", 0)
	
	g_bProtected[id] = true
	g_bProtecting[id] = get_systime() + get_pcvar_num(pCvar_ctf_protection)
	
	player_updateRender(id)
	strip_user_weapons(id)
	
	new iPistols = random_num(0, 5)
	new iRifles = random_num(6, 19)
	
	give_item(id, "weapon_knife")
	give_item(id, g_szListWeapons[iPistols][WEAPON_ENT])
	give_item(id, g_szListWeapons[iRifles][WEAPON_ENT])
	
	cs_set_user_bpammo(id, g_szListWeapons[iPistols][WEAPON_CSW], g_szListWeapons[iPistols][WEAPON_AMMO])
	cs_set_user_bpammo(id, g_szListWeapons[iRifles][WEAPON_CSW], g_szListWeapons[iRifles][WEAPON_AMMO])
	
	client_print_color(id, id, "%s%L.", CHAT_PREFIX, id, "MSG_GIVE_WEAPON", id, g_szListWeapons[iPistols][WEAPON_TYPE], g_szListWeapons[iPistols][WEAPON_NAME], id, g_szListWeapons[iRifles][WEAPON_TYPE], g_szListWeapons[iRifles][WEAPON_NAME])
	return HAM_IGNORED
}

public pfn_pAutoKilled(id)
{
	if(is_user_connected(id))
	{
		if(g_bAdrenaline[id] >= PENALTY_SUICIDE)
		{
			g_bAdrenaline[id] -= PENALTY_SUICIDE
		}
		client_print_color(id, id, "%s%L", CHAT_PREFIX, id, "PENALTY_SUICIDE", PENALTY_SUICIDE)
	}
	return FMRES_IGNORED
}

public pfn_GameDescription()
{
	forward_return(FMV_STRING, fmt("%c%c%c%c %c%s %c%c %s", 106, 67, 84, 70, 118, VERSION, 98, 121, AUTHOR))
	return FMRES_SUPERCEDE
}

public player_removeProtection(id, szLang[])
{
	if(!(TEAM_RED <= g_iTeam[id] <= TEAM_BLUE))
		return
	
	g_bProtected[id] = false
	player_updateRender(id)
	
	set_hudmessage(HUD_PROTECTION)
	ShowSyncHudMsg(id, g_iSync[1], "%L", id, szLang)
}

public player_updateRender(id)
{
	new bool:bGlows = (get_pcvar_num(pCvar_ctf_glows) == 1)
	new iMode = kRenderNormal
	new iEffect = kRenderFxNone
	new iAmount = 0
	new iColor[3] = { 0, 0, 0 }
	
	if(g_bProtected[id])
	{
		iEffect = bGlows ? kRenderFxGlowShell : kRenderFxNone
		iMode = bGlows ? kRenderNormal : kRenderTransAdd
		iAmount = bGlows ? 90 : 100
		
		iColor[0] = bGlows ? (g_iTeam[id] == TEAM_RED ? 155 : 0) : 0
		iColor[2] = bGlows ? (g_iTeam[id] == TEAM_BLUE ? 155 : 0) : 0
	}
	set_user_rendering(id, iEffect, iColor[0], iColor[1], iColor[2], iMode, iAmount)
}

public event_playerKilled()
{
	new iKiller = read_data(1)
	new iVictim = read_data(2)
	
	g_bRespawn[iVictim] = get_systime() + get_pcvar_num(pCvar_ctf_respawntime)
	if(1 <= iKiller <= MaxClients && iVictim != iKiller)
	{
		g_bAdrenaline[iKiller] = clamp(g_bAdrenaline[iKiller] + REWARD_FRAG, 0, LIMIT_ADRENALINE)
		
		if(iVictim == g_iFlagHolder[g_iTeam[iKiller]])
		{
			g_bAssisted[iKiller][g_iTeam[iKiller]] = true
			g_bAdrenaline[iKiller] = clamp(g_bAdrenaline[iKiller] + REWARD_KILL_FLAGHOLDER, 0, LIMIT_ADRENALINE)
			
			client_print_color(iKiller, iKiller, "%s%L", CHAT_PREFIX, iKiller, "REWARD_KILL_FLAGHOLDER", REWARD_KILL_FLAGHOLDER)
		}
	}
	player_dropFlag(iVictim)
	player_updateRender(iVictim)
	
	set_hudmessage(HUD_HINT)
	ShowSyncHudMsg(iVictim, g_iSync[2], "%L: %L", iVictim, "HINT", iVictim, fmt("HINT_%d", random_num(1, 5)))
}

public player_cmd_dropFlag(id)
{
	if(!is_user_alive(id) || id != g_iFlagHolder[get_opTeam(g_iTeam[id])])
	{
		client_print_color(id, id, "%s%L", CHAT_PREFIX, id, "DROPFLAG_NOFLAG")
	}
	else
	{
		new iOpTeam = get_opTeam(g_iTeam[id])
		
		player_dropFlag(id)
		ExecuteForward(handle_JctfFlag, _, FLAG_MANUALDROP, id, iOpTeam, false)
		if(g_bAdrenaline[id] >= PENALTY_DROP)
		{
			g_bAdrenaline[id] -= PENALTY_DROP
		}
		client_print_color(id, id, "%s%L", CHAT_PREFIX, id, "PENALTY_DROP", PENALTY_DROP)
		
		g_bAssisted[id][iOpTeam] = false
	}
	return PLUGIN_HANDLED
}

public player_dropFlag(id)
{
	new iOpTeam = get_opTeam(g_iTeam[id])
	
	if(id != g_iFlagHolder[iOpTeam])
		return
	
	new ent = g_iFlagEntity[iOpTeam]
	
	if(!is_valid_ent(ent))
		return
	
	g_fLastDrop[id] = get_gametime() + 2.0
	g_iFlagHolder[iOpTeam] = FLAG_HOLD_DROPPED
	
	entity_set_edict(ent, EV_ENT_aiment, -1)
	entity_set_int(ent, EV_INT_movetype, MOVETYPE_TOSS)
	entity_set_int(ent, EV_INT_sequence, FLAG_ANI_DROPPED)
	entity_set_int(ent, EV_INT_solid, SOLID_TRIGGER)
	entity_set_origin(ent, g_fFlagLocation[iOpTeam])
	
	new Float:fReturn = get_pcvar_float(pCvar_ctf_flagreturn)
	
	if(fReturn > 0)
		set_task(fReturn, "flag_autoReturn", ent)
	
	if(is_user_alive(id))
	{
		new Float:fVelocity[3]
		velocity_by_aim(id, 500, fVelocity)
		
		fVelocity[z] = 0.0
		entity_set_vector(ent, EV_VEC_velocity, fVelocity)
	}
	else
		entity_set_vector(ent, EV_VEC_velocity, FLAG_DROP_VELOCITY)
	
	game_announce(EVENT_DROPPED, iOpTeam, g_bPlayerName[id])
	
	ExecuteForward(handle_JctfFlag, _, FLAG_DROPPED, id, iOpTeam, false)
	
	g_fFlagDropped[iOpTeam] = get_gametime()
	
	log_message("<%s>%s dropped the ^"%s^" flag.", g_szTeamName[g_iTeam[id]], g_bPlayerName[id], g_szTeamName[iOpTeam])
}

public admin_cmd_moveFlag(id, level, cid)
{
	if(~get_user_flags(id) & level)
	{
		return PLUGIN_HANDLED
	}
	
	new szTeam[2]
	read_argv(1, szTeam, charsmax(szTeam))

	new iTeam = str_to_num(szTeam)
	
	if(!(TEAM_RED <= iTeam <= TEAM_BLUE))
	{
		switch(szTeam[0])
		{
			case 'r', 'R': iTeam = 1
			case 'b', 'B': iTeam = 2
		}
	}

	if(!(TEAM_RED <= iTeam <= TEAM_BLUE))
		return PLUGIN_HANDLED
	
	entity_get_vector(id, EV_VEC_origin, g_fFlagBase[iTeam])
	
	entity_set_origin(g_iBaseEntity[iTeam], g_fFlagBase[iTeam])
	entity_set_vector(g_iBaseEntity[iTeam], EV_VEC_velocity, FLAG_SPAWN_VELOCITY)
	
	if(g_iFlagHolder[iTeam] == FLAG_HOLD_BASE)
	{
		entity_set_origin(g_iFlagEntity[iTeam], g_fFlagBase[iTeam])
		entity_set_vector(g_iFlagEntity[iTeam], EV_VEC_velocity, FLAG_SPAWN_VELOCITY)
	}
	
	client_print(id, print_console, "%s%L", CONSOLE_PREFIX, id, "ADMIN_MOVEBASE_MOVED", id, g_szMLFlagTeam[iTeam])
	
	return PLUGIN_HANDLED
}

public admin_cmd_saveFlags(id, level, cid)
{
	if(~get_user_flags(id) & level)
	{
		return PLUGIN_HANDLED
	}

	new iOrigin[3][3]
	new szFile[34]
	new szBuffer[34]
	new szMap[32]
	
	get_mapname(szMap, charsmax(szMap))
	FVecIVec(g_fFlagBase[TEAM_RED], iOrigin[TEAM_RED])
	FVecIVec(g_fFlagBase[TEAM_BLUE], iOrigin[TEAM_BLUE])

	formatex(szBuffer, charsmax(szBuffer), "%d %d %d^n%d %d %d", iOrigin[TEAM_RED][x], iOrigin[TEAM_RED][y], iOrigin[TEAM_RED][z], iOrigin[TEAM_BLUE][x], iOrigin[TEAM_BLUE][y], iOrigin[TEAM_BLUE][z])
	formatex(szFile, charsmax(szFile), FLAG_SAVELOCATION, szMap)

	if(file_exists(szFile))
		delete_file(szFile)

	write_file(szFile, szBuffer)

	client_print(id, print_console, "%s%L %s", CONSOLE_PREFIX, id, "ADMIN_MOVEBASE_SAVED", szFile)

	return PLUGIN_HANDLED
}

public admin_cmd_returnFlag(id, level, cid)
{
	if(~get_user_flags(id) & level)
	{
		return PLUGIN_HANDLED
	}
	
	new iTeam = read_argv_int(1)
	
	if(!(TEAM_RED <= iTeam <= TEAM_BLUE))
		return PLUGIN_HANDLED
	
	if(g_iFlagHolder[iTeam] == FLAG_HOLD_DROPPED)
	{
		if(g_fFlagDropped[iTeam] < (get_gametime() - ADMIN_RETURNWAIT))
		{
			new Float:fFlagOrigin[3]
			entity_get_vector(g_iFlagEntity[iTeam], EV_VEC_origin, fFlagOrigin)
			
			flag_sendHome(iTeam)
			
			ExecuteForward(handle_JctfFlag, _, FLAG_ADMINRETURN, id, iTeam, false)
			
			game_announce(EVENT_RETURNED, iTeam, NULL)
			
			client_print(id, print_console, "%s%L", CONSOLE_PREFIX, id, "ADMIN_RETURN_DONE", id, g_szMLFlagTeam[iTeam])
		}
		else
			client_print(id, print_console, "%s%L", CONSOLE_PREFIX, id, "ADMIN_RETURN_WAIT", id, g_szMLFlagTeam[iTeam], ADMIN_RETURNWAIT)
	}
	else
		client_print(id, print_console, "%s%L", CONSOLE_PREFIX, id, "ADMIN_RETURN_NOTDROPPED", id, g_szMLFlagTeam[iTeam])
	
	return PLUGIN_HANDLED
}

public event_restartGame()
{
	g_bRestarting = true
}

public event_roundStart()
{
	for(new id = 1; id <= MaxClients; id++)
	{
		if(!is_user_alive(id))
			continue
		
		if(g_bRestarting)
		{
			remove_task(id)
		}
	}
	
	for(new iFlagTeam = TEAM_RED; iFlagTeam <= TEAM_BLUE; iFlagTeam++)
	{
		flag_sendHome(iFlagTeam)
		remove_task(g_iFlagEntity[iFlagTeam])
		
		log_message("%s, %s flag returned back to base.", (g_bRestarting ? "Game restarted" : "New round started"), g_szTeamName[iFlagTeam])
	}
	
	if(g_bRestarting)
	{
		g_iScore = {0, 0, 0}
		g_bRestarting = false
	}
}

public msg_teamScore()
{
	static szTeam[3]
	get_msg_arg_string(1, szTeam, charsmax(szTeam))
	switch(szTeam[0])
	{
		case 'T': set_msg_arg_int(2, ARG_SHORT, g_iScore[TEAM_RED])
		case 'C': set_msg_arg_int(2, ARG_SHORT, g_iScore[TEAM_BLUE])
	}
}

public msg_roundTime()
{
	set_msg_arg_int(1, ARG_SHORT, get_timeleft())
}

player_healingEffect(id)
{
	new iOrigin[3]
	get_user_origin(id, iOrigin)
	
	message_begin(MSG_PVS, SVC_TEMPENTITY, iOrigin)
	write_byte(TE_PROJECTILE)
	write_coord(iOrigin[x] + random_num(-10, 10))
	write_coord(iOrigin[y] + random_num(-10, 10))
	write_coord(iOrigin[z] + random_num(0, 30))
	write_coord(0)
	write_coord(0)
	write_coord(15)
	write_short(gSpr_regeneration)
	write_byte(1)
	write_byte(id)
	message_end()
}

game_announce(iEvent, iFlagTeam, szName[])
{
	new iColor = iFlagTeam
	new szText[64]
	
	switch(iEvent)
	{
		case EVENT_TAKEN:
		{
			iColor = get_opTeam(iFlagTeam)
			formatex(szText, charsmax(szText), "%L", LANG_PLAYER, "ANNOUNCE_FLAGTAKEN", szName, LANG_PLAYER, g_szMLFlagTeam[iFlagTeam])
		}
		case EVENT_DROPPED: formatex(szText, charsmax(szText), "%L", LANG_PLAYER, "ANNOUNCE_FLAGDROPPED", szName, LANG_PLAYER, g_szMLFlagTeam[iFlagTeam])
		case EVENT_RETURNED:
		{
			if(strlen(szName) != 0)
				formatex(szText, charsmax(szText), "%L", LANG_PLAYER, "ANNOUNCE_FLAGRETURNED", szName, LANG_PLAYER, g_szMLFlagTeam[iFlagTeam])
			else
				formatex(szText, charsmax(szText), "%L", LANG_PLAYER, "ANNOUNCE_FLAGAUTORETURNED", LANG_PLAYER, g_szMLFlagTeam[iFlagTeam])
		}
		case EVENT_SCORE: formatex(szText, charsmax(szText), "%L", LANG_PLAYER, "ANNOUNCE_FLAGCAPTURED", szName, LANG_PLAYER, g_szMLFlagTeam[get_opTeam(iFlagTeam)])
	}
	
	set_hudmessage(iColor == TEAM_RED ? 255 : 0, iColor == TEAM_RED ? 0 : 255, iColor == TEAM_BLUE ? 255 : 0, HUD_ANNOUNCE)
	ShowSyncHudMsg(0, g_iSync[3], szText)
	
	if(get_pcvar_num(pCvar_ctf_sound[iEvent]))
	{
		client_cmd(0, "mp3 play ^"sound/jctf/%s.mp3^"", g_szSounds[iEvent][iFlagTeam])
	}
}
