/// Temporary effects used exclusively by vampire abilities.

/datum/status_effect/vampire_blood_swell
	id = "vampire_blood_swell"
	duration = 30 SECONDS
	tick_interval = STATUS_EFFECT_NO_TICK
	alert_type = /atom/movable/screen/alert/status_effect/vampire_blood_swell
	show_duration = TRUE
	var/bonus_unarmed_damage_applied = FALSE

/datum/status_effect/vampire_blood_swell/on_apply()
	var/mob/living/carbon/human/human_owner = owner
	if(!istype(human_owner))
		return FALSE
	ADD_TRAIT(human_owner, TRAIT_NOGUNS, REF(src))
	MODIFY_PHYSIOLOGY(human_owner, BRUTE, 0.4)
	MODIFY_PHYSIOLOGY(human_owner, BURN, 0.5)
	MODIFY_PHYSIOLOGY(human_owner, STAMINA, 0.5)
	MODIFY_PHYSIOLOGY(human_owner, PHYS_COEFF_STUN, 0.5)
	var/datum/antagonist/vampire/vampire = human_owner.mind?.has_antag_datum(/datum/antagonist/vampire)
	if(vampire?.get_ability(/datum/vampire_passive/blood_swell_upgrade))
		bonus_unarmed_damage_applied = TRUE
		human_owner.AddElement(/datum/element/bonus_unarmed_damage, 10)
	to_chat(human_owner, span_notice("Кровь переполняет ваше тело. Вы не можете стрелять, пока действует усиление."))
	RegisterSignal(human_owner, COMSIG_MOB_STATCHANGE, PROC_REF(on_stat_change))
	return TRUE

/datum/status_effect/vampire_blood_swell/on_remove()
	var/mob/living/carbon/human/human_owner = owner
	if(!istype(human_owner))
		return
	REMOVE_TRAIT(human_owner, TRAIT_NOGUNS, REF(src))
	MODIFY_PHYSIOLOGY(human_owner, BRUTE, 1 / 0.4)
	MODIFY_PHYSIOLOGY(human_owner, BURN, 1 / 0.5)
	MODIFY_PHYSIOLOGY(human_owner, STAMINA, 1 / 0.5)
	MODIFY_PHYSIOLOGY(human_owner, PHYS_COEFF_STUN, 1 / 0.5)
	if(bonus_unarmed_damage_applied)
		human_owner.RemoveElement(/datum/element/bonus_unarmed_damage, 10)
	UnregisterSignal(human_owner, COMSIG_MOB_STATCHANGE)
	if(human_owner.stat != DEAD)
		to_chat(human_owner, span_notice("Кровавое усиление рассеивается."))

/datum/status_effect/vampire_blood_swell/proc/on_stat_change(mob/living/source, new_stat, old_stat)
	SIGNAL_HANDLER
	if(new_stat == DEAD)
		qdel(src)

/atom/movable/screen/alert/status_effect/vampire_blood_swell
	name = "Кровавое усиление"
	desc = "Вы сильно сопротивляетесь физическому урону и оглушению, но не можете использовать огнестрельное оружие."
	icon = 'modular_bandastation/vampire/icons/mob/actions/actions.dmi'
	icon_state = "blood_swell"

/datum/status_effect/vampire_blood_rush
	id = "vampire_blood_rush"
	duration = 10 SECONDS
	tick_interval = STATUS_EFFECT_NO_TICK
	alert_type = null

/datum/status_effect/vampire_blood_rush/on_apply()
	owner.add_movespeed_modifier(/datum/movespeed_modifier/vampire_blood_rush, update = TRUE)
	return TRUE

/datum/status_effect/vampire_blood_rush/on_remove()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/vampire_blood_rush, update = TRUE)

/datum/movespeed_modifier/vampire_blood_rush
	multiplicative_slowdown = -0.5

/datum/movespeed_modifier/vampire_cloak
	multiplicative_slowdown = -0.25

/datum/status_effect/blood_tendril_slow
	id = "vampire_tendril_slow"
	duration = 6 SECONDS
	tick_interval = STATUS_EFFECT_NO_TICK
	alert_type = null

/datum/status_effect/blood_tendril_slow/on_apply()
	owner.add_movespeed_modifier(/datum/movespeed_modifier/blood_tendril_slow, update = TRUE)
	return TRUE

/datum/status_effect/blood_tendril_slow/on_remove()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/blood_tendril_slow, update = TRUE)

/datum/movespeed_modifier/blood_tendril_slow
	multiplicative_slowdown = 0.5

