/datum/action/cooldown/spell/conjure/luzha
	name = "Я ЛУЖА БУБУБУБУ"
	desc = "Срёт лужей"
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_INCAPACITATED | AB_CHECK_HANDS_BLOCKED
	background_icon_state = "bg_spell"
	button_icon = 'icons/mob/actions/actions_cult.dmi'
	button_icon_state = "draw"
	cooldown_time = 15 MINUTES

	spell_requirements = NONE
	create_summon_timer = 4 SECONDS
	summon_radius = 0
	summon_type = list(/obj/effect/decal/cleanable/luzha)

	/// The base icon state of the spell's button icon, used for editing the icon "off"
	// button_icon = 'icons/mob/actions/actions_spells.dmi'
	// button_icon_state = "spell_default"
	// sound = null
	/// What is uttered when the user casts the spell
	// invocation = "YA BYBYBYBY"
	/// Can be "none", "whisper", "shout", "emote"
	// invocation_type = "shout"
	/// The typepath of the smoke to create on cast.
	// smoke_type = ???

/datum/action/cooldown/spell/conjure/luzha/IsAvailable(feedback)
	. = ..()
	if(!.)
		return FALSE
	var/turf/owner_turf = get_turf(owner)
	if(owner_turf.is_blocked_turf(exclude_mobs = TRUE))
		return FALSE
	return TRUE

/obj/effect/decal/cleanable/luzha
	icon = 'icons/effects/96x96.dmi'
	icon_state = "wizard_rune"
	pixel_x = -33
	pixel_y = 16
	pixel_z = -48
	plane = FLOOR_PLANE
