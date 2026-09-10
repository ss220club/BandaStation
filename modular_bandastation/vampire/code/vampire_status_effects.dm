/// Temporary effects used exclusively by vampire abilities.

/datum/status_effect/vampire_blood_swell
	id = "vampire_blood_swell"
	duration = 30 SECONDS
	tick_interval = STATUS_EFFECT_NO_TICK
	alert_type = null
	var/bonus_damage_applied = FALSE

/datum/status_effect/vampire_blood_swell/on_apply()
	var/mob/living/carbon/human/human_owner = owner
	if(!istype(human_owner))
		return FALSE
	ADD_TRAIT(human_owner, TRAIT_CHUNKYFINGERS, REF(src))
	human_owner.physiology.brute_mod *= 0.4
	human_owner.physiology.burn_mod *= 0.5
	human_owner.physiology.stamina_mod *= 0.5
	human_owner.physiology.stun_mod *= 0.5
	var/datum/antagonist/vampire/vampire = human_owner.mind?.has_antag_datum(/datum/antagonist/vampire)
	if(vampire?.get_ability(/datum/vampire_passive/blood_swell_upgrade))
		bonus_damage_applied = TRUE
		human_owner.AddElement(/datum/element/bonus_damage, 100, 10)
	return TRUE

/datum/status_effect/vampire_blood_swell/on_remove()
	var/mob/living/carbon/human/human_owner = owner
	if(!istype(human_owner))
		return
	REMOVE_TRAIT(human_owner, TRAIT_CHUNKYFINGERS, REF(src))
	human_owner.physiology.brute_mod /= 0.4
	human_owner.physiology.burn_mod /= 0.5
	human_owner.physiology.stamina_mod /= 0.5
	human_owner.physiology.stun_mod /= 0.5
	if(bonus_damage_applied)
		human_owner.RemoveElement(/datum/element/bonus_damage, 100, 10)

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
	multiplicative_slowdown = -1

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
	network_members += WEAKREF(owner)
	for(var/datum/antagonist/vampire_thrall/thrall as anything in vampire.get_thralls())
		if(thrall.owner?.current && get_dist(owner, thrall.owner.current) <= 7 && thrall.owner.current.stat != DEAD)
			network_members += WEAKREF(thrall.owner.current)
	return length(network_members) > 1

/datum/status_effect/vampire_thrall_net/tick(seconds_between_ticks)
	var/list/mob/living/members = list()
	var/total_damage = 0
	for(var/datum/weakref/member_ref as anything in network_members)
		var/mob/living/member = member_ref.resolve()
		if(!member || member.stat == DEAD || get_dist(owner, member) > 7)
			continue
		members += member
		total_damage += member.maxHealth - member.health
		var/datum/status_effect/genetic_damage/genetic_damage = member.has_status_effect(/datum/status_effect/genetic_damage)
		total_damage += genetic_damage?.total_damage
	if(length(members) <= 1 || !vampire?.bloodusable)
		qdel(src)
		return
	var/average_damage = total_damage / length(members)
	for(var/mob/living/member as anything in members)
		var/datum/status_effect/genetic_damage/genetic_damage = member.has_status_effect(/datum/status_effect/genetic_damage)
		var/current_damage = member.maxHealth - member.health + (genetic_damage?.total_damage || 0)
		var/difference = average_damage - current_damage
		if(difference > 0)
			member.adjust_fire_loss(difference)
		else if(difference < 0)
			var/healing = -difference
			member.adjust_brute_loss(-healing)
			if(genetic_damage)
				genetic_damage.total_damage = max(0, genetic_damage.total_damage - healing)
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
	shadow_to_animation(get_turf(source), get_turf(owner), source)

/datum/status_effect/vampire_charging
	id = "vampire_charging"
	duration = 5 SECONDS
	tick_interval = STATUS_EFFECT_NO_TICK
	alert_type = null
