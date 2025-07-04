GLOBAL_LIST_EMPTY_TYPED(transmitters, /obj/structure/transmitter)

#define COMSIG_TRANSMITTER_UPDATE_ICON "transmitter_update_icon"
#define TRANSMITTER_UNAVAILABLE(T) (!T.attached_to || !T.enabled)

#define PHONE_NET_PUBLIC    "Public"
#define PHONE_NET_COMMAND   "Command"
#define PHONE_NET_CENTCOMM  "CentComm"
#define PHONE_NET_SYNDIE    "Syndicate"

#define PHONE_DND_FORCED 2
#define PHONE_DND_ON 1
#define PHONE_DND_OFF 0
#define PHONE_DND_FORBIDDEN -1

#define SINGLE_CALL_PRICE 5
#define RING_TIMEOUT 4 SECONDS

#define STATUS_INBOUND "Inbound call"
#define STATUS_ONGOING "Ongoing call"
#define STATUS_OUTGOING "Outgoing call"
#define STATUS_IDLE "Idle"

#define COMMSIG_OFFHOOK             "CS_OF" // The telephone is removed from the hook
#define COMMSIG_DIALTONE            "CS_DT" // The phone should play the dialtone sound, indicating it's ready for dialing
#define COMMSIG_DIAL                "CS_DL"	// The phone sends a request to the CTE, attempting to call a `phone_id`
#define COMMSIG_RINGING             "CS_RG" // The phone rings, being ready to pick up
#define COMMSIG_RINGBACK            "CS_RB"	// The caller hears the ringback sounds, waiting for the other side to pick up
#define COMMSIG_BUSY                "CS_BS"	// The target phone is busy
#define COMMSIG_NUMBER_NOT_FOUND    "CS_NF"	// The CTE couldn't find the device with such `phone_id`
#define COMMSIG_ANSWER              "CS_AN"	// The phone should initialize the call
#define COMMSIG_TALK                "CS_TK"	// The signal sent with the voice message itself
#define COMMSIG_HANGUP              "CS_HU"	// The other side has hanged up
#define COMMSIG_TIMEOUT             "CS_TO" // The line has been inactive for over 30 seconds

#define MAX_RANGE 3

/obj/structure/transmitter/proc/process_commsig(commsig, data)
	stop_loops()
	switch(commsig)
		if(COMMSIG_DIALTONE)
			status = STATUS_IDLE
			dialtone_loop.start()
			update_icon()

		if(COMMSIG_RINGING)
			status = STATUS_INBOUND
			var/obj/structure/transmitter/caller = GLOB.transmitters[data]
			if(caller)
				current_call = caller
				try_ring()
			update_icon()

		if(COMMSIG_RINGBACK)
			status = STATUS_OUTGOING
			outring_loop.start()
			update_icon()

		if(COMMSIG_BUSY)
			status = STATUS_IDLE
			playsound(src, 'sound/machines/telephone/busy.ogg', 50)
			end_call(forced = TRUE)
			update_icon()

		if(COMMSIG_NUMBER_NOT_FOUND)
			status = STATUS_IDLE
			playsound(src, 'sound/machines/telephone/notfound.ogg', 50)
			end_call(forced = TRUE)
			update_icon()

		if(COMMSIG_ANSWER)
			status = STATUS_ONGOING
			outring_loop.stop()
			if(ismob(attached_to.loc))
				var/mob/M = attached_to.loc
				to_chat(M, span_notice("[icon2html(src, M)] Call answered."))
			update_icon()

		if(COMMSIG_TALK)
			if(attached_to.loc && ismob(attached_to.loc))
				var/mob/M = attached_to.loc
				M.playsound_local(get_turf(M), 'sound/machines/telephone/voice.ogg', 50)
				to_chat(M, span_notice("[icon2html(src, M)] [data]"))

		if(COMMSIG_HANGUP)
			end_call(forced = TRUE)
			update_icon()

		if(COMMSIG_TIMEOUT)
			status = STATUS_IDLE
			playsound(src, 'sound/machines/telephone/timeout.ogg', 50)
			end_call(forced = TRUE, timeout = TRUE)
			update_icon()

