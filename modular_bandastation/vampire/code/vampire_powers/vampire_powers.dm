//This should hold all the vampire related powers
/mob/living/proc/affects_vampire(mob/user)
	//Other vampires and thralls aren't affected
	if(mind?.has_antag_datum(/datum/antagonist/vampire) || mind?.has_antag_datum(/datum/antagonist/vampire_thrall))
		return FALSE
	/// Chaplains with their nullrod can block a full power vampire, but a chaplain by themselfs or a crew with a null rod can not.
	if(can_block_magic(MAGIC_RESISTANCE_HOLY) && HAS_MIND_TRAIT(src, TRAIT_HOLY))
		return FALSE
	//Vampires who have reached their full potential can affect nearly everything
	var/datum/antagonist/vampire/V = user?.mind.has_antag_datum(/datum/antagonist/vampire)
	if(V?.get_ability(/datum/vampire_passive/full))
		return TRUE
	//Holy characters are resistant to vampire powers
	if(HAS_MIND_TRAIT(src, TRAIT_HOLY))
		return FALSE
	if(can_block_magic(MAGIC_RESISTANCE_HOLY))
		return FALSE
	return TRUE

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

/datum/vampire_passive/proc/on_apply(datum/antagonist/vampire/V)
	owner.update_sight() // Life updates conditionally, so we need to update sight here in case the vamp gets new vision based on his powers. Maybe one day refactor to be more OOP and on the vampire's ability datum.
	return

/datum/action/cooldown/spell/vampire_rejuvenate
	name = "Rejuvenate"
	desc = "Use reserve blood to enliven your body, removing any incapacitating effects."
	button_icon_state = "vampire_rejuvinate"
	cooldown_time = 20 SECONDS
	check_flags = AB_CHECK_PHASED
	antimagic_flags = NONE // So. If you have a null rod on your person, you can't cast vampire spells. I would rather not have officers abuse this by putting a nullrod in their pocket or something to block rejuvinate.


/datum/action/cooldown/spell/vampire_rejuvenate/New(Target)
	. = ..()
	add_vampire_ability()

/datum/action/cooldown/spell/vampire_rejuvenate/cast(atom/cast_on)
	. = ..()
	var/mob/living/user = owner

	user.SetAllImmobility(0)
	user.set_stamina_loss(0)
	user.set_resting(FALSE, instant = TRUE)

	to_chat(user, span_notice("You instill your body with clean blood and remove any incapacitating effects."))
	var/datum/antagonist/vampire/vampire = user.mind.has_antag_datum(/datum/antagonist/vampire)

	var/rejuv_bonus = vampire.get_rejuv_bonus()
	if(rejuv_bonus)
		INVOKE_ASYNC(src, PROC_REF(heal), user, rejuv_bonus)

/datum/action/cooldown/spell/vampire_rejuvenate/proc/heal(mob/living/user, rejuv_bonus)
	// TODO: rewrite to something better
	for(var/i in 1 to 5)
		user.adjust_brute_loss(-2 * rejuv_bonus)
		user.adjust_oxy_loss(-5 * rejuv_bonus)
		user.adjust_tox_loss(-2 * rejuv_bonus, forced = TRUE)
		user.adjust_fire_loss(-2 * rejuv_bonus)
		for(var/datum/reagent/toxin/toxin as anything in user.reagents.reagent_list)
			user.reagents.remove_reagent(toxin.type, 2 * rejuv_bonus)
		sleep(35)

/datum/antagonist/vampire/proc/get_rejuv_bonus()
	var/rejuv_multiplier = 0
	if(!get_ability(/datum/vampire_passive/regen))
		return rejuv_multiplier

	if(subclass?.improved_rejuv_healing)
		rejuv_multiplier = clamp((100 - owner.current.health) / 20, 1, 5) // brute and burn healing between 5 and 50
		return rejuv_multiplier

	return TRUE

// No exfiltration feature for tg

/datum/action/cooldown/spell/vampire_specialize
	name = "Choose Specialization"
	desc = "Choose what sub-class of vampire you want to evolve into."
	cooldown_time = 2 SECONDS
	button_icon_state = "select_class"

/datum/action/cooldown/spell/vampire_specialize/New(Target)
	. = ..()
	add_vampire_ability()

/datum/action/cooldown/spell/vampire_specialize/cast(atom/cast_on)
	. = ..()
	ui_interact(owner)

/datum/action/cooldown/spell/vampire_specialize/ui_state(mob/user)
	return GLOB.always_state

/datum/action/cooldown/spell/vampire_specialize/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SpecMenu", "Specialisation Menu")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/action/cooldown/spell/vampire_specialize/ui_data(mob/user)
	var/datum/antagonist/vampire/vamp = user.mind.has_antag_datum(/datum/antagonist/vampire)
	var/list/data = list("subclasses" = vamp.subclass)
	return data

