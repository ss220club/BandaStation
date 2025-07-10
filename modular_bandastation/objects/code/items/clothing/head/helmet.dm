/obj/item/clothing/head/helmet/biker_helmet
	name = "biker helmet"
	desc = "Крутой шлем."
	icon = 'modular_bandastation/objects/icons/obj/clothing/head/helmet.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/head/helmet.dmi'
	icon_state = "bike_helmet"
	base_icon_state = "bike_helmet"
	inhand_icon_state = "bike_helmet"
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_left_hand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_right_hand.dmi'
	actions_types = list(/datum/action/item_action/toggle_helmet)
	flags_cover = HEADCOVERSEYES|EARS_COVERED
	dog_fashion = null
	var/on = TRUE

/obj/item/clothing/head/helmet/biker_helmet/replica
	desc = "Крутой шлем. На вид хлипкий..."

/obj/item/clothing/head/helmet/biker_helmet/ui_action_click(mob/user, toggle_helmet)
	helm_toggle(user)

/obj/item/clothing/head/helmet/biker_helmet/update_icon_state()
	icon_state = "[base_icon_state][on ? null : "_up" ]"
	if (on)
		flags_cover &= ~HEADCOVERSEYES
	else
		flags_cover |= HEADCOVERSEYES
	return ..()

/obj/item/clothing/head/helmet/biker_helmet/proc/helm_toggle(mob/user)
	on = !on
	update_icon_state()
	update_appearance()

/obj/item/clothing/head/helmet/space/hardsuit/security
	icon = 'modular_bandastation/objects/icons/obj/clothing/head/helmet.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/head/helmet.dmi'
	icon_state = "hardsuit0-sec"

/obj/item/clothing/head/helmet/ntci_helmet
	name = "tactical helmet"
	desc = "Облегчённый военный шлем с проверенным временем дизайном. Использование современных технологий обеспечивает защиту от осколков и винтовочных калибров."
	icon = 'modular_bandastation/objects/icons/obj/clothing/head/helmet.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/head/helmet.dmi'
	icon_state = "ntci_helmet"
	base_icon_state = "ntci_helmet"
	armor_type = /datum/armor/pmc
	clothing_flags = STACKABLE_HELMET_EXEMPT
	resistance_flags = FIRE_PROOF | ACID_PROOF
	hair_mask = /datum/hair_mask/standard_hat_middle
	flags_inv = null
	dog_fashion = null
	sound_vary = TRUE
	equip_sound = 'sound/items/handling/helmet/helmet_equip1.ogg'
	pickup_sound = 'sound/items/handling/helmet/helmet_pickup1.ogg'
	drop_sound = 'sound/items/handling/helmet/helmet_drop1.ogg'

/obj/item/clothing/head/helmet/ntci_helmet/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/seclite_attachable, light_icon_state = "flight")

// MARK: USSP
/obj/item/clothing/head/helmet/marine/ussp_officer_kaska
	name = "komandir kaska"
	icon = 'modular_bandastation/objects/icons/obj/clothing/head/helmet.dmi'
	icon_state = "ussp_command"
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/head/helmet.dmi'
	base_icon_state = "ussp_command"

/obj/item/clothing/head/helmet/marine/security/ussp_kaska
	name = "heavy kaska"
	icon = 'modular_bandastation/objects/icons/obj/clothing/head/helmet.dmi'
	icon_state = "ussp_security"
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/head/helmet.dmi'
	base_icon_state = "ussp_security"

/obj/item/clothing/head/helmet/marine/security/ussp_kaska/medic
	icon_state = "ussp_medic"
	base_icon_state = "ussp_medic"

/obj/item/clothing/head/helmet/toggleable/riot/ussp_riot
	name = "OMON helmet"
	icon = 'modular_bandastation/objects/icons/obj/clothing/head/helmet.dmi'
	icon_state = "ussp_riot"
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/head/helmet.dmi'
