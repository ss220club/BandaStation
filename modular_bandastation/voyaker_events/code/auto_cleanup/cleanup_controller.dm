SUBSYSTEM_DEF(casing_cleanup)
	name = "EFTK Casing Cleanup System"
	wait = 2 MINUTES
	runlevels = RUNLEVEL_GAME
	var/static/list/casing_cleanup_blacklist = list(
		/obj/item/ammo_box,
		/obj/item/ammo_box/magazine,
		/obj/item/storage/box,
		/obj/item/storage/box/lethalshot,
		/obj/item/storage/bag/trash/bluespace,
		/obj/item/storage/toolbox/ammobox/c762x54mmr_bullets,
		/obj/item/storage/backpack,
		/obj/item/storage/belt,
	)

/datum/controller/subsystem/casing_cleanup/fire()
	var/removed = 0
	for(var/obj/item/ammo_casing/C in GLOB.shell_casings)
		if(QDELETED(C))
			continue
		if(world.time - C.spawn_time < 15 MINUTES)
			continue
		if(!isturf(C.loc))
			continue
		var/skip = FALSE
		for(var/type in casing_cleanup_blacklist)
			if(istype(C.loc, type))
				skip = TRUE
				break
		if(skip)
			continue
		removed++
		qdel(C)
	if(removed)
		priority_announce(
			"Мы прибрали гильзы на всех локациях, чтобы они не мешались вам под ногами.",
			"Сообщение группы Чистильщиков"
		)

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
