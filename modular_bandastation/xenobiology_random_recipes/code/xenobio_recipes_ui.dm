#define XENOBIO_RECIPE_COST 25

/datum/action/innate/xenobio_recipes
	name = "Рецепты"
	button_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "pai"

/datum/action/innate/xenobio_recipes/Activate()
	if(!target || !isliving(owner))
		return
	var/obj/machinery/computer/camera_advanced/xenobio/cons = target
	if(istype(cons))
		cons.ui_interact(owner)

GLOBAL_LIST_EMPTY_TYPED(xenobio_slime_recipe_entries, /list)

#define XENOBIO_TERMINAL_ATTEMPTS 4
#define XENOBIO_TERMINAL_OPTIONS 7
#define XENOBIO_TERMINAL_FORMULA_LEN 6
#define XENOBIO_TERMINAL_LINE_LEN 84
#define XENOBIO_TERMINAL_LINES 20
#define XENOBIO_TERMINAL_SEPARATORS "().'\[\];:=<>-+?*&"

/proc/xenobio_random_chemical_formula()
	var/static/list/elements = list("H", "C", "N", "O", "S", "P", "Cl", "Br", "F", "I", "Na", "K", "Ca", "Mg", "Fe", "Al", "Zn", "Cu")
	var/parts = rand(2, 4)
	var/out = ""
	for(var/i in 1 to parts)
		out += pick(elements)
		if(prob(70))
			out += "[rand(1, 15)]"
	return out

/proc/xenobio_random_formula_fixed_len(len)
	var/static/list/elements = list("H", "C", "N", "O", "S", "P", "Cl", "Br", "F", "I", "Na", "K", "Ca", "Mg", "Fe", "Al", "Zn", "Cu")
	var/out = ""
	while(length(out) < len)
		out += pick(elements)
		if(length(out) < len && prob(65))
			out += "[rand(1, 9)]"
	if(length(out) > len)
		out = copytext(out, 1, len + 1)
	else if(length(out) < len)
		while(length(out) < len)
			out += "[rand(0, 9)]"
	return out

GLOBAL_LIST_INIT(xenobio_slime_tiers, list(
	list(/obj/item/slime_extract/grey),                                                                                     // Tier 0
	list(/obj/item/slime_extract/orange, /obj/item/slime_extract/purple, /obj/item/slime_extract/blue, /obj/item/slime_extract/metal),  // Tier 1
	list(/obj/item/slime_extract/yellow, /obj/item/slime_extract/darkpurple, /obj/item/slime_extract/darkblue, /obj/item/slime_extract/silver), // Tier 2
	list(/obj/item/slime_extract/bluespace, /obj/item/slime_extract/sepia, /obj/item/slime_extract/cerulean, /obj/item/slime_extract/pyrite), // Tier 3
	list(/obj/item/slime_extract/red, /obj/item/slime_extract/green, /obj/item/slime_extract/pink, /obj/item/slime_extract/gold),         // Tier 4
	list(/obj/item/slime_extract/oil, /obj/item/slime_extract/black, /obj/item/slime_extract/lightpink, /obj/item/slime_extract/adamantine, /obj/item/slime_extract/rainbow), // Tier 5
))

// fucking ugly
/proc/xenobio_slime_extract_display_name(extract_path)
	var/static/list/display_names = list(
		/obj/item/slime_extract/grey = "Серый",
		/obj/item/slime_extract/orange = "Оранжевый",
		/obj/item/slime_extract/purple = "Фиолетовый",
		/obj/item/slime_extract/blue = "Синий",
		/obj/item/slime_extract/metal = "Металлический",
		/obj/item/slime_extract/yellow = "Жёлтый",
		/obj/item/slime_extract/darkpurple = "Тёмно-фиолетовый",
		/obj/item/slime_extract/darkblue = "Тёмно-синий",
		/obj/item/slime_extract/silver = "Серебряный",
		/obj/item/slime_extract/bluespace = "Блюспейс",
		/obj/item/slime_extract/sepia = "Сепия",
		/obj/item/slime_extract/cerulean = "Лазурный",
		/obj/item/slime_extract/pyrite = "Пиритовый",
		/obj/item/slime_extract/red = "Красный",
		/obj/item/slime_extract/green = "Зелёный",
		/obj/item/slime_extract/pink = "Розовый",
		/obj/item/slime_extract/gold = "Золотой",
		/obj/item/slime_extract/oil = "Масляный",
		/obj/item/slime_extract/black = "Чёрный",
		/obj/item/slime_extract/lightpink = "Светло-розовый",
		/obj/item/slime_extract/adamantine = "Адамантиновый",
		/obj/item/slime_extract/rainbow = "Радужный",
	)
	var/path_typed = ispath(extract_path) ? extract_path : text2path(extract_path)
	if(path_typed && display_names[path_typed])
		return display_names[path_typed]
	// fallback
	var/obj/item/slime_extract/E = path_typed
	if(path_typed)
		var/name = initial(E.name)
		return replacetext(name, " slime extract", "")
	return "?"

