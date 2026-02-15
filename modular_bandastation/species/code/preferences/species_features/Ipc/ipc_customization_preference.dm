// ============================================
// PREFERENCE: IPC CUSTOMIZATION
// ============================================
// Хранит все настройки IPC в одной ассоциативной списке:
//   chassis_brand: "morpheus" / "etamin" / "hef" / etc
//   brain_type: "positronic" / "mmi" / "borg"
//   hef_head: "morpheus" (если chassis == hef)
//   hef_chest: "etamin" (если chassis == hef)
//   и т.д.
// ============================================

/datum/preference/ipc_customization
	savefile_key = "ipc_customization"
	savefile_identifier = PREFERENCE_CHARACTER
	priority = PREFERENCE_PRIORITY_BODYPARTS
	can_randomize = FALSE

/datum/preference/ipc_customization/is_valid(value)
	if(!islist(value))
		return FALSE
	// Можно добавить дополнительную валидацию здесь
	return TRUE

/datum/preference/ipc_customization/apply_to_human(mob/living/carbon/human/target, value)
	to_chat(target, span_boldwarning("DEBUG PREF: apply_to_human ВЫЗВАН!"))

	if(!islist(value))
		to_chat(target, span_boldwarning("DEBUG PREF: value не список!"))
		return

	// FIX: Проверяем что target это живой human с dna и species
	if(!istype(target))
		to_chat(target, span_boldwarning("DEBUG PREF: target не human!"))
		return
	if(!target.dna)
		to_chat(target, span_boldwarning("DEBUG PREF: нет target.dna!"))
		return
	if(!istype(target.dna.species, /datum/species/ipc))
		to_chat(target, span_boldwarning("DEBUG PREF: species не IPC! species=[target.dna.species.type]"))
		return

	var/list/customization = value
	var/datum/species/ipc/S = target.dna.species

	to_chat(target, span_boldnotice("DEBUG PREF: Все проверки пройдены! Применяем customization..."))

	// Применяем тип мозга
	var/brain_type = customization["brain_type"] || "positronic"
	to_chat(target, span_notice("DEBUG PREF: brain_type = [brain_type]"))
	apply_ipc_brain_type_direct(target, brain_type)

	// Применяем chassis brand
	var/chassis_brand = customization["chassis_brand"] || "unbranded"
	to_chat(target, span_notice("DEBUG PREF: chassis_brand = [chassis_brand]"))
	S.ipc_brand_key = chassis_brand

	if(chassis_brand == "hef")
		// HEF: применяем поштучные выборы
		to_chat(target, span_notice("DEBUG PREF: Применяем HEF визуал"))
		S.hef_head = customization["hef_head"] || "unbranded"
		S.hef_chest = customization["hef_chest"] || "unbranded"
		S.hef_l_arm = customization["hef_l_arm"] || "unbranded"
		S.hef_r_arm = customization["hef_r_arm"] || "unbranded"
		S.hef_l_leg = customization["hef_l_leg"] || "unbranded"
		S.hef_r_leg = customization["hef_r_leg"] || "unbranded"
		apply_ipc_hef_visual(target, S)
	else
		// Обычный бренд: единый визуал + эффекты
		to_chat(target, span_notice("DEBUG PREF: Вызываем apply_ipc_brand([chassis_brand])"))
		apply_ipc_brand(target, chassis_brand)
		to_chat(target, span_notice("DEBUG PREF: Вызываем apply_ipc_brand_effects([chassis_brand])"))
		apply_ipc_brand_effects(target, chassis_brand)

	to_chat(target, span_notice("DEBUG PREF: Вызываем update_body()"))
	target.update_body()

/datum/preference/ipc_customization/deserialize(input, datum/preferences/preferences)
	if(!islist(input))
		return create_default_value()
	return input

/datum/preference/ipc_customization/serialize(input)
	if(!islist(input))
		return create_default_value()
	return input

/datum/preference/ipc_customization/create_default_value()
	return list(
		"chassis_brand" = "unbranded",
		"brain_type" = "positronic",
		"hef_head" = "unbranded",
		"hef_chest" = "unbranded",
		"hef_l_arm" = "unbranded",
		"hef_r_arm" = "unbranded",
		"hef_l_leg" = "unbranded",
		"hef_r_leg" = "unbranded",
	)

// ============================================
// HELPER PROC: Применение типа мозга
// ============================================
/proc/apply_ipc_brain_type_direct(mob/living/carbon/human/target, brain_type)
	// Проверяем что target это реальный human (не new_player)
	if(!istype(target, /mob/living/carbon/human))
		return FALSE
	// Проверяем что есть dna
	if(!target.dna)
		return FALSE
	// Проверяем что species IPC
	if(!istype(target.dna.species, /datum/species/ipc))
		return FALSE

	var/obj/item/organ/brain/current_brain = target.get_organ_slot(ORGAN_SLOT_BRAIN)
	var/obj/item/organ/brain/new_brain = null

	switch(brain_type)
		if("positronic")
			if(istype(current_brain, /obj/item/organ/brain/positronic) && !istype(current_brain, /obj/item/organ/brain/positronic/mmi) && !istype(current_brain, /obj/item/organ/brain/positronic/borg))
				return TRUE  // Уже установлен правильный тип
			new_brain = new /obj/item/organ/brain/positronic()
		if("mmi")
			if(istype(current_brain, /obj/item/organ/brain/positronic/mmi))
				return TRUE
			new_brain = new /obj/item/organ/brain/positronic/mmi()
		if("borg")
			if(istype(current_brain, /obj/item/organ/brain/positronic/borg))
				return TRUE
			new_brain = new /obj/item/organ/brain/positronic/borg()
		else
			return FALSE

	// Заменяем мозг
	if(current_brain)
		current_brain.Remove(target)
		qdel(current_brain)
	if(new_brain)
		new_brain.Insert(target)
	return TRUE
