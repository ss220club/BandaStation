#define LOOT_GOBLIN_BODYPARTS_ICON 'modular_bandastation/loot_goblin/icons/bodyparts.dmi'
#define LOOT_GOBLIN_SKIN_COLOR "#2b5a1f"

/datum/species/monkey/loot_goblin
	name = "\improper Лут гоблин"
	id = SPECIES_LOOT_GOBLIN
	changesource_flags = MIRROR_BADMIN
	fixed_mut_color = LOOT_GOBLIN_SKIN_COLOR
	mutant_organs = list()
	mutanttongue = /obj/item/organ/tongue/loot_goblin
	species_language_holder = /datum/language_holder/loot_goblin
	inherent_traits = list(
		TRAIT_NO_BLOOD_OVERLAY,
		TRAIT_NO_DNA_COPY,
		TRAIT_NO_UNDERWEAR,
		TRAIT_LESSER_HUMANOID,
		TRAIT_SIMIAN,
		TRAIT_MUTANT_COLORS,
	)
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/loot_goblin,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/loot_goblin,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/loot_goblin,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/loot_goblin,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/loot_goblin,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/loot_goblin,
	)

/obj/item/organ/tongue/loot_goblin
	name = "goblin tongue"
	emote_sounds = list(
		/datum/emote/living/laugh::key = 'modular_bandastation/loot_goblin/sound/goblin_laugh.ogg',
	)

/datum/language_holder/loot_goblin
	understood_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
	)
	spoken_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
	)

/obj/item/bodypart/head/loot_goblin
	icon_greyscale = LOOT_GOBLIN_BODYPARTS_ICON
	limb_id = SPECIES_GOBLIN_LIMB
	is_dimorphic = FALSE
	head_flags = HEAD_LIPS|HEAD_EYESPRITES|HEAD_EYECOLOR|HEAD_EYEHOLES|HEAD_DEBRAIN

/obj/item/bodypart/head/loot_goblin/Initialize(mapload)
	. = ..()
	add_bodypart_overlay(new /datum/bodypart_overlay/simple/loot_goblin_ears())
	add_bodypart_overlay(new /datum/bodypart_overlay/simple/loot_goblin_nose())

/obj/item/bodypart/chest/loot_goblin
	icon_greyscale = LOOT_GOBLIN_BODYPARTS_ICON
	limb_id = SPECIES_GOBLIN_LIMB
	is_dimorphic = TRUE
	bodypart_traits = list(
		TRAIT_PASSTABLE,
		TRAIT_VENTCRAWLER_NUDE,
		TRAIT_NO_AUGMENTS,
		TRAIT_NO_UNDERWEAR,
	)

/obj/item/bodypart/chest/loot_goblin/update_mob_heights(mob/living/carbon/holder)
	return HUMAN_HEIGHT_DWARF

/obj/item/bodypart/arm/left/loot_goblin
	icon_greyscale = LOOT_GOBLIN_BODYPARTS_ICON
	limb_id = SPECIES_GOBLIN_LIMB

/obj/item/bodypart/arm/right/loot_goblin
	icon_greyscale = LOOT_GOBLIN_BODYPARTS_ICON
	limb_id = SPECIES_GOBLIN_LIMB

/obj/item/bodypart/leg/left/loot_goblin
	icon_greyscale = LOOT_GOBLIN_BODYPARTS_ICON
	limb_id = SPECIES_GOBLIN_LIMB

/obj/item/bodypart/leg/right/loot_goblin
	icon_greyscale = LOOT_GOBLIN_BODYPARTS_ICON
	limb_id = SPECIES_GOBLIN_LIMB

/datum/bodypart_overlay/simple/loot_goblin_ears
	icon = 'modular_bandastation/loot_goblin/icons/goblin_ears.dmi'
	icon_state = "m_goblin_ears_long"
	layers = list(
		EXTERNAL_ADJACENT = BODY_ADJ_LAYER,
		EXTERNAL_FRONT = BODY_FRONT_LAYER,
	)
	offset_location = UPPER_BODY
	draw_color = LOOT_GOBLIN_SKIN_COLOR

/datum/bodypart_overlay/simple/loot_goblin_ears/New()
	. = ..()
	icon_state = "m_goblin_ears_[pick("normal", "wide", "broad", "long")]"

/datum/bodypart_overlay/simple/loot_goblin_nose
	icon = 'modular_bandastation/loot_goblin/icons/goblin_nose.dmi'
	icon_state = "m_goblin_nose_button"
	layers = list(
		EXTERNAL_ADJACENT = BODY_ADJ_LAYER,
	)
	offset_location = UPPER_BODY
	draw_color = LOOT_GOBLIN_SKIN_COLOR

/datum/bodypart_overlay/simple/loot_goblin_nose/New()
	. = ..()
	icon_state = "m_goblin_nose_[pick("button", "liar", "sniffer", "hook", "wobble")]"

#undef LOOT_GOBLIN_BODYPARTS_ICON
#undef LOOT_GOBLIN_SKIN_COLOR
