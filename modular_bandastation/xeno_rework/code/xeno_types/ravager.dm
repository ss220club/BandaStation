/// banda MODULE banda_XENO_REDO

#define RAVAGER_OUTLINE_EFFECT "ravager_endure_outline"

/mob/living/carbon/alien/adult/banda/ravager
	name = "alien ravager"
	desc = "Чужой с ярко-красным, словно разъярённым, хитином и устрашающими клинковыми когтями вместо обычных рук. Острый хвост выглядит так, будто удар им будет крайне болезненным."
	caste = "ravager"
	maxHealth = 350
	health = 350
	icon_state = "alienravager"
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

/mob/living/carbon/alien/adult/banda/ravager/Initialize(mapload)
	. = ..()
	var/static/list/innate_actions = list(
		/datum/action/cooldown/spell/aoe/repulse/xeno/banda_tailsweep/slicing,
		/datum/action/cooldown/alien/banda/literally_too_angry_to_die,
		/datum/action/cooldown/mob_cooldown/charge/triple_charge/ravager,
	)
	grant_actions_by_list(innate_actions)

	REMOVE_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

/mob/living/carbon/alien/adult/banda/ravager/add_tts_component()
	AddComponent(/datum/component/tts_component, /datum/tts_seed/silero/zarya)

/datum/action/cooldown/mob_cooldown/charge/triple_charge/ravager
	name = "Triple Charge Attack"
	desc = "Позволяет трижды совершить рывок к указанной точке, растаптывая всех на своём пути. Каждый рывок наносит дополнительный удар рукой, если вы в агресивном режиме"
	cooldown_time = 60 SECONDS
	charge_delay = 0.2 SECONDS
	charge_distance = 7
	charge_past = 3
	destroy_objects = FALSE
	charge_damage = 8
	button_icon = 'modular_bandastation/xeno_rework/icons/xeno_actions.dmi'
	button_icon_state = "ravager_charge"
	unset_after_click = TRUE

/datum/action/cooldown/mob_cooldown/charge/triple_charge/ravager/do_charge_indicator(atom/charger, atom/charge_target)
	playsound(charger, 'modular_bandastation/xeno_rework/sound/alien_roar2.ogg', 70, TRUE, 8, 0.9)

/datum/action/cooldown/mob_cooldown/charge/triple_charge/ravager/Activate(atom/target_atom)
	. = ..()
	return TRUE

/datum/action/cooldown/spell/aoe/repulse/xeno/banda_tailsweep/slicing
	name = "Slicing Tail Sweep"
	desc = "Отбросьте нападающих взмахом хвоста, разрезая их его заострённым кончиком."

	aoe_radius = 2

	button_icon_state = "slice_tail"

	sparkle_path = /obj/effect/temp_visual/dir_setting/tailsweep/ravager

	sound = 'modular_bandastation/xeno_rework/sound/alien_tail_swipe.ogg' //The defender's tail sound isn't changed because its big and heavy, this isn't

	impact_sound = 'modular_bandastation/xeno_rework/sound/bloodyslice.ogg'
	impact_damage = 40
	impact_sharpness = SHARP_EDGED

/obj/effect/temp_visual/dir_setting/tailsweep/ravager
	icon = 'modular_bandastation/xeno_rework/icons/xeno_actions.dmi'
	icon_state = "slice_tail_anim"

/datum/action/cooldown/alien/banda/literally_too_angry_to_die
	name = "Endure"
	desc =  "Наполните своё тело невообразимой яростью (и плазмой), позволяя себе игнорировать всю боль на короткое время."
	button_icon_state = "literally_too_angry"
	plasma_cost = 250 //This requires full plasma to do, so there can be some time between armstrong moments
	/// If the endure ability is currently active or not
	var/endure_active = FALSE
	/// How long the endure ability should last when activated
	var/endure_duration = 20 SECONDS

/datum/action/cooldown/alien/banda/literally_too_angry_to_die/Activate()
	. = ..()
	if(endure_active)
		owner.balloon_alert(owner, "already enduring")
		return FALSE
	owner.balloon_alert(owner, "endure began")
	playsound(owner, 'modular_bandastation/xeno_rework/sound/alien_roar1.ogg', 70, TRUE, 8, 0.9)
	to_chat(owner, span_danger("Мы подавляем способность чувствовать боль, позволяя себе сражаться до самого конца в течение следующих [endure_duration/10] секунд."))
	addtimer(CALLBACK(src, PROC_REF(endure_deactivate)), endure_duration)
	owner.add_filter(RAVAGER_OUTLINE_EFFECT, 4, outline_filter(1, COLOR_RED_LIGHT))
	ADD_TRAIT(owner, TRAIT_STUNIMMUNE, TRAIT_XENO_ABILITY_GIVEN)
	ADD_TRAIT(owner, TRAIT_NOSOFTCRIT, TRAIT_XENO_ABILITY_GIVEN)
	ADD_TRAIT(owner, TRAIT_NOHARDCRIT, TRAIT_XENO_ABILITY_GIVEN)
	endure_active = TRUE
	return TRUE

/datum/action/cooldown/alien/banda/literally_too_angry_to_die/proc/endure_deactivate()
	endure_active = FALSE
	owner.balloon_alert(owner, "endure ended")
	owner.remove_filter(RAVAGER_OUTLINE_EFFECT)
	REMOVE_TRAIT(owner, TRAIT_STUNIMMUNE, TRAIT_XENO_ABILITY_GIVEN)
	REMOVE_TRAIT(owner, TRAIT_NOSOFTCRIT, TRAIT_XENO_ABILITY_GIVEN)
	REMOVE_TRAIT(owner, TRAIT_NOHARDCRIT, TRAIT_XENO_ABILITY_GIVEN)

#undef RAVAGER_OUTLINE_EFFECT
