/datum/action/cooldown/shadowling/shadow_phase_in
	name = "Теневой вход"
	desc = "Стать нематериальным и проходить сквозь стены. Яркий свет разрывает фазу (если не набрано достаточно слуг)."
	button_icon_state = "shadowling_crawl"
	cooldown_time = 30 SECONDS

	/// Сколько живых траллов нужно, чтобы свет перестал выбрасывать из фазы
	var/light_immunity_thralls = 7

	requires_dark_user = FALSE
	requires_dark_target = FALSE
	max_range = 0
	channel_time = 0

/datum/action/cooldown/shadowling/shadow_phase_in/DoEffect(mob/living/carbon/human/H, atom/_)
	if(istype(H.loc, /obj/effect/dummy/phased_mob))
		to_chat(H, span_warning("Вы уже рассеялись во тьме."))
		return FALSE

	var/turf/start = get_turf(H)
	if(!start)
		return FALSE

	var/obj/effect/dummy/phased_mob/shadowling/P = new(start)
	P.dir = H.dir

	var/datum/shadow_hive/hive = get_shadow_hive()
	var/nt = hive ? hive.count_nt() : 0
	P.light_immunity = (nt >= light_immunity_thralls)

	P.jaunter = H
	H.forceMove(P)

	to_chat(H, span_notice("Вы растворяетесь во тени."))
	return TRUE

/datum/action/cooldown/shadowling/shadow_phase_in/Trigger(mob/clicker, trigger_flags, atom/target)
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE

	if(!CanUse(H))
		owner.balloon_alert(owner, "Сейчас нельзя")
		return FALSE

	if(!ValidateTarget(H, target))
		owner.balloon_alert(owner, "Нет доступных целей")
		return FALSE

	if(channel_time > 0)
		if(!PerformChannel(H, target))
			return FALSE

	return DoEffect(H, target)

/datum/action/cooldown/shadowling/shadow_phase_out
	name = "Теневой выход"
	desc = "Вернуться в материальный мир, завершая теневую фазу."
	button_icon_state = "shadow_phase_out"
	cooldown_time = 0

	requires_dark_user = FALSE
	requires_dark_target = FALSE
	max_range = 0
	channel_time = 0

/datum/action/cooldown/shadowling/shadow_phase_out/DoEffect(mob/living/carbon/human/H, atom/_)
	var/obj/effect/dummy/phased_mob/shadowling/P = H.loc
	if(!istype(P))
		owner.balloon_alert(owner, "Вы и так материальны")
		return FALSE

	P.eject_jaunter(FALSE)
	enable()
	to_chat(H, span_notice("Вы возвращаетесь в материальность."))
	return TRUE

/proc/shadow_phase_start_entry_cooldown(mob/living/carbon/human/H)
	if(!istype(H))
		return

	for(var/datum/action/cooldown/shadowling/shadow_phase_in/A in H.actions)
		if(!A.IsAvailable())
			return
		A.StartCooldown()
		return
