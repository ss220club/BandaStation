/obj/item/knife/security_service
	name = "security service knife"
	desc = "Служебный нож, разработанный НТ для удовлетворения потребности СБ в чём-то остром; на материалах экономили как могли."
	icon = 'modular_bandastation/weapon/icons/sec_force/knife/objects.dmi'
	icon_state = "combat_knife"
	inhand_icon_state = "combat_knife"
	lefthand_file = 'modular_bandastation/weapon/icons/sec_force/knife/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/sec_force/knife/righthand.dmi'
	worn_icon = 'modular_bandastation/weapon/icons/sec_force/knife/belt.dmi'
	worn_icon_state = "combat_knife"
	inhand_x_dimension = 32
	inhand_y_dimension = 32
	slot_flags = ITEM_SLOT_BELT
	force = 10
	throwforce = 5
	embed_type = null

/obj/item/knife/security_service/get_throw_hit_message(mob/living/victim, victim_message = FALSE)
	if(victim_message)
		return "[capitalize(declent_ru(NOMINATIVE))] врезается в вас, но не втыкается. Похоже, балансировкой изделия занималась бухгалтерия."
	return "[capitalize(declent_ru(NOMINATIVE))] врезается в [victim.declent_ru(ACCUSATIVE)], но не втыкается. Похоже, балансировкой изделия занималась бухгалтерия."
