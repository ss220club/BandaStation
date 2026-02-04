#define SLIME_RECIPE_POSITIVE "Positive"
#define SLIME_RECIPE_NEGATIVE "Negative"
#define SLIME_RECIPE_FUN "Fun"

/datum/controller/subsystem/persistence/proc/load_slime_randomization()
	var/json_file = file("data/RandomizedSlimeRecipes.json")
	var/list/json = list()
	if(fexists(json_file))
		json = json_decode(file2text(json_file))

	var/list/to_process = list()
	for(var/reagent_id in GLOB.chemical_reactions_list_reactant_index)
		for(var/datum/chemical_reaction/slime/R in GLOB.chemical_reactions_list_reactant_index[reagent_id])
			if(R.randomized)
				to_process += R

	to_process = shuffle(to_process)

	var/list/used_recipe_keys = list()
	for(var/datum/chemical_reaction/slime/R in to_process)
		remove_chemical_reaction(R)
		R.rotation_disabled = FALSE
		var/loaded = FALSE
		var/list/recipe_data = json["[R.type]"]
		if(recipe_data && R.LoadOldRecipe(recipe_data) && daysSince(R.created) <= R.persistence_period)
			if(R.rotation_disabled)
				loaded = TRUE
			else
				var/key = R.get_recipe_key()
				if(used_recipe_keys[key])
					R.rotation_disabled = TRUE
					loaded = TRUE
				else
					used_recipe_keys[key] = TRUE
					loaded = TRUE
		if(!loaded)
			if(R.GenerateRecipe(used_recipe_keys))
				log_game("Slime Randomization: Generated new recipe for [R.type]")
			else
				R.rotation_disabled = TRUE
				log_game("Slime Randomization: [R.type] disabled this rotation (collision).")
		if(!R.rotation_disabled)
			add_chemical_reaction(R)

/datum/controller/subsystem/persistence/proc/save_slime_randomization()
	var/json_file = file("data/RandomizedSlimeRecipes.json")
	var/list/file_data = list()

	for(var/path in GLOB.chemical_reactions_list)
		var/datum/chemical_reaction/slime/R = GLOB.chemical_reactions_list[path]
		if(!istype(R) || !R.randomized || !R.persistent)
			continue
		file_data["[path]"] = R.SaveOldRecipe()

	if(fexists(json_file))
		fdel(json_file)
	WRITE_FILE(json_file, json_encode(file_data))

/datum/controller/subsystem/persistence/Initialize()
	. = ..()
	load_slime_randomization()

/datum/controller/subsystem/persistence/Shutdown()
	save_slime_randomization()
	return ..()

/datum/chemical_reaction/slime
	var/randomized = FALSE
	var/persistence_period = 2 // days
	var/created
	var/persistent = TRUE
	reaction_flags = REACTION_INSTANT | REACTION_COMPETITIVE

	var/rotation_disabled = FALSE

	// gonna use it later
	required_temp = 0

	// does nothing for now
	var/recipe_category = SLIME_RECIPE_POSITIVE

	//list(required_container, list(reagent_type = amount), required_temp or 0)
	var/list/recipe_variants = list()

/datum/chemical_reaction/slime/proc/get_rotation_index()
	var/period_ds = persistence_period * (24 HOURS)
	if(period_ds <= 0)
		return 0
	return round(world.realtime / period_ds)

/datum/chemical_reaction/slime/proc/get_variant_index()
	if(!length(recipe_variants))
		return 0
	var/rot = get_rotation_index()
	var/seed = length("[type]") * 31
	return (rot + seed) % length(recipe_variants) + 1

/datum/chemical_reaction/slime/proc/get_recipe_key()
	var/list/parts = list()
	for(var/r in required_reagents)
		parts += "[r]"
	parts = sort_list(parts)
	return "[required_container]_[parts.Join(";")]"

// /datum/chemical_reaction/slime/proc/ApplyVariant(list/list/variant)
// 	if(length(variant) < 2)
// 		return FALSE
// 	required_container = variant[1]
// 	var/list/reagents_src = variant[2]
// 	required_reagents = reagents_src.Copy()
// 	required_temp = 0
// 	return TRUE

