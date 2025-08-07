/obj/machinery/teapot
	name = "Teapot machine"
	desc = "Бла бал бла, уничтожить Арасаку"
	icon = 'modular_bandastation/objects/icons/obj/machines/teapot.dmi'
	icon_state = "teapot_empty"
	base_icon_state = "teapot"
	active_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.0025
	circuit = /obj/item/circuitboard/machine/teapot
	pass_flags = PASSTABLE
	anchored = TRUE
	resistance_flags = ACID_PROOF
	anchored_tabletop_offset = 8
	var/maximum_weight = WEIGHT_CLASS_BULKY
	/// Is the teapot currently performing work
	var/is_operating = FALSE
	/// The glass to hold the final products
	var/obj/item/reagent_containers/cup/glass = null
	/// How fast heating take place
	var/heater_coefficient = 0.05
	/// How fast operations take place
	var/speed = 0.25
	/// Current temperature for reagents
	var/temperature = 273

/obj/machinery/teapot/Initialize(mapload)
	. = ..()
	if(mapload)
		glass = new /obj/item/reagent_containers/cup/glass/drinkingglass(src)

	register_context()
	update_appearance(UPDATE_OVERLAYS)

	RegisterSignal(src,COMSIG_STORAGE_DUMP_CONTENT,PROC_REF(on_storage_dump))

/obj/machinery/teapot/Destroy()
	QDEL_NULL(glass)
	return ..()

/obj/machinery/teapot/contents_explosion(severity, target)
	if(!QDELETED(glass))
		return

	switch(severity)
		if(EXPLODE_DEVASTATE)
			SSexplosions.high_mov_atom += glass
		if(EXPLODE_HEAVY)
			SSexplosions.med_mov_atom += glass
		if(EXPLODE_LIGHT)
			SSexplosions.low_mov_atom +=glass

/obj/machinery/teapot/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	var/result = NONE
	if(isnull(held_item))
		if(!QDELETED(glass) && !is_operating)
			context[SCREENTIP_CONTEXT_RMB] = "Remove glass"
			result = CONTEXTUAL_SCREENTIP_SET
		return result

	if(istype(held_item,/obj/item/reagent_containers/cup/glass)  && !is_operating)
		if(QDELETED(glass))
			context[SCREENTIP_CONTEXT_LMB] = "Insert glass"
		else
			context[SCREENTIP_CONTEXT_LMB] = "Replace glass"
		return CONTEXTUAL_SCREENTIP_SET

	if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
		context[SCREENTIP_CONTEXT_LMB] = "[panel_open ? "Close" : "Open"] panel"
		return CONTEXTUAL_SCREENTIP_SET
	else if(held_item.tool_behaviour == TOOL_CROWBAR && panel_open)
		context[SCREENTIP_CONTEXT_LMB] = "Deconstruct"
		return CONTEXTUAL_SCREENTIP_SET
	else if(held_item.tool_behaviour == TOOL_WRENCH)
		context[SCREENTIP_CONTEXT_LMB] = "[anchored ? "Una" : "A"]nchor"
		return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/teapot/examine(mob/user)
	. = ..()
	if(!in_range(user, src) && !issilicon(user) && !isobserver(user))
		. += span_warning("You're too far away to examine [src]'s contents and display!")
		return

	var/total_weight = 0
	var/list/obj/item/to_process = list()
	for(var/obj/item/target in src)
		if((target in component_parts) || target == glass)
			continue
		var/amount = 1
		if (isstack(target))
			var/obj/item/stack/target_stack = target
			amount = target_stack.amount
		to_process["[target.name]"] += amount
		total_weight += target.w_class
	if(to_process.len)
		. += span_notice("Сейчас содержит:")
		for(var/target_name as anything in to_process)
			. += span_notice("[to_process[target_name]] [target_name]")
		. += span_notice("Наполнен на <b>[round((total_weight / maximum_weight) * 100)]%</b> вместимости.")

	if(!QDELETED(glass))
		. += span_notice("Мензурка размером в <b>[glass.reagents.maximum_volume]u</b> [declension_ru(glass.reagents.maximum_volume,"юнит","юнита","юнитов")] вставлена. Содержимое:")
		if(glass.reagents.total_volume)
			for(var/datum/reagent/reg as anything in glass.reagents.reagent_list)
				. += span_notice("[round(reg.volume, CHEMICAL_VOLUME_ROUNDING)] [declension_ru(round(reg.volume, CHEMICAL_VOLUME_ROUNDING),"юнит","юнита","юнитов")] [reg.name]")
		else
			. += span_notice("Ничего.")
		. += span_notice("[EXAMINE_HINT("ПКМ")] пустой рукой для снятия мензурки.")
	else
		. += span_warning("Нет мензурки.")

	. += span_notice("Вы можете перетащить хранилище на [declent_ru(ACCUSATIVE)], чтобы перемести всё содержимое.")
	if(anchored)
		. += span_notice("Машина может быть [EXAMINE_HINT("откручена")].")
	else
		. += span_warning("Машина должна быть [EXAMINE_HINT("прикручена")] к полу для работы.")
	. += span_notice("Панель обслуживания может быть [EXAMINE_HINT(panel_open ? "привинчина" : "отвинчина")].")
	if(panel_open)
		. += span_notice("Машина может быть [EXAMINE_HINT("разобрана")] при помощи лома.")

