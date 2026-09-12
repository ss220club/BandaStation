/// Admin loadout for testing the complete ancient-vampire progression.
/datum/outfit/ancient_vampire
	name = "Ancient Vampire"

	uniform = /obj/item/clothing/under/suit/red
	suit = /obj/item/clothing/suit/costume/dracula
	back = /obj/item/storage/backpack
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/chameleon/noslip
	ears = /obj/item/radio/headset/syndicate
	id = /obj/item/card/id/advanced/debug
	backpack_contents = list(
		/obj/item/storage/box/survival = 1,
		/obj/item/flashlight = 1,
		/obj/item/clothing/under/color/black = 1,
	)

/datum/outfit/ancient_vampire/post_equip(mob/living/carbon/human/human, visuals_only = FALSE)
	. = ..()
	if(visuals_only)
		return

	var/obj/item/card/id/id_card = human.wear_id
	if(id_card)
		id_card.registered_name = "Ancient One"
		id_card.assignment = "data"
		id_card.update_label()

	if(!human.mind || human.mind.has_antag_datum(/datum/antagonist/vampire))
		return
	var/datum/antagonist/vampire/vampire = human.mind.add_antag_datum(/datum/antagonist/vampire)
	if(!vampire)
		return
	vampire.bloodusable = 9999
	vampire.bloodtotal = 9999
	vampire.add_subclass(SUBCLASS_ANCIENT, announce = FALSE)
