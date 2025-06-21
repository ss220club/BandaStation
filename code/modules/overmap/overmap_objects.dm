/datum/overmap_object
	/// Unique integer ID, used for easy communication between the server and clients UI
	var/id
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
	/// Reference to the visual dummy
	var/obj/effect/abstract/overmap/my_visual

	/// The type of the visual that will be spawned for this object
	var/visual_type = /obj/effect/abstract/overmap

	/// Related Z levels of this overmap object, for objects like the station, planets, ruin clusters
	var/list/related_levels = list()

/datum/overmap_object/New(datum/overmap_sun_system/passed_system, x_coord, y_coord)
	SSovermap.RegisterObject(src)

	x = x_coord
	y = y_coord
	current_system = passed_system
	current_system.overmap_objects += src

	if(make_visual)
		my_visual = new visual_type(locate(x,y,current_system.z_level))

		my_visual.name = name
		my_visual.my_overmap_object = src


/datum/overmap_object/Destroy()
	SSovermap.UnregisterObject(src)

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
	visual_type = /obj/effect/abstract/overmap/ruins

