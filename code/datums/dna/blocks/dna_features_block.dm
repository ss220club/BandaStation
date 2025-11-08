/datum/dna_block/feature/mutant_color
	block_length = DNA_BLOCK_SIZE_COLOR
	feature_key = FEATURE_MUTANT_COLOR

/datum/dna_block/feature/mutant_color/create_unique_block(mob/living/carbon/human/target)
	return sanitize_hexcolor(target.dna.features[feature_key], include_crunch = FALSE)

/datum/dna_block/feature/mutant_color/apply_to_mob(mob/living/carbon/human/target, dna_hash)
	target.dna.features[feature_key] = sanitize_hexcolor(get_block(dna_hash))

/datum/dna_block/feature/ethereal_color
	block_length = DNA_BLOCK_SIZE_COLOR
	feature_key = FEATURE_ETHEREAL_COLOR

/datum/dna_block/feature/ethereal_color/create_unique_block(mob/living/carbon/human/target)
	return sanitize_hexcolor(target.dna.features[FEATURE_ETHEREAL_COLOR], include_crunch = FALSE)

/datum/dna_block/feature/ethereal_color/apply_to_mob(mob/living/carbon/human/target, dna_hash)
	target.dna.features[feature_key] = sanitize_hexcolor(get_block(dna_hash))

/// Features tied to a sprite accessory
/datum/dna_block/feature/accessory
	abstract_type = /datum/dna_block/feature/accessory

/datum/dna_block/feature/accessory/create_unique_block(mob/living/carbon/human/target)
	var/block_value = SSaccessories.feature_list[feature_key].Find(target.dna.features[feature_key])
	var/max_value = length(SSaccessories.feature_list[feature_key])
	return construct_block(block_value, max_value)

/datum/dna_block/feature/accessory/apply_to_mob(mob/living/carbon/human/target, dna_hash)
	var/block_value = get_block(dna_hash)
	var/max_value = length(SSaccessories.feature_list[feature_key])
	var/deconstructed = deconstruct_block(block_value, max_value)
	target.dna.features[feature_key] = SSaccessories.feature_list[feature_key][deconstructed]

/datum/dna_block/feature/accessory/ears
	feature_key = FEATURE_EARS

// One day, someone should consider merging all tails into one, this is stupid
// No I don't care that it will "Create situations where a felinid grows a lizard tail" that makes it more fun
/datum/dna_block/feature/accessory/tail
	feature_key = FEATURE_TAIL_CAT

/datum/dna_block/feature/accessory/tail_lizard
	feature_key = FEATURE_TAIL_LIZARD

/datum/dna_block/feature/accessory/tail_fish
	feature_key = FEATURE_TAIL_FISH

/datum/dna_block/feature/accessory/snout
	feature_key = FEATURE_SNOUT

/datum/dna_block/feature/accessory/lizard_marking
	feature_key = FEATURE_LIZARD_MARKINGS

/datum/dna_block/feature/accessory/horn
	feature_key = FEATURE_HORNS

/datum/dna_block/feature/accessory/frill
	feature_key = FEATURE_FRILLS

/datum/dna_block/feature/accessory/spine
	feature_key = FEATURE_SPINES

/datum/dna_block/feature/accessory/moth_wing
	feature_key = FEATURE_MOTH_WINGS

/datum/dna_block/feature/accessory/moth_wing/create_unique_block(mob/living/carbon/human/target)
	if(target.dna.features[feature_key] == "Burnt Off") // Why is this snowflake check a thing. Please find a way to fix this later
		return random_string(block_length, GLOB.hex_characters)
	return ..()

/datum/dna_block/feature/accessory/moth_antenna
	feature_key = FEATURE_MOTH_ANTENNAE

/datum/dna_block/feature/accessory/moth_antenna/create_unique_block(mob/living/carbon/human/target)
	if(target.dna.features[feature_key] == "Burnt Off")
		return random_string(block_length, GLOB.hex_characters)
	return ..()

