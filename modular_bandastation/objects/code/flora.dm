//Snowless Pine
/obj/structure/flora/tree/snowless_pine
	name = "pine tree"
	desc = "A coniferous pine tree."
	icon = 'modular_bandastation/objects/icons/obj/structures/flora/tree.dmi'
	icon_state = "snowlesspine_1"
	var/list/icon_states = list("snowlesspine_1", "snowlesspine_2", "snowlesspine_3", "snowlesspine_4")

/obj/structure/flora/tree/snowless_pine/get_seethrough_map()
	return SEE_THROUGH_MAP_DEFAULT_TWO_TALL

/obj/structure/flora/tree/snowless_pine/style_2
	icon_state = "snowlesspine_2"

/obj/structure/flora/tree/snowless_pine/style_3
	icon_state = "snowlesspine_3"

/obj/structure/flora/tree/snowless_pine/style_4
	icon_state = "snowlesspine_4"

/obj/structure/flora/tree/snowless_pine/style_random/Initialize(mapload)
	. = ..()
	icon_state = "snowlesspine_[rand(1,4)]"
	update_appearance()

/obj/structure/flora/tree/stump/snowless_pine
	icon = 'modular_bandastation/objects/icons/obj/structures/flora/tree.dmi'
	icon_state = "pine_tree_stump"

// //Large Pine
// /obj/structure/flora/tree/large_pine
// 	name = "large pine tree"
// 	desc = "A coniferous large pine tree."
// 	icon = 'modular_bandastation/objects/icons/obj/structures/flora/tree.dmi'
// 	icon_state = "large_pine_1"
// 	var/list/icon_states = list("large_pine_1", "large_pine_2", "large_pine_3")

// /obj/structure/flora/tree/large_pine/get_seethrough_map()
// 	return SEE_THROUGH_MAP_DEFAULT_TWO_TALL

// /obj/structure/flora/tree/large_pine/style_2
// 	icon_state = "large_pine_2"

// /obj/structure/flora/tree/large_pine/style_3
// 	icon_state = "large_pine_3"

// /obj/structure/flora/tree/large_pine/style_random/Initialize(mapload)
// 	. = ..()
// 	icon_state = "large_pine_[rand(1,3)]"
// 	update_appearance()

// //Large Tree
// /obj/structure/flora/tree/large_tree
// 	name = "large dead tree"
// 	desc = "A large dead tree."
// 	icon = 'modular_bandastation/objects/icons/obj/structures/flora/tree.dmi'
// 	icon_state = "large_tree_1"
// 	var/list/icon_states = list("large_tree_1", "large_tree_2", "large_tree_3")

// /obj/structure/flora/tree/large_tree/get_seethrough_map()
// 	return SEE_THROUGH_MAP_DEFAULT_THREE_TALL

// /obj/structure/flora/tree/large_tree/style_2
// 	icon_state = "large_tree_2"

// /obj/structure/flora/tree/large_tree/style_3
// 	icon_state = "large_tree_3"

// /obj/structure/flora/tree/large_tree/style_random/Initialize(mapload)
// 	. = ..()
// 	icon_state = "large_tree_[rand(1,3)]"
// 	update_appearance()

// /obj/structure/flora/tree/stump/large_tree
// 	icon = 'modular_bandastation/objects/icons/obj/structures/flora/tree.dmi'
// 	icon_state = "large_tree_stump"

/obj/structure/flora/fruit/apple
	name = "apple tree"
	desc = "A coniferous apple tree."
	icon = 'modular_bandastation/objects/icons/obj/structures/flora/fruit.dmi'
	icon_state = "apple1"

/obj/structure/flora/fruit/get_seethrough_map()
	return SEE_THROUGH_MAP_DEFAULT_TWO_TALL

/obj/structure/flora/fruit/apple1
	name = "apple tree"
	desc = "A coniferous apple tree."
	icon = 'modular_bandastation/objects/icons/obj/structures/flora/fruit.dmi'
	icon_state = "apple0"
	var/list/icon_states = list("apple0", "apple1", "apple2", "apple3")

