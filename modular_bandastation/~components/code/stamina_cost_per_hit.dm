/datum/component/stamina_cost_per_hit
	var/stamina_cost = 20
	var/stamina_cost_wielded

/datum/component/stamina_cost_per_hit/Initialize(
	stamina_cost = 20,
	stamina_cost_wielded,
)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.stamina_cost = stamina_cost
	src.stamina_cost_wielded = stamina_cost
	if(stamina_cost_wielded)
		src.stamina_cost_wielded = stamina_cost_wielded

/datum/component/stamina_cost_per_hit/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_ATTACK, PROC_REF(on_attack))

/datum/component/stamina_cost_per_hit/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ITEM_ATTACK,
	))

/datum/component/stamina_cost_per_hit/proc/on_attack(obj/item/attaking_item, mob/living/target_mob, mob/living/user, list/modifiers, list/attack_modifiers)
	SIGNAL_HANDLER

	if(HAS_TRAIT(parent, TRAIT_WIELDED))
		user.adjustStaminaLoss(stamina_cost_wielded)
	else
		user.adjustStaminaLoss(stamina_cost)
