/datum/action/changeling/headcrab
	name = "Last Resort"
	desc = "Мы жертвуем своим нынешним телом в трудную минуту, получая в управление носитель, который может поселить наше подобие в новом хозяине. Стоит 20 химикатов."
	helptext = "Мы станем контролировать маленькое, хрупкое существо. Мы можем атаковать труп, чтобы заложить яйцо, которое медленно созреет и превратится в новую форму для нас."
	button_icon_state = "last_resort"
	chemical_cost = 20
	dna_cost = 1
	req_stat = DEAD
	ignores_fakedeath = TRUE
	disabled_by_fire = FALSE

/datum/action/changeling/headcrab/can_be_used_by(mob/living/user)
	if(HAS_TRAIT(user, TRAIT_TEMPORARY_BODY))
		return FALSE
	if(isanimal_or_basicmob(user) && !istype(user, /mob/living/basic/headslug) && !isconstruct(user) && !(user.mob_biotypes & MOB_SPIRIT))
		return TRUE
	return ..()

/datum/action/changeling/headcrab/sting_action(mob/living/user)
	set waitfor = FALSE
	var/confirm = tgui_alert(user, "Уверены ли мы в том, что хотим уничтожить свое тело и создать червя?", "Last Resort", list("Да", "Нет"))
	if(confirm != "Да")
		return

	..()
	var/datum/mind/stored_mind = user.mind
	var/list/organs = user.get_organs_for_zone(BODY_ZONE_HEAD, TRUE)

	explosion(user, light_impact_range = 2, adminlog = TRUE, explosion_cause = src)
	for(var/mob/living/carbon/human/blinded_human in range(2, user))
		var/obj/item/organ/eyes/eyes = blinded_human.get_organ_slot(ORGAN_SLOT_EYES)
		if(!eyes || blinded_human.is_blind())
			continue
		to_chat(blinded_human, span_userdanger("Вы ослеплены кровавым дождем!"))
		blinded_human.Stun(4 SECONDS)
		blinded_human.set_eye_blur_if_lower(40 SECONDS)
		blinded_human.adjust_confusion(12 SECONDS)

	for(var/mob/living/silicon/blinded_silicon in range(2,user))
		to_chat(blinded_silicon, span_userdanger("Ваши сенсоры отключены ливнем крови!"))
		blinded_silicon.Paralyze(6 SECONDS)

	var/turf/user_turf = get_turf(user)
	user.transfer_observers_to(user_turf) // user is about to be deleted, store orbiters on the turf
	if(user.stat != DEAD)
		user.investigate_log("has been gibbed by headslug burst.", INVESTIGATE_DEATHS)
	user.gib(DROP_ALL_REMAINS)
	. = TRUE
	addtimer(CALLBACK(src, PROC_REF(spawn_headcrab), stored_mind, user_turf, organs), 1 SECONDS)

/// Creates the headrab to occupy
/datum/action/changeling/headcrab/proc/spawn_headcrab(datum/mind/stored_mind, turf/spawn_location, list/organs)
	var/mob/living/basic/headslug/crab = new(spawn_location)
	for(var/obj/item/organ/I in organs)
		I.forceMove(crab)

	stored_mind.transfer_to(crab, force_key_move = TRUE)
	spawn_location.transfer_observers_to(crab)
	to_chat(crab, span_warning("Вы вырываетесь из останков своего прежнего тела под ливнем кровавых ошметков!"))
