/// Acquires only visible enemies, but keeps pursuing an already acquired enemy through cover.
/datum/targeting_strategy/basic/redspace_demon

/datum/targeting_strategy/basic/redspace_demon/can_keep_target(mob/living/living_mob, atom/target, range, datum/ai_controller/controller = null)
	var/turf/owner_turf = get_turf(living_mob)
	var/turf/target_turf = get_turf(target)
	if(isnull(owner_turf) || isnull(target_turf) || owner_turf.z != target_turf.z)
		return FALSE
	var/datum/targeting_strategy/retention_strategy = GET_TARGETING_STRATEGY(/datum/targeting_strategy/basic/redspace_demon/retained)
	return retention_strategy.is_valid_target(living_mob, target, range, controller)

/datum/targeting_strategy/basic/redspace_demon/retained
	ignore_sight = TRUE

/// Returns TRUE when a player-controlled human is alive and can be attacked.
/proc/redspace_devourer_can_target(atom/target)
	if(!ishuman(target))
		return FALSE
	var/mob/living/carbon/human/human_target = target
	if(QDELETED(human_target) || human_target.stat == DEAD || !human_target.mind)
		return FALSE
	return TRUE

/// Returns TRUE when a player-controlled human is incapacitated but still alive.
/proc/redspace_devourer_can_consume(atom/target)
	if(!redspace_devourer_can_target(target))
		return FALSE
	var/mob/living/carbon/human/human_target = target
	return IS_UNCONSCIOUS_OR_CRIT(human_target) || HAS_TRAIT(human_target, TRAIT_INCAPACITATED)

/// Devourers attack living humans and retain valid prey through cover.
/datum/targeting_strategy/basic/redspace_demon/devourer

/datum/targeting_strategy/basic/redspace_demon/devourer/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!. || !redspace_devourer_can_target(target))
		return FALSE
	return TRUE

/datum/targeting_strategy/basic/redspace_demon/devourer/can_keep_target(mob/living/living_mob, atom/target, range, datum/ai_controller/controller = null)
	if(!redspace_devourer_can_target(target))
		return FALSE
	return ..()

/// Mirrors attack_obstructions' object checks for movement behaviors that must wait for an obstacle attack.
/proc/redspace_demon_can_smash_object(mob/living/basic/basic_mob, obj/object)
	if(!isobj(object) || !object.density)
		return FALSE
	if(object.IsObscured())
		return FALSE
	if(basic_mob.see_invisible < object.invisibility)
		return FALSE
	var/list/whitelist = basic_mob.ai_controller.blackboard[BB_OBSTACLE_TARGETING_WHITELIST]
	if(whitelist && !is_type_in_typecache(object, whitelist))
		return FALSE
	return TRUE

/// Returns TRUE when the next tile is blocked by an object we should either attack or shoot through.
/proc/redspace_demon_has_obstruction(mob/living/basic/basic_mob, atom/target, projectile_pass_flags = NONE)
	var/turf/next_step = get_step_towards(basic_mob, target)
	if(isnull(next_step))
		return FALSE

	var/list/obstruction_turfs = list()
	var/direction_to_next_step = get_dir(basic_mob, next_step)
	if(ISDIAGONALDIR(direction_to_next_step))
		for(var/cardinal_direction in GLOB.cardinals)
			if(direction_to_next_step & cardinal_direction)
				obstruction_turfs += get_step(basic_mob, cardinal_direction)
		obstruction_turfs += next_step
	else
		obstruction_turfs += next_step

	for(var/turf/obstruction_turf as anything in obstruction_turfs)
		if(isnull(obstruction_turf) || !obstruction_turf.is_blocked_turf(exclude_mobs = TRUE, source_atom = basic_mob))
			continue
		for(var/obj/object as anything in obstruction_turf.contents)
			if(!object.density)
				continue
			if(projectile_pass_flags && (object.pass_flags_self & projectile_pass_flags))
				return TRUE
			if(redspace_demon_can_smash_object(basic_mob, object))
				return TRUE
	return FALSE

/// Waits for the obstacle attack instead of repeatedly pathing into the object being attacked.
/datum/bt_node/ai_behavior/move_to_target/redspace_demon

/datum/bt_node/ai_behavior/move_to_target/redspace_demon/setup(datum/ai_controller/controller)
	. = ..()
	if(!. || !redspace_demon_has_obstruction(controller.pawn, controller.blackboard[target_key]))
		return .
	controller.ai_movement.stop_moving_towards(controller)
	return .

/datum/bt_node/ai_behavior/move_to_target/redspace_demon/perform(seconds_per_tick, datum/ai_controller/controller)
	var/atom/target = controller.blackboard[target_key]
	if(movement_failed && !QDELETED(target) && redspace_demon_has_obstruction(controller.pawn, target))
		movement_failed = FALSE
		controller.consecutive_pathing_attempts = 0
		return AI_BEHAVIOR_INSTANT
	if(!QDELETED(target) && redspace_demon_has_obstruction(controller.pawn, target))
		controller.ai_movement.stop_moving_towards(controller)
		return AI_BEHAVIOR_INSTANT
	return ..()

/// Keeps ranged demons at a distance while visible, but closes in on a remembered target to reach cover.
/datum/bt_node/ai_behavior/maintain_distance/redspace_demon
	var/static/projectile_pass_flags = /obj/projectile/magic/lesser_fireball::pass_flags
	var/static/max_attack_range = 9

/datum/bt_node/ai_behavior/maintain_distance/redspace_demon/setup(datum/ai_controller/controller)
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	RegisterSignal(controller.pawn, COMSIG_MOB_AI_MOVEMENT_FAILED, PROC_REF(on_movement_failed))
	return TRUE

