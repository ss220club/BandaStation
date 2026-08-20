// ==========================================
// MOB HOOKS & RESISTANCE CHECKS
// ==========================================

/mob/living/proc/affects_vampire(mob/user)
	// Other vampires and thralls aren't affected
	if(mind?.has_antag_datum(/datum/antagonist/vampire) || mind?.has_antag_datum(/datum/antagonist/mindslave/thrall))
		return FALSE

	// Chaplains with their null rod can block a full power vampire
	if(can_block_magic(MAGIC_RESISTANCE_HOLY) && HAS_TRAIT(mind, TRAIT_HOLY))
		return FALSE

	// Vampires who have reached their full potential can affect nearly everything
	var/datum/antagonist/vampire/vamp = user?.mind?.has_antag_datum(/datum/antagonist/vampire)
	if(vamp?.get_ability(/datum/vampire_passive/full))
		return TRUE

	// Holy characters are resistant to vampire powers
	if(HAS_TRAIT(mind, TRAIT_HOLY) || can_block_magic(MAGIC_RESISTANCE_HOLY))
		return FALSE

	return TRUE


// ==========================================
// BASE VAMPIRE SPELL
// ==========================================

/datum/action/cooldown/spell/vampire
	button_icon_state = "bg_vampire"
	background_icon_state = "bg_vampire"
	spell_requirements = SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_MIND | SPELL_REQUIRES_NO_ANTIMAGIC
	antimagic_flags = MAGIC_RESISTANCE_HOLY

	/// How much blood this ability costs to use
	var/required_blood = 0
	/// Whether blood is automatically deducted on a successful cast
	var/deduct_blood_on_cast = TRUE

/datum/action/cooldown/spell/vampire/can_cast_spell(mob/living/caster = owner)
	. = ..()
	if(!.)
		return FALSE

	if(required_blood > 0)
		var/datum/antagonist/vampire/vamp = caster.mind?.has_antag_datum(/datum/antagonist/vampire)
		if(!vamp || vamp.bloodusable < required_blood)
			to_chat(caster, span_warning("You do not have enough blood stored to cast this!"))
			return FALSE

	return TRUE

/datum/action/cooldown/spell/vampire/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	if(deduct_blood_on_cast && required_blood > 0 && isliving(owner))
		var/mob/living/caster = owner
		var/datum/antagonist/vampire/vamp = caster.mind?.has_antag_datum(/datum/antagonist/vampire)
		vamp?.remove_blood(required_blood)


// ==========================================
// REJUVENATE (SELF)
// ==========================================

/datum/action/cooldown/spell/vampire/rejuvenate
	name = "Rejuvenate"
	desc = "Use reserve blood to enliven your body, removing any incapacitating effects."
	button_icon_state = "vampire_rejuvinate"
	cooldown_time = 20 SECONDS
	check_flags = NONE
	stat_allowed = UNCONSCIOUS
	spell_requirements = SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_MIND
	antimagic_flags = NONE // Null rods shouldn't prevent removing stuns

/datum/action/cooldown/spell/vampire/rejuvenate/cast(mob/living/cast_on = owner)
	. = ..()
	var/mob/living/caster = cast_on

	caster.set_paralyzed(0)
	caster.set_stun(0)
	caster.set_knocked_down(0)
	caster.set_resting(FALSE, silent = TRUE)
	caster.set_confusion(0)
	caster.set_dizziness(0)
	caster.adjust_stamina(-100)
	SEND_SIGNAL(caster, COMSIG_LIVING_CLEAR_STUNS)

	to_chat(caster, span_notice("You instill your body with clean blood and remove any incapacitating effects."))

	var/datum/antagonist/vampire/vamp = caster.mind?.has_antag_datum(/datum/antagonist/vampire)
	for(var/datum/disease/zombie/zombie_infection in caster.diseases)
		zombie_infection.stage = min(zombie_infection.stage, round(7 - (vamp.bloodtotal / 100)))
		if(zombie_infection.stage <= 0)
			zombie_infection.cure()
			to_chat(caster, span_notice("You cleanse the plague from your system."))
		else
			to_chat(caster, span_warning("You weaken the plague in your system, but lack the blood to completely remove it."))

	var/rejuv_bonus = vamp?.get_rejuv_bonus()
	if(rejuv_bonus)
		INVOKE_ASYNC(src, PROC_REF(heal), caster, rejuv_bonus)

