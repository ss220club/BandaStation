/proc/get_reagent_type_from_ru_name(product_name)
	var/normalized_name = replacetext(LOWER_TEXT(product_name), " ", "")
	if(!length(normalized_name))
		return null
	for(var/reagent_name in GLOB.name2reagent)
		var/translated_name = declent_ru_initial(reagent_name)
		if(translated_name && replacetext(LOWER_TEXT(translated_name), " ", "") == normalized_name)
			return GLOB.name2reagent[reagent_name]
	return null

/proc/tgui_input_reagent_name(mob/user, message, title)
	var/list/reagent_options = list()
	for(var/reagent_name in GLOB.name2reagent)
		var/translated_name = declent_ru_initial(reagent_name)
		var/option_name = translated_name ? "[capitalize(translated_name)] ([reagent_name])" : reagent_name
		reagent_options[option_name] = reagent_name
	var/selected_option = tgui_input_list(user, message, title, reagent_options)
	return reagent_options[selected_option]

/proc/translate_reagent_ui_entries(list/entries)
	. = list()
	for(var/list/entry as anything in entries)
		var/list/translated_entry = entry.Copy()
		translated_entry["name"] = capitalize(declent_ru_initial(entry["name"], override_backup = entry["name"]))
		. += list(translated_entry)

/obj/machinery/chem_dispenser/ui_data(mob/user)
	. = ..()
	for(var/list/chemical as anything in .["chemicals"])
		chemical["ru_display_name"] = capitalize(declent_ru_initial(chemical["title"], override_backup = chemical["title"]))
	var/list/beaker_data = .["beaker"]
	if(beaker_data)
		beaker_data["contents"] = translate_reagent_ui_entries(beaker_data["contents"])

/obj/machinery/chem_dispenser/proc/translate_reaction_info(list/reaction_data, datum/reagent/product, alternate_index)
	var/alternate_suffix = alternate_index ? " (Alt[alternate_index == 1 ? "" : " #[alternate_index]"])" : ""
	reaction_data["ru_display_name"] = "[capitalize(declent_ru_initial(product.name, override_backup = product.name))][alternate_suffix]"
	for(var/entry_key in list("required_reagents", "required_catalysts"))
		for(var/list/reagent_data as anything in reaction_data[entry_key])
			reagent_data["ru_display_name"] = capitalize(declent_ru_initial(reagent_data["name"], override_backup = reagent_data["name"]))

/obj/machinery/chem_master/ui_data(mob/user)
	. = ..()
	for(var/container_key in list("beaker", "buffer"))
		var/list/container_data = .[container_key]
		if(container_data)
			container_data["contents"] = translate_reagent_ui_entries(container_data["contents"])

/datum/reagents/ui_data(mob/user)
	. = ..()
	.["linkedBeaker"] = my_atom.get_visible_name()
	var/list/reagent_data = .["reagent_mode_reagent"]
	if(reagent_data)
		reagent_data["ru_display_name"] = capitalize(declent_ru_initial(reagent_data["name"], override_backup = reagent_data["name"]))
		if(reagent_data["inverseReagent"])
			reagent_data["inverseReagent"] = capitalize(declent_ru_initial(reagent_data["inverseReagent"], override_backup = reagent_data["inverseReagent"]))
	var/list/recipe_data = .["reagent_mode_recipe"]
	if(recipe_data)
		if(recipe_data["hasProduct"])
			recipe_data["ru_display_name"] = capitalize(declent_ru_initial(recipe_data["name"], override_backup = recipe_data["name"]))
		for(var/entry_key in list("products", "reactants", "catalysts"))
			recipe_data[entry_key] = translate_reagent_ui_entries(recipe_data[entry_key])

/datum/reagents/ui_static_data(mob/user)
	. = ..()
	var/list/translated_reactions = translate_reagent_ui_entries(.["master_reaction_list"])
	for(var/list/reaction_data as anything in translated_reactions)
		reaction_data["reactants"] = translate_reagent_ui_entries(reaction_data["reactants"])
	.["master_reaction_list"] = translated_reactions
