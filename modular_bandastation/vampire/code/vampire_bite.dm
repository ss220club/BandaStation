/// Starts vampire blood draining from the normal unarmed combat flow.
/datum/component/vampire_biter
	dupe_mode = COMPONENT_DUPE_UNIQUE

/datum/component/vampire_biter/Initialize(...)
	. = ..()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/vampire_biter/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_LIVING_EARLY_UNARMED_ATTACK, PROC_REF(try_bite))

/datum/component/vampire_biter/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_LIVING_EARLY_UNARMED_ATTACK)

/datum/component/vampire_biter/proc/try_bite(mob/living/carbon/human/source, atom/target, proximity_flag, list/modifiers)
	SIGNAL_HANDLER
	if(!proximity_flag || !source.combat_mode || LAZYACCESS(modifiers, RIGHT_CLICK) || source.get_active_held_item() || source.zone_selected != BODY_ZONE_HEAD)
		return
	if(!istype(target, /mob/living/carbon/human))
		return
	if(!source.can_unarmed_attack())
		return COMPONENT_CANCEL_ATTACK_CHAIN

	var/mob/living/carbon/human/victim = target
	var/datum/antagonist/vampire/vampire = source.mind?.has_antag_datum(/datum/antagonist/vampire)
	if(!vampire || vampire.draining || victim == source)
		return
	if(!victim.get_blood_volume())
		to_chat(source, span_warning("They have no blood!"))
		return COMPONENT_CANCEL_ATTACK_CHAIN
	if(victim.mind?.has_antag_datum(/datum/antagonist/vampire) || victim.mind?.has_antag_datum(/datum/antagonist/vampire_thrall))
		to_chat(source, span_warning("Your fangs fail to pierce [victim]'s cold flesh!"))
		return COMPONENT_CANCEL_ATTACK_CHAIN

	vampire.draining = victim
	INVOKE_ASYNC(vampire, TYPE_PROC_REF(/datum/antagonist/vampire, handle_bloodsucking), victim)
	return COMPONENT_CANCEL_ATTACK_CHAIN