/obj/structure/transmitter/proc/send_commsig(commsig, data)
	if(!GLOB.central_telephone_exchange)
		return

	var/obj/structure/central_telephone_exchange/cte = GLOB.central_telephone_exchange
	cte.process_commsig(phone_id, commsig, data)

/obj/structure/transmitter/proc/stop_loops()
	busy_loop.stop()
	hangup_loop.stop()
	outring_loop.stop()
	dialtone_loop.stop()


/obj/structure/transmitter
	name = "rotary telephone"
	icon = 'icons/obj/machines/phone.dmi'
	icon_state = "rotary_phone"
	desc = "The most generic phone you have ever seen. You struggle to imagine something even more devoid of personality and miserably fail."
	anchored = TRUE
	layer = OBJ_LAYER + 0.01
	pass_flags = PASSTABLE

	/// The tape inserted
	var/obj/item/tape/inserted_tape
	/// The unique 8-character alphanumeric ID of this transmitter
	var/phone_id = "0x000000"
	/// The name of this transmitter as visible on the other devices
	var/display_name
	var/phone_icon
	var/obj/item/telephone/attached_to
	/// Currently active call
	var/obj/structure/transmitter/current_call
	/// Call status
	var/status = STATUS_IDLE
	var/phone_type = /obj/item/telephone
	var/enabled = TRUE
	/// Whether or not the phone will emit sound when receiving a call.
	var/do_not_disturb = PHONE_DND_OFF
	var/default_icon_state
	var/timeout_timer_id
	var/timeout_duration = 30 SECONDS
	/// What network does this phone belong to?
	var/phone_category = PHONE_NET_PUBLIC
	/// Which networks can call this phone?
	var/list/networks_receive = list(PHONE_NET_PUBLIC)
	/// Which networks this phone can call?
	var/list/networks_transmit = list(PHONE_NET_PUBLIC)
	var/datum/looping_sound/telephone/busy/busy_loop
	var/datum/looping_sound/telephone/hangup/hangup_loop
	var/datum/looping_sound/telephone/ring/outring_loop
	var/datum/looping_sound/telephone/dialtone/dialtone_loop
	/// If this phone is advanced enough to display the caller and the call history
	var/is_advanced = TRUE
	/// Last 5 call origins
	var/list/callers_list = list()
	/// If this phone's `display_name` can be changed
	var/can_rename = FALSE
	// If calling this phone is free of charge
	var/is_free = TRUE
	// If the next call has been paid for
	var/is_paid = FALSE

/obj/structure/transmitter/Initialize(mapload, new_phone_id, new_display_name)
	. = ..()
	default_icon_state = icon_state
	attached_to = new phone_type(src)
	RegisterSignal(attached_to, COMSIG_QDELETING, PROC_REF(override_delete))
	update_icon()
	outring_loop = new(attached_to)
	busy_loop = new(attached_to)
	hangup_loop = new(attached_to)
	dialtone_loop = new(attached_to)

	if(!get_turf(src))
		return

	GLOB.transmitters += src

	// Generate or use provided phone ID
	phone_id = new_phone_id ? new_phone_id : generate_unique_phone_id()
	display_name = new_display_name || "[get_area_name(src, TRUE)]"

	if(name == initial(name))
		name = "[get_area_name(src, TRUE)] [initial(name)]"

/**
 * Generates a unique 8-character alphanumeric phone ID
 */
