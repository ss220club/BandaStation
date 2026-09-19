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
	var/datum/action/cooldown/spell/vampire_commune/thrall_commune

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
	obey_master.explanation_text = "Подчиняйтесь приказам [master.owner.current] и защищайте [master.owner.current.ru_p_them()]."
	obey_master.completed = TRUE
	objectives = list(obey_master)
	master.add_thrall(src)
	return ..()

/datum/antagonist/vampire_thrall/on_removal()
	get_master()?.remove_thrall(src)
	return ..()

/datum/antagonist/vampire_thrall/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/thrall_mob = mob_override || owner.current
	if(!thrall_mob)
		return
	ADD_TRAIT(thrall_mob, TRAIT_VAMPIRE_LIKE, REF(src))
	if(ishuman(thrall_mob))
		thrall_mob.AddComponent(/datum/component/vampire_holywater)
	if(thrall_commune)
		return
	thrall_commune = new(null, TRUE)
	thrall_commune.Grant(thrall_mob)
	get_master()?.update_thrall_huds()

/datum/antagonist/vampire_thrall/remove_innate_effects(mob/living/mob_override)
	var/datum/antagonist/vampire/master = get_master()
	var/mob/living/thrall_mob = mob_override || owner.current
	if(thrall_mob)
		REMOVE_TRAIT(thrall_mob, TRAIT_VAMPIRE_LIKE, REF(src))
	if(ishuman(thrall_mob))
		var/datum/component/vampire_holywater/vampire_holywater = thrall_mob.GetComponent(/datum/component/vampire_holywater)
		QDEL_NULL(vampire_holywater)
	if(master)
		thrall_mob?.remove_alt_appearance(master.get_thrall_hud_key("thrall"))
	if(thrall_commune)
		thrall_commune.Remove(thrall_mob)
		QDEL_NULL(thrall_commune)
	return ..()
