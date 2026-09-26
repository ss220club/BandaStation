/mob/living/silicon/pai/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PaiInterface", name)
		ui.open()
		ui.set_autoupdate(!!card?.syndicate_hardware)

/mob/living/silicon/pai/ui_data(mob/user)
	var/list/data = list()
	data["door_jack"] = hacking_cable
	data["screen_image_interface_icon"] = card.screen_image.interface_icon
	data["installed"] = installed_software
	data["ram"] = ram
	data["chemical_reserve"] = chemical_reserve
	return data

/mob/living/silicon/pai/ui_static_data(mob/user)
	var/list/data = list()
	data["available"] = available_software
	data["directives"] = laws.inherent
	data["emagged"] = emagged
	data["languages"] = languages_granted
	data["master_name"] = master_name
	data["master_dna"] = master_dna
	return data

/mob/living/silicon/pai/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return TRUE
	if(action == "buy")
		buy_software(params["selection"])
		return TRUE
	if(action == "change image")
		change_image()
		return TRUE
	if(action == "check dna")
		check_dna()
		return TRUE
	// Software related ui actions
	if(available_software[action] && !installed_software.Find(action))
		balloon_alert(ui.user, "software unavailable!")
		return FALSE
	switch(action)
		if("Atmospheric Sensor")
			atmos_analyzer.attack_self(src)
			return TRUE
		if("Crew Manifest")
			ai_roster()
			return TRUE
		if("Crew Monitor")
			crew_monitor.attack_self(src) // BANDASTATION REPLACEMENT: GLOB.crewmonitor.show(usr, src)
			return TRUE
		if("Digital Messenger")
			modularInterface?.interact(usr)
			return TRUE
		if("Door Jack")
			// Look to door_jack.dm for implementation
			door_jack(params["mode"])
			return TRUE
		if("Encryption Slot")
			balloon_alert(usr, "radio frequencies [!encrypt_mod ? "enabled" : "disabled"]")
			encrypt_mod = !encrypt_mod
			radio.subspace_transmission = !radio.subspace_transmission
			return TRUE
		if("Host Scan")
			host_scan(params["mode"])
			return TRUE
		if("Internal GPS")
			internal_gps.attack_self(src)
			return TRUE
		if("Music Synthesizer")
			instrument.interact(src)
			return TRUE
		if("Medical HUD")
			toggle_hud(PAI_TOGGLE_MEDICAL_HUD)
			return TRUE
		if("Newscaster")
			newscaster.ui_interact(src)
			return TRUE
		if("Photography Module")
			// Look to pai_camera.dm for implementation
			use_camera(usr, params["mode"])
			return TRUE
		if("Remote Signaler")
			signaler.ui_interact(src)
			return TRUE
		if("Security HUD")
			if(!card?.syndicate_hardware || !("Security HUD" in installed_software))
				return FALSE
			toggle_hud(PAI_TOGGLE_SECURITY_HUD)
			return TRUE
		if("Universal Translator")
			grant_languages()
			ui.send_full_update()
			return TRUE
		if("Thermal Vision")
			thermal_active = !thermal_active
			if(thermal_active)
				ADD_TRAIT(src, TRAIT_THERMAL_VISION, "syndicate_pai_thermal")
			else
				REMOVE_TRAIT(src, TRAIT_THERMAL_VISION, "syndicate_pai_thermal")
			update_sight()
			return TRUE
		if("Night Vision")
			if(card?.syndicate_hardware || !("Night Vision" in installed_software))
				return FALSE
			night_vision_active = !night_vision_active
			if(night_vision_active)
				ADD_TRAIT(src, TRAIT_NIGHT_VISION, "syndicate_pai_night")
			else
				REMOVE_TRAIT(src, TRAIT_NIGHT_VISION, "syndicate_pai_night")
			update_sight()
			return TRUE
		if("Medical Injector")
			return inject_holder(params["reagent"])
		if("Camera Network")
			return use_camera_network()
		if("Security Records")
			if(card?.syndicate_hardware && !QDELETED(records_console))
				records_console.ui_interact(src)
				return TRUE
		if("Syndicate Radio")
			balloon_alert(src, "Syndicate channel: :t")
			return TRUE
	return FALSE

/**
 * Purchases the selected software from the list and deducts their
 * available ram.
 *
 * @param {string} selection - The software to purchase.
 *
 * @returns {boolean} - TRUE if the software was purchased, FALSE otherwise.
 */