/obj/structure/transmitter/proc/generate_unique_phone_id()
	var/static/list/valid_chars = list()
	if(!length(valid_chars))
		// Numbers 0-9
		for(var/i in 0 to 9)
			valid_chars += num2text(i)
		// Uppercase A-Z
		for(var/i in 65 to 90)
			valid_chars += ascii2text(i)
		// Lowercase a-z
		for(var/i in 97 to 122)
			valid_chars += ascii2text(i)

	var/unique_id
	var/attempts = 0
	var/max_attempts = 100

	while(phone_id_exists(unique_id))
		unique_id = ""
		for(var/i in 1 to 8)
			unique_id += pick(valid_chars)

		attempts++
		if(attempts > max_attempts)
			CRASH("Failed to generate unique phone ID after [max_attempts] attempts")

	return unique_id

/obj/structure/transmitter/proc/phone_id_exists(id_to_check)
	for(var/obj/structure/transmitter/T in GLOB.transmitters)
		if(T.phone_id == id_to_check && T != src)
			return TRUE
	return FALSE

/obj/structure/transmitter/Destroy()
	if(attached_to)
		if(attached_to.loc == src)
			UnregisterSignal(attached_to, COMSIG_QDELETING)
			qdel(attached_to)
		else
			attached_to.attached_to = null
		attached_to = null
	GLOB.transmitters -= src
	SStgui.close_uis(src)
	end_call()
	return ..()

/obj/structure/transmitter/proc/override_delete()
	SIGNAL_HANDLER
	recall_phone()
	return TRUE

/obj/structure/transmitter/examine(mob/user)
	. = ..()

	if(can_rename)
		. += span_notice("Alt-LMB to change the phone ID.")

	if(is_advanced && (current_call))
		. += span_notice("Now calling: [current_call.display_name]")

		// . += span_notice("Last 5 calls:")
		// for(var/i in callers_list)
		// 	. += span_notice(i)

/obj/structure/transmitter/click_ctrl_shift(mob/user)
	. = ..()
	recall_phone()

/obj/structure/transmitter/update_icon()
	. = ..()
	SEND_SIGNAL(src, COMSIG_TRANSMITTER_UPDATE_ICON)
	if(attached_to.loc != src)
		icon_state = "[default_icon_state]_ear"
		return
	if(status == STATUS_INBOUND)
		icon_state = "[default_icon_state]_ring"
	else
		icon_state = default_icon_state

/obj/structure/transmitter/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(!.)
		return

	if(!attached_to)
		return

	if(!attached_to.do_zlevel_check())
		recall_phone()

	if(get_dist(attached_to, src) > MAX_RANGE)
		if(ismob(attached_to.loc))
			var/mob/M = attached_to.loc
			M.dropItemToGround(attached_to, TRUE)
		else
			recall_phone()

/obj/structure/transmitter/attack_hand(mob/user)
	. = ..()
	if(!attached_to || attached_to.loc != src)
		return

	if(!ishuman(user))
		return

	if(!enabled)
		return

	if(status != STATUS_INBOUND && status != STATUS_OUTGOING)
		if(!is_free && !is_paid)
			to_chat(user, span_notice("[icon2html(src, user)] Please deposit $[SINGLE_CALL_PRICE]."))
			return

		ui_interact(user)
		return

	if(current_call.attached_to)
		if(ismob(current_call.attached_to.loc))
			var/mob/attached_to_mob = current_call.attached_to.loc
			to_chat(attached_to_mob, span_notice("[icon2html(src, attached_to_mob)] on the other side, someone has picked up."))
		playsound(current_call.attached_to.loc, 'sound/machines/telephone/remote_pickup.ogg', 20)

		if(current_call.timeout_timer_id)
			deltimer(current_call.timeout_timer_id)
			current_call.timeout_timer_id = null

	to_chat(user, span_notice("[icon2html(src, user)] You pick up the [attached_to]."))
	playsound(get_turf(user), SFX_TELEPHONE_HANDSET)
	current_call.outring_loop.stop()
	user.put_in_active_hand(attached_to)
	update_icon()

