// MARK: Species datums
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
		TRAIT_NO_SLIP_ALL,
		TRAIT_BRAWLING_KNOCKDOWN_BLOCKED
	)

	no_equip_flags = ITEM_SLOT_MASK | ITEM_SLOT_HEAD | ITEM_SLOT_EYES | ITEM_SLOT_OCLOTHING | ITEM_SLOT_GLOVES | ITEM_SLOT_FEET | ITEM_SLOT_ICLOTHING | ITEM_SLOT_SUITSTORE
	mutantbrain = /obj/item/organ/brain/shadow/shadowling
	mutanteyes = /obj/item/organ/eyes/shadow/shadowling

/datum/species/shadow/shadowling/ascended
	name = "Ascended Shadowling"
	id = SPECIES_SHADOWLING_ASCENDED
	no_equip_flags = ITEM_SLOT_MASK | ITEM_SLOT_HEAD | ITEM_SLOT_EYES | ITEM_SLOT_OCLOTHING | ITEM_SLOT_GLOVES | ITEM_SLOT_FEET | ITEM_SLOT_ICLOTHING | ITEM_SLOT_SUITSTORE | ITEM_SLOT_LPOCKET | ITEM_SLOT_RPOCKET | ITEM_SLOT_BELT | ITEM_SLOT_EARS | ITEM_SLOT_NECK | ITEM_SLOT_BACK | ITEM_SLOT_ID
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/shadow/shadowling/ascended,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/shadow/shadowling/ascended,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/shadow/shadowling/ascended,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/shadow/shadowling/ascended,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/shadow/shadowling/ascended,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/shadow/shadowling/ascended,
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
		TRAIT_NO_SLIP_ALL,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHEAT,
		TRAIT_BRAWLING_KNOCKDOWN_BLOCKED,
		TRAIT_FREE_FLOAT_MOVEMENT,
		TRAIT_MOVE_FLYING,

	)

/datum/species/shadow/shadowling/check_roundstart_eligible()
	return FALSE

/datum/species/shadow/shadowling/ascended/on_species_gain(mob/living/carbon/human/H)
	. = ..()
	if(!istype(H))
		return
	H.setMaxHealth(SHADOWLING_ASCENDED_MAX_HEALTH)
	H.heal_overall_damage()
	shadowling_equip_ascended_claws(H)

/datum/species/shadow/shadowling/ascended/on_species_loss(mob/living/carbon/human/H, datum/species/new_species)
	. = ..()
	if(!istype(H))
		return
	shadowling_remove_ascended_claws(H)

/datum/species/shadow/shadowling/ascended/proc/shadowling_equip_ascended_claws(mob/living/carbon/human/H)
	if(!istype(H))
		return

	var/obj/item/knife/combat/umbral_claw/left/claw_l = new(H)
	var/obj/item/knife/combat/umbral_claw/claw_r = new(H)

	H.drop_all_held_items()

	if(!H.put_in_l_hand(claw_l))
		H.dropItemToGround(claw_l, TRUE)
	if(!H.put_in_r_hand(claw_r))
		H.dropItemToGround(claw_r, TRUE)

/datum/species/shadow/shadowling/ascended/proc/shadowling_remove_ascended_claws(mob/living/carbon/human/H)
	if(!istype(H))
		return
	for(var/obj/item/knife/combat/umbral_claw/C in H.get_all_contents())
		qdel(C)

// MARK: Mob related
/mob/living/basic/adjustStaminaLoss(amount, updating_stamina = TRUE, forced = FALSE, required_biotype)
	if(isshadowling_ascended(src))
		return
	else
		. = ..()

/mob/living/carbon/human/proc/shadowling_strip_quirks()
	cleanse_quirk_datums()

/mob/living/carbon/human/proc/refresh_eye_overlays()
	remove_overlay(EYES_LAYER)

	var/obj/item/organ/eyes/E = get_organ_slot(ORGAN_SLOT_EYES)
	if(!E)
		return

	E.refresh(call_update = FALSE)
	overlays_standing[EYES_LAYER] = E.generate_body_overlay(src)
	apply_overlay(EYES_LAYER)

// MARK: Claws
/obj/item/knife/combat/umbral_claw
	name = "umbral claw (right)"
	desc = "Слиток зазубренной тени."
	icon = 'modular_bandastation/antagonists/icons/shadowling/shadowling_objects.dmi'
	icon_state = "claw_right"
	lefthand_file = 'modular_bandastation/antagonists/icons/shadowling/shadowling_empty.dmi'
	righthand_file = 'modular_bandastation/antagonists/icons/shadowling/shadowling_empty.dmi'
	inhand_icon_state = "claw_right"
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = INDESTRUCTIBLE
	force = 18
	armour_penetration = 25
	sharpness = SHARP_EDGED
	attack_verb_continuous = list("разрывает", "режет", "раздирает")
	attack_verb_simple = list("разрывать", "резать", "раздирать")
	hitsound = 'sound/items/weapons/slash.ogg'

/obj/item/knife/combat/umbral_claw/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)

/obj/item/knife/combat/umbral_claw/left
	name = "umbral claw (left)"
	icon_state = "claw_left"
	inhand_icon_state = "claw_left"
	sharpness = SHARP_POINTY
	attack_verb_continuous = list("пронзает", "протыкает", "разрывает")
	attack_verb_simple = list("пронзать", "протыкать", "разрывать")

// MARK: Bodyparts
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

// MARK: Organs
/obj/item/organ/brain/shadow/shadowling
	name = "shadowling swarm tumor"

/obj/item/organ/eyes/shadow/shadowling
	name = "freezing blue eyes"
	desc = "Even without their shadowy owner, looking at these eyes gives you a sense of dread."
	icon = 'icons/obj/medical/organs/shadow_organs.dmi'
	iris_overlay = "eyes_cyber_glow_iris"
	eye_icon_state = "eyes_glow_gs"
	icon_eyes_path = 'modular_bandastation/augmentation_preferences/icons/human_face.dmi'
	overlay_ignore_lighting = TRUE
	pepperspray_protect = TRUE
	color_cutoffs = null
	flash_protect = FLASH_PROTECTION_SENSITIVE
	eye_color_left = "#ff0000"
	eye_color_right = "#ff0000"

/obj/item/organ/eyes/shadow/shadowling/generate_body_overlay(mob/living/carbon/human/parent)
	. = ..()
	if(!islist(.))
		return .

	var/list/states_left = list("[eye_icon_state]_l", "[iris_overlay]_l")
	var/list/states_right = list("[eye_icon_state]_r", "[iris_overlay]_r")

	for(var/mutable_appearance/ov as anything in .)
		if(!istype(ov))
			continue
		if(ov.icon != icon_eyes_path)
			continue

		if(ov.icon_state in states_left)
			ov.color = eye_color_left
			continue

		if(ov.icon_state in states_right)
			ov.color = eye_color_right
			continue

	return .