/datum/chemical_reaction/slime/proc/GenerateRecipe(list/used_recipe_keys)
	created = world.realtime
	if(!length(recipe_variants))
		return FALSE

	var/list/list/order = shuffle(recipe_variants.Copy())
	for(var/list/variant in order)
		if(length(variant) < 2)
			continue
		required_container = variant[1]
		var/list/reagents_src = variant[2]
		required_reagents = reagents_src.Copy()
		required_temp = 0
		var/key = get_recipe_key()
		if(!used_recipe_keys[key])
			used_recipe_keys[key] = TRUE
			return TRUE
	return FALSE

/datum/chemical_reaction/slime/proc/LoadOldRecipe(list/recipe_data)
	created = text2num(recipe_data["timestamp"])
	rotation_disabled = recipe_data["rotation_disabled"] ? TRUE : FALSE
	if(rotation_disabled)
		required_temp = 0
		return TRUE
	var/raw_container = recipe_data["required_container"]
	if(raw_container)
		var/containerpath = text2path(raw_container)
		if(containerpath)
			required_container = containerpath

	var/list/saved_reagents = recipe_data["required_reagents"]
	if(islist(saved_reagents) && length(saved_reagents))
		required_reagents = list()
		for(var/key in saved_reagents)
			var/p = text2path(key)
			if(p)
				required_reagents[p] = saved_reagents[key]
	else
		return FALSE

	required_temp = 0
	return TRUE

/datum/chemical_reaction/slime/proc/SaveOldRecipe()
	var/list/reagent_strings = list()
	for(var/r in required_reagents)
		reagent_strings["[r]"] = required_reagents[r]
	return list(
		"timestamp" = created,
		"rotation_disabled" = rotation_disabled,
		"required_container" = "[required_container]",
		"required_reagents" = reagent_strings,
		"required_temp" = required_temp
	)

/datum/chemical_reaction/slime/New()
	if(length(recipe_variants))
		randomized = TRUE

/datum/chemical_reaction/slime/slimemonkey/New()
	randomized = FALSE

/datum/chemical_reaction/slime/slimeinaprov/New()
	randomized = FALSE

/datum/chemical_reaction/slime/slimespawn/New()
	randomized = FALSE

// MARK: Positive

/datum/chemical_reaction/slime/slimespeed
	recipe_category = SLIME_RECIPE_POSITIVE
	recipe_variants = list(
		list(/obj/item/slime_extract/red,   list(/datum/reagent/water = 10), 0),
		list(/obj/item/slime_extract/black, list(/datum/reagent/blood = 10), 444),
		list(/obj/item/slime_extract/blue, list(/datum/reagent/water = 10), 300),
		list(/obj/item/slime_extract/purple, list(/datum/reagent/water = 10), 350),
		list(/obj/item/slime_extract/orange, list(/datum/reagent/nitrogen = 10), 0),
		list(/obj/item/slime_extract/cerulean, list(/datum/reagent/carbon = 10), 0),
	)

/datum/chemical_reaction/slime/slimestabilizer
	recipe_category = SLIME_RECIPE_POSITIVE
	recipe_variants = list(
		list(/obj/item/slime_extract/blue, list(/datum/reagent/blood = 10), 0),
		list(/obj/item/slime_extract/grey, list(/datum/reagent/nitrogen = 10), 280),
		list(/obj/item/slime_extract/pink, list(/datum/reagent/blood = 10), 320),
		list(/obj/item/slime_extract/cerulean, list(/datum/reagent/water = 10), 300),
		list(/obj/item/slime_extract/darkblue, list(/datum/reagent/silicon = 10), 0),
		list(/obj/item/slime_extract/sepia, list(/datum/reagent/nitrogen = 10), 0),
	)