/obj/structure/transmitter/proc/process_payment(mob/living/user, obj/item/card/id/used_card)
	if(!used_card.registered_account)
		to_chat(user, span_warning("You don't have a bank account!"))
		playsound(src, 'sound/machines/buzz/buzz-two.ogg', 30, TRUE)
		return FALSE

	if(used_card.registered_account.account_balance < SINGLE_CALL_PRICE)
		to_chat(user, span_warning("Insufficient funds!"))
		playsound(src, 'sound/machines/buzz/buzz-two.ogg', 30, TRUE)
		return FALSE

	var/datum/bank_account/service_account = SSeconomy.get_dep_account(ACCOUNT_SRV)
	to_chat(user, span_notice("You swipe the card..."))
	is_paid = TRUE
	service_account.transfer_money(used_card.registered_account, SINGLE_CALL_PRICE, "Telephone: [phone_id]")

/obj/structure/transmitter/proc/insert_tape(obj/item/tape/some_tape, mob/living/user)
	some_tape.forceMove(src)
	if(inserted_tape)
		to_chat(user, span_notice("You replace the tape in the [src]."))
		user.put_in_active_hand(inserted_tape)
	else
		to_chat(user, span_notice("You insert the [some_tape] in the [src]."))

	inserted_tape = some_tape

/obj/structure/transmitter/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(tool == attached_to)
		recall_phone()
		return ITEM_INTERACT_SUCCESS

	if(istype(tool, /obj/item/tape))
		insert_tape(tool, user)
		return ITEM_INTERACT_SUCCESS

	var/obj/item/card/id/used_card = tool.GetID()
	if(used_card)
		if(is_free)
			to_chat(user, span_notice("You poke the [src] with the [tool] only to realize it doesn't have a card slot. You feel stupid."))
			return ITEM_INTERACT_BLOCKING
		else
			if(isidcard(tool))
				playsound(src, 'sound/machines/card_slide.ogg', 50, TRUE)
			else
				playsound(src, 'sound/machines/terminal/terminal_success.ogg', 50, TRUE)
			process_payment(user, used_card)
			return ITEM_INTERACT_SUCCESS

	else if(tool.tool_behaviour == TOOL_WRENCH)
		playsound(src, 'sound/items/deconstruct.ogg', 50, 1)
		if(!anchored && !isinspace())
			to_chat(user,"<span class='notice'>You secure [src] to the floor.</span>")
			return ITEM_INTERACT_SUCCESS
		else if(anchored)
			to_chat(user,"<span class='notice'>You unsecure and disconnect [src].</span>")
			return ITEM_INTERACT_SUCCESS
		return
	else
		return ..()

/obj/structure/transmitter/ui_status(mob/user, datum/ui_state/state)
	. = ..()
	if(TRANSMITTER_UNAVAILABLE(src))
		return UI_CLOSE

/obj/structure/transmitter/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(TRANSMITTER_UNAVAILABLE(src))
		return
	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/user = usr
	switch(action)
		if("call_phone")
			process_outbound_call(user, params["phone_id"])
			. = TRUE
			SStgui.close_uis(src)
		if("toggle_dnd")
			toggle_dnd(user)
	update_icon()

/obj/structure/transmitter/ui_interact(mob/user, datum/tgui/ui)
	if(status == STATUS_INBOUND)
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PhoneMenu", "[display_name] Telephone")
		ui.open()

/obj/structure/transmitter/ui_data(mob/user)
	var/list/data = list()
	data["availability"] = do_not_disturb
	data["last_caller"] = current_call
	data["current_display_name"] = display_name
	data["current_phone_id"] = phone_id
	return data

/obj/structure/transmitter/ui_static_data(mob/user)
	. = list()
	var/list/transmitters = list()
	var/list/received_transmitters = get_transmitters()
	var/list/available_transmitters = list()
	for(var/id in received_transmitters)
		var/data = received_transmitters[id]
		var/obj/structure/transmitter/received_transmitter = data["phone"]
		transmitters += list(list(
			"phone_id" = data["phone_id"],
			"display_name" = data["display_name"],
			"phone_category" = received_transmitter.phone_category,
			"phone_icon" = received_transmitter.phone_icon
		))
		available_transmitters += data["phone_id"]
	.["transmitters"] = transmitters
	.["available_transmitters"] = available_transmitters

