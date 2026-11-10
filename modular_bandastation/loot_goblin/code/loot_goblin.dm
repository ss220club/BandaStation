/datum/antagonist/loot_goblin
	name = "\improper Лут гоблин"
	roundend_category = "Лут гоблины"
	antagpanel_category = "Лут гоблин"
	ui_name = "AntagInfoLootGoblin"
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	suicide_cry = "МОЙ ЛУ-У-УТ!"
	stinger_sound = 'modular_bandastation/loot_goblin/sound/goblin_stinger.ogg'
	var/obj/structure/loot_goblin_lair/lair
	var/datum/action/loot_goblin_lair/lair_action
	var/datum/action/loot_goblin_ritual/ritual_action
	var/obj/structure/loot_goblin_cauldron/cauldron
	var/datum/action/loot_goblin_cauldron/cauldron_action
	var/datum/action/cooldown/loot_goblin_recall/recall_action
	var/datum/action/cooldown/spell/smoke/lesser/loot_goblin/smoke_action
	var/datum/action/cooldown/loot_goblin_trap/trap_action
	var/datum/objective/loot_goblin_tier/tier_objective
	var/list/chosen_perks = new /list(LOOT_GOBLIN_PERK_TIERS)
	var/list/applied_perks = list()
	var/static/list/perk_info = list(
		LOOT_GOBLIN_PERK_SPEED = list("name" = "Сильные ноги", "desc" = "Ваши ноги сами знают, куда вас нести.", "tier" = 2),
		LOOT_GOBLIN_PERK_REGEN = list("name" = "Гоблинская шкура", "desc" = "Во тьме ваши раны затягиваются сами.", "tier" = 2),
		LOOT_GOBLIN_PERK_NIGHT_VISION = list("name" = "Глаза искателя", "desc" = "Вы видите в темноте — теперь искать ценные вещи куда легче.", "tier" = 2),
		LOOT_GOBLIN_PERK_STEADY = list("name" = "Стойкие ноги", "desc" = "Вы не падаете ни на битом стекле, ни на хрупких столах, а оглушить вас вдвое труднее.", "tier" = 2),
		LOOT_GOBLIN_PERK_DOOR_PRY = list("name" = "Сильные руки", "desc" = "Ничто не остановит вас на пути к добыче — двери вам не помеха.", "tier" = 3),
		LOOT_GOBLIN_PERK_RECALL = list("name" = "Возврат в логово", "desc" = "В опасной ситуации вы всегда знаете дорогу к своему логову.", "tier" = 3),
		LOOT_GOBLIN_PERK_HEARING = list("name" = "Чуткий слух", "desc" = "Вы слышите каждый шорох.", "tier" = 3),
		LOOT_GOBLIN_PERK_SMOKE = list("name" = "Пыль в глаза", "desc" = "Горсть пыли в лицо — и вас уже и след простыл.", "tier" = 4),
		LOOT_GOBLIN_PERK_TRAP = list("name" = "Гоблинский капкан", "desc" = "Незаметный капкан валит жертву с ног на 5 секунд, лишает сил и не даёт вымолвить ни слова 15 секунд. Нужно 5 листов железа, перезарядка 1 минута, не больше 3 капканов сразу.", "tier" = 4),
	)
	var/tier = 0
	var/sacrifices_done = 0
	var/admin_tier
	var/aura_shown = FALSE
	var/list/original_tts_seeds = list()
	var/static/list/goblin_voices = list(
		/datum/tts_seed/silero/goblin,
		/datum/tts_seed/silero/hg_goblin_generic_a,
		/datum/tts_seed/silero/gnomenapper,
	)
	var/datum/weakref/contract_target_ref
	var/tier_one_loot
	var/tier_two_loot
	var/tier_one_closed_by
	var/influence = 0
	var/figures_in_lair = 0
	var/list/lair_loot = list()
	var/static/list/loot_types = list(
		/datum/objective_item/steal/traitor/captain_spare,
		/datum/objective_item/steal/caplaser,
		/datum/objective_item/steal/capmedal,
		/datum/objective_item/steal/jetpack,
		/datum/objective_item/steal/handtele,
		/datum/objective_item/steal/reactive,
		/datum/objective_item/steal/magboots,
		/datum/objective_item/steal/blueprints,
		/datum/objective_item/steal/traitor/chief_engineer_belt,
		/datum/objective_item/steal/hypo,
		/datum/objective_item/steal/compactshotty,
		/datum/objective_item/steal/ablative,
	)
	var/static/list/crew_figures
	var/static/list/sacrifice_areas = list(
		/area/station/medical/medbay,
		/area/station/command/bridge,
		/area/station/security/brig,
		/area/station/service/bar,
	)

