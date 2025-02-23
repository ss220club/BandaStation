/// banda MODULE banda_XENO_REDO

/mob/living/carbon/alien/adult/banda/queen
	name = "alien queen"
	desc = "Исполинская тварь с устрашающей аурой. Пора действовать, а не глазеть."
	caste = "queen"
	maxHealth = 500
	health = 500
	icon_state = "alienqueen"
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
		ORGAN_SLOT_XENO_PLASMAVESSEL = /obj/item/organ/alien/plasmavessel/large/queen,
		ORGAN_SLOT_XENO_RESINSPINNER = /obj/item/organ/alien/resinspinner,
		ORGAN_SLOT_XENO_NEUROTOXINGLAND = /obj/item/organ/alien/neurotoxin/queen,
		ORGAN_SLOT_XENO_EGGSAC = /obj/item/organ/alien/eggsac,
	)

/mob/living/carbon/alien/adult/banda/queen/Initialize(mapload)
	. = ..()
	var/static/list/innate_actions = list(
		/datum/action/cooldown/spell/aoe/repulse/xeno/banda_tailsweep/hard_throwing,
		/datum/action/cooldown/alien/banda/queen_screech,
	)
	grant_actions_by_list(innate_actions)

	ADD_TRAIT(src, TRAIT_NOFIRE, INNATE_TRAIT)
	REMOVE_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

	add_movespeed_modifier(/datum/movespeed_modifier/alien_big)

/mob/living/carbon/alien/adult/banda/queen/add_tts_component()
	AddComponent(/datum/component/tts_component, /datum/tts_seed/silero/alexstraza)

/mob/living/carbon/alien/adult/banda/queen/alien_talk(message, shown_name = name)
	..(message, shown_name, TRUE)

/obj/item/organ/alien/neurotoxin/queen
	name = "neurotoxin gland"
	icon_state = "neurotox"
	zone = BODY_ZONE_PRECISE_MOUTH
	slot = ORGAN_SLOT_XENO_NEUROTOXINGLAND
	actions_types = list(
		/datum/action/cooldown/alien/acid/banda,
		/datum/action/cooldown/alien/acid/banda/lethal,
		/datum/action/cooldown/alien/acid/corrosion,
	)

/mob/living/carbon/alien/adult/banda/queen/death(gibbed)
	if(stat == DEAD)
		return

	for(var/mob/living/carbon/carbon_mob in GLOB.alive_mob_list)
		if(carbon_mob == src)
			continue

		var/obj/item/organ/alien/hivenode/node = carbon_mob.get_organ_by_type(/obj/item/organ/alien/hivenode)

		if(istype(node))
			node.queen_death()

	return ..()

/datum/action/cooldown/alien/banda/queen_screech
	name = "Deafening Screech"
	desc = "Издаёт оглушительный визг, который, вероятно, ненадолго выведет из строя всех слышащих существ вокруг. Перезарядка 5 минут."
	button_icon_state = "screech"
	cooldown_time = 5 MINUTES

/datum/action/cooldown/alien/banda/queen_screech/Activate()
	. = ..()
	var/mob/living/carbon/alien/adult/banda/queenie = owner
	playsound(queenie, 'modular_bandastation/xeno_rework/sound/alien_queen_screech.ogg', 70, FALSE, 8, 0.9)
	queenie.create_shriekwave()
	shake_camera(owner, 2, 2)

	for(var/mob/living/carbon/human/screech_target in get_hearers_in_view(7, get_turf(queenie)))
		screech_target.soundbang_act(intensity = 5, stun_pwr = 50, damage_pwr = 10, deafen_pwr = 30) //Only being deaf will save you from the screech
		shake_camera(screech_target, 4, 3)
		to_chat(screech_target, span_red("[queenie] lets out a deafening screech!"))

	return TRUE

/mob/living/carbon/alien/adult/banda/proc/create_shriekwave()
	remove_overlay(HALO_LAYER)
	overlays_standing[HALO_LAYER] = image("icon" = 'modular_bandastation/xeno_rework/icons/big_xenos.dmi', "icon_state" = "shriek_waves") //Ehh, suit layer's not being used.
	apply_overlay(HALO_LAYER)
	addtimer(CALLBACK(src, PROC_REF(remove_shriekwave)), 3 SECONDS)

/mob/living/carbon/alien/adult/banda/proc/remove_shriekwave()
	remove_overlay(HALO_LAYER)
