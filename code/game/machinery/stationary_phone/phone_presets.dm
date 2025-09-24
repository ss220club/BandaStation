#define PHONE_NET_PUBLIC	     			"Public"
#define PHONE_NET_COMMAND	     			"Command"
#define PHONE_NET_CENTCOMM	   			"CentComm"
#define PHONE_NET_BRIDGE	     			"Bridge"
#define PHONE_NET_SYNDIE	     			"Syndicate"

#define PHONE_DND_FORCED            "Forced"
#define PHONE_DND_ON                "On"
#define PHONE_DND_OFF               "Off"
#define PHONE_DND_FORBIDDEN         "Forbidden"

#define STATUS_INBOUND              "Inbound call"
#define STATUS_ONGOING              "Ongoing call"
#define STATUS_OUTGOING             "Outgoing call"
#define STATUS_IDLE                 "Idle"

#define COMSIG_TRANSMITTER_UPDATE_ICON "transmitter_update_icon"

/obj/structure/transmitter/mounted
	name = "telephone receiver"
	desc = "It is a wall mounted telephone."
	icon_state = "wall_phone"
	is_free = FALSE
	greyscale_colors = "#6e7766"

/obj/structure/transmitter/mounted/examine(mob/user)
	. = ..()
	. += span_notice("The fine print on the metal placard reads:")
	. += span_notice("\"$5 per call, swipe your ID or insert a coin to pay. Regarding all complaints about the quality of service, please call... \[unreadable\]\"")

/obj/structure/transmitter/mounted/update_icon()
	. = ..()
	SEND_SIGNAL(src, COMSIG_TRANSMITTER_UPDATE_ICON)

	cut_overlays()

	if(attached_to.loc == src)
		var/mutable_appearance/handset_overlay = mutable_appearance(icon, "wall_handset")
		handset_overlay.plane = plane
		add_overlay(handset_overlay)

	var/status_overlay

	if(do_not_disturb == PHONE_DND_ON || do_not_disturb == PHONE_DND_FORCED)
		status_overlay = "wall_red"
	else
		if(status == STATUS_INBOUND)
			status_overlay = "wall_yellow"
		else
			status_overlay = "wall_green"

	if(status_overlay)
		var/mutable_appearance/status_appearance = mutable_appearance(icon, status_overlay, src)
		status_appearance.plane = plane
		add_overlay(status_appearance)

		var/mutable_appearance/emissive_overlay = emissive_appearance(icon, "wall_light", src)
		emissive_overlay.plane = FLOAT_PLANE
		add_overlay(emissive_overlay)

// A personal command line for private offices.
/obj/structure/transmitter/command
	phone_category = PHONE_NET_COMMAND
	networks_transmit = list(PHONE_NET_PUBLIC, PHONE_NET_COMMAND)
	greyscale_colors = "#8198E1"

// THE "Red Phone". Can call the station networks AND the CentCom, if they feel like it.
/obj/structure/transmitter/bridge
	phone_category = PHONE_NET_BRIDGE
	networks_transmit = list(PHONE_NET_PUBLIC, PHONE_NET_COMMAND, PHONE_NET_CENTCOMM)
	greyscale_colors = "#CB3E3E"

/obj/structure/transmitter/engineering
	phone_category = PHONE_NET_PUBLIC
	networks_transmit = list(PHONE_NET_PUBLIC, PHONE_NET_COMMAND)
	greyscale_colors = COLOR_ENGINEERING_ORANGE

/obj/structure/transmitter/cargo
	phone_category = PHONE_NET_PUBLIC
	networks_transmit = list(PHONE_NET_PUBLIC)
	greyscale_colors = COLOR_CARGO_BROWN

/obj/structure/transmitter/medbay
	phone_category = PHONE_NET_PUBLIC
	networks_transmit = list(PHONE_NET_PUBLIC)
	greyscale_colors = COLOR_MEDICAL_BLUE

/obj/structure/transmitter/secutiry
	phone_category = PHONE_NET_PUBLIC
	networks_transmit = list(PHONE_NET_PUBLIC, PHONE_NET_COMMAND)
	greyscale_colors = COLOR_SECURITY_RED

// The CentCom line. Call anyone anytime.
/obj/structure/transmitter/centcom
	phone_category = PHONE_NET_CENTCOMM
	networks_transmit = list(PHONE_NET_PUBLIC, PHONE_NET_COMMAND, PHONE_NET_SYNDIE, PHONE_NET_CENTCOMM)
	greyscale_colors = "#415F78"

/obj/structure/transmitter/centcom/click_alt(mob/user)
	var/input_name = stripped_input(user, "Rename this phone?", "Rename this phone", name, MAX_NAME_LEN)
	if(input_name)
		display_name = input_name

#undef PHONE_NET_PUBLIC
#undef PHONE_NET_COMMAND
#undef PHONE_NET_CENTCOMM
#undef PHONE_NET_SYNDIE
#undef PHONE_NET_BRIDGE

#undef PHONE_DND_FORCED
#undef PHONE_DND_ON
#undef PHONE_DND_OFF
#undef PHONE_DND_FORBIDDEN
