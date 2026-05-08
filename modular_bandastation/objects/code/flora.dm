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
	icon = 'modular_bandastation/objects/icons/obj/flora/tree.dmi'
	icon_state = "pine_tree_stump"

// //Large Pine
// /obj/structure/flora/tree/large_pine
// 	name = "large pine tree"
// 	desc = "A coniferous large pine tree."
// 	icon = 'modular_bandastation/objects/icons/obj/flora/tree.dmi'
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
// 	icon = 'modular_bandastation/aesthetics/flora/icons/tall_trees.dmi'
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
// 	icon = 'modular_bandastation/objects/icons/obj/flora/tree.dmi'
// 	icon_state = "large_tree_stump"

/obj/structure/flora/fruit/apple1
	name = "apple tree"
	desc = "A coniferous apple tree."
	icon = 'modular_bandastation/objects/icons/obj/flora/fruit.dmi'
	icon_state = "apple0"

/obj/structure/flora/fruit/get_seethrough_map()
	return SEE_THROUGH_MAP_DEFAULT_TWO_TALL

/obj/structure/flora/fruit/apple1
	name = "apple tree"
	desc = "A coniferous apple tree."
	icon = 'modular_bandastation/objects/icons/obj/flora/fruit.dmi'
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
