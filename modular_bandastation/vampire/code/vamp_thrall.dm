/datum/antagonist/vampire_thrall
	name = "Vampire Thrall"
	roundend_category = "Vampire Thralls"
	antag_hud_name = "traitor"
	ui_name = "AntagInfoBrainwashed"
	antagpanel_category = ANTAG_GROUP_CREW
	show_name_in_check_antagonists = TRUE
	antag_flags = ANTAG_FAKE|ANTAG_SKIP_GLOBAL_LIST

	/// The vampire whose commands this thrall must obey.
	var/datum/weakref/master_ref

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
	obey_master.explanation_text = "Obey [master.owner.current]'s commands and protect [master.owner.current.p_them()]."
	obey_master.completed = TRUE
	objectives = list(obey_master)
	master.add_thrall(src)
	return ..()

/datum/antagonist/vampire_thrall/on_removal()
	get_master()?.remove_thrall(src)
	return ..()

/datum/antagonist/vampire_thrall/apply_innate_effects(mob/living/mob_override)
	var/datum/mind/thrall_mind = mob_override?.mind
	thrall_mind?.AddSpell(new /datum/action/cooldown/spell/vampire/thrall_commune)

/datum/antagonist/vampire_thrall/remove_innate_effects(mob/living/mob_override)
	var/datum/mind/thrall_mind = mob_override?.mind
	thrall_mind?.RemoveSpell(/datum/action/cooldown/spell/vampire/thrall_commune)
