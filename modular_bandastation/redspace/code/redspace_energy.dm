/// Per-mob redspace energy component. The component itself is a field listener so every host has isolated state.
/datum/movespeed_modifier/redspace_energy
	variable = TRUE

/datum/component/redspace_energy
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

	var/max_energy = 100
	var/current_energy = 100
	/// Percentage of maximum energy recovered per second in a recharge zone.
	var/recovery_percent = 10
	/// Percentage of maximum energy lost per second in a drain zone.
	var/drain_percent = 10
	/// Percentage of maximum health dealt per second while energy is empty.
	var/zero_energy_damage_percent = 5
	/// Percentage of maximum energy consumed by each granted action.
	var/action_cost_percent = 5
	/// Percentage of maximum health healed per second in a recharge zone.
	var/healing_percent = 3
	/// Negative values speed the mob up; positive values slow it down.
	var/recharge_speed_modifier = -0.2
	var/drain_speed_modifier = 0.5
	/// Field value at which the mob starts recharging and receives its speed bonus.
	var/recharge_threshold = REDSPACE_DISTURBANCE_ENTER_VALUE

	var/environment_state = REDSPACE_ENERGY_ENVIRONMENT_NONE
	var/current_redspace_value
	var/turf/listener_turf
	var/waiting_for_redspace = FALSE
	var/list/tracked_actions = list()

/datum/component/redspace_energy/Initialize(
	max_energy = 100,
	initial_energy_percent = 100,
	recovery_percent = 10,
	drain_percent = 10,
	zero_energy_damage_percent = 5,
	action_cost_percent = 5,
	healing_percent = 3,
	recharge_speed_modifier = -0.2,
	drain_speed_modifier = 0.5,
	recharge_threshold = REDSPACE_DISTURBANCE_ENTER_VALUE,
)
	. = ..()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	if(!isnum(max_energy) || max_energy <= 0)
		return COMPONENT_INCOMPATIBLE

	src.max_energy = max_energy
	src.current_energy = max_energy * clamp(initial_energy_percent, 0, 100) / 100
	src.recovery_percent = max(recovery_percent, 0)
	src.drain_percent = max(drain_percent, 0)
	src.zero_energy_damage_percent = max(zero_energy_damage_percent, 0)
	src.action_cost_percent = clamp(action_cost_percent, 0, 100)
	src.healing_percent = max(healing_percent, 0)
	src.recharge_speed_modifier = recharge_speed_modifier
	src.drain_speed_modifier = drain_speed_modifier
	src.recharge_threshold = recharge_threshold

/datum/component/redspace_energy/RegisterWithParent()
	var/mob/living/living_parent = parent
	RegisterSignal(living_parent, COMSIG_LIVING_LIFE, PROC_REF(on_life))
	RegisterSignal(living_parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_parent_moved))
	RegisterSignal(living_parent, COMSIG_MOB_HUD_CREATED, PROC_REF(hud_created))
	RegisterSignal(living_parent, COMSIG_MOB_GRANTED_ACTION, PROC_REF(on_action_granted))
	RegisterSignal(living_parent, COMSIG_MOB_REMOVED_ACTION, PROC_REF(on_action_removed))
	RegisterSignal(living_parent, COMSIG_MOB_ABILITY_STARTED, PROC_REF(on_ability_started))
	RegisterSignal(src, COMSIG_REDSPACE_FIELD_CHANGED, PROC_REF(on_redspace_changed))

	for(var/datum/action/action as anything in living_parent.actions)
		track_action(action)
	update_field_registration(play_transition_sound = FALSE)
	if(living_parent.hud_used)
		hud_created(living_parent)

/datum/component/redspace_energy/UnregisterFromParent()
	cleanup_runtime()

/datum/component/redspace_energy/Destroy(force = FALSE)
	cleanup_runtime()
	return ..()

