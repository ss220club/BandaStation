/obj/structure/neon_sign
	name = "neon sign"
	icon = 'modular_bandastation/voyaker_events/icons/urban64x64_signs.dmi'
	icon_state = "open"
	anchored = TRUE
	density = FALSE
	layer = ABOVE_WINDOW_LAYER
	var/lit_icon_state
	var/enabled = TRUE
	light_range = 2
	light_power = 0.8
	light_color = "#FFD080"

/obj/structure/neon_sign/Initialize(mapload)
	. = ..()
	update_sign()

/obj/structure/neon_sign/proc/update_sign()
	if(enabled)
		icon_state = lit_icon_state
		set_light_on(TRUE)
	else
		icon_state = base_icon_state
		set_light_on(FALSE)

/obj/structure/neon_sign/attack_hand(mob/user)
	enabled = !enabled
	update_sign()
	to_chat(user, span_notice("Вы переключаете вывеску."))

/obj/structure/neon_sign/jacks
	name = "Jack's Supplies"
	icon_state = "jacksopen_on"
	base_icon_state = "jacksopen"
	lit_icon_state = "jacksopen_on"
	light_color = "#66CCFF"

/obj/structure/neon_sign/nightgold
	name = "Night Gold Casino"
	lit_icon_state = "nightgoldcasinoopen_on"
	base_icon_state = "nightgoldcasinoopen"
	lit_icon_state = "nightgoldcasinoopen_on"
	light_color = "#FFCC55"

/obj/structure/neon_sign/open
	name = "Open"
	icon_state = "open_on"
	base_icon_state = "open"
	lit_icon_state = "open_on"
	light_color = "#FFCC55"

/obj/structure/neon_sign/open2
	name = "Open"
	icon_state = "open_on2"
	base_icon_state = "open2"
	lit_icon_state = "open_on2"
	light_color = "#FFCC55"

/obj/structure/neon_sign/pizza
	name = "Pizza Neon"
	icon_state = "pizzaneon_on"
	base_icon_state = "pizzaneon"
	lit_icon_state = "pizzaneon_on"
	light_color = "#FF8844"

/obj/structure/neon_sign/nt_mart
	name = "NT Mart"
	icon_state = "weymartsign2"
	base_icon_state = "weymartsign2_off"
	lit_icon_state = "weymartsign2"
	light_color = "#FF8844"

/obj/structure/neon_sign/mechanic
	name = "Mechanic"
	icon_state = "mechanicopen_on2"
	base_icon_state = "mechanicopen2"
	lit_icon_state = "mechanicopen_on2"
	light_color = "#44ffff"

/obj/structure/neon_sign/cuppajoes
	name = "Cuppa Joes"
	icon_state = "cuppajoes"
	base_icon_state = "cuppajoesoff"
	lit_icon_state = "cuppajoes"
	light_color = "#922320"



