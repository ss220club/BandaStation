#define PANEL_OPEN 0
#define WIRES_DISCONNECTED 1
#define LOCK_OFF 2

/obj/structure/closet
	var/picklocking_stage

/obj/structure/closet/examine(mob/user)
	. = ..()
	switch(picklocking_stage)
		if(PANEL_OPEN)
			. += span_notice("Панель управления снята.")
		if(WIRES_DISCONNECTED)
			. += span_notice("Панель управления снята.")
			. += span_notice("Провода отключены и торчат наружу.")
		if(LOCK_OFF)
			. += span_notice("Панель управления снята.")
			. += span_notice("Провода отключены и торчат наружу.")
			. += span_notice("Замок отключён.")

/obj/structure/closet/secure_closet/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(locked && picklocking_stage == null && !user.combat_mode)
		to_chat(user, span_notice("Вы начинаете откручивать панель замка..."))
		balloon_alert(user, "снятие панели...")
		if(I.use_tool(src, user, 16 SECONDS, volume = 50))
			if(prob(95))
				broken = TRUE
				picklocking_stage = PANEL_OPEN
				update_icon()
				to_chat(user, span_notice("Вы успешно открутили и сняли панель с замка!"))
				balloon_alert(user, "панель снята")
			else
				user.apply_damage(5, BRUTE, user.get_inactive_hand())
				user.emote("scream")
				to_chat(user, span_warning("Проклятье! [I.declent_ru(ACCUSATIVE)] сорвалась и повредила руку!"))
				balloon_alert(user, "неудача!")
		return TRUE

/obj/structure/closet/secure_closet/wirecutter_act(mob/living/user, obj/item/I)
	. = ..()
	if(locked && picklocking_stage == PANEL_OPEN && !user.combat_mode)
		to_chat(user, span_notice("Вы начинаете подготавливать провода для взлома..."))
		balloon_alert(user, "подготовка проводов...")
		if(I.use_tool(src, user, 16 SECONDS, volume = 50))
			if(prob(80))
				to_chat(user, span_notice("Вы успешно подготовили провода для взлома!"))
				balloon_alert(user, "провода подготовлены")
				picklocking_stage = WIRES_DISCONNECTED
			else
				to_chat(user, span_warning("Черт! Не тот провод!"))
				balloon_alert(user, "неудача!")
				do_sparks(5, TRUE, src)
				electrocute_mob(user, get_area(src), src, 0.5, TRUE)
		return TRUE

/obj/structure/closet/secure_closet/multitool_act(mob/living/user, obj/item/I)
	. = ..()
	if(locked && picklocking_stage == WIRES_DISCONNECTED && !user.combat_mode)
		to_chat(user, span_notice("Вы начинаете подключаться к проводам [I.declent_ru(INSTRUMENTAL)]..."))
		balloon_alert(user, "подключение проводов...")
		if(I.use_tool(src, user, 16 SECONDS, volume = 50))
			if(prob(80))
				broken = FALSE
				picklocking_stage = LOCK_OFF
				emag_act(user)
			else
				to_chat(user, span_warning("Черт! Не тот провод!"))
				balloon_alert(user, "неудача!")
				do_sparks(5, TRUE, src)
				electrocute_mob(user, get_area(src), src, 0.5, TRUE)
		return TRUE

/obj/structure/closet/crate/secure/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(locked && picklocking_stage == null && !user.combat_mode)
		to_chat(user, span_notice("Вы начинаете откручивать панель замка..."))
		balloon_alert(user, "снятие панели...")
		if(I.use_tool(src, user, 16 SECONDS, volume = 50))
			if(prob(95))
				broken = TRUE
				picklocking_stage = PANEL_OPEN
				update_icon()
				to_chat(user, span_notice("Вы успешно открутили и сняли панель с замка!"))
				balloon_alert(user, "панель снята")
			else
				user.apply_damage(5, BRUTE, user.get_inactive_hand())
				user.emote("scream")
				to_chat(user, span_warning("Проклятье! [I.declent_ru(ACCUSATIVE)] сорвалась и повредила руку!"))
				balloon_alert(user, "неудача!")
		return TRUE

/obj/structure/closet/crate/secure/wirecutter_act(mob/living/user, obj/item/I)
	. = ..()
	if(locked && picklocking_stage == PANEL_OPEN && !user.combat_mode)
		to_chat(user, span_notice("Вы начинаете подготавливать провода для взлома..."))
		if(I.use_tool(src, user, 16 SECONDS, volume = 50))
			if(prob(80))
				to_chat(user, span_notice("Вы успешно подготовили провода панели замка!"))
				balloon_alert(user, "провода подготовлены")
				picklocking_stage = WIRES_DISCONNECTED
			else
				to_chat(user, span_warning("Черт! Не тот провод!"))
				balloon_alert(user, "неудача!")
				do_sparks(5, TRUE, src)
				electrocute_mob(user, get_area(src), src, 0.5, TRUE)
		return TRUE

/obj/structure/closet/crate/secure/multitool_act(mob/living/user, obj/item/I)
	. = ..()
	if(locked && picklocking_stage == WIRES_DISCONNECTED && !user.combat_mode)
		to_chat(user, span_notice("Вы начинаете подключаться к проводам [I.declent_ru(INSTRUMENTAL)]..."))
		balloon_alert(user, "подключение проводов...")
		if(I.use_tool(src, user, 16 SECONDS, volume = 50))
			if(prob(80))
				broken = FALSE
				picklocking_stage = LOCK_OFF
				emag_act(user)
			else
				to_chat(user, span_warning("Черт! Не тот провод!"))
				balloon_alert(user, "неудача!")
				do_sparks(5, TRUE, src)
				electrocute_mob(user, get_area(src), src, 0.5, TRUE)
		return TRUE

#undef PANEL_OPEN
#undef WIRES_DISCONNECTED
#undef LOCK_OFF