/datum/component/redspace_energy/proc/cleanup_runtime()
	var/mob/living/living_parent = parent
	if(SSredspace)
		SSredspace.unregister_field_listener(src)
	if(listener_turf)
		UnregisterSignal(listener_turf, COMSIG_TURF_CHANGE)
		listener_turf = null
	if(waiting_for_redspace && SSredspace)
		UnregisterSignal(SSredspace, COMSIG_SUBSYSTEM_POST_INITIALIZE)
	waiting_for_redspace = FALSE
	UnregisterSignal(src, COMSIG_REDSPACE_FIELD_CHANGED)

	for(var/datum/action/action as anything in tracked_actions.Copy())
		if(action && !QDELETED(action))
			UnregisterSignal(action, list(COMSIG_ACTION_TRIGGER, COMSIG_QDELETING))
	tracked_actions.Cut()

	if(living_parent)
		UnregisterSignal(living_parent, list(
			COMSIG_LIVING_LIFE,
			COMSIG_MOVABLE_MOVED,
			COMSIG_MOB_HUD_CREATED,
			COMSIG_MOB_GRANTED_ACTION,
			COMSIG_MOB_REMOVED_ACTION,
			COMSIG_MOB_ABILITY_STARTED,
		))
		living_parent.remove_movespeed_modifier(/datum/movespeed_modifier/redspace_energy)
		if(living_parent.hud_used && !QDELETED(living_parent.hud_used))
			living_parent.hud_used.remove_screen_object(REDSPACE_ENERGY_HUD_KEY)

/datum/component/redspace_energy/proc/on_life(mob/living/source, seconds_per_tick)
	SIGNAL_HANDLER
	if(source != parent || QDELETED(source) || source.stat == DEAD)
		return

	var/turf/current_turf = get_turf(source)
	if(current_turf != listener_turf)
		update_field_registration()

	var/delta_time = max(seconds_per_tick, 0)
	if(environment_state == REDSPACE_ENERGY_ENVIRONMENT_RECHARGE)
		adjust_energy(max_energy * recovery_percent / 100 * delta_time)
		if(healing_percent > 0 && source.maxHealth > 0)
			source.heal_ordered_damage(
				source.maxHealth * healing_percent / 100 * delta_time,
				list(BRUTE, BURN, TOX, OXY),
			)
	else if(environment_state == REDSPACE_ENERGY_ENVIRONMENT_DRAIN)
		adjust_energy(-(max_energy * drain_percent / 100 * delta_time))
		if(current_energy <= 0 && zero_energy_damage_percent > 0 && source.maxHealth > 0)
			source.adjust_brute_loss(source.maxHealth * zero_energy_damage_percent / 100 * delta_time, forced = TRUE)