/datum/dna_block/feature/accessory/moth_marking
	feature_key = FEATURE_MOTH_MARKINGS

/datum/dna_block/feature/accessory/mush_cap
	feature_key = FEATURE_MUSH_CAP

/datum/dna_block/feature/accessory/pod_hair
	feature_key = FEATURE_POD_HAIR

/datum/dna_block/feature/pod_hair/create_unique_block(mob/living/carbon/human/target)
	return construct_block(SSaccessories.pod_hair_list.Find(target.dna.features[feature_key]), length(SSaccessories.pod_hair_list))

/datum/dna_block/feature/pod_hair/apply_to_mob(mob/living/carbon/human/target, dna_hash)
	target.dna.features[feature_key] = SSaccessories.pod_hair_list[deconstruct_block(get_block(dna_hash), length(SSaccessories.pod_hair_list))]

// BANDASTATION ADD START - Species
// MARK: Vulpkanin
/datum/dna_block/feature/vulpkanin_head_markings
	feature_key = FEATURE_VULPKANIN_HEAD_MARKINGS

/datum/dna_block/feature/vulpkanin_head_markings/create_unique_block(mob/living/carbon/human/target)
	return construct_block(SSaccessories.vulpkanin_head_markings_list.Find(target.dna.features[feature_key]), length(SSaccessories.vulpkanin_head_markings_list))

/datum/dna_block/feature/vulpkanin_head_markings/apply_to_mob(mob/living/carbon/human/target, dna_hash)
	target.dna.features[feature_key] = SSaccessories.vulpkanin_head_markings_list[deconstruct_block(get_block(dna_hash), length(SSaccessories.vulpkanin_head_markings_list))]

/datum/dna_block/feature/vulpkanin_chest_markings
	feature_key = FEATURE_VULPKANIN_CHEST_MARKINGS

/datum/dna_block/feature/vulpkanin_chest_markings/create_unique_block(mob/living/carbon/human/target)
	return construct_block(SSaccessories.vulpkanin_chest_markings_list.Find(target.dna.features[feature_key]), length(SSaccessories.vulpkanin_chest_markings_list))

/datum/dna_block/feature/vulpkanin_chest_markings/apply_to_mob(mob/living/carbon/human/target, dna_hash)
	target.dna.features[feature_key] = SSaccessories.vulpkanin_chest_markings_list[deconstruct_block(get_block(dna_hash), length(SSaccessories.vulpkanin_chest_markings_list))]

/datum/dna_block/feature/vulpkanin_limb_markings
	feature_key = FEATURE_VULPKANIN_LIMB_MARKINGS

/datum/dna_block/feature/vulpkanin_limb_markings/create_unique_block(mob/living/carbon/human/target)
	return construct_block(SSaccessories.vulpkanin_limb_markings_list.Find(target.dna.features[feature_key]), length(SSaccessories.vulpkanin_limb_markings_list))

/datum/dna_block/feature/vulpkanin_limb_markings/apply_to_mob(mob/living/carbon/human/target, dna_hash)
	target.dna.features[feature_key] = SSaccessories.vulpkanin_limb_markings_list[deconstruct_block(get_block(dna_hash), length(SSaccessories.vulpkanin_limb_markings_list))]

/datum/dna_block/feature/vulpkanin_tail
	feature_key = FEATURE_VULPKANIN_TAIL

/datum/dna_block/feature/vulpkanin_tail/create_unique_block(mob/living/carbon/human/target)
	return construct_block(SSaccessories.tails_list_vulpkanin.Find(target.dna.features[feature_key]), length(SSaccessories.tails_list_vulpkanin))

/datum/dna_block/feature/vulpkanin_tail/apply_to_mob(mob/living/carbon/human/target, dna_hash)
	target.dna.features[feature_key] = SSaccessories.tails_list_vulpkanin[deconstruct_block(get_block(dna_hash), length(SSaccessories.tails_list_vulpkanin))]

