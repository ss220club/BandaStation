/// Time the fist takes to close on a target.
#define GOLDEN_GARDREN_FIST_GRAB_TIME (1 SECONDS)
/// Time a held target needs to wrench itself free.
#define GOLDEN_GARDREN_FIST_ESCAPE_TIME (8 SECONDS)
/// Time someone standing next to the mech needs to pry a held target free.
#define GOLDEN_GARDREN_FIST_RESCUE_TIME (4 SECONDS)
/// How far the fist throws a held target, in tiles.
#define GOLDEN_GARDREN_FIST_THROW_RANGE 7
/// Brute damage the throw itself deals, before whatever the target hits on landing.
#define GOLDEN_GARDREN_FIST_THROW_DAMAGE 10
/// Oxygen damage per second while the fist squeezes: the target cannot breathe.
#define GOLDEN_GARDREN_FIST_CHOKE_RATE 4
/// How long the fist has to squeeze before the bones start to give.
#define GOLDEN_GARDREN_FIST_CRUSH_DELAY (8 SECONDS)
/// Brute damage per second to the chest once the bones give.
#define GOLDEN_GARDREN_FIST_CRUSH_RATE 3
/// How often a crushing squeeze breaks the bones one stage further.
#define GOLDEN_GARDREN_FIST_FRACTURE_INTERVAL (6 SECONDS)
/// Trait source for everything the fist does to its target.
#define GOLDEN_GARDREN_FIST_TRAIT "golden_gardren_fist"

/**
 * ## Golden-Gardren fist
 *
 * A Titanfall-style mech fist for the pilot of the Gardren or the combined mech. In grab mode the pilot's hand click
 * on an adjacent target closes the fist on it instead of punching. A held target rides along with the mech and cannot use its hands.
 * Holding someone, the pilot can throw them hard with a click anywhere ahead, or squeeze: the target chokes,
 * and if the squeeze goes on long enough its bones start to break.
 * The target needs time to wrench itself free; anyone next to a mech that stands still can pry it out faster with a non-combat hand click.
 */
/datum/component/golden_gardren_fist
	/// Whether the pilot's hand clicks close the fist instead of punching.
	var/grab_mode = FALSE
	/// Whoever the fist holds right now.
	var/mob/living/held
	/// Whether the fist is closing on someone right now.
	var/grabbing = FALSE
	/// Whether someone is trying to get the held target out right now.
	var/escaping = FALSE
	/// Whether the fist squeezes whoever it holds.
	var/squeezing = FALSE
	/// For how long the current squeeze has gone on, in deciseconds.
	var/squeeze_time = 0
	/// Bone wound severity the squeeze has reached on the held target.
	var/fracture_stage = WOUND_SEVERITY_TRIVIAL
	/// Squeeze time at which the bones give one stage further.
	var/next_fracture_time = 0

/datum/component/golden_gardren_fist/Initialize()
	if(!istype(parent, /obj/vehicle/sealed/mecha))
		return COMPONENT_INCOMPATIBLE

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
	var/obj/vehicle/sealed/mecha/mech = parent
	if(!is_adjacent || grabbing)
		return COMPONENT_CANCEL_MELEE_CLICK
	if(!isliving(target))
		mech.balloon_alert(pilot, "хватать можно только живых!")
		return COMPONENT_CANCEL_MELEE_CLICK
	INVOKE_ASYNC(src, PROC_REF(try_grab), pilot, target)
	return COMPONENT_CANCEL_MELEE_CLICK

/// A pilot who also holds the weapons throws with the click instead of shooting while the fist holds someone.
/datum/component/golden_gardren_fist/proc/on_equipment_click(datum/source, mob/living/pilot, atom/target)
	SIGNAL_HANDLER
	if(!held || !is_fist_pilot(pilot))
		return NONE
	INVOKE_ASYNC(src, PROC_REF(throw_held), pilot, target)
	return COMPONENT_CANCEL_EQUIPMENT_CLICK

