GLOBAL_LIST_EMPTY(ru_names)

/atom
	// code\__DEFINES\bandastation\pronouns.dm for more info
	/// List consists of ("name", "именительный", "родительный", "дательный", "винительный", "творительный", "предложный", "gender")
	var/list/ru_names

/// Хелпер для создания склонений
/proc/ru_names_list(base, nominative, genitive, dative, accusative, instrumental, prepositional, gender)
	if(!base || !nominative || !genitive || !dative || !accusative || !instrumental || !prepositional)
		CRASH("ru_names_list() received incomplete declent list!")
	return list("base" = base, NOMINATIVE = nominative, GENITIVE = genitive, DATIVE = dative, ACCUSATIVE = accusative, INSTRUMENTAL = instrumental, PREPOSITIONAL = prepositional, "gender" = gender)

/proc/ru_names_toml(name, prefix, suffix, override_base)
	. = list()
	var/formatted_name = format_text(name)
	if(!length(GLOB.ru_names))
		load_all_ru_names_toml_files()
	if(GLOB.ru_names[formatted_name])
		var/base = override_base || "[prefix][name][suffix]"
		var/nominative_form = GLOB.ru_names[formatted_name]["nominative"] || name
		var/genitive_form = GLOB.ru_names[formatted_name]["genitive"] || nominative_form
		var/dative_form = GLOB.ru_names[formatted_name]["dative"] || nominative_form
		var/accusative_form = GLOB.ru_names[formatted_name]["accusative"] || nominative_form
		var/instrumental_form = GLOB.ru_names[formatted_name]["instrumental"] || nominative_form
		var/prepositional_form = GLOB.ru_names[formatted_name]["prepositional"] || nominative_form
		. = ru_names_list(
			base,
			"[prefix][nominative_form][suffix]",
			"[prefix][genitive_form][suffix]",
			"[prefix][dative_form][suffix]",
			"[prefix][accusative_form][suffix]",
			"[prefix][instrumental_form][suffix]",
			"[prefix][prepositional_form][suffix]",
			gender = "[GLOB.ru_names[formatted_name]["gender"] || null]",)

/// Recursively loads all *.toml files from the translation_data directory into GLOB.ru_names
/// This function will scan all subdirectories and load any TOML files containing Russian name declensions
/// The loaded data is merged into a single GLOB.ru_names list for efficient access
/proc/load_all_ru_names_toml_files()
	GLOB.ru_names = list()
	_load_ru_names_from_directory(PATH_TO_TRANSLATE_DATA_FOLDER)

/// Helper proc to recursively load TOML files from a directory and its subdirectories
/proc/_load_ru_names_from_directory(directory_path)
	var/list/files = flist(directory_path)
	if(!length(files))
		return

	for(var/file_or_dir in files)
		var/full_path = "[directory_path]/[file_or_dir]"
		// If it's a directory (ends with /), recursively scan it
		if(findtext(file_or_dir, "/", length(file_or_dir)))
			_load_ru_names_from_directory(full_path)
		// If it's a TOML file, load it
		else if(findtext(file_or_dir, ".toml"))
			if(fexists(file(full_path)))
				var/list/toml_data = rustg_read_toml_file(full_path)
				if(length(toml_data))
					// Merge the loaded data into GLOB.ru_names
					for(var/key in toml_data)
						GLOB.ru_names[key] = toml_data[key]

/atom/Initialize(mapload, ...)
	. = ..()
	article = null
	ru_names_rename(ru_names_toml(name))

/turf/Initialize(mapload)
	. = ..()
	article = null
	ru_names_rename(ru_names_toml(name))

/datum/proc/ru_names_rename(list/new_list)
	SHOULD_CALL_PARENT(FALSE)
	CRASH("Unimplemented proc/ru_names_rename() was used")

/// Необходимо использовать ПЕРЕД изменением var/name, и использовать только этот прок для изменения в рантайме склонений
/atom/ru_names_rename(list/new_list)
	if(!length(new_list))
		ru_names = null
		return
	ru_names = new_list
	if(new_list["gender"])
		gender = new_list["gender"]
	else
		gender = src::gender

/**
* Процедура выбора правильного падежа для любого предмета, если у него указан словарь «ru_names», примерно такой:
* RU_NAMES_LIST_INIT("jaws of life", "челюсти жизни", "челюстей жизни", "челюстям жизни", "челюсти жизни", "челюстями жизни", "челюстях жизни")
*/
/datum/proc/declent_ru(declent = NOMINATIVE)
	CRASH("Unimplemented proc/declent_ru() was used")

/proc/get_declented_value(list/declented_list, declent, backup_value)
	if(declent == "gender")
		return declented_list[declent] || backup_value
	return declented_list[declent] || declented_list[NOMINATIVE] || backup_value

/atom/declent_ru(declent)
	. = name
	if(declent == "gender")
		. = gender
	if(!length(ru_names) || ru_names["base"] != name)
		return .
	return get_declented_value(ru_names, declent, .)

/// Used for getting initial values, such as for recipies where resulted atom is not yet created. It can return null - use var/override_backup to have a returned value guaranteed
/proc/declent_ru_initial(target_name, declent = NOMINATIVE, override_backup = null)
	. = override_backup
	if(declent == "gender")
		. = NEUTER
	var/list/declented_list = ru_names_toml(target_name)
	if(!length(declented_list))
		return .
	return get_declented_value(declented_list, declent, .)
