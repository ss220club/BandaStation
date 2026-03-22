//Ritual Altar

/obj/structure/ritual_altar
	name = "Ritual altar"
	desc = "Из трещин в камне сочится кровь, источая сладковатый запах"
	icon = 'modular_bandastation/objects/icons/obj/structures/custom_puzzles.dmi'
	icon_state = "hereticaltar"
	custom_materials = list(/datum/material/runedmetal = SHEET_MATERIAL_AMOUNT * 3)
	density = TRUE
	anchored = TRUE
	layer = TABLE_LAYER
	pass_flags_self = PASSSTRUCTURE | PASSTABLE | LETPASSTHROW
	can_buckle = TRUE
	buckle_lying = 90

	var/obj/item/ritual_cup/cup = null
	var/obj/item/heretic_heart/heart = null
	var/obj/machinery/door/target_door = null
	var/activated = FALSE

/datum/armor/ritual_altar
	melee = 100
	bullet = 100
	laser = 100
	energy = 100
	bomb = 100
	bio = 100
	fire = 100
	acid = 100

/obj/structure/ritual_altar/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/climbable)
	AddElement(/datum/element/elevation, pixel_shift = 12)
	update_appearance(UPDATE_OVERLAYS)

/obj/structure/ritual_altar/attackby(obj/item/I, mob/user, params)
    if(activated)
        to_chat(user, span_warning("Ритуал был завершен."))
        return

    if(istype(I, /obj/item/ritual_cup))
        if(cup)
            to_chat(user, span_warning("Чаша уже установлена на алтарь."))
            return

        user.transferItemToLoc(I, src)
        cup = I

        to_chat(user, span_notice("Вы помещаете ритуальную чашу на алтарь."))
        visible_message(span_notice("[user] ставит чашу на алтарь."))

        check_ritual()
        return

    if(istype(I, /obj/item/heretic_heart))
        if(heart)
            to_chat(user, span_warning("На алтаре уже лежит проклятое сердце."))
            return

        user.transferItemToLoc(I, src)
        heart = I

        to_chat(user, span_notice("Вы помещаете сердце на алтарь."))
        visible_message(span_danger("[user] кладет сердце на алтарь."))

        check_ritual()
        return

    ..()

/obj/structure/ritual_altar/proc/check_ritual()

    if(cup && heart && !activated)
        activate_ritual()

/obj/structure/ritual_altar/proc/activate_ritual()

    activated = TRUE

    visible_message(span_cult("Алтарь начинает излучать темную, но притягательную энергию."))

    playsound(src, 'modular_bandastation/objects/sounds/darkmagic/ghostwhisper.ogg', 75, TRUE)

    // визуальный эффект
    new /obj/effect/particle_effect/fluid/smoke/sleeping(get_turf(src))

    // небольшая тряска камеры
    for(var/mob/M in viewers(src, 5))
        shake_camera(M, 2, 1)

    sleep(20)

    visible_message(span_cult("Подношения растворяются в облаке кровавой дымки"))

    if(cup)
        qdel(cup)

    if(heart)
        qdel(heart)

    if(target_door)
        target_door.open()