/obj/structure/transmitter/proc/get_transmitters()
	var/list/phone_list = list()
	for(var/obj/structure/transmitter/target_phone in GLOB.transmitters)
		if(!istype(target_phone))
			GLOB.transmitters.Remove(target_phone)
			continue

		if(TRANSMITTER_UNAVAILABLE(target_phone) || target_phone.do_not_disturb == PHONE_DND_ON || target_phone.do_not_disturb == PHONE_DND_FORCED)
			continue

		if(target_phone == src)
			continue

		var/net_link = FALSE
		for(var/network in networks_transmit)
			if(network in target_phone.networks_receive)
				net_link = TRUE
				continue

		if(!net_link)
			continue

		var/id = target_phone.phone_id
		var/display = target_phone.display_name
		var/num_id = 2
		var/original_display = display

		while(display in phone_list)
			display = "[original_display] #[num_id]"
			num_id++

		phone_list[display] = list(
			"phone" = target_phone,
			"phone_id" = id,
			"display_name" = display
		)
	return phone_list


/obj/structure/transmitter/proc/process_outbound_call(mob/living/carbon/human/user, calling_phone_id)
	if(!is_free && !is_paid)
		to_chat(user, span_notice("[icon2html(src, user)] Please deposit $[SINGLE_CALL_PRICE]."))
		return

	var/list/transmitters = get_transmitters()
	if(!length(transmitters))
		to_chat(user, span_notice("[icon2html(src, user)] No transmitters could be located to call!"))
		return

	var/obj/structure/transmitter/target = null
	var/display = null

	for(var/key in transmitters)
		var/list/transmitter_data = transmitters[key]
		if(transmitter_data["phone_id"] == calling_phone_id)
			target = transmitter_data["phone"]
			display = transmitter_data["display_name"]
			break

	if(!target)
		to_chat(user, span_notice("[icon2html(src, user)] No transmitter with ID [calling_phone_id] could be located!"))
		return

	if(!istype(target) || QDELETED(target))
		transmitters -= target
		CRASH("Qdelled/improper atom inside transmitters list! (istype returned: [istype(target)], QDELETED returned: [QDELETED(target)])")

	if(TRANSMITTER_UNAVAILABLE(target))
		return

	user.put_in_hands(attached_to)
	to_chat(user, span_notice("[icon2html(src, user)] Dialing [display] ([calling_phone_id])..."))
	playsound(get_turf(user), SFX_TELEPHONE_HANDSET, 100)

	if(target.current_call || target.attached_to.loc != target)
		to_chat(user, span_purple("[icon2html(src, user)] Your call to [display] ([calling_phone_id]) has reached voicemail, the line is busy."))
		busy_loop.start()
		return

	current_call = target
	target.process_inbound_call(target)

	is_paid = FALSE

	target.callers_list += "[src.phone_id] - [STATION_TIME_PASSED("hh:mm:ss", world.time)]"
	if(target.callers_list.len > 5)
		target.callers_list.Remove(target.callers_list[1])
	target.update_icon()
	timeout_timer_id = addtimer(CALLBACK(src, PROC_REF(end_call), FALSE, TRUE), timeout_duration, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE)
	outring_loop.start()
	START_PROCESSING(SSobj, src)
	START_PROCESSING(SSobj, target)

/obj/structure/transmitter/proc/toggle_dnd(mob/living/carbon/human/user)
	switch(do_not_disturb)
		if(PHONE_DND_ON)
			do_not_disturb = PHONE_DND_OFF
		if(PHONE_DND_OFF)
			do_not_disturb = PHONE_DND_ON
		else
			return FALSE
	return TRUE

