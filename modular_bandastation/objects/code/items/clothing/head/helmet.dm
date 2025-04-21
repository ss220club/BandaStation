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
