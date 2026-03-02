/// banda MODULE banda_XENO_REDO

/mob/living/carbon/alien/adult/banda/spitter
	name = "alien spitter"
	desc = "Довольно массивный чужой с выраженными кислотными железами, из его рта капает... то ли токсин, то ли кислота."
	caste = "spitter"
	maxHealth = 300
	health = 300
	icon_state = "alienspitter"
	melee_damage_lower = 10
	melee_damage_upper = 15

	default_organ_types_by_slot = list(
		ORGAN_SLOT_BRAIN = /obj/item/organ/brain/alien,
		ORGAN_SLOT_XENO_HIVENODE = /obj/item/organ/alien/hivenode,
		ORGAN_SLOT_TONGUE = /obj/item/organ/tongue/alien,
		ORGAN_SLOT_EYES = /obj/item/organ/eyes/alien,
		ORGAN_SLOT_LIVER = /obj/item/organ/liver/alien,
		ORGAN_SLOT_EARS = /obj/item/organ/ears,
		ORGAN_SLOT_STOMACH = /obj/item/organ/stomach/alien_banda,
		ORGAN_SLOT_XENO_PLASMAVESSEL = /obj/item/organ/alien/plasmavessel,
		ORGAN_SLOT_XENO_NEUROTOXINGLAND = /obj/item/organ/alien/neurotoxin/spitter,
	)

/mob/living/carbon/alien/adult/banda/spitter/Initialize(mapload)
	. = ..()

	add_movespeed_modifier(/datum/movespeed_modifier/alien_heavy)

	REMOVE_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

/mob/living/carbon/alien/adult/banda/spitter/add_tts_component()
	AddComponent(/datum/component/tts_component, /datum/tts_seed/silero/janna)

// MARK: SPITTER UNIQUE ABILITIES

/datum/action/cooldown/alien/acid/banda/spread/spitter
	name = "Spit Neurotoxin Spread"
	desc = "Выплёвывает нейротоксин, истощая противника."
	plasma_cost = 1
	cooldown_time = 1.5 SECONDS

/datum/action/cooldown/alien/acid/banda/spread/lethal/spitter
	name = "Spit Acid Spread"
	desc = "Выплёвывает облако кислоты в цель, обжигая её."
	plasma_cost = 1
	cooldown_time = 1.5 SECONDS

/obj/item/organ/alien/neurotoxin/spitter
	name = "large neurotoxin gland"
	icon_state = "neurotox"
	zone = BODY_ZONE_PRECISE_MOUTH
	slot = ORGAN_SLOT_XENO_NEUROTOXINGLAND
	actions_types = list(
		/datum/action/cooldown/alien/acid/banda/spread/spitter,
		/datum/action/cooldown/alien/acid/banda/spread/lethal/spitter,
		/datum/action/cooldown/alien/acid/corrosion,
	)
