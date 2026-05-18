/obj/structure/bodycontainer/crematorium/Destroy()
	GLOB.crematoriums -= src
	return ..()

/obj/structure/bodycontainer/crematorium/atom_deconstruct(disassembled = TRUE)

	var/obj/structure/bodycontainer/crematorium/broken/B = new(loc)

	B.dir = dir
	B.id = id

/obj/structure/bodycontainer/crematorium/broken
	name = "broken crematorium"
	desc = "Сломанный крематорий, но выглядит так, будто его можно починить."
	icon = 'modular_bandastation/objects/icons/obj/structures/crematorium.dmi'
	icon_state = "crema_broken"
	base_icon_state = "crema_broken"
	dir = SOUTH

	resistance_flags = INDESTRUCTIBLE

	density = TRUE
	anchored = TRUE

	var/repair_stage = 0
	var/igniters_installed = 0
	var/sparking = TRUE

/obj/structure/bodycontainer/crematorium/broken/Initialize(mapload)
	. = ..()
	GLOB.crematoriums -= src
	START_PROCESSING(SSobj, src)

/obj/structure/bodycontainer/crematorium/broken/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/bodycontainer/crematorium/broken/open()
	return FALSE

/obj/structure/bodycontainer/crematorium/broken/cremate()
	return

/obj/structure/bodycontainer/crematorium/broken/attack_hand(mob/user)
	to_chat(user, span_warning("Крематорий сломан."))

/obj/structure/bodycontainer/crematorium/broken/process(seconds_per_tick)

	if(!sparking)
		return

	if(prob(20))
		do_sparks(3, FALSE, src)

		if(prob(30))
			playsound(src, 'sound/items/tools/welder.ogg', 25, TRUE)

//MARK: Процесс ремонта
/obj/structure/bodycontainer/crematorium/broken/attackby(obj/item/W, mob/user, params)

//MARK: Первая стадия ремонта - использование 5 игнайтеров
	if(isigniter(W) && repair_stage == CREMATORIUM_STAGE_IGNITERS)

		qdel(W)

		igniters_installed++

		to_chat(user, span_notice("Вы устанавливаете воспламенитель в крематорий. ([igniters_installed]/[CREMATORIUM_REPAIR_IGNITERS])"))

		if(igniters_installed >= CREMATORIUM_REPAIR_IGNITERS)

			repair_stage = CREMATORIUM_STAGE_SCREWDRIVER
			sparking = FALSE

			to_chat(user, span_notice("Система поджига восстановлена. Теперь необходимо закрепить воспламенители отверткой."))

		return

//MARK: Вторая стадия ремонта - использование отвертки
	if(W.tool_behaviour == TOOL_SCREWDRIVER && repair_stage ==  CREMATORIUM_STAGE_SCREWDRIVER)

		to_chat(user, span_notice("Вы начинаете закреплять воспламенители крематория..."))

		if(!W.use_tool(src, user, 3 SECONDS))
			return

		repair_stage = CREMATORIUM_STAGE_PLASTEEL

		to_chat(user, span_notice("Воспламенители закреплены. Теперь требуется пласталь."))

		return

//MARK: Третья стадия ремонта - применение 2 листов пластали, смена спрайта
	if(istype(W, /obj/item/stack/sheet/plasteel) && repair_stage ==  CREMATORIUM_STAGE_PLASTEEL)

		var/obj/item/stack/sheet/plasteel/P = W

		if(P.amount < 2)
			to_chat(user, span_warning("Необходимо 2 листа пластали!"))
			return

		P.use(2)

		icon_state = (repair_stage >= CREMATORIUM_STAGE_PLASTEEL) ? "crema_broken1" : "crema_broken"

		repair_stage = CREMATORIUM_STAGE_WELDING
		update_appearance()

		to_chat(user, span_notice("Вы заменяете поврежденные панели пласталью. Осталось заварить корпус."))

		return

//MARK: Четвертая стадия ремонта - использование сварки, превращение обратно в функционирующий крематорий
	if(W.tool_behaviour == TOOL_WELDER && repair_stage == CREMATORIUM_STAGE_WELDING)

		if(!W.tool_start_check(user, amount = 1))
			return

		to_chat(user, span_notice("Вы начинаете восстанавливать крематорий..."))

		if(!W.use_tool(src, user, 5 SECONDS, amount = 1))
			return

		for(var/atom/movable/movable in contents)

			if(movable == connected)
				continue

			movable.forceMove(get_step(src, dir))

		var/obj/structure/bodycontainer/crematorium/C = new(loc)

		C.dir = dir
		C.id = id

		to_chat(user, span_notice("Вы полностью починили крематорий."))

		qdel(src)

		return

	return ..()

/obj/structure/bodycontainer/crematorium/broken/examine(mob/user)
	. = ..()

	switch(repair_stage)

		if(0)
			. += span_notice("Крематорий поврежден. Требуется установить [span_bold("воспламенители")] ([igniters_installed]/5)")

		if(1)
			. += span_notice("Компоненты не закреплены. Нужна [span_bold("отвертка")]")

		if(2)
			. += span_notice("Корпус поврежден. Требуется несколько листов [span_bold("пластали")]")

		if(3)
			. += span_notice("Осталось заварить корпус [span_bold("сваркой")]")