/obj/machinery/teapot/update_overlays()
	. = ..()

	if(!QDELETED(glass))
		. += "[base_icon_state]_cup"

	if(anchored && !panel_open && is_operational)
		. += "[base_icon_state]_on"

/obj/machinery/teapot/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == glass)
		glass = null
		update_appearance(UPDATE_OVERLAYS)

/obj/machinery/teapot/proc/replace_beaker(mob/living/user, obj/item/reagent_containers/new_glass)
	PRIVATE_PROC(TRUE)

	if(!QDELETED(glass))
		try_put_in_hand(glass, user)

	if(!QDELETED(new_glass))
		if(!user.transferItemToLoc(new_glass, src))
			return
		glass = new_glass

	update_appearance(UPDATE_OVERLAYS)

/obj/machinery/teapot/proc/load_items(mob/user, list/obj/item/to_add)
	PRIVATE_PROC(TRUE)

	var/list/obj/item/filtered_list = list()
	for(var/obj/item/ingredient as anything in to_add)
		if((ingredient.item_flags & ABSTRACT) || (ingredient.flags_1 & HOLOGRAM_1))
			continue
		if(!ingredient.blend_requirements(src))
			continue

		filtered_list += ingredient
	if(!filtered_list.len)
		return FALSE

	var/total_weight
	for(var/obj/item/to_process in src)
		if((to_process in component_parts) || to_process == glass)
			continue
		total_weight += to_process.w_class

	var/items_transfered = 0
	for(var/obj/item/weapon as anything in filtered_list)
		if(weapon.w_class + total_weight > maximum_weight)
			to_chat(user, span_warning("[weapon] is too big to fit into [src]."))
			continue

		if(!user.transferItemToLoc(weapon, src))
			continue

		total_weight += weapon.w_class
		items_transfered += 1
		to_chat(user, span_notice("[weapon] was loaded into [src]."))

	return items_transfered

/obj/machinery/teapot/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(user.combat_mode || (tool.item_flags & ABSTRACT) || (tool.flags_1 & HOLOGRAM_1))
		return ITEM_INTERACT_SKIP_TO_ATTACK

	if (istype(tool,/obj/item/reagent_containers/cup/glass) && !is_operating)
		replace_beaker(user, tool)
		to_chat(user, span_notice("You add [tool] to [src]."))
		return ITEM_INTERACT_SUCCESS

	else if(istype(tool, /obj/item/storage/bag))
		var/list/obj/item/to_add = list()

		var/static/list/accepted_items = list(
			/obj/item/grown,
			/obj/item/food/grown,
			/obj/item/food/honeycomb,
		)

		for(var/obj/item/ingredient in tool)
			if(!is_type_in_list(ingredient, accepted_items))
				continue
			to_add += ingredient

		var/items_added = load_items(user, to_add)
		if(!items_added)
			to_chat(user, span_warning("No items were added."))
			return ITEM_INTERACT_BLOCKING
		to_chat(user, span_notice("[items_added] items were added from [tool] to [src]."))
		return ITEM_INTERACT_SUCCESS

	else if(length(tool.grind_results) || tool.reagents?.total_volume)
		if(tool.atom_storage && length(tool.contents))
			to_chat(user, span_notice("Drag this item onto [src] to dump its contents, or empty it to grind the container."))
			return ITEM_INTERACT_BLOCKING

		if(!load_items(user, list(tool)))
			return ITEM_INTERACT_BLOCKING
		to_chat(user, span_notice("[tool] was added to [src]."))
		return ITEM_INTERACT_SUCCESS

	else if(tool.atom_storage)
		to_chat(user, span_warning("You must drag & dump contents of [tool] into [src]."))
		return ITEM_INTERACT_BLOCKING

	return NONE

/obj/machinery/teapot/wrench_act(mob/living/user, obj/item/tool)
	. = NONE

	if(is_operating)
		balloon_alert(user, "still operating!")
		return ITEM_INTERACT_BLOCKING

	if(glass)
		balloon_alert(user, "remove the glass firstly")
		return ITEM_INTERACT_BLOCKING
	if(default_unfasten_wrench(user, tool) == SUCCESSFUL_UNFASTEN)
		update_appearance(UPDATE_OVERLAYS)
		anchored = !anchored
		icon_state = "teapot_[anchored]"
		return ITEM_INTERACT_SUCCESS

