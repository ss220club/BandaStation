/datum/keybinding/artificial_intelligence
	category = CATEGORY_AI
	weight = WEIGHT_AI

/datum/keybinding/artificial_intelligence/can_use(client/user)
	return isAI(user.mob)

/datum/keybinding/artificial_intelligence/reconnect
	hotkey_keys = list("-")
	name = "reconnect"
	full_name = "Переподключиться к оболочке"
	description = "Подключает к ИИ оболочке, которая была подключена последней"
	keybind_signal = COMSIG_KB_SILICON_RECONNECT_DOWN

/datum/keybinding/artificial_intelligence/reconnect/down(client/user, turf/target)
	. = ..()
	if(.)
		return
	var/mob/living/silicon/ai/our_ai = user.mob
	our_ai.deploy_to_shell(our_ai.redeploy_action.last_used_shell)
	return TRUE
