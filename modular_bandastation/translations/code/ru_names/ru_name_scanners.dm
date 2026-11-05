/obj/item/plant_analyzer/ui_data(mob/user)
	. = ..()
	for(var/entry_key in list("tray_data", "plant_data", "seed_data"))
		var/list/scan_data = .[entry_key]
		if(!scan_data)
			continue
		var/list/translated_data = scan_data.Copy()
		translated_data["reagents"] = translate_reagent_ui_entries(scan_data["reagents"])
		.[entry_key] = translated_data
		if(entry_key != "seed_data")
			continue
		for(var/product_key in list("distill_reagent", "juice_name"))
			var/reagent_name = scan_data[product_key]
			translated_data[product_key] = capitalize(declent_ru_initial(reagent_name, override_backup = reagent_name))
		var/list/grind_results = list()
		for(var/reagent_name in scan_data["grind_results"])
			grind_results += capitalize(declent_ru_initial(reagent_name, override_backup = reagent_name))
		translated_data["grind_results"] = grind_results

/obj/machinery/medical_kiosk/ui_data(mob/living/carbon/human/user)
	. = ..()
	if(isnull(.))
		return
	for(var/entry_key in list("chemical_list", "overdose_list"))
		.[entry_key] = translate_reagent_ui_entries(.[entry_key])

/datum/detective_scanner_data_entry/ui_data(mob/user)
	. = ..()
	if(category != DETSCAN_CATEGORY_REAGENTS)
		return .
	var/list/display_names = list()
	for(var/reagent_name in data)
		display_names[reagent_name] = capitalize(declent_ru_initial(reagent_name, override_backup = reagent_name))
	.["ru_display_names"] = display_names

/datum/detective_scan_category/drink/format_report_entry(entry, entry_associated_value)
	return ..(capitalize(declent_ru_initial(entry, override_backup = entry)), entry_associated_value)
