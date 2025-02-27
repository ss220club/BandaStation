/// banda MODULE banda_XENO_REDO

#define EVASION_VENTCRAWL_INABILTY_CD_PERCENTAGE 0.8
#define RUNNER_BLUR_EFFECT "runner_evasion"

/mob/living/carbon/alien/adult/banda/runner
	name = "alien runner"
	desc = "Невысокий чужой с гладким красным хитином, явно следующий теореме «красный значит быстрый» и почти всегда передвигающийся на четырёх лапах."
	caste = "runner"
	maxHealth = 150
	health = 150
	icon_state = "alienrunner"
	/// Holds the evade ability to be granted to the runner later
	var/datum/action/cooldown/alien/banda/evade/evade_ability
	melee_damage_lower = 15
	melee_damage_upper = 20
	next_evolution = /mob/living/carbon/alien/adult/banda/ravager
	on_fire_pixel_y = 0

	default_organ_types_by_slot = list(
		ORGAN_SLOT_BRAIN = /obj/item/organ/brain/alien,
		ORGAN_SLOT_XENO_HIVENODE = /obj/item/organ/alien/hivenode,
		ORGAN_SLOT_TONGUE = /obj/item/organ/tongue/alien,
		ORGAN_SLOT_EYES = /obj/item/organ/eyes/alien,
		ORGAN_SLOT_LIVER = /obj/item/organ/liver/alien,
		ORGAN_SLOT_EARS = /obj/item/organ/ears,
		ORGAN_SLOT_STOMACH = /obj/item/organ/stomach/alien,
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

/datum/action/cooldown/alien/banda/evade
	name = "Evade"
	desc = "Позволяет уклоняться от любых снарядов, которые могли бы попасть в вас, в течение нескольких секунд."
	button_icon_state = "evade"
	plasma_cost = 50
	cooldown_time = 60 SECONDS
	/// If the evade ability is currently active or not
	var/evade_active = FALSE
	/// How long evasion should last
	var/evasion_duration = 10 SECONDS

/datum/action/cooldown/alien/banda/evade/Activate()
	. = ..()
	if(evade_active) //Can't evade while we're already evading.
		owner.balloon_alert(owner, "already evading")
		return FALSE

	owner.balloon_alert(owner, "evasive movements began")
	playsound(owner, 'modular_bandastation/xeno_rework/sound/alien_hiss.ogg', 70, TRUE, 8, 0.9)
	to_chat(owner, span_danger("Мы совершаем уклоняющий манёвр, становясь неуязвимыми для снарядов в течение следующих [evasion_duration / 10] секунд."))
	addtimer(CALLBACK(src, PROC_REF(evasion_deactivate)), evasion_duration)
	evade_active = TRUE
	RegisterSignal(owner, COMSIG_PROJECTILE_ON_HIT, PROC_REF(on_projectile_hit))
	REMOVE_TRAIT(owner, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
	addtimer(CALLBACK(src, PROC_REF(give_back_ventcrawl)), (cooldown_time * EVASION_VENTCRAWL_INABILTY_CD_PERCENTAGE)) //They cannot ventcrawl until the defined percent of the cooldown has passed
	to_chat(owner, span_warning("Мы не сможем ползать по вентиляции в течение следующих [(cooldown_time * EVASION_VENTCRAWL_INABILTY_CD_PERCENTAGE) / 10] секунд."))
	return TRUE

/// Handles deactivation of the xeno evasion ability, mainly unregistering the signal and giving a balloon alert
/datum/action/cooldown/alien/banda/evade/proc/evasion_deactivate()
	evade_active = FALSE
	owner.balloon_alert(owner, "evasion ended")
	UnregisterSignal(owner, COMSIG_PROJECTILE_ON_HIT)

/datum/action/cooldown/alien/banda/evade/proc/give_back_ventcrawl()
	ADD_TRAIT(owner, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
	to_chat(owner, span_notice("Мы достаточно отдохнули и снова можем ползать по вентиляции."))

/// Handles if either BULLET_ACT_HIT or BULLET_ACT_FORCE_PIERCE happens to something using the xeno evade ability
/datum/action/cooldown/alien/banda/evade/proc/on_projectile_hit()
	if(!INCAPACITATED_IGNORING(owner, INCAPABLE_GRAB) || !isturf(owner.loc) || !evade_active)
		return BULLET_ACT_HIT

	owner.visible_message(span_danger("[owner] без труда уклоняется от снаряда!"), span_userdanger("Вы уклоняетесь от снаряда!"))
	playsound(get_turf(owner), pick('sound/items/weapons/bulletflyby.ogg', 'sound/items/weapons/bulletflyby2.ogg', 'sound/items/weapons/bulletflyby3.ogg'), 75, TRUE)
	owner.add_filter(RUNNER_BLUR_EFFECT, 2, gauss_blur_filter(5))
	addtimer(CALLBACK(owner, TYPE_PROC_REF(/datum, remove_filter), RUNNER_BLUR_EFFECT), 0.5 SECONDS)
	return BULLET_ACT_FORCE_PIERCE

/mob/living/carbon/alien/adult/banda/runner/bullet_act(obj/projectile/hitting_projectile, def_zone, piercing_hit = FALSE)
	if(evade_ability)
		var/evade_result = evade_ability.on_projectile_hit()
		if(!(evade_result == BULLET_ACT_HIT))
			return evade_result
	return ..()

#undef EVASION_VENTCRAWL_INABILTY_CD_PERCENTAGE
#undef RUNNER_BLUR_EFFECT
