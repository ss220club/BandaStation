/datum/action/cooldown/spell/smoke/lesser/loot_goblin
	name = "Пыль в глаза"
	desc = "Выпустить облако дыма вокруг себя."
	school = SCHOOL_UNSET
	antimagic_flags = NONE

/datum/action/cooldown/spell/smoke/lesser/loot_goblin/cast(atom/cast_on)
	. = ..()
	playsound(get_turf(owner), 'modular_bandastation/loot_goblin/sound/goblin_laugh.ogg', 60, TRUE)

/datum/status_effect/loot_goblin_hearing
	id = "loot_goblin_hearing"
	status_type = STATUS_EFFECT_UNIQUE
	duration = STATUS_EFFECT_PERMANENT
	tick_interval = 0.6 SECONDS
	alert_type = null
	var/list/last_positions = list()
	var/list/active_prints = list()

/datum/status_effect/loot_goblin_hearing/on_remove()
	for(var/image/print as anything in active_prints)
		owner.client?.images -= print
	active_prints.Cut()
	last_positions.Cut()

/datum/status_effect/loot_goblin_hearing/tick(seconds_between_ticks)
	var/turf/center = get_turf(owner)
	if(!center || owner.stat == DEAD || !owner.client)
		last_positions.Cut()
		return
	var/list/visible = list()
	for(var/mob/living/seen in view(LOOT_GOBLIN_HEARING_RANGE, owner))
		visible[seen] = TRUE
	var/list/new_positions = list()
	for(var/mob/living/heard in range(LOOT_GOBLIN_HEARING_RANGE, center))
		if(heard == owner || heard.stat == DEAD || !isturf(heard.loc))
			continue
		var/heard_ref = REF(heard)
		var/turf_ref = REF(heard.loc)
		new_positions[heard_ref] = turf_ref
		var/old_turf_ref = last_positions[heard_ref]
		if(!old_turf_ref || old_turf_ref == turf_ref || visible[heard])
			continue
		if(HAS_TRAIT(heard, TRAIT_SILENT_FOOTSTEPS) || (heard.movement_type & (FLYING|FLOATING)) || heard.body_position == LYING_DOWN)
			continue
		show_footprint(center, heard.loc, heard.dir)
	last_positions = new_positions

/datum/status_effect/loot_goblin_hearing/proc/show_footprint(turf/anchor, turf/print_turf, print_dir)
	var/image/print = image('icons/effects/footprints.dmi', anchor, "footprint1", dir = print_dir)
	SET_PLANE(print, ABOVE_LIGHTING_PLANE, anchor)
	print.pixel_w = (print_turf.x - anchor.x) * ICON_SIZE_X
	print.pixel_z = (print_turf.y - anchor.y) * ICON_SIZE_Y
	print.color = LOOT_GOBLIN_FOOTPRINT_COLOR
	print.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	active_prints += print
	owner.client.images += print
	animate(print, alpha = 0, time = LOOT_GOBLIN_FOOTPRINT_TIME)
	addtimer(CALLBACK(src, PROC_REF(remove_footprint), print), LOOT_GOBLIN_FOOTPRINT_TIME)

/datum/status_effect/loot_goblin_hearing/proc/remove_footprint(image/print)
	active_prints -= print
	owner?.client?.images -= print

/datum/action/cooldown/loot_goblin_recall
	name = "Возврат в логово"
	desc = "Через 5 секунд перенестись в логово вместе с вещами. Нельзя в наручниках, пристёгнутым или в вентиляции."
	button_icon = 'modular_bandastation/loot_goblin/icons/lair.dmi'
	button_icon_state = "lair"
	check_flags = AB_CHECK_CONSCIOUS
	cooldown_time = LOOT_GOBLIN_RECALL_COOLDOWN
	var/channeling = FALSE

/datum/action/cooldown/loot_goblin_recall/Activate(atom/cast_on)
	var/mob/living/user = owner
	if(channeling || !can_recall(user))
		return FALSE
	channeling = TRUE
	user.visible_message(
		span_warning("[capitalize(user.declent_ru(NOMINATIVE))] окутывается зловещей аурой!"),
		span_notice("Вы сосредотачиваетесь на своём логове..."),
	)
	var/mutable_appearance/aura = mutable_appearance('icons/mob/effects/heretic_aura.dmi', "heretic_aura")
	user.add_overlay(aura)
	addtimer(CALLBACK(user, TYPE_PROC_REF(/atom, cut_overlay), aura), LOOT_GOBLIN_RECALL_DELAY)
	addtimer(CALLBACK(src, PROC_REF(finish_recall), user), LOOT_GOBLIN_RECALL_DELAY)
	return TRUE

/datum/action/cooldown/loot_goblin_recall/proc/finish_recall(mob/living/user)
	channeling = FALSE
	if(QDELETED(user) || QDELETED(src) || owner != user || IS_UNCONSCIOUS_OR_CRIT(user) || !can_recall(user))
		return
	var/datum/antagonist/loot_goblin/goblin = target
	var/turf/start_turf = get_turf(user)
	var/turf/lair_turf = get_turf(goblin.lair)
	if(!do_teleport(user, lair_turf, channel = TELEPORT_CHANNEL_FREE, forced = TRUE))
		to_chat(user, span_warning("Не удалось вернуться в логово."))
		return
	new /obj/effect/temp_visual/loot_goblin_aura(start_turf)
	new /obj/effect/temp_visual/loot_goblin_aura(lair_turf)
	StartCooldown()

/obj/effect/temp_visual/loot_goblin_aura
	icon = 'icons/mob/effects/heretic_aura.dmi'
	icon_state = "heretic_aura"
	duration = 1 SECONDS

/datum/action/cooldown/loot_goblin_recall/proc/can_recall(mob/living/user)
	var/datum/antagonist/loot_goblin/goblin = target
	if(QDELETED(goblin) || goblin.owner != user.mind)
		return FALSE
	if(!goblin.lair)
		to_chat(user, span_warning("У вас нет логова!"))
		return FALSE
	if(!isturf(user.loc))
		to_chat(user, span_warning("Отсюда не вернуться в логово!"))
		return FALSE
	if(HAS_TRAIT(user, TRAIT_RESTRAINED) || user.buckled)
		to_chat(user, span_warning("Вы скованы и не можете вернуться в логово!"))
		return FALSE
	return TRUE
