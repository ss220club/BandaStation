/datum/antagonist/hypnotized/thrall
	name = "Vampire Thrall"
	antag_hud_name = "traitor"
//	master_hud_name = "vampire"
// TODO: display master somehow

/datum/antagonist/hypnotized/thrall/add_owner_to_gamemode()
	SSticker.mode.vampire_enthralled += owner

/datum/antagonist/hypnotized/thrall/remove_owner_from_gamemode()
	owner.current.create_log(CONVERSION_LOG, "Deconverted from thrall")
	SSticker.mode.vampire_enthralled -= owner

/datum/antagonist/hypnotized/thrall/apply_innate_effects(mob/living/mob_override)
	mob_override = ..()
	var/datum/mind/M = mob_override.mind
	M.AddSpell(new /datum/action/cooldown/spell/vampire/thrall_commune)

/datum/antagonist/hypnotized/thrall/remove_innate_effects(mob/living/mob_override)
	mob_override = ..()
	var/datum/mind/M = mob_override.mind
	M.RemoveSpell(/datum/action/cooldown/spell/vampire/thrall_commune)
