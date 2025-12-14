/// banda MODULE banda_XENO_REDO

/mob/living/carbon/alien/adult/banda/runner
	name = "alien runner"
	desc = "Невысокий чужой с гладким красным хитином, явно следующий теореме «красный значит быстрый» и почти всегда передвигающийся на четырёх лапах."
	caste = "runner"
	maxHealth = 200
	health = 200
	icon_state = "alienrunner"
	/// Holds the evade ability to be granted to the runner later
	var/datum/action/cooldown/alien/banda/evade/evade_ability
	melee_damage_lower = 10
	melee_damage_upper = 15
	next_evolution = NONE // /mob/living/carbon/alien/adult/banda/ravager // todo: rebalance ravager
	on_fire_pixel_y = 0

	default_organ_types_by_slot = list(
		ORGAN_SLOT_BRAIN = /obj/item/organ/brain/alien,
		ORGAN_SLOT_XENO_HIVENODE = /obj/item/organ/alien/hivenode,
		ORGAN_SLOT_TONGUE = /obj/item/organ/tongue/alien,
		ORGAN_SLOT_EYES = /obj/item/organ/eyes/alien,
		ORGAN_SLOT_LIVER = /obj/item/organ/liver/alien,
		ORGAN_SLOT_EARS = /obj/item/organ/ears,
		ORGAN_SLOT_STOMACH = /obj/item/organ/stomach/alien_banda,
		ORGAN_SLOT_XENO_PLASMAVESSEL = /obj/item/organ/alien/plasmavessel/small/tiny,
	)

/mob/living/carbon/alien/adult/banda/runner/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/tackler, stamina_cost = 0, base_knockdown = 2, range = 10, speed = 2, skill_mod = 7, min_distance = 0)
	evade_ability = new(src)
	evade_ability.Grant(src)

	add_movespeed_modifier(/datum/movespeed_modifier/alien_quick)

/mob/living/carbon/alien/adult/banda/runner/add_tts_component()
	AddComponent(/datum/component/tts_component, /datum/tts_seed/silero/wendy)

/mob/living/carbon/alien/adult/banda/runner/create_internal_organs()
	organs += new /obj/item/organ/alien/plasmavessel/small/tiny
	..()

/mob/living/carbon/alien/adult/banda/runner/bullet_act(obj/projectile/hitting_projectile, def_zone, piercing_hit = FALSE)
	if(evade_ability)
		var/evade_result = evade_ability.on_projectile_hit()
		if(!(evade_result == BULLET_ACT_HIT))
			return evade_result
	return ..()