/datum/antagonist/loot_goblin/Destroy()
	remove_lair()
	remove_cauldron()
	QDEL_NULL(cauldron_action)
	QDEL_NULL(lair_action)
	QDEL_NULL(ritual_action)
	QDEL_NULL(recall_action)
	QDEL_NULL(smoke_action)
	QDEL_NULL(trap_action)
	tier_objective = null
	return ..()

/datum/antagonist/loot_goblin/can_be_owned(datum/mind/new_owner)
	. = ..()
	if(!.)
		return
	var/datum/mind/tested = new_owner || owner
	return ishuman(tested.current)

/datum/antagonist/loot_goblin/on_gain()
	var/mob/living/carbon/human/goblin = owner.current
	make_goblin_body(goblin)
	lair_action = new(src)
	ritual_action = new(src)
	cauldron_action = new(src)
	recall_action = new(src)
	smoke_action = new(src)
	trap_action = new(src)
	forge_objectives()
	. = ..()
	var/datum/action/antag_info/info_button = info_button_ref?.resolve()
	if(info_button)
		info_button.button_icon = 'modular_bandastation/loot_goblin/icons/ledger.dmi'
		info_button.button_icon_state = "ledger"
		info_button.build_all_button_icons()
	priority_announce("На борту станции замечен Лут гоблин! Берегите ценные вещи и коллекционные фигурки.", "Внимание")

/datum/antagonist/loot_goblin/on_body_transfer(mob/living/old_body, mob/living/new_body)
	if(ishuman(new_body))
		make_goblin_body(new_body)
	return ..()

/datum/antagonist/loot_goblin/proc/make_goblin_body(mob/living/carbon/human/goblin)
	if(!ismonkey(goblin))
		goblin.monkeyize(instant = TRUE)
	goblin.gender = MALE
	goblin.physique = MALE
	if(is_species(goblin, /datum/species/monkey/loot_goblin))
		goblin.update_body(is_creating = TRUE)
	else
		goblin.set_species(/datum/species/monkey/loot_goblin)
	goblin.ru_names_rename(ru_names_list("Гоблин", "Гоблин", "Гоблина", "Гоблину", "Гоблина", "Гоблином", "Гоблине", goblin.gender))
	goblin.fully_replace_character_name(goblin.real_name, "Гоблин")
	var/body_key = REF(goblin)
	if(!(body_key in original_tts_seeds))
		var/datum/component/tts_component/old_tts = goblin.GetComponent(/datum/component/tts_component)
		original_tts_seeds[body_key] = old_tts?.tts_seed
	apply_tts_seed(goblin, pick(goblin_voices))

/datum/antagonist/loot_goblin/on_removal()
	remove_lair()
	remove_cauldron()
	var/mob/living/carbon/human/goblin = owner.current
	if(is_species(goblin, /datum/species/monkey/loot_goblin))
		goblin.set_species(/datum/species/monkey)
	var/datum/tts_seed/original_seed = original_tts_seeds[REF(goblin)]
	if(original_seed && ishuman(goblin))
		apply_tts_seed(goblin, original_seed)
	original_tts_seeds.Cut()
	return ..()

/datum/antagonist/loot_goblin/proc/apply_tts_seed(mob/living/carbon/human/goblin, datum/tts_seed/seed)
	goblin.AddComponent(/datum/component/tts_component, seed)
	var/datum/component/tts_component/tts = goblin.GetComponent(/datum/component/tts_component)
	if(!tts)
		return
	goblin.dna?.tts_seed_dna = tts.tts_seed
	GLOB.human_to_tts["[goblin.real_name]"] = tts.tts_seed

/datum/antagonist/loot_goblin/greet()
	to_chat(owner.current, span_userdanger("Вы — Лут гоблин!"))
	to_chat(owner.current, span_danger("Когда-то ваш народ хранил в глубоких норах несметные сокровища. Потом пришли они — высокие, громкие, с фонарями и ломами. \
		Они назвали ваши норы «полезными ископаемыми», ваш народ — «вредителями», а ваше золото растащили по своим сейфам и витринам."))
	to_chat(owner.current, span_danger("Вы жаждете мести. Теперь сокровища гуманоидов на этой станции должны принадлежать вам. \
		Верните своё: тащите ценности в логово, а кровь обидчиков принесите в жертву своей жадности."))
	play_stinger()
	to_chat(owner.current, span_notice("Обустройте логово на верхнем уровне станции и сносите туда добычу: ценные вещи отделов и коллекционные фигурки экипажа. \
		Чем богаче логово, тем сильнее ваша жадность и тем выше ваш тир. Вы пролезаете в вентиляцию даже с вещами. Экипаж уже знает о вашем появлении."))
	owner.announce_objectives()

