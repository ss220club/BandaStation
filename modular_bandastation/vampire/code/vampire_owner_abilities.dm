/datum/component/vampire_owner_abilities
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/datum/weakref/vampire_ref

/datum/component/vampire_owner_abilities/Initialize(datum/antagonist/vampire/vampire)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	vampire_ref = WEAKREF(vampire)

/datum/component/vampire_owner_abilities/RegisterWithParent()
	RegisterSignal(parent, COMSIG_VAMPIRE_OWNER_TOGGLE_BLOOD_SPILL, PROC_REF(toggle_blood_spill))
	RegisterSignal(parent, COMSIG_VAMPIRE_OWNER_TOGGLE_ETERNAL_DARKNESS, PROC_REF(toggle_eternal_darkness))
	RegisterSignal(parent, COMSIG_VAMPIRE_ABILITY_GET_REJUV_MULT, PROC_REF(provide_rejuv_mult))
	RegisterSignal(parent, COMSIG_VAMPIRE_ABILITY_TOGGLE_CLOAK, PROC_REF(toggle_cloak))
	RegisterSignal(parent, COMSIG_VAMPIRE_ABILITY_DISABLE_CLOAK, PROC_REF(disable_cloak))
	RegisterSignal(parent, COMSIG_VAMPIRE_ABILITY_UPDATE_CLOAK, PROC_REF(update_cloak))
	RegisterSignal(parent, COMSIG_VAMPIRE_NETWORK_GET_RECIPIENTS, PROC_REF(get_network_recipients))
	RegisterSignal(parent, COMSIG_VAMPIRE_ABILITY_COMPLETE_LAIR, PROC_REF(complete_lair))
	RegisterSignal(parent, COMSIG_VAMPIRE_ABILITY_CAN_ENTHRALL, PROC_REF(can_enthrall))
	RegisterSignal(parent, COMSIG_VAMPIRE_ABILITY_ENTHRALL, PROC_REF(enthrall))
	RegisterSignal(parent, COMSIG_VAMPIRE_ABILITY_GET_THRALLS_IN_RANGE, PROC_REF(get_thralls_in_range))
	RegisterSignal(parent, COMSIG_VAMPIRE_ABILITY_TOGGLE_THRALL_NET, PROC_REF(toggle_thrall_net))

/datum/component/vampire_owner_abilities/UnregisterFromParent()
	var/mob/living/user = parent
	disable_cloak(user)
	user.remove_status_effect(/datum/status_effect/vampire_blood_spill)
	user.remove_status_effect(/datum/status_effect/vampire_eternal_darkness)
	user.remove_status_effect(/datum/status_effect/vampire_thrall_net)
	UnregisterSignal(parent, list(
		COMSIG_VAMPIRE_OWNER_TOGGLE_BLOOD_SPILL,
		COMSIG_VAMPIRE_OWNER_TOGGLE_ETERNAL_DARKNESS,
		COMSIG_VAMPIRE_ABILITY_GET_REJUV_MULT,
		COMSIG_VAMPIRE_ABILITY_TOGGLE_CLOAK,
		COMSIG_VAMPIRE_ABILITY_DISABLE_CLOAK,
		COMSIG_VAMPIRE_ABILITY_UPDATE_CLOAK,
		COMSIG_VAMPIRE_NETWORK_GET_RECIPIENTS,
		COMSIG_VAMPIRE_ABILITY_COMPLETE_LAIR,
		COMSIG_VAMPIRE_ABILITY_CAN_ENTHRALL,
		COMSIG_VAMPIRE_ABILITY_ENTHRALL,
		COMSIG_VAMPIRE_ABILITY_GET_THRALLS_IN_RANGE,
		COMSIG_VAMPIRE_ABILITY_TOGGLE_THRALL_NET,
	))

/datum/component/vampire_owner_abilities/proc/toggle_blood_spill(mob/living/source)
	SIGNAL_HANDLER
	var/datum/status_effect/vampire_blood_spill/spill = source.has_status_effect(/datum/status_effect/vampire_blood_spill)
	if(spill)
		qdel(spill)
		return
	source.apply_status_effect(/datum/status_effect/vampire_blood_spill, vampire_ref)

/datum/component/vampire_owner_abilities/proc/toggle_eternal_darkness(mob/living/source)
	SIGNAL_HANDLER
	var/datum/status_effect/vampire_eternal_darkness/darkness = source.has_status_effect(/datum/status_effect/vampire_eternal_darkness)
	if(darkness)
		qdel(darkness)
		return
	source.apply_status_effect(/datum/status_effect/vampire_eternal_darkness, vampire_ref)

/datum/component/vampire_owner_abilities/proc/provide_rejuv_mult(mob/living/source, multiplier_ref)
	SIGNAL_HANDLER
	var/datum/antagonist/vampire/vampire = vampire_ref?.resolve()
	*multiplier_ref = vampire?.get_rejuv_mult()

/datum/component/vampire_owner_abilities/proc/toggle_cloak(mob/living/source)
	SIGNAL_HANDLER
	var/datum/antagonist/vampire/vampire = vampire_ref?.resolve()
	if(!vampire || !ishuman(source))
		return
	if(source.has_status_effect(/datum/status_effect/vampire_cloak))
		disable_cloak(source)
		return COMPONENT_VAMPIRE_ABILITY_CLOAK_TOGGLED
	if(source.apply_status_effect(/datum/status_effect/vampire_cloak, vampire_ref))
		return COMPONENT_VAMPIRE_ABILITY_CLOAK_TOGGLED | COMPONENT_VAMPIRE_ABILITY_CLOAK_ENABLED