/datum/action/cooldown/spell/vampire/rejuvenate/proc/heal(mob/living/caster, rejuv_bonus)
	for(var/i in 1 to 5)
		if(QDELETED(caster))
			return
		caster.adjustBruteLoss(-2 * rejuv_bonus)
		caster.adjustOxyLoss(-5 * rejuv_bonus)
		caster.adjustToxLoss(-2 * rejuv_bonus)
		caster.adjustFireLoss(-2 * rejuv_bonus)
		if(caster.reagents)
			for(var/datum/reagent/reagent as anything in caster.reagents.reagent_list)
				if(!reagent.harmless)
					caster.reagents.remove_reagent(reagent.type, 2 * rejuv_bonus)
		sleep(3.5 SECONDS)

/datum/antagonist/vampire/proc/get_rejuv_bonus()
	if(!get_ability(/datum/vampire_passive/regen))
		return 0
	if(subclass?.improved_rejuv_healing)
		return clamp((100 - owner.current.health) / 20, 1, 5)
	return 1


// ==========================================
// EXFILTRATE (CHALICE)
// ==========================================

/datum/action/cooldown/spell/vampire/exfiltrate
	name = "Conjure Blood Chalice"
	desc = "Congeal blood into a chalice that will generate a portal away from the station."
	button_icon = 'icons/obj/items.dmi'
	button_icon_state = "blood-chalice"
	cooldown_time = 2 SECONDS
	var/used = FALSE

/datum/action/cooldown/spell/vampire/exfiltrate/cast(mob/living/cast_on = owner)
	. = ..()
	if(used)
		to_chat(cast_on, span_warning("You have already attempted to create a blood chalice!"))
		return
	var/datum/antagonist/vampire/vamp = cast_on.mind?.has_antag_datum(/datum/antagonist/vampire)
	vamp?.prepare_exfiltration(cast_on, /obj/item/wormhole_jaunter/extraction/vampire)
	used = TRUE


// ==========================================
// SPECIALIZATION MENU
// ==========================================

/datum/action/cooldown/spell/vampire/specialize
	name = "Choose Specialization"
	desc = "Choose what sub-class of vampire you want to evolve into."
	button_icon_state = "select_class"
	cooldown_time = 2 SECONDS

/datum/action/cooldown/spell/vampire/specialize/cast(mob/living/cast_on = owner)
	. = ..()
	ui_interact(cast_on)

/datum/action/cooldown/spell/vampire/specialize/ui_state(mob/user)
	return GLOB.always_state

/datum/action/cooldown/spell/vampire/specialize/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SpecMenu", "Specialisation Menu")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/action/cooldown/spell/vampire/specialize/ui_data(mob/user)
	var/datum/antagonist/vampire/vamp = user.mind?.has_antag_datum(/datum/antagonist/vampire)
	return list("subclasses" = vamp?.subclass)

/datum/action/cooldown/spell/vampire/specialize/ui_act(action, list/params)
	if(..())
		return TRUE
	var/datum/antagonist/vampire/vamp = usr.mind?.has_antag_datum(/datum/antagonist/vampire)
	if(!vamp)
		return TRUE

	if(vamp.subclass)
		vamp.upgrade_tiers -= type
		vamp.remove_ability(src)
		return TRUE

	switch(action)
		if("umbrae")
			vamp.add_subclass(SUBCLASS_UMBRAE)
		if("hemomancer")
			vamp.add_subclass(SUBCLASS_HEMOMANCER)
		if("gargantua")
			vamp.add_subclass(SUBCLASS_GARGANTUA)
		if("dantalion")
			vamp.add_subclass(SUBCLASS_DANTALION)

	vamp.upgrade_tiers -= type
	vamp.remove_ability(src)
	return TRUE

/datum/antagonist/vampire/proc/add_subclass(subclass_to_add, announce = TRUE, log_choice = TRUE)
	var/datum/vampire_subclass/new_subclass = new subclass_to_add
	subclass = new_subclass
	check_vampire_upgrade(announce)
	if(log_choice)
		SSblackbox.record_feedback("nested tally", "vampire_subclasses", 1, list("[new_subclass.name]"))

	for(var/datum/objective/specialization/objective in owner.get_all_objectives())
		objective.update_explanation_text()


// ==========================================
// GLARE (AOE / CHARGES)
// ==========================================

#define DEVIATION_NONE 3
#define DEVIATION_PARTIAL 2
#define DEVIATION_FULL 1

/datum/action/cooldown/spell/aoe/charges/vampire/glare
	name = "Glare"
	desc = "Your eyes flash, stunning and silencing anyone in front of you."
	button_icon_state = "vampire_glare"
	cooldown_time = 30 SECONDS
	charge_recovery_time = 30 SECONDS
	max_charges = 2
	aoe_radius = 1
	stat_allowed = UNCONSCIOUS

