/mob/living/proc/affects_vampire(mob/user)
	//Other vampires and thralls aren't affected
	if(HAS_TRAIT(src, TRAIT_VAMPIRE_LIKE))
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
		gain_desc = "Теперь вы можете использовать [src.declent_ru(INSTRUMENTAL)]."

/datum/vampire_passive/Destroy(force, ...)
	owner = null
	return ..()

/datum/vampire_passive/proc/on_apply(datum/antagonist/vampire/V)
	owner.update_sight() // Life updates conditionally, so vision passives must force an update when granted.
	return

/datum/action/cooldown/spell/vampire_rejuvenate
	name = "Омоложение"
	desc = "Используйте запас крови, чтобы оживить тело и снять все обездвиживающие эффекты."
	button_icon = 'modular_bandastation/vampire/icons/mob/actions/actions.dmi'
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

	// TODO: wake up from crit?
	user.SetAllImmobility(0)
	user.set_stamina_loss(0)
	user.set_resting(FALSE, instant = TRUE)

	to_chat(user, span_notice("Вы наполняете тело чистой кровью и снимаете все обездвиживающие эффекты."))
	var/rejuv_mult = 0
	SEND_SIGNAL(owner, COMSIG_VAMPIRE_ABILITY_GET_REJUV_MULT, &rejuv_mult)
	if(rejuv_mult)
		user.apply_status_effect(/datum/status_effect/vampire_rejuvenation, rejuv_mult)

/datum/antagonist/vampire/proc/get_rejuv_mult()
	var/rejuv_multiplier = 0
	if(!get_ability(/datum/vampire_passive/regen))
		return
	rejuv_multiplier = 1

	if(subclass?.improved_rejuv_healing)
		rejuv_multiplier = clamp((100 - owner.current.health) / 20, 1, 5) // brute and burn healing between 5 and 50

	return rejuv_multiplier

/datum/antagonist/vampire/proc/add_subclass(subclass_to_add, announce = TRUE, log_choice = TRUE)
	var/datum/vampire_subclass/new_subclass = new subclass_to_add
	subclass = new_subclass
	check_vampire_upgrade(announce)
	update_specialization_objective()
	if(log_choice)
		SSblackbox.record_feedback("nested tally", "vampire_subclasses", 1, list("[new_subclass.name]"))

// TODO for someone else: convert this to an universal spell with charges thingie
/datum/action/cooldown/spell/aoe/vampire_glare
	name = "Взгляд"
	desc = "Ваши глаза вспыхивают, оглушая и лишая речи тех, кто перед вами. На окружающих эффект слабее."
	button_icon = 'modular_bandastation/vampire/icons/mob/actions/actions.dmi'
	button_icon_state = "vampire_glare"
	check_flags = AB_CHECK_PHASED
	cooldown_time = 2 SECONDS
	aoe_radius = 1
	var/charges = 2
	var/max_charges = 2
	var/recharge_time = 30 SECONDS
	/// Maps each spent charge's unique ID to its recharge time.
	var/list/recharge_times = list()
	var/next_recharge_id = 0

/datum/action/cooldown/spell/aoe/vampire_glare/New(Target)
	. = ..()
	add_vampire_ability()

/datum/action/cooldown/spell/aoe/vampire_glare/get_things_to_cast_on(atom/center)
	. = list()
	for(var/mob/living/target in range(aoe_radius, center))
		if(target != owner)
			. += target

/datum/action/cooldown/spell/aoe/vampire_glare/can_cast_spell(feedback = TRUE)
	if(!..())
		return FALSE
	if(charges)
		return TRUE
	if(feedback)
		to_chat(owner, span_warning("Ваш взгляд ещё не восстановился."))
	return FALSE

/datum/action/cooldown/spell/aoe/vampire_glare/after_cast(atom/cast_on)
	. = ..()
	charges--
	var/recharge_id = "charge_[++next_recharge_id]"
	recharge_times[recharge_id] = world.time + recharge_time
	addtimer(CALLBACK(src, PROC_REF(recharge), recharge_id), recharge_time)
	if(!charges)
		StartCooldown(get_next_recharge_time() - world.time)
	else
		build_all_button_icons(UPDATE_BUTTON_STATUS)


