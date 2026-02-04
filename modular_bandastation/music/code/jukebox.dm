// Reasons for appling STATUS_MUTE to a mob's sound status
/// The mob is deaf
#define MUTE_DEAF (1<<0)
/// The mob has disabled jukeboxes in their preferences
#define MUTE_PREF (1<<1)
/// The mob is out of range of the jukebox
#define MUTE_RANGE (1<<2)

/datum/jukebox/concertspeaker
	var/list/last_anchor_by_mob = list()
	var/list/last_d2_by_mob     = list()
	var/list/last_switch_time   = list()
	var/const/ANCHOR_MIN_SWITCH_DS = 5
	var/const/ANCHOR_MARGIN_D2     = 1
	var/anchor_scan_timer_id

/datum/jukebox/concertspeaker/New(atom/new_parent)
	. = ..()
	songs = list()

/datum/jukebox/concertspeaker/load_songs_from_config()
	return list()

/datum/jukebox/concertspeaker/proc/fill_songs_static_list()
	var/songs_list = list()
	for(var/datum/track/new_track as anything in subtypesof(/datum/track/soundhand))
		songs_list[new_track.song_name] = new new_track (new_track.song_name,new_track.song_path,new_track.song_length,new_track.song_beat_deciseconds)

	if(!length(songs_list))
		var/datum/track/default/default_track = new()
		songs_list[default_track.song_name] = default_track

	return songs_list

/datum/jukebox/concertspeaker/proc/get_anchor_turfs()
	var/list/turfs = list()
	var/obj/machinery/jukebox/concertspeaker/machine = parent

	if(istype(machine) && machine.master_component)
		for(var/obj/item/circuit_component/concert_listener/L in machine.master_component.remote.takers)
			if(!L.playing) continue
			var/obj/item/integrated_circuit/C = L.parent
			var/atom/movable/sh = C?.shell
			if(!sh) continue

			if(istype(sh, /obj/structure/concertspeaker))
				var/obj/structure/concertspeaker/S = sh
				if(!S.anchored)
					continue

			var/turf/T = get_turf(sh)
			if(T) turfs += T

	var/turf/self_t = get_turf(parent)
	if(self_t) turfs += self_t

	return turfs

/datum/jukebox/concertspeaker/proc/pick_anchor_for(mob/listener)
	var/turf/L = get_turf(listener)
	if(!L) return get_turf(parent)

	var/list/anchors = get_anchor_turfs()
	var/turf/best = null
	var/best_d2 = 1.0e30

	for(var/turf/A as anything in anchors)
		if(!A || A.z != L.z) continue
		var/dx = A.x - L.x
		var/dy = A.y - L.y
		var/d2 = dx*dx + dy*dy
		if(d2 < best_d2)
			best_d2 = d2
			best = A

	if(!best) return get_turf(parent)
	var/turf/prev = last_anchor_by_mob[listener]
	var/prev_d2 = last_d2_by_mob[listener]
	var/last_sw = last_switch_time[listener] || 0
	if(prev && prev.z == L.z && !isnull(prev_d2))
		if( (best_d2 + ANCHOR_MARGIN_D2) >= prev_d2 && (world.time - last_sw) < ANCHOR_MIN_SWITCH_DS )
			return prev

	last_anchor_by_mob[listener] = best
	last_d2_by_mob[listener]     = best_d2
	last_switch_time[listener]   = world.time
	return best

