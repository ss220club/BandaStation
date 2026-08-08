/turf/open/misc/asteroid/basalt/hot
	name = "scorched basalt"

/turf/open/misc/asteroid/basalt/hot/Entered(atom/movable/AM)
	. = ..()
	if(!isliving(AM))
		return
	var/mob/living/L = AM
	// Летающие и лежащие на каталке не страдают
	if(L.movement_type & FLOATING)
		return
	L.adjust_fire_loss(2)
	if(prob(25))
		playsound(src,'sound/effects/chemistry/bufferadd.ogg', 25, TRUE)
		to_chat(L, span_warning("Жар обжигает подошвы ботинок!"))



