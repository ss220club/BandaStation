/// Chat and third-person aliases must use one datum and one ordinary sound lookup.
/datum/unit_test/vox_emote_dispatch
	var/completed_emotes = 0
	var/sound_lookups = 0
	var/datum/emote/last_emote

/datum/unit_test/vox_emote_dispatch/Run()
	var/list/cases = list(
		"quill" = 'modular_bandastation/emote_panel/audio/vox/voxrustle.ogg',
		"click" = 'modular_bandastation/emote_panel/audio/vox/kidanclack2.ogg',
	)
	for(var/key in cases)
		var/datum/emote/emote = GLOB.emote_list[key][1]
		TEST_ASSERT_EQUAL(length(GLOB.emote_list[key]), 1, "Vox emote key collides with another registered emote: [key].")
		TEST_ASSERT_EQUAL(GLOB.emote_list[emote.key_third_person][1], emote, "The third-person alias selected a different emote.")
		TEST_ASSERT(findtext(emote.select_param(null, "Test Target"), "Test Target"), "The targeted Vox emote lost its target.")
		for(var/mode in list("command", "alias", "chat"))
			var/mob/living/carbon/human/vox = allocate(/mob/living/carbon/human/consistent)
			vox.set_species(/datum/species/vox)
			TEST_ASSERT_EQUAL(emote.get_sound(vox), cases[key], "The Vox emote selected the wrong Paradise sound.")
			RegisterSignal(vox, COMSIG_MOB_EMOTE, PROC_REF(on_emote))
			RegisterSignal(vox, COMSIG_MOB_EMOTE_SOUND(key), PROC_REF(on_sound_lookup))
			completed_emotes = 0
			sound_lookups = 0
			last_emote = null
			if(mode == "chat")
				vox.key = "VoxEmoteTestKey"
				vox.say("*[key]")
				vox.key = null
			else
				TEST_ASSERT(vox.emote(mode == "alias" ? emote.key_third_person : key, intentional = TRUE), "The Vox emote command was rejected.")
			TEST_ASSERT_EQUAL(completed_emotes, 1, "A Vox emote did not complete exactly once.")
			TEST_ASSERT_EQUAL(sound_lookups, 1, "A Vox emote did not use exactly one standard sound lookup.")
			TEST_ASSERT_EQUAL(last_emote, emote, "Vox dispatch selected a different registered datum.")
			UnregisterSignal(vox, list(COMSIG_MOB_EMOTE, COMSIG_MOB_EMOTE_SOUND(key)))
		last_emote = null

/datum/unit_test/vox_emote_dispatch/proc/on_emote(datum/source, datum/emote/emote)
	SIGNAL_HANDLER
	completed_emotes++
	last_emote = emote

/datum/unit_test/vox_emote_dispatch/proc/on_sound_lookup(datum/source, key, list/sounds)
	SIGNAL_HANDLER
	sound_lookups++

/// Real mask signals must spare feather sounds while respecting a fixed beak.
/datum/unit_test/vox_emote_mask_dispatch
	parent_type = /datum/unit_test/vox_emote_dispatch

/datum/unit_test/vox_emote_mask_dispatch/Run()
	var/list/masks = list(
		/obj/item/clothing/mask/breath/vox = FALSE,
		/obj/item/clothing/mask/gas = FALSE,
		/obj/item/clothing/mask/muzzle = TRUE,
		/obj/item/clothing/mask/breath/muzzle = TRUE,
	)
	for(var/mask_type in masks)
		for(var/key in list("quill", "click"))
			var/mob/living/carbon/human/vox = allocate(/mob/living/carbon/human/consistent)
			vox.set_species(/datum/species/vox)
			var/obj/item/clothing/mask/mask = allocate(mask_type)
			TEST_ASSERT(vox.equip_to_slot_if_possible(mask, ITEM_SLOT_MASK, disable_warning = TRUE), "Could not equip [mask_type].")
			RegisterSignal(vox, COMSIG_MOB_EMOTE, PROC_REF(on_emote))
			RegisterSignal(vox, COMSIG_MOB_EMOTE_SOUND(key), PROC_REF(on_sound_lookup))
			completed_emotes = 0
			sound_lookups = 0
			var/expected = !(key == "click" && masks[mask_type])
			TEST_ASSERT_EQUAL(vox.emote(key, intentional = TRUE, force_silence = TRUE), expected, "A physical Vox emote had the wrong mask restriction: [mask_type]/[key].")
			TEST_ASSERT_EQUAL(completed_emotes, expected ? 1 : 0, "A mask suppressed a feather emote or allowed a restrained beak.")
			TEST_ASSERT_EQUAL(sound_lookups, expected ? 1 : 0, "A physical mask interaction used the wrong number of sound lookups.")
			UnregisterSignal(vox, list(COMSIG_MOB_EMOTE, COMSIG_MOB_EMOTE_SOUND(key)))
	last_emote = null

