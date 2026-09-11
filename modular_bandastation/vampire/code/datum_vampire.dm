/datum/antagonist/vampire
	name = "\proper Вампир"
	roundend_category = "Вампиры"
	antagpanel_category = "Вампир"
	pref_flag = ROLE_VAMPIRE
	antag_moodlet = /datum/mood_event/focused
	hijack_speed = 0.5
	suicide_cry = "Я УМИРАЮ РАДИ НОЧИ!"
	preview_outfit = /datum/outfit/butler
	stinger_sound = 'sound/music/antag/heretic/heretic_gain.ogg'
	antag_flags = parent_type::antag_flags | ANTAG_OBSERVER_VISIBLE_PANEL

	ui_name = "AntagInfoGeneric"
	antag_hud_name = "vampire"
	hud_icon = 'modular_bandastation/vampire/icons/mob/huds/vampire_antag.dmi'

	var/bloodtotal = 0
	var/bloodusable = 0
	/// What vampire subclass the vampire is.
	var/datum/vampire_subclass/subclass
	/// Handles the vampire cloak toggle
	var/iscloaking = FALSE
	/// List of available active spell actions and passives
	var/list/powers = list()
	/// Who the vampire is draining of blood
	var/mob/living/carbon/human/draining
	/// Null rods and holy water make abilities cost more
	var/nullified = 0

	/// Powers that all vampires unlock and at what blood total level they unlock them
	var/list/upgrade_tiers = list(
		/datum/action/cooldown/spell/vampire_rejuvenate = 0,
		/datum/action/cooldown/spell/aoe/vampire_glare = 0,
		/datum/vampire_passive/vision = 100,
		/datum/action/cooldown/spell/vampire_specialize = 150,
		/datum/action/cooldown/spell/pointed/vampire_lair = 150,
		/datum/vampire_passive/regen = 200,
		/datum/vampire_passive/vision/advanced = 500,
	)

	/// List of victims' REF IDs we have drained and how much blood from each
	var/list/drained_humans = list()
	/// Weak references to the thralls bound to this vampire.
	var/list/thrall_refs = list()
	/// Did the vampire build a lair?
	var/has_lair = FALSE

/datum/antagonist/vampire/Destroy(force, ...)
	draining = null
	remove_all_powers()
	QDEL_NULL(subclass)
	return ..()

/datum/antagonist/vampire/on_removal()
	deconvert_thralls()
	if(owner?.current)
		log_combat(owner.current, owner.current, "de-vampired")
		owner.current.alpha = 255
	return ..()

/datum/antagonist/vampire/on_gain()
	forge_objectives()
	return ..()

/datum/antagonist/vampire/proc/adjust_nullification(base, extra)
	nullified = clamp(nullified + extra, base, VAMPIRE_NULLIFICATION_CAP)

/datum/antagonist/vampire/antag_panel_data()
	return "Специализация: [subclass.name] | Всего крови: [bloodtotal] | Доступно крови: [bloodusable]"

/datum/antagonist/vampire/get_admin_commands()
	. = ..()
	.["Установить общее количество крови"] = CALLBACK(src, PROC_REF(admin_set_total_blood))
	.["Установить доступную кровь"] = CALLBACK(src, PROC_REF(admin_set_usable_blood))

/datum/antagonist/vampire/proc/admin_set_total_blood(mob/admin)
	var/new_total = tgui_input_number(admin, "Установите общее количество крови, выпитой вампиром за жизнь.", "Установить общее количество крови", default = bloodtotal, min_value = 0)
	if(isnull(new_total) || QDELETED(src))
		return
	var/old_total = bloodtotal
	bloodtotal = new_total
	bloodusable = min(bloodusable, bloodtotal)
	subtract_usable_blood(0)
	check_vampire_upgrade()
	message_admins("[key_name_admin(admin)] set [key_name_admin(owner)]'s total vampire blood from [old_total] to [bloodtotal].")
	log_admin("[key_name(admin)] set [key_name(owner)]'s total vampire blood from [old_total] to [bloodtotal].")

