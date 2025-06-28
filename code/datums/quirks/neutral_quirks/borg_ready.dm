/datum/quirk/item_quirk/borg_ready
	name = "Cyborg Pre-screened dogtag"
	desc = "Получите предварительное одобрение на участие в экспериментальной программе 'Киборг' с жетоном, который позволит врачам знать об этом."
	icon = FA_ICON_TAG
	value = 0
	gain_text = span_notice("Вы слышите отдаленное эхо гудков и жужжания.")
	lose_text = span_danger("Отдаленные гудки затихают.")
	medical_record_text = "Пациент стал зарегистрированным донором мозга для исследований в области робототехники."

/datum/quirk/item_quirk/borg_ready/add_unique(client/client_source)
	if(is_banned_from(client_source.ckey, JOB_CYBORG))
		return FALSE
	var/obj/item/clothing/accessory/dogtag/borg_ready/borgtag = new(get_turf(quirk_holder))
	give_item_to_holder(borgtag, list(LOCATION_BACKPACK, LOCATION_HANDS))
