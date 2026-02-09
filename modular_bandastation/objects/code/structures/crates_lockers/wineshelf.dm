/obj/structure/wine_rack
	name = "wine shelf"
	desc = "Деревянная полка для вина. Пустая."
	icon = 'icons/obj/storage/wineshelf.dmi'
	icon_state = "wineshelf_empty"
	anchored = TRUE
	density = FALSE

	var/max_bottles = 6

/obj/structure/wine_rack/Initialize()
	. = ..()

	AddComponent(/datum/component/storage, list(
		max_items = max_bottles,
		can_hold = list(/obj/item/reagent_containers/food/drinks/bottle),
		quickdraw = FALSE,
		silent = FALSE
	))

/obj/structure/wine_rack/proc/update_icon()
	var/datum/component/storage/S = GetComponent(/datum/component/storage)
	if(!S)
		return

	if(S.contents.len)
		icon_state = "wineshelf_full"
		desc = "Деревянная полка для вина. Заполнена некоторыми бутылками."
	else
		icon_state = "wineshefl_empty"
		desc = "Деревянная полка для вина. Пустая."
