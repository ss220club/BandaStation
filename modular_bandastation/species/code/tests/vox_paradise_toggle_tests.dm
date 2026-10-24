/// Interactions must update the live worn overlay without replacing the original item.
/datum/unit_test/vox_appearance_screenshots/paradise_interactions/Run()
	var/mob/living/carbon/human/dummy/consistent/uniform_wearer = make_vox()
	var/obj/item/clothing/under/rank/engineering/chief_engineer/skirt/uniform = allocate(/obj/item/clothing/under/rank/engineering/chief_engineer/skirt)
	TEST_ASSERT(uniform.can_adjust, "The Paradise uniform fixture cannot change style.")
	TEST_ASSERT(uniform_wearer.equip_to_slot_if_possible(uniform, ITEM_SLOT_ICLOTHING, disable_warning = TRUE), "Could not equip the Paradise uniform interaction fixture.")
	var/base_uniform_state = uniform.icon_state
	var/icon/uniform_catalogue = get_flat_icon_for_all_directions(uniform_wearer)
	var/old_usr = usr
	usr = uniform_wearer // rolldown() reports the style change through usr.
	uniform.click_alt(uniform_wearer)
	usr = old_usr
	TEST_ASSERT_EQUAL(uniform.adjusted, ALT_STYLE, "Alt-click did not roll down the Paradise uniform.")
	TEST_ASSERT_EQUAL(uniform.icon_state, base_uniform_state, "Rolling down the uniform changed its base item state.")
	TEST_ASSERT_EQUAL(uniform_wearer.w_uniform, uniform, "Rolling down the uniform replaced the original item.")
	var/mutable_appearance/rolled_overlay = uniform_wearer.overlays_standing[UNIFORM_LAYER]
	TEST_ASSERT_EQUAL(rolled_overlay.icon, 'icons/bandastation/mob/species/vox/paradise/under_replacement.dmi', "The live rolled uniform lost its Paradise file.")
	TEST_ASSERT_EQUAL(rolled_overlay.icon_state, "[base_uniform_state]_d", "The live renderer did not resolve the rolled uniform state.")
	for(var/direction in GLOB.cardinals)
		uniform_catalogue.Insert(getFlatIcon(uniform_wearer, defdir = direction, no_anim = TRUE), dir = direction, frame = 2)
	usr = uniform_wearer
	uniform.click_alt(uniform_wearer)
	usr = old_usr
	TEST_ASSERT_EQUAL(uniform.adjusted, NORMAL_STYLE, "Alt-click did not restore the Paradise uniform style.")
	for(var/direction in GLOB.cardinals)
		uniform_catalogue.Insert(getFlatIcon(uniform_wearer, defdir = direction, no_anim = TRUE), dir = direction, frame = 3)
	test_screenshot("rolled_uniform", uniform_catalogue)

	var/mob/living/carbon/human/dummy/consistent/jacket_wearer = make_vox()
	var/obj/item/clothing/suit/toggle/etamin_jacket/jacket = allocate(/obj/item/clothing/suit/toggle/etamin_jacket)
	TEST_ASSERT(jacket_wearer.equip_to_slot_if_possible(jacket, ITEM_SLOT_OCLOTHING, disable_warning = TRUE), "Could not equip the EI jacket interaction fixture.")
	var/datum/component/toggle_icon/jacket_toggle = jacket.GetComponent(/datum/component/toggle_icon)
	TEST_ASSERT_NOTNULL(jacket_toggle, "The EI jacket has no toggle component.")
	var/base_jacket_state = jacket.icon_state
	var/icon/jacket_catalogue = get_flat_icon_for_all_directions(jacket_wearer)
	SEND_SIGNAL(jacket, COMSIG_CLICK_ALT, jacket_wearer)
	TEST_ASSERT(jacket_toggle.toggled, "Alt-click did not toggle the EI jacket component.")
	TEST_ASSERT_EQUAL(jacket.icon_state, "[base_jacket_state]_t", "The EI jacket component selected the wrong toggled state.")
	TEST_ASSERT_EQUAL(jacket_wearer.wear_suit, jacket, "Toggling the EI jacket replaced the original item.")
	var/mutable_appearance/jacket_overlay = jacket_wearer.overlays_standing[SUIT_LAYER]
	TEST_ASSERT_EQUAL(jacket_overlay.icon, 'icons/bandastation/mob/species/vox/paradise/suit.dmi', "The live toggled EI jacket lost its Paradise file.")
	TEST_ASSERT_EQUAL(jacket_overlay.icon_state, "[base_jacket_state]_t", "The EI jacket component did not update its live worn overlay.")
	for(var/direction in GLOB.cardinals)
		jacket_catalogue.Insert(getFlatIcon(jacket_wearer, defdir = direction, no_anim = TRUE), dir = direction, frame = 2)
	SEND_SIGNAL(jacket, COMSIG_CLICK_ALT, jacket_wearer)
	TEST_ASSERT(!jacket_toggle.toggled, "Alt-click did not restore the EI jacket component.")
	TEST_ASSERT_EQUAL(jacket.icon_state, base_jacket_state, "The EI jacket did not restore its base state.")
	for(var/direction in GLOB.cardinals)
		jacket_catalogue.Insert(getFlatIcon(jacket_wearer, defdir = direction, no_anim = TRUE), dir = direction, frame = 3)
	test_screenshot("ei_jacket", jacket_catalogue)

	for(var/hat_type in list(/obj/item/clothing/head/utility/hardhat/pumpkinhead, /obj/item/clothing/head/utility/hardhat/pumpkinhead/blumpkin))
		var/mob/living/carbon/human/dummy/consistent/hat_wearer = make_vox()
		var/obj/item/clothing/head/utility/hardhat/pumpkinhead/hat = allocate(hat_type)
		TEST_ASSERT(hat_wearer.equip_to_slot_if_possible(hat, ITEM_SLOT_HEAD, disable_warning = TRUE), "Could not equip the [hat.hat_type] light fixture.")
		var/base_hat_state = hat.icon_state
		var/icon/hat_catalogue = get_flat_icon_for_all_directions(hat_wearer)
		hat.attack_self(hat_wearer)
		TEST_ASSERT(hat.on && hat.light_on, "The [hat.hat_type] headlamp did not turn on.")
		TEST_ASSERT_EQUAL(hat.icon_state, "hardhat1_[hat.hat_type]", "The headlamp selected the wrong lit state.")
		TEST_ASSERT_EQUAL(hat_wearer.head, hat, "Toggling the headlamp replaced the original item.")
		var/hat_file = hat.get_species_worn_icon(SPECIES_VOX)
		var/expected_file = istype(hat, /obj/item/clothing/head/utility/hardhat/pumpkinhead/blumpkin) ? 'icons/bandastation/mob/species/vox/paradise/head.dmi' : 'icons/bandastation/mob/species/vox/clothing/head.dmi'
		TEST_ASSERT_EQUAL(hat_file, expected_file, "The lit headlamp lost its fitted file.")
		var/list/lit_overlays = hat.worn_overlays(mutable_appearance(hat_file, hat.icon_state), FALSE, hat_file, hat_wearer.bodyshape)
		TEST_ASSERT(length(lit_overlays), "The lit headlamp produced no emissive worn overlay.")
		var/mutable_appearance/emissive_overlay = lit_overlays[length(lit_overlays)]
		TEST_ASSERT(icon_exists(emissive_overlay.icon, emissive_overlay.icon_state), "The headlamp selected a missing auxiliary worn state: [emissive_overlay.icon_state].")
		for(var/direction in GLOB.cardinals)
			hat_catalogue.Insert(getFlatIcon(hat_wearer, defdir = direction, no_anim = TRUE), dir = direction, frame = 2)
		hat.attack_self(hat_wearer)
		TEST_ASSERT(!hat.on && !hat.light_on, "The headlamp did not turn off.")
		TEST_ASSERT_EQUAL(hat.icon_state, base_hat_state, "The headlamp did not restore its unlit state.")
		for(var/direction in GLOB.cardinals)
			hat_catalogue.Insert(getFlatIcon(hat_wearer, defdir = direction, no_anim = TRUE), dir = direction, frame = 3)
		test_screenshot("[hat.hat_type]_light", hat_catalogue)
