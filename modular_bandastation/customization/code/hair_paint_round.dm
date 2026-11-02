/mob/living/carbon/human/proc/vv_edit_hair_paint()
	if(!check_rights(R_VAREDIT))
		return
	var/mob/editor_user = usr
	var/choice = tgui_alert(editor_user, "Что раскрасить?", "Редактор внешности", list("Волосы", "Бороду"))
	if(!choice || !check_rights_for(editor_user?.client, R_VAREDIT))
		return
	open_hair_paint_editor(editor_user, facial = choice == "Бороду")

/mob/living/carbon/human/proc/open_hair_paint_editor(mob/user, facial = FALSE, obj/item/dyespray/spray)
	if(!user?.client || !dna?.species)
		return
	var/datum/hair_paint_editor/in_round/editor = new(src, user, facial, spray)
	if(!editor.prepare() || editor.ui_status(user) != UI_INTERACTIVE || !editor.character_unchanged())
		to_chat(user, span_warning("Редактор недоступен. Проверьте, что волосы видны и персонаж не изменился."))
		qdel(editor)
		return
	editor.ui_interact(user)

/datum/hair_paint_editor/in_round
	close_on_submit = TRUE
	var/datum/weakref/target_ref
	var/datum/weakref/actor_ref
	var/datum/weakref/client_ref
	var/datum/weakref/spray_ref
	var/admin_edit = FALSE

/datum/hair_paint_editor/in_round/New(mob/living/carbon/human/target, mob/user, facial = FALSE, obj/item/dyespray/spray)
	..(null, null, facial)
	target_ref = WEAKREF(target)
	actor_ref = WEAKREF(user)
	client_ref = WEAKREF(user.client)
	if(spray)
		spray_ref = WEAKREF(spray)
	admin_edit = isnull(spray)
	species = "[target.dna.species.type]"
	var/obj/item/bodypart/head/head = target.get_bodypart(BODY_ZONE_HEAD)
	style = facial ? head?.facial_hairstyle : head?.hairstyle
	character_state = current_character_state()

/datum/hair_paint_editor/in_round/Destroy()
	target_ref = null
	actor_ref = null
	client_ref = null
	spray_ref = null
	return ..()

/datum/hair_paint_editor/in_round/proc/current_character_state()
	var/mob/living/carbon/human/target = target_ref.resolve()
	var/obj/item/bodypart/head/head = target?.get_bodypart(BODY_ZONE_HEAD)
	if(!head || !target.dna || HAS_TRAIT(target, facial ? TRAIT_SHAVED : TRAIT_BALD))
		return null
	if(!facial && !target.get_organ_slot(ORGAN_SLOT_BRAIN) && (head.head_flags & HEAD_DEBRAIN))
		return null
	var/gradient_key = facial ? GRADIENT_FACIAL_HAIR_KEY : GRADIENT_HAIR_KEY
	return json_encode(list(
		"dna" = REF(target.dna),
		"head" = REF(head),
		"species" = "[target.dna.species.type]",
		"style" = facial ? head.facial_hairstyle : head.hairstyle,
		"color" = facial ? head.facial_hair_color : head.hair_color,
		"gradient_style" = head.get_hair_gradient_style(gradient_key),
		"gradient_color" = head.get_hair_gradient_color(gradient_key),
		"alpha" = facial ? head.facial_hair_alpha : head.hair_alpha,
		"fixed_color" = head.fixed_hair_color,
		"override_color" = head.override_hair_color,
		"flags" = head.head_flags,
		"husked" = head.is_husked,
		"invisible" = head.is_invisible,
		"obscured" = target.obscured_slots & (facial ? HIDEFACIALHAIR : HIDEHAIR),
		"hair_masks" = target.hair_masks,
		"species_mask" = "[head.species_hair_mask]",
		"offset_x" = head.worn_face_offset?.offset_x,
		"offset_y" = head.worn_face_offset?.offset_y,
		"paint" = facial ? head.facial_hair_paint : head.hair_paint,
	))

