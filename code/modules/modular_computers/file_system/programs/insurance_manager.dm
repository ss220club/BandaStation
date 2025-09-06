// NTOS Insurance Manager - allows selecting insurance tier via PDA/console

/datum/computer_file/program/nt_insurance
	filename = "ntinsurance"
	filedesc = "Insurance Manager"
	downloader_category = PROGRAM_CATEGORY_DEVICE
	program_open_overlay = "generic"
	extended_desc = "Manage your payroll insurance tier and view current status."
	size = 2
	tgui_id = "NtosInsurance"
	program_icon = "shield-heart"
	can_run_on_flags = PROGRAM_ALL
	circuit_comp_type = /obj/item/circuit_component/mod_program/nt_insurance
	///Reference to the currently logged in user's bank account.
	var/datum/bank_account/current_user

/datum/computer_file/program/nt_insurance/ui_interact(mob/user, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, tgui_id, filedesc)
		ui.open()

/datum/computer_file/program/nt_insurance/ui_data(mob/user)
	var/list/data = list()

	current_user = computer.stored_id?.registered_account || null
	if(!current_user)
		data["name"] = null
		return data

	data["name"] = current_user.account_holder
	// pull crew record by account holder name
	var/datum/record/crew/rec = find_record(current_user.account_holder)
	data["insurance_current"] = rec ? INSURANCE_TIER_TO_TEXT(rec.insurance_current) : INSURANCE_TIER_TO_TEXT(INSURANCE_NONE)
	data["insurance_desired"] = INSURANCE_TIER_TO_TEXT(current_user.insurance_desired)
	data["payer_account_id"] = current_user.account_id
	data["is_dept"] = IS_DEPARTMENTAL_ACCOUNT(current_user)
	return data


/datum/computer_file/program/nt_insurance/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(action == "set_tier")
		// Refresh current user from inserted ID and validate
		var/datum/bank_account/ba = computer.stored_id?.registered_account || null
		if(!ba)
			return TRUE
		if(IS_DEPARTMENTAL_ACCOUNT(ba))
			return TRUE
		// Parse, round and clamp tier safely
		var/raw_tier = text2num(params["tier"]) // may be null
		if(isnull(raw_tier))
			return TRUE
		var/tier = clamp(round(raw_tier), INSURANCE_NONE, INSURANCE_PREMIUM)
		current_user = ba
		current_user.insurance_desired = tier
		// Try to update matching record's desired/payer
		var/datum/record/crew/rec = find_record(current_user.account_holder)
		if(rec)
			rec.insurance_desired = tier
			rec.insurance_payer_account_id = isnull(current_user.account_id) ? 0 : current_user.account_id
		SStgui.update_uis(src)
		return TRUE

// Circuit integration to let signal graphs change tier
/obj/item/circuit_component/mod_program/nt_insurance
	associated_program = /datum/computer_file/program/nt_insurance
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL
	var/datum/port/input/tier_port
	var/datum/port/output/changed

/obj/item/circuit_component/mod_program/nt_insurance/populate_ports()
	. = ..()
	tier_port = add_input_port("Tier (0-2)", PORT_TYPE_NUMBER)
	changed = add_output_port("Changed", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/mod_program/nt_insurance/input_received(datum/port/port)
	var/datum/computer_file/program/nt_insurance/program = associated_program
	if(!program)
		return
	if(port == tier_port)
		program.ui_act("set_tier", list("tier" = round(tier_port.value)))
		changed.set_output(COMPONENT_SIGNAL)
