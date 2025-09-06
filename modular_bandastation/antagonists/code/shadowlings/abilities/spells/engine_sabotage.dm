/datum/action/cooldown/shadowling/engine_sabotage
	name = "Саботаж двигателей"
	desc = "Вы обращаетесь к Единой тени, и та хитро ломает двигатели спасательного шаттла, задерживая его прибытие на 10 минут."
	button_icon_state = "shadow_engine"
	cooldown_time = 0
	requires_dark_user = FALSE
	requires_dark_target = FALSE
	max_range = 0
	channel_time = 0

/datum/action/cooldown/shadowling/engine_sabotage/IsAvailable(feedback = FALSE)
	if(!..())
		return FALSE
	if(GLOB.shadowling_engine_sabotage_used)
		if(feedback && owner)
			to_chat(owner, span_warning("Саботаж уже был использован в этом раунде."))
		return FALSE
	return TRUE

/datum/action/cooldown/shadowling/engine_sabotage/DoEffect(mob/living/carbon/human/H, atom/_)
	if(GLOB.shadowling_engine_sabotage_used)
		return FALSE

	var/datum/team/shadow_hive/hive = get_shadow_hive()
	if(!hive)
		return FALSE

	var/success = hive.apply_evac_delay(10 MINUTES)
	GLOB.shadowling_engine_sabotage_used = TRUE

	if(success)
		to_chat(H, span_boldnotice("Вы ломаете силовые контуры — эвакуация задержана на 10 минут."))
	else
		to_chat(H, span_boldnotice("Вы срываете работу двигателей — эвакуация должна быть задержана."))

	Remove(H)
	qdel(src)
	return TRUE
