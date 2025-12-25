// MARK: Misc Objects
// Декор
/obj/structure/shipping_container/kosmologistika/crates
	name = "ящики"
	desc = "Груда ящиков с различным содержимым."
	icon = 'modular_bandastation/events/avangarde17/icons/crates.dmi'
	icon_state = "crates"

/obj/structure/lep
	name = "вышка ЛЭП"
	desc = "Молчат..."
	icon = 'modular_bandastation/events/avangarde17/icons/lep.dmi'
	icon_state = "lep"
	layer = ABOVE_MOB_LAYER
	max_integrity = 1000
	anchored = TRUE
	density = TRUE
	bound_width = 64

// БТР - еще поедет...
/obj/structure/btr
	name = "МБМ-67"
	desc = "Многофункциональный бронированный транспорт проекта \"Красноармеец\". Все люки заперты."
	icon = 'modular_bandastation/events/avangarde17/icons/btr.dmi'
	icon_state = "btr"
	max_integrity = 1000
	anchored = TRUE
	density = TRUE
	bound_width = 64
	bound_height = 96

/obj/structure/btr/wrench_act(mob/living/user, obj/item/tool)
	return TRUE

// Колонны, обелиски и прочее из Вторжения 2
/obj/structure/tomb
	name = "колонна из черного камня"
	desc = "От её узоров отходит странная пульсация... Прямо как из ваших снов!"
	icon = 'modular_bandastation/events/avangarde17/icons/32x96_statue.dmi'
	icon_state = "tomb_1"
	max_integrity = 1000
	anchored = TRUE
	density = TRUE
	layer = ABOVE_ALL_MOB_LAYER

/obj/structure/tomb/wrench_act(mob/living/user, obj/item/tool)
	to_chat(user, span_warning("Серьезно?"))
	return TRUE

/obj/structure/tomb/tomb_2
	name = "разрушенная колонна из черного камня"
	desc = "Полуразрушенная колонна из черного камня... Прямо как из ваших снов!"
	icon = 'modular_bandastation/events/avangarde17/icons/32x64_statue.dmi'
	icon_state = "tomb_3"
	layer = BELOW_MOB_LAYER

/obj/structure/tomb/tomb_3
	name = "разрушенная колонна из черного камня"
	desc = "Полуразрушенная колонна из черного камня... Прямо как из ваших снов!"
	icon_state = "tomb_2"

/obj/structure/tomb/obelisk
	name = "чёрный обелиск"
	desc = "Ужасающий черный обелиск, несущий запретные знания в своих письменах."
	icon_state = "obelisk"

/obj/structure/tomb/obelisk_2
	name = "поврежденный чёрный обелиск"
	desc = "Разрушенный ужасающий черный обелиск, несущий запретные знания в своих письменах."
	icon = 'modular_bandastation/events/avangarde17/icons/32x64_statue.dmi'
	icon_state = "obelisk_2"

// Темная книга
/obj/item/dark_book
	name = "тёмная книга"
	desc = "Старый том в тёмном кожаном переплёте, покрытый странными письменами."
	icon = 'icons/obj/service/library.dmi'
	icon_state = "book1"
	w_class = WEIGHT_CLASS_SMALL
	color = "#4b4b4b"
	var/text_in_head = "Вам неизвестен этот язык."

/obj/item/dark_book/attack_self(mob/user)
	if(!user) return FALSE
	to_chat(user, span_hypnophrase(text_in_head))
	return TRUE

/obj/item/dark_book/vedi
	name = "велесова книга"
	desc = "Старый том в светлом кожаном переплёте, покрытый странными письменами."
	icon_state = "book7"
	color = "#c5c81a"
	text = "Вас переполняет память предков!"

// Бетонные баррикады
/obj/structure/barricade/concrete_block
	name = "бетонный блок"
	desc = "Бетонное ограждение. Поможет в качестве укрытия."
	icon = 'modular_bandastation/events/avangarde17/icons/barricade.dmi'
	icon_state = "concrete_block"
	max_integrity = 280
	proj_pass_rate = 40
	pass_flags_self = LETPASSTHROW

/obj/structure/barricade/concrete_block/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/climbable)
	AddElement(/datum/element/elevation, pixel_shift = 12)

// Полочки
/obj/structure/shelves
	name = "полки"
	desc = "Для всякой всячины."
	icon = 'modular_bandastation/events/avangarde17/icons/obj.dmi'
	icon_state = "empty_shelf_1"
	density = TRUE
	anchored = TRUE
	custom_materials = list(/datum/material/wood = SHEET_MATERIAL_AMOUNT)
	max_integrity = 100

/obj/structure/shelves/base_item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = ..()
	if(.)
		return .

	if(tool.item_flags & ABSTRACT)
		return ITEM_INTERACT_BLOCKING

	return shelf_place_act(user, tool, modifiers)

