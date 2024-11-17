// MARK: Windows
/obj/structure/window
	layer = ABOVE_WINDOW_LAYER
	/// Used to define what file the edging sprite is contained within
	var/edge_overlay_file
	/// Tracks the edging appearence sprite
	var/mutable_appearance/edge_overlay

/obj/structure/window/update_overlays(updates=ALL)
	. = ..()
	if(!edge_overlay_file)
		return

	edge_overlay = mutable_appearance(edge_overlay_file, "[smoothing_junction]", layer + 0.1, appearance_flags = RESET_COLOR)
	. += edge_overlay

/obj/structure/window/fulltile
	icon = 'modular_bandastation/aesthetics/windows/icons/window.dmi'
	edge_overlay_file = 'modular_bandastation/aesthetics/windows/icons/window_edges.dmi'
	icon_state = "window-0"
	base_icon_state = "window"
	canSmoothWith = SMOOTH_GROUP_AIRLOCK + SMOOTH_GROUP_WINDOW_FULLTILE + SMOOTH_GROUP_WALLS
	color = "#99BBFF"

/obj/structure/window/reinforced/fulltile
	icon = 'modular_bandastation/aesthetics/windows/icons/reinforced_window.dmi'
	edge_overlay_file = 'modular_bandastation/aesthetics/windows/icons/reinforced_window_edges.dmi'
	icon_state = "reinforced_window-0"
	base_icon_state = "reinforced_window"
	canSmoothWith = SMOOTH_GROUP_AIRLOCK + SMOOTH_GROUP_WINDOW_FULLTILE + SMOOTH_GROUP_WALLS
	color = "#99BBFF"

/obj/structure/window/reinforced/tinted/fulltile
	icon = 'modular_bandastation/aesthetics/windows/icons/reinforced_window.dmi'
	edge_overlay_file = 'modular_bandastation/aesthetics/windows/icons/reinforced_window_edges.dmi'
	icon_state = "reinforced_window-0"
	base_icon_state = "reinforced_window"
	canSmoothWith = SMOOTH_GROUP_AIRLOCK + SMOOTH_GROUP_WINDOW_FULLTILE + SMOOTH_GROUP_WALLS
	flags_1 = UNPAINTABLE_1
	color = "#5A6E82"

/obj/structure/window/plasma/fulltile
	icon = 'modular_bandastation/aesthetics/windows/icons/window.dmi'
	edge_overlay_file = 'modular_bandastation/aesthetics/windows/icons/window_edges.dmi'
	icon_state = "window-0"
	base_icon_state = "window"
	canSmoothWith = SMOOTH_GROUP_AIRLOCK + SMOOTH_GROUP_WINDOW_FULLTILE + SMOOTH_GROUP_WALLS
	flags_1 = UNPAINTABLE_1
	color = "#C800FF"

/obj/structure/window/reinforced/plasma/fulltile
	icon = 'modular_bandastation/aesthetics/windows/icons/reinforced_window.dmi'
	edge_overlay_file = 'modular_bandastation/aesthetics/windows/icons/reinforced_window_edges.dmi'
	icon_state = "reinforced_window-0"
	base_icon_state = "reinforced_window"
	canSmoothWith = SMOOTH_GROUP_AIRLOCK + SMOOTH_GROUP_WINDOW_FULLTILE + SMOOTH_GROUP_WALLS
	flags_1 = UNPAINTABLE_1
	color = "#C800FF"

/obj/structure/window/reinforced/shuttle
	canSmoothWith = SMOOTH_GROUP_SHUTTLE_PARTS + SMOOTH_GROUP_AIRLOCK + SMOOTH_GROUP_WINDOW_FULLTILE_SHUTTLE + SMOOTH_GROUP_TITANIUM_WALLS

// MARK: Spawners
/obj/effect/spawner/structure/window
	icon = 'modular_bandastation/aesthetics/windows/icons/spawners.dmi'

// Override to original
/obj/effect/spawner/structure/window/bronze
	icon = 'icons/obj/structures_spawners.dmi'

/obj/effect/spawner/structure/window/hollow
	icon = 'icons/obj/structures_spawners.dmi'

/obj/effect/spawner/structure/window/ice
	icon = 'icons/obj/structures_spawners.dmi'

/obj/effect/spawner/structure/window/survival_pod
	icon = 'icons/obj/structures_spawners.dmi'

/obj/effect/spawner/structure/window/reinforced/shuttle
	icon = 'icons/obj/structures_spawners.dmi'

/obj/effect/spawner/structure/window/reinforced/plasma/plastitanium
	icon = 'icons/obj/structures_spawners.dmi'
