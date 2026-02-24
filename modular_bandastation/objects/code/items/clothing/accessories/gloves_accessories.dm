/obj/item/clothing/accessory/gloves_accessory
	name = "gloves accessory"
	abstract_type = /obj/item/clothing/accessory/gloves_accessory
	desc = "An accessory that can be worn on gloves."
	icon = 'modular_bandastation/objects/icons/obj/items/rings.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/inhands/rings-hands.dmi'
	slot_flags = ITEM_SLOT_GLOVES
	body_parts_covered = 0
	icon_state = "ringgold"
	worn_icon_state = "gring"

// MARK: rings
/obj/item/clothing/accessory/gloves_accessory/ring
	icon = 'modular_bandastation/objects/icons/obj/items/rings.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/inhands/rings-hands.dmi'
	name = "gold ring"
	desc = "Маленькое золотое колечко, размером, чтобы надеть на палец."
	gender = NEUTER
	w_class = WEIGHT_CLASS_TINY
	icon_state = "ringgold"
	inhand_icon_state = null
	worn_icon_state = "gring"
	strip_delay = 4 SECONDS
	clothing_traits = list(TRAIT_FINGERPRINT_PASSTHROUGH)
	resistance_flags = FIRE_PROOF
	siemens_coefficient = 1

/obj/item/clothing/accessory/gloves_accessory/ring/diamond
	name = "diamond ring"
	desc = "Дорогое кольцо, украшенное бриллиантом. В разных культурах такие кольца использовались для ухаживания уже тысячелетия."
	icon_state = "ringdiamond"
	worn_icon_state = "dring"

/obj/item/clothing/accessory/gloves_accessory/ring/silver
	name = "silver ring"
	desc = "Маленькое серебряное колечко, размером, чтобы надеть на палец."
	icon_state = "ringsilver"
	worn_icon_state = "sring"
