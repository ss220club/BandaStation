/// Common emergency ejection behavior for both halves and the combined mech.
/obj/vehicle/sealed/mecha/golden_gardren_base
	abstract_type = /obj/vehicle/sealed/mecha/golden_gardren_base

/obj/vehicle/sealed/mecha/golden_gardren_base/Initialize(mapload, built_manually)
	. = ..()
	AddComponent(/datum/component/golden_gardren_ejection)

/obj/vehicle/sealed/mecha/golden_gardren_base/remove_occupant(mob/driver)
	. = ..()
	var/datum/component/golden_gardren_ejection/ejection = GetComponent(/datum/component/golden_gardren_ejection)
	ejection?.clear_landing_choice(driver)

/obj/vehicle/sealed/mecha/golden_gardren_base/on_mouseclick(mob/user, atom/target, list/modifiers)
	var/datum/component/golden_gardren_ejection/ejection = GetComponent(/datum/component/golden_gardren_ejection)
	if(ejection?.handle_click(user, target))
		return COMSIG_MOB_CANCEL_CLICKON
	return ..()

/obj/vehicle/sealed/mecha/golden_gardren_base/atom_destruction()
	var/datum/component/golden_gardren_ejection/ejection = GetComponent(/datum/component/golden_gardren_ejection)
	ejection?.eject()
	return ..()
