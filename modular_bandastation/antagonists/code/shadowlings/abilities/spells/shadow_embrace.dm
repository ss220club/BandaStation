/datum/action/cooldown/shadowling/shadow_phase
	name = "Теневой вход"
	desc = "Стать нематериальным и проходить сквозь стены на ограниченное время. Яркий свет до набора достаточного числа слуг разрывает фазу."
	button_icon_state = "shadowling_crawl"
	cooldown_time = 30 SECONDS

	requires_dark_user = FALSE
	requires_dark_target = FALSE
	max_range = 0
	channel_time = 0

	/// Сколько длится одна сессия фазы
	var/phase_duration = 12 SECONDS
	/// Порог живых слуг, после которого свет перестаёт выбивать из фазы
	var/light_immunity_thralls = 7

/datum/action/cooldown/shadowling/shadow_phase/Trigger(mob/clicker, trigger_flags, atom/target)
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE

	var/obj/effect/dummy/phased_mob/shadowling/P = istype(H.loc, /obj/effect/dummy/phased_mob/shadowling) ? H.loc : null
	var/is_in_phase = !!P

	if(!is_in_phase)
		if(!CanUse(H))
			owner.balloon_alert(owner, "Сейчас нельзя")
			return FALSE
		if(channel_time > 0)
			if(!PerformChannel(H, null))
				return FALSE
		if(!enter_phase(H))
			return FALSE
		return TRUE

	if(!exit_phase(H, forced_out = FALSE))
		return FALSE

	StartCooldown()
	return TRUE

/datum/action/cooldown/shadowling/shadow_phase/proc/enter_phase(mob/living/carbon/human/H)
	var/turf/start = get_turf(H)
	if(!start)
		return FALSE

	if(istype(H.loc, /obj/effect/dummy/phased_mob))
		to_chat(H, span_warning("Вы уже рассеялись во тьме."))
		return FALSE

	var/obj/effect/dummy/phased_mob/shadowling/P = new(start)
	P.dir = H.dir

	var/datum/shadow_hive/hive = get_shadow_hive()
	var/nt = hive ? hive.count_nt() : 0
	P.light_immunity = (nt >= light_immunity_thralls)

	P.jaunter = H
	H.forceMove(P)

	addtimer(CALLBACK(src, PROC_REF(_auto_exit_if_still_inside), WEAKREF(P)), phase_duration)

	to_chat(H, span_notice("Вы растворяетесь во тени."))
	return TRUE

/datum/action/cooldown/shadowling/shadow_phase/proc/_auto_exit_if_still_inside(datum/weakref/p_ref)
	var/obj/effect/dummy/phased_mob/shadowling/P = p_ref?.resolve()
	if(!istype(P))
		return
	var/mob/living/L = P.jaunter
	if(!istype(L))
		return
	P.eject_jaunter(FALSE)

/datum/action/cooldown/shadowling/shadow_phase/proc/exit_phase(mob/living/carbon/human/H, forced_out = FALSE)
	var/obj/effect/dummy/phased_mob/shadowling/P = H.loc
	if(istype(P))
		P.eject_jaunter(forced_out)
		to_chat(H, span_notice("Вы возвращаетесь в материальность."))
		return TRUE

	H.remove_status_effect(/datum/status_effect/shadow/phase)
	to_chat(H, span_notice("Вы возвращаетесь в материальность."))
	return TRUE

/proc/shadow_phase_start_entry_cooldown(mob/living/carbon/human/H)
	if(!istype(H))
		return

	for(var/datum/action/cooldown/shadowling/shadow_phase/A in H.actions)
		if(!A.IsAvailable())
			return
		A.StartCooldown()
		return
