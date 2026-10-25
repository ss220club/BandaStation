/datum/quirk/cybernetic_rejection
	name = "Полное отторжение кибернетики"
	desc = "Ваше тело полностью несовместимо с кибернетикой. Любые вживлённые кибернетические органы, импланты и конечности не работают. Органические органы и конечности других рас работают как обычно. Борг-фабрика разорвёт ваше тело вместо превращения в киборга, а ваш мозг невозможно поместить ни в обычный, ни в синдикатовский MMI."
	icon = FA_ICON_PLUG_CIRCLE_XMARK
	value = -6
	mob_trait = TRAIT_CYBERNETIC_REJECTION
	gain_text = span_danger("Ваше тело полностью отторгает кибернетику.")
	lose_text = span_notice("Ваше тело снова совместимо с кибернетикой.")
	medical_record_text = "Полная несовместимость с кибернетическими органами, имплантами, конечностями и MMI. Переработка в борг-фабрике смертельна. Органические трансплантаты совместимы."
	hardcore_value = 6

/datum/quirk/cybernetic_rejection/is_species_appropriate(datum/species/mob_species)
	if(GLOB.species_prototypes[mob_species].inherent_biotypes & MOB_ROBOTIC)
		return FALSE
	return ..()

/datum/quirk/cybernetic_rejection/add(client/client_source)
	var/mob/living/carbon/human/human_holder = quirk_holder
	var/obj/item/organ/brain/brain = human_holder.get_organ_slot(ORGAN_SLOT_BRAIN)
	brain?.activate_skillchip_failsafe()
	for(var/obj/item/organ/organ as anything in human_holder.organs)
		organ.set_cybernetic_rejection(IS_ROBOTIC_ORGAN(organ))
	for(var/obj/item/implant/implant as anything in human_holder.implants?.Copy())
		implant.set_cybernetic_rejection(TRUE)
	for(var/obj/item/bodypart/limb as anything in human_holder.get_bodyparts())
		if(IS_ROBOTIC_LIMB(limb))
			ADD_TRAIT(limb, TRAIT_PARALYSIS, TRAIT_CYBERNETIC_REJECTION)
	RegisterSignal(human_holder, COMSIG_CARBON_ATTACH_LIMB, PROC_REF(on_limb_gain))
	RegisterSignal(human_holder, COMSIG_CARBON_REMOVE_LIMB, PROC_REF(on_limb_loss))

/datum/quirk/cybernetic_rejection/remove()
	UnregisterSignal(quirk_holder, list(COMSIG_CARBON_ATTACH_LIMB, COMSIG_CARBON_REMOVE_LIMB))
	var/mob/living/carbon/human/human_holder = quirk_holder
	if(QDELING(human_holder))
		return
	for(var/obj/item/organ/organ as anything in human_holder.organs)
		organ.set_cybernetic_rejection(FALSE)
	for(var/obj/item/implant/implant as anything in human_holder.implants?.Copy())
		implant.set_cybernetic_rejection(FALSE)
	for(var/obj/item/bodypart/limb as anything in human_holder.get_bodyparts())
		REMOVE_TRAIT(limb, TRAIT_PARALYSIS, TRAIT_CYBERNETIC_REJECTION)
	var/obj/item/organ/brain/brain = human_holder.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(brain)
		REMOVE_TRAIT(brain, TRAIT_CYBERNETIC_REJECTION, QUIRK_TRAIT)

/datum/quirk/cybernetic_rejection/proc/on_limb_gain(mob/living/carbon/source, obj/item/bodypart/limb)
	SIGNAL_HANDLER
	if(IS_ROBOTIC_LIMB(limb))
		ADD_TRAIT(limb, TRAIT_PARALYSIS, TRAIT_CYBERNETIC_REJECTION)

/datum/quirk/cybernetic_rejection/proc/on_limb_loss(mob/living/carbon/source, obj/item/bodypart/limb)
	SIGNAL_HANDLER
	REMOVE_TRAIT(limb, TRAIT_PARALYSIS, TRAIT_CYBERNETIC_REJECTION)
