/obj/item/circuit_component/concert_master
	display_name = "Concert Master"
	desc = "Основная управляющая схема концертной установки. Получает текущий трек и рассылает его колонкам."

	var/datum/port/output/track_name_out
	var/datum/port/output/is_playing
	var/datum/port/output/started_playing
	var/datum/port/output/stopped_playing

	var/obj/machinery/jukebox/concertspeaker/linked_jukebox
	var/obj/item/concert_remote/remote

/obj/item/circuit_component/concert_master/populate_ports()
	track_name_out  = add_output_port("Track Name", PORT_TYPE_STRING)
	is_playing      = add_output_port("Is Playing", PORT_TYPE_NUMBER)
	started_playing = add_output_port("Started Playing", PORT_TYPE_SIGNAL)
	stopped_playing = add_output_port("Stopped Playing", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/concert_master/Initialize(mapload)
	. = ..()
	if(!remote)
		remote = new /obj/item/concert_remote(src)
	remote.forceMove(src)

/obj/machinery/jukebox/concertspeaker/examine()
	. = ..()
	if(!inserted_disk)
		. += span_warning("Вставьте музыкальный диск, чтобы загрузить треки.")

/obj/item/circuit_component/concert_master/attack_self(mob/user)
	if(!remote)
		to_chat(user, span_warning("Пульт уже извлечён."))
		return
	if(!user.put_in_active_hand(remote))
		remote.forceMove(drop_location())
	to_chat(user, span_notice("Вы извлекли концертный пульт."))

/obj/item/circuit_component/concert_master/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/concert_remote))
		if(I != remote)
			to_chat(user, span_warning("Этот пульт не подходит к данному контроллеру."))
			return TRUE
		I.forceMove(src)
		to_chat(user, span_notice("Пульт вставлен в контроллер."))
		return TRUE
	return ..()

/obj/item/circuit_component/concert_master/register_shell(atom/movable/shell)
	if(!remote)
		return ..()

	. = ..()
	if(istype(shell, /obj/machinery/jukebox/concertspeaker))
		linked_jukebox = shell
		linked_jukebox.master_component = src
		linked_jukebox.remote_installed = TRUE
		RegisterSignal(linked_jukebox, COMSIG_INSTRUMENT_START, PROC_REF(on_song_start))
		RegisterSignal(linked_jukebox, COMSIG_INSTRUMENT_END,   PROC_REF(on_song_end))
		linked_jukebox.update_icon()

/obj/item/circuit_component/concert_master/unregister_shell(atom/movable/shell)
	if(linked_jukebox)
		UnregisterSignal(linked_jukebox, list(COMSIG_INSTRUMENT_START, COMSIG_INSTRUMENT_END))
		linked_jukebox.master_component = null
		linked_jukebox.remote_installed = FALSE
		linked_jukebox.update_icon()
	linked_jukebox = null
	return ..()

/obj/item/circuit_component/concert_master/proc/on_song_start(datum/source, datum/track/starting_song)
	SIGNAL_HANDLER
	if(!starting_song)
		return
	track_name_out.set_output(starting_song.song_name)
	is_playing.set_output(TRUE)
	started_playing.set_output(COMPONENT_SIGNAL)

	for(var/obj/item/circuit_component/concert_listener/L in remote.takers)
		L.play_track()

/obj/item/circuit_component/concert_master/proc/on_song_end()
	SIGNAL_HANDLER
	track_name_out.set_output("")
	is_playing.set_output(FALSE)
	stopped_playing.set_output(COMPONENT_SIGNAL)

	for(var/obj/item/circuit_component/concert_listener/L in remote.takers)
		L.stop_playback()

/datum/supply_pack/goody/concert_controller
	access = NONE
	group = "Imports"
	cost = CARGO_CRATE_VALUE * 1.5
	crate_name = "Контейнер Установки Саундхенд"
	crate_type = /obj/structure/closet/crate
	discountable = SUPPLY_PACK_NOT_DISCOUNTABLE
	name = "Установка Саундхенд"
	desc = "Контейнер содержит плату для сборки концертной установки Саундхенд. Материалы в поставку не входят."
	contains = list(
		/obj/item/concert_master,
		/obj/item/circuit_component/concert_master
		)
