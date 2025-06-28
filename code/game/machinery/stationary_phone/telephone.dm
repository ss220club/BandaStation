/obj/item/telephone
	name = "telephone"
	icon = 'icons/obj/machines/phone.dmi'
	lefthand_file = 'icons/mob/inhands/equipment/phone_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/phone_righthand.dmi'
	icon_state = "rpb_phone"
	w_class = WEIGHT_CLASS_BULKY
	var/obj/structure/transmitter/attached_to
	var/datum/beam/tether = null
	// var/datum/effects/tethering/tether_effect
	var/raised = FALSE
	var/zlevel_transfer = FALSE
	var/zlevel_transfer_timer = TIMER_ID_NULL
	var/zlevel_transfer_timeout = 5 SECONDS

/obj/item/telephone/Initialize(mapload)
	. = ..()
	if(istype(loc, /obj/structure/transmitter))
		attach_to(loc)

/obj/item/telephone/Destroy()
	remove_attached()
	return ..()

/obj/item/telephone/examine(mob/user)
	. = ..()
	. += span_notice("Activate item to lower [src] to stop talking and listening to it.")

/obj/item/telephone/interact(mob/user)
	if(attached_to && get_dist(user, attached_to) > attached_to.range)
		return FALSE

/obj/item/telephone/attack_self(mob/user)
	..()
	if(raised)
		set_raised(FALSE, user)
		to_chat(user, span_notice("You lower [src]."))
	else
		set_raised(TRUE, user)
		to_chat(user, span_notice("You raise [src] to your ear."))

/obj/item/telephone/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(.)
		if(attached_to)
			reset_tether()
			if(!do_zlevel_check())
				attached_to.recall_phone()
			if(attached_to && !ismob(old_loc))
				if(get_dist(attached_to, src) > attached_to.range)
					if(ismob(loc))
						var/mob/M = loc
						M.dropItemToGround(src, TRUE)
					else
						attached_to.recall_phone()

/obj/item/telephone/on_enter_storage(obj/item/storage/S)
	. = ..()
	if(attached_to)
		attached_to.recall_phone()

/obj/item/telephone/equipped(mob/user, slot, initial)
	. = ..()
	RegisterSignal(user, COMSIG_MOB_SAY, PROC_REF(handle_speak))
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_mob_move))
	set_raised(TRUE, user)

/obj/item/telephone/dropped(mob/user)
	. = ..()
	UnregisterSignal(user, COMSIG_MOB_SAY)
	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
	set_raised(FALSE, user)

/obj/item/telephone/proc/on_mob_move(atom/old_loc, dir)
	SIGNAL_HANDLER
	if(attached_to)
		if(!do_zlevel_check())
			attached_to.recall_phone()
		if(get_dist(attached_to, src) > attached_to.range)
			if(ismob(loc))
				var/mob/M = loc
				M.dropItemToGround(src, TRUE)
			else
				attached_to.recall_phone()

/obj/item/telephone/proc/handle_speak(mob/speaking, list/speech_args)
	SIGNAL_HANDLER
	if(!attached_to || loc == attached_to)
		UnregisterSignal(speaking, COMSIG_MOB_SAY)
		return
	attached_to.handle_speak(speaking, speech_args)

/obj/item/telephone/proc/handle_hear(mob/speaking, list/speech_args)
	var/message = speech_args[SPEECH_MESSAGE]
	var/datum/language/L = speech_args[SPEECH_LANGUAGE]
	// var/m_spans = speech_args[SPEECH_SPANS]
	if(!attached_to)
		return
	var/obj/structure/transmitter/T = attached_to.get_calling_phone()
	if(!T)
		return
	if(!ismob(loc))
		return
	if(!raised || !T.attached_to?.raised) //listener or speaker lowered the phone and they can't hear each other
		to_chat(loc, span_red("You hear some muffled sounds from the phone."))
		return
	send_speech(message, 0, spans = list(SPAN_TAPE_RECORDER), message_language = L)
	// var/composed_message = compose_message(M, L, message, null, spans, source = src)
	// M.Hear(composed_message, vname, L, message, null, spans, source = src)
	// to_chat(M, "[span_purple("[vname] says: ")] [span_notice(message)]")

	// var/loudness = 0
	// if(raised)
	// 	loudness = 3
	// var/mob/M = loc
	// var/vname = T.phone_id
	// if(M == speaking)
	// 	vname = attached_to.phone_id
	// M.hear_radio(
	// 	message, "says", L, part_a = "<span class='purple'><span class='name'>",
	// 	part_b = "</span><span class='message'> ", vname = vname,
	// 	speaker = speaking, command = loudness, no_paygrade = TRUE)

/obj/item/telephone/proc/attach_to(obj/structure/transmitter/to_attach)
	if(!istype(to_attach))
		return
	remove_attached()
	attached_to = to_attach

/obj/item/telephone/proc/remove_attached()
	attached_to = null
	reset_tether()

