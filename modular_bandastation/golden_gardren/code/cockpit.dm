/// Opens the cockpit panel of the Golden-Gardren. Each seat sees the shared state and its own controls.
/datum/action/vehicle/sealed/mecha/golden_gardren_cockpit
	name = "Кабина"
	desc = "Панель своего места: состояние машины и управление, доступное этому пилоту."
	button_icon_state = "mech_view_stats"

/datum/action/vehicle/sealed/mecha/golden_gardren_cockpit/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return
	var/obj/vehicle/sealed/mecha/golden_gardren/mech = chassis
	if(!istype(mech) || !(owner in mech.occupants))
		return
	if(!mech.cockpit)
		mech.cockpit = new(mech)
	mech.cockpit.ui_interact(owner)

/**
 * ## Golden-Gardren cockpit
 *
 * Separate per-seat panel of the combined mech, apart from the regular mech panel.
 * The data and every action are filtered by the seat of the user on the server side.
 */
/datum/golden_gardren_cockpit
	/// The mech this panel belongs to.
	var/obj/vehicle/sealed/mecha/golden_gardren/mech

/datum/golden_gardren_cockpit/New(obj/vehicle/sealed/mecha/golden_gardren/owner)
	mech = owner

/datum/golden_gardren_cockpit/Destroy(force)
	SStgui.close_uis(src)
	mech = null
	return ..()

/datum/golden_gardren_cockpit/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GoldenGardrenCockpit", mech.name)
		ui.open()

/datum/golden_gardren_cockpit/ui_status(mob/user, datum/ui_state/state)
	if(QDELETED(mech) || !mech.is_occupant(user) || user.stat == DEAD)
		return UI_CLOSE
	if(user.incapacitated)
		return UI_UPDATE
	return UI_INTERACTIVE

/// Returns "main", "weapons" or null for the seat [user] holds in the mech.
/datum/golden_gardren_cockpit/proc/seat_of(mob/user)
	if(!mech.is_occupant(user))
		return null
	if(mech.is_driver(user))
		return "main"
	if(mech.occupants[user] & VEHICLE_CONTROL_EQUIPMENT)
		return "weapons"
	return null

/datum/golden_gardren_cockpit/ui_data(mob/user)
	var/list/data = list()
	var/seat = seat_of(user)
	data["seat"] = seat
	data["integrity"] = mech.get_integrity()
	data["max_integrity"] = mech.max_integrity
	data["charge"] = mech.cell ? mech.cell.charge : 0
	data["max_charge"] = mech.cell ? mech.cell.maxcharge : 0
	var/datum/component/golden_gardren_shield/shield = mech.GetComponent(/datum/component/golden_gardren_shield)
	data["shield_active"] = shield.active
	data["shield_charge"] = shield.charge
	data["shield_max_charge"] = shield.max_charge
	data["ejecting"] = golden_gardren_is_ejecting(mech)
	data["separate_blocker"] = mech.separate_blocker()
	var/list/main_pilots = mech.return_drivers()
	var/list/gunners = mech.return_controllers_with_flag(VEHICLE_CONTROL_EQUIPMENT)
	var/mob/main_pilot = length(main_pilots) ? main_pilots[1] : null
	var/mob/gunner = length(gunners) ? gunners[1] : null
	data["main_pilot"] = main_pilot?.name
	data["gunner"] = gunner?.name
	if(seat == "main")
		data["strafe"] = mech.strafe
		data["lights"] = !!(mech.mecha_flags & LIGHTS_ON)
		data["force"] = mech.force
		data["ram_cooldown"] = round(S_TIMER_COOLDOWN_TIMELEFT(mech, COOLDOWN_GOLDEN_GARDREN_RAM) / (1 SECONDS))
	else if(seat == "weapons")
		data["shield_ready"] = COOLDOWN_FINISHED(shield, toggle_cooldown)
		data["strike_cooldown"] = round(S_TIMER_COOLDOWN_TIMELEFT(mech, COOLDOWN_MECHA_MISSILE_STRIKE) / (1 SECONDS))
		var/list/weapons = list()
		for(var/slot in list(MECHA_L_ARM, MECHA_R_ARM))
			var/obj/item/mecha_parts/mecha_equipment/weapon/weapon = mech.equip_by_category[slot]
			if(!istype(weapon))
				continue
			var/list/weapon_data = list(
				"slot" = slot,
				"name" = weapon.name,
				"button" = slot == MECHA_L_ARM ? "ЛКМ" : "ПКМ",
			)
			var/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/gun = weapon
			if(istype(gun))
				weapon_data["ammo"] = gun.projectiles
				weapon_data["max_ammo"] = initial(gun.projectiles)
				weapon_data["reserve"] = gun.projectiles_cache
				weapon_data["can_reload"] = !gun.disabledreload && gun.projectiles_cache > 0 && gun.projectiles < initial(gun.projectiles)
			weapons += list(weapon_data)
		data["weapons"] = weapons
	return data

/datum/golden_gardren_cockpit/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/user = ui.user
	var/seat = seat_of(user)
	if(!seat)
		return FALSE
	switch(action)
		if("emergency_eject")
			var/datum/component/golden_gardren_ejection/ejection = mech.GetComponent(/datum/component/golden_gardren_ejection)
			return ejection?.start(user)
		if("separate")
			INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(golden_gardren_try_separate), mech, user)
			return TRUE
	if(seat == "main")
		switch(action)
			if("toggle_strafe")
				mech.toggle_strafe()
				return TRUE
			if("toggle_lights")
				mech.toggle_lights(user = user)
				return TRUE
		return FALSE
	switch(action)
		if("toggle_shield")
			var/datum/component/golden_gardren_shield/shield = mech.GetComponent(/datum/component/golden_gardren_shield)
			return shield.toggle(user)
		if("reload")
			var/slot = params["slot"]
			if(!(slot in list(MECHA_L_ARM, MECHA_R_ARM)))
				return FALSE
			var/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/gun = mech.equip_by_category[slot]
			if(!istype(gun) || gun.disabledreload)
				return FALSE
			return gun.rearm()
	return FALSE