/datum/bt_node/ai_behavior/maintain_distance/redspace_demon/perform(seconds_per_tick, datum/ai_controller/controller)
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return AI_BEHAVIOR_FAILED
	if(movement_failed)
		if(redspace_demon_has_obstruction(controller.pawn, target, projectile_pass_flags))
			movement_failed = FALSE
			controller.consecutive_pathing_attempts = 0
			return AI_BEHAVIOR_INSTANT
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	var/target_visible = can_see(controller.pawn, target, 10)
	var/minimum_distance = controller.blackboard[min_dist_key] || 4
	var/maximum_distance = controller.blackboard[max_dist_key] || 6
	var/current_distance = get_dist(controller.pawn, target)
	var/obstruction_pass_flags = current_distance <= max_attack_range ? projectile_pass_flags : NONE
	if(target_visible)
		if(current_distance > maximum_distance && redspace_demon_has_obstruction(controller.pawn, target, obstruction_pass_flags))
			controller.ai_movement.stop_moving_towards(controller)
			return AI_BEHAVIOR_INSTANT
		var/desired_movement_type
		if(current_distance < minimum_distance)
			desired_movement_type = /datum/ai_movement/basic_avoidance/backstep
		else if(current_distance > maximum_distance)
			desired_movement_type = approach_movement_type || initial(controller.ai_movement)
		var/datum/ai_movement/desired_movement = SSai_movement.movement_types[desired_movement_type]
		if(controller.blackboard[BB_CURRENT_MIN_MOVE_DISTANCE] == 1 || (desired_movement && controller.ai_movement != desired_movement))
			controller.ai_movement.stop_moving_towards(controller)
		return ..()

	if(redspace_demon_has_obstruction(controller.pawn, target, obstruction_pass_flags))
		controller.ai_movement.stop_moving_towards(controller)
		return AI_BEHAVIOR_INSTANT
	if(controller.blackboard[BB_CURRENT_MIN_MOVE_DISTANCE] != 1)
		controller.ai_movement.stop_moving_towards(controller)
		controller.change_ai_movement_type(approach_movement_type || initial(controller.ai_movement))
	controller.ai_movement.start_moving_towards(controller, target, 1)
	return AI_BEHAVIOR_INSTANT

/// Failed checks are delayed as well, avoiding a hot loop while retained targets remain behind cover.
/datum/bt_node/ai_behavior/attack_obstructions/redspace_demon/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/basic/basic_mob = controller.pawn
	var/atom/target = controller.blackboard[target_key]
	var/turf/next_step = !QDELETED(target) ? get_step_towards(basic_mob, target) : null
	if(next_step?.is_blocked_turf(exclude_mobs = TRUE, source_atom = basic_mob) && ISDIAGONALDIR(get_dir(basic_mob, next_step)))
		for(var/obj/object as anything in next_step.contents)
			if(!can_smash_object(basic_mob, object))
				continue
			basic_mob.melee_attack(object)
			return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	. = ..()
	if(. & AI_BEHAVIOR_FAILED)
		. |= AI_BEHAVIOR_DELAY

/datum/bt_node/ai_behavior/attack_obstructions/redspace_demon/can_smash_object(mob/living/basic/basic_mob, obj/object)
	return redspace_demon_can_smash_object(basic_mob, object)

/datum/bt_node/ai_behavior/attack_obstructions/redspace_demon/ranged
	var/static/projectile_pass_flags = /obj/projectile/magic/lesser_fireball::pass_flags
	var/static/max_attack_range = 9

/datum/bt_node/ai_behavior/attack_obstructions/redspace_demon/ranged/can_smash_object(mob/living/basic/basic_mob, obj/object)
	var/atom/target = basic_mob.ai_controller.blackboard[BB_CURRENT_TARGET]
	if(object.pass_flags_self & projectile_pass_flags && !QDELETED(target) && get_dist(basic_mob, target) <= max_attack_range && can_see(basic_mob, target, 10))
		return FALSE
	return ..()

/datum/bt_node/ai_behavior/basic_ranged_attack/redspace_demon
	avoid_friendly_fire = TRUE
	var/static/projectile_pass_flags = /obj/projectile/magic/lesser_fireball::pass_flags

/datum/bt_node/ai_behavior/basic_ranged_attack/redspace_demon/perform(seconds_per_tick, datum/ai_controller/controller)
	. = ..()
	if(. & AI_BEHAVIOR_FAILED)
		. |= AI_BEHAVIOR_DELAY

/datum/bt_node/ai_behavior/basic_ranged_attack/redspace_demon/check_friendly_in_path(mob/living/source, atom/target, datum/targeting_strategy/targeting_strategy)
	return is_firing_path_blocked(source, source, target, targeting_strategy)

/datum/bt_node/ai_behavior/basic_ranged_attack/redspace_demon/adjust_position(mob/living/living_pawn, atom/target)
	var/turf/our_turf = get_turf(living_pawn)
	var/current_distance = get_dist(our_turf, target)
	var/minimum_distance = living_pawn.ai_controller.blackboard[BB_RANGED_SKIRMISH_MIN_DISTANCE] || 4
	var/list/clear_positions = list()
	var/list/fallback_positions = list()
	var/datum/targeting_strategy/targeting_strategy = GET_TARGETING_STRATEGY(living_pawn.ai_controller.blackboard[BB_TARGETING_STRATEGY])

	for(var/direction in GLOB.cardinals)
		var/turf/candidate = get_step(our_turf, direction)
		if(isnull(candidate) || candidate.is_blocked_turf(source_atom = living_pawn) || !candidate.can_cross_safely(living_pawn))
			continue
		var/candidate_distance = get_dist(candidate, target)
		if(candidate_distance > current_distance || candidate_distance < min(minimum_distance, current_distance))
			continue
		fallback_positions += candidate
		if(!is_firing_path_blocked(candidate, living_pawn, target, targeting_strategy))
			clear_positions += candidate

	var/list/possible_positions = length(clear_positions) ? clear_positions : fallback_positions
	while(length(possible_positions))
		var/turf/chosen_turf = get_closest_atom(/turf, possible_positions, target)
		possible_positions -= chosen_turf
		if(living_pawn.Move(chosen_turf, get_dir(our_turf, chosen_turf)))
			return

