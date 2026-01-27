/obj/structure/alien/resin/door
	name = "resin door"
	desc = "A thick resin secretion that can be parted by xenomorphs."
	icon = 'icons/obj/smooth_structures/alien/resin_door.dmi'
	icon_state = "resin_door-0"
	density = TRUE
	anchored = TRUE
	opacity = TRUE
	max_integrity = 60
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_ALIEN_WALLS + SMOOTH_GROUP_ALIEN_RESIN
	canSmoothWith = SMOOTH_GROUP_ALIEN_WALLS

	/// Whether the door is open (TRUE) or closed (FALSE).
	var/state_open = FALSE
	/// Whether the door is currently operating (opening/closing).
	var/is_operating = FALSE
	/// Delay before attempting to close the door automatically (in seconds).
	var/close_delay = 3 SECONDS
	/// Sound played when the door opens.
	var/open_sound = 'sound/machines/airlock/airlockopen.ogg'
	/// Sound played when the door closes.
	var/close_sound = 'sound/machines/airlock/airlockclose.ogg'

	/// Static overlay for closed door state.
	var/mutable_appearance/close_overlay = null
	/// Temporary overlay for door animation.
	var/mutable_appearance/anim_overlay = null

	/// List of smoothing junction numbers for vertical door states
	var/list/vertical_sides = list(1, 2, 3, 5, 6, 7, 9, 10, 11, 21, 23, 38, 39, 55, 63, 74, 75, 137, 139, 203, 207, 223, 239, 255)
	/// List of smoothing junction numbers for horizontal door states
	var/list/horizontal_sides = list(0, 4, 8, 12, 13, 14, 15, 29, 31, 46, 47, 78, 79, 95, 110, 111, 127, 141, 143, 157, 159, 175, 191)

	/// Duration of animations in ticks, based on .dmi
	var/list/anim_lengths = list(
		"resinopening" = 3,
		"resinclosing" = 3,
		"resinopening-side" = 3,
		"resinclosing-side" = 3
	)

/// Initializes the door, updating its icon and air properties.
/obj/structure/alien/resin/door/Initialize(mapload)
	. = ..()
	update_icon()
	air_update_turf(TRUE, TRUE)

/// Cleans up overlays and air properties before destruction.
/obj/structure/alien/resin/door/Destroy()
	if (close_overlay)
		overlays -= close_overlay
		close_overlay = null
	if (anim_overlay)
		overlays -= anim_overlay
		anim_overlay = null
	density = FALSE
	air_update_turf(TRUE, FALSE)
	return ..()

/// Updates air properties when the door moves.
/obj/structure/alien/resin/door/Move()
	var/turf/T = loc
	. = ..()
	move_update_air(T)
	update_icon()

/// Determines if atmosphere can pass through the door based on its density.
/obj/structure/alien/resin/door/proc/CanAtmosPass(turf/source, turf/target, air_group)
	return !density

/// Handles hand attacks to operate the door.
/obj/structure/alien/resin/door/attack_hand(mob/living/user, list/modifiers)
	return try_to_operate(user)

/// Handles paw attacks to operate the door.
/obj/structure/alien/resin/door/attack_paw(mob/living/user, list/modifiers)
	return attack_hand(user, modifiers)

/// Handles alien attacks, either to operate or destroy the door.
/obj/structure/alien/resin/door/attack_alien(mob/living/carbon/alien/user, list/modifiers)
	if (!user.combat_mode)
		return try_to_operate(user)
	to_chat(user, span_notice("You begin tearing down this resin structure."))
	if (!do_after(user, 4 SECONDS, target = src) || QDELETED(src))
		return
	qdel(src)

/// Attempts to open or close the door if the user has the required organ and is not handcuffed.
/obj/structure/alien/resin/door/proc/try_to_operate(mob/living/user, bumped_open = FALSE)
	if (is_operating || QDELETED(src))
		return
	if (!iscarbon(user))
		return
	var/mob/living/carbon/C = user
	if (C.get_organ_by_type(/obj/item/organ/alien/plasmavessel))
		if (!C.handcuffed)
			operate(bumped_open)
		return
	to_chat(user, span_notice("Your lack of connection to the hive prevents the resin door from opening."))

