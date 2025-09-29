
// Как выставлять контроллер:
//	ai_controller = /datum/ai_controller/basic_controller/base_animal

// =========== Базовый контроллер животного ===========
/datum/ai_controller/basic_controller/base_animal
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_traits = PASSIVE_AI_FLAGS
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/random_speech/base_animal,	// - что будет говорить и показывает в качестве эмоций
	)

/datum/ai_planning_subtree/random_speech/base_animal
	speech_chance = 3
	speak = list("Вэх!", "Вэх.") // Что говорит
	emote_hear = list("говорит.") // Что показывается когда говорит
	emote_see = list("трясет головой.", "гонится за хвостом.", "пялится.", "озирается.") // Случайная эмоция

// =========== Петух ===========
/datum/ai_controller/basic_controller/chicken/cock
	planning_subtrees = list(
		// Addition subtrees
		/datum/ai_planning_subtree/capricious_retaliate, // Capricious like Capra, get it?
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,

		// Parent subtrees
		// /datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,	// no flee anymore
		// /datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/random_speech/chicken,
	)

// =========== Опоссум ===========
/datum/ai_controller/basic_controller/possum
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_traits = DEFAULT_AI_FLAGS | STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/capricious_retaliate, // Capricious like Capra, get it?
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/find_food,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/random_speech/possum,
	)

/datum/ai_planning_subtree/random_speech/possum
	speech_chance = 3
	emote_hear = list("Хсаааа!", "Хссс!")
	emote_see = list("трясет головой.", "гонится за хвостом.", "пялится.", "озирается.")
	speak = list("Хссс...", "Хиссс...")

// =========== Большие ящерицы ===========
/datum/ai_controller/basic_controller/lizard/big
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_traits = DEFAULT_AI_FLAGS | STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity, // Нельзя запереть, попытается выбраться
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/random_speech/lizard/big,
	)

/datum/ai_planning_subtree/random_speech/lizard/big
	speech_chance = 1
	speak = list("ГРРР!", "Гррр!", "Рыр!", "Грх!")
	emote_hear = list("рычит.", "ворчит.", "грохочет.")
	emote_see = list("топает.", "свирепо пялится.")

// =========== ... ===========

// =========== ... ===========

// =========== ... ===========

// =========== ... ===========