/datum/antagonist/loot_goblin/get_admin_commands()
	. = ..()
	.["Установить тир"] = CALLBACK(src, PROC_REF(admin_set_tier))

/datum/antagonist/loot_goblin/proc/admin_set_tier(mob/admin)
	var/new_tier = tgui_input_number(admin, "Тир гоблина от 1 до [LOOT_GOBLIN_TIER_ESCAPE]. 0 — снова считать тир по логову.", "Тир гоблина", tier, LOOT_GOBLIN_TIER_ESCAPE, 0)
	if(isnull(new_tier) || QDELETED(src) || !check_rights_for(admin.client, R_ADMIN))
		return
	admin_tier = new_tier || null
	update_influence()
	message_admins("[key_name_admin(admin)] установил тир Лут гоблина [key_name_admin(owner)]: [new_tier || "по логову"].")
	log_admin("[key_name(admin)] set loot goblin tier of [key_name(owner)] to [new_tier || "computed"].")

/datum/antagonist/loot_goblin/roundend_report()
	return ..() + "<br>Достигнутый тир: [tier]"

/datum/antagonist/loot_goblin/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/goblin = mob_override || owner.current
	if(!ishuman(goblin))
		return
	ADD_TRAIT(goblin, TRAIT_VENTCRAWLER_ALWAYS, REF(src))
	ADD_TRAIT(goblin, TRAIT_LOOT_GOBLIN, REF(src))
	RegisterSignal(goblin, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(add_aura_overlay))
	goblin.update_appearance(UPDATE_OVERLAYS)
	lair_action.Grant(goblin)
	ritual_action.Grant(goblin)
	cauldron_action.Grant(goblin)
	for(var/datum/action/item_action/organ_action/toggle_trip/trip_button in goblin.actions)
		trip_button.Remove(goblin)
	update_perks(goblin)

/datum/antagonist/loot_goblin/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/goblin = mob_override || owner.current
	if(!ishuman(goblin))
		return
	REMOVE_TRAIT(goblin, TRAIT_VENTCRAWLER_ALWAYS, REF(src))
	REMOVE_TRAIT(goblin, TRAIT_LOOT_GOBLIN, REF(src))
	UnregisterSignal(goblin, COMSIG_ATOM_UPDATE_OVERLAYS)
	goblin.update_appearance(UPDATE_OVERLAYS)
	lair_action.Remove(goblin)
	ritual_action.Remove(goblin)
	cauldron_action.Remove(goblin)
	for(var/perk in applied_perks.Copy())
		remove_perk(goblin, perk)
	goblin.remove_movespeed_modifier(/datum/movespeed_modifier/loot_goblin_tier_bonus)
	var/obj/item/organ/brain/primate/monkey_brain = goblin.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(istype(monkey_brain))
		for(var/datum/action/item_action/organ_action/toggle_trip/trip_button in monkey_brain.actions)
			trip_button.Grant(goblin)

/datum/antagonist/loot_goblin/forge_objectives()
	tier_one_loot = pick_loot(easy = TRUE)
	tier_two_loot = pick_loot(easy = FALSE, exclude = tier_one_loot)
	tier_objective = new
	tier_objective.owner = owner
	objectives += tier_objective
	update_tier()

/datum/antagonist/loot_goblin/proc/pick_loot(easy, exclude)
	var/list/fitting = list()
	var/list/fallback = list()
	for(var/datum/objective_item/item as anything in GLOB.possible_items)
		if(!(item.type in loot_types) || item.type == exclude)
			continue
		if(!item.valid_objective_for(list(owner)))
			continue
		fallback += item.type
		if((item.difficulty <= LOOT_GOBLIN_EASY_LOOT_DIFFICULTY) == easy)
			fitting += item.type
	if(length(fitting))
		return pick(fitting)
	if(length(fallback))
		return pick(fallback)
	return null

/datum/antagonist/loot_goblin/proc/get_loot_datum(loot_type)
	if(!loot_type)
		return null
	for(var/datum/objective_item/item as anything in GLOB.possible_items)
		if(item.type == loot_type)
			return item
	return null

