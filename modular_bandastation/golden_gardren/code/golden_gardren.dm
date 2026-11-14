/// Upkeep drawn from the main cell every second while the shield is up.
#define GOLDEN_GARDREN_SHIELD_UPKEEP (0.005 * STANDARD_CELL_CHARGE)
/// Shield points restored every second while the shield recharges.
#define GOLDEN_GARDREN_SHIELD_RECHARGE_RATE 15
/// How long after taking a hit or going down the shield starts recharging.
#define GOLDEN_GARDREN_SHIELD_RECHARGE_DELAY (5 SECONDS)
/// How long the shield cannot be raised after the operator lowers it.
#define GOLDEN_GARDREN_SHIELD_TOGGLE_DELAY (3 SECONDS)
/// How long the shield cannot be raised after it collapses from damage or lack of power.
#define GOLDEN_GARDREN_SHIELD_COLLAPSE_DELAY (15 SECONDS)
/// Share of integrity at and below which the pilots are warned that the frame is about to break.
#define GOLDEN_GARDREN_CRITICAL_INTEGRITY 0.3

/**
 * ## Golden-Gardren
 *
 * The combined two-pilot mech. Occupies a single tile so it fits through airlocks, but is drawn twice as large.
 * Main seat: movement, fists and the Golden Ram. Weapons seat: arm weapons, the shield and the missile strike.
 * When formed from the pair, the Golden and the Gardren are kept docked inside and the frame runs on the Gardren's parts.
 * Event-only: spawned by admins or formed from the pair, not buildable.
 */
/obj/vehicle/sealed/mecha/golden_gardren
	name = "\improper Golden-Gardren"
	desc = "Громадная боевая машина: Голден сидит в люке Гардрена, как голова на плечах. Управляется двумя пилотами."
	icon = 'modular_bandastation/golden_gardren/icons/golden_gardren.dmi'
	icon_state = "golden_gardren"
	base_icon_state = "golden_gardren"
	SET_BASE_PIXEL(-16, 0)
	mecha_flags = CAN_STRAFE | IS_ENCLOSED | HAS_LIGHTS | BEACON_TRACKABLE
	// Reuses the Savannah-Ivanov module bit so combat equipment fits without a new exosuit define.
	mech_type = EXOSUIT_MODULE_SAVANNAH
	movedelay = 3
	max_integrity = 450
	armor_type = /datum/armor/mecha_golden_gardren
	max_temperature = 30000
	force = 45
	destruction_sleep_duration = 40
	exit_delay = 40
	max_occupants = 2
	wreckage = /obj/structure/mecha_wreckage/golden_gardren
	equip_by_category = list(
		MECHA_L_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/heavy,
		MECHA_R_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack,
		MECHA_UTILITY = list(),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(),
	)
	max_equip_by_category = list(
		MECHA_L_ARM = 1,
		MECHA_R_ARM = 1,
		MECHA_UTILITY = 3,
		MECHA_POWER = 1,
		MECHA_ARMOR = 1,
	)
	/// The Golden docked inside while combined. Null for an admin-spawned frame.
	var/obj/vehicle/sealed/mecha/golden/docked_golden
	/// The Gardren docked inside while combined. Null for an admin-spawned frame.
	var/obj/vehicle/sealed/mecha/gardren/docked_gardren
	/// Whether the shield is currently up.
	var/shield_active = FALSE
	/// Damage the shield can still absorb.
	var/shield_charge = 300
	/// Damage the shield absorbs when fully charged.
	var/shield_max_charge = 300
	/// The shield cannot be raised until this runs out.
	COOLDOWN_DECLARE(shield_toggle_cooldown)
	/// The shield does not recharge until this runs out.
	COOLDOWN_DECLARE(shield_recharge_cooldown)
	/// Timer of a running emergency ejection countdown.
	var/emergency_eject_timer

/datum/armor/mecha_golden_gardren
	melee = 45
	bullet = 40
	laser = 35
	energy = 30
	bomb = 40
	fire = 100
	acid = 100

/obj/vehicle/sealed/mecha/golden_gardren/Destroy()
	deltimer(emergency_eject_timer)
	// Put the pilots on free turfs instead of the base drop under the frame.
	emergency_eject(stun = FALSE)
	// The halves exist only as a part of this frame now, so they go down with it.
	QDEL_NULL(docked_golden)
	QDEL_NULL(docked_gardren)
	return ..()

