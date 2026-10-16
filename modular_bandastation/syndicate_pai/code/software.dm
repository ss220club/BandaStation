/mob/living/silicon/pai/proc/has_integrated_radio()
	return FALSE

/mob/living/silicon/pai/syndicate/has_integrated_radio()
	return "Syndicate Radio" in installed_software

/mob/living/silicon/pai/syndicate/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PaiInterface", name)
		ui.open()
		ui.set_autoupdate(TRUE)

/mob/living/silicon/pai/syndicate/ui_data(mob/user)
	. = ..()
	.["chemical_reserve"] = chemical_reserve

/mob/living/silicon/pai/syndicate/ui_act(action, list/params, datum/tgui/ui)
	if(action in syndicate_software)
		if(!installed_software.Find(action))
			balloon_alert(ui.user, "программа недоступна!")
			return FALSE
		switch(action)
			if("Thermal Vision")
				thermal_active = !thermal_active
				if(thermal_active)
					ADD_TRAIT(src, TRAIT_THERMAL_VISION, "syndicate_pai_thermal")
				else
					REMOVE_TRAIT(src, TRAIT_THERMAL_VISION, "syndicate_pai_thermal")
				update_sight()
				return TRUE
			if("Medical Injector")
				return inject_holder(params["reagent"])
			if("Camera Network")
				return use_camera_network()
			if("Security Records")
				if(QDELETED(records_console))
					return FALSE
				records_console.ui_interact(src)
				return TRUE
			if("Syndicate Radio")
				balloon_alert(src, "Канал Синдиката: :t")
				return TRUE
		return FALSE
	return ..()

/mob/living/silicon/pai/syndicate/buy_software(selection)
	if((selection == "Night Vision" && ("Thermal Vision" in installed_software)) || (selection == "Thermal Vision" && ("Night Vision" in installed_software)))
		balloon_alert(src, "ночное видение и термальное зрение несовместимы")
		return FALSE
	if(!..())
		return FALSE
	switch(selection)
		if("Camera Network")
			camera_console = new(src, src)
		if("Security Records")
			records_console = new(src)
			records_console.owner_pai = src
		if("Syndicate Radio")
			var/obj/item/radio/headset/pai_radio = radio
			pai_radio.keyslot2 = new /obj/item/encryptionkey/syndicate(pai_radio)
			pai_radio.subspace_transmission = TRUE
			pai_radio.recalculateChannels()
	return TRUE

/// Inject five units into the carbon carrying the card. The reserve regenerates slowly.
/mob/living/silicon/pai/syndicate/proc/inject_holder(reagent_name)
	if(!("Medical Injector" in installed_software))
		return FALSE
	var/static/list/medical_reagents = list(
		"Epinephrine" = /datum/reagent/medicine/epinephrine,
		"Salbutamol" = /datum/reagent/medicine/salbutamol,
		"Mannitol" = /datum/reagent/medicine/mannitol,
		"Pentetic Acid" = /datum/reagent/medicine/pen_acid,
		"Saline Glucose" = /datum/reagent/medicine/salglu_solution,
	)
	var/reagent_type = medical_reagents[reagent_name]
	var/reserve_cost = 5
	var/mob/living/carbon/holder = get_holder()
	if(!reagent_type || !iscarbon(holder) || !holder.reagents)
		balloon_alert(src, "нет подходящего носителя или реагента")
		return FALSE
	if(chemical_reserve < reserve_cost || !COOLDOWN_FINISHED(src, chemical_injection))
		balloon_alert(src, "инъектор перезаряжается")
		return FALSE
	chemical_reserve -= reserve_cost
	COOLDOWN_START(src, chemical_injection, 10 SECONDS)
	if(!chemical_recharge_running)
		chemical_recharge_running = TRUE
		addtimer(CALLBACK(src, PROC_REF(replenish_chemicals)), 1 MINUTES)
	holder.reagents.add_reagent(reagent_type, 5)
	SStgui.update_uis(src)
	to_chat(src, span_notice("Введено 5 единиц [reagent_name] носителю [holder]."))
	return TRUE

