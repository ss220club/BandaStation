/datum/design/rcd_loaded
	name = "Rapid Construction Device (RCD)"

/datum/outfit/job/atmos
	skillchips = list(/obj/item/skillchip/job/engineer)

/obj/item/construction/rcd/proc/check_engineer_skillchip(mob/user, alert = TRUE)
	if(!HAS_TRAIT(user, TRAIT_KNOW_ENGI_WIRES) && !issilicon(user) && !(item_flags & DROPDEL))
		if(alert)
			balloon_alert(user, "нет скиллчипа!")
		return FALSE

	return TRUE

/obj/item/construction/rcd/examine(mob/user)
	. = ..()
	. += "Для полноценного использования требуется скиллчип инженера."