/obj/structure/shelves/proc/shelf_place_act(mob/living/user, obj/item/tool, list/modifiers)
	var/x_offset = 0
	var/y_offset = 0

	if(LAZYACCESS(modifiers, ICON_X) && LAZYACCESS(modifiers, ICON_Y))
		x_offset = clamp(text2num(LAZYACCESS(modifiers, ICON_X)) - 16, -(ICON_SIZE_X * 0.5), ICON_SIZE_X * 0.5)
		y_offset = clamp(text2num(LAZYACCESS(modifiers, ICON_Y)) - 16, -(ICON_SIZE_Y * 0.5), ICON_SIZE_Y * 0.5)

	if(!user.transfer_item_to_turf(tool, get_turf(src), x_offset, y_offset, silent = FALSE))
		return ITEM_INTERACT_BLOCKING

	AfterPutItemOnShelf(tool, user)
	return ITEM_INTERACT_SUCCESS

/obj/structure/shelves/proc/AfterPutItemOnShelf(obj/item/thing, mob/living/user)
	return

/obj/structure/shelves/wrench_act_secondary(mob/living/user, obj/item/tool)
	tool.play_tool_sound(src)
	drop_planks()
	qdel(src)
	return ITEM_INTERACT_SUCCESS

/obj/structure/shelves/screwdriver_act_secondary(mob/living/user, obj/item/tool)
	tool.play_tool_sound(src)
	drop_planks()
	qdel(src)
	return ITEM_INTERACT_SUCCESS

/obj/structure/shelves/atom_deconstruct(disassembled = TRUE)
	drop_planks()

/obj/structure/shelves/proc/drop_planks()
	new /obj/item/stack/sheet/mineral/wood(get_turf(src), 5)

/obj/structure/shelves/style2
	name = "полки"
	icon_state = "empty_shelf_2"

/obj/structure/shelves/style3
	name = "полки"
	icon_state = "empty_shelf_3"

// Кран без трубы
/obj/structure/sink/shell_only
	icon = 'modular_bandastation/events/avangarde17/icons/obj.dmi'
	icon_state = "sink_new"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sink/shell_only, (-16))

// Мусорки
/obj/structure/closet/crate/trashcart/soviet
	icon = 'modular_bandastation/events/avangarde17/icons/obj.dmi'
	icon_state = "soviettrashcart"
	base_icon_state = "soviettrashcart"
	anchored = TRUE

/obj/structure/closet/crate/trashcart/soviet/fieled

/obj/structure/closet/crate/trashcart/soviet/fieled/Initialize(mapload)
	. = ..()
	if(mapload)
		new /obj/effect/spawner/random/trash/grime(loc)

/obj/structure/closet/crate/trashcart/soviet/fieled/PopulateContents()
	. = ..()
	for(var/i in 1 to rand(7,15))
		new /obj/effect/spawner/random/trash/garbage(src)
		if(prob(12))
			new /obj/item/storage/bag/trash/filled(src)

// Bus
/obj/structure/bus
	name = "ЗИЛ - 220"
	desc = "На нём вы приехали в ПГТ \"Зорька\"! Водитель отошел за сигаретами, так что на скорый отъезд не расчитывайте."
	icon = 'modular_bandastation/events/avangarde17/icons/bus.dmi'
	icon_state = "bus"
	max_integrity = 1000
	anchored = TRUE
	density = TRUE
	bound_width = 192
	bound_height = 96

/obj/structure/bus/wrench_act(mob/living/user, obj/item/tool)
	return TRUE

// Calendar
/obj/structure/sign/calendar/ussp
	name = "календарь"
	desc = "Я календарь... Я календарь... Я календарь... Я календарь..."
	icon = 'modular_bandastation/events/avangarde17/icons/obj.dmi'
	icon_state = "calendar_ussp"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/calendar/ussp, 32)

// House stuff
/obj/structure/wheels
	name = "покрышка"
	desc = "Простой и красивый способ украсить двор."
	icon = 'modular_bandastation/events/avangarde17/icons/obj.dmi'
	icon_state = "wheels"
	anchored = TRUE
	density = FALSE

/obj/structure/wheels/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/elevation, pixel_shift = 12)

/obj/structure/wheels/style_2
	name = "клумба"
	desc = "Покрышечное искусство."
	icon_state = "wheels_grass_1"

/obj/structure/wheels/style_3
	name = "клумба"
	desc = "Покрышечное искусство."
	icon_state = "wheels_grass_2"

/obj/structure/wheels/style_4
	name = "клумба"
	desc = "Покрышечное искусство."
	icon_state = "wheels_grass_3"

/obj/structure/wheels/style_5
	name = "клумба"
	desc = "Покрышечное искусство."
	icon_state = "wheels_grass_4"

/obj/structure/toys
	name = "колобок"
	desc = "Смотрит прямо в душу."
	icon = 'modular_bandastation/events/avangarde17/icons/obj.dmi'
	icon_state = "kolobok"
	anchored = TRUE
	density = TRUE
	layer = LOW_ITEM_LAYER

