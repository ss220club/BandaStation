// MARK: Misc Objects
// Декор
/obj/structure/shipping_container/kosmologistika/crates
	name = "ящики"
	desc = "Груда ящиков с различным содержимым."
	icon = 'modular_bandastation/events/avangarde17/icons/crates.dmi'
	icon_state = "crates"

/obj/structure/guncase/akm
	name = "AKM locker"
	desc = "A locker that holds modern Sable AKM."
	case_type = "AKM"
	gun_category = /obj/item/gun/ballistic/automatic/sabel/auto/modern/no_mag

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

/obj/item/dark_book/attack_self(mob/user)
	if(!user) return FALSE
	to_chat(user, span_hypnophrase("Вам неизвестен этот язык."))
	return TRUE

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
/obj/structure/rack/shelves
	name = "полки"
	desc = "Для всякой всячины."
	icon = 'modular_bandastation/events/avangarde17/icons/obj.dmi'
	icon_state = "empty_shelf_1"
	custom_materials = list(/datum/material/wood = SHEET_MATERIAL_AMOUNT)

/obj/structure/rack/shelves/style2
	name = "полки"
	icon_state = "empty_shelf_2"

/obj/structure/rack/shelves/style3
	name = "полки"
	icon_state = "empty_shelf_3"

// Кран без трубы
/obj/structure/sink/shell_only
	icon = 'modular_bandastation/events/avangarde17/icons/obj.dmi'
	icon_state = "sink_new"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sink/shell_only, (-16))
