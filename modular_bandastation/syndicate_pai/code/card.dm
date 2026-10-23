/obj/item/pai_card
	/// Mob created when a candidate inhabits this card.
	var/pai_mob_type = /mob/living/silicon/pai

/obj/item/pai_card/syndicate
	name = "syndicate personal AI device"
	desc = "A modified personal AI device with expanded memory and clandestine software."
	pai_mob_type = /mob/living/silicon/pai/syndicate

/obj/item/pai_card/screwdriver_act(mob/living/user, obj/item/tool)
	if(!pai?.radio)
		return ..()
	return pai.radio.screwdriver_act(user, tool)