/obj/structure/flora/tree/fruit/apple/style_2
	icon_state = "apple1"

/obj/structure/flora/tree/fruit/apple/style_3
	icon_state = "apple2"

/obj/structure/flora/tree/fruit/apple/style_4
	icon_state = "apple3"

/obj/structure/flora/fruit/apple/style_random/Initialize(mapload)
	. = ..()
	icon_state = "apple[rand(0,3)]"
	update_appearance()

/obj/structure/flora/tree/fruit/pear
	name = "pear tree"
	desc = "A coniferous pear tree."
	icon = 'modular_bandastation/objects/icons/obj/structures/flora/fruit.dmi'
	icon_state = "pear0"
	var/list/icon_states = list("pear0", "pear1", "pear2", "pear3")

/obj/structure/flora/tree/fruit/pear/style_2
	icon_state = "pear1"

/obj/structure/flora/tree/fruit/pear/style_3
	icon_state = "pear2"

/obj/structure/flora/tree/fruit/pear/style_4
	icon_state = "pear3"

/obj/structure/flora/tree/fruit/pear/style_random/Initialize(mapload)
	. = ..()
	icon_state = "pear[rand(0,3)]"
	update_appearance()

/obj/structure/flora/tree/fruit/lemon
	name = "lemon tree"
	desc = "A coniferous lemon tree."
	icon = 'modular_bandastation/objects/icons/obj/structures/flora/fruit.dmi'
	icon_state = "lemon0"
	var/list/icon_states = list("lemon0", "lemon1", "lemon2", "lemon3")

/obj/structure/flora/tree/fruit/lemon/style_2
	icon_state = "lemon1"

/obj/structure/flora/tree/fruit/lemon/style_3
	icon_state = "lemon2"

/obj/structure/flora/tree/fruit/lemon/style_4
	icon_state = "lemon3"

/obj/structure/flora/tree/fruit/lemon/style_random/Initialize(mapload)
	. = ..()
	icon_state = "lemon[rand(0,3)]"
	update_appearance()

/obj/structure/flora/tree/fruit/lime
	name = "lime tree"
	desc = "A coniferous lime tree."
	icon = 'modular_bandastation/objects/icons/obj/structures/flora/fruit.dmi'
	icon_state = "lime0"
	var/list/icon_states = list("lime0", "lime1", "lime2", "lime3")

/obj/structure/flora/tree/fruit/lime/style_2
	icon_state = "lime1"

/obj/structure/flora/tree/fruit/lime/style_3
	icon_state = "lime2"

/obj/structure/flora/tree/fruit/lime/style_4
	icon_state = "lime3"

/obj/structure/flora/tree/fruit/lime/style_random/Initialize(mapload)
	. = ..()
	icon_state = "lime[rand(0,3)]"
	update_appearance()

/obj/structure/flora/tree/fruit/plum
	name = "plum tree"
	desc = "A coniferous plum tree."
	icon = 'modular_bandastation/objects/icons/obj/structures/flora/fruit.dmi'
	icon_state = "plum0"
	var/list/icon_states = list("plum0", "plum1", "plum2", "plum3")

/obj/structure/flora/tree/fruit/plum/style_2
	icon_state = "plum1"

/obj/structure/flora/tree/fruit/plum/style_3
	icon_state = "plum2"

/obj/structure/flora/tree/fruit/plum/style_4
	icon_state = "plum3"

/obj/structure/flora/tree/fruit/plum/style_random/Initialize(mapload)
	. = ..()
	icon_state = "plum[rand(0,3)]"
	update_appearance()

/obj/structure/flora/tree/fruit/tangerine
	name = "tangerine tree"
	desc = "A coniferous tangerine tree."
	icon = 'modular_bandastation/objects/icons/obj/structures/flora/fruit.dmi'
	icon_state = "tangerine0"
	var/list/icon_states = list("tangerine0", "tangerine1", "tangerine2", "tangerine3")