/datum/chemical_reaction/slime/slimeregen
	recipe_category = SLIME_RECIPE_POSITIVE
	recipe_variants = list(
		list(/obj/item/slime_extract/purple, list(/datum/reagent/blood = 10), 0),
		list(/obj/item/slime_extract/red, list(/datum/reagent/toxin/plasma = 10), 400),
		list(/obj/item/slime_extract/blue, list(/datum/reagent/blood = 10), 310),
		list(/obj/item/slime_extract/lightpink, list(/datum/reagent/blood = 10), 330),
		list(/obj/item/slime_extract/green, list(/datum/reagent/toxin/mutagen = 10), 0),
		list(/obj/item/slime_extract/yellow, list(/datum/reagent/carbon = 10), 0),
	)

/datum/chemical_reaction/slime/slimefireproof
	recipe_category = SLIME_RECIPE_POSITIVE
	recipe_variants = list(
		list(/obj/item/slime_extract/darkblue, list(/datum/reagent/water = 10), 0),
		list(/obj/item/slime_extract/blue, list(/datum/reagent/water = 10), 270),
		list(/obj/item/slime_extract/grey, list(/datum/reagent/consumable/ethanol = 10), 290),
		list(/obj/item/slime_extract/bluespace, list(/datum/reagent/nitrogen = 10), 0),
		list(/obj/item/slime_extract/lightpink, list(/datum/reagent/silicon = 10), 0),
	)

/datum/chemical_reaction/slime/slimeglow
	recipe_category = SLIME_RECIPE_POSITIVE
	recipe_variants = list(
		list(/obj/item/slime_extract/yellow, list(/datum/reagent/water = 10), 0),
		list(/obj/item/slime_extract/blue, list(/datum/reagent/water = 10), 320),
		list(/obj/item/slime_extract/rainbow, list(/datum/reagent/water = 10), 380),
	)

/datum/chemical_reaction/slime/slimeradio
	recipe_category = SLIME_RECIPE_POSITIVE
	recipe_variants = list(
		list(/obj/item/slime_extract/bluespace, list(/datum/reagent/water = 10), 0),
		list(/obj/item/slime_extract/cerulean, list(/datum/reagent/water = 10), 350),
		list(/obj/item/slime_extract/pyrite, list(/datum/reagent/water = 10), 360),
	)

/datum/chemical_reaction/slime/docility
	recipe_category = SLIME_RECIPE_POSITIVE
	recipe_variants = list(
		list(/obj/item/slime_extract/pink, list(/datum/reagent/toxin/plasma = 10), 0),
		list(/obj/item/slime_extract/lightpink, list(/datum/reagent/water = 10), 300),
		list(/obj/item/slime_extract/lightpink, list(/datum/reagent/toxin/plasma = 10), 320),
	)

/datum/chemical_reaction/slime/slimepsteroid
	recipe_category = SLIME_RECIPE_POSITIVE
	recipe_variants = list(
		list(/obj/item/slime_extract/purple, list(/datum/reagent/toxin/plasma = 10), 0),
		list(/obj/item/slime_extract/red, list(/datum/reagent/toxin/plasma = 10), 380),
		list(/obj/item/slime_extract/metal, list(/datum/reagent/toxin/plasma = 10), 400),
	)

/datum/chemical_reaction/slime/slimepsteroid2
	recipe_category = SLIME_RECIPE_POSITIVE
	recipe_variants = list(
		list(/obj/item/slime_extract/cerulean, list(/datum/reagent/toxin/plasma = 10), 0),
		list(/obj/item/slime_extract/purple, list(/datum/reagent/toxin/plasma = 10), 390),
		list(/obj/item/slime_extract/yellow, list(/datum/reagent/toxin/plasma = 10), 370),
	)

/datum/chemical_reaction/slime/slimemutator
	recipe_category = SLIME_RECIPE_POSITIVE
	recipe_variants = list(
		list(/obj/item/slime_extract/red, list(/datum/reagent/toxin/plasma = 10), 0),
		list(/obj/item/slime_extract/black, list(/datum/reagent/toxin/plasma = 10), 420),
		list(/obj/item/slime_extract/rainbow, list(/datum/reagent/toxin/plasma = 10), 400),
		list(/obj/item/slime_extract/green, list(/datum/reagent/toxin/mutagen = 10), 0),
		list(/obj/item/slime_extract/oil, list(/datum/reagent/toxin/mutagen = 10), 0),
	)

