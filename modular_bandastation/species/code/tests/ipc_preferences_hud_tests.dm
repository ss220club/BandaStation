/// Model numbers survive editing and a savefile round trip, while organic names retain their restrictions.
/datum/unit_test/ipc_numbered_names/Run()
	var/datum/client_interface/mock_client = allocate(/datum/client_interface)
	var/datum/preferences/preferences = allocate(/datum/preferences, mock_client)
	var/datum/preference/name/real_name/name_preference = GLOB.preference_entries[/datum/preference/name/real_name]
	var/datum/preference/choiced/species/species_preference = GLOB.preference_entries[/datum/preference/choiced/species]
	preferences.value_cache[/datum/preference/choiced/species] = /datum/species/ipc
	TEST_ASSERT(preferences.update_preference(name_preference, "R2-D2"), "The preferences editor rejected an IPC model number.")
	TEST_ASSERT_EQUAL(preferences.read_preference(/datum/preference/name/real_name), "R2-D2", "The preferences editor removed an IPC's model number.")
	var/list/save_data = list()
	TEST_ASSERT(name_preference.write(save_data, "R2-D2", preferences), "A valid IPC model name could not be saved.")
	TEST_ASSERT_EQUAL(save_data["real_name"], "R2-D2", "Serializing the IPC name removed its digits.")
	TEST_ASSERT_EQUAL(name_preference.read(save_data, preferences), "R2-D2", "Loading the IPC name removed its digits.")
	TEST_ASSERT(!name_preference.is_valid(list("R2-D2"), preferences), "An IPC name accepted non-text input.")
	TEST_ASSERT(!name_preference.is_valid("<b>R2-D2</b>", preferences), "An IPC name accepted markup without sanitization.")

	species_preference.post_write(/datum/species/human, preferences)
	var/organic_name = preferences.read_preference(/datum/preference/name/real_name)
	TEST_ASSERT(!findtext(organic_name, "2"), "Changing species retained the IPC model number in the cached name.")
	TEST_ASSERT(name_preference.is_valid(organic_name, preferences), "Changing species left an invalid organic name.")
	TEST_ASSERT(!name_preference.is_valid("R2-D2", preferences), "An organic name accepted IPC model digits.")
	TEST_ASSERT(name_preference.write(save_data, organic_name, preferences), "The normalized organic name could not be saved.")
	TEST_ASSERT_EQUAL(name_preference.read(save_data, preferences), organic_name, "The organic name changed during a savefile round trip.")

	var/datum/preference/name/backup_human/backup_preference = GLOB.preference_entries[/datum/preference/name/backup_human]
	TEST_ASSERT_EQUAL(backup_preference.deserialize("Unit 42", preferences), "Unit", "The backup human name inherited IPC naming rules.")
	species_preference.post_write(/datum/species/ipc, preferences)
	TEST_ASSERT(preferences.update_preference(name_preference, "Model 42"), "Changing back into an IPC did not restore numbered names.")
	TEST_ASSERT_EQUAL(preferences.read_preference(/datum/preference/name/real_name), "Model 42", "The restored IPC lost its model number.")

/// Both medical HUDs reject IPCs across initialization, sensor changes, health updates and transformations.
/datum/unit_test/ipc_medical_hud_exclusion/Run()
	var/mob/living/carbon/human/ipc = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left, /datum/species/ipc)
	var/datum/atom_hud/basic_hud = GLOB.huds[DATA_HUD_MEDICAL_BASIC]
	var/datum/atom_hud/advanced_hud = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	var/datum/atom_hud/diagnostic_hud = GLOB.huds[DATA_HUD_DIAGNOSTIC]
	var/datum/atom_hud/security_hud = GLOB.huds[DATA_HUD_SECURITY_ADVANCED]
	TEST_ASSERT(!basic_hud.hud_atoms_all_z_levels[ipc], "A newly initialized IPC appeared in the basic medical HUD.")
	TEST_ASSERT(!advanced_hud.hud_atoms_all_z_levels[ipc], "A newly initialized IPC appeared in the advanced medical HUD.")
	TEST_ASSERT(diagnostic_hud.hud_atoms_all_z_levels[ipc], "Medical HUD exclusion hid the IPC from diagnostics.")
	TEST_ASSERT(security_hud.hud_atoms_all_z_levels[ipc], "Medical HUD exclusion hid the IPC from security.")

	ADD_TRAIT(ipc, TRAIT_BASIC_HEALTH_HUD_VISIBLE, TRAIT_SOURCE_UNIT_TESTS)
	ipc.prepare_data_huds()
	ipc.adjust_brute_loss(10)
	ipc.med_hud_set_health()
	ipc.med_hud_set_status()
	TEST_ASSERT(!basic_hud.hud_atoms_all_z_levels[ipc], "Suit sensors or HUD preparation re-added an IPC to the basic medical HUD.")
	TEST_ASSERT(!advanced_hud.hud_atoms_all_z_levels[ipc], "Health updates re-added an IPC to the advanced medical HUD.")

	ipc.set_species(/datum/species/human)
	TEST_ASSERT(basic_hud.hud_atoms_all_z_levels[ipc], "Changing back to a human did not restore the basic medical HUD.")
	TEST_ASSERT(advanced_hud.hud_atoms_all_z_levels[ipc], "Changing back to a human did not restore the advanced medical HUD.")
	ipc.set_species(/datum/species/ipc)
	TEST_ASSERT(!basic_hud.hud_atoms_all_z_levels[ipc], "A second IPC transformation retained the basic medical HUD.")
	TEST_ASSERT(!advanced_hud.hud_atoms_all_z_levels[ipc], "A second IPC transformation retained the advanced medical HUD.")
	REMOVE_TRAIT(ipc, TRAIT_BASIC_HEALTH_HUD_VISIBLE, TRAIT_SOURCE_UNIT_TESTS)
	ADD_TRAIT(ipc, TRAIT_BASIC_HEALTH_HUD_VISIBLE, TRAIT_SOURCE_UNIT_TESTS)
	TEST_ASSERT(!basic_hud.hud_atoms_all_z_levels[ipc], "Toggling suit sensors made an IPC visible to the basic medical HUD.")