/datum/action/cooldown/spell/aoe/charges/vampire/glare/cast(list/targets, mob/living/caster = owner)
	. = ..()
	if(ishuman(caster))
		var/mob/living/carbon/human/human_caster = caster
		if(istype(human_caster.glasses, /obj/item/clothing/glasses/sunglasses/blindfold))
			var/obj/item/clothing/glasses/sunglasses/blindfold/blindfold = human_caster.glasses
			if(blindfold.tint)
				to_chat(caster, span_warning("You're blindfolded!"))
				return

	caster.set_light(3, 1, LIGHT_COLOR_BLOOD_MAGIC)
	addtimer(CALLBACK(caster, TYPE_PROC_REF(/mob/living, set_light), 0), 2 SECONDS)
	caster.visible_message(span_warning("[caster]'s eyes emit a blinding flash!"))

	for(var/mob/living/target in targets)
		if(target == caster || !target.affects_vampire(caster))
			continue

		var/deviation = (caster.body_position == LYING_DOWN) ? DEVIATION_PARTIAL : calculate_deviation(target, caster)

		switch(deviation)
			if(DEVIATION_FULL)
				target.set_confusion(6 SECONDS)
				target.apply_damage(20, STAMINA)
			if(DEVIATION_PARTIAL)
				target.set_knocked_down(5 SECONDS)
				target.set_confusion(6 SECONDS)
				target.apply_damage(40, STAMINA)
			else
				target.set_confusion(10 SECONDS)
				target.apply_damage(70, STAMINA)
				target.set_knocked_down(12 SECONDS)
				target.adjust_silence(8 SECONDS)
				target.flash_act(1, TRUE, TRUE)

		to_chat(target, span_warning("You are blinded by [caster]'s glare."))
		log_combat(caster, target, "glared at (vampire)")

/datum/action/cooldown/spell/aoe/charges/vampire/glare/proc/calculate_deviation(mob/victim, mob/attacker)
	var/attacker_to_victim = get_dir(attacker, victim)
	var/attacker_dir = attacker.dir

	if(attacker_dir & attacker_to_victim)
		return DEVIATION_NONE
	if(victim.loc == attacker.loc)
		return DEVIATION_NONE
	if(attacker_dir & REVERSE_DIR(attacker_to_victim))
		return DEVIATION_FULL
	return DEVIATION_PARTIAL

#undef DEVIATION_NONE
#undef DEVIATION_PARTIAL
#undef DEVIATION_FULL


// ==========================================
// LAIR (POINTED)
// ==========================================

/datum/action/cooldown/spell/pointed/vampire/lair
	name = "Lair"
	desc = "Pick a coffin for yourself, the centerpiece of your new lair."
	button_icon = 'icons/obj/closet.dmi'
	button_icon_state = "coffin"
	cooldown_time = 2 SECONDS
	cast_range = 1

/datum/action/cooldown/spell/pointed/vampire/lair/is_valid_target(atom/target)
	. = ..()
	if(!.)
		return FALSE
	return istype(target, /obj/structure/closet/coffin)

/datum/action/cooldown/spell/pointed/vampire/lair/cast(obj/structure/closet/coffin/target_coffin, mob/living/caster = owner)
	. = ..()
	if(!istype(target_coffin))
		to_chat(caster, span_warning("This only works on coffins!"))
		return
	if(istype(target_coffin, /obj/structure/closet/coffin/vampire))
		to_chat(caster, span_warning("This coffin serves another and refuses to bend to your will!"))
		return
	if(istype(target_coffin, /obj/structure/closet/coffin/sarcophagus))
		to_chat(caster, span_warning("Making such a lavish lair would likely upset an ancient. You should use a wooden coffin for now."))
		return

	for(var/turf/turf in range(1, target_coffin))
		if(turf.density)
			to_chat(caster, span_warning("You need more space around the coffin for the ritual!"))
			return

	to_chat(caster, span_danger("You begin marking the coffin!"))
	target_coffin.Beam(caster, icon_state = "drainbeam", maxdistance = 1, time = 10 SECONDS)
	playsound(target_coffin, 'sound/misc/enter_blood.ogg', 20)

	for(var/obj/machinery/light/light in range(5, caster))
		light.forced_flicker()

	var/obj/effect/lair_rune/rune = new /obj/effect/lair_rune(get_turf(target_coffin), caster)
	if(!do_after(caster, 10 SECONDS, target = target_coffin))
		qdel(rune)
		return

	playsound(caster, 'sound/hallucinations/im_here1.ogg', 30)
	new /obj/structure/closet/coffin/vampire(get_turf(target_coffin), caster)
	qdel(target_coffin)

	var/datum/antagonist/vampire/vamp = caster.mind?.has_antag_datum(/datum/antagonist/vampire)
	if(vamp)
		vamp.has_lair = TRUE
		vamp.upgrade_tiers -= type
		vamp.remove_ability(src)

