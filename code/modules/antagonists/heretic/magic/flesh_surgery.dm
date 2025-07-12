/datum/action/cooldown/spell/touch/flesh_surgery
	name = "Knit Flesh"
	desc = "Заклинание прикосновения, которое позволяет вам либо собрать, либо восстановить плоть цели. \
		Нажав левой кнопкой мыши, можно извлечь органы жертвы, не прибегая к хирургическому вмешательству или расчленению. \
		Вы также можете подобрать свободный орган и вставить его в свою жертву. \
		Щелчок правой кнопкой мыши на призванных или миньонах восстанавливает здоровье. Также может использоваться для лечения поврежденных органов."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "mad_touch"
	sound = null

	school = SCHOOL_FORBIDDEN
	cooldown_time = 20 SECONDS
	invocation = "CL'M M'N!" // "CLAIM MINE", but also almost "KALI MA"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE

	hand_path = /obj/item/melee/touch_attack/flesh_surgery
	can_cast_on_self = TRUE

	/// If used on an organ, how much percent of the organ's HP do we restore
	var/organ_percent_healing = 0.5
	/// If used on a heretic mob, how much brute do we heal
	var/monster_brute_healing = 10
	/// If used on a heretic mob, how much burn do we heal
	var/monster_burn_healing = 5
	/// The organ being held in the touch attack - which will be implanted into mobs.
	var/obj/item/organ/held_organ
	/// Can we implant cybernetic organs?
	var/allow_cyber_organs = FALSE

/datum/action/cooldown/spell/touch/flesh_surgery/is_valid_target(atom/cast_on)
	return isliving(cast_on) || isorgan(cast_on)

/datum/action/cooldown/spell/touch/flesh_surgery/remove_hand(mob/living/hand_owner, reset_cooldown_after)
	var/obj/item/organ/the_organ = held_organ
	if(the_organ)
		unregister_held_organ(the_organ)
		the_organ.forceMove(hand_owner.drop_location())

	return ..()

/datum/action/cooldown/spell/touch/flesh_surgery/cast_on_hand_hit(obj/item/melee/touch_attack/flesh_surgery/hand, atom/victim, mob/living/carbon/caster)
	if(isorgan(victim))
		grab_organ(hand, victim, caster)
		return FALSE

	if(isliving(victim))
		if(held_organ)
			return insert_organ_into_mob(held_organ, hand, victim, caster)
		return steal_organ_from_mob(hand, victim, caster)

	return FALSE

/datum/action/cooldown/spell/touch/flesh_surgery/cast_on_secondary_hand_hit(obj/item/melee/touch_attack/flesh_surgery/hand, atom/victim, mob/living/carbon/caster)
	if(isorgan(victim))
		return heal_organ(hand, victim, caster)

	if(isliving(victim))
		var/mob/living/mob_victim = victim
		if(mob_victim.stat == DEAD || !HAS_TRAIT(mob_victim, TRAIT_HERETIC_SUMMON))
			return SECONDARY_ATTACK_CALL_NORMAL

		if(heal_heretic_monster(hand, mob_victim, caster))
			return SECONDARY_ATTACK_CONTINUE_CHAIN

	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/datum/action/cooldown/spell/touch/flesh_surgery/register_hand_signals()
	. = ..()
	RegisterSignal(attached_hand, COMSIG_ITEM_REQUESTING_CONTEXT_FOR_TARGET, PROC_REF(add_item_context))
	RegisterSignal(attached_hand, COMSIG_ATOM_ITEM_INTERACTION, PROC_REF(hand_interacted_with))
	attached_hand.item_flags |= ITEM_HAS_CONTEXTUAL_SCREENTIPS

/datum/action/cooldown/spell/touch/flesh_surgery/unregister_hand_signals()
	. = ..()
	UnregisterSignal(attached_hand, list(COMSIG_ITEM_REQUESTING_CONTEXT_FOR_TARGET, COMSIG_ATOM_ITEM_INTERACTION))

