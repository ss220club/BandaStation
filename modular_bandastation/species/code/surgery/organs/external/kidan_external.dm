/obj/item/organ/antennae/kidan

	name = "kidan antennae"
	desc = "A kidan antennae. What is it telling them? What are they sensing?"

	icon = 'icons/bandastation/mob/species/kidan/organs.dmi'
	icon_state = "kidan_antennae"

	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_HEAD_ANTENNAE

	dna_block = /datum/dna_block/feature/accessory/antennae/kidan
	restyle_flags = EXTERNAL_RESTYLE_FLESH

	bodypart_overlay = /datum/bodypart_overlay/mutant/antennae/kidan

	organ_flags = parent_type::organ_flags | ORGAN_EXTERNAL

/datum/bodypart_overlay/mutant/antennae/kidan
	layers = EXTERNAL_FRONT | EXTERNAL_BEHIND
	feature_key = FEATURE_KIDAN_ANTENNAE
	color_source = ORGAN_COLOR_INHERIT

/datum/bodypart_overlay/mutant/antennae/kidan/get_global_feature_list()
	return SSaccessories.feature_list[FEATURE_KIDAN_ANTENNAE]

/datum/bodypart_overlay/mutant/antennae/kidan/can_draw_on_bodypart(obj/item/bodypart/bodypart_owner)
	var/mob/living/carbon/human/human = bodypart_owner.owner
	if(!istype(human))
		return TRUE
	if((human.head?.flags_inv & HIDEHAIR) || (human.wear_mask?.flags_inv & HIDEHAIR))
		return FALSE
	return TRUE
