GLOBAL_LIST_EMPTY(area_ambients)

/obj/effect/landmark/ambient_sound
	name = "ambient sound"
	icon = 'icons/effects/hitsplats.dmi'
	icon_state = "hitsplat_heal"
	var/sound_file
	var/sound_range = 15
	var/min_delay = 2 SECONDS
	var/max_delay = 5 SECONDS

/obj/effect/landmark/ambient_sound/Initialize(mapload)
	. = ..()
	GLOB.area_ambients += src
	start_ambient()

/obj/effect/landmark/ambient_sound/Destroy()
	GLOB.area_ambients -= src
	return ..()

/obj/effect/landmark/ambient_sound/proc/start_ambient()
	addtimer(
		CALLBACK(src, PROC_REF(play_ambient)), rand(min_delay, max_delay))

/obj/effect/landmark/ambient_sound/proc/play_ambient()
	if(QDELETED(src))
		return
	if(length(viewers(sound_range, src)))
		playsound(get_turf(src), sound_file, 80, FALSE)
	start_ambient()

/obj/effect/landmark/ambient_sound/dark_forest
	name = "Dark Forest Ambient"
	sound_file = 'modular_bandastation/voyaker_events/sounds/forest_wind.ogg'
	min_delay = 2 SECONDS
	max_delay = 60 SECONDS
	sound_range = 25

/obj/effect/landmark/ambient_sound/radiation_lake
	name = "Radiation Lake Ambient"
	sound_file = 'modular_bandastation/voyaker_events/sounds/radiation_hum.ogg'
	min_delay = 10 SECONDS
	max_delay = 20 SECONDS
	sound_range = 40

/obj/effect/landmark/ambient_sound/hub
	name = "Hub Ambient"
	sound_file = 'modular_bandastation/voyaker_events/sounds/hub.ogg'
	min_delay = 10 SECONDS
	max_delay = 20 SECONDS
	sound_range = 15

/obj/effect/landmark/ambient_sound/bunker
	name = "Bunker Work Ambient"
	sound_file = 'modular_bandastation/voyaker_events/sounds/bunker.ogg'
	min_delay = 10 SECONDS
	max_delay = 20 SECONDS
	sound_range = 20

/obj/effect/landmark/ambient_sound/desert
	name = "Desert Ambient"
	sound_file = 'modular_bandastation/voyaker_events/sounds/desert.ogg'
	min_delay = 10 SECONDS
	max_delay = 20 SECONDS
	sound_range = 20
