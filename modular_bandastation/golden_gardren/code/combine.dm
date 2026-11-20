/// How long each pilot has to answer their confirmation prompt.
#define GOLDEN_GARDREN_CONFIRM_TIME (15 SECONDS)
/// How long the Golden takes to climb onto the Gardren.
#define GOLDEN_GARDREN_COMBINE_TIME (1.5 SECONDS)

/// Mechs of the family in the middle of combining, separating or answering a summon. Blocks a second such action from starting on them.
GLOBAL_LIST_EMPTY(golden_gardren_busy)

/datum/action/vehicle/sealed/mecha/golden_gardren_combine
	name = "Объединение"
	desc = "Объединиться с соседним мехом пары в Голден-Гардрен. Нужно подтверждение обоих пилотов."
	button_icon = 'modular_bandastation/golden_gardren/icons/actions.dmi'
	button_icon_state = "combine"

/datum/action/vehicle/sealed/mecha/golden_gardren_combine/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return
	if(!chassis || !(owner in chassis.occupants))
		return
	// Confirmation waits for both pilots and must not hold up the action button.
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(golden_gardren_try_combine), chassis, owner)

/proc/golden_gardren_pilot_ready(obj/vehicle/sealed/mecha/mech, mob/living/pilot)
	return !QDELETED(pilot) && pilot.loc == mech && mech.is_occupant(pilot) && pilot.stat == STABLE && !pilot.incapacitated

/// Revalidate the operation after each pilot's confirmation.
/proc/golden_gardren_confirm_pair(mob/living/initiator, mob/living/partner, title, datum/callback/recheck)
	var/list/answers = list("Да", "Нет")
	if(tgui_alert(initiator, "Подтвердить действие «[title]»?", title, answers, GOLDEN_GARDREN_CONFIRM_TIME) != "Да")
		return "[title] отменено: подтверждение не получено."
	var/failure = recheck.Invoke()
	if(failure)
		return "[title] сорвалось: [failure]."
	to_chat(initiator, span_notice("Ожидаем подтверждения второго пилота."))
	if(tgui_alert(partner, "[initiator.declent_ru(NOMINATIVE)] запрашивает действие «[title]». Согласиться?", title, answers, GOLDEN_GARDREN_CONFIRM_TIME) != "Да")
		return "[title] отменено: подтверждение не получено."
	failure = recheck.Invoke()
	return failure ? "[title] сорвалось: [failure]." : null

/// Returns the pilot able to take part in combining, or null.
/proc/golden_gardren_pilot(obj/vehicle/sealed/mecha/mech)
	for(var/mob/living/occupant as anything in mech.occupants)
		if(golden_gardren_pilot_ready(mech, occupant))
			return occupant
	return null

/// Returns why the pair cannot combine right now, or null if it can.
/proc/golden_gardren_combine_blocker(obj/vehicle/sealed/mecha/golden/golden, obj/vehicle/sealed/mecha/gardren/gardren)
	if(QDELETED(golden) || QDELETED(gardren))
		return "пара не найдена"
	if(!isturf(golden.loc) || !isturf(gardren.loc) || golden.z != gardren.z || get_dist(golden, gardren) > 1)
		return "мехи должны стоять рядом"
	for(var/obj/vehicle/sealed/mecha/mech as anything in list(golden, gardren))
		if(mech.get_integrity() <= 0 || mech.completely_disabled)
			return "[mech.name] неисправен"
		if(mech.is_currently_ejecting || golden_gardren_is_ejecting(mech))
			return "[mech.name] занят"
		if(!golden_gardren_pilot(mech))
			return length(mech.occupants) ? "пилот [mech.name] не в состоянии управлять" : "в [mech.name] нет пилота"
	return null

/// Returns why a combination that had passed its checks cannot go on after a wait, or null if nothing has changed.
/proc/golden_gardren_combine_recheck(obj/vehicle/sealed/mecha/golden/golden, obj/vehicle/sealed/mecha/gardren/gardren, mob/living/golden_pilot, mob/living/gardren_pilot)
	var/blocker = golden_gardren_combine_blocker(golden, gardren)
	if(blocker)
		return blocker
	if(golden_gardren_pilot(golden) != golden_pilot || golden_gardren_pilot(gardren) != gardren_pilot)
		return "пилоты сменились"
	return null

/// Finds the other half next to [source] and starts combining with it on behalf of [initiator], keeping both halves busy meanwhile.
/proc/golden_gardren_try_combine(obj/vehicle/sealed/mecha/source, mob/living/initiator)
	if(QDELETED(source) || !golden_gardren_pilot_ready(source, initiator))
		return
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
	var/blocker = golden_gardren_combine_blocker(golden, gardren)
	if(blocker)
		source.balloon_alert(initiator, blocker)
		return
	var/mob/living/golden_pilot = golden_gardren_pilot(golden)
	var/mob/living/gardren_pilot = golden_gardren_pilot(gardren)
	if(initiator != golden_pilot && initiator != gardren_pilot)
		return

	var/list/pair = list(golden, gardren)
	GLOB.golden_gardren_busy += pair
	var/failure = golden_gardren_combine(golden, gardren, golden_pilot, gardren_pilot, initiator)
	GLOB.golden_gardren_busy -= pair
	if(failure)
		golden_gardren_notify(list(golden_pilot, gardren_pilot), failure)

/**
 * Asks both pilots to confirm, revalidates after every wait and builds the frame.
 * Returns the message for the pilots if the combination fell through, or null if the frame was formed.
 */
/proc/golden_gardren_combine(obj/vehicle/sealed/mecha/golden/golden, obj/vehicle/sealed/mecha/gardren/gardren, mob/living/golden_pilot, mob/living/gardren_pilot, mob/living/initiator)
	var/mob/living/partner = initiator == golden_pilot ? gardren_pilot : golden_pilot
	var/failure = golden_gardren_confirm_pair(initiator, partner, "Объединение", CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(golden_gardren_combine_recheck), golden, gardren, golden_pilot, gardren_pilot))
	if(failure)
		return failure

	gardren.visible_message(span_notice("[golden.declent_ru(NOMINATIVE)] взбирается на плечи [gardren.declent_ru(GENITIVE)]!"))
	playsound(gardren, 'sound/vehicles/mecha/mechmove03.ogg', 75, TRUE)
	animate(golden, pixel_x = golden.base_pixel_x + (gardren.x - golden.x) * ICON_SIZE_X, pixel_y = golden.base_pixel_y + (gardren.y - golden.y) * ICON_SIZE_Y + 16, time = GOLDEN_GARDREN_COMBINE_TIME, easing = QUAD_EASING | EASE_OUT)
	sleep(GOLDEN_GARDREN_COMBINE_TIME)

	failure = golden_gardren_combine_recheck(golden, gardren, golden_pilot, gardren_pilot)
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
		if(!QDELETED(pilot))
			to_chat(pilot, span_warning(message))

#undef GOLDEN_GARDREN_CONFIRM_TIME
#undef GOLDEN_GARDREN_COMBINE_TIME