/datum/action/cooldown/spell/touch/flesh_surgery/proc/hand_interacted_with(obj/item/melee/touch_attack/source, mob/living/user, obj/item/tool)
	SIGNAL_HANDLER
	if(isorgan(tool))
		return grab_organ(source, tool, user)

/// Signal proc for [COMSIG_ITEM_REQUESTING_CONTEXT_FOR_TARGET] to add some context to the hand.
/datum/action/cooldown/spell/touch/flesh_surgery/proc/add_item_context(obj/item/melee/touch_attack/source, list/context, atom/victim, mob/living/user)
	SIGNAL_HANDLER

	. = NONE

	if(isliving(victim))
		var/mob/living/mob_victim = victim

		if(iscarbon(mob_victim))
			if(held_organ)
				context[SCREENTIP_CONTEXT_LMB] = "Вставить орган"
			else
				context[SCREENTIP_CONTEXT_LMB] = "Извлечь орган"
			. = CONTEXTUAL_SCREENTIP_SET

		if(HAS_TRAIT(mob_victim, TRAIT_HERETIC_SUMMON))
			context[SCREENTIP_CONTEXT_RMB] = "Вылечить [ishuman(mob_victim) ? "миньона" : "призванного"]"
			. = CONTEXTUAL_SCREENTIP_SET

	else if(isorgan(victim))
		context[SCREENTIP_CONTEXT_LMB] = "Поднять орган"
		context[SCREENTIP_CONTEXT_RMB] = "Вылечить орган"
		. = CONTEXTUAL_SCREENTIP_SET

	return .

/// If cast on an organ with left-click, we'll try to grab it.
/datum/action/cooldown/spell/touch/flesh_surgery/proc/grab_organ(obj/item/melee/touch_attack/hand, obj/item/organ/to_grab, mob/living/carbon/caster)
	if(held_organ)
		hand.balloon_alert(caster, "already holding organ!")
		return ITEM_INTERACT_FAILURE
	if(to_grab.organ_flags & ORGAN_ROBOTIC && !allow_cyber_organs)
		hand.balloon_alert(caster, "cybernetic organs not allowed!")
		return ITEM_INTERACT_FAILURE
	if(!caster.transferItemToLoc(to_grab, hand))
		hand.balloon_alert(caster, "couldn't grab organ!")
		return ITEM_INTERACT_FAILURE
	register_held_organ(to_grab, hand)
	return ITEM_INTERACT_SUCCESS

/datum/action/cooldown/spell/touch/flesh_surgery/proc/register_held_organ(obj/item/organ/new_held_organ, obj/item/melee/touch_attack/hand)
	hand.vis_contents += new_held_organ
	held_organ = new_held_organ
	new_held_organ.flags_1 |= IS_ONTOP_1
	new_held_organ.vis_flags |= VIS_INHERIT_PLANE
	RegisterSignal(new_held_organ, COMSIG_MOVABLE_MOVED, PROC_REF(unregister_held_organ))
	RegisterSignal(new_held_organ, COMSIG_QDELETING, PROC_REF(unregister_held_organ))
	// We gotta offset ourselves via pixel_w/z, so we don't end up z fighting with the touch attack
	new_held_organ.pixel_w = new_held_organ.pixel_x
	new_held_organ.pixel_z = new_held_organ.pixel_y
	new_held_organ.pixel_x = 0
	new_held_organ.pixel_y = 0

/datum/action/cooldown/spell/touch/flesh_surgery/proc/unregister_held_organ(obj/item/organ/removed_organ)
	LAZYREMOVE(attached_hand.vis_contents, removed_organ)
	held_organ = null
	removed_organ.flags_1 &= ~IS_ONTOP_1
	removed_organ.vis_flags &= ~VIS_INHERIT_PLANE
	UnregisterSignal(removed_organ, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING))
	// Reset item offsets
	removed_organ.pixel_x = removed_organ.pixel_w
	removed_organ.pixel_y = removed_organ.pixel_z
	removed_organ.pixel_w = 0
	removed_organ.pixel_z = 0