/datum/action/cooldown/spell/vampire_specialize/ui_act(action, list/params)
	if(..())
		return
	var/datum/antagonist/vampire/vamp = usr.mind.has_antag_datum(/datum/antagonist/vampire)

	if(vamp.subclass)
		vamp.upgrade_tiers -= type
		vamp.remove_ability(src)
		return

	switch(action)
		if("umbrae")
			vamp.add_subclass(SUBCLASS_UMBRAE)
			vamp.upgrade_tiers -= type
			vamp.remove_ability(src)
		if("hemomancer")
			vamp.add_subclass(SUBCLASS_HEMOMANCER)
			vamp.upgrade_tiers -= type
			vamp.remove_ability(src)
		if("gargantua")
			vamp.add_subclass(SUBCLASS_GARGANTUA)
			vamp.upgrade_tiers -= type
			vamp.remove_ability(src)
		if("dantalion")
			vamp.add_subclass(SUBCLASS_DANTALION)
			vamp.upgrade_tiers -= type
			vamp.remove_ability(src)


/datum/antagonist/vampire/proc/add_subclass(subclass_to_add, announce = TRUE, log_choice = TRUE)
	var/datum/vampire_subclass/new_subclass = new subclass_to_add
	subclass = new_subclass
	check_vampire_upgrade(announce)
	if(log_choice)
		SSblackbox.record_feedback("nested tally", "vampire_subclasses", 1, list("[new_subclass.name]"))

// TODO for someone else: convert this to an universal spell with charges thingie
/datum/action/cooldown/spell/vampire_glare
	parent_type = /datum/action/cooldown/spell/aoe
	name = "Glare"
	desc = "Your eyes flash, stunning and silencing anyone in front of you. It has lesser effects for those around you. Holds two charges, each of which recovers over 30 seconds."
	button_icon_state = "vampire_glare"
	check_flags = AB_CHECK_PHASED
	cooldown_time = 0
	aoe_radius = 1
	var/charges = 2
	var/max_charges = 2
	var/recharge_time = 30 SECONDS
	/// Maps each spent charge's unique ID to its recharge time.
	var/list/recharge_times = list()
	var/next_recharge_id = 0

/datum/action/cooldown/spell/vampire_glare/New(Target)
	. = ..()
	add_vampire_ability()

/datum/action/cooldown/spell/vampire_glare/get_things_to_cast_on(atom/center)
	. = list()
	for(var/mob/living/target in range(aoe_radius, center))
		if(target != owner)
			. += target

/datum/action/cooldown/spell/vampire_glare/can_cast_spell(feedback = TRUE)
	if(!..())
		return FALSE
	if(charges)
		return TRUE
	if(feedback)
		to_chat(owner, span_warning("Your glare has not recovered yet."))
	return FALSE

/datum/action/cooldown/spell/vampire_glare/after_cast(atom/cast_on)
	. = ..()
	charges--
	var/recharge_id = "charge_[++next_recharge_id]"
	recharge_times[recharge_id] = world.time + recharge_time
	addtimer(CALLBACK(src, PROC_REF(recharge), recharge_id), recharge_time)
	if(!charges)
		StartCooldown(get_next_recharge_time() - world.time)
	else
		build_all_button_icons(UPDATE_BUTTON_STATUS)


/datum/action/cooldown/spell/vampire_glare/proc/get_next_recharge_time()
	var/next_recharge_time = INFINITY
	for(var/recharge_id in recharge_times)
		next_recharge_time = min(next_recharge_time, recharge_times[recharge_id])
	return next_recharge_time

/datum/action/cooldown/spell/vampire_glare/proc/recharge(recharge_id)
	if(isnull(recharge_times[recharge_id]))
		return
	recharge_times[recharge_id] = null
	charges = min(charges + 1, max_charges)
	if(charges)
		ResetCooldown()
	else
		StartCooldown(get_next_recharge_time() - world.time)
	build_all_button_icons(UPDATE_BUTTON_STATUS)

/datum/action/cooldown/spell/vampire_glare/update_button_status(atom/movable/screen/movable/action_button/button, force = FALSE)
	. = ..()
	if(charges)
		button.maptext = MAPTEXT_TINY_UNICODE(charges)

/datum/action/cooldown/spell/vampire_lair
	parent_type = /datum/action/cooldown/spell/pointed
	name = "Lair"
	desc = "Pick a coffin for yourself, the centrepiece of your new lair."
	button_icon = 'icons/obj/storage/crates.dmi'
	button_icon_state = "coffin"
	cooldown_time = 2 SECONDS
	cast_range = 1
	aim_assist = FALSE

