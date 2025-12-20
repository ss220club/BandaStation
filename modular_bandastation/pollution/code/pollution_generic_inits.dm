/obj/effect/decal/cleanable/greenglow/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/pollution_emitter, /datum/pollutant/chemical_vapors, 10)

/obj/effect/decal/cleanable/vomit/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/pollution_emitter, /datum/pollutant/decaying_waste, 10)

/obj/effect/decal/cleanable/insectguts/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/pollution_emitter, /datum/pollutant/decaying_waste, 10)

/obj/effect/decal/cleanable/garbage/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/pollution_emitter, /datum/pollutant/decaying_waste, 30)

/obj/effect/decal/cleanable/blood/gibs/old/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	AddElement(/datum/element/pollution_emitter, /datum/pollutant/decaying_waste, 30)

/obj/structure/moisture_trap/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/pollution_emitter, /datum/pollutant/decaying_waste, 30)
