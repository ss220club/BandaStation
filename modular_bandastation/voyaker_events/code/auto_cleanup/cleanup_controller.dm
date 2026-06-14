SUBSYSTEM_DEF(casing_cleanup)
	name = "Casing Cleanup"
	wait = 2 MINUTES
	runlevels = RUNLEVEL_GAME

/datum/controller/subsystem/casing_cleanup/fire()
	var/removed = 0
	for(var/obj/item/ammo_casing/C in GLOB.shell_casings)
		if(QDELETED(C))
			continue
		if(world.time - C.spawn_time < 15 MINUTES)
			continue
		removed++
		qdel(C)
	if(removed)
		priority_announce(
			"Мы прибрали гильзы на всех локациях, чтобы они не мешались вам под ногами.",
			"Сообщение группы Чистильщиков"
		)
