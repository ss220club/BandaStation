#define SPECIES_SHADOWLING "shadow"

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
		TRAIT_SNOWSTORM_IMMUNE, // Shared with plasma river... but I guess if you can survive a plasma river a blizzard isn't a big deal
		TRAIT_UNHUSKABLE,
		TRAIT_SILENT_FOOTSTEPS,
		TRAIT_NOHUNGER,
		TRAIT_NO_SLIP_ALL
	)

	no_equip_flags = ITEM_SLOT_MASK | ITEM_SLOT_HEAD | ITEM_SLOT_EYES | ITEM_SLOT_OCLOTHING | ITEM_SLOT_GLOVES | ITEM_SLOT_FEET | ITEM_SLOT_ICLOTHING | ITEM_SLOT_SUITSTORE
	mutantbrain = /obj/item/organ/brain/shadow/shadowling

/datum/species/shadow/shadowling/check_roundstart_eligible()
	return TRUE//FALSE

/obj/item/organ/brain/shadow/shadowling
	name = "shadowling swarm tumor"

/obj/item/bodypart/head/shadow/shadowling
	limb_id = SPECIES_SHADOWLING
	biological_state = BIO_INORGANIC
	bodypart_effects = list(/datum/status_effect/grouped/bodypart_effect/nyxosynthesis/shadowling)

/obj/item/bodypart/chest/shadow/shadowling
	limb_id = SPECIES_SHADOWLING
	biological_state = BIO_INORGANIC
	bodypart_traits = list(TRAIT_NO_JUMPSUIT)
	bodypart_effects = list(/datum/status_effect/grouped/bodypart_effect/nyxosynthesis/shadowling)

/obj/item/bodypart/leg/left/shadow/shadowling
	limb_id = SPECIES_SHADOWLING
	biological_state = BIO_INORGANIC
	bodypart_effects = list(/datum/status_effect/grouped/bodypart_effect/nyxosynthesis/shadowling)

/obj/item/bodypart/leg/right/shadow/shadowling
	limb_id = SPECIES_SHADOWLING
	biological_state = BIO_INORGANIC
	bodypart_effects = list(/datum/status_effect/grouped/bodypart_effect/nyxosynthesis/shadowling)

/obj/item/bodypart/arm/left/shadow/shadowling
	limb_id = SPECIES_SHADOWLING
	biological_state = BIO_INORGANIC
	bodypart_effects = list(/datum/status_effect/grouped/bodypart_effect/nyxosynthesis/shadowling)
	unarmed_attack_verbs = list("slash", "lash")
	unarmed_attack_verbs_continuous = list("slashes", "lashes")
	grappled_attack_verb = "lacerate"
	grappled_attack_verb_continuous = "lacerates"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_damage_low = 5
	unarmed_damage_high = 14
	unarmed_effectiveness = 20
	unarmed_sharpness = SHARP_EDGED
	bodypart_traits = list(TRAIT_CHUNKYFINGERS)
	bodypart_effects = list(/datum/status_effect/grouped/bodypart_effect/nyxosynthesis)

/obj/item/bodypart/arm/right/shadow/shadowling
	limb_id = SPECIES_SHADOWLING
	biological_state = BIO_INORGANIC
	bodypart_effects = list(/datum/status_effect/grouped/bodypart_effect/nyxosynthesis/shadowling)
	unarmed_attack_verbs = list("pierce", "impale")
	unarmed_attack_verbs_continuous = list("pierces", "impales")
	grappled_attack_verb = "pierce"
	grappled_attack_verb_continuous = "pierces"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_damage_low = 5
	unarmed_damage_high = 14
	unarmed_effectiveness = 20
	unarmed_sharpness = SHARP_POINTY
	bodypart_traits = list(TRAIT_CHUNKYFINGERS)
	bodypart_effects = list(/datum/status_effect/grouped/bodypart_effect/nyxosynthesis)
