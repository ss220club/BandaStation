/// Time the fist takes to close on a target.
#define GOLDEN_GARDREN_FIST_GRAB_TIME (1 SECONDS)
/// Time a held target needs to wrench itself free.
#define GOLDEN_GARDREN_FIST_ESCAPE_TIME (8 SECONDS)
/// Time someone standing next to the mech needs to pry a held target free.
#define GOLDEN_GARDREN_FIST_RESCUE_TIME (4 SECONDS)
/// How far the fist throws what it holds, in tiles.
#define GOLDEN_GARDREN_FIST_THROW_RANGE 7
/// Brute damage the throw itself deals to a thrown body, before whatever it hits on landing.
#define GOLDEN_GARDREN_FIST_THROW_DAMAGE 10
/// Brute damage a thrown object deals to whoever it hits.
#define GOLDEN_GARDREN_FIST_OBJECT_HIT_DAMAGE 20
/// Oxygen damage per second while the fist squeezes: the target cannot breathe.
#define GOLDEN_GARDREN_FIST_CHOKE_RATE 4
/// How long the fist has to squeeze before the bones start to give.
#define GOLDEN_GARDREN_FIST_CRUSH_DELAY (8 SECONDS)
/// Brute damage per second to the chest once the bones give.
#define GOLDEN_GARDREN_FIST_CRUSH_RATE 3
/// How often a crushing squeeze breaks the bones one stage further.
#define GOLDEN_GARDREN_FIST_FRACTURE_INTERVAL (6 SECONDS)
/// Damage per second a squeezed object takes until it breaks.
#define GOLDEN_GARDREN_FIST_OBJECT_CRUSH_RATE 25
/// Trait source for everything the fist does to its target.
#define GOLDEN_GARDREN_FIST_TRAIT "golden_gardren_fist"

/// Objects the fist does not take: building parts and materials, wiring and pipes, signs and other fixtures of the station itself.
GLOBAL_LIST_INIT(golden_gardren_fist_forbidden, typecacheof(list(
	/obj/structure/broken_flooring,
	/obj/structure/cable,
	/obj/structure/closet/supplypod,
	/obj/structure/curtain,
	/obj/structure/disposalconstruct,
	/obj/structure/disposalpipe,
	/obj/structure/door_assembly,
	/obj/structure/extinguisher_cabinet,
	/obj/structure/fake_stairs,
	/obj/structure/falsewall,
	/obj/structure/fans,
	/obj/structure/fireaxecabinet,
	/obj/structure/frame,
	/obj/structure/girder,
	/obj/structure/grille,
	/obj/structure/holosign,
	/obj/structure/ladder,
	/obj/structure/lattice,
	/obj/structure/mineral_door,
	/obj/structure/mirror,
	/obj/structure/noticeboard,
	/obj/structure/plasticflaps,
	/obj/structure/platform,
	/obj/structure/railing,
	/obj/structure/sign,
	/obj/structure/spawner,
	/obj/structure/stairs,
	/obj/structure/steps,
	/obj/structure/table_frame,
	/obj/structure/transit_tube,
	/obj/structure/window,
)))

/**
 * ## Golden-Gardren fist
 *
 * A Titanfall-style mech fist for the pilot of the Gardren or the combined mech. In grab mode the pilot's hand click
 * on an adjacent target closes the fist on it instead of punching. The fist takes living beings and large loose objects
 * such as furniture, lockers or portable machines, but not items, building parts or fixtures of the station.
 * Whatever it holds is carried in front of the mech; a held body cannot use its hands.
 * Holding something, the pilot can throw it hard with a click anywhere ahead, or squeeze: a body chokes and,
 * if the squeeze goes on long enough, its bones start to break; an object is crushed until it breaks.
 * A held body needs time to wrench itself free; anyone next to a mech that stands still can pry it out faster with a non-combat hand click.
 */
