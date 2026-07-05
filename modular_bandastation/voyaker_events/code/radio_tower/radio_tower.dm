/obj/structure/radio_tower
	name = "communications tower"
	desc = "Военная радиовышка для запроса снабжения."
	icon = 'modular_bandastation/voyaker_events/icons/radiotower.dmi'
	icon_state = "comm_tower"
	anchored = TRUE
	density = TRUE
	var/next_use = 0
	var/cooldown_time = 20 MINUTES
	var/drop_delay = 1 MINUTES

/obj/structure/radio_tower/proc/on_cooldown()
	return world.time < next_use + cooldown_time

/obj/structure/radio_tower/interact(mob/user)
	. = ..()
	if(world.time < next_use)
		var/time_left = round((next_use - world.time) / 10)
		to_chat(user, span_warning("Система перезаряжается. Осталось [time_left] секунд."))
		return
	to_chat(user, span_notice("Вы начинаете отправлять запрос на снабжение..."))
	if(!do_after(user, 10 SECONDS, src))
		return
	if(world.time < next_use)
		return
	next_use = world.time + cooldown_time
	priority_announce(
		"Зафиксирована отправка запроса на доставку снабжения со стороны военного объекта Орион-15. Прибытие грузовой капсулы на место ожидается в течении минуты.",
		"Система наблюдения АСБ Ковчег"
	)
	addtimer(CALLBACK(src, PROC_REF(spawn_supply_drop)), drop_delay)
	icon_state = "comm_tower_on"

/obj/structure/radio_tower/proc/get_random_drop_turf()
	var/list/valid_turfs = list()
	for(var/turf/open/T in get_area_turfs(/area/new_sydney/military_base))
		if(!T.density)
			valid_turfs += T
	if(!valid_turfs.len)
		return null
	return pick(valid_turfs)

/obj/structure/radio_tower/proc/spawn_supply_drop()
	var/list/possible_turfs = list()
	for(var/turf/T in get_area_turfs(/area/new_sydney/military_base))
		if(!T.density)
			possible_turfs += T
		if(T.density)
			continue
		if(locate(/obj/structure) in T)
			continue
		if(locate(/turf/closed) in T)
			continue
		if(locate(/obj/effect/spawner/structure) in T)
			continue
	if(!possible_turfs.len)
		return
	var/turf/target = pick(possible_turfs)
	var/obj/structure/closet/crate/loot/common/crate = new
	podspawn(list(
		"target" = target,
		"path" = /obj/structure/closet/supplypod,
		"spawn" = list(crate)
	))
	priority_announce(
		"Грузовая капсула НаноТрейзен успешно прибыла в военный сектор базы Орион-15.",
		"Система наблюдения АСБ Ковчег"
	)
	icon_state = "comm_tower"
