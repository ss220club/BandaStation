/// Every selectable accessory and both squashed/free leg states need real sprites.
/datum/unit_test/vox_appearance_assets/Run()
	var/list/body_states = icon_states('icons/bandastation/mob/species/vox/bodyparts.dmi')
	for(var/part in list("head", "chest", "l_arm", "r_arm", "l_hand", "r_hand", "l_leg", "r_leg"))
		TEST_ASSERT("vox_[part]" in body_states, "Vox body is missing [part].")
	for(var/side in list("l", "r"))
		TEST_ASSERT("digitigrade_[side]_leg" in body_states, "Vox body is missing a free digitigrade leg.")

	for(var/feature in list(FEATURE_VOX_SNOUT, FEATURE_VOX_QUILLS, FEATURE_VOX_FACIAL_QUILLS, FEATURE_VOX_TAIL))
		var/list/accessories = SSaccessories.feature_list[feature]
		TEST_ASSERT(length(accessories), "Vox feature [feature] has no choices.")
		for(var/name in accessories)
			var/datum/sprite_accessory/accessory = accessories[name]
			if(accessory.icon_state == SPRITE_ACCESSORY_NONE)
				continue
			var/list/layers = feature == FEATURE_VOX_TAIL ? list(EXTERNAL_FRONT, EXTERNAL_BEHIND) : list(EXTERNAL_ADJACENT)
			for(var/layer in layers)
				TEST_ASSERT(icon_exists(accessory.icon, "m_[feature]_[accessory.icon_state]_[layer]"), "Vox accessory [name] has no [layer] sprite.")

	for(var/name in SSaccessories.feature_list[FEATURE_VOX_BODY_MARKINGS])
		var/datum/sprite_accessory/accessory = SSaccessories.feature_list[FEATURE_VOX_BODY_MARKINGS][name]
		if(accessory.icon_state != SPRITE_ACCESSORY_NONE)
			TEST_ASSERT(icon_exists(accessory.icon, "[accessory.icon_state]_chest"), "Vox chest marking [name] has no sprite.")

	var/mob/living/carbon/human/dummy/consistent/vox = allocate(/mob/living/carbon/human/dummy/consistent)
	vox.set_species(/datum/species/vox)
	for(var/obj/item/organ/organ as anything in vox.organs)
		if(istype(organ.bodypart_overlay, /datum/bodypart_overlay/mutant))
			var/datum/bodypart_overlay/mutant/overlay = organ.bodypart_overlay
			TEST_ASSERT_NOTNULL(overlay.sprite_datum, "Vox default external organ has no accessory.")

/// DNA modification/cloning must preserve independently chosen markings and colours.
/datum/unit_test/vox_appearance_dna/Run()
	var/mob/living/carbon/human/consistent/vox = allocate(/mob/living/carbon/human/consistent)
	vox.set_species(/datum/species/vox)
	var/list/expected = list(
		FEATURE_VOX_SNOUT = /datum/sprite_accessory/vox_snout/primalis::name,
		FEATURE_VOX_QUILLS = /datum/sprite_accessory/vox_quills/kingly::name,
		FEATURE_VOX_FACIAL_QUILLS = /datum/sprite_accessory/vox_facial_quills/beard::name,
		FEATURE_VOX_BODY_MARKINGS = /datum/sprite_accessory/vox_body_markings/leader::name,
		FEATURE_VOX_SNOUT_COLOR = "#123456",
		FEATURE_VOX_QUILLS_COLOR = "#234567",
		FEATURE_VOX_FACIAL_QUILLS_COLOR = "#345678",
		FEATURE_VOX_LIMB_MARKINGS_COLOR = "#456789",
		FEATURE_VOX_BODY_MARKINGS_COLOR = "#56789a",
	)
	for(var/feature in expected)
		vox.dna.features[feature] = expected[feature]
	vox.dna.unique_features = vox.dna.generate_unique_features()
	var/expected_length = 0
	for(var/block_type in GLOB.dna_feature_blocks)
		var/datum/dna_block/feature/block = GLOB.dna_feature_blocks[block_type]
		expected_length += block.block_length
	TEST_ASSERT_EQUAL(length(vox.dna.unique_features), expected_length, "Vox DNA lost a block and shifted subsequent features.")
	for(var/block_type in GLOB.dna_feature_blocks)
		var/datum/dna_block/feature/block = GLOB.dna_feature_blocks[block_type]
		if(!(block.feature_key in expected))
			continue
		vox.dna.features[block.feature_key] = null
		block.apply_to_mob(vox, vox.dna.unique_features)
	for(var/feature in expected)
		TEST_ASSERT_EQUAL(vox.dna.features[feature], expected[feature], "Vox DNA changed [feature] during a round trip.")

