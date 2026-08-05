SUBSYSTEM_DEF(casing_cleanup)
	name = "EFTK Casing Cleanup System"
	wait = 2 MINUTES
	runlevels = RUNLEVEL_GAME

/datum/controller/subsystem/casing_cleanup/fire()
	for(var/obj/item/ammo_casing/C in GLOB.shell_casings)
		if(QDELETED(C))
			continue
		if(world.time - C.spawn_time < 15 MINUTES)
			continue
		if(!isturf(C.loc))
			continue
		qdel(C)

SUBSYSTEM_DEF(gibs_cleanup)
	name = "EFTK Gibs Cleanup System"
	wait = 5 MINUTES
	runlevels = RUNLEVEL_GAME

/datum/controller/subsystem/gibs_cleanup/fire()
	for(var/obj/effect/decal/cleanable/blood/gibs/G in GLOB.world_gibs)
		if(QDELETED(G))
			continue
		if(world.time - G.spawn_time < 10 MINUTES)
			continue
		if(!isturf(G.loc))
			continue
		qdel(G)