/datum/antagonist/loot_goblin/proc/get_loot_name(loot_type)
	var/datum/objective_item/item = get_loot_datum(loot_type)
	return item?.name

/datum/antagonist/loot_goblin/proc/is_target_loot(datum/objective_item/item, obj/item/thing)
	if(!item)
		return FALSE
	return (istype(thing, item.targetitem) || (thing.type in item.altitems)) && item.check_special_completion(thing)

/datum/antagonist/loot_goblin/proc/is_crew_figure(obj/item/thing)
	if(isnull(crew_figures))
		crew_figures = typecacheof(/obj/item/toy/figure, ignore_root_path = TRUE)
		for(var/excluded in typecacheof(list(
			/obj/item/toy/figure/borg,
			/obj/item/toy/figure/dsquad,
			/obj/item/toy/figure/ian,
			/obj/item/toy/figure/ninja,
			/obj/item/toy/figure/prisoner,
			/obj/item/toy/figure/syndie,
			/obj/item/toy/figure/wizard,
		)))
			crew_figures -= excluded
	return is_type_in_typecache(thing, crew_figures)

/datum/antagonist/loot_goblin/proc/remove_lair()
	if(!lair)
		return
	lair.goblin = null
	QDEL_NULL(lair)

/datum/antagonist/loot_goblin/proc/remove_cauldron()
	if(!cauldron)
		return
	cauldron.goblin = null
	QDEL_NULL(cauldron)

/datum/antagonist/loot_goblin/proc/create_cauldron(turf/cauldron_turf)
	remove_cauldron()
	cauldron = new(cauldron_turf, src)
	to_chat(owner.current, span_notice("Котёл установлен. Осмотрите его, чтобы увидеть рецепты."))

/datum/antagonist/loot_goblin/proc/create_lair(turf/lair_turf)
	remove_lair()
	lair = new(lair_turf, src)
	update_influence()
	to_chat(owner.current, span_notice("Логово обустроено: [get_area_name(lair, TRUE)]."))

/datum/antagonist/loot_goblin/proc/update_influence()
	influence = 0
	figures_in_lair = 0
	lair_loot = list()
	var/turf/lair_turf = get_turf(lair)
	if(lair_turf)
		var/datum/objective_item/first_loot = get_loot_datum(tier_one_loot)
		var/datum/objective_item/second_loot = get_loot_datum(tier_two_loot)
		var/obj/item/first_found
		var/obj/item/second_found
		var/list/figure_types = list()
		for(var/obj/item/thing in lair_turf)
			if(HAS_TRAIT(thing, TRAIT_ITEM_OBJECTIVE_BLOCKED))
				continue
			if(!first_found && is_target_loot(first_loot, thing))
				first_found = thing
			else if(!second_found && is_target_loot(second_loot, thing))
				second_found = thing
			else if(is_crew_figure(thing) && length(figure_types) < LOOT_GOBLIN_MAX_FIGURES)
				figure_types |= thing.type
		figures_in_lair = length(figure_types)
		var/figure_points = figures_in_lair * LOOT_GOBLIN_FIGURE_INFLUENCE
		if(tier_one_closed_by == LOOT_GOBLIN_CLOSED_BY_LOOT && !first_found)
			tier_one_closed_by = null
		if(tier_one_closed_by == LOOT_GOBLIN_CLOSED_BY_FIGURES && figure_points < LOOT_GOBLIN_TIER_TWO_INFLUENCE)
			tier_one_closed_by = null
		if(!tier_one_closed_by)
			if(first_found)
				tier_one_closed_by = LOOT_GOBLIN_CLOSED_BY_LOOT
			else if(figure_points >= LOOT_GOBLIN_TIER_TWO_INFLUENCE)
				tier_one_closed_by = LOOT_GOBLIN_CLOSED_BY_FIGURES
		if(!tier_one_closed_by)
			influence = figure_points
		else
			influence = LOOT_GOBLIN_TIER_TWO_INFLUENCE
			if(tier_one_closed_by == LOOT_GOBLIN_CLOSED_BY_LOOT)
				lair_loot += list(list("name" = first_found.declent_ru(NOMINATIVE), "value" = LOOT_GOBLIN_LOOT_INFLUENCE))
			else
				figure_points -= LOOT_GOBLIN_TIER_TWO_INFLUENCE
			if(second_found)
				influence += LOOT_GOBLIN_LOOT_INFLUENCE
				lair_loot += list(list("name" = second_found.declent_ru(NOMINATIVE), "value" = LOOT_GOBLIN_LOOT_INFLUENCE))
			else
				influence += min(figure_points, LOOT_GOBLIN_TIER_THREE_INFLUENCE - LOOT_GOBLIN_TIER_TWO_INFLUENCE)
	else
		tier_one_closed_by = null
	if(influence >= LOOT_GOBLIN_TIER_THREE_INFLUENCE)
		influence = min(influence + sacrifices_done * LOOT_GOBLIN_SACRIFICE_INFLUENCE, LOOT_GOBLIN_MAX_INFLUENCE)
	if(admin_tier)
		influence = min((admin_tier - 1) * LOOT_GOBLIN_TIER_TWO_INFLUENCE, LOOT_GOBLIN_MAX_INFLUENCE)
	var/has_aura = influence >= LOOT_GOBLIN_AURA_INFLUENCE
	if(has_aura != aura_shown)
		aura_shown = has_aura
		owner?.current?.update_appearance(UPDATE_OVERLAYS)
	update_tier()

