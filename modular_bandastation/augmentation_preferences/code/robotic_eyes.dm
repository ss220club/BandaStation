/obj/effect/abstract/eye_glow_light
	name = "eye glow"
	anchored = TRUE
	light_system = OVERLAY_LIGHT_DIRECTIONAL
	light_range = 1.5
	light_power = 0.6
	light_on = FALSE

/// Roundstart augments retain the selected eye colors and Paradise's unblurred eye shine.
/obj/item/organ/eyes/robotic/basic/augmented
	eye_color_left = null
	eye_color_right = null
	eye_icon = 'modular_bandastation/augmentation_preferences/icons/human_face.dmi'
	eye_icon_state = "eyes_glow_gs"
	iris_overlay = "eyes_cyber_glow_iris"
	organ_traits = list(TRAIT_LUMINESCENT_EYES)
	var/obj/effect/abstract/eye_glow_light/glow_light
	/// Видимое свечение-конус. Не влияет на эмиссивный оверлей самих глаз.
	var/datum/light_overlay/glow_visual
	/// Включено ли свечение игроком; сохраняется при извлечении и установке глаз.
	var/glow_enabled = TRUE
	var/datum/action/innate/eye_glow_toggle/glow_action
	/// На сколько тайлов конус вынесен вперёд (0 — центр на персонаже).
	var/glow_cast_range = 0.5
	/// Подъём маски в пикселях, чтобы центр был на уровне лица.
	var/glow_pixel_y = 12

/obj/item/organ/eyes/robotic/basic/augmented/Destroy()
	QDEL_NULL(glow_visual)
	QDEL_NULL(glow_action)
	return ..()

/obj/item/organ/eyes/robotic/basic/augmented/on_mob_insert(mob/living/carbon/eye_owner, special, movement_flags)
	. = ..()
	QDEL_NULL(glow_visual)
	glow_visual = new(eye_owner, TRUE, FALSE) // parent = моб, направленный, не луч
	glow_visual.set_range(1.5)
	glow_visual.set_power(0.6)
	apply_head_offset()
	update_glow()
	if(!glow_action)
		glow_action = new(src)
	glow_action.Grant(eye_owner)

/obj/item/organ/eyes/robotic/basic/augmented/on_mob_remove(mob/living/carbon/eye_owner, special, movement_flags)
	QDEL_NULL(glow_visual)
	QDEL_NULL(glow_action)
	return ..()

/obj/item/organ/eyes/robotic/basic/augmented/on_begin_failure()
	. = ..()
	update_glow()

/obj/item/organ/eyes/robotic/basic/augmented/on_failure_recovery()
	. = ..()
	update_glow()

/obj/item/organ/eyes/robotic/basic/augmented/proc/apply_head_offset()
	if(!glow_visual)
		return
	glow_visual.cast_range = glow_cast_range
	glow_visual.hide_from_holder()
	glow_visual.visible_mask.pixel_y = glow_pixel_y
	glow_visual.cone?.pixel_y = glow_pixel_y
	glow_visual.show_to_holder()
	glow_visual.update_directional_light()

/obj/item/organ/eyes/robotic/basic/augmented/proc/update_glow()
	if(!glow_visual)
		return
	var/left = eye_color_left || COLOR_WHITE
	var/right = eye_color_right || left
	glow_visual.set_color(BlendRGB(left, right, 0.5))
	if(glow_enabled && !(organ_flags & (ORGAN_FAILING | ORGAN_EMP)))
		glow_visual.turn_on()
	else
		glow_visual.turn_off()

/obj/item/organ/eyes/robotic/basic/augmented/proc/set_glow_enabled(enabled)
	glow_enabled = enabled
	update_glow()
	owner?.balloon_alert(owner, enabled ? "подсветка включена" : "подсветка выключена")

/obj/item/organ/eyes/robotic/basic/augmented/get_emissive_overlays(mutable_appearance/eye_left, mutable_appearance/eye_right, atom/spokesman)
	return list(
		emissive_appearance(eye_left.icon, eye_left.icon_state, spokesman, -EYES_LAYER, alpha = eye_left.alpha, effect_type = EMISSIVE_NO_BLOOM),
		emissive_appearance(eye_right.icon, eye_right.icon_state, spokesman, -EYES_LAYER, alpha = eye_right.alpha, effect_type = EMISSIVE_NO_BLOOM),
	)

/datum/action/innate/eye_glow_toggle
	name = "Подсветка глаз"
	desc = "Включить или выключить свечение глаз. Внешний вид глаз не меняется."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon = 'icons/mob/actions/actions_mecha.dmi'
	button_icon_state = "mech_lights_on" // по умолчанию glow_enabled = TRUE

/datum/action/innate/eye_glow_toggle/Grant(mob/grant_to)
	. = ..()
	sync_with_organ()

/datum/action/innate/eye_glow_toggle/Activate()
	var/obj/item/organ/eyes/robotic/basic/augmented/eyes = target
	if(!eyes)
		return
	eyes.set_glow_enabled(TRUE)
	sync_with_organ()

/datum/action/innate/eye_glow_toggle/Deactivate()
	var/obj/item/organ/eyes/robotic/basic/augmented/eyes = target
	if(!eyes)
		return
	eyes.set_glow_enabled(FALSE)
	sync_with_organ()

/datum/action/innate/eye_glow_toggle/proc/sync_with_organ()
	var/obj/item/organ/eyes/robotic/basic/augmented/eyes = target
	if(!eyes)
		return
	active = eyes.glow_enabled
	button_icon_state = active ? "mech_lights_on" : "mech_lights_off"
	build_all_button_icons(UPDATE_BUTTON_ICON, TRUE)