/obj/structure/flora/tree/fruit/tangerine/style_2
	icon_state = "tangerine1"

/obj/structure/flora/tree/fruit/tangerine/style_3
	icon_state = "tangerine2"

/obj/structure/flora/tree/fruit/tangerine/style_random/Initialize(mapload)
	. = ..()
	icon_state = "tangerine[rand(0,2)]"
	update_appearance()

//Grass Sticks
/obj/structure/flora/grass_sticks
	name = "stick"
	desc = "Watch your step."
	icon = 'modular_bandastation/objects/icons/obj/structures/flora/grass_sticks.dmi'
	icon_state = "stick_1"
	flora_flags = FLORA_HERBAL

/obj/structure/flora/grass_sticks/style_2
	icon_state = "stick_2"

/obj/structure/flora/grass_sticks/style_3
	icon_state = "stick_3"

/obj/structure/flora/grass_sticks/style_4
	icon_state = "stick_4"

/obj/structure/flora/grass_sticks/style_random/Initialize(mapload)
	. = ..()
	icon_state = "stick_[rand(1, 4)]"
	update_appearance()

//Tall Grass
/obj/structure/flora/tall_grass
	name = "tall grass"
	desc = "Thick clumps of grass."
	icon = 'modular_bandastation/objects/icons/obj/structures/flora/grass_sticks.dmi'
	icon_state = "tall_grass_1"
	flora_flags = FLORA_HERBAL

/obj/structure/flora/tall_grass/style_2
	icon_state = "tall_grass_2"

/obj/structure/flora/tall_grass/style_random/Initialize(mapload)
	. = ..()
	icon_state = "tall_grass_[rand(1, 2)]"
	update_appearance()

// Dry Log
/obj/structure/flora/dry_log
	name = "dry log"
	icon_state = "dry_log"
	desc = "A dry log. It's almost rotten."
	icon = 'modular_bandastation/objects/icons/obj/structures/flora/grass_sticks.dmi'
	density = TRUE
	resistance_flags = FLAMMABLE
	harvest_amount_low = 2
	harvest_amount_high = 4
	harvest_message_med = "You finish chopping the log."
	harvest_verb = "chop"
	flora_flags = FLORA_WOODEN
	can_uproot = FALSE
	delete_on_harvest = TRUE

/obj/structure/flora/dry_log/get_potential_products()
	return list(/obj/item/grown/log/tree = 1)

/obj/structure/bigfence
	name = "fence"
	desc = "A chain link fence. Not as effective as a wall, but generally it keeps people out."
	density = TRUE
	anchored = TRUE
	icon = 'modular_bandastation/objects/icons/obj/structures/flora/grass.dmi'
	icon_state = "straight"

/obj/structure/bigfence/corner
	name = "fence corner"
	icon_state = "corner_end"

//Dry Grass
/obj/structure/flora/dry_grass
	name = "dry grass"
	desc = "Dead, dry grass."
	icon = 'modular_bandastation/objects/icons/obj/structures/flora/grass.dmi'
	icon_state = "dry_grass_1"
	flora_flags = FLORA_HERBAL

/obj/structure/flora/dry_grass/style_2
	icon_state = "dry_grass_2"

/obj/structure/flora/dry_grass/style_random/Initialize(mapload)
	. = ..()
	icon_state = "dry_grass_[rand(1, 2)]"
	update_appearance()


/obj/structure/flora/vegetable
	name = "turnip"
	desc = "Watch your step."
	icon = 'modular_bandastation/objects/icons/obj/structures/flora/grass.dmi'
	icon_state = "turnip0"
	flora_flags = FLORA_HERBAL

/obj/structure/flora/vegetable/turnip
	name = "turnip"
	desc = "Watch your step."
	icon_state = "turnip0"

