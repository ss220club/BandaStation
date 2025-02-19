// Ye old forbidden book, the Codex Cicatrix.
/obj/item/codex_cicatrix
	name = "Codex Cicatrix"
	desc = "Этот тяжелый том полон загадочных каракулей и невозможных диаграмм. \
	Согласно легенде, его можно расшифровать, чтобы раскрыть секреты завесы между мирами."
	icon = 'icons/obj/antags/eldritch.dmi'
	base_icon_state = "book"
	icon_state = "book"
	worn_icon_state = "book"
	w_class = WEIGHT_CLASS_SMALL
	/// Helps determine the icon state of this item when it's used on self.
	var/book_open = FALSE

/obj/item/codex_cicatrix/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/effect_remover, \
		success_feedback = "Вы убираете %THEEFFECT.", \
		tip_text = "Очистить руну", \
		on_clear_callback = CALLBACK(src, PROC_REF(after_clear_rune)), \
		effects_we_clear = list(/obj/effect/heretic_rune))

/// Callback for effect_remover component after a rune is deleted
/obj/item/codex_cicatrix/proc/after_clear_rune(obj/effect/target, mob/living/user)
	new /obj/effect/temp_visual/drawing_heretic_rune/fail(target.loc, target.greyscale_colors)

/obj/item/codex_cicatrix/examine(mob/user)
	. = ..()
	if(!IS_HERETIC(user))
		return

	. += span_notice("Может быть использован на влияниях для получения дополнительных очков знаний.")
	. += span_notice("Упрощает начертание или удаление рун трансмутации.")
	. += span_notice("Также, может быть использован как фокусировка, когда находится в руках, но рекомендуется более специализированный для этого предмет, так как этот может выпасть во время боя.")

/obj/item/codex_cicatrix/attack_self(mob/user, modifiers)
	. = ..()
	if(.)
		return

	if(book_open)
		close_animation()
		RemoveElement(/datum/element/heretic_focus)
		update_weight_class(WEIGHT_CLASS_SMALL)
	else
		open_animation()
		AddElement(/datum/element/heretic_focus)
		update_weight_class(WEIGHT_CLASS_NORMAL)

/obj/item/codex_cicatrix/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	var/datum/antagonist/heretic/heretic_datum = GET_HERETIC(user)
	if(!heretic_datum)
		return NONE
	if(isopenturf(interacting_with))
		var/obj/effect/heretic_influence/influence = locate(/obj/effect/heretic_influence) in interacting_with
		if(!influence?.drain_influence_with_codex(user, src))
			heretic_datum.try_draw_rune(user, interacting_with, drawing_time = 8 SECONDS)
		return ITEM_INTERACT_BLOCKING
	return NONE

/// Plays a little animation that shows the book opening and closing.
/obj/item/codex_cicatrix/proc/open_animation()
	icon_state = "[base_icon_state]_open"
	flick("[base_icon_state]_opening", src)
	book_open = TRUE

/// Plays a closing animation and resets the icon state.
/obj/item/codex_cicatrix/proc/close_animation()
	icon_state = base_icon_state
	flick("[base_icon_state]_closing", src)
	book_open = FALSE