/datum/action/cooldown/spell/aoe/vampire_glare/proc/get_next_recharge_time()
	var/next_recharge_time = INFINITY
	for(var/recharge_id in recharge_times)
		var/recharge_time = recharge_times[recharge_id]
		if(isnull(recharge_time))
			continue
		next_recharge_time = min(next_recharge_time, recharge_time)
	return next_recharge_time

/datum/action/cooldown/spell/aoe/vampire_glare/proc/recharge(recharge_id)
	if(isnull(recharge_times[recharge_id]))
		return
	recharge_times[recharge_id] = null
	charges = min(charges + 1, max_charges)
	if(charges)
		ResetCooldown()
	else
		StartCooldown(get_next_recharge_time() - world.time)
	build_all_button_icons(UPDATE_BUTTON_STATUS)

/datum/action/cooldown/spell/aoe/vampire_glare/update_button_status(atom/movable/screen/movable/action_button/button, force = FALSE)
	. = ..()
	if(charges)
		button.maptext = MAPTEXT_TINY_UNICODE(charges)

/datum/action/cooldown/spell/aoe/vampire_glare/cast(atom/cast_on)
	var/mob/living/user = owner
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(istype(H.glasses, /obj/item/clothing/glasses/blindfold))
			var/obj/item/clothing/glasses/blindfold/B = H.glasses
			if(B.tint)
				to_chat(user, span_warning("На вас повязка на глазах!"))
				return
	user.mob_light(range = 3, power = 1, color = LIGHT_COLOR_BLOOD_MAGIC, duration = 2 SECONDS)
	user.visible_message(span_warning("Глаза [user.declent_ru(GENITIVE)] испускают ослепительную вспышку!"))
	return ..()

/datum/action/cooldown/spell/aoe/vampire_glare/cast_on_thing_in_aoe(mob/living/target, mob/living/user)
	if(!target.affects_vampire(user))
		return

	var/deviation
	if(user.body_position == LYING_DOWN)
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
	to_chat(target, span_warning("Вас ослепляет взгляд [user]."))
	log_combat(user, target, "glared at", addition = "(Vampire)")

/datum/action/cooldown/spell/aoe/vampire_glare/proc/calculate_deviation(mob/victim, mob/attacker)

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

/datum/action/cooldown/spell/pointed/vampire_lair
	name = "Логово"
	desc = "Выберите себе гроб, который станет центральным элементом вашего нового логова."
	button_icon = 'modular_bandastation/vampire/icons/obj/items.dmi' // tg coffin icon is too big
	button_icon_state = "coffin"
	cooldown_time = 2 SECONDS
	cast_range = 1
	aim_assist = FALSE

/datum/action/cooldown/spell/pointed/vampire_lair/New(Target)
	. = ..()
	add_vampire_ability()

/datum/action/cooldown/spell/pointed/vampire_lair/is_valid_target(atom/cast_on)
	. = ..()
	return istype(cast_on, /obj/structure/closet/crate/coffin)

