/obj/structure/barbed_wire
	name = "Колючая проволока"
	desc = "Металлическая проволока, мешающая свободному передвижению."
	icon = 'modular_bandastation/voyaker_events/icons/barricade.dmi'
	icon_state = "metal_wire"
	layer = ABOVE_MOB_LAYER
	density = FALSE
	anchored = TRUE
	var/list/recent_mobs = list()

/obj/structure/barbed_wire/Crossed(atom/movable/AM)
	. = ..()
	if(!isliving(AM))
		return
	var/mob/living/L = AM
	if(recent_mobs[L])
		return
	recent_mobs[L] = world.time
	var/obj/item/bodypart/leg = L.get_bodypart(BODY_ZONE_L_LEG)
	if(leg)
		leg.receive_damage(10, 15)
	to_chat(L, span_warning("Вы наступили на колючую проволоку!"))
	addtimer(CALLBACK(src, PROC_REF(clear_cd), L), 2 SECONDS)

/obj/structure/barbed_wire/proc/clear_cd(mob/living/L)
	recent_mobs -= L
