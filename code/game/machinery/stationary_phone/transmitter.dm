GLOBAL_LIST_EMPTY_TYPED(transmitters, /obj/structure/transmitter)

#define COMSIG_TRANSMITTER_UPDATE_ICON "transmitter_update_icon"
#define TRANSMITTER_UNAVAILABLE(T) (!T.attached_to || !T.enabled)

#define PHONE_NET_PUBLIC	"Public"
#define PHONE_NET_COMMAND	"Command"
#define PHONE_NET_CENTCOMM	"CentComm"
#define PHONE_NET_SYNDIE	"Syndicate"

#define PHONE_DND_FORCED 2
#define PHONE_DND_ON 1
#define PHONE_DND_OFF 0
#define PHONE_DND_FORBIDDEN -1

#define SINGLE_CALL_PRICE 5

/obj/structure/transmitter
	name = "rotary telephone"
	icon = 'icons/obj/machines/phone.dmi'
	icon_state = "rotary_phone"
	desc = "The most generic phone you have ever seen. You struggle to imagine something even more devoid of personality and miserably fail."
	anchored = TRUE
	layer = OBJ_LAYER + 0.01
	pass_flags = PASSTABLE

	var/phone_category = PHONE_NET_PUBLIC
	var/phone_color = "white"
	var/phone_id = "Telephone"
	var/display_name
	var/phone_icon
	var/obj/item/telephone/attached_to
	// var/atom/tether_holder
	var/obj/structure/transmitter/outbound_call
	var/obj/structure/transmitter/inbound_call
	var/next_ring = 0
	var/phone_type = /obj/item/telephone
	var/range = 3
	var/enabled = TRUE
	/// Whether or not the phone will emit sound when receiving a call.
	var/do_not_disturb = PHONE_DND_OFF
	/// If this phone is advanced enough to display th caller and the call history
	var/is_advanced = TRUE
	/// Who is calling this phone?
	var/current_caller
	/// Last 5 call origins
	var/list/callers_list = list()
	var/default_icon_state
	var/timeout_timer_id
	var/timeout_duration = 30 SECONDS
	/// THEY can call you from there (and above)
	var/list/networks_receive = list(PHONE_NET_PUBLIC)
	/// YOU can call there
	var/list/networks_transmit = list(PHONE_NET_PUBLIC)
	var/datum/looping_sound/telephone/busy/busy_loop
	var/datum/looping_sound/telephone/hangup/hangup_loop
	var/datum/looping_sound/telephone/ring/outring_loop
	var/can_rename = FALSE
	// If calling this phone is free of charge
	var/is_free = FALSE
	// If the next call has been paid for
	var/is_paid = FALSE

/obj/structure/transmitter/Initialize(mapload, ...)
	. = ..()
	default_icon_state = icon_state
	attached_to = new phone_type(src)
	RegisterSignal(attached_to, COMSIG_QDELETING, PROC_REF(override_delete))
	update_icon()
	outring_loop = new(attached_to)
	busy_loop = new(attached_to)
	hangup_loop = new(attached_to)

	if(!get_turf(src))
		return

	GLOB.transmitters += src

	if(name == initial(name))
		name = "[get_area_name(src,)] [initial(name)]"
		phone_id = "[get_area_name(src, TRUE)]"

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
	reset_call()
	return ..()

/obj/structure/transmitter/proc/override_delete()
	SIGNAL_HANDLER
	recall_phone()
	return TRUE

/obj/structure/transmitter/examine(mob/user)
	. = ..()

	if(can_rename)
		. += span_notice("Alt-LMB to change the phone ID.")

	if(is_advanced && (outbound_call || inbound_call))
		. += span_notice("The little screen reads out:")
		if(outbound_call)
			. += span_warning("Outgoing call: [outbound_call.phone_id]")
		if(inbound_call)
			. += span_warning("Inconming call: [current_caller]")
		. += span_notice("Last 5 calls:")
		for(var/i in callers_list)
			. += span_notice(i)

/obj/structure/transmitter/click_ctrl_shift(mob/user)
	. = ..()
	recall_phone()