/datum/chemical_reaction/slime/slimemetal
	recipe_category = SLIME_RECIPE_POSITIVE
	recipe_variants = list(
		list(/obj/item/slime_extract/metal, list(/datum/reagent/toxin/plasma = 10), 0),
		list(/obj/item/slime_extract/darkpurple, list(/datum/reagent/toxin/plasma = 10), 450),
		list(/obj/item/slime_extract/grey, list(/datum/reagent/toxin/plasma = 10), 420),
		list(/obj/item/slime_extract/gold, list(/datum/reagent/iron = 10), 0),
		list(/obj/item/slime_extract/silver, list(/datum/reagent/iron = 10), 0),
		list(/obj/item/slime_extract/red, list(/datum/reagent/carbon = 10), 0),
	)

/datum/chemical_reaction/slime/slimeglass
	recipe_category = SLIME_RECIPE_POSITIVE
	recipe_variants = list(
		list(/obj/item/slime_extract/metal, list(/datum/reagent/water = 10), 0),
		list(/obj/item/slime_extract/blue, list(/datum/reagent/water = 10), 300),
		list(/obj/item/slime_extract/darkblue, list(/datum/reagent/water = 10), 280),
		list(/obj/item/slime_extract/cerulean, list(/datum/reagent/silicon = 10), 0),
		list(/obj/item/slime_extract/sepia, list(/datum/reagent/silicon = 10), 0),
		list(/obj/item/slime_extract/pyrite, list(/datum/reagent/iron = 10), 0),
	)

/datum/chemical_reaction/slime/adamantine
	recipe_category = SLIME_RECIPE_POSITIVE
	recipe_variants = list(
		list(/obj/item/slime_extract/adamantine, list(/datum/reagent/toxin/plasma = 10), 0),
		list(/obj/item/slime_extract/metal, list(/datum/reagent/toxin/plasma = 10), 600),
		list(/obj/item/slime_extract/darkpurple, list(/datum/reagent/toxin/plasma = 10), 580),
	)

// MARK: Negative

/datum/chemical_reaction/slime/slimebloodlust
	recipe_category = SLIME_RECIPE_NEGATIVE
	recipe_variants = list(
		list(/obj/item/slime_extract/red, list(/datum/reagent/blood = 10), 0),
		list(/obj/item/slime_extract/black, list(/datum/reagent/blood = 10), 400),
		list(/obj/item/slime_extract/orange, list(/datum/reagent/blood = 10), 450),
	)

/datum/chemical_reaction/slime/slimeoverload
	recipe_category = SLIME_RECIPE_NEGATIVE
	recipe_variants = list(
		list(/obj/item/slime_extract/yellow, list(/datum/reagent/blood = 10), 0),
		list(/obj/item/slime_extract/oil, list(/datum/reagent/blood = 10), 500),
		list(/obj/item/slime_extract/red, list(/datum/reagent/blood = 10), 480),
	)

/datum/chemical_reaction/slime/slimefreeze
	recipe_category = SLIME_RECIPE_NEGATIVE
	recipe_variants = list(
		list(/obj/item/slime_extract/darkblue, list(/datum/reagent/toxin/plasma = 10), 0),
		list(/obj/item/slime_extract/blue, list(/datum/reagent/toxin/plasma = 10), 250),
		list(/obj/item/slime_extract/grey, list(/datum/reagent/nitrogen = 10), 200),
	)

/datum/chemical_reaction/slime/slimeexplosion
	recipe_category = SLIME_RECIPE_NEGATIVE
	recipe_variants = list(
		list(/obj/item/slime_extract/oil, list(/datum/reagent/toxin/plasma = 10), 0),
		list(/obj/item/slime_extract/orange, list(/datum/reagent/toxin/plasma = 15), 600),
		list(/obj/item/slime_extract/red, list(/datum/reagent/toxin/plasma = 15), 550),
	)

