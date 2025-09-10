/// Return values for wall tearing validation
#define WALL_TEAR_ALLOWED 1
#define WALL_TEAR_INVALID 0
#define WALL_TEAR_CANCEL_CHAIN -1

/datum/component/rip_and_tear
	var/stamina_cost = 30
	var/stamina_cost_wielded
	var/require_wielded = TRUE
	var/reinforced_multiplier
	var/tear_time = 5 SECONDS
	var/do_after_key = "rip_and_tear"

/datum/component/rip_and_tear/Initialize(
	stamina_cost = 30,
	stamina_cost_wielded,
	require_wielded = TRUE,
	reinforced_multiplier,
	tear_time = 5 SECONDS,
)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.stamina_cost = stamina_cost
	src.stamina_cost_wielded = stamina_cost_wielded
	if(!stamina_cost_wielded)
		src.stamina_cost_wielded = stamina_cost
	src.require_wielded = require_wielded
	src.reinforced_multiplier = reinforced_multiplier
	src.tear_time = tear_time

/datum/component/rip_and_tear/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_PRE_ATTACK, PROC_REF(on_pre_attack))

/datum/component/rip_and_tear/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ITEM_PRE_ATTACK,
	))

/datum/component/rip_and_tear/proc/on_pre_attack(obj/item/source, atom/target, mob/living/user, list/modifiers)
	SIGNAL_HANDLER // COMSIG_ITEM_PRE_ATTACK

	if(!iswallturf(target))
		return

	var/is_valid = validate_target(target, user)
	if(is_valid != WALL_TEAR_ALLOWED)
		return is_valid == WALL_TEAR_CANCEL_CHAIN ? COMPONENT_CANCEL_ATTACK_CHAIN : .

	INVOKE_ASYNC(src, PROC_REF(rip_and_tear), user, target)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/rip_and_tear/proc/validate_target(atom/target, mob/living/user)
	if(!isclosedturf(target) || isindestructiblewall(target))
		return WALL_TEAR_INVALID

	if(require_wielded && !HAS_TRAIT(parent, TRAIT_WIELDED))
		user.balloon_alert(user, "нужно держать двумя руками!")
		return WALL_TEAR_CANCEL_CHAIN

	var/reinforced = istype(target, /turf/closed/wall/r_wall)
	if(!reinforced_multiplier && reinforced)
		target.balloon_alert(user, "слишком крепкая!")
		return WALL_TEAR_CANCEL_CHAIN

	return WALL_TEAR_ALLOWED

/datum/component/rip_and_tear/proc/rip_and_tear(mob/living/user, atom/target)
	if(QDELETED(target))
		return

	var/reinforced = istype(target, /turf/closed/wall/r_wall)
	if(reinforced && !reinforced_multiplier)
		return

	var/rip_time = (reinforced ? tear_time * reinforced_multiplier : tear_time) / 3
	if(rip_time > 0)
		if(DOING_INTERACTION_WITH_TARGET(user, target) || DOING_INTERACTION(user, do_after_key))
			user.balloon_alert(user, "заняты!")
			return
		if(user.getStaminaLoss() >= 90)
			user.balloon_alert(user, "вы слишком устали!")
			return
		user.visible_message(span_warning("[capitalize(user.declent_ru(NOMINATIVE))] начинает выламывать [target.declent_ru(ACCUSATIVE)]!"))
		playsound(user, 'sound/machines/airlock/airlock_alien_prying.ogg', vol = 100, vary = TRUE)
		target.balloon_alert(user, "выламываем...")
		if(!do_after(user, delay = rip_time, target = target, interaction_key = do_after_key))
			user.balloon_alert(user, "прервано!")
			return

	var/is_valid = validate_target(target, user)
	if(is_valid != WALL_TEAR_ALLOWED)
		return

	user.do_attack_animation(target)
	target.AddComponent(/datum/component/torn_wall)
	user.adjustStaminaLoss(get_stamina_cost())
	playsound(target, 'sound/effects/meteorimpact.ogg', 100, TRUE)

	is_valid = validate_target(target, user)
	if(is_valid == WALL_TEAR_ALLOWED)
		rip_and_tear(user, target)

/datum/component/rip_and_tear/proc/get_stamina_cost()
	return HAS_TRAIT(parent, TRAIT_WIELDED) ? stamina_cost_wielded : stamina_cost

#undef WALL_TEAR_ALLOWED
#undef WALL_TEAR_INVALID
#undef WALL_TEAR_CANCEL_CHAIN