/obj/structure/transmitter/update_icon()
	. = ..()
	SEND_SIGNAL(src, COMSIG_TRANSMITTER_UPDATE_ICON)
	if(attached_to.loc != src)
		icon_state = "[default_icon_state]_ear"
		return
	if(inbound_call)
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

	if(get_dist(attached_to, src) > range)
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

	if(!get_calling_phone())
		ui_interact(user)
		return

	var/obj/structure/transmitter/T = get_calling_phone()
	if(T.attached_to)
		if(ismob(T.attached_to.loc))
			var/mob/M = T.attached_to.loc
			to_chat(M, span_purple("[icon2html(src, M)] [phone_id] has picked up."))
		playsound(T.attached_to.loc, 'sound/machines/telephone/remote_pickup.ogg', 20)
		if(T.timeout_timer_id)
			deltimer(T.timeout_timer_id)
			T.timeout_timer_id = null
	to_chat(user, span_purple("[icon2html(src, user)] Picked up a call from [T.phone_id]."))
	playsound(get_turf(user), pick(
		'sound/machines/telephone/rtb_handset_1.ogg',
		'sound/machines/telephone/rtb_handset_2.ogg',
		'sound/machines/telephone/rtb_handset_3.ogg',
		'sound/machines/telephone/rtb_handset_4.ogg',
		'sound/machines/telephone/rtb_handset_5.ogg'))
	T.outring_loop.stop()
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
	service_account.transfer_money(used_card.registered_account, SINGLE_CALL_PRICE, "Telephone: [phone_id]")


/obj/structure/transmitter/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(tool == attached_to)
		recall_phone()

	var/obj/item/card/id/used_card = tool.GetID()
	if(used_card)
		if(is_free)
			to_chat(user, span_notice("You poke the [src] with the [tool] only to realize it doesn't have a card slot. You feel stupid."))
		else
			if(isidcard(tool))
				playsound(src, 'sound/machines/card_slide.ogg', 50, TRUE)
			else
				playsound(src, 'sound/machines/terminal/terminal_success.ogg', 50, TRUE)
			process_payment(user, used_card)

	else if(tool.tool_behaviour == TOOL_WRENCH)
		playsound(src, 'sound/items/deconstruct.ogg', 50, 1)
		if(!anchored && !isinspace())
			to_chat(user,"<span class='notice'>You secure [src] to the floor.</span>")
			return ..()
		else if(anchored)
			to_chat(user,"<span class='notice'>You unsecure and disconnect [src].</span>")
			return ..()
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
			call_phone(user, params["phone_id"])
			. = TRUE
			SStgui.close_uis(src)
		if("toggle_dnd")
			toggle_dnd(user)
	update_icon()

/obj/structure/transmitter/ui_interact(mob/user, datum/tgui/ui)
	if(inbound_call)
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PhoneMenu", phone_id)
		ui.open()

/obj/structure/transmitter/ui_data(mob/user)
	var/list/data = list()
	data["availability"] = do_not_disturb
	data["last_caller"] = current_caller
	return data

/obj/structure/transmitter/ui_static_data(mob/user)
	. = list()
	.["available_transmitters"] = get_transmitters() - list(phone_id)
	var/list/transmitters = list()
	for(var/i in GLOB.transmitters)
		var/obj/structure/transmitter/T = i
		transmitters += list(list(
			"phone_category" = T.phone_category,
			"phone_color" = T.phone_color,
			"phone_id" = T.phone_id,
			"phone_icon" = T.phone_icon
		))
	.["transmitters"] = transmitters

/obj/structure/transmitter/proc/get_transmitters()
	var/list/phone_list = list()
	for(var/possible_phone in GLOB.transmitters)
		var/obj/structure/transmitter/target_phone = possible_phone
		var/current_dnd = FALSE
		switch(target_phone.do_not_disturb)
			if(PHONE_DND_ON, PHONE_DND_FORCED)
				current_dnd = TRUE
		if(TRANSMITTER_UNAVAILABLE(target_phone) || current_dnd) // Phone not available
			continue
		var/net_link = FALSE
		for(var/network in networks_transmit)
			if(network in target_phone.networks_receive)
				net_link = TRUE
				continue
		if(!net_link)
			continue
		var/id = target_phone.phone_id
		var/num_id = 1
		while(id in phone_list)
			id = "[target_phone.phone_id] [num_id]"
			num_id++
		target_phone.phone_id = id
		phone_list[id] = target_phone
	return phone_list