/// Physical emotes need their anatomy and consciousness, but not a working voice.
/datum/unit_test/vox_emote_restrictions/Run()
	var/mob/living/carbon/human/vox = allocate(/mob/living/carbon/human/consistent)
	vox.set_species(/datum/species/vox)
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/silicon/robot/robot = allocate(/mob/living/silicon/robot)
	var/datum/emote/quill = GLOB.emote_list["quill"][1]
	var/datum/emote/click = GLOB.emote_list["click"][1]
	for(var/datum/emote/emote as anything in list(quill, click))
		TEST_ASSERT(emote.can_run_emote(vox), "A healthy Vox could not use its physical emote.")
		TEST_ASSERT(!emote.can_run_emote(human), "A human received a Vox physical emote.")
		TEST_ASSERT(!emote.can_run_emote(robot), "A non-human received a Vox physical emote.")

	var/obj/item/organ/tongue/tongue = vox.get_organ_slot(ORGAN_SLOT_TONGUE)
	allocated += tongue
	tongue.Remove(vox, special = TRUE)
	ADD_TRAIT(vox, TRAIT_MUTE, TRAIT_SOURCE_UNIT_TESTS)
	for(var/datum/emote/emote as anything in list(quill, click))
		TEST_ASSERT(emote.can_run_emote(vox) && emote.should_play_sound(vox, intentional = TRUE), "A non-vocal physical emote required a tongue or voice.")
	var/datum/emote/scream = GLOB.emote_list["scream"][1]
	TEST_ASSERT(!scream.should_play_sound(vox, intentional = TRUE), "Non-vocal support also bypassed ordinary voice restrictions.")
	REMOVE_TRAIT(vox, TRAIT_MUTE, TRAIT_SOURCE_UNIT_TESTS)
	tongue.Insert(vox, special = TRUE)
	var/datum/emote/probe = allocate(/datum/emote/living/carbon/human/vox/quill)
	probe.only_forced_audio = TRUE
	TEST_ASSERT(!probe.should_play_sound(vox, intentional = TRUE), "Non-vocal support bypassed the parent's forced-audio policy.")

	var/obj/item/organ/quills/vox/quills = vox.get_organ_by_type(/obj/item/organ/quills/vox)
	allocated += quills
	quills.Remove(vox, special = TRUE)
	TEST_ASSERT(!quill.can_run_emote(vox), "A Vox without quills could rustle them.")
	quills.Insert(vox, special = TRUE)
	var/datum/bodypart_overlay/mutant/quills/vox/overlay = quills.bodypart_overlay
	var/original_style = overlay.sprite_datum.type
	overlay.set_appearance_from_name(SPRITE_ACCESSORY_NONE)
	TEST_ASSERT(!quill.can_run_emote(vox), "The None quill style could rustle visible feathers.")
	overlay.set_appearance(original_style)
	TEST_ASSERT(quill.can_run_emote(vox), "Reinserting and restyling the quills did not restore their emote.")
	var/obj/item/organ/snout/vox/beak = vox.get_organ_by_type(/obj/item/organ/snout/vox)
	allocated += beak
	beak.Remove(vox, special = TRUE)
	TEST_ASSERT(!click.can_run_emote(vox), "A Vox without its beak could click.")
	beak.Insert(vox, special = TRUE)
	TEST_ASSERT(click.can_run_emote(vox), "Reinserting the beak did not restore its emote.")

	ADD_TRAIT(vox, TRAIT_EMOTEMUTE, TRAIT_SOURCE_UNIT_TESTS)
	TEST_ASSERT(!vox.emote("quill", force_silence = TRUE) && !vox.emote("click", force_silence = TRUE), "Vox physical emotes bypassed emote muting.")
	REMOVE_TRAIT(vox, TRAIT_EMOTEMUTE, TRAIT_SOURCE_UNIT_TESTS)
	vox.Unconscious(1 MINUTES, ignore_canstun = TRUE)
	TEST_ASSERT(!quill.can_run_emote(vox) && !click.can_run_emote(vox), "An unconscious Vox could perform its physical emotes.")
	vox.SetUnconscious(0)
	vox.death()
	TEST_ASSERT(!quill.can_run_emote(vox) && !click.can_run_emote(vox), "A dead Vox could deliberately move its beak or quills.")

/// The existing panel must discover both keys once and follow species changes.
/datum/unit_test/vox_emote_panel/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)
	var/datum/emote_panel/panel = allocate(/datum/emote_panel)
	for(var/is_vox in list(TRUE, FALSE, TRUE))
		human.set_species(is_vox ? /datum/species/vox : /datum/species/human)
		var/list/data = panel.ui_static_data(human)
		for(var/key in list("quill", "click"))
			var/matches = 0
			for(var/list/entry as anything in data["emotes"])
				if(entry["key"] != key)
					continue
				matches++
				TEST_ASSERT(entry["sound"] && entry["use_params"], "The Vox panel entry lost its audio preview or targeted message.")
			TEST_ASSERT_EQUAL(matches, is_vox ? 1 : 0, "The panel retained, duplicated or omitted the wrong species' physical emote.")
