/obj/machinery/jukebox/concertspeaker
	name = "\proper концертная установка"
	desc = "Концертная колонка, которая используется для воспроизведения концертной записи."
	icon = 'modular_bandastation/objects/icons/obj/machines/jukebox.dmi'
	icon_state = "concertmaster"
	base_icon_state = "concertmaster"
	req_access = list()
	anchored = TRUE
	density = TRUE
	layer = 2.5
	resistance_flags = NONE
	max_integrity = 250
	integrity_failure = 25
	var/shell_capacity = SHELL_CAPACITY_SMALL
	var/remote_installed = FALSE
	var/obj/item/circuit_component/concert_master/master_component
	var/obj/item/concert_disk/inserted_disk

/obj/machinery/jukebox/concertspeaker/Destroy()
	clear_music_player()

	return ..()

/obj/machinery/jukebox/concertspeaker/examine()
	. = ..()
	. += "<span class='notice'>Используйте гаечный ключ, чтобы разобрать для транспортировки и собрать для игры.</span>"

/obj/machinery/jukebox/concertspeaker/wrench_act(mob/living/user, obj/item/I)
	if(!anchored)
		return ..()

	to_chat(user, span_notice("Вы демонтируете DJ-стойку."))
	convert_to_regular(user)
	return TRUE

/obj/machinery/jukebox/concertspeaker/update_icon_state()
	. = ..()
	if(machine_stat & (BROKEN))
		icon_state = "concertspeaker_broken"
	else
		icon_state = base_icon_state
	update_overlays()

/obj/machinery/jukebox/concertspeaker/update_overlays()
	. = ..()
	overlays.Cut()

	if(music_player.active_song_sound)
		overlays += mutable_appearance(icon, "song_act1")
		overlays += mutable_appearance(icon, "song_act2")
		overlays += mutable_appearance(icon, "song_act3b")

	if(length(music_player.songs))
		overlays += mutable_appearance(icon, "playing")
	else
		overlays += mutable_appearance(icon, "standby")

	if(remote_installed)
		overlays += mutable_appearance(icon, "synced")
	else
		overlays += mutable_appearance(icon, "asynced")

/obj/machinery/jukebox/concertspeaker/Initialize(mapload)
	. = ..()
	music_player = new /datum/jukebox/concertspeaker(src)
	AddComponent(/datum/component/shell, list(), shell_capacity)

/obj/machinery/jukebox/concertspeaker/activate_music()
	. = ..()
	SEND_SIGNAL(src, COMSIG_INSTRUMENT_START, music_player.selection)

/obj/machinery/jukebox/concertspeaker/stop_music()
	. = ..()
	SEND_SIGNAL(src, COMSIG_INSTRUMENT_END, src)

/obj/machinery/jukebox/concertspeaker/attack_hand_secondary(mob/user, list/modifiers)
	if(!allowed(user))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	if(inserted_disk)
		eject_disk(user)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	return ..()

/obj/machinery/jukebox/concertspeaker/proc/convert_to_regular(mob/user)
	var/turf/T = get_turf(src)
	if(!T) return

	stop_music()

	var/obj/structure/concertspeaker/S = new(T)
	S.dir = dir
	S.anchored = TRUE
	S.density = TRUE
	S.layer = 5

	for(var/obj/item/integrated_circuit/C in contents)
		C.forceMove(S)

	new /obj/item/concert_master(T)

	qdel(src)

/obj/machinery/jukebox/concertspeaker/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/concert_disk))
		insert_disk(I, user)
		return TRUE

	return ..()

/obj/machinery/jukebox/concertspeaker/proc/insert_disk(obj/item/concert_disk/D, mob/user)
	if(inserted_disk)
		to_chat(user, span_warning("Диск уже вставлен."))
		return

	clear_music_player()

	inserted_disk = D
	D.forceMove(src)

	var/datum/jukebox/concertspeaker/concert_system = music_player
	if(concert_system)
		concert_system.load_album(D.album_id)
		to_chat(user, span_notice("Вы загрузили альбом: [D.name]."))
		update_overlays()

/obj/machinery/jukebox/concertspeaker/proc/eject_disk(mob/user)
	if(!inserted_disk)
		return

	clear_music_player()

	var/obj/item/concert_disk/D = inserted_disk
	inserted_disk = null

	if(user && user.put_in_active_hand(D))
		to_chat(user, span_notice("Вы извлекли диск [D.name]."))

	else
		D.forceMove(drop_location())

	update_overlays()

	if(music_player)
		music_player.songs = list()

	update_icon()

/obj/machinery/jukebox/concertspeaker/proc/clear_music_player()
	if(music_player)
		var/datum/jukebox/concertspeaker/C = music_player
		if(C)
			C.clear_album()
