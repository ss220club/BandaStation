/// Cultural knowledge uses the languages and name generators already present in this build.
/// State affiliation and current residence do not prove that a person learned a language.
/proc/get_sierra_background_culture_profile(culture_id)
	var/static/list/profiles
	if(isnull(profiles))
		profiles = list()
		var/list/catalog = get_sierra_background_catalog()
		var/list/cultures = catalog["culture"]
		for(var/id in cultures)
			var/list/culture = cultures[id]
			var/list/profile = list(
				"languages" = list(/datum/language/common),
				"name_language" = /datum/language/common,
				"name_label" = "Человеческие имена",
			)
			// The existing Spinwarder datum is overridden as Neorussian in this build.
			if(culture["faction"] == "CUSP")
				var/list/languages = profile["languages"]
				languages += /datum/language/spinwarder
				profile["name_language"] = /datum/language/spinwarder
				profile["name_label"] = "Неорусские имена"
			else if(culture["faction"] == "Elysium")
				var/list/languages = profile["languages"]
				languages += /datum/language/gutter
				profile["name_language"] = /datum/language/gutter
				profile["name_profile"] = "elysian"
				profile["name_label"] = "Элизианские имена"
			profiles[id] = profile

		var/list/native_upbringing = list(
			"skrell_imperial" = /datum/language/qurvolious,
			"adomai_upbringing" = /datum/language/siiktajr,
			"altam_upbringing" = /datum/language/canilunzt,
			"moges_upbringing" = /datum/language/draconic,
			"zuviyen_upbringing" = /datum/language/moffic,
			"felinid_community" = /datum/language/nekomimetic,
			"nian_caravan" = /datum/language/moffic,
			"nian_zuviyen" = /datum/language/moffic,
			"nian_mixed" = /datum/language/moffic,
			"nian_colonies" = /datum/language/moffic,
			"nian_diaspora" = /datum/language/moffic,
			"ethereal_sprout" = /datum/language/voltaic,
			"ethereal_human_influenced" = /datum/language/voltaic,
		)
		for(var/id in native_upbringing)
			var/list/profile = profiles[id]
			var/language_type = native_upbringing[id]
			var/list/languages = profile["languages"]
			languages |= language_type
			profile["name_language"] = language_type
			profile["name_label"] = "Имена культуры [cultures[id]["name"]]"

		// The approved Plasmaman article says their old language was lost.
		// Chemical names remain a naming tradition; they do not grant knowledge of Calcic.
		var/list/plasmaman_profile = profiles["plasmaman_technocrat"]
		plasmaman_profile["name_language"] = /datum/language/calcic
		plasmaman_profile["name_label"] = "Химические названия с номером"

		// These cultures have no corresponding naming language in the current build.
		// Preserve the existing species generator rather than inventing another people's names.
		for(var/id in list("other", "urlum_upbringing", "mauna_b_upbringing", "aurum_upbringing", "limneya_upbringing", "inka_upbringing"))
			var/list/profile = profiles[id]
			profile["name_language"] = null
			profile["name_label"] = null
	return profiles[culture_id] || profiles["other"]

/// Display exactly the cultural grants; species, quirks and other sources stay independent.
/proc/get_sierra_background_language_names(culture_id)
	var/list/profile = get_sierra_background_culture_profile(culture_id)
	var/list/names = list()
	for(var/language_type in profile["languages"])
		var/datum/language/language = GLOB.language_datum_instances[language_type]
		names += language.name
	return names
