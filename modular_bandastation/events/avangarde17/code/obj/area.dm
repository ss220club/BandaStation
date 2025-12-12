// MARK: Area
// Зоны Авангарда
/area/awaymission/avangarde17
	name = "Авангард-17"
	icon_state = "awaycontent1"
	requires_power = FALSE
	static_lighting = FALSE
	base_lighting_alpha = 255

/area/awaymission/avangarde17/outside
	name = "Лес"
	icon_state = "awaycontent17"
	base_lighting_alpha = 120

// Скорее всего удалить луп музыки, трансляция будет по радио
/area/awaymission/avangarde17/outside/base
	name = "Аванпост КССП"
	icon_state = "awaycontent3"
	var/sound_file = 'modular_bandastation/events/avangarde17/audio/red_army.ogg'
	var/sound_channel = 61
	var/max_volume = 20
	var/fade_tick = 0.3 SECONDS
	var/fade_duration = 1.5 SECONDS
	var/check_period = 3 SECONDS

	var/play_duration = 4 MINUTES + 40 SECONDS
	var/silence_duration = 20 SECONDS
	var/is_phase_play = FALSE

	var/list/current_volumes = list()
	var/list/target_volumes  = list()
	var/list/attached_mobs   = list()

/area/awaymission/avangarde17/inside
	name = "Аванпост КССП"
	icon_state = "awaycontent4"
	static_lighting = TRUE
	base_lighting_alpha = 0

/area/awaymission/avangarde17/inside/cave
	name = "Пещеры"
	icon_state = "awaycontent5"

/area/awaymission/avangarde17/inside/temple
	name = "Древний храм"
	icon_state = "awaycontent6"

/area/awaymission/avangarde17/outside/base/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(update_members)), check_period, TIMER_LOOP | TIMER_STOPPABLE)
	addtimer(CALLBACK(src, PROC_REF(process_fades)),  fade_tick,   TIMER_LOOP | TIMER_STOPPABLE)
	start_cycle()

/area/awaymission/avangarde17/outside/base/Destroy()
	for(var/mob/M in attached_mobs)
		if(M?.client)
			SEND_SOUND(M, sound(null, channel = sound_channel))
	current_volumes.Cut()
	target_volumes.Cut()
	attached_mobs.Cut()
	return ..()

/area/awaymission/avangarde17/outside/base/proc/start_cycle()
	is_phase_play = TRUE
	for(var/mob/M in attached_mobs)
		if(!M?.client) continue
		var/sound/start = sound(sound_file)
		start.channel = sound_channel
		start.repeat = TRUE
		start.volume = current_volumes[M] || 0
		SEND_SOUND(M, start)
	update_members()
	addtimer(CALLBACK(src, PROC_REF(begin_silence_phase)), play_duration, TIMER_STOPPABLE)

/area/awaymission/avangarde17/outside/base/proc/begin_silence_phase()
	is_phase_play = FALSE
	for(var/mob/M in attached_mobs)
		target_volumes[M] = 0
	addtimer(CALLBACK(src, PROC_REF(start_cycle)), silence_duration, TIMER_STOPPABLE)

/area/awaymission/avangarde17/outside/base/proc/update_members()
	var/list/in_zone = list()
	for(var/mob/living/player in GLOB.player_list)
		if(!player?.client) continue
		if(get_area(player) == src)
			in_zone[player] = TRUE
			if(!(player in attached_mobs))
				var/sound/seed = sound(sound_file)
				seed.channel = sound_channel
				seed.repeat = TRUE
				seed.volume = 0
				SEND_SOUND(player, seed)
				attached_mobs += player
				current_volumes[player] = 0
			target_volumes[player] = is_phase_play ? max_volume : 0
	for(var/mob/existing in current_volumes.Copy())
		if(!existing?.client)
			detach_listener(existing)
		else if(!(existing in in_zone))
			target_volumes[existing] = 0

/area/awaymission/avangarde17/outside/base/proc/process_fades()
	for(var/mob/listener in current_volumes.Copy())
		if(!listener?.client)
			detach_listener(listener)
			continue
		var/cv = current_volumes[listener]
		var/tv = isnull(target_volumes[listener]) ? 0 : target_volumes[listener]
		if(cv == tv) continue
		var/step = round((max_volume * fade_tick) / max(0.1 SECONDS, fade_duration))
		if(step < 1) step = 1
		var/nv = cv
		if(cv < tv) nv = min(cv + step, tv)
		else        nv = max(cv - step, tv)
		if(abs(nv - cv) >= 2)
			var/sound/update = sound(null)
			update.channel = sound_channel
			update.repeat = TRUE
			update.volume = nv
			update.status = SOUND_UPDATE
			SEND_SOUND(listener, update)
		current_volumes[listener] = nv

/area/awaymission/avangarde17/outside/base/proc/detach_listener(mob/M)
	if(!M) return
	SEND_SOUND(M, sound(null, channel = sound_channel))
	current_volumes -= M
	target_volumes  -= M
	attached_mobs   -= M
