/datum/action/cooldown/spell/vampire_blood_swell
	name = "Кровавое усиление"
	desc = "Наполните тело кровью, чтобы сильно сопротивляться оглушению и физическому урону. Пока способность активна, вы не можете стрелять из дальнобойного оружия."
	button_icon = 'modular_bandastation/vampire/icons/mob/actions/actions.dmi'
	button_icon_state = "blood_swell"
	cooldown_time = 40 SECONDS

/datum/action/cooldown/spell/vampire_blood_swell/New(Target)
	. = ..()
	add_vampire_ability(30)

/datum/action/cooldown/spell/vampire_blood_swell/cast(atom/cast_on)
	. = ..()
	var/mob/living/user = owner
	if(ishuman(user))
		user.apply_status_effect(/datum/status_effect/vampire_blood_swell)

/datum/action/cooldown/spell/vampire_stomp
	name = "Сейсмический топот"
	desc = "Ударьте ногой о пол, пустив по корпусу станции мощную ударную волну, отбрасывающую людей. Нельзя использовать со связанными болой или подобным предметом ногами."
	button_icon = 'modular_bandastation/vampire/icons/mob/actions/actions.dmi'
	button_icon_state = "seismic_stomp"
	cooldown_time = 60 SECONDS
	var/max_range = 4

/datum/action/cooldown/spell/vampire_stomp/New(Target)
	. = ..()
	add_vampire_ability(30)

/datum/action/cooldown/spell/vampire_stomp/can_cast_spell(feedback = TRUE)
	if(!..())
		return FALSE
	var/mob/living/carbon/user = owner
	if(user.legcuffed)
		if(feedback)
			user.balloon_alert(user, "ноги связаны")
		return FALSE
	return TRUE

/datum/action/cooldown/spell/vampire_stomp/cast(atom/cast_on)
	. = ..()
	var/turf/origin = get_turf(owner)
	playsound(origin, 'sound/effects/meteorimpact.ogg', 100, TRUE)
	new /obj/effect/temp_visual/stomp(origin)
	addtimer(CALLBACK(src, PROC_REF(hit_check), 1, origin, owner), 0.2 SECONDS)

/datum/action/cooldown/spell/vampire_stomp/proc/hit_check(range, turf/origin, mob/living/user, list/safe_targets = list())
	if(!origin)
		return
	var/list/targets = view(range, origin) - view(range - 2, origin)
	for(var/turf/open/floor/flooring in targets)
		if(prob(100 - range * 20))
			flooring.ex_act(EXPLODE_LIGHT)
	for(var/mob/living/target in targets)
		if((target in safe_targets) || target.throwing || !target.affects_vampire(user) || target.move_resist > MOVE_FORCE_VERY_STRONG)
			continue
		var/turf/throw_target = get_edge_target_turf(target, get_dir(origin, target))
		INVOKE_ASYNC(target, TYPE_PROC_REF(/atom/movable, throw_at), throw_target, 3, 4)
		target.Knockdown(1 SECONDS)
		safe_targets += target
	if(range < max_range)
		addtimer(CALLBACK(src, PROC_REF(hit_check), range + 1, origin, user, safe_targets), 0.2 SECONDS)

/obj/effect/temp_visual/stomp
	icon = 'modular_bandastation/vampire/icons/effects/seismic_stomp_effect.dmi'
	icon_state = "stomp_effect"
	duration = 0.8 SECONDS
	pixel_y = -16
	pixel_x = -16

/obj/effect/temp_visual/stomp/Initialize(mapload)
	. = ..()
	var/matrix/transform_matrix = matrix() * 0.5
	transform = transform_matrix
	animate(src, transform = transform_matrix * 8, time = duration, alpha = 0)

/datum/vampire_passive/blood_swell_upgrade
	gain_desc = "Пока кровавое усиление активно, все ваши атаки в ближнем бою наносят больше урона."

