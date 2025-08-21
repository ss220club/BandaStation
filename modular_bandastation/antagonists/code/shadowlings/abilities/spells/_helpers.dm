// Глобальный список ульев (можно держать ровно один на раунд)
var/global/list/shadowling_hives = list()

/proc/get_local_brightness(atom/A)
	var/turf/T = get_turf(A)
	if(!T) return 1
	return T.get_lumcount()

/proc/shadow_dark_ok(atom/A)
	return get_local_brightness(A) < L_DIM

// «Фаза/инкорпореальность» — без фантазии: твой флаг + плотность
/proc/is_incorporeal(mob/living/L)
	if(!L)
		return FALSE
	if(L.has_status_effect(/datum/status_effect/shadow/phase))
		return TRUE
	if(!L.density)
		return TRUE
	return FALSE

// Является ли мобом-тенелингом (пока без антаг-датумов)
/proc/is_shadowling_mob(mob/living/carbon/human/H)
	if(!istype(H)) return FALSE
	if(istype(H.dna.species, /datum/species/shadow/shadowling)) return TRUE
	return FALSE

// Является ли траллом: проверяем орган в нашем слоте
/proc/is_shadow_thrall(mob/living/carbon/human/H)
	if(!istype(H)) return FALSE
	if(H.get_organ_slot(ORGAN_SLOT_BRAIN_THRALL))
		return TRUE
	return FALSE

// Майндшилд — максимально безопасная проверка для «ванильного» TG
/proc/shadowling_has_mindshield(mob/living/carbon/human/H)
	if(!istype(H)) return FALSE
	// В большинстве тг: implants — список
	var/list/impls = H.implants
	if(islist(impls) && (locate(/obj/item/implant/mindshield) in impls))
		return TRUE
	// запасной путь: ищем имплант во внутренних контейнерах
	for(var/obj/item/implant/I in H.contents)
		if(istype(I, /obj/item/implant/mindshield))
			return TRUE
	return FALSE

/proc/ensure_language_holder(mob/living/carbon/human/H)
	if(!H.language_holder)
		H.language_holder = new /datum/language_holder(H)
	return H.language_holder