/datum/bt_node/ai_behavior/basic_ranged_attack/redspace_demon/proc/is_firing_path_blocked(atom/trajectory_start, mob/living/shooter, atom/target, datum/targeting_strategy/targeting_strategy)
	var/list/turf_list = get_line(trajectory_start, target)
	var/list_length = length(turf_list) - 1
	for(var/index in 1 to list_length)
		var/turf/current_turf = turf_list[index]
		var/turf/next_turf = turf_list[index + 1]
		var/direction_to_turf = get_dir(current_turf, next_turf)
		if(!ISDIAGONALDIR(direction_to_turf))
			continue
		for(var/cardinal_direction in GLOB.cardinals)
			if(!(cardinal_direction & direction_to_turf))
				continue
			var/turf/extra_turf = get_step(current_turf, cardinal_direction)
			if(extra_turf)
				turf_list += extra_turf

	turf_list -= get_turf(trajectory_start)
	turf_list -= get_turf(target)
	for(var/turf/path_turf as anything in turf_list)
		if(path_turf.density && !(path_turf.pass_flags_self & projectile_pass_flags))
			return TRUE
		for(var/atom/movable/blocker as anything in path_turf.contents)
			if(!blocker.density || ismob(blocker))
				continue
			if(!(blocker.pass_flags_self & projectile_pass_flags))
				return TRUE
		for(var/mob/living/potential_friend in path_turf)
			if(!targeting_strategy.is_valid_target(shooter, potential_friend, get_dist(shooter, potential_friend), controller = shooter.ai_controller))
				return TRUE
	return FALSE

/// Ranged combat that attacks blocking objects and advances only while its target is out of sight.
/datum/bt_node/subtree/redspace_ranged_combat
	behavior_tree_json = "code/modules/mob/living/basic/space_fauna/demon/redspace_demon_ranged_combat.bt.json"

/datum/bt_node/subtree/redspace_melee_combat
	behavior_tree_json = "code/modules/mob/living/basic/space_fauna/demon/redspace_demon_melee_combat.bt.json"


/datum/ai_controller/basic_controller/simple/redspace_demon
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/redspace_demon,
		BB_TARGET_PRIORITY_STRATEGY = /datum/target_priority_strategy/nearest,
	)

/datum/ai_controller/basic_controller/simple/redspace_demon/melee
	behavior_tree_json = "code/modules/mob/living/basic/space_fauna/demon/redspace_demon_melee.bt.json"

/datum/ai_controller/basic_controller/simple/redspace_demon/melee/devourer
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/redspace_demon/devourer,
		BB_TARGET_PRIORITY_STRATEGY = /datum/target_priority_strategy/nearest,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
	)

/datum/ai_controller/basic_controller/simple/redspace_demon/ranged
	behavior_tree_json = "code/modules/mob/living/basic/space_fauna/demon/redspace_demon_ranged.bt.json"

/// A direct fireball projectile used by the ranged demon. It has no explosion.
/obj/projectile/magic/lesser_fireball
	name = "bolt of fireball"
	icon_state = "fireball"
	damage = 20
	damage_type = BURN
	/// Chance to ignite a living target on hit.
	var/ignite_chance = 30
	/// Fire stacks applied when the ignition roll succeeds.
	var/fire_stacks = 2

/obj/projectile/magic/lesser_fireball/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(!isliving(target) || !prob(ignite_chance))
		return
	var/mob/living/living_target = target
	living_target.adjust_fire_stacks(fire_stacks)
	living_target.ignite_mob()

/// A short-range ground slam used by larger redspace demons.
/datum/action/cooldown/mob_cooldown/ground_slam/redspace
	name = "Удар по земле"
	desc = "Ударяет по земле, нанося урон и сбивая с ног ближайших врагов."
	cooldown_time = 12 SECONDS
	range = 2
	delay = 0
	var/damage = 20
	var/knockdown_duration = 2 SECONDS

/datum/action/cooldown/mob_cooldown/ground_slam/redspace/do_slam(atom/target)
	redspace_ground_slam(owner, range, damage, knockdown_duration)

/proc/redspace_ground_slam(mob/living/owner, range, damage, knockdown_duration)
	var/turf/origin = get_turf(owner)
	if(!origin)
		return
	playsound(origin, 'sound/effects/bamf.ogg', 100, TRUE, 3)
	owner.visible_message(span_danger("[owner] ударяет по земле!"))
	owner.do_attack_animation(owner, ATTACK_EFFECT_SMASH)

	for(var/turf/stomp_turf as anything in RANGE_TURFS(range, origin))
		new /obj/effect/temp_visual/small_smoke/halfsecond(stomp_turf)
		for(var/mob/living/hit_mob in stomp_turf)
			if(hit_mob == owner || hit_mob.stat == DEAD || owner.faction_check_atom(hit_mob))
				continue
			hit_mob.apply_damage(damage, BRUTE, wound_bonus = CANT_WOUND)
			hit_mob.Knockdown(knockdown_duration)
			shake_camera(hit_mob, 2, 1)

#define REDSPACE_RAVAGER_BEACON_STRENGTH 7
/// Redspace source radii are measured in tiles; this is one complete redspace hex.
#define REDSPACE_RAVAGER_BEACON_RADIUS REDSPACE_HEX_RADIUS
#define REDSPACE_RAVAGER_BEACON_COOLDOWN (60 SECONDS)
#define REDSPACE_RAVAGER_TRANSFORMATION_RETRY_DELAY (60 SECONDS)
#define REDSPACE_RAVAGER_POLL_TIME (20 SECONDS)
#define REDSPACE_RAVAGER_MOVEMENT_CHECK_DELAY (1 SECONDS)

/// A destructible hotspot created by a Ravager.
/obj/structure/redspace/demonic_beacon
	name = "demonic beacon"
	desc = "A crimson beacon that distorts the redspace around it."
	icon = 'modular_bandastation/redspace/icons/obj/demon_objs.dmi'
	icon_state = "demonic_crystal"
	anchored = TRUE
	density = FALSE
	max_integrity = 100
	uses_integrity = TRUE
	var/datum/redspace_field_source/hotspot/field_source

