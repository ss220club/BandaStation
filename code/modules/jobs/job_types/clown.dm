/datum/job/clown
	title = JOB_CLOWN
	description = "Веселите экипаж, шутите несмешные шутки, выполните священное задание по поиску бананиума, ХОНК!"
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = JOB_HEAD_OF_PERSONNEL_RU
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "CLOWN"

	outfit = /datum/outfit/job/clown
	plasmaman_outfit = /datum/outfit/plasmaman/clown

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_SRV

	mind_traits = list(TRAIT_NAIVE)
	liver_traits = list(TRAIT_COMEDY_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_CLOWN
	departments_list = list(
		/datum/job_department/service,
		)

	mail_goodies = list(
		/obj/item/food/grown/banana = 100,
		/obj/item/food/pie/cream = 50,
		/obj/item/spess_knife = 20, // As a joke for clumsy clown from engineering department
		/obj/item/clothing/shoes/clown_shoes/combat = 10,
		/obj/item/reagent_containers/spray/waterflower/lube = 20, // lube
		/obj/item/reagent_containers/spray/waterflower/superlube = 1 // Superlube, good lord.
	)

	family_heirlooms = list(/obj/item/bikehorn/golden)
	rpg_title = "Jester"
	job_flags = STATION_JOB_FLAGS

	job_tone = "honk"

/datum/job/clown/after_spawn(mob/living/spawned, client/player_client)
	if (ishuman(spawned))
		spawned.apply_pref_name(/datum/preference/name/clown, player_client)
		if(check_holidays(APRIL_FOOLS)) // Clown blood is real
			var/mob/living/carbon/human/human_clown = spawned
			human_clown.set_blood_type(BLOOD_TYPE_CLOWN)

	return ..()

/datum/outfit/job/clown
	name = "Clown"
	jobtype = /datum/job/clown

	id = /obj/item/card/id/advanced/rainbow
	id_trim = /datum/id_trim/job/clown
	uniform = /obj/item/clothing/under/rank/civilian/mime
	suit = /obj/item/clothing/suit/toggle/suspenders
	backpack_contents = list(
		/obj/item/book/granter/action/spell/mime/mimery = 1,
		/obj/item/reagent_containers/cup/glass/bottle/bottleofnothing = 1,
		/obj/item/stamp/mime = 1,
		)
	belt = /obj/item/modular_computer/pda/mime
	ears = /obj/item/radio/headset/headset_srv
	gloves = /obj/item/clothing/gloves/color/white
	head = /obj/item/clothing/head/beret/frenchberet
	mask = /obj/item/clothing/mask/gas/mime
	shoes = /obj/item/clothing/shoes/laceup

	backpack = /obj/item/storage/backpack/mime
	satchel = /obj/item/storage/backpack/mime

	box = /obj/item/storage/box/survival/hug/black
	chameleon_extras = /obj/item/stamp/mime
	implants = list()
	skillchips = list()

/datum/outfit/job/clown/mod
	name = "Clown (MODsuit)"

	suit_store = /obj/item/tank/internals/oxygen
	back = /obj/item/mod/control/pre_equipped/cosmohonk
	internals_slot = ITEM_SLOT_SUITSTORE

/datum/outfit/job/clown/pre_equip(mob/living/carbon/human/H, visuals_only)
	. = ..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_BANANIUM_SHIPMENTS))
		backpack_contents[/obj/item/stack/sheet/mineral/bananium/five] = 1

/datum/outfit/job/clown/get_types_to_preload()
	. = ..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_BANANIUM_SHIPMENTS))
		. += /obj/item/stack/sheet/mineral/bananium/five

/datum/outfit/job/clown/post_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	..()
	if(visuals_only)
		return

	H.fully_replace_character_name(H.real_name, pick(GLOB.clown_names)) //rename the mob AFTER they're equipped so their ID gets updated properly.
	if(H.mind)
		var/datum/action/cooldown/spell/vow_of_silence/vow = new(H.mind)
		vow.Grant(H)

	ADD_TRAIT(H, TRAIT_CLOWN_ENJOYER, INNATE_TRAIT)
	H.add_faction(FACTION_CLOWN)
