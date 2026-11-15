/// Time the claw takes to close on a target.
#define GOLDEN_GARDREN_CLAW_GRAB_TIME (1 SECONDS)
/// Time a held target needs to wrench itself free.
#define GOLDEN_GARDREN_CLAW_ESCAPE_TIME (8 SECONDS)
/// Time someone standing next to the mech needs to pry a held target free.
#define GOLDEN_GARDREN_CLAW_RESCUE_TIME (4 SECONDS)
/// Trait source for everything the claw does to its target.
#define GOLDEN_GARDREN_CLAW_TRAIT "golden_gardren_claw"

/**
 * ## Golden-Gardren claw
 *
 * Lets the pilot of the Gardren or the combined mech seize a living target next to the mech and carry it around.
 * In claw mode the pilot's hand click closes the claw instead of punching. A held target rides along with the mech,
 * cannot use its hands and needs time to wrench itself free; anyone next to the mech can pry it out faster with a non-combat hand click,
 * as long as the mech stands still.
 */
/datum/component/golden_gardren_claw
	/// Whether the pilot's hand clicks close the claw instead of punching.
	var/claw_mode = FALSE
	/// Whoever the claw holds right now.
	var/mob/living/held
	/// Whether the claw is closing on someone right now.
	var/grabbing = FALSE
	/// Whether someone is trying to get the held target out right now.
	var/escaping = FALSE

/datum/component/golden_gardren_claw/Initialize()
	if(!istype(parent, /obj/vehicle/sealed/mecha))
		return COMPONENT_INCOMPATIBLE

/datum/component/golden_gardren_claw/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MECHA_MELEE_CLICK, PROC_REF(on_melee_click))
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_attack_hand))

/datum/component/golden_gardren_claw/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MECHA_MELEE_CLICK, COMSIG_ATOM_ATTACK_HAND))

/datum/component/golden_gardren_claw/Destroy(force)
	if(held)
		release()
	return ..()

/datum/component/golden_gardren_claw/proc/on_melee_click(datum/source, mob/living/pilot, atom/target, on_cooldown, is_adjacent)
	SIGNAL_HANDLER
	var/obj/vehicle/sealed/mecha/mech = parent
	if(!claw_mode || !(pilot in mech.return_controllers_with_flag(VEHICLE_CONTROL_MELEE)))
		return NONE
	if(held)
		mech.balloon_alert(pilot, "клешня занята!")
		return COMPONENT_CANCEL_MELEE_CLICK
	if(!is_adjacent || grabbing)
		return COMPONENT_CANCEL_MELEE_CLICK
	if(!isliving(target))
		mech.balloon_alert(pilot, "клешнёй хватают только живых!")
		return COMPONENT_CANCEL_MELEE_CLICK
	INVOKE_ASYNC(src, PROC_REF(try_grab), pilot, target)
	return COMPONENT_CANCEL_MELEE_CLICK

/// A non-combat hand click on the mech by someone outside pries the held target out.
/datum/component/golden_gardren_claw/proc/on_attack_hand(datum/source, mob/living/user, list/modifiers)
	SIGNAL_HANDLER
	if(!held || user == held || user.combat_mode || user.loc == parent)
		return NONE
	INVOKE_ASYNC(src, PROC_REF(try_free), user)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/// Returns why [pilot] cannot seize [target] right now, or null if they can.
/datum/component/golden_gardren_claw/proc/grab_blocker(mob/living/pilot, mob/living/target)
	var/obj/vehicle/sealed/mecha/mech = parent
	if(QDELETED(target) || QDELETED(pilot))
		return "цель пропала"
	if(!mech.is_occupant(pilot) || !(mech.occupants[pilot] & VEHICLE_CONTROL_MELEE))
		return "клешня не у вас"
	if(held)
		return "клешня занята"
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

