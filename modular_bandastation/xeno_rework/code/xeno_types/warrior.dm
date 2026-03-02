/// banda MODULE banda_XENO_REDO

/mob/living/carbon/alien/adult/banda/warrior
	name = "alien warrior"
	desc = "Если среди чужих и есть ходячие танки, то этот — один из них, с тяжёлой бронёй и мощными руками, подтверждающими этот статус."
	caste = "warrior"
	maxHealth = 400
	health = 400
	icon_state = "alienwarrior"
	melee_damage_lower = 15
	melee_damage_upper = 20

	default_organ_types_by_slot = list(
		ORGAN_SLOT_BRAIN = /obj/item/organ/brain/alien,
		ORGAN_SLOT_XENO_HIVENODE = /obj/item/organ/alien/hivenode,
		ORGAN_SLOT_TONGUE = /obj/item/organ/tongue/alien,
		ORGAN_SLOT_EYES = /obj/item/organ/eyes/alien,
		ORGAN_SLOT_LIVER = /obj/item/organ/liver/alien,
		ORGAN_SLOT_EARS = /obj/item/organ/ears,
		ORGAN_SLOT_STOMACH = /obj/item/organ/stomach/alien_banda,
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