/proc/xenobio_get_slime_map_entries()
	var/list/out = list()
	var/tier_idx = 0
	for(var/list/tier_paths in GLOB.xenobio_slime_tiers)
		for(var/path in tier_paths)
			var/obj/item/slime_extract/E = path
			var/name = initial(E.name)
			var/icon_state = initial(E.icon_state)
			out += list(list(
				"path" = "[path]",
				"name" = name,
				"display_name" = xenobio_slime_extract_display_name(path),
				"icon_state" = icon_state,
				"tier" = tier_idx,
				"reaction_count" = xenobio_get_slime_reaction_count(path),
			))
		tier_idx++
	return out

/proc/xenobio_get_slime_lore(extract_path)
	// var/path = ispath(extract_path) ? extract_path : text2path(extract_path)
	// if(!path)
	return "Один из изменчивых подвидов слаймов, реакция на химикаты которых со временем меняется, из-за изменений в их ДНК."
	// var/obj/item/slime_extract/E = path
	// return initial(E.desc)

/proc/xenobio_get_active_slime_reactions()
	var/list/out = list()
	for(var/reagent_id in GLOB.chemical_reactions_list_reactant_index)
		for(var/datum/chemical_reaction/slime/R in GLOB.chemical_reactions_list_reactant_index[reagent_id])
			if(!istype(R) || R.rotation_disabled)
				continue
			out += R
	return out

/proc/xenobio_reagent_display_name(reagent_type)
	var/datum/reagent/R = reagent_type
	return initial(R.name)

/proc/xenobio_reaction_display_name(datum/chemical_reaction/slime/R)
	if(R.reaction_display_name)
		return R.reaction_display_name
	var/path = "[R.type]"
	var/last = findlasttext(path, "/")
	if(last)
		path = copytext(path, last + 1)
	return replacetext(path, "_", " ")

/proc/xenobio_get_slime_reaction_count(extract_path)
	var/path_typed = ispath(extract_path) ? extract_path : text2path(extract_path)
	if(!path_typed)
		return 0
	var/count = 0
	var/list/active = xenobio_get_active_slime_reactions()
	for(var/datum/chemical_reaction/slime/R in active)
		if(R.required_container == path_typed)
			count++
	return count


// MARK: Xenobio camera

/obj/machinery/computer/camera_advanced/xenobio
	var/datum/techweb/stored_research
	var/selected_slime_path
	var/loaded_slime_type = null
	var/list/pending_random_recipe = null
	var/list/pending_minigame_terminal_lines = null
	var/list/list/pending_minigame_terminal_words = null

	var/pending_minigame_correct_word = null
	var/pending_minigame_last_likeness = null
	var/pending_minigame_attempts_left = 0

/obj/machinery/computer/camera_advanced/xenobio/post_machine_initialize()
	. = ..()
	if(!CONFIG_GET(flag/no_default_techweb_link) && !stored_research)
		CONNECT_TO_RND_SERVER_ROUNDSTART(stored_research, src)

/obj/machinery/computer/camera_advanced/xenobio/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "XenobioRecipes", "Рецепты слаймов")
		ui.open()

