/datum/overmap_sun_system
	/// Name of the sun system
	var/name = "Alpha"
	/// It's x coordinate in the galaxy
	var/x = 0
	/// It's y coordinate in the galaxy
	var/y = 0
	/// All overmap objects that are inside the sunsystem
	var/list/overmap_objects = list()
	/// The simulated Z level
	var/datum/space_level/my_space_level
	/// The z value of the simulated space level, for easier lookup
	var/z_level = 0

/datum/overmap_sun_system/proc/GetObjectsInRadius(_x,_y,rad)
	. = list()
	for(var/i in overmap_objects)
		var/datum/overmap_object/OO = i
		if(OO.x <= _x + rad && OO.x >= _x - rad && OO.y <= _y + rad && OO.y >= _y - rad)
			. += OO

/datum/overmap_sun_system/New()
	SSmapping.add_new_zlevel("Sun system [name]", list(ZTRAIT_LINKAGE = UNAFFECTED))
	z_level = world.maxz
	my_space_level = SSmapping.z_list[z_level]