/datum/antagonist/vampire/proc/admin_set_usable_blood(mob/admin)
	var/new_usable = tgui_input_number(admin, "Установите текущее количество доступной вампиру крови.", "Установить доступную кровь", default = bloodusable, max_value = bloodtotal, min_value = 0)
	if(isnull(new_usable) || QDELETED(src))
		return
	var/old_usable = bloodusable
	bloodusable = new_usable
	update_blood_hud()
	for(var/datum/action/cooldown/spell/spell in powers)
		spell.build_all_button_icons()
	message_admins("[key_name_admin(admin)] set [key_name_admin(owner)]'s usable vampire blood from [old_usable] to [bloodusable].")
	log_admin("[key_name(admin)] set [key_name(owner)]'s usable vampire blood from [old_usable] to [bloodusable].")

/datum/antagonist/vampire/proc/force_add_ability(path)
	var/datum/power = new path()
	powers += power

	if(istype(power, /datum/action/cooldown/spell))
		var/datum/action/cooldown/spell/spell = power
		spell.Grant(owner.current)
	else if(istype(power, /datum/vampire_passive))
		var/datum/vampire_passive/passive = power
		passive.owner = owner.current
		passive.on_apply(src)

/datum/antagonist/vampire/proc/get_ability(path)
	for(var/datum/power as anything in powers)
		if(power.type == path)
			return power
	return null

/datum/antagonist/vampire/proc/add_ability(path)
	if(!get_ability(path))
		force_add_ability(path)

/datum/antagonist/vampire/proc/remove_ability(datum/ability)
	if(ability && (ability in powers))
		powers -= ability
		if(istype(ability, /datum/action))
			var/datum/action/action = ability
			action.Remove(owner.current)
		qdel(ability)
		if(owner?.current)
			owner.current.update_sight()

/datum/antagonist/vampire/proc/remove_all_powers()
	for(var/power in powers)
		remove_ability(power)

/datum/antagonist/vampire/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/vampire_mob = mob_override || owner.current
	if(!vampire_mob)
		return
	if(ishuman(vampire_mob))
		var/mob/living/carbon/human/human_target = vampire_mob
		human_target.set_hunger_icon('modular_bandastation/vampire/icons/screen_hunger_vampire.dmi')
		human_target.AddComponent(/datum/component/vampire_biter)
		human_target.AddComponent(/datum/component/vampire_holywater)

	update_blood_hud()
	check_vampire_upgrade(FALSE)
	RegisterSignal(vampire_mob, COMSIG_ATOM_HOLYATTACK, PROC_REF(holy_attack_reaction))
	RegisterSignal(vampire_mob, COMSIG_LIVING_LIFE, PROC_REF(on_life))
	RegisterSignal(vampire_mob, COMSIG_MOB_HUD_CREATED, PROC_REF(on_hud_created))
	RegisterSignal(vampire_mob, COMSIG_FIRE_STACKS_UPDATED, PROC_REF(on_fire_stacks_updated))
	update_thrall_huds()

/datum/antagonist/vampire/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/vampire_mob = mob_override || owner.current
	remove_all_powers()
	if(!vampire_mob)
		return
	vampire_mob.remove_alt_appearance(get_thrall_hud_key("vampire"))
	clear_thrall_huds()
	vampire_mob?.hud_used?.remove_screen_object(HUD_MOB_VAMPIRE_BLOOD)

	if(ishuman(vampire_mob))
		var/mob/living/carbon/human/human_target = vampire_mob
		human_target.reset_hunger_icon()
		var/datum/component/vampire_biter/vampire_biter = human_target.GetComponent(/datum/component/vampire_biter)
		QDEL_NULL(vampire_biter)
		var/datum/component/vampire_holywater/vampire_holywater = human_target.GetComponent(/datum/component/vampire_holywater)
		QDEL_NULL(vampire_holywater)
		human_target.alpha = 255

	REMOVE_TRAITS_IN(vampire_mob, "vampire")
	UnregisterSignal(vampire_mob, list(
		COMSIG_ATOM_HOLYATTACK,
		COMSIG_LIVING_LIFE,
		COMSIG_MOB_HUD_CREATED,
		COMSIG_FIRE_STACKS_UPDATED,
	))