/datum/antagonist/loot_goblin/proc/add_aura_overlay(mob/living/source, list/overlays)
	SIGNAL_HANDLER
	if(!aura_shown)
		return
	overlays += mutable_appearance('icons/mob/effects/loot_goblin_aura.dmi', "loot_goblin_aura")
	overlays += emissive_appearance('icons/mob/effects/loot_goblin_aura.dmi', "loot_goblin_aura", source, alpha = 200)

/datum/antagonist/loot_goblin/proc/update_tier()
	var/new_tier = 1
	if(influence >= LOOT_GOBLIN_TIER_THREE_INFLUENCE)
		new_tier = min(LOOT_GOBLIN_TIER_ANY_SACRIFICE + sacrifices_done, LOOT_GOBLIN_TIER_ESCAPE)
	else if(influence >= LOOT_GOBLIN_TIER_TWO_INFLUENCE)
		new_tier = 2
	if(admin_tier)
		new_tier = admin_tier
	if(new_tier == tier)
		return
	var/old_tier = tier
	tier = new_tier
	if(tier == LOOT_GOBLIN_TIER_CONTRACT)
		get_contract_target()
	tier_objective?.update_explanation_text()
	update_static_data_for_all_viewers()
	ritual_action?.build_all_button_icons(UPDATE_BUTTON_STATUS)
	cauldron_action?.build_all_button_icons(UPDATE_BUTTON_STATUS)
	update_perks(owner?.current)
	if(!old_tier || !owner?.current)
		return
	if(new_tier > old_tier)
		to_chat(owner.current, span_boldnotice("Ваша жадность растёт! Вы достигли тира [new_tier]."))
	else
		to_chat(owner.current, span_bolddanger("Логово разграбили! Вы откатились на тир [new_tier]."))
	if(get_pending_perk_tier())
		to_chat(owner.current, span_notice("Доступен выбор умения в меню гоблина."))
	owner.announce_objectives()

/datum/antagonist/loot_goblin/proc/complete_sacrifice()
	sacrifices_done++
	contract_target_ref = null
	if(admin_tier)
		admin_tier = min(admin_tier + 1, LOOT_GOBLIN_TIER_ESCAPE)
	update_influence()

/datum/antagonist/loot_goblin/proc/is_valid_sacrifice_mind(datum/mind/candidate)
	if(!candidate?.key || candidate == owner)
		return FALSE
	var/mob/living/carbon/human/body = candidate.current
	if(!ishuman(body) || QDELETED(body) || HAS_TRAIT(body, TRAIT_LESSER_HUMANOID))
		return FALSE
	return candidate.assigned_role?.job_flags & JOB_CREW_MEMBER

/datum/antagonist/loot_goblin/proc/get_contract_target()
	var/datum/mind/target_mind = contract_target_ref?.resolve()
	if(is_valid_sacrifice_mind(target_mind))
		return target_mind
	var/list/candidates = list()
	for(var/datum/mind/candidate as anything in get_crewmember_minds())
		if(is_valid_sacrifice_mind(candidate) && candidate.current.stat != DEAD)
			candidates += candidate
	target_mind = length(candidates) ? pick(candidates) : null
	contract_target_ref = target_mind ? WEAKREF(target_mind) : null
	tier_objective?.update_explanation_text()
	update_static_data_for_all_viewers()
	if(tier == LOOT_GOBLIN_TIER_CONTRACT && owner?.current)
		if(target_mind)
			to_chat(owner.current, span_bolddanger("Новый заказ: [target_mind.name], [target_mind.assigned_role.title]."))
		else
			to_chat(owner.current, span_bolddanger("Подходящей цели для заказа нет: подойдёт любой сотрудник станции."))
	return target_mind

