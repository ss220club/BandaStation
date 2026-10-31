/** Открывает временную блокировку видимого помещения, разрешённого координатором. */
/datum/ai_project/room_lockdown
	name = "Room Lockdown"
	description = "Предупреждает видимое помещение, затем временно закрывает и блокирует управляемые шлюзы. Требуется подключённый координатор ИИ с разрешением на эту зону."
	research_cost = 2500
	can_be_run = FALSE
	category = AI_PROJECT_MISC
	ability_path = /datum/action/innate/ai/ranged/room_lockdown
	ability_recharge_cost = 1750

/datum/ai_project/room_lockdown/finish()
	add_ability(ability_path)

/** Выбирает видимое помещение и запускает прерываемую блокировку шлюзов. */
/datum/action/innate/ai/ranged/room_lockdown
	name = "Блокировка помещения"
	desc = "Предупреждает видимое помещение за 2,5 секунды, затем закрывает и блокирует подходящие двери на 20 секунд. Требуется разрешение координатора ИИ. Автоматическое снятие болтов требует питания двери и исправной проводки болтов."
	button_icon_state = "lockdown"
	uses = 1
	max_uses = 1
	enable_text = span_notice("Выберите видимое помещение с разрешением вашего координатора ИИ.")
	disable_text = span_notice("Блокировка помещения отменена.")

/datum/action/innate/ai/ranged/room_lockdown/adjust_uses(amount, silent)
	uses = clamp(uses + amount, 0, max_uses)
	build_all_button_icons()

/datum/action/innate/ai/ranged/room_lockdown/IsAvailable(feedback = FALSE)
	return uses > 0 && owner_AI?.find_subcontroller() && ..()

/datum/action/innate/ai/ranged/room_lockdown/do_ability(mob/living/user, atom/clicked_on)
	if(!clicked_on || user != owner_AI || !IsAvailable() || !owner_AI.can_see(clicked_on))
		return FALSE
	var/turf/target = get_turf(clicked_on)
	var/area/zone = get_area(target)
	if(istype(zone, /area/station/maintenance))
		to_chat(owner_AI, span_warning("Блокировка помещения недоступна в технических тоннелях."))
		return FALSE
	if(!target || !ai_supported_location(target) || !owner_AI.find_subcontroller(zone))
		to_chat(owner_AI, span_warning("Координатор ИИ не разрешает команды в этой зоне."))
		return FALSE
	new /datum/ai_room_lockdown(owner_AI, target)
	adjust_uses(-1)
	unset_ranged_ability(user)
	return TRUE

/** Проверяет видимость помещения и выполняет отложенное закрытие подходящих шлюзов. */
/datum/ai_room_lockdown
	/// ИИ, запустивший временную блокировку помещения.
	var/mob/living/silicon/ai/operator
	/// Клетка выбранного помещения для проверки видимости и координатора.
	var/turf/target

/datum/ai_room_lockdown/New(mob/living/silicon/ai/ai, turf/where)
	operator = ai
	target = where
	var/area/zone = get_area(where)
	for(var/mob/living/listener in GLOB.alive_mob_list)
		if(get_area(listener) == zone)
			to_chat(listener, span_bolddanger("Сетевая тревога: через 2,5 секунды помещение будет временно заблокировано."))
	log_game("[key_name(ai)] requested temporary room lockdown in [zone].")
	addtimer(CALLBACK(src, PROC_REF(execute)), 2.5 SECONDS)

/datum/ai_room_lockdown/Destroy()
	operator = null
	target = null
	return ..()

/** Предупреждает видимое помещение и запускает временную блокировку подходящих шлюзов. */
/datum/ai_room_lockdown/proc/execute()
	var/area/zone = get_area(target)
	if(QDELETED(operator) || !target || !operator.find_subcontroller(zone) || !operator.can_see(target))
		qdel(src)
		return
	for(var/turf/tile in get_area_turfs(zone, target.z))
		if(get_area(tile) != zone)
			continue
		for(var/obj/machinery/door/airlock/door in tile)
			INVOKE_ASYNC(src, PROC_REF(close_door), door)
	QDEL_IN(src, 10 SECONDS)

/** Проверяет видимость шлюза и разрешение координатора на блокировку его помещения. */
/datum/ai_room_lockdown/proc/eligible(obj/machinery/door/airlock/door)
	return !QDELETED(operator) && !QDELETED(door) && operator.find_subcontroller(get_area(door)) && operator.can_see(door) && door.canAIControl(operator) && door.hasPower() && !door.machine_stat && !door.locked && !door.welded && door.safe && !door.wires.is_cut(WIRE_BOLTS) && !istype(door, /obj/machinery/door/airlock/external)

/** Закрывает подходящий шлюз и ставит временные болты, не присваивая ручные блокировки. */
/datum/ai_room_lockdown/proc/close_door(obj/machinery/door/airlock/door)
	if(!eligible(door) || !door.close())
		return
	if(QDELETED(src) || !eligible(door) || !door.density)
		return
	new /datum/ai_door_bolt_lease(door)

/** Владеет временными болтами одного шлюза до ручного вмешательства или окончания эффекта. */
/datum/ai_door_bolt_lease
	/// Шлюз, чьими временными болтами управляет эта запись.
	var/obj/machinery/door/airlock/door
	/// Разрешает снять болты только пока их состояние принадлежит этому эффекту.
	var/owns_bolts = FALSE

/datum/ai_door_bolt_lease/New(obj/machinery/door/airlock/target)
	if(QDELETED(target) || target.locked)
		qdel(src)
		return
	door = target
	door.bolt()
	owns_bolts = TRUE
	RegisterSignal(door, COMSIG_AIRLOCK_SET_BOLT, PROC_REF(manually_changed))
	RegisterSignal(door, COMSIG_QDELETING, PROC_REF(door_deleted))
	addtimer(CALLBACK(src, PROC_REF(release)), 20 SECONDS)

/** Передаёт владение болтами ручному управлению при внешней смене их состояния. */
/datum/ai_door_bolt_lease/proc/manually_changed(datum/source, should_bolt)
	SIGNAL_HANDLER
	owns_bolts = FALSE

/** Удаляет временную связь после удаления шлюза. */
/datum/ai_door_bolt_lease/proc/door_deleted(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/** Убирает только болты, поставленные этой временной блокировкой. */
/datum/ai_door_bolt_lease/proc/release()
	if(owns_bolts && !QDELETED(door) && !(door.machine_stat & (BROKEN | EMPED)) && door.hasPower() && !door.wires.is_cut(WIRE_BOLTS))
		door.unbolt()
	qdel(src)

/datum/ai_door_bolt_lease/Destroy()
	if(!QDELETED(door))
		UnregisterSignal(door, list(COMSIG_AIRLOCK_SET_BOLT, COMSIG_QDELETING))
	door = null
	return ..()
