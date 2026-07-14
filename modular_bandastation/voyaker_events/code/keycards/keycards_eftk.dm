/obj/item/keycard
    /// Максимальное количество использований
    var/max_uses = 5
    /// Осталось использований
    var/uses_left = 5

/obj/item/keycard/examine(mob/user)
    . = ..()
    . += span_notice("Оставшиеся открытия: [uses_left]/[max_uses]")

/obj/item/keycard/forest_bunker
	name = "Ключ-карта NB-063"
	desc = "Ключ-карта с обозначением NB-063 на бирке. Обычно такие применялись для открытия секретных бункерных входов НТ в районе Тёмного Леса."
	max_uses = 10
	uses_left = 10

/obj/item/keycard/nt_labs
	name = "Ключ-карта NT Labs"
	icon = 'icons/obj/service/bureaucracy.dmi'
	icon_state = "paperbiscuit_secret"
	desc = "Гладкая пластиковая ключ карта с инициалами NT Labs, которая, судя по всему, открывает дверь в секретный лабораторный объект НаноТрейзен."
	max_uses = 1
	uses_left = 1

/obj/item/keycard/nt_commsbuoy/village_base
	name = "Ключ карта OB-15"
	desc = "Ключ-карта с обозначением OB-15 на бирке. Цвет корпуса и гравировка надписи явно отсылают к тому, что ключ военного образца ТСФ. Возможно, он должен открывать один из их объектов..."
	max_uses = 3
	uses_left = 3

/obj/item/keycard/blue/mine_exit
	name = "Ключ-карта от главного входа шахты NT"
	desc = "Ключ-карта с биркой, которая открывает главные ворота шахты НаноТрейзен."
	max_uses = 5
	uses_left = 5

/obj/item/keycard/cafeteria/administration
	name = "Проржавевшая ключ-карта с круглой пометкой"
	desc = "Довольно старая и ржавая ключ карта с круглой отметкой, похожей на ту, которую обычно оставляет группа Чистильщиков. Возможно, она ведёт в одну из их потайных комнат где-то в Пустошах."
	max_uses = 5
	uses_left = 5