/// Exercise actual item states, including GAGS colours, adjusted uniforms and MOD parts.
/datum/unit_test/vox_clothing_icons/Run()
	var/list/fitted_items = list(
		/obj/item/clothing/head/utility/hardhat,
		/obj/item/clothing/head/utility/hardhat/white,
		/obj/item/clothing/head/utility/chefhat,
		/obj/item/clothing/head/utility/surgerycap,
		/obj/item/clothing/head/utility/surgerycap/green,
		/obj/item/clothing/head/utility/surgerycap/purple,
		/obj/item/clothing/head/helmet,
		/obj/item/clothing/head/helmet/toggleable/riot,
		/obj/item/clothing/head/beret,
		/obj/item/clothing/head/beret/sec,
		/obj/item/clothing/mask/breath,
		/obj/item/clothing/mask/breath/vox,
		/obj/item/clothing/mask/gas,
		/obj/item/clothing/mask/bandana,
		/obj/item/clothing/mask/bandana/striped,
		/obj/item/clothing/mask/bandana/skull,
		/obj/item/clothing/glasses/regular,
		/obj/item/clothing/glasses/regular/hipster,
		/obj/item/clothing/glasses/hud/security,
		/obj/item/clothing/glasses/hud/health,
		/obj/item/clothing/gloves/color/black,
		/obj/item/clothing/shoes/sneakers/black,
		/obj/item/clothing/shoes/wheelys,
		/obj/item/clothing/shoes/wheelys/rollerskates,
		/obj/item/clothing/shoes/wheelys/skishoes,
		/obj/item/clothing/under/color/grey,
		/obj/item/clothing/under/color/jumpskirt/grey,
		/obj/item/clothing/under/rank/engineering/engineer,
		/obj/item/clothing/under/rank/medical/doctor,
		/obj/item/clothing/under/rank/security/officer,
		/obj/item/clothing/head/mod,
		/obj/item/clothing/suit/mod,
		/obj/item/clothing/gloves/mod,
		/obj/item/clothing/shoes/mod,
		/obj/item/clothing/head/helmet/space/eva,
		/obj/item/clothing/suit/space/eva,
	)
	for(var/item_type in fitted_items)
		var/obj/item/item = allocate(item_type)
		TEST_ASSERT_NOTNULL(item.get_species_worn_icon(SPECIES_VOX), "[item_type] has no fitted vox worn sprite for [item.worn_icon_state || item.icon_state].")
		TEST_ASSERT_NULL(item.get_species_worn_icon(SPECIES_VOX, "vox_deliberately_missing_state"), "[item_type] selected an invisible missing sprite.")
		TEST_ASSERT_NULL(item.get_species_worn_icon(SPECIES_IPC), "Vox clothing overrides leaked onto IPCs.")

	var/obj/item/clothing/under/color/grey/uniform = allocate(/obj/item/clothing/under/color/grey)
	TEST_ASSERT_EQUAL(uniform.get_species_worn_icon(SPECIES_VOX), SSgreyscale.GetColoredIconByType(/datum/greyscale_config/jumpsuit/worn/vox, uniform.greyscale_colors), "Vox jumpsuit lost its chosen GAGS colour.")
	TEST_ASSERT_NOTNULL(uniform.get_species_worn_icon(SPECIES_VOX, "jumpsuit_d"), "Rolled vox jumpsuit has no fitted sprite.")
	var/obj/item/clothing/head/helmet/helmet = allocate(/obj/item/clothing/head/helmet)
	TEST_ASSERT_EQUAL(helmet.get_species_worn_icon(SPECIES_VOX), 'icons/bandastation/mob/species/vox/clothing/helmet.dmi', "Vox helmet selected a partial cosmetic head overlay.")
	TEST_ASSERT_NOTNULL(helmet.worn_icon_species[SPECIES_SKRELL], "Vox helmet overrides removed the existing Skrell mapping.")
	var/obj/item/clothing/shoes/wheelys/skates = allocate(/obj/item/clothing/shoes/wheelys/rollerskates)
	TEST_ASSERT_EQUAL(skates.get_species_worn_icon(SPECIES_VOX), 'icons/bandastation/mob/species/vox/clothing/feet_64.dmi', "Large vox shoes selected a 32px sprite and lost their anchor.")

