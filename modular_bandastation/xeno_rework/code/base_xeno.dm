///  MODULE _XENO_REDO

/mob/living/carbon/alien/adult/banda
	name = "rare bugged alien"
	icon = 'modular_bandastation/xeno_rework/icons/big_xenos.dmi'
	rotate_on_lying = FALSE
	base_pixel_x = -16 //All of the xeno sprites are 64x64, and we want them to be level with the tile they are on, much like oversized quirk users
	mob_size = MOB_SIZE_LARGE
	layer = LARGE_MOB_LAYER //above most mobs, but below speechbubbles
	plane = ABOVE_GAME_PLANE
	maptext_height = 64
	maptext_width = 64
	pressure_resistance = 200

	/// What icon file update_held_items will look for when making inhands for xenos
	var/alt_inhands_file = 'modular_bandastation/xeno_rework/icons/big_xenos.dmi'
	/// Setting this will give a xeno generic_evolve set to evolve them into this type
	var/next_evolution
	/// Keeps track of if a xeno has evolved recently, if so then we prevent them from evolving until that time is up
	var/has_evolved_recently = FALSE
	/// How long xenos should be unable to evolve after recently evolving
	var/evolution_cooldown_time = 90 SECONDS
	/// Determines if a xeno is unable to use abilities
	var/unable_to_use_abilities = FALSE
	/// Pixel X shifting of the on fire overlay
	var/on_fire_pixel_x = 16
	/// Pixel Y shifting of the on fire overlay
	var/on_fire_pixel_y = 16


/mob/living/carbon/alien/adult/banda/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/seethrough_mob)

	GRANT_ACTION(/datum/action/cooldown/alien/banda/sleepytime)
	if(next_evolution)
		GRANT_ACTION(/datum/action/cooldown/alien/banda/generic_evolve)

	pixel_x = -16

	ADD_TRAIT(src, TRAIT_XENO_HEAL_AURA, TRAIT_XENO_INNATE)
	ADD_TRAIT(src, TRAIT_SLEEPIMMUNE, TRAIT_XENO_INNATE)
	real_name = "alien [caste]"

/// Called when a larva or xeno evolves, adds a configurable timer on evolving again to the xeno
/mob/living/carbon/alien/adult/banda/proc/has_just_evolved()
	if(has_evolved_recently)
		return
	has_evolved_recently = TRUE
	addtimer(CALLBACK(src, PROC_REF(can_evolve_once_again)), evolution_cooldown_time)

/// Allows xenos to evolve again if they are currently unable to
/mob/living/carbon/alien/adult/banda/proc/can_evolve_once_again()
	if(!has_evolved_recently)
		return
	has_evolved_recently = FALSE

/datum/action/cooldown/alien/banda
	button_icon = 'modular_bandastation/xeno_rework/icons/xeno_actions.dmi'
	/// Some xeno abilities block other abilities from being used, this allows them to get around that in cases where it is needed
	var/can_be_used_always = FALSE

/datum/action/cooldown/alien/banda/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return FALSE

	if(can_be_used_always)
		return TRUE

	var/mob/living/carbon/alien/adult/banda/owner_alien = owner
	if(!istype(owner_alien) || owner_alien.unable_to_use_abilities)
		return FALSE

/datum/movespeed_modifier/alien_quick
	multiplicative_slowdown = -0.5

/datum/movespeed_modifier/alien_slow
	multiplicative_slowdown = 0.5

/datum/movespeed_modifier/alien_heavy
	multiplicative_slowdown = 1

/datum/movespeed_modifier/alien_big
	multiplicative_slowdown = 2

/mob/living/carbon/alien/adult/banda/update_held_items()
	..()
	remove_overlay(HANDS_LAYER)
	var/list/hands = list()

	var/obj/item/l_hand = get_item_for_held_index(1)
	if(l_hand)
		var/itm_state = l_hand.inhand_icon_state
		if(!itm_state)
			itm_state = l_hand.icon_state
		var/mutable_appearance/l_hand_item = mutable_appearance(alt_inhands_file, "[itm_state][caste]_l", -HANDS_LAYER)
		if(l_hand.blocks_emissive)
			l_hand_item.overlays += emissive_blocker(l_hand_item.icon, l_hand_item.icon_state, alpha = l_hand_item.alpha)
		hands += l_hand_item

	var/obj/item/r_hand = get_item_for_held_index(2)
	if(r_hand)
		var/itm_state = r_hand.inhand_icon_state
		if(!itm_state)
			itm_state = r_hand.icon_state
		var/mutable_appearance/r_hand_item = mutable_appearance(alt_inhands_file, "[itm_state][caste]_r", -HANDS_LAYER)
		if(r_hand.blocks_emissive)
			r_hand_item.overlays += emissive_blocker(r_hand_item.icon, r_hand_item.icon_state, alpha = r_hand_item.alpha)
		hands += r_hand_item

	overlays_standing[HANDS_LAYER] = hands
	apply_overlay(HANDS_LAYER)

/mob/living/carbon/proc/get_max_plasma()
	var/obj/item/organ/alien/plasmavessel/vessel = get_organ_by_type(/obj/item/organ/alien/plasmavessel)
	if(!vessel)
		return -1
	return vessel.max_plasma

/mob/living/carbon/alien/adult/banda/alien_evolve(mob/living/carbon/alien/new_xeno, is_it_a_larva)
	var/mob/living/carbon/alien/adult/banda/xeno_to_transfer_to = new_xeno

	xeno_to_transfer_to.setDir(dir)
	if(!islarva(xeno_to_transfer_to))
		xeno_to_transfer_to.has_just_evolved()
	if(mind)
		mind.name = xeno_to_transfer_to.real_name
		mind.transfer_to(xeno_to_transfer_to)
	qdel(src)

/mob/living/carbon/alien/adult/banda/findQueen() //Yes we really do need to do this whole thing to let the queen finder work
	if(hud_used)
		hud_used.alien_queen_finder.cut_overlays()
		var/mob/queen = get_alien_type(/mob/living/carbon/alien/adult/banda/queen)
		if(!queen)
			return
		var/turf/Q = get_turf(queen)
		var/turf/A = get_turf(src)
		if(Q.z != A.z) //The queen is on a different Z level, we cannot sense that far.
			return
		var/Qdir = get_dir(src, Q)
		var/Qdist = get_dist(src, Q)
		var/finder_icon = "finder_center" //Overlay showed when adjacent to or on top of the queen!
		switch(Qdist)
			if(2 to 7)
				finder_icon = "finder_near"
			if(8 to 20)
				finder_icon = "finder_med"
			if(21 to INFINITY)
				finder_icon = "finder_far"
		var/image/finder_eye = image('icons/hud/screen_alien.dmi', finder_icon, dir = Qdir)
		hud_used.alien_queen_finder.add_overlay(finder_eye)
