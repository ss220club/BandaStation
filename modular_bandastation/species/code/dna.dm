/datum/dna/generate_unique_features()
	. = ..()
	var/list/L = new /list(DNA_MODULAR_BLOCKS_COUNT)
	// vulpkanin
	if(features["vulpkanin_body_markings"])
		L[DNA_VULPKANIN_BODY_MARKINGS - DNA_FEATURE_BLOCKS] = construct_block(SSaccessories.vulpkanin_body_markings_list.Find(features["vulpkanin_body_markings"]), SSaccessories.vulpkanin_body_markings_list.len)
	if(features["vulpkanin_head_markings"])
		L[DNA_VULPKANIN_HEAD_MARKINGS - DNA_FEATURE_BLOCKS] = construct_block(SSaccessories.vulpkanin_head_markings_list.Find(features["vulpkanin_head_markings"]), SSaccessories.vulpkanin_head_markings_list.len)
	if(features["tail_vulpkanin"])
		L[DNA_VULPKANIN_TAIL - DNA_FEATURE_BLOCKS] = construct_block(SSaccessories.tails_list_vulpkanin.Find(features["tail_vulpkanin"]), SSaccessories.tails_list_vulpkanin.len)
	if(features["tail_markings"])
		L[DNA_VULPKANIN_TAIL_MARKINGS - DNA_FEATURE_BLOCKS] = construct_block(SSaccessories.vulpkanin_tail_markings_list.Find(features["tail_markings"]), SSaccessories.vulpkanin_tail_markings_list.len)
	if(features["vulpkanin_facial_hair"])
		L[DNA_VULPKANIN_FACIAL_HAIR - DNA_FEATURE_BLOCKS] = construct_block(SSaccessories.vulpkanin_facial_hair_list.Find(features["vulpkanin_facial_hair"]), SSaccessories.vulpkanin_facial_hair_list.len)
	// tajaran
	if(features["tajaran_body_markings"])
		L[DNA_TAJARAN_BODY_MARKINGS - DNA_FEATURE_BLOCKS] = construct_block(SSaccessories.tajaran_body_markings_list.Find(features["tajaran_body_markings"]), SSaccessories.tajaran_body_markings_list.len)
	if(features["tajaran_head_markings"])
		L[DNA_TAJARAN_HEAD_MARKINGS - DNA_FEATURE_BLOCKS] = construct_block(SSaccessories.tajaran_head_markings_list.Find(features["tajaran_head_markings"]), SSaccessories.tajaran_head_markings_list.len)
	if(features["tail_tajaran"])
		L[DNA_TAJARAN_TAIL - DNA_FEATURE_BLOCKS] = construct_block(SSaccessories.tails_list_tajaran.Find(features["tail_tajaran"]), SSaccessories.tails_list_tajaran.len)
	if(features["tajaran_tail_markings"])
		L[DNA_TAJARAN_TAIL_MARKINGS - DNA_FEATURE_BLOCKS] = construct_block(SSaccessories.tajaran_tail_markings_list.Find(features["tajaran_tail_markings"]), SSaccessories.tajaran_tail_markings_list.len)
	if(features["tajaran_facial_hair"])
		L[DNA_TAJARAN_FACIAL_HAIR - DNA_FEATURE_BLOCKS] = construct_block(SSaccessories.tajaran_facial_hair_list.Find(features["tajaran_facial_hair"]), SSaccessories.tajaran_facial_hair_list.len)

	// vulpkanin
	if(features["vulpkanin_body_markings_color"])
		L[DNA_VULPKANIN_BODY_MARKINGS_COLOR - DNA_FEATURE_BLOCKS] = sanitize_hexcolor(features["vulpkanin_body_markings_color"], include_crunch = FALSE)
	if(features["vulpkanin_tail_markings_color"])
		L[DNA_VULPKANIN_TAIL_MARKINGS_COLOR - DNA_FEATURE_BLOCKS] = sanitize_hexcolor(features["vulpkanin_tail_markings_color"], include_crunch = FALSE)
	if(features["vulpkanin_head_markings_color"])
		L[DNA_VULPKANIN_HEAD_MARKINGS_COLOR - DNA_FEATURE_BLOCKS] = sanitize_hexcolor(features["vulpkanin_head_markings_color"], include_crunch = FALSE)
	if(features["vulpkanin_facial_hair_color"])
		L[DNA_VULPKANIN_FACIAL_HAIR_COLOR - DNA_FEATURE_BLOCKS] = sanitize_hexcolor(features["vulpkanin_facial_hair_color"], include_crunch = FALSE)
	// tajaran
	if(features["tajaran_body_markings_color"])
		L[DNA_TAJARAN_BODY_MARKINGS_COLOR - DNA_FEATURE_BLOCKS] = sanitize_hexcolor(features["tajaran_body_markings_color"], include_crunch = FALSE)
	if(features["tajaran_head_markings_color"])
		L[DNA_TAJARAN_HEAD_MARKINGS_COLOR - DNA_FEATURE_BLOCKS] = sanitize_hexcolor(features["tajaran_head_markings_color"], include_crunch = FALSE)
	if(features["tajaran_tail_markings_color"])
		L[DNA_TAJARAN_TAIL_MARKINGS_COLOR - DNA_FEATURE_BLOCKS] = sanitize_hexcolor(features["tajaran_tail_markings_color"], include_crunch = FALSE)
	if(features["tajaran_facial_hair_color"])
		L[DNA_TAJARAN_FACIAL_HAIR_COLOR - DNA_FEATURE_BLOCKS] = sanitize_hexcolor(features["tajaran_facial_hair_color"], include_crunch = FALSE)

	for(var/blocknum in 1 to DNA_MODULAR_BLOCKS_COUNT)
		. += L[blocknum] || random_string(GET_UI_BLOCK_LEN(blocknum), GLOB.hex_characters)

