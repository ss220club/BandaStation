#define SOUNDHAND_SUMMONER_CALL_ALLOWED "mrix"

/obj/item/soundhand_summoner
	name = "старый кликер"
	desc = "Обычный кликер с единственной кнопкой, который похоже видал времена и получше"
	icon = 'icons/obj/devices/tracker.dmi'
	icon_state = "beacon"

	var/template_shuttle_id = "soundhand_basic"
	var/next_use = 0
	var/cooldown = 10 SECONDS
	var/ram_warn_time = 15 SECONDS

/obj/item/soundhand_summoner/attack_self(mob/user)
	. = ..()
	if(user)
		balloon_alert(user, "клик")

	if(!user?.client || user.ckey != SOUNDHAND_SUMMONER_CALL_ALLOWED)
		return

	if(world.time < next_use)
		return
	next_use = world.time + cooldown

	var/turf/T = get_turf(user)
	if(!istype(T))
		return

	var/turf/landing = get_step(T, SOUTH) || T
	if(landing.x <= 10 || landing.y <= 10 || landing.x >= world.maxx - 10 || landing.y >= world.maxy - 10)
		return

	var/obj/docking_port/stationary/soundhand_beacon/beacon = new(landing)
	beacon.setDir(NORTH)

	announce_danger()
	var/obj/docking_port/mobile/soundhand/S = SSshuttle.getShuttle("soundhand")
	if(!istype(S) || QDELETED(S))
		var/datum/map_template/shuttle/tpl = SSmapping.shuttle_templates[template_shuttle_id]
		if(!tpl)
			qdel(beacon)
			return

		S = SSshuttle.action_load(tpl)
		if(!istype(S) || QDELETED(S))
			qdel(beacon)
			return

	S.initiate_drop_landing(beacon, ram_warn_time)
	addtimer(CALLBACK(S, TYPE_PROC_REF(/obj/docking_port/mobile/soundhand, _do_ram_to), beacon), ram_warn_time)
	addtimer(CALLBACK(src, PROC_REF(_cleanup_after_ram), beacon), ram_warn_time + 2 SECONDS)

/obj/item/soundhand_summoner/proc/announce_danger()
	priority_announce(
		text = "ВНИМАНИЕ: Автоматическая система шаттла сообщает об ошибках в навигационных расчётах. Возможна потеря точности активации торможения и столкновение с объектом. Немедленно освободите предполагаемую зону прибытия и прилегающие коридоры.",
		title = "СБОЙ СИСТЕМ НАВИГАЦИИ SH-713!",
		sound = SSstation.announcer.get_rand_report_sound(),
		sender_override = "Автоматическая система шаттла",
		color_override = "red",
	)

/obj/item/soundhand_summoner/proc/_cleanup_after_ram(obj/docking_port/stationary/soundhand_beacon/beacon)
	if(!QDELETED(beacon))
		qdel(beacon)

	if(!QDELETED(src))
		qdel(src)

/datum/crafting_recipe/soundhand_summoner
	name = "strange clicker"
	result = /obj/item/soundhand_summoner
	time = 4 SECONDS

	reqs = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stack/sheet/plastic = 2,
		/obj/item/assembly/signaler = 1,
	)

	category = CAT_MISC