/datum/action/cooldown/spell/vampire_overwhelming_force
	name = "Подавляющая сила"
	desc = "Включите силу, чтобы выбивать двери, в которые вы врезаетесь."
	button_icon = 'modular_bandastation/vampire/icons/mob/actions/actions.dmi'
	button_icon_state = "OH_YEAAAAH"
	cooldown_time = 2 SECONDS
	var/active

/datum/action/cooldown/spell/vampire_overwhelming_force/New(Target)
	. = ..()
	add_vampire_ability()

/datum/action/cooldown/spell/vampire_overwhelming_force/cast(atom/cast_on)
	. = ..()
	var/mob/living/user = owner
	if(!active)
		to_chat(user, span_warning("Вы чувствуете НЕВЕРОЯТНУЮ СИЛУ!"))
		active = TRUE
		RegisterSignal(user, COMSIG_MOVABLE_BUMP, PROC_REF(force_open_door))
		RegisterSignal(user, COMSIG_MOB_STATCHANGE, PROC_REF(on_stat_change))
		user.status_flags &= ~CANPUSH
		user.move_resist = MOVE_FORCE_STRONG
	else
		deactivate()

/datum/action/cooldown/spell/vampire_overwhelming_force/Remove(mob/living/removed_from)
	deactivate(removed_from)
	return ..()

/datum/action/cooldown/spell/vampire_overwhelming_force/proc/deactivate(mob/living/user = owner)
	if(!active)
		return
	active = FALSE
	if(!user)
		return
	UnregisterSignal(user, list(COMSIG_MOVABLE_BUMP, COMSIG_MOB_STATCHANGE))
	user.move_resist = MOVE_FORCE_DEFAULT
	user.status_flags |= CANPUSH

/datum/action/cooldown/spell/vampire_overwhelming_force/proc/on_stat_change(mob/living/source, new_stat, old_stat)
	SIGNAL_HANDLER
	if(new_stat == DEAD)
		deactivate(source)

/datum/action/cooldown/spell/vampire_overwhelming_force/proc/force_open_door(datum/source, atom/bumped)
	SIGNAL_HANDLER
	if(!istype(bumped, /obj/machinery/door))
		return
	var/obj/machinery/door/door = bumped
	if(!door.density || door.operating || door.locked || door.allowed(owner))
		return
	if(!(SEND_SIGNAL(src, COMSIG_VAMPIRE_ABILITY_CONSUME_BLOOD, 5) & COMPONENT_VAMPIRE_ABILITY_BLOOD_CONSUMED))
		return
	INVOKE_ASYNC(door, TYPE_PROC_REF(/obj/machinery/door, open), BYPASS_DOOR_CHECKS)

/datum/action/cooldown/spell/vampire_blood_rush
	name = "Кровавый рывок"
	desc = "Наполните себя магией крови, чтобы ускориться и освободиться от пут на ногах."
	button_icon = 'modular_bandastation/vampire/icons/mob/actions/actions.dmi'
	button_icon_state = "blood_rush"
	cooldown_time = 30 SECONDS

/datum/action/cooldown/spell/vampire_blood_rush/New(Target)
	. = ..()
	add_vampire_ability(30)

/datum/action/cooldown/spell/vampire_blood_rush/can_cast_spell(feedback = TRUE)
	if(!..())
		return FALSE
	var/mob/living/user = owner
	if(user.IsKnockdown() || user.buckled)
		if(feedback)
			to_chat(user, span_warning("Нельзя использовать это в беспомощном состоянии!"))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/vampire_blood_rush/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/user = owner
	if(!istype(user))
		return
	to_chat(user, span_notice("Вы чувствуете прилив энергии!"))
	user.apply_status_effect(/datum/status_effect/vampire_blood_rush)
	QDEL_NULL(user.legcuffed)
	user.SetKnockdown(0)
	user.set_body_position(STANDING_UP)

/datum/action/cooldown/spell/pointed/projectile/vampire_demonic_grasp
	name = "Демоническая хватка"
	desc = "Призовите руку демонической энергии, которая опутает и швырнёт цель: в боевом режиме толкнёт её, в обычном — притянет к вам."
	button_icon = 'modular_bandastation/vampire/icons/mob/actions/actions.dmi'
	button_icon_state = "demonic_grasp"
	cooldown_time = 30 SECONDS
	cast_range = 7
	projectile_type = /obj/projectile/magic/demonic_grasp

