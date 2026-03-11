/*
 * Examples of using the dodge_shift element
 * This file demonstrates various ways to apply the dodge system
 */

/*
 * EXAMPLE 1: Adding element to mob via code
 */

/mob/living/simple_animal/hostile/example_dodger
	name = "shadow stalker"
	desc = "A fast creature that can dodge attacks."

/mob/living/simple_animal/hostile/example_dodger/Initialize(mapload)
	. = ..()
	// Add dodge element: 30% chance, 20 pixel shift
	AddElement(/datum/element/dodge_shift, dodge_chance = 30, shift_distance = 20)

/*
 * EXAMPLE 2: Adding dodge via traits
 */

/// Trait that grants dodge ability
#define TRAIT_DODGE_SHIFT "dodge_shift_ability"

/// Item that grants dodge ability when worn
/obj/item/clothing/suit/armor/dodge_cloak
	name = "shadow cloak"
	desc = "A cloak that allows dodging attacks."
	icon_state = "goliath_cloak"

	/// Reference to dodge element
	var/datum/element/dodge_shift/dodge_element

/obj/item/clothing/suit/armor/dodge_cloak/equipped(mob/living/user, slot)
	. = ..()
	if(slot & ITEM_SLOT_OCLOTHING)
		user.AddElement(/datum/element/dodge_shift/advanced)
		ADD_TRAIT(user, TRAIT_DODGE_SHIFT, CLOTHING_TRAIT)

/obj/item/clothing/suit/armor/dodge_cloak/dropped(mob/living/user)
	. = ..()
	if(HAS_TRAIT(user, TRAIT_DODGE_SHIFT))
		user.RemoveElement(/datum/element/dodge_shift/advanced)
		REMOVE_TRAIT(user, TRAIT_DODGE_SHIFT, CLOTHING_TRAIT)

/*
 * EXAMPLE 3: Ability via spell/action
 */

/datum/action/cooldown/spell/dodge_mode
	name = "Dodge Mode"
	desc = "Toggles dodge mode."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "blink"
	cooldown_time = 3 SECONDS
	/// Whether dodge mode is active
	var/dodge_active = FALSE
	var/datum/element/dodge_shift/shift_type = /datum/element/dodge_shift/ultimate

/datum/action/cooldown/spell/dodge_mode/cast(mob/living/cast_on)
	. = ..()

	if(dodge_active)
		cast_on.RemoveElement(shift_type)
		dodge_active = FALSE
		name = "Dodge Mode"
		desc = "Enable dodge mode."
		to_chat(cast_on, span_warning("Dodge mode disabled."))
	else
		cast_on.AddElement(shift_type)
		dodge_active = TRUE
		name = "Dodge Mode (Active)"
		desc = "Disable dodge mode."
		to_chat(cast_on, span_notice("Dodge mode enabled!"))

	build_all_button_icons()

/datum/action/cooldown/spell/dodge_mode/Remove(mob/living/remove_from)
	. = ..()
	// Disable dodge mode when ability is removed
	if(dodge_active && !QDELETED(remove_from))
		remove_from.RemoveElement(shift_type)
		dodge_active = FALSE

/*
 * EXAMPLE 4: Status effect with dodge
 */

/datum/status_effect/dodge_buff
	id = "dodge_buff"
	duration = 30 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/dodge_buff

/datum/status_effect/dodge_buff/on_apply()
	. = ..()
	owner.AddElement(/datum/element/dodge_shift/advanced)
	return TRUE

/datum/status_effect/dodge_buff/on_remove()
	. = ..()
	owner.RemoveElement(/datum/element/dodge_shift/advanced)

/atom/movable/screen/alert/status_effect/dodge_buff
	name = "Dodge Buff"
	desc = "You feel a surge of agility!"
	icon_state = "template"

/*
 * EXAMPLE 5: Extended element with projectile dodge
 * IMPORTANT: Projectiles require additional handling via COMSIG_ATOM_PRE_BULLET_ACT
 */

/datum/element/dodge_shift/projectile/Attach(datum/target, ...)
	. = ..()
	if(. == ELEMENT_INCOMPATIBLE)
		return

	// Additionally register signal for projectiles
	RegisterSignal(target, COMSIG_ATOM_PRE_BULLET_ACT, PROC_REF(on_projectile_act))

/datum/element/dodge_shift/projectile/Detach(datum/target)
	UnregisterSignal(target, COMSIG_ATOM_PRE_BULLET_ACT)
	return ..()

/datum/element/dodge_shift/projectile/proc/on_projectile_act(mob/living/source, obj/projectile/hitting_projectile, def_zone)
	SIGNAL_HANDLER

	if(!TIMER_COOLDOWN_FINISHED(source, COOLDOWN_DODGE_SHIFT))
		return

	if(!prob(dodge_chance))
		return

	if(!(source.mobility_flags & MOBILITY_MOVE))
		return

	perform_dodge(source, hitting_projectile, hitting_projectile.name)
	TIMER_COOLDOWN_START(source, COOLDOWN_DODGE_SHIFT, cooldown_time)

	return COMPONENT_BULLET_PIERCED

/*
 * EXAMPLE 6: Reagent granting dodge
 */

/datum/reagent/medicine/dodge_serum
	name = "Dodge Serum"
	description = "A chemical cocktail that temporarily increases reflexes."
	color = "#00FFFF"
	overdose_threshold = 15

/datum/reagent/medicine/dodge_serum/on_mob_add(mob/living/source)
	. = ..()
	source.AddElement(/datum/element/dodge_shift/basic)

/datum/reagent/medicine/dodge_serum/on_mob_delete(mob/living/source)
	. = ..()
	source.RemoveElement(/datum/element/dodge_shift/basic)

/datum/reagent/medicine/dodge_serum/overdose_process(mob/living/source, seconds_per_tick)
	. = ..()
	// Overdose causes dizziness
	source.adjust_dizzy(5)