/obj/structure/redspace/demonic_beacon/Initialize(mapload)
	. = ..()
	var/turf/origin = get_turf(src)
	if(!origin || !SSredspace || !SSredspace.is_supported_z(origin.z))
		return INITIALIZE_HINT_QDEL
	field_source = SSredspace.register_hotspot(
		origin,
		REDSPACE_RAVAGER_BEACON_STRENGTH,
		REDSPACE_RAVAGER_BEACON_RADIUS,
		REDSPACE_PROFILE_DEMONIC,
		"установлен демонический маяк",
		"маяк опустошителя",
	)
	if(!field_source)
		return INITIALIZE_HINT_QDEL
	set_light(3, 1, "#ff5500")
	return .

/obj/structure/redspace/demonic_beacon/Destroy()
	var/datum/redspace_field_source/hotspot/source = field_source
	field_source = null
	if(source)
		if(SSredspace && SSredspace.field_sources["[source.source_id]"] == source)
			SSredspace.remove_source(source.source_id, "демонический маяк разрушен")
		else
			qdel(source)
	return ..()

/// Places one persistent redspace hotspot at the Ravager's feet.
/datum/action/cooldown/mob_cooldown/redspace_beacon
	name = "Demonic Beacon"
	desc = "Place a beacon that creates a one-hex redspace disturbance."
	button_icon = 'modular_bandastation/redspace/icons/obj/demon_objs.dmi'
	button_icon_state = "demonic_crystal"
	click_to_activate = FALSE
	cooldown_time = REDSPACE_RAVAGER_BEACON_COOLDOWN
	melee_cooldown_time = 0
	cooldown_rounding = 1
	var/obj/structure/redspace/demonic_beacon/beacon

/datum/action/cooldown/mob_cooldown/redspace_beacon/Activate(atom/target)
	var/turf/beacon_turf = get_turf(owner)
	if(!beacon_turf || beacon_turf.density || !SSredspace?.is_supported_z(beacon_turf.z))
		owner.balloon_alert(owner, "здесь нельзя установить маяк")
		return FALSE
	if(beacon && !QDELETED(beacon))
		owner.balloon_alert(owner, "маяк уже установлен")
		return FALSE

	var/obj/structure/redspace/demonic_beacon/new_beacon = new(beacon_turf)
	if(!new_beacon || QDELETED(new_beacon) || !new_beacon.field_source)
		if(new_beacon && !QDELETED(new_beacon))
			qdel(new_beacon)
		owner.balloon_alert(owner, "не удалось установить маяк")
		return FALSE

	beacon = new_beacon
	RegisterSignal(beacon, COMSIG_QDELETING, PROC_REF(on_beacon_deleted))
	owner.visible_message(span_warning("[capitalize(owner.declent_ru(NOMINATIVE))] устанавливает демонический маяк."))
	to_chat(owner, span_notice("Демонический маяк создаёт возмущение редспейса вокруг себя."))
	StartCooldown()
	return TRUE

/datum/action/cooldown/mob_cooldown/redspace_beacon/proc/on_beacon_deleted(obj/structure/redspace/demonic_beacon/deleted_beacon)
	SIGNAL_HANDLER
	if(deleted_beacon == beacon)
		beacon = null

/datum/action/cooldown/mob_cooldown/redspace_beacon/Remove(mob/removed_from)
	if(beacon)
		UnregisterSignal(beacon, COMSIG_QDELETING)
	return ..()

/// A lesser demon that can survive only while its redspace energy is supplied.
/mob/living/basic/demon/redspace
	icon = 'modular_bandastation/redspace/icons/mob/demonic/lesser_demons.dmi'
	icon_state = "demon_melee"
	icon_living = "demon_melee"
	speed = 0.5
	maxHealth = 150
	health = 150
	melee_damage_lower = 12
	melee_damage_upper = 18
	ai_controller = /datum/ai_controller/basic_controller/simple/redspace_demon/melee
	var/redspace_max_energy = 100
	var/redspace_drain_percent = 10
	var/redspace_zero_energy_damage_percent = 5

/mob/living/basic/demon/redspace/Initialize(mapload)
	. = ..()
	AddComponent(\
		/datum/component/redspace_energy,\
		max_energy = redspace_max_energy,\
		drain_percent = redspace_drain_percent,\
		zero_energy_damage_percent = redspace_zero_energy_damage_percent,\
	)

/mob/living/basic/demon/redspace/ranged
	name = "ranged demon"
	real_name = "ranged demon"
	unique_name = FALSE
	desc = "A lesser redspace demon that hurls weakened fireballs from a distance."
	icon_state = "demon_ranged"
	icon_living = "demon_ranged"
	maxHealth = 100
	health = 100
	melee_damage_lower = 6
	melee_damage_upper = 10
	ai_controller = /datum/ai_controller/basic_controller/simple/redspace_demon/ranged

/mob/living/basic/demon/redspace/ranged/Initialize(mapload)
	. = ..()
	AddComponent(\
		/datum/component/ranged_attacks,\
		projectile_type = /obj/projectile/magic/lesser_fireball,\
		projectile_sound = 'sound/effects/magic/fireball.ogg',\
		cooldown_time = 3 SECONDS,\
	)

/mob/living/basic/demon/redspace/soldier
	name = "demon soldier"
	real_name = "demon soldier"
	unique_name = FALSE
	desc = "A heavily built redspace demon bred for close combat."
	icon_state = "demon_soldier"
	icon_living = "demon_soldier"
	maxHealth = 240
	health = 240
	melee_damage_lower = 20
	melee_damage_upper = 28

/mob/living/basic/demon/redspace/moderate
	redspace_max_energy = 200
	redspace_drain_percent = 5
	redspace_zero_energy_damage_percent = 0.5

/mob/living/basic/demon/redspace/moderate/minotaur
	name = "minotaur"
	real_name = "minotaur"
	unique_name = FALSE
	desc = "A massive redspace demon that shakes the ground with every blow."
	icon = 'modular_bandastation/redspace/icons/mob/demonic/moderate_demons/32x48.dmi'
	icon_state = "minotaur"
	icon_living = "minotaur"
	maxHealth = 300
	health = 300
	melee_damage_lower = 25
	melee_damage_upper = 35