/datum/action/cooldown/spell/pointed/projectile/vampire_demonic_grasp/New(Target)
	. = ..()
	add_vampire_ability(20)

/datum/action/cooldown/spell/pointed/projectile/vampire_demonic_grasp/cast(atom/cast_on)
	. = ..()
	if(!.)
		return
	var/mob/living/user = owner
	to_chat(user, span_notice(user.combat_mode ? "Демоническая хватка оттолкнёт цель." : "Демоническая хватка притянет цель."))

/obj/projectile/magic/demonic_grasp
	name = "demonic grasp"
	reflectable = FALSE
	icon_state = null

/obj/projectile/magic/demonic_grasp/on_hit(atom/target, blocked, pierce_hit)
	. = ..()
	if(!. || !isliving(target) || !firer)
		return
	var/mob/living/victim = target
	if(!victim.affects_vampire(firer))
		return
	victim.Immobilize(1 SECONDS)
	new /obj/effect/temp_visual/demonic_grasp(loc)
	var/turf/throw_target
	var/mob/living/living_firer = firer
	throw_target = living_firer.combat_mode ? get_edge_target_turf(victim, get_dir(firer, victim)) : get_step(firer, get_dir(firer, victim))
	if(throw_target)
		victim.throw_at(throw_target, 2, 5, spin = FALSE, callback = CALLBACK(src, PROC_REF(create_snare), victim))

/obj/projectile/magic/demonic_grasp/proc/create_snare(mob/target)
	new /obj/effect/temp_visual/demonic_snare(target.loc)

/obj/effect/temp_visual/demonic_grasp
	icon = 'modular_bandastation/vampire/icons/effects/vampire_effects.dmi'
	icon_state = "demonic_grasp"
	duration = 3.5 SECONDS

/obj/effect/temp_visual/demonic_snare
	icon = 'modular_bandastation/vampire/icons/effects/vampire_effects.dmi'
	icon_state = "immobilized"

/datum/action/cooldown/spell/pointed/vampire_charge
	name = "Таран"
	desc = "Рваните к точке на экране, нанося большой урон, оглушая цели и разрушая стены и другие объекты."
	button_icon = 'modular_bandastation/vampire/icons/mob/actions/actions.dmi'
	button_icon_state = "vampire_charge"
	cooldown_time = 30 SECONDS
	cast_range = 7

/datum/action/cooldown/spell/pointed/vampire_charge/New(Target)
	. = ..()
	add_vampire_ability(30, deduct_blood_on_cast = FALSE)

/datum/action/cooldown/spell/pointed/vampire_charge/can_cast_spell(feedback = TRUE)
	var/mob/living/user = owner
	return user?.body_position == STANDING_UP && !user.throwing && !user.buckled && isturf(user.loc) && ..()

/datum/action/cooldown/spell/pointed/vampire_charge/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return
	var/mob/living/user = owner
	var/turf/destination = get_turf(cast_on)
	if(!destination || destination == user.loc || !can_cast_spell())
		return . | SPELL_CANCEL_CAST
	// No thrower means no walking momentum. Defer movement until after the cast commits.
	if(!user.throw_at(cast_on, cast_range, 1, spin = FALSE, gentle = TRUE, quickstart = FALSE, throw_type_path = /datum/thrownthing/vampire_charge))
		return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/pointed/vampire_charge/cast(atom/target)
	. = ..()
	SEND_SIGNAL(src, COMSIG_VAMPIRE_ABILITY_DEDUCT_BLOOD)

/// The charge's effects belong to this throw, never to later throws of the same mob.
/datum/thrownthing/vampire_charge
	/// Prevent an obstacle damaged before movement from being damaged again on impact.
	var/list/struck_atoms = list()
	/// Only smash obstacles during movement driven by this throw.
	var/advancing = FALSE

