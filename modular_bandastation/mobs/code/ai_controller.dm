
//	ai_controller = /datum/ai_controller/basic_controller/base_animal

// /mob/living/basic/axolotl/Initialize(mapload)
// 	. = ..()
// 	add_traits(list(TRAIT_NODROWN, TRAIT_SWIMMER, TRAIT_VENTCRAWLER_ALWAYS), INNATE_TRAIT)
// 	AddElement(/datum/element/swabable, CELL_LINE_TABLE_AXOLOTL, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

/datum/ai_controller/basic_controller/base_animal
	ai_traits = PASSIVE_AI_FLAGS
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk


