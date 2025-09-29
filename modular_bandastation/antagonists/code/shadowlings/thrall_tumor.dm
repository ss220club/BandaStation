/obj/item/organ/brain/shadow/shadowling
	name = "shadowling swarm brain"
	desc = "Извивающийся клубок теневой плоти, намертво приковывающий хозяина к Рою."
	slot = ORGAN_SLOT_BRAIN

/obj/item/organ/brain/shadow/tumor_thrall
	name = "shadow thrall tumor"
	desc = "Паразитический узел Роя, опутывающий сознание носителя."
	slot = ORGAN_SLOT_BRAIN_THRALL

/obj/item/organ/brain/shadow/tumor_thrall/Insert(mob/living/carbon/receiver, special = FALSE, movement_flags)
	. = ..()
	if(!.)
		return
	receiver?.mind?.add_antag_datum(/datum/antagonist/shadow_thrall)
	RegisterSignal(receiver, COMSIG_ATOM_EXAMINE, PROC_REF(on_holder_examine))
	to_chat(receiver, span_danger("Леденящий шёпот пронизывает разум... Вы порабощены."))

/obj/item/organ/brain/shadow/tumor_thrall/Remove(mob/living/carbon/organ_owner, special = FALSE, movement_flags)
	. = ..()
	if(!.)
		return
	organ_owner?.mind?.remove_antag_datum(/datum/antagonist/shadow_thrall)
	UnregisterSignal(organ_owner, COMSIG_ATOM_EXAMINE)
	to_chat(organ_owner, span_notice("Сковывающий холод покидает ваше сознание. Вы снова подвластны себе!"))

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
	examine_list += span_warning("[capitalize(H.ru_p_them())] лицо до жути неестественно искажено.")
