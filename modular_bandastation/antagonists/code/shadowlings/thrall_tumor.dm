/obj/item/organ/brain/shadow/shadowling
	name = "shadowling swarm brain"
	desc = "A writhing nexus of shadowstuff, binding its owner to the Hive."
	slot = ORGAN_SLOT_BRAIN

/obj/item/organ/brain/shadow/shadowling/Insert(mob/living/carbon/receiver, special = FALSE, movement_flags)
	. = ..()
	if(!.)
		return
	var/datum/team/shadow_hive/hive = get_shadow_hive()
	if(hive)
		hive.join_member(receiver, SHADOWLING_ROLE_MAIN)

/obj/item/organ/brain/shadow/shadowling/Remove(mob/living/carbon/organ_owner, special = FALSE, movement_flags)
	. = ..()
	if(!.)
		return
	var/datum/team/shadow_hive/hive = get_shadow_hive()
	if(hive)
		hive.leave_member(organ_owner)

/obj/item/organ/brain/shadow/tumor_thrall
	name = "shadow thrall tumor"
	desc = "A parasitic node of the Hive, binding the host’s mind."
	slot = ORGAN_SLOT_BRAIN_THRALL

/obj/item/organ/brain/shadow/tumor_thrall/Insert(mob/living/carbon/receiver, special = FALSE, movement_flags)
	. = ..()
	if(!.)
		return
	var/datum/team/shadow_hive/hive = get_shadow_hive()
	if(hive)
		hive.join_member(receiver, SHADOWLING_ROLE_THRALL)
	RegisterSignal(receiver, COMSIG_ATOM_EXAMINE, PROC_REF(on_holder_examine))
	to_chat(receiver, span_danger("A frigid whisper coils in your mind... You are a thrall."))

/obj/item/organ/brain/shadow/tumor_thrall/Remove(mob/living/carbon/organ_owner, special = FALSE, movement_flags)
	. = ..()
	if(!.)
		return
	var/datum/team/shadow_hive/hive = get_shadow_hive()
	if(hive)
		hive.leave_member(organ_owner)
	UnregisterSignal(organ_owner, COMSIG_ATOM_EXAMINE)
	to_chat(organ_owner, span_notice("The chilling presence leaves your mind."))

/obj/item/organ/brain/shadow/tumor_thrall/proc/on_holder_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/H = source
	if(!istype(H) || !ismob(user))
		return
	if(H.get_organ_slot(ORGAN_SLOT_BRAIN_THRALL) != src)
		return
	if(!user.Adjacent(H))
		return
	if(H.wear_mask)
		return
	examine_list += span_warning("Его лицо как-то неестественно искажено.")
