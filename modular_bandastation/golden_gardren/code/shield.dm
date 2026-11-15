/// Upkeep drawn from the mech's cell every second while the shield is up.
#define GOLDEN_GARDREN_SHIELD_UPKEEP (0.005 * STANDARD_CELL_CHARGE)
/// Shield points restored every second while the shield recharges.
#define GOLDEN_GARDREN_SHIELD_RECHARGE_RATE 15
/// How long after taking a hit or going down the shield starts recharging.
#define GOLDEN_GARDREN_SHIELD_RECHARGE_DELAY (5 SECONDS)
/// How long the shield cannot be raised after the operator lowers it.
#define GOLDEN_GARDREN_SHIELD_TOGGLE_DELAY (3 SECONDS)
/// How long the shield cannot be raised after it collapses from damage or lack of power.
#define GOLDEN_GARDREN_SHIELD_COLLAPSE_DELAY (15 SECONDS)

/// Returns the energy shield of a Golden-Gardren family mech, or null if it has none.
/proc/golden_gardren_shield_of(obj/vehicle/sealed/mecha/mech)
	if(istype(mech, /obj/vehicle/sealed/mecha/golden_gardren))
		var/obj/vehicle/sealed/mecha/golden_gardren/frame = mech
		return frame.shield
	if(istype(mech, /obj/vehicle/sealed/mecha/golden))
		var/obj/vehicle/sealed/mecha/golden/golden = mech
		return golden.shield
	return null

/**
 * ## Golden-Gardren energy shield
 *
 * Soaks brute and burn damage from its own charge before it reaches the hull, recharges between hits,
 * costs the mech's cell while up, and cannot be raised right after it goes down.
 * Owned by the Golden and by the combined mech; the owner routes take_damage() and its overlays through it.
 */
/datum/golden_gardren_shield
	/// The mech this shield protects.
	var/obj/vehicle/sealed/mecha/owner
	/// Whether the shield is currently up.
	var/active = FALSE
	/// Damage the shield can still absorb.
	var/charge = 300
	/// Damage the shield absorbs when fully charged.
	var/max_charge = 300
	/// How much the regular mech shield sprite is stretched to cover the owner.
	var/overlay_scale = 1
	/// Horizontal shift of the shield sprite to centre it on the owner.
	var/overlay_offset_w = 0
	/// Vertical shift of the shield sprite to centre it on the owner.
	var/overlay_offset_z = 4
	/// The shield cannot be raised until this runs out.
	COOLDOWN_DECLARE(toggle_cooldown)
	/// The shield does not recharge until this runs out.
	COOLDOWN_DECLARE(recharge_cooldown)

/datum/golden_gardren_shield/New(obj/vehicle/sealed/mecha/owner, overlay_scale = 1, overlay_offset_w = 0, overlay_offset_z = 4)
	src.owner = owner
	src.overlay_scale = overlay_scale
	src.overlay_offset_w = overlay_offset_w
	src.overlay_offset_z = overlay_offset_z
	START_PROCESSING(SSobj, src)

/datum/golden_gardren_shield/Destroy(force)
	STOP_PROCESSING(SSobj, src)
	owner = null
	return ..()

/datum/golden_gardren_shield/process(seconds_per_tick)
	if(active)
		if(!owner.cell || !owner.use_energy(GOLDEN_GARDREN_SHIELD_UPKEEP * seconds_per_tick))
			set_active(FALSE, collapsed = TRUE)
		return
	if(charge < max_charge && COOLDOWN_FINISHED(src, recharge_cooldown))
		charge = min(max_charge, charge + GOLDEN_GARDREN_SHIELD_RECHARGE_RATE * seconds_per_tick)

/// Spends the charge on incoming brute or burn damage. Returns the damage left for the hull.
/datum/golden_gardren_shield/proc/absorb(damage_amount, damage_type)
	if(!active || damage_amount <= 0 || (damage_type != BRUTE && damage_type != BURN))
		return damage_amount
	var/absorbed = min(damage_amount, charge)
	charge -= absorbed
	COOLDOWN_START(src, recharge_cooldown, GOLDEN_GARDREN_SHIELD_RECHARGE_DELAY)
	playsound(owner, 'sound/vehicles/mecha/mech_shield_deflect.ogg', 60, TRUE)
	if(charge <= 0)
		set_active(FALSE, collapsed = TRUE)
	return damage_amount - absorbed