/obj/structure/flora/vegetable/turnip/style_2
	icon_state = "turnip1"

/obj/structure/flora/vegetable/turnip/style_3
	icon_state = "turnip2"

/obj/structure/flora/vegetable/turnip/style_4
	icon_state = "turnip3"

/obj/structure/flora/vegetable/turnip/style_random/Initialize(mapload)
	. = ..()
	icon_state = "turnip[rand(0, 3)]"
	update_appearance()


/obj/structure/flora/vegetable/sunflower
	name = "sunflower"
	desc = "Watch your step."
	icon_state = "sunflower0"

/obj/structure/flora/vegetable/sunflower/style_2
	icon_state = "sunflower1"

/obj/structure/flora/vegetable/sunflower/style_3
	icon_state = "sunflower2"

/obj/structure/flora/vegetable/sunflower/style_4
	icon_state = "sunflower3"

/obj/structure/flora/vegetable/sunflower/style_random/Initialize(mapload)
	. = ..()
	icon_state = "sunflower[rand(0, 3)]"
	update_appearance()


/obj/structure/flora/vegetable/sugarcane
	name = "sugarcane"
	desc = "Watch your step."
	icon_state = "sugarcane0"

/obj/structure/flora/vegetable/sugarcane/style_2
	icon_state = "sugarcane1"

/obj/structure/flora/vegetable/sugarcane/style_3
	icon_state = "sugarcane2"

/obj/structure/flora/vegetable/sugarcane/style_4
	icon_state = "sugarcane3"

/obj/structure/flora/vegetable/sugarcane/style_random/Initialize(mapload)
	. = ..()
	icon_state = "sugarcane[rand(0, 3)]"
	update_appearance()


/obj/structure/flora/vegetable/tomato
	name = "tomato"
	desc = "Watch your step."
	icon_state = "tomato0"

/obj/structure/flora/vegetable/tomato/style_2
	icon_state = "tomato1"

/obj/structure/flora/vegetable/tomato/style_3
	icon_state = "tomato2"

/obj/structure/flora/vegetable/tomato/style_4
	icon_state = "tomato3"

/obj/structure/flora/vegetable/tomato/style_random/Initialize(mapload)
	. = ..()
	icon_state = "tomato[rand(0, 3)]"
	update_appearance()


/obj/structure/flora/vegetable/raspberry
	name = "raspberry"
	desc = "Watch your step."
	icon_state = "raspberry0"

/obj/structure/flora/vegetable/raspberry/style_2
	icon_state = "raspberry1"

/obj/structure/flora/vegetable/raspberry/style_3
	icon_state = "raspberry2"

/obj/structure/flora/vegetable/raspberry/style_4
	icon_state = "raspberry3"

/obj/structure/flora/vegetable/raspberry/style_random/Initialize(mapload)
	. = ..()
	icon_state = "raspberry[rand(0, 3)]"
	update_appearance()



/obj/structure/flora/vegetable/blackberry
	name = "blackberry"
	desc = "Watch your step."
	icon_state = "blackberry0"

/obj/structure/flora/vegetable/blackberry/style_2
	icon_state = "blackberry1"

/obj/structure/flora/vegetable/blackberry/style_3
	icon_state = "blackberry2"

/obj/structure/flora/vegetable/blackberry/style_4
	icon_state = "blackberry3"

/obj/structure/flora/vegetable/blackberry/style_random/Initialize(mapload)
	. = ..()
	icon_state = "blackberry[rand(0, 3)]"
	update_appearance()


/obj/structure/flora/vegetable/strawberry
	name = "strawberry"
	desc = "Watch your step."
	icon_state = "strawberry0"

/obj/structure/flora/vegetable/strawberry/style_2
	icon_state = "strawberry1"

/obj/structure/flora/vegetable/strawberry/style_3
	icon_state = "strawberry2"

/obj/structure/flora/vegetable/strawberry/style_4
	icon_state = "strawberry3"