/obj/machinery/computer/camera_advanced/xenobio/ui_data(mob/user)
	var/list/data = list()
	data["slimes"] = xenobio_get_slime_map_entries()
	data["research_points"] = list()
	if(stored_research)
		data["research_points"] = stored_research.research_points.Copy()
	else
		data["research_points"] = list(TECHWEB_POINT_TYPE_GENERIC = 0)
	data["recipe_cost"] = XENOBIO_RECIPE_COST
	data["loaded_slime_path"] = loaded_slime_type ? "[loaded_slime_type]" : null
	data["selected_slime"] = selected_slime_path
	data["selected_slime_lore"] = null
	data["selected_slime_reactions"] = list()
	data["slime_study_available"] = FALSE
	data["random_recipe_available"] = xenobio_has_random_recipe_available()
	data["minigame_active"] = (pending_random_recipe != null)
	if(pending_random_recipe && pending_minigame_terminal_lines)
		data["minigame_terminal_lines"] = pending_minigame_terminal_lines.Copy()
		if(pending_minigame_terminal_words)
			data["minigame_terminal_words"] = pending_minigame_terminal_words.Copy()
		data["minigame_last_likeness"] = pending_minigame_last_likeness
		data["minigame_correct_length"] = length(pending_minigame_correct_word || "")
		data["minigame_attempts_left"] = pending_minigame_attempts_left
	if(selected_slime_path)
		data["selected_slime_lore"] = xenobio_get_slime_lore(selected_slime_path)
		var/list/list/reaction_entries = GLOB.xenobio_slime_recipe_entries[selected_slime_path]
		if(reaction_entries)
			data["selected_slime_reactions"] = reaction_entries.Copy()
		data["slime_study_available"] = xenobio_slime_has_study_available(selected_slime_path)
	return data

/obj/machinery/computer/camera_advanced/xenobio/ui_static_data(mob/user)
	var/list/data = list()
	data["slimes"] = xenobio_get_slime_map_entries()
	return data

/obj/machinery/computer/camera_advanced/xenobio/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return TRUE
	switch(action)
		if("open_notes")
			open_xenobio_notes(usr)
			return TRUE
		if("open_random_recipe")
			return try_open_random_recipe(usr)
		if("guess_word")
			return try_guess_terminal_word(usr, params["word"])
		if("cancel_random_recipe_minigame")
			return try_cancel_random_recipe_minigame(usr)
		if("open_slime_detail")
			selected_slime_path = params["slime_path"]
			return TRUE
		if("close_slime_detail")
			selected_slime_path = null
			return TRUE
		if("study_slime_property")
			return try_study_slime_property(usr, params["slime_path"])
	return FALSE

/obj/machinery/computer/camera_advanced/xenobio/proc/open_xenobio_notes(mob/user)
	if(!isliving(user))
		return
	var/datum/action/innate/notes/notes_action = locate() in actions
	if(notes_action)
		notes_action.ui_interact(user)
		return
	var/json_file = file("data/XenobioNotes.json")
	var/current_notes = ""
	if(fexists(json_file))
		var/list/data = json_decode(file2text(json_file))
		current_notes = data["text"] || ""
	var/new_notes = tgui_input_text(user, "Запишите результаты экспериментов или рецепты.", "Заметки", current_notes, 9999, TRUE, FALSE)
	if(isnull(new_notes))
		return
	if(new_notes != current_notes && tgui_alert(user, "Сохранить изменения?", "Подтверждение", list("Да", "Нет")) == "Да")
		if(fexists(json_file))
			fdel(json_file)
		WRITE_FILE(json_file, json_encode(list("text" = new_notes, "timestamp" = world.realtime)))
		to_chat(user, span_nicegreen("Заметки сохранены."))

/proc/xenobio_has_random_recipe_available()
	var/list/active = xenobio_get_active_slime_reactions()
	for(var/datum/chemical_reaction/slime/R in active)
		var/key = "[R.required_container]"
		var/list/entries = GLOB.xenobio_slime_recipe_entries[key]
		var/list/reag_list = R.required_reagents
		var/reagent_type = length(reag_list) ? reag_list[1] : null
		var/reagent_name = reagent_type ? xenobio_reagent_display_name(reagent_type) : "?"
		var/reaction_name = xenobio_reaction_display_name(R)
		var/found = FALSE
		if(entries && islist(entries))
			for(var/list/ent in entries)
				if(ent["reagent"] == reagent_name && ent["reaction"] == reaction_name)
					found = TRUE
					break
		if(!found)
			return TRUE
	return FALSE

