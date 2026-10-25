// Adapted from Paradise-SS220; see ../ATTRIBUTION.md for source revisions.
/datum/action/cooldown/spell/shadow_grapple
	parent_type = /datum/action/cooldown/spell/pointed/projectile
	name = "Shadow Grapple"
	desc = "Выстрелите теневой рукой: она притянет жертву к вам или вас к препятствию и погасит свет в радиусе двух тайлов."
	button_icon = 'modular_bandastation/shadow_demon/icons/actions.dmi'
	button_icon_state = "shadow_grapple"
	background_icon = 'modular_bandastation/shadow_demon/icons/actions.dmi'
	background_icon_state = "shadow_demon_bg"
	overlay_icon_state = null
	active_overlay_icon_state = null
	spell_requirements = NONE
	cooldown_time = 10 SECONDS
	cast_range = 7
	projectile_type = /obj/projectile/magic/shadow_hand
	active_msg = "Вы поднимаете руку, наполненную демонической энергией!"
	deactive_msg = "Вы поглощаете энергию обратно."

/datum/action/cooldown/spell/shadow_grapple/can_cast_spell(feedback = TRUE)
	if(!..())
		return FALSE
	if(!isturf(owner.loc))
		if(feedback)
			to_chat(owner, span_warning("Сначала нужно материализоваться!"))
		return FALSE
	return TRUE

/mob/living/basic/demon/shadow
	/// A grapple prevents disappearing until the projectile and the resulting throw finish.
	var/block_shadow_crawl = FALSE
	/// Monotonic generation prevents an old throw callback from releasing a later grapple.
	var/last_block_shadow_crawl = 0

/mob/living/basic/demon/shadow/proc/block_shadow_crawl()
	block_shadow_crawl = TRUE
	last_block_shadow_crawl++
	addtimer(CALLBACK(src, PROC_REF(check_block_shadow_crawl), last_block_shadow_crawl), 10 SECONDS)
	return last_block_shadow_crawl

/mob/living/basic/demon/shadow/proc/unblock_shadow_crawl(grapple_generation)
	if(!isnull(grapple_generation) && grapple_generation != last_block_shadow_crawl)
		return
	block_shadow_crawl = FALSE

/mob/living/basic/demon/shadow/proc/check_block_shadow_crawl(grapple_generation)
	if(grapple_generation != last_block_shadow_crawl || !block_shadow_crawl)
		return
	unblock_shadow_crawl(grapple_generation)
	to_chat(src, span_notice("Вы снова можете сливаться с тенями."))

/obj/projectile/magic/shadow_hand
	name = "shadow hand"
	icon = 'modular_bandastation/shadow_demon/icons/projectiles.dmi'
	icon_state = "shadow_hand"
	// Native floors use topdown layers; a normal projectile on FLOOR_PLANE is hidden beneath them.
	plane = GAME_PLANE
	hitsound = 'modular_bandastation/shadow_demon/sound/shadowattack1.ogg'
	/// on_hit can be reentered when the grapple begins throwing an atom.
	var/hit = FALSE
	/// The generation of the demon's crawl lock owned by this projectile.
	var/grapple_generation
	/// Own our beam explicitly; a missed projectile must not leave a beam behind.
	var/datum/beam/grapple_beam

/obj/projectile/magic/shadow_hand/fire(fire_angle, atom/direct_target)
	if(istype(firer, /mob/living/basic/demon/shadow))
		var/mob/living/basic/demon/shadow/demon = firer
		grapple_generation = demon.block_shadow_crawl()
	if(firer)
		grapple_beam = firer.Beam(src, icon = 'modular_bandastation/shadow_demon/icons/effects.dmi', icon_state = "grabber_beam", beam_type = /obj/effect/ebeam/shadow_grapple, emissive = FALSE, layer = BELOW_MOB_LAYER)
	return ..()

/obj/projectile/magic/shadow_hand/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(QDELETED(src) || !fired || hit)
		return
	var/obj/machinery/light/floor/floor_light = locate() in get_turf(src)
	if(floor_light)
		Bump(floor_light)

/obj/projectile/magic/shadow_hand/on_hit(atom/target, blocked = 0, pierce_hit)
	if(hit)
		return BULLET_ACT_BLOCK
	hit = TRUE
	var/turf/impact_turf = get_turf(target)
	. = ..()
	for(var/atom/extinguish_target in range(2, src))
		shadow_demon_extinguish(extinguish_target, TRUE)
	if(QDELETED(firer))
		return
	if(!isliving(target))
		var/datum/callback/finish_grapple
		if(istype(firer, /mob/living/basic/demon/shadow))
			finish_grapple = CALLBACK(firer, TYPE_PROC_REF(/mob/living/basic/demon/shadow, unblock_shadow_crawl), grapple_generation)
		if(!firer.throw_at(get_step(impact_turf, get_dir(impact_turf, firer)), 50, 10, callback = finish_grapple))
			unblock_shadowdemon_crawl()
		return
	unblock_shadowdemon_crawl()
	if(blocked >= 100 || . != BULLET_ACT_HIT)
		return
	var/mob/living/victim = target
	victim.Immobilize(2 SECONDS)
	victim.apply_damage(40, BRUTE, BODY_ZONE_CHEST)
	victim.throw_at(get_step(firer, get_dir(firer, victim)), 50, 10)

/obj/projectile/magic/shadow_hand/Destroy()
	if(!hit)
		unblock_shadowdemon_crawl()
	QDEL_NULL(grapple_beam)
	return ..()

