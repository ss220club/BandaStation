/mob/living/basic/moth
	name = "моль"
	desc = "Смотря на эту моль становится понятно куда пропали шубы перевозимые СССП."
	icon = 'modular_bandastation/mobs/icons/mob/animal.dmi'
	icon_state = "moth"
	icon_living = "moth"
	icon_dead = "moth_dead"
	turns_per_move = 1
	emote_see = list("flutters")
	response_help = "shoos"
	response_disarm_continuous = "brushes aside"
	response_disarm_simple = "brushes aside"
	response_harm_continuous = "squashes"
	response_harm_simple = "squashes"
	speak_chance = 0
	maxHealth = 15
	health = 15
	see_in_dark = 100
	friendly = "nudges"
	density = 0
	initial_traits = list(TRAIT_FLYING)
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	ventcrawler = 2
	mob_size = MOB_SIZE_TINY
	butcher_results = list(/obj/item/food/monstermeat/xenomeat = 1)
	gold_core_spawnable = FRIENDLY_SPAWN
	// holder_type = /obj/item/holder/moth

/mob/living/basic/nian_caterpillar/Initialize(mapload)
	. = ..()
	butcher_results |= list(/obj/item/stack/sheet/animalhide/mothroach = 1)
