// Overriding proc so chef can learn cqc without disabling his skillchip
/obj/item/book/granter/martial/cqc/can_learn(mob/living/user)
	if(!martial)
		CRASH("Someone attempted to learn [type], which did not have a martial arts set.")
	if(!isliving(user))
		return FALSE
	for(var/datum/martial_art/martial_art as anything in user.martial_arts)
		if(martial_art.type == martial) // chef already has cqc subtype
			to_chat(user, span_warning("You already know [martial_name]!"))
			return FALSE
	return TRUE
