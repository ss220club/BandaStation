/obj/item/organ/head_tentacle
	name = "skrell head tentacle"
	desc = "Is it really tentacle?"

	icon = 'icons/bandastation/mob/species/skrell/organs.dmi'
	icon_state = "head_tentacle"

	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_HEAD_TENTACLE

	preference = "feature_skrell_head_tentacle"

	dna_block = /datum/dna_block/feature/skrell_head_tentacle
	restyle_flags = EXTERNAL_RESTYLE_FLESH

	bodypart_overlay = /datum/bodypart_overlay/mutant/head_tentacle

	organ_flags = parent_type::organ_flags | ORGAN_EXTERNAL

	actions_types = list(/datum/action/item_action/organ_action/headpocket)

/obj/item/organ/head_tentacle/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/headpocket)

/obj/item/organ/head_tentacle/ui_action_click(mob/user, actiontype)
	. = ..()
	atom_storage.open_storage(user)

// MARK: Action

/datum/action/item_action/organ_action/headpocket
	name = "Полость в щупальцах"
	button_icon = 'modular_bandastation/species/icons/hud/actions.dmi'
	button_icon_state = "skrell_headpocket"

// MARK: Storage

/datum/storage/headpocket
	max_slots = 1
	max_specific_storage = WEIGHT_CLASS_SMALL
	max_total_storage = WEIGHT_CLASS_SMALL
	silent = TRUE

// MARK: Bodypart overlay

/datum/bodypart_overlay/mutant/head_tentacle
	layers = EXTERNAL_FRONT|EXTERNAL_ADJACENT
	feature_key = FEATURE_SKRELL_HEAD_TENTACLE
	color_source = ORGAN_COLOR_INHERIT

/datum/bodypart_overlay/mutant/head_tentacle/get_global_feature_list()
	return SSaccessories.skrell_head_tentacles_list

/datum/bodypart_overlay/mutant/head_tentacle/can_draw_on_bodypart(obj/item/bodypart/bodypart_owner)
	var/mob/living/carbon/human/human = bodypart_owner.owner
	if(!istype(human))
		return TRUE
	if((human.head?.flags_inv & HIDEHAIR) || (human.wear_mask?.flags_inv & HIDEHAIR))
		return FALSE
	return TRUE