/mob/living/basic/demon/redspace/moderate/minotaur/Initialize(mapload)
	. = ..()
	var/datum/action/cooldown/mob_cooldown/ground_slam/redspace/ground_slam = new(src)
	ground_slam.Grant(src)
	ai_controller.set_blackboard_key(BB_TARGETED_ACTION, ground_slam)

/mob/living/basic/demon/redspace/moderate/ravager
	name = "ravager"
	real_name = "ravager"
	unique_name = FALSE
	desc = "A hulking redspace demon that crawls out of a consumed victim and tears through its surroundings."
	icon = 'modular_bandastation/redspace/icons/mob/demonic/moderate_demons/32x64.dmi'
	icon_state = "ravager"
	icon_living = "ravager"
	icon_dead = "ravager"
	maxHealth = 300
	health = 300
	melee_damage_lower = 25
	melee_damage_upper = 35

/mob/living/basic/demon/redspace/moderate/ravager/Initialize(mapload)
	. = ..()
	var/datum/action/cooldown/mob_cooldown/ground_slam/redspace/ground_slam = new(src)
	ground_slam.Grant(src)
	ai_controller.set_blackboard_key(BB_TARGETED_ACTION, ground_slam)
	var/datum/action/cooldown/mob_cooldown/redspace_beacon/beacon_action = new(src)
	beacon_action.Grant(src)

#define REDSPACE_DEVOURER_STASIS "redspace_devourer_stasis"

/// A slow demon that hides an incapacitated player before a Ravager crawls out.
/mob/living/basic/demon/redspace/devourer
	name = "demonic devourer"
	real_name = "demonic devourer"
	unique_name = FALSE
	desc = "A hulking redspace demon that consumes helpless people and grows into something worse."
	icon = 'modular_bandastation/redspace/icons/mob/demonic/moderate_demons/64x64.dmi'
	icon_state = "Devourer"
	icon_living = "Devourer"
	icon_dead = "Devourer-closed"
	speed = 2
	maxHealth = 250
	health = 250
	melee_damage_lower = 20
	melee_damage_upper = 28
	base_pixel_x = -16
	base_pixel_y = -16
	attack_vis_effect = ATTACK_EFFECT_BITE
	status_flags = NONE
	move_force = MOVE_FORCE_OVERPOWERING
	move_resist = INFINITY
	pull_force = MOVE_FORCE_OVERPOWERING
	mob_size = MOB_SIZE_LARGE
	layer = LARGE_MOB_LAYER
	ai_controller = /datum/ai_controller/basic_controller/simple/redspace_demon/melee/devourer

	/// The victim currently held inside this demon.
	var/mob/living/carbon/human/stored_victim
	/// Prevents duplicate asynchronous devour actions.
	var/devour_in_progress = FALSE
	/// Time spent holding a target adjacent before consuming them.
	var/devour_delay = 5 SECONDS
	/// Time spent in the hot zone before transforming.
	var/transformation_delay = 2 MINUTES
	var/transformation_timer_id
	/// Prevents overlapping ghost polls while a captured victim is waiting to transform.
	var/transformation_in_progress = FALSE
	/// Destination the Devourer is walking toward before transformation.
	var/turf/transformation_target
	/// Temporary pathfinding movement used while carrying the victim.
	var/datum/ai_movement/jps/transformation_movement

/mob/living/basic/demon/redspace/devourer/early_melee_attack(atom/target, list/modifiers, ignore_cooldown)
	. = ..()
	if(.)
		return
	if(stored_victim || devour_in_progress)
		return BASIC_MOB_END_ATTACK_CHAIN_COOLDOWN
	if(!Adjacent(target) || !redspace_devourer_can_consume(target))
		return BASIC_MOB_CONTINUE_ATTACK_CHAIN

	devour_in_progress = TRUE
	INVOKE_ASYNC(src, PROC_REF(devour), target)
	return BASIC_MOB_END_ATTACK_CHAIN_COOLDOWN

/mob/living/basic/demon/redspace/devourer/proc/can_finish_devour(mob/living/carbon/human/victim)
	return !QDELETED(src) && stat != DEAD && !stored_victim && Adjacent(victim) && redspace_devourer_can_consume(victim)

/mob/living/basic/demon/redspace/devourer/proc/devour(mob/living/carbon/human/victim)
	if(!can_finish_devour(victim))
		devour_in_progress = FALSE
		return

	visible_message(span_warning("[capitalize(declent_ru(NOMINATIVE))] начинает поглощать [victim.declent_ru(ACCUSATIVE)]."))
	playsound(src, 'sound/effects/magic/demon_consume.ogg', 75, TRUE)
	do_attack_animation(victim, ATTACK_EFFECT_BITE)

	if(!do_after(src, devour_delay, target = victim, extra_checks = CALLBACK(src, PROC_REF(can_finish_devour), victim)))
		devour_in_progress = FALSE
		return

	if(!capture_victim(victim))
		devour_in_progress = FALSE
		return

	ai_controller?.clear_blackboard_key(BB_CURRENT_TARGET)
	ai_controller?.clear_blackboard_key(BB_CURRENT_TARGET_HIDING_LOCATION)
	ai_controller?.force_ai_off()

	var/turf/hottest_turf = redspace_devourer_get_hottest_turf(get_turf(src))
	icon_state = "Devourer-closed"
	if(hottest_turf && hottest_turf != get_turf(src))
		visible_message(span_warning("[capitalize(declent_ru(NOMINATIVE))] направляется к эпицентру редспейса."))
		INVOKE_ASYNC(src, PROC_REF(move_to_transformation_site), hottest_turf)
	else
		visible_message(span_warning("[capitalize(declent_ru(NOMINATIVE))] скрывается в горячей зоне редспейса."))
		start_transformation_countdown()
	devour_in_progress = FALSE