/obj/structure/transmitter/proc/call_phone(mob/living/carbon/human/user, calling_phone_id)
	var/list/transmitters = get_transmitters()
	transmitters -= phone_id
	if(!length(transmitters) || !(calling_phone_id in transmitters))
		to_chat(user, span_purple("[icon2html(src, user)] No transmitters could be located to call!"))
		return
	var/obj/structure/transmitter/T = transmitters[calling_phone_id]
	if(!istype(T) || QDELETED(T))
		transmitters -= T
		CRASH("Qdelled/improper atom inside transmitters list! (istype returned: [istype(T)], QDELETED returned: [QDELETED(T)])")
	if(TRANSMITTER_UNAVAILABLE(T))
		return
	user.put_in_hands(attached_to)
	to_chat(user, span_purple("[icon2html(src, user)] Dialing [calling_phone_id].."))
	playsound(get_turf(user), pick('sound/machines/telephone/rtb_handset_1.ogg',
									'sound/machines/telephone/rtb_handset_2.ogg',
									'sound/machines/telephone/rtb_handset_3.ogg',
									'sound/machines/telephone/rtb_handset_4.ogg',
									'sound/machines/telephone/rtb_handset_5.ogg'), 100)
	if(T.get_calling_phone() || T.attached_to.loc != T)
		to_chat(user, span_purple("[icon2html(src, user)] Your call to [T.phone_id] has reached voicemail, the line is busy."))
		busy_loop.start()
		return
	outbound_call = T
	outbound_call.inbound_call = src
	T.current_caller = src.phone_id
	T.callers_list += "[src.phone_id] - [STATION_TIME_PASSED("hh:mm:ss", world.time)]"
	if(T.callers_list.len > 5)
		T.callers_list.Remove(T.callers_list[1])
	T.update_icon()
	timeout_timer_id = addtimer(CALLBACK(src, PROC_REF(reset_call), TRUE), timeout_duration, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE)
	outring_loop.start()
	START_PROCESSING(SSobj, src)
	START_PROCESSING(SSobj, T)

/obj/structure/transmitter/proc/toggle_dnd(mob/living/carbon/human/user)
	switch(do_not_disturb)
		if(PHONE_DND_ON)
			do_not_disturb = PHONE_DND_OFF
			to_chat(user, span_notice("Do Not Disturb has been disabled. You can now receive calls."))
		if(PHONE_DND_OFF)
			do_not_disturb = PHONE_DND_ON
			to_chat(user, span_warning("Do Not Disturb has been enabled. No calls will be received."))
		else
			return FALSE
	return TRUE

// /obj/structure/transmitter/proc/set_tether_holder(atom/A)
// 	tether_holder = A
// 	if(attached_to)
// 		attached_to.reset_tether()

/obj/structure/transmitter/proc/reset_call(timeout = FALSE)
	var/obj/structure/transmitter/T = get_calling_phone()
	if(T)
		if(T.attached_to && ismob(T.attached_to.loc))
			var/mob/M = T.attached_to.loc
			to_chat(M, span_purple("[icon2html(src, M)] [phone_id] has hung up on you."))
			T.hangup_loop.start()
		if(attached_to && ismob(attached_to.loc))
			var/mob/M = attached_to.loc
			if(timeout)
				to_chat(M, span_purple("[icon2html(src, M)] Your call to [T.phone_id] has reached voicemail, nobody picked up the phone."))
				busy_loop.start()
				outring_loop.stop()
			else
				to_chat(M, span_purple("[icon2html(src, M)] You have hung up on [T.phone_id]."))
	if(outbound_call)
		outbound_call.inbound_call = null
		outbound_call = null
	if(inbound_call)
		inbound_call.outbound_call = null
		inbound_call = null
	if(timeout_timer_id)
		deltimer(timeout_timer_id)
		timeout_timer_id = null
	if(T)
		if(T.timeout_timer_id)
			deltimer(T.timeout_timer_id)
			T.timeout_timer_id = null
		T.update_icon()
		STOP_PROCESSING(SSobj, T)
	outring_loop.stop()
	if(!timeout) //we place the telephone back.
		attached_to?.reset_tether()
	STOP_PROCESSING(SSobj, src)