/// If cast on an organ with right-click, we'll restore its health and even un-fail it.
/datum/action/cooldown/spell/touch/flesh_surgery/proc/heal_organ(obj/item/melee/touch_attack/hand, obj/item/organ/to_heal, mob/living/carbon/caster)
	if(held_organ)
		hand.balloon_alert(caster, "drop held organ first!")
		return FALSE
	if(to_heal.damage == 0)
		to_heal.balloon_alert(caster, "уже в хорошем состоянии!")
		return FALSE
	to_heal.balloon_alert(caster, "лечение органа...")
	if(!do_after(caster, 1 SECONDS, to_heal, extra_checks = CALLBACK(src, PROC_REF(heal_checks), hand, to_heal, caster)))
		to_heal.balloon_alert(caster, "прервано!")
		return FALSE

	var/organ_hp_to_heal = to_heal.maxHealth * organ_percent_healing
	to_heal.set_organ_damage(max(0 , to_heal.damage - organ_hp_to_heal))
	to_heal.balloon_alert(caster, "organ healed")
	playsound(to_heal, 'sound/effects/magic/staff_healing.ogg', 30)
	new /obj/effect/temp_visual/cult/sparks(get_turf(to_heal))
	var/condition = (to_heal.damage > 0) ? "better" : "perfect"
	caster.visible_message(
		span_warning("Рука [caster.declent_ru(GENITIVE)] светится ярким красным светом, [to_heal.declent_ru(NOMINATIVE)] восстанавливается до состояния - [condition]!"),
		span_notice("Ваша рука светится ярким красным светом, [to_heal.declent_ru(NOMINATIVE)] восстанавливается до состояния - [condition]!"),
	)

	return TRUE

/// If cast on a heretic monster who's not dead we'll heal it a bit.
/datum/action/cooldown/spell/touch/flesh_surgery/proc/heal_heretic_monster(obj/item/melee/touch_attack/hand, mob/living/to_heal, mob/living/carbon/caster)
	var/what_are_we = ishuman(to_heal) ? "миньон" : "призванный"
	to_heal.balloon_alert(caster, "[what_are_we] лечится...")
	if(!do_after(caster, 1 SECONDS, to_heal, extra_checks = CALLBACK(src, PROC_REF(heal_checks), hand, to_heal, caster)))
		to_heal.balloon_alert(caster, "прервано!")
		return FALSE

	// Keep in mind that, for simplemobs(summons), this will just flat heal the combined value of both brute and burn healing,
	// while for human minions(ghouls), this will heal brute and burn like normal. So be careful adjusting to bigger numbers
	to_heal.balloon_alert(caster, "[what_are_we] вылечен")
	to_heal.heal_overall_damage(monster_brute_healing, monster_burn_healing)
	playsound(to_heal, 'sound/effects/magic/staff_healing.ogg', 30)
	new /obj/effect/temp_visual/cult/sparks(get_turf(to_heal))
	caster.visible_message(
		span_warning("Рука [caster.declent_ru(GENITIVE)] светится ярким красным светом, [to_heal.declent_ru(NOMINATIVE)] восстанавливается до хорошего состояния!"),
		span_notice("Ваша рука светится ярким красным светом, [to_heal.declent_ru(NOMINATIVE)] восстанавливается до хорошего состояния!"),
	)
	return TRUE

