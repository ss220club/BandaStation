/obj/vehicle/sealed/mecha/golden_gardren_base
	abstract_type = /obj/vehicle/sealed/mecha/golden_gardren_base
	mecha_flags = CAN_STRAFE | IS_ENCLOSED | HAS_LIGHTS | BEACON_TRACKABLE
	mech_type = EXOSUIT_MODULE_SAVANNAH
	max_temperature = 30000
	destruction_sleep_duration = 40
	exit_delay = 40
	equip_by_category = list(
		MECHA_L_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/energy/laser,
		MECHA_R_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/energy/laser,
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

/obj/vehicle/sealed/mecha/golden_gardren_base/Initialize(mapload, built_manually)
	. = ..()
	AddComponent(/datum/component/golden_gardren_ejection)

/obj/vehicle/sealed/mecha/golden_gardren_base/populate_parts()
	cell = new /obj/item/stock_parts/power_store/cell/bluespace(src)
	scanmod = new /obj/item/stock_parts/scanning_module(src)
	capacitor = new /obj/item/stock_parts/capacitor(src)
	servo = new /obj/item/stock_parts/servo(src)
	update_part_values()

/obj/vehicle/sealed/mecha/golden_gardren_base/update_overlays()
	. = ..()
	if(length(occupants))
		. += emissive_appearance(icon, "[base_icon_state]-glow", src, alpha = src.alpha)

/obj/vehicle/sealed/mecha/golden_gardren_base/remove_occupant(mob/driver)
	. = ..()
	var/datum/component/golden_gardren_ejection/ejection = GetComponent(/datum/component/golden_gardren_ejection)
	ejection?.clear_landing_choice(driver)
	drop_unmanned_systems()

/obj/vehicle/sealed/mecha/golden_gardren_base/proc/drop_unmanned_systems()
	var/datum/component/golden_gardren_shield/shield = GetComponent(/datum/component/golden_gardren_shield)
	shield?.drop_if_unmanned()
	if(!return_amount_of_controllers_with_flag(VEHICLE_CONTROL_MELEE))
		golden_gardren_release_fist(src)

/obj/vehicle/sealed/mecha/golden_gardren_base/take_damage(damage_amount, damage_type = BRUTE, damage_flag = "", sound_effect = TRUE, attack_dir, armour_penetration = 0)
	var/datum/component/golden_gardren_shield/shield = GetComponent(/datum/component/golden_gardren_shield)
	if(shield?.active && damage_amount > 0)
		damage_amount = shield.absorb(damage_amount, damage_type)
		if(damage_amount <= 0)
			return 0
	return ..()

/obj/vehicle/sealed/mecha/golden_gardren_base/user_unbuckle_mob(mob/living/buckled_mob, mob/user)
	if(golden_gardren_fist_intercept_unbuckle(src, buckled_mob, user))
		return null
	return ..()

/obj/vehicle/sealed/mecha/golden_gardren_base/on_mouseclick(mob/user, atom/target, list/modifiers)
	var/datum/component/golden_gardren_ejection/ejection = GetComponent(/datum/component/golden_gardren_ejection)
	if(ejection?.handle_click(user, target))
		return COMSIG_MOB_CANCEL_CLICKON
	return ..()

/obj/vehicle/sealed/mecha/golden_gardren_base/atom_destruction()
	var/datum/component/golden_gardren_ejection/ejection = GetComponent(/datum/component/golden_gardren_ejection)
	ejection?.eject()
	return ..()

/obj/vehicle/sealed/mecha/golden_gardren_base/proc/transfer_stock_parts(obj/vehicle/sealed/mecha/golden_gardren_base/destination)
	for(var/obj/item/stock_parts/part in list(cell, scanmod, capacitor, servo))
		part.forceMove(destination)
	locate_parts()
	destination.locate_parts()

/// Moving the pilot into the destination triggers occupant cleanup on the source.
/obj/vehicle/sealed/mecha/golden_gardren_base/proc/transfer_pilot(obj/vehicle/sealed/mecha/golden_gardren_base/destination, mob/living/pilot)
	if(!is_occupant(pilot) || pilot.loc != src)
		return FALSE
	SStgui.close_user_uis(pilot, src)
	if(!destination.mob_enter(pilot, silent = TRUE))
		return FALSE
	pilot.update_mouse_pointer()
	destination.set_mouse_pointer()
	return TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/heavy/golden_gardren
	equip_cooldown = 1.2 SECONDS