/obj/structure/flora/vegetable/strawberry/style_random/Initialize(mapload)
	. = ..()
	icon_state = "strawberry[rand(0, 3)]"
	update_appearance()


/obj/structure/flora/vegetable/manabloom
	name = "manabloom"
	desc = "Watch your step."
	icon_state = "manabloom0"

/obj/structure/flora/vegetable/manabloom/style_2
	icon_state = "manabloom1"

/obj/structure/flora/vegetable/manabloom/style_3
	icon_state = "manabloom2"

/obj/structure/flora/vegetable/manabloom/style_4
	icon_state = "manabloom3"

/obj/structure/flora/vegetable/manabloom/style_random/Initialize(mapload)
	. = ..()
	icon_state = "manabloom[rand(0, 3)]"
	update_appearance()


/obj/structure/flora/vegetable/wheat
	name = "wheat"
	desc = "Watch your step."
	icon_state = "wheat0"

/obj/structure/flora/vegetable/wheat/style_2
	icon_state = "wheat1"

/obj/structure/flora/vegetable/wheat/style_3
	icon_state = "wheat2"

/obj/structure/flora/vegetable/wheat/style_4
	icon_state = "wheat3"

/obj/structure/flora/vegetable/wheat/style_random/Initialize(mapload)
	. = ..()
	icon_state = "wheat[rand(0, 3)]"
	update_appearance()


/obj/structure/flora/vegetable/oat0
	name = "oat"
	desc = "Watch your step."
	icon_state = "oat0"

/obj/structure/flora/vegetable/oat/style_2
	icon_state = "oat1"

/obj/structure/flora/vegetable/oat/style_3
	icon_state = "oat2"

/obj/structure/flora/vegetable/oat/style_4
	icon_state = "oat3"

/obj/structure/flora/vegetable/oat/style_random/Initialize(mapload)
	. = ..()
	icon_state = "oat[rand(0, 3)]"
	update_appearance()


/obj/structure/flora/vegetable/berry
	name = "berry"
	desc = "Watch your step."
	icon_state = "berry0"

/obj/structure/flora/vegetable/berry/style_2
	icon_state = "berry1"

/obj/structure/flora/vegetable/berry/style_3
	icon_state = "berry2"

/obj/structure/flora/vegetable/berry/style_4
	icon_state = "berry3"

/obj/structure/flora/vegetable/berry/style_random/Initialize(mapload)
	. = ..()
	icon_state = "berry[rand(0, 3)]"
	update_appearance()


/obj/structure/flora/vegetable/fyritius
	name = "fyritius"
	desc = "Watch your step."
	icon_state = "fyritius0"

/obj/structure/flora/vegetable/fyritius/style_2
	icon_state = "fyritius1"

/obj/structure/flora/vegetable/fyritius/style_3
	icon_state = "fyritius2"

/obj/structure/flora/vegetable/fyritius/style_4
	icon_state = "fyritius3"

/obj/structure/flora/vegetable/fyritius/style_random/Initialize(mapload)
	. = ..()
	icon_state = "fyritius[rand(0, 3)]"
	update_appearance()


/obj/structure/flora/vegetable/swampweed
	name = "swampweed"
	desc = "Watch your step."
	icon_state = "swampweed0"

/obj/structure/flora/vegetable/swampweed/style_2
	icon_state = "swampweed1"

/obj/structure/flora/vegetable/swampweed/style_3
	icon_state = "swampweed2"

/obj/structure/flora/vegetable/swampweed/style_4
	icon_state = "swampweed3"

/obj/structure/flora/vegetable/swampweed/style_random/Initialize(mapload)
	. = ..()
	icon_state = "swampweed[rand(0, 3)]"
	update_appearance()


/obj/structure/flora/vegetable/westleach
	name = "westleach"
	desc = "Watch your step."
	icon_state = "westleach0"

/obj/structure/flora/vegetable/westleach/style_2
	icon_state = "westleach1"

