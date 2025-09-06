/datum/species/shadow/shadowling
	name = "Shadowling"
	plural_form = "Shadowlings"
	id = SPECIES_SHADOWLING

	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/shadow/shadowling,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/shadow/shadowling,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/shadow/shadowling,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/shadow/shadowling,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/shadow/shadowling,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/shadow/shadowling,
	)

	inherent_traits = list(
		TRAIT_GENELESS,
		TRAIT_LAVA_IMMUNE,
		TRAIT_NEVER_WOUNDED,
		TRAIT_NOBLOOD,
		TRAIT_NOBREATH,
		TRAIT_NODISMEMBER,
		TRAIT_NOFIRE,
		TRAIT_VIRUSIMMUNE,
		TRAIT_NO_AUGMENTS,
		TRAIT_NO_DNA_COPY,
		TRAIT_NO_PLASMA_TRANSFORM,
		TRAIT_NO_UNDERWEAR,
		TRAIT_PIERCEIMMUNE,
		TRAIT_RADIMMUNE,
		TRAIT_SNOWSTORM_IMMUNE,
		TRAIT_UNHUSKABLE,
		TRAIT_SILENT_FOOTSTEPS,
		TRAIT_NOHUNGER,
		TRAIT_NO_SLIP_ALL
	)

	no_equip_flags = ITEM_SLOT_MASK | ITEM_SLOT_HEAD | ITEM_SLOT_EYES | ITEM_SLOT_OCLOTHING | ITEM_SLOT_GLOVES | ITEM_SLOT_FEET | ITEM_SLOT_ICLOTHING | ITEM_SLOT_SUITSTORE
	mutantbrain = /obj/item/organ/brain/shadow/shadowling
	mutanteyes = /obj/item/organ/eyes/shadow/shadowling
	mutanttongue = /obj/item/organ/tongue/shadow_hive

/datum/species/shadow/shadowling/ascended
	name = "Ascended Shadowling"
	id = SPECIES_SHADOWLING_ASCENDED
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/shadow/shadowling/ascended,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/shadow/shadowling/ascended,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/shadow/shadowling/ascended,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/shadow/shadowling/ascended,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/shadow/shadowling/ascended,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/shadow/shadowling/ascended,
	)

/datum/species/shadow/shadowling/check_roundstart_eligible()
	return FALSE

/obj/item/organ/brain/shadow/shadowling
	name = "shadowling swarm tumor"

/obj/item/bodypart/head/shadow/shadowling
	limb_id = SPECIES_SHADOWLING
	biological_state = BIO_INORGANIC
	icon_static = 'modular_bandastation/antagonists/icons/shadowling/shadowling.dmi'
	bodypart_effects = list(/datum/status_effect/grouped/bodypart_effect/nyxosynthesis/shadowling)

/obj/item/bodypart/chest/shadow/shadowling
	limb_id = SPECIES_SHADOWLING
	biological_state = BIO_INORGANIC
	bodypart_traits = list(TRAIT_NO_JUMPSUIT)
	icon_static = 'modular_bandastation/antagonists/icons/shadowling/shadowling.dmi'
	bodypart_effects = list(/datum/status_effect/grouped/bodypart_effect/nyxosynthesis/shadowling)

/obj/item/bodypart/leg/left/shadow/shadowling
	limb_id = SPECIES_SHADOWLING
	biological_state = BIO_INORGANIC
	icon_static = 'modular_bandastation/antagonists/icons/shadowling/shadowling.dmi'
	bodypart_effects = list(/datum/status_effect/grouped/bodypart_effect/nyxosynthesis/shadowling)

/obj/item/bodypart/leg/right/shadow/shadowling
	limb_id = SPECIES_SHADOWLING
	biological_state = BIO_INORGANIC
	icon_static = 'modular_bandastation/antagonists/icons/shadowling/shadowling.dmi'
	bodypart_effects = list(/datum/status_effect/grouped/bodypart_effect/nyxosynthesis/shadowling)