/// Raises or lowers the shield on the operator's request. Returns TRUE if the state changed.
/datum/golden_gardren_shield/proc/toggle(mob/user)
	if(active)
		set_active(FALSE)
		return TRUE
	if(!COOLDOWN_FINISHED(src, toggle_cooldown))
		owner.balloon_alert(user, "щит перезаряжается!")
		return FALSE
	if(charge <= 0)
		owner.balloon_alert(user, "щит разряжен!")
		return FALSE
	if(!owner.has_charge(GOLDEN_GARDREN_SHIELD_UPKEEP))
		owner.balloon_alert(user, "мало энергии!")
		return FALSE
	set_active(TRUE)
	return TRUE

/// Lowers the shield if nobody in the mech can operate it anymore.
/datum/golden_gardren_shield/proc/drop_if_unmanned()
	if(active && !owner.return_amount_of_controllers_with_flag(VEHICLE_CONTROL_EQUIPMENT))
		set_active(FALSE)

/// Changes the shield state. A collapse blocks raising it again for longer than a manual shutdown.
/datum/golden_gardren_shield/proc/set_active(new_state, collapsed = FALSE)
	if(active == new_state)
		return
	active = new_state
	if(active)
		playsound(owner, 'sound/vehicles/mecha/mech_shield_raise.ogg', 50, FALSE)
		to_chat(owner.occupants, span_notice("Щит поднят."))
	else
		COOLDOWN_START(src, toggle_cooldown, collapsed ? GOLDEN_GARDREN_SHIELD_COLLAPSE_DELAY : GOLDEN_GARDREN_SHIELD_TOGGLE_DELAY)
		COOLDOWN_START(src, recharge_cooldown, GOLDEN_GARDREN_SHIELD_RECHARGE_DELAY)
		playsound(owner, 'sound/vehicles/mecha/mech_shield_drop.ogg', 50, FALSE)
		to_chat(owner.occupants, collapsed ? span_danger("Щит пробит!") : span_notice("Щит опущен."))
	owner.log_message("Shield [active ? "raised" : "lowered"][collapsed ? " (collapsed)" : ""], charge [charge].", LOG_MECHA)
	for(var/mob/occupant as anything in owner.occupants)
		var/datum/action/shield_button = LAZYACCESSASSOC(owner.occupant_actions, occupant, /datum/action/vehicle/sealed/mecha/golden_gardren_shield)
		if(shield_button)
			shield_button.button_icon_state = "mech_defense_mode_[active ? "on" : "off"]"
			shield_button.build_all_button_icons()
	owner.update_appearance(UPDATE_OVERLAYS)

/// The shield glow drawn over the owner while the shield is up, or null.
/datum/golden_gardren_shield/proc/get_overlay()
	if(!active)
		return null
	var/mutable_appearance/glow = mutable_appearance('icons/mob/effects/durand_shield.dmi', "shield")
	// The shield sprite is drawn for a regular mech, so it is stretched over a bigger owner.
	if(overlay_scale != 1)
		glow.transform = matrix().Scale(overlay_scale)
	glow.pixel_w = overlay_offset_w
	glow.pixel_z = overlay_offset_z
	return glow

/// Toggles the shield of the mech. Weapons seat only.
/datum/action/vehicle/sealed/mecha/golden_gardren_shield
	name = "Щит"
	desc = "Поднять или опустить энергощит. Щит гасит урон собственным зарядом, тратит энергию батареи и после пробития долго восстанавливается."
	button_icon_state = "mech_defense_mode_off"

/datum/action/vehicle/sealed/mecha/golden_gardren_shield/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return
	var/datum/golden_gardren_shield/shield = golden_gardren_shield_of(chassis)
	if(!shield || !(owner in chassis.return_controllers_with_flag(VEHICLE_CONTROL_EQUIPMENT)))
		return
	shield.toggle(owner)

#undef GOLDEN_GARDREN_SHIELD_UPKEEP
#undef GOLDEN_GARDREN_SHIELD_RECHARGE_RATE
#undef GOLDEN_GARDREN_SHIELD_RECHARGE_DELAY
#undef GOLDEN_GARDREN_SHIELD_TOGGLE_DELAY
#undef GOLDEN_GARDREN_SHIELD_COLLAPSE_DELAY