/obj/structure/flora/vegetable/westleach/style_3
	icon_state = "westleach2"

/obj/structure/flora/vegetable/westleach/style_4
	icon_state = "westleach3"

/obj/structure/flora/vegetable/westleach/style_random/Initialize(mapload)
	. = ..()
	icon_state = "westleach[rand(0, 3)]"
	update_appearance()


/obj/structure/flora/vegetable/potato
	name = "potato"
	desc = "Watch your step."
	icon_state = "potato0"

/obj/structure/flora/vegetable/potato/style_2
	icon_state = "potato1"

/obj/structure/flora/vegetable/potato/style_3
	icon_state = "potato2"

/obj/structure/flora/vegetable/potato/style_4
	icon_state = "potato3"

/obj/structure/flora/vegetable/potato/style_random/Initialize(mapload)
	. = ..()
	icon_state = "potato[rand(0, 3)]"
	update_appearance()


/obj/structure/flora/vegetable/potato
	name = "onion"
	desc = "Watch your step."
	icon_state = "onion0"

/obj/structure/flora/vegetable/onion/style_2
	icon_state = "onion1"

/obj/structure/flora/vegetable/onion/style_3
	icon_state = "onion2"

/obj/structure/flora/vegetable/onion/style_4
	icon_state = "onion3"

/obj/structure/flora/vegetable/onion/style_random/Initialize(mapload)
	. = ..()
	icon_state = "onion[rand(0, 3)]"
	update_appearance()


/obj/structure/flora/vegetable/cabbage
	name = "cabbage"
	desc = "Watch your step."
	icon_state = "cabbage0"

/obj/structure/flora/vegetable/cabbage/style_2
	icon_state = "cabbage1"

/obj/structure/flora/vegetable/cabbage/style_3
	icon_state = "cabbage2"

/obj/structure/flora/vegetable/cabbage/style_4
	icon_state = "cabbage3"

/obj/structure/flora/vegetable/cabbage/style_random/Initialize(mapload)
	. = ..()
	icon_state = "cabbage[rand(0, 3)]"
	update_appearance()


/obj/structure/flora/vegetable/poppy
	name = "poppy"
	desc = "Watch your step."
	icon_state = "poppy0"

/obj/structure/flora/vegetable/poppy/style_2
	icon_state = "poppy1"

/obj/structure/flora/vegetable/poppy/style_3
	icon_state = "poppy2"

/obj/structure/flora/vegetable/poppy/style_4
	icon_state = "poppy3"

/obj/structure/flora/vegetable/poppy/style_random/Initialize(mapload)
	. = ..()
	icon_state = "poppy[rand(0, 3)]"
	update_appearance()


/obj/structure/flora/vegetable/olive
	name = "olive"
	desc = "Watch your step."
	icon_state = "olive1"

/obj/structure/flora/vegetable/olive/style_2
	icon_state = "olive2"

/obj/structure/flora/vegetable/olive/style_3
	icon_state = "olive3"

/obj/structure/flora/vegetable/olive/style_random/Initialize(mapload)
	. = ..()
	icon_state = "olive[rand(1, 2)]"
	update_appearance()


/obj/structure/flora/vegetable/nuts
	name = "nuts"
	desc = "Watch your step."
	icon_state = "nuts0"

/obj/structure/flora/vegetable/nuts/style_2
	icon_state = "nuts1"

/obj/structure/flora/vegetable/nuts/style_3
	icon_state = "nuts2"

/obj/structure/flora/vegetable/nuts/style_4
	icon_state = "nuts3"

/obj/structure/flora/vegetable/nuts/style_random/Initialize(mapload)
	. = ..()
	icon_state = "nuts[rand(0, 3)]"
	update_appearance()


/obj/structure/flora/vegetable/rice
	name = "rice"
	desc = "Watch your step."
	icon_state = "rice0"

/obj/structure/flora/vegetable/rice/style_2
	icon_state = "rice1"

