/// banda MODULE banda_XENO_REDO

/mob/living/carbon/alien/adult/banda/praetorian
	name = "alien praetorian"
	desc = "Чужой, выглядящий как нечто среднее между королевой и дроном — и, вероятно, именно так оно и есть."
	caste = "praetorian"
	maxHealth = 400
	health = 400
	icon_state = "alienpraetorian"
	melee_damage_lower = 25
	melee_damage_upper = 30
	next_evolution = /mob/living/carbon/alien/adult/banda/queen

	default_organ_types_by_slot = list(
		ORGAN_SLOT_BRAIN = /obj/item/organ/brain/alien,
		ORGAN_SLOT_XENO_HIVENODE = /obj/item/organ/alien/hivenode,
		ORGAN_SLOT_TONGUE = /obj/item/organ/tongue/alien,
		ORGAN_SLOT_EYES = /obj/item/organ/eyes/alien,
		ORGAN_SLOT_LIVER = /obj/item/organ/liver/alien,
		ORGAN_SLOT_EARS = /obj/item/organ/ears,
		ORGAN_SLOT_STOMACH = /obj/item/organ/stomach/alien,
		ORGAN_SLOT_XENO_PLASMAVESSEL = /obj/item/organ/alien/plasmavessel/large,
		ORGAN_SLOT_XENO_RESINSPINNER = /obj/item/organ/alien/resinspinner,
		ORGAN_SLOT_XENO_NEUROTOXINGLAND = /obj/item/organ/alien/neurotoxin/spitter,
	)

/mob/living/carbon/alien/adult/banda/praetorian/Initialize(mapload)
	. = ..()
	var/static/list/innate_actions = list(
		/datum/action/cooldown/alien/banda/heal_aura/juiced,
		/datum/action/cooldown/spell/aoe/repulse/xeno/banda_tailsweep/hard_throwing,
	)
	grant_actions_by_list(innate_actions)

	REMOVE_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

	add_movespeed_modifier(/datum/movespeed_modifier/alien_big)

/mob/living/carbon/alien/adult/banda/praetorian/add_tts_component()
	AddComponent(/datum/component/tts_component, /datum/tts_seed/silero/tyrande_hs)

/datum/action/cooldown/alien/banda/heal_aura/juiced
	name = "Strong Healing Aura"
	desc = "Дружественные ксеноморфы в большем радиусе вокруг вас будут получать пассивное исцеление."
	button_icon_state = "healaura_juiced"
	plasma_cost = 100
	cooldown_time = 90 SECONDS
	aura_range = 7
	aura_healing_amount = 10
	aura_healing_color = COLOR_RED_LIGHT

/datum/action/cooldown/spell/aoe/repulse/xeno/banda_tailsweep/hard_throwing
	name = "Flinging Tail Sweep"
	desc = "Размашистый удар хвоста отбрасывает врагов назад с огромной силой."

	aoe_radius = 2
	repulse_force = MOVE_FORCE_OVERPOWERING //Fuck everyone who gets hit by this tail in particular

	button_icon_state = "throw_tail"

	sparkle_path = /obj/effect/temp_visual/dir_setting/tailsweep/praetorian

	impact_sound = 'sound/items/weapons/slap.ogg'
	impact_damage = 20
	impact_wound_bonus = 10

/obj/effect/temp_visual/dir_setting/tailsweep/praetorian
	icon = 'modular_bandastation/xeno_rework/icons/xeno_actions.dmi'
	icon_state = "throw_tail_anim"

/datum/action/cooldown/alien/acid/banda/spread
	name = "Spit Neurotoxin Spread"
	desc = "Выплёвывает нейротоксин, истощая противника."
	plasma_cost = 50
	acid_projectile = null
	acid_casing = /obj/item/ammo_casing/xenospit
	spit_sound = 'modular_bandastation/xeno_rework/sound/alien_spitacid2.ogg'
	cooldown_time = 10 SECONDS

/obj/item/ammo_casing/xenospit //This is probably really bad, however I couldn't find any other nice way to do this
	name = "big glob of neurotoxin"
	projectile_type = /obj/projectile/neurotoxin/banda/spitter_spread
	pellets = 3
	variance = 20

/obj/item/ammo_casing/xenospit/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/caseless)

/obj/item/ammo_casing/xenospit/tk_firing(mob/living/user, atom/fired_from)
	return FALSE

/obj/projectile/neurotoxin/banda/spitter_spread //Slightly nerfed because its a shotgun spread of these
	name = "neurotoxin spit"
	icon_state = "neurotoxin"
	damage = 25

/datum/action/cooldown/alien/acid/banda/spread/lethal
	name = "Spit Acid Spread"
	desc = "Выплёвывает облако кислоты в цель, обжигая её."
	acid_projectile = null
	acid_casing = /obj/item/ammo_casing/xenospit/spread/lethal
	button_icon_state = "acidspit_0"
	projectile_name = "acid"
	button_base_icon = "acidspit"

/obj/item/ammo_casing/xenospit/spread/lethal
	name = "big glob of acid"
	projectile_type = /obj/projectile/neurotoxin/banda/acid/spitter_spread
	pellets = 4
	variance = 30

/obj/projectile/neurotoxin/banda/acid/spitter_spread
	name = "acid spit"
	icon_state = "toxin"
	damage = 15
	damage_type = BURN

/obj/item/organ/alien/neurotoxin/spitter
	name = "large neurotoxin gland"
	icon_state = "neurotox"
	zone = BODY_ZONE_PRECISE_MOUTH
	slot = ORGAN_SLOT_XENO_NEUROTOXINGLAND
	actions_types = list(
		/datum/action/cooldown/alien/acid/banda/spread,
		/datum/action/cooldown/alien/acid/banda/spread/lethal,
		/datum/action/cooldown/alien/acid/corrosion,
	)