/datum/antagonist/loot_goblin/proc/is_head_available()
	for(var/datum/mind/candidate as anything in get_crewmember_minds())
		if(is_valid_sacrifice_mind(candidate) && (candidate.assigned_role.job_flags & JOB_HEAD_OF_STAFF) && candidate.current.stat != DEAD)
			return TRUE
	return FALSE

/datum/antagonist/loot_goblin/proc/is_fitting_sacrifice(mob/living/carbon/human/victim)
	if(!is_valid_sacrifice_mind(victim.mind))
		return FALSE
	switch(tier)
		if(LOOT_GOBLIN_TIER_CONTRACT)
			var/datum/mind/target_mind = get_contract_target()
			return !target_mind || victim.mind == target_mind
		if(LOOT_GOBLIN_TIER_HEAD)
			return (victim.mind.assigned_role.job_flags & JOB_HEAD_OF_STAFF) || !is_head_available()
	return TRUE

/datum/antagonist/loot_goblin/proc/pick_sacrifice_destination()
	for(var/area_type in shuffle(sacrifice_areas))
		var/list/turfs = list()
		for(var/turf/open/floor/floor in get_area_turfs(area_type, subtypes = TRUE))
			if(!floor.is_blocked_turf(exclude_mobs = TRUE))
				turfs += floor
		if(length(turfs))
			return pick(turfs)
	return null

/datum/antagonist/loot_goblin/proc/get_pending_perk_tier()
	for(var/perk_tier in LOOT_GOBLIN_FIRST_PERK_TIER to min(tier, LOOT_GOBLIN_PERK_TIERS))
		if(!chosen_perks[perk_tier])
			return perk_tier
	return null

/datum/antagonist/loot_goblin/proc/get_perk_options(perk_tier)
	var/list/options = list()
	for(var/perk in perk_info)
		if(perk_info[perk]["tier"] <= perk_tier && !(perk in chosen_perks))
			options += perk
	return options

/datum/antagonist/loot_goblin/proc/choose_perk(perk)
	var/perk_tier = get_pending_perk_tier()
	if(!perk_tier || !(perk in get_perk_options(perk_tier)))
		return FALSE
	chosen_perks[perk_tier] = perk
	update_perks(owner.current)
	to_chat(owner.current, span_boldnotice("Вы получили умение «[perk_info[perk]["name"]]»."))
	return TRUE

/datum/antagonist/loot_goblin/proc/update_perks(mob/living/goblin)
	if(!ishuman(goblin))
		return
	if(tier >= LOOT_GOBLIN_BONUS_SPEED_TIER)
		goblin.add_movespeed_modifier(/datum/movespeed_modifier/loot_goblin_tier_bonus)
	else
		goblin.remove_movespeed_modifier(/datum/movespeed_modifier/loot_goblin_tier_bonus)
	var/list/active_perks = list()
	for(var/perk_tier in LOOT_GOBLIN_FIRST_PERK_TIER to LOOT_GOBLIN_PERK_TIERS)
		if(chosen_perks[perk_tier] && tier >= perk_tier)
			active_perks += chosen_perks[perk_tier]
	for(var/perk in applied_perks.Copy())
		if(!(perk in active_perks))
			remove_perk(goblin, perk)
	for(var/perk in active_perks)
		if(!(perk in applied_perks))
			apply_perk(goblin, perk)