/obj/vehicle/sealed/mecha/golden_gardren/generate_actions()
	. = ..()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/golden_gardren_swap_seat)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/golden_gardren_emergency_eject)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/golden_gardren_separate)
	initialize_controller_action_type(/datum/action/vehicle/sealed/mecha/golden_gardren_ram, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/mecha/mech_view_stats, VEHICLE_CONTROL_EQUIPMENT)
	initialize_controller_action_type(/datum/action/vehicle/sealed/mecha/golden_gardren_shield, VEHICLE_CONTROL_EQUIPMENT)
	initialize_controller_action_type(/datum/action/vehicle/sealed/mecha/ivanov_strike/golden_gardren, VEHICLE_CONTROL_EQUIPMENT)

/// The first pilot in takes the main seat, the second one the weapons seat.
/obj/vehicle/sealed/mecha/golden_gardren/auto_assign_occupant_flags(mob/new_occupant)
	if(driver_amount() < max_drivers)
		add_control_flags(new_occupant, GOLDEN_GARDREN_MAIN_SEAT)
	else
		add_control_flags(new_occupant, GOLDEN_GARDREN_WEAPONS_SEAT)

/// Moves an occupant into the given seat, replacing whatever seat they had.
/obj/vehicle/sealed/mecha/golden_gardren/proc/assign_seat(mob/occupant, main_seat)
	remove_control_flags(occupant, ALL)
	remove_all_equipment_actions(occupant)
	add_control_flags(occupant, main_seat ? GOLDEN_GARDREN_MAIN_SEAT : GOLDEN_GARDREN_WEAPONS_SEAT)
	generate_equipment_actions(occupant)
	update_appearance()

// Equipment buttons belong to the weapons seat, not to the seat with mech settings.
/obj/vehicle/sealed/mecha/golden_gardren/generate_equipment_actions(mob/occupant)
	if(!(occupant in occupants) || !(occupants[occupant] & VEHICLE_CONTROL_EQUIPMENT))
		return
	for(var/obj/item/mecha_parts/mecha_equipment/equipment in flat_equipment)
		if(is_equipment_valid_for_action(equipment))
			grant_equipment_action(occupant, equipment)

/obj/vehicle/sealed/mecha/golden_gardren/on_equipment_attach(obj/item/mecha_parts/mecha_equipment/equipment)
	if(!is_equipment_valid_for_action(equipment))
		return
	for(var/mob/occupant as anything in return_controllers_with_flag(VEHICLE_CONTROL_EQUIPMENT))
		grant_equipment_action(occupant, equipment)

/obj/vehicle/sealed/mecha/golden_gardren/remove_occupant(mob/driver)
	. = ..()
	// Without an operator the shield cannot be held.
	if(shield_active && !return_amount_of_controllers_with_flag(VEHICLE_CONTROL_EQUIPMENT))
		set_shield(FALSE)

/// Each seat may only use its own part of the mech panel: weapons belong to the weapons seat, settings to the main seat.
/obj/vehicle/sealed/mecha/golden_gardren/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	var/mob/user = ui?.user
	if(user && is_occupant(user))
		var/static/list/weapons_seat_actions = list("select_module", "equip_act", "toggle_safety")
		if(occupants[user] & VEHICLE_CONTROL_SETTINGS)
			if(action == "equip_act")
				return FALSE
		else if(!(action in weapons_seat_actions))
			return FALSE
	return ..()

/obj/vehicle/sealed/mecha/golden_gardren/process(seconds_per_tick)
	. = ..()
	if(shield_active)
		if(!cell || !use_energy(GOLDEN_GARDREN_SHIELD_UPKEEP * seconds_per_tick))
			set_shield(FALSE, collapsed = TRUE)
		return
	if(shield_charge < shield_max_charge && COOLDOWN_FINISHED(src, shield_recharge_cooldown))
		shield_charge = min(shield_max_charge, shield_charge + GOLDEN_GARDREN_SHIELD_RECHARGE_RATE * seconds_per_tick)

