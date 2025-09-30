GLOBAL_LIST_EMPTY_TYPED(transmitters, /obj/structure/transmitter)

#define TRANSMITTER_UNAVAILABLE(T) (!T.attached_to || !T.enabled)

#define PHONE_NET_PUBLIC            "Public"
#define PHONE_NET_COMMAND           "Command"
#define PHONE_NET_CENTCOM           "CentCom"
#define PHONE_NET_SYNDIE            "Syndicate"

#define PHONE_DND_ON                "On"
#define PHONE_DND_OFF               "Off"
#define PHONE_DND_FORBIDDEN         "Forbidden"

#define SINGLE_CALL_PRICE           5
#define MAX_RANGE                   3
#define RING_TIMEOUT                4 SECONDS
#define HISTORY_LENGTH 							5

#define STATUS_INBOUND              "Inbound call"
#define STATUS_ONGOING              "Ongoing call"
#define STATUS_OUTGOING             "Outgoing call"
#define STATUS_IDLE                 "Idle"

#define COMMSIG_OFFHOOK             "Communication Signal - Offhook"           // The telephone is removed from the hook
#define COMMSIG_DIALTONE            "Communication Signal - Dialtone"          // The phone should play the dialtone sound, indicating it's ready for dialing
#define COMMSIG_DIAL                "Communication Signal - Dial"	             // The phone sends a request to the CTE, attempting to call a `phone_id`
#define COMMSIG_RINGING             "Communication Signal - Ringing"           // The phone rings, being ready to pick up
#define COMMSIG_RINGBACK            "Communication Signal - Ringback"	         // The caller hears the ringback sounds, waiting for the other side to pick up
#define COMMSIG_BUSY                "Communication Signal - Busy"	             // The target phone is busy
#define COMMSIG_NUMBER_NOT_FOUND    "Communication Signal - Number Not Found"	 // The CTE couldn't find the device with such `phone_id`
#define COMMSIG_ANSWER              "Communication Signal - Answer"	           // The phone should initialize the call
#define COMMSIG_TALK                "Communication Signal - Talk"	             // The signal sent with the voice message itself
#define COMMSIG_HANGUP              "Communication Signal - Hangup"	           // The other side has hanged up
#define COMMSIG_TIMEOUT             "Communication Signal - Timeout"	         // The line has been inactive for over 30 seconds

/obj/structure/transmitter
	name = "rotary telephone"
	icon = 'icons/obj/machines/phone.dmi'
	icon_state = "rotary"
	post_init_icon_state = "rotary"
	desc = "The most generic phone you have ever seen. You struggle to imagine something even more devoid of personality and miserably fail."
	anchored = TRUE
	layer = OBJ_LAYER + 0.01
	pass_flags = PASSTABLE
	greyscale_config = /datum/greyscale_config/transmitter
	greyscale_colors = "#6e7766"

	/// The tape inserted
	var/obj/item/tape/inserted_tape
	/// The unique 8-character alphanumeric ID of this transmitter
	var/phone_id = "0x00000b" // reserved for CC
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
	/// What network does this phone belong to?
	var/phone_category = PHONE_NET_PUBLIC
	/// Which networks this phone can call?
	var/list/networks_transmit = list(PHONE_NET_PUBLIC)
	var/datum/looping_sound/telephone/busy/busy_loop
	var/datum/looping_sound/telephone/hangup/hangup_loop
	var/datum/looping_sound/telephone/ring/outring_loop
	var/datum/looping_sound/telephone/dialtone/dialtone_loop
	/// If this phone is advanced enough to display the caller and the call history
	var/is_advanced = TRUE
	/// Last HISTORY_LENGTH calls
	var/list/callers_list = list()
	// If calling this phone is free of charge
	var/is_free = TRUE
	// If the next call has been paid for
	var/is_paid = FALSE

/obj/structure/transmitter/Initialize(mapload, new_phone_id, new_display_name)
	. = ..()
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

	phone_id = new_phone_id ? new_phone_id : generate_unique_phone_id()
	display_name = new_display_name || "[get_area_name(src, TRUE)]"

	if(name == initial(name))
		name = "[get_area_name(src, TRUE)] [initial(name)]"

/obj/structure/transmitter/proc/find_device(device_id)
	for(var/obj/structure/transmitter/each_transmitter in GLOB.transmitters)
		if(each_transmitter.phone_id == device_id)
			return each_transmitter
	return null

