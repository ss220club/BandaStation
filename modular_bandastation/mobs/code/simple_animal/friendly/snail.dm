/mob/living/basic/snail
	name = "улитка"
	desc = "Маленькая улиточка со своим маленьким домиком. Не гигиеничная..."
	death_sound = 'modular_bandastation/mobs/sound/crack_death1.ogg'
	// holder_type = /obj/item/holder/snail

/mob/living/basic/snail/space
	name = "космоулитка"
	desc = "Маленькая космо-улиточка со своим космо-домиком. Прочная, тихая и медленная."
	icon = 'modular_bandastation/mobs/icons/mob/animal.dmi'
	icon_state = "snail"
	icon_living = "snail"
	icon_dead = "snail_dead"
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0

/mob/living/basic/snail/space/Process_Spacemove(movement_dir = 0)
	return 1

/mob/living/basic/snail/space/Move(atom/newloc, direct, movetime)
	var/oldLoc = src.loc
	. = ..()
	if(.)
		if(stat != DEAD)
			make_wet_floor(oldLoc)

/mob/living/basic/snail/space/proc/make_wet_floor(atom/oldLoc)
	if(oldLoc != src.loc)
		reagents.add_reagent("water",10)
		reagents.reaction(oldLoc, REAGENT_TOUCH, 10)	//10 is the multiplier for the reaction effect. probably needed to wet the floor properly.
		reagents.remove_any(10)

/mob/living/basic/snail/space/lube
	name = "space snail"
	desc = "Маленькая космо-улиточка со своим космо-домиком. Прочная, тихая и медленная. И очень склизкая."
	gold_core_spawnable = HOSTILE_SPAWN
	faction = list("slime", "hostile")

/mob/living/basic/snail/space/lube/make_wet_floor(atom/oldLoc)
	if(oldLoc != src.loc)
		reagents.add_reagent("lube",10)
		reagents.reaction(oldLoc, REAGENT_TOUCH, 10)
		reagents.remove_any(10)

/mob/living/basic/turtle
	death_sound = 'modular_bandastation/mobs/sound/crack_death1.ogg'
	// holder_type = /obj/item/holder/turtle