/// The shield soaks brute and burn damage from its own charge before it reaches the hull. Crossing into critical damage raises the alarm.
/obj/vehicle/sealed/mecha/golden_gardren/take_damage(damage_amount, damage_type = BRUTE, damage_flag = "", sound_effect = TRUE, attack_dir, armour_penetration = 0)
	if(shield_active && damage_amount > 0 && (damage_type == BRUTE || damage_type == BURN))
		var/absorbed = min(damage_amount, shield_charge)
		shield_charge -= absorbed
		damage_amount -= absorbed
		COOLDOWN_START(src, shield_recharge_cooldown, GOLDEN_GARDREN_SHIELD_RECHARGE_DELAY)
		playsound(src, 'sound/vehicles/mecha/mech_shield_deflect.ogg', 60, TRUE)
		if(shield_charge <= 0)
			set_shield(FALSE, collapsed = TRUE)
		if(damage_amount <= 0)
			return 0
	var/critical_integrity = max_integrity * GOLDEN_GARDREN_CRITICAL_INTEGRITY
	var/was_above_critical = get_integrity() > critical_integrity
	. = ..()
	if(was_above_critical && !QDELETED(src) && get_integrity() > 0 && get_integrity() <= critical_integrity)
		log_message("Integrity critical.", LOG_MECHA)
		to_chat(occupants, span_userdanger("КРИТИЧЕСКИЕ ПОВРЕЖДЕНИЯ! Корпус вот-вот разрушится — готовьтесь к аварийному катапультированию."))
		playsound(src, 'sound/machines/warning-buzzer.ogg', 75, FALSE)

/// Throws the pilots clear of the wreck before the base destruction handles what is left.
/obj/vehicle/sealed/mecha/golden_gardren/atom_destruction(damage_flag)
	deltimer(emergency_eject_timer)
	emergency_eject()
	return ..()

/// Raises or lowers the shield on the operator's request. Returns TRUE if the state changed.
/obj/vehicle/sealed/mecha/golden_gardren/proc/toggle_shield(mob/user)
	if(shield_active)
		set_shield(FALSE)
		return TRUE
	if(!COOLDOWN_FINISHED(src, shield_toggle_cooldown))
		balloon_alert(user, "щит перезаряжается!")
		return FALSE
	if(shield_charge <= 0)
		balloon_alert(user, "щит разряжен!")
		return FALSE
	if(!has_charge(GOLDEN_GARDREN_SHIELD_UPKEEP))
		balloon_alert(user, "мало энергии!")
		return FALSE
	set_shield(TRUE)
	return TRUE

/// Changes the shield state. A collapse blocks raising it again for longer than a manual shutdown.
/obj/vehicle/sealed/mecha/golden_gardren/proc/set_shield(new_state, collapsed = FALSE)
	if(shield_active == new_state)
		return
	shield_active = new_state
	if(shield_active)
		playsound(src, 'sound/vehicles/mecha/mech_shield_raise.ogg', 50, FALSE)
		to_chat(occupants, span_notice("Щит поднят."))
	else
		COOLDOWN_START(src, shield_toggle_cooldown, collapsed ? GOLDEN_GARDREN_SHIELD_COLLAPSE_DELAY : GOLDEN_GARDREN_SHIELD_TOGGLE_DELAY)
		COOLDOWN_START(src, shield_recharge_cooldown, GOLDEN_GARDREN_SHIELD_RECHARGE_DELAY)
		playsound(src, 'sound/vehicles/mecha/mech_shield_drop.ogg', 50, FALSE)
		to_chat(occupants, collapsed ? span_danger("Щит пробит!") : span_notice("Щит опущен."))
	log_message("Shield [shield_active ? "raised" : "lowered"][collapsed ? " (collapsed)" : ""], charge [shield_charge].", LOG_MECHA)
	for(var/mob/occupant as anything in occupants)
		var/datum/action/shield_button = LAZYACCESSASSOC(occupant_actions, occupant, /datum/action/vehicle/sealed/mecha/golden_gardren_shield)
		if(shield_button)
			shield_button.button_icon_state = "mech_defense_mode_[shield_active ? "on" : "off"]"
			shield_button.build_all_button_icons()
	update_appearance(UPDATE_OVERLAYS)

/obj/vehicle/sealed/mecha/golden_gardren/update_overlays()
	. = ..()
	if(!shield_active)
		return
	var/mutable_appearance/shield = mutable_appearance('icons/mob/effects/durand_shield.dmi', "shield")
	// The shield sprite is drawn for a regular mech, so it is stretched over the twice as big frame.
	shield.transform = matrix().Scale(2)
	shield.pixel_w = 16
	shield.pixel_z = 24
	. += shield

/**
 * Forms the frame from the pair: moves the pilots in, takes over the Gardren's parts and docks both halves.
 * Every check must already have passed; either pilot may be missing.
 * Returns FALSE and leaves the pair untouched if a pilot could not be moved.
 */