/// Processes incoming communication signals. Arguments: `commsig`: string, `data`: object
/obj/structure/transmitter/proc/process_commsig(commsig, data)
	// to_chat(world, "DEBUG: transmitter [display_name] with ID [phone_id] received [commsig] with data ([data])")
	stop_loops()
	switch(commsig)
		if(COMMSIG_DIALTONE)
			status = STATUS_IDLE
			dialtone_loop.start()
			update_icon()

		if(COMMSIG_RINGING)
			status = STATUS_INBOUND
			START_PROCESSING(SSobj, src)
			var/obj/structure/transmitter/new_caller = find_device(data)
			if(new_caller)
				current_call = new_caller
				add_call_history("in", new_caller)
				try_ring()
			update_icon()

		if(COMMSIG_RINGBACK)
			status = STATUS_OUTGOING
			stop_loops()
			outring_loop.start()
			update_icon()

		if(COMMSIG_BUSY)
			status = STATUS_IDLE
			// playsound(src, 'sound/machines/telephone/busy.ogg', 50)
			end_call(forced = TRUE)
			update_icon()

		if(COMMSIG_NUMBER_NOT_FOUND)
			status = STATUS_IDLE
			// playsound(src, 'sound/machines/telephone/notfound.ogg', 50)
			end_call(forced = TRUE)
			update_icon()

		if(COMMSIG_ANSWER)
			status = STATUS_OUTGOING
			if(ismob(attached_to.loc))
				var/mob/M = attached_to.loc
				to_chat(M, span_notice("[icon2html(src, M)] Someone on the other side picks up the phone."))
			update_icon()
			outring_loop.stop()
			stop_loops()

		if(COMMSIG_TALK)
			if(attached_to.loc && ismob(attached_to.loc))
				var/mob/M = attached_to.loc
				to_chat(M, span_notice("[icon2html(src, M)] [src] says, \"[capitalize(data)]\""))

		if(COMMSIG_HANGUP)
			end_call(forced = TRUE)
			update_icon()

		if(COMMSIG_TIMEOUT)
			status = STATUS_IDLE
			end_call(forced = TRUE, timeout = TRUE)
			update_icon()

/obj/structure/transmitter/proc/send_commsig(commsig, data)
	if(!GLOB.central_telephone_exchange)
		return

	var/obj/machinery/central_telephone_exchange/cte = GLOB.central_telephone_exchange
	cte.process_commsig(phone_id, commsig, data)

/obj/structure/transmitter/proc/stop_loops()
	busy_loop.stop()
	hangup_loop.stop()
	outring_loop.stop()
	dialtone_loop.stop()

/// Generates a unique 8-character alphanumeric phone ID
/obj/structure/transmitter/proc/generate_unique_phone_id()
	var/static/list/valid_chars = list()
	if(!length(valid_chars))
		for(var/i in 0 to 9)
			valid_chars += num2text(i)
		for(var/i in 65 to 90)
			valid_chars += ascii2text(i)
		for(var/i in 97 to 122)
			valid_chars += ascii2text(i)

	var/unique_id = phone_id
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

/// Checks if a phone ID already exists in the global pool
/obj/structure/transmitter/proc/phone_id_exists(id_to_check)
	for(var/obj/structure/transmitter/each_transmitter in GLOB.transmitters)
		if(each_transmitter.phone_id == id_to_check && each_transmitter != src)
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

	if(is_advanced && (current_call))
		. += span_notice("Now calling: [current_call.display_name]")

/obj/structure/transmitter/click_ctrl_shift(mob/user)
	. = ..()
	recall_phone()

/obj/structure/transmitter/update_icon()
	. = ..()

	apply_transmitter_overlays(
		/*handset_state=*/ "rotary_handset",
		/*handset_ring_state=*/ "rotary_handset_ring",
		/*status_red=*/ "rotary_red",
		/*status_yellow=*/ "rotary_yellow",
		/*status_green=*/ "rotary_green",
		/*light_state=*/ "rotary_light"
	)

