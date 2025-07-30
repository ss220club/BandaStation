// MARK: Logotypes
// Note: Used to be non turf-decals so we can pixel-shift them
/obj/effect/decal/syndie_logo
	name = "Syndicate logo"
	icon = 'modular_bandastation/objects/icons/obj/effects/logos.dmi'
	icon_state = "logo1"
	layer = MID_TURF_LAYER // Above other decals

/obj/effect/decal/nt_logo
	name = "Nanotrasen logo"
	icon = 'modular_bandastation/objects/icons/obj/effects/logos.dmi'
	icon_state = "ntlogo_sec"
	alpha = 180
	layer = MID_TURF_LAYER // Above other decals

/obj/effect/decal/nt_logo/alt
	icon_state = "ntlogo"

/obj/effect/decal/solgov_logo
	name = "SolGov logo"
	icon = 'modular_bandastation/objects/icons/obj/effects/logos.dmi'
	icon_state = "sol_logo1"
	layer = MID_TURF_LAYER // Above other decals

// MARK: Wood Sidings
#define DEFINE_WOOD_SIDING(wood_name, wood_color) \
	/obj/effect/turf_decal/siding/wood/##wood_name { \
		color = wood_color; \
	} \
	/obj/effect/turf_decal/siding/wood/##wood_name/corner { \
		icon_state = "siding_wood_corner"; \
	} \
	/obj/effect/turf_decal/siding/wood/##wood_name/end { \
		icon_state = "siding_wood_end"; \
	}

DEFINE_WOOD_SIDING(oak, "#644526")
DEFINE_WOOD_SIDING(birch, "#FFECB3")
DEFINE_WOOD_SIDING(cherry, "#643412")
DEFINE_WOOD_SIDING(amaranth, "#6B2E3E")
DEFINE_WOOD_SIDING(ebonite, "#363649")
DEFINE_WOOD_SIDING(ivory, "#D78575")
DEFINE_WOOD_SIDING(guaiacum, "#5C6250")

#undef DEFINE_WOOD_SIDING