/obj/machinery/computer/camera_advanced/xenobio/proc/try_open_random_recipe(mob/user)
	var/list/active = xenobio_get_active_slime_reactions()
	if(!length(active))
		balloon_alert(user, "нет активных рецептов")
		return TRUE
	if(!stored_research)
		balloon_alert(user, "нет связи с R&D")
		return TRUE
	var/points = stored_research.research_points[TECHWEB_POINT_TYPE_GENERIC] || 0
	if(points < XENOBIO_RECIPE_COST)
		balloon_alert(user, "недостаточно очков ([XENOBIO_RECIPE_COST] нужно)")
		return TRUE
	var/list/available = list()
	for(var/datum/chemical_reaction/slime/R in active)
		var/key = "[R.required_container]"
		var/list/entries = GLOB.xenobio_slime_recipe_entries[key]
		var/list/reag_list = R.required_reagents
		var/reagent_type = length(reag_list) ? reag_list[1] : null
		var/reagent_name = reagent_type ? xenobio_reagent_display_name(reagent_type) : "?"
		var/reaction_name = xenobio_reaction_display_name(R)
		var/found = FALSE
		if(entries && islist(entries))
			for(var/list/ent in entries)
				if(ent["reagent"] == reagent_name && ent["reaction"] == reaction_name)
					found = TRUE
					break
		if(!found)
			available += R
	if(!length(available))
		balloon_alert(user, "все рецепты уже открыты")
		return TRUE
	stored_research.remove_point_type(TECHWEB_POINT_TYPE_GENERIC, XENOBIO_RECIPE_COST)
	var/datum/chemical_reaction/slime/picked = pick(available)
	var/container_path = picked.required_container
	var/list/reag_list = picked.required_reagents
	var/reagent_type = length(reag_list) ? reag_list[1] : null
	var/reagent_name = reagent_type ? xenobio_reagent_display_name(reagent_type) : "?"
	var/reaction_name = xenobio_reaction_display_name(picked)
	var/key = "[container_path]"
	pending_random_recipe = list(
		"key" = key,
		"reagent" = reagent_name,
		"reaction" = reaction_name,
	)
	xenobio_build_terminal_puzzle(src)
	return TRUE

/obj/machinery/computer/camera_advanced/xenobio/proc/xenobio_build_terminal_puzzle(obj/machinery/computer/camera_advanced/xenobio/cons)
	var/formula_len = XENOBIO_TERMINAL_FORMULA_LEN
	var/correct_formula = xenobio_random_formula_fixed_len(formula_len)
	var/list/options = list(correct_formula)
	var/list/seen = list(correct_formula = TRUE)
	for(var/i in 1 to (XENOBIO_TERMINAL_OPTIONS - 1))
		var/candidate = xenobio_random_formula_fixed_len(formula_len)
		if(seen[candidate])
			continue
		seen[candidate] = TRUE
		options += candidate
	while(length(options) < XENOBIO_TERMINAL_OPTIONS)
		var/candidate = xenobio_random_formula_fixed_len(formula_len)
		if(!seen[candidate])
			seen[candidate] = TRUE
			options += candidate
	shuffle_inplace(options)
	var/len_line = XENOBIO_TERMINAL_LINE_LEN
	var/sep_len = length(XENOBIO_TERMINAL_SEPARATORS)
	var/list/grid = list()
	for(var/line in 1 to XENOBIO_TERMINAL_LINES)
		var/line_str = ""
		while(length(line_str) < len_line)
			line_str += xenobio_random_chemical_formula()
			if(length(line_str) >= len_line)
				break
			var/num_seps = prob(50) ? 2 : 1
			for(var/s in 1 to num_seps)
				var/p = rand(1, sep_len)
				line_str += copytext(XENOBIO_TERMINAL_SEPARATORS, p, p + 1)
				if(length(line_str) >= len_line)
					break
		if(length(line_str) > len_line)
			line_str = copytext(line_str, 1, len_line + 1)
		grid += list(line_str)
	var/list/list/word_entries = list()
	var/list/available_lines = list()
	for(var/i in 1 to XENOBIO_TERMINAL_LINES)
		available_lines += i
	shuffle_inplace(available_lines)
	for(var/idx in 1 to length(options))
		var/formula = options[idx]
		var/line_idx = available_lines[idx]
		var/start = rand(1, len_line - length(formula) + 1)
		if(start < 1)
			start = 1
		var/line_str = grid[line_idx]
		for(var/j in 1 to length(formula))
			var/pos = start + j - 1
			line_str = copytext(line_str, 1, pos) + copytext(formula, j, j + 1) + copytext(line_str, pos + 1)
		grid[line_idx] = line_str
		word_entries += list(list("word" = formula, "line" = line_idx - 1, "start" = start - 1))
	cons.pending_minigame_terminal_lines = grid
	cons.pending_minigame_terminal_words = word_entries
	cons.pending_minigame_correct_word = correct_formula
	cons.pending_minigame_last_likeness = null
	cons.pending_minigame_attempts_left = XENOBIO_TERMINAL_ATTEMPTS

