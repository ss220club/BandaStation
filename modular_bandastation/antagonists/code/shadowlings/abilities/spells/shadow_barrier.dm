// MARK: Shadow Barrier
/obj/effect/shadow_barrier
	name = "shadow barrier"
	desc = "A barrier of condensed shadow energy."
	icon = 'modular_bandastation/antagonists/icons/shadowling/shadowling_objects.dmi'
	icon_state = "shadow_barrier"
	density = TRUE
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	/// Shadowling who created this barrier.
	var/mob/living/owner
	/// Direction the barrier faces.
	var/barrier_dir = NORTH
	/// Projectile types that the barrier can reflect.
	var/list/allowed_projectile_typecache

/obj/effect/shadow_barrier/Initialize(mapload)
	. = ..()
	allowed_projectile_typecache = typecacheof(list(/obj/projectile/beam))

/obj/effect/shadow_barrier/bullet_act(obj/projectile/proj)
	// The barrier no longer has a valid owner.
	if(!owner || QDELETED(owner))
		return BULLET_ACT_FORCE_PIERCE
	// Only reflect beam projectiles.
	if(!allowed_projectile_typecache[proj.type])
		return BULLET_ACT_FORCE_PIERCE
	// Only reflect projectiles travelling directly into the front face.
	if(proj.dir != REVERSE_DIR(barrier_dir))
		return BULLET_ACT_FORCE_PIERCE
	// Reflect the projectile back along its incoming trajectory.
	proj.ignore_source_check = TRUE
	proj.range = proj.maximum_range
	proj.set_angle_centered(get_turf(src), SIMPLIFY_DEGREES(proj.angle + 180))
	return BULLET_ACT_FORCE_PIERCE

/obj/effect/shadow_barrier/proc/expire()
	qdel(src)

// Ability
/datum/action/cooldown/shadowling/shadow_barrier
    name = "Теневой барьер"
    desc = "Создать перед собой барьер, отражающий энергетические снаряды. Вы будете получать защиту только по направлению барьера."
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
    var/obj/effect/shadow_barrier/barrier
    var/atom/movable/barrier_visual

/datum/action/cooldown/shadowling/shadow_barrier/Trigger(mob/clicker, trigger_flags, atom/target)
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE
	if(!can_use(H))
		return FALSE
	if(channel_time > 0)
		if(!PerformChannel(H, null))
			return FALSE
	var/turf/barrier_turf = get_step(H, H.dir)
	if(!barrier_turf)
		return FALSE
	var/obj/effect/shadow_barrier/B = new(barrier_turf)
	B.owner = H
	B.barrier_dir = H.dir
	B.dir = H.dir
	playsound(H, sfx_activate, 65, TRUE)
	addtimer(CALLBACK(B, TYPE_PROC_REF(/obj/effect/shadow_barrier, expire)), barrier_duration)
	StartCooldown()
	return TRUE