/datum/antagonist/loot_goblin/proc/apply_perk(mob/living/goblin, perk)
	applied_perks += perk
	switch(perk)
		if(LOOT_GOBLIN_PERK_SPEED)
			goblin.add_movespeed_modifier(/datum/movespeed_modifier/loot_goblin)
		if(LOOT_GOBLIN_PERK_REGEN)
			goblin.apply_status_effect(/datum/status_effect/loot_goblin_regen)
		if(LOOT_GOBLIN_PERK_NIGHT_VISION)
			ADD_TRAIT(goblin, TRAIT_TRUE_NIGHT_VISION, REF(src))
			goblin.update_sight()
		if(LOOT_GOBLIN_PERK_DOOR_PRY)
			ADD_TRAIT(goblin, TRAIT_LOOT_GOBLIN_DOOR_PRYER, REF(src))
			goblin.AddElement(/datum/element/door_pryer, LOOT_GOBLIN_DOOR_PRY_TIME)
		if(LOOT_GOBLIN_PERK_RECALL)
			recall_action.Grant(goblin)
		if(LOOT_GOBLIN_PERK_SMOKE)
			smoke_action.Grant(goblin)
		if(LOOT_GOBLIN_PERK_TRAP)
			trap_action.Grant(goblin)
		if(LOOT_GOBLIN_PERK_HEARING)
			goblin.apply_status_effect(/datum/status_effect/loot_goblin_hearing)
		if(LOOT_GOBLIN_PERK_STEADY)
			ADD_TRAIT(goblin, TRAIT_LOOT_GOBLIN_STEADY_FEET, REF(src))
			MODIFY_PHYSIOLOGY(goblin, PHYS_COEFF_STUN, LOOT_GOBLIN_STEADY_STUN_MULT)

/datum/antagonist/loot_goblin/proc/remove_perk(mob/living/goblin, perk)
	applied_perks -= perk
	switch(perk)
		if(LOOT_GOBLIN_PERK_SPEED)
			goblin.remove_movespeed_modifier(/datum/movespeed_modifier/loot_goblin)
		if(LOOT_GOBLIN_PERK_REGEN)
			goblin.remove_status_effect(/datum/status_effect/loot_goblin_regen)
		if(LOOT_GOBLIN_PERK_NIGHT_VISION)
			REMOVE_TRAIT(goblin, TRAIT_TRUE_NIGHT_VISION, REF(src))
			goblin.update_sight()
		if(LOOT_GOBLIN_PERK_DOOR_PRY)
			if(HAS_TRAIT_FROM(goblin, TRAIT_LOOT_GOBLIN_DOOR_PRYER, REF(src)))
				REMOVE_TRAIT(goblin, TRAIT_LOOT_GOBLIN_DOOR_PRYER, REF(src))
				goblin.RemoveElement(/datum/element/door_pryer, LOOT_GOBLIN_DOOR_PRY_TIME)
		if(LOOT_GOBLIN_PERK_RECALL)
			recall_action.Remove(goblin)
		if(LOOT_GOBLIN_PERK_SMOKE)
			smoke_action.Remove(goblin)
		if(LOOT_GOBLIN_PERK_TRAP)
			trap_action.Remove(goblin)
		if(LOOT_GOBLIN_PERK_HEARING)
			goblin.remove_status_effect(/datum/status_effect/loot_goblin_hearing)
		if(LOOT_GOBLIN_PERK_STEADY)
			REMOVE_TRAIT(goblin, TRAIT_LOOT_GOBLIN_STEADY_FEET, REF(src))
			MODIFY_PHYSIOLOGY(goblin, PHYS_COEFF_STUN, 1 / LOOT_GOBLIN_STEADY_STUN_MULT)

/datum/antagonist/loot_goblin/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(action == "choose_perk")
		return choose_perk(params["perk"])

/datum/antagonist/loot_goblin/ui_static_data(mob/user)
	var/list/data = ..()
	var/list/recipes = list()
	for(var/list/recipe as anything in GLOB.loot_goblin_recipes)
		var/obj/item/loot_goblin_potion/potion_type = recipe["potion"]
		var/list/ingredients = list()
		var/list/recipe_ingredients = recipe["ingredients"]
		for(var/ingredient_type in recipe_ingredients)
			ingredients += list(list("name" = GLOB.loot_goblin_ingredient_names[ingredient_type], "amount" = recipe_ingredients[ingredient_type]))
		var/list/ru_name = ru_names_toml(initial(potion_type.name))
		recipes += list(list("name" = ru_name[NOMINATIVE] || initial(potion_type.name), "effect" = initial(potion_type.effect_desc), "ingredients" = ingredients))
	data["recipes"] = recipes
	return data

