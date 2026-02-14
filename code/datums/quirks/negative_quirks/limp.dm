/datum/quirk/limp
	name = "Limp"
	desc = "Старая травма ноги. Бегать невозможно."
	value = -6
	icon = FA_ICON_CRUTCH

	mob_trait = TRAIT_LIMP

/datum/quirk/limp/add()
	var/mob/living/L = quirk_holder

	if(L.move_intent == MOVE_INTENT_RUN)
		L.toggle_move_intent(MOVE_INTENT_WALK)

	RegisterSignal(L, COMSIG_MOB_PRE_TOGGLE_MOVE_INTENT, PROC_REF(on_intent_attempt))

/datum/quirk/limp/remove()
	var/mob/living/L = quirk_holder
	UnregisterSignal(L, COMSIG_MOB_PRE_TOGGLE_MOVE_INTENT, src)

/datum/quirk/limp/proc/on_intent_attempt(datum/source, target_intent)
	SIGNAL_HANDLER
	var/mob/living/L = source

	if(target_intent == MOVE_INTENT_RUN)
		to_chat(L, span_warning("Моя нога слишком болит, чтобы бежать!"))
		return COMPONENT_PREVENT_TOGGLE_MOVE_INTENT
