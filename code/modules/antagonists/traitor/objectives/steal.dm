/datum/traitor_objective_category/steal_item
	name = "Steal Item"
	objectives = list(
		list(
			/datum/traitor_objective/steal_item/low_risk = 1,
			/datum/traitor_objective/destroy_item/low_risk = 1,
		) = 1,
		/datum/traitor_objective/steal_item/somewhat_risky = 1,
		list(
			/datum/traitor_objective/destroy_item/very_risky = 1,
			/datum/traitor_objective/steal_item/very_risky = 1,
		) = 1,
		/datum/traitor_objective/steal_item/most_risky = 1
	)

GLOBAL_DATUM_INIT(steal_item_handler, /datum/objective_item_handler, new())

/datum/objective_item_handler
	var/list/list/objectives_by_path
	var/generated_items = FALSE

/datum/objective_item_handler/New()
	. = ..()
	objectives_by_path = list()
	for(var/datum/objective_item/item as anything in subtypesof(/datum/objective_item))
		objectives_by_path[initial(item.targetitem)] = list()
	RegisterSignal(SSatoms, COMSIG_SUBSYSTEM_POST_INITIALIZE, PROC_REF(save_items))
	RegisterSignal(SSdcs, COMSIG_GLOB_NEW_ITEM, PROC_REF(new_item_created))

/datum/objective_item_handler/proc/new_item_created(datum/source, obj/item/item)
	SIGNAL_HANDLER
	if(HAS_TRAIT(item, TRAIT_ITEM_OBJECTIVE_BLOCKED))
		return
	if(!generated_items)
		item.add_stealing_item_objective()
		return
	var/typepath = item.add_stealing_item_objective()
	if(typepath != null)
		register_item(item, typepath)

/// Registers all items that are potentially stealable and removes ones that aren't.
/// We still need to do things this way because on mapload, items may not be on the station until everything has finished loading.
/datum/objective_item_handler/proc/save_items()
	SIGNAL_HANDLER
	for(var/obj/item/typepath as anything in objectives_by_path)
		var/list/obj_by_path_cache = objectives_by_path[typepath].Copy()
		for(var/obj/item/object as anything in obj_by_path_cache)
			register_item(object, typepath)
	generated_items = TRUE

/datum/objective_item_handler/proc/register_item(atom/object, typepath)
	var/turf/place = get_turf(object)
	if(!place || !is_station_level(place.z))
		objectives_by_path[typepath] -= object
		return
	RegisterSignal(object, COMSIG_QDELETING, PROC_REF(remove_item))

/datum/objective_item_handler/proc/remove_item(atom/source)
	SIGNAL_HANDLER
	for(var/typepath in objectives_by_path)
		objectives_by_path[typepath] -= source

/datum/traitor_objective/steal_item
	name = "Украдите %ITEM% и разместите специальное сканирующее устройство на него."
	description = "Используйте кнопку ниже, чтобы материализовать сканер в вашей руке, чтобы в будущем установить его на %ITEM%. Кроме того, вы можете удерживать предмет рядом, позволяя сканеру работать в течение %TIME% минут, тогда дополнительное вознаграждение составит: репутации - %PROGRESSION%, телекристаллов - %TC%."

	progression_minimum = 20 MINUTES

	var/list/possible_items = list()
	/// The current target item that we are stealing.
	var/datum/objective_item/steal/target_item
	/// A list of 2 elements, which contain the range that the time will be in. Represented in minutes.
	var/hold_time_required = list(5, 15)
	/// The current time fulfilled around the item
	var/time_fulfilled = 0
	/// The maximum distance between the bug and the objective taker for time to count as fulfilled
	var/max_distance = 4
	/// The bug that will be put onto the item
	var/obj/item/traitor_bug/bug
	/// Any special equipment that may be needed
	var/list/special_equipment
	/// Telecrystal reward increase per unit of time.
	var/minutes_per_telecrystal = 3

	/// Extra TC given for holding the item for the required duration of time.
	var/extra_tc = 0
	/// Extra progression given for holding the item for the required duration of time.
	var/extra_progression = 0

	abstract_type = /datum/traitor_objective/steal_item

/datum/traitor_objective/steal_item/low_risk
	progression_minimum = 10 MINUTES
	progression_maximum = 35 MINUTES
	progression_reward = list(5 MINUTES, 10 MINUTES)
	telecrystal_reward = 0
	minutes_per_telecrystal = 6

	possible_items = list(
		/datum/objective_item/steal/traitor/cargo_budget,
		/datum/objective_item/steal/traitor/clown_shoes,
		/datum/objective_item/steal/traitor/lawyers_badge,
		/datum/objective_item/steal/traitor/chef_moustache,
		/datum/objective_item/steal/traitor/pka,
	)