/datum/dna_block/feature/vulpkanin_tail_markings
	feature_key = FEATURE_VULPKANIN_TAIL_MARKINGS

/datum/dna_block/feature/vulpkanin_tail_markings/create_unique_block(mob/living/carbon/human/target)
	return construct_block(SSaccessories.vulpkanin_tail_markings_list.Find(target.dna.features[feature_key]), length(SSaccessories.vulpkanin_tail_markings_list))

/datum/dna_block/feature/vulpkanin_tail_markings/apply_to_mob(mob/living/carbon/human/target, dna_hash)
	target.dna.features[feature_key] = SSaccessories.vulpkanin_tail_markings_list[deconstruct_block(get_block(dna_hash), length(SSaccessories.vulpkanin_tail_markings_list))]

/datum/dna_block/feature/vulpkanin_facial_hair
	feature_key = FEATURE_VULPKANIN_FACIAL_HAIR

/datum/dna_block/feature/vulpkanin_facial_hair/create_unique_block(mob/living/carbon/human/target)
	return construct_block(SSaccessories.vulpkanin_facial_hair_list.Find(target.dna.features[feature_key]), length(SSaccessories.vulpkanin_facial_hair_list))

/datum/dna_block/feature/vulpkanin_facial_hair/apply_to_mob(mob/living/carbon/human/target, dna_hash)
	target.dna.features[feature_key] = SSaccessories.vulpkanin_facial_hair_list[deconstruct_block(get_block(dna_hash), length(SSaccessories.vulpkanin_facial_hair_list))]

/datum/dna_block/feature/vulpkanin_body_markings_color
	block_length = DNA_BLOCK_SIZE_COLOR
	feature_key = FEATURE_VULPKANIN_BODY_MARKINGS_COLOR

/datum/dna_block/feature/vulpkanin_body_markings_color/create_unique_block(mob/living/carbon/human/target)
	return sanitize_hexcolor(target.dna.features[feature_key], include_crunch = FALSE)

/datum/dna_block/feature/vulpkanin_body_markings_color/apply_to_mob(mob/living/carbon/human/target, dna_hash)
	target.dna.features[feature_key] = sanitize_hexcolor(get_block(dna_hash))

/datum/dna_block/feature/vulpkanin_tail_markings_color
	block_length = DNA_BLOCK_SIZE_COLOR
	feature_key = FEATURE_VULPKANIN_TAIL_MARKINGS_COLOR

/datum/dna_block/feature/vulpkanin_tail_markings_color/create_unique_block(mob/living/carbon/human/target)
	return sanitize_hexcolor(target.dna.features[feature_key], include_crunch = FALSE)

/datum/dna_block/feature/vulpkanin_tail_markings_color/apply_to_mob(mob/living/carbon/human/target, dna_hash)
	target.dna.features[feature_key] = sanitize_hexcolor(get_block(dna_hash))

/datum/dna_block/feature/vulpkanin_head_markings_color
	block_length = DNA_BLOCK_SIZE_COLOR
	feature_key = FEATURE_VULPKANIN_HEAD_MARKINGS_COLOR

/datum/dna_block/feature/vulpkanin_head_markings_color/create_unique_block(mob/living/carbon/human/target)
	return sanitize_hexcolor(target.dna.features[feature_key], include_crunch = FALSE)

/datum/dna_block/feature/vulpkanin_head_markings_color/apply_to_mob(mob/living/carbon/human/target, dna_hash)
	target.dna.features[feature_key] = sanitize_hexcolor(get_block(dna_hash))

/datum/dna_block/feature/vulpkanin_facial_hair_color
	block_length = DNA_BLOCK_SIZE_COLOR
	feature_key = FEATURE_VULPKANIN_FACIAL_HAIR_COLOR

/datum/dna_block/feature/vulpkanin_facial_hair_color/create_unique_block(mob/living/carbon/human/target)
	return sanitize_hexcolor(target.dna.features[feature_key], include_crunch = FALSE)