/// Closes the claw on [target] after a short wind-up, rechecking everything once it closes.
/datum/component/golden_gardren_claw/proc/try_grab(mob/living/pilot, mob/living/target)
	var/obj/vehicle/sealed/mecha/mech = parent
	var/blocker = grab_blocker(pilot, target)
	if(blocker)
		mech.balloon_alert(pilot, blocker)
		return FALSE
	grabbing = TRUE
	mech.visible_message(span_warning("[mech.declent_ru(NOMINATIVE)] тянется клешнёй к [target.declent_ru(DATIVE)]!"))
	playsound(mech, 'sound/vehicles/mecha/hydraulic.ogg', 50, TRUE)
	// The target can still dodge: stepping away before the claw closes breaks the grab.
	var/closed = do_after(pilot, GOLDEN_GARDREN_CLAW_GRAB_TIME, target = target)
	grabbing = FALSE
	if(!closed || QDELETED(mech))
		return FALSE
	blocker = grab_blocker(pilot, target)
	if(blocker)
		mech.balloon_alert(pilot, blocker)
		return FALSE
	return grab(target, pilot)

/// Seizes [target]: it rides along with the mech, lifted in the claw and unable to use its hands.
/datum/component/golden_gardren_claw/proc/grab(mob/living/target, mob/living/pilot)
	var/obj/vehicle/sealed/mecha/mech = parent
	if(!mech.buckle_mob(target, force = TRUE, check_loc = FALSE))
		return FALSE
	held = target
	ADD_TRAIT(target, TRAIT_HANDS_BLOCKED, GOLDEN_GARDREN_CLAW_TRAIT)
	target.add_offsets(GOLDEN_GARDREN_CLAW_TRAIT, z_add = 14)
	RegisterSignal(target, COMSIG_MOB_UNBUCKLED, PROC_REF(on_held_unbuckled))
	RegisterSignal(target, COMSIG_QDELETING, PROC_REF(on_held_deleted))
	log_combat(pilot, target, "seized with a mech claw", mech)
	target.visible_message(span_danger("[mech.declent_ru(NOMINATIVE)] хватает [target.declent_ru(ACCUSATIVE)] клешнёй!"), span_userdanger("[mech.declent_ru(NOMINATIVE)] хватает вас клешнёй! Сопротивляйтесь, чтобы вырваться."))
	playsound(mech, 'sound/vehicles/mecha/hydraulic.ogg', 75, TRUE)
	update_buttons()
	return TRUE

/// Lets go of the held target in front of the mech.
/datum/component/golden_gardren_claw/proc/release()
	if(!held)
		return
	var/obj/vehicle/sealed/mecha/mech = parent
	var/mob/living/victim = held
	mech.unbuckle_mob(victim, force = TRUE)
	var/turf/front = get_step(mech, mech.dir)
	if(front && !front.is_blocked_turf(exclude_mobs = TRUE) && mech.Adjacent(front))
		victim.forceMove(front)
	victim.Knockdown(1 SECONDS)
	victim.visible_message(span_notice("[mech.declent_ru(NOMINATIVE)] разжимает клешню."), span_notice("Клешня разжимается и отпускает вас."))

/// Someone tries to get the held target out: the target itself, or anyone next to the mech.
/datum/component/golden_gardren_claw/proc/try_free(mob/living/user)
	var/obj/vehicle/sealed/mecha/mech = parent
	if(!held || escaping)
		return
	var/self_escape = (user == held)
	if(!self_escape && !user.Adjacent(mech))
		return
	escaping = TRUE
	user.visible_message(span_warning((self_escape ? "[user.declent_ru(NOMINATIVE)] пытается вырваться из клешни!" : "[user.declent_ru(NOMINATIVE)] пытается разжать клешню [mech.declent_ru(GENITIVE)]!")))
	// The held target is carried along, so walking does not reset its own attempt; a rescuer has to keep up with a mech that stands still.
	var/freed = self_escape \
		? do_after(user, GOLDEN_GARDREN_CLAW_ESCAPE_TIME, target = mech, timed_action_flags = IGNORE_USER_LOC_CHANGE | IGNORE_TARGET_LOC_CHANGE) \
		: do_after(user, GOLDEN_GARDREN_CLAW_RESCUE_TIME, target = mech)
	escaping = FALSE
	if(!freed || !held || (!self_escape && !user.Adjacent(mech)) || (self_escape && user != held))
		return
	log_combat(user, mech, self_escape ? "broke free from the claw of" : "pried [held] out of the claw of")
	release()