/datum/traitor_objective/steal_item/somewhat_risky
	progression_minimum = 20 MINUTES
	progression_maximum = 50 MINUTES
	progression_reward = 10 MINUTES
	telecrystal_reward = 2

	possible_items = list(
		/datum/objective_item/steal/traitor/chief_engineer_belt
	)

/datum/traitor_objective/steal_item/very_risky
	progression_minimum = 30 MINUTES
	progression_reward = 15 MINUTES
	telecrystal_reward = 3

	possible_items = list(
		/datum/objective_item/steal/traitor/det_revolver,
	)

/datum/traitor_objective/steal_item/most_risky
	progression_minimum = 50 MINUTES
	progression_reward = 20 MINUTES
	telecrystal_reward = 5

	possible_items = list(
		/datum/objective_item/steal/traitor/captain_modsuit,
		/datum/objective_item/steal/traitor/captain_spare,
	)

/datum/traitor_objective/steal_item/most_risky/generate_objective(datum/mind/generating_for, list/possible_duplicates)
	if(!handler.get_completion_count(/datum/traitor_objective/steal_item/very_risky))
		return FALSE
	return ..()

/datum/traitor_objective/steal_item/generate_objective(datum/mind/generating_for, list/possible_duplicates)
	for(var/datum/traitor_objective/steal_item/objective as anything in possible_duplicates)
		possible_items -= objective.target_item.type
	while(length(possible_items))
		var/datum/objective_item/steal/target = pick_n_take(possible_items)
		target = new target()
		if(!target.valid_objective_for(list(generating_for), require_owner = TRUE))
			qdel(target)
			continue
		target_item = target
		break
	if(!target_item)
		return FALSE
	if(length(target_item.special_equipment))
		special_equipment = target_item.special_equipment
	hold_time_required = rand(hold_time_required[1], hold_time_required[2])
	extra_progression += hold_time_required * (1 MINUTES)
	extra_tc += round(hold_time_required / max(minutes_per_telecrystal, 0.1))
	replace_in_name("%ITEM%", target_item.name)
	replace_in_name("%TIME%", hold_time_required)
	replace_in_name("%TC%", extra_tc)
	replace_in_name("%PROGRESSION%", DISPLAY_PROGRESSION(extra_progression))
	return TRUE

/datum/traitor_objective/steal_item/ungenerate_objective()
	STOP_PROCESSING(SSprocessing, src)
	if(bug)
		UnregisterSignal(bug, list(COMSIG_TRAITOR_BUG_PLANTED_OBJECT, COMSIG_TRAITOR_BUG_PRE_PLANTED_OBJECT))
	bug = null

/datum/traitor_objective/steal_item/generate_ui_buttons(mob/user)
	var/list/buttons = list()
	if(special_equipment)
		buttons += add_ui_button("", "Нажатие этой кнопки вызовет любое дополнительное специальное оборудование, которое может вам понадобиться для миссии.", "tools", "summon_gear")
	if(!bug)
		buttons += add_ui_button("", "При нажатии на эту кнопку в вашей руке появится сканер, который вы сможете поместить на цель.", "wifi", "summon_bug")
	else if(bug.planted_on)
		buttons += add_ui_button("[DisplayTimeText(time_fulfilled)]", "Это показывает, сколько времени вы провели возле целевого предмета после установки сканера.", "clock", "none")
		buttons += add_ui_button("Пропустить время", "Нажатие этой кнопки приведет к успеху миссии. Вы не получите дополнительных TК и прогресса.", "forward", "cash_out")
	return buttons

/datum/traitor_objective/steal_item/ui_perform_action(mob/living/user, action)
	. = ..()
	switch(action)
		if("summon_bug")
			if(bug)
				return
			bug = new(user.drop_location())
			user.put_in_hands(bug)
			bug.balloon_alert(user, "сканер материализуется у вас в руке")
			bug.target_object_type = target_item.targetitem
			AddComponent(/datum/component/traitor_objective_register, bug, \
				fail_signals = list(COMSIG_QDELETING), \
				penalty = telecrystal_penalty)
			RegisterSignal(bug, COMSIG_TRAITOR_BUG_PLANTED_OBJECT, PROC_REF(on_bug_planted))
			RegisterSignal(bug, COMSIG_TRAITOR_BUG_PRE_PLANTED_OBJECT, PROC_REF(handle_special_case))
		if("summon_gear")
			if(!special_equipment)
				return
			for(var/item in special_equipment)
				var/obj/item/new_item = new item(user.drop_location())
				user.put_in_hands(new_item)
			user.balloon_alert(user, "оборудование материализуется в ваших руках")
			special_equipment = null
		if("cash_out")
			if(!bug.planted_on)
				return
			succeed_objective()

