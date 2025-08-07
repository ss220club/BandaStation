/**
 * Unit test to check that all translation files do not have duplicate keys
 * This test scans all TOML files in the translation directory and verifies that
 * no translation keys are duplicated across different files, which could cause
 * translation conflicts and overwriting of values.
 *
 * The test checks both:
 * 1. Top-level keys across all files (like section names [taste], [attack_verbs], or individual entries ["item name"])
 * 2. Individual translation keys within the modular loaded name files
 */
/datum/unit_test/translation_duplicates

/datum/unit_test/translation_duplicates/Run()

	var/list/modular_files = list()
	// Add all TOML files from the game directory recursively (these have individual item entries)
	_collect_toml_files_recursive("modular_bandastation/translations/code/translation_data/game/", modular_files)
	_test_modular_files(modular_files)


/// Helper to test modular files (like individual item entries)
/datum/unit_test/translation_duplicates/proc/_test_modular_files(list/file_list)

	// Track all keys found across all files
	var/list/all_keys = list()
	var/list/key_sources = list() // Maps key -> list of files containing it

	// Report any duplicates found
	var/duplicates_found = FALSE

	// Process each translation file
	for(var/file_path in file_list)

		var/list/toml_data = rustg_read_toml_file(file_path)
		if(!length(toml_data))
			continue

		// Check each top-level key in the file
		for(var/key in toml_data)
			if(key in all_keys)
				// Duplicate found! Record which files have this key
				if(!(key in key_sources))
					key_sources[key] = list()
				key_sources[key] += file_path
				duplicates_found = TRUE
			else
				all_keys += key
				key_sources[key] = list(file_path)

	for(var/key in key_sources)
		var/list/sources = key_sources[key]
		if(length(sources) > 1)
			log_test("Warning: Translation key '[key]' found in multiple files: [english_list(sources)]")

	if(!duplicates_found)
		log_test("No duplicate translation keys found across [length(file_list)] modular translation files")
	else
		TEST_FAIL("Found duplicate translation keys across modular translation files - this could cause translation conflicts")


/// Helper proc to recursively collect all TOML files from a directory
/datum/unit_test/translation_duplicates/proc/_collect_toml_files_recursive(directory_path, list/file_list)

	log_test("Processing directory: [directory_path]")

	var/list/files = flist(directory_path)
	if(!length(files))
		return

	for(var/file_or_dir in files)
		var/full_path = "[directory_path]/[file_or_dir]"

		log_test("Trying to process: [full_path]")

		// If it's a directory (ends with /), recursively scan it
		if(findtext(file_or_dir, "/", length(file_or_dir)))
			_collect_toml_files_recursive(full_path, file_list)
		// If it's a TOML file, add it to our list
		else if(copytext(file_or_dir, -4) == "toml")
			log_test("Adding TOML file: [full_path]")
			file_list += full_path
