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

/datum/golden_gardren_cockpit
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
	data["charge_percent"] = mech.cell?.maxcharge > 0 ? mech.cell.percent() : 0
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
	else if(seat == "weapons")
		data["shield_ready"] = COOLDOWN_FINISHED(shield, toggle_cooldown)
		data["strike_cooldown"] = CEILING(S_TIMER_COOLDOWN_TIMELEFT(mech, COOLDOWN_MECHA_MISSILE_STRIKE) / (1 SECONDS), 1)
		var/list/weapons = list()
		for(var/slot in list(MECHA_L_ARM, MECHA_R_ARM))
			var/obj/item/mecha_parts/mecha_equipment/weapon/weapon = mech.equip_by_category[slot]
			if(!istype(weapon))
				continue
			weapons += list(list(
				"slot" = slot,
				"name" = weapon.name,
				"button" = slot == MECHA_L_ARM ? "ЛКМ" : "ПКМ",
			))
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
	if(action == "toggle_shield")
		var/datum/component/golden_gardren_shield/shield = mech.GetComponent(/datum/component/golden_gardren_shield)
		return shield.toggle(user)
	return FALSE