/obj/projectile/magic/shadow_hand/proc/unblock_shadowdemon_crawl()
	if(!istype(firer, /mob/living/basic/demon/shadow))
		return
	var/mob/living/basic/demon/shadow/demon = firer
	demon.unblock_shadow_crawl(grapple_generation)

/obj/effect/ebeam/shadow_grapple
	plane = GAME_PLANE

/datum/action/cooldown/spell/jaunt/shadow_demon
	name = "Shadow Crawl"
	desc = "Мгновенно растворитесь в тени. Для возвращения понадобится две секунды и тёмный тайл рядом. Свет обжигает даже бесплотную форму."
	button_icon = 'modular_bandastation/shadow_demon/icons/actions.dmi'
	button_icon_state = "shadow_crawl"
	background_icon = 'modular_bandastation/shadow_demon/icons/actions.dmi'
	background_icon_state = "shadow_demon_bg"
	overlay_icon_state = null
	active_overlay_icon_state = null
	spell_requirements = NONE
	cooldown_time = 1 SECONDS
	jaunt_type = /obj/effect/dummy/phased_mob/shadow_demon
	/// The selected nearby dark turf, held only during a cast.
	var/turf/crawl_target
	/// Prevent parallel exit attempts during the two-second manifestation.
	var/transitioning = FALSE

/datum/action/cooldown/spell/jaunt/shadow_demon/can_cast_spell(feedback = TRUE)
	if(!..() || transitioning)
		return FALSE
	if(istype(owner, /mob/living/basic/demon/shadow))
		var/mob/living/basic/demon/shadow/demon = owner
		if(demon.block_shadow_crawl)
			if(feedback)
				to_chat(owner, span_warning("Вы слишком сосредоточены на теневой руке!"))
			return FALSE
	if(!is_jaunting(owner) && !isturf(owner.loc))
		return FALSE
	if(!find_shadow_turf())
		if(feedback)
			to_chat(owner, span_warning("Поблизости недостаточно темно!"))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/jaunt/shadow_demon/proc/find_shadow_turf()
	for(var/turf/candidate in range(1, get_turf(owner)))
		if(candidate.check_lumcount_below(0.2))
			return candidate
	return null

/datum/action/cooldown/spell/jaunt/shadow_demon/before_cast(atom/cast_on)
	. = ..() | SPELL_NO_IMMEDIATE_COOLDOWN
	if(. & SPELL_CANCEL_CAST)
		return
	if(transitioning || cast_on != owner || !can_cast_spell())
		return . | SPELL_CANCEL_CAST
	crawl_target = find_shadow_turf()
	transitioning = TRUE
	if(!is_jaunting(owner))
		return
	var/atom/old_holder = owner.loc
	if(!do_after(owner, 2 SECONDS, target = crawl_target) || QDELETED(src) || QDELETED(owner) || owner != cast_on || owner.loc != old_holder || owner.stat || !crawl_target?.check_lumcount_below(0.2) || get_dist(owner, crawl_target) > 1)
		transitioning = FALSE
		crawl_target = null
		return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/jaunt/shadow_demon/cast(mob/living/cast_on)
	. = ..()
	if(is_jaunting(cast_on))
		var/turf/destination = crawl_target
		exit_jaunt(cast_on, destination)
		new /obj/effect/temp_visual/shadow_demon_crawl(destination, cast_on.dir, "shadowwalk_appear")
		StartCooldown()
		return
	cast_on.visible_message(span_danger("[cast_on] растворяется в тенях..."))
	new /obj/effect/temp_visual/shadow_demon_crawl(get_turf(cast_on), cast_on.dir, "shadowwalk_disappear")
	cast_on.extinguish_mob()
	enter_jaunt(cast_on)

/datum/action/cooldown/spell/jaunt/shadow_demon/after_cast(atom/cast_on)
	transitioning = FALSE
	crawl_target = null
	return ..()

/datum/action/cooldown/spell/jaunt/shadow_demon/enter_jaunt(mob/living/jaunter, turf/loc_override)
	. = ..()
	RegisterSignal(., COMSIG_MOVABLE_MOVED, PROC_REF(on_holder_moved))
	if(istype(jaunter, /mob/living/basic/demon/shadow))
		var/mob/living/basic/demon/shadow/demon = jaunter
		demon.check_darkness()

/datum/action/cooldown/spell/jaunt/shadow_demon/on_jaunt_exited(obj/effect/dummy/phased_mob/jaunt, mob/living/unjaunter)
	UnregisterSignal(jaunt, COMSIG_MOVABLE_MOVED)
	return ..()

/datum/action/cooldown/spell/jaunt/shadow_demon/proc/on_holder_moved()
	SIGNAL_HANDLER
	if(istype(owner, /mob/living/basic/demon/shadow))
		var/mob/living/basic/demon/shadow/demon = owner
		demon.check_darkness()

/obj/effect/dummy/phased_mob/shadow_demon
	name = "shadows"
	phased_mob_icon_state = "purple_laser"

/obj/effect/dummy/phased_mob/shadow_demon/Destroy()
	// The parent deliberately leaves passengers to deletion; shadow crawling never consumes passengers.
	if(jaunter?.loc == src)
		jaunter.forceMove(get_turf(src))
	return ..()

/obj/effect/temp_visual/shadow_demon_crawl
	icon = 'modular_bandastation/shadow_demon/icons/shadow_demon.dmi'
	icon_state = ""
	duration = 0.6 SECONDS

/obj/effect/temp_visual/shadow_demon_crawl/Initialize(mapload, new_dir, animation_state)
	. = ..()
	setDir(new_dir)
	flick(animation_state, src)
