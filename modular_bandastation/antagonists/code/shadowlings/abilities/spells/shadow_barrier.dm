/datum/action/cooldown/shadowling/shadow_barrier
	name = "Теневой барьер"
	desc = "Создать теневой барьер, отражающий энергетические снаряды спереди."
	button_icon_state = "shadow_barrier"
	cooldown_time = 40 SECONDS
	requires_dark_user = FALSE
	requires_dark_target = FALSE
	max_range = 0
	channel_time = 0
	min_req = 1
	max_req = 20
	required_thralls = 30
	var/barrier_duration = 5 SECONDS
	var/static/sfx_activate = 'sound/effects/magic/teleport_app.ogg'
	var/image/barrier_overlay
	var/list/allowed_projectile_typecache

/datum/action/cooldown/shadowling/shadow_barrier/Trigger(mob/clicker, trigger_flags, atom/target)
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(!istype(H) || !can_use(H))
		return FALSE
	if(channel_time > 0 && !PerformChannel(H, null))
		return FALSE
	if(!allowed_projectile_typecache)
		allowed_projectile_typecache = typecacheof(list(/obj/projectile/beam))
	if(barrier_overlay)
		H.cut_overlay(barrier_overlay)
		barrier_overlay = null
	barrier_overlay = image('modular_bandastation/antagonists/icons/shadowling/shadowling_objects.dmi', "shadow_barrier")
	barrier_overlay.layer = ABOVE_MOB_LAYER
	update_barrier_overlay(H)
	H.add_overlay(barrier_overlay)
	RegisterSignal(H, COMSIG_ATOM_BULLET_ACT, PROC_REF(on_barrier_bullet_act))
	RegisterSignal(H, COMSIG_ATOM_DIR_CHANGE, PROC_REF(update_barrier_overlay))
	playsound(H, sfx_activate, 65, TRUE)
	addtimer(CALLBACK(src, PROC_REF(end_barrier), WEAKREF(H)), barrier_duration)
	StartCooldown()
	return TRUE

/datum/action/cooldown/shadowling/shadow_barrier/proc/update_barrier_overlay(atom/source)
	SIGNAL_HANDLER

	var/mob/living/carbon/human/H = source
	if(!H || QDELETED(H) || !barrier_overlay)
		return

	barrier_overlay.dir = H.dir
	barrier_overlay.pixel_x = 0
	barrier_overlay.pixel_y = 0

	switch(H.dir)
		if(NORTH)
			barrier_overlay.pixel_y = 7
			barrier_overlay.layer = ABOVE_MOB_LAYER
		if(SOUTH)
			barrier_overlay.pixel_y = 7
		if(EAST)
			barrier_overlay.pixel_x = 7
		if(WEST)
			barrier_overlay.pixel_x = -7

/datum/action/cooldown/shadowling/shadow_barrier/proc/end_barrier(datum/weakref/owner_ref)
	var/mob/living/carbon/human/H = owner_ref?.resolve()
	if(H)
		UnregisterSignal(H, list(COMSIG_ATOM_BULLET_ACT, COMSIG_ATOM_DIR_CHANGE))
		if(barrier_overlay)
			H.cut_overlay(barrier_overlay)
	barrier_overlay = null

/datum/action/cooldown/shadowling/shadow_barrier/proc/on_barrier_bullet_act(atom/source, obj/projectile/proj, def_zone, piercing_hit = FALSE, blocked = 0)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/H = source
	if(!H || QDELETED(H) || !proj || QDELETED(proj) || !barrier_overlay)
		return
	if(!allowed_projectile_typecache[proj.type])
		return
	if(proj.dir != REVERSE_DIR(H.dir))
		return
	proj.reflect(H)

