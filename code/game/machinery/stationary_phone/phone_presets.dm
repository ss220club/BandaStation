#define PHONE_NET_PUBLIC	     			"Public"
#define PHONE_NET_COMMAND	     			"Command"
#define PHONE_NET_CENTCOMM	   			"CentComm"
#define PHONE_NET_BRIDGE	     			"Bridge"
#define PHONE_NET_SYNDIE	     			"Syndicate"

#define PHONE_DND_FORCED            "Forced"
#define PHONE_DND_ON                "On"
#define PHONE_DND_OFF               "Off"
#define PHONE_DND_FORBIDDEN         "Forbidden"

/// always available.
/obj/structure/transmitter/no_dnd
	do_not_disturb = PHONE_DND_FORBIDDEN

/// you don't see it in the phone lists and can't call here.
/obj/structure/transmitter/hidden
	do_not_disturb = PHONE_DND_FORCED

// mounted in a wall machine
/obj/structure/transmitter/mounted
	name = "telephone receiver"
	desc = "It is a wall mounted telephone."
	icon_state = "wall_phone"

/obj/structure/transmitter/mounted/examine(mob/user)
	. = ..()
	. += span_notice("The fine print on the metal placard reads:")
	. += span_notice("\"$5 per call, swipe to pay. Regarding all complaints about the quality of service, please call... \[unreadable\]\"")

/obj/structure/transmitter/mounted/no_dnd
	do_not_disturb = PHONE_DND_FORBIDDEN

/obj/structure/transmitter/mounted/hidden
	do_not_disturb = PHONE_DND_FORCED


//Personal command line for private offices.
/obj/structure/transmitter/command
	phone_category = PHONE_NET_COMMAND
	networks_transmit = list(PHONE_NET_PUBLIC, PHONE_NET_COMMAND)

// THE "Red Phone". Can call the station networks AND the CentCom, if they feel like it.
/obj/structure/transmitter/bridge
	phone_category = PHONE_NET_BRIDGE
	networks_transmit = list(PHONE_NET_PUBLIC, PHONE_NET_COMMAND)

// The CentCom line. Call anyone anytime.
/obj/structure/transmitter/centcom
	phone_category = PHONE_NET_CENTCOMM
	networks_transmit = list(PHONE_NET_PUBLIC, PHONE_NET_COMMAND, PHONE_NET_SYNDIE, PHONE_NET_CENTCOMM)
	can_rename = TRUE



/obj/structure/transmitter/centcom/click_alt(mob/user)
	var/input_name = stripped_input(user, "Rename this phone?", "Rename this phone", name, MAX_NAME_LEN)
	if(input_name)
		name = input_name
		phone_id = input_name

/obj/structure/transmitter/engineering
	greyscale_colors = COLOR_LIGHT_ORANGE

#undef PHONE_NET_PUBLIC
#undef PHONE_NET_COMMAND
#undef PHONE_NET_CENTCOMM
#undef PHONE_NET_SYNDIE
#undef PHONE_NET_BRIDGE

#undef PHONE_DND_FORCED
#undef PHONE_DND_ON
#undef PHONE_DND_OFF
#undef PHONE_DND_FORBIDDEN
