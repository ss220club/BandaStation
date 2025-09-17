/mob/living/basic/moth
	name = "моль"
	desc = "Смотря на эту моль становится понятно куда пропали шубы перевозимые СССП."
	// holder_type = /obj/item/holder/moth

/mob/living/basic/nian_caterpillar/Initialize(mapload)
	. = ..()
	butcher_results |= list(/obj/item/stack/sheet/animalhide/mothroach = 1)
