/// Simple manager for medical bills that require patient confirmation

GLOBAL_DATUM_INIT(medical_billing, /datum/medical_billing_manager, new)

/datum/medical_billing_manager
	/// Autoincrement bill id
	var/next_id = 1
	/// id -> bill datum
	var/list/pending_by_id = list()
	/// patient_account_id (string) -> list of bill ids
	var/list/pending_by_patient = list()

/datum/medical_billing_manager/proc/create_bill(datum/bank_account/patient, amount, reason, issuer_name, issuer_account_id,patient_name)
	if(!patient || amount <= 0)
		return 0
	var/id = next_id++
	var/datum/medical_bill/B = new
	B.id = id
	B.patient_account_id = isnull(patient.account_id) ? 0 : patient.account_id
	B.amount = round(amount)
	B.reason = reason
	B.issuer = issuer_name
	B.issuer_account_id = issuer_account_id
	B.patient_name = patient_name
	B.created_at = world.time
	pending_by_id["[id]"] = B
	var/key = "[B.patient_account_id]"
	LAZYADDASSOCLIST(pending_by_patient, key, id)
	// Update insurance manager windows for patient and issuer only
	refresh_insurance_uis_for(patient.account_id, issuer_account_id)
	// Notify patient if present on station
	for(var/mob/living/carbon/human/H in GLOB.mob_living_list)
		if(H.account_id && H.account_id == patient.account_id)
			to_chat(H, span_notice("Вам выставлен медицинский счёт на [B.amount] кр. [issuer_name ? "(от [issuer_name])" : ""] — [reason || "Медицинские услуги"]. Откройте Insurance Manager для подтверждения."))
			break
	return id


/datum/medical_billing_manager/proc/list_for(patient_account_id)
	var/list/out = list()
	var/key = "[patient_account_id]"
	for(var/id in pending_by_patient[key] || list())
		var/datum/medical_bill/B = pending_by_id["[id]"]
		if(B)
			out += list(B)
	return out

/datum/medical_billing_manager/proc/accept_bill(id, datum/bank_account/patient)
	var/key = "[patient?.account_id || 0]"
	var/datum/medical_bill/B = pending_by_id["[id]"]
	if(!B)
		// Bill was already processed; ensure orphan id is cleaned for this patient
		if(pending_by_patient[key])
			pending_by_patient[key] -= id
			ASSOC_UNSETEMPTY(pending_by_patient, key)
		refresh_insurance_uis_for(patient?.account_id, null)
		return FALSE
	if(!patient || B.patient_account_id != (patient.account_id || 0))
		return FALSE
	if(is_expired(B))
		remove_bill(B)
		return FALSE
	var/datum/bank_account/department/med = SSeconomy.get_dep_account(ACCOUNT_MED)
	if(!med)
		return FALSE
	if(!med.transfer_money(patient, B.amount, B.reason || "Nanotrasen: Medical Bill"))
		return FALSE
	// remove bill
	remove_bill(B)
	return TRUE


/datum/medical_billing_manager/proc/decline_bill(id, datum/bank_account/patient)
	var/key = "[patient?.account_id || 0]"
	var/datum/medical_bill/B = pending_by_id["[id]"]
	if(!B)
		// Bill was already processed; ensure orphan id is cleaned for this patient
		if(pending_by_patient[key])
			pending_by_patient[key] -= id
			ASSOC_UNSETEMPTY(pending_by_patient, key)
		refresh_insurance_uis_for(patient?.account_id, null)
		return FALSE
	if(!patient || B.patient_account_id != (patient.account_id || 0))
		return FALSE
	remove_bill(B)
	return TRUE

/// Returns list of bills issued by a specific issuer account id

/datum/medical_billing_manager/proc/list_for_issuer(issuer_account_id)
	var/list/out = list()
	for(var/id in pending_by_id)
		var/datum/medical_bill/B = pending_by_id[id]
		if(B && B.issuer_account_id == issuer_account_id)
			out += list(B)
	return out

/// Cancels bill by the issuer
/datum/medical_billing_manager/proc/cancel_by_issuer(id, datum/bank_account/issuer)
	var/datum/medical_bill/B = pending_by_id["[id]"]
	if(!B || !issuer || B.issuer_account_id != (issuer.account_id || 0))
		return FALSE
	remove_bill(B)
	return TRUE

/datum/medical_billing_manager/proc/remove_bill(datum/medical_bill/B)
    if(!B) return
    var/id = B.id
    var/patient_id = B.patient_account_id
    var/issuer_id = B.issuer_account_id
    pending_by_id -= "[id]"
    var/key = "[B.patient_account_id]"
    if(pending_by_patient[key])
        pending_by_patient[key] -= id
        ASSOC_UNSETEMPTY(pending_by_patient, key)
    qdel(B)
    refresh_insurance_uis_for(patient_id, issuer_id)

/datum/medical_billing_manager/proc/is_expired(datum/medical_bill/B)
	if(!B) return TRUE
	return (world.time - B.created_at) >= INSURANCE_BILL_EXPIRE

/// Updates NTOS Insurance Manager windows for specific account ids
/datum/medical_billing_manager/proc/refresh_insurance_uis_for(patient_account_id, issuer_account_id)
    var/list/targets = list()
    if(!isnull(patient_account_id))
        LAZYADD(targets, "[patient_account_id]")
    if(!isnull(issuer_account_id))
        LAZYADD(targets, "[issuer_account_id]")
    if(!length(targets))
        return
    for(var/datum/computer_file/program/nt_insurance/P in world)
        var/datum/bank_account/acc = P?.computer?.stored_id?.registered_account
        if(!acc)
            continue
        if("[acc.account_id]" in targets)
            SStgui.update_uis(P)

/// Represents a pending medical bill awaiting patient confirmation
/datum/medical_bill
	var/id
	var/patient_account_id
	var/amount
	var/reason
	var/issuer
	var/issuer_account_id
	var/patient_name
	var/created_at