/// If cast on a carbon, we'll try to steal one of their organs directly from their person.
/datum/action/cooldown/spell/touch/flesh_surgery/proc/steal_organ_from_mob(obj/item/melee/touch_attack/hand, mob/living/victim, mob/living/carbon/caster)
	var/mob/living/carbon/carbon_victim = victim
	if(!istype(carbon_victim) || !length(carbon_victim.organs))
		victim.balloon_alert(caster, "нет органов!")
		return FALSE

	// Round u pto the nearest generic zone (body, chest, arm)
	var/zone_to_check = check_zone(caster.zone_selected)
	var/parsed_zone = victim.parse_zone_with_bodypart(zone_to_check, declent = DATIVE)

	var/list/organs_we_can_remove = list()
	for(var/obj/item/organ/organ as anything in carbon_victim.organs)
		// Only show organs which are in our generic zone
		if(deprecise_zone(organ.zone) != zone_to_check)
			continue
		// Also, some organs to exclude. Don't remove vital (brains), don't remove synthetics, and don't remove unremovable
		if(organ.organ_flags & (ORGAN_ROBOTIC|ORGAN_VITAL|ORGAN_UNREMOVABLE))
			continue

		organs_we_can_remove[organ.name] = organ

	if(!length(organs_we_can_remove))
		victim.balloon_alert(caster, "тут нет органов!")
		return FALSE

	var/chosen_organ = tgui_input_list(caster, "Какой орган вы хотите извлечь?", name, sort_list(organs_we_can_remove))
	if(isnull(chosen_organ))
		return FALSE
	var/obj/item/organ/picked_organ = organs_we_can_remove[chosen_organ]
	if(!istype(picked_organ) || !extraction_checks(picked_organ, hand, victim, caster))
		return FALSE

	// Don't let people stam crit into steal heart true combo
	var/time_it_takes = carbon_victim.stat == DEAD ? 3 SECONDS : 15 SECONDS

	// Sure you can remove your own organs, fun party trick
	if(carbon_victim == caster)
		var/are_you_sure = tgui_alert(caster, "Вы уверены, что хотите удалить [picked_organ.declent_ru(ACCUSATIVE)] у себя?", "Вы уверены?", list("Да", "Нет"))
		if(are_you_sure != "Да" || !extraction_checks(picked_organ, hand, victim, caster))
			return FALSE

		time_it_takes = 6 SECONDS
		caster.visible_message(
			span_danger("Рука [caster.declent_ru(GENITIVE)] светится ярким красным светом, когда они тянутся к своей [parsed_zone]!"),
			span_userdanger("Ваша рука светится ярким красным светом, когда вы тянетесь к своей [parsed_zone]!"),
		)

	else
		carbon_victim.visible_message(
			span_danger("Рука [caster.declent_ru(GENITIVE)] светится ярким светом, когда они тянутся к [parsed_zone] у [carbon_victim.declent_ru(GENITIVE)]!"),
			span_userdanger("Рука [caster.declent_ru(GENITIVE)] светится ярким светом, когда они тянутся к вашей [parsed_zone]!"),
		)

	carbon_victim.balloon_alert(caster, "начало извлечения [picked_organ.declent_ru(GENITIVE)]...")
	playsound(victim, 'sound/items/weapons/slice.ogg', 50, TRUE)
	carbon_victim.add_atom_colour(COLOR_DARK_RED, TEMPORARY_COLOUR_PRIORITY)
	if(!do_after(caster, time_it_takes, carbon_victim, extra_checks = CALLBACK(src, PROC_REF(extraction_checks), picked_organ, hand, victim, caster)))
		carbon_victim.balloon_alert(caster, "прервано!")
		carbon_victim.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, COLOR_DARK_RED)
		return FALSE

	// Visible message done before Remove()
	// Mainly so it gets across if you're taking the eyes of someone who's conscious
	if(carbon_victim == caster)
		caster.visible_message(
			span_bolddanger("[capitalize(caster.declent_ru(NOMINATIVE))] извлекает из себя [picked_organ.declent_ru(ACCUSATIVE)] из [victim.parse_zone_with_bodypart(zone_to_check, declent = GENITIVE)]!!"),
			span_userdanger("Вы извлекаете из себя [picked_organ.declent_ru(ACCUSATIVE)] из [victim.parse_zone_with_bodypart(zone_to_check, declent = GENITIVE)]!!"),
		)

	else
		carbon_victim.visible_message(
			span_bolddanger("[capitalize(caster.declent_ru(NOMINATIVE))] извлекает [picked_organ.declent_ru(ACCUSATIVE)] из [carbon_victim] из их [victim.parse_zone_with_bodypart(zone_to_check, declent = GENITIVE)]!!"),
			span_userdanger("[capitalize(caster.declent_ru(NOMINATIVE))] извлекает [picked_organ.declent_ru(ACCUSATIVE)] из вашей [victim.parse_zone_with_bodypart(zone_to_check, declent = GENITIVE)]!!"),
		)

	picked_organ.Remove(carbon_victim)
	carbon_victim.balloon_alert(caster, "извлечение [picked_organ.declent_ru(GENITIVE)]")
	carbon_victim.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, COLOR_DARK_RED)
	playsound(victim, 'sound/effects/dismember.ogg', 50, TRUE)
	if(carbon_victim.stat == CONSCIOUS)
		carbon_victim.adjust_timed_status_effect(15 SECONDS, /datum/status_effect/speech/slurring/heretic)
		carbon_victim.emote("scream")

	// We need to wait for the spell to actually finish casting to put the organ in their hands, hence, 1 ms timer.
	addtimer(CALLBACK(caster, TYPE_PROC_REF(/mob, put_in_hands), picked_organ), 0.1 SECONDS)
	return TRUE

