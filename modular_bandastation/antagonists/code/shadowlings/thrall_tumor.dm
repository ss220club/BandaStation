// Мозг шадоулинга: при установке/снятии — подключаем/отключаем от улья

/obj/item/organ/brain/shadow/shadowling/Insert(mob/living/carbon/human/H, special = FALSE, drop_if_organ_full = TRUE)
	. = ..()
	if(!.) return
	shadowling_join_hive(H)

/obj/item/organ/brain/shadow/shadowling/Remove(mob/living/carbon/human/H, special = FALSE)
	. = ..()
	if(!.) return
	shadowling_leave_hive(H)

// Опухоль тралла: тоже член улья (получит язык и тралльские кнопки)

/obj/item/organ/brain/shadow/tumor_thrall
	name = "shadow thrall tumor"
	desc = "A parasitic shadow growth threaded through the host's brain."
	icon = 'icons/obj/medical/organs/shadow_organs.dmi'
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_BRAIN_THRALL

/obj/item/organ/brain/shadow/tumor_thrall/Insert(mob/living/carbon/human/H, special = FALSE, drop_if_organ_full = TRUE)
	. = ..()
	if(!.) return
	shadowling_join_hive(H)
	to_chat(H, span_danger("A frigid whisper coils in your mind... You are a thrall."))

/obj/item/organ/brain/shadow/tumor_thrall/Remove(mob/living/carbon/human/H, special = FALSE)
	. = ..()
	if(!.) return
	shadowling_leave_hive(H)
	to_chat(H, span_notice("The chilling presence leaves your mind."))
