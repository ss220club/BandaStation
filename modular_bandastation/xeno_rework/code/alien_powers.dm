/datum/action/cooldown/alien/select_resin_structure
	name = "Select Resin Structure"
	desc = "Choose the type of resin structure to build."
	button_icon = 'icons/mob/actions/actions_xeno.dmi'
	button_icon_state = "alien_resin"
	plasma_cost = 0
	cooldown_time = 0 SECONDS
	var/static/list/structures = list(
		"resin wall" = /obj/structure/alien/resin/wall,
		"resin membrane" = /obj/structure/alien/resin/membrane,
		"resin nest" = /obj/structure/bed/nest,
	)

/datum/action/cooldown/alien/select_resin_structure/Activate(atom/target)
	var/choice = tgui_input_list(owner, "Select a shape to build", "Resin building", structures)
	if(isnull(choice) || QDELETED(src) || QDELETED(owner))
		return FALSE

	var/obj/structure/choice_path = structures[choice]
	if(!ispath(choice_path))
		return FALSE

	var/mob/living/carbon/alien/alien_owner = owner
	alien_owner.selected_resin_structure = choice_path
	to_chat(owner, span_noticealien("You prepare to build a [choice]."))
	return TRUE

/datum/action/cooldown/alien/build_resin_structure
	name = "Build Resin Structure"
	desc = "Build the selected resin structure on a nearby tile."
	button_icon = 'icons/mob/actions/actions_xeno.dmi'
	button_icon_state = "alien_resin"
	plasma_cost = 55
	click_to_activate = TRUE
	unset_after_click = FALSE
	var/obj/structure/made_structure_type
	var/build_time = 3 SECONDS

/datum/action/cooldown/alien/build_resin_structure/proc/check_for_duplicate(turf/location)
	var/obj/structure/existing_thing = locate(made_structure_type) in location
	if(existing_thing)
		to_chat(owner, span_warning("There is already \a [existing_thing] here!"))
		return FALSE
	// Проверка на множественные типы смолы
	var/static/list/structures = list(
		"resin wall" = /obj/structure/alien/resin/wall,
		"resin membrane" = /obj/structure/alien/resin/membrane,
		"resin nest" = /obj/structure/bed/nest,
	)
	for(var/blocker_name in structures)
		var/obj/structure/blocker_type = structures[blocker_name]
		if(locate(blocker_type) in location)
			to_chat(owner, span_warning("There is already a resin structure there!"))
			return FALSE
	return TRUE

/datum/action/cooldown/alien/build_resin_structure/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/alien/alien_owner = owner
	if(!alien_owner.selected_resin_structure)
		if(feedback)
			to_chat(owner, span_warning("You must select a structure to build first!"))
		return FALSE
	if(!isturf(owner.loc) || isspaceturf(owner.loc))
		if(feedback)
			to_chat(owner, span_warning("You can't build here!"))
		return FALSE
	return TRUE

/datum/action/cooldown/alien/build_resin_structure/PreActivate(atom/target)
	var/turf/location = get_turf(target)
	if(!location)
		return FALSE

	if(get_dist(owner, location) > 1)
		to_chat(owner, span_warning("You can only build on adjacent tiles!"))
		return FALSE

	if(!locate(/obj/structure/alien/weeds) in location)
		to_chat(owner, span_warning("You can only build on xenomorph weeds!"))
		return FALSE

	var/mob/living/carbon/alien/alien_owner = owner
	made_structure_type = alien_owner.selected_resin_structure
	if(!ispath(made_structure_type))
		to_chat(owner, span_warning("No structure selected!"))
		return FALSE

	if(!check_for_duplicate(location))
		return FALSE

	return ..()

/datum/action/cooldown/alien/build_resin_structure/Activate(atom/target)
	var/turf/location = get_turf(target)
	if(!location)
		return FALSE

	var/mob/living/carbon/alien/alien_owner = owner
	var/obj/structure/choice_path = alien_owner.selected_resin_structure
	if(!ispath(choice_path))
		to_chat(owner, span_warning("No structure selected!"))
		return FALSE

	if(alien_owner.getPlasma() < plasma_cost)
		to_chat(owner, span_warning("You don't have enough plasma to start building!"))
		return FALSE

	alien_owner.adjustPlasma(-plasma_cost)

	// Определяем название структуры для сообщений
	var/structure_name
	for(var/name in list("resin wall" = /obj/structure/alien/resin/wall, "resin membrane" = /obj/structure/alien/resin/membrane, "resin nest" = /obj/structure/bed/nest))
		if(choice_path == list("resin wall" = /obj/structure/alien/resin/wall, "resin membrane" = /obj/structure/alien/resin/membrane, "resin nest" = /obj/structure/bed/nest)[name])
			structure_name = name
			break

	owner.visible_message(
		span_notice("[owner] begins to secrete a thick purple substance towards [location]."),
		span_notice("You start shaping a [structure_name] on [location == owner.loc ? "your tile" : "the adjacent tile"]."),
	)

	if(!do_after(owner, build_time, target = location, extra_checks = CALLBACK(src, /datum/action/cooldown/alien/build_resin_structure/proc/check_for_duplicate, location)))
		to_chat(owner, span_warning("Your construction was interrupted!"))
		return FALSE

	if(location == owner.loc)
		owner.visible_message(
			span_notice("[owner] finishes shaping a [structure_name]."),
			span_notice("You finish shaping a [structure_name]."),
		)
	else
		owner.visible_message(
			span_notice("[owner] finishes shaping a [structure_name] on [location]."),
			span_notice("You finish shaping a [structure_name] on the adjacent tile."),
		)

	new choice_path(location)
	return TRUE