/datum/hair_paint_editor/in_round/character_unchanged()
	return !isnull(character_state) && current_character_state() == character_state

/datum/hair_paint_editor/in_round/ui_status(mob/user, datum/ui_state/state)
	if(!user?.client || user != actor_ref?.resolve() || user.client != client_ref?.resolve() || !target_ref?.resolve())
		return UI_CLOSE
	if(admin_edit)
		return check_rights_for(user.client, R_VAREDIT) ? UI_INTERACTIVE : UI_CLOSE
	var/obj/item/dyespray/spray = spray_ref?.resolve()
	var/mob/living/carbon/human/target = target_ref.resolve()
	if(!spray || !spray.IsReachableBy(user) || !target.IsReachableBy(user))
		return UI_CLOSE
	return UI_INTERACTIVE

/datum/hair_paint_editor/in_round/prepare()
	var/mob/user = actor_ref.resolve()
	if(ui_status(user) != UI_INTERACTIVE || !character_unchanged())
		return FALSE
	var/obj/item/dyespray/spray = spray_ref?.resolve()
	if(!admin_edit && !user.can_perform_action(spray, NEED_DEXTERITY))
		return FALSE
	var/mob/living/carbon/human/target = target_ref.resolve()
	var/obj/item/bodypart/head/head = target.get_bodypart(BODY_ZONE_HEAD)
	var/list/paint = facial ? head.facial_hair_paint : head.hair_paint
	if(!head.hair_paint_matches(paint, facial))
		paint = list()
	return prepare_preview(target, paint)

/datum/hair_paint_editor/in_round/save_paint(list/paint, mob/user)
	if(ui_status(user) != UI_INTERACTIVE || !character_unchanged())
		return FALSE
	var/mob/living/carbon/human/target = target_ref.resolve()
	var/obj/item/dyespray/spray = spray_ref?.resolve()
	if(!admin_edit)
		if(!user.can_perform_action(spray, NEED_DEXTERITY))
			return FALSE
		to_chat(user, span_notice("Вы начинаете наносить краску..."))
		if(!do_after(user, 3 SECONDS, target))
			return FALSE
		if(ui_status(user) != UI_INTERACTIVE || !character_unchanged() || !user.can_perform_action(spray, NEED_DEXTERITY))
			return FALSE
	var/obj/item/bodypart/head/head = target.get_bodypart(BODY_ZONE_HEAD)
	var/gradient_key = facial ? GRADIENT_FACIAL_HAIR_KEY : GRADIENT_HAIR_KEY
	paint["base_color"] = facial ? head.facial_hair_color : head.hair_color
	paint["gradient_style"] = head.get_hair_gradient_style(gradient_key)
	paint["gradient_color"] = head.get_hair_gradient_color(gradient_key)
	target.dna.features[facial ? "facial_hair_paint" : "hair_paint"] = paint
	if(facial)
		target.facial_hair_paint = paint
		head.facial_hair_paint = paint
	else
		target.hair_paint = paint
		head.hair_paint = paint
	var/list/identity_blocks = facial \
		? list(/datum/dna_block/identity/facial_style, /datum/dna_block/identity/facial_color, /datum/dna_block/identity/facial_gradient, /datum/dna_block/identity/facial_gradient_color) \
		: list(/datum/dna_block/identity/hair_style, /datum/dna_block/identity/hair_color, /datum/dna_block/identity/hair_gradient, /datum/dna_block/identity/hair_gradient_color)
	for(var/block in identity_blocks)
		target.dna.update_ui_block(block)
	target.update_hair()
	if(admin_edit)
		log_admin("[key_name(user)] edited [facial ? "beard" : "hair"] paint of [key_name(target)] via VV.")
		message_admins("[key_name_admin(user)] edited [facial ? "beard" : "hair"] paint of [key_name_admin(target)] via VV.")
	else
		log_combat(user, target, "painted [facial ? "beard" : "hair"] of", spray)
		playsound(target, 'sound/effects/spray.ogg', 10, vary = TRUE)
	return TRUE
