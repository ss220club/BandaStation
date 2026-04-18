/mob/living/basic/junkermoff
	name = "junkermoff"
	desc = "Данное создание, кажется, повидало ужасы не только войны, но и ваших грехов."
	icon = 'modular_bandastation/mobs/icons/animal.dmi'
	icon_state = "junkermoff"
	icon_living = "junkermoff"
	icon_dead = "junkermoff_dead"
	held_state = "junkermoff"
	held_lh = 'modular_bandastation/mobs/icons/inhands/mobs_lefthand.dmi'
	held_rh = 'modular_bandastation/mobs/icons/inhands/mobs_righthand.dmi'
	head_icon = 'modular_bandastation/mobs/icons/inhead/head.dmi'
	butcher_results = list(/obj/item/food/meat/slab/mothroach = 1, /obj/item/stack/sheet/iron = 3)
	mob_biotypes = MOB_ORGANIC|MOB_BUG
	mob_size = MOB_SIZE_SMALL
	mobility_flags = MOBILITY_FLAGS_REST_CAPABLE_DEFAULT
	health = 25
	maxHealth = 25
	speed = 1.25
	gold_core_spawnable = NO_SPAWN
	can_be_held = FALSE

	verb_say = "flutters"
	verb_ask = "flutters inquisitively"
	verb_exclaim = "flutters loudly"
	verb_yell = "flutters loudly"
	response_disarm_continuous = "shoos"
	response_disarm_simple = "shoo"
	response_harm_continuous = "hits"
	response_harm_simple = "hit"
	response_help_continuous = "pats"
	response_help_simple = "pat"

	faction = list(FACTION_NEUTRAL)
	var/max_satiety = 50
	var/moff_satiety = 0
	ai_controller = /datum/ai_controller/basic_controller/mothroach

/mob/living/basic/junkermoff/Initialize(mapload)
	. = ..()
	var/static/list/food_types = typecacheof(list(/obj/item))
	AddElement(/datum/element/basic_eating, food_types = food_types)
	RegisterSignal(src, COMSIG_MOB_PRE_EAT, PROC_REF(on_pre_eat))
	RegisterSignal(src, COMSIG_MOB_ATE, PROC_REF(on_ate))
	ai_controller.set_blackboard_key(BB_BASIC_FOODS, food_types)
	ai_controller.set_blackboard_key(BB_EAT_FOOD_COOLDOWN, 10 SECONDS)
	AddElement(/datum/element/ai_retaliate)
	add_verb(src, /mob/living/proc/toggle_resting)
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

/mob/living/basic/junkermoff/proc/on_pre_eat(datum/source, obj/item/potential_food, mob/living/feeder, list/effect_mult)
	SIGNAL_HANDLER
	var/static/list/blacklist_food_types = list(
		/obj/item/defibrillator/compact/loaded/cmo, /obj/item/reagent_containers/hypospray/cmo,
		/obj/item/disk/nuclear, /obj/item/clothing/suit/hooded/ablative, /obj/item/clothing/suit/armor/reactive/teleport,
		/obj/item/nuke_core_container, /obj/item/disk/computer/hdd_theft, /obj/item/nuke_core/supermatter_sliver,
		/obj/item/aicard, /obj/item/blueprints, /obj/item/blackbox, /obj/item/pipe_dispenser,
		/obj/item/mod/control/pre_equipped/advanced, /obj/item/mod/control/pre_equipped/research,
		/obj/item/mod/control/pre_equipped/safeguard, /obj/item/storage/belt/sheath/sabre, /obj/item/melee/sabre,
		/obj/item/clothing/shoes/magboots/advance, /obj/item/clothing/accessory/medal/gold/captain, /obj/item/tank/jetpack/captain,
		/obj/item/hand_tele, /obj/item/gun/ballistic/shotgun/automatic/combat/compact, /obj/item/gun/energy/e_gun/hos,
		/obj/item/gun/energy/laser/captain, /obj/item/card/id/advanced/gold/captains_spare, /obj/item/mod/control/pre_equipped/magnate,
		/obj/item/card/id/departmental_budget/car, /obj/item/storage/belt/utility/chief, /obj/item/melee/baton/telescopic, /obj/item/melee/baton/nt_cane,
		/obj/item/melee/baton/nt_cane/gun)

	if(is_type_in_list(potential_food, blacklist_food_types))
		return COMSIG_MOB_CANCEL_EAT

	if(!istype(potential_food))
		return COMSIG_MOB_CANCEL_EAT

	var/turf/food_turf = get_turf(potential_food)
	if(!istype(food_turf))
		return COMSIG_MOB_CANCEL_EAT

	if(locate(/obj/structure/table) in food_turf)
		return COMSIG_MOB_CANCEL_EAT

	return NONE

/mob/living/basic/junkermoff/proc/on_ate(datum/source, obj/item/eaten_item, mob/living/feeder)
	SIGNAL_HANDLER

	if(!istype(eaten_item))
		return NONE

	moff_satiety += eaten_item.w_class
	check_satiety()
	return NONE

/mob/living/basic/junkermoff/proc/check_satiety()
	if(moff_satiety <= max_satiety)
		return FALSE

	visible_message(span_danger("[src] раздувается и взрывается на куски!"))
	explosion(src, light_impact_range = 3, heavy_impact_range = 1, flash_range = 2, explosion_cause = src)
	gib(DROP_ALL_REMAINS)
	return TRUE

/mob/living/basic/junkermoff/toggle_resting()
	. = ..()
	if(stat == DEAD)
		return
	if (resting)
		icon_state = "[icon_living]_rest"
	else
		icon_state = "[icon_living]"
	regenerate_icons()

/mob/living/basic/junkermoff/attack_hand(mob/living/carbon/human/user, list/modifiers)
	. = ..()
	if(src.stat == DEAD)
		return
	else
		playsound(loc, 'sound/mobs/humanoids/moth/scream_moth.ogg', 50, TRUE)

/mob/living/basic/junkermoff/attackby(obj/item/attacking_item, mob/living/user, list/modifiers, list/attack_modifiers)
	. = ..()
	if(src.stat == DEAD)
		return
	else
		playsound(loc, 'sound/mobs/humanoids/moth/scream_moth.ogg', 50, TRUE)
