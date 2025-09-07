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
	/// Last billing status message to show in UI
	var/billing_last_msg
	/// Last billing success flag
	var/billing_last_ok = FALSE

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
	// Populate crew manifest names for dropdown selection
	var/list/crew_names = list()
	for(var/datum/record/crew/C in GLOB.manifest.general)
		if(C?.name)
			crew_names += C.name
	data["crew_names"] = crew_names
	// medical staff flag: can issue bills
	data["is_med_staff"] = (current_user?.account_job?.paycheck_department == ACCOUNT_MED)
	// billing feedback
	if(billing_last_msg)
		data["bill_last_msg"] = billing_last_msg
		data["bill_last_ok"] = billing_last_ok

	// Pending bills for current user to accept/decline
	var/list/pending = list()
	for(var/datum/medical_bill/B as anything in GLOB.medical_billing.list_for(current_user.account_id))
		pending += list(list(
			"id" = B.id,
			"amount" = B.amount,
			"reason" = B.reason,
			"issuer" = B.issuer,
			"created_at" = B.created_at,
			"expired" = GLOB.medical_billing.is_expired(B),
		))
	if(length(pending))
		data["pending_bills"] = pending

	// Issued bills for medical staff (allow cancel)
	if(data["is_med_staff"]) // already computed above
		var/list/issued = list()
		for(var/datum/medical_bill/IB as anything in GLOB.medical_billing.list_for_issuer(current_user.account_id))
			issued += list(list(
				"id" = IB.id,
				"amount" = IB.amount,
				"reason" = IB.reason,
				"patient" = IB.patient_name,
				"created_at" = IB.created_at,
				"expired" = GLOB.medical_billing.is_expired(IB),
			))
		if(length(issued))
			data["issued_bills"] = issued

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

	if(action == "bill_patient")
		// Only medical staff can bill
		var/datum/bank_account/issuer = computer.stored_id?.registered_account || null
		if(!issuer || issuer?.account_job?.paycheck_department != ACCOUNT_MED)
			return TRUE
		var/raw_name = params["name"]
		var/amount = max(0, round(text2num(params["amount"])))
		var/reason = params["reason"]
		billing_last_msg = null
		billing_last_ok = FALSE
		if(!istext(raw_name) || !length(trim(raw_name)))
			billing_last_msg = "Некорректное имя пациента"
			SStgui.update_uis(src)
			return TRUE
		if(amount <= 0)
			billing_last_msg = "Сумма должна быть больше 0"
			SStgui.update_uis(src)
			return TRUE
		var/datum/record/crew/target_rec = find_record(raw_name)
		if(!target_rec)
			billing_last_msg = "Запись экипажа не найдена"
			SStgui.update_uis(src)
			return TRUE
		// Resolve patient's bank account: prefer payer_account_id, fallback by name scan
		var/datum/bank_account/patient_acc
		if(target_rec.insurance_payer_account_id > 0)
			patient_acc = SSeconomy.bank_accounts_by_id["[target_rec.insurance_payer_account_id]"]
		if(!patient_acc)
			for(var/id in SSeconomy.bank_accounts_by_id)
				var/datum/bank_account/B = SSeconomy.bank_accounts_by_id[id]
				if(B?.account_holder == raw_name)
					patient_acc = B; break
		if(!patient_acc)
			billing_last_msg = "Банковский счёт пациента не найден"
			SStgui.update_uis(src)
			return TRUE
		// Create pending bill, to be accepted by the patient later
		var/id = GLOB.medical_billing.create_bill(patient_acc, amount, reason, issuer.account_holder, issuer.account_id, raw_name)
		if(id)
			billing_last_ok = TRUE
			billing_last_msg = "Счёт на [amount] кр. отправлен [raw_name] для подтверждения"
		else
			billing_last_msg = "Не удалось создать счёт"
		SStgui.update_uis(src)
		return TRUE

	if(action == "accept_bill")
		var/datum/bank_account/pa = computer.stored_id?.registered_account || null
		if(!pa || IS_DEPARTMENTAL_ACCOUNT(pa))
			return TRUE
		var/id = round(text2num(params["id"]))
		billing_last_msg = null
		billing_last_ok = FALSE
		if(id <= 0)
			return TRUE
		if(GLOB.medical_billing.accept_bill(id, pa))
			billing_last_ok = TRUE
			billing_last_msg = "Счёт оплачен"
		else
			billing_last_msg = "Оплата не выполнена"
		SStgui.update_uis(src)
		return TRUE

	if(action == "decline_bill")
		var/datum/bank_account/pa = computer.stored_id?.registered_account || null
		if(!pa || IS_DEPARTMENTAL_ACCOUNT(pa))
			return TRUE
		var/id = round(text2num(params["id"]))
		billing_last_msg = null
		billing_last_ok = FALSE
		if(id <= 0)
			return TRUE
		if(GLOB.medical_billing.decline_bill(id, pa))
			billing_last_ok = TRUE
			billing_last_msg = "Счёт отклонён"
		else
			billing_last_msg = "Не удалось отклонить"
		SStgui.update_uis(src)
		return TRUE

	if(action == "cancel_bill")
		// cancel issued bill by medic
		var/datum/bank_account/iss = computer.stored_id?.registered_account || null
		if(!iss || iss?.account_job?.paycheck_department != ACCOUNT_MED)
			return TRUE
		var/id = round(text2num(params["id"]))
		billing_last_msg = null
		billing_last_ok = FALSE
		if(id <= 0)
			return TRUE
		if(GLOB.medical_billing.cancel_by_issuer(id, iss))
			billing_last_ok = TRUE
			billing_last_msg = "Счёт удалён"
		else
			billing_last_msg = "Не удалось удалить счёт"
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