/datum/component/golden_gardren_fist
	/// How far in front of the mech's sprite a held thing is drawn, in pixels.
	var/reach = 16
	/// Whether the pilot's hand clicks close the fist instead of punching.
	var/grab_mode = FALSE
	/// Whatever the fist holds right now: a living being or an object.
	var/atom/movable/held
	/// Whether the fist is closing on something right now.
	var/grabbing = FALSE
	/// Whether someone is trying to get the held body out right now.
	var/escaping = FALSE
	/// Set while the fist itself carries a held object along, so that move is not taken for someone else taking it.
	var/carrying = FALSE
	/// Pixel offsets and layer of a held object before the fist lifted it.
	var/list/held_object_look
	/// Whether the fist squeezes whatever it holds.
	var/squeezing = FALSE
	/// For how long the current squeeze has gone on, in deciseconds.
	var/squeeze_time = 0
	/// Bone wound severity the squeeze has reached on the held body.
	var/fracture_stage = WOUND_SEVERITY_TRIVIAL
	/// Squeeze time at which the bones give one stage further.
	var/next_fracture_time = 0

/datum/component/golden_gardren_fist/Initialize(reach = 16)
	if(!istype(parent, /obj/vehicle/sealed/mecha))
		return COMPONENT_INCOMPATIBLE
	src.reach = reach

/datum/component/golden_gardren_fist/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MECHA_MELEE_CLICK, PROC_REF(on_melee_click))
	RegisterSignal(parent, COMSIG_MECHA_EQUIPMENT_CLICK, PROC_REF(on_equipment_click))
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_attack_hand))

/datum/component/golden_gardren_fist/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MECHA_MELEE_CLICK, COMSIG_MECHA_EQUIPMENT_CLICK, COMSIG_ATOM_ATTACK_HAND))

/datum/component/golden_gardren_fist/Destroy(force)
	if(held)
		release()
	STOP_PROCESSING(SSobj, src)
	return ..()

/// Whether [pilot] sits in the seat that owns the fist.
/datum/component/golden_gardren_fist/proc/is_fist_pilot(mob/living/pilot)
	var/obj/vehicle/sealed/mecha/mech = parent
	return pilot in mech.return_controllers_with_flag(VEHICLE_CONTROL_MELEE)

/datum/component/golden_gardren_fist/proc/on_melee_click(datum/source, mob/living/pilot, atom/target, on_cooldown, is_adjacent)
	SIGNAL_HANDLER
	if(!is_fist_pilot(pilot))
		return NONE
	if(held)
		INVOKE_ASYNC(src, PROC_REF(throw_held), pilot, target)
		return COMPONENT_CANCEL_MELEE_CLICK
	if(!grab_mode)
		return NONE
	if(!is_adjacent || grabbing)
		return COMPONENT_CANCEL_MELEE_CLICK
	INVOKE_ASYNC(src, PROC_REF(try_grab), pilot, target)
	return COMPONENT_CANCEL_MELEE_CLICK

/// A pilot who also holds the weapons throws with the click instead of shooting while the fist holds something.
/datum/component/golden_gardren_fist/proc/on_equipment_click(datum/source, mob/living/pilot, atom/target)
	SIGNAL_HANDLER
	if(!held || !is_fist_pilot(pilot))
		return NONE
	INVOKE_ASYNC(src, PROC_REF(throw_held), pilot, target)
	return COMPONENT_CANCEL_EQUIPMENT_CLICK

/// A non-combat hand click on the mech by someone outside pries the held body out.
/datum/component/golden_gardren_fist/proc/on_attack_hand(datum/source, mob/living/user, list/modifiers)
	SIGNAL_HANDLER
	if(!isliving(held) || user == held || user.combat_mode || user.loc == parent)
		return NONE
	INVOKE_ASYNC(src, PROC_REF(try_free), user)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/// Returns why [pilot] cannot seize [target] right now, or null if they can.