/datum/action/cooldown/spell/pointed/vampire_lair/cast(atom/cast_on)
	. = ..()
	var/mob/living/user = owner
	var/obj/structure/closet/crate/coffin/coffin = cast_on
	if(!istype(coffin))
		to_chat(user, span_warning("Это работает только с гробами!"))
		return
	if(istype(coffin, /obj/structure/closet/crate/coffin/vampire))
		to_chat(user, span_warning("[coffin.declent_ru(NOMINATIVE)] служит другому и отказывается подчиняться вашей воле!"))
		return
	for(var/turf/T in range(1, coffin))
		if(T.density)
			to_chat(user, span_warning("Для ритуала вокруг [coffin.declent_ru(GENITIVE)] нужно больше места!"))
			return
	to_chat(user, span_danger("Вы начинаете помечать [coffin.declent_ru(ACCUSATIVE)]!"))
	coffin.Beam(user, icon_state = "drainbeam", maxdistance = 1, time = 10 SECONDS)
	playsound(coffin, 'sound/effects/magic/enter_blood.ogg', 20)
	for(var/obj/machinery/light/L in range(5, user))
		L.flicker()
	var/obj/effect/lair_rune/rune = new /obj/effect/lair_rune(get_turf(coffin), user)
	if(!do_after(user, 10 SECONDS, target = coffin))
		qdel(rune)
		return
	playsound(user, 'modular_bandastation/vampire/sound/misc/im_here1.ogg', 30)
	var/obj/structure/closet/crate/coffin/vampire/vampire_coffin = new(get_turf(coffin), user, rune)
	for(var/atom/movable/content in coffin.contents)
		content.forceMove(vampire_coffin)
	qdel(coffin)
	SEND_SIGNAL(owner, COMSIG_VAMPIRE_ABILITY_COMPLETE_LAIR, src)

/obj/structure/closet/crate/coffin/vampire
	name = "vampire coffin"
	desc = "Гроб, отмеченный кровавой руной."
	max_integrity = 500
	anchored = TRUE
	armor_type = /datum/armor/vampire_coffin
	/// Owner of this coffin.
	var/datum/weakref/vampire_ref
	/// The rune created with this coffin.
	var/obj/effect/lair_rune/lair_rune
	/// Whether the coffin is currently being ignited with a welder.
	var/igniting = FALSE
	COOLDOWN_DECLARE(fire_act_cooldown)

/datum/armor/vampire_coffin
	melee = 200
	bullet = 200
	laser = 80
	energy = 200
	bomb = 200
	fire = -60 // Burning deals 16 damage per second, destroying the coffin in ~30 seconds
	acid = 200

/obj/structure/closet/crate/coffin/vampire/Initialize(mapload, mob/living/user, obj/effect/lair_rune/rune)
	. = ..()
	desc += "<br>Владелец этого гроба, возможно, никому не был дорог или даже ещё не умер.<br>[span_warning("Кажется, он неуязвим для всего, кроме лазеров и огня! Особенно для огня!")]"
	if(user?.mind?.name)
		desc += "<br>На крышке гроба высечено имя: «[html_encode(user.mind.name)]»."
	vampire_ref = WEAKREF(user)
	lair_rune = rune

/obj/structure/closet/crate/coffin/vampire/Destroy()
	vampire_ref = null
	QDEL_NULL(lair_rune)
	return ..()

/obj/structure/closet/crate/coffin/vampire/proc/get_vampire() as /mob/living
	return vampire_ref?.resolve()

/obj/structure/closet/crate/coffin/vampire/wrench_act(mob/living/user, obj/item/tool)
	return ITEM_INTERACT_BLOCKING

/obj/structure/closet/crate/coffin/vampire/welder_act(mob/living/user, obj/item/tool)
	if(igniting)
		return ITEM_INTERACT_BLOCKING
	if(!tool.tool_use_check(user, 30))
		return ITEM_INTERACT_BLOCKING
	igniting = TRUE


	to_chat(user, span_notice("Вы пытаетесь поджечь [src.declent_ru(ACCUSATIVE)] с помощью [tool.declent_ru(INSTRUMENTAL)]."))
	var/mob/living/vampire = get_vampire()
	if(vampire)
		to_chat(vampire, span_warning("На ваше логово напали!"))
	if(tool.use_tool(src, user, 15 SECONDS, amount = 30))
		fire_act(tool.get_temperature())
	igniting = FALSE
	return ITEM_INTERACT_SUCCESS


/obj/structure/closet/crate/coffin/vampire/bullet_act(obj/projectile/projectile, def_zone, piercing_hit = FALSE, blocked = null)
	if(istype(projectile, /obj/projectile/bullet/incendiary))
		fire_act()
	return ..(projectile, def_zone, piercing_hit, blocked)

