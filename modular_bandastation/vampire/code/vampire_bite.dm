/// Starts vampire blood draining from the normal unarmed combat flow.
/datum/component/vampire_biter
	dupe_mode = COMPONENT_DUPE_UNIQUE

/datum/component/vampire_biter/Initialize(...)
	. = ..()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/vampire_biter/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_LIVING_EARLY_UNARMED_ATTACK, PROC_REF(try_bite))

/datum/component/vampire_biter/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_LIVING_EARLY_UNARMED_ATTACK)

/datum/component/vampire_biter/proc/try_bite(mob/living/carbon/human/source, atom/target, proximity_flag, list/modifiers)
	SIGNAL_HANDLER
	if(!proximity_flag || !source.combat_mode || LAZYACCESS(modifiers, RIGHT_CLICK) || source.get_active_held_item() || source.zone_selected != BODY_ZONE_HEAD)
		return
	if(!istype(target, /mob/living/carbon/human))
		return
	var/datum/antagonist/vampire/vampire = source.mind?.has_antag_datum(/datum/antagonist/vampire)
	if(!vampire || vampire.draining || target == source)
		return
	INVOKE_ASYNC(vampire, TYPE_PROC_REF(/datum/antagonist/vampire, handle_bloodsucking), target)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/// Shared requirements for starting a bite, maintaining it during do_after, and draining a tick.
/// Dead victims are valid: only the usable-blood reward requires a living victim.
/datum/antagonist/vampire/proc/can_bloodsuck(mob/living/carbon/human/caster, mob/living/carbon/human/victim)
	if(QDELETED(src) || QDELETED(caster) || QDELETED(victim) || !ishuman(caster) || !ishuman(victim))
		return FALSE
	if(owner?.current != caster || victim == caster || !caster.Adjacent(victim))
		return FALSE
	if(!caster.combat_mode || caster.zone_selected != BODY_ZONE_HEAD || caster.get_active_held_item() || caster.incapacitated)
		return FALSE
	if(!caster.can_unarmed_attack())
		return FALSE
	if(caster.is_mouth_covered())
		to_chat(caster, span_warning("Ваша маска или намордник не позволяют укусить [victim.declent_ru(ACCUSATIVE)]!"))
		return FALSE
	var/datum/species/species = victim.dna.species
	if(species.exotic_bloodtype && (species.exotic_bloodtype::reagent_type != /datum/reagent/blood))
		to_chat(caster, span_warning("В [victim.declent_ru(PREPOSITIONAL)] не кровь!"))
		return FALSE
	if(victim.get_blood_volume() <= 0)
		to_chat(caster, span_warning("В [victim.declent_ru(PREPOSITIONAL)] нет крови!"))
		return FALSE
	if(HAS_TRAIT(victim, TRAIT_VAMPIRE_LIKE))
		to_chat(caster, span_warning("Ваши клыки не могут пронзить холодную плоть [victim.declent_ru(GENITIVE)]!"))
		return FALSE
	return TRUE

#define BLOOD_GAINED_MODIFIER 0.5

/// Eligibility for usable blood, independent of whether we can physically bite the victim.
/datum/antagonist/vampire/proc/can_gain_usable_blood_from(mob/living/carbon/target)
	return !QDELETED(target) \
		&& target.stat != DEAD \
		&& drained_humans[REF(target)] < BLOOD_DRAIN_LIMIT \
		&& (target.ckey || target.get_ghost(FALSE))

/// Performs one bite's drain and rewards. Returns the amount physically drained, including from corpses.
/datum/antagonist/vampire/proc/bloodsuck_tick(mob/living/carbon/human/caster, mob/living/carbon/human/victim, drain_amount = 25)
	if(drain_amount <= 0 || !can_bloodsuck(caster, victim))
		return 0
	caster.do_attack_animation(victim, ATTACK_EFFECT_BITE)
	var/blood_drained = -victim.adjust_blood_volume(-drain_amount)
	if(!blood_drained)
		return 0
	var/usable_blood_gain = can_gain_usable_blood_from(victim) ? min(20, blood_drained) * BLOOD_GAINED_MODIFIER : 0
	if(usable_blood_gain)
		usable_blood_gain = adjust_blood(victim, usable_blood_gain)
		to_chat(caster, span_notice("<b>Вы накопили [bloodtotal] ед. крови; для использования осталось [bloodusable].</b>"))
	else
		to_chat(caster, span_notice("<b>Питание кровью [victim.declent_ru(GENITIVE)] утоляет ваш голод, но не даёт доступной крови.</b>"))
	caster.set_nutrition(min(NUTRITION_LEVEL_WELL_FED, caster.nutrition + (usable_blood_gain || 5)), forced = TRUE)
	return blood_drained

/datum/antagonist/vampire/proc/handle_bloodsucking(mob/living/carbon/human/target_human, suck_rate = 5 SECONDS)
	var/mob/living/carbon/human/caster = owner?.current
	if(draining || !can_bloodsuck(caster, target_human))
		return
	draining = target_human
	var/blood_volume_warning = BLOOD_VOLUME_MAXIMUM

	log_combat(caster, target_human, "bitten & drained of blood (vampire)")
	caster.visible_message(
		span_danger("[caster.declent_ru(NOMINATIVE)] грубо хватает [target_human.declent_ru(ACCUSATIVE)] за шею и вонзает свои клыки!"),
		span_danger("Вы вонзаете клыки в [target_human.declent_ru(ACCUSATIVE)] и начинаете высасывать [target_human.ru_p_them()] кровь."),
		span_notice("Вы слышите влажный чавкающий звук."),
	)

	var/datum/callback/bite_checks = CALLBACK(src, PROC_REF(can_bloodsuck), caster, target_human)
	while(do_after(caster, suck_rate, target_human, extra_checks = bite_checks, cog_icon = null))
		if(!bloodsuck_tick(caster, target_human))
			break

		if(target_human.blood_volume)
			if(target_human.blood_volume <= BLOOD_VOLUME_BAD && blood_volume_warning > BLOOD_VOLUME_BAD)
				to_chat(caster, span_danger("Объём крови вашей жертвы опасно низок."))
			else if(target_human.blood_volume <= BLOOD_VOLUME_OKAY && blood_volume_warning > BLOOD_VOLUME_OKAY)
				to_chat(caster, span_warning("У вашей жертвы слишком мало крови!"))
			blood_volume_warning = target_human.blood_volume
		else
			to_chat(caster, span_warning("Вы обескровили свою жертву!"))
			break

	if(!QDELETED(src))
		draining = null
	if(!QDELETED(caster) && !QDELETED(target_human))
		to_chat(caster, span_notice("Вы прекращаете высасывать кровь из [target_human.declent_ru(GENITIVE)]."))

#undef BLOOD_GAINED_MODIFIER

/datum/reagent/blood/expose_mob(mob/living/exposed_mob, methods = TOUCH, reac_volume)
	. = ..()
	if(!(methods & INGEST) || !ishuman(exposed_mob))
		return
	var/mob/living/carbon/human/affected_human = exposed_mob
	if(HAS_TRAIT(affected_human, TRAIT_VAMPIRE))
		affected_human.set_nutrition(min(NUTRITION_LEVEL_WELL_FED, affected_human.nutrition + reac_volume / 5), forced = TRUE)