/datum/chemical_reaction/slime/slimemutate2
	recipe_category = SLIME_RECIPE_NEGATIVE
	recipe_variants = list(
		list(/obj/item/slime_extract/black, list(/datum/reagent/toxin/plasma = 10), 0),
		list(/obj/item/slime_extract/green, list(/datum/reagent/toxin/plasma = 10), 380),
		list(/obj/item/slime_extract/darkpurple, list(/datum/reagent/toxin/plasma = 10), 400),
		list(/obj/item/slime_extract/rainbow, list(/datum/reagent/toxin/mutagen = 10), 0),
		list(/obj/item/slime_extract/red, list(/datum/reagent/toxin/mutagen = 10), 0),
	)

/datum/chemical_reaction/slime/slimemobspawn
	recipe_category = SLIME_RECIPE_NEGATIVE
	recipe_variants = list(
		list(/obj/item/slime_extract/gold, list(/datum/reagent/toxin/plasma = 10), 0),
		list(/obj/item/slime_extract/black, list(/datum/reagent/toxin/plasma = 10), 450),
		list(/obj/item/slime_extract/oil, list(/datum/reagent/toxin/plasma = 10), 500),
	)

/datum/chemical_reaction/slime/slimefire
	recipe_category = SLIME_RECIPE_NEGATIVE
	recipe_variants = list(
		list(/obj/item/slime_extract/orange, list(/datum/reagent/toxin/plasma = 10), 0),
		list(/obj/item/slime_extract/red, list(/datum/reagent/toxin/plasma = 10), 550),
		list(/obj/item/slime_extract/oil, list(/datum/reagent/toxin/plasma = 10), 520),
	)

// MARK: Fun

/datum/chemical_reaction/slime/slimebork
	recipe_category = SLIME_RECIPE_FUN
	recipe_variants = list(
		list(/obj/item/slime_extract/silver, list(/datum/reagent/toxin/plasma = 10), 0),
		list(/obj/item/slime_extract/rainbow, list(/datum/reagent/toxin/plasma = 10), 350),
		list(/obj/item/slime_extract/pink, list(/datum/reagent/toxin/plasma = 10), 330),
	)

/datum/chemical_reaction/slime/slimefrost
	recipe_category = SLIME_RECIPE_FUN
	recipe_variants = list(
		list(/obj/item/slime_extract/blue, list(/datum/reagent/toxin/plasma = 10), 0),
		list(/obj/item/slime_extract/darkblue, list(/datum/reagent/toxin/plasma = 10), 260),
		list(/obj/item/slime_extract/cerulean, list(/datum/reagent/toxin/plasma = 10), 290),
	)

/datum/chemical_reaction/slime/slimefoam
	recipe_category = SLIME_RECIPE_FUN
	recipe_variants = list(
		list(/obj/item/slime_extract/blue, list(/datum/reagent/water = 10), 0),
		list(/obj/item/slime_extract/grey, list(/datum/reagent/water = 10), 300),
		list(/obj/item/slime_extract/lightpink, list(/datum/reagent/water = 10), 320),
		list(/obj/item/slime_extract/rainbow, list(/datum/reagent/carbon = 10), 0),
		list(/obj/item/slime_extract/pink, list(/datum/reagent/nitrogen = 10), 0),
	)

/datum/chemical_reaction/slime/slimecell
	recipe_category = SLIME_RECIPE_FUN
	recipe_variants = list(
		list(/obj/item/slime_extract/yellow, list(/datum/reagent/toxin/plasma = 10), 0),
		list(/obj/item/slime_extract/metal, list(/datum/reagent/toxin/plasma = 10), 400),
		list(/obj/item/slime_extract/bluespace, list(/datum/reagent/toxin/plasma = 10), 380),
	)

/datum/chemical_reaction/slime/slimeplasma
	recipe_category = SLIME_RECIPE_FUN
	recipe_variants = list(
		list(/obj/item/slime_extract/darkpurple, list(/datum/reagent/toxin/plasma = 10), 0),
		list(/obj/item/slime_extract/purple, list(/datum/reagent/toxin/plasma = 10), 420),
		list(/obj/item/slime_extract/oil, list(/datum/reagent/toxin/plasma = 10), 450),
	)

