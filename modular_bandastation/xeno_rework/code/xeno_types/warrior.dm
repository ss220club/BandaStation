/// banda MODULE banda_XENO_REDO

/mob/living/carbon/alien/adult/banda/warrior
	name = "alien warrior"
	desc = "Если среди чужих и есть ходячие танки, то этот — один из них, с тяжёлой бронёй и мощными руками, подтверждающими этот статус."
	caste = "warrior"
	maxHealth = 400
	health = 400
	icon_state = "alienwarrior"
	melee_damage_lower = 30
	melee_damage_upper = 35

	default_organ_types_by_slot = list(
		ORGAN_SLOT_BRAIN = /obj/item/organ/brain/alien,
		ORGAN_SLOT_XENO_HIVENODE = /obj/item/organ/alien/hivenode,
		ORGAN_SLOT_TONGUE = /obj/item/organ/tongue/alien,
		ORGAN_SLOT_EYES = /obj/item/organ/eyes/alien,
		ORGAN_SLOT_LIVER = /obj/item/organ/liver/alien,
		ORGAN_SLOT_EARS = /obj/item/organ/ears,
		ORGAN_SLOT_STOMACH = /obj/item/organ/stomach/alien,
		ORGAN_SLOT_XENO_PLASMAVESSEL = /obj/item/organ/alien/plasmavessel,
	)

/mob/living/carbon/alien/adult/banda/warrior/Initialize(mapload)
	. = ..()
	var/static/list/innate_actions = list(
		/datum/action/cooldown/spell/aoe/repulse/xeno/banda_tailsweep,
		/datum/action/cooldown/mob_cooldown/charge/basic_charge/defender,
		/datum/action/cooldown/alien/banda/warrior_agility,
	)
	grant_actions_by_list(innate_actions)

	REMOVE_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

	add_movespeed_modifier(/datum/movespeed_modifier/alien_big)

/mob/living/carbon/alien/adult/banda/warrior/add_tts_component()
	AddComponent(/datum/component/tts_component, /datum/tts_seed/silero/barbarian)

/datum/action/cooldown/alien/banda/warrior_agility
	name = "Agility Mode"
	desc = "Опуститесь на четвереньки, увеличивая скорость за счёт снижения урона и невозможности использовать большинство способностей."
	button_icon_state = "the_speed_is_alot"
	cooldown_time = 1 SECONDS
	can_be_used_always = TRUE
	/// Is the warrior currently running around on all fours?
	var/being_agile = FALSE

/datum/action/cooldown/alien/banda/warrior_agility/Activate()
	. = ..()
	if(!being_agile)
		begin_agility()
		return TRUE
	if(being_agile)
		end_agility()
		return TRUE

/// Handles the visual indication and code activation of the warrior agility ability (say that five times fast)
/datum/action/cooldown/alien/banda/warrior_agility/proc/begin_agility()
	var/mob/living/carbon/alien/adult/banda/agility_target = owner
	agility_target.balloon_alert(agility_target, "agility active")
	to_chat(agility_target, span_danger("Мы опускаемся на четвереньки, позволяя себе двигаться намного быстрее, но теряя возможность использовать большинство способностей."))
	playsound(agility_target, 'modular_bandastation/xeno_rework/sound/alien_hiss.ogg', 79, TRUE, 8, 0.9)
	agility_target.icon_state = "alien[agility_target.caste]_mobility"

	being_agile = TRUE
	agility_target.add_movespeed_modifier(/datum/movespeed_modifier/warrior_agility)
	agility_target.unable_to_use_abilities = TRUE

	agility_target.melee_damage_lower = 15
	agility_target.melee_damage_upper = 20

/// Handles the visual indicators and code side of deactivating the agility ability
/datum/action/cooldown/alien/banda/warrior_agility/proc/end_agility()
	var/mob/living/carbon/alien/adult/banda/agility_target = owner
	agility_target.balloon_alert(agility_target, "agility ended")
	playsound(agility_target, 'modular_bandastation/xeno_rework/sound/alien_roar2.ogg', 70, TRUE, 8, 0.9) //Warrior runs up on all fours, stands upright, screams at you
	agility_target.icon_state = "alien[agility_target.caste]"

	being_agile = FALSE
	agility_target.remove_movespeed_modifier(/datum/movespeed_modifier/warrior_agility)
	agility_target.unable_to_use_abilities = FALSE

	agility_target.melee_damage_lower = initial(agility_target.melee_damage_lower)
	agility_target.melee_damage_upper = initial(agility_target.melee_damage_upper)

/datum/movespeed_modifier/warrior_agility
	multiplicative_slowdown = -2
