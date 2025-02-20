#define COLOR_WOOD "#864A2D"
#define COLOR_OAK "#644526"
#define COLOR_BIRCH "#FFECB3"
#define COLOR_CHERRY "#643412"
#define COLOR_AMARANTH "#6B2E3E"
#define COLOR_EBONITE "#363649"
#define COLOR_PINK_IVORY "#D78575"
#define COLOR_GUAIACUM "#5C6250"

/// Automatically generates all subtypes for a wooden floor with tiles.
#define WOODEN_FLOOR_HELPER(path, tile)\
##path/oak {\
	color = COLOR_OAK;\
	floor_tile = ##tile/oak;\
}\
##tile/oak {\
	name = "oak floor tiles";\
	singular_name = "oak floor tile";\
	color = COLOR_OAK;\
	turf_type = ##path/oak;\
	merge_type = ##tile/oak;\
}\
##path/birch {\
	color = COLOR_BIRCH;\
	floor_tile = ##tile/birch;\
}\
##tile/birch {\
	name = "birch floor tiles";\
	singular_name = "birch floor tile";\
	color = COLOR_BIRCH;\
	turf_type = ##path/birch;\
	merge_type = ##tile/birch;\
}\
##path/cherry {\
	color = COLOR_CHERRY;\
	floor_tile = ##tile/cherry;\
}\
##tile/cherry {\
	name = "cherry floor tiles";\
	singular_name = "cherry floor tile";\
	color = COLOR_CHERRY;\
	turf_type = ##path/cherry;\
	merge_type = ##tile/cherry;\
}\
##path/amaranth {\
	color = COLOR_AMARANTH;\
	floor_tile = ##tile/amaranth;\
}\
##tile/amaranth {\
	name = "amaranth floor tiles";\
	singular_name = "amaranth floor tile";\
	color = COLOR_AMARANTH;\
	turf_type = ##path/amaranth;\
	merge_type = ##tile/amaranth;\
}\
##path/ebonite {\
	color = COLOR_EBONITE;\
	floor_tile = ##tile/ebonite;\
}\
##tile/ebonite {\
	name = "ebonite floor tiles";\
	singular_name = "ebonite floor tile";\
	color = COLOR_EBONITE;\
	turf_type = ##path/ebonite;\
	merge_type = ##tile/ebonite;\
}\
##path/pink_ivory {\
	color = COLOR_PINK_IVORY;\
	floor_tile = ##tile/pink_ivory;\
}\
##tile/pink_ivory {\
	name = "pink ivory floor tiles";\
	singular_name = "pink ivory floor tile";\
	color = COLOR_PINK_IVORY;\
	turf_type = ##path/pink_ivory;\
	merge_type = ##tile/pink_ivory;\
}\
##path/guaiacum {\
	color = COLOR_GUAIACUM;\
	floor_tile = ##tile/guaiacum;\
}\
##tile/guaiacum {\
	name = "guaiacum floor tiles";\
	singular_name = "guaiacum floor tile";\
	color = COLOR_GUAIACUM;\
	turf_type = ##path/guaiacum;\
	merge_type = ##tile/guaiacum;\
}\

// Wood
/obj/item/stack/tile/wood
	icon = 'modular_bandastation/objects/icons/turf/wooden/tiles.dmi'
	icon_state = "tile-wood"
	color = COLOR_WOOD

/turf/open/floor/wood
	icon = 'modular_bandastation/objects/icons/turf/wooden/wooden.dmi'
	icon_state = "wood"
	damaged_dmi = 'modular_bandastation/objects/icons/turf/wooden/wooden.dmi'
	color = COLOR_WOOD
	appearance_flags = RESET_COLOR

/turf/open/floor/wood/broken_states()
	return list("wood-broken", "wood-broken2", "wood-broken3", "wood-broken4", "wood-broken5", "wood-broken6", "wood-broken7")

/turf/open/floor/wood/Initialize(mapload)
	. = ..()
	add_atom_colour(color, FIXED_COLOUR_PRIORITY)

WOODEN_FLOOR_HELPER(/turf/open/floor/wood, /obj/item/stack/tile/wood)

// Fancy Wood
/obj/item/stack/tile/wood/large
	name = "fancy wood floor tiles"
	singular_name = "fancy wood floor tile"
	icon_state = "tile-wood-fancy"
	color = COLOR_WOOD
	turf_type = /turf/open/floor/wood/large
	merge_type = /obj/item/stack/tile/wood/large

/turf/open/floor/wood/large
	icon_state = "wood_fancy"
	color = COLOR_WOOD
	floor_tile = /obj/item/stack/tile/wood/large

/turf/open/floor/wood/large/broken_states()
	return list("wood_fancy-broken", "wood_fancy-broken2", "wood_fancy-broken3")

WOODEN_FLOOR_HELPER(/turf/open/floor/wood/large, /obj/item/stack/tile/wood/large)

// Parquet
/obj/item/stack/tile/wood/parquet
	name = "parquet floor tiles"
	singular_name = "parquet floor tile"
	icon_state = "tile-wood-parquet"
	color = COLOR_WOOD
	turf_type = /turf/open/floor/wood/parquet
	merge_type = /obj/item/stack/tile/wood/parquet

/turf/open/floor/wood/parquet
	icon_state = "wood_parquet"
	color = COLOR_WOOD
	floor_tile = /obj/item/stack/tile/wood/parquet

/turf/open/floor/wood/parquet/broken_states()
	return list("wood_parquet-broken", "wood_parquet-broken2", "wood_parquet-broken3", "wood_parquet-broken4", "wood_parquet-broken5", "wood_parquet-broken6", "wood_parquet-broken7")

WOODEN_FLOOR_HELPER(/turf/open/floor/wood/parquet, /obj/item/stack/tile/wood/parquet)

// Tiled Parquet
/obj/item/stack/tile/wood/tile
	name = "tiled parquet floor tiles"
	singular_name = "tiled parquet floor tile"
	icon_state = "tile-wood-tile"
	color = COLOR_WOOD
	turf_type = /turf/open/floor/wood/tile
	merge_type = /obj/item/stack/tile/wood/tile

/turf/open/floor/wood/tile
	icon_state = "wood_tile"
	color = COLOR_WOOD
	floor_tile = /obj/item/stack/tile/wood/tile

/turf/open/floor/wood/tile/broken_states()
	return list("wood_tile-broken", "wood_tile-broken2", "wood_tile-broken3")

WOODEN_FLOOR_HELPER(/turf/open/floor/wood/tile, /obj/item/stack/tile/wood/tile)

#undef COLOR_WOOD
#undef COLOR_OAK
#undef COLOR_BIRCH
#undef COLOR_CHERRY
#undef COLOR_AMARANTH
#undef COLOR_EBONITE
#undef COLOR_PINK_IVORY
#undef COLOR_GUAIACUM

#undef WOODEN_FLOOR_HELPER
