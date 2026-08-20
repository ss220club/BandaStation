/obj/structure/barbed_wire
	name = "Колючая проволока"
	desc = "Металлическая проволока, мешающая свободному передвижению."
	icon = 'modular_bandastation/voyaker_events/icons/barricade.dmi'
	icon_state = "metal_wire"
	density = FALSE
	anchored = TRUE
	var/list/recent_mobs = list()

/obj/structure/barbed_wire/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/barbed_wire/process(seconds_per_tick)
	for(var/mob/living/L in loc)
		if(recent_mobs[L])
			continue
		recent_mobs[L] = TRUE
		L.apply_damage(10, BRUTE, BODY_ZONE_L_LEG)
		playsound(src, 'sound/effects/wounds/blood3.ogg', 50, TRUE)
		to_chat(L, span_warning("Вы наступили на колючую проволоку!"))

/obj/structure/barbed_wire/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/wirecutters))
		balloon_alert(user, "срезает...")
		if(!do_after(user, 3 SECONDS, target = src))
			return
		playsound(src, 'sound/items/tools/wirecutter.ogg', 50, TRUE)
		qdel(src)
		return
	return ..()
