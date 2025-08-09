/obj/item/reagent_containers/c4_big
	name = "C-4 brick"
	desc = "Большой брикет С4. Похоже, тебе понадобится что-то острое, чтобы разрезать его..."
	icon = 'modular_bandastation/objects/icons/obj/items/explosives.dmi'
	icon_state = "C4_cube"
	volume = 60
	list_reagents = list(/datum/reagent/rdx = 8, /datum/reagent/medicine/c2/penthrite = 12, /datum/reagent/fuel/oil = 40)

/obj/item/reagent_containers/c4_big/attackby(obj/item/W, mob/user, params)
	if(W.get_sharpness())
		user.show_message(span_notice("Вы разрезали [src] на несколько кусков."), MSG_VISUAL)
		for(var/i in 1 to 4)
			new /obj/item/reagent_containers/с4_small(get_turf(user))
		qdel(src)

/datum/crafting_recipe/c4_big
	name = "C-4 brick"
	result = /obj/item/reagent_containers/c4_big
	reqs = list(/obj/item/reagent_containers/c4_small = 4)
	parts = list(/obj/item/reagent_containers/c4_small = 4)
	time = 2 SECONDS
	category = CAT_CHEMISTRY

/obj/item/reagent_containers/c4_small
	name = "Piece of C-4"
	desc = "Кусочек С-4. Выглядит как клубничная жвачка."
	icon = 'modular_bandastation/objects/icons/obj/items/explosives.dmi'
	icon_state = "C4_piece"
	volume = 15
	list_reagents = list(/datum/reagent/rdx = 2, /datum/reagent/medicine/c2/penthrite = 3, /datum/reagent/fuel/oil = 10)

/obj/item/reagent_containers/semtex_big
	name = "Semtex brick"
	desc = "Большой брикет семтекса. Похоже, тебе понадобится что-то острое, чтобы разрезать его..."
	icon = 'modular_bandastation/objects/icons/obj/items/explosives.dmi'
	icon_state = "semtex_cube"
	volume = 84
	list_reagents = list(/datum/reagent/rdx = 20, /datum/reagent/medicine/c2/penthrite = 12, /datum/reagent/fuel/oil = 40, /datum/reagent/tatp = 12)

/obj/item/reagent_containers/semtex_big/attackby(obj/item/W, mob/user, params)
	if(W.get_sharpness())
		user.show_message(span_notice("Вы разрезали [src] на несколько кусков."), MSG_VISUAL)
		for(var/i in 1 to 4)
			new /obj/item/reagent_containers/semtex_small(get_turf(user))
		qdel(src)

/datum/crafting_recipe/semtex_big
	name = "Semtex brick"
	result = /obj/item/reagent_containers/semtex_big
	reqs = list(/obj/item/reagent_containers/semtex_small = 4)
	parts = list(/obj/item/reagent_containers/semtex_small = 4)
	time = 2 SECONDS
	category = CAT_CHEMISTRY

/obj/item/reagent_containers/semtex_small
	name = "Piece of semtex"
	desc = "Кусочек семтекса. Настоящее Чешское качество."
	icon = 'modular_bandastation/objects/icons/obj/items/explosives.dmi'
	icon_state = "semtex_piece"
	volume = 21
	list_reagents = list(/datum/reagent/rdx = 5, /datum/reagent/medicine/c2/penthrite = 3, /datum/reagent/fuel/oil = 10, /datum/reagent/tatp = 3)