/obj/vehicle/sealed/mecha/golden_gardren/proc/assemble(obj/vehicle/sealed/mecha/golden/golden, obj/vehicle/sealed/mecha/gardren/gardren, mob/living/golden_pilot, mob/living/gardren_pilot)
	if(gardren_pilot && !take_pilot_from(gardren, gardren_pilot))
		return FALSE
	if(golden_pilot && !take_pilot_from(golden, golden_pilot))
		if(gardren_pilot)
			move_pilot_to(gardren, gardren_pilot)
		return FALSE
	// The seat follows the half the pilot came from, whoever entered first.
	if(gardren_pilot)
		assign_seat(gardren_pilot, main_seat = TRUE)
	if(golden_pilot)
		assign_seat(golden_pilot, main_seat = FALSE)

	for(var/obj/item/stock_parts/part in list(gardren.cell, gardren.scanmod, gardren.capacitor, gardren.servo))
		part.forceMove(src)
	gardren.locate_parts()
	locate_parts()

	max_integrity = golden.max_integrity + gardren.max_integrity
	update_integrity(golden.get_integrity() + gardren.get_integrity())

	dock_component(golden)
	dock_component(gardren)
	docked_golden = golden
	docked_gardren = gardren
	diag_hud_set_mechhealth()
	update_appearance()
	log_message("Combined from [golden] ([key_name(golden_pilot)]) and [gardren] ([key_name(gardren_pilot)]).", LOG_MECHA)
	return TRUE

/// Moves a pilot from one of the halves into this frame without dropping them on the floor in between.
/obj/vehicle/sealed/mecha/golden_gardren/proc/take_pilot_from(obj/vehicle/sealed/mecha/source, mob/living/pilot)
	if(!source.is_occupant(pilot) || pilot.loc != source)
		return FALSE
	SStgui.close_user_uis(pilot, source)
	// Leaving the source makes its Exited() remove the occupant there.
	if(!mob_enter(pilot, silent = TRUE))
		return FALSE
	pilot.update_mouse_pointer()
	set_mouse_pointer()
	return TRUE

/// Moves a pilot from this frame into one of the halves. Used to roll back a failed assembly and on separation.
/obj/vehicle/sealed/mecha/golden_gardren/proc/move_pilot_to(obj/vehicle/sealed/mecha/destination, mob/living/pilot)
	if(!is_occupant(pilot))
		return
	SStgui.close_user_uis(pilot, src)
	// Leaving this frame makes its Exited() remove the occupant here.
	destination.mob_enter(pilot, silent = TRUE)
	pilot.update_mouse_pointer()
	destination.set_mouse_pointer()

/// Stores a half inside the frame: hidden, switched off and not processing until the frame separates.
/obj/vehicle/sealed/mecha/golden_gardren/proc/dock_component(obj/vehicle/sealed/mecha/component)
	if(component.mecha_flags & LIGHTS_ON)
		component.toggle_lights()
	component.forceMove(src)
	component.completely_disabled = TRUE
	STOP_PROCESSING(SSobj, component)
	RegisterSignal(component, COMSIG_QDELETING, PROC_REF(on_docked_component_deleted))

/obj/vehicle/sealed/mecha/golden_gardren/proc/on_docked_component_deleted(datum/source)
	SIGNAL_HANDLER
	if(source == docked_golden)
		docked_golden = null
	else if(source == docked_gardren)
		docked_gardren = null

/obj/structure/mecha_wreckage/golden_gardren
	name = "\improper Golden-Gardren wreckage"
	desc = "Груда искорёженного золочёного металла — всё, что осталось от Голден-Гардрена. Восстановить невозможно, но что-то ещё можно снять."
	icon = 'modular_bandastation/golden_gardren/icons/golden_gardren.dmi'
	icon_state = "golden_gardren-broken"
	SET_BASE_PIXEL(-16, 0)
	welder_salvage = list(/obj/item/stack/sheet/mineral/gold, /obj/item/stack/sheet/plasteel, /obj/item/stack/sheet/iron, /obj/item/stack/rods)
	salvage_num = 8

#undef GOLDEN_GARDREN_SHIELD_UPKEEP
#undef GOLDEN_GARDREN_SHIELD_RECHARGE_RATE
#undef GOLDEN_GARDREN_SHIELD_RECHARGE_DELAY
#undef GOLDEN_GARDREN_SHIELD_TOGGLE_DELAY
#undef GOLDEN_GARDREN_SHIELD_COLLAPSE_DELAY
#undef GOLDEN_GARDREN_CRITICAL_INTEGRITY