/obj/machinery/teapot/screwdriver_act(mob/living/user, obj/item/tool)
	. = NONE

	if(is_operating)
		balloon_alert(user, "still operating!")
		return ITEM_INTERACT_BLOCKING

	if(glass)
		balloon_alert(user, "remove the glass firstly!")
		return ITEM_INTERACT_BLOCKING

	if(default_deconstruction_screwdriver(user, icon_state, icon_state, tool))
		update_appearance(UPDATE_OVERLAYS)
		return ITEM_INTERACT_SUCCESS

/obj/machinery/teapot/crowbar_act(mob/living/user, obj/item/tool)
	. = NONE

	if(is_operating)
		balloon_alert(user, "still operating!")
		return ITEM_INTERACT_BLOCKING

	if(default_deconstruction_crowbar(tool))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/teapot/proc/on_storage_dump(datum/source,datum/storage/storage, mob/user)
	SIGNAL_HANDLER

	var/list/obj/item/contents_to_dump = list()
	for(var/obj/item/to_dump in storage.real_location)
		if(to_dump.atom_storage)
			continue
		contents_to_dump += to_dump

	to_chat(user,span_notice("You dumped [load_items(user, contents_to_dump)] items from [storage.parent] into [src]."))

	return STORAGE_DUMP_HANDLED

/obj/machinery/teapot/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN || !check_interactable(user))
		return
	replace_beaker(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/teapot/attack_robot_secondary(mob/user, list/modifiers)
	return attack_hand_secondary(user, modifiers)

/obj/machinery/teapot/attack_ai_secondary(mob/user, list/modifiers)
	return attack_hand_secondary(user, modifiers)

/obj/machinery/teapot/proc/heat_reagents(seconds_per_tick)
	PRIVATE_PROC(TRUE)

	if(!is_operating || !is_operational || QDELETED(glass) || !glass.reagents.total_volume)
		return FALSE
	playsound(src, 'sound/machines/hiss.ogg', 40, FALSE)
	var/energy = (temperature - glass.reagents.chem_temp) * heater_coefficient * seconds_per_tick * glass.reagents.heat_capacity()
	glass.reagents.adjust_thermal_energy(energy)
	use_energy(active_power_usage + abs(ROUND_UP(energy) / 120))
	if(glass.reagents.chem_temp == temperature)
		is_operating = FALSE
	return TRUE

/obj/machinery/teapot/ui_interact(mob/user)

	if(!user.can_perform_action(src, ALLOW_SILICON_REACH | FORBID_TELEKINESIS_REACH))
		return

	var/static/radial_eject = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_eject")
	var/list/options = list()

	for(var/obj/item/to_process in src)
		if((to_process in component_parts) || to_process == glass)
			continue

		if(is_operational && anchored && !QDELETED(glass) && !glass.reagents.holder_full())
			var/static/radial_up = image(icon = 'modular_bandastation/objects/icons/obj/machines/teapot.dmi', icon_state = "radial_up")
			options["temp_up"] = radial_up

			var/static/radial_down = image(icon = 'modular_bandastation/objects/icons/obj/machines/teapot.dmi', icon_state = "radial_down")
			options["temp_down"] = radial_down

		options["eject"] = radial_eject
		break

	if(!QDELETED(glass))
		options["on"] = radial_eject
		if(is_operational && anchored && glass.reagents.total_volume)
			var/static/radial_on = image(icon = 'modular_bandastation/objects/icons/obj/machines/teapot.dmi', icon_state = "radial_on")
			options["on"] = radial_on

	if(HAS_AI_ACCESS(user))
		var/static/radial_examine = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_examine")
		options["examine"] = radial_examine

	var/choice = show_radial_menu(user,src,options,custom_check = CALLBACK(src, PROC_REF(check_interactable), user),require_near = !HAS_SILICON_ACCESS(user),)
	if(!choice)
		return

	switch(choice)
		if("eject")
			replace_beaker(user)

		if("temp_up")
			if(temperature < 333)
				temperature += 30
				balloon_alert(user,"Temperature is [temperature]")
			else
				balloon_alert(user,"This is the maximum temperature")

		if("temp_down")
			if(temperature > 213)
				temperature += -30
				balloon_alert(user,"Temperature is [temperature]")
			else
				balloon_alert(user,"This is the minimum temperature")

		if("on")
			is_operating = TRUE

		if("examine")
			to_chat(user, boxed_message(jointext(examine(user), "\n")))

/obj/machinery/teapot/proc/check_interactable(mob/user)
	PRIVATE_PROC(TRUE)

	return !is_operating && user.can_perform_action(src, ALLOW_SILICON_REACH | FORBID_TELEKINESIS_REACH)
