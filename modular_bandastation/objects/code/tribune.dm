/obj/structure/tribune
	name = "tribune"
	icon = 'modular_bandastation/objects/icons/tribune.dmi'
	icon_state = "nt_tribune"
	desc = "A sturdy wooden tribune. When you look at it, you want to start making a speech."
	density = TRUE
	anchored = FALSE
	max_integrity = 100
	resistance_flags = FLAMMABLE
	var/buildstacktype = /obj/item/stack/sheet/mineral/wood
	var/buildstackamount = 5
	var/mover_dir = null
	var/ini_dir = null

/obj/structure/tribune/wrench_act(mob/user, obj/item/tool)
	. = TRUE
	default_unfasten_wrench(user, tool)

/obj/structure/tribune/screwdriver_act(mob/user, obj/item/tool)
	. = TRUE
	if(flags_1 & INDESTRUCTIBLE)
		to_chat(user, span_warning("Try as you might, you can't figure out how to deconstruct [src]."))
		return
	if(!tool.use_tool(src, user, 30))
		return
	deconstruct(TRUE)

/obj/structure/tribune/proc/after_rotation(mob/user)
	add_fingerprint(user)

/obj/structure/tribune/Initialize(mapload) //Only for mappers
	..()
	handle_layer()

/obj/structure/tribune/setDir(newdir)
	..()
	handle_layer()

/obj/structure/tribune/Move(newloc, direct, movetime)
	. = ..()
	handle_layer()

/obj/structure/tribune/proc/handle_layer()
	if(dir == NORTH)
		layer = LOW_ITEM_LAYER
	else
		layer = ABOVE_MOB_LAYER

/obj/structure/tribune/click_alt(mob/user)
	. = ..()
	if(!Adjacent(user))
		return
	if(anchored)
		to_chat(user, span_warning("It is fastened to the floor!"))
		return
	setDir(turn(dir, 90))
	after_rotation(user)

/obj/structure/tribune/centcom
	name = "CentCom tribune"
	icon = 'modular_bandastation/objects/icons/tribune.dmi'
	icon_state = "nt_tribune_cc"
	desc = "A richly decorated tribune. Just looking at her makes your heart skip a beat."
