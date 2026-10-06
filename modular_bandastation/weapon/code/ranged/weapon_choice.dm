/obj/item/choice_beacon/weapon/security_pistol
	name = "sidearm weapon beacon"
	desc = "Одноразовый маяк для доставки оружия по вашему выбору. Пожалуйста, используйте его только в своем офисе."

/obj/item/choice_beacon/weapon/security_pistol/generate_display_names()
	var/static/list/selectable_gun_types = list(
		"GP-9 9x25mm Pistol" = /obj/item/storage/toolbox/guncase/ntcase/pistol/gp9/sec,
		"Disabler Energy Pistol" = /obj/item/gun/energy/disabler,
	)
	return selectable_gun_types

/obj/item/choice_beacon/weapon/blueshield/generate_display_names()
	var/static/list/selectable_gun_types = list(
	//	"GP-93R 9x25mm Autopistol" = /obj/item/storage/toolbox/guncase/ntspecial/pistol/gp93r,
		"EG-14 Energy Pistol" = /obj/item/gun/energy/eg_14,
		"GP-38 .38 cal Pistol" = /obj/item/storage/toolbox/guncase/ntspecial/pistol/gp38,
	)
	return selectable_gun_types

/obj/item/choice_beacon/weapon/hos/generate_display_names()
	var/static/list/selectable_gun_types = list(
		"X-01 MultiPhase Energy Gun" = /obj/item/gun/energy/e_gun/hos,
		"GP-45 .45 cal Pistol" = /obj/item/storage/toolbox/guncase/ntspecial/pistol/gp45,
	)
	return selectable_gun_types

/datum/objective_item/steal/hosgun
	name = "the head of security's personal weapon"
	targetitem = /obj/item/choice_beacon/weapon/hos
	excludefromjob = list(JOB_HEAD_OF_SECURITY)
	altitems = list(/obj/item/gun/ballistic/automatic/pistol/cm70/hos, /obj/item/gun/energy/e_gun/hos)
	item_owner = list(JOB_HEAD_OF_SECURITY)
	exists_on_map = TRUE

/obj/item/choice_beacon/hos/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/choice_beacon/hos)

