/**
 * HITBOX
 * The core of multitile. Acts as a relay for damage and stops people from walking onto the multitle sprite
 * has changed bounds and as thus must always be forcemoved so it doesnt break everything
 * I would use pixel movement but the maptick caused by it is way too high and a fake tile based movement might work? but I want this to at least pretend to be generic
 * Thus we just use this relay. it's an obj so we can make sure all the damage procs that work on root also work on the hitbox
 * These ones are mainly used for multitile vehicles. If you want to use it for other movable atoms is better to write our own hitbox logic
 * Ported to SS220 TG from TGMC
 */

// MARK: BASIC HITBOX LOGIC

///This one is both basic type and 3x3 hitbox
/obj/hitbox
	density = TRUE
	anchored = TRUE
	invisibility = INVISIBILITY_MAXIMUM
	bound_x = -32
	bound_y = -32
	max_integrity = INFINITY
	move_resist = INFINITY // non forcemoving this could break gliding so lets just say no
	explosion_block = 1
	///The "parent" that this hitbox is attached to and to whom it will relay damage
	var/obj/vehicle/root = null
	///Length of the vehicle. Assumed to be longer than it is wide
	var/vehicle_length = 96
	///Width of the vehicle
	var/vehicle_width = 96

/obj/hitbox/Initialize(mapload, obj/vehicle/new_root)
	. = ..()
	bound_height = vehicle_length
	bound_width = vehicle_width
	root = new_root
	resistance_flags = root.resistance_flags
	RegisterSignal(new_root, COMSIG_MOVABLE_MOVED, PROC_REF(root_move))
	RegisterSignal(new_root, COMSIG_QDELETING, PROC_REF(root_delete))

///When root deletes is the only time we want to be deleting
/obj/hitbox/proc/root_delete()
	SIGNAL_HANDLER
	qdel(src, TRUE)

///When the owner moves, let's move with them!
/obj/hitbox/proc/root_move(atom/movable/mover, atom/oldloc, direction, forced, list/turf/old_locs)
	SIGNAL_HANDLER
	//direction is null here, so we improvise
	direction = get_dir(oldloc, mover)
	forceMove(mover.loc)
