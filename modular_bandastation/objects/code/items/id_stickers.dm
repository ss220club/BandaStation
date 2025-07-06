/obj/item/card/id/advanced
	var/obj/item/id_sticker/applied_sticker = null

/obj/item/card/id/advanced/Destroy()
	if(applied_sticker)
		QDEL_NULL(applied_sticker)
	. = ..()

/obj/item/card/id/advanced/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = ..()
	if(!istype(tool, /obj/item/id_sticker))
		return NONE

	if(applied_sticker)
		to_chat(user, span_warning("На ID карте уже есть наклейка, сначала снимите её!"))
		return ITEM_INTERACT_BLOCKING

	to_chat(user, span_notice("Вы начинаете наносить наклейку на ID карту."))
	if(!do_after(user, 2 SECONDS, src))
		return ITEM_INTERACT_BLOCKING
	apply_sticker(user, tool)

/obj/item/card/id/advanced/examine(mob/user)
	. = ..()
	if(applied_sticker)
		. += "На ней [applied_sticker.declent_ru(NOMINATIVE)]"
		. += span_info("Вы можете снять наклейку, используя <b>Ctrl-Shift-Click</b>.")

/obj/item/card/id/advanced/click_ctrl_shift(mob/living/user)
	. = ..()
	if(HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		to_chat(user, span_warning("Ваши руки должны быть свободны, чтобы сделать это!"))
		return
	if(!applied_sticker)
		to_chat(user, span_warning("На ID карте нет наклейки!"))
		return
	if(user.combat_mode)
		to_chat(user, span_notice("Вы сдираете наклейку с ID карты!"))
		playsound(src, 'sound/items/poster/poster_ripped.ogg', 100, TRUE)
		qdel(remove_sticker())
		return

	to_chat(user, span_notice("Вы пытаетесь снять наклейку с ID карты..."))
	if(do_after(user, 5 SECONDS, src))
		to_chat(user, span_notice("Вы сняли наклейку с ID карты."))
		user.put_in_hands(remove_sticker())

/obj/item/card/id/advanced/update_overlays()
	. = ..()
	if(applied_sticker)
		var/mutable_appearance/sticker_overlay = mutable_appearance(applied_sticker.icon, applied_sticker.icon_state)
		. += sticker_overlay

/obj/item/card/id/advanced/update_desc(updates)
	. = ..()
	if(applied_sticker?.id_card_desc)
		desc = "[src::desc]<br>[applied_sticker.id_card_desc]"
	else
		desc = src::desc

/obj/item/card/id/advanced/proc/apply_sticker(mob/user, obj/item/id_sticker/sticker)
	sticker.forceMove(src)
	applied_sticker = sticker
	update_appearance(UPDATE_OVERLAYS|UPDATE_DESC)
	to_chat(user, span_notice("Вы наклеили [sticker.declent_ru(ACCUSATIVE)] на ID карту."))
	RegisterSignal(sticker, COMSIG_QDELETING, PROC_REF(on_applied_sticker_qdeleting))

/obj/item/card/id/advanced/proc/on_applied_sticker_qdeleting()
	SIGNAL_HANDLER

	remove_sticker()

/obj/item/card/id/advanced/proc/remove_sticker()
	var/obj/item/id_sticker/removed_sticker = applied_sticker
	applied_sticker = null
	update_appearance(UPDATE_OVERLAYS|UPDATE_DESC)
	UnregisterSignal(removed_sticker, COMSIG_QDELETING)
	return removed_sticker

/obj/machinery/pdapainter/attackby(obj/item/O, mob/living/user, params)
	if(istype(O, /obj/item/card/id/advanced))
		var/obj/item/card/id/advanced/card = O
		if(card.applied_sticker)
			to_chat(user, span_warning("ID карта со стикером не может быть покрашена!"))
			return
	. = ..()

/obj/item/id_sticker
	name = "ID sticker"
	desc = "Этим можно изменить внешний вид своей карты! Покажи службе безопасности какой ты стильный."
	icon = 'modular_bandastation/objects/icons/obj/items/id_stickers.dmi'
	icon_state = ""
	w_class = WEIGHT_CLASS_SMALL
	var/id_card_desc

/obj/item/id_sticker/colored
	name = "holographic ID sticker"
	desc = "Голографическая наклейка на карту. Вы можете выбрать цвет который она примет."
	icon_state = "colored"
	var/static/list/color_list = list(
		"Красный" = COLOR_RED_LIGHT,
		"Зелёный" = LIGHT_COLOR_GREEN,
		"Синий" = LIGHT_COLOR_BLUE,
		"Жёлтый" = COLOR_VIVID_YELLOW,
		"Оранжевый" = LIGHT_COLOR_ORANGE,
		"Фиолетовый" = LIGHT_COLOR_LAVENDER,
		"Голубой" = LIGHT_COLOR_LIGHT_CYAN,
		"Циановый" = LIGHT_COLOR_CYAN,
		"Аквамариновый" = LIGHT_COLOR_BLUEGREEN,
		"Розовый" = LIGHT_COLOR_PINK
	)
	greyscale_config = /datum/greyscale_config/id_sticker
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/id_sticker/colored/Initialize(mapload)
	. = ..()
	set_greyscale(color_list[pick(color_list)])

/obj/item/id_sticker/colored/attack_self(mob/living)
	var/choice = tgui_input_list(usr, "Какой цвет предпочитаете?", "Выбор цвета", list("Выбрать предустановленный", "Выбрать вручную"))
	if(!choice)
		return
	switch(choice)
		if("Выбрать предустановленный")
			choice = tgui_input_list(usr, "Выберите цвет", "Выбор цвета", color_list)
			var/color_to_set = color_list[choice]
			if(!color_to_set)
				return

			set_greyscale(color_to_set)

		if("Выбрать вручную")
			set_greyscale(input(usr, "Выберите цвет") as color)

/obj/item/id_sticker/donut
	name = "donut ID sticker"
	icon_state = "donut"
	id_card_desc = "С глазурью!"

/obj/item/id_sticker/silver
	name = "silver ID sticker"
	icon_state = "silver"

/obj/item/id_sticker/colored/silver
	name = "silver holographic ID sticker"
	desc = "Голографическая наклейка на карту, изготовленная из специального материала, похожего на серебро. Вы можете выбрать цвет который она примет."
	icon_state = "colored_silver"
	greyscale_config = /datum/greyscale_config/id_sticker/silver

/obj/item/id_sticker/gold
	name = "gold ID sticker"
	desc = "Можно продать какому-то дураку за баснословные деньги. Ой..."
	icon_state = "gold"

/obj/item/id_sticker/business
	name = "businessman ID sticker"
	desc = "Осталось раздобыть портмоне и стильный костюм."
	icon_state = "business"

/obj/item/id_sticker/lifetime
	name = "stylish ID sticker"
	desc = "Ничего особенного, но что-то в этом есть..."
	icon_state = "lifetime"

/obj/item/id_sticker/ussp
	name = "communistic ID sticker"
	desc = "Партия гордится вами! Возьмите своя миска-рис в ближайшем баре."
	icon_state = "ussp"

/obj/item/id_sticker/clown
	name = "clownish ID sticker"
	desc = "HONK!"
	icon_state = "clown"
	id_card_desc = "HONK!"

/obj/item/id_sticker/neon
	name = "neon ID sticker"
	desc = "Неоновая наклейка в цианово-розовых цветах."
	icon_state = "neon"
	id_card_desc = "Кажется будто она светится."

/obj/item/id_sticker/colored/neon
	name = "neon holographic ID sticker"
	desc = "Какая же она яркая... Ещё и цвета меняет!"
	icon_state = "colored_neon"
	id_card_desc = "Кажется будто она светится."
	greyscale_config = /datum/greyscale_config/id_sticker/neon

/obj/item/id_sticker/missing
	name = "black-and-pink ID sticker"
	desc = "Текстура пропала..."
	icon_state = "missing"
	id_card_desc = "А где?"

/obj/item/id_sticker/ouija
	name = "Ouija ID sticker"
	desc = "Ходят легенты, что тот кто наклеит это на карту, может общаться с духами..."
	icon_state = "ouija"
	id_card_desc = "Умеет ли он общаться с призраками?"

/obj/item/id_sticker/paradise
	name = "beach ID sticker"
	desc = "Хола!"
	icon_state = "paradise"

/obj/item/id_sticker/rainbow
	name = "rainbow ID sticker"
	desc = "Переливается всеми цветами радуги!"
	icon_state = "rainbow"
	id_card_desc = "Одобряемо."

/obj/item/id_sticker/space
	name = "SPACE ID sticker"
	desc = "Яркая, блестящая и бескрайняя. Прямо как хозяин карты на которую её приклеят."
	icon_state = "space"
	id_card_desc = "Есть 3 вещи на которые можно смотреть вечно. Это четвёртая."

/obj/item/id_sticker/kitty
	name = "cat ID sticker"
	desc = "Прекрасная наклейка, которая делает вашу карту похожей на котика. UwU."
	icon_state = "kitty"
	id_card_desc = "Так и хочется погладить, жаль это всего-лишь наклейка..."

/obj/item/id_sticker/colored/kitty
	name = "cat holographic ID sticker"
	desc = "Прекрасная наклейка, которая делает вашу карту похожей на котика. Эта может менять цвет."
	icon_state = "colored_kitty"
	id_card_desc = "Так и хочется погладить, жаль это всего-лишь наклейка..."
	greyscale_config = /datum/greyscale_config/id_sticker/kitty

/obj/item/id_sticker/cursedmiku
	name = "anime ID sticker"
	desc = "Kawaii!!!"
	icon_state = "cursedmiku"
	id_card_desc = "AYAYA!"

/obj/item/id_sticker/colored/snake
	name = "running ID sticker"
	desc = "Она что-то загружает?"
	icon_state = "snake"
	id_card_desc = "Бегает и бегает..."
	greyscale_config = /datum/greyscale_config/id_sticker/snake

/obj/item/id_sticker/magic
	name = "magical ID sticker"
	desc = "EI NATH!"
	icon_state = "magic"
	id_card_desc = "Кто-то до сих пор девственник..."

/obj/item/id_sticker/terminal
	name = "terminal ID sticker"
	desc = "HACKERMAN."
	icon_state = "terminal"
	id_card_desc = "Эта карта похожа на терминал."

/obj/item/id_sticker/jokerge
	name = "jokerge ID sticker"
	desc = "Jokerge."
	icon_state = "jokerge"
	id_card_desc = "Jokerge."

/obj/item/id_sticker/boykisser
	name = "boykisser ID sticker"
	desc = "Наклеив её на карту, у вас с почти 100% вероятностью, появится желание целовать мальчиков."
	icon_state = "boykisser"
	id_card_desc = "Он любит целовать мальчиков."

/datum/supply_pack/misc/id_stickers
	name = "ID stickers"
	desc = "Хотите выделиться среди всех работников? Тогда покупайте эти замечательные наклейки на вашу ID карту!"
	crate_type = /obj/structure/closet/crate/wooden
	cost = CARGO_CRATE_VALUE * 18
	contains = list(/obj/effect/spawner/random/id_stickers = 5)
	crate_name = "ID stickers crate"
