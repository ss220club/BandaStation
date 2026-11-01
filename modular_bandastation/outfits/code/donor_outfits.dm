/datum/outfit/job/donor
	ears = /obj/item/radio/headset/headset_srv
	preserve_backpack_supplies = TRUE

/datum/outfit/job/donor/acolyte
	name = "Acolyte"
	jobtype = /datum/job/donor/acolyte
	id_trim = /datum/id_trim/job/donor_acolyte
	belt = /obj/item/modular_computer/pda/crew/chaplain
	uniform = /obj/item/clothing/under/rank/civilian/chaplain
	shoes = /obj/item/clothing/shoes/sandal/velcro
	backpack_contents = list(/obj/item/book/bible = 1)

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

/datum/outfit/job/donor/service_administrator
	name = "Administrator"
	jobtype = /datum/job/donor/service_administrator
	id_trim = /datum/id_trim/job/donor_service_administrator
	uniform = /obj/item/clothing/under/rank/civilian/lawyer/blue
	shoes = /obj/item/clothing/shoes/laceup
	suit = /obj/item/clothing/suit/toggle/lawyer/black
	gloves = /obj/item/clothing/gloves/color/white
	glasses = /obj/item/clothing/glasses/regular
	belt = /obj/item/modular_computer/pda/crew/curator
	l_hand = /obj/item/clipboard
	r_pocket = /obj/item/pen

/datum/outfit/job/donor/banker
	name = "Banker"
	jobtype = /datum/job/donor/banker
	id_trim = /datum/id_trim/job/donor_banker
	uniform = /obj/item/clothing/under/suit/black_really
	shoes = /obj/item/clothing/shoes/laceup
	suit = /obj/item/clothing/suit/toggle/lawyer/black
	glasses = /obj/item/clothing/glasses/monocle
	gloves = /obj/item/clothing/gloves/color/white
	head = /obj/item/clothing/head/fedora
	l_hand = /obj/item/cane
	l_pocket = /obj/item/melee/baton/telescopic
	backpack_contents = list(/obj/item/stack/spacecash/c1000 = 5)
	implants = list(/obj/item/implant/mindshield, /obj/item/implant/death_alarm)

/datum/outfit/job/donor/merchant
	name = "Dealer"
	jobtype = /datum/job/donor/merchant
	id_trim = /datum/id_trim/job/donor_merchant
	uniform = /obj/item/clothing/under/suit/black
	shoes = /obj/item/clothing/shoes/laceup
	suit = /obj/item/clothing/suit/toggle/lawyer/black
	head = /obj/item/clothing/head/fedora
	glasses = /obj/item/clothing/glasses/sunglasses/big
	gloves = /obj/item/clothing/gloves/color/black
	belt = /obj/item/modular_computer/pda/crew/curator
	l_pocket = /obj/item/hand_labeler
	backpack_contents = list(
		/obj/item/pen/fourcolor = 2,
		/obj/item/flashlight = 1,
		/obj/item/storage/crayons = 1,
		/obj/item/clothing/glasses/sunglasses = 1,
		/obj/item/lighter = 1,
	)

/datum/outfit/job/donor/service_guard
	name = "Guard"
	jobtype = /datum/job/donor/service_guard
	id_trim = /datum/id_trim/job/donor_service_guard
	uniform = /obj/item/clothing/under/costume/buttondown/slacks/service
	shoes = /obj/item/clothing/shoes/jackboots
	suit = /obj/item/clothing/suit/jacket/leather
	belt = /obj/item/melee/baton
	head = /obj/item/clothing/head/hats/bowler
	glasses = /obj/item/clothing/glasses/sunglasses/big
	l_pocket = /obj/item/modular_computer/pda/crew/bar
	pda_slot = ITEM_SLOT_LPOCKET
	r_pocket = /obj/item/reagent_containers/spray/pepper

/datum/outfit/job/donor/migrant
	name = "Migrant"
	jobtype = /datum/job/donor/migrant
	id_trim = /datum/id_trim/job/donor_migrant
	uniform = /obj/item/clothing/under/costume/pirate
	shoes = /obj/item/clothing/shoes/sandal/velcro
	suit = /obj/item/clothing/suit/costume/poncho
	head = /obj/item/clothing/head/costume/sombrero
	mask = /obj/item/clothing/mask/fakemoustache
	ears = /obj/item/radio/headset

/datum/outfit/job/donor/musician
	name = "Musician"
	jobtype = /datum/job/donor/musician
	id_trim = /datum/id_trim/job/donor_musician
	uniform = /obj/item/clothing/under/costume/singer/blue
	shoes = /obj/item/clothing/shoes/singerb
	gloves = /obj/item/clothing/gloves/color/white
	glasses = /obj/item/clothing/glasses/regular/hipster
	l_hand = /obj/item/instrument/guitar
	backpack_contents = list(/obj/item/instrument/harmonica = 1)

