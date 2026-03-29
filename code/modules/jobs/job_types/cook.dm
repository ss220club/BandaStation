/datum/job/cook
	title = JOB_COOK
	description = "Обеспечьте станцию едой, жарьте стейки, следите за тем, чтобы экипаж был сыт."
	faction = FACTION_STATION
	total_positions = 2
	spawn_positions = 2
	supervisors = JOB_HEAD_OF_PERSONNEL_RU
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "COOK"
	var/cooks = 0 //Counts cooks amount

	outfit = /datum/outfit/job/cook
	plasmaman_outfit = /datum/outfit/plasmaman/chef

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_SRV

	desensitized_base = DESENSITIZED_THRESHOLD // butcher
	liver_traits = list(TRAIT_CULINARY_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_COOK
	bounty_types = CIV_JOB_CHEF
	departments_list = list(
		/datum/job_department/service,
		)

	family_heirlooms = list(
		/obj/item/reagent_containers/condiment/saltshaker,
		/obj/item/kitchen/rollingpin,
		/obj/item/clothing/head/utility/chefhat,
	)

	// Adds up to 100, don't mess it up
	mail_goodies = list(
		/obj/item/storage/box/ingredients/random = 40,
		/obj/item/reagent_containers/cup/bottle/caramel = 7,
		/obj/item/reagent_containers/condiment/flour = 7,
		/obj/item/reagent_containers/condiment/rice = 7,
		/obj/item/reagent_containers/condiment/ketchup = 7,
		/obj/item/reagent_containers/condiment/mustard = 7,
		/obj/item/reagent_containers/condiment/enzyme = 7,
		/obj/item/reagent_containers/condiment/soymilk = 7,
		/obj/item/kitchen/spoon/soup_ladle = 6,
		/obj/item/kitchen/tongs = 6,
		/obj/item/knife/kitchen = 4,
		/obj/item/knife/butcher = 2,
	)

	rpg_title = "Tavern Chef"
	alternate_titles = list(
		JOB_CHEF,
	)
	job_flags = STATION_JOB_FLAGS

/datum/job/cook/award_service(client/winner, award)
	winner.give_award(award, winner.mob)

	var/datum/venue/restaurant = SSrestaurant.all_venues[/datum/venue/restaurant]
	var/award_score = restaurant.total_income
	var/award_status = winner.get_award_status(/datum/award/score/chef_tourist_score)
	if(award_score > award_status)
		award_score -= award_status
	winner.give_award(/datum/award/score/chef_tourist_score, winner.mob, award_score)


/datum/outfit/job/cook
	name = "Cook"
	jobtype = /datum/job/cook

	id_trim = /datum/id_trim/job/cook/chef
	uniform = /obj/item/clothing/under/costume/buttondown/slacks/service
	suit = /obj/item/clothing/suit/toggle/chef
	backpack_contents = list(
		/obj/item/choice_beacon/ingredient = 1,
		/obj/item/sharpener = 1,
	)
	belt = /obj/item/modular_computer/pda/cook
	ears = /obj/item/radio/headset/headset_srv
	head = /obj/item/clothing/head/utility/chefhat
	mask = /obj/item/clothing/mask/fakemoustache/italian

	skillchips = list(/obj/item/skillchip/job/chef)

/datum/outfit/job/cook/pre_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	..()
	var/datum/job/cook/other_chefs = SSjob.get_job_type(jobtype)
	if(other_chefs) // If there's other Chefs, you're a Cook
		if(other_chefs.cooks > 0)//Cooks
			id_trim = /datum/id_trim/job/cook
			suit = /obj/item/clothing/suit/apron/chef
			head = /obj/item/clothing/head/soft/mime
		if(!visuals_only)
			other_chefs.cooks++

/datum/outfit/job/cook/post_equip(mob/living/carbon/human/user, visuals_only = FALSE)
	. = ..()
	if(!visuals_only && user.mind && !locate(/datum/action/cooldown/cook_rage) in user.actions)
		var/datum/action/cooldown/cook_rage/rage = new(user.mind)
		rage.Grant(user)
	// Update PDA to match possible new trim.
	var/obj/item/card/id/worn_id = user.wear_id
	var/obj/item/modular_computer/pda/pda = user.get_item_by_slot(pda_slot)
	if(!istype(worn_id) || !istype(pda))
		return
	var/assignment = worn_id.get_trim_assignment()
	if(!isnull(assignment))
		pda.imprint_id(user.real_name, assignment)

/datum/outfit/job/cook/get_types_to_preload()
	. = ..()
	. += /obj/item/clothing/suit/apron/chef
	. += /obj/item/clothing/head/soft/mime

/proc/cooks_cqc_area_contains(atom/movable/movable)
	var/datum/martial_art/cqc/under_siege/kitchen_zone = new
	kitchen_zone.refresh_valid_areas()
	. = is_type_in_list(get_area(movable), kitchen_zone.kitchen_areas)
	qdel(kitchen_zone)

/proc/cook_rage_scatter_loose(mob/living/viktor_petrovich, radius = 3)
	var/turf/epicenter = get_turf(viktor_petrovich)
	if(!epicenter)
		return
	var/required_resist = MOVE_FORCE_STRONG
	for(var/atom/movable/movable in orange(radius, epicenter))
		if(QDELETED(movable) || movable == viktor_petrovich || isliving(movable))
			continue
		if(isliving(movable.loc))
			continue
		if(movable.anchored || movable.move_resist >= required_resist)
			continue
		var/atom_throw_range = rand(2, 4) + radius
		var/turf/throw_at = get_ranged_target_turf_direct(movable, epicenter, atom_throw_range, 180)
		movable.throw_at(throw_at, atom_throw_range, 4, viktor_petrovich, quickstart = FALSE)

/datum/action/cooldown/cook_rage
	name = "НУ ВСЁ ОГУЗОК, ТЫ МЕНЯ ДОСТАЛ"
	desc = "ИНВАЛИДЫ!!! ОГУЗКИ!!! БЕЗДАРИ!!!"
	cooldown_time = 5 MINUTES
	check_flags = AB_CHECK_CONSCIOUS
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "fireball0"

/datum/action/cooldown/cook_rage/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return FALSE
	if(!istype(owner, /mob/living/carbon))
		return FALSE
	if(!cooks_cqc_area_contains(owner))
		if(feedback)
			to_chat(owner, span_warning("Надо быть на кухне."))
		return FALSE
	return TRUE

/datum/action/cooldown/cook_rage/Remove(mob/removed_from)
	if(istype(removed_from, /mob/living/carbon))
		var/mob/living/carbon/carbon = removed_from
		carbon.remove_movespeed_modifier(/datum/movespeed_modifier/strained_muscles)
	return ..()

/datum/action/cooldown/cook_rage/Activate(atom/target)
	var/mob/living/carbon/viktor_petrovich = owner
	if(!istype(viktor_petrovich))
		return
	playsound(get_turf(viktor_petrovich), 'sound/misc/viktor_petrovich.ogg', 100, FALSE, 12)
	var/oguzki = "ИНВАЛИДЫ!!! ОГУЗКИ!!! БЕЗДАРИ!!!"
	for(var/mob/oguzok as anything in viewers(viktor_petrovich))
		if(!oguzok.client)
			continue
		if(viktor_petrovich.runechat_prefs_check(oguzok, EMOTE_MESSAGE))
			oguzok.create_chat_message(viktor_petrovich, raw_message = oguzki, runechat_flags = EMOTE_MESSAGE)
		else
			to_chat(oguzok, span_warning("<b>[viktor_petrovich]</b> орёт: \"[oguzki]\""))
	to_chat(viktor_petrovich, span_notice("Я СЕЙЧАС ВАМ ВСЕМ ОБЪЯСНЮ!"))
	..()
	INVOKE_ASYNC(src, PROC_REF(rage_muscles_async), viktor_petrovich)
	INVOKE_ASYNC(src, PROC_REF(rage_scatter_pulse), viktor_petrovich)

/datum/action/cooldown/cook_rage/proc/rage_scatter_pulse(mob/living/carbon/viktor_petrovich)
	var/burst_delay = (22 SECONDS) / 8
	for(var/burst in 1 to 9)
		if(QDELETED(viktor_petrovich) || viktor_petrovich.stat != CONSCIOUS || !cooks_cqc_area_contains(viktor_petrovich))
			return
		cook_rage_scatter_loose(viktor_petrovich)
		if(burst < 9)
			sleep(burst_delay)

/datum/action/cooldown/cook_rage/proc/rage_muscles_async(mob/living/carbon/viktor_petrovich)
	var/stacks = 0
	var/end_time = world.time + 22 SECONDS
	viktor_petrovich.add_movespeed_modifier(/datum/movespeed_modifier/strained_muscles)
	while(world.time < end_time)
		if(QDELETED(viktor_petrovich))
			break
		stacks++
		if(viktor_petrovich.stat != CONSCIOUS || viktor_petrovich.staminaloss >= 90)
			to_chat(viktor_petrovich, span_notice("Вы выдыхаетесь, и ноги перестают нести вас. Огузки получили по заслугам."))
			viktor_petrovich.Paralyze(4 SECONDS)
			break
		viktor_petrovich.adjust_stamina_loss(stacks * 1.3)
		if(stacks == 11)
			to_chat(viktor_petrovich, span_warning("Ноги начинают ныть..."))
		sleep(4 SECONDS)
	if(!QDELETED(viktor_petrovich))
		viktor_petrovich.remove_movespeed_modifier(/datum/movespeed_modifier/strained_muscles)