/datum/dna_block/feature/vulpkanin_facial_hair_color/apply_to_mob(mob/living/carbon/human/target, dna_hash)
	target.dna.features[feature_key] = sanitize_hexcolor(get_block(dna_hash))

// MARK: Tajaran
/datum/dna_block/feature/tajaran_head_markings
	feature_key = FEATURE_TAJARAN_HEAD_MARKINGS

/datum/dna_block/feature/tajaran_head_markings/create_unique_block(mob/living/carbon/human/target)
	return construct_block(SSaccessories.tajaran_head_markings_list.Find(target.dna.features[feature_key]), length(SSaccessories.tajaran_head_markings_list))

/datum/dna_block/feature/tajaran_head_markings/apply_to_mob(mob/living/carbon/human/target, dna_hash)
	target.dna.features[feature_key] = SSaccessories.tajaran_head_markings_list[deconstruct_block(get_block(dna_hash), length(SSaccessories.tajaran_head_markings_list))]

/datum/dna_block/feature/tajaran_chest_markings
	feature_key = FEATURE_TAJARAN_CHEST_MARKINGS

/datum/dna_block/feature/tajaran_chest_markings/create_unique_block(mob/living/carbon/human/target)
	return construct_block(SSaccessories.tajaran_chest_markings_list.Find(target.dna.features[feature_key]), length(SSaccessories.tajaran_chest_markings_list))

/datum/dna_block/feature/tajaran_chest_markings/apply_to_mob(mob/living/carbon/human/target, dna_hash)
	target.dna.features[feature_key] = SSaccessories.tajaran_chest_markings_list[deconstruct_block(get_block(dna_hash), length(SSaccessories.tajaran_chest_markings_list))]

/datum/dna_block/feature/tajaran_limb_markings
	feature_key = FEATURE_TAJARAN_LIMB_MARKINGS

/datum/dna_block/feature/tajaran_limb_markings/create_unique_block(mob/living/carbon/human/target)
	return construct_block(SSaccessories.tajaran_limb_markings_list.Find(target.dna.features[feature_key]), length(SSaccessories.tajaran_limb_markings_list))

/datum/dna_block/feature/tajaran_limb_markings/apply_to_mob(mob/living/carbon/human/target, dna_hash)
	target.dna.features[feature_key] = SSaccessories.tajaran_limb_markings_list[deconstruct_block(get_block(dna_hash), length(SSaccessories.tajaran_limb_markings_list))]

/datum/dna_block/feature/tajaran_tail
	feature_key = FEATURE_TAJARAN_TAIL

/datum/dna_block/feature/tajaran_tail/create_unique_block(mob/living/carbon/human/target)
	return construct_block(SSaccessories.tails_list_tajaran.Find(target.dna.features[feature_key]), length(SSaccessories.tails_list_tajaran))

/datum/dna_block/feature/tajaran_tail/apply_to_mob(mob/living/carbon/human/target, dna_hash)
	target.dna.features[feature_key] = SSaccessories.tails_list_tajaran[deconstruct_block(get_block(dna_hash), length(SSaccessories.tails_list_tajaran))]

/datum/dna_block/feature/tajaran_tail_markings
	feature_key = FEATURE_TAJARAN_TAIL_MARKINGS

/datum/dna_block/feature/tajaran_tail_markings/create_unique_block(mob/living/carbon/human/target)
	return construct_block(SSaccessories.tajaran_tail_markings_list.Find(target.dna.features[feature_key]), length(SSaccessories.tajaran_tail_markings_list))

/datum/dna_block/feature/tajaran_tail_markings/apply_to_mob(mob/living/carbon/human/target, dna_hash)
	target.dna.features[feature_key] = SSaccessories.tajaran_tail_markings_list[deconstruct_block(get_block(dna_hash), length(SSaccessories.tajaran_tail_markings_list))]

/datum/dna_block/feature/tajaran_facial_hair
	feature_key = FEATURE_TAJARAN_FACIAL_HAIR