/datum/component/golden_gardren_fist/proc/grab_blocker(mob/living/pilot, atom/movable/target)
	var/obj/vehicle/sealed/mecha/mech = parent
	if(QDELETED(target) || QDELETED(pilot))
		return "цель пропала"
	if(!mech.is_occupant(pilot) || !(mech.occupants[pilot] & VEHICLE_CONTROL_MELEE))
		return "кулак не у вас"
	if(held)
		return "кулак занят"
	if(!isturf(mech.loc) || !isturf(target.loc) || !mech.Adjacent(target))
		return "цель слишком далеко"
	if(isliving(target))
		var/mob/living/body = target
		if(mech.is_occupant(body) || body.buckled || body.has_buckled_mobs())
			return "цель не схватить"
		if(body.move_resist >= MOVE_FORCE_OVERPOWERING || body.mob_size >= MOB_SIZE_LARGE)
			return "цель слишком велика"
	else if(!is_grabbable_object(target))
		return "это не схватить"
	var/datum/component/golden_gardren_phasing/phasing = mech.GetComponent(/datum/component/golden_gardren_phasing)
	if(phasing?.active)
		return "не во время фазового сдвига"
	return null

/// Whether [thing] is a large loose object the fist may take: furniture, lockers, portable machines and the like.
/datum/component/golden_gardren_fist/proc/is_grabbable_object(atom/movable/thing)
	if(!isstructure(thing) && !(ismachinery(thing) && !thing.anchored))
		return FALSE
	var/obj/object = thing
	if(is_type_in_typecache(object, GLOB.golden_gardren_fist_forbidden) || HAS_TRAIT(object, TRAIT_WALLMOUNTED) || HAS_TRAIT(object, TRAIT_UNDERFLOOR))
		return FALSE
	if((object.resistance_flags & INDESTRUCTIBLE) || object.move_resist >= MOVE_FORCE_OVERPOWERING || object.has_buckled_mobs())
		return FALSE
	return TRUE

/// Closes the fist on [target] after a short wind-up, rechecking everything once it closes.
/datum/component/golden_gardren_fist/proc/try_grab(mob/living/pilot, atom/movable/target)
	var/obj/vehicle/sealed/mecha/mech = parent
	if(!ismovable(target))
		mech.balloon_alert(pilot, "это не схватить")
		return FALSE
	var/blocker = grab_blocker(pilot, target)
	if(blocker)
		mech.balloon_alert(pilot, blocker)
		return FALSE
	grabbing = TRUE
	mech.visible_message(span_warning("[mech.declent_ru(NOMINATIVE)] тянется кулаком к [target.declent_ru(DATIVE)]!"))
	playsound(mech, 'sound/vehicles/mecha/hydraulic.ogg', 50, TRUE)
	// A body can still dodge: stepping away before the fist closes breaks the grab.
	var/closed = do_after(pilot, GOLDEN_GARDREN_FIST_GRAB_TIME, target = target)
	grabbing = FALSE
	if(!closed || QDELETED(mech))
		return FALSE
	blocker = grab_blocker(pilot, target)
	if(blocker)
		mech.balloon_alert(pilot, blocker)
		return FALSE
	return grab(target, pilot)

