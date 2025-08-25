/obj/item/organ/brain/shadow/shadowling
	name = "shadowling swarm brain"
	desc = "A writhing nexus of shadowstuff, binding its owner to the Hive."
	slot = ORGAN_SLOT_BRAIN

/obj/item/organ/brain/shadow/shadowling/Insert(mob/living/carbon/receiver, special = FALSE, movement_flags)
	. = ..()
	if(!.)
		return
	var/datum/language_holder/lang_holder = receiver.get_language_holder()
	lang_holder.grant_language(/datum/language/shadow_hive, ALL, LANGUAGE_ATOM)
	var/datum/shadow_hive/hive = get_shadow_hive()
	hive.join_ling(receiver)

/obj/item/organ/brain/shadow/shadowling/Remove(mob/living/carbon/organ_owner, special = FALSE, movement_flags)
	. = ..()
	if(!.)
		return
	var/datum/language_holder/lang_holder = organ_owner.get_language_holder()
	lang_holder.remove_language(/datum/language/shadow_hive, ALL, LANGUAGE_ATOM)
	var/datum/shadow_hive/hive = get_shadow_hive()
	hive.leave(organ_owner)

/obj/item/organ/brain/shadow/tumor_thrall
	name = "shadow thrall tumor"
	desc = "A parasitic node of the Hive, binding the host’s mind."
	slot = ORGAN_SLOT_BRAIN_THRALL

/obj/item/organ/brain/shadow/tumor_thrall/Insert(mob/living/carbon/receiver, special = FALSE, movement_flags)
	. = ..()
	if(!.)
		return
	var/datum/language_holder/lang_holder = receiver.get_language_holder()
	lang_holder.grant_language(/datum/language/shadow_hive, ALL, LANGUAGE_ATOM)
	var/datum/shadow_hive/hive = get_shadow_hive()
	hive.join_thrall(receiver)
	to_chat(receiver, span_danger("A frigid whisper coils in your mind... You are a thrall."))

/obj/item/organ/brain/shadow/tumor_thrall/Remove(mob/living/carbon/organ_owner, special = FALSE, movement_flags)
	. = ..()
	if(!.)
		return
	var/datum/language_holder/lang_holder = organ_owner.get_language_holder()
	lang_holder.remove_language(/datum/language/shadow_hive, ALL, LANGUAGE_ATOM)
	var/datum/shadow_hive/hive = get_shadow_hive()
	hive.leave(organ_owner)
	to_chat(organ_owner, span_notice("The chilling presence leaves your mind."))