/// Determines if the door is vertical based on its icon_state.
/obj/structure/alien/resin/door/proc/is_vertical()
	var/parts = splittext(icon_state, "-")
	var/num = 0
	if (length(parts) >= 2)
		num = text2num(parts[2]) || 0
	return (num in vertical_sides)

/// Starts the door opening or closing animation.
/obj/structure/alien/resin/door/proc/operate(bumped_open = FALSE)
	if (is_operating || QDELETED(src))
		return

	var/is_closing = state_open

	if (is_closing)
		var/list/mobs_present = locate(/mob/living) in get_turf(src)
		if (length(mobs_present))
			if (state_open)
				addtimer(CALLBACK(src, PROC_REF(mobless_try_to_operate)), close_delay)
			return

	is_operating = TRUE
	var/isvert = is_vertical()
	var/anim_state = is_closing ? (isvert ? "resinclosing-side" : "resinclosing") : (isvert ? "resinopening-side" : "resinopening")

	// Remove static closed overlay when opening to show the "hole".
	if (!state_open && close_overlay)
		overlays -= close_overlay
		close_overlay = null

	// Create and play animation overlay.
	anim_overlay = mutable_appearance(icon, anim_state)
	overlays += anim_overlay
	flick(anim_state, anim_overlay)

	// Play sound.
	playsound(loc, is_closing ? close_sound : open_sound, 50, TRUE)

	var/duration = src.anim_lengths[anim_state] || 6

	// Schedule update after animation.
	addtimer(CALLBACK(src, PROC_REF(operate_update), bumped_open), duration)

/// Updates door state, physics, and icon after animation.
/obj/structure/alien/resin/door/proc/operate_update(bumped_open)
	if (QDELETED(src))
		return

	// Update physics.
	density = !density
	opacity = !opacity
	state_open = !state_open

	// Remove animation overlay.
	if (anim_overlay)
		overlays -= anim_overlay
		anim_overlay = null

	// Add static overlay if closed.
	if (!state_open)
		close_overlay = mutable_appearance(icon, is_vertical() ? "resinclose-side" : "resinclose")
		overlays += close_overlay

	air_update_turf(TRUE, TRUE)
	icon_state = "resin_door-[smoothing_junction || 0]"
	if (smoothing_flags & SMOOTH_BITMASK)
		smooth_icon(src)

	is_operating = FALSE
	if (state_open && bumped_open)
		addtimer(CALLBACK(src, PROC_REF(mobless_try_to_operate)), close_delay)

/// Attempts to close the door automatically if no mobs are present.
/obj/structure/alien/resin/door/proc/mobless_try_to_operate()
	if (QDELETED(src))
		return

	if (!state_open)
		return

	if (is_operating)
		addtimer(CALLBACK(src, PROC_REF(mobless_try_to_operate)), close_delay)
		return

	var/list/mobs_present = locate(/mob/living) in get_turf(src)
	if (length(mobs_present))
		addtimer(CALLBACK(src, PROC_REF(mobless_try_to_operate)), close_delay)
		return
	operate()

/obj/structure/alien/resin/door/update_icon()
	. = ..()
	// Clear only static overlay (preserve anim_overlay if playing).
	if (close_overlay)
		overlays -= close_overlay
		close_overlay = null

	// Set smoothed icon.
	icon_state = "resin_door-[smoothing_junction || 0]"

	// Add static overlay if closed.
	if (!state_open)
		close_overlay = mutable_appearance(icon, is_vertical() ? "resinclose-side" : "resinclose")
		overlays += close_overlay

/obj/structure/alien/resin/door/Bumped(atom/movable/user)
	. = ..()
	if (!state_open)
		return try_to_operate(user, TRUE)
