/// Catalog resources are compiled into the RSC and loaded once.
/proc/get_sierra_background_catalog()
	var/static/list/catalog
	if(isnull(catalog))
		var/list/cultures = json_decode(file2text('modular_bandastation/sierra_background/data/cultures.json'))
		var/list/worlds = json_decode(file2text('modular_bandastation/sierra_background/data/worlds.json'))
		var/list/factions = json_decode(file2text('modular_bandastation/sierra_background/data/factions.json'))
		var/list/religions = json_decode(file2text('modular_bandastation/sierra_background/data/religions.json'))
		var/list/wiki = json_decode(file2text('modular_bandastation/sierra_background/data/wiki_species.json'))
		catalog = list(
			"culture" = cultures["entries"] + wiki["cultures"],
			"homeworld" = worlds["entries"] + wiki["worlds"],
			"faction" = factions["entries"],
			"religion" = religions["entries"] + wiki["religions"],
		)
	return catalog

/// Felinids and ceruleans inherit /human but have distinct native IDs.
/proc/get_sierra_background_species(datum/species/species_type)
	return ispath(species_type, /datum/species) ? initial(species_type.id) : null

/// Defaults assign neither citizenship nor faith.
/proc/get_sierra_background_default(category, datum/species/species_type = /datum/species/human)
	var/static/list/culture_defaults = list(
		"human" = "tsf_solar",
		"felinid" = "felinid_community",
		"lizard" = "moges_upbringing",
		"skrell" = "skrell_imperial",
		"plasmaman" = "plasmaman_technocrat",
		"moth" = "nian_caravan",
		"ethereal" = "ethereal_sprout",
		"tajaran" = "adomai_upbringing",
		"vulpkanin" = "altam_upbringing",
	)
	var/static/list/world_defaults = list(
		"human" = "Earth",
		"lizard" = "Moges",
		"skrell" = "KverrBalakk",
		"plasmaman" = "Boron",
		"moth" = "Zuviyen",
		"ethereal" = "sprout",
		"tajaran" = "Adomai",
		"vulpkanin" = "Altam",
	)
	var/species_id = get_sierra_background_species(species_type)
	switch(category)
		if("culture")
			return culture_defaults[species_id] || "other"
		if("homeworld")
			return world_defaults[species_id] || "other"
		if("faction", "religion")
			return "none"
	return null

/// Shared upbringing and beliefs are independent of biology; enforce only explicit restrictions.
/proc/get_sierra_background_choices(category, datum/species/species_type = /datum/species/human)
	var/list/catalog = get_sierra_background_catalog()
	var/list/entries = catalog[category]
	var/species_id = get_sierra_background_species(species_type)
	var/list/choices = list()
	for(var/id in entries)
		var/list/entry = entries[id]
		var/list/allowed_species = entry["allowed_species"]
		var/list/excluded_species = entry["excluded_species"]
		if((islist(allowed_species) && !(species_id in allowed_species)) || (species_id in excluded_species))
			continue
		choices += id
	var/default_value = get_sierra_background_default(category, species_type)
	if(default_value in choices)
		choices -= default_value
		choices.Insert(1, default_value)
	return choices

/// Migrate unambiguous equivalents without renaming foreign Sierra polities into our states.
/proc/normalize_sierra_background_value(category, value, datum/species/species_type)
	var/static/list/aliases = list(
		"culture" = list("Earther" = "tsf_solar", "Other Culture" = "other", "OtherCulture" = "other"),
		"homeworld" = list("Other" = "other"),
		"faction" = list("Other Faction" = "none"),
		"religion" = list("Other Religion" = "other", "None" = "none", "Atheism" = "atheism", "Agnosticism" = "agnosticism"),
	)
	var/list/choices = get_sierra_background_choices(category, species_type)
	if(istext(value))
		if(category == "faction" && value == ("Nano" + "Trasen"))
			value = "Nanotrasen"
		if(value in choices)
			return value
		var/list/category_aliases = aliases[category]
		var/mapped_value = category_aliases?[value]
		if(mapped_value in choices)
			return mapped_value
	return choices[1]
