/mob/dead/new_player/Login()
	. = ..()
	if(!. || !client)
		return
	if(client.interviewee)
		return
	INVOKE_ASYNC(src, PROC_REF(open_lobby_messenger_promo))

/mob/dead/new_player/proc/open_lobby_messenger_promo()
	if(QDELETED(src) || !client || client.interviewee)
		return
	if(client.lobby_messenger_promo)
		SStgui.close_user_uis(src, client.lobby_messenger_promo)
	client.lobby_messenger_promo = new
	client.lobby_messenger_promo.ui_interact(src)

/mob/dead/new_player/Destroy()
	if(client?.lobby_messenger_promo)
		SStgui.close_user_uis(src, client.lobby_messenger_promo)
		if(client.lobby_messenger_promo)
			QDEL_NULL(client.lobby_messenger_promo)
	return ..()
