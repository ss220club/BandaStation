/area/ruin/shadow_template
	name = "\improper Shadow Template Ruin"
	var/darkness_active = FALSE
	var/darkness_broken = FALSE
	var/list/darkness_occupants = list()
	var/list/darkness_lights = list()
	var/list/holy_candles = list()
	var/holy_candle_count = 0
	var/required_holy_candles = 13

/area/ruin/shadow_template/Entered(atom/movable/arrived, area/old_area)
	. = ..()
	if(istype(arrived, /obj/item/flashlight/flare/candle))
		register_holy_candle(arrived)
		return
	if(!isliving(arrived))
		return
	darkness_occupants |= arrived
	if(!darkness_broken && !darkness_active)
		darkness_active = TRUE
		enable_darkness()
	register_lights_in(arrived)

/area/ruin/shadow_template/Exited(atom/movable/gone, direction)
	. = ..()
	if(istype(gone, /obj/item/flashlight/flare/candle))
		unregister_holy_candle(gone)
		return
	if(!isliving(gone))
		return
	darkness_occupants -= gone
	if(!length(darkness_occupants) && !darkness_broken)
		darkness_active = FALSE
		disable_darkness()

/area/ruin/shadow_template/proc/enable_darkness()
	darkness_active = TRUE
	for(var/turf/T in src)
		for(var/obj/item/flashlight/flare/candle/holy_candle in T)
			register_holy_candle(holy_candle)
	check_holy_candles()

/area/ruin/shadow_template/proc/disable_darkness()
	darkness_active = FALSE
	clear_light_sources()

/area/ruin/shadow_template/proc/register_light_source(atom/source)
	if(!source)
		return
	if(istype(source, /obj/item/flashlight/flare/candle))
		return
	if(source.light_range <= 0)
		return
	if(source in darkness_lights)
		return
	darkness_lights += source
	RegisterSignal(source, COMSIG_ATOM_SET_LIGHT_ON, PROC_REF(on_light_set))
	if(source.light_on)
		source.set_light_on(FALSE)

/area/ruin/shadow_template/proc/on_light_set(atom/source, new_value)
	SIGNAL_HANDLER
	if(!darkness_active)
		return
	if(new_value)
		return COMPONENT_BLOCK_LIGHT_UPDATE

/area/ruin/shadow_template/proc/unregister_light_source(atom/source)
	if(!(source in darkness_lights))
		return
	UnregisterSignal(source, COMSIG_ATOM_SET_LIGHT_ON)
	darkness_lights -= source

/area/ruin/shadow_template/proc/clear_light_sources()
	for(var/atom/source as anything in darkness_lights)
		if(source)
			UnregisterSignal(source, COMSIG_ATOM_SET_LIGHT_ON)
	darkness_lights.Cut()

/area/ruin/shadow_template/proc/register_lights_in(atom/movable/M)
	if(M.light_range > 0)
		register_light_source(M)
	for(var/atom/A in M.contents)
		if(A.light_range > 0)
			register_light_source(A)

/area/ruin/shadow_template/proc/register_holy_candle(obj/item/flashlight/flare/candle/holy_candle)
	if(!holy_candle)
		return
	if(holy_candle in holy_candles)
		return
	holy_candles += holy_candle
	RegisterSignal(holy_candle, COMSIG_ATOM_SET_LIGHT_ON, PROC_REF(on_holy_candle_set))
	if(holy_candle.light_on)
		holy_candle_count++
	check_holy_candles()

/area/ruin/shadow_template/proc/check_holy_candles()
	if(darkness_broken)
		return
	var/lit_candles = 0
	for(var/obj/item/flashlight/flare/candle/infinite/holy_candle as anything in holy_candles)
		if(!holy_candle || QDELETED(holy_candle))
			continue
		if(holy_candle.light_on)
			lit_candles++
	if(lit_candles < required_holy_candles)
		return
	break_darkness()

/area/ruin/shadow_template/proc/unregister_holy_candle(obj/item/flashlight/flare/candle/holy_candle)
	if(!(holy_candle in holy_candles))
		return
	UnregisterSignal(holy_candle, COMSIG_ATOM_SET_LIGHT_ON)
	holy_candles -= holy_candle

/area/ruin/shadow_template/proc/on_holy_candle_set(obj/item/flashlight/flare/candle/holy_candle, new_value)
	SIGNAL_HANDLER
	if(new_value)
		holy_candle_count++
		check_holy_candles()

/area/ruin/shadow_template/proc/break_darkness()
	if(darkness_broken)
		return
	darkness_broken = TRUE
	darkness_active = FALSE
	clear_light_sources()
	for(var/mob/living/L as anything in darkness_occupants)
		if(L)
			to_chat(L, span_danger("Гнетущая тьма была развеяна священным светом..."))
