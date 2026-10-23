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

/// Security job icons must remain readable when diagnostic glasses show an IPC's bars.
/datum/unit_test/ipc_diagnostic_hud_layout/Run()
	var/mob/living/carbon/human/dummy/consistent/ipc = allocate(/mob/living/carbon/human/dummy/consistent)
	ipc.set_species(/datum/species/ipc)
	ipc.dna.species.prepare_human_for_preview(ipc)
	ipc.equipOutfit(/datum/outfit/job/assistant/consistent, visuals_only = TRUE)
	ipc.set_hud_image_state(ID_HUD, hud_state = SECHUD_ASSISTANT)
	var/image/job_hud = ipc.hud_list[ID_HUD]
	var/icon/job_icon = icon(job_hud.icon, job_hud.icon_state)
	var/icon/combined_huds = render_huds(ipc, include_body = FALSE)
	var/icon/old_huds = render_huds(ipc, include_body = FALSE, old_layout = TRUE)
	var/old_layout_obscures_job = FALSE
	for(var/x in 1 to job_icon.Width())
		for(var/y in 1 to job_icon.Height())
			var/job_pixel = job_icon.GetPixel(x, y)
			if(job_pixel)
				TEST_ASSERT_EQUAL(combined_huds.GetPixel(x, y), job_pixel, "Diagnostic HUD obscured the security job icon at [x],[y].")
				if(old_huds.GetPixel(x, y) != job_pixel)
					old_layout_obscures_job = TRUE
	TEST_ASSERT(old_layout_obscures_job, "HUD regression fixture did not reproduce the original overlap.")

	for(var/hud_type in list(DIAG_HUD, DIAG_BATT_HUD))
		var/image/diagnostic_bar = ipc.hud_list[hud_type]
		var/original_x = diagnostic_bar.pixel_x
		ipc.readjust_atom_huds()
		TEST_ASSERT_EQUAL(diagnostic_bar.pixel_x, original_x, "Mob transform adjustment reset the diagnostic bar's position.")
		TEST_ASSERT_EQUAL(diagnostic_bar.pixel_w, job_hud.pixel_w, "Diagnostic bar lost the common HUD anchor.")

	// Keep a local comparison of the former layout without accepting it as a reference.
	fcopy(render_huds(ipc, old_layout = TRUE), "data/ipc-diagnostic-hud-before.png")
	fcopy(render_huds(ipc), "data/ipc-diagnostic-hud-after.png")
	ipc.death()
	fcopy(render_huds(ipc), "data/ipc-diagnostic-hud-dead.png")

/datum/unit_test/ipc_diagnostic_hud_layout/proc/render_huds(mob/living/carbon/human/ipc, include_body = TRUE, old_layout = FALSE)
	var/image/preview = include_body ? image(ipc) : image('icons/blanks/32x32.dmi', icon_state = "nothing")
	for(var/hud_type in list(ID_HUD, DIAG_STAT_HUD, DIAG_HUD, DIAG_BATT_HUD))
		var/image/hud_image = image(ipc.hud_list[hud_type])
		if(old_layout && (hud_type == DIAG_HUD || hud_type == DIAG_BATT_HUD))
			hud_image.pixel_x = 0
		preview.overlays += hud_image
	return getFlatIcon(preview, no_anim = TRUE)
