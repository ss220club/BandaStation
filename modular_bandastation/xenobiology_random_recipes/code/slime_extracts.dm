/datum/controller/subsystem/persistence/proc/load_slime_randomization()
	var/json_file = file("data/RandomizedSlimeRecipes.json")
	var/list/json = list()
	if(fexists(json_file))
		json = json_decode(file2text(json_file))

	for(var/reagent_id in GLOB.chemical_reactions_list_reactant_index)
		for(var/datum/chemical_reaction/slime/R in GLOB.chemical_reactions_list_reactant_index[reagent_id])
			if(!R.randomized)
				continue

			var/loaded = FALSE
			var/list/recipe_data = json["[R.type]"]

			if(recipe_data && R.LoadOldRecipe(recipe_data))
				if(daysSince(R.created) <= R.persistence_period)
					loaded = TRUE

			if(!loaded)
				R.GenerateRecipe()
				log_game("Slime Randomization: Generated new recipe for [R.type]")

/datum/controller/subsystem/persistence/proc/save_slime_randomization()
	var/json_file = file("data/RandomizedSlimeRecipes.json")
	var/list/file_data = list()

	for(var/reagent_id in GLOB.chemical_reactions_list_reactant_index)
		for(var/datum/chemical_reaction/slime/R in GLOB.chemical_reactions_list_reactant_index[reagent_id])
			if(!R.randomized || !R.persistent)
				continue

			file_data["[R.type]"] = R.SaveOldRecipe()

	if(fexists(json_file))
		fdel(json_file)
	WRITE_FILE(json_file, json_encode(file_data))

/datum/controller/subsystem/persistence/Initialize()
	. = ..()
	load_slime_randomization()

/datum/controller/subsystem/persistence/Shutdown()
	save_slime_randomization()
	return ..()

ADMIN_VERB(check_slime_randomization, R_DEBUG, "Check Slime Recipes", "Выводит текущие рандомные рецепты слаймов в чат.", "Debug")
	var/list/msg = list("<span class='adminnotice'>Текущая рандомизация слаймов:</span>")

	var/found_any = FALSE

	for(var/reagent_id in GLOB.chemical_reactions_list_reactant_index)
		for(var/datum/chemical_reaction/slime/R in GLOB.chemical_reactions_list_reactant_index[reagent_id])
			if(!R.randomized)
				continue

			found_any = TRUE

			var/extract_name = "[R.required_container]"
			extract_name = replacetext(extract_name, "/obj/item/slime_extract/", "")

			var/list/reagent_names = list()
			for(var/reag in R.required_reagents)
				var/reag_path = "[reag]"
				reag_path = replacetext(reag_path, "/datum/reagent/", "")
				reagent_names += reag_path

			var/recipe_line = "<b>[R.type]</b>: <span class='nicegreen'>[extract_name]</span> <- ([reagent_names.Join(", ")])"
			msg += recipe_line

	if(!found_any)
		to_chat(user, "<span class='adminnotice'>Рандомизированных рецептов слаймов не найдено.</span>")
		return

	to_chat(user, msg.Join("<br>"))

/datum/chemical_reaction/slime
	var/randomized = FALSE
	var/persistence_period = 4 // days
	var/created
	var/persistent = TRUE

	var/randomize_container = TRUE
	var/list/possible_containers = list(
		/obj/item/slime_extract/pink,
		/obj/item/slime_extract/gold,
		/obj/item/slime_extract/oil,
		/obj/item/slime_extract/sepia,
		/obj/item/slime_extract/cerulean,
		/obj/item/slime_extract/red,
		/obj/item/slime_extract/green,
		/obj/item/slime_extract/lightpink,
		/obj/item/slime_extract/rainbow,
		/obj/item/slime_extract/black,
		/obj/item/slime_extract/blue,
		/obj/item/slime_extract/orange,
		/obj/item/slime_extract/purple,
		/obj/item/slime_extract/darkblue,
		/obj/item/slime_extract/darkpurple,
		/obj/item/slime_extract/silver,
		/obj/item/slime_extract/yellow,
		/obj/item/slime_extract/bluespace,
		/obj/item/slime_extract/pyrite,
		/obj/item/slime_extract/adamantine
	)

/datum/chemical_reaction/slime/proc/GenerateRecipe()
	created = world.realtime
	if(randomize_container)
		required_container = pick(possible_containers)
	return TRUE

/datum/chemical_reaction/slime/proc/LoadOldRecipe(list/recipe_data)
	created = text2num(recipe_data["timestamp"])
	var/raw_container_path = recipe_data["required_container"]
	if(raw_container_path)
		var/containerpath = text2path(raw_container_path)
		if(containerpath)
			required_container = containerpath
	return TRUE

/datum/chemical_reaction/slime/proc/SaveOldRecipe()
	return list(
		"timestamp" = created,
		"required_container" = "[required_container]"
	)

/datum/chemical_reaction/slime/proc/HasConflicts()
	return FALSE

/datum/chemical_reaction/slime/New()
	randomized = TRUE

/datum/chemical_reaction/slime/slimemonkey/New()
	randomized = FALSE

/datum/chemical_reaction/slime/slimeinaprov/New()
	randomized = FALSE

/datum/chemical_reaction/slime/slimespawn/New()
	randomized = FALSE