/datum/action/cooldown/spell/touch/flesh_surgery/proc/insert_organ_into_mob(obj/item/organ/inserted_organ, obj/item/melee/touch_attack/flesh_surgery/hand, mob/living/carbon/victim, mob/living/carbon/caster)
	if(!istype(victim))
		hand.balloon_alert(caster, "no organs!")
		return FALSE

	var/zone_organ_goes_in = inserted_organ.zone
	if(!victim.get_bodypart(deprecise_zone(zone_organ_goes_in)))
		hand.balloon_alert(caster, "nowhere for organ to go!")
		return FALSE

	var/slot_organ_goes_in = inserted_organ.slot
	var/obj/item/organ/organ_victim_already_has = victim.get_organ_slot(slot_organ_goes_in)
	if(organ_victim_already_has?.organ_flags & ORGAN_VITAL|ORGAN_UNREMOVABLE)
		hand.balloon_alert(caster, "can't replace organ!")
		return FALSE

	var/time_it_takes
	var/using_on_self = victim == caster
	var/replacing_with_failing = !(organ_victim_already_has?.organ_flags & ORGAN_FAILING) && inserted_organ.organ_flags & ORGAN_FAILING
	if(using_on_self)
		time_it_takes = inserted_organ.w_class * 2 SECONDS
	else if(victim.stat == DEAD)
		time_it_takes = inserted_organ.w_class * 1 SECONDS
	else if(replacing_with_failing)
		time_it_takes = 15 SECONDS
	else
		time_it_takes = inserted_organ.w_class * 3 SECONDS

	if(using_on_self && replacing_with_failing)
		var/are_you_sure = tgui_alert(caster,
			"Are you sure you want to replace your [organ_victim_already_has.name] with a non-functional [inserted_organ.name]?",
			"Are you sure?",
			list("Yes", "No"))
		if(!are_you_sure)
			return FALSE

	if(!insertion_checks(inserted_organ, hand, victim, caster))
		return FALSE

	if(using_on_self)
		caster.visible_message(
			span_danger("[caster]'s hand glows a brilliant red as [caster.p_they()] begin[caster.p_es()] forcing [inserted_organ] into [caster.p_their()] [zone_organ_goes_in]!!"),
			span_userdanger("You begin forcing [inserted_organ] into your [zone_organ_goes_in]!")
		)
	else
		caster.visible_message(
			span_danger("[caster]'s hand glows a brilliant red as [caster.p_they()] begin[caster.p_es()] forcing [inserted_organ] into [victim]'s [zone_organ_goes_in]!!"),
			span_notice("You begin forcing [inserted_organ] into [victim]'s [zone_organ_goes_in].")
		)

	victim.balloon_alert(caster, "inserting [inserted_organ]...")
	playsound(victim, 'sound/items/weapons/slice.ogg', 50, TRUE)
	victim.add_atom_colour(COLOR_DARK_RED, TEMPORARY_COLOUR_PRIORITY)
	if(!do_after(caster, time_it_takes, victim, extra_checks = CALLBACK(src, PROC_REF(insertion_checks), inserted_organ, hand, victim, caster)))
		victim.balloon_alert(caster, "interrupted!")
		victim.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, COLOR_DARK_RED)
		return FALSE

	organ_victim_already_has = victim.get_organ_slot(slot_organ_goes_in) // This COULD have changed over the course of the do_after

	if(using_on_self)
		caster.visible_message(
			span_danger("[caster] crams [inserted_organ] into [caster.p_their()] own [zone_organ_goes_in][organ_victim_already_has ? ", forcing out [caster.p_their()] [organ_victim_already_has.name]": ""]!"),
			span_userdanger("You finish inserting [inserted_organ] into your [zone_organ_goes_in][organ_victim_already_has ? ", forcing out your [organ_victim_already_has]" : ""]!")
		)
	else
		caster.visible_message(
			span_danger("[caster] crams [inserted_organ] into [victim]'s [zone_organ_goes_in][organ_victim_already_has ? ", forcing out [victim.p_their()] [organ_victim_already_has.name]": ""]!"),
			span_notice("You finish inserting [inserted_organ] into [victim]'s [zone_organ_goes_in][organ_victim_already_has ? ", forcing out [victim.p_their()] [organ_victim_already_has.name]": ""].")
		)

	unregister_held_organ(inserted_organ)
	inserted_organ.Insert(victim)
	victim.balloon_alert(caster, "[inserted_organ] inserted")
	victim.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, COLOR_DARK_RED)
	playsound(victim, 'sound/effects/dismember.ogg', 50, TRUE)
	if(victim.stat == CONSCIOUS)
		victim.emote("scream")
		if(!using_on_self)
			victim.adjust_timed_status_effect(15 SECONDS, /datum/status_effect/speech/slurring/heretic)

	return TRUE

