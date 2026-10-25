/// Applying real character preferences must preserve the chosen colour on cosmetic robotic eyes.
/datum/unit_test/augmentation_robotic_eye_preferences/Run()
	var/datum/client_interface/mock_client = allocate(/datum/client_interface)
	var/datum/preferences/preferences = allocate(/datum/preferences, mock_client)
	preferences.value_cache[/datum/preference/choiced/species] = /datum/species/human
	preferences.value_cache[/datum/preference/body_modifications] = list("robotic_eyes" = list())
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)

	for(var/selected_color in list("#36c5f0", "#e76ba4"))
		preferences.value_cache[/datum/preference/color/eye_color] = selected_color
		preferences.apply_prefs_to(human)
		var/obj/item/organ/eyes/eyes = human.get_organ_slot(ORGAN_SLOT_EYES)
		TEST_ASSERT_NOTNULL(eyes, "Character preferences left the character without eyes.")
		TEST_ASSERT_EQUAL(eyes.type, /obj/item/organ/eyes/robotic/basic/augmented, "Character preferences did not install cosmetic robotic eyes.")
		TEST_ASSERT_EQUAL(eyes.eye_color_left, selected_color, "The left robotic eye discarded its preference colour.")
		TEST_ASSERT_EQUAL(eyes.eye_color_right, selected_color, "The right robotic eye discarded its preference colour.")
		TEST_ASSERT_EQUAL(human.get_left_eye_color(), selected_color, "A stale override replaced the chosen left eye colour.")
		TEST_ASSERT_EQUAL(human.get_right_eye_color(), selected_color, "A stale override replaced the chosen right eye colour.")
		TEST_ASSERT(HAS_TRAIT(human, TRAIT_LUMINESCENT_EYES), "Robotic eyes did not apply their cosmetic glow.")

		var/list/overlays = eyes.generate_body_overlay(human.get_bodypart(BODY_ZONE_HEAD))
		TEST_ASSERT(length(overlays) >= 4, "Robotic eyes did not generate both coloured eyes and emissive masks.")
		var/mutable_appearance/left_eye = overlays[1]
		var/mutable_appearance/right_eye = overlays[2]
		TEST_ASSERT_EQUAL(left_eye.color, selected_color, "The left body overlay lost its selected tint.")
		TEST_ASSERT_EQUAL(right_eye.color, selected_color, "The right body overlay lost its selected tint.")
		TEST_ASSERT_EQUAL(left_eye.icon_state, "eyes_glow_gs_l", "The left eye used the ordinary organic sprite.")
		TEST_ASSERT_EQUAL(right_eye.icon_state, "eyes_glow_gs_r", "The right eye used the ordinary organic sprite.")
		var/emissive_masks = 0
		for(var/mutable_appearance/overlay as anything in overlays)
			TEST_ASSERT(icon_exists(overlay.icon, overlay.icon_state), "Robotic eyes generated a missing sprite: [overlay.icon_state].")
			if(json_encode(overlay.color) == json_encode(GLOB.emissive_color_no_bloom))
				emissive_masks++
		TEST_ASSERT_EQUAL(emissive_masks, 2, "Cosmetic robotic eyes must emit exactly two glowing eye masks.")

/// Replacing cosmetic eyes must clear their glow; moth models retain their native appearance.
/datum/unit_test/augmentation_robotic_eye_replacement/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)
	human.set_eye_color("#36c5f0", "#e76ba4")
	var/obj/item/organ/eyes/robotic/basic/augmented/robotic_eyes = allocate(/obj/item/organ/eyes/robotic/basic/augmented)
	TEST_ASSERT(robotic_eyes.Insert(human), "Could not insert cosmetic robotic eyes.")
	TEST_ASSERT_EQUAL(human.get_right_eye_color(), "#e76ba4", "Robotic eyes lost independent left and right colours.")
	robotic_eyes.apply_scar(LEFT_EYE_SCAR)
	robotic_eyes.apply_scar(RIGHT_EYE_SCAR)
	var/list/scarred_overlays = robotic_eyes.generate_body_overlay(human.get_bodypart(BODY_ZONE_HEAD))
	TEST_ASSERT_EQUAL(length(scarred_overlays), 6, "Scarred robotic eyes did not generate both scars.")
	for(var/mutable_appearance/overlay as anything in scarred_overlays)
		TEST_ASSERT(icon_exists(overlay.icon, overlay.icon_state), "Scarred robotic eyes generated a missing sprite: [overlay.icon_state].")
	robotic_eyes.Remove(human)
	TEST_ASSERT(!HAS_TRAIT(human, TRAIT_LUMINESCENT_EYES), "Removed robotic eyes left their glow on the old owner.")
	TEST_ASSERT_EQUAL(human.get_left_eye_color(), human.eye_color_left, "Removed robotic eyes left a left colour override.")
	TEST_ASSERT_EQUAL(human.get_right_eye_color(), human.eye_color_right, "Removed robotic eyes left a right colour override.")

	var/obj/item/organ/eyes/organic_eyes = allocate(/obj/item/organ/eyes)
	TEST_ASSERT(organic_eyes.Insert(human), "Could not restore ordinary eyes.")
	TEST_ASSERT(!HAS_TRAIT(human, TRAIT_LUMINESCENT_EYES), "Ordinary eyes inherited cosmetic robotic glow.")
	TEST_ASSERT_EQUAL(human.get_left_eye_color(), "#36c5f0", "Ordinary eyes did not restore the natural left colour.")
	TEST_ASSERT_EQUAL(human.get_right_eye_color(), "#e76ba4", "Ordinary eyes did not restore the natural right colour.")

	var/obj/item/organ/eyes/robotic/basic/moth/moth_eyes = allocate(/obj/item/organ/eyes/robotic/basic/moth)
	TEST_ASSERT(moth_eyes.Insert(human), "Could not insert the moth control eyes.")
	TEST_ASSERT(!HAS_TRAIT(human, TRAIT_LUMINESCENT_EYES), "Basic moth eyes inherited the human cosmetic glow.")
	TEST_ASSERT_EQUAL(human.get_left_eye_color(), "#65686f", "Basic moth eyes lost their fixed model colour.")
	TEST_ASSERT_EQUAL(moth_eyes.eye_icon, 'icons/mob/human/human_eyes.dmi', "Basic moth eyes inherited the human cosmetic sprite file.")
	TEST_ASSERT_EQUAL(moth_eyes.eye_icon_state, "motheyes_white", "Basic moth eyes lost their native body sprite.")
	var/list/moth_overlays = moth_eyes.generate_body_overlay(human.get_bodypart(BODY_ZONE_HEAD))
	for(var/mutable_appearance/overlay as anything in moth_overlays)
		TEST_ASSERT(icon_exists(overlay.icon, overlay.icon_state), "Basic moth eyes generated a missing sprite: [overlay.icon_state].")