/obj/structure/closet/crate/coffin/vampire/fire_act(exposed_temperature, exposed_volume)
	. = ..()
	if(!COOLDOWN_FINISHED(src, fire_act_cooldown))
		return
	var/mob/living/vampire = get_vampire()
	if(vampire)
		to_chat(vampire, span_warning("На ваше логово напали!"))
	switch(rand(1, 4))
		if(1)
			visible_message(span_danger("Древесина воет, а огонь вспыхивает, казалось бы, из ниоткуда!"))
			playsound(src, 'modular_bandastation/vampire/sound/misc/howl.ogg', 30)
		if(2 to 3)
			visible_message(span_danger("Древесина шипит, и огонь вспыхивает, казалось бы, из ниоткуда!"))
			playsound(src, pick('modular_bandastation/vampire/sound/misc/unathihiss.ogg', 'modular_bandastation/vampire/sound/misc/tajaranhiss.ogg'), 30)
		if(4)
			visible_message(span_danger("Древесина рычит, когда огонь вырывается из ниоткуда!"))
			playsound(src, 'modular_bandastation/vampire/sound/misc/growl3.ogg', 30)
	var/turf/nearby_turf = pick(RANGE_TURFS(2, src))
	new /obj/effect/hotspot(nearby_turf)
	new /obj/effect/hotspot(get_turf(src))
	COOLDOWN_START(src, fire_act_cooldown, 10 SECONDS)

/obj/structure/closet/crate/coffin/vampire/burn()
	playsound(src, 'sound/effects/hallucinations/wail.ogg', 20, extrarange = 5)
	visible_message(span_danger("Огонь вырывается из [src.declent_ru(GENITIVE)], когда он разрушается!"))
	var/turf/coffin_turf = get_turf(src)
	for(var/turf/turf in range(1, src))
		if(turf == coffin_turf)
			continue
		new /obj/effect/hotspot(turf)
	return ..()

/obj/effect/lair_rune
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
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

/datum/vampire_passive/regen
	gain_desc = "Ваши способности омоложения улучшились и теперь при использовании исцеляют вас со временем."

/datum/vampire_passive/vision
	gain_desc = "Ваше вампирское зрение улучшилось."
	/// The brightest darkness this passive lets the vampire see through.
	var/lighting_cutoff = LIGHTING_CUTOFF_LOW
	/// Native sight traits supplied by this tier.
	var/list/vision_traits = list(TRAIT_THERMAL_VISION)

/datum/vampire_passive/vision/on_apply(datum/antagonist/vampire/vampire)
	. = ..()
	if(iscarbon(owner))
		owner.add_traits(vision_traits, REF(src))
		RegisterSignal(owner, COMSIG_CARBON_UPDATE_SIGHT_CUTOFFS, PROC_REF(update_vision))
		owner.update_sight()

/datum/vampire_passive/vision/Destroy(force, ...)
	if(iscarbon(owner))
		UnregisterSignal(owner, COMSIG_CARBON_UPDATE_SIGHT_CUTOFFS)
		owner.remove_traits(vision_traits, REF(src))
		owner.update_sight()
	return ..()

/datum/vampire_passive/vision/proc/update_vision(mob/living/carbon/vampire, list/new_sight_flags)
	SIGNAL_HANDLER
	vampire.lighting_cutoff = max(vampire.lighting_cutoff, lighting_cutoff)

/datum/vampire_passive/vision/advanced
	gain_desc = "Теперь ваше вампирское зрение позволяет видеть всё во тьме!"
	lighting_cutoff = LIGHTING_CUTOFF_HIGH

/datum/vampire_passive/vision/full
	gain_desc = "Ваше вампирское зрение достигло полной силы!"
	lighting_cutoff = LIGHTING_CUTOFF_FULLBRIGHT

/datum/vampire_passive/full
	gain_desc = "Вы достигли полного потенциала. Святые предметы и эффекты больше не являются вашей слабостью."

