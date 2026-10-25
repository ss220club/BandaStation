/obj/item/organ/tongue/vox
	emote_sounds = list(
		/datum/emote/living/scream::key = 'modular_bandastation/emote_panel/audio/vox/shriek1.ogg',
		/datum/emote/living/cough::key = 'modular_bandastation/emote_panel/audio/vox/shriekcough.ogg',
		/datum/emote/living/sneeze::key = 'modular_bandastation/emote_panel/audio/vox/shrieksneeze.ogg'
	)

/datum/emote/living/carbon/human/vox
	abstract_type = /datum/emote/living/carbon/human/vox
	species_type_whitelist_typecache = list(/datum/species/vox)
	emote_type = EMOTE_AUDIBLE
	affected_by_pitch = FALSE
	vocal = FALSE

/datum/emote/living/carbon/human/vox/can_run_emote(mob/user, status_check = TRUE, intentional = FALSE, params)
	if(!ishuman(user))
		return FALSE
	return ..()

/datum/emote/living/carbon/human/vox/quill
	name = "Шелестеть перьями"
	key = "quill"
	key_third_person = "quills"
	message = "шелестит перьями."
	message_param = "шелестит перьями на %t."
	sound = 'modular_bandastation/emote_panel/audio/vox/voxrustle.ogg'

/datum/emote/living/carbon/human/vox/quill/can_run_emote(mob/user, status_check = TRUE, intentional = FALSE, params)
	if(!..())
		return FALSE
	var/obj/item/organ/quills/vox/quills = user.get_organ_by_type(/obj/item/organ/quills/vox)
	var/datum/bodypart_overlay/mutant/quills/vox/overlay = quills?.bodypart_overlay
	return overlay?.sprite_datum && overlay.sprite_datum.icon_state != SPRITE_ACCESSORY_NONE

/datum/emote/living/carbon/human/vox/click
	name = "Щёлкать клювом"
	key = "click"
	key_third_person = "clicks"
	message = "щёлкает клювом."
	message_param = "щёлкает клювом на %t."
	sound = 'modular_bandastation/emote_panel/audio/vox/kidanclack2.ogg'

/datum/emote/living/carbon/human/vox/click/can_run_emote(mob/user, status_check = TRUE, intentional = FALSE, params)
	if(!..())
		return FALSE
	var/mob/living/carbon/human/human = user
	if(istype(human.wear_mask, /obj/item/clothing/mask/muzzle) || istype(human.wear_mask, /obj/item/clothing/mask/breath/muzzle))
		return FALSE
	return istype(human.get_bodypart(BODY_ZONE_HEAD), /obj/item/bodypart/head/vox) && human.get_organ_by_type(/obj/item/organ/snout/vox)