/mob/living/basic/demon/redspace/devourer/proc/capture_victim(mob/living/carbon/human/victim)
	if(stored_victim || !redspace_devourer_can_consume(victim))
		return FALSE

	victim.apply_status_effect(/datum/status_effect/grouped/stasis, REDSPACE_DEVOURER_STASIS)
	RegisterSignal(victim, COMSIG_QDELETING, PROC_REF(on_stored_victim_deleted))
	if(!victim.forceMove(src))
		UnregisterSignal(victim, COMSIG_QDELETING, PROC_REF(on_stored_victim_deleted))
		victim.remove_status_effect(/datum/status_effect/grouped/stasis, REDSPACE_DEVOURER_STASIS)
		return FALSE

	stored_victim = victim
	ADD_TRAIT(src, TRAIT_IMMOBILIZED, REDSPACE_DEVOURER_STASIS)
	return TRUE

/mob/living/basic/demon/redspace/devourer/proc/on_stored_victim_deleted(mob/living/carbon/human/victim)
	SIGNAL_HANDLER
	if(victim != stored_victim)
		return
	release_victim()

/mob/living/basic/demon/redspace/devourer/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == stored_victim)
		release_victim()

/mob/living/basic/demon/redspace/devourer/proc/release_victim()
	var/mob/living/carbon/human/victim = stored_victim
	stored_victim = null
	if(victim)
		UnregisterSignal(victim, COMSIG_QDELETING, PROC_REF(on_stored_victim_deleted))
		if(!QDELETED(victim))
			victim.remove_status_effect(/datum/status_effect/grouped/stasis, REDSPACE_DEVOURER_STASIS)
			if(victim.loc == src)
				victim.forceMove(get_turf(src))
	REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, REDSPACE_DEVOURER_STASIS)
	if(transformation_timer_id)
		deltimer(transformation_timer_id)
	transformation_timer_id = null
	stop_transformation_movement()
	transformation_in_progress = FALSE
	devour_in_progress = FALSE
	ai_controller?.clear_forced_off()

/mob/living/basic/demon/redspace/devourer/proc/can_transform_with_victim()
	var/mob/living/carbon/human/victim = stored_victim
	return !QDELETED(src) && stat != DEAD && victim && !QDELETED(victim) && victim.loc == src && victim.stat != DEAD && victim.mind

/mob/living/basic/demon/redspace/devourer/proc/begin_transformation()
	if(QDELETED(src) || transformation_in_progress || !stored_victim)
		return
	transformation_timer_id = null
	transformation_in_progress = TRUE
	visible_message(span_warning("[capitalize(declent_ru(NOMINATIVE))] начинает раскрываться изнутри."))
	INVOKE_ASYNC(src, PROC_REF(poll_for_ravager))

/mob/living/basic/demon/redspace/devourer/proc/start_transformation_countdown()
	if(!can_transform_with_victim())
		release_victim()
		return
	transformation_in_progress = FALSE
	transformation_timer_id = addtimer(CALLBACK(src, PROC_REF(begin_transformation)), transformation_delay, TIMER_STOPPABLE | TIMER_DELETE_ME)

/mob/living/basic/demon/redspace/devourer/proc/stop_transformation_movement()
	var/datum/ai_movement/jps/movement = transformation_movement
	transformation_movement = null
	transformation_target = null
	if(!movement)
		return
	if(ai_controller && !QDELETED(ai_controller))
		movement.stop_moving_towards(ai_controller)
	if(!QDELETED(movement))
		qdel(movement)

/mob/living/basic/demon/redspace/devourer/proc/move_to_transformation_site(turf/destination)
	if(QDELETED(src) || !destination || !can_transform_with_victim())
		release_victim()
		return

	transformation_in_progress = TRUE
	transformation_target = destination
	REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, REDSPACE_DEVOURER_STASIS)

	var/datum/ai_controller/controller = ai_controller
	if(!controller || QDELETED(controller))
		stop_transformation_movement()
		start_transformation_countdown()
		return
	controller.ai_movement.stop_moving_towards(controller)
	var/datum/ai_movement/jps/movement = new
	transformation_movement = movement
	if(!movement.start_moving_towards(controller, destination, 0))
		stop_transformation_movement()
		start_transformation_countdown()
		return

	while(!QDELETED(src) && can_transform_with_victim() && get_turf(src) != destination)
		if(!transformation_movement || !transformation_movement.moving_controllers[controller])
			break
		sleep(REDSPACE_RAVAGER_MOVEMENT_CHECK_DELAY)

	if(QDELETED(src))
		return
	if(!can_transform_with_victim())
		release_victim()
		return
	var/reached_destination = get_turf(src) == destination
	stop_transformation_movement()
	if(reached_destination)
		visible_message(span_warning("[capitalize(declent_ru(NOMINATIVE))] достигает эпицентра редспейса."))
	else
		visible_message(span_warning("[capitalize(declent_ru(NOMINATIVE))] не может найти путь к эпицентру редспейса."))
	start_transformation_countdown()

/mob/living/basic/demon/redspace/devourer/proc/poll_for_ravager()
	if(!can_transform_with_victim())
		release_victim()
		return

	var/mob/dead/observer/chosen_ghost = SSpolling.poll_ghosts_for_target(
		question = "Вы хотите сыграть за [span_notice("опустошителя")], выползающего из [span_danger(declent_ru(ACCUSATIVE))]?",
		role = ROLE_SENTIENCE,
		check_jobban = ROLE_SENTIENCE,
		poll_time = REDSPACE_RAVAGER_POLL_TIME,
		checked_target = src,
		ignore_category = POLL_IGNORE_REDSPACE_RAVAGER,
		alert_pic = /mob/living/basic/demon/redspace/moderate/ravager,
		jump_target = src,
		role_name_text = "ravager",
		chat_text_border_icon = /mob/living/basic/demon/redspace/moderate/ravager,
	)

	if(QDELETED(src))
		return
	if(!chosen_ghost)
		transformation_in_progress = FALSE
		visible_message(span_warning("Возмущение стихает, и появление опустошителя откладывается."))
		transformation_timer_id = addtimer(CALLBACK(src, PROC_REF(begin_transformation)), REDSPACE_RAVAGER_TRANSFORMATION_RETRY_DELAY, TIMER_STOPPABLE | TIMER_DELETE_ME)
		return
	if(!can_transform_with_victim())
		release_victim()
		return
	transform_with_victim(chosen_ghost.key)

