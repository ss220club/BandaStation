/particles/debris
	icon = 'modular_bandastation/aesthetics/effects/icons/generic.dmi'
	width = 500
	height = 500
	count = 10
	spawning = 10
	lifespan = 0.7 SECONDS
	fade = 0.4 SECONDS
	drift = generator(GEN_CIRCLE, 0, 7)
	scale = 0.7
	velocity = list(50, 0)
	friction = generator(GEN_NUM, 0.1, 0.15)
	spin = generator(GEN_NUM, -20, 20)

/particles/impact_smoke
	icon = 'icons/effects/effects.dmi'
	icon_state = "smoke"
	width = 500
	height = 500
	count = 20
	spawning = 20
	lifespan = 0.7 SECONDS
	fade = 8 SECONDS
	grow = 0.1
	scale = 0.2
	spin = generator(GEN_NUM, -20, 20)
	velocity = list(50, 0)
	friction = generator(GEN_NUM, 0.1, 0.5)

// MARK: debris for things
//STRUCTURES
/obj/structure/flora/rock/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_ROCK, -15, 8, 0.7)

/obj/structure/flora/rock/icy/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_SNOW, -15, 8, 0.7)

/obj/structure/flora/rock/pile/jungle/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_LEAF, -15, 8, 0.7)

/obj/structure/flora/rock/pile/icy/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_SNOW, -15, 8, 0.7)

/obj/structure/fermenting_barrel/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_WOOD, -15, 8, 0.7)

/obj/structure/barricade/wooden/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_WOOD, -15, 8, 0.7)

/obj/structure/chair/wood/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_WOOD, -15, 8, 0.7)

/obj/structure/bookcase/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_WOOD, -15, 8, 0.7)

/obj/structure/table_frame/wood/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_WOOD, -15, 8, 0.7)

/obj/structure/table/wood/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_WOOD, -15, 8, 0.7)

/obj/structure/window/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_GLASS, -15, 8, 0.7)

// MARK:  WALLS
/turf/closed/mineral/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_ROCK, -15, 8, 0.7)

/turf/closed/mineral/random/snow/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_SNOW, -15, 8, 0.7)

/turf/closed/mineral/random/labormineral/ice/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_SNOW, -15, 8, 0.7)

/turf/closed/wall/mineral/wood/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_WOOD, -15, 8, 0.7)

/turf/closed/wall/mineral/bamboo/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_WOOD, -15, 8, 0.7)

/turf/closed/wall/mineral/snow/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_SNOW, -15, 8, 0.7)

// FALSE WALLS
/obj/structure/falsewall/wood/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_WOOD, -15, 8, 0.7)

/obj/structure/falsewall/bamboo/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_WOOD, -15, 8, 0.7)