/datum/outfit/job/donor/musician/drummer
	name = "Musician (drummer)"
	l_hand = /obj/item/instrument/drumskit_folded
	backpack_contents = list(
		/obj/item/instrument/harmonica = 1,
		/obj/item/wrench = 1,
	)

/datum/outfit/job/donor/musician/keyboard
	name = "Musician (keyboard)"
	l_hand = /obj/item/instrument/piano_synth

/datum/outfit/job/donor/musician/violinist
	name = "Musician (violinist)"
	l_hand = /obj/item/instrument/violin

/datum/outfit/job/donor/musician/jester
	name = "Musician (jester)"
	l_hand = /obj/item/instrument/accordion

/datum/outfit/job/donor/musician/saxophonist
	name = "Musician (saxophonist)"
	l_hand = /obj/item/instrument/saxophone

/datum/outfit/job/donor/musician/vocalist
	name = "Musician (vocalist)"
	l_hand = /obj/item/radio/entertainment/microphone/physical

/datum/outfit/job/donor/musician/touring_musician
	name = "Musician (touring musician)"
	l_hand = /obj/item/instrument/banjo

/datum/outfit/job/donor/representative_tsf
	name = "Representative TSF"
	jobtype = /datum/job/donor/representative_tsf
	id_trim = /datum/id_trim/job/donor_representative_tsf
	uniform = /obj/item/clothing/under/rank/tsf/commander
	shoes = /obj/item/clothing/shoes/laceup
	head = /obj/item/clothing/head/beret/tsf
	glasses = /obj/item/clothing/glasses/sunglasses
	gloves = /obj/item/clothing/gloves/color/white
	ears = /obj/item/radio/headset
	belt = /obj/item/storage/belt/fannypack/black
	l_pocket = /obj/item/melee/baton/telescopic
	r_pocket = /obj/item/modular_computer/pda/crew
	pda_slot = ITEM_SLOT_RPOCKET
	box = /obj/item/storage/box/survival/mining
	backpack_contents = list(
		/obj/item/implanter/death_alarm = 1,
		/obj/item/lighter = 1,
		/obj/item/storage/fancy/cigarettes/cigpack_robustgold = 1,
		/obj/item/clothing/under/shorts/blue = 1,
	)
	implants = list(/obj/item/implant/mindshield, /obj/item/implant/death_alarm)

/datum/outfit/job/donor/representative_tsf/post_equip(mob/living/carbon/human/body, visuals_only = FALSE)
	. = ..()
	if(!visuals_only)
		body.grant_language(/datum/language/uncommon)

/datum/outfit/job/donor/representative_ussp
	name = "Representative USSP"
	jobtype = /datum/job/donor/representative_ussp
	id_trim = /datum/id_trim/job/donor_representative_ussp
	uniform = /obj/item/clothing/under/costume/soviet/ussp/officer
	shoes = /obj/item/clothing/shoes/combat
	suit = /obj/item/clothing/suit/costume/soviet/ussp/officer
	head = /obj/item/clothing/head/hats/ussp/classic/officer
	gloves = /obj/item/clothing/gloves/color/black
	glasses = /obj/item/clothing/glasses/sunglasses
	ears = /obj/item/radio/headset
	belt = /obj/item/storage/belt/fannypack/red
	l_pocket = /obj/item/melee/baton/telescopic
	r_pocket = /obj/item/modular_computer/pda/crew
	pda_slot = ITEM_SLOT_RPOCKET
	box = /obj/item/storage/box/survival/mining
	backpack_contents = list(
		/obj/item/implanter/death_alarm = 1,
		/obj/item/lighter = 1,
		/obj/item/storage/fancy/cigarettes/cigpack_robustgold = 1,
		/obj/item/clothing/under/shorts/red = 1,
		/obj/item/clothing/head/costume/ushanka = 1,
	)
	implants = list(/obj/item/implant/mindshield, /obj/item/implant/death_alarm)

/datum/outfit/job/donor/representative_ussp/post_equip(mob/living/carbon/human/body, visuals_only = FALSE)
	. = ..()
	if(!visuals_only)
		body.grant_language(/datum/language/spinwarder)

/datum/outfit/job/clown/security
	name = "Security Clown"
	preserve_backpack_supplies = TRUE
	jobtype = /datum/job/donor/security_clown
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/donor_security_clown
	uniform = /obj/item/clothing/under/rank/civilian/clown/security
	suit = /obj/item/clothing/suit/armor/vest/alt/sec
	head = /obj/item/clothing/head/helmet
	suit_store = /obj/item/gun/energy/honk_rifle
	gloves = /obj/item/clothing/gloves/color/red
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	ears = /obj/item/radio/headset/headset_sec
	backpack_contents = list(
		/obj/item/stamp/clown = 1,
		/obj/item/storage/crayons = 1,
		/obj/item/reagent_containers/spray/waterflower = 1,
	)
	implants = list(/obj/item/implant/sad_trombone, /obj/item/implant/mindshield)

