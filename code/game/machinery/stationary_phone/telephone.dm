#define MAX_RANGE 3

/obj/item/telephone
	name = "telephone"
	icon = 'icons/obj/machines/phone.dmi'
	lefthand_file = 'icons/mob/inhands/equipment/phone_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/phone_righthand.dmi'
	icon_state = "rpb_phone"
	w_class = WEIGHT_CLASS_BULKY
	var/obj/structure/transmitter/attached_to
	var/raised = FALSE
	var/datum/beam/telephone_beam = null
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
	if(attached_to && get_dist(user, attached_to) > MAX_RANGE)
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
			update_beam()
			if(!do_zlevel_check())
				attached_to.recall_phone()
			if(attached_to && !ismob(old_loc))
				if(get_dist(attached_to, src) > MAX_RANGE)
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
	update_beam()

/obj/item/telephone/dropped(mob/user)
	. = ..()
	UnregisterSignal(user, COMSIG_MOB_SAY)
	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
	set_raised(FALSE, user)
	update_beam()

/obj/item/telephone/proc/on_mob_move(atom/old_loc, dir)
	SIGNAL_HANDLER
	if(attached_to)
		if(!do_zlevel_check())
			attached_to.recall_phone()
		if(get_dist(attached_to, src) > MAX_RANGE)
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
	if(!attached_to)
		return
	var/obj/structure/transmitter/current_caller = attached_to.current_call
	if(!current_caller)
		return
	if(!ismob(loc))
		return
	if(!raised || !current_caller.attached_to?.raised)
		to_chat(loc, span_red("You hear some muffled sounds from the phone."))
		return
	send_speech(message, 0, spans = list(SPAN_TAPE_RECORDER), message_language = L)

/obj/item/telephone/proc/attach_to(obj/structure/transmitter/to_attach)
	if(!istype(to_attach))
		return
	remove_attached()
	attached_to = to_attach
	update_beam()

/obj/item/telephone/proc/remove_attached()
	attached_to = null
	update_beam()

/obj/item/telephone/proc/update_beam()
	if(telephone_beam)
		qdel(telephone_beam)
		telephone_beam = null

	if(!attached_to || loc == attached_to)
		return

	if(loc.z != attached_to.z)
		return

	if(ismob(loc))
		telephone_beam = loc.Beam(attached_to, icon_state="wire", icon = "icons/effects/beam.dmi", time = INFINITY, maxdistance = MAX_RANGE)
	else
		telephone_beam = Beam(attached_to, icon_state="wire", icon = "icons/effects/beam.dmi", time = INFINITY, maxdistance = MAX_RANGE)

/obj/item/telephone/proc/set_raised(to_raise, mob/living/carbon/human/H)
	if(!istype(H))
		return
	if(!to_raise)
		raised = FALSE
		icon_state = "rpb_phone"
	else
		raised = TRUE
		icon_state = "rpb_phone_ear"

/obj/item/telephone/proc/do_zlevel_check()
	if(!attached_to || !loc.z || !attached_to.z)
		return FALSE
	if(loc.z != attached_to.z)
		return FALSE
	if(zlevel_transfer)
		if(loc.z == attached_to.z)
			zlevel_transfer = FALSE
			if(zlevel_transfer_timer)
				deltimer(zlevel_transfer_timer)
			UnregisterSignal(attached_to, COMSIG_MOVABLE_MOVED)
			return FALSE
		return TRUE
	if(attached_to && loc.z != attached_to.z)
		return TRUE
	return TRUE

/obj/item/telephone/interact(mob/user)
	if(attached_to && get_dist(user, attached_to) > MAX_RANGE)
		return FALSE
	return ..()

/obj/item/telephone/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(.)
		if(attached_to)
			update_beam()
			if(attached_to && !ismob(old_loc))
				if(get_dist(attached_to, src) > MAX_RANGE)
					if(ismob(loc))
						var/mob/M = loc
						M.dropItemToGround(src, TRUE)
					else
						attached_to.recall_phone()


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

#undef MAX_RANGE