/datum/action/cooldown/spell/aoe/vampire_raise_vampires
	name = "Поднять вампиров"
	desc = "Призывает смертоносных вампиров из блюспейса."
	button_icon = 'modular_bandastation/vampire/icons/mob/actions/actions.dmi'
	button_icon_state = "revive_thrall"
	sound = 'modular_bandastation/vampire/sound/magic/wandodeath.ogg'
	cooldown_time = 20 MINUTES
	aoe_radius = 3

/datum/action/cooldown/spell/aoe/vampire_raise_vampires/New(Target)
	. = ..()
	add_vampire_ability()

/datum/action/cooldown/spell/aoe/vampire_raise_vampires/get_things_to_cast_on(atom/center)
	. = list()
	for(var/mob/living/carbon/human/target in range(aoe_radius, center))
		if(target != owner)
			. += target

/datum/action/cooldown/spell/aoe/vampire_raise_vampires/cast(atom/cast_on)
	var/mob/living/user = owner
	new /obj/effect/temp_visual/cult/sparks(user.loc)
	to_chat(user, span_warning("Вы взываете в блюспейсе, призывая на помощь новых вампирских духов!"))
	return ..()

/datum/action/cooldown/spell/aoe/vampire_raise_vampires/cast_on_thing_in_aoe(mob/living/carbon/human/target, mob/living/user)
	var/turf/user_turf = get_turf(user)
	user_turf.Beam(target, "sendbeam", 'icons/effects/beam.dmi', time = 3 SECONDS, maxdistance = 7, beam_type = /obj/effect/ebeam)
	new /obj/effect/temp_visual/cult/sparks(target.loc)
	raise_vampire(user, target)


/datum/action/cooldown/spell/aoe/vampire_raise_vampires/proc/raise_vampire(mob/living/user, mob/living/carbon/human/target)
	if(!user?.mind || !target?.mind)
		if(target)
			target.visible_message("[capitalize(target.declent_ru(NOMINATIVE))], похоже, слишком глуп, чтобы понять происходящее.")
		return
	if(!target.can_have_blood() || !target.get_blood_volume())
		target.visible_message("[capitalize(target.declent_ru(NOMINATIVE))] выглядит невозмутимо!")
		return
	if(HAS_TRAIT(target, TRAIT_VAMPIRE_LIKE))
		target.visible_message(span_notice("[capitalize(target.declent_ru(NOMINATIVE))] выглядит посвежевшим!"))
		target.heal_overall_damage(brute = 60, burn = 60)
		for(var/obj/item/bodypart/bodypart as anything in target.bodyparts)
			if(prob(25))
				for(var/datum/wound/wound as anything in bodypart.wounds)
					wound.remove_wound()
		return
	if(target.stat != DEAD)
		if(target.IsKnockdown())
			target.visible_message(span_warning("[capitalize(target.declent_ru(NOMINATIVE))], похоже, испытывает боль!"))
			target.adjust_organ_loss(ORGAN_SLOT_BRAIN, 60)
		else
			target.visible_message(span_warning("[capitalize(target.declent_ru(NOMINATIVE))], похоже, оглушён энергией!"))
			target.SetKnockdown(40 SECONDS)
		return
	if(target.ckey && is_banned_from(target.ckey, list(ROLE_SYNDICATE, ROLE_VAMPIRE)))
		target.visible_message(span_warning("[capitalize(target.declent_ru(NOMINATIVE))] остаётся безжизненным."))
		return
	for(var/obj/item/implant/mindshield/mindshield in target.implants)
		mindshield.removed(target)
	for(var/obj/item/implant/uplink/traitor_implant in target.implants)
		traitor_implant.removed(target)
	target.visible_message(span_warning("В глазах [target.declent_ru(GENITIVE)] появляется жуткое красное свечение!"))
	log_combat(user, target, "sired", addition = "(Vampire)")

	var/datum/antagonist/vampire/new_vampire = target.mind.add_antag_datum(/datum/antagonist/vampire/bodyguard)
	var/datum/objective/protect/protect_objective = new
	protect_objective.target = user.mind
	protect_objective.explanation_text = "Защищайте [user.real_name]."
	new_vampire.objectives += protect_objective
	target.revive()
	target.SetKnockdown(40 SECONDS)
