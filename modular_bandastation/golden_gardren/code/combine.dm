/// How long the other pilot has to accept the combination.
#define GOLDEN_GARDREN_CONFIRM_TIME (15 SECONDS)
/// How long the Golden takes to climb onto the Gardren.
#define GOLDEN_GARDREN_COMBINE_TIME (1.5 SECONDS)

/// Halves of the pair currently in the middle of combining. Blocks a second combination from starting on them.
GLOBAL_LIST_EMPTY(golden_gardren_combining)

// shortcut: one pilot may combine the pair alone and without consent, for testing; switch off before the release build.
/// Lets a single pilot combine the pair: the second half may be empty and its pilot is not asked.
GLOBAL_VAR_INIT(golden_gardren_solo_combine, TRUE)

/datum/action/vehicle/sealed/mecha/golden_gardren_combine
	name = "Объединение"
	desc = "Объединиться с соседним мехом пары в Голден-Гардрен."
	button_icon = 'modular_bandastation/golden_gardren/icons/actions.dmi'
	button_icon_state = "combine"

/datum/action/vehicle/sealed/mecha/golden_gardren_combine/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return
	if(!chassis || !(owner in chassis.occupants))
		return
	// Waits for the other pilot's answer, so it must not hold up the click.
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(golden_gardren_try_combine), chassis, owner)

/// Returns the pilot able to take part in combining, or null.
/proc/golden_gardren_pilot(obj/vehicle/sealed/mecha/mech)
	for(var/mob/living/occupant as anything in mech.occupants)
		if(occupant.loc == mech && occupant.stat == STABLE && !occupant.incapacitated)
			return occupant
	return null

/// Returns why the pair cannot combine right now, or null if it can. [solo] allows one of the halves to have no pilot.
/proc/golden_gardren_combine_blocker(obj/vehicle/sealed/mecha/golden/golden, obj/vehicle/sealed/mecha/gardren/gardren, solo)
	if(QDELETED(golden) || QDELETED(gardren))
		return "пара не найдена"
	if(!isturf(golden.loc) || !isturf(gardren.loc) || golden.z != gardren.z || get_dist(golden, gardren) > 1)
		return "мехи должны стоять рядом"
	var/pilots = 0
	for(var/obj/vehicle/sealed/mecha/mech as anything in list(golden, gardren))
		if(mech.get_integrity() <= 0 || mech.completely_disabled)
			return "[mech.name] неисправен"
		if(mech.is_currently_ejecting)
			return "[mech.name] занят"
		if(golden_gardren_pilot(mech))
			pilots++
		else if(length(mech.occupants))
			return "пилот [mech.name] не в состоянии управлять"
		else if(!solo)
			return "в [mech.name] нет пилота"
	if(!pilots)
		return "нет ни одного пилота"
	return null

/**
 * Starts combining the half [source] with the other half next to it, on behalf of [initiator].
 * Asks the other pilot unless in solo mode, rechecks everything after the answer and after the animation, then builds the frame.
 */