/datum/chemical_reaction/slime/slimecrystal
	recipe_category = SLIME_RECIPE_FUN
	recipe_variants = list(
		list(/obj/item/slime_extract/bluespace, list(/datum/reagent/toxin/plasma = 10), 0),
		list(/obj/item/slime_extract/cerulean, list(/datum/reagent/toxin/plasma = 10), 350),
		list(/obj/item/slime_extract/rainbow, list(/datum/reagent/toxin/plasma = 10), 400),
	)

/datum/chemical_reaction/slime/slimefloor2
	recipe_category = SLIME_RECIPE_FUN
	recipe_variants = list(
		list(/obj/item/slime_extract/bluespace, list(/datum/reagent/blood = 10), 0),
		list(/obj/item/slime_extract/sepia, list(/datum/reagent/blood = 10), 320),
		list(/obj/item/slime_extract/rainbow, list(/datum/reagent/blood = 10), 360),
	)

/datum/chemical_reaction/slime/slime_territory
	recipe_category = SLIME_RECIPE_FUN
	recipe_variants = list(
		list(/obj/item/slime_extract/cerulean, list(/datum/reagent/blood = 10), 0),
		list(/obj/item/slime_extract/bluespace, list(/datum/reagent/blood = 10), 340),
		list(/obj/item/slime_extract/pyrite, list(/datum/reagent/blood = 10), 330),
	)

/datum/chemical_reaction/slime/slimestop
	recipe_category = SLIME_RECIPE_FUN
	recipe_variants = list(
		list(/obj/item/slime_extract/sepia, list(/datum/reagent/toxin/plasma = 10), 0),
		list(/obj/item/slime_extract/rainbow, list(/datum/reagent/toxin/plasma = 10), 380),
		list(/obj/item/slime_extract/grey, list(/datum/reagent/toxin/plasma = 10), 350),
	)

/datum/chemical_reaction/slime/slimecamera
	recipe_category = SLIME_RECIPE_FUN
	recipe_variants = list(
		list(/obj/item/slime_extract/sepia, list(/datum/reagent/water = 10), 0),
		list(/obj/item/slime_extract/pyrite, list(/datum/reagent/water = 10), 300),
		list(/obj/item/slime_extract/silver, list(/datum/reagent/water = 10), 310),
		list(/obj/item/slime_extract/cerulean, list(/datum/reagent/silicon = 10), 0),
		list(/obj/item/slime_extract/adamantine, list(/datum/reagent/iron = 10), 0),
	)

/datum/chemical_reaction/slime/slimefloor
	recipe_category = SLIME_RECIPE_FUN
	recipe_variants = list(
		list(/obj/item/slime_extract/sepia, list(/datum/reagent/blood = 10), 0),
		list(/obj/item/slime_extract/pyrite, list(/datum/reagent/blood = 10), 320),
		list(/obj/item/slime_extract/cerulean, list(/datum/reagent/blood = 10), 330),
		list(/obj/item/slime_extract/grey, list(/datum/reagent/iron = 10), 0),
		list(/obj/item/slime_extract/metal, list(/datum/reagent/iron = 10), 0),
	)

/datum/chemical_reaction/slime/slimepaint
	recipe_category = SLIME_RECIPE_FUN
	recipe_variants = list(
		list(/obj/item/slime_extract/pyrite, list(/datum/reagent/toxin/plasma = 10), 0),
		list(/obj/item/slime_extract/rainbow, list(/datum/reagent/toxin/plasma = 10), 370),
		list(/obj/item/slime_extract/silver, list(/datum/reagent/toxin/plasma = 10), 390),
	)

/datum/chemical_reaction/slime/slimecrayon
	recipe_category = SLIME_RECIPE_FUN
	recipe_variants = list(
		list(/obj/item/slime_extract/pyrite, list(/datum/reagent/blood = 10), 0),
		list(/obj/item/slime_extract/rainbow, list(/datum/reagent/blood = 10), 340),
		list(/obj/item/slime_extract/pink, list(/datum/reagent/blood = 10), 330),
	)

