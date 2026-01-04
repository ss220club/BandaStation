/obj/item/stack/talon
	name = "Талон"
	desc = "Это заглушка"
	icon = 'icons/obj/economy.dmi'
	icon_state = null
	worn_icon_state = "nothing"
	amount = 1
	max_amount = INFINITY
	throwforce = 0
	throw_speed = 2
	throw_range = 2
	w_class = WEIGHT_CLASS_TINY
	full_w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE
	var/value = 0
	grind_results = list(/datum/reagent/cellulose = 10)

/obj/item/stack/talon/food
	name = "Талон на еду"
	desc = "Это талон определенный для обмена на продовольственные товары. Можно обменять один товар на один талон."
	icon_state = "spacecash200"

/obj/item/stack/talon/clothes
	name = "Талон на одежду"
	icon_state  = "spacecash1"

/obj/item/stack/talon/tools
	name = "Талон на инструменты"
	icon_state  = "spacecash100"

/obj/item/stack/talon/alcohol
	name = "Талон на алкоголь"
	icon_state  = "spacecash50"

/obj/item/stack/talon/household
	name = "Талон на бытовые товары"
	icon_state  = "spacecash10"