/datum/dna_block/feature/tajaran_facial_hair/create_unique_block(mob/living/carbon/human/target)
	return construct_block(SSaccessories.tajaran_facial_hair_list.Find(target.dna.features[feature_key]), length(SSaccessories.tajaran_facial_hair_list))

/datum/dna_block/feature/tajaran_facial_hair/apply_to_mob(mob/living/carbon/human/target, dna_hash)
	target.dna.features[feature_key] = SSaccessories.tajaran_facial_hair_list[deconstruct_block(get_block(dna_hash), length(SSaccessories.tajaran_facial_hair_list))]

/datum/dna_block/feature/tajaran_body_markings_color
	block_length = DNA_BLOCK_SIZE_COLOR
	feature_key = FEATURE_TAJARAN_BODY_MARKINGS_COLOR

/datum/dna_block/feature/tajaran_body_markings_color/create_unique_block(mob/living/carbon/human/target)
	return sanitize_hexcolor(target.dna.features[feature_key], include_crunch = FALSE)

/datum/dna_block/feature/tajaran_body_markings_color/apply_to_mob(mob/living/carbon/human/target, dna_hash)
	target.dna.features[feature_key] = sanitize_hexcolor(get_block(dna_hash))

/datum/dna_block/feature/tajaran_head_markings_color
	block_length = DNA_BLOCK_SIZE_COLOR
	feature_key = FEATURE_TAJARAN_HEAD_MARKINGS_COLOR

/datum/dna_block/feature/tajaran_head_markings_color/create_unique_block(mob/living/carbon/human/target)
	return sanitize_hexcolor(target.dna.features[feature_key], include_crunch = FALSE)

/datum/dna_block/feature/tajaran_head_markings_color/apply_to_mob(mob/living/carbon/human/target, dna_hash)
	target.dna.features[feature_key] = sanitize_hexcolor(get_block(dna_hash))

/datum/dna_block/feature/tajaran_tail_markings_color
	block_length = DNA_BLOCK_SIZE_COLOR
	feature_key = FEATURE_TAJARAN_TAIL_MARKINGS_COLOR

/datum/dna_block/feature/tajaran_tail_markings_color/create_unique_block(mob/living/carbon/human/target)
	return sanitize_hexcolor(target.dna.features[feature_key], include_crunch = FALSE)

/datum/dna_block/feature/tajaran_tail_markings_color/apply_to_mob(mob/living/carbon/human/target, dna_hash)
	target.dna.features[feature_key] = sanitize_hexcolor(get_block(dna_hash))

/datum/dna_block/feature/tajaran_facial_hair_color
	block_length = DNA_BLOCK_SIZE_COLOR
	feature_key = FEATURE_TAJARAN_FACIAL_HAIR_COLOR

/datum/dna_block/feature/tajaran_facial_hair_color/create_unique_block(mob/living/carbon/human/target)
	return sanitize_hexcolor(target.dna.features[feature_key], include_crunch = FALSE)

/datum/dna_block/feature/tajaran_facial_hair_color/apply_to_mob(mob/living/carbon/human/target, dna_hash)
	target.dna.features[feature_key] = sanitize_hexcolor(get_block(dna_hash))

// MARK: Skrell
/datum/dna_block/feature/skrell_head_tentacle
	feature_key = FEATURE_SKRELL_HEAD_TENTACLE

/datum/dna_block/feature/skrell_head_tentacle/create_unique_block(mob/living/carbon/human/target)
	return construct_block(SSaccessories.skrell_head_tentacles_list.Find(target.dna.features[feature_key]), length(SSaccessories.skrell_head_tentacles_list))

/datum/dna_block/feature/skrell_head_tentacle/apply_to_mob(mob/living/carbon/human/target, dna_hash)
	target.dna.features[feature_key] = SSaccessories.skrell_head_tentacles_list[deconstruct_block(get_block(dna_hash), length(SSaccessories.skrell_head_tentacles_list))]

// BANDASTATION ADD END - Species
