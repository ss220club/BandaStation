// MARK: Ability
/datum/action/cooldown/shadowling/recuperation
	name = "Рекуперация"
	desc = "Преобразовать связанного слугу в младшего Тенеморфа. Занимает 15 секунд и требует неподвижности цели."
	button_icon_state = "shadow_recuperation"
	cooldown_time = 45 SECONDS
	requires_dark_user = FALSE
	requires_dark_target = FALSE
	click_to_activate = TRUE
	unset_after_click = TRUE
	// Shadowling related
	channel_time = 15 SECONDS
	max_range = 1
	min_req = 1
	max_req = 3
	required_thralls = 70
	var/prev_alpha
	var/static/sfx_begin = 'sound/effects/magic/teleport_diss.ogg'
	var/static/sfx_end   = 'sound/effects/ghost.ogg'
	var/obj/effect/beam/active_beam
	var/obj/structure/shadowling_cocoon/cover

/datum/action/cooldown/shadowling/recuperation/Trigger(mob/clicker, trigger_flags, atom/target)
	return ..()

/datum/action/cooldown/shadowling/recuperation/InterceptClickOn(mob/living/clicker, params, atom/target)
	if(!IsAvailable(TRUE))
		unset_click_ability(clicker, TRUE)
		return FALSE

	var/mob/living/carbon/human/T = target
	if(!istype(T))
		clicker.balloon_alert(clicker, "нужна гуманоидная цель")
		unset_click_ability(clicker, TRUE)
		return FALSE

	if(get_dist(clicker, T) > 1)
		clicker.balloon_alert(clicker, "слишком далеко")
		unset_click_ability(clicker, TRUE)
		return FALSE

	var/datum/team/shadow_hive/hive = get_shadow_hive()
	if(!hive)
		unset_click_ability(clicker, TRUE)
		return FALSE

	if(!(T in hive.thralls) || !T.get_organ_slot(ORGAN_SLOT_BRAIN_THRALL))
		clicker.balloon_alert(clicker, "требуется слуга")
		unset_click_ability(clicker, TRUE)
		return FALSE

	if(T in hive.lings)
		clicker.balloon_alert(clicker, "уже линг")
		unset_click_ability(clicker, TRUE)
		return FALSE

	StartCooldown()

	start_beam(clicker, T)
	attach_cover(T)
	prev_alpha = T.alpha
	T.alpha = 0

	var/start_loc = T.loc
	if(!do_after(clicker, channel_time, T))
		stop_beam()
		detach_cover(T)
		T.alpha = prev_alpha
		unset_click_ability(clicker, TRUE)
		return FALSE

	if(QDELETED(T) || T.loc != start_loc || get_dist(clicker, T) > 1)
		stop_beam()
		detach_cover(T)
		T.alpha = prev_alpha
		unset_click_ability(clicker, TRUE)
		return FALSE

	T.shadowling_strip_quirks()
	T.set_species(/datum/species/shadow/shadowling)

	for(var/datum/action/cooldown/ability in T.actions)
		if(ability.type in typesof(/datum/action/cooldown/shadowling))
			ability.Remove(T)

	// Make our thrall a lesser Shadowling
	hive.join_member(T, SHADOWLING_ROLE_LESSER)

	to_chat(clicker, span_notice("Вы переплавляете сущность [T.real_name] во тьму — он восстаёт младшим тенеморфом."))
	to_chat(T, span_danger("Тьма переписывает вашу плоть и волю... Вы становитесь младшим тенеморфом!"))
	playsound(get_turf(T), sfx_end, 65, TRUE)

	stop_beam()
	detach_cover(T)
	T.alpha = prev_alpha
	unset_click_ability(clicker, FALSE)
	hive.sync_after_event(T)
	return TRUE

/datum/action/cooldown/shadowling/recuperation/proc/start_beam(mob/living/source, mob/living/target)
	playsound(get_turf(source), sfx_begin, 55, TRUE)
	active_beam = new /obj/effect/beam(source, target)
	if(active_beam)
		active_beam.icon = 'icons/effects/beam.dmi'
		active_beam.icon_state = "purple_lightning"
		active_beam.layer = EFFECTS_LAYER
		QDEL_IN(active_beam, channel_time)

/datum/action/cooldown/shadowling/recuperation/proc/stop_beam()
	if(active_beam && !QDELETED(active_beam))
		qdel(active_beam)
	active_beam = null

/datum/action/cooldown/shadowling/recuperation/proc/attach_cover(mob/living/carbon/human/T)
	if(cover)
		return
	cover = new /obj/structure/shadowling_cocoon(get_turf(T))
	T.vis_contents += cover

/datum/action/cooldown/shadowling/recuperation/proc/detach_cover(mob/living/carbon/human/T)
	if(!cover)
		return
	if(istype(T))
		T.vis_contents -= cover
	qdel(cover)
	cover = null