/proc/xenobio_terminal_likeness(word, correct)
	var/c = 0
	var/len = min(length(word), length(correct))
	for(var/i in 1 to len)
		if(copytext(word, i, i + 1) == copytext(correct, i, i + 1))
			c++
	return c

/obj/machinery/computer/camera_advanced/xenobio/proc/try_guess_terminal_word(mob/user, word)
	if(!pending_random_recipe || !pending_minigame_correct_word)
		return FALSE
	if(pending_minigame_attempts_left <= 0)
		return TRUE
	if(word == pending_minigame_correct_word)
		var/key = pending_random_recipe["key"]
		var/reagent_name = pending_random_recipe["reagent"]
		var/reaction_name = pending_random_recipe["reaction"]
		if(!GLOB.xenobio_slime_recipe_entries[key])
			GLOB.xenobio_slime_recipe_entries[key] = list()
		GLOB.xenobio_slime_recipe_entries[key] += list(list(
			"reagent" = reagent_name,
			"reaction" = reaction_name,
			"locked" = TRUE,
		))
		playsound(src, 'sound/machines/high_tech_confirm.ogg', 30, vary = FALSE)
		balloon_alert(user, "рецепт открыт: [reaction_name]")
		pending_random_recipe = null
		pending_minigame_terminal_lines = null
		pending_minigame_terminal_words = null
		pending_minigame_correct_word = null
		pending_minigame_last_likeness = null
		pending_minigame_attempts_left = 0
		return TRUE
	pending_minigame_attempts_left--
	pending_minigame_last_likeness = xenobio_terminal_likeness(word, pending_minigame_correct_word)
	return TRUE

/obj/machinery/computer/camera_advanced/xenobio/proc/try_cancel_random_recipe_minigame(mob/user)
	if(pending_random_recipe)
		pending_random_recipe = null
		pending_minigame_terminal_lines = null
		pending_minigame_terminal_words = null
		pending_minigame_correct_word = null
		pending_minigame_last_likeness = null
		pending_minigame_attempts_left = 0
	return TRUE

/proc/xenobio_slime_has_study_available(slime_path)
	var/slime_path_typed = text2path(slime_path)
	if(!slime_path_typed)
		return FALSE
	var/list/entries = GLOB.xenobio_slime_recipe_entries[slime_path]
	var/list/already = list()
	if(entries && islist(entries))
		for(var/list/ent in entries)
			already["[ent["reagent"]]|[ent["reaction"]]"] = TRUE
	var/list/active = xenobio_get_active_slime_reactions()
	for(var/datum/chemical_reaction/slime/R in active)
		if(R.required_container != slime_path_typed)
			continue
		var/list/reag_list = R.required_reagents
		var/reagent_type = length(reag_list) ? reag_list[1] : null
		var/reagent_name = reagent_type ? xenobio_reagent_display_name(reagent_type) : "?"
		var/reaction_name = xenobio_reaction_display_name(R)
		if(!already["[reagent_name]|[reaction_name]"])
			return TRUE
	return FALSE