/datum/thrownthing/vampire_charge/New(thrownthing, target, init_dir, maxrange, speed, thrower, diagonals_first, force, gentle, callback, target_zone)
	. = ..()
	RegisterSignal(thrownthing, COMSIG_MOVABLE_ATTEMPTED_MOVE, PROC_REF(on_attempted_move))
	RegisterSignal(thrownthing, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(check_endpoint))
	RegisterSignal(thrownthing, COMSIG_MOVABLE_PRE_THROW, PROC_REF(on_rethrow))
	RegisterSignal(thrownthing, COMSIG_MOVABLE_PRE_IMPACT, PROC_REF(on_pre_impact))

/datum/thrownthing/vampire_charge/Destroy()
	if(thrownthing)
		UnregisterSignal(thrownthing, list(COMSIG_MOVABLE_ATTEMPTED_MOVE, COMSIG_MOVABLE_PRE_MOVE, COMSIG_MOVABLE_PRE_THROW, COMSIG_MOVABLE_PRE_IMPACT))
	return ..()

/// gentle suppresses carbon self-damage, but objects also need their ordinary hitby skipped.
/datum/thrownthing/vampire_charge/proc/on_pre_impact(atom/movable/source, atom/target, datum/thrownthing/throwingdatum)
	SIGNAL_HANDLER
	if(throwingdatum == src)
		return COMPONENT_MOVABLE_IMPACT_NEVERMIND

/// Finish this charge before another throw replaces its entry in SSthrowing.
/datum/thrownthing/vampire_charge/proc/on_rethrow(atom/movable/source)
	SIGNAL_HANDLER
	if(source.throwing == src)
		finalize()

/datum/thrownthing/vampire_charge/tick()
	advancing = TRUE
	. = ..()
	advancing = FALSE

/// Stop at the selected destination/range even without gravity.
/datum/thrownthing/vampire_charge/proc/check_endpoint(atom/movable/source, atom/newloc)
	SIGNAL_HANDLER
	if(advancing && source.throwing == src && (source.loc == target_turf || dist_travelled >= maxrange))
		return COMPONENT_MOVABLE_BLOCK_PRE_MOVE

/// Destroy breakable obstacles before Enter()/Bump() ends the throw.
/datum/thrownthing/vampire_charge/proc/on_attempted_move(atom/movable/source, atom/newloc)
	SIGNAL_HANDLER
	if(!advancing || source.throwing != src || !isturf(newloc) || source.loc == target_turf || dist_travelled >= maxrange)
		return
	if(iswallturf(newloc))
		hit_target(newloc)
	if(newloc.density)
		return
	for(var/obj/obstacle in newloc)
		if(!obstacle.density || obstacle.CanPass(source, get_dir(newloc, source)))
			continue
		hit_target(obstacle)
		if(!QDELETED(obstacle) && obstacle.density)
			break

/datum/thrownthing/vampire_charge/finalize(hit = FALSE, atom/target = null)
	if(hit && !QDELETED(target))
		hit_target(target)
	if(QDELETED(target))
		target = null
		hit = FALSE
	return ..()

/datum/thrownthing/vampire_charge/proc/hit_target(atom/target)
	if(QDELETED(target) || (REF(target) in struck_atoms))
		return
	// Enter() can bump the next tile before check_endpoint runs in zero gravity.
	if((thrownthing.loc == target_turf || dist_travelled >= maxrange) && get_turf(target) != thrownthing.loc)
		return
	if(!isliving(target) && !iswallturf(target) && !target.uses_integrity)
		return
	struck_atoms += REF(target)
	var/mob/living/user = thrownthing
	// Announce before damage can delete the obstacle or replace its turf.
	playsound(get_turf(user), 'sound/effects/meteorimpact.ogg', 100, TRUE)
	user.visible_message(span_danger("[capitalize(user.declent_ru(NOMINATIVE))] врезается в [target.declent_ru(ACCUSATIVE)]!"), span_userdanger("Вы врезаетесь в [target.declent_ru(ACCUSATIVE)]!"))
	log_combat(user, target, "rammed (vampire charge)")
	if(isliving(target))
		var/mob/living/victim = target
		if(victim.check_block(user, 60, "таран", LEAP_ATTACK) == SUCCESSFUL_BLOCK)
			return
		shake_camera(victim, 4, 3)
		victim.adjust_brute_loss(60)
		victim.Knockdown(12 SECONDS)
		victim.adjust_confusion(10 SECONDS)
	else if(iswallturf(target))
		var/turf/closed/wall/wall = target
		wall.dismantle_wall(devastated = TRUE)
	else
		target.take_damage(150, BRUTE, MELEE)