/mob/living/silicon/pai/syndicate/proc/replenish_chemicals()
	chemical_reserve = min(30, chemical_reserve + 5)
	SStgui.update_uis(src)
	if(chemical_reserve < 30)
		addtimer(CALLBACK(src, PROC_REF(replenish_chemicals)), 1 MINUTES)
	else
		chemical_recharge_running = FALSE

/// The built-in console moves with the card and only accepts its own pAI.
/obj/machinery/computer/camera_advanced/syndicate_pai
	name = "pAI camera network"
	invisibility = INVISIBILITY_ABSTRACT
	add_usb_port = FALSE
	var/mob/living/silicon/pai/syndicate/owner_pai

/obj/machinery/computer/camera_advanced/syndicate_pai/Initialize(mapload, mob/living/silicon/pai/syndicate/new_owner)
	. = ..()
	owner_pai = new_owner

/obj/machinery/computer/camera_advanced/syndicate_pai/can_use(mob/living/user)
	return user == owner_pai && !QDELETED(owner_pai?.card) && ("Camera Network" in owner_pai.installed_software) && !QDELETED(user?.client)

/obj/machinery/computer/camera_advanced/syndicate_pai/process()
	if(!can_use(current_user))
		unset_machine()
		return PROCESS_KILL

/obj/machinery/computer/camera_advanced/syndicate_pai/attack_hand(mob/user, list/modifiers)
	// The normal console requires physical interaction with a powered machine.
	// This console is integrated into the pAI card instead.
	if(!can_use(user) || (!QDELETED(current_user) && current_user != user))
		return
	if(current_user == user)
		unset_machine()
		return
	if(!eyeobj && !CreateEye())
		return
	var/turf/camera_location
	var/turf/origin = get_turf(owner_pai.card)
	if(eyeobj.use_visibility && !SScameras.is_visible_by_cameras(origin))
		for(var/obj/machinery/camera/candidate as anything in SScameras.cameras)
			if(candidate.can_use() && length(networks & candidate.network))
				camera_location = get_turf(candidate)
				break
	else
		camera_location = origin
	if(!camera_location)
		to_chat(user, span_warning("В сети нет доступных камер."))
		return
	give_eye_control(user)
	eyeobj.setLoc(camera_location, TRUE)

/mob/living/silicon/pai/syndicate/proc/use_camera_network()
	if(!("Camera Network" in installed_software) || QDELETED(camera_console))
		return FALSE
	camera_console.attack_hand(src)
	return TRUE

/// Remote machinery uses the holoform's sight when deployed, or the card's sight when folded.
/mob/living/silicon/pai/syndicate/proc/can_control_remote_machine(obj/machinery/target)
	if(!("Remote Machinery" in installed_software) || !client || QDELETED(target))
		return FALSE
	var/atom/viewpoint = holoform ? src : card
	var/turf/eye_turf = get_turf(viewpoint)
	return eye_turf && (target in view(7, eye_turf))

/// Open the APC's native interface from either the folded card or holoform.
/mob/living/silicon/pai/syndicate/ClickOn(atom/target, params)
	if(istype(target, /obj/machinery/power/apc))
		var/list/modifiers = params2list(params)
		if(!LAZYACCESS(modifiers, SHIFT_CLICK) && !LAZYACCESS(modifiers, CTRL_CLICK) && !LAZYACCESS(modifiers, ALT_CLICK) && !LAZYACCESS(modifiers, MIDDLE_CLICK))
			var/obj/machinery/power/apc/apc = target
			if(LAZYACCESS(modifiers, RIGHT_CLICK))
				control_remote_apc(apc, "lock")
				return
			if(can_control_remote_machine(apc) && apc.is_operational && apc.can_use(src, 1))
				active_remote_apc = apc
				apc.ui_interact(src)
				return
	return ..()

/// AI-like shortcuts for visible airlocks; the camera program is independent.
/mob/living/silicon/pai/syndicate/ShiftClickOn(atom/target)
	target.syndicate_pai_shift_click(src)

