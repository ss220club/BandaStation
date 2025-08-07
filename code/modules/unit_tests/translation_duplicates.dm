/**
 * Unit test to check that all translation files do not have duplicate keys
 * This test scans all TOML files in the translation directory and verifies that
 * no translation keys are duplicated across different files, which could cause
 * translation conflicts and overwriting of values.
 *
 * The test checks both:
 * 1. Top-level keys across all files (like section names [food], [attack_verbs], or individual entries ["item name"])
 * 2. Individual translation keys within the recursively loaded name files
 */
/datum/unit_test/translation_duplicates

/datum/unit_test/translation_duplicates/Run()
	// Build list of all translation files to check
	var/list/standalone_files = list()
	var/list/recursive_files = list()

	// Add specific translation files (these have sections like [food], [attack_verbs], etc.)
	var/list/specific_files = list(
		"modular_bandastation/translations/code/translation_data/ru_tastes.toml",
		"modular_bandastation/translations/code/translation_data/ru_verbs.toml",
		"modular_bandastation/translations/code/translation_data/ru_emotes.toml",
		"modular_bandastation/translations/code/translation_data/ru_reagents.toml"
	)

	for(var/file_path in specific_files)
		if(fexists(file(file_path)))
			standalone_files += file_path

	// Add all TOML files from the game directory recursively (these have individual item entries)
	_collect_toml_files_recursive("modular_bandastation/translations/code/translation_data/game", recursive_files)

	_test_standalone_files(standalone_files) // TODO: Uncomment after fixing

	_test_recursive_files(recursive_files)


/// Helper to test singular files (like [tastes], [attack_verbs], etc.)
/datum/unit_test/translation_duplicates/proc/_test_standalone_files(list/file_list)

	var/duplicates_found = FALSE

	// Process each translation file
	for(var/file_path in file_list)

		var/list/toml_data = rustg_read_toml_file(file_path)
		if(!length(toml_data))
			continue

		// Check each section in the file
		for(var/section_key in toml_data)

			var/list/section_data = toml_data[section_key]
			if(!islist(section_data))
				continue

			// Track all unique keys found across the file
			var/list/all_keys = list()

			// Check each translation value in the section
			for(var/translation_key in section_data)

				if(translation_key in all_keys)
					// Duplicate keys found! Record which keys
					duplicates_found = TRUE
					log_test("Translation key '[translation_key]' found in [file_path]:[section_key]")
				else
					all_keys += translation_value

	if(!duplicates_found)
		TEST_PASS("No duplicate translation keys found across [length(file_list)] standalone translation files")
	else
		TEST_FAIL("Found duplicate translation keys across standalone translation files - this could cause translation conflicts")

/// Helper to test recursive files (like individual item entries)
/datum/unit_test/translation_duplicates/proc/_test_recursive_files(list/file_list)

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
			log_test("Translation key '[key]' found in multiple files: [english_list(sources)]")

	if(!duplicates_found)
		TEST_PASS("No duplicate translation keys found across [length(file_list)] standalone translation files")
	else
		TEST_FAIL("Found duplicate translation keys across standalone translation files - this could cause translation conflicts")


/// Helper proc to recursively collect all TOML files from a directory
/datum/unit_test/translation_duplicates/proc/_collect_toml_files_recursive(directory_path, list/file_list)
	var/list/files = flist(directory_path)
	if(!length(files))
		return

	for(var/file_or_dir in files)
		var/full_path = "[directory_path]/[file_or_dir]"
		// If it's a directory (ends with /), recursively scan it
		if(findtext(file_or_dir, "/", length(file_or_dir)))
			_collect_toml_files_recursive(full_path, file_list)
		// If it's a TOML file, add it to our list
		else if(copytext(file_or_dir, -4) == "toml")
			file_list += full_path