/datum/traitor_objective/steal_item/process(seconds_per_tick)
	var/mob/owner = handler.owner?.current
	if(objective_state != OBJECTIVE_STATE_ACTIVE || !bug.planted_on)
		return PROCESS_KILL
	if(!owner)
		fail_objective()
		return PROCESS_KILL
	if(get_dist(get_turf(owner), get_turf(bug)) > max_distance)
		return
	time_fulfilled += seconds_per_tick * (1 SECONDS)
	if(time_fulfilled >= hold_time_required * (1 MINUTES))
		progression_reward += extra_progression
		telecrystal_reward += extra_tc
		succeed_objective()
		return PROCESS_KILL
	handler.on_update()

/datum/traitor_objective/steal_item/proc/handle_special_case(obj/item/source, obj/item/target)
	SIGNAL_HANDLER
	if(HAS_TRAIT(target, TRAIT_ITEM_OBJECTIVE_BLOCKED))
		return COMPONENT_FORCE_FAIL_PLACEMENT
	if(istype(target, target_item.targetitem))
		if(!target_item.check_special_completion(target))
			return COMPONENT_FORCE_FAIL_PLACEMENT
		return

	var/found = FALSE
	for(var/typepath in target_item.valid_containers)
		if(istype(target, typepath))
			found = TRUE
			break

	if(!found)
		return

	var/found_item = locate(target_item.targetitem) in target
	if(!found_item || !target_item.check_special_completion(found_item))
		return COMPONENT_FORCE_FAIL_PLACEMENT
	return COMPONENT_FORCE_PLACEMENT

/datum/traitor_objective/steal_item/proc/on_bug_planted(obj/item/source, obj/item/location)
	SIGNAL_HANDLER
	if(objective_state == OBJECTIVE_STATE_ACTIVE)
		START_PROCESSING(SSprocessing, src)

/obj/item/traitor_bug
	name = "suspicious device"
	desc = "Это выглядит опасно."
	item_flags = EXAMINE_SKIP|NOBLUDGEON

	icon = 'icons/obj/antags/syndicate_tools.dmi'
	icon_state = "bug"

	/// The object on which this bug can be planted on. Has to be a type.
	var/obj/target_object_type
	/// The object this bug is currently planted on.
	var/obj/planted_on
	/// The time it takes to place this bug.
	var/deploy_time = 10 SECONDS

/obj/item/traitor_bug/examine(mob/user)
	. = ..()
	if(planted_on)
		return

	if(IS_TRAITOR(user))
		if(target_object_type)
			. += span_notice("Это устройство необходимо разместить, <b>нажав на [declent_ru_initial(target_object_type::name, ACCUSATIVE, target_object_type::name)]</b> с ним.")
		. += span_notice("Помните, что вы можете оставить на устройстве отпечатки пальцев или волокна. Используйте <b>мыло</b> или что-то подобное, чтобы очистить его, чтобы быть в безопасности!")

/obj/item/traitor_bug/interact_with_atom(atom/movable/target, mob/living/user, list/modifiers)
	if(!target_object_type || !ismovable(target))
		return NONE
	if(SHOULD_SKIP_INTERACTION(target, src, user))
		return NONE
	var/result = SEND_SIGNAL(src, COMSIG_TRAITOR_BUG_PRE_PLANTED_OBJECT, target)
	if(!(result & COMPONENT_FORCE_PLACEMENT))
		if(result & COMPONENT_FORCE_FAIL_PLACEMENT || !istype(target, target_object_type))
			balloon_alert(user, "вы не можете прикрепить это сюда!")
			return ITEM_INTERACT_BLOCKING
	if(!do_after(user, deploy_time, src, hidden = TRUE))
		return ITEM_INTERACT_BLOCKING
	if(planted_on)
		return ITEM_INTERACT_BLOCKING
	forceMove(target)
	target.vis_contents += src
	vis_flags |= VIS_INHERIT_PLANE
	planted_on = target
	RegisterSignal(planted_on, COMSIG_QDELETING, PROC_REF(handle_planted_on_deletion))
	SEND_SIGNAL(src, COMSIG_TRAITOR_BUG_PLANTED_OBJECT, target)
	return ITEM_INTERACT_SUCCESS

/obj/item/traitor_bug/proc/handle_planted_on_deletion()
	planted_on = null

/obj/item/traitor_bug/Destroy()
	if(planted_on)
		vis_flags &= ~VIS_INHERIT_PLANE
		planted_on.vis_contents -= src
	return ..()

/obj/item/traitor_bug/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(planted_on)
		vis_flags &= ~VIS_INHERIT_PLANE
		planted_on.vis_contents -= src
		anchored = FALSE
		UnregisterSignal(planted_on, COMSIG_QDELETING)
		planted_on = null
