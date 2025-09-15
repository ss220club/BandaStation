/obj/structure/statue/gold/galactic_map
	name = "galactic map"
	desc = "Политическая карта галактики."
	icon = 'modular_bandastation/galactic_map/icons/galactic_map.dmi'
	icon_state = "galactic_map_statue"
	anchored = TRUE

/obj/structure/statue/gold/galactic_map/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GalacticMap")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/area_spawn/galactic_map
	target_areas = list(/area/station/service/library)
	desired_atom = /obj/structure/statue/gold/galactic_map
	mode = AREA_SPAWN_MODE_HUG_WALL
