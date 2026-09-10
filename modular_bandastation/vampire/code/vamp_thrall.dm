/datum/antagonist/vampire_thrall
	name = "Вампирский раб"
	roundend_category = "Вампирские рабы"
	antag_hud_name = "vampthrall"
	hud_icon = 'modular_bandastation/vampire/icons/mob/huds/vampire_antag.dmi'
	ui_name = "AntagInfoBrainwashed"
	antagpanel_category = ANTAG_GROUP_CREW
	show_name_in_check_antagonists = TRUE
	antag_flags = ANTAG_FAKE|ANTAG_SKIP_GLOBAL_LIST

	/// The vampire whose commands this thrall must obey.
	var/datum/weakref/master_ref
	/// The telepathic communication action granted to this thrall.
	var/datum/action/cooldown/spell/vampire_thrall_commune/thrall_commune

/datum/antagonist/vampire_thrall/New(datum/antagonist/vampire/master)
	master_ref = WEAKREF(master)
	return ..()

/datum/antagonist/vampire_thrall/proc/get_master() as /datum/antagonist/vampire
	return master_ref?.resolve()

/datum/antagonist/vampire_thrall/on_gain()
	var/datum/antagonist/vampire/master = get_master()
	if(!master)
		qdel(src)
		return

	var/datum/objective/obey_master = new
	obey_master.explanation_text = "Подчиняйтесь приказам [master.owner.current] и защищайте [master.owner.current.p_them()]."
	obey_master.completed = TRUE
	objectives = list(obey_master)
	master.add_thrall(src)
	return ..()

/datum/antagonist/vampire_thrall/on_removal()
	get_master()?.remove_thrall(src)
	return ..()

/datum/antagonist/vampire_thrall/apply_innate_effects(mob/living/mob_override)
	. = ..()
	if(ishuman(mob_override))
		mob_override.AddComponent(/datum/component/vampire_holywater)
	if(!mob_override || thrall_commune)
		return
	thrall_commune = new
	thrall_commune.Grant(mob_override)
	get_master()?.update_thrall_huds()

/datum/antagonist/vampire_thrall/remove_innate_effects(mob/living/mob_override)
	var/datum/antagonist/vampire/master = get_master()
	if(ishuman(mob_override))
		var/datum/component/vampire_holywater/vampire_holywater = mob_override.GetComponent(/datum/component/vampire_holywater)
		QDEL_NULL(vampire_holywater)
	if(master)
		mob_override?.remove_alt_appearance(master.get_thrall_hud_key("thrall"))
	if(thrall_commune)
		thrall_commune.Remove(mob_override)
		QDEL_NULL(thrall_commune)
	return ..()

/datum/action/cooldown/spell/vampire_thrall_commune
	name = "Общение"
	desc = "Телепатически общайтесь со своим вампиром-хозяином и его рабами."
	button_icon_state = "vamp_communication"
	cooldown_time = 2 SECONDS
	spell_requirements = NONE

/datum/action/cooldown/spell/vampire_thrall_commune/cast(atom/cast_on)
	. = ..()
	var/datum/antagonist/vampire_thrall/thrall = owner.mind?.has_antag_datum(/datum/antagonist/vampire_thrall)
	var/datum/antagonist/vampire/master = thrall?.get_master()
	if(!master?.owner?.current)
		to_chat(owner, span_warning("Ваша связь с хозяином угасла."))
		return

	var/message = tgui_input_text(owner, "Введите сообщение для сети вашего вампира.", "Общение рабов")
	if(!message)
		return
	var/list/recipients = list(master.owner.current)
	for(var/datum/antagonist/vampire_thrall/network_thrall as anything in master.get_thralls())
		if(network_thrall.owner?.current)
			recipients += network_thrall.owner.current
	for(var/mob/living/recipient as anything in recipients)
		to_chat(recipient, span_notice("[owner.real_name] (Раб): [message]"))
	log_say("(VAMPIRE THRALL) [message]", list("CONNECTION" = owner))
