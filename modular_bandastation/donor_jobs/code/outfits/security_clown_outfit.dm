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
