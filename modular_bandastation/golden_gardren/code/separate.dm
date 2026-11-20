/// Splits the Golden-Gardren back into the Golden and the Gardren after both pilots agree.
/datum/action/vehicle/sealed/mecha/golden_gardren_separate
	name = "Разделение"
	desc = "Разделиться на Голдена и Гардрена. Нужны подтверждение обоих пилотов и свободная клетка рядом."
	button_icon = 'modular_bandastation/golden_gardren/icons/actions.dmi'
	button_icon_state = "separate"

/datum/action/vehicle/sealed/mecha/golden_gardren_separate/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return
	if(!istype(chassis, /obj/vehicle/sealed/mecha/golden_gardren) || !(owner in chassis.occupants))
		return
	// Confirmation waits for both pilots and must not hold up the action button.
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(golden_gardren_try_separate), chassis, owner)

/// Returns why the frame cannot separate right now, or null if it can.
/obj/vehicle/sealed/mecha/golden_gardren/proc/separate_blocker(ignore_busy = FALSE)
	// An admin-spawned frame or one that lost a half has nothing to give back, and must not hand out free mechs.
	if(QDELETED(docked_golden) || QDELETED(docked_gardren))
		return "этот мех нельзя разделить"
	if(!isturf(loc))
		return "здесь нельзя разделиться"
	if(get_integrity() <= 0 || completely_disabled)
		return "мех неисправен"
	if(is_currently_ejecting || golden_gardren_is_ejecting(src) || (!ignore_busy && (src in GLOB.golden_gardren_busy)))
		return "мех занят"
	if(occupant_amount() < max_occupants)
		return "для разделения нужны два пилота"
	for(var/mob/living/pilot as anything in occupants)
		if(!golden_gardren_pilot_ready(src, pilot))
			return "оба пилота должны быть в состоянии управлять"
	if(!golden_gardren_find_exit_turf(src))
		return "нет места для разделения"
	return null

/// Keeps the frame busy until both pilots have answered and revalidates the separation.
/proc/golden_gardren_try_separate(obj/vehicle/sealed/mecha/golden_gardren/combined, mob/living/initiator)
	if(QDELETED(combined) || !golden_gardren_pilot_ready(combined, initiator))
		return
	var/blocker = combined.separate_blocker()
	if(blocker)
		combined.balloon_alert(initiator, blocker)
		return
	var/mob/living/partner
	for(var/mob/living/occupant as anything in combined.occupants)
		if(occupant != initiator)
			partner = occupant
			break
	GLOB.golden_gardren_busy += combined
	var/failure = golden_gardren_confirm_pair(initiator, partner, "Разделение", CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(golden_gardren_separate_recheck), combined, initiator, partner))
	GLOB.golden_gardren_busy -= combined
	if(failure)
		golden_gardren_notify(list(initiator, partner), failure)
		return
	if(!combined.disassemble())
		golden_gardren_notify(list(initiator, partner), "Разделение сорвалось: нет места для Голдена.")

/proc/golden_gardren_separate_recheck(obj/vehicle/sealed/mecha/golden_gardren/combined, mob/living/initiator, mob/living/partner)
	if(QDELETED(combined) || !golden_gardren_pilot_ready(combined, initiator) || !golden_gardren_pilot_ready(combined, partner))
		return "пилоты сменились или утратили возможность управлять"
	return combined.separate_blocker(ignore_busy = TRUE)

/**
 * Gives the halves back: the Gardren stays on the frame's turf with the main seat pilot, the Golden lands next to it with the gunner.
 * Damage is spread by the share of integrity the frame has left. Deletes the frame. Returns FALSE if there is no room for the Golden.
 */
/obj/vehicle/sealed/mecha/golden_gardren/proc/disassemble()
	if(separate_blocker())
		return FALSE
	var/turf/frame_turf = get_turf(src)
	var/turf/golden_turf = golden_gardren_find_exit_turf(src)
	if(!golden_turf)
		return FALSE
	var/obj/vehicle/sealed/mecha/golden/golden = docked_golden
	var/obj/vehicle/sealed/mecha/gardren/gardren = docked_gardren
	var/list/mob/living/main_pilots = return_drivers()
	var/list/mob/living/gunners = return_controllers_with_flag(VEHICLE_CONTROL_EQUIPMENT)
	var/integrity_share = get_integrity() / max_integrity

	undock_component(gardren, frame_turf)
	undock_component(golden, golden_turf)
	transfer_stock_parts(gardren)
	gardren.update_integrity(max(1, round(gardren.max_integrity * integrity_share)))
	golden.update_integrity(max(1, round(golden.max_integrity * integrity_share)))

	if(length(main_pilots))
		transfer_pilot(gardren, main_pilots[1])
	if(length(gunners))
		transfer_pilot(golden, gunners[1])
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