/obj/item/bodypart/arm/left/shadow/shadowling
	limb_id = SPECIES_SHADOWLING
	biological_state = BIO_INORGANIC
	bodypart_effects = list(/datum/status_effect/grouped/bodypart_effect/nyxosynthesis/shadowling)
	unarmed_attack_verbs = list("slash", "claw", "scratch")
	unarmed_attack_verbs_continuous = list("slashes", "claws", "scratches")
	grappled_attack_verb = "lacerate"
	grappled_attack_verb_continuous = "lacerates"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/items/weapons/slash.ogg'
	unarmed_miss_sound = 'sound/items/weapons/slashmiss.ogg'
	unarmed_damage_low = 5
	unarmed_damage_high = 14
	unarmed_effectiveness = 20
	unarmed_sharpness = SHARP_EDGED
	bodypart_traits = list(TRAIT_CHUNKYFINGERS)
	icon_static = 'modular_bandastation/antagonists/icons/shadowling/shadowling.dmi'

/obj/item/bodypart/arm/right/shadow/shadowling
	limb_id = SPECIES_SHADOWLING
	biological_state = BIO_INORGANIC
	bodypart_effects = list(/datum/status_effect/grouped/bodypart_effect/nyxosynthesis/shadowling)
	unarmed_attack_verbs = list("pierce", "impale", "stab")
	unarmed_attack_verbs_continuous = list("pierces", "impales", "stabs")
	grappled_attack_verb = "pierce"
	grappled_attack_verb_continuous = "pierces"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/items/weapons/slash.ogg'
	unarmed_miss_sound = 'sound/items/weapons/slashmiss.ogg'
	unarmed_damage_low = 5
	unarmed_damage_high = 14
	unarmed_effectiveness = 20
	unarmed_sharpness = SHARP_POINTY
	bodypart_traits = list(TRAIT_CHUNKYFINGERS)
	icon_static = 'modular_bandastation/antagonists/icons/shadowling/shadowling.dmi'

/obj/item/organ/eyes/shadow/shadowling
	name = "freezing blue eyes"
	desc = "Even without their shadowy owner, looking at these eyes gives you a sense of dread."
	icon = 'icons/obj/medical/organs/shadow_organs.dmi'
	iris_overlay = "eyes_cyber_glow_iris"
	eye_icon_state = "eyes_glow_gs"
	icon_eyes_path = 'modular_bandastation/augmentation_preferences/icons/human_face.dmi'
	overlay_ignore_lighting = TRUE
	color_cutoffs = list(20, 10, 40)
	pepperspray_protect = TRUE
	flash_protect = FLASH_PROTECTION_SENSITIVE
	eye_color_left = "#3cb8a5"
	eye_color_right = "#3cb8a5"

/obj/item/bodypart/head/shadow/shadowling/ascended
	limb_id = SPECIES_SHADOWLING_ASCENDED
	icon_static = 'modular_bandastation/antagonists/icons/shadowling/shadowling_ascended.dmi'

/obj/item/bodypart/chest/shadow/shadowling/ascended
	limb_id = SPECIES_SHADOWLING_ASCENDED
	icon_static = 'modular_bandastation/antagonists/icons/shadowling/shadowling_ascended.dmi'

/obj/item/bodypart/leg/left/shadow/shadowling/ascended
	limb_id = SPECIES_SHADOWLING_ASCENDED
	icon_static = 'modular_bandastation/antagonists/icons/shadowling/shadowling_ascended.dmi'

/obj/item/bodypart/leg/right/shadow/shadowling/ascended
	limb_id = SPECIES_SHADOWLING_ASCENDED
	icon_static = 'modular_bandastation/antagonists/icons/shadowling/shadowling_ascended.dmi'

/obj/item/bodypart/arm/left/shadow/shadowling/ascended
	limb_id = SPECIES_SHADOWLING_ASCENDED
	icon_static = 'modular_bandastation/antagonists/icons/shadowling/shadowling_ascended.dmi'

/obj/item/bodypart/arm/right/shadow/shadowling/ascended
	limb_id = SPECIES_SHADOWLING_ASCENDED
	icon_static = 'modular_bandastation/antagonists/icons/shadowling/shadowling_ascended.dmi'

/mob/living/carbon/human
	var/lower_shadowling = FALSE

/mob/living/carbon/human/proc/shadowling_strip_quirks()
	cleanse_quirk_datums()
