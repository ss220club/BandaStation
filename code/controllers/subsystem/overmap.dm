SUBSYSTEM_DEF(overmap)
	name = "Overmap"
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	wait = 0.5 SECONDS
	/// All the existing sun systems, it's gonna be atleast 1 including the main system
	var/list/sun_systems = list()
	/// The mandatory and main sun system
	var/datum/overmap_sun_system/main_system

/datum/controller/subsystem/overmap/Initialize()
	return ..()

/**
 * MappingInit() is called shortly after SSmapping starts initializing.
 *
 * It needs to be called there so mapping initializes all sorts of templates and other things that will be nessecary in here.
*/
/datum/controller/subsystem/overmap/proc/MappingInit()
	//Initialize sun systems
	main_system = CreateNewSunSystem(new /datum/overmap_sun_system())
	//Seed some random objects in the main system
	//Seed some space trash here that will yield random loots
	//Seed some asteroids that will be mine'able

/**
 * CreateNewSunSystem() is called to create and register a new sunsystem
*/
/datum/controller/subsystem/overmap/proc/CreateNewSunSystem(datum/overmap_sun_system/new_sunsystem)
	sun_systems += new_sunsystem
	return new_sunsystem

/datum/controller/subsystem/overmap/fire(resumed = FALSE)
	return