/// A non-combat hand click on the mech by someone outside pries the held target out.
/datum/component/golden_gardren_fist/proc/on_attack_hand(datum/source, mob/living/user, list/modifiers)
	SIGNAL_HANDLER
	if(!held || user == held || user.combat_mode || user.loc == parent)
		return NONE
	INVOKE_ASYNC(src, PROC_REF(try_free), user)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/// Returns why [pilot] cannot seize [target] right now, or null if they can.
/datum/component/golden_gardren_fist/proc/grab_blocker(mob/living/pilot, mob/living/target)
	var/obj/vehicle/sealed/mecha/mech = parent
	if(QDELETED(target) || QDELETED(pilot))
		return "цель пропала"
	if(!mech.is_occupant(pilot) || !(mech.occupants[pilot] & VEHICLE_CONTROL_MELEE))
		return "кулак не у вас"
	if(held)
		return "кулак занят"
	if(!isturf(mech.loc) || !mech.Adjacent(target))
		return "цель слишком далеко"
	if(mech.is_occupant(target) || target.buckled || target.has_buckled_mobs())
		return "цель не схватить"
	if(target.move_resist >= MOVE_FORCE_OVERPOWERING || target.mob_size >= MOB_SIZE_LARGE)
		return "цель слишком велика"
	var/datum/component/golden_gardren_phasing/phasing = mech.GetComponent(/datum/component/golden_gardren_phasing)
	if(phasing?.active)
		return "не во время фазового сдвига"
	return null

/// Closes the fist on [target] after a short wind-up, rechecking everything once it closes.
/datum/component/golden_gardren_fist/proc/try_grab(mob/living/pilot, mob/living/target)
	var/obj/vehicle/sealed/mecha/mech = parent
	var/blocker = grab_blocker(pilot, target)
	if(blocker)
		mech.balloon_alert(pilot, blocker)
		return FALSE
	grabbing = TRUE
	mech.visible_message(span_warning("[mech.declent_ru(NOMINATIVE)] тянется кулаком к [target.declent_ru(DATIVE)]!"))
	playsound(mech, 'sound/vehicles/mecha/hydraulic.ogg', 50, TRUE)
	// The target can still dodge: stepping away before the fist closes breaks the grab.
	var/closed = do_after(pilot, GOLDEN_GARDREN_FIST_GRAB_TIME, target = target)
	grabbing = FALSE
	if(!closed || QDELETED(mech))
		return FALSE
	blocker = grab_blocker(pilot, target)
	if(blocker)
		mech.balloon_alert(pilot, blocker)
		return FALSE
	return grab(target, pilot)

/// Seizes [target]: it rides along with the mech, lifted in the fist and unable to use its hands.
/datum/component/golden_gardren_fist/proc/grab(mob/living/target, mob/living/pilot)
	var/obj/vehicle/sealed/mecha/mech = parent
	if(!mech.buckle_mob(target, force = TRUE, check_loc = FALSE))
		return FALSE
	held = target
	ADD_TRAIT(target, TRAIT_HANDS_BLOCKED, GOLDEN_GARDREN_FIST_TRAIT)
	target.add_offsets(GOLDEN_GARDREN_FIST_TRAIT, z_add = 14)
	RegisterSignal(target, COMSIG_MOB_UNBUCKLED, PROC_REF(on_held_unbuckled))
	RegisterSignal(target, COMSIG_QDELETING, PROC_REF(on_held_deleted))
	log_combat(pilot, target, "seized with a mech fist", mech)
	target.visible_message(span_danger("[mech.declent_ru(NOMINATIVE)] хватает [target.declent_ru(ACCUSATIVE)] кулаком!"), span_userdanger("[mech.declent_ru(NOMINATIVE)] хватает вас кулаком! Сопротивляйтесь, чтобы вырваться."))
	playsound(mech, 'sound/vehicles/mecha/hydraulic.ogg', 75, TRUE)
	update_buttons()
	return TRUE

