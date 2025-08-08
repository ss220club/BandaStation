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
	var/heater_coefficient = 0.5
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
			context[SCREENTIP_CONTEXT_RMB] = "Убрать сосуд"
			result = CONTEXTUAL_SCREENTIP_SET
		return result

	if(istype(held_item,/obj/item/reagent_containers/cup/glass)  && !is_operating)
		if(QDELETED(glass))
			context[SCREENTIP_CONTEXT_LMB] = "Вставить сосуд"
		else
			context[SCREENTIP_CONTEXT_LMB] = "Заменить сосуд"
		return CONTEXTUAL_SCREENTIP_SET

	if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
		context[SCREENTIP_CONTEXT_LMB] = "[panel_open ? "Закрыть" : "Открыть"] палень"
		return CONTEXTUAL_SCREENTIP_SET
	else if(held_item.tool_behaviour == TOOL_CROWBAR && panel_open)
		context[SCREENTIP_CONTEXT_LMB] = "Разобрать"
		return CONTEXTUAL_SCREENTIP_SET
	else if(held_item.tool_behaviour == TOOL_WRENCH)
		context[SCREENTIP_CONTEXT_LMB] = "[anchored ? "От" : "При"]крутить"
		return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/teapot/examine(mob/user)
	. = ..()
	if(!in_range(user, src) && !issilicon(user) && !isobserver(user))
		. += span_warning("Вы слишком далеко чтобы рассмотреть содержимое и дисплей [src]!")
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
		. += span_notice("Стакан размером в <b>[glass.reagents.maximum_volume]u</b> [declension_ru(glass.reagents.maximum_volume,"юнит","юнита","юнитов")] вставлена. Содержимое:")
		if(glass.reagents.total_volume)
			for(var/datum/reagent/reg as anything in glass.reagents.reagent_list)
				. += span_notice("[round(reg.volume, CHEMICAL_VOLUME_ROUNDING)] [declension_ru(round(reg.volume, CHEMICAL_VOLUME_ROUNDING),"юнит","юнита","юнитов")] [reg.name]")
		else
			. += span_notice("Ничего.")
		. += span_notice("[EXAMINE_HINT("ПКМ")] пустой рукой для того, чтобы забрать стакан.")
	else
		. += span_warning("Нет стакана.")

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
/**
 * Inserts, removes or replaces the beaker present
 * Arguments
 *
 * * mob/living/user - the player performing the action
 * * obj/item/reagent_containers/new_beaker - the new beaker to replace the old, null to do nothing
 */
/obj/machinery/teapot/proc/replace_beaker(mob/living/user, obj/item/reagent_containers/new_glass)
	PRIVATE_PROC(TRUE)

	if(!QDELETED(glass))
		try_put_in_hand(glass, user)

	if(!QDELETED(new_glass))
		if(!user.transferItemToLoc(new_glass, src))
			return
		glass = new_glass

	update_appearance(UPDATE_OVERLAYS)


/obj/machinery/teapot/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(user.combat_mode || (tool.item_flags & ABSTRACT) || (tool.flags_1 & HOLOGRAM_1))
		return ITEM_INTERACT_SKIP_TO_ATTACK

	//add the glass
	if (istype(tool,/obj/item/reagent_containers/cup/glass))
		replace_beaker(user, tool)
		to_chat(user, span_notice("You add [tool] to [src]."))
		return ITEM_INTERACT_SUCCESS

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

/obj/machinery/teapot/proc/heat_reagents()
	PRIVATE_PROC(TRUE)

	if(!is_operating || !is_operational || QDELETED(glass) || !glass.reagents.total_volume)
		return FALSE
	playsound(src, 'sound/machines/hiss.ogg', 40, FALSE)
	while(!(glass.reagents.chem_temp == temperature))
		var/energy = (temperature - glass.reagents.chem_temp) * heater_coefficient * glass.reagents.heat_capacity()
		glass.reagents.adjust_thermal_energy(energy)
		use_energy(active_power_usage + abs(ROUND_UP(energy) / 120))
	is_operating = FALSE
	return TRUE

/obj/machinery/teapot/ui_interact(mob/user)

	if(!user.can_perform_action(src, ALLOW_SILICON_REACH | FORBID_TELEKINESIS_REACH))
		return

	var/list/options = list()

	for(var/obj/item/to_process in src)

		if(glass.reagents == null)
			to_chat(user,span_notice("Стакан пуст"))
			return
		if(is_operational && anchored && !QDELETED(glass))
			var/static/radial_up = image(icon = 'modular_bandastation/objects/icons/obj/machines/teapot.dmi', icon_state = "radial_up")
			options["temp_up"] = radial_up

			var/static/radial_down = image(icon = 'modular_bandastation/objects/icons/obj/machines/teapot.dmi', icon_state = "radial_down")
			options["temp_down"] = radial_down

		break

	if(!QDELETED(glass))
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

		if("on")
			is_operating = TRUE
			heat_reagents()

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

		if("examine")
			to_chat(user, boxed_message(jointext(examine(user), "\n")))

/obj/machinery/teapot/proc/check_interactable(mob/user)
	PRIVATE_PROC(TRUE)

	return !is_operating && user.can_perform_action(src, ALLOW_SILICON_REACH | FORBID_TELEKINESIS_REACH)