/datum/action/cooldown/spell/vampire_lair/New(Target)
	. = ..()
	add_vampire_ability()

/datum/action/cooldown/spell/vampire_lair/is_valid_target(atom/cast_on)
	. = ..()
	return istype(cast_on, /obj/structure/closet/crate/coffin)

/datum/action/cooldown/spell/vampire_lair/cast(atom/cast_on)
	. = ..()
	var/mob/living/user = owner
	var/obj/structure/closet/crate/coffin/coffin = cast_on
	if(!istype(coffin))
		to_chat(user, span_warning("This only works on coffins!"))
		return
	if(istype(coffin, /obj/structure/closet/crate/coffin/vampire))
		to_chat(user, span_warning("This coffin serves another and refuses to bend to your will!"))
		return
	for(var/turf/T in range(1, coffin))
		if(T.density)
			to_chat(user, span_warning("You need more space around the coffin for the ritual!"))
			return
	to_chat(user, span_danger("You begin marking the coffin!"))
	coffin.Beam(user, icon_state = "drainbeam", maxdistance = 1, time = 10 SECONDS)
	playsound(coffin, 'sound/effects/bubbles/bubbles.ogg', 20)
	for(var/obj/machinery/light/L in range(5, user))
		L.flicker()
	var/obj/effect/lair_rune/rune = new /obj/effect/lair_rune(get_turf(coffin), user)
	if(!do_after(user, 10 SECONDS, target = coffin))
		qdel(rune)
		return
	playsound(user, 'sound/misc/interference.ogg', 30)
	new /obj/structure/closet/crate/coffin/vampire(get_turf(coffin), user)
	qdel(coffin)
	var/datum/antagonist/vampire/V = user.mind.has_antag_datum(/datum/antagonist/vampire)
	V.has_lair = TRUE
	V.upgrade_tiers -= type
	V.remove_ability(src)

/obj/structure/closet/crate/coffin/vampire
	name = "vampiric coffin"
	desc = "A coffin marked with a sanguine rune."

/obj/effect/lair_rune
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = FLOOR_PLANE
	layer = RUNE_LAYER
	icon = 'modular_bandastation/vampire/icons/effects/vampire_rune.dmi'
	icon_state = "vampiric_rune"
	pixel_x = -34
	pixel_y = -38

/obj/effect/lair_rune/Initialize(mapload, mob/user)
	. = ..()
	if(user)
		var/mob/living/living_user = user
		color = living_user?.get_bloodtype()?.get_color()

/datum/action/cooldown/spell/vampire_glare/cast(atom/cast_on)
	var/mob/living/user = owner
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(istype(H.glasses, /obj/item/clothing/glasses/blindfold))
			var/obj/item/clothing/glasses/blindfold/B = H.glasses
			if(B.tint)
				to_chat(user, span_warning("You're blindfolded!"))
				return
	user.mob_light(range = 3, power = 1, color = LIGHT_COLOR_BLOOD_MAGIC, duration = 2 SECONDS)
	user.visible_message(span_warning("[user]'s eyes emit a blinding flash!"))
	return ..()

/datum/action/cooldown/spell/vampire_glare/cast_on_thing_in_aoe(mob/living/target, mob/living/user)
	if(!target.affects_vampire(user))
		return

	var/deviation
	if(user.dir & (EAST | WEST))
		deviation = DEVIATION_PARTIAL
	else
		deviation = calculate_deviation(target, user)

	if(deviation == DEVIATION_FULL)
		target.adjust_confusion(6 SECONDS)
		target.apply_damage(20, STAMINA)
	else if(deviation == DEVIATION_PARTIAL)
		target.AdjustKnockdown(5 SECONDS)
		target.adjust_confusion(6 SECONDS)
		target.apply_damage(40, STAMINA)
	else
		target.adjust_confusion(10 SECONDS)
		target.apply_damage(70, STAMINA)
		target.AdjustKnockdown(12 SECONDS)
		target.adjust_silence(8 SECONDS)
		target.flash_act(visual = TRUE)
	to_chat(target, span_warning("You are blinded by [user]'s glare."))
	log_combat(user, target, "glared at", addition = "(Vampire)")

