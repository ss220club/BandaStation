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

/datum/outfit/job/donor/adjutant
	name = "Adjutant"
	jobtype = /datum/job/donor/adjutant
	id_trim = /datum/id_trim/job/donor_adjutant
	belt = /obj/item/modular_computer/pda/crew/lawyer
	uniform = /obj/item/clothing/under/rank/civilian/lawyer/blue
	shoes = /obj/item/clothing/shoes/laceup
	suit = /obj/item/clothing/suit/toggle/lawyer
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	gloves = /obj/item/clothing/gloves/color/white
	l_pocket = /obj/item/laser_pointer
	r_pocket = /obj/item/clothing/accessory/lawyers_badge
	l_hand = /obj/item/storage/briefcase/empty
	ears = /obj/item/radio/headset/heads/hop
	backpack_contents = list(
		/obj/item/folder/blue = 1,
		/obj/item/clipboard = 1,
		/obj/item/pen = 1,
	)
	implants = list(/obj/item/implant/mindshield)
	satchel = /obj/item/storage/backpack/satchel/sec
	duffelbag = /obj/item/storage/backpack/duffelbag/sec

/datum/outfit/job/donor/adjutant/butler
	name = "Adjutant (butler)"
	id_trim = /datum/id_trim/job/donor_adjutant/butler
	belt = /obj/item/modular_computer/pda/crew/bar
	uniform = /obj/item/clothing/under/rank/civilian/lawyer/black
	glasses = /obj/item/clothing/glasses/monocle
	head = /obj/item/clothing/head/hats/tophat
	r_pocket = /obj/item/rag

/datum/outfit/job/donor/adjutant/maid
	name = "Adjutant (maid)"
	id_trim = /datum/id_trim/job/donor_adjutant/maid
	belt = /obj/item/modular_computer/pda/crew/bar
	uniform = /obj/item/clothing/under/costume/maid
	suit = null
	l_hand = /obj/item/mop
	r_pocket = /obj/item/rag

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

/datum/outfit/job/donor/barber
	name = "Barber"
	jobtype = /datum/job/donor/barber
	id_trim = /datum/id_trim/job/donor_barber
	uniform = /obj/item/clothing/under/suit/waiter
	shoes = /obj/item/clothing/shoes/laceup
	suit = /obj/item/clothing/suit/apron
	head = /obj/item/clothing/head/hats/bowler
	l_pocket = /obj/item/razor
	r_pocket = /obj/item/dyespray

/datum/outfit/job/donor/bath_attendant
	name = "Bath"
	jobtype = /datum/job/donor/bath_attendant
	id_trim = /datum/id_trim/job/donor_bath_attendant
	uniform = /obj/item/clothing/under/shorts/blue
	shoes = /obj/item/clothing/shoes/sandal/velcro
	head = /obj/item/clothing/head/beanie/darkblue
	l_pocket = /obj/item/rag
	r_pocket = /obj/item/soap

/datum/outfit/job/donor/croupier
	name = "Casino"
	jobtype = /datum/job/donor/croupier
	id_trim = /datum/id_trim/job/donor_croupier
	belt = /obj/item/modular_computer/pda/crew/bar
	uniform = /obj/item/clothing/under/suit/burgundy
	shoes = /obj/item/clothing/shoes/laceup
	suit = /obj/item/clothing/suit/toggle/lawyer/purple
	l_pocket = /obj/item/toy/cards/deck
	r_pocket = /obj/item/dice/d6
	backpack_contents = list(
		/obj/item/dice/d6 = 1,
		/obj/item/coin/twoheaded = 1,
		/obj/item/coin/gold = 2,
		/obj/item/coin/silver = 4,
		/obj/item/coin/iron = 8,
	)

/datum/outfit/job/donor/cleaning_manager
	name = "Cleaning Manager"
	jobtype = /datum/job/donor/cleaning_manager
	id_trim = /datum/id_trim/job/donor_cleaning_manager
	uniform = /obj/item/clothing/under/rank/civilian/janitor
	shoes = /obj/item/clothing/shoes/galoshes/dry
	suit = /obj/item/clothing/suit/apron/overalls
	gloves = /obj/item/clothing/gloves/color/purple
	mask = /obj/item/clothing/mask/bandana/purple
	head = /obj/item/clothing/head/soft/purple
	belt = /obj/item/storage/belt/janitor
	belt_contents = list(
		/obj/item/lightreplacer = 1,
		/obj/item/reagent_containers/spray/cleaner = 1,
		/obj/item/soap/nanotrasen = 1,
		/obj/item/holosign_creator = 1,
		/obj/item/melee/flyswatter = 1,
	)
	r_pocket = /obj/item/access_key
	l_pocket = /obj/item/modular_computer/pda/crew/janitor
	pda_slot = ITEM_SLOT_LPOCKET
	l_hand = /obj/item/clipboard

/datum/outfit/job/donor/cleaning_manager/apprentice
	name = "Cleaning Manager (apprentice)"
	id_trim = /datum/id_trim/job/donor_cleaning_manager/apprentice
	l_pocket = /obj/item/modular_computer/pda/crew
	uniform = /obj/item/clothing/under/color/grey
	shoes = /obj/item/clothing/shoes/workboots
	suit = null
	gloves = /obj/item/clothing/gloves/color/grey
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/utility/welding
	belt = /obj/item/storage/belt/utility
	belt_contents = list(
		/obj/item/screwdriver = 1,
		/obj/item/wrench = 1,
		/obj/item/weldingtool = 1,
		/obj/item/crowbar = 1,
		/obj/item/wirecutters = 1,
		/obj/item/multitool = 1,
		/obj/item/stack/cable_coil = 1,
	)
	l_hand = null
	backpack_contents = list(/obj/item/flashlight = 1)

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

/datum/outfit/job/donor/wrestler
	name = "Wrestler"
	jobtype = /datum/job/donor/wrestler
	id_trim = /datum/id_trim/job/donor_wrestler
	belt = /obj/item/modular_computer/pda/crew/curator
	uniform = /obj/item/clothing/under/shorts/blue
	shoes = /obj/item/clothing/shoes/sandal/velcro
	gloves = /obj/item/clothing/gloves/boxing
	mask = /obj/item/clothing/mask/luchador