/mob/living/silicon/pai/syndicate/CtrlClickOn(atom/target)
	target.syndicate_pai_ctrl_click(src)

/mob/living/silicon/pai/syndicate/CtrlShiftClickOn(atom/target)
	target.syndicate_pai_ctrl_shift_click(src)

/mob/living/silicon/pai/syndicate/AltClickOn(atom/target)
	target.syndicate_pai_alt_click(src)

/// Dispatch by target type, as with the station borg's door shortcuts.
/atom/proc/syndicate_pai_shift_click(mob/living/silicon/pai/syndicate/user)
	ShiftClick(user)

/obj/machinery/door/airlock/syndicate_pai_shift_click(mob/living/silicon/pai/syndicate/user)
	user.control_remote_door(src, "open")

/obj/machinery/power/apc/syndicate_pai_shift_click(mob/living/silicon/pai/syndicate/user)
	user.control_remote_apc(src, "lighting")

/atom/proc/syndicate_pai_ctrl_click(mob/living/silicon/pai/syndicate/user)
	user.base_click_ctrl(src)

/obj/machinery/door/airlock/syndicate_pai_ctrl_click(mob/living/silicon/pai/syndicate/user)
	user.control_remote_door(src, "bolts")

/obj/machinery/power/apc/syndicate_pai_ctrl_click(mob/living/silicon/pai/syndicate/user)
	user.control_remote_apc(src, "breaker")

/atom/proc/syndicate_pai_ctrl_shift_click(mob/living/silicon/pai/syndicate/user)
	user.base_click_ctrl_shift(src)

/obj/machinery/door/airlock/syndicate_pai_ctrl_shift_click(mob/living/silicon/pai/syndicate/user)
	user.control_remote_door(src, "emergency")

/obj/machinery/power/apc/syndicate_pai_ctrl_shift_click(mob/living/silicon/pai/syndicate/user)
	user.control_remote_apc(src, "environment")

/atom/proc/syndicate_pai_alt_click(mob/living/silicon/pai/syndicate/user)
	user.base_click_alt(src)

/obj/machinery/door/airlock/syndicate_pai_alt_click(mob/living/silicon/pai/syndicate/user)
	user.control_remote_door(src, "shock")

/obj/machinery/power/apc/syndicate_pai_alt_click(mob/living/silicon/pai/syndicate/user)
	user.control_remote_apc(src, "equipment")

/// Shortcuts and the native APC UI share one cooldown across all APCs.
/mob/living/silicon/pai/syndicate/proc/control_remote_apc(obj/machinery/power/apc/apc, action)
	if(!COOLDOWN_FINISHED(src, remote_machinery_action))
		balloon_alert(src, "управление АПЦ перезаряжается")
		return FALSE
	if(!can_control_remote_machine(apc) || !apc.can_use(src, 1) || !apc.is_operational || apc.failure_timer)
		return FALSE
	switch(action)
		if("lock")
			if((apc.obj_flags & EMAGGED) || (apc.machine_stat & (BROKEN | MAINT)) || apc.remote_control_user)
				return FALSE
			apc.locked = !apc.locked
		if("breaker")
			apc.toggle_breaker(src)
		if("lighting")
			apc.lighting = apc.lighting ? APC_CHANNEL_OFF : APC_CHANNEL_ON
		if("environment")
			apc.environ = apc.environ ? APC_CHANNEL_OFF : APC_CHANNEL_ON
		if("equipment")
			apc.equipment = apc.equipment ? APC_CHANNEL_OFF : APC_CHANNEL_ON
		else
			return FALSE
	apc.add_hiddenprint(src)
	apc.update_appearance()
	apc.update()
	COOLDOWN_START(src, remote_machinery_action, 30 SECONDS)
	log_game("[key_name(src)] remotely used [action] on [apc] at [AREACOORD(apc)] via Syndicate pAI")
	return TRUE

