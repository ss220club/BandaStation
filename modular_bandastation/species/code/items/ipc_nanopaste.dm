/// A consumable alternative to core repair for stopping IPC irradiation, inspired by Paradise's nanopaste.
/obj/item/stack/nanopaste
	name = "nanopaste"
	singular_name = "nanite dose"
	desc = "Тюбик нанопасты для удаления радиоактивного загрязнения с КПБ. Обработка занимает пять секунд. Повреждения мозга и корпуса требуют отдельного ремонта."
	gender = FEMALE
	icon = 'icons/obj/medical/surgery_tools.dmi'
	icon_state = "bone-gel"
	inhand_icon_state = "bone-gel"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	color = COLOR_CYAN
	amount = 6
	max_amount = 6
	w_class = WEIGHT_CLASS_TINY
	full_w_class = WEIGHT_CLASS_TINY
	item_flags = NOBLUDGEON|SKIP_FANTASY_ON_SPAWN
	mats_per_unit = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT / 4, /datum/material/glass = SHEET_MATERIAL_AMOUNT / 4)

/obj/item/stack/nanopaste/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!ishuman(interacting_with))
		return NONE
	var/mob/living/carbon/human/target = interacting_with
	if(!is_species(target, /datum/species/ipc))
		target.balloon_alert(user, "только для КПБ!")
		return ITEM_INTERACT_BLOCKING
	if(!get_amount())
		balloon_alert(user, "тюбик пуст!")
		return ITEM_INTERACT_BLOCKING
	if(!target.GetComponent(/datum/component/irradiated))
		target.balloon_alert(user, "облучения нет")
		return ITEM_INTERACT_BLOCKING
	if(!user.is_holding(src) || !user.Adjacent(target) || DOING_INTERACTION_WITH_TARGET(user, target))
		return ITEM_INTERACT_BLOCKING
	target.balloon_alert(user, "деконтаминация...")
	if(!do_after(user, 5 SECONDS, target))
		return ITEM_INTERACT_BLOCKING
	if(QDELETED(src) || QDELETED(user) || QDELETED(target) || !is_species(target, /datum/species/ipc) || !user.is_holding(src) || !user.Adjacent(target))
		return ITEM_INTERACT_BLOCKING
	var/datum/component/irradiated/irradiation = target.GetComponent(/datum/component/irradiated)
	if(!irradiation || !use(1))
		return ITEM_INTERACT_BLOCKING
	qdel(irradiation)
	target.balloon_alert(user, "облучение снято")
	return ITEM_INTERACT_SUCCESS