/// Seizes [target] and lifts it in front of the mech. A body rides along buckled and cannot use its hands; an object is carried along.
/datum/component/golden_gardren_fist/proc/grab(atom/movable/target, mob/living/pilot)
	var/obj/vehicle/sealed/mecha/mech = parent
	if(isliving(target))
		var/mob/living/body = target
		if(!mech.buckle_mob(body, force = TRUE, check_loc = FALSE))
			return FALSE
		held = body
		ADD_TRAIT(body, TRAIT_HANDS_BLOCKED, GOLDEN_GARDREN_FIST_TRAIT)
		RegisterSignal(body, COMSIG_MOB_UNBUCKLED, PROC_REF(on_held_unbuckled))
		body.visible_message(span_danger("[mech.declent_ru(NOMINATIVE)] хватает [body.declent_ru(ACCUSATIVE)] кулаком!"), span_userdanger("[mech.declent_ru(NOMINATIVE)] хватает вас кулаком! Сопротивляйтесь, чтобы вырваться."))
	else
		var/obj/object = target
		held = object
		held_object_look = list(object.pixel_w, object.pixel_z, object.layer)
		// Furniture bolted to the floor is torn loose.
		if(object.anchored)
			object.set_anchored(FALSE)
		carrying = TRUE
		object.forceMove(mech.loc)
		carrying = FALSE
		RegisterSignal(object, COMSIG_MOVABLE_MOVED, PROC_REF(on_held_object_moved))
		RegisterSignal(mech, COMSIG_MOVABLE_MOVED, PROC_REF(on_mech_moved))
		mech.visible_message(span_warning("[mech.declent_ru(NOMINATIVE)] подхватывает [object.declent_ru(ACCUSATIVE)] кулаком!"))
	RegisterSignal(held, COMSIG_QDELETING, PROC_REF(on_held_deleted))
	RegisterSignal(mech, COMSIG_ATOM_DIR_CHANGE, PROC_REF(on_mech_turned))
	show_in_front(mech.dir)
	log_combat(pilot, held, "seized with a mech fist", mech)
	playsound(mech, 'sound/vehicles/mecha/hydraulic.ogg', 75, TRUE)
	update_buttons()
	return TRUE

/// Draws the held thing in front of the mech's sprite for the given facing.
/datum/component/golden_gardren_fist/proc/show_in_front(facing)
	var/front_w = 0
	var/front_z = 0
	switch(facing)
		if(NORTH)
			front_z = reach
		if(SOUTH)
			front_z = -round(reach / 2)
		if(EAST)
			front_w = reach
			front_z = 4
		if(WEST)
			front_w = -reach
			front_z = 4
	if(isliving(held))
		var/mob/living/body = held
		body.add_offsets(GOLDEN_GARDREN_FIST_TRAIT, w_add = front_w, z_add = front_z)
		return
	var/obj/object = held
	var/obj/vehicle/sealed/mecha/mech = parent
	object.pixel_w = held_object_look[1] + front_w
	object.pixel_z = held_object_look[2] + front_z
	// Facing away the object is behind the mech, otherwise in front of it.
	object.layer = facing == NORTH ? mech.layer - 0.01 : mech.layer + 0.01

/datum/component/golden_gardren_fist/proc/on_mech_turned(datum/source, old_dir, new_dir)
	SIGNAL_HANDLER
	if(held && old_dir != new_dir)
		show_in_front(new_dir)

/// Carries a held object along with the mech.
/datum/component/golden_gardren_fist/proc/on_mech_moved(datum/source, atom/old_loc, movement_dir, forced)
	SIGNAL_HANDLER
	var/obj/vehicle/sealed/mecha/mech = parent
	if(!held || isliving(held) || !isturf(mech.loc))
		return
	carrying = TRUE
	held.forceMove(mech.loc)
	carrying = FALSE

/// Anything else moving the held object away takes it out of the fist.
/datum/component/golden_gardren_fist/proc/on_held_object_moved(datum/source, atom/old_loc, movement_dir, forced)
	SIGNAL_HANDLER
	var/obj/vehicle/sealed/mecha/mech = parent
	if(!carrying && held && held.loc != mech.loc)
		forget_held()

/// Lets go of what the fist holds in front of the mech.
/datum/component/golden_gardren_fist/proc/release()
	if(!held)
		return
	var/obj/vehicle/sealed/mecha/mech = parent
	var/atom/movable/dropped = held
	if(isliving(dropped))
		mech.unbuckle_mob(dropped, force = TRUE)
	else
		forget_held()
	var/turf/front = get_step(mech, mech.dir)
	if(front && !front.is_blocked_turf(exclude_mobs = TRUE) && mech.Adjacent(front))
		dropped.forceMove(front)
	if(isliving(dropped))
		var/mob/living/body = dropped
		body.Knockdown(1 SECONDS)
		body.visible_message(span_notice("[mech.declent_ru(NOMINATIVE)] разжимает кулак."), span_notice("Кулак разжимается и отпускает вас."))
	else
		mech.visible_message(span_notice("[mech.declent_ru(NOMINATIVE)] ставит [dropped.declent_ru(ACCUSATIVE)]."))

