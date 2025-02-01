/datum/quirk/prosthetic_limb
	name = "Prosthetic Limb"
	desc = "В результате несчастного случая вы потеряли одну из своих конечностей. Из-за этого у вас установлен дешевый протез!"
	icon = "tg-prosthetic-leg"
	value = -3
	hardcore_value = 3
	quirk_flags = QUIRK_HUMAN_ONLY | QUIRK_CHANGES_APPEARANCE
	mail_goodies = list(/obj/item/weldingtool/mini, /obj/item/stack/cable_coil/five)
	/// The slot to replace, in string form
	var/slot_string = "limb"
	/// the original limb from before the prosthetic was applied
	var/obj/item/bodypart/old_limb

/datum/quirk_constant_data/prosthetic_limb
	associated_typepath = /datum/quirk/prosthetic_limb
	customization_options = list(/datum/preference/choiced/prosthetic)

/datum/quirk/prosthetic_limb/add_unique(client/client_source)
	var/limb_type = GLOB.prosthetic_limb_choice[client_source?.prefs?.read_preference(/datum/preference/choiced/prosthetic)]
	if(isnull(limb_type))  //Client gone or they chose a random prosthetic
		limb_type = GLOB.prosthetic_limb_choice[pick(GLOB.prosthetic_limb_choice)]

	var/mob/living/carbon/human/human_holder = quirk_holder
	var/obj/item/bodypart/surplus = new limb_type()
	slot_string = "[surplus.ru_plaintext_zone[NOMINATIVE] || surplus.plaintext_zone]"

	medical_record_text = "Пациент имеет бюджетный протез вместо \"[slot_string]\"."
	old_limb = human_holder.return_and_replace_bodypart(surplus, special = TRUE)

/datum/quirk/prosthetic_limb/post_add()
	to_chat(quirk_holder, span_bolddanger("Ваша конечность, [slot_string], была заменена дешевым протезом. Он почти не обладает мышечной силой и делает вас еще более нездоровым. Кроме того, \
	для ремонта необходимо использовать сварочный аппарат и кабели, а не швы и регенеративные сетки."))

/datum/quirk/prosthetic_limb/remove()
	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder.del_and_replace_bodypart(old_limb, special = TRUE)
	old_limb = null
