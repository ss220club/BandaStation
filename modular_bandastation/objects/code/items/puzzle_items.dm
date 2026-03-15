//Ritual cup key

/obj/item/ritual_cup
    name = "Ritual cup"
    desc = "Древняя ритуальная чаша, со следами свежей крови"
    icon = 'modular_bandastation/objects/icons/obj/items/puzzle_items.dmi'
    icon_state = "hereticcup"
	w_class = WEIGHT_CLASS_NORMAL
	force = 10
	throwforce = 8
	amount_per_transfer_from_this = 15
	custom_materials = list(/datum/material/silver=SMALL_MATERIAL_AMOUNT*8)
	volume = 100

//Ritual heart

/obj/item/heretic_heart
    name = "Cursed Heart"
    desc = "Человеческое сердце, источающее отвратительно-привлекательный сладковатый запах"
    icon = 'modular_bandastation/objects/icons/obj/items/puzzle_items.dmi'
    icon_state = "hereticheart"
	w_class = WEIGHT_CLASS_SMALL