/mob/living/silicon/pai/proc/buy_software(selection)
	if(!available_software[selection] || installed_software.Find(selection))
		return FALSE
	if(selection in list("Security HUD", "Thermal Vision", "Medical Injector", "Camera Network", "Remote Machinery", "Security Records", "Syndicate Radio"))
		if(!card?.syndicate_hardware)
			return FALSE
	var/cost = available_software[selection]
	if(ram < cost)
		return FALSE
	installed_software.Add(selection)
	ram -= cost
	var/datum/hud/pai/pAIhud = hud_used
	pAIhud?.update_software_buttons()
	switch(selection)
		if("Atmospheric Sensor")
			atmos_analyzer = new(src)
		if("Digital Messenger")
			create_modularInterface()
		if("Internal GPS")
			internal_gps = new(src)
		if("Music Synthesizer")
			instrument = new(src)
		if("Newscaster")
			newscaster = new(src)
		// BANDASTATION EDIT START
		if("Crew Monitor")
			crew_monitor = new(src)
		// BANDASTATION EDIT END
		if("Photography Module")
			aicamera = new /obj/item/camera/siliconcam/pai_camera(src)
		if("Remote Signaler")
			signaler = new(src)
		if("Camera Network")
			camera_console = new(src, src)
		if("Security Records")
			records_console = new(src)
			records_console.owner_pai = src
		if("Syndicate Radio")
			if(radio.keyslot)
				qdel(radio.keyslot)
			radio.keyslot = new /obj/item/encryptionkey/syndicate(radio)
			radio.keylock = RADIO_KEYSLOT_LOCKED
			radio.subspace_transmission = TRUE
			radio.recalculateChannels()
	return TRUE

/// Inject five units into the carbon carrying the card. The reserve regenerates slowly.
/mob/living/silicon/pai/proc/inject_holder(reagent_name)
	if(!card?.syndicate_hardware || !("Medical Injector" in installed_software))
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
	if(!reagent_type || !holder || !holder.reagents)
		balloon_alert(src, "no valid carrier or reagent")
		return FALSE
	if(chemical_reserve < reserve_cost || !COOLDOWN_FINISHED(src, chemical_injection))
		balloon_alert(src, "injector recharging")
		return FALSE
	chemical_reserve -= reserve_cost
	COOLDOWN_START(src, chemical_injection, 10 SECONDS)
	if(!chemical_recharge_running)
		chemical_recharge_running = TRUE
		addtimer(CALLBACK(src, PROC_REF(replenish_chemicals)), 1 MINUTES)
	holder.reagents.add_reagent(reagent_type, 5)
	SStgui.update_uis(src)
	to_chat(src, span_notice("Injected 5 units of [reagent_name] into [holder]."))
	return TRUE

/mob/living/silicon/pai/proc/replenish_chemicals()
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
	var/mob/living/silicon/pai/owner_pai

/obj/machinery/computer/camera_advanced/syndicate_pai/Initialize(mapload, mob/living/silicon/pai/new_owner)
	. = ..()
	owner_pai = new_owner

/obj/machinery/computer/camera_advanced/syndicate_pai/can_use(mob/living/user)
	return user == owner_pai && !QDELETED(owner_pai?.card) && owner_pai.card.syndicate_hardware && ("Camera Network" in owner_pai.installed_software) && !QDELETED(user?.client)

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
		to_chat(user, span_warning("No available cameras on the network."))
		return
	give_eye_control(user)
	eyeobj.setLoc(camera_location, TRUE)

/mob/living/silicon/pai/proc/use_camera_network()
	if(!card?.syndicate_hardware || !("Camera Network" in installed_software) || QDELETED(camera_console))
		return FALSE
	camera_console.attack_hand(src)
	return TRUE

/// Sight is handled here because the carbon sight proc does not run for silicon pAIs.
/mob/living/silicon/pai/update_sight()
	if(!client)
		return ..()
	lighting_cutoff = initial(lighting_cutoff)
	var/new_sight = initial(sight)
	var/atom/remote_eye = client.eye
	if(remote_eye && remote_eye != src && remote_eye.update_remote_sight(src))
		return ..()
	if(card?.syndicate_hardware && thermal_active && ("Thermal Vision" in installed_software))
		new_sight |= SEE_MOBS
		lighting_cutoff = max(lighting_cutoff, LIGHTING_CUTOFF_MEDIUM)
	if(!card?.syndicate_hardware && night_vision_active && ("Night Vision" in installed_software))
		lighting_cutoff = max(lighting_cutoff, LIGHTING_CUTOFF_HIGH)
	if(SSmapping.level_trait(z, ZTRAIT_NOXRAY))
		new_sight = NONE
	set_sight(new_sight)
	return ..()

