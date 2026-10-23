/// A broken asset must fail here, rather than producing an invisible limb or screen in character setup.
/datum/unit_test/ipc_appearance_assets/Run()
	for(var/chassis_name in GLOB.ipc_chassis)
		var/datum/ipc_chassis/chassis = GLOB.ipc_chassis[chassis_name]
		var/list/states = icon_states(chassis.icon)
		if(chassis.has_head)
			TEST_ASSERT("ipc_head" in states, "IPC head [chassis_name] has no head icon.")
		if(chassis.has_body)
			for(var/part in list("chest", "l_arm", "r_arm", "l_hand", "r_hand", "l_leg", "r_leg"))
				TEST_ASSERT("ipc_[part]" in states, "IPC chassis [chassis_name] has no [part] icon.")
		if(chassis.has_head)
			var/default_display = get_default_ipc_display(chassis_name)
			TEST_ASSERT(default_display in get_ipc_display_choices(chassis_name), "IPC head [chassis_name] has an incompatible default display.")

	for(var/display_name in GLOB.ipc_displays)
		var/datum/sprite_accessory/ipc_display/display = GLOB.ipc_displays[display_name]
		if(display.icon_state == SPRITE_ACCESSORY_NONE)
			continue
		var/list/states = icon_states(display.icon)
		TEST_ASSERT(display.icon_state in states, "IPC display [display_name] has no icon.")
		if(display.secondary_state)
			TEST_ASSERT(display.secondary_state in states, "IPC display [display_name] has no foreground icon.")
	for(var/antenna_name in GLOB.ipc_antennae)
		var/datum/sprite_accessory/ipc_antenna/antenna = GLOB.ipc_antennae[antenna_name]
		if(antenna.icon_state == SPRITE_ACCESSORY_NONE)
			continue
		TEST_ASSERT(antenna.icon_state in icon_states(antenna.icon), "IPC antenna [antenna_name] has no icon.")

/datum/unit_test/ipc_appearance_screenshots/Run()
	var/mob/living/carbon/human/dummy/consistent/ipc = allocate(/mob/living/carbon/human/dummy/consistent)
	ipc.set_species(/datum/species/ipc)
	ipc.dna.species.prepare_human_for_preview(ipc)
	test_screenshot("naked", get_flat_icon_for_all_directions(ipc))
	ipc.equipOutfit(/datum/outfit/job/assistant/consistent, visuals_only = TRUE)
	test_screenshot("assistant", get_flat_icon_for_all_directions(ipc))

	var/obj/item/bodypart/head/robot/ipc/head = ipc.get_bodypart(BODY_ZONE_HEAD)
	var/datum/sprite_accessory/ipc_display/display = GLOB.ipc_displays[head.ipc_display_name]
	TEST_ASSERT(has_display_image(head, display), "Living IPC does not show its chosen display.")
	ipc.death()
	TEST_ASSERT(!has_display_image(head, display), "Dead IPC still shows a powered display.")
	test_screenshot("dead", get_flat_icon_for_all_directions(ipc))

/datum/unit_test/ipc_appearance_screenshots/proc/has_display_image(obj/item/bodypart/head/robot/ipc/head, datum/sprite_accessory/ipc_display/display)
	var/list/limb_images = head.get_limb_icon(dropped = FALSE)
	for(var/image/limb_image as anything in limb_images)
		if(limb_image.icon == display.icon && limb_image.icon_state == display.icon_state)
			return TRUE
	return FALSE
