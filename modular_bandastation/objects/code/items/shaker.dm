/obj/item/reagent_containers/cup/glass/shaker
	icon = 'modular_bandastation/objects/icons/obj/items/drinks.dmi'
	icon_state = "shaker"
	var/shaking_sound = 'modular_bandastation/objects/sounds/boston_shaker.ogg'
	COOLDOWN_DECLARE(shaking_cooldown)

/obj/item/reagent_containers/cup/glass/shaker/Initialize(mapload)
	. = ..()
	reagents.set_reacting(FALSE)
	register_item_context()

/obj/item/reagent_containers/cup/glass/shaker/examine(mob/user)
	. = ..()
	. += span_notice("Реагенты внутри не смешиваются, пока [declent_ru(NOMINATIVE)] не потрясут.")
	. += span_notice("Использовать в руке - трясти.")

/obj/item/reagent_containers/cup/glass/shaker/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(user.get_inactive_held_item() == src)
		context[SCREENTIP_CONTEXT_LMB] = "Трясти"
		return CONTEXTUAL_SCREENTIP_SET

/obj/item/reagent_containers/cup/glass/shaker/proc/try_shake(mob/user)
	if(!reagents.total_volume)
		to_chat(user, span_warning("[capitalize(declent_ru(NOMINATIVE))] пуст!"))
		return FALSE

	if(!COOLDOWN_FINISHED(src, shaking_cooldown))
		to_chat(user, span_warning("Я только что тряс [capitalize(declent_ru(ACCUSATIVE))]! Нужно дать руке немного отдохнуть."))
		return FALSE

	var/adjective = pick("яростно", "страстно", "энергично", "решительно", "как дьявол", "с заботой и любовью", "как будто завтра не наступит")
	user.visible_message(span_notice("[user] [adjective] трясет [declent_ru(ACCUSATIVE)]!"), span_notice("Вы [adjective] трясете [declent_ru(ACCUSATIVE)]!"))
	icon_state = "[initial(icon_state)]-shaking"
	playsound(user, shaking_sound, 80, TRUE)
	COOLDOWN_START(src, shaking_cooldown, 3 SECONDS)

	if(do_after(user, 3 SECONDS, src, IGNORE_USER_LOC_CHANGE, max_interact_count = 1))
		reagents.set_reacting(TRUE)
		reagents.handle_reactions()

	icon_state = initial(icon_state)
	reagents.set_reacting(FALSE)

	return TRUE

/obj/item/reagent_containers/cup/glass/shaker/attack_self(mob/user)
	. = ..()
	try_shake(user)