/// Remote machinery uses the holoform's sight when deployed, or the card's sight when folded.
/mob/living/silicon/pai/proc/can_control_remote_machine(obj/machinery/target)
	if(!card?.syndicate_hardware || !("Remote Machinery" in installed_software) || !client || QDELETED(target))
		return FALSE
	var/atom/viewpoint = holoform ? src : card
	var/turf/eye_turf = get_turf(viewpoint)
	return eye_turf && target in view(7, eye_turf)

/// Open the APC's native interface from either the folded card or holoform.
/mob/living/silicon/pai/ClickOn(atom/target, params)
	if(istype(target, /obj/machinery/power/apc))
		var/list/modifiers = params2list(params)
		if(!LAZYACCESS(modifiers, SHIFT_CLICK) && !LAZYACCESS(modifiers, CTRL_CLICK) && !LAZYACCESS(modifiers, ALT_CLICK) && !LAZYACCESS(modifiers, RIGHT_CLICK) && !LAZYACCESS(modifiers, MIDDLE_CLICK))
			var/obj/machinery/power/apc/apc = target
			if(can_control_remote_machine(apc) && apc.is_operational && apc.can_use(src))
				active_remote_apc = apc
				apc.ui_interact(src)
				return
	return ..()

/// AI-like shortcuts for visible airlocks; the camera program is independent.
/mob/living/silicon/pai/ShiftClickOn(atom/target)
	if(istype(target, /obj/machinery/door/airlock))
		control_remote_door(target, "open")
		return
	return ..()

/mob/living/silicon/pai/CtrlClickOn(atom/target)
	if(istype(target, /obj/machinery/door/airlock))
		control_remote_door(target, "bolts")
		return
	return ..()

/mob/living/silicon/pai/CtrlShiftClickOn(atom/target)
	if(istype(target, /obj/machinery/door/airlock))
		control_remote_door(target, "emergency")
		return
	return ..()

/mob/living/silicon/pai/AltClickSecondaryOn(atom/target)
	if(istype(target, /obj/machinery/door/airlock))
		control_remote_door(target, "shock")
		return
	return ..()

/mob/living/silicon/pai/proc/control_remote_door(obj/machinery/door/airlock/airlock, mode)
	if(!COOLDOWN_FINISHED(src, remote_door_action))
		balloon_alert(src, "door control recharging")
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
	COOLDOWN_START(src, remote_door_action, 7 SECONDS)
	log_game("[key_name(src)] remotely used [mode] on [airlock] at [AREACOORD(airlock)] via Syndicate pAI")
	return TRUE

/// Airlock operations reuse the normal wire, power and bolt checks.
/obj/machinery/door/airlock/user_allowed(mob/user)
	if(istype(user, /mob/living/silicon/pai))
		var/mob/living/silicon/pai/pai_user = user
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
	var/mob/living/silicon/pai/owner_pai

/obj/machinery/computer/records/security/syndicate_pai/ui_state(mob/user)
	return GLOB.deep_inventory_state

/obj/machinery/computer/records/security/syndicate_pai/ui_status(mob/user, datum/ui_state/state)
	if(user == owner_pai && owner_pai?.card?.syndicate_hardware && ("Security Records" in owner_pai.installed_software))
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
	if(user != owner_pai || QDELETED(owner_pai) || !owner_pai.card?.syndicate_hardware || !("Security Records" in owner_pai.installed_software))
		return
	authenticated = TRUE
	return ..()

/obj/machinery/computer/records/security/syndicate_pai/ui_act(action, list/params, datum/tgui/ui)
	if(ui?.user != owner_pai || QDELETED(owner_pai) || !("Security Records" in owner_pai.installed_software))
		return FALSE
	if(action in list("delete_record", "expunge_record", "purge_records"))
		return FALSE
	if(action == "login" || action == "logout")
		return TRUE
	authenticated = TRUE
	return ..()

/obj/machinery/computer/records/security/syndicate_pai/has_armory_access(mob/user)
	if(user == owner_pai)
		return TRUE
	return ..()

/**
 * Changes the image displayed on the pAI.
 *
 * @returns {boolean} - TRUE if the image was changed, FALSE otherwise.
 */
