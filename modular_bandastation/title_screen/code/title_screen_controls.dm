/**
 * Reloads the titlescreen if it is bugged for someone.
 */
/client/verb/fix_title_screen()
	set name = "Fix Lobby Screen"
	set desc = "Lobbyscreen broke? Press this."
	set category = "Special"

	if(!isnewplayer(src.mob))
		SStitle.hide_title_screen_from(src)
		return

	SStitle.show_title_screen_to(src)

/client/open_escape_menu()
	if(isnewplayer(mob))
		return
	. = ..()