/// Hurls what the fist holds towards [target] with the full swing of the arm.
/datum/component/golden_gardren_fist/proc/throw_held(mob/living/pilot, atom/target)
	var/obj/vehicle/sealed/mecha/mech = parent
	if(!held || !is_fist_pilot(pilot))
		return FALSE
	var/turf/aim = get_turf(target)
	if(!aim || aim == get_turf(mech))
		return FALSE
	if(HAS_TRAIT(pilot, TRAIT_PACIFISM))
		mech.balloon_alert(pilot, "вы не хотите никому навредить!")
		return FALSE
	var/atom/movable/thrown = held
	if(isliving(thrown))
		mech.unbuckle_mob(thrown, force = TRUE)
	else
		forget_held()
	log_combat(pilot, thrown, "threw with a mech fist", mech)
	mech.visible_message(span_danger("[mech.declent_ru(NOMINATIVE)] со всей силы швыряет [thrown.declent_ru(ACCUSATIVE)]!"))
	playsound(mech, 'sound/vehicles/mecha/mechmove04.ogg', 75, TRUE)
	mech.do_attack_animation(aim)
	if(isliving(thrown))
		var/mob/living/body = thrown
		body.apply_damage(GOLDEN_GARDREN_FIST_THROW_DAMAGE, BRUTE, BODY_ZONE_CHEST, body.run_armor_check(BODY_ZONE_CHEST, MELEE))
		body.Knockdown(3 SECONDS)
	else
		// A thrown object hurts whoever it lands on; the hooks only last for this throw.
		RegisterSignal(thrown, COMSIG_MOVABLE_IMPACT, PROC_REF(on_thrown_object_impact))
		RegisterSignal(thrown, COMSIG_MOVABLE_THROW_LANDED, PROC_REF(on_thrown_object_landed))
	thrown.throw_at(aim, GOLDEN_GARDREN_FIST_THROW_RANGE, 2, mech, TRUE, FALSE, null, MOVE_FORCE_OVERPOWERING)
	return TRUE

/datum/component/golden_gardren_fist/proc/on_thrown_object_impact(atom/movable/source, atom/hit_atom, datum/thrownthing/throwingdatum, caught)
	SIGNAL_HANDLER
	UnregisterSignal(source, list(COMSIG_MOVABLE_IMPACT, COMSIG_MOVABLE_THROW_LANDED))
	if(isliving(hit_atom))
		var/mob/living/victim = hit_atom
		victim.apply_damage(GOLDEN_GARDREN_FIST_OBJECT_HIT_DAMAGE, BRUTE, blocked = victim.run_armor_check(attack_flag = MELEE))
		victim.Knockdown(2 SECONDS)
		victim.visible_message(span_danger("[source.declent_ru(NOMINATIVE)] врезается в [victim.declent_ru(ACCUSATIVE)]!"), span_userdanger("В вас врезается [source.declent_ru(NOMINATIVE)]!"))
	if(isobj(source))
		var/obj/smashed = source
		smashed.take_damage(GOLDEN_GARDREN_FIST_OBJECT_HIT_DAMAGE, BRUTE, MELEE)

/datum/component/golden_gardren_fist/proc/on_thrown_object_landed(atom/movable/source, datum/thrownthing/throwingdatum)
	SIGNAL_HANDLER
	UnregisterSignal(source, list(COMSIG_MOVABLE_IMPACT, COMSIG_MOVABLE_THROW_LANDED))