/mob/living/silicon/pai/proc/change_image()
	var/list/possible_choices = list()
	for(var/datum/pai_screen_image/screen_option as anything in subtypesof(/datum/pai_screen_image))
		var/datum/radial_menu_choice/choice = new
		choice.name = screen_option.name
		choice.image = image(icon = screen_option.icon, icon_state = screen_option.icon_state)
		possible_choices[screen_option] += choice
	var/atom/anchor = get_atom_on_turf(src)
	var/new_image = show_radial_menu(src, anchor, possible_choices, custom_check = CALLBACK(src, PROC_REF(check_menu), anchor), radius = 40, require_near = TRUE)
	if(isnull(new_image))
		return FALSE
	card.screen_image = new_image
	card.update_appearance()
	return TRUE

/**
 * Supporting proc for the pAI to prick it's master's hand
 * or... whatever. It must be held in order to work
 * Gives the owner a popup if they want to get the jab.
 *
 * @returns {boolean} - TRUE if a sample was taken, FALSE otherwise.
 */
/mob/living/silicon/pai/proc/check_dna()
	if(emagged) // Their master DNA signature is scrambled anyway
		to_chat(src, span_syndradio("You are not at liberty to do this! All agents are clandestine."))
		return FALSE
	var/mob/living/carbon/holder = get_holder()
	if(!isnull(holder))
		balloon_alert(src, "not being carried")
		return FALSE
	balloon_alert(src, "requesting dna sample")
	if(tgui_alert(holder, "[src] is requesting a DNA sample from you. Will you allow it to confirm your identity?", "Checking DNA", list("Yes", "No")) != "Yes")
		balloon_alert(src, "dna sample refused!")
		return FALSE
	holder.visible_message(span_notice("[holder] presses [holder.p_their()] thumb against [src]."), span_notice("You press your thumb against [src]."), span_notice("[src] makes a sharp clicking sound as it extracts DNA material from [holder]."))
	if(!holder.has_dna())
		balloon_alert(src, "no dna detected!")
		return FALSE
	to_chat(src, span_bolddanger(("[holder]'s UE string: [holder.dna.unique_enzymes]")))
	to_chat(src, span_notice("DNA [holder.dna.unique_enzymes == master_dna ? "matches" : "does not match"] our stored Master's DNA."))
	return TRUE

/**
 * Grant all languages to the current pAI.
 *
 * @returns {boolean} - TRUE if the languages were granted, FALSE otherwise.
 */
/mob/living/silicon/pai/proc/grant_languages()
	if(languages_granted)
		return FALSE
	grant_all_languages(source = LANGUAGE_SOFTWARE)
	languages_granted = TRUE
	return TRUE

/**
 * Host scan supporting proc
 *
 * Allows the pAI to scan its host's health vitals
 * using an integrated health analyzer.
 *
 * @returns {boolean} - TRUE if the scan was successful, FALSE otherwise.
 */
/mob/living/silicon/pai/proc/host_scan(mode)
	switch(mode)
		if(PAI_SCAN_TARGET)
			var/mob/living/carbon/target = get_holder()
			if(isnull(target))
				balloon_alert(src, "not being carried!")
				return FALSE
			healthscan(src, target)
			return TRUE

		if(PAI_SCAN_MASTER)
			var/mob/living/resolved_master = find_master()
			if(isnull(resolved_master))
				balloon_alert(src, "no master detected!")
				return FALSE
			if(!is_valid_z_level(get_turf(src), get_turf(resolved_master)))
				balloon_alert(src, "master out of range!")
				return FALSE
			healthscan(src, resolved_master)
			return TRUE

	stack_trace("Invalid mode passed to host scan: [mode || "null"]")
	return FALSE

/// Huds from PAI software
#define PAI_HUD_TRAIT "pai_hud"

/**
 * Proc that toggles any active huds based on the option.
 *
 * @param {string} mode - The hud to toggle.
 */
/mob/living/silicon/pai/proc/toggle_hud(mode)
	if(isnull(mode))
		return FALSE
	if(mode == PAI_TOGGLE_MEDICAL_HUD)
		if(HAS_TRAIT_FROM(src, TRAIT_MEDICAL_HUD, PAI_HUD_TRAIT))
			REMOVE_TRAIT(src, TRAIT_MEDICAL_HUD, PAI_HUD_TRAIT)
		else
			ADD_TRAIT(src, TRAIT_MEDICAL_HUD, PAI_HUD_TRAIT)
	if(mode == PAI_TOGGLE_SECURITY_HUD)
		if(HAS_TRAIT_FROM(src, TRAIT_SECURITY_HUD, PAI_HUD_TRAIT))
			REMOVE_TRAIT(src, TRAIT_SECURITY_HUD, PAI_HUD_TRAIT)
		else
			ADD_TRAIT(src, TRAIT_SECURITY_HUD, PAI_HUD_TRAIT)
	return TRUE

#undef PAI_HUD_TRAIT