/datum/jukebox/concertspeaker/update_listener(mob/listener)
	if(isnull(active_song_sound))
		..()
		return

	active_song_sound.status = listeners[listener] || NONE

	var/turf/sound_turf = pick_anchor_for(listener)
	var/turf/listener_turf = get_turf(listener)

	if(isnull(sound_turf) || isnull(listener_turf))
		active_song_sound.x = 0
		active_song_sound.z = 0

	else if(sound_turf.z != listener_turf.z)
		listeners[listener] |= SOUND_MUTE

	else
		var/new_x = sound_turf.x - listener_turf.x
		var/new_z = sound_turf.y - listener_turf.y

		if((abs(new_x) > x_cutoff || abs(new_z) > z_cutoff))
			listeners[listener] |= SOUND_MUTE
		else if(listeners[listener] & SOUND_MUTE)
			unmute_listener(listener, MUTE_RANGE)

		active_song_sound.x = new_x
		active_song_sound.z = new_z

		var/pref_volume = listener.client?.prefs.read_preference(/datum/preference/numeric/volume/sound_jukebox)
		if(!pref_volume)
			listeners[listener] |= SOUND_MUTE
		else
			unmute_listener(listener, MUTE_PREF)
			active_song_sound.volume = volume * (pref_volume/100)

	SEND_SOUND(listener, active_song_sound)

/datum/jukebox/concertspeaker/proc/register_near_anchor_mobs()
	var/list/anchors = get_anchor_turfs()
	if(!length(anchors))
		anchors += get_turf(parent)

	var/list/seen = list()
	for(var/turf/T in anchors)
		if(!T)
			continue

		for(var/mob/M in hearers(sound_range, T))
			if(seen[M])
				continue

			seen[M] = TRUE

			if(!(M in listeners))
				register_listener(M)

/datum/jukebox/concertspeaker/proc/periodic_anchor_scan()
	if(isnull(active_song_sound))
		stop_anchor_scan()
		return
	register_near_anchor_mobs()

/datum/jukebox/concertspeaker/start_music()
	..()
	register_near_anchor_mobs()
	start_anchor_scan()

/datum/jukebox/concertspeaker/Destroy()
	stop_anchor_scan()
	return ..()

/datum/jukebox/concertspeaker/unmute_listener(mob/listener, reason)
	reason = ~reason

	if((reason & MUTE_DEAF) && HAS_TRAIT(listener, TRAIT_DEAF))
		return FALSE

	var/pref_volume = listener.client?.prefs.read_preference(/datum/preference/numeric/volume/sound_jukebox)
	if((reason & MUTE_PREF) && !pref_volume)
		return FALSE

	if(reason & MUTE_RANGE)
		var/turf/sound_turf = pick_anchor_for(listener)
		var/turf/listener_turf = get_turf(listener)
		if(isnull(sound_turf) || isnull(listener_turf))
			return FALSE
		if(sound_turf.z != listener_turf.z)
			return FALSE
		var/dx = sound_turf.x - listener_turf.x
		var/dy = sound_turf.y - listener_turf.y
		if(abs(dx) > x_cutoff || abs(dy) > z_cutoff)
			return FALSE

	listeners[listener] &= ~SOUND_MUTE
	return TRUE

/datum/jukebox/concertspeaker/proc/start_anchor_scan()
	if(anchor_scan_timer_id)
		return
	anchor_scan_timer_id = addtimer(CALLBACK(src, PROC_REF(periodic_anchor_scan)), 2 SECONDS, TIMER_LOOP | TIMER_STOPPABLE)

/datum/jukebox/concertspeaker/proc/stop_anchor_scan()
	var/id = anchor_scan_timer_id
	anchor_scan_timer_id = null
	if(id)
		deltimer(id)

/datum/jukebox/concertspeaker/proc/load_album(album_id)
	songs = list()
	var/datum/concert_album/A = get_album(album_id)
	if(!A)
		return

	for(var/T in A.track_types)
		var/datum/track/TR = new T
		songs[TR.song_name] = TR

	qdel(A)

/datum/jukebox/concertspeaker/proc/get_album(id)
	for(var/T in subtypesof(/datum/concert_album))
		var/datum/concert_album/A = new T
		if(A.id == id)
			return A
	return null

/datum/jukebox/concertspeaker/proc/clear_album()
	unlisten_all()
	active_song_sound = null
	selection = null
	songs = list()

#undef MUTE_DEAF
#undef MUTE_PREF
#undef MUTE_RANGE

