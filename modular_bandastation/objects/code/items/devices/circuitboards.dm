/obj/item/integrated_circuit/attackby(obj/item/I, mob/user, params)
    if(istype(I, /obj/item/concert_remote))
        var/obj/item/concert_remote/P = I
        P.try_toggle_on(src, user)
        return TRUE
    return ..()
