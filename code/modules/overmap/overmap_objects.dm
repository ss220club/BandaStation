/obj/effect/abstract/overmap
	glide_size = 3
	/// The overmap object this visual effect is representing
	var/datum/overmap_object/my_overmap_object

/obj/effect/abstract/overmap/relaymove(mob/living/user, direction)
	my_overmap_object.relaymove(user, direction)

/datum/overmap_object
	/// The name of the overmpa object
	var/name = "Overmap object"
	/// It's x coordinate
	var/x = 0
	/// It's y coordinate
	var/y = 0
	/// The sunsystem it is stationed in
	var/datum/overmap_sun_system/current_system
	/// Whether it should make a visual dummy or not
	var/make_visual = TRUE
	/// Icon to use for the visual dummy
	var/icon = 'icons/obj/watercloset.dmi'
	/// Icon state to the visual dummy
	var/icon_state = "toilet10"
	/// Reference to the visual dummy
	var/obj/effect/abstract/overmap/my_visual
	/// X offset of the visual dummy, for sprite
	var/visual_x_offset = 0
	/// Y offset of the visual dummy, for sprite
	var/visual_y_offset = 0

	/// Related Z levels of this overmap object, for objects like the station, planets, ruin clusters
	var/list/related_levels = list()

/datum/overmap_object/New(datum/overmap_sun_system/passed_system, x_coord, y_coord)
	x = x_coord
	y = y_coord
	current_system = passed_system
	current_system.overmap_objects += src

	if(make_visual)
		my_visual = new(locate(x,y,current_system.z_level))
		my_visual.icon = icon
		my_visual.icon_state = icon_state
		my_visual.name = name
		my_visual.my_overmap_object = src
		var/matrix/M = new
		M.Translate(visual_x_offset, visual_y_offset)
		my_visual.transform = M

/datum/overmap_object/Destroy()
	current_system.overmap_objects -= src
	if(my_visual)
		my_visual.my_overmap_object = null
		qdel(my_visual)
	return ..()

/datum/overmap_object/proc/relaymove(mob/living/user, direction)
	return

/datum/overmap_object/proc/update_visual_position()
	if(my_visual)
		my_visual.x = x
		my_visual.y = y

/datum/overmap_object/process(delta_time)
	return

/datum/overmap_object/ruins
	name = "Cluster of ruins"
	icon = 'icons/overmap/64x64.dmi'
	icon_state = "ruins"
	visual_y_offset = -16
	visual_x_offset = -16

/datum/overmap_object/ruins/New(datum/overmap_sun_system/passed_system, x_coord, y_coord)
	..()
	my_visual.icon_state = "ruins[rand(1,3)]"

/datum/overmap_object/station
	name = "Space station"
	icon = 'icons/overmap/64x64.dmi'
	icon_state = "station"
	visual_y_offset = -16
	visual_x_offset = -16

/datum/overmap_object/lavaland
	name = "Lavaland planet"
	icon = 'icons/overmap/64x64.dmi'
	icon_state = "lavaland"
	visual_y_offset = -16
	visual_x_offset = -16

/datum/overmap_object/jungle_planet
	name = "Jungle planet"
	icon = 'icons/overmap/64x64.dmi'
	icon_state = "jungleplanet"
	visual_y_offset = -16
	visual_x_offset = -16
