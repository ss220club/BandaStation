// MARK: Konu Curse
// Мне не стыдно
/obj/structure/temple_arch
	name = "арка храмовых врат"
	desc = "Циклопическая арка над входом в храм, высеченная из черного камня."
	icon = 'modular_bandastation/events/avangarde17/icons/160x160.dmi'
	icon_state = "arch_full"
	appearance_flags = 0
	layer = FLY_LAYER
	plane = ABOVE_GAME_PLANE
	anchored = TRUE
	pixel_x = -64
	pixel_y = -43
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/open = FALSE
	var/static/mutable_appearance/top_overlay
	color = "#adadad"

/obj/structure/temple_arch/Initialize(mapload)
	. = ..()
	icon_state = "arch_bottom"
	top_overlay = mutable_appearance('modular_bandastation/events/avangarde17/icons/160x160.dmi', "arch_top")
	top_overlay.layer = EDGED_TURF_LAYER
	add_overlay(top_overlay)

	AddComponent(/datum/component/seethrough, SEE_THROUGH_MAP_DEFAULT_TWO_TALL)

/obj/structure/temple_arch/singularity_pull(atom/singularity, current_size)
	return 0

// MARK: I'LL CAST KONU CURSE!!!
/obj/structure/gate_part
	name = "храмовые врата"
	desc = "Проклятые чёрные врата забытого храма. Кажется, вы видели их во снах..."
	icon = 'modular_bandastation/events/avangarde17/icons/gate_part.dmi'
	icon_state = "left"
	max_integrity = 1000
	anchored = TRUE
	density = TRUE
	opacity = FALSE
	layer = BELOW_MOB_LAYER
	color = "#adadad"

/obj/structure/gate_part/right
	icon_state = "right"

/obj/structure/gate_part/top
	icon = 'modular_bandastation/events/avangarde17/icons/gate_part_top.dmi'
	icon_state = "top"
	layer = ABOVE_ALL_MOB_LAYER
	density = FALSE
	opacity = TRUE

/obj/structure/gate_part/bottom
	icon = 'modular_bandastation/events/avangarde17/icons/gate_part_bottom.dmi'
	icon_state = "bottom"
	density = FALSE
	opacity = TRUE

/obj/machinery/door/password/voice/temple
	name = "храмовые врата"
	desc = "Проклятые чёрные врата забытого храма. Кажется, вы видели их во снах..."
	icon = 'modular_bandastation/events/avangarde17/icons/gate_door.dmi'
	icon_state = "closed"
	password = "куб"
	opacity = FALSE
	door_open = 'sound/effects/stonedoor_openclose.ogg'
	door_close = 'sound/effects/stonedoor_openclose.ogg'
	door_deny = 'sound/effects/shieldbash.ogg'