/proc/golden_gardren_try_combine(obj/vehicle/sealed/mecha/source, mob/living/initiator)
	var/solo = GLOB.golden_gardren_solo_combine
	var/obj/vehicle/sealed/mecha/golden/golden
	var/obj/vehicle/sealed/mecha/gardren/gardren
	if(istype(source, /obj/vehicle/sealed/mecha/golden))
		golden = source
		gardren = locate(/obj/vehicle/sealed/mecha/gardren) in orange(1, source)
	else if(istype(source, /obj/vehicle/sealed/mecha/gardren))
		gardren = source
		golden = locate(/obj/vehicle/sealed/mecha/golden) in orange(1, source)
	if(!golden || !gardren)
		source.balloon_alert(initiator, "рядом нет второго меха пары!")
		return
	if((golden in GLOB.golden_gardren_combining) || (gardren in GLOB.golden_gardren_combining))
		source.balloon_alert(initiator, "объединение уже идёт!")
		return
	var/blocker = golden_gardren_combine_blocker(golden, gardren, solo)
	if(blocker)
		source.balloon_alert(initiator, blocker)
		return

	var/mob/living/golden_pilot = golden_gardren_pilot(golden)
	var/mob/living/gardren_pilot = golden_gardren_pilot(gardren)
	if(initiator != golden_pilot && initiator != gardren_pilot)
		return
	var/mob/living/partner = initiator == golden_pilot ? gardren_pilot : golden_pilot

	GLOB.golden_gardren_combining += list(golden, gardren)
	if(partner && !solo)
		to_chat(initiator, span_notice("Запрос на объединение отправлен пилоту [partner.declent_ru(GENITIVE)]."))
		var/answer = tgui_alert(partner, "[initiator.declent_ru(NOMINATIVE)] предлагает объединиться в Голден-Гардрен. Согласиться?", "Объединение", list("Да", "Нет"), GOLDEN_GARDREN_CONFIRM_TIME)
		if(answer != "Да")
			GLOB.golden_gardren_combining -= list(golden, gardren)
			if(!QDELETED(initiator))
				to_chat(initiator, span_warning("Второй пилот не согласился на объединение."))
			return
		// Everything may have changed while waiting for the answer.
		blocker = golden_gardren_combine_blocker(golden, gardren, solo)
		if(blocker || golden_gardren_pilot(golden) != golden_pilot || golden_gardren_pilot(gardren) != gardren_pilot)
			GLOB.golden_gardren_combining -= list(golden, gardren)
			golden_gardren_notify(list(golden_pilot, gardren_pilot), "Объединение сорвалось: [blocker || "пилоты сменились"].")
			return

	gardren.visible_message(span_notice("[golden.declent_ru(NOMINATIVE)] взбирается на плечи [gardren.declent_ru(GENITIVE)]!"))
	playsound(gardren, 'sound/vehicles/mecha/mechmove03.ogg', 75, TRUE)
	animate(golden, pixel_x = golden.base_pixel_x + (gardren.x - golden.x) * ICON_SIZE_X, pixel_y = golden.base_pixel_y + (gardren.y - golden.y) * ICON_SIZE_Y + 16, time = GOLDEN_GARDREN_COMBINE_TIME, easing = QUAD_EASING | EASE_OUT)
	sleep(GOLDEN_GARDREN_COMBINE_TIME)

	blocker = golden_gardren_combine_blocker(golden, gardren, solo)
	if(blocker || golden_gardren_pilot(golden) != golden_pilot || golden_gardren_pilot(gardren) != gardren_pilot)
		GLOB.golden_gardren_combining -= list(golden, gardren)
		if(!QDELETED(golden))
			animate(golden, pixel_x = golden.base_pixel_x, pixel_y = golden.base_pixel_y, time = 0.5 SECONDS)
		golden_gardren_notify(list(golden_pilot, gardren_pilot), "Объединение сорвалось: [blocker || "пилоты сменились"].")
		return

	var/obj/vehicle/sealed/mecha/golden_gardren/combined = new(gardren.loc, TRUE)
	combined.setDir(gardren.dir)
	animate(golden, pixel_x = golden.base_pixel_x, pixel_y = golden.base_pixel_y, time = 0)
	if(!combined.assemble(golden, gardren, golden_pilot, gardren_pilot))
		qdel(combined)
		GLOB.golden_gardren_combining -= list(golden, gardren)
		golden_gardren_notify(list(golden_pilot, gardren_pilot), "Объединение сорвалось: не удалось пересадить пилотов.")
		return
	GLOB.golden_gardren_combining -= list(golden, gardren)
	combined.visible_message(span_boldnotice("[combined.declent_ru(NOMINATIVE)] поднимается во весь рост!"))
	playsound(combined, 'sound/vehicles/mecha/nominal.ogg', 75, TRUE)

/// Tells each still existing pilot about the combination outcome.
/proc/golden_gardren_notify(list/pilots, message)
	for(var/mob/living/pilot in pilots)
		to_chat(pilot, span_warning(message))

#undef GOLDEN_GARDREN_CONFIRM_TIME
#undef GOLDEN_GARDREN_COMBINE_TIME
