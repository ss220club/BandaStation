/// How long the other pilot has to accept the combination.
#define GOLDEN_GARDREN_CONFIRM_TIME (15 SECONDS)
/// How long the Golden takes to climb onto the Gardren.
#define GOLDEN_GARDREN_COMBINE_TIME (1.5 SECONDS)

/// Mechs of the family in the middle of combining, separating or answering a summon. Blocks a second such action from starting on them.
GLOBAL_LIST_EMPTY(golden_gardren_busy)

// shortcut: on for solo testing on the author's request; switch to FALSE before the PR to the main repository.
/// Lets a single pilot combine or separate the pair: the other half may be empty and the other pilot is not asked.
/// Admins can flip it through the global variables.
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
		if(mech.is_currently_ejecting || golden_gardren_is_ejecting(mech))
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

/// Returns why a combination that had passed its checks cannot go on after a wait, or null if nothing has changed.
/proc/golden_gardren_combine_recheck(obj/vehicle/sealed/mecha/golden/golden, obj/vehicle/sealed/mecha/gardren/gardren, mob/living/golden_pilot, mob/living/gardren_pilot, solo)
	var/blocker = golden_gardren_combine_blocker(golden, gardren, solo)
	if(blocker)
		return blocker
	if(golden_gardren_pilot(golden) != golden_pilot || golden_gardren_pilot(gardren) != gardren_pilot)
		return "пилоты сменились"
	return null

/// Finds the other half next to [source] and starts combining with it on behalf of [initiator], keeping both halves busy meanwhile.
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
	if((golden in GLOB.golden_gardren_busy) || (gardren in GLOB.golden_gardren_busy))
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

	var/list/pair = list(golden, gardren)
	GLOB.golden_gardren_busy += pair
	var/failure = golden_gardren_combine(golden, gardren, golden_pilot, gardren_pilot, initiator, solo)
	GLOB.golden_gardren_busy -= pair
	if(failure)
		golden_gardren_notify(list(golden_pilot, gardren_pilot), failure)

/**
 * Combines the pair: asks the other pilot unless in solo mode, plays the climb, rechecks everything after each wait and builds the frame.
 * Returns the message for the pilots if the combination fell through, or null if the frame was formed.
 */
/proc/golden_gardren_combine(obj/vehicle/sealed/mecha/golden/golden, obj/vehicle/sealed/mecha/gardren/gardren, mob/living/golden_pilot, mob/living/gardren_pilot, mob/living/initiator, solo)
	var/mob/living/partner = initiator == golden_pilot ? gardren_pilot : golden_pilot
	var/failure
	if(partner && !solo)
		to_chat(initiator, span_notice("Запрос на объединение отправлен пилоту [partner.declent_ru(GENITIVE)]."))
		var/answer = tgui_alert(partner, "[initiator.declent_ru(NOMINATIVE)] предлагает объединиться в Голден-Гардрен. Согласиться?", "Объединение", list("Да", "Нет"), GOLDEN_GARDREN_CONFIRM_TIME)
		if(answer != "Да")
			return "Объединение отменено: получен отказ."
		// Everything may have changed while waiting for the answer.
		failure = golden_gardren_combine_recheck(golden, gardren, golden_pilot, gardren_pilot, solo)
		if(failure)
			return "Объединение сорвалось: [failure]."

	gardren.visible_message(span_notice("[golden.declent_ru(NOMINATIVE)] взбирается на плечи [gardren.declent_ru(GENITIVE)]!"))
	playsound(gardren, 'sound/vehicles/mecha/mechmove03.ogg', 75, TRUE)
	animate(golden, pixel_x = golden.base_pixel_x + (gardren.x - golden.x) * ICON_SIZE_X, pixel_y = golden.base_pixel_y + (gardren.y - golden.y) * ICON_SIZE_Y + 16, time = GOLDEN_GARDREN_COMBINE_TIME, easing = QUAD_EASING | EASE_OUT)
	sleep(GOLDEN_GARDREN_COMBINE_TIME)

	failure = golden_gardren_combine_recheck(golden, gardren, golden_pilot, gardren_pilot, solo)
	if(failure)
		if(!QDELETED(golden))
			animate(golden, pixel_x = golden.base_pixel_x, pixel_y = golden.base_pixel_y, time = 0.5 SECONDS)
		return "Объединение сорвалось: [failure]."

	var/obj/vehicle/sealed/mecha/golden_gardren/combined = new(gardren.loc, TRUE)
	combined.setDir(gardren.dir)
	animate(golden, pixel_x = golden.base_pixel_x, pixel_y = golden.base_pixel_y, time = 0)
	if(!combined.assemble(golden, gardren, golden_pilot, gardren_pilot))
		qdel(combined)
		return "Объединение сорвалось: не удалось пересадить пилотов."
	combined.visible_message(span_boldnotice("[combined.declent_ru(NOMINATIVE)] поднимается во весь рост!"))
	playsound(combined, 'sound/vehicles/mecha/nominal.ogg', 75, TRUE)
	return null

/// Tells each still existing pilot that a combination or separation fell through.
/proc/golden_gardren_notify(list/pilots, message)
	for(var/mob/living/pilot in pilots)
		to_chat(pilot, span_warning(message))

#undef GOLDEN_GARDREN_CONFIRM_TIME
#undef GOLDEN_GARDREN_COMBINE_TIME
