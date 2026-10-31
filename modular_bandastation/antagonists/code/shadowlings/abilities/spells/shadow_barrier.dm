/datum/action/cooldown/shadowling/shadow_barrier
	name = "Теневой барьер"
	desc = "Создать окутывающий себя теневой барьер, отражающий энергетические снаряды спереди."
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
	var/reflect_cone = 60
	var/static/sfx_activate = 'sound/effects/magic/teleport_app.ogg'
	var/static/list/allowed_projectile_typecache = typecacheof(list(/obj/projectile/beam))
	var/datum/weakref/barrier_owner
	var/barrier_timer
	var/image/barrier_overlay

/datum/action/cooldown/shadowling/shadow_barrier/Destroy()
	end_barrier()
	return ..()

/datum/action/cooldown/shadowling/shadow_barrier/DoEffect(mob/living/carbon/human/H, atom/target)
	end_barrier()
	barrier_owner = WEAKREF(H)
	RegisterSignal(H, COMSIG_ATOM_PRE_BULLET_ACT, PROC_REF(on_barrier_pre_bullet_act))
	RegisterSignal(H, COMSIG_ATOM_DIR_CHANGE, PROC_REF(on_barrier_dir_change))
	refresh_barrier_overlay(H, H.dir)
	playsound(H, sfx_activate, 65, TRUE)
	barrier_timer = addtimer(CALLBACK(src, PROC_REF(end_barrier)), barrier_duration, TIMER_STOPPABLE)
	return TRUE

/datum/action/cooldown/shadowling/shadow_barrier/proc/refresh_barrier_overlay(mob/living/carbon/human/H, direction)
	if(barrier_overlay)
		H.cut_overlay(barrier_overlay)
	var/image/new_overlay = image('modular_bandastation/antagonists/icons/shadowling/shadowling_objects.dmi', "shadow_barrier")
	new_overlay.layer = ABOVE_MOB_LAYER
	new_overlay.appearance_flags |= KEEP_APART
	new_overlay.dir = direction
	switch(direction)
		if(NORTH, SOUTH)
			new_overlay.pixel_y = 7
		if(EAST)
			new_overlay.pixel_x = 7
		if(WEST)
			new_overlay.pixel_x = -7
	barrier_overlay = new_overlay
	H.add_overlay(barrier_overlay)

/datum/action/cooldown/shadowling/shadow_barrier/proc/on_barrier_dir_change(atom/source, old_dir, new_dir)
	SIGNAL_HANDLER
	refresh_barrier_overlay(source, new_dir)

/datum/action/cooldown/shadowling/shadow_barrier/proc/end_barrier()
	var/timer = barrier_timer
	barrier_timer = null
	if(timer)
		deltimer(timer)
	var/mob/living/carbon/human/H = barrier_owner?.resolve()
	if(H)
		UnregisterSignal(H, list(COMSIG_ATOM_PRE_BULLET_ACT, COMSIG_ATOM_DIR_CHANGE))
		if(barrier_overlay)
			H.cut_overlay(barrier_overlay)
	barrier_overlay = null
	barrier_owner = null

/datum/action/cooldown/shadowling/shadow_barrier/proc/on_barrier_pre_bullet_act(atom/source, obj/projectile/hitting_projectile, def_zone)
	SIGNAL_HANDLER
	if(!allowed_projectile_typecache[hitting_projectile.type])
		return NONE
	if(isnull(hitting_projectile.angle))
		return NONE
	var/mob/living/carbon/human/H = source
	var/incoming_angle = dir2angle(REVERSE_DIR(H.dir))
	if(abs(closer_angle_difference(hitting_projectile.angle, incoming_angle)) > reflect_cone)
		return NONE
	hitting_projectile.reflect(H)
	return COMPONENT_BULLET_PIERCED