/// Lets go of the held target in front of the mech.
/datum/component/golden_gardren_fist/proc/release()
	if(!held)
		return
	var/obj/vehicle/sealed/mecha/mech = parent
	var/mob/living/victim = held
	mech.unbuckle_mob(victim, force = TRUE)
	var/turf/front = get_step(mech, mech.dir)
	if(front && !front.is_blocked_turf(exclude_mobs = TRUE) && mech.Adjacent(front))
		victim.forceMove(front)
	victim.Knockdown(1 SECONDS)
	victim.visible_message(span_notice("[mech.declent_ru(NOMINATIVE)] разжимает кулак."), span_notice("Кулак разжимается и отпускает вас."))

/// Hurls the held target towards [target] with the full swing of the arm.
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
	var/mob/living/victim = held
	mech.unbuckle_mob(victim, force = TRUE)
	log_combat(pilot, victim, "threw with a mech fist", mech)
	victim.visible_message(span_danger("[mech.declent_ru(NOMINATIVE)] со всей силы швыряет [victim.declent_ru(ACCUSATIVE)]!"), span_userdanger("[mech.declent_ru(NOMINATIVE)] со всей силы швыряет вас!"))
	playsound(mech, 'sound/vehicles/mecha/mechmove04.ogg', 75, TRUE)
	mech.do_attack_animation(aim)
	victim.apply_damage(GOLDEN_GARDREN_FIST_THROW_DAMAGE, BRUTE, BODY_ZONE_CHEST, victim.run_armor_check(BODY_ZONE_CHEST, MELEE))
	victim.Knockdown(3 SECONDS)
	victim.throw_at(aim, GOLDEN_GARDREN_FIST_THROW_RANGE, 2, mech)
	return TRUE

/// Starts or stops squeezing whoever the fist holds.
/datum/component/golden_gardren_fist/proc/toggle_squeeze(mob/living/pilot)
	var/obj/vehicle/sealed/mecha/mech = parent
	if(!held)
		mech.balloon_alert(pilot, "кулак пуст!")
		return FALSE
	if(squeezing)
		stop_squeeze()
		mech.balloon_alert(pilot, "хватка ослаблена")
		return TRUE
	if(HAS_TRAIT(pilot, TRAIT_PACIFISM))
		mech.balloon_alert(pilot, "вы не хотите никому навредить!")
		return FALSE
	squeezing = TRUE
	squeeze_time = 0
	// A chest cannot be dislocated, so the first crack is already a fracture.
	fracture_stage = WOUND_SEVERITY_MODERATE
	next_fracture_time = GOLDEN_GARDREN_FIST_CRUSH_DELAY
	ADD_TRAIT(held, TRAIT_MUTE, GOLDEN_GARDREN_FIST_TRAIT)
	START_PROCESSING(SSobj, src)
	log_combat(pilot, held, "started squeezing with a mech fist", mech)
	held.visible_message(span_danger("[mech.declent_ru(NOMINATIVE)] сдавливает [held.declent_ru(ACCUSATIVE)] в кулаке!"), span_userdanger("Кулак сдавливает вас! Нечем дышать!"))
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

/// The squeeze chokes the target from the start; held long enough, it crushes the chest and breaks the bones one stage at a time.
/datum/component/golden_gardren_fist/process(seconds_per_tick)
	if(!held || !squeezing)
		stop_squeeze()
		return PROCESS_KILL
	squeeze_time += seconds_per_tick SECONDS
	if(!HAS_TRAIT(held, TRAIT_NOBREATH))
		held.adjust_oxy_loss(GOLDEN_GARDREN_FIST_CHOKE_RATE * seconds_per_tick)
	if(squeeze_time < GOLDEN_GARDREN_FIST_CRUSH_DELAY)
		return
	held.apply_damage(GOLDEN_GARDREN_FIST_CRUSH_RATE * seconds_per_tick, BRUTE, BODY_ZONE_CHEST, held.run_armor_check(BODY_ZONE_CHEST, MELEE, silent = TRUE))
	if(squeeze_time < next_fracture_time || fracture_stage >= WOUND_SEVERITY_CRITICAL)
		return
	next_fracture_time += GOLDEN_GARDREN_FIST_FRACTURE_INTERVAL
	fracture_stage++
	var/obj/vehicle/sealed/mecha/mech = parent
	if(iscarbon(held))
		var/mob/living/carbon/crushed = held
		crushed.cause_wound_of_type_and_severity(WOUND_BLUNT, crushed.get_bodypart(BODY_ZONE_CHEST), fracture_stage, wound_source = mech)
	playsound(held, 'sound/effects/wounds/crack1.ogg', 75, TRUE)
	held.visible_message(span_danger("Из кулака [mech.declent_ru(GENITIVE)] раздаётся хруст костей!"), span_userdanger("Ваши кости трещат под давлением кулака!"))