/// Starts or stops squeezing whatever the fist holds.
/datum/component/golden_gardren_fist/proc/toggle_squeeze(mob/living/pilot)
	var/obj/vehicle/sealed/mecha/mech = parent
	if(!held)
		mech.balloon_alert(pilot, "кулак пуст!")
		return FALSE
	if(squeezing)
		stop_squeeze()
		mech.balloon_alert(pilot, "хватка ослаблена")
		return TRUE
	if(isliving(held) && HAS_TRAIT(pilot, TRAIT_PACIFISM))
		mech.balloon_alert(pilot, "вы не хотите никому навредить!")
		return FALSE
	squeezing = TRUE
	squeeze_time = 0
	// A chest cannot be dislocated, so the first crack is already a fracture.
	fracture_stage = WOUND_SEVERITY_MODERATE
	next_fracture_time = GOLDEN_GARDREN_FIST_CRUSH_DELAY
	START_PROCESSING(SSobj, src)
	log_combat(pilot, held, "started squeezing with a mech fist", mech)
	if(isliving(held))
		ADD_TRAIT(held, TRAIT_MUTE, GOLDEN_GARDREN_FIST_TRAIT)
		held.visible_message(span_danger("[mech.declent_ru(NOMINATIVE)] сдавливает [held.declent_ru(ACCUSATIVE)] в кулаке!"), span_userdanger("Кулак сдавливает вас! Нечем дышать!"))
	else
		mech.visible_message(span_danger("[mech.declent_ru(NOMINATIVE)] сминает [held.declent_ru(ACCUSATIVE)] в кулаке!"))
	playsound(mech, 'sound/vehicles/mecha/hydraulic.ogg', 75, TRUE)
	update_buttons()
	return TRUE

/datum/component/golden_gardren_fist/proc/stop_squeeze()
	if(!squeezing)
		return
	squeezing = FALSE
	STOP_PROCESSING(SSobj, src)
	if(held)
		REMOVE_TRAIT(held, TRAIT_MUTE, GOLDEN_GARDREN_FIST_TRAIT)
	update_buttons()

/**
 * A squeezed object takes damage until it breaks.
 * A squeezed body chokes from the start; held long enough, its chest is crushed and the bones break one stage at a time.
 */
/datum/component/golden_gardren_fist/process(seconds_per_tick)
	if(!held || !squeezing)
		stop_squeeze()
		return PROCESS_KILL
	squeeze_time += seconds_per_tick SECONDS
	if(isobj(held))
		var/obj/crushed_object = held
		crushed_object.take_damage(GOLDEN_GARDREN_FIST_OBJECT_CRUSH_RATE * seconds_per_tick, BRUTE, MELEE, sound_effect = FALSE)
		return
	var/mob/living/body = held
	if(!HAS_TRAIT(body, TRAIT_NOBREATH))
		body.adjust_oxy_loss(GOLDEN_GARDREN_FIST_CHOKE_RATE * seconds_per_tick)
	if(squeeze_time < GOLDEN_GARDREN_FIST_CRUSH_DELAY)
		return
	body.apply_damage(GOLDEN_GARDREN_FIST_CRUSH_RATE * seconds_per_tick, BRUTE, BODY_ZONE_CHEST, body.run_armor_check(BODY_ZONE_CHEST, MELEE, silent = TRUE))
	if(squeeze_time < next_fracture_time || fracture_stage >= WOUND_SEVERITY_CRITICAL)
		return
	next_fracture_time += GOLDEN_GARDREN_FIST_FRACTURE_INTERVAL
	fracture_stage++
	var/obj/vehicle/sealed/mecha/mech = parent
	if(iscarbon(body))
		var/mob/living/carbon/crushed = body
		crushed.cause_wound_of_type_and_severity(WOUND_BLUNT, crushed.get_bodypart(BODY_ZONE_CHEST), fracture_stage, wound_source = mech)
	playsound(body, 'sound/effects/wounds/crack1.ogg', 75, TRUE)
	body.visible_message(span_danger("Из кулака [mech.declent_ru(GENITIVE)] раздаётся хруст костей!"), span_userdanger("Ваши кости трещат под давлением кулака!"))

