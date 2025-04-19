/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//			TG OVERWRITES

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Prevents Bloodsuckers from getting affected by blood
/mob/living/carbon/human/handle_blood(seconds_per_tick, times_fired)
	if(mind && IS_BLOODSUCKER(src))
		return FALSE
	return ..()

/datum/reagent/blood/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message=TRUE, touch_protection=0)
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = IS_BLOODSUCKER(exposed_mob)
	if(!bloodsuckerdatum)
		return ..()
	bloodsuckerdatum.AddBloodVolume(round(reac_volume, 0.1))

/mob/living/carbon/transfer_blood_to(atom/movable/AM, amount, forced, ignore_incompatibility)
	. = ..()

	var/datum/antagonist/bloodsucker/bloodsuckerdatum = mind?.has_antag_datum(/datum/antagonist/bloodsucker)
	bloodsuckerdatum?.bloodsucker_blood_volume -= amount

/// Prevents using a Memento Mori
/obj/item/clothing/neck/necklace/memento_mori/memento(mob/living/carbon/human/user)
	if(IS_BLOODSUCKER(user))
		to_chat(user, span_warning("Мементо Мори замечает вашу осквернённую душу и отказывается реагировать..."))
		return
	return ..()

// Used when analyzing a Bloodsucker, Masquerade will hide brain traumas (Unless you're a Beefman)
/mob/living/carbon/get_traumas()
	if(!mind)
		return ..()
	if(IS_BLOODSUCKER(src) && HAS_TRAIT(src, TRAIT_MASQUERADE))
		return
	return ..()

/mob/living/carbon/human/natural_bodytemperature_stabilization(datum/gas_mixture/environment, seconds_per_tick, times_fired)
	// Return 0 as your natural temperature. Species proc handle_environment() will adjust your temperature based on this.
	if(HAS_TRAIT(src, TRAIT_COLDBLOODED))
		return 0
	return ..()

// Used to keep track of how much Blood we've drank so far
/mob/living/get_status_tab_items()
	. = ..()
	if(!mind)
		return ..()
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = mind.has_antag_datum(/datum/antagonist/bloodsucker)
	if(bloodsuckerdatum)
		. += ""
		. += "Blood Drank: [bloodsuckerdatum.total_blood_drank]"
		if(bloodsuckerdatum.has_task)
			. += "Task Blood Drank: [bloodsuckerdatum.task_blood_drank]"

/datum/outfit/bloodsucker_outfit
	name = "Bloodsucker outfit (Preview only)"
	suit = /obj/item/clothing/suit/costume/dracula

/datum/outfit/bloodsucker_outfit/post_equip(mob/living/carbon/human/enrico, visualsOnly=FALSE)
	enrico.hairstyle = "Undercut"
	enrico.hair_color = "FFF"
	enrico.skin_tone = "african2"
	enrico.eye_color_left = "#663300"
	enrico.eye_color_right = "#663300"

	enrico.update_body(is_creating = TRUE)

/* Handle returning from ghost/observer to body for special roles
/mob/living/carbon/human/mind_initialize()
	. = ..()
	if(!mind)
		return
	// Check for bloodsucker, vassal or hunter traits when returning to body
	if(IS_BLOODSUCKER(src) || IS_VASSAL(src) || HAS_TRAIT(mind, TRAIT_BLOODSUCKER_HUNTER))
		see_invisible = SEE_INVISIBLE_CRYPT
*/
/mob/set_invis_see()
	if(!mind)
		return ..()
	if(IS_BLOODSUCKER(src) || IS_VASSAL(src) || IS_MONSTERHUNTER(src))
		see_invisible = SEE_INVISIBLE_CRYPT
		return
	return ..()
