/datum/action/cooldown/spell/luzha
	name = "Я ЛУЖА БУБУБУБУ"
	desc = "Срёт лужей"
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_INCAPACITATED | AB_CHECK_HANDS_BLOCKED
	background_icon_state = "bg_spell"
	button_icon = 'icons/mob/actions/actions_cult.dmi'
	button_icon_state = "draw"
	cooldown_time = 15 MINUTES

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

/datum/action/cooldown/spell/luzha/IsAvailable(feedback)
	. = ..()
	if (!.)
		return

	if(!isturf(owner.loc))
		if (feedback)
			owner.balloon_alert(owner, "не достает до пола!")
		return FALSE
	return TRUE

/datum/action/cooldown/spell/luzha/Activate(trigger_flags)
	. = ..()
	if(!do_after(owner, 4 SECONDS, owner.loc))
		owner.loc.balloon_alert(owner, "прервано!")
		// Можно переделать под before_cast() и другую ересь, чтобы не ресетить
		ResetCooldown()
		return
	create_pool()

/datum/action/cooldown/spell/luzha/proc/create_pool()
	new /obj/effect/decal/cleanable/luzha(owner.loc)

/obj/effect/decal/cleanable/luzha
	icon = 'icons/effects/96x96.dmi'
	icon_state = "wizard_rune"
	pixel_x = -33
	pixel_y = 16
	pixel_z = -48
	plane = FLOOR_PLANE
