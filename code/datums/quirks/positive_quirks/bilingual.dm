/datum/quirk/bilingual
	name = "Bilingual"
	desc = "За эти годы вы освоили еще один язык!"
	icon = FA_ICON_GLOBE
	value = 4
	gain_text = span_notice("Некоторые из слов ваших собеседников точно не являются обычными. Хорошо, что вы научились их понимать.")
	lose_text = span_notice("Кажется, вы забыли свой второй язык.")
	medical_record_text = "Пациент говорит на нескольких языках."
	mail_goodies = list(/obj/item/taperecorder, /obj/item/clothing/head/frenchberet, /obj/item/clothing/mask/fakemoustache/italian)

/datum/quirk_constant_data/bilingual
	associated_typepath = /datum/quirk/bilingual
	customization_options = list(/datum/preference/choiced/language)

/datum/quirk/bilingual/add(client/client_source)
	var/wanted_language = client_source?.prefs.read_preference(/datum/preference/choiced/language)
	var/datum/language/language_type
	if(wanted_language == "Random")
		language_type = pick(GLOB.uncommon_roundstart_languages)
	else
		language_type = GLOB.language_types_by_name[wanted_language]
	if(quirk_holder.has_language(language_type))
		language_type = /datum/language/uncommon
		if(quirk_holder.has_language(language_type))
			to_chat(quirk_holder, span_boldnotice("Вы уже знакомы с данной чертой в своих предпочтениях, поэтому не стали изучать ее."))
			return
		to_chat(quirk_holder, span_boldnotice("Вы уже знакомы с данной чертой в своих предпочтениях, поэтому вместо нее вы выучили старогалактический."))
	quirk_holder.grant_language(language_type, source = LANGUAGE_QUIRK)