/datum/chemical_reaction/slime/slime_rng
	recipe_category = SLIME_RECIPE_FUN
	recipe_variants = list(
		list(/obj/item/slime_extract/rainbow, list(/datum/reagent/toxin/plasma = 10), 0),
		list(/obj/item/slime_extract/gold, list(/datum/reagent/toxin/plasma = 10), 400),
		list(/obj/item/slime_extract/black, list(/datum/reagent/toxin/plasma = 10), 420),
	)

/datum/chemical_reaction/slime/slime_transfer
	recipe_category = SLIME_RECIPE_FUN
	recipe_variants = list(
		list(/obj/item/slime_extract/rainbow, list(/datum/reagent/blood = 10), 0),
		list(/obj/item/slime_extract/lightpink, list(/datum/reagent/blood = 10), 350),
		list(/obj/item/slime_extract/purple, list(/datum/reagent/blood = 10), 360),
	)

/datum/chemical_reaction/slime/slimepotion2
	recipe_category = SLIME_RECIPE_FUN
	recipe_variants = list(
		list(/obj/item/slime_extract/lightpink, list(/datum/reagent/toxin/plasma = 10), 0),
		list(/obj/item/slime_extract/rainbow, list(/datum/reagent/toxin/plasma = 10), 380),
		list(/obj/item/slime_extract/pink, list(/datum/reagent/toxin/plasma = 10), 370),
	)

/datum/chemical_reaction/slime/renaming
	recipe_category = SLIME_RECIPE_FUN
	recipe_variants = list(
		list(/obj/item/slime_extract/lightpink, list(/datum/reagent/water = 10), 0),
		list(/obj/item/slime_extract/pink, list(/datum/reagent/water = 10), 300),
		list(/obj/item/slime_extract/rainbow, list(/datum/reagent/water = 10), 320),
	)

/datum/chemical_reaction/slime/gender
	recipe_category = SLIME_RECIPE_FUN
	recipe_variants = list(
		list(/obj/item/slime_extract/pink, list(/datum/reagent/blood = 10), 0),
		list(/obj/item/slime_extract/lightpink, list(/datum/reagent/blood = 10), 330),
		list(/obj/item/slime_extract/rainbow, list(/datum/reagent/blood = 10), 340),
	)

/datum/chemical_reaction/slime/slimecasp
	recipe_category = SLIME_RECIPE_FUN
	recipe_variants = list(
		list(/obj/item/slime_extract/orange, list(/datum/reagent/blood = 10), 0),
		list(/obj/item/slime_extract/red, list(/datum/reagent/blood = 10), 400),
		list(/obj/item/slime_extract/yellow, list(/datum/reagent/blood = 10), 420),
	)

/datum/chemical_reaction/slime/slimesmoke
	recipe_category = SLIME_RECIPE_FUN
	recipe_variants = list(
		list(/obj/item/slime_extract/orange, list(/datum/reagent/water = 5), 0),
		list(/obj/item/slime_extract/yellow, list(/datum/reagent/water = 5), 380),
		list(/obj/item/slime_extract/red, list(/datum/reagent/water = 5), 400),
	)

/datum/chemical_reaction/slime/slimeoil
	recipe_category = SLIME_RECIPE_FUN
	recipe_variants = list(
		list(/obj/item/slime_extract/oil, list(/datum/reagent/blood = 10), 0),
		list(/obj/item/slime_extract/orange, list(/datum/reagent/blood = 10), 450),
		list(/obj/item/slime_extract/yellow, list(/datum/reagent/blood = 10), 430),
	)

/datum/chemical_reaction/slime/slimebork/drinks
	recipe_category = SLIME_RECIPE_FUN
	recipe_variants = list(
		list(/obj/item/slime_extract/silver, list(/datum/reagent/water = 10), 0),
		list(/obj/item/slime_extract/rainbow, list(/datum/reagent/water = 10), 320),
		list(/obj/item/slime_extract/blue, list(/datum/reagent/water = 10), 300),
	)