/obj/structure/toys/style_2
	name = "мишутка"
	desc = "О холеро..."
	icon_state = "mishutka"

/obj/structure/toys/style_3
	name = "белый мишутка"
	desc = "Чэто Фредди Фазз бэар..."
	icon_state = "mishutka_2"

/obj/structure/toys/style_4
	name = "ёжик"
	desc = "Все еще в тумане."
	icon_state = "ezhik"

/obj/structure/toys/style_5
	name = "белый лебедь"
	desc = "Очередная жертва покрышечного искусства."
	icon_state = "lebed"

/obj/structure/toys/style_6
	name = "миша"
	desc = "Прямо из сказки, но есть нюанс."
	icon = 'modular_bandastation/events/avangarde17/icons/32x64_statue.dmi'
	icon_state = "misha"

/obj/structure/toys/style_7
	name = "Маша"
	desc = "Прямо из сказки, но есть нюанс."
	icon = 'modular_bandastation/events/avangarde17/icons/32x64_statue.dmi'
	icon_state = "masha"

/obj/structure/toys/style_8
	name = "чебурашка"
	desc = "Я был когда-то странной, игрушкой очень всратой..."
	icon_state = "cheburator"

/obj/structure/walk_sign
	name = "пешеходный знак"
	desc = "Лучше переходить дорогу тут."
	icon = 'modular_bandastation/events/avangarde17/icons/32x64_statue.dmi'
	icon_state = "walk_sign"
	anchored = TRUE
	density = TRUE
	layer = ABOVE_MOB_LAYER

/obj/structure/swings
	name = "качели"
	desc = "Очень травмоопасно."
	icon = 'modular_bandastation/events/avangarde17/icons/64x64_statue.dmi'
	icon_state = "swings"
	anchored = TRUE
	density = TRUE
	layer = ABOVE_MOB_LAYER
	bound_width = 64
	can_buckle = TRUE

/obj/structure/swings/wrench_act(mob/living/user, obj/item/tool)
	return TRUE

/obj/structure/swings/style_2
	icon = 'modular_bandastation/events/avangarde17/icons/64x32_statue.dmi'
	icon_state = "kacheli"
	layer = LOW_ITEM_LAYER

/obj/structure/swings/style_3
	icon = 'modular_bandastation/events/avangarde17/icons/64x64_statue.dmi'
	icon_state = "gorka"
	layer = ABOVE_MOB_LAYER
	can_buckle = FALSE

// WISE TREE
/obj/structure/flora/tree/jungle/wise
	name = "ведическое древо"
	desc = "Дедушка, ты что, эллизиец?"
	icon = 'modular_bandastation/events/avangarde17/icons/128x160.dmi'
	icon_state = "wise_tree"
	pixel_x = -48
	pixel_y = -20

//LAMPPOST
/obj/structure/lamppost
	name = "фонарный столб"
	desc = "Типовое уличное освещение - залог безопасных дворов!"
	icon = 'modular_bandastation/events/avangarde17/icons/32x96_statue.dmi'
	anchored = TRUE
	density = TRUE
	icon_state = "lamppost"
	base_icon_state = "lamppost"
	light_range = 8
	light_power = 1.5
	light_color = "#cbcbc3"
	layer = ABOVE_MOB_LAYER

/obj/structure/lamppost/wrench_act(mob/living/user, obj/item/tool)
	return TRUE

//CIGPACK RENAME
/obj/item/storage/fancy/cigarettes/cigpack_robust
	name = "сигареты ''Прима''"
	desc = "Как в детстве."

/obj/item/cigarette/robust
	desc = "Сигарета ''Прима''."

/obj/item/storage/fancy/cigarettes/cigpack_uplift
	name = "папиросы ''Беломорканал''"
	desc = "Острожно! От одной затяжки можно выплевать лёгкие."

/obj/item/cigarette/uplift
	desc = "Папироска ''Беломорканал''."

/obj/machinery/vending/cigarette/ussp
	name = "сигаретный автомат"
	product_slogans = "Космосигареты хороши на вкус, какими они и должны быть.;Курение убивает, но не сегодня!;Курите!;Не верьте исследованиям - курите сегодня!"
	product_ads = "Наверняка не вредно!;Не верьте ученым!;На здоровье!;Не бросайте курить, купите ещё!;Курите!;Никотиновый рай.;Лучшие сигареты с 2150 года.;Сигареты с множеством наград."
	products = list(
		/obj/item/storage/fancy/cigarettes/cigpack_uplift = 15,
		/obj/item/storage/fancy/cigarettes/cigpack_robust = 15,
	)
	premium = list(
		/obj/item/storage/box/matches = 10,
		/obj/item/lighter = 3,
	)
	refill_canister = /obj/item/vending_refill/cigarette/syndicate