/// Shared helper to (re)build overlays for a transmitter appearance
/obj/structure/transmitter/proc/apply_transmitter_overlays(handset_state, handset_ring_state, status_red, status_yellow, status_green, light_state)
	cut_overlays()

	if(attached_to.loc == src)
		var/handset_icon_state = (status == STATUS_INBOUND && handset_ring_state) ? handset_ring_state : handset_state
		var/mutable_appearance/handset_overlay = mutable_appearance(icon, handset_icon_state)
		handset_overlay.plane = plane
		add_overlay(handset_overlay)

	var/status_overlay

	if(do_not_disturb == PHONE_DND_ON)
		status_overlay = status_red
	else
		if(status == STATUS_INBOUND)
			status_overlay = status_yellow
		else
			status_overlay = status_green

	if(status_overlay)
		var/mutable_appearance/status_appearance = mutable_appearance('icons/obj/machines/phone.dmi', status_overlay, src, layer = layer)
		status_appearance.plane = plane
		add_overlay(status_appearance)

		if(light_state)
			var/mutable_appearance/emissive_overlay = emissive_appearance('icons/obj/machines/phone.dmi', status == STATUS_INBOUND ? "[light_state]_blink" : light_state, src, layer = layer)
			add_overlay(emissive_overlay)

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
			recall_phone()
		else
			recall_phone()

/obj/structure/transmitter/attack_hand(mob/user)
	. = ..()

	if(!ishuman(user))
		return

	if(!enabled)
		return

	if(!attached_to)
		CRASH("A transmitter with ID [phone_id] has no telephone!")

	if(attached_to.loc == src)
		to_chat(user, span_notice("[icon2html(src, user)] You pick up [attached_to]."))
		playsound(get_turf(user), SFX_TELEPHONE_HANDSET, 20)
		user.put_in_active_hand(attached_to)
		var/obj/machinery/central_telephone_exchange/cte = GLOB.central_telephone_exchange
		if(current_call && status == STATUS_INBOUND)
			cte.process_commsig(phone_id, COMMSIG_ANSWER, current_call.phone_id)
		else
			cte.process_commsig(phone_id, COMMSIG_OFFHOOK)
		update_icon()
	else if(attached_to.loc == user)
		ui_interact(user)

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
		if(user.combat_mode)
			visible_message(span_warning("[user] slams [attached_to] on the [src]!"), span_warning("You slammed the [attached_to] on the cradle!"))
			user.do_attack_animation(src)
			Shake(2, 0, 10, shake_interval = 0.05 SECONDS)
			playsound(src, SFX_TELEPHONE_HANDSET, 60)
			playsound(src, 'sound/items/weapons/genhit1.ogg', 30, FALSE)
			playsound(src, 'sound/machines/telephone/bell.ogg', 75, FALSE)
		else
			to_chat(attached_to, span_notice("[icon2html(src, user)] You set the [attached_to] in the cradle."))
			playsound(get_turf(user), SFX_TELEPHONE_HANDSET, 20)
		return ITEM_INTERACT_SUCCESS

	if(istype(tool, /obj/item/tape))
		insert_tape(tool, user)
		return ITEM_INTERACT_SUCCESS

	if(istype(tool, /obj/item/coin))
		if(is_free)
			to_chat(user, span_notice("You try to insert [tool], but this phone doesn't require payment."))
			return ITEM_INTERACT_BLOCKING

		return process_coin_payment(user, tool)

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
			anchored = TRUE
			return ITEM_INTERACT_SUCCESS
		else if(anchored)
			to_chat(user,"<span class='notice'>You unsecure and disconnect [src].</span>")
			anchored = FALSE
			return ITEM_INTERACT_SUCCESS
		return
	else
		return ..()

/obj/structure/transmitter/proc/process_coin_payment(mob/living/user, obj/item/coin/inserted_coin)
	if(!inserted_coin)
		return ITEM_INTERACT_BLOCKING

	qdel(inserted_coin)
	playsound(src, 'sound/machines/coindrop.ogg', 50, TRUE)
	to_chat(user, span_notice("You insert [inserted_coin] in the coin slot."))
	is_paid = TRUE

	return ITEM_INTERACT_SUCCESS

