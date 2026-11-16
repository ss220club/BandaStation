/**
 * ## Golden-Gardren phase shift
 *
 * The Phazon's phasing for the Gardren and the combined mech: while on, the mech passes through walls and other obstacles,
 * every step costs energy, and the hands and weapons cannot be used. Same limits as the Phazon:
 * no phasing into places where teleportation is not allowed or on levels that forbid phasing.
 * A phasing mech is drawn blurred and half see-through.
 */
/datum/component/golden_gardren_phasing
	/// Whether the phase shift is on.
	var/active = FALSE
	/// Energy spent on every step while phasing.
	var/energy_drain = 0.2 * STANDARD_CELL_CHARGE

/datum/component/golden_gardren_phasing/Initialize()
	if(!istype(parent, /obj/vehicle/sealed/mecha))
		return COMPONENT_INCOMPATIBLE

/datum/component/golden_gardren_phasing/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_CAN_PASS_THROUGH, PROC_REF(on_can_pass_through))
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	RegisterSignal(parent, COMSIG_MECHA_MELEE_CLICK, PROC_REF(on_melee_click))
	RegisterSignal(parent, COMSIG_MECHA_EQUIPMENT_CLICK, PROC_REF(on_equipment_click))

/datum/component/golden_gardren_phasing/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOVABLE_CAN_PASS_THROUGH, COMSIG_MOVABLE_MOVED, COMSIG_MECHA_MELEE_CLICK, COMSIG_MECHA_EQUIPMENT_CLICK))
	set_phase_look(FALSE)

/datum/component/golden_gardren_phasing/proc/on_can_pass_through(datum/source, atom/blocker, movement_dir)
	SIGNAL_HANDLER
	var/obj/vehicle/sealed/mecha/mech = parent
	if(!active || mech.throwing || mech.get_charge() <= energy_drain || !isturf(mech.loc))
		return NONE
	var/turf/destination = get_step(mech.loc, movement_dir)
	if(!destination || !check_teleport_valid(mech, destination) || SSmapping.level_trait(destination.z, ZTRAIT_NOPHASE))
		return NONE
	return COMSIG_COMPONENT_PERMIT_PASSAGE

/datum/component/golden_gardren_phasing/proc/on_moved(datum/source, atom/old_loc, movement_dir, forced)
	SIGNAL_HANDLER
	var/obj/vehicle/sealed/mecha/mech = parent
	if(active && !forced && isturf(mech.loc))
		mech.use_energy(energy_drain)

/datum/component/golden_gardren_phasing/proc/on_melee_click(datum/source, mob/living/pilot, atom/target, on_cooldown, is_adjacent)
	SIGNAL_HANDLER
	if(!active)
		return NONE
	var/obj/vehicle/sealed/mecha/mech = parent
	mech.balloon_alert(pilot, "не во время фазового сдвига!")
	return COMPONENT_CANCEL_MELEE_CLICK

/datum/component/golden_gardren_phasing/proc/on_equipment_click(datum/source, mob/living/pilot, atom/target)
	SIGNAL_HANDLER
	if(!active)
		return NONE
	var/obj/vehicle/sealed/mecha/mech = parent
	mech.balloon_alert(pilot, "не во время фазового сдвига!")
	return COMPONENT_CANCEL_EQUIPMENT_CLICK

/// Turns the phase shift on or off on the pilot's request. Returns TRUE if the state changed.
/datum/component/golden_gardren_phasing/proc/toggle(mob/user)
	var/obj/vehicle/sealed/mecha/mech = parent
	if(!active)
		var/datum/component/golden_gardren_fist/fist = mech.GetComponent(/datum/component/golden_gardren_fist)
		if(fist?.held)
			mech.balloon_alert(user, "сначала отпустите цель!")
			return FALSE
		if(mech.get_charge() <= energy_drain)
			mech.balloon_alert(user, "мало энергии!")
			return FALSE
	set_active(!active)
	mech.balloon_alert(user, active ? "фазовый сдвиг включён" : "фазовый сдвиг выключен")
	return TRUE

/datum/component/golden_gardren_phasing/proc/set_active(new_state)
	var/obj/vehicle/sealed/mecha/mech = parent
	if(active == new_state)
		return
	active = new_state
	mech.log_message("Phasing [active ? "enabled" : "disabled"].", LOG_MECHA)
	playsound(mech, 'sound/vehicles/mecha/mechmove03.ogg', 50, TRUE)
	set_phase_look(active)
	for(var/mob/occupant as anything in mech.occupants)
		var/datum/action/phasing_button = LAZYACCESSASSOC(mech.occupant_actions, occupant, /datum/action/vehicle/sealed/mecha/golden_gardren_phasing)
		if(phasing_button)
			phasing_button.button_icon_state = "mech_phasing_[active ? "on" : "off"]"
			phasing_button.build_all_button_icons()

/// Toggles the phase shift. The pilot's seat: movement belongs to them.
/datum/action/vehicle/sealed/mecha/golden_gardren_phasing
	name = "Фазовый сдвиг"
	desc = "Проходить сквозь стены и препятствия. Каждый шаг тратит много энергии; руки и оружие недоступны, пока сдвиг включён."
	button_icon_state = "mech_phasing_off"

/datum/action/vehicle/sealed/mecha/golden_gardren_phasing/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return
	if(!chassis || !chassis.is_driver(owner))
		return
	var/datum/component/golden_gardren_phasing/phasing = chassis.GetComponent(/datum/component/golden_gardren_phasing)
	phasing?.toggle(owner)

/// Blurs the mech and makes it half see-through while it phases.
/datum/component/golden_gardren_phasing/proc/set_phase_look(phasing)
	var/obj/vehicle/sealed/mecha/mech = parent
	if(phasing)
		mech.add_filter("golden_gardren_phasing", 1, gauss_blur_filter(1.5))
		animate(mech, alpha = 160, time = 0.3 SECONDS)
		return
	mech.remove_filter("golden_gardren_phasing")
	animate(mech, alpha = initial(mech.alpha), time = 0.3 SECONDS)
