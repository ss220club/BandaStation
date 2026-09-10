/datum/action/cooldown/spell/vampire_blood_swell
	name = "Blood Swell"
	desc = "You infuse your body with blood, making you highly resistant to stuns and physical damage. However, this makes you unable to fire ranged weapons while it is active."
	gain_desc = "You have gained the ability to temporarily resist large amounts of stuns and physical damage."
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
	name = "Seismic Stomp"
	desc = "You slam your foot into the ground sending a powerful shockwave through the station's hull, sending people flying away. Cannot be cast if your legs are restrained by a bola or similar."
	gain_desc = "You have gained the ability to knock people back using a powerful stomp."
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
			to_chat(user, span_warning("Your legs are restrained!"))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/vampire_stomp/cast(atom/cast_on)
	. = ..()
	var/turf/origin = get_turf(owner)
	playsound(origin, 'sound/effects/meteorimpact.ogg', 100, TRUE)
	new /obj/effect/temp_visual/stomp(origin)
	addtimer(CALLBACK(src, PROC_REF(hit_check), 1, origin, owner), 0.2 SECONDS)

/datum/action/cooldown/spell/vampire_stomp/proc/hit_check(range, turf/origin, mob/living/user, list/safe_targets = list())
	var/list/targets = view(range, origin) - view(range - 2, origin)
	for(var/turf/open/floor/flooring in targets)
		if(prob(100 - range * 20))
			flooring.ex_act(EXPLODE_LIGHT)
	for(var/mob/living/target in targets)
		if(target in safe_targets || target.throwing || !target.affects_vampire(user) || target.move_resist > MOVE_FORCE_VERY_STRONG)
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
	gain_desc = "While blood swell is active, all of your melee attacks deal increased damage."

/datum/action/cooldown/spell/vampire_overwhelming_force
	name = "Overwhelming Force"
	desc = "Toggle the strength to force open doors you bump into."
	gain_desc = "You have gained the ability to force open doors at a small blood cost."
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
		to_chat(user, span_warning("You feel MIGHTY!"))
		active = TRUE
		RegisterSignal(user, COMSIG_MOVABLE_BUMP, PROC_REF(force_open_door))
		user.status_flags &= ~CANPUSH
		user.move_resist = MOVE_FORCE_STRONG
	else
		active = FALSE
		UnregisterSignal(user, COMSIG_MOVABLE_BUMP)
		user.move_resist = MOVE_FORCE_DEFAULT
		user.status_flags |= CANPUSH

/datum/action/cooldown/spell/vampire_overwhelming_force/proc/force_open_door(datum/source, atom/bumped)
	SIGNAL_HANDLER
	if(!istype(bumped, /obj/machinery/door))
		return
	var/obj/machinery/door/door = bumped
	if(!door.density || door.operating || door.locked || door.allowed(owner))
		return
	INVOKE_ASYNC(door, TYPE_PROC_REF(/obj/machinery/door, open), BYPASS_DOOR_CHECKS)

/datum/action/cooldown/spell/vampire_blood_rush
	name = "Blood Rush"
	desc = "Infuse yourself with blood magic to boost your movement speed and break out of leg restraints."
	gain_desc = "You have gained the ability to temporarily move at high speeds."
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
			to_chat(user, span_warning("You can't use this while incapacitated!"))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/vampire_blood_rush/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/user = owner
	if(!istype(user))
		return
	to_chat(user, span_notice("You feel a rush of energy!"))
	user.apply_status_effect(/datum/status_effect/vampire_blood_rush)
	QDEL_NULL(user.legcuffed)
	user.SetKnockdown(0)
	user.set_body_position(STANDING_UP)

/datum/action/cooldown/spell/pointed/projectile/vampire_demonic_grasp
	name = "Demonic Grasp"
	desc = "Summon a hand of demonic energy, snaring and throwing its target around, based on your intent. Disarm pushes, grab pulls."
	gain_desc = "You have gained the ability to snare and disrupt people with demonic appendages."
	button_icon = 'modular_bandastation/vampire/icons/mob/actions/actions.dmi'
	button_icon_state = "demonic_grasp"
	cooldown_time = 30 SECONDS
	cast_range = 7
	projectile_type = /obj/projectile/magic/demonic_grasp