/// Someone tries to get the held target out: the target itself, or anyone next to the mech.
/datum/component/golden_gardren_fist/proc/try_free(mob/living/user)
	var/obj/vehicle/sealed/mecha/mech = parent
	if(!held || escaping)
		return
	var/self_escape = (user == held)
	if(!self_escape && !user.Adjacent(mech))
		return
	escaping = TRUE
	user.visible_message(span_warning((self_escape ? "[user.declent_ru(NOMINATIVE)] пытается вырваться из кулака!" : "[user.declent_ru(NOMINATIVE)] пытается разжать кулак [mech.declent_ru(GENITIVE)]!")))
	// The held target is carried along, so walking does not reset its own attempt; a rescuer has to keep up with a mech that stands still.
	var/freed = self_escape \
		? do_after(user, GOLDEN_GARDREN_FIST_ESCAPE_TIME, target = mech, timed_action_flags = IGNORE_USER_LOC_CHANGE | IGNORE_TARGET_LOC_CHANGE) \
		: do_after(user, GOLDEN_GARDREN_FIST_RESCUE_TIME, target = mech)
	escaping = FALSE
	if(!freed || !held || (!self_escape && !user.Adjacent(mech)) || (self_escape && user != held))
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

/// Undoes everything the fist did to its target and lets go of the reference.
/datum/component/golden_gardren_fist/proc/forget_held()
	if(!held)
		return
	stop_squeeze()
	UnregisterSignal(held, list(COMSIG_MOB_UNBUCKLED, COMSIG_QDELETING))
	REMOVE_TRAIT(held, TRAIT_HANDS_BLOCKED, GOLDEN_GARDREN_FIST_TRAIT)
	held.remove_offsets(GOLDEN_GARDREN_FIST_TRAIT)
	held = null
	update_buttons()

/// Switches between punching and grabbing, or lets go if the fist holds someone.
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

/// Lets go of whatever the fist of [mech] holds. Used whenever the mech is about to move in a way a held body cannot follow.
/proc/golden_gardren_release_fist(obj/vehicle/sealed/mecha/mech)
	var/datum/component/golden_gardren_fist/fist = mech.GetComponent(/datum/component/golden_gardren_fist)
	fist?.release()

/// Switches the fist between punching and grabbing, or opens it if it holds someone. The pilot's seat.
/datum/action/vehicle/sealed/mecha/golden_gardren_fist
	name = "Кулак"
	desc = "Переключает кулак между ударом и захватом: в режиме захвата клик по соседней цели хватает её. Схваченную цель мех носит с собой; клик в любую точку впереди швыряет её туда. Повторное нажатие разжимает кулак."
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

/// Squeezes whoever the fist holds, or eases the grip. The pilot's seat.
/datum/action/vehicle/sealed/mecha/golden_gardren_fist_squeeze
	name = "Сжатие"
	desc = "Сжать кулак со схваченной целью: она задыхается, а если держать долго — начинают ломаться кости. Повторное нажатие ослабляет хватку."
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
#undef GOLDEN_GARDREN_FIST_CHOKE_RATE
#undef GOLDEN_GARDREN_FIST_CRUSH_DELAY
#undef GOLDEN_GARDREN_FIST_CRUSH_RATE
#undef GOLDEN_GARDREN_FIST_FRACTURE_INTERVAL
#undef GOLDEN_GARDREN_FIST_TRAIT