/mob/living/basic/demon/redspace/devourer/proc/transform_with_victim(ghost_key)
	if(!istext(ghost_key) || !can_transform_with_victim())
		transformation_in_progress = FALSE
		return

	transformation_timer_id = null
	var/mob/living/carbon/human/victim = stored_victim
	if(!can_transform_with_victim())
		release_victim()
		return

	var/turf/transform_turf = get_turf(src)
	if(!transform_turf)
		release_victim()
		return

	var/mob/living/basic/demon/redspace/moderate/ravager/transformed = new(transform_turf)
	if(!transformed || QDELETED(transformed))
		release_victim()
		return

	stored_victim = null
	UnregisterSignal(victim, COMSIG_QDELETING, PROC_REF(on_stored_victim_deleted))
	victim.remove_status_effect(/datum/status_effect/grouped/stasis, REDSPACE_DEVOURER_STASIS)
	transformation_in_progress = FALSE
	transformed.PossessByPlayer(ghost_key)
	transform_turf.visible_message(span_warning("Из [declent_ru(GENITIVE)] выползает [transformed.declent_ru(NOMINATIVE)]!"))
	new /obj/effect/temp_visual/circle_wave(transform_turf, "#ff3b20")
	playsound(transform_turf, 'sound/effects/magic/teleport_app.ogg', 75, TRUE)

	if(SSredspace)
		for(var/datum/redspace_event/spawn/event as anything in SSredspace.active_events)
			if(src in event.spawned_atoms)
				event.replace_spawned_atom(src, transformed)
				break

	qdel(victim)
	qdel(src)
	return transformed

/mob/living/basic/demon/redspace/devourer/Destroy()
	release_victim()
	return ..()

/mob/living/basic/demon/redspace/devourer/can_be_pulled(user, force)
	return FALSE

/// Returns the best valid turf in the hottest currently materialized redspace cell.
/proc/redspace_devourer_get_hottest_turf(turf/fallback) as /turf
	var/turf/fallback_turf = get_turf(fallback)
	if(!SSredspace || !length(SSredspace.field_cells))
		return fallback_turf

	var/datum/redspace_field_cell/hottest_cell
	var/hottest_value = -INFINITY
	for(var/cell_key in SSredspace.field_cells)
		var/datum/redspace_field_cell/cell = SSredspace.field_cells[cell_key]
		var/turf/sample_turf = cell?.get_sample_turf()
		if(!sample_turf || !SSredspace.is_supported_z(sample_turf.z) || !isnum(cell.value))
			continue
		if(cell.value > hottest_value)
			hottest_value = cell.value
			hottest_cell = cell

	if(!hottest_cell)
		return fallback_turf
	var/list/candidates = SSredspace.get_event_candidate_turfs(hottest_cell)
	return length(candidates) ? candidates[1] : hottest_cell.get_sample_turf() || fallback_turf

/// Keeps a replacement mob attached to a persistent spawn event during transformation.
/datum/redspace_event/spawn/proc/replace_spawned_atom(atom/old_atom, atom/new_atom)
	if(!old_atom || !new_atom || QDELETED(new_atom) || !(old_atom in spawned_atoms))
		return FALSE
	UnregisterSignal(old_atom, COMSIG_QDELETING, PROC_REF(on_spawned_atom_deleted))
	spawned_atoms -= old_atom
	return register_spawned_atom(new_atom)

/// A persistent redspace manifestation used to verify object spawn events.
/obj/structure/redspace/demonic_crystal
	name = "demonic redspace crystal"
	desc = "A crimson crystal that seems to draw its glow from the space around it."
	icon = 'modular_bandastation/redspace/icons/obj/demon_objs.dmi'
	icon_state = "demonic_crystal"
	anchored = TRUE
	density = FALSE
	var/redspace_deletion_threshold = REDSPACE_DISTURBANCE_ENTER_VALUE

/obj/structure/redspace/demonic_crystal/Initialize(mapload)
	. = ..()
	set_light(3, 1, "#ff0000")
	AddElement(/datum/element/redspace_threshold/delete_below, redspace_deletion_threshold)
	return .

/// Spawns one demonic crystal and keeps the event reserved until the crystal disappears.
/datum/redspace_event/spawn/object/demonic_crystal
	event_id = "demonic_crystal"
	profile_id = REDSPACE_PROFILE_DEMONIC
	min_value = REDSPACE_STORM_ENTER_VALUE
	max_value = REDSPACE_MAX_NORMAL_VALUE
	cooldown = 60 SECONDS
	automatic = TRUE
	weight = 1
	spawn_count = 1
	spawn_budget_cost = 1
	spawn_policy_id = "demonic_crystal"

/datum/redspace_event/spawn/object/demonic_crystal/can_start(turf/target)
	if(!..())
		return FALSE
	for(var/obj/structure/redspace/demonic_crystal/crystal in target)
		return FALSE
	return TRUE

/datum/redspace_event/spawn/object/demonic_crystal/start(client/admin, turf/target)
	if(!can_start(target))
		return FALSE

	var/obj/structure/redspace/demonic_crystal/crystal = new(target)
	if(!crystal || QDELETED(crystal))
		return FALSE
	if(!register_spawned_atom(crystal))
		qdel(crystal)
		return FALSE

	target.visible_message(span_warning("В пространстве формируется демонический кристалл."))
	return TRUE