/datum/action/cooldown/spell/pointed/projectile/vampire_demonic_grasp/New(Target)
	. = ..()
	add_vampire_ability(20)

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
	name = "Charge"
	desc = "You charge at wherever you click on screen, dealing large amounts of damage, stunning targets, and destroying walls and other objects."
	gain_desc = "You can now charge at a target on screen, dealing massive damage and destroying structures."
	button_icon = 'modular_bandastation/vampire/icons/mob/actions/actions.dmi'
	button_icon_state = "vampire_charge"
	cooldown_time = 30 SECONDS
	cast_range = 7

/datum/action/cooldown/spell/pointed/vampire_charge/New(Target)
	. = ..()
	add_vampire_ability(30)

/datum/action/cooldown/spell/pointed/vampire_charge/can_cast_spell(feedback = TRUE)
	var/mob/living/user = owner
	return user?.body_position == STANDING_UP && ..()

/datum/action/cooldown/spell/pointed/vampire_charge/cast(atom/target)
	. = ..()
	var/mob/living/user = owner
	user.apply_status_effect(/datum/status_effect/vampire_charging)
	user.throw_at(target, cast_range, 1, user, FALSE, callback = CALLBACK(user, TYPE_PROC_REF(/mob/living, remove_status_effect), /datum/status_effect/vampire_charging))

#define ARENA_SIZE 3
/datum/action/cooldown/spell/pointed/vampire_arena
	name = "Desecrated Duel"
	desc = "You leap towards someone. Upon landing, you conjure an arena, and within it you will heal brute and burn damage, recover from fatigue faster, and be strengthened against lasting damages. Can be recasted to end the spell early."
	gain_desc = "You can now leap to a target and trap them in a conjured arena."
	button_icon = 'modular_bandastation/vampire/icons/mob/actions/actions.dmi'
	button_icon_state = "duel"
	cooldown_time = 30 SECONDS
	cast_range = 7
	var/timer
	var/list/all_temp_walls = list()

/datum/action/cooldown/spell/pointed/vampire_arena/New(Target)
	. = ..()
	add_vampire_ability(150, FALSE)

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
	GetComponent(/datum/component/vampire_ability).deduct_blood(src)
	user.forceMove(get_turf(target))
	playsound(user, 'sound/effects/meteorimpact.ogg', 100, TRUE)
	new /obj/effect/temp_visual/stomp(get_turf(user))
	user.apply_status_effect(/datum/status_effect/vampire_gladiator)
	for(var/turf/turf as anything in orange(ARENA_SIZE, get_turf(target)))
		if(get_dist(turf, get_turf(target)) == ARENA_SIZE)
			all_temp_walls += new /obj/structure/vampire_arena_wall(turf)
	timer = addtimer(CALLBACK(src, PROC_REF(dispel), user), 30 SECONDS, TIMER_STOPPABLE)
	RegisterSignal(user, COMSIG_LIVING_DEATH, PROC_REF(on_owner_death))

/datum/action/cooldown/spell/pointed/vampire_arena/proc/on_owner_death(datum/source)
	SIGNAL_HANDLER
	dispel(owner)

/datum/action/cooldown/spell/pointed/vampire_arena/proc/dispel(mob/living/user)
	if(timer)
		deltimer(timer)
		timer = null
	UnregisterSignal(user, COMSIG_LIVING_DEATH)
	for(var/obj/structure/vampire_arena_wall/wall as anything in all_temp_walls)
		qdel(wall)
	all_temp_walls.Cut()
	user.remove_status_effect(/datum/status_effect/vampire_gladiator)
	user.visible_message(span_warning("The arena begins to dissipate."))
	StartCooldown()

#undef ARENA_SIZE

/obj/structure/vampire_arena_wall
	name = "wall of coagulated blood"
	desc = "A temporary wall of congealed blood."
	density = TRUE
	anchored = TRUE
	max_integrity = 100