/datum/dna/update_uf_block(blocknumber)
	. = ..()
	switch(blocknumber)
		// vulpkanin
		if(DNA_VULPKANIN_BODY_MARKINGS)
			set_uni_feature_block(blocknumber, construct_block(SSaccessories.vulpkanin_body_markings_list.Find(features["vulpkanin_body_markings"]), SSaccessories.vulpkanin_body_markings_list.len))
		if(DNA_VULPKANIN_HEAD_MARKINGS)
			set_uni_feature_block(blocknumber, construct_block(SSaccessories.vulpkanin_head_markings_list.Find(features["vulpkanin_head_markings"]), SSaccessories.vulpkanin_head_markings_list.len))
		if(DNA_VULPKANIN_TAIL)
			set_uni_feature_block(blocknumber, construct_block(SSaccessories.tails_list_vulpkanin.Find(features["tail_vulpkanin"]), SSaccessories.tails_list_vulpkanin.len))
		if(DNA_VULPKANIN_TAIL_MARKINGS)
			set_uni_feature_block(blocknumber, construct_block(SSaccessories.vulpkanin_tail_markings_list.Find(features["tail_markings"]), SSaccessories.vulpkanin_tail_markings_list.len))
		if(DNA_VULPKANIN_FACIAL_HAIR)
			set_uni_feature_block(blocknumber, construct_block(SSaccessories.vulpkanin_facial_hair_list.Find(features["vulpkanin_facial_hair"]), SSaccessories.vulpkanin_facial_hair_list.len))
		// tajaran
		if(DNA_TAJARAN_BODY_MARKINGS)
			set_uni_feature_block(blocknumber, construct_block(SSaccessories.tajaran_body_markings_list.Find(features["tajaran_body_markings"]), SSaccessories.tajaran_body_markings_list.len))
		if(DNA_TAJARAN_HEAD_MARKINGS)
			set_uni_feature_block(blocknumber, construct_block(SSaccessories.tajaran_head_markings_list.Find(features["tajaran_head_markings"]), SSaccessories.tajaran_head_markings_list.len))
		if(DNA_TAJARAN_TAIL)
			set_uni_feature_block(blocknumber, construct_block(SSaccessories.tails_list_tajaran.Find(features["tail_tajaran"]), SSaccessories.tails_list_tajaran.len))
		if(DNA_TAJARAN_TAIL_MARKINGS)
			set_uni_feature_block(blocknumber, construct_block(SSaccessories.tajaran_tail_markings_list.Find(features["tajaran_tail_markings"]), SSaccessories.tajaran_tail_markings_list.len))
		if(DNA_TAJARAN_FACIAL_HAIR)
			set_uni_feature_block(blocknumber, construct_block(SSaccessories.tajaran_facial_hair_list.Find(features["tajaran_facial_hair"]), SSaccessories.tajaran_facial_hair_list.len))
		// vulpkanin
		if(DNA_VULPKANIN_BODY_MARKINGS_COLOR)
			set_uni_feature_block(blocknumber, sanitize_hexcolor(features["vulpkanin_body_markings_color"], include_crunch = FALSE))
		if(DNA_VULPKANIN_TAIL_MARKINGS_COLOR)
			set_uni_feature_block(blocknumber, sanitize_hexcolor(features["vulpkanin_tail_markings_color"], include_crunch = FALSE))
		if(DNA_VULPKANIN_HEAD_MARKINGS_COLOR)
			set_uni_feature_block(blocknumber, sanitize_hexcolor(features["vulpkanin_head_markings_color"], include_crunch = FALSE))
		if(DNA_VULPKANIN_FACIAL_HAIR_COLOR)
			set_uni_feature_block(blocknumber, sanitize_hexcolor(features["vulpkanin_facial_hair_color"], include_crunch = FALSE))
		// tajaran
		if(DNA_TAJARAN_BODY_MARKINGS_COLOR)
			set_uni_feature_block(blocknumber, sanitize_hexcolor(features["tajaran_body_markings_color"], include_crunch = FALSE))
		if(DNA_TAJARAN_HEAD_MARKINGS_COLOR)
			set_uni_feature_block(blocknumber, sanitize_hexcolor(features["tajaran_head_markings_color"], include_crunch = FALSE))
		if(DNA_TAJARAN_TAIL_MARKINGS_COLOR)
			set_uni_feature_block(blocknumber, sanitize_hexcolor(features["tajaran_tail_markings_color"], include_crunch = FALSE))
		if(DNA_TAJARAN_FACIAL_HAIR_COLOR)
			set_uni_feature_block(blocknumber, sanitize_hexcolor(features["tajaran_facial_hair_color"], include_crunch = FALSE))

