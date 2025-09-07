/// Character preference: desired medical insurance tier at round start.
/datum/preference/choiced/insurance_tier
    category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
    can_randomize = FALSE
    savefile_identifier = PREFERENCE_CHARACTER
    savefile_key = "insurance_tier"

/datum/preference/choiced/insurance_tier/init_possible_values()
    // Stored as strings to play nice with TGUI dropdowns
    return list("none", "standard", "premium")

/datum/preference/choiced/insurance_tier/create_default_value()
    return "none"

/datum/preference/choiced/insurance_tier/compile_constant_data()
    var/list/data = ..()

    // Display names for dropdown
    var/list/display_names = list()
    display_names["none"] = "Нет"
    display_names["standard"] = "Стандартная"
    display_names["premium"] = "Премиальная"

    data[CHOICED_PREFERENCE_DISPLAY_NAMES] = display_names
    return data

/datum/preference/choiced/insurance_tier/apply_to_human(mob/living/carbon/human/target, value)
    // No direct visual effect on the mob; handled on job equip via bank account
    return