/obj/item/telephone/proc/reset_tether()
	QDEL_NULL(tether)
	if(!attached_to || loc == attached_to)
		return
	if(ismob(loc))
		tether = loc.Beam(attached_to, icon_state="wire", icon = "modular_bluemoon/icons/effects/beam.dmi", time = INFINITY, maxdistance = INFINITY)
	else
		tether = Beam(attached_to, icon_state="wire", icon = "modular_bluemoon/icons/effects/beam.dmi", time = INFINITY, maxdistance = INFINITY)
// 	SIGNAL_HANDLER
// 	if (tether_effect)
// 		UnregisterSignal(tether_effect, COMSIG_PARENT_QDELETING)
// 		if(!QDESTROYING(tether_effect))
// 			qdel(tether_effect)
// 		tether_effect = null
// 	if(!do_zlevel_check())
// 		on_beam_removed()

// /obj/item/telephone/proc/on_beam_removed()
// 	if(!attached_to)
// 		return
// 	if(loc == attached_to)
// 		return
// 	if(get_dist(attached_to, src) > attached_to.range)
// 		attached_to.recall_phone()
// 	var/atom/tether_to = src
// 	if(loc != get_turf(src))
// 		tether_to = loc
// 		if(tether_to.loc != get_turf(tether_to))
// 			attached_to.recall_phone()
// 			return
// 	var/atom/tether_from = attached_to
// 	if(attached_to.tether_holder)
// 		tether_from = attached_to.tether_holder
// 	if(tether_from == tether_to)
// 		return
// 	var/list/tether_effects = apply_tether(tether_from, tether_to, range = attached_to.range, icon = "wire", always_face = FALSE)
// 	tether_effect = tether_effects["tetherer_tether"]
// 	RegisterSignal(tether_effect, COMSIG_PARENT_QDELETING, PROC_REF(reset_tether))

/obj/item/telephone/proc/set_raised(to_raise, mob/living/carbon/human/H)
	if(!istype(H))
		return
	if(!to_raise)
		raised = FALSE
		icon_state = "rpb_phone"
		// var/obj/item/device/radio/R = H.get_type_in_ears(/obj/item/device/radio)
		// R?.on = TRUE
	else
		raised = TRUE
		icon_state = "rpb_phone_ear"
		// var/obj/item/device/radio/R = H.get_type_in_ears(/obj/item/device/radio)
		// R?.on = FALSE
	// H.update_inv_r_hand()
	// H.update_inv_l_hand()

/obj/item/telephone/proc/do_zlevel_check()
	. = TRUE
	if(!attached_to || !loc.z || !attached_to.z)
		return FALSE
	if(loc.z != attached_to.z)
		return FALSE
	// if(zlevel_transfer)
	// 	if(loc.z == attached_to.z)
	// 		zlevel_transfer = FALSE
	// 		if(zlevel_transfer_timer)
	// 			deltimer(zlevel_transfer_timer)
	// 		UnregisterSignal(attached_to, COMSIG_MOVABLE_MOVED)
	// 		return FALSE
	// 	return TRUE
	// if(attached_to && loc.z != attached_to.z)
	// 	// zlevel_transfer = TRUE
	// 	// zlevel_transfer_timer = addtimer(CALLBACK(src, PROC_REF(try_doing_tether)), zlevel_transfer_timeout, TIMER_UNIQUE|TIMER_STOPPABLE)
	// 	// RegisterSignal(attached_to, COMSIG_MOVABLE_MOVED, PROC_REF(transmitter_move_handler))
	// 	return TRUE
	// return FALSE

// /obj/item/telephone/proc/transmitter_move_handler(datum/source)
// 	SIGNAL_HANDLER
// 	zlevel_transfer = FALSE
// 	if(zlevel_transfer_timer)
// 		deltimer(zlevel_transfer_timer)
// 	UnregisterSignal(attached_to, COMSIG_MOVABLE_MOVED)
	// reset_tether()

// /obj/item/telephone/proc/try_doing_tether()
// 	zlevel_transfer_timer = TIMER_ID_NULL
// 	zlevel_transfer = FALSE
// 	UnregisterSignal(attached_to, COMSIG_MOVABLE_MOVED)
// 	reset_tether()


	/// TELEPHONE TYPES ///

	/// ETC ///

/datum/looping_sound/telephone/ring
	start_sound = 'sound/machines/telephone/dial.ogg'
	start_length = 3.2 SECONDS
	mid_sounds = 'sound/machines/telephone/ring_outgoing.ogg'
	mid_length = 2.1 SECONDS
	volume = 20

/datum/looping_sound/telephone/busy
	start_sound = 'sound/machines/telephone/callstation_unavailable.ogg'
	start_length = 5.7 SECONDS
	mid_sounds = 'sound/machines/telephone/phone_busy.ogg'
	mid_length = 5 SECONDS
	volume = 50

/datum/looping_sound/telephone/hangup
	start_sound = 'sound/machines/telephone/remote_hangup.ogg'
	start_length = 0.6 SECONDS
	mid_sounds = 'sound/machines/telephone/phone_busy.ogg'
	mid_length = 5 SECONDS
	volume = 50
