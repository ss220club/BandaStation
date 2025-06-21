/obj/effect/abstract/overmap
	glide_size = 3
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "soap"
	/// The overmap object this visual effect is representing
	var/datum/overmap_object/my_overmap_object
	/// X offset of the visual dummy, for sprite
	var/visual_x_offset = 0
	/// Y offset of the visual dummy, for sprite
	var/visual_y_offset = 0

/obj/effect/abstract/overmap/Initialize()
	. = ..()
	var/matrix/M = new
	M.Translate(visual_x_offset, visual_y_offset)
	transform = M

/obj/effect/abstract/overmap/ruins
	icon = 'icons/overmap/64x64.dmi'
	icon_state = "ruins"
	visual_y_offset = -16
	visual_x_offset = -16

/obj/effect/abstract/overmap/ruins/Initialize()
	. = ..()
	icon_state = "ruins[rand(1,3)]"

/obj/effect/abstract/overmap/shuttle
	icon = 'icons/overmap/shuttle.dmi'
	icon_state = "shuttle"
	var/shuttle_idle_state = "shuttle"
	var/shuttle_forward_state = "shuttle_forward"
	var/shuttle_backward_state = "shuttle_backwards"

/obj/effect/abstract/overmap/relaymove(mob/living/user, direction)
	my_overmap_object.relaymove(user, direction)

/obj/effect/abstract/overmap/shuttle/station
	icon = 'icons/overmap/64x64.dmi'
	icon_state = "station"
	visual_y_offset = -16
	visual_x_offset = -16
	shuttle_idle_state = "station"
	shuttle_forward_state = "station"
	shuttle_backward_state = "station"

/obj/effect/abstract/overmap/shuttle/lavaland
	name = "Lavaland planet"
	icon = 'icons/overmap/64x64.dmi'
	icon_state = "lavaland"
	shuttle_idle_state = "lavaland"
	shuttle_forward_state = "lavaland"
	shuttle_backward_state = "lavaland"
	visual_y_offset = -16
	visual_x_offset = -16

/obj/effect/abstract/overmap/shuttle/jungle_planet
	name = "Jungle planet"
	icon = 'icons/overmap/64x64.dmi'
	icon_state = "jungleplanet"
	shuttle_idle_state = "jungleplanet"
	shuttle_forward_state = "jungleplanet"
	shuttle_backward_state = "jungleplanet"
	visual_y_offset = -16
	visual_x_offset = -16

/obj/effect/abstract/overmap/shuttle/icebox
	name = "Ice planet"
	icon = 'icons/overmap/64x64.dmi'
	icon_state = "jungleplanet"
	shuttle_idle_state = "iceplanet"
	shuttle_forward_state = "iceplanet"
	shuttle_backward_state = "iceplanet"
	visual_y_offset = -16
	visual_x_offset = -16