/mob/living/carbon/human/updateappearance(icon_update = TRUE, mutcolor_update = FALSE, mutations_overlay_update = FALSE)
	. = ..()
	var/features = dna.unique_features
	// vulpkanin
	if(dna.features["vulpkanin_body_markings"])
		dna.features["vulpkanin_body_markings"] = SSaccessories.vulpkanin_body_markings_list[deconstruct_block(get_uni_feature_block(features, DNA_VULPKANIN_BODY_MARKINGS), SSaccessories.vulpkanin_body_markings_list.len)]
	if(dna.features["vulpkanin_head_markings"])
		dna.features["vulpkanin_head_markings"] = SSaccessories.vulpkanin_head_markings_list[deconstruct_block(get_uni_feature_block(features, DNA_VULPKANIN_HEAD_MARKINGS), SSaccessories.vulpkanin_head_markings_list.len)]
	if(dna.features["tail_vulpkanin"])
		dna.features["tail_vulpkanin"] = SSaccessories.tails_list_vulpkanin[deconstruct_block(get_uni_feature_block(features, DNA_VULPKANIN_TAIL), SSaccessories.tails_list_vulpkanin.len)]
		var/obj/item/organ/tail/vulpkanin/tail = organs_slot[ORGAN_SLOT_EXTERNAL_TAIL]
		if (tail && tail.type == /obj/item/organ/tail/vulpkanin)
			tail.Remove(src)
			tail.Insert(src, special=TRUE, movement_flags = DELETE_IF_REPLACED)
	if(dna.features["tail_markings"])
		dna.features["tail_markings"] = SSaccessories.vulpkanin_tail_markings_list[deconstruct_block(get_uni_feature_block(features, DNA_VULPKANIN_TAIL_MARKINGS), SSaccessories.vulpkanin_tail_markings_list.len)]
		var/obj/item/organ/tail/vulpkanin/tail = organs_slot[ORGAN_SLOT_EXTERNAL_TAIL]
		if (tail && tail.type == /obj/item/organ/tail/vulpkanin)
			tail.Remove(src)
			tail.Insert(src, special=TRUE, movement_flags = DELETE_IF_REPLACED)
	if(dna.features["vulpkanin_facial_hair"])
		dna.features["vulpkanin_facial_hair"] = SSaccessories.vulpkanin_facial_hair_list[deconstruct_block(get_uni_feature_block(features, DNA_VULPKANIN_FACIAL_HAIR), SSaccessories.vulpkanin_facial_hair_list.len)]
	// tajaran
	if(dna.features["tajaran_body_markings"])
		dna.features["tajaran_body_markings"] = SSaccessories.tajaran_body_markings_list[deconstruct_block(get_uni_feature_block(features, DNA_TAJARAN_BODY_MARKINGS), SSaccessories.tajaran_body_markings_list.len)]
	if(dna.features["tajaran_head_markings"])
		dna.features["tajaran_head_markings"] = SSaccessories.tajaran_head_markings_list[deconstruct_block(get_uni_feature_block(features, DNA_TAJARAN_HEAD_MARKINGS), SSaccessories.tajaran_head_markings_list.len)]
	if(dna.features["tail_tajaran"])
		dna.features["tail_tajaran"] = SSaccessories.tails_list_tajaran[deconstruct_block(get_uni_feature_block(features, DNA_TAJARAN_TAIL), SSaccessories.tails_list_tajaran.len)]
		var/obj/item/organ/tail/tajaran/tail = organs_slot[ORGAN_SLOT_EXTERNAL_TAIL]
		if (tail && tail.type == /obj/item/organ/tail/tajaran)
			tail.Remove(src)
			tail.Insert(src, special=TRUE, movement_flags = DELETE_IF_REPLACED)
	if(dna.features["tajaran_tail_markings"])
		dna.features["tajaran_tail_markings"] = SSaccessories.tajaran_tail_markings_list[deconstruct_block(get_uni_feature_block(features, DNA_TAJARAN_TAIL_MARKINGS), SSaccessories.tajaran_tail_markings_list.len)]
		var/obj/item/organ/tail/tajaran/tail = organs_slot[ORGAN_SLOT_EXTERNAL_TAIL]
		if (tail && tail.type == /obj/item/organ/tail/tajaran)
			tail.Remove(src)
			tail.Insert(src, special=TRUE, movement_flags = DELETE_IF_REPLACED)
	if(dna.features["tajaran_facial_hair"])
		dna.features["tajaran_facial_hair"] = SSaccessories.tajaran_facial_hair_list[deconstruct_block(get_uni_feature_block(features, DNA_TAJARAN_FACIAL_HAIR), SSaccessories.tajaran_facial_hair_list.len)]
	// vulpkanin
	if(dna.features["vulpkanin_body_markings_color"])
		dna.features["vulpkanin_body_markings_color"] = sanitize_hexcolor(get_uni_feature_block(features, DNA_VULPKANIN_BODY_MARKINGS_COLOR))
	if(dna.features["vulpkanin_tail_markings_color"])
		dna.features["vulpkanin_tail_markings_color"] = sanitize_hexcolor(get_uni_feature_block(features, DNA_VULPKANIN_TAIL_MARKINGS_COLOR))
	if(dna.features["vulpkanin_head_markings_color"])
		dna.features["vulpkanin_head_markings_color"] = sanitize_hexcolor(get_uni_feature_block(features, DNA_VULPKANIN_HEAD_MARKINGS_COLOR))
	if(dna.features["vulpkanin_facial_hair_color"])
		dna.features["vulpkanin_facial_hair_color"] = sanitize_hexcolor(get_uni_feature_block(features, DNA_VULPKANIN_FACIAL_HAIR_COLOR))
	// tajaran
	if(dna.features["tajaran_body_markings_color"])
		dna.features["tajaran_body_markings_color"] = sanitize_hexcolor(get_uni_feature_block(features, DNA_TAJARAN_BODY_MARKINGS_COLOR))
	if(dna.features["tajaran_head_markings_color"])
		dna.features["tajaran_head_markings_color"] = sanitize_hexcolor(get_uni_feature_block(features, DNA_TAJARAN_HEAD_MARKINGS_COLOR))
	if(dna.features["tajaran_tail_markings_color"])
		dna.features["tajaran_tail_markings_color"] = sanitize_hexcolor(get_uni_feature_block(features, DNA_TAJARAN_TAIL_MARKINGS_COLOR))
	if(dna.features["tajaran_facial_hair_color"])
		dna.features["tajaran_facial_hair_color"] = sanitize_hexcolor(get_uni_feature_block(features, DNA_TAJARAN_FACIAL_HAIR_COLOR))

