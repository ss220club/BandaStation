/obj/item/circuit_component/concert_listener
	display_name = "Concert Speaker Receiver"
	desc = "Компонент, который получает с систему управления концертом информацию о текущем треке. Разработано Саундхенд."

	var/datum/port/output/is_playing
	var/datum/port/output/started_playing
	var/datum/port/output/stopped_playing

	var/playing = FALSE

/obj/item/circuit_component/concert_listener/populate_ports()
	is_playing = add_output_port("Is Playing", PORT_TYPE_NUMBER)
	started_playing = add_output_port("Started Playing", PORT_TYPE_SIGNAL)
	stopped_playing = add_output_port("Stopped Playing", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/concert_listener/proc/play_track()
	if(playing || !parent) return

	var/obj/item/integrated_circuit/C = parent
	var/atom/movable/sh = C?.shell
	if(istype(sh, /obj/structure/concertspeaker))
		var/obj/structure/concertspeaker/S = sh
		if(!S.anchored)
			return

	playing = TRUE
	is_playing.set_output(TRUE)
	started_playing.set_output(COMPONENT_SIGNAL)
	update_parent()

/obj/item/circuit_component/concert_listener/proc/stop_playback()
	if(!playing || !parent) return
	playing = FALSE
	is_playing.set_output(FALSE)
	stopped_playing.set_output(COMPONENT_SIGNAL)
	update_parent()

/obj/item/circuit_component/concert_listener/proc/update_parent(unreg = FALSE)
	var/obj/item/integrated_circuit/C = parent
	var/atom/movable/shell = C?.shell
	if(istype(shell, /obj/structure/concertspeaker))
		var/obj/structure/concertspeaker/S = shell
		S.active = (playing && S.anchored)
		S.is_synced = !unreg
		S.update_icon()
		S.update_overlays()

	if(istype(C, /obj/machinery/jukebox/concertspeaker))
		var/obj/machinery/jukebox/concertspeaker/J = C
		J.music_player?.update_all()

/obj/item/circuit_component/concert_listener/register_shell(atom/movable/shell)
	. = ..()
	update_parent()

/obj/item/circuit_component/concert_listener/unregister_shell(atom/movable/shell)
	. = ..()
	update_parent(TRUE)
