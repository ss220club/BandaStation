/datum/outfit/job/donor/actor
	name = "Actor"
	jobtype = /datum/job/donor/actor
	id_trim = /datum/id_trim/job/donor_actor
	uniform = /obj/item/clothing/under/rank/civilian/lawyer/red
	shoes = /obj/item/clothing/shoes/laceup
	head = /obj/item/clothing/head/hats/bowler
	gloves = /obj/item/clothing/gloves/color/white
	glasses = /obj/item/clothing/glasses/regular

/datum/outfit/job/donor/actor/painter
	name = "Actor (painter)"
	id_trim = /datum/id_trim/job/donor_actor/painter
	uniform = /obj/item/clothing/under/misc/assistantformal
	shoes = /obj/item/clothing/shoes/sneakers/white
	head = /obj/item/clothing/head/beret
	glasses = /obj/item/clothing/glasses/regular/hipster
	suit = /obj/item/clothing/suit/apron
	l_hand = /obj/item/canvas/nineteen_nineteen
	backpack_contents = list(
		/obj/item/paint_palette = 1,
		/obj/item/paint/anycolor = 1,
		/obj/item/storage/crayons = 1,
		/obj/item/toy/crayon/spraycan = 1,
	)

/datum/outfit/job/donor/actor/comedian
	name = "Actor (comedian)"
	uniform = /obj/item/clothing/under/rank/civilian/clown/jester
	head = /obj/item/clothing/head/costume/jester
