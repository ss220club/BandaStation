GLOBAL_LIST_EMPTY(shell_casings)

/obj/item/ammo_casing
	var/spawn_time

/obj/item/ammo_casing/Initialize(mapload)
	. = ..()
	spawn_time = world.time
	GLOB.shell_casings += src

/obj/item/ammo_casing/Destroy()
	GLOB.shell_casings -= src
	return ..()