/datum/antagonist/loot_goblin/ui_data(mob/user)
	var/list/data = list()
	data["cauldron_unlocked"] = tier >= LOOT_GOBLIN_TIER_HEAD
	data["cauldron_placed"] = !!cauldron
	data["cauldron_cooldown"] = cauldron ? round(COOLDOWN_TIMELEFT(cauldron, brew_cooldown) / 10) : 0
	data["tier"] = tier
	data["influence"] = influence
	data["max_influence"] = LOOT_GOBLIN_MAX_INFLUENCE
	data["figures"] = figures_in_lair
	data["max_figures"] = LOOT_GOBLIN_MAX_FIGURES
	data["has_lair"] = !!lair
	data["lair_loot"] = lair_loot
	var/pending_tier = get_pending_perk_tier()
	data["pending_perk_tier"] = pending_tier
	var/list/options = list()
	if(pending_tier)
		for(var/perk in get_perk_options(pending_tier))
			options += list(list("id" = perk, "name" = perk_info[perk]["name"], "desc" = perk_info[perk]["desc"], "tier" = perk_info[perk]["tier"]))
	data["perk_options"] = options
	var/list/perks = list()
	for(var/perk_tier in LOOT_GOBLIN_FIRST_PERK_TIER to LOOT_GOBLIN_PERK_TIERS)
		var/perk = chosen_perks[perk_tier]
		if(perk)
			perks += list(list("id" = perk, "tier" = perk_tier, "name" = perk_info[perk]["name"], "desc" = perk_info[perk]["desc"], "active" = tier >= perk_tier))
	data["perks"] = perks
	return data

/datum/objective/loot_goblin_tier
	name = "loot goblin tier"
	admin_grantable = FALSE

/datum/objective/loot_goblin_tier/update_explanation_text()
	var/datum/antagonist/loot_goblin/goblin = owner?.has_antag_datum(/datum/antagonist/loot_goblin)
	if(!goblin)
		return
	switch(goblin.tier)
		if(1)
			explanation_text = "Тир 1: принесите в логово [goblin.get_loot_name(goblin.tier_one_loot) || "ценную вещь отдела"] или [LOOT_GOBLIN_TIER_FIGURES] коллекционных фигурок экипажа ([LOOT_GOBLIN_TIER_TWO_INFLUENCE] жадности)."
		if(2)
			explanation_text = "Тир 2: принесите в логово [goblin.get_loot_name(goblin.tier_two_loot) || "ценную вещь отдела"] или ещё [LOOT_GOBLIN_TIER_FIGURES] коллекционных фигурок экипажа ([LOOT_GOBLIN_TIER_THREE_INFLUENCE] жадности)."
		if(LOOT_GOBLIN_TIER_ANY_SACRIFICE)
			explanation_text = "Тир 3: принесите в жертву сотрудника станции. Он должен лежать в логове мёртвым или в критическом состоянии."
		if(LOOT_GOBLIN_TIER_CONTRACT)
			var/datum/mind/target_mind = goblin.contract_target_ref?.resolve()
			if(target_mind)
				explanation_text = "Тир 4: заказ — принесите в жертву [target_mind.name], [target_mind.assigned_role.title]. Цель должна лежать в логове мёртвой или в критическом состоянии."
			else
				explanation_text = "Тир 4: заказ — принесите в жертву любого сотрудника станции."
		if(LOOT_GOBLIN_TIER_HEAD)
			explanation_text = "Тир 5: принесите в жертву любого главу отдела. Вам открыт гоблинский алхимический котёл."
		if(LOOT_GOBLIN_TIER_ESCAPE)
			explanation_text = "Тир 6: сбегите со станции на эвакуационном шаттле, не дав разграбить логово."

/datum/objective/loot_goblin_tier/check_completion()
	var/datum/antagonist/loot_goblin/goblin = owner?.has_antag_datum(/datum/antagonist/loot_goblin)
	return goblin?.tier == LOOT_GOBLIN_TIER_ESCAPE && considered_escaped(owner)

/datum/movespeed_modifier/loot_goblin
	multiplicative_slowdown = -0.25

/datum/movespeed_modifier/loot_goblin_tier_bonus
	multiplicative_slowdown = -0.1

/datum/status_effect/loot_goblin_regen
	id = "loot_goblin_regen"
	status_type = STATUS_EFFECT_UNIQUE
	duration = STATUS_EFFECT_PERMANENT
	tick_interval = 1 SECONDS
	alert_type = null

/datum/status_effect/loot_goblin_regen/tick(seconds_between_ticks)
	if(owner.stat == DEAD)
		return
	var/turf/owner_turf = get_turf(owner)
	if(!owner_turf || owner_turf.get_lumcount() > SHADOW_SPECIES_LIGHT_THRESHOLD)
		return
	owner.heal_overall_damage(brute = LOOT_GOBLIN_REGEN_PER_SECOND * seconds_between_ticks, burn = LOOT_GOBLIN_REGEN_PER_SECOND * seconds_between_ticks)
