/// Calculates an estimated price for a surgery based on complexity
/// Arguments:
/// * surgery_type - a /datum/surgery subtype
/proc/calc_surgery_price(surgery_type)
	var/datum/surgery/T = surgery_type
	if(!surgery_type)
		return 0

	var/price = SURGERY_PRICE_BASE

	// Steps count contribution
	var/list/steps = initial(T.steps)
	var/steps_count = islist(steps) ? length(steps) : 0
	price += (steps_count * SURGERY_PRICE_PER_STEP)

	// Advanced surgeries cost extra
	if(initial(T.requires_tech))
		price += SURGERY_PRICE_ADVANCED_BONUS

	// Location difficulty bonus
	var/list/locs = initial(T.possible_locs)
	if(islist(locs))
		if(BODY_ZONE_HEAD in locs)
			price += SURGERY_PRICE_HEAD_BONUS
		else if(BODY_ZONE_CHEST in locs)
			price += SURGERY_PRICE_CHEST_BONUS

	// Targeting a specific wound tends to be harder
	if(initial(T.targetable_wound))
		price += SURGERY_PRICE_WOUND_BONUS

	// Clamp and round
	price = round(max(SURGERY_PRICE_MIN, min(price, SURGERY_PRICE_MAX)))
	return price

