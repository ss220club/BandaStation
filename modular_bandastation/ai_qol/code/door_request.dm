#define DOOR_AI_REQUEST_COOLDOWN (10 SECONDS)

/obj/machinery/door/airlock
	COOLDOWN_DECLARE(denied_sound_cd)
	COOLDOWN_DECLARE(answer_cd)
	var/static/list/requesters = list()

/obj/machinery/door/airlock/attack_hand_secondary(mob/living/user, list/modifiers)
	var/request_key = "[user.ckey]_[REF(src)]"
	var/last_request_time = requesters[request_key]
	if(last_request_time && world.time < last_request_time + DOOR_AI_REQUEST_COOLDOWN)
		to_chat(user, span_warning("Вы уже запросили ИИ на открытие этого шлюза."))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	. = ..()

	if(!hasPower())
		to_chat(user, span_warning("Вы нажимаете на кнопку, но шлюз обесточен."))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	if(hackProof)
		to_chat(user, span_warning("Тут нет кнопки на запрос ИИ."))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	// Автоодобрение
	var/auto_opened = FALSE
	for(var/mob/living/silicon/ai/ai_mob as anything in GLOB.ai_list)
		if(ai_mob.stat == DEAD)
			continue
		if(ai_mob.control_disabled)
			continue
		if(istype(ai_mob.loc, /obj/item/aicard))
			continue

		if(ai_mob.try_autoapprove_open_door(user, src))
			auto_opened = TRUE
			break

	if(auto_opened)
		balloon_alert(user, "Доступ разрешен!")
		requesters[request_key] = world.time
		addtimer(CALLBACK(src, PROC_REF(clear_stale_requester), request_key, world.time), DOOR_AI_REQUEST_COOLDOWN)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	var/any_ai = FALSE

	for(var/mob/living/silicon/ai/ai_mob as anything in GLOB.ai_list)
		if(ai_mob.stat == DEAD)
			continue
		if(ai_mob.control_disabled)
			continue

		if(istype(ai_mob.loc, /obj/item/aicard))
			continue

		var/deny_link = "<a href='byond://?src=[REF(ai_mob)];open_door=[REF(src)];user=[REF(user)];action=deny'> (Отклонить)</a>"
		var/open_link = "<a href='byond://?src=[REF(ai_mob)];open_door=[REF(src)];user=[REF(user)];action=open'> (Открыть)</a>"
		var/bolt_link = "<a href='byond://?src=[REF(ai_mob)];open_door=[REF(src)];user=[REF(user)];action=bolt'> (Болтирование)</a>"

		if(ai_mob.deployed_shell)
			if(!is_station_level(ai_mob.deployed_shell.registered_z))
				continue
			to_chat(ai_mob.deployed_shell, "<b><a href='byond://?src=[REF(ai_mob)];track=[html_encode(user.name)]'>[user]</a></b> запрашивает открытие [src].[deny_link][open_link][bolt_link]")
			any_ai = TRUE
			continue

		if(!is_station_level(ai_mob.registered_z))
			continue
		to_chat(ai_mob, "<b><a href='byond://?src=[REF(ai_mob)];track=[html_encode(user.name)]'>[user]</a></b> запрашивает открытие [src].[deny_link][open_link][bolt_link]")
		any_ai = TRUE

	if(any_ai)
		balloon_alert(user, "ИИ запрошен!")
	else
		balloon_alert(user, "ИИ недоступен!")

	requesters[request_key] = world.time
	addtimer(CALLBACK(src, PROC_REF(clear_stale_requester), request_key, world.time), DOOR_AI_REQUEST_COOLDOWN)

	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/door/airlock/proc/clear_stale_requester(key, set_at)
	if(requesters[key] == set_at)
		requesters -= key

#undef DOOR_AI_REQUEST_COOLDOWN
