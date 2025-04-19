/datum/species/skrell
	name = "Скрелл"
	plural_form = "Скреллы"
	id = SPECIES_SKRELL
	inherent_traits = list(
		TRAIT_MUTANT_COLORS
	)
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT

	species_language_holder = /datum/language_holder/skrell
	mutantbrain = /obj/item/organ/brain/skrell
	mutantheart = /obj/item/organ/heart/skrell
	mutantlungs = /obj/item/organ/lungs/skrell
	mutanteyes = /obj/item/organ/eyes/skrell
	mutanttongue = /obj/item/organ/tongue/skrell
	mutantliver = /obj/item/organ/liver/skrell
	mutantstomach = /obj/item/organ/stomach/skrell
	mutant_organs = list(
		/obj/item/organ/head_tentacle = /datum/sprite_accessory/skrell_head_tentacle/long::name
	)

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/skrell,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/skrell,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/skrell,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/skrell,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/skrell,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/skrell,
	)
	payday_modifier = 1.5

/datum/species/tajaran/get_species_lore()
	return list(

	)

/datum/species/tajaran/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "assistive-listening-systems",
			SPECIES_PERK_NAME = "Чувствительный слух",
			SPECIES_PERK_DESC = "[plural_form] лучше слышат, но более чувствительны к громким звукам, например, светошумовым гранатам.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "",
			SPECIES_PERK_NAME = "",
			SPECIES_PERK_DESC = "",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "",
			SPECIES_PERK_NAME = "Непереносимость алкоголя",
			SPECIES_PERK_DESC = "Алкоголь токсичен для скреллов и очень быстро вызывает опьянение.",
		),
	)
	return to_add
