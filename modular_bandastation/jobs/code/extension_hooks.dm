/// Whether automatic staffing and random latejoin require an enabled job preference.
/datum/job/proc/requires_explicit_preference()
	return FALSE

/// Additional job admission rules. A null reason preserves ordinary admission.
/datum/job/proc/get_join_lock_reason(client/player)
	SHOULD_CALL_PARENT(TRUE)
	return null

/// AI construction moves the lobby mind before preferences can yield; restore only that owned mind.
/datum/job/proc/rollback_spawn_character(mob/living/body, mob/dead/new_player/spawning_player, datum/mind/spawning_mind)
	if(QDELETED(body) || !isAI(body) || QDELETED(spawning_player) || QDELETED(spawning_mind))
		return
	if(body.mind != spawning_mind || spawning_mind.current != body || spawning_mind.assigned_role != src || spawning_player.mind)
		return
	spawning_mind.transfer_to(spawning_player)

/// TRUE means a module handled this item; FALSE leaves the native storage operation intact.
/datum/outfit/proc/equip_backpack_item(mob/living/carbon/human/user, item_path)
	return FALSE

/datum/id_trim/job
	/// Expose a registered job template only through native CentCom authentication.
	var/centcom_template = FALSE

/// Blank cards have no paycheck account. Access is already applied; finish native RETA grants only.
/datum/controller/subsystem/id_access/proc/finish_unbanked_trim_access(obj/item/card/id/id_card)
	if(id_card.registered_account)
		return FALSE
	apply_active_reta_grants_to_card(id_card)
	return TRUE
