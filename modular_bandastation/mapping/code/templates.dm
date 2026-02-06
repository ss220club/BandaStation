// MARK: General
/datum/lazy_template/nukie_base
	map_dir = "_maps/templates/lazy_templates/ss220"
	map_name = "syndie_cc_small"
	key = LAZY_TEMPLATE_KEY_NUKIEBASE

/datum/lazy_template/syndie_cc
	map_dir = "_maps/templates/lazy_templates/ss220"
	map_name = "syndie_cc"
	key = LAZY_TEMPLATE_KEY_SYNDIE_CC

// MARK: Shuttles
/datum/map_template/shuttle/sit
	port_id = "sit"
	who_can_purchase = null
	prefix = "_maps/shuttles/ss220/"

/datum/map_template/shuttle/sit/basic
	suffix = "basic"
	name = "basic syndicate sit shuttle"
	description = "Base SIT shuttle, spawned by default for syndicate infiltration team to use."

/datum/map_template/shuttle/sst
	port_id = "sst"
	who_can_purchase = null
	prefix = "_maps/shuttles/ss220/"

/datum/map_template/shuttle/sst/basic
	suffix = "basic"
	name = "basic syndicate sst shuttle"
	description = "Base SST shuttle, spawned by default for syndicate strike team to use."

/datum/map_template/shuttle/argos
	port_id = "argos"
	who_can_purchase = null
	prefix = "_maps/shuttles/ss220/"

/datum/map_template/shuttle/argos/basic
	suffix = "basic"
	name = "basic argos shuttle"
	description = "Base Argos shuttle."

/datum/map_template/shuttle/specops
	port_id = "specops"
	who_can_purchase = null
	prefix = "_maps/shuttles/ss220/"

/datum/map_template/shuttle/specops/basic
	suffix = "basic"
	name = "basic specops shuttle"
	description = "Base Specops shuttle."

// Gamma
/datum/map_template/shuttle/gamma
	port_id = "gamma"
	who_can_purchase = null
	prefix = "_maps/shuttles/ss220/"

/datum/map_template/shuttle/gamma/basic
	suffix = "basic"
	name = "Standard Gamma Armory Shuttle"

/datum/map_template/shuttle/gamma/clown
	suffix = "clown"
	name = "Clown Gamma Armory Shuttle"

/datum/map_template/shuttle/gamma/destroyed
	suffix = "destroyed"
	name = "Destroyed Gamma Armory Shuttle"

/datum/map_template/shuttle/gamma/empty
	suffix = "empty"
	name = "Empty Gamma Armory Shuttle"

/datum/map_template/shuttle/assault_pod/nanotrasen
	suffix = "nt"
	name = "assault pod (Nanotrasen)"
	prefix = "_maps/shuttles/ss220/"

/datum/map_template/shuttle/soundhand
	port_id = "soundhand"
	who_can_purchase = null
	prefix = "_maps/shuttles/ss220/"

/datum/map_template/shuttle/soundhand/basic
	suffix = "basic"
	name = "basic soundhand shuttle"
	description = "Base Soundhand shuttle."

// MARK: Shuttles Overrides
/datum/map_template/shuttle/infiltrator/basic
	prefix = "_maps/shuttles/ss220/"

// MARK: Deathmatch
/datum/lazy_template/deathmatch/underground_thunderdome
	name = "Underground Thunderdome"
	map_dir = "_maps/deathmatch/ss220"
	map_name = "underground_arena_big"
	key = "underground_arena_big"

#define SOUNDHAND_RAM_WARN_TIME (10 SECONDS)
/obj/docking_port/mobile/soundhand/proc/ram_to(obj/docking_port/stationary/target)
	if(QDELETED(src) || QDELETED(target))
		return FALSE

	initiate_drop_landing(target, SOUNDHAND_RAM_WARN_TIME)
	addtimer(CALLBACK(src, PROC_REF(_do_ram_to), target), SOUNDHAND_RAM_WARN_TIME)
	return TRUE
#undef SOUNDHAND_RAM_WARN_TIME

/obj/docking_port/mobile/soundhand/proc/_do_ram_to(obj/docking_port/stationary/target)
	if(QDELETED(src) || QDELETED(target))
		return

	ram_clear_landing_zone(target)
	initiate_docking(target, force = TRUE)

/obj/docking_port/mobile/soundhand/proc/ram_clear_landing_zone(obj/docking_port/stationary/target)
	// Берём прямоугольник, куда встанет шаттл при target.dir
	var/list/bounds = return_coords(target.x, target.y, target.dir)
	var/min_x = bounds[1]
	var/min_y = bounds[2]
	var/max_x = bounds[3]
	var/max_y = bounds[4]

	for(var/x in min_x to max_x)
		for(var/y in min_y to max_y)
			var/turf/T = locate(x, y, target.z)
			if(!T)
				continue

			// Если это "наши" шаттл-турфы — не трогаем
			if(shuttle_areas && shuttle_areas[T.loc])
				continue

			// 1) Удаляем/ломаем плотные объекты (окна, шкафы, решётки, машины)
			for(var/atom/movable/A as anything in T)
				if(QDELETED(A))
					continue
				if(A.density)
					// мягче: A.ex_act(EXPLODE_HEAVY) если у вас это норм
					qdel(A)

			// 2) Ломаем плотные турфы (стены)
			if(T.density)
				// В tg обычно есть scrape/ReplaceWith/etc, но в разных форках по-разному.
				// Самый универсальный путь — ex_act, если у турфа есть реакция.
				T.ex_act(EXPLODE_HEAVY)

				// Если у вас ex_act не сносит стену, тогда заменяй явно:
				// T.ChangeTurf(/turf/open/floor/plating)  // или /turf/open/space
