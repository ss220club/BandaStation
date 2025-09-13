// Adds insurance selection verb for ID cards

/obj/item/card/id/verb/change_insurance()
	set name = "Change Insurance"
	set desc = "Choose your insurance tier for payday deductions."
	set category = "Object"
	set src in usr

	if(!isliving(usr))
		return
	var/mob/living/L = usr
	set_insurance(L)

/// Opens a small prompt to set the desired insurance tier for the card's linked bank account.
/obj/item/card/id/proc/set_insurance(mob/living/user)
	if(loc != user)
		to_chat(user, span_warning("Hold the ID card to change insurance."))
		return FALSE
	if(!registered_account || IS_DEPARTMENTAL_ACCOUNT(registered_account))
		to_chat(user, span_warning("This card is not linked to a personal account."))
		return FALSE

	var/list/choices = list("None" = INSURANCE_NONE, "Standard" = INSURANCE_STANDARD, "Premium" = INSURANCE_PREMIUM)
	var/pick = tgui_input_list(user, "Select your insurance tier", "Insurance", choices)
	if(isnull(pick))
		return FALSE
	var/selected_tier = choices[pick]
	registered_account.insurance_desired = selected_tier

	// Try to update matching crew record's desired tier and payer id immediately
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/datum/record/crew/rec = find_record(H.real_name)
		if(rec)
			rec.insurance_desired = selected_tier
			rec.insurance_payer_account_id = isnull(registered_account.account_id) ? 0 : registered_account.account_id

	to_chat(user, span_notice("Insurance set to [INSURANCE_TIER_TO_TEXT(selected_tier)]."))
	return TRUE
