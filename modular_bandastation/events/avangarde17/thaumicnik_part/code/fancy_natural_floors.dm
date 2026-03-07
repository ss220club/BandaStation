// MARK: SNOW

/turf/open/misc/snow/avangarde
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_FLOOR_GRASS
	canSmoothWith = SMOOTH_GROUP_FLOOR_GRASS + SMOOTH_GROUP_CLOSED_TURFS
	layer = HIGH_TURF_LAYER
	smoothing_flags = SMOOTH_BITMASK
	icon = 'modular_bandastation/events/avangarde17/icons/snow.dmi'
	icon_state = "smooth_snow"
	base_icon_state = "smooth_snow"

/turf/open/misc/snow/avangarde/Initialize(mapload)
	. = ..()
	if(smoothing_flags)
		var/matrix/translation = new
		translation.Translate(LARGE_TURF_SMOOTHING_X_OFFSET, LARGE_TURF_SMOOTHING_Y_OFFSET)
		transform = translation
		icon = 'icons/turf/floors/smooth_snow.dmi'

	if(is_station_level(z))
		GLOB.station_turfs += src

/turf/open/misc/snow/avangarde/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	. = ..()
	if (!.)
		return

	if(!smoothing_flags)
		return

	underlay_appearance.transform = transform