/obj/effect/lair_rune
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = FLOOR_PLANE
	layer = SIGIL_LAYER
	icon = 'icons/effects/96x96.dmi'
	icon_state = "vampiric_rune"
	pixel_x = -34
	pixel_y = -38

/obj/effect/lair_rune/Initialize(mapload, mob/living/carbon/human/user)
	. = ..()
	if(istype(user) && user.dna?.species)
		color = user.dna.species.blood_color


// ==========================================
// RAISE VAMPIRES (AOE)
// ==========================================

/datum/action/cooldown/spell/aoe/vampire/raise_vampires
	name = "Raise Vampires"
	desc = "Summons deadly vampires from bluespace."
	button_icon_state = "revive_thrall"
	sound = 'sound/magic/wandodeath.ogg'
	cooldown_time = 20 SECONDS
	aoe_radius = 3
	invocation_type = INVOCATION_NONE

/datum/action/cooldown/spell/aoe/vampire/raise_vampires/cast(list/targets, mob/living/caster = owner)
	. = ..()
	new /obj/effect/temp_visual/cult/sparks(caster.loc)
	var/turf/caster_turf = get_turf(caster)
	to_chat(caster, span_warning("You call out within bluespace, summoning more vampiric spirits to aid you!"))

	for(var/mob/living/carbon/human/target_human in targets)
		if(target_human == caster)
			continue
		caster_turf.Beam(target_human, "sendbeam", 'icons/effects/effects.dmi', time = 3 SECONDS, maxdistance = 7)
		new /obj/effect/temp_visual/cult/sparks(target_human.loc)
		raise_vampire(caster, target_human)

/datum/action/cooldown/spell/aoe/vampire/raise_vampires/proc/raise_vampire(mob/living/caster, mob/living/carbon/human/target_human)
	if(!target_human.mind)
		target_human.visible_message("[target_human] looks to be too stupid to understand what is going on.")
		return

	if(HAS_TRAIT(target_human, TRAIT_NOBLOOD) || !target_human.blood_volume)
		target_human.visible_message("[target_human] looks unfazed!")
		return

	if(target_human.mind.has_antag_datum(/datum/antagonist/vampire) || target_human.mind.has_antag_datum(/datum/antagonist/mindslave/thrall))
		target_human.visible_message(span_notice("[target_human] looks refreshed!"))
		target_human.adjustBruteLoss(-60)
		target_human.adjustFireLoss(-60)
		for(var/datum/wound/wound as anything in target_human.all_wounds)
			if(prob(25))
				wound.remove_wound()
		return

	if(target_human.stat != DEAD)
		if(target_human.body_position == LYING_DOWN)
			target_human.visible_message(span_warning("[target_human] looks to be in pain!"))
			target_human.adjustOrganLoss(ORGAN_SLOT_BRAIN, 60)
		else
			target_human.visible_message(span_warning("[target_human] looks to be stunned by the energy!"))
			target_human.set_knocked_down(40 SECONDS)
		return

	for(var/obj/item/implant/mindshield/implant in target_human.implants)
		qdel(implant)

	target_human.visible_message(span_warning("[target_human] gets an eerie red glow in their eyes!"))

	var/datum/objective/protect/protect_objective = new
	protect_objective.target = caster.mind
	protect_objective.explanation_text = "Protect [caster.real_name]."
	target_human.mind.add_objective(protect_objective)

	log_combat(caster, target_human, "vampire-sired")
	target_human.mind.add_antag_datum(/datum/antagonist/vampire)
	target_human.revive(full_heal_flags = HEAL_ALL)
	target_human.set_knocked_down(40 SECONDS)


// ==========================================
// VAMPIRE PASSIVES
// ==========================================

/datum/vampire_passive
	var/gain_desc
	var/mob/living/owner = null

/datum/vampire_passive/New()
	..()
	if(!gain_desc)
		gain_desc = "You can now use [src]."

/datum/vampire_passive/Destroy(force, ...)
	owner = null
	return ..()

/datum/vampire_passive/proc/on_apply(datum/antagonist/vampire/vamp)
	owner?.update_sight()

/datum/vampire_passive/regen
	gain_desc = "Your rejuvenation abilities have improved and will now heal you over time when used."

/datum/vampire_passive/vision
	gain_desc = "Your vampiric vision has improved."
	var/lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	var/see_in_dark = 1
	var/vision_flags = SEE_MOBS

/datum/vampire_passive/vision/advanced
	gain_desc = "Your vampiric vision now allows you to see everything in the dark!"
	see_in_dark = 3

/datum/vampire_passive/vision/full
	gain_desc = "Your vampiric vision has reached its full strength!"
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	see_in_dark = 6

/datum/vampire_passive/full
	gain_desc = "You have reached your full potential. You are no longer weak to the effects of anything holy."