/obj/structure/flora/vegetable/rice/style_3
	icon_state = "rice2"

/obj/structure/flora/vegetable/rice/style_4
	icon_state = "rice3"

/obj/structure/flora/vegetable/rice/style_random/Initialize(mapload)
	. = ..()
	icon_state = "rice[rand(0, 3)]"
	update_appearance()


/obj/structure/flora/vegetable/coffee
	name = "coffee"
	desc = "Watch your step."
	icon_state = "coffee0"

/obj/structure/flora/vegetable/coffee/style_2
	icon_state = "coffee1"

/obj/structure/flora/vegetable/coffee/style_3
	icon_state = "coffee2"

/obj/structure/flora/vegetable/coffee/style_4
	icon_state = "coffee3"

/obj/structure/flora/vegetable/coffee/style_random/Initialize(mapload)
	. = ..()
	icon_state = "coffee[rand(0, 3)]"
	update_appearance()


/obj/structure/flora/vegetable/tea
	name = "tea"
	desc = "Watch your step."
	icon_state = "tea0"

/obj/structure/flora/vegetable/tea/style_2
	icon_state = "tea1"

/obj/structure/flora/vegetable/tea/style_3
	icon_state = "tea2"

/obj/structure/flora/vegetable/tea/style_4
	icon_state = "tea3"

/obj/structure/flora/vegetable/tea/style_random/Initialize(mapload)
	. = ..()
	icon_state = "tea[rand(0, 3)]"
	update_appearance()


/obj/structure/flora/vegetable/carrot
	name = "carrot"
	desc = "Watch your step."
	icon_state = "carrot0"

/obj/structure/flora/vegetable/carrot/style_2
	icon_state = "carrot1"

/obj/structure/flora/vegetable/carrot/style_3
	icon_state = "carrot2"

/obj/structure/flora/vegetable/carrot/style_4
	icon_state = "carrot3"

/obj/structure/flora/vegetable/carrot/style_random/Initialize(mapload)
	. = ..()
	icon_state = "carrot[rand(0, 3)]"
	update_appearance()


/obj/structure/flora/vegetable/eggplant
	name = "eggplant"
	desc = "Watch your step."
	icon_state = "eggplant0"

/obj/structure/flora/vegetable/eggplant/style_2
	icon_state = "eggplant1"

/obj/structure/flora/vegetable/eggplant/style_3
	icon_state = "eggplant2"

/obj/structure/flora/vegetable/eggplant/style_4
	icon_state = "eggplant3"

/obj/structure/flora/vegetable/eggplant/style_random/Initialize(mapload)
	. = ..()
	icon_state = "eggplant[rand(0, 3)]"
	update_appearance()



/obj/structure/flora/vegetable/pumpkin
	name = "pumpkin"
	desc = "Watch your step."
	icon_state = "pumpkin0"

/obj/structure/flora/vegetable/pumpkin/style_2
	icon_state = "pumpkin1"

/obj/structure/flora/vegetable/pumpkin/style_3
	icon_state = "pumpkin2"

/obj/structure/flora/vegetable/pumpkin/style_4
	icon_state = "pumpkin3"

/obj/structure/flora/vegetable/pumpkin/style_random/Initialize(mapload)
	. = ..()
	icon_state = "pumpkin[rand(0, 3)]"
	update_appearance()

//Tall Grass
/obj/structure/flora/tall_grass
	name = "tall grass"
	desc = "Thick clumps of grass."
	icon = 'modular_bandastation/objects/icons/obj/structures/flora/grass_sticks.dmi'
	icon_state = "tall_grass_1"
	flora_flags = FLORA_HERBAL

/obj/structure/flora/tall_grass/style_2
	icon_state = "tall_grass_2"

/obj/structure/flora/tall_grass/style_random/Initialize(mapload)
	. = ..()
	icon_state = "tall_grass_[rand(1, 2)]"
	update_appearance()
