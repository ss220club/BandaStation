/datum/atom_skin/inferno_suit
	abstract_type = /datum/atom_skin/inferno_suit

/datum/atom_skin/inferno_suit/pride
	preview_name = "Гордыня"
	new_icon_state = "lucifer"

/datum/atom_skin/inferno_suit/wrath
	preview_name = "Гнев"
	new_icon_state = "justice"

/datum/atom_skin/inferno_suit/gluttony
	preview_name = "Чревоугодие"
	new_icon_state = "malina"

/datum/atom_skin/inferno_suit/envy
	preview_name = "Зависть"
	new_icon_state = "zdara"

/datum/atom_skin/inferno_suit/vanity
	preview_name = "Тщеславие"
	new_icon_state = "cereberus"

/obj/item/clothing/under/suit/inferno
	name = "inferno suit"
	desc = "Стильный настолько, что впечатлит самого дьявола."
	icon = 'modular_bandastation/objects/icons/obj/clothing/under/inferno.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/under/inferno.dmi'
	icon_state = "lucifer"
	inhand_icon_state = null
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	obj_flags = UNIQUE_RENAME

/obj/item/clothing/under/suit/inferno/setup_reskins()
	AddComponent(/datum/component/reskinable_item, /datum/atom_skin/inferno_suit)

/datum/atom_skin/inferno_skirt
	abstract_type = /datum/atom_skin/inferno_skirt

/datum/atom_skin/inferno_skirt/lust
	preview_name = "Похоть"
	new_icon_state = "modeus"

/datum/atom_skin/inferno_skirt/sloth
	preview_name = "Лень"
	new_icon_state = "pande"

/obj/item/clothing/under/suit/inferno/skirt
	name = "inferno suitskirt"
	icon_state = "modeus"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	bodyshapes_with_variations = NONE

/obj/item/clothing/under/suit/inferno/skirt/setup_reskins()
	AddComponent(/datum/component/reskinable_item, /datum/atom_skin/inferno_skirt)

/datum/atom_skin/designer_inferno
	abstract_type = /datum/atom_skin/designer_inferno

/datum/atom_skin/designer_inferno/beelzebub
	preview_name = "Вельзевул"
	new_icon_state = "beelzebub"

/datum/atom_skin/designer_inferno/sacrifice
	preview_name = "Жертвоприношение"
	new_icon_state = "sacrifice"

/obj/item/clothing/under/suit/inferno/designer
	name = "designer inferno suit"
	desc = "Изысканный костюм доступный лучшим сотрудникам юридического отдела."
	icon_state = "beelzebub"
	obj_flags = NONE

/obj/item/clothing/under/suit/inferno/designer/setup_reskins()
	AddComponent(/datum/component/reskinable_item, /datum/atom_skin/designer_inferno)

/obj/item/clothing/under/suit/helltaker
	name = "red shirt with white pants"
	desc = "Некогда. Занят сбором девушек."
	icon = 'modular_bandastation/objects/icons/obj/clothing/under/inferno.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/under/inferno.dmi'
	icon_state = "helltaker"
	inhand_icon_state = null
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY

/obj/item/clothing/under/suit/helltaker/skirt
	name = "red shirt with white skirt"
	desc = "Некогда. Занята сбором парней."
	icon_state = "helltakerskirt"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	bodyshapes_with_variations = NONE