/mob/living/silicon/pai/syndicate/proc/control_remote_door(obj/machinery/door/airlock/airlock, mode)
	if(!COOLDOWN_FINISHED(src, remote_machinery_action))
		balloon_alert(src, "управление шлюзами перезаряжается")
		return FALSE
	if(!can_control_remote_machine(airlock) || !airlock.canAIControl(src) || (airlock.obj_flags & EMAGGED))
		return FALSE
	switch(mode)
		if("open")
			airlock.user_toggle_open(src)
		if("bolts")
			airlock.toggle_bolt(src)
		if("emergency")
			airlock.toggle_emergency(src)
		if("shock")
			if(airlock.secondsElectrified)
				airlock.shock_restore(src)
			else
				airlock.shock_perm(src)
		else
			return FALSE
	COOLDOWN_START(src, remote_machinery_action, 7 SECONDS)
	log_game("[key_name(src)] remotely used [mode] on [airlock] at [AREACOORD(airlock)] via Syndicate pAI")
	return TRUE

/// Airlock operations reuse the normal wire, power and bolt checks.
/obj/machinery/door/airlock/user_allowed(mob/user)
	if(istype(user, /mob/living/silicon/pai/syndicate))
		var/mob/living/silicon/pai/syndicate/pai_user = user
		if(pai_user.can_control_remote_machine(src) && canAIControl(pai_user))
			return TRUE
	return ..()

/// Internal version of the brig records console. Its UI retains the same
/// record editing actions, status validation and administrative audit log.
/obj/machinery/computer/records/security/syndicate_pai
	name = "pAI security records"
	invisibility = INVISIBILITY_ABSTRACT
	use_power = NO_POWER_USE
	req_one_access = list()
	var/mob/living/silicon/pai/syndicate/owner_pai

/obj/machinery/computer/records/security/syndicate_pai/ui_state(mob/user)
	return GLOB.deep_inventory_state

/obj/machinery/computer/records/security/syndicate_pai/ui_status(mob/user, datum/ui_state/state)
	if(user == owner_pai && ("Security Records" in owner_pai.installed_software))
		return UI_INTERACTIVE
	return UI_CLOSE

/obj/machinery/computer/records/security/syndicate_pai/ui_data(mob/user)
	// The shared records UI needs an authenticated session to show the records.
	// This console is physically bound to its owner and has no login step.
	if(user == owner_pai)
		authenticated = TRUE
	var/list/data = ..()
	if(user == owner_pai)
		data["pai_integrated"] = TRUE
		var/turf/card_turf = get_turf(owner_pai.card)
		data["station_z"] = card_turf && is_station_level(card_turf.z)
	return data

/obj/machinery/computer/records/security/syndicate_pai/ui_interact(mob/user, datum/tgui/ui)
	if(user != owner_pai || QDELETED(owner_pai) || !("Security Records" in owner_pai.installed_software))
		return
	authenticated = TRUE
	return ..()

/obj/machinery/computer/records/security/syndicate_pai/ui_act(action, list/params, datum/tgui/ui)
	if(ui?.user != owner_pai || QDELETED(owner_pai) || !("Security Records" in owner_pai.installed_software))
		return FALSE
	if(action in list("delete_record", "expunge_record", "purge_records", "print_record"))
		return FALSE
	if(action == "login" || action == "logout")
		return TRUE
	authenticated = TRUE
	return ..()

/obj/machinery/computer/records/security/syndicate_pai/has_armory_access(mob/user)
	if(user == owner_pai)
		return TRUE
	return ..()

/mob/living/silicon/pai/ui_data(mob/user)
	. = ..()
	.["max_ram"] = initial(ram)
	
/atom/movable/screen/pai/camera_network
	name = "Camera Network"
	icon = 'icons/hud/screen_ai.dmi'
	icon_state = "camera"
	screen_loc = ui_pai_camera_network
	required_software = "Camera Network"

/atom/movable/screen/pai/camera_network/Click()
	if(!..())
		return
	var/mob/living/silicon/pai/syndicate/pAI = usr
	if(istype(pAI))
		pAI.use_camera_network()
