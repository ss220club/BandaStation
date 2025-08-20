#define ORGAN_SLOT_BRAIN_THRALL "brain_thrall_tumor"

/obj/item/organ/brain/shadow/tumor_thrall
	name = "shadow thrall tumor"
	desc = "A parasitic shadow growth threaded through the host's brain."
	icon = 'icons/obj/medical/organs/shadow_organs.dmi'
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_BRAIN_THRALL

/obj/item/organ/brain/shadow/tumor_thrall/Insert(mob/living/carbon/human/H, special = FALSE, drop_if_organ_full = TRUE)
	. = ..()
	if(!.) return
	// Выдать роль тралла/датум/компонент
	H.AddComponent(/datum/component/shadow_thrall) // или ваш /datum/antagonist/shadowling_thrall
	// Хайвмайнд :8
	ADD_LANGUAGE(H, /datum/language_holder/hivemind8)
	// Подсказка при examine в упор
	H.AddComponent(/datum/component/close_examine_hint, "Their breath chills the air, and a strange shadow coils in their mouth.")
	// Уведомить улей: +1 живой тралл
	SEND_SIGNAL(GLOB.shadow_hive, COMSIG_SHADOW_HIVE_THRALL_STATE, H, TRUE)

/obj/item/organ/brain/shadow/tumor_thrall/Remove(mob/living/carbon/human/H, special = FALSE)
	. = ..()
	if(!.) return
	// Снять роль/язык/подсказку
	H.RemoveComponent(/datum/component/shadow_thrall)
	REMOVE_LANGUAGE(H, /datum/language_holder/hivemind8)
	H.RemoveComponent(/datum/component/close_examine_hint)
	// −1 живой тралл
	SEND_SIGNAL(GLOB.shadow_hive, COMSIG_SHADOW_HIVE_THRALL_STATE, H, FALSE)