/datum/action/cooldown/spell/vampire_glare/proc/calculate_deviation(mob/victim, mob/attacker)

	// If the victim was looking at the attacker, this is the direction they'd have to be facing.
	var/attacker_to_victim = get_dir(attacker, victim)
	// The victim's dir is necessarily a cardinal value.
	var/attacker_dir = attacker.dir

	// - - -
	// - V - Attacker facing south
	// # # #
	// Attacker within 45 degrees of where the victim is facing.
	if(attacker_dir & attacker_to_victim)
		return DEVIATION_NONE
	// Are they on the same tile? This is probably the victim crawling under the vampire, and looking down shouldn't be too tough.
	if(victim.loc == attacker.loc)
		return DEVIATION_NONE
	// # # #
	// - V - Attacker facing south
	// - - -
	// Victim at 135 or more degrees of where the victim is facing.
	if(attacker_dir & REVERSE_DIR(attacker_to_victim))
		return DEVIATION_FULL
	// - - -
	// # V # Attacker facing south
	// - - -
	// Victim lateral to the victim.
	return DEVIATION_PARTIAL

#undef DEVIATION_NONE
#undef DEVIATION_PARTIAL
#undef DEVIATION_FULL

/datum/vampire_passive/regen
	gain_desc = "Your rejuvenation abilities have improved and will now heal you over time when used."

/datum/vampire_passive/vision
	gain_desc = "Your vampiric vision has improved."
	var/see_in_dark = 1
	var/vision_flags = SEE_MOBS

/datum/vampire_passive/vision/advanced
	gain_desc = "Your vampiric vision now allows you to see everything in the dark!"
	see_in_dark = 3

/datum/vampire_passive/vision/full
	gain_desc = "Your vampiric vision has reached its full strength!"
	see_in_dark = 6

/datum/vampire_passive/full
	gain_desc = "You have reached your full potential. You are no longer weak to the effects of anything holy."

/datum/action/cooldown/spell/vampire_raise_vampires
	parent_type = /datum/action/cooldown/spell/aoe
	name = "Raise Vampires"
	desc = "Summons deadly vampires from bluespace."
	button_icon_state = "revive_thrall"
	sound = 'sound/effects/empulse.ogg'
	cooldown_time = 20 MINUTES
	aoe_radius = 3

/datum/action/cooldown/spell/vampire_raise_vampires/New(Target)
	. = ..()
	add_vampire_ability()

/datum/action/cooldown/spell/vampire_raise_vampires/get_things_to_cast_on(atom/center)
	. = list()
	for(var/mob/living/carbon/human/target in range(aoe_radius, center))
		if(target != owner)
			. += target

/datum/action/cooldown/spell/vampire_raise_vampires/cast(atom/cast_on)
	var/mob/living/user = owner
	new /obj/effect/temp_visual/cult/sparks(user.loc)
	to_chat(user, span_warning("You call out within bluespace, summoning more vampiric spirits to aid you!"))
	return ..()

/datum/action/cooldown/spell/vampire_raise_vampires/cast_on_thing_in_aoe(mob/living/carbon/human/target, mob/living/user)
	var/turf/user_turf = get_turf(user)
	user_turf.Beam(target, "sendbeam", 'icons/effects/effects.dmi', time = 3 SECONDS, maxdistance = 7, beam_type = /obj/effect/ebeam)
	new /obj/effect/temp_visual/cult/sparks(target.loc)
	raise_vampire(user, target)


/datum/action/cooldown/spell/vampire_raise_vampires/proc/raise_vampire(mob/living/user, mob/living/carbon/human/target)
	if(!user?.mind || !target?.mind)
		if(target)
			target.visible_message("[target] looks to be too stupid to understand what is going on.")
		return
	if(!target.can_have_blood() || !target.get_blood_volume())
		target.visible_message("[target] looks unfazed!")
		return
	if(target.mind.has_antag_datum(/datum/antagonist/vampire) || target.mind.has_antag_datum(/datum/antagonist/vampire_thrall))
		target.visible_message(span_notice("[target] looks refreshed!"))
		target.heal_overall_damage(brute = 60, burn = 60)
		return
	if(target.stat != DEAD)
		if(target.IsKnockdown())
			target.visible_message(span_warning("[target] looks to be in pain!"))
			target.adjust_organ_loss(ORGAN_SLOT_BRAIN, 60)
		else
			target.visible_message(span_warning("[target] looks to be stunned by the energy!"))
			target.SetKnockdown(40 SECONDS)
		return
	for(var/obj/item/implant/mindshield/mindshield in target.implants)
		mindshield.removed(target)
	target.visible_message(span_warning("[target] gets an eerie red glow in their eyes!"))

	log_combat(user, target, "sired", addition = "(Vampire)")
	var/datum/antagonist/vampire/new_vampire = target.mind.add_antag_datum(/datum/antagonist/vampire)
	var/datum/objective/protect/protect_objective = new
	protect_objective.target = user.mind
	protect_objective.explanation_text = "Protect [user.real_name]."
	new_vampire.objectives += protect_objective
	target.revive()
	target.SetKnockdown(40 SECONDS)
