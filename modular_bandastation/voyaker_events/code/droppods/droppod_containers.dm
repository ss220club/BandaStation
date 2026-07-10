/obj/structure/closet/crate/secure/weapon/air
	resistance_flags = INDESTRUCTIBLE
	var/unlock_time = 0
	var/unlocking = FALSE
	var/unlock_sound_timer = null

/obj/structure/closet/crate/secure/weapon/air/attack_hand(mob/living/user)
	if(!ishuman(user))
		return ..()
	var/mob/living/carbon/human/H = user
	if(unlocking)
		var/time_left = round((unlock_time - world.time) / 10)
		to_chat(H, span_warning("Разблокировка ящика продолжается. Осталось [time_left] сек."))
		return
	if(!locked)
		return ..()
	start_unlock(H)

/obj/structure/closet/crate/secure/weapon/air/proc/start_unlock(mob/user)
	unlocking = TRUE
	unlock_time = world.time + 1 MINUTES
	to_chat(user, span_warning("Вы запустили процедуру разблокировки контейнера. Процедура займёт одну минуту."))
	playsound(src, 'sound/items/timer.ogg', 80, TRUE)
	unlock_sound_loop()
	addtimer(CALLBACK(src, PROC_REF(finish_unlock)), 1 MINUTES)

/obj/structure/closet/crate/secure/weapon/air/proc/unlock_sound_loop()
	if(!unlocking)
		return
	var/last_tick = 0
	if(world.time - last_tick < 10)
		return
	last_tick = world.time
	playsound(src, 'sound/items/timer.ogg', 50, FALSE)
	addtimer(CALLBACK(src, PROC_REF(unlock_sound_loop)), 1 SECONDS)

/obj/structure/closet/crate/secure/weapon/air/proc/finish_unlock()
	unlocking = FALSE
	locked = FALSE
	playsound(src, 'sound/machines/beep/beep.ogg', 80, TRUE)
	for(var/mob/living/M in viewers(5, src))
		to_chat(M, span_notice("Замок ящика разблокирован."))

/obj/structure/closet/crate/secure/weapon/air/common/Initialize(mapload)
	. = ..()

	var/list/loot = list(
		/obj/item/stack/sheet/iron,
		/obj/item/storage/toolbox,
		/obj/item/flashlight,
		/obj/item/crowbar
	)
	for(var/i in 1 to rand(3,6))
		var/path = pick(loot)
		new path(src)

/obj/structure/closet/crate/secure/weapon/air/medical/Initialize(mapload)
	. = ..()

	var/list/loot = list(
		/obj/item/stack/sheet/iron,
		/obj/item/storage/toolbox,
		/obj/item/flashlight,
		/obj/item/crowbar
	)
	for(var/i in 1 to rand(3,6))
		var/path = pick(loot)
		new path(src)

/obj/structure/closet/crate/secure/weapon/air/ammunition/Initialize(mapload)
	. = ..()

	var/list/loot = list(
		/obj/item/stack/sheet/iron,
		/obj/item/storage/toolbox,
		/obj/item/flashlight,
		/obj/item/crowbar
	)
	for(var/i in 1 to rand(3,6))
		var/path = pick(loot)
		new path(src)
