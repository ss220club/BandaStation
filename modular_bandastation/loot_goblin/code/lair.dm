/obj/structure/loot_goblin_lair
	name = "loot goblin lair"
	desc = "Груда тряпья и блестящего хлама. Похоже, кто-то стаскивает сюда добычу."
	icon = 'modular_bandastation/loot_goblin/icons/lair.dmi'
	icon_state = "lair"
	anchored = TRUE
	density = FALSE
	layer = LOW_OBJ_LAYER
	max_integrity = 100
	var/datum/antagonist/loot_goblin/goblin

/obj/structure/loot_goblin_lair/Initialize(mapload, datum/antagonist/loot_goblin/new_goblin)
	. = ..()
	goblin = new_goblin
	register_turf(loc)

/obj/structure/loot_goblin_lair/Destroy()
	UnregisterSignal(loc, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_EXITED))
	if(goblin)
		goblin.lair = null
		goblin.update_influence()
		goblin = null
	return ..()

/obj/structure/loot_goblin_lair/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(old_loc)
		UnregisterSignal(old_loc, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_EXITED))
	register_turf(loc)
	goblin?.update_influence()

/obj/structure/loot_goblin_lair/proc/register_turf(atom/new_loc)
	if(isturf(new_loc))
		RegisterSignals(new_loc, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_EXITED), PROC_REF(on_turf_contents_changed))

/obj/structure/loot_goblin_lair/proc/on_turf_contents_changed(datum/source, atom/movable/thing)
	SIGNAL_HANDLER
	if(isitem(thing))
		goblin?.update_influence()

/datum/action/loot_goblin_lair
	name = "Обустроить логово"
	desc = "Обустроить логово на текущем тайле, только на полу верхнего уровня станции. Логово ставится один раз и не переносится — выберите укромное место, где его никто не найдёт. Новое можно обустроить, только если старое разрушат."
	button_icon = 'modular_bandastation/loot_goblin/icons/lair.dmi'
	button_icon_state = "lair"
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_INCAPACITATED
	var/building = FALSE

/datum/action/loot_goblin_lair/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return
	var/mob/living/user = owner
	if(building || !can_build_lair(user))
		return FALSE
	var/turf/lair_turf = user.loc
	to_chat(user, span_notice("Вы начинаете стаскивать хлам в кучу..."))
	building = TRUE
	var/success = do_after(user, 5 SECONDS, target = lair_turf)
	building = FALSE
	if(!success || QDELETED(src) || owner != user || user.loc != lair_turf || !can_build_lair(user))
		return FALSE
	var/datum/antagonist/loot_goblin/goblin = target
	if(QDELETED(goblin) || goblin.owner != user.mind)
		return FALSE
	goblin.create_lair(lair_turf)
	return TRUE

/datum/action/loot_goblin_lair/proc/can_build_lair(mob/living/user)
	var/datum/antagonist/loot_goblin/goblin = target
	if(goblin.lair)
		to_chat(user, span_warning("Логово уже обустроено, перенести его нельзя."))
		return FALSE
	var/turf/lair_turf = user.loc
	if(!isfloorturf(lair_turf))
		to_chat(user, span_warning("Логово можно обустроить только на полу!"))
		return FALSE
	if(!is_station_level(lair_turf.z) || istype(get_area(lair_turf), /area/shuttle))
		to_chat(user, span_warning("Логово можно обустроить только на станции!"))
		return FALSE
	var/list/station_levels = SSmapping.levels_by_trait(ZTRAIT_STATION)
	if(lair_turf.z != max(station_levels))
		to_chat(user, span_warning("Логово можно обустроить только на верхнем уровне станции!"))
		return FALSE
	if(lair_turf.is_blocked_turf(exclude_mobs = TRUE))
		to_chat(user, span_warning("Здесь слишком тесно для логова!"))
		return FALSE
	return TRUE

/datum/action/loot_goblin_ritual
	name = "Жертвоприношение"
	desc = "Принести в жертву того, кто лежит в логове мёртвым или в критическом состоянии. Кого именно — указано в цели тира. Доступно на тирах 3-5."
	button_icon = 'modular_bandastation/loot_goblin/icons/ritual.dmi'
	button_icon_state = "ritual"
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_INCAPACITATED | AB_CHECK_HANDS_BLOCKED
	var/performing = FALSE

/datum/action/loot_goblin_ritual/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return
	var/datum/antagonist/loot_goblin/goblin = target
	if(!is_ritual_tier(goblin.tier))
		if(feedback)
			owner.balloon_alert(owner, "сейчас не нужно!")
		return FALSE

/datum/action/loot_goblin_ritual/proc/is_ritual_tier(goblin_tier)
	return goblin_tier >= LOOT_GOBLIN_TIER_ANY_SACRIFICE && goblin_tier <= LOOT_GOBLIN_TIER_HEAD

/datum/action/loot_goblin_ritual/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return
	var/mob/living/user = owner
	if(performing)
		return FALSE
	var/mob/living/carbon/human/victim = find_victim(user, feedback = TRUE)
	if(!victim)
		return FALSE
	user.visible_message(
		span_danger("[capitalize(user.declent_ru(NOMINATIVE))] начинает зловещий ритуал над [victim.declent_ru(INSTRUMENTAL)]!"),
		span_notice("Вы начинаете ритуал жертвоприношения..."),
	)
	performing = TRUE
	var/success = do_after(user, LOOT_GOBLIN_RITUAL_TIME, target = victim)
	performing = FALSE
	if(!success || QDELETED(src) || owner != user)
		return FALSE
	var/datum/antagonist/loot_goblin/goblin = target
	if(QDELETED(goblin) || goblin.owner != user.mind || !is_ritual_tier(goblin.tier))
		return FALSE
	if(find_victim(user, feedback = TRUE) != victim)
		return FALSE
	var/turf/destination = goblin.pick_sacrifice_destination()
	if(!destination)
		to_chat(user, span_warning("Ритуал не удался: жертве некуда отправиться."))
		return FALSE
	var/turf/sacrifice_turf = get_turf(victim)
	if(!do_teleport(victim, destination, channel = TELEPORT_CHANNEL_FREE, forced = TRUE))
		to_chat(user, span_warning("Ритуал не удался: жертву не удалось перенести."))
		return FALSE
	sacrifice_turf.visible_message(span_danger("[capitalize(victim.declent_ru(NOMINATIVE))] исчезает во вспышке зелёного света!"))
	log_combat(user, victim, "sacrificed as a loot goblin, teleported to [AREACOORD(destination)]")
	to_chat(user, span_boldnotice("Жертва принята!"))
	goblin.complete_sacrifice()
	return TRUE

/datum/action/loot_goblin_ritual/proc/find_victim(mob/living/user, feedback = FALSE)
	var/datum/antagonist/loot_goblin/goblin = target
	var/turf/lair_turf = get_turf(goblin.lair)
	if(!lair_turf)
		if(feedback)
			to_chat(user, span_warning("Сначала обустройте логово!"))
		return null
	if(get_dist(user, lair_turf) > 1)
		if(feedback)
			to_chat(user, span_warning("Нужно стоять в логове или рядом с ним!"))
		return null
	for(var/mob/living/carbon/human/victim in lair_turf)
		if(victim == user || !(victim.stat in list(SOFT_CRIT, HARD_CRIT, DEAD)))
			continue
		if(goblin.is_fitting_sacrifice(victim))
			return victim
	if(feedback)
		to_chat(user, span_warning("В логове нет подходящей жертвы. Кто нужен — указано в цели; жертва должна быть мертва или в критическом состоянии."))
	return null
