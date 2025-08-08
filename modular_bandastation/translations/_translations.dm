GLOBAL_LIST_EMPTY(ru_attack_verbs)
GLOBAL_LIST_EMPTY(ru_eat_verbs)
GLOBAL_LIST_EMPTY(ru_tastes)
GLOBAL_LIST_EMPTY(ru_say_verbs)
GLOBAL_LIST_EMPTY(ru_emote_names)
GLOBAL_LIST_EMPTY(ru_emote_messages)
GLOBAL_LIST_EMPTY(ru_reagent_descs)
GLOBAL_LIST_EMPTY(ru_names)


SUBSYSTEM_DEF(translations)
	name = "Translations"
	init_stage = INITSTAGE_FIRST
	flags = SS_NO_FIRE
	dependents = list(
		/datum/controller/subsystem/atoms, // Some Atoms being initialized too early, so we need to load translations before them
	)

	var/list/ru_tastes = list()


/datum/controller/subsystem/translations/Initialize()
	// Tastes
	var/food_path = "[PATH_TO_TRANSLATE_DATA]/ru_tastes.toml"
	if(fexists(file(food_path)))
		var/list/tastes_toml_list = rustg_read_toml_file(food_path)

		var/list/tastes_list = tastes_toml_list["tastes"]
		if(tastes_list)
			GLOB.ru_tastes |= tastes_list

	// Verbs
	var/toml_path = "[PATH_TO_TRANSLATE_DATA]/ru_verbs.toml"
	if(fexists(file(toml_path)))
		var/list/verbs_toml_list = rustg_read_toml_file(toml_path)

		var/list/attack_verbs = verbs_toml_list["attack_verbs"]
		for(var/attack_key in attack_verbs)
			GLOB.ru_attack_verbs += list("[attack_key]" = attack_verbs[attack_key])

		var/list/eat_verbs = verbs_toml_list["eat_verbs"]
		for(var/eat_key in eat_verbs)
			GLOB.ru_eat_verbs += list("[eat_key]" = eat_verbs[eat_key])

		var/list/say_verbs = verbs_toml_list["say_verbs"]
		for(var/say_key in say_verbs)
			GLOB.ru_say_verbs += list("[say_key]" = say_verbs[say_key])

	// Emotes
	var/emote_path = "[PATH_TO_TRANSLATE_DATA]/ru_emotes.toml"
	if(fexists(file(emote_path)))
		var/list/emotes_toml_list = rustg_read_toml_file(emote_path)

		var/list/emote_messages = emotes_toml_list["emote_messages"]
		for(var/emote_message_key in emote_messages)
			GLOB.ru_emote_messages += list("[emote_message_key]" = emote_messages[emote_message_key])

		var/list/emote_names = emotes_toml_list["emote_names"]
		for(var/emote_name_key in emote_names)
			GLOB.ru_emote_names += list("[emote_name_key]" = emote_names[emote_name_key])

		for(var/emote_key as anything in GLOB.emote_list)
			var/list/emote_list = GLOB.emote_list[emote_key]
			for(var/datum/emote/emote in emote_list)
				emote.update_to_ru()
		for(var/emote_kb_key as anything in GLOB.keybindings_by_name)
			var/datum/keybinding/emote/emote_kb = GLOB.keybindings_by_name[emote_kb_key]
			if(!istype(emote_kb))
				continue
			emote_kb.update_to_ru()

	// Reagents desc
	var/reagents_path = "[PATH_TO_TRANSLATE_DATA]/ru_reagents.toml"
	if(fexists(file(reagents_path)))
		var/list/reagents_toml_list = rustg_read_toml_file(reagents_path)

		var/list/reagent_descs = reagents_toml_list["reagents_desc"]
		for(var/reagent_desc_key in reagent_descs)
			GLOB.ru_reagent_descs += list("[reagent_desc_key]" = reagent_descs[reagent_desc_key])

		for(var/reagent_key as anything in GLOB.chemical_reagents_list)
			var/datum/reagent/reagent = GLOB.chemical_reagents_list[reagent_key]
			reagent.update_to_ru()

	load_all_ru_names_toml_files()

	return SS_INIT_SUCCESS


/// Recursively loads all *.toml files from the translation_data directory into GLOB.ru_names
/// This function will scan all subdirectories and load any TOML files containing Russian name declensions
/// The loaded data is merged into a single GLOB.ru_names list for efficient access
/datum/controller/subsystem/translations/proc/load_all_ru_names_toml_files()
	GLOB.ru_names = list()
	_load_ru_names_from_directory(PATH_TO_TRANSLATE_DATA_FOLDER)

/// Helper proc to recursively load TOML files from a directory and its subdirectories
/datum/controller/subsystem/translations/proc/_load_ru_names_from_directory(directory_path)
	var/list/files = flist(directory_path)
	if(!length(files))
		return

	for(var/file_or_dir in files)
		var/full_path = "[directory_path]/[file_or_dir]"
		// If it's a directory (ends with /), recursively scan it
		if(findtext(file_or_dir, "/", length(file_or_dir)))
			_load_ru_names_from_directory(full_path)
		// If it's a TOML file, load it
		else if(copytext(file_or_dir, -4) == "toml")
			if(fexists(file(full_path)))
				var/list/toml_data = rustg_read_toml_file(full_path)
				if(length(toml_data))
					// Merge the loaded data into GLOB.ru_names
					for(var/key in toml_data)
						GLOB.ru_names[key] = toml_data[key]