/datum/component/vampire_owner_abilities/proc/disable_cloak(mob/living/source)
	SIGNAL_HANDLER
	if(source.remove_status_effect(/datum/status_effect/vampire_cloak))
		return COMPONENT_VAMPIRE_ABILITY_CLOAK_TOGGLED

/datum/component/vampire_owner_abilities/proc/update_cloak(mob/living/source)
	SIGNAL_HANDLER
	var/datum/antagonist/vampire/vampire = vampire_ref?.resolve()
	vampire?.handle_vampire_cloak(source)

/datum/component/vampire_owner_abilities/proc/get_network_recipients(mob/living/source, list/recipients)
	SIGNAL_HANDLER
	var/datum/antagonist/vampire/vampire = vampire_ref?.resolve()
	if(!vampire)
		return
	recipients |= source
	for(var/datum/antagonist/vampire_thrall/thrall in vampire.get_thralls())
		if(thrall.owner?.current)
			recipients |= thrall.owner.current

/datum/component/vampire_thrall_communication
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/datum/weakref/thrall_ref

/datum/component/vampire_thrall_communication/Initialize(datum/antagonist/vampire_thrall/thrall)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	thrall_ref = WEAKREF(thrall)

/datum/component/vampire_thrall_communication/RegisterWithParent()
	RegisterSignal(parent, COMSIG_VAMPIRE_NETWORK_GET_RECIPIENTS, PROC_REF(get_network_recipients))

/datum/component/vampire_thrall_communication/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_VAMPIRE_NETWORK_GET_RECIPIENTS)

/datum/component/vampire_thrall_communication/proc/get_network_recipients(mob/living/source, list/recipients)
	SIGNAL_HANDLER
	var/datum/antagonist/vampire_thrall/speaker_thrall = thrall_ref?.resolve()
	var/datum/antagonist/vampire/master = speaker_thrall?.get_master()
	if(!master?.owner?.current)
		return
	recipients |= master.owner.current
	for(var/datum/antagonist/vampire_thrall/thrall in master.get_thralls())
		if(thrall.owner?.current)
			recipients |= thrall.owner.current

/datum/component/vampire_owner_abilities/proc/complete_lair(mob/living/source, datum/action/cooldown/spell/spell)
	SIGNAL_HANDLER
	var/datum/antagonist/vampire/vampire = vampire_ref?.resolve()
	if(!vampire)
		return
	vampire.has_lair = TRUE
	vampire.remove_spell_ability(spell)

/datum/component/vampire_owner_abilities/proc/can_enthrall(mob/living/source)
	SIGNAL_HANDLER
	var/datum/antagonist/vampire/vampire = vampire_ref?.resolve()
	if(vampire?.subclass && vampire.subclass.thrall_cap > length(vampire.get_thralls()))
		return COMPONENT_VAMPIRE_ABILITY_CAN_ENTHRALL

/datum/component/vampire_owner_abilities/proc/enthrall(mob/living/source, mob/living/carbon/human/target)
	SIGNAL_HANDLER
	var/datum/antagonist/vampire/vampire = vampire_ref?.resolve()
	if(!vampire || !target?.mind)
		return
	var/datum/antagonist/vampire_thrall/thrall = new(vampire)
	if(!target.mind.add_antag_datum(thrall))
		qdel(thrall)
		return
	return COMPONENT_VAMPIRE_ABILITY_ENTHRALLED

/datum/component/vampire_owner_abilities/proc/get_thralls_in_range(mob/living/source, atom/center, range, list/targets)
	SIGNAL_HANDLER
	var/datum/antagonist/vampire/vampire = vampire_ref?.resolve()
	if(!vampire)
		return
	if(range == INFINITY)
		add_thralls_to_targets(vampire.get_thralls(), targets)
		return
	add_thralls_to_targets(vampire.get_thralls(), targets, center, range)

/datum/component/vampire_owner_abilities/proc/add_thralls_to_targets(list/thralls, list/targets, atom/center = null, range = INFINITY)
	var/turf/center_turf = get_turf(center)
	if(center && !center_turf)
		return
	for(var/datum/antagonist/vampire_thrall/thrall in thralls)
		var/mob/living/thrall_mob = thrall.owner?.current
		if(!thrall_mob)
			continue
		var/turf/thrall_turf = get_turf(thrall_mob)
		if(center && (!thrall_turf || thrall_turf.z != center_turf.z || get_dist(center_turf, thrall_turf) > range))
			continue
		targets += thrall_mob

/datum/component/vampire_owner_abilities/proc/toggle_thrall_net(mob/living/source)
	SIGNAL_HANDLER
	var/datum/antagonist/vampire/vampire = vampire_ref?.resolve()
	if(!vampire)
		return
	var/datum/status_effect/vampire_thrall_net/net = source.has_status_effect(/datum/status_effect/vampire_thrall_net)
	if(net)
		qdel(net)
	else
		source.apply_status_effect(/datum/status_effect/vampire_thrall_net, vampire)