/datum/antagonist/vampire/proc/holy_attack_reaction(mob/target, obj/item/source, mob/user, antimagic_flags)
	SIGNAL_HANDLER
	if(!HAS_TRAIT(user?.mind, TRAIT_HOLY))
		return
	if(!source.force)
		return

	var/bonus_force = 0
	if(istype(source, /obj/item/nullrod))
		var/obj/item/nullrod/nullrod = source
		bonus_force = nullrod.sanctify_force

	if(!get_ability(/datum/vampire_passive/full))
		to_chat(owner.current, span_warning("Сила [source] мешает вашим собственным силам!"))
		adjust_nullification(30 + bonus_force, 15 + bonus_force)

/// Fire consumes blood while it can still harm the vampire, matching the fire handler's protection threshold.
/datum/antagonist/vampire/proc/on_fire_stacks_updated(mob/living/vampire_mob, fire_stacks)
	SIGNAL_HANDLER
	if(vampire_mob != owner?.current || vampire_mob.stat == DEAD || !fire_stacks || get_ability(/datum/vampire_passive/full))
		return
	if(ishuman(vampire_mob))
		var/mob/living/carbon/human/human_vampire = vampire_mob
		if(human_vampire.get_thermal_protection() >= FIRE_SUIT_MAX_TEMP_PROTECT)
			return
	subtract_usable_blood(5)

#define BLOOD_GAINED_MODIFIER 0.5

/datum/antagonist/vampire/proc/handle_bloodsucking(mob/living/carbon/human/target_human, suck_rate = 5 SECONDS)
	draining = target_human
	var/unique_suck_id = REF(target_human)
	var/blood = 0
	var/blood_volume_warning = 9999
	var/mob/living/caster = owner.current

	if(caster.is_mouth_covered())
		to_chat(caster, span_warning("Ваша маска или намордник не позволяют укусить [target_human]!"))
		draining = null
		return

	log_combat(caster, target_human, "bitten & drained of blood (vampire)")
	caster.visible_message(
		span_danger("[caster] грубо хватает [target_human] за шею и вонзает [caster.p_their()] клыки!"),
		span_danger("Вы вонзаете клыки в [target_human] и начинаете высасывать [target_human.p_their()] кровь."),
		span_notice("Вы слышите тихий прокол и влажный чавкающий звук."),
	)

	while(do_after(caster, suck_rate, target_human, cog_icon = null))
		// TODO: compact this
		caster.do_attack_animation(target_human, ATTACK_EFFECT_BITE)
		if(unique_suck_id in drained_humans)
			if(drained_humans[unique_suck_id] >= BLOOD_DRAIN_LIMIT)
				to_chat(caster, span_warning("Вы выпили из крови [target_human] почти всю жизненную силу и больше не получите доступной крови!"))
				target_human.blood_volume = max(target_human.blood_volume - 25, 0)
				caster.set_nutrition(min(NUTRITION_LEVEL_WELL_FED, caster.nutrition + 5))
				continue

		if(target_human.stat != DEAD)
			if(target_human.ckey || target_human.get_ghost(FALSE))
				blood = min(20, target_human.blood_volume)
				adjust_blood(target_human, blood * BLOOD_GAINED_MODIFIER)
				to_chat(caster, span_notice("<b>Вы накопили [bloodtotal] ед. крови; для использования осталось [bloodusable].</b>"))

		target_human.blood_volume = max(target_human.blood_volume - 25, 0)

		if(target_human.blood_volume)
			if(target_human.blood_volume <= BLOOD_VOLUME_BAD && blood_volume_warning > BLOOD_VOLUME_BAD)
				to_chat(caster, span_danger("Объём крови вашей жертвы опасно низок."))
			else if(target_human.blood_volume <= BLOOD_VOLUME_OKAY && blood_volume_warning > BLOOD_VOLUME_OKAY)
				to_chat(caster, span_warning("У вашей жертвы небезопасно мало крови."))
			blood_volume_warning = target_human.blood_volume
		else
			to_chat(caster, span_warning("Вы обескровили свою жертву!"))
			break

		if(!target_human.ckey && !target_human.get_ghost(FALSE))
			to_chat(caster, span_notice("<b>Питание кровью [target_human] утоляет ваш голод, но не даёт доступной крови.</b>"))
			caster.set_nutrition(min(NUTRITION_LEVEL_WELL_FED, caster.nutrition + 5))
		else
			caster.set_nutrition(min(NUTRITION_LEVEL_WELL_FED, caster.nutrition + (blood / 2)))

	draining = null
	to_chat(caster, span_notice("Вы прекращаете высасывать кровь из [target_human.name]."))

