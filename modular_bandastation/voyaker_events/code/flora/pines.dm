/obj/structure/flora/tree/pine
	name = "pine tree"
	desc = "A tall pine tree."
	icon = 'modular_bandastation/voyaker_events/icons/pines.dmi'
	density = TRUE
	anchored = TRUE
	layer = ABOVE_MOB_LAYER
	pixel_x = -16

/obj/structure/flora/tree/pine/pine1
	icon_state = "pine1"

/obj/structure/flora/tree/pine/pine2
	icon_state = "pine2"

/obj/structure/flora/tree/pine/pine3
	icon_state = "pine3"

/obj/structure/flora/tree/pine/pine4
	icon_state = "pine4"

/obj/structure/flora/tree/pine/dead1
	name = "dead pine"
	icon_state = "dead1"

/obj/structure/flora/tree/pine/dead2
	name = "dead pine"
	icon_state = "dead2"

/obj/structure/flora/tree/pine/dead3
	name = "dead pine"
	icon_state = "dead3"

/obj/structure/flora/tree/pine/dead4
	name = "dead stump"
	icon_state = "dead4"
	density = FALSE

/obj/structure/flora/tree/pine/dead5
	name = "dead stump"
	icon_state = "dead5"
	density = FALSE

/obj/structure/flora/tree/pine/random
	icon_state = "pine1"

/obj/structure/flora/tree/pine/random/Initialize(mapload)
	. = ..()
	icon_state = pick("pine1", "pine2", "pine3", "pine4", "dead1", "dead2", "dead3")