/datum/unit_test/vox_appearance_screenshots/Run()
	var/mob/living/carbon/human/dummy/consistent/naked = make_vox()
	test_screenshot("naked", get_flat_icon_for_all_directions(naked))

	var/mob/living/carbon/human/dummy/consistent/assistant = make_vox()
	assistant.equipOutfit(/datum/outfit/job/assistant/consistent, visuals_only = TRUE)
	test_screenshot("assistant", get_flat_icon_for_all_directions(assistant))
	var/obj/item/clothing/under/uniform = assistant.w_uniform
	uniform.adjusted = ALT_STYLE
	assistant.update_worn_undersuit()
	test_screenshot("assistant_rolled", get_flat_icon_for_all_directions(assistant))

	var/list/looks = list(
		"engineer" = list(/obj/item/clothing/under/rank/engineering/engineer, /obj/item/clothing/head/utility/hardhat, /obj/item/clothing/glasses/meson, /obj/item/clothing/mask/breath/vox),
		"security" = list(/obj/item/clothing/under/rank/security/officer, /obj/item/clothing/head/helmet, /obj/item/clothing/glasses/hud/security, /obj/item/clothing/mask/gas),
		"doctor" = list(/obj/item/clothing/under/rank/medical/doctor, /obj/item/clothing/head/beret/medical, /obj/item/clothing/glasses/hud/health, /obj/item/clothing/mask/breath/medical),
		"riot" = list(/obj/item/clothing/under/rank/security/officer, /obj/item/clothing/head/helmet/toggleable/riot, /obj/item/clothing/glasses/hud/security, /obj/item/clothing/mask/gas),
	)
	for(var/look in looks)
		var/mob/living/carbon/human/dummy/consistent/vox = make_vox()
		var/list/item_types = looks[look]
		var/list/slots = list(ITEM_SLOT_ICLOTHING, ITEM_SLOT_HEAD, ITEM_SLOT_EYES, ITEM_SLOT_MASK)
		for(var/index in 1 to length(item_types))
			var/obj/item/item = allocate(item_types[index])
			TEST_ASSERT(vox.equip_to_slot_if_possible(item, slots[index], disable_warning = TRUE), "Could not equip [look] fixture [item.type].")
		var/obj/item/shoes = allocate(/obj/item/clothing/shoes/jackboots)
		vox.equip_to_slot_if_possible(shoes, ITEM_SLOT_FEET, disable_warning = TRUE)
		test_screenshot(look, get_flat_icon_for_all_directions(vox))

	var/mob/living/carbon/human/dummy/consistent/eva = make_vox()
	var/obj/item/eva_helmet = allocate(/obj/item/clothing/head/helmet/space/eva)
	var/obj/item/eva_suit = allocate(/obj/item/clothing/suit/space/eva)
	eva.equip_to_slot_if_possible(eva_helmet, ITEM_SLOT_HEAD, disable_warning = TRUE)
	eva.equip_to_slot_if_possible(eva_suit, ITEM_SLOT_OCLOTHING, disable_warning = TRUE)
	test_screenshot("eva", get_flat_icon_for_all_directions(eva))

	var/mob/living/carbon/human/dummy/consistent/mod_wearer = make_vox()
	var/obj/item/cap = allocate(/obj/item/clothing/head/soft/red)
	mod_wearer.equip_to_slot_if_possible(cap, ITEM_SLOT_HEAD, disable_warning = TRUE)
	var/obj/item/mod/control/pre_equipped/standard/mod = allocate(/obj/item/mod/control/pre_equipped/standard)
	TEST_ASSERT(mod_wearer.equip_to_slot_if_possible(mod, ITEM_SLOT_BACK, disable_warning = TRUE), "Could not equip vox MOD fixture.")
	mod.quick_deploy(mod_wearer)
	test_screenshot("mod_deployed", get_flat_icon_for_all_directions(mod_wearer))
	mod.quick_deploy(mod_wearer)
	mod.quick_activation()
	TEST_ASSERT(mod.active, "MOD screenshot fixture did not activate.")
	var/datum/mod_part/sealed_helmet = mod.get_part_datum(mod_wearer.head)
	TEST_ASSERT(sealed_helmet?.sealed, "MOD screenshot fixture did not seal its helmet.")
	test_screenshot("mod_sealed", get_flat_icon_for_all_directions(mod_wearer))

	var/mob/living/carbon/human/dummy/consistent/human = allocate(/mob/living/carbon/human/dummy/consistent)
	var/mob/living/carbon/human/dummy/consistent/donor = make_vox()
	var/obj/item/bodypart/head/transplant = donor.get_bodypart(BODY_ZONE_HEAD)
	transplant.drop_limb(special = TRUE)
	var/obj/item/bodypart/head/old_head = human.get_bodypart(BODY_ZONE_HEAD)
	TEST_ASSERT(transplant.replace_limb(human), "Could not transplant a vox head for the MOD fitting test.")
	qdel(old_head)
	var/obj/item/clothing/head/soft/transplant_hat = allocate(/obj/item/clothing/head/soft/red)
	human.equip_to_slot_if_possible(transplant_hat, ITEM_SLOT_HEAD, disable_warning = TRUE)
	var/obj/item/mod/control/pre_equipped/standard/transplant_mod = allocate(/obj/item/mod/control/pre_equipped/standard)
	human.equip_to_slot_if_possible(transplant_mod, ITEM_SLOT_BACK, disable_warning = TRUE)
	transplant_mod.quick_deploy(human)
	var/datum/mod_part/open_helmet = transplant_mod.get_part_datum(human.head)
	TEST_ASSERT_EQUAL(open_helmet.overslotting, transplant_hat, "Transplanted-head fixture did not overslot the cap.")
	var/list/rendered_overlays = list()
	var/mutable_appearance/standing = mutable_appearance(human.head.worn_icon, human.head.icon_state)
	open_helmet.get_separate_worn_overlays(human.head, rendered_overlays, standing, standing, FALSE, human.head.worn_icon, human.bodyshape)
	TEST_ASSERT(length(rendered_overlays), "The overslotted cap was not rendered.")
	var/mutable_appearance/hat_overlay = rendered_overlays[1]
	TEST_ASSERT_EQUAL(hat_overlay.icon, transplant_hat.get_species_worn_icon(SPECIES_VOX), "Open MOD helmet used human hat art on a transplanted vox head.")
	test_screenshot("transplanted_mod_head", get_flat_icon_for_all_directions(human))

	var/list/quill_choices = list("Short quills", "Kingly", "Whip", "Kingly dreads")
	for(var/hat in list("naked", "hardhat", "beret"))
		var/icon/catalogue = icon('icons/effects/effects.dmi', "nothing")
		for(var/index in 1 to length(quill_choices))
			var/mob/living/carbon/human/dummy/consistent/vox = make_vox()
			var/obj/item/organ/quills/vox/quills = vox.get_organ_slot(ORGAN_SLOT_EXTERNAL_VOX_QUILLS)
			var/datum/bodypart_overlay/mutant/quill_overlay = quills.bodypart_overlay
			quill_overlay.set_appearance_from_name(quill_choices[index])
			vox.update_body_parts()
			if(hat != "naked")
				var/hat_type = hat == "hardhat" ? /obj/item/clothing/head/utility/hardhat : /obj/item/clothing/head/beret
				var/obj/item/headgear = allocate(hat_type)
				vox.equip_to_slot_if_possible(headgear, ITEM_SLOT_HEAD, disable_warning = TRUE)
			for(var/direction in GLOB.cardinals)
				catalogue.Insert(getFlatIcon(vox, defdir = direction, no_anim = TRUE), dir = direction, frame = index)
		test_screenshot("quills_[hat]", catalogue)

	var/icon/beaks = icon('icons/effects/effects.dmi', "nothing")
	var/list/beak_choices = list("Primalis beak", "Armalis beak")
	for(var/index in 1 to length(beak_choices))
		var/mob/living/carbon/human/dummy/consistent/vox = make_vox()
		var/obj/item/organ/snout/vox/snout = vox.get_organ_slot(ORGAN_SLOT_EXTERNAL_SNOUT)
		var/datum/bodypart_overlay/mutant/snout_overlay = snout.bodypart_overlay
		snout_overlay.set_appearance_from_name(beak_choices[index])
		vox.update_body_parts()
		for(var/direction in GLOB.cardinals)
			beaks.Insert(getFlatIcon(vox, defdir = direction, no_anim = TRUE), dir = direction, frame = index)
	test_screenshot("beaks", beaks)

