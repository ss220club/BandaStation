// toggle_night_vision.dm

#define NV_OFF 0
#define NV_LOW 1
#define NV_MID 2
#define NV_HI  3

/datum/action/cooldown/shadowling/toggle_night_vision
	name = "Ночное зрение"
	desc = "Переключить режим ночного зрения (вычисляется на текущих глазах)."
	button_icon_state = "night_vision"
	cooldown_time = 0 SECONDS

	/// 0=off, 1/2/3 – уровни
	var/nv_level = NV_OFF

	/// пресеты отсечек по аналогии с night_vision глазами
	var/list/cut_low  = list(20, 10, 40)
	var/list/cut_mid  = list(35, 18, 65)
	var/list/cut_high = list(50, 25, 90)

/datum/action/cooldown/shadowling/toggle_night_vision/DoEffect(mob/living/carbon/human/H, atom/_)
	if(!istype(H))
		return FALSE

	var/obj/item/organ/eyes/E = H.get_organ_slot(ORGAN_SLOT_EYES)
	if(!istype(E))
		H.balloon_alert(H, "нужны глаза")
		return FALSE

	switch(nv_level)
		if(NV_OFF)
			E.color_cutoffs = cut_low.Copy()
			nv_level = NV_LOW
		if(NV_LOW)
			E.color_cutoffs = cut_mid.Copy()
			nv_level = NV_MID
		if(NV_MID)
			E.color_cutoffs = cut_high.Copy()
			nv_level = NV_HI
		else
			E.color_cutoffs = null
			nv_level = NV_OFF

	H.update_sight()
	enable()
	return TRUE

#undef NV_OFF
#undef NV_LOW
#undef NV_MID
#undef NV_HI