/// Someone tries to get the held body out: the body itself, or anyone next to the mech.
/datum/component/golden_gardren_fist/proc/try_free(mob/living/user)
	var/obj/vehicle/sealed/mecha/mech = parent
	if(!isliving(held) || escaping)
		return
	var/self_escape = (user == held)
	if(!self_escape && !user.Adjacent(mech))
		return
	escaping = TRUE
	user.visible_message(span_warning((self_escape ? "[user.declent_ru(NOMINATIVE)] пытается вырваться из кулака!" : "[user.declent_ru(NOMINATIVE)] пытается разжать кулак [mech.declent_ru(GENITIVE)]!")))
	// The held body is carried along, so walking does not reset its own attempt; a rescuer has to keep up with a mech that stands still.
	var/freed = self_escape \
		? do_after(user, GOLDEN_GARDREN_FIST_ESCAPE_TIME, target = mech, timed_action_flags = IGNORE_USER_LOC_CHANGE | IGNORE_TARGET_LOC_CHANGE) \
		: do_after(user, GOLDEN_GARDREN_FIST_RESCUE_TIME, target = mech)
	escaping = FALSE
	if(!freed || !isliving(held) || (!self_escape && !user.Adjacent(mech)) || (self_escape && user != held))
		return
	log_combat(user, mech, self_escape ? "broke free from the fist of" : "pried [held] out of the fist of")
	release()

/datum/component/golden_gardren_fist/proc/on_held_unbuckled(datum/source, atom/movable/unbuckled_from)
	SIGNAL_HANDLER
	if(unbuckled_from == parent)
		forget_held()

/datum/component/golden_gardren_fist/proc/on_held_deleted(datum/source)
	SIGNAL_HANDLER
	forget_held()

/// Undoes everything the fist did to what it held and lets go of the reference.
/datum/component/golden_gardren_fist/proc/forget_held()
	if(!held)
		return
	stop_squeeze()
	UnregisterSignal(held, list(COMSIG_MOB_UNBUCKLED, COMSIG_QDELETING, COMSIG_MOVABLE_MOVED))
	UnregisterSignal(parent, list(COMSIG_ATOM_DIR_CHANGE, COMSIG_MOVABLE_MOVED))
	if(isliving(held))
		var/mob/living/body = held
		REMOVE_TRAIT(body, TRAIT_HANDS_BLOCKED, GOLDEN_GARDREN_FIST_TRAIT)
		body.remove_offsets(GOLDEN_GARDREN_FIST_TRAIT)
	else if(held_object_look)
		var/obj/object = held
		object.pixel_w = held_object_look[1]
		object.pixel_z = held_object_look[2]
		object.layer = held_object_look[3]
	held_object_look = null
	held = null
	update_buttons()

/// Switches between punching and grabbing, or lets go if the fist holds something.
/datum/component/golden_gardren_fist/proc/toggle(mob/user)
	var/obj/vehicle/sealed/mecha/mech = parent
	if(held)
		release()
		return
	grab_mode = !grab_mode
	mech.balloon_alert(user, grab_mode ? "кулак: хватать" : "кулак: бить")
	update_buttons()

/datum/component/golden_gardren_fist/proc/update_buttons()
	var/obj/vehicle/sealed/mecha/mech = parent
	var/fist_state = held ? "fist_holding" : (grab_mode ? "fist_grab" : "fist_punch")
	var/squeeze_state = squeezing ? "fist_squeeze_on" : "fist_squeeze_off"
	for(var/mob/occupant as anything in mech.occupants)
		var/datum/action/fist_button = LAZYACCESSASSOC(mech.occupant_actions, occupant, /datum/action/vehicle/sealed/mecha/golden_gardren_fist)
		if(fist_button)
			fist_button.button_icon_state = fist_state
			fist_button.build_all_button_icons()
		var/datum/action/squeeze_button = LAZYACCESSASSOC(mech.occupant_actions, occupant, /datum/action/vehicle/sealed/mecha/golden_gardren_fist_squeeze)
		if(squeeze_button)
			squeeze_button.button_icon_state = squeeze_state
			squeeze_button.build_all_button_icons()

