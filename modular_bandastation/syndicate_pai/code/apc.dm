/obj/machinery/power/apc/ui_status(mob/user, datum/ui_state/state)
	. = ..()
	if(!istype(user, /mob/living/silicon/pai/syndicate))
		return
	var/mob/living/silicon/pai/syndicate/pai_user = user
	if(pai_user.active_remote_apc == src && ("Remote Machinery" in pai_user.installed_software) && pai_user.client)
		. = UI_INTERACTIVE

/obj/machinery/power/apc/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(!istype(ui?.user, /mob/living/silicon/pai/syndicate))
		return ..()
	var/mob/living/silicon/pai/syndicate/pai_user = ui.user
	if(pai_user.active_remote_apc != src || !("Remote Machinery" in pai_user.installed_software))
		return FALSE
	if(!COOLDOWN_FINISHED(pai_user, remote_machinery_action))
		balloon_alert(pai_user, "управление механизмами перезаряжается")
		return FALSE
	. = ..()
	if(.)
		COOLDOWN_START(pai_user, remote_machinery_action, 30 SECONDS)

/obj/machinery/power/apc/ui_close(mob/user)
	. = ..()
	if(!istype(user, /mob/living/silicon/pai/syndicate))
		return
	var/mob/living/silicon/pai/syndicate/pai_user = user
	if(pai_user.active_remote_apc == src)
		pai_user.active_remote_apc = null
