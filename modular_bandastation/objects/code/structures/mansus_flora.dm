/obj/structure/flora/tree/jungle/mansus
	desc = "Раньше здесь росли британские хвойные породы... Чтож, время неуклонно идёт."
	icon = 'modular_bandastation/objects/icons/obj/structures/mansus_trees.dmi'
	icon_state = "tree1"
	pixel_x = -48
	pixel_y = -20

/obj/structure/flora/tree/jungle/mansus/style_2
	icon_state = "tree2"

/obj/structure/flora/tree/jungle/mansus/style_3
	icon_state = "tree3"

/obj/structure/flora/tree/jungle/mansus/style_4
	icon_state = "tree4"

/obj/structure/flora/tree/jungle/mansus/style_5
	icon_state = "tree5"

/obj/structure/flora/tree/jungle/mansus/style_6
	icon_state = "tree6"

/obj/structure/flora/tree/jungle/mansus/style_random/Initialize(mapload)
	. = ..()
	icon_state = "tree[rand(1, 6)]"
	update_appearance()