/**
 * Routes [/atom/movable/proc/user_unbuckle_mob] of a mech with a fist: a held body is not simply unbuckled, it has to break free.
 * Returns TRUE if the fist took over the attempt.
 */
/proc/golden_gardren_fist_intercept_unbuckle(obj/vehicle/sealed/mecha/mech, mob/living/buckled_mob, mob/user)
	var/datum/component/golden_gardren_fist/fist = mech.GetComponent(/datum/component/golden_gardren_fist)
	if(!fist?.held || fist.held != buckled_mob)
		return FALSE
	INVOKE_ASYNC(fist, TYPE_PROC_REF(/datum/component/golden_gardren_fist, try_free), user)
	return TRUE

/// Lets go of whatever the fist of [mech] holds. Used whenever the mech is about to move in a way a held thing cannot follow.
/proc/golden_gardren_release_fist(obj/vehicle/sealed/mecha/mech)
	var/datum/component/golden_gardren_fist/fist = mech.GetComponent(/datum/component/golden_gardren_fist)
	fist?.release()

/// Switches the fist between punching and grabbing, or opens it if it holds something. The pilot's seat.
/datum/action/vehicle/sealed/mecha/golden_gardren_fist
	name = "Кулак"
	desc = "Переключает кулак между ударом и захватом: в режиме захвата клик по соседней цели — живой или крупному предмету вроде стола или шкафа — хватает её. Схваченное мех носит перед собой; клик в любую точку впереди швыряет его туда. Повторное нажатие разжимает кулак."
	button_icon = 'modular_bandastation/golden_gardren/icons/actions.dmi'
	button_icon_state = "fist_punch"

/datum/action/vehicle/sealed/mecha/golden_gardren_fist/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return
	if(!chassis || !(owner in chassis.return_controllers_with_flag(VEHICLE_CONTROL_MELEE)))
		return
	var/datum/component/golden_gardren_fist/fist = chassis.GetComponent(/datum/component/golden_gardren_fist)
	fist?.toggle(owner)

/// Squeezes whatever the fist holds, or eases the grip. The pilot's seat.
/datum/action/vehicle/sealed/mecha/golden_gardren_fist_squeeze
	name = "Сжатие"
	desc = "Сжать кулак: живая цель задыхается, а если держать долго — начинают ломаться кости; предмет сминается, пока не сломается. Повторное нажатие ослабляет хватку."
	button_icon = 'modular_bandastation/golden_gardren/icons/actions.dmi'
	button_icon_state = "fist_squeeze_off"

/datum/action/vehicle/sealed/mecha/golden_gardren_fist_squeeze/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return
	if(!chassis || !(owner in chassis.return_controllers_with_flag(VEHICLE_CONTROL_MELEE)))
		return
	var/datum/component/golden_gardren_fist/fist = chassis.GetComponent(/datum/component/golden_gardren_fist)
	fist?.toggle_squeeze(owner)

#undef GOLDEN_GARDREN_FIST_GRAB_TIME
#undef GOLDEN_GARDREN_FIST_ESCAPE_TIME
#undef GOLDEN_GARDREN_FIST_RESCUE_TIME
#undef GOLDEN_GARDREN_FIST_THROW_RANGE
#undef GOLDEN_GARDREN_FIST_THROW_DAMAGE
#undef GOLDEN_GARDREN_FIST_OBJECT_HIT_DAMAGE
#undef GOLDEN_GARDREN_FIST_CHOKE_RATE
#undef GOLDEN_GARDREN_FIST_CRUSH_DELAY
#undef GOLDEN_GARDREN_FIST_CRUSH_RATE
#undef GOLDEN_GARDREN_FIST_FRACTURE_INTERVAL
#undef GOLDEN_GARDREN_FIST_OBJECT_CRUSH_RATE
#undef GOLDEN_GARDREN_FIST_TRAIT