/datum/unit_test/vox_appearance_screenshots/proc/make_vox()
	var/mob/living/carbon/human/dummy/consistent/vox = allocate(/mob/living/carbon/human/dummy/consistent)
	vox.set_species(/datum/species/vox)
	vox.dna.species.prepare_human_for_preview(vox)
	return vox

/// Export actual initialized clothing states, without treating human fallback art as fitted.
/datum/unit_test/vox_clothing_inventory/Run()
	var/obj/item/storage/box/container = allocate(/obj/item/storage/box)
	var/list/inventory = list()
	var/list/skipped = list()
	var/list/native_visibility = list()
	var/list/categories = list(
		"head" = /obj/item/clothing/head,
		"mask" = /obj/item/clothing/mask,
		"under" = /obj/item/clothing/under,
		"shoes" = /obj/item/clothing/shoes,
	)
	var/list/slots = list("head" = ITEM_SLOT_HEAD, "mask" = ITEM_SLOT_MASK, "under" = ITEM_SLOT_ICLOTHING, "shoes" = ITEM_SLOT_FEET)
	for(var/category in categories)
		for(var/obj/item/item_type as anything in valid_subtypesof(categories[category]))
			if(initial(item_type.item_flags) & ABSTRACT)
				continue
			var/obj/item/item = allocate(item_type, container)
			if(QDELETED(item))
				skipped += list(list("type" = "[item_type]", "reason" = "transforms_or_deletes_during_Initialize"))
				continue
			if(HAS_TRAIT(item, TRAIT_NO_WORN_ICON))
				qdel(item)
				continue
			var/state = item.worn_icon_state || item.icon_state
			var/native_icon = item.worn_icon || get_default_icon_by_slot(slots[category])
			if(!state || !icon_exists(native_icon, state))
				skipped += list(list("type" = "[item_type]", "state" = state, "reason" = "no_native_initial_worn_state"))
				qdel(item)
				continue
			var/visibility_key = "[native_icon]-[state]"
			if(!(visibility_key in native_visibility))
				var/icon/native_sprite = icon(native_icon, state, SOUTH)
				var/visible = FALSE
				for(var/x in 1 to native_sprite.Width())
					for(var/y in 1 to native_sprite.Height())
						if(native_sprite.GetPixel(x, y))
							visible = TRUE
							break
					if(visible)
						break
				native_visibility[visibility_key] = visible
			if(!native_visibility[visibility_key])
				skipped += list(list("type" = "[item_type]", "state" = state, "reason" = "invisible_native_worn_sprite"))
				qdel(item)
				continue
			var/fitted_icon = item.get_species_worn_icon(SPECIES_VOX)
			inventory += list(list(
				"category" = category,
				"type" = "[item_type]",
				"name" = item.name,
				"name_ru" = item.declent_ru(NOMINATIVE),
				"state" = state,
				"native_icon" = "[native_icon]",
				"greyscale_config" = item.greyscale_config_worn ? "[item.greyscale_config_worn]" : null,
				"fitted" = !isnull(fitted_icon),
				"fitted_icon" = fitted_icon ? "[fitted_icon]" : null,
			))
			qdel(item)
	TEST_ASSERT(length(inventory), "No visible wearable types were collected for the vox inventory.")
	var/export_path = "data/vox-clothing-inventory.json"
	fdel(export_path)
	file(export_path) << json_encode(list(
		"scope" = "Initialized default worn states; toggled variants are covered separately by scenario tests.",
		"items" = inventory,
		"skipped" = skipped,
	))
	TEST_ASSERT(fexists(export_path), "Vox clothing inventory was not written to disk.")
	var/list/exported = json_decode(file2text(export_path))
	TEST_ASSERT(islist(exported), "Vox clothing inventory is not a JSON object.")
	TEST_ASSERT_EQUAL(length(exported["items"]), length(inventory), "Vox clothing inventory lost rows while being exported.")
