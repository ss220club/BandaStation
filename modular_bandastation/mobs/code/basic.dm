// MARK: Crocodile
/mob/living/basic/crocodile
	name = "crocodile"
	desc = "Клац, клац, клац. Острые зубки, толстая кожа - страшно!"
	icon = 'modular_bandastation/mobs/icons/crocodile.dmi'
	icon_state = "crocodile"
	icon_living = "crocodile"
	icon_dead = "crocodile_dead"
	pixel_x = -8
	pixel_y = -4
	base_pixel_x = -8
	base_pixel_y = -4
	gender = MALE
	butcher_results = list(/obj/item/food/meat/slab = 5)

	response_help_continuous = "гладит"
	response_help_simple = "гладите"
	response_disarm_continuous = "осторожно отодвигает в сторону"
	response_disarm_simple = "осторожно отодвигаете в сторону"

	maxHealth = 250
	health = 250
	combat_mode = TRUE
	mob_size = MOB_SIZE_LARGE
	mob_biotypes = MOB_ORGANIC | MOB_BEAST

	obj_damage = 60
	melee_damage_lower = 15
	melee_damage_upper = 15
	wound_bonus = -5
	exposed_wound_bonus = 10
	sharpness = SHARP_EDGED
	attack_verb_continuous = "кусает"
	attack_verb_simple = "кусаете"
	attack_sound = 'sound/items/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	friendly_verb_continuous = "дружелюбно обвивает хвостом"
	friendly_verb_simple = "дружелюбно обвиваете хвостом"

	speak_emote = list("рычит")

	ai_controller = /datum/ai_controller/basic_controller/crocodile

	var/static/list/food_types = list(
		/obj/item/food/meat,
		/obj/item/food/deadmouse,
		/mob/living/basic/mouse
	)

/mob/living/basic/crocodile/gena
	name = "Gena"
	desc = "Крокодил Гена."

/mob/living/basic/crocodile/Initialize(mapload)
	. = ..()
	add_traits(list(TRAIT_FENCE_CLIMBER), INNATE_TRAIT)
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_CLAW)
	AddElement(/datum/element/nerfed_pulling, GLOB.typecache_general_bad_things_to_easily_move)
	AddElement(/datum/element/basic_eating, heal_amt = 10, food_types = food_types)
	AddComponent(/datum/component/health_scaling_effects, min_health_slowdown = 1.5)
	ai_controller.set_blackboard_key(BB_BASIC_FOODS, typecacheof(food_types))

/mob/living/basic/crocodile/Login()
	. = ..()
	if(!. || !client)
		return FALSE
	AddElement(/datum/element/ridable, /datum/component/riding/creature/crocodile)

// Croco AI
/datum/ai_planning_subtree/random_speech/crocodile
	speech_chance = 5
	sound = list('sound/mobs/humanoids/lizard/lizard_hiss.ogg')
	emote_hear = list("рычит.", "хрипит.", "шипит.")
	emote_see = list("машет хвостом.", "широко раскрывает пасть.")

/datum/ai_controller/basic_controller/crocodile
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/go_for_swim,
		/datum/ai_planning_subtree/find_food,
		/datum/ai_planning_subtree/random_speech/crocodile,
	)

// Croco rideable
/datum/component/riding/creature/crocodile

/datum/component/riding/creature/crocodile/get_rider_offsets_and_layers(pass_index, mob/offsetter)
	return list(
		TEXT_NORTH = list( 0, 8),
		TEXT_SOUTH = list( 0, 8),
		TEXT_EAST =  list(-2, 8),
		TEXT_WEST =  list( 2, 8),
	)

/datum/component/riding/creature/crocodile/get_parent_offsets_and_layers()
	return list(
		TEXT_NORTH = list(0, 0, MOB_BELOW_PIGGYBACK_LAYER),
		TEXT_SOUTH = list(0, 0, MOB_BELOW_PIGGYBACK_LAYER),
		TEXT_EAST =  list(0, 0, MOB_BELOW_PIGGYBACK_LAYER),
		TEXT_WEST =  list(0, 0, MOB_BELOW_PIGGYBACK_LAYER),
	)
