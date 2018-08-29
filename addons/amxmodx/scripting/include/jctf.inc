#if defined _jctf_included
	#endinput
#endif

#define _jctf_included
#pragma library jctf

/*
	These are parsed in the iEvent var of the jctf_flag() forward.
*/
enum
{
	/* Event		| Forward variables used by event	| Description of event								*/
	FLAG_STOLEN = 0,	/* iPlayer, iFlagTeam			| iPlayer got iFlagTeam's flag from their base					*/
	FLAG_PICKED,		/* iPlayer, iFlagTeam			| iPlayer picked iFlagTeam's flag from the ground				*/
	FLAG_DROPPED,		/* iPlayer, iFlagTeam			| iPlayer dropped the iFlagTeam's flag by dying, disconnecting or manually	*/
	FLAG_MANUALDROP,	/* iPlayer, iFlagTeam			| iPlayer dropped the iFlagTeam's flag manually (using /dropflag)		*/
	FLAG_RETURNED,		/* iPlayer, iFlagTeam, bAssist 		| iPlayer (bAssist ? "assisted on returning" : "returned") the iFlagTeam's flag	*/
	FLAG_CAPTURED,		/* iPlayer, iFlagTeam, bAssist		| iPlayer (bAssist ? "assisted on capturing" : "captured") the iFlagTeam's flag	*/
	FLAG_AUTORETURN,	/* iFlagTeam				| iFlagTeam's flag was automatically returned					*/
	FLAG_ADMINRETURN	/* iPlayer, iFlagTeam			| iFlagTeam's flag was returned by admin iPlayer using the command		*/
};

/**
 * This forward triggers when a team's flag changes status.
 * This forward also triggers, for example, when a flag is captured, for the
 * capturing player and also for the assisting ones, each having bAssist true/false acordingly.
 *
 * @param iEvent		The event triggered (list above)
 * @param iPlayer		Index of player
 * @param iFlagTeam	The flag's team
 * @param bool:bAssist	Is true if the iPlayer is an assisting player for iEvent, false if not.
 * @noreturn
 */
forward jctf_flag(iEvent, iPlayer, iFlagTeam, bool:bAssist)

/**
 * This native returns if the player is carrying the flag
 * NOTE: It doesn't check if player is actually a player, you could get plugin errors if you use it wrong.
 *
 * @param id		Index of player
 * @return		1 if player is carying the flag, 0 otherwise
 */
native jctf_get_flagcarrier(id)

/**
 * Retorna cuanta adrenalina tiene un jugador
 * NOTE: 
 *
 * @param id		Index of player
 * @return		Adrenaline of player
 */
native get_user_adrenaline(id)

/**
 * Le establece adrenalina al jugador según el parámetro iAdr
 * NOTE: 
 *
 * @param id		Index of player
 * @param iAdr		Adrenaline to set
 * @return		don't return
 */
native set_user_adrenaline(id, iAdr)

/**
 * Muestra la tienda de adrenalina
 * NOTE: 
 *
 * @param id		Index of player
 * @return		don't return
 */
native display_shop(id)

/**
 * Agrega items a la tienda de adrenalina
 * NOTE: 
 *
 * @noreturn
 */
native shop_add_item(const name[], cost, const function[])
