/datum/job/mime
	title = JOB_MIME
	description = "..."
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = JOB_HEAD_OF_PERSONNEL_RU
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "MIME"

	outfit = /datum/outfit/job/mime
	plasmaman_outfit = /datum/outfit/plasmaman/mime

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_SRV

	display_order = JOB_DISPLAY_ORDER_MIME
	departments_list = list(
		/datum/job_department/service,
		)

	family_heirlooms = list(/obj/item/food/baguette)

	mail_goodies = list(
		/obj/item/food/baguette = 15,
		/obj/item/food/cheese/wheel = 10,
		/obj/item/reagent_containers/cup/glass/bottle/bottleofnothing = 10,
		/obj/item/book/granter/action/spell/mime/mimery = 1,
	)
	rpg_title = "Fool"
	job_flags = STATION_JOB_FLAGS

	voice_of_god_power = 0.5 //Why are you speaking
	voice_of_god_silence_power = 3

	job_tone = "silence"

/datum/job/mime/after_spawn(mob/living/spawned, client/player_client)
	if (ishuman(spawned))
		spawned.apply_pref_name(/datum/preference/name/mime, player_client)
	return ..()

/datum/outfit/job/mime
	name = "Mime"
	jobtype = /datum/job/mime

	id_trim = /datum/id_trim/job/mime
	uniform = /obj/item/clothing/under/rank/civilian/clown
	backpack_contents = list(
		/obj/item/stamp/clown = 1,
		/obj/item/reagent_containers/spray/waterflower = 1,
		/obj/item/food/grown/banana = 1,
		/obj/item/instrument/bikehorn = 1,
		/obj/item/storage/box/balloons = 1,
		)
	belt = /obj/item/modular_computer/pda/clown
	ears = /obj/item/radio/headset/headset_srv
	shoes = /obj/item/clothing/shoes/clown_shoes
	mask = /obj/item/clothing/mask/gas/clown_hat
	l_pocket = /obj/item/bikehorn

	backpack = /obj/item/storage/backpack/clown
	satchel = /obj/item/storage/backpack/clown
	duffelbag = /obj/item/storage/backpack/duffelbag/clown //strangely has a duffel
	messenger = /obj/item/storage/backpack/messenger/clown

	box = /obj/item/storage/box/survival/hug
	chameleon_extras = /obj/item/stamp/clown
	implants = list(/obj/item/implant/sad_trombone)
	skillchips = list(/obj/item/skillchip/job/clown)

/datum/outfit/job/mime/post_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	..()

	if(visuals_only)
		return

	H.dna.add_mutation(/datum/mutation/clumsy, MUTATION_SOURCE_CLOWN_CLUMSINESS)

	ADD_TRAIT(H, TRAIT_MIME_FAN, INNATE_TRAIT)

/obj/item/book/granter/action/spell/mime/mimery
	name = "Guide to Dank Mimery"
	desc = "Teaches one of three classic pantomime routines, allowing a practiced mime to conjure invisible objects into corporeal existence. One use only."
	pages_to_mastery = 0
	reading_time = 0

/obj/item/book/granter/action/spell/mime/mimery/on_reading_start(mob/living/user)
	var/list/spell_icons = list()
	var/list/name_to_spell = list()
	for(var/datum/action/type as anything in list(/datum/action/cooldown/spell/conjure/invisible_wall, /datum/action/cooldown/spell/conjure/invisible_chair, /datum/action/cooldown/spell/conjure_item/invisible_box))
		if(!(locate(type) in user.actions))
			spell_icons[initial(type.name)] = image(icon = initial(type.button_icon), icon_state = initial(type.button_icon_state))
		name_to_spell[initial(type.name)] = type
	var/picked_spell = show_radial_menu(user, src, spell_icons, custom_check = CALLBACK(src, PROC_REF(check_menu), user), radius = 36, require_near = TRUE)
	if(!picked_spell)
		return FALSE
	granted_action = name_to_spell[picked_spell]
	return TRUE

/obj/item/book/granter/action/spell/mime/mimery/on_reading_finished(mob/living/user)
	// Gives the user a vow ability too, if they don't already have one
	var/datum/action/cooldown/spell/vow_of_silence/vow = locate() in user.actions
	if(!vow && user.mind)
		vow = new(user.mind)
		vow.Grant(user)
	var/datum/action/new_action = new granted_action(user.mind || user)
	new_action.Grant(user)
	to_chat(user, span_warning("The book disappears into thin air."))
	qdel(src)

/obj/item/book/granter/action/spell/mime/mimery/can_learn(mob/living/user)
	for(var/type in list(/datum/action/cooldown/spell/conjure/invisible_wall, /datum/action/cooldown/spell/conjure/invisible_chair, /datum/action/cooldown/spell/conjure_item/invisible_box))
		if(!(locate(type) in user.actions))
			return TRUE
	to_chat(user, span_warning("You already know the secrets of mimery!"))
	return FALSE

/**
 * Checks if we are allowed to interact with a radial menu
 *
 * Arguments:
 * * user The human mob interacting with the menu
 */
/obj/item/book/granter/action/spell/mime/mimery/proc/check_menu(mob/living/carbon/human/user)
	if(!istype(user))
		return FALSE
	if(!user.is_holding(src))
		return FALSE
	if(user.incapacitated)
		return FALSE
	if(!user.mind)
		return FALSE
	return TRUE