/obj/structure/transmitter/process()
	if(attached_to)
		if(attached_to.loc != src)
			if(!attached_to.tether)
				attached_to.reset_tether()
		else
			attached_to.reset_tether()
	if(inbound_call)
		if(!attached_to)
			STOP_PROCESSING(SSobj, src)
			return
		if(attached_to.loc == src)
			if(next_ring < world.time)
				// balloon_alert_to_viewers("Inconming call: [last_caller]")
				say("Inconming call: [current_caller]")
				playsound(loc, 'sound/machines/telephone/telephone_ring.ogg', 75, FALSE)
				visible_message(span_warning("[src] rings vigorously!"))
				next_ring = world.time + 3 SECONDS
	else if(outbound_call)
		var/obj/structure/transmitter/T = get_calling_phone()
		if(!T)
			STOP_PROCESSING(SSobj, src)
			return
		var/obj/item/telephone/P = T.attached_to
		// I'm pretty sure code below is never executed. But it is an original CMSS13 code. So I leave it as it is.
		if(P && attached_to.loc == src && P.loc == T && next_ring < world.time)
			playsound(get_turf(attached_to), 'sound/machines/telephone/telephone_ring.ogg', 20, FALSE, 14)
			visible_message(span_warning("[src] rings vigorously!"))
			next_ring = world.time + 3 SECONDS
	else
		STOP_PROCESSING(SSobj, src)
		return

/obj/structure/transmitter/proc/recall_phone()
	if(ismob(attached_to.loc))
		var/mob/M = attached_to.loc
		M.dropItemToGround(attached_to)
	playsound(loc, pick('sound/machines/telephone/rtb_handset_1.ogg',
								'sound/machines/telephone/rtb_handset_2.ogg',
								'sound/machines/telephone/rtb_handset_3.ogg',
								'sound/machines/telephone/rtb_handset_4.ogg',
								'sound/machines/telephone/rtb_handset_5.ogg'), 100, FALSE, 7)
	attached_to.forceMove(src)
	reset_call()
	busy_loop.stop()
	hangup_loop.stop()
	outring_loop.stop()
	update_icon()

/obj/structure/transmitter/proc/get_calling_phone()
	if(outbound_call)
		return outbound_call
	else if(inbound_call)
		return inbound_call
	return

/obj/structure/transmitter/proc/handle_speak(mob/speaking, list/speech_args)
	var/obj/structure/transmitter/T = get_calling_phone()
	if(!istype(T))
		return
	var/message = speech_args[SPEECH_MESSAGE]
	var/obj/item/telephone/P = T.attached_to
	if(!P || !attached_to)
		return
	P.handle_hear(speaking, speech_args)
	// attached_to.handle_hear(message, L, speaking)
	playsound(P, pick('sound/machines/telephone/talk_phone1.ogg',
						'sound/machines/telephone/talk_phone2.ogg',
						'sound/machines/telephone/talk_phone3.ogg',
						'sound/machines/telephone/talk_phone4.ogg',
						'sound/machines/telephone/talk_phone5.ogg',
						'sound/machines/telephone/talk_phone6.ogg',
						'sound/machines/telephone/talk_phone7.ogg'), 10)
	if(attached_to.raised)
		log_say("TELEPHONE: [key_name(speaking)] on Phone '[phone_id]' to '[T.phone_id]' said '[message]'")

#undef PHONE_NET_PUBLIC
#undef PHONE_NET_COMMAND
#undef PHONE_NET_CENTCOMM
#undef PHONE_NET_SYNDIE

#undef PHONE_DND_FORCED
#undef PHONE_DND_ON
#undef PHONE_DND_OFF
#undef PHONE_DND_FORBIDDEN

#undef TRANSMITTER_UNAVAILABLE