#undef BLOOD_GAINED_MODIFIER

/datum/antagonist/vampire/proc/change_subclass(new_subclass_type)
	if(isnull(new_subclass_type))
		return
	clear_subclass(FALSE)
	add_subclass(new_subclass_type, log_choice = FALSE)

/datum/antagonist/vampire/proc/clear_subclass(give_specialize_power = TRUE)
	if(give_specialize_power)
		upgrade_tiers[/datum/action/cooldown/spell/vampire_specialize] = 150
	remove_all_powers()
	QDEL_NULL(subclass)
	check_vampire_upgrade()

/datum/antagonist/vampire/proc/check_vampire_upgrade(announce = TRUE)
	var/list/old_powers = powers.Copy()

	for(var/ptype in upgrade_tiers)
		var/level = upgrade_tiers[ptype]
		if(bloodtotal >= level)
			add_ability(ptype)

	if(!subclass)
		return
	subclass.add_subclass_ability(src)
	check_full_power_upgrade()

	if(announce)
		announce_new_power(old_powers)

/datum/antagonist/vampire/proc/check_full_power_upgrade()
	if(subclass?.full_power_override || (length(drained_humans) >= FULLPOWER_DRAINED_REQUIREMENT && bloodtotal >= FULLPOWER_BLOODTOTAL_REQUIREMENT))
		subclass?.add_full_power_abilities(src)

/datum/antagonist/vampire/proc/announce_new_power(list/old_powers)
	for(var/power in powers)
		if(power in old_powers)
			continue
		if(istype(power, /datum/vampire_passive))
			var/datum/vampire_passive/passive = power
			to_chat(owner.current, span_boldnotice("[passive.gain_desc]"))

/datum/antagonist/vampire/proc/check_sun()
	var/turf/turf_loc = get_turf(owner.current)
	if(!turf_loc || turf_loc.is_sunlight_blocked())
		return

	if(bloodusable >= 10)
		to_chat(owner.current, span_userdanger("Свет звёзд высасывает ваши силы — покиньте его!"))
		subtract_usable_blood(10)
		vamp_burn(10)
	else
		to_chat(owner.current, span_userdanger("Ваше тело превращается в пепел — НЕМЕДЛЕННО уйдите от света звёзд!"))
		owner.current.apply_status_effect(/datum/status_effect/genetic_damage, 100)
		vamp_burn(85)
		if(owner.current.health <= HEALTH_THRESHOLD_DEAD)
			owner.current.dust()

/// Runs the vampire's persistent effects alongside tg's normal living-mob life processing.
/datum/antagonist/vampire/proc/on_life(mob/living/vampire_mob, seconds_per_tick)
	SIGNAL_HANDLER
	if(vampire_mob != owner?.current)
		return
	handle_vampire(vampire_mob)

/// Handles effects which need to be checked every life tick.
/datum/antagonist/vampire/proc/handle_vampire(mob/living/vampire_mob)
	handle_vampire_cloak(vampire_mob)
	if(isspaceturf(get_turf(vampire_mob)))
		check_sun()
	if(istype(get_area(vampire_mob), /area/station/service/chapel) && !get_ability(/datum/vampire_passive/full) && bloodtotal > 0)
		vamp_burn(7)
	nullified = max(0, nullified - 2)