/datum/chemical_reaction/slime/slimehuman
	recipe_category = SLIME_RECIPE_POSITIVE
	recipe_variants = list(
		list(/obj/item/slime_extract/grey, list(/datum/reagent/carbon = 10), 0),
		list(/obj/item/slime_extract/gold, list(/datum/reagent/water = 10), 320),
		list(/obj/item/slime_extract/blue, list(/datum/reagent/carbon = 10), 300),
	)

/datum/chemical_reaction/slime/slimelizard
	recipe_category = SLIME_RECIPE_FUN
	recipe_variants = list(
		list(/obj/item/slime_extract/green, list(/datum/reagent/blood = 10), 0),
		list(/obj/item/slime_extract/green, list(/datum/reagent/carbon = 10), 320),
		list(/obj/item/slime_extract/green, list(/datum/reagent/uranium/radium = 10), 320),
	)

/datum/chemical_reaction/slime/slimefelinid
	recipe_category = SLIME_RECIPE_NEGATIVE
	recipe_variants = list(
		list(/obj/item/slime_extract/rainbow, list(/datum/reagent/consumable/milk = 10), 0),
		list(/obj/item/slime_extract/pink, list(/datum/reagent/water = 10), 320),
		list(/obj/item/slime_extract/lightpink, list(/datum/reagent/water = 10), 300),
	)

/datum/chemical_reaction/slime/slimemoth
	recipe_category = SLIME_RECIPE_FUN
	recipe_variants = list(
		list(/obj/item/slime_extract/yellow, list(/datum/reagent/cellulose = 10), 0),
		list(/obj/item/slime_extract/gold, list(/datum/reagent/cellulose = 10), 320),
		list(/obj/item/slime_extract/orange, list(/datum/reagent/cellulose = 10), 300),
	)

/datum/chemical_reaction/slime/flight_potion
	recipe_category = SLIME_RECIPE_POSITIVE
	recipe_variants = list(
		list(/obj/item/slime_extract/rainbow, list(/datum/reagent/water/holywater = 15), 0),
		list(/obj/item/slime_extract/gold, list(/datum/reagent/water/holywater = 15), 320),
	)

// ADMIN_VERB(check_slime_randomization, R_DEBUG, "Check Slime Recipes", "Выводит текущие рандомные рецепты слаймов в чат.", ADMIN_CATEGORY_DEBUG)
// 	var/list/seen = list()
// 	var/list/out = list(span_adminnotice("Текущая рандомизация слаймов:"))
// 	var/list/disabled_out = list()
// 	for(var/path in GLOB.chemical_reactions_list)
// 		var/datum/chemical_reaction/slime/R = GLOB.chemical_reactions_list[path]
// 		if(!istype(R) || !R.randomized || (R in seen))
// 			continue
// 		seen[R] = TRUE
// 		if(R.rotation_disabled)
// 			disabled_out += span_grey("[R.recipe_category] <b>[R.type]</b>: отключена (коллизия)")
// 			continue
// 		var/container_name = replacetext("[R.required_container]", "/obj/item/slime_extract/", "")
// 		var/list/reag_parts = list()
// 		for(var/reag in R.required_reagents)
// 			reag_parts += "[replacetext("[reag]", "/datum/reagent/", "")] = [R.required_reagents[reag]]"
// 		var/temp_str = (R.required_temp != initial(R.required_temp)) ? ", [R.required_temp] K" : ""
// 		out += "[R.recipe_category] <b>[R.type]</b>: [container_name] + ([reag_parts.Join(", ")])[temp_str]"
// 	if(length(disabled_out))
// 		out += "<br>" + span_adminnotice("Отключены в этой ротации:") + "<br>" + disabled_out.Join("<br>")
// 	if(length(out) <= 1)
// 		to_chat(user, span_adminnotice("Рандомизированных рецептов слаймов не найдено."), confidential = TRUE)
// 		return
// 	to_chat(user, out.Join("<br>"), confidential = TRUE)