/datum/status_effect/vampire_gladiator
	id = "vampire_gladiator"
	duration = 30 SECONDS
	tick_interval = 2 SECONDS
	alert_type = null
	var/list/boosted_bodyparts

/datum/status_effect/vampire_gladiator/on_apply()
	var/mob/living/carbon/human/human_owner = owner
	if(!istype(human_owner))
		return FALSE
	boosted_bodyparts = list()
	for(var/obj/item/bodypart/bodypart as anything in human_owner.bodyparts)
		bodypart.wound_resistance += 100
		boosted_bodyparts += bodypart
	return TRUE

/datum/status_effect/vampire_gladiator/on_remove()
	for(var/obj/item/bodypart/bodypart as anything in boosted_bodyparts)
		if(!QDELETED(bodypart))
			bodypart.wound_resistance -= 100

/datum/status_effect/vampire_gladiator/tick(seconds_between_ticks)
	var/need_update = FALSE
	need_update += owner.adjust_stamina_loss(-20)
	need_update += owner.adjust_brute_loss(-5 * seconds_between_ticks, updating_health = FALSE)
	need_update += owner.adjust_fire_loss(-5 * seconds_between_ticks, updating_health = FALSE)
	if(need_update)
		owner.updatehealth()

/datum/status_effect/vampire_thrall_net
	id = "vampire_thrall_net"
	tick_interval = 2 SECONDS
	alert_type = null
	var/blood_cost_per_tick = 5
	var/datum/antagonist/vampire/vampire
	var/list/datum/weakref/network_members = list()

/datum/status_effect/vampire_thrall_net/on_creation(mob/living/new_owner, datum/antagonist/vampire/new_vampire)
	vampire = new_vampire
	. = ..()

/datum/status_effect/vampire_thrall_net/on_apply()
	if(!vampire)
		return FALSE
	var/turf/owner_turf = get_turf(owner)
	if(!owner_turf)
		return FALSE
	network_members += WEAKREF(owner)
	for(var/datum/antagonist/vampire_thrall/thrall as anything in vampire.get_thralls())
		var/turf/thrall_turf = get_turf(thrall.owner?.current)
		if(thrall_turf && thrall_turf.z == owner_turf.z && get_dist(owner_turf, thrall_turf) <= 7 && thrall.owner.current.stat != DEAD)
			network_members += WEAKREF(thrall.owner.current)
	return length(network_members) > 1

/datum/status_effect/vampire_thrall_net/tick(seconds_between_ticks)
	var/turf/owner_turf = get_turf(owner)
	if(!owner_turf)
		qdel(src)
		return
	var/list/mob/living/members = list()
	var/total_brute_damage = 0
	var/total_burn_damage = 0
	var/total_tox_damage = 0
	var/total_oxy_damage = 0
	for(var/datum/weakref/member_ref as anything in network_members)
		var/mob/living/member = member_ref.resolve()
		var/turf/member_turf = get_turf(member)
		if(!member_turf || member.stat == DEAD || member_turf.z != owner_turf.z || get_dist(owner_turf, member_turf) > 7)
			continue
		members += member
		total_brute_damage += member.get_brute_loss()
		total_burn_damage += member.get_fire_loss()
		total_tox_damage += member.get_tox_loss()
		total_oxy_damage += member.get_oxy_loss()
	if(length(members) <= 1 || !vampire?.bloodusable)
		qdel(src)
		return
	var/member_count = length(members)
	var/average_brute_damage = total_brute_damage / member_count
	var/average_burn_damage = total_burn_damage / member_count
	var/average_tox_damage = total_tox_damage / member_count
	var/average_oxy_damage = total_oxy_damage / member_count
	for(var/mob/living/member as anything in members)
		member.adjust_brute_loss(average_brute_damage - member.get_brute_loss())
		member.adjust_fire_loss(average_burn_damage - member.get_fire_loss())
		member.adjust_tox_loss(average_tox_damage - member.get_tox_loss(), forced = TRUE)
		member.adjust_oxy_loss(average_oxy_damage - member.get_oxy_loss(), forced = TRUE)
	vampire.subtract_usable_blood(blood_cost_per_tick)

/datum/status_effect/vampire_shadow_boxing
	id = "vampire_shadow_boxing"
	duration = 10 SECONDS
	tick_interval = 0.4 SECONDS
	alert_type = null
	var/datum/weakref/source_ref

/datum/status_effect/vampire_shadow_boxing/on_creation(mob/living/new_owner, mob/living/source)
	source_ref = WEAKREF(source)
	return ..()