/datum/antagonist/vampire/proc/on_hud_created(mob/living/vampire_mob)
	SIGNAL_HANDLER
	if(vampire_mob == owner?.current)
		update_blood_hud()

/datum/antagonist/vampire/proc/handle_vampire_cloak(mob/living/vampire_mob)
	if(!ishuman(vampire_mob))
		vampire_mob.alpha = 255
		return

	var/mob/living/carbon/human/human_owner = vampire_mob
	var/turf/turf_loc = get_turf(human_owner)
	if(!turf_loc)
		return

	var/light_available = turf_loc.get_lumcount() * 10

	if(!iscloaking || human_owner.on_fire)
		human_owner.alpha = 255
		return

	if(light_available <= 2)
		human_owner.alpha = 40
		return

	human_owner.alpha = 200

/datum/antagonist/vampire/proc/adjust_blood(mob/living/carbon/victim, blood_amount = 0)
	if(victim)
		var/unique_suck_id = REF(victim)
		if(!(unique_suck_id in drained_humans))
			drained_humans[unique_suck_id] = 0
		if(drained_humans[unique_suck_id] >= BLOOD_DRAIN_LIMIT)
			return
		drained_humans[unique_suck_id] += blood_amount

	bloodtotal += blood_amount
	bloodusable += blood_amount
	update_blood_hud()
	check_vampire_upgrade(TRUE)

	for(var/datum/action/cooldown/spell/spell in powers)
		spell.build_all_button_icons()

/datum/antagonist/vampire/proc/subtract_usable_blood(blood_amount)
	bloodusable = clamp(bloodusable - blood_amount, 0, bloodtotal)
	update_blood_hud()
	for(var/datum/action/cooldown/spell/spell in powers)
		spell.build_all_button_icons()

/datum/antagonist/vampire/proc/update_blood_hud()
	var/datum/hud/hud = owner?.current?.hud_used
	if(!hud)
		return

	var/atom/movable/screen/vampire_blood/blood_display = hud.screen_objects[HUD_MOB_VAMPIRE_BLOOD]
	if(!blood_display)
		blood_display = hud.add_screen_object(/atom/movable/screen/vampire_blood, HUD_MOB_VAMPIRE_BLOOD, HUD_GROUP_INFO, update_screen = TRUE)
	blood_display.update_maptext()

/datum/antagonist/vampire/proc/add_thrall(datum/antagonist/vampire_thrall/thrall)
	if(!thrall)
		return
	LAZYADD(thrall_refs, WEAKREF(thrall))
	update_thrall_huds()

/datum/antagonist/vampire/proc/remove_thrall(datum/antagonist/vampire_thrall/thrall)
	thrall?.owner?.current?.remove_alt_appearance(get_thrall_hud_key("thrall"))
	for(var/datum/weakref/thrall_ref as anything in thrall_refs)
		if(thrall_ref.resolve() == thrall)
			thrall_refs -= thrall_ref
			break
	update_thrall_huds()

/datum/antagonist/vampire/proc/get_thralls()
	var/list/datum/antagonist/vampire_thrall/active_thralls = list()
	for(var/datum/weakref/thrall_ref as anything in thrall_refs)
		var/datum/antagonist/vampire_thrall/thrall = thrall_ref.resolve()
		if(!thrall || thrall.get_master() != src)
			thrall_refs -= thrall_ref
			continue
		active_thralls += thrall
	return active_thralls

/datum/antagonist/vampire/proc/deconvert_thralls()
	for(var/datum/antagonist/vampire_thrall/thrall as anything in get_thralls())
		thrall.owner?.remove_antag_datum(/datum/antagonist/vampire_thrall)
	thrall_refs.Cut()
	clear_thrall_huds()

/datum/antagonist/vampire/proc/get_thrall_hud_key(role)
	return "vampire_network_[role]_[REF(src)]"

/datum/antagonist/vampire/proc/clear_thrall_huds()
	owner?.current?.remove_alt_appearance(get_thrall_hud_key("vampire"))
	for(var/datum/antagonist/vampire_thrall/thrall as anything in get_thralls())
		thrall.owner?.current?.remove_alt_appearance(get_thrall_hud_key("thrall"))

