// MARK: CentCom
/obj/item/clothing/gloves/combat/centcom
	name = "fleet officer's gloves"
	desc = "Солидные перчатки офицеров Центрального Командования Нанотрейзен."
	icon = 'modular_bandastation/aesthetics/clothing/centcom/icons/obj/clothing/gloves/gloves.dmi'
	worn_icon = 'modular_bandastation/aesthetics/clothing/centcom/icons/mob/clothing/gloves/gloves.dmi'
	lefthand_file = 'modular_bandastation/aesthetics/clothing/centcom/icons/inhands/clothing/gloves_lefthand.dmi'
	righthand_file = 'modular_bandastation/aesthetics/clothing/centcom/icons/inhands/clothing/gloves_righthand.dmi'
	icon_state = "centcom"
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | FREEZE_PROOF | UNACIDABLE | ACID_PROOF

/obj/item/clothing/gloves/combat/centcom/diplomat
	desc = "Изящные и солидные перчатки офицеров Центрального Командования Нанотрейзен."
	icon_state = "centcom_diplomat"

// MARK: Detective (forensics) gloves
/obj/item/clothing/gloves/color/black/forensics
	name = "forensics gloves"
	desc = "Эти высокотехнологичные перчатки не оставляют никаких следов на предметах, к которым прикасаются. Идеально подходят для того, чтобы оставить место преступления нетронутым... как до, так и после преступления."
	icon = 'modular_bandastation/objects/icons/obj/clothing/gloves.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/gloves.dmi'
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/gloves_lefthand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/gloves_righthand.dmi'
	icon_state = "forensics"
	clothing_flags = FIBERLESS_GLOVES

/obj/item/clothing/gloves/examine_tags(mob/user)
	. = ..()
	if(clothing_flags & FIBERLESS_GLOVES)
		.["безволоконная"] = "Не оставляет волокна."

/obj/item/clothing/gloves/fingerless/biker_gloves
	name = "biker gloves"
	desc = "Обычные черные перчатки с черепом."
	icon = 'modular_bandastation/objects/icons/obj/clothing/gloves.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/gloves.dmi'
	icon_state = "bike_gloves"

// MARK: Etamin ind.
/obj/item/clothing/gloves/etamin_gloves
	name = "Gold On Black gloves"
	desc = "Качественные перчатки с золотой вставкой 999 пробы."
	icon = 'modular_bandastation/objects/icons/obj/clothing/gloves.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/gloves.dmi'
	icon_state = "ei_gloves"

// MARK: rings
/obj/item/clothing/gloves/ring
	icon = 'modular_bandastation/objects/icons/obj/items/rings.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/inhands/rings-hands.dmi'
	name = "gold ring"
	desc = "Маленькое золотое колечко, размером, чтобы надеть на палец."
	gender = NEUTER
	w_class = WEIGHT_CLASS_TINY
	icon_state = "ringgold"
	inhand_icon_state = null
	worn_icon_state = "gring"
	body_parts_covered = 0
	strip_delay = 4 SECONDS
	clothing_traits = list(TRAIT_FINGERPRINT_PASSTHROUGH)

/obj/item/clothing/gloves/ring/diamond
	name = "diamond ring"
	desc = "Дорогое кольцо, украшенное бриллиантом. В разных культурах такие кольца использовались для ухаживания уже тысячелетия."
	icon_state = "ringdiamond"
	worn_icon_state = "dring"

/obj/item/clothing/gloves/ring/silver
	name = "silver ring"
	desc = "Маленькое серебряное колечко, размером, чтобы надеть на палец."
	icon_state = "ringsilver"
	worn_icon_state = "sring"
