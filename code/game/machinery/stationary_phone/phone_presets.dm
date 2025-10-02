#define PHONE_NET_PUBLIC	     			"Общий"
#define PHONE_NET_COMMAND	     			"Командный"
#define PHONE_NET_CENTCOM	   			  "ЦентКом"
#define PHONE_NET_BRIDGE	     			"Мостик"
#define PHONE_NET_SYNDIE	     			"Синдикат"

#define PHONE_DND_ON                "On"
#define PHONE_DND_OFF               "Off"
#define PHONE_DND_FORBIDDEN         "Forbidden"

#define STATUS_INBOUND              "Inbound call"
#define STATUS_ONGOING              "Ongoing call"
#define STATUS_OUTGOING             "Outgoing call"
#define STATUS_IDLE                 "Idle"

/obj/structure/transmitter/mounted
	name = "wallmount telephone"
	desc = "Настенный таксофон. Кажется, платный!"
	icon_state = "wall_phone"
	post_init_icon_state = "wall_phone"
	is_free = FALSE
	is_advanced = FALSE
	greyscale_colors = "#6e7766"
	phone_category = null // эта штобы нельзя было звонить на таксофоны

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
	networks_transmit = list(PHONE_NET_PUBLIC, PHONE_NET_COMMAND, PHONE_NET_BRIDGE)
	greyscale_colors = "#8198E1"
	phone_icon = "shield-halved"
	was_renamed = TRUE

// THE "Red Phone". Can call the station networks AND the CentCom, if they feel like it.
/obj/structure/transmitter/bridge
	phone_category = PHONE_NET_BRIDGE
	networks_transmit = list(PHONE_NET_PUBLIC, PHONE_NET_COMMAND, PHONE_NET_CENTCOM)
	greyscale_colors = "#CB3E3E"
	phone_icon = "shield-halved"
	was_renamed = TRUE

/obj/structure/transmitter/engineering
	phone_category = PHONE_NET_PUBLIC
	networks_transmit = list(PHONE_NET_PUBLIC, PHONE_NET_COMMAND)
	greyscale_colors = COLOR_ENGINEERING_ORANGE
	phone_icon = "gear"
	was_renamed = TRUE

/obj/structure/transmitter/cargo
	phone_category = PHONE_NET_PUBLIC
	networks_transmit = list(PHONE_NET_PUBLIC)
	greyscale_colors = COLOR_CARGO_BROWN
	phone_icon = "boxes-stacked"
	was_renamed = TRUE

/obj/structure/transmitter/medbay
	phone_category = PHONE_NET_PUBLIC
	networks_transmit = list(PHONE_NET_PUBLIC)
	greyscale_colors = COLOR_MEDICAL_BLUE
	phone_icon = "kit-medical"
	was_renamed = TRUE

/obj/structure/transmitter/secutiry
	phone_category = PHONE_NET_PUBLIC
	networks_transmit = list(PHONE_NET_PUBLIC, PHONE_NET_COMMAND)
	greyscale_colors = COLOR_SECURITY_RED
	phone_icon = "user-secret"
	was_renamed = TRUE

/obj/structure/transmitter/science
	phone_category = PHONE_NET_PUBLIC
	networks_transmit = list(PHONE_NET_PUBLIC)
	greyscale_colors = COLOR_SCIENCE_PINK
	phone_icon = "flask"
	was_renamed = TRUE

/obj/structure/transmitter/service
	phone_category = PHONE_NET_PUBLIC
	networks_transmit = list(PHONE_NET_PUBLIC)
	greyscale_colors = COLOR_SERVICE_LIME
	phone_icon = "bell-concierge"
	was_renamed = TRUE

// The CentCom line. Call anyone anytime.
/obj/structure/transmitter/centcom
	phone_category = PHONE_NET_CENTCOM
	networks_transmit = list(PHONE_NET_PUBLIC, PHONE_NET_COMMAND, PHONE_NET_SYNDIE, PHONE_NET_CENTCOM)
	greyscale_colors = "#415F78"
	phone_icon = "closed-captioning"

/obj/structure/transmitter/click_alt(mob/user)
	if(was_renamed && !istype(src, /obj/structure/transmitter/centcom))
		to_chat(user, span_warning("Этот телефон не может быть переименован!"))
		return

	var/input_name = tgui_input_text(user, "Как вы хотите назвать этот телефон? Изменить название можно только один раз!", "Переименовать телефон", display_name, MAX_NAME_LEN)
	if(input_name && can_interact(user))
		display_name = input_name
		was_renamed = TRUE
		name = "[declent_ru(NOMINATIVE)] «[display_name]»"

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
