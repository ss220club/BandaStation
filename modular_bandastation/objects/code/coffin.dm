/obj/structure/closet/coffin/corn
	name = "cornffin"
	desc = "Мы потеряли его. Он скукурузился."
	icon = 'modular_bandastation/objects/icons/closets.dmi'
	icon_state = "coffin_corn"
	icon_opened = "coffin_corn_open"
	open_door_sprite = null
	resistance_flags = FLAMMABLE
	max_integrity = 300
	material_drop = /obj/item/food/snacks/grown/corn
	material_drop_amount = 10

// Выращивание кукурузогроба
/obj/item/seeds/corn/cornffin
	name = "pack of cornffin seeds"
	desc = "Эти семена вырастут и скукурузятся.."
	icon_state = "seed-corn"
	species = "corn"
	plantname = "Cornffin Stalks"
	product = /obj/structure/closet/coffin/corn


/obj/item/seeds/corn/Initialize(mapload)
	. = ..()
	mutatelist |= list(/obj/item/seeds/corn/cornffin)
