/obj/structure/statue/gold/new_sydney_map
	name = "map new sydney"
	desc = "Подробная карта Нового Сиднея, отображающая доступные к посещению регионы."
	icon = 'modular_bandastation/galactic_map/icons/galactic_map.dmi'
	icon_state = "galactic_map_statue"
	anchored = TRUE

/obj/structure/statue/gold/new_sydney_map/ui_interact(mob/user, datum/tgui/ui)
    user << browse_rsc(
        'modular_bandastation/voyaker_events/icons/other/worldmap.png',
        "worldmap.png"
    )

    ui = SStgui.try_update_ui(user, src, ui)
    if(!ui)
        ui = new(user, src, "NewSydneyMap")
        ui.open()
