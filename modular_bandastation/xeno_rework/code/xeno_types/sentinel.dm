/// banda MODULE banda_XENO_REDO

/mob/living/carbon/alien/adult/banda/sentinel
	name = "alien sentinel"
	desc = "Чужой, который был бы неприметным, если бы не яркая окраска и видимые кислотные железы, покрывающие его тело."
	caste = "sentinel"
	maxHealth = 200
	health = 200
	icon_state = "aliensentinel"
	melee_damage_lower = 10
	melee_damage_upper = 15
	next_evolution = /mob/living/carbon/alien/adult/banda/spitter

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
		ORGAN_SLOT_XENO_NEUROTOXINGLAND = /obj/item/organ/alien/neurotoxin/sentinel,
	)

/mob/living/carbon/alien/adult/banda/sentinel/Initialize(mapload)
	. = ..()

	add_movespeed_modifier(/datum/movespeed_modifier/alien_slow)

/mob/living/carbon/alien/adult/banda/sentinel/add_tts_component()
	AddComponent(/datum/component/tts_component, /datum/tts_seed/silero/tracer)

/datum/action/cooldown/alien/acid/banda
	name = "Spit Neurotoxin"
	desc = "Выплёвывает нейротоксин в цель, изнуряя её."
	button_icon = 'modular_bandastation/xeno_rework/icons/xeno_actions.dmi'
	button_icon_state = "neurospit_0"
	plasma_cost = 40
	/// A singular projectile? Use this one and leave acid_casing null
	var/acid_projectile = /obj/projectile/neurotoxin/banda
	/// You want it to be more like a shotgun style attack? Use this one and make acid_projectile null
	var/acid_casing
	/// Used in to_chat messages to the owner
	var/projectile_name = "neurotoxin"
	/// The base icon for the ability, so a red box can be put on it using _0 or _1
	var/button_base_icon = "neurospit"
	/// The sound that should be played when the xeno actually spits
	var/spit_sound = 'modular_bandastation/xeno_rework/sound/alien_spitacid.ogg'
	shared_cooldown = MOB_SHARED_COOLDOWN_3
	cooldown_time = 5 SECONDS

/datum/action/cooldown/alien/acid/banda/IsAvailable(feedback = FALSE)
	return ..() && isturf(owner.loc)

/datum/action/cooldown/alien/acid/banda/set_click_ability(mob/on_who)
	. = ..()
	if(!.)
		return

	to_chat(on_who, span_notice("Вы подготавливаете свою железу [projectile_name]. <B>Левый клик, чтобы выстрелить по цели!</B>"))

	button_icon_state = "[button_base_icon]_1"
	build_all_button_icons()
	on_who.update_icons()

/datum/action/cooldown/alien/acid/banda/unset_click_ability(mob/on_who, refund_cooldown = TRUE)
	. = ..()
	if(!.)
		return

	if(refund_cooldown)
		to_chat(on_who, span_notice("Вы опустошаете свою железу [projectile_name]."))

	button_icon_state = "[button_base_icon]_0"
	build_all_button_icons()
	on_who.update_icons()

/datum/action/cooldown/alien/acid/banda/InterceptClickOn(mob/living/clicker, params, atom/target)
	. = ..()
	if(!.)
		unset_click_ability(clicker, refund_cooldown = FALSE)
		return FALSE

	var/turf/user_turf = clicker.loc
	var/turf/target_turf = get_step(clicker, target.dir)
	if(!isturf(target_turf))
		return FALSE

	var/modifiers = params2list(params)
	clicker.visible_message(
		span_danger("[clicker] выплёвывает [projectile_name]!"),
		span_alertalien("Вы выплёвываете [projectile_name]."),
	)

	if(acid_projectile)
		var/obj/projectile/spit_projectile = new acid_projectile(clicker.loc)
		spit_projectile.aim_projectile(target, clicker, modifiers)
		spit_projectile.firer = clicker
		spit_projectile.fire()
		playsound(clicker, spit_sound, 70, TRUE, 5, 0.9)
		clicker.newtonian_move(get_dir(target_turf, user_turf))
		return TRUE

	if(acid_casing)
		var/obj/item/ammo_casing/casing = new acid_casing(clicker.loc)
		playsound(clicker, spit_sound, 70, TRUE, 5, 0.9)
		casing.fire_casing(target, clicker, null, null, null, ran_zone(), 0, clicker)
		clicker.newtonian_move(get_dir(target_turf, user_turf))
		return TRUE

	CRASH("Для плевательной атаки [clicker] не заданы ни acid_projectile, ни acid_casing!")

/datum/action/cooldown/alien/acid/banda/Activate(atom/target)
	return TRUE

/obj/projectile/neurotoxin/banda
	name = "neurotoxin spit"
	icon_state = "neurotoxin"
	damage = 30
	paralyze = 0
	damage_type = STAMINA
	armor_flag = BIO

/obj/projectile/neurotoxin/on_hit(atom/target, blocked = 0, pierce_hit)
	if(isalien(target))
		damage = 0
	return ..()

/datum/action/cooldown/alien/acid/banda/lethal
	name = "Spit Acid"
	desc = "Выплёвывает нейротоксин в цель, обжигая её."
	acid_projectile = /obj/projectile/neurotoxin/banda/acid
	button_icon_state = "acidspit_0"
	projectile_name = "acid"
	button_base_icon = "acidspit"

/obj/projectile/neurotoxin/banda/acid
	name = "acid spit"
	icon_state = "toxin"
	damage = 20
	paralyze = 0
	damage_type = BURN

/obj/item/organ/alien/neurotoxin/sentinel
	name = "neurotoxin gland"
	icon_state = "neurotox"
	zone = BODY_ZONE_PRECISE_MOUTH
	slot = ORGAN_SLOT_XENO_NEUROTOXINGLAND
	actions_types = list(
		/datum/action/cooldown/alien/acid/banda,
		/datum/action/cooldown/alien/acid/banda/lethal,
	)
