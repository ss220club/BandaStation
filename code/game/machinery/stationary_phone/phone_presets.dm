#define PHONE_NET_PUBLIC	     			"Public"
#define PHONE_NET_COMMAND	     			"Command"
#define PHONE_NET_CENTCOM	   			  "CentCom"
#define PHONE_NET_BRIDGE	     			"Bridge"
#define PHONE_NET_SYNDIE	     			"Syndicate"

#define PHONE_DND_ON                "On"
#define PHONE_DND_OFF               "Off"
#define PHONE_DND_FORBIDDEN         "Forbidden"

#define STATUS_INBOUND              "Inbound call"
#define STATUS_ONGOING              "Ongoing call"
#define STATUS_OUTGOING             "Outgoing call"
#define STATUS_IDLE                 "Idle"

/obj/structure/transmitter/mounted
	name = "wallmount telephone"
	desc = "Настенный телефон."
	icon_state = "wall_phone"
	post_init_icon_state = "wall_phone"
	is_free = FALSE
	is_advanced = FALSE
	greyscale_colors = "#6e7766"

/obj/structure/transmitter/mounted/examine(mob/user)
	. = ..()
	. += span_notice("Мелким шрифтом на металлической табличке выгравировано:")
	. += span_notice("«Один звонок — $5. Вставьте монету или проведите картой. Жалобы на качество обслуживания принимаются по... \[нечитаемо\]»")

/obj/structure/transmitter/mounted/update_icon()
	. = ..()

	apply_transmitter_overlays(
		/*handset_state=*/ "wall_handset",
		/*handset_ring_state=*/ null,
		/*status_red=*/ "wall_red",
		/*status_yellow=*/ "wall_yellow",
		/*status_green=*/ "wall_green",
		/*light_state=*/ "wall_light"
	)

/obj/structure/transmitter/mounted/directional/north
	dir = NORTH
	pixel_y = 24

/obj/structure/transmitter/mounted/directional/south
	dir = SOUTH
	pixel_y = -26

/obj/structure/transmitter/mounted/directional/west
	dir = WEST
	pixel_x = 16

/obj/structure/transmitter/mounted/directional/east
	dir = EAST
	pixel_x = -16

// A personal command line for private offices.
/obj/structure/transmitter/command
	phone_category = PHONE_NET_COMMAND
	networks_transmit = list(PHONE_NET_PUBLIC, PHONE_NET_COMMAND)
	greyscale_colors = "#8198E1"

// THE "Red Phone". Can call the station networks AND the CentCom, if they feel like it.
/obj/structure/transmitter/bridge
	phone_category = PHONE_NET_BRIDGE
	networks_transmit = list(PHONE_NET_PUBLIC, PHONE_NET_COMMAND, PHONE_NET_CENTCOM)
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

/obj/structure/transmitter/science
	phone_category = PHONE_NET_PUBLIC
	networks_transmit = list(PHONE_NET_PUBLIC)
	greyscale_colors = COLOR_SCIENCE_PINK

/obj/structure/transmitter/service
	phone_category = PHONE_NET_PUBLIC
	networks_transmit = list(PHONE_NET_PUBLIC)
	greyscale_colors = COLOR_SERVICE_LIME

// The CentCom line. Call anyone anytime.
/obj/structure/transmitter/centcom
	phone_category = PHONE_NET_CENTCOM
	networks_transmit = list(PHONE_NET_PUBLIC, PHONE_NET_COMMAND, PHONE_NET_SYNDIE, PHONE_NET_CENTCOM)
	greyscale_colors = "#415F78"

/obj/structure/transmitter/centcom/click_alt(mob/user)
	var/input_name = stripped_input(user, "Rename this phone?", "Rename this phone", name, MAX_NAME_LEN)
	if(input_name)
		display_name = input_name

#undef PHONE_NET_PUBLIC
#undef PHONE_NET_COMMAND
#undef PHONE_NET_CENTCOM
#undef PHONE_NET_SYNDIE
#undef PHONE_NET_BRIDGE

#undef PHONE_DND_ON
#undef PHONE_DND_OFF
#undef PHONE_DND_FORBIDDEN

#undef STATUS_INBOUND
#undef STATUS_ONGOING
#undef STATUS_OUTGOING
#undef STATUS_IDLE
