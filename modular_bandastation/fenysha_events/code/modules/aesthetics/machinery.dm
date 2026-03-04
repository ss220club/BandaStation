// Аирлоки
/obj/machinery/door/airlock/shuttle/ferry
	icon = 'modular_bandastation/fenysha_events/icons/machinery/airlocks/shuttle2/erokez.dmi'
	overlays_file = 'modular_bandastation/fenysha_events/icons/machinery/airlocks/shuttle2/overlays.dmi'

/obj/machinery/door/airlock/external/wagon
	icon = 'modular_bandastation/fenysha_events/icons/machinery/airlocks/shuttle2/wagon.dmi'
	overlays_file = 'modular_bandastation/fenysha_events/icons/machinery/airlocks/shuttle2/overlays.dmi'


// Переключатели

/obj/machinery/light_switch/default_on

/obj/machinery/light_switch/default_on/post_machine_initialize()
	. = ..()
	set_lights(TRUE)

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/light_switch/default_on, 26)
