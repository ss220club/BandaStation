/// How long the other pilot has to accept the separation.
#define GOLDEN_GARDREN_SEPARATE_CONFIRM_TIME (15 SECONDS)

/// Splits the Golden-Gardren back into the Golden and the Gardren. Both pilots must agree unless in solo mode.
/datum/action/vehicle/sealed/mecha/golden_gardren_separate
	name = "Разделение"
	desc = "Разделиться обратно на Голдена и Гардрена. Голдену нужна свободная соседняя клетка."
	button_icon = 'modular_bandastation/golden_gardren/icons/actions.dmi'
	button_icon_state = "separate"

/datum/action/vehicle/sealed/mecha/golden_gardren_separate/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return
	if(!istype(chassis, /obj/vehicle/sealed/mecha/golden_gardren) || !(owner in chassis.occupants))
		return
	// Waits for the other pilot's answer, so it must not hold up the click.
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(golden_gardren_try_separate), chassis, owner)

/// Returns why the frame cannot separate right now, or null if it can.
/obj/vehicle/sealed/mecha/golden_gardren/proc/separate_blocker()
	// An admin-spawned frame or one that lost a half has nothing to give back, and must not hand out free mechs.
	if(QDELETED(docked_golden) || QDELETED(docked_gardren))
		return "этот мех нельзя разделить"
	if(!isturf(loc))
		return "здесь нельзя разделиться"
	if(get_integrity() <= 0 || completely_disabled)
		return "мех неисправен"
	if(is_currently_ejecting || emergency_eject_timer || (src in GLOB.golden_gardren_combining))
		return "мех занят"
	if(!find_exit_turf())
		return "нет места для разделения"
	return null

/// Asks the other pilot unless in solo mode, rechecks everything after the answer, then splits the frame.
/proc/golden_gardren_try_separate(obj/vehicle/sealed/mecha/golden_gardren/combined, mob/living/initiator)
	var/blocker = combined.separate_blocker()
	if(blocker)
		combined.balloon_alert(initiator, blocker)
		return
	var/mob/living/partner
	for(var/mob/living/occupant as anything in combined.occupants)
		if(occupant != initiator)
			partner = occupant
	GLOB.golden_gardren_combining += combined
	if(partner && !GLOB.golden_gardren_solo_combine)
		to_chat(initiator, span_notice("Запрос на разделение отправлен пилоту [partner.declent_ru(GENITIVE)]."))
		var/answer = tgui_alert(partner, "[initiator.declent_ru(NOMINATIVE)] предлагает разделиться на Голдена и Гардрена. Согласиться?", "Разделение", list("Да", "Нет"), GOLDEN_GARDREN_SEPARATE_CONFIRM_TIME)
		GLOB.golden_gardren_combining -= combined
		if(answer != "Да")
			if(!QDELETED(initiator))
				to_chat(initiator, span_warning("Второй пилот не согласился на разделение."))
			return
		// Everything may have changed while waiting for the answer.
		if(QDELETED(combined) || !(initiator in combined.occupants) || !(partner in combined.occupants))
			golden_gardren_notify(list(initiator, partner), "Разделение сорвалось: пилоты сменились.")
			return
		blocker = combined.separate_blocker()
		if(blocker)
			golden_gardren_notify(list(initiator, partner), "Разделение сорвалось: [blocker].")
			return
	else
		GLOB.golden_gardren_combining -= combined
	if(!combined.disassemble())
		golden_gardren_notify(list(initiator, partner), "Разделение сорвалось: нет места для Голдена.")

/**
 * Gives the halves back: the Gardren stays on the frame's turf with the main seat pilot, the Golden lands next to it with the gunner.
 * Damage is spread by the share of integrity the frame has left. Deletes the frame. Returns FALSE if there is no room for the Golden.
 */
/obj/vehicle/sealed/mecha/golden_gardren/proc/disassemble()
	var/turf/frame_turf = get_turf(src)
	var/turf/golden_turf = find_exit_turf()
	if(!frame_turf || !golden_turf || QDELETED(docked_golden) || QDELETED(docked_gardren))
		return FALSE
	var/obj/vehicle/sealed/mecha/golden/golden = docked_golden
	var/obj/vehicle/sealed/mecha/gardren/gardren = docked_gardren
	var/list/mob/living/main_pilots = return_drivers()
	var/list/mob/living/gunners = return_controllers_with_flag(VEHICLE_CONTROL_EQUIPMENT)
	var/integrity_share = get_integrity() / max_integrity

	undock_component(gardren, frame_turf)
	undock_component(golden, golden_turf)
	for(var/obj/item/stock_parts/part in list(cell, scanmod, capacitor, servo))
		part.forceMove(gardren)
	locate_parts()
	gardren.locate_parts()
	gardren.update_integrity(max(1, round(gardren.max_integrity * integrity_share)))
	golden.update_integrity(max(1, round(golden.max_integrity * integrity_share)))

	if(length(main_pilots))
		move_pilot_to(gardren, main_pilots[1])
	if(length(gunners))
		move_pilot_to(golden, gunners[1])
	// Anyone else left inside walks out on their own.
	for(var/mob/living/leftover as anything in occupants?.Copy())
		mob_exit(leftover, silent = TRUE)

	gardren.setDir(dir)
	golden.setDir(dir)
	// The Golden jumps down from the Gardren's shoulders.
	golden.pixel_x = golden.base_pixel_x + (frame_turf.x - golden_turf.x) * ICON_SIZE_X
	golden.pixel_y = golden.base_pixel_y + (frame_turf.y - golden_turf.y) * ICON_SIZE_Y + 16
	animate(golden, pixel_x = golden.base_pixel_x, pixel_y = golden.base_pixel_y, time = 0.5 SECONDS, easing = QUAD_EASING | EASE_IN)
	gardren.visible_message(span_notice("[golden.declent_ru(NOMINATIVE)] спрыгивает с плеч [gardren.declent_ru(GENITIVE)]!"))
	playsound(gardren, 'sound/vehicles/mecha/mechmove04.ogg', 75, TRUE)
	log_message("Separated into [golden] and [gardren].", LOG_MECHA)
	qdel(src)
	return TRUE

/// Takes a half out of the frame and switches it back on.
/obj/vehicle/sealed/mecha/golden_gardren/proc/undock_component(obj/vehicle/sealed/mecha/component, turf/destination)
	UnregisterSignal(component, COMSIG_QDELETING)
	if(component == docked_golden)
		docked_golden = null
	else if(component == docked_gardren)
		docked_gardren = null
	component.forceMove(destination)
	component.completely_disabled = FALSE
	START_PROCESSING(SSobj, component)

#undef GOLDEN_GARDREN_SEPARATE_CONFIRM_TIME