/datum/component/redspace_energy/proc/on_parent_moved(atom/movable/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER
	if(source == parent)
		update_field_registration()

/datum/component/redspace_energy/proc/update_field_registration(play_transition_sound = TRUE)
	if(!parent || QDELETED(parent))
		return

	if(listener_turf)
		if(SSredspace)
			SSredspace.unregister_field_listener(src)
		UnregisterSignal(listener_turf, COMSIG_TURF_CHANGE)
		listener_turf = null

	if(!SSredspace)
		update_environment(null, play_transition_sound)
		return
	if(!SSredspace.initialized)
		if(!waiting_for_redspace)
			RegisterSignal(SSredspace, COMSIG_SUBSYSTEM_POST_INITIALIZE, PROC_REF(on_redspace_initialized))
			waiting_for_redspace = TRUE
		update_environment(null, play_transition_sound)
		return
	if(waiting_for_redspace)
		UnregisterSignal(SSredspace, COMSIG_SUBSYSTEM_POST_INITIALIZE)
		waiting_for_redspace = FALSE

	var/turf/current_turf = get_turf(parent)
	if(!current_turf || !SSredspace.is_supported_z(current_turf.z))
		update_environment(null, play_transition_sound)
		return

	listener_turf = current_turf
	RegisterSignal(listener_turf, COMSIG_TURF_CHANGE, PROC_REF(on_turf_change))
	if(!SSredspace.register_field_listener(src, listener_turf))
		UnregisterSignal(listener_turf, COMSIG_TURF_CHANGE)
		listener_turf = null
		update_environment(null, play_transition_sound)
		return

	update_environment(SSredspace.get_value(listener_turf), play_transition_sound)

/datum/component/redspace_energy/proc/on_redspace_initialized(datum/source)
	SIGNAL_HANDLER
	if(source == SSredspace)
		update_field_registration()

/datum/component/redspace_energy/proc/on_redspace_changed(
	datum/source,
	datum/redspace_field_cell/cell,
	old_value,
	new_value,
	old_state,
	new_state,
	reason,
)
	SIGNAL_HANDLER
	if(source == src)
		update_environment(new_value)

/datum/component/redspace_energy/proc/on_turf_change(turf/changed, path, list/new_baseturfs, flags, list/post_change_callbacks)
	SIGNAL_HANDLER
	if(changed != listener_turf)
		return
	post_change_callbacks += CALLBACK(src, PROC_REF(on_turf_replaced))

/datum/component/redspace_energy/proc/on_turf_replaced(turf/new_turf)
	if(QDELETED(src) || !new_turf)
		return
	update_field_registration()

/datum/component/redspace_energy/proc/update_environment(new_value, play_transition_sound = TRUE)
	var/new_environment = REDSPACE_ENERGY_ENVIRONMENT_NONE
	if(isnum(new_value))
		new_environment = new_value >= recharge_threshold ? REDSPACE_ENERGY_ENVIRONMENT_RECHARGE : REDSPACE_ENERGY_ENVIRONMENT_DRAIN

	var/old_environment = environment_state
	current_redspace_value = new_value
	if(new_environment == old_environment)
		update_environment_modifier()
		update_hud()
		return

	environment_state = new_environment
	if(play_transition_sound && new_environment == REDSPACE_ENERGY_ENVIRONMENT_DRAIN && old_environment != REDSPACE_ENERGY_ENVIRONMENT_DRAIN)
		playsound(parent, 'sound/effects/extinguish.ogg', 50, TRUE)
	update_environment_modifier()
	update_hud()

/datum/component/redspace_energy/proc/update_environment_modifier()
	var/mob/living/living_parent = parent
	if(!living_parent)
		return
	switch(environment_state)
		if(REDSPACE_ENERGY_ENVIRONMENT_RECHARGE)
			living_parent.add_or_update_variable_movespeed_modifier(
				/datum/movespeed_modifier/redspace_energy,
				multiplicative_slowdown = recharge_speed_modifier,
			)
		if(REDSPACE_ENERGY_ENVIRONMENT_DRAIN)
			living_parent.add_or_update_variable_movespeed_modifier(
				/datum/movespeed_modifier/redspace_energy,
				multiplicative_slowdown = drain_speed_modifier,
			)
		else
			living_parent.remove_movespeed_modifier(/datum/movespeed_modifier/redspace_energy)

/datum/component/redspace_energy/proc/adjust_energy(amount)
	if(!isnum(amount))
		return
	current_energy = clamp(current_energy + amount, 0, max_energy)
	update_hud()

/datum/component/redspace_energy/proc/consume_energy(cost_percent = action_cost_percent)
	if(!isnum(cost_percent) || cost_percent <= 0)
		return TRUE
	var/energy_cost = max_energy * cost_percent / 100
	if(current_energy < energy_cost)
		var/mob/living/living_parent = parent
		living_parent.balloon_alert(living_parent, "недостаточно энергии")
		return FALSE
	adjust_energy(-energy_cost)
	return TRUE

/datum/component/redspace_energy/proc/track_action(datum/action/action)
	if(!action || QDELETED(action) || action in tracked_actions)
		return
	tracked_actions += action
	RegisterSignal(action, COMSIG_ACTION_TRIGGER, PROC_REF(on_action_trigger))
	RegisterSignal(action, COMSIG_QDELETING, PROC_REF(on_action_deleted))

/datum/component/redspace_energy/proc/untrack_action(datum/action/action)
	if(!action)
		return
	tracked_actions -= action
	if(!QDELETED(action))
		UnregisterSignal(action, list(COMSIG_ACTION_TRIGGER, COMSIG_QDELETING))

/datum/component/redspace_energy/proc/on_action_granted(mob/living/source, datum/action/action)
	SIGNAL_HANDLER
	if(source == parent)
		track_action(action)

/datum/component/redspace_energy/proc/on_action_removed(mob/living/source, datum/action/action)
	SIGNAL_HANDLER
	if(source == parent)
		untrack_action(action)

/datum/component/redspace_energy/proc/on_action_trigger(datum/action/source)
	SIGNAL_HANDLER
	if(!source || source.owner != parent || istype(source, /datum/action/cooldown) || consume_energy())
		return NONE
	return COMPONENT_ACTION_BLOCK_TRIGGER

/datum/component/redspace_energy/proc/on_ability_started(mob/living/source, datum/action/cooldown/activated, atom/target)
	SIGNAL_HANDLER
	if(source != parent || !activated || consume_energy())
		return NONE
	return COMPONENT_BLOCK_ABILITY_START

/datum/component/redspace_energy/proc/on_action_deleted(datum/action/source)
	SIGNAL_HANDLER
	tracked_actions -= source

/datum/component/redspace_energy/proc/hud_created(mob/living/source)
	SIGNAL_HANDLER
	if(source != parent || !source.hud_used)
		return
	var/atom/movable/screen/redspace_energy/display = source.hud_used.screen_objects[REDSPACE_ENERGY_HUD_KEY]
	if(!display)
		display = source.hud_used.add_screen_object(
			/atom/movable/screen/redspace_energy,
			REDSPACE_ENERGY_HUD_KEY,
			HUD_GROUP_INFO,
			null,
			ui_mood,
			TRUE,
		)
	display.energy_component = src
	display.update_energy(current_energy, max_energy, environment_state)

/datum/component/redspace_energy/proc/update_hud()
	var/mob/living/living_parent = parent
	if(!living_parent?.hud_used)
		return
	var/atom/movable/screen/redspace_energy/display = living_parent.hud_used.screen_objects[REDSPACE_ENERGY_HUD_KEY]
	display?.update_energy(current_energy, max_energy, environment_state)

/atom/movable/screen/redspace_energy
	icon_state = "stamina_full"
	screen_loc = ui_mood
	var/datum/component/redspace_energy/energy_component

/atom/movable/screen/redspace_energy/Destroy()
	energy_component = null
	return ..()

/atom/movable/screen/redspace_energy/proc/update_energy(new_energy, new_max_energy, environment_state)
	if(!isnum(new_max_energy) || new_max_energy <= 0)
		return
	var/percentage = clamp(new_energy / new_max_energy * 100, 0, 100)
	if(percentage >= 100)
		icon_state = "stamina_full"
	else if(percentage <= 0)
		icon_state = "stamina_crit"
	else
		icon_state = "stamina_[clamp(ceil((100 - percentage) / 20), 1, 5)]"

	var/text_color = "#ff5500"
	if(environment_state == REDSPACE_ENERGY_ENVIRONMENT_RECHARGE)
		text_color = "#33ff66"
	else if(environment_state == REDSPACE_ENERGY_ENVIRONMENT_DRAIN)
		text_color = "#ff2222"
	else if(environment_state == REDSPACE_ENERGY_ENVIRONMENT_NONE)
		text_color = "#888888"
	maptext = MAPTEXT("<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='[text_color]'>[round(percentage)]%</font></div>")