/// Extra checks ran while we're extracting an organ to make sure we can continue to do.
/datum/action/cooldown/spell/touch/flesh_surgery/proc/extraction_checks(obj/item/organ/picked_organ, obj/item/melee/touch_attack/flesh_surgery/hand, mob/living/carbon/victim, mob/living/carbon/caster)
	if(QDELETED(src) || QDELETED(hand) || QDELETED(picked_organ) || QDELETED(victim) || held_organ || !IsAvailable())
		return FALSE

	return TRUE

/// Extra checks ran while we're healing something (organ, mob).
/datum/action/cooldown/spell/touch/flesh_surgery/proc/heal_checks(obj/item/melee/touch_attack/flesh_surgery/hand, atom/healing, mob/living/carbon/caster)
	if(QDELETED(src) || QDELETED(hand) || QDELETED(healing) || held_organ || !IsAvailable())
		return FALSE

	return TRUE

/// Extra checks ran while we're inserting an organ.
/datum/action/cooldown/spell/touch/flesh_surgery/proc/insertion_checks(obj/item/organ/inserted_organ, obj/item/melee/touch_attack/flesh_surgery/hand, mob/living/carbon/victim, mob/living/carbon/caster)
	if(QDELETED(src) || QDELETED(hand) || QDELETED(victim) || QDELETED(inserted_organ) || (held_organ != inserted_organ) || !IsAvailable())
		return FALSE
	var/obj/item/organ/organ_victim_already_has = victim.get_organ_slot(inserted_organ.slot)
	if(organ_victim_already_has?.organ_flags & ORGAN_VITAL|ORGAN_UNREMOVABLE)
		return FALSE

	return TRUE

/obj/item/melee/touch_attack/flesh_surgery
	name = "\improper knit flesh"
	desc = "Let's go practice medicine."
	icon = 'icons/obj/weapons/hand.dmi'
	icon_state = "disintegrate"
	inhand_icon_state = "disintegrate"