/obj/structure/transmitter/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()

	if(TRANSMITTER_UNAVAILABLE(src))
		return

	if(!ishuman(usr))
		return

	var/mob/living/carbon/human/user = usr
	switch(action)
		if("call_phone")
			process_outbound_call(user, params["phone_id"])
			return TRUE

		if("toggle_dnd")
			toggle_dnd(user)
			return TRUE

		if("hangup")
			end_call()
			return TRUE

		if("clear_history")
			callers_list = list()
			return TRUE
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
	data["callers_list"] = callers_list
	if(current_call)
		data["current_call"] = list(
			"display_name" = current_call.display_name,
			"phone_id" = current_call.phone_id,
		)
	data["is_advanced"] = is_advanced
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

		if(TRANSMITTER_UNAVAILABLE(target_phone) || target_phone.do_not_disturb == PHONE_DND_ON)
			continue

		if(target_phone == src)
			continue

		if(!(target_phone.phone_category in networks_transmit))
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

	if(attached_to.loc != user)
		user.put_in_hands(attached_to)

	to_chat(user, span_notice("[icon2html(src, user)] Dialing [display] ([calling_phone_id])..."))
	playsound(get_turf(user), SFX_TELEPHONE_HANDSET, 100)

	// if(target.current_call || target.attached_to.loc != target)
	// 	to_chat(user, span_purple("[icon2html(src, user)] Your call to [display] ([calling_phone_id]) has reached voicemail, the line is busy."))
	// 	busy_loop.start()
	// 	return

	current_call = target
	add_call_history("out", target)
	send_commsig(COMMSIG_DIAL, target.phone_id)

	is_paid = FALSE
	START_PROCESSING(SSobj, src)
	SStgui.update_uis(src)

/obj/structure/transmitter/proc/toggle_dnd(mob/living/carbon/human/user)
	switch(do_not_disturb)
		if(PHONE_DND_ON)
			do_not_disturb = PHONE_DND_OFF
		if(PHONE_DND_OFF)
			do_not_disturb = PHONE_DND_ON

	update_overlays()
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

	if(!forced && other && other.current_call == src)
		other.end_call(TRUE, timeout)

	current_call = null
	status = STATUS_IDLE
	STOP_PROCESSING(SSobj, src)
	update_icon()
	stop_loops()
	SStgui.update_uis(src)

/obj/structure/transmitter/proc/add_call_history(direction, obj/structure/transmitter/other)
	if(!other)
		return

	if(length(callers_list) >= HISTORY_LENGTH)
		callers_list.Cut(1, 2)
	var/entry = list(
		"dir" = direction,
		"id" = other.phone_id,
		"name" = other.display_name,
	)
	callers_list += list(entry)

/obj/structure/transmitter/proc/try_ring()
	if(!current_call || attached_to.loc != src || status != STATUS_INBOUND)
		return

	playsound(loc, 'sound/machines/telephone/telephone_ring.ogg', 75, FALSE)
	visible_message(span_warning("[src] rings vigorously!"))
	if(is_advanced)
		say("Incoming call: [current_call.display_name]!")
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
		var/mob/user_mob = attached_to.loc
		user_mob.dropItemToGround(attached_to)
	playsound(loc, SFX_TELEPHONE_HANDSET, 20, FALSE, 7)
	attached_to.forceMove(src)
	send_commsig(COMMSIG_HANGUP, current_call && current_call.phone_id)
	end_call()
	stop_loops()
	current_call = null
	update_icon()

/obj/structure/transmitter/proc/handle_speak(mob/speaking, list/speech_args)
	var/message = speech_args[SPEECH_MESSAGE]
	if(current_call && status == STATUS_OUTGOING)
		var/list/data = list(
			"target_id" = current_call.phone_id,
			"message" = message
		)
		send_commsig(COMMSIG_TALK, data)
		if(attached_to.raised && ismob(attached_to.loc))
			var/mob/holder = attached_to.loc
			holder.playsound_local(get_turf(holder), SFX_TELEPHONE_SPEAKING, 20)
			log_say("TELEPHONE: [key_name(speaking)] at '[display_name]' to '[current_call.display_name]' said '[message]'")

#undef MAX_RANGE

#undef TRANSMITTER_UNAVAILABLE

#undef PHONE_NET_PUBLIC
#undef PHONE_NET_COMMAND
#undef PHONE_NET_CENTCOM
#undef PHONE_NET_SYNDIE

#undef PHONE_DND_ON
#undef PHONE_DND_OFF
#undef PHONE_DND_FORBIDDEN

#undef SINGLE_CALL_PRICE
#undef RING_TIMEOUT

#undef STATUS_INBOUND
#undef STATUS_ONGOING
#undef STATUS_OUTGOING
#undef STATUS_IDLE

#undef COMMSIG_OFFHOOK
#undef COMMSIG_DIALTONE
#undef COMMSIG_DIAL
#undef COMMSIG_RINGING
#undef COMMSIG_RINGBACK
#undef COMMSIG_BUSY
#undef COMMSIG_NUMBER_NOT_FOUND
#undef COMMSIG_ANSWER
#undef COMMSIG_TALK
#undef COMMSIG_HANGUP
#undef COMMSIG_TIMEOUT
