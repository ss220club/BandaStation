/datum/component/stamina_cost_per_hit
	var/stamina_cost = 10
	var/stamina_cost_wielded
	var/stamina_cost_on_atom
	var/stamina_cost_wielded_on_atom
	var/ignore_exhaustion = FALSE

	var/attack_cost

/datum/component/stamina_cost_per_hit/Initialize(
	stamina_cost = 10,
	stamina_cost_wielded,
	stamina_cost_on_atom,
	stamina_cost_wielded_on_atom,
	ignore_exhaustion = FALSE,
)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.stamina_cost = stamina_cost
	src.stamina_cost_wielded = stamina_cost_wielded || stamina_cost
	src.stamina_cost_on_atom = stamina_cost_on_atom || stamina_cost
	src.stamina_cost_wielded_on_atom = stamina_cost_wielded_on_atom || src.stamina_cost_wielded
	src.ignore_exhaustion = ignore_exhaustion

/datum/component/stamina_cost_per_hit/RegisterWithParent()
	RegisterSignals(parent, list(
		COMSIG_ITEM_ATTACK,
		COMSIG_ITEM_ATTACK_ATOM
		), PROC_REF(on_attack))
	RegisterSignal(parent, COMSIG_ITEM_AFTERATTACK, PROC_REF(on_afterattack))

/datum/component/stamina_cost_per_hit/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ITEM_ATTACK,
		COMSIG_ITEM_ATTACK_ATOM,
		COMSIG_ITEM_AFTERATTACK,
	))

/datum/component/stamina_cost_per_hit/proc/on_attack(obj/item/attaking_item, atom/target, mob/living/user, list/modifiers, list/attack_modifiers)
	SIGNAL_HANDLER // COMSIG_ITEM_ATTACK + COMSIG_ITEM_ATTACK_ATOM

	if(isliving(target))
		attack_cost = HAS_TRAIT(parent, TRAIT_WIELDED) ? stamina_cost_wielded : stamina_cost
	else
		attack_cost = HAS_TRAIT(parent, TRAIT_WIELDED) ? stamina_cost_wielded_on_atom : stamina_cost_on_atom

	if(!ignore_exhaustion && ((user.maxHealth - (user.getStaminaLoss() + attack_cost)) <= user.crit_threshold))
		user.balloon_alert(user, "нет сил!")
		return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/stamina_cost_per_hit/proc/on_afterattack(obj/item/attaking_item, atom/target, mob/living/user, list/modifiers, list/attack_modifiers)
	SIGNAL_HANDLER // COMSIG_ITEM_AFTERATTACK

	user.adjustStaminaLoss(attack_cost)