/datum/component/golden_gardren_claw/proc/on_held_unbuckled(datum/source, atom/movable/unbuckled_from)
	SIGNAL_HANDLER
	if(unbuckled_from == parent)
		forget_held()

/datum/component/golden_gardren_claw/proc/on_held_deleted(datum/source)
	SIGNAL_HANDLER
	forget_held()

/// Undoes everything the claw did to its target and lets go of the reference.
/datum/component/golden_gardren_claw/proc/forget_held()
	if(!held)
		return
	UnregisterSignal(held, list(COMSIG_MOB_UNBUCKLED, COMSIG_QDELETING))
	REMOVE_TRAIT(held, TRAIT_HANDS_BLOCKED, GOLDEN_GARDREN_CLAW_TRAIT)
	held.remove_offsets(GOLDEN_GARDREN_CLAW_TRAIT)
	held = null
	update_buttons()

/// Switches between punching and grabbing, or lets go if the claw holds someone.
/datum/component/golden_gardren_claw/proc/toggle(mob/user)
	var/obj/vehicle/sealed/mecha/mech = parent
	if(held)
		release()
		return
	claw_mode = !claw_mode
	mech.balloon_alert(user, claw_mode ? "клешня: хватать" : "клешня: бить")
	update_buttons()

/datum/component/golden_gardren_claw/proc/update_buttons()
	var/obj/vehicle/sealed/mecha/mech = parent
	var/state = held ? "claw_holding" : (claw_mode ? "claw_on" : "claw_off")
	for(var/mob/occupant as anything in mech.occupants)
		var/datum/action/claw_button = LAZYACCESSASSOC(mech.occupant_actions, occupant, /datum/action/vehicle/sealed/mecha/golden_gardren_claw)
		if(claw_button)
			claw_button.button_icon_state = state
			claw_button.build_all_button_icons()

/**
 * Routes [/atom/movable/proc/user_unbuckle_mob] of a clawed mech: a held body is not simply unbuckled, it has to break free.
 * Returns TRUE if the claw took over the attempt.
 */
/proc/golden_gardren_claw_intercept_unbuckle(obj/vehicle/sealed/mecha/mech, mob/living/buckled_mob, mob/user)
	var/datum/component/golden_gardren_claw/claw = mech.GetComponent(/datum/component/golden_gardren_claw)
	if(!claw?.held || claw.held != buckled_mob)
		return FALSE
	INVOKE_ASYNC(claw, TYPE_PROC_REF(/datum/component/golden_gardren_claw, try_free), user)
	return TRUE

/// Lets go of whatever the claw of [mech] holds. Used whenever the mech is about to move in a way a held body cannot follow.
/proc/golden_gardren_release_claw(obj/vehicle/sealed/mecha/mech)
	var/datum/component/golden_gardren_claw/claw = mech.GetComponent(/datum/component/golden_gardren_claw)
	claw?.release()

/// Switches the claw between grabbing and punching, or opens it if it holds someone. The pilot's seat.
/datum/action/vehicle/sealed/mecha/golden_gardren_claw
	name = "Клешня"
	desc = "В режиме клешни клик рукой по соседней цели хватает её вместо удара. Схваченную цель мех носит с собой; повторное нажатие разжимает клешню."
	button_icon = 'modular_bandastation/golden_gardren/icons/actions.dmi'
	button_icon_state = "claw_off"

/datum/action/vehicle/sealed/mecha/golden_gardren_claw/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return
	if(!chassis || !(owner in chassis.return_controllers_with_flag(VEHICLE_CONTROL_MELEE)))
		return
	var/datum/component/golden_gardren_claw/claw = chassis.GetComponent(/datum/component/golden_gardren_claw)
	claw?.toggle(owner)

#undef GOLDEN_GARDREN_CLAW_GRAB_TIME
#undef GOLDEN_GARDREN_CLAW_ESCAPE_TIME
#undef GOLDEN_GARDREN_CLAW_RESCUE_TIME
#undef GOLDEN_GARDREN_CLAW_TRAIT
