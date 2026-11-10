/datum/emote/should_play_sound(mob/user, intentional = FALSE)
	. = ..()
	if(!. || !HAS_TRAIT(user, TRAIT_LOOT_GOBLIN) || !(emote_type & EMOTE_AUDIBLE) || hands_use_check)
		return
	var/list/goblin_sounds = list()
	SEND_SIGNAL(user, COMSIG_MOB_EMOTE_SOUND(key), key, goblin_sounds)
	return length(goblin_sounds) > 0
