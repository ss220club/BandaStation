/obj/item/stack/tile/elevated
	name = "elevated floor tile"
	singular_name = "elevated floor tile"
	turf_type = /turf/open/floor/elevated
	merge_type = /obj/item/stack/tile/elevated
	icon = 'modular_bandastation/liquids/icons/obj/items/tiles.dmi'
	icon_state = "elevated"

/obj/item/stack/tile/lowered
	name = "lowered floor tile"
	singular_name = "lowered floor tile"
	turf_type = /turf/open/floor/lowered
	merge_type = /obj/item/stack/tile/lowered
	icon = 'modular_bandastation/liquids/icons/obj/items/tiles.dmi'
	icon_state = "lowered"

/obj/item/stack/tile/lowered/iron
	name = "lowered floor tile"
	singular_name = "lowered floor tile"
	turf_type = /turf/open/floor/lowered
	merge_type = /obj/item/stack/tile/lowered
	icon = 'modular_bandastation/liquids/icons/obj/items/tiles.dmi'
	icon_state = "lowered"

/obj/item/stack/tile/lowered/iron/pool
	name = "pool floor tile"
	singular_name = "pool floor tile"
	turf_type = /turf/open/floor/lowered
	merge_type = /obj/item/stack/tile/lowered
	icon = 'modular_bandastation/liquids/icons/obj/items/tiles.dmi'
	icon_state = "pool"

/turf/open/floor/elevated
	name = "elevated floor"
	floor_tile = /obj/item/stack/tile/elevated
	icon = 'modular_bandastation/liquids/icons/turf/elevated_iron.dmi'
	icon_state = "elevated_plasteel-0"
	base_icon_state = "elevated_plasteel-0"
	liquid_height = 30
	turf_height = 30

/turf/open/floor/elevated/rust_heretic_act()
	return

/turf/open/floor/lowered
	name = "lowered floor"
	floor_tile = /obj/item/stack/tile/lowered
	icon = 'modular_bandastation/liquids/icons/turf/lowered_iron.dmi'
	icon_state = "lowered_plasteel-0"
	base_icon_state = "lowered_plasteel-0"
	liquid_height = -30
	turf_height = -30

/turf/open/floor/lowered/rust_heretic_act()
	return