/datum/status_effect/vampire_shadow_boxing/tick(seconds_between_ticks)
	var/mob/living/source = source_ref?.resolve()
	if(!source || get_dist(owner, source) > 2)
		qdel(src)
		return
	source.do_attack_animation(owner, ATTACK_EFFECT_PUNCH)
	owner.apply_damage(8, BRUTE)
	var/obj/effect/immortality_talisman/effect = new(get_turf(source))
	effect.shadow_to_animation(get_turf(owner), source)

/**
 * Attached to a human. Adds unarmed damage.
 */
/datum/element/bonus_unarmed_damage
	/// The amount of brute damage we will deal
	var/brute_damage_amount

/datum/element/bonus_unarmed_damage/Attach(datum/target, brute_damage_amount = 15)
	. = ..()
	if(!ishuman(target))
		return ELEMENT_INCOMPATIBLE

	src.brute_damage_amount = brute_damage_amount
	RegisterSignal(target, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(unarmed_attack_target))

/datum/element/bonus_unarmed_damage/Detach(datum/source)
	UnregisterSignal(source, COMSIG_LIVING_UNARMED_ATTACK)
	return ..()

/datum/element/bonus_unarmed_damage/proc/unarmed_attack_target(mob/living/attacker, atom/target, proximity, list/modifiers)
	SIGNAL_HANDLER

	if(!attacker.combat_mode || !proximity || LAZYACCESS(modifiers, RIGHT_CLICK))
		return

	if(!isliving(target))
		return
	var/mob/living/living_target = target
	if(living_target.stat == DEAD)
		return

	living_target.adjust_brute_loss(brute_damage_amount)

/datum/status_effect/vampire_blood_spill
	id = "vampire_blood_spill"
	tick_interval = 2 SECONDS
	alert_type = null
	var/datum/weakref/vampire_ref

/datum/status_effect/vampire_blood_spill/on_creation(mob/living/new_owner, datum/weakref/new_vampire_ref)
	vampire_ref = new_vampire_ref
	return ..()

/datum/status_effect/vampire_blood_spill/tick(seconds_between_ticks)
	var/datum/antagonist/vampire/vampire = vampire_ref?.resolve()
	if(!vampire || owner.stat == DEAD || !vampire.bloodusable)
		qdel(src)
		return
	var/beam_number = 0
	for(var/mob/living/carbon/human/target in view(7, owner))
		if(!target.get_blood_volume() || !target.affects_vampire(owner) || target.stat)
			continue
		var/drain_amount = rand(5, 10) * seconds_between_ticks / 2
		target.bleed(drain_amount)
		target.Beam(owner, icon_state = "drainbeam", time = seconds_between_ticks SECONDS)
		target.adjust_brute_loss(seconds_between_ticks)
		owner.heal_overall_damage(4 * seconds_between_ticks, seconds_between_ticks, TRUE)
		owner.adjust_stamina_loss(-7.5 * seconds_between_ticks)
		owner.AdjustStun(-seconds_between_ticks SECONDS)
		owner.AdjustKnockdown(-seconds_between_ticks SECONDS)
		owner.AdjustImmobilized(-seconds_between_ticks SECONDS)
		if(++beam_number >= 10)
			break
	vampire.subtract_usable_blood(5 * seconds_between_ticks)

/datum/status_effect/vampire_eternal_darkness
	id = "vampire_eternal_darkness"
	tick_interval = 1 SECONDS
	alert_type = null
	var/datum/weakref/vampire_ref

/datum/status_effect/vampire_eternal_darkness/on_creation(mob/living/new_owner, datum/weakref/new_vampire_ref)
	vampire_ref = new_vampire_ref
	return ..()

/datum/status_effect/vampire_eternal_darkness/on_apply()
	owner.set_light(8, -6, "#ddd6cf")
	return TRUE

/datum/status_effect/vampire_eternal_darkness/on_remove()
	owner.set_light(0)

/datum/status_effect/vampire_eternal_darkness/tick(seconds_between_ticks)
	var/datum/antagonist/vampire/vampire = vampire_ref?.resolve()
	if(!vampire || owner.stat == DEAD || !vampire.bloodusable)
		qdel(src)
		return
	for(var/atom/target as mob|obj in view(8, owner))
		if(isliving(target))
			var/mob/living/living_target = target
			if(living_target.affects_vampire(owner))
				living_target.adjust_bodytemperature(-15 * TEMPERATURE_DAMAGE_COEFFICIENT * seconds_between_ticks)
		else if(isprojectile(target))
			var/obj/projectile/projectile = target
			if(projectile.armor_flag == ENERGY || projectile.armor_flag == LASER)
				projectile.damage *= 0.7 ** (seconds_between_ticks / 0.2)
	vampire.subtract_usable_blood(1.25 * seconds_between_ticks)