// /obj/structure/transmitter/proc/set_tether_holder(atom/A)
// 	tether_holder = A
// 	if(attached_to)
// 		attached_to.reset_tether()

/obj/structure/transmitter/proc/end_call(forced = FALSE, timeout = FALSE)
	if(!current_call)
		return

	var/obj/structure/transmitter/other = current_call
	var/mob/attached_to_mob = attached_to?.loc

	if(attached_to_mob && ismob(attached_to_mob))
		if(timeout)
			to_chat(attached_to_mob, span_notice("[icon2html(src, attached_to_mob)] Your call to [other.display_name] has reached voicemail."))
			busy_loop.start()
		else if(forced)
			to_chat(attached_to_mob, span_notice("[icon2html(src, attached_to_mob)] [other.display_name] has hung up."))
			hangup_loop.start()
		else
			to_chat(attached_to_mob, span_notice("[icon2html(src, attached_to_mob)] You hang up the call."))
			hangup_loop.start()

	outring_loop.stop()

	if(!forced && other && other.current_call == src)
		other.end_call(TRUE, timeout)

	current_call = null
	status = STATUS_IDLE
	if(timeout_timer_id)
		deltimer(timeout_timer_id)
		timeout_timer_id = null
	STOP_PROCESSING(SSobj, src)
	update_icon()

	busy_loop.stop()
	hangup_loop.stop()
	outring_loop.stop()

/obj/structure/transmitter/proc/try_ring()
	if(!current_call || attached_to.loc != src || !status != STATUS_INBOUND)
		return

	playsound(loc, 'sound/machines/telephone/telephone_ring.ogg', 75, FALSE)
	visible_message(span_warning("[src] rings vigorously!"))
	if(is_advanced)
		say("Incoming call: [current_call]")
	else
		balloon_alert_to_viewers("ring, ring!")

	addtimer(CALLBACK(src, PROC_REF(try_ring)), RING_TIMEOUT)

/obj/structure/transmitter/proc/process_inbound_call(obj/structure/transmitter/the_one_who_calls)
	current_call = the_one_who_calls
	status = STATUS_INBOUND
	try_ring()

/obj/structure/transmitter/process()
	if(current_call && status == STATUS_INBOUND)
		if(!attached_to)
			STOP_PROCESSING(SSobj, src)
			return

	else if(!current_call && status == STATUS_OUTGOING)
		STOP_PROCESSING(SSobj, src)
		return

	else
		STOP_PROCESSING(SSobj, src)
		return

/obj/structure/transmitter/proc/recall_phone()
	if(ismob(attached_to.loc))
		var/mob/M = attached_to.loc
		M.dropItemToGround(attached_to)
	playsound(loc, SFX_TELEPHONE_HANDSET, 20, FALSE, 7)
	attached_to.forceMove(src)
	end_call()
	busy_loop.stop()
	hangup_loop.stop()
	outring_loop.stop()
	current_call = null
	update_icon()


/obj/structure/transmitter/proc/handle_speak(mob/speaking, list/speech_args)
	var/message = speech_args[SPEECH_MESSAGE]
	if(current_call && status == STATUS_ONGOING)
		send_commsig(COMMSIG_TALK, message)
		if(attached_to.raised && ismob(attached_to.loc))
			var/mob/holder = attached_to.loc
			holder.playsound_local(get_turf(holder), 'sound/machines/telephone/voice.ogg', 50)
			log_say("TELEPHONE: [key_name(speaking)] at '[display_name]' to '[current_call.display_name]' said '[message]'")

#undef PHONE_NET_PUBLIC
#undef PHONE_NET_COMMAND
#undef PHONE_NET_CENTCOMM
#undef PHONE_NET_SYNDIE

#undef PHONE_DND_FORCED
#undef PHONE_DND_ON
#undef PHONE_DND_OFF
#undef PHONE_DND_FORBIDDEN

#undef TRANSMITTER_UNAVAILABLE
#undef MAX_RANGE
