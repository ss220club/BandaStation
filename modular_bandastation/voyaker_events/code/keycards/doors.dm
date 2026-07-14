/obj/machinery/door/password/keycard
	name = "гермодверь"
	desc = "Для открытия требуется специальная ключ-карта."
	resistance_flags = INDESTRUCTIBLE
	var/required_key = null
	var/open_time = 10 SECONDS

/obj/machinery/door/password/keycard/attack_hand(mob/user)
    if(locked)
        balloon_alert(user, "дверь заперта")
        return TRUE
    return ..()

/obj/machinery/door/password/keycard/attackby(obj/item/I, mob/living/user, params)
    if(!required_key)
        return ..()
    if(!istype(I, required_key))
        balloon_alert(user, "не подходит")
        return TRUE
    if(!density)
        return TRUE
    var/obj/item/keycard/K = I
    if(K.uses_left <= 0)
        balloon_alert(user, "ключ разряжен")
        return TRUE
    K.uses_left--
    to_chat(user, span_notice("Дверь открыта. Закрытие двери произойдёт через 10 секунд..."))
    if(K.uses_left <= 0)
        to_chat(user, span_warning("Ключ-карта исчерпала свой ресурс и рассыпалась."))
        qdel(K)
    open()
    addtimer(CALLBACK(src, PROC_REF(close)), open_time)
    return TRUE

/obj/machinery/door/password/keycard/forest_bunker
	name = "гермоворота бункера"
	required_key = /obj/item/keycard/forest_bunker

/obj/machinery/door/password/keycard/village_base
	name = "гермоворота базы"
	required_key = /obj/item/keycard/nt_commsbuoy/village_base

/obj/machinery/door/password/keycard/mine_exit
	name = "главные ворота шахты"
	required_key = /obj/item/keycard/blue/mine_exit

/obj/machinery/door/password/keycard/administration
	name = "гермодверь административной комнаты"
	required_key = /obj/item/keycard/cafeteria/administration