/obj/machinery/computer/camera_advanced/xenobio/proc/try_study_slime_property(mob/user, slime_path)
	if(!slime_path)
		return FALSE
	var/slime_path_typed = text2path(slime_path)
	if(loaded_slime_type != slime_path_typed)
		balloon_alert(user, "загрузите данные этого слайма сканером")
		return TRUE
	if(!stored_research)
		balloon_alert(user, "нет связи с R&D")
		return TRUE
	var/points = stored_research.research_points[TECHWEB_POINT_TYPE_GENERIC] || 0
	if(points < XENOBIO_RECIPE_COST)
		balloon_alert(user, "недостаточно очков ([XENOBIO_RECIPE_COST] нужно)")
		return TRUE
	var/list/entries = GLOB.xenobio_slime_recipe_entries[slime_path]
	var/list/already_added = list()
	if(entries && islist(entries))
		for(var/list/ent in entries)
			already_added["[ent["reagent"]]|[ent["reaction"]]"] = TRUE
	var/list/active = xenobio_get_active_slime_reactions()
	var/list/for_slime = list()
	for(var/datum/chemical_reaction/slime/R in active)
		if(R.required_container != slime_path_typed)
			continue
		var/list/reag_list = R.required_reagents
		var/reagent_type = length(reag_list) ? reag_list[1] : null
		var/reagent_name = reagent_type ? xenobio_reagent_display_name(reagent_type) : "?"
		var/reaction_name = xenobio_reaction_display_name(R)
		if(already_added["[reagent_name]|[reaction_name]"])
			continue
		for_slime += R
	if(!length(for_slime))
		balloon_alert(user, "все рецепты этого слайма уже изучены")
		return TRUE
	balloon_alert(user, "сканирование образца...")
	if(!do_after(user, 2.5 SECONDS, target = src, progress = TRUE))
		return TRUE
	playsound(src, 'sound/machines/terminal/terminal_processing.ogg', 25, vary = TRUE)
	var/datum/chemical_reaction/slime/picked = pick(for_slime)
	var/list/reag_list = picked.required_reagents
	var/reagent_type = length(reag_list) ? reag_list[1] : null
	var/reagent_name = reagent_type ? xenobio_reagent_display_name(reagent_type) : "?"
	var/reaction_name = xenobio_reaction_display_name(picked)
	var/key = "[picked.required_container]"
	if(!GLOB.xenobio_slime_recipe_entries[key])
		GLOB.xenobio_slime_recipe_entries[key] = list()
	GLOB.xenobio_slime_recipe_entries[key] += list(list(
		"reagent" = reagent_name,
		"reaction" = reaction_name,
		"locked" = TRUE,
	))
	stored_research.remove_point_type(TECHWEB_POINT_TYPE_GENERIC, XENOBIO_RECIPE_COST)
	playsound(src, 'sound/machines/high_tech_confirm.ogg', 30, vary = FALSE)
	balloon_alert(user, "рецепт открыт: [reaction_name]")
	return TRUE

/obj/machinery/computer/camera_advanced/xenobio/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = ..()
	if(.)
		return .
	if(istype(tool, /obj/item/slime_scanner))
		return load_slime_from_scanner(user, tool)
	return NONE

/obj/machinery/computer/camera_advanced/xenobio/proc/load_slime_from_scanner(mob/living/user, obj/item/slime_scanner/scanner)
	if(!scanner.stored_slime_extract_path)
		balloon_alert(user, "в сканере нет данных слайма")
		return NONE
	loaded_slime_type = scanner.stored_slime_extract_path
	scanner.stored_slime_extract_path = null
	playsound(src, 'sound/machines/terminal/terminal_processing.ogg', 20, vary = TRUE)
	to_chat(user, span_nicegreen("Данные слайма загружены в консоль. Можно изучить свойства этого слайма."))
	return ITEM_INTERACT_SUCCESS
