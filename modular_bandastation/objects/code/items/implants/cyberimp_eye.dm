/obj/item/organ/cyberimp/eyes/hud/security/shielded
	name = "shielded security HUD implant"
	desc = "These cybernetic eye implants will display a security HUD over everything you see. It is shielded from flashbangs."

/obj/item/organ/cyberimp/eyes/hud/security/shielded/toggle_hud(mob/living/carbon/human/eye_owner)
	. = ..()
	var/obj/item/organ/eyes/eyes = eye_owner.get_organ_slot(ORGAN_SLOT_EYES)
	if(toggled_on)
		eyes.flash_protect = min(eyes.flash_protect + 2, FLASH_PROTECTION_WELDER)
		return
	eyes.flash_protect = initial(eyes.flash_protect)

/obj/item/organ/cyberimp/eyes/hud/security/shielded/on_mob_insert(mob/living/carbon/human/eye_owner, special, movement_flags)
	. = ..()
	toggle_hud(eye_owner)

/obj/item/organ/cyberimp/eyes/hud/security/shielded/on_mob_remove(mob/living/carbon/human/eye_owner, special, movement_flags)
	. = ..()
	var/obj/item/organ/eyes/eyes = eye_owner.get_organ_slot(ORGAN_SLOT_EYES)
	eyes.flash_protect = initial(eyes.flash_protect)

