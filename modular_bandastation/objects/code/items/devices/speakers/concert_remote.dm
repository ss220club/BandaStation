/obj/item/concert_remote
	name = "Concert remote"
	desc = "Пульт линковки концертных устройств."
	icon = 'icons/obj/devices/remote.dmi'
	icon_state = "shuttleremote"

/obj/item/concert_remote
    var/list/obj/item/circuit_component/concert_listener/takers

/obj/item/concert_remote/Initialize(mapload)
    . = ..()
    takers = list()

/obj/item/concert_remote/proc/add_taker(obj/item/circuit_component/concert_listener/L)
	if(!L || takers[L])
		return
	takers += L

/obj/item/concert_remote/proc/remove_taker(obj/item/circuit_component/concert_listener/L)
	if(!L || !takers[L])
		return
	takers -= L

/obj/item/concert_remote/proc/on_component_removed(datum/source, obj/item/circuit_component/removed)
	SIGNAL_HANDLER
	if(istype(removed, /obj/item/circuit_component/concert_listener))
		remove_taker(removed)

/obj/item/concert_remote/proc/find_linked_listener_in_circuit(obj/item/integrated_circuit/circ)
    for(var/obj/item/circuit_component/concert_listener/L in circ.attached_components)
        return L
    return null

/obj/item/concert_remote/proc/try_toggle_on(atom/target, mob/user)
    var/obj/item/integrated_circuit/circ = find_circuit(target)
    if(!circ)
        to_chat(user, span_warning("Здесь нет интегральной схемы."))
        return

    var/obj/item/circuit_component/concert_listener/existing = find_linked_listener_in_circuit(circ)
    if(existing)
        circ.remove_component(existing)
        remove_taker(existing)
        qdel(existing)
        to_chat(user, span_notice("Отвязано. Всего: [length(takers)]."))
        return

    if(length(takers) >= 16)
        to_chat(user, span_warning("Достигнут предел связей."))
        return

    var/obj/item/circuit_component/concert_listener/L = new
    circ.add_component(L)
    add_taker(L)
    to_chat(user, span_notice("Привязано. Всего: [length(takers)]."))

/obj/item/concert_remote/proc/find_circuit(atom/A)
	if(istype(A, /obj/item/integrated_circuit)) return A
	if(ismob(A) || istype(A, /obj/item) || istype(A, /obj/structure))
		for(var/obj/item/integrated_circuit/C in A.contents)
			return C
	return null
