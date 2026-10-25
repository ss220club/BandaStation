/// Separate from /heart/demon: that native type grants bloodcrawl on insertion.
/obj/item/organ/heart/shadow_demon
	name = "heart of darkness"
	desc = "Оно продолжает яростно биться, излучая ауру страха."
	icon_state = "demon_heart-on"
	color = COLOR_BLACK
	decay_factor = 0
	organ_flags = ORGAN_ORGANIC
	/// Only the action owned by this heart is removed on extraction.
	var/datum/action/cooldown/spell/shadow_grapple/grapple

/obj/item/organ/heart/shadow_demon/Initialize(mapload)
	AddElement(/datum/element/update_icon_blocker)
	return ..()

/obj/item/organ/heart/shadow_demon/attack(mob/target_mob, mob/living/carbon/user, obj/target)
	if(target_mob != user)
		return ..()
	if(!user.temporarilyRemoveItemFromInventory(src))
		return
	user.visible_message(span_warning("[user] подносит [src] ко рту и впивается в него зубами!"), span_userdanger("Неестественный голод заставляет вас пожрать сердце!"))
	playsound(user, 'sound/effects/magic/demon_consume.ogg', 50, TRUE)
	Insert(user)

/obj/item/organ/heart/shadow_demon/on_mob_insert(mob/living/carbon/heart_owner)
	. = ..()
	grapple = new(src)
	grapple.Grant(heart_owner)

/obj/item/organ/heart/shadow_demon/on_mob_remove(mob/living/carbon/heart_owner, special = FALSE, movement_flags)
	. = ..()
	QDEL_NULL(grapple)

/obj/item/organ/heart/shadow_demon/Destroy()
	QDEL_NULL(grapple)
	return ..()

/obj/item/organ/heart/shadow_demon/Stop()
	return FALSE