/proc/populate_total_uf_len_by_block_modular(last)
	. = list()
	var/total_block_len = last
	for(var/blocknumber in 1 to DNA_MODULAR_BLOCKS_COUNT + 1)
		total_block_len += GET_UF_BLOCK_LEN(blocknumber + DNA_FEATURE_BLOCKS - 1)
		. += total_block_len

// vulpkanin
/mob/living/carbon/human/species/vulpkanin/random_mutate_unique_features()
	if(!has_dna())
		CRASH("[src] does not have DNA")
	var/num = rand(1, DNA_FEATURE_BLOCKS + DNA_MODULAR_BLOCKS_COUNT)
	dna.set_uni_feature_block(num, random_string(GET_UF_BLOCK_LEN(num), GLOB.hex_characters))
	updateappearance(mutcolor_update = TRUE, mutations_overlay_update = TRUE)

// tajaran
/mob/living/carbon/human/species/tajaran/random_mutate_unique_features()
	if(!has_dna())
		CRASH("[src] does not have DNA")
	var/num = rand(1, DNA_FEATURE_BLOCKS + DNA_MODULAR_BLOCKS_COUNT)
	dna.set_uni_feature_block(num, random_string(GET_UF_BLOCK_LEN(num), GLOB.hex_characters))
	updateappearance(mutcolor_update = TRUE, mutations_overlay_update = TRUE)