/datum/antagonist/vampire/proc/update_thrall_huds()
	clear_thrall_huds()
	var/mob/living/vampire_mob = owner?.current
	if(!vampire_mob)
		return
	vampire_mob.add_alt_appearance(
		/datum/atom_hud/alternate_appearance/basic/vampire_network,
		get_thrall_hud_key("vampire"),
		hud_image_on(vampire_mob),
		src,
	)
	for(var/datum/antagonist/vampire_thrall/thrall as anything in get_thralls())
		var/mob/living/thrall_mob = thrall.owner?.current
		if(!thrall_mob)
			continue
		thrall_mob.add_alt_appearance(
			/datum/atom_hud/alternate_appearance/basic/vampire_network,
			get_thrall_hud_key("thrall"),
			thrall.hud_image_on(thrall_mob),
			src,
		)

/datum/antagonist/vampire/proc/vamp_burn(burn_chance)
	if(prob(burn_chance) && owner.current.health >= 50)
		switch(owner.current.health)
			if(75 to 100)
				to_chat(owner.current, span_warning("Ваша кожа отслаивается..."))
			if(50 to 75)
				to_chat(owner.current, span_warning("Ваша кожа шипит!"))
		owner.current.adjust_fire_loss(3)
	else if(owner.current.health < 50)
		if(!owner.current.on_fire)
			to_chat(owner.current, span_danger("Ваша кожа загорается!"))
			INVOKE_ASYNC(owner.current, TYPE_PROC_REF(/mob, emote), "scream")
		else
			to_chat(owner.current, span_danger("Вы продолжаете гореть!"))
		owner.current.adjust_fire_stacks(5)
		owner.current.ignite_mob()

/datum/antagonist/vampire/vv_edit_var(var_name, var_value)
	. = ..()
	check_vampire_upgrade(TRUE)

/datum/antagonist/vampire/forge_objectives()
	// TODO: make it more similar to traitor or heretic?
	objectives = list()

	var/datum/objective/vampire/blood/blood_objective = new
	blood_objective.owner = owner
	blood_objective.update_explanation_text()
	objectives += blood_objective

	var/datum/objective/assassinate/assassinate_objective = new
	assassinate_objective.owner = owner
	assassinate_objective.find_target(list(src))
	objectives += assassinate_objective

	if(prob(5))
		var/datum/objective/protect/protect_objective = new
		protect_objective.owner = owner
		protect_objective.find_target(list(src))
		objectives += protect_objective
	else if(prob(50))
		var/datum/objective/vampire/specialization/specialization_objective = new
		specialization_objective.owner = owner
		specialization_objective.update_explanation_text()
		objectives += specialization_objective
	else
		var/datum/objective/steal/steal_objective = new
		steal_objective.owner = owner
		steal_objective.find_target(list(src))
		objectives += steal_objective

	var/datum/objective/vampire/lair/lair_objective = new
	lair_objective.owner = owner
	objectives += lair_objective

	var/datum/objective/ending_objective
	if(prob(20))
		ending_objective = new /datum/objective/survive
	else
		ending_objective = new /datum/objective/escape
	ending_objective.owner = owner
	objectives += ending_objective

/datum/antagonist/vampire/proc/update_specialization_objective()
	for(var/datum/objective/vampire/specialization/specialization_objective as anything in objectives)
		specialization_objective.update_explanation_text()
	owner?.announce_objectives()

/datum/antagonist/vampire/greet()
	. = ..()
	SEND_SOUND(owner.current, sound('sound/music/antag/ling_alert.ogg')) // TODO: replace sound
	to_chat(owner.current, span_danger("Вы — вампир!"))
	to_chat(owner.current, span_notice("Чтобы укусить кого-то, выберите голову, включите намерение навредить и используйте пустую руку. Пейте кровь, чтобы получить новые силы. \
		Вы слабы перед святыми предметами, светом звёзд и огнём. Не выходите в космос и избегайте капеллана, часовни и особенно святой воды."))
	owner.announce_objectives()
