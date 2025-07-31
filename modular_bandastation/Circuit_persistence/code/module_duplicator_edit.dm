/obj/machinery/module_duplicator/post_machine_initialize()
	. = ..()
	if(!CONFIG_GET(flag/no_default_techweb_link) && !techweb)
		CONNECT_TO_RND_SERVER_ROUNDSTART(techweb, src)
	if(techweb)
		on_connected_techweb()

/obj/machinery/module_duplicator/proc/connect_techweb(datum/techweb/new_techweb)
	if(techweb)
		UnregisterSignal(techweb, list(COMSIG_TECHWEB_ADD_DESIGN, COMSIG_TECHWEB_REMOVE_DESIGN))
	techweb = new_techweb
	if(!isnull(techweb))
		on_connected_techweb()

/obj/machinery/module_duplicator/proc/on_connected_techweb()
	for (var/researched_design_id in techweb.researched_designs)
		var/datum/design/design = SSresearch.techweb_design_by_id(researched_design_id)
		if (!(design.build_type & COMPONENT_PRINTER) || !ispath(design.build_path, /obj/item/circuit_component))
			continue

		current_unlocked_designs[design.build_path] = design.id

	RegisterSignal(techweb, COMSIG_TECHWEB_ADD_DESIGN, PROC_REF(on_research))
	RegisterSignal(techweb, COMSIG_TECHWEB_REMOVE_DESIGN, PROC_REF(on_removed))

/obj/machinery/module_duplicator/multitool_act(mob/living/user, obj/item/multitool/tool)
	if(!QDELETED(tool.buffer) && istype(tool.buffer, /datum/techweb))
		connect_techweb(tool.buffer)
	return TRUE

/obj/machinery/module_duplicator/proc/on_research(datum/source, datum/design/added_design, custom)
	SIGNAL_HANDLER
	if (!(added_design.build_type & COMPONENT_PRINTER) || !ispath(added_design.build_path, /obj/item/circuit_component))
		return
	current_unlocked_designs[added_design.build_path] = added_design.id

/obj/machinery/module_duplicator/proc/on_removed(datum/source, datum/design/added_design, custom)
	SIGNAL_HANDLER
	if (!(added_design.build_type & COMPONENT_PRINTER) || !ispath(added_design.build_path, /obj/item/circuit_component))
		return
	current_unlocked_designs -= added_design.build_path

/obj/machinery/module_duplicator/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if (.)
		return

	switch (action)
		if ("print")

			var/design_id = text2num(params["designId"])
			var/list/all_designs = scanned_designs
			if (!isnull(SSpersistence.circuit_designs[ui.user.client?.ckey]))
				all_designs = scanned_designs | SSpersistence.circuit_designs[ui.user.client?.ckey]

			var/list/design = all_designs[design_id]

			if (design_id < 1 || design_id > length(all_designs))
				return TRUE

			if (design["author_ckey"] != ui.user.client?.ckey && !(design in scanned_designs)) // Get away from here, cheater
				return TRUE

			if (materials.on_hold())
				say("Mineral access is on hold, please contact the quartermaster.")
				return TRUE
			if (!materials.mat_container.has_materials(design["materials"], efficiency_coeff))
				say("Not enough materials.")
				return TRUE

			var/list/design_data = json_decode(design["dupe_data"])
			if(!design_data)
				say("Invalid design data.")
				return FALSE

			var/list/circuit_data = design_data["components"]
			for(var/identifier in circuit_data)
				var/list/component_data = circuit_data[identifier]
				var/comp_type = text2path(component_data["type"])
				if (!ispath(comp_type, /obj/item/circuit_component))
					say("[component_data["name"]] component in this circuit has been recalled, unable to proceed.")
					return TRUE

				if (isnull(current_unlocked_designs[comp_type]))
					say("[component_data["name"]] component has not been researched yet.")
					return TRUE

			materials.use_materials(design["materials"], efficiency_coeff, 1, design["name"], design["materials"])
			print_module(design)
			balloon_alert_to_viewers("printed [design["name"]]")

		if ("delete")
			var/design_id = text2num(params["designId"])

			if (design_id < 1 || design_id > length(SSpersistence.circuit_designs))
				return TRUE

			var/list/design = SSpersistence.circuit_designs[design_id]
			if (design["author_ckey"] != ui.user.client?.ckey)
				return TRUE

			if(tgui_alert(ui.user, "Are you sure you want to delete [design["name"]]?", "Module Duplicator", list("Yes","No")) != "Yes")
				return TRUE

			if (!isnull(SSpersistence.circuit_designs[design["author_ckey"]]))
				SSpersistence.circuit_designs[design["author_ckey"]] -= list(design)
			scanned_designs -= list(design)
			update_static_data_for_all_viewers()

		if ("remove_mat")
			var/datum/material/material = locate(params["ref"])
			var/amount = text2num(params["amount"])
			// SAFETY: eject_sheets checks for valid mats
			materials.eject_sheets(material, amount)
	return TRUE