/datum/modpack/species/modular/post_initialize()
	GLOB.features_block_lengths += list(
		"[DNA_VULPKANIN_BODY_MARKINGS_COLOR]" = DNA_BLOCK_SIZE_COLOR,
		"[DNA_VULPKANIN_TAIL_MARKINGS_COLOR]" = DNA_BLOCK_SIZE_COLOR,
		"[DNA_VULPKANIN_HEAD_MARKINGS_COLOR]" = DNA_BLOCK_SIZE_COLOR,
		"[DNA_VULPKANIN_FACIAL_HAIR_COLOR]" = DNA_BLOCK_SIZE_COLOR,
		"[DNA_TAJARAN_BODY_MARKINGS_COLOR]" = DNA_BLOCK_SIZE_COLOR,
		"[DNA_TAJARAN_HEAD_MARKINGS_COLOR]" = DNA_BLOCK_SIZE_COLOR,
		"[DNA_TAJARAN_TAIL_MARKINGS_COLOR]" = DNA_BLOCK_SIZE_COLOR,
		"[DNA_TAJARAN_FACIAL_HAIR_COLOR]" = DNA_BLOCK_SIZE_COLOR,
	)
	GLOB.total_uf_len_by_block += populate_total_uf_len_by_block_modular(GLOB.total_uf_len_by_block[DNA_FEATURE_BLOCKS])