/// Replaces one turf with a necropolis floor and restores it below the disturbance range.
/datum/redspace_event/spawn/turf/demonic_necropolis
	event_id = "demonic_necropolis"
	profile_id = REDSPACE_PROFILE_DEMONIC
	min_value = REDSPACE_STORM_ENTER_VALUE
	max_value = REDSPACE_MAX_NORMAL_VALUE
	cooldown = 20 SECONDS
	automatic = TRUE
	weight = 2
	spawn_count = 1
	spawn_budget_cost = 1
	spawn_policy_id = "demonic_necropolis"

/datum/redspace_event/spawn/turf/demonic_necropolis/can_start(turf/target)
	if(!..())
		return FALSE
	return !istype(target, /turf/open/indestructible/necropolis)

/datum/redspace_event/spawn/turf/demonic_necropolis/start(client/admin, turf/target)
	if(!can_start(target))
		return FALSE

	var/restore_turf_type = target.type
	var/list/restore_baseturfs = islist(target.baseturfs) ? target.baseturfs.Copy() : target.baseturfs ? list(target.baseturfs) : list()
	var/turf/necropolis_turf = target.ChangeTurf(/turf/open/indestructible/necropolis, null, CHANGETURF_FORCEOP)
	if(!necropolis_turf || QDELETED(necropolis_turf))
		return FALSE

	event_target = necropolis_turf
	if(!register_spawned_atom(necropolis_turf))
		necropolis_turf.ChangeTurf(restore_turf_type, restore_baseturfs.Copy(), CHANGETURF_FORCEOP)
		return FALSE
	necropolis_turf.AddElement(/datum/element/redspace_threshold/revert_turf_below, REDSPACE_DISTURBANCE_ENTER_VALUE, restore_turf_type, restore_baseturfs)
	if(QDELETED(src) || !(src in SSredspace.active_events))
		return FALSE

	necropolis_turf.visible_message(span_warning("Пол покрывается камнем демонического некрополя."))
	return TRUE

/// Spawns a lesser demon and keeps the event reserved until the demon is removed.
/datum/redspace_event/spawn/mob/demonic_lesser_demon
	event_id = "demonic_lesser_demon"
	profile_id = REDSPACE_PROFILE_DEMONIC
	min_value = REDSPACE_STORM_ENTER_VALUE
	max_value = REDSPACE_MAX_NORMAL_VALUE
	cooldown = 60 SECONDS
	automatic = TRUE
	weight = 5
	spawn_count = 1
	spawn_budget_cost = 1
	spawn_policy_id = "demonic_lesser_demon"
	spawn_type = /mob/living/basic/demon/redspace
	spawn_message = "В редспейсе материализуется малый демон."

/datum/redspace_event/spawn/mob/demonic_lesser_demon/can_start(turf/target)
	if(!..())
		return FALSE
	for(var/mob/living/basic/demon/redspace/demon in target)
		return FALSE
	return TRUE

/datum/redspace_event/spawn/mob/demonic_lesser_demon/ranged
	event_id = "demonic_ranged_demon"
	profile_id = REDSPACE_PROFILE_DEMONIC
	min_value = REDSPACE_STORM_ENTER_VALUE
	max_value = REDSPACE_MAX_NORMAL_VALUE
	cooldown = 60 SECONDS
	automatic = TRUE
	weight = 5
	spawn_count = 1
	spawn_budget_cost = 1
	spawn_policy_id = "demonic_ranged_demon"
	spawn_type = /mob/living/basic/demon/redspace/ranged
	spawn_message = "В редспейсе материализуется демон-стрелок."

/datum/redspace_event/spawn/mob/demonic_lesser_demon/soldier
	event_id = "demonic_soldier"
	profile_id = REDSPACE_PROFILE_DEMONIC
	min_value = REDSPACE_STORM_ENTER_VALUE
	max_value = REDSPACE_MAX_NORMAL_VALUE
	cooldown = 60 SECONDS
	automatic = TRUE
	weight = 2
	spawn_count = 1
	spawn_budget_cost = 1
	spawn_policy_id = "demonic_soldier"
	spawn_type = /mob/living/basic/demon/redspace/soldier
	spawn_message = "В редспейсе материализуется демонический солдат."

/datum/redspace_event/spawn/mob/demonic_lesser_demon/moderate_minotaur
	event_id = "demonic_minotaur"
	profile_id = REDSPACE_PROFILE_DEMONIC
	min_value = REDSPACE_STORM_ENTER_VALUE
	max_value = REDSPACE_MAX_NORMAL_VALUE
	cooldown = 90 SECONDS
	automatic = TRUE
	weight = 1
	spawn_count = 1
	spawn_budget_cost = 3
	spawn_policy_id = "demonic_minotaur"
	spawn_type = /mob/living/basic/demon/redspace/moderate/minotaur
	spawn_message = "В редспейсе материализуется могучий минотавр."

/datum/redspace_event/spawn/mob/demonic_lesser_demon/devourer
	event_id = "demonic_devourer"
	profile_id = REDSPACE_PROFILE_DEMONIC
	min_value = REDSPACE_STORM_ENTER_VALUE
	max_value = REDSPACE_MAX_NORMAL_VALUE
	cooldown = 120 SECONDS
	automatic = TRUE
	weight = 1
	spawn_count = 1
	spawn_budget_cost = 3
	spawn_policy_id = "demonic_devourer"
	spawn_type = /mob/living/basic/demon/redspace/devourer
	spawn_message = "В редспейсе материализуется демонический пожиратель."

/datum/redspace_event/spawn/mob/demonic_lesser_demon/devourer/can_start(turf/target)
	if(!..())
		return FALSE
	for(var/mob/living/basic/demon/redspace/demon in target)
		return FALSE
	return TRUE

#undef REDSPACE_DEVOURER_STASIS
#undef REDSPACE_RAVAGER_BEACON_STRENGTH
#undef REDSPACE_RAVAGER_BEACON_RADIUS
#undef REDSPACE_RAVAGER_BEACON_COOLDOWN
#undef REDSPACE_RAVAGER_TRANSFORMATION_RETRY_DELAY
#undef REDSPACE_RAVAGER_POLL_TIME
#undef REDSPACE_RAVAGER_MOVEMENT_CHECK_DELAY