/datum/outfit/job/clown/security/detective
	name = "Security Clown (detective)"
	suit = /obj/item/clothing/suit/toggle/jacket/det_trench
	head = /obj/item/clothing/head/fedora/det_hat

/datum/outfit/job/clown/security/warden
	name = "Security Clown (warden)"
	suit = /obj/item/clothing/suit/armor/vest/warden/alt
	head = /obj/item/clothing/head/hats/warden/red
	suit_store = /obj/item/gun/energy/honk_rifle/warden

/datum/outfit/job/clown/security/cadet
	name = "Security Clown (cadet)"
	head = /obj/item/clothing/head/soft/sec

/datum/outfit/job/donor/tourist_tsf
	name = "Tourist TSF"
	jobtype = /datum/job/donor/tourist_tsf
	id_trim = /datum/id_trim/job/donor_tourist_tsf
	uniform = /obj/item/clothing/under/rank/tsf/marine
	suit = /obj/item/clothing/suit/hooded/wintercoat/zipup/tsf
	head = /obj/item/clothing/head/soft/tsf
	shoes = /obj/item/clothing/shoes/combat
	belt = /obj/item/storage/belt/fannypack/black
	r_pocket = /obj/item/modular_computer/pda/crew
	pda_slot = ITEM_SLOT_RPOCKET
	gloves = /obj/item/clothing/gloves/fingerless
	ears = /obj/item/radio/headset
	backpack_contents = list(/obj/item/clothing/under/shorts/blue = 1)

/datum/outfit/job/donor/tourist_tsf/post_equip(mob/living/carbon/human/body, visuals_only = FALSE)
	. = ..()
	if(!visuals_only)
		body.grant_language(/datum/language/uncommon)

/datum/outfit/job/donor/tourist_ussp
	name = "Tourist USSP"
	jobtype = /datum/job/donor/tourist_ussp
	id_trim = /datum/id_trim/job/donor_tourist_ussp
	uniform = /obj/item/clothing/under/costume/soviet/ussp
	suit = /obj/item/clothing/suit/costume/soviet/ussp
	head = /obj/item/clothing/head/hats/ussp/classic
	shoes = /obj/item/clothing/shoes/combat
	belt = /obj/item/storage/belt/fannypack/red
	r_pocket = /obj/item/modular_computer/pda/crew
	pda_slot = ITEM_SLOT_RPOCKET
	glasses = /obj/item/clothing/glasses/sunglasses/big
	gloves = /obj/item/clothing/gloves/fingerless
	ears = /obj/item/radio/headset
	backpack_contents = list(
		/obj/item/clothing/under/shorts/red = 1,
		/obj/item/clothing/head/costume/ushanka = 1,
	)

/datum/outfit/job/donor/tourist_ussp/post_equip(mob/living/carbon/human/body, visuals_only = FALSE)
	. = ..()
	if(!visuals_only)
		body.grant_language(/datum/language/spinwarder)

/datum/outfit/job/donor/unemployed
	name = "Uncertain"
	jobtype = /datum/job/donor/unemployed
	id_trim = /datum/id_trim/job/donor_unemployed
	belt = /obj/item/modular_computer/pda/crew/curator
	uniform = /obj/item/clothing/under/costume/kilt
	shoes = /obj/item/clothing/shoes/sandal/velcro
	suit = /obj/item/clothing/suit/costume/poncho
	head = /obj/item/clothing/head/beanie/yellow
	glasses = /obj/item/clothing/glasses/eyepatch
	ears = /obj/item/radio/headset
	backpack = /obj/item/storage/backpack/explorer
	satchel = /obj/item/storage/backpack/satchel/explorer

/datum/outfit/job/donor/vip_guest
	name = "VIP Corporate Guest"
	jobtype = /datum/job/donor/vip_guest
	id_trim = /datum/id_trim/job/donor_vip_guest
	uniform = /obj/item/clothing/under/suit/black_really
	shoes = /obj/item/clothing/shoes/laceup
	glasses = /obj/item/clothing/glasses/monocle
	gloves = /obj/item/clothing/gloves/color/black
	head = /obj/item/clothing/head/hats/tophat
	l_hand = /obj/item/cane
	l_pocket = /obj/item/melee/baton/telescopic
	backpack_contents = list(/obj/item/stack/spacecash/c1000 = 2)
	implants = list(/obj/item/implant/mindshield, /obj/item/implant/death_alarm)

/datum/outfit/job/donor/waiter
	name = "Waiter"
	jobtype = /datum/job/donor/waiter
	id_trim = /datum/id_trim/job/donor_waiter
	uniform = /obj/item/clothing/under/suit/waiter
	shoes = /obj/item/clothing/shoes/laceup
	suit = /obj/item/clothing/suit/toggle/lawyer/black
	belt = /obj/item/modular_computer/pda/crew/cook
	l_hand = /obj/item/clipboard
	r_pocket = /obj/item/rag
