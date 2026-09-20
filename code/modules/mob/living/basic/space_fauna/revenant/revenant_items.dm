//reforming
/obj/item/ectoplasm/revenant
	name = "glimmering residue"
	desc = "Кучка мелкой голубой пыли. Вокруг неё кружатся маленькие завитки фиолетового тумана."
	icon = 'icons/effects/effects.dmi'
	icon_state = "revenantEctoplasm"
	w_class = WEIGHT_CLASS_SMALL
	// Can the revenant reform?
	var/inert = FALSE

/obj/item/ectoplasm/revenant/Initialize(mapload, revenant)
	. = ..()
	inert = !revenant
	if(revenant)
		AddComponent(/datum/component/revenant_prison, revenant = revenant)
		addtimer(CALLBACK(src, PROC_REF(reform)), 1 MINUTES)

/obj/item/ectoplasm/revenant/Destroy()
	return ..()

/obj/item/ectoplasm/revenant/attack_self(mob/user)
	if(inert)
		return ..()
	user.visible_message(
		span_notice("[user] разбрасывает [declent_ru(ACCUSATIVE)] во все стороны."),
		span_notice("Вы разбрасываете [declent_ru(ACCUSATIVE)] по всей области. Частицы медленно исчезают."),
	)
	user.dropItemToGround(src)
	SEND_SIGNAL(src, COMSIG_RESIDUE_DISPERSE)
	qdel(src)

/obj/item/ectoplasm/revenant/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(inert)
		return
	visible_message(span_notice("[declent_ru(ACCUSATIVE)] при ударе распадается на частицы, которые исчезают, превращаясь в ничто."))
	SEND_SIGNAL(src, COMSIG_RESIDUE_DISPERSE)
	qdel(src)

/obj/item/ectoplasm/revenant/examine(mob/user)
	. = ..()
	if(inert)
		. += span_revennotice("Он кажется инертным.")
	else
		. += span_revenwarning("Он смещается и искажается. Было бы разумно уничтожить это.")

/obj/item/ectoplasm/revenant/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] вдыхает [declent_ru(ACCUSATIVE)]! Кажется, [user.ru_p_they()] пытается попасть в царство теней!"))
	qdel(src)
	return OXYLOSS

/// Actually moves the revenant out of ourself
/obj/item/ectoplasm/revenant/proc/reform()
	if(QDELETED(src) || inert)
		return
	if(!(SEND_SIGNAL(src, COMSIG_RESIDUE_REFORM) & COMPONENT_RESIDUE_REFORM_SUCCESS))
		inert = TRUE
		return
	message_admins("Revenant ectoplasm was left undestroyed for 1 minute and is reforming into a new revenant.")
	visible_message(span_revenboldnotice("[src] внезапно взмывает в воздух, прежде чем исчезнуть."))
	qdel(src)