#define ARENA_SIZE 3
/datum/action/cooldown/spell/pointed/vampire_arena
	name = "Осквернённая дуэль"
	desc = "Прыгните к кому-то. При приземлении вы создадите арену, где будете лечить физический урон и ожоги, быстрее восстанавливаться от усталости и лучше сопротивляться длительному урону. Повторное применение завершит заклинание раньше."
	button_icon = 'modular_bandastation/vampire/icons/mob/actions/actions.dmi'
	button_icon_state = "duel"
	cooldown_time = 30 SECONDS
	cast_range = 7
	var/timer
	var/list/all_temp_walls = list()

/datum/action/cooldown/spell/pointed/vampire_arena/New(Target)
	. = ..()
	add_vampire_ability(150, FALSE)

/datum/action/cooldown/spell/pointed/vampire_arena/Remove(mob/living/removed_from)
	if(timer)
		dispel(removed_from)
	return ..()

/datum/action/cooldown/spell/pointed/vampire_arena/before_cast(atom/cast_on)
	return ..() | SPELL_NO_IMMEDIATE_COOLDOWN

/datum/action/cooldown/spell/pointed/vampire_arena/is_valid_target(atom/cast_on)
	return ..() && ishuman(cast_on)

/datum/action/cooldown/spell/pointed/vampire_arena/cast(mob/living/target)
	. = ..()
	var/mob/living/user = owner
	if(timer)
		dispel(user)
		return
	SEND_SIGNAL(src, COMSIG_VAMPIRE_ABILITY_DEDUCT_BLOOD)
	user.forceMove(get_turf(target))
	playsound(user, 'sound/effects/meteorimpact.ogg', 100, TRUE)
	new /obj/effect/temp_visual/stomp(get_turf(user))
	user.apply_status_effect(/datum/status_effect/vampire_gladiator)
	arena_trap(get_turf(target))
	timer = addtimer(CALLBACK(src, PROC_REF(dispel), user), 30 SECONDS, TIMER_STOPPABLE)
	RegisterSignal(user, COMSIG_LIVING_DEATH, PROC_REF(on_owner_death))

/datum/action/cooldown/spell/pointed/vampire_arena/proc/arena_trap(turf/target_turf)
	for(var/turf/wall_turf in border_diamond_range_turfs(target_turf, ARENA_SIZE))
		all_temp_walls += new /obj/effect/temp_visual/elite_tumor_wall/gargantua(wall_turf, src)

/datum/action/cooldown/spell/pointed/vampire_arena/proc/on_owner_death(datum/source)
	SIGNAL_HANDLER
	dispel(owner)

/datum/action/cooldown/spell/pointed/vampire_arena/proc/dispel(mob/living/user)
	if(timer)
		deltimer(timer)
		timer = null
	UnregisterSignal(user, COMSIG_LIVING_DEATH)
	for(var/obj/effect/temp_visual/elite_tumor_wall/gargantua/wall in all_temp_walls)
		qdel(wall)
	all_temp_walls.Cut()
	user.remove_status_effect(/datum/status_effect/vampire_gladiator)
	user.visible_message(span_warning("Арена начинает рассеиваться."))
	StartCooldown()

/obj/effect/temp_visual/elite_tumor_wall/gargantua
	duration = 35 SECONDS

/obj/effect/temp_visual/elite_tumor_wall/gargantua/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	return FALSE

#undef ARENA_SIZE
