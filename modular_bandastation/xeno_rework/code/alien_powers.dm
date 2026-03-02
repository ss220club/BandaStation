/datum/action/cooldown/alien/select_resin_structure
	name = "Select Resin Structure"
	desc = "Choose the type of resin structure to build."
	button_icon = 'icons/mob/actions/actions_xeno.dmi'
	button_icon_state = "alien_resin"
	plasma_cost = 0
	cooldown_time = 0 SECONDS
	var/static/list/structures = list(
		"resin wall" = /obj/structure/alien/resin/wall,
		"resin membrane" = /obj/structure/alien/resin/membrane,
		"resin nest" = /obj/structure/bed/nest,
		"resin door" = /obj/structure/alien/resin/door,
	)

/datum/action/cooldown/alien/select_resin_structure/Activate(atom/target)
	var/choice = tgui_input_list(owner, "Select a shape to build", "Resin building", structures)
	if(isnull(choice) || QDELETED(src) || QDELETED(owner))
		return FALSE

	var/obj/structure/choice_path = structures[choice]
	if(!ispath(choice_path))
		return FALSE

	var/mob/living/carbon/alien/alien_owner = owner
	alien_owner.selected_resin_structure = choice_path
	to_chat(owner, span_noticealien("You prepare to build a [choice]."))
	return TRUE

/datum/action/cooldown/alien/build_resin_structure
	name = "Build Resin Structure"
	desc = "Build the selected resin structure on a nearby tile."
	button_icon = 'icons/mob/actions/actions_xeno.dmi'
	button_icon_state = "alien_resin"
	plasma_cost = 55
	click_to_activate = TRUE
	unset_after_click = FALSE
	var/obj/structure/made_structure_type
	var/build_time = 3 SECONDS

/datum/action/cooldown/alien/build_resin_structure/proc/check_for_duplicate(turf/location)
	var/obj/structure/existing_thing = locate(made_structure_type) in location
	if(existing_thing)
		to_chat(owner, span_warning("There is already \a [existing_thing] here!"))
		return FALSE
	// Проверка на множественные типы смолы
	var/static/list/structures = list(
		"resin wall" = /obj/structure/alien/resin/wall,
		"resin membrane" = /obj/structure/alien/resin/membrane,
		"resin nest" = /obj/structure/bed/nest,
		"resin door" = /obj/structure/alien/resin/door,
	)
	for(var/blocker_name in structures)
		var/obj/structure/blocker_type = structures[blocker_name]
		if(locate(blocker_type) in location)
			to_chat(owner, span_warning("There is already a resin structure there!"))
			return FALSE
	return TRUE

/datum/action/cooldown/alien/build_resin_structure/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/alien/alien_owner = owner
	if(!alien_owner.selected_resin_structure)
		if(feedback)
			to_chat(owner, span_warning("You must select a structure to build first!"))
		return FALSE
	if(!isturf(owner.loc) || isspaceturf(owner.loc))
		if(feedback)
			to_chat(owner, span_warning("You can't build here!"))
		return FALSE
	return TRUE

/datum/action/cooldown/alien/build_resin_structure/PreActivate(atom/target)
	var/turf/location = get_turf(target)
	if(!location)
		return FALSE

	if(get_dist(owner, location) > 1)
		to_chat(owner, span_warning("You can only build on adjacent tiles!"))
		return FALSE

	if(!locate(/obj/structure/alien/weeds) in location)
		to_chat(owner, span_warning("You can only build on xenomorph weeds!"))
		return FALSE

	var/mob/living/carbon/alien/alien_owner = owner
	made_structure_type = alien_owner.selected_resin_structure
	if(!ispath(made_structure_type))
		to_chat(owner, span_warning("No structure selected!"))
		return FALSE

	if(!check_for_duplicate(location))
		return FALSE

	return ..()

/datum/action/cooldown/alien/build_resin_structure/Activate(atom/target)
	var/turf/location = get_turf(target)
	if(!location)
		return FALSE

	var/mob/living/carbon/alien/alien_owner = owner
	var/obj/structure/choice_path = alien_owner.selected_resin_structure
	if(!ispath(choice_path))
		to_chat(owner, span_warning("No structure selected!"))
		return FALSE

	if(alien_owner.getPlasma() < plasma_cost)
		to_chat(owner, span_warning("You don't have enough plasma to start building!"))
		return FALSE

	alien_owner.adjustPlasma(-plasma_cost)

	// Определяем название структуры для сообщений
	var/structure_name
	var/list/structure_map = list(
		"resin wall" = /obj/structure/alien/resin/wall,
		"resin membrane" = /obj/structure/alien/resin/membrane,
		"resin nest" = /obj/structure/bed/nest,
		"resin door" = /obj/structure/alien/resin/door
	)
	for (var/name in structure_map)
		if (choice_path == structure_map[name])
			structure_name = name
			break

	owner.visible_message(
		span_notice("[owner] begins to secrete a thick purple substance towards [location]."),
		span_notice("You start shaping a [structure_name] on [location == owner.loc ? "your tile" : "the adjacent tile"]."),
	)

	if(!do_after(owner, build_time, target = location, extra_checks = CALLBACK(src, /datum/action/cooldown/alien/build_resin_structure/proc/check_for_duplicate, location)))
		to_chat(owner, span_warning("Your construction was interrupted!"))
		return FALSE

	if(location == owner.loc)
		owner.visible_message(
			span_notice("[owner] finishes shaping a [structure_name]."),
			span_notice("You finish shaping a [structure_name]."),
		)
	else
		owner.visible_message(
			span_notice("[owner] finishes shaping a [structure_name] on [location]."),
			span_notice("You finish shaping a [structure_name] on the adjacent tile."),
		)

	new choice_path(location)
	return TRUE

// MARK: SENTINEL

/datum/action/cooldown/alien/acid/banda
	name = "Spit Neurotoxin"
	desc = "Выплёвывает нейротоксин в цель, изнуряя её."
	button_icon = 'modular_bandastation/xeno_rework/icons/xeno_actions.dmi'
	button_icon_state = "neurospit_0"
	plasma_cost = 25
	/// A singular projectile? Use this one and leave acid_casing null
	var/acid_projectile = /obj/projectile/neurotoxin/banda
	/// You want it to be more like a shotgun style attack? Use this one and make acid_projectile null
	var/acid_casing
	/// Used in to_chat messages to the owner
	var/projectile_name = "neurotoxin"
	/// The base icon for the ability, so a red box can be put on it using _0 or _1
	var/button_base_icon = "neurospit"
	/// The sound that should be played when the xeno actually spits
	var/spit_sound = 'modular_bandastation/xeno_rework/sound/alien_spitacid.ogg'
	shared_cooldown = MOB_SHARED_COOLDOWN_3
	cooldown_time = 3 SECONDS

/datum/action/cooldown/alien/acid/banda/IsAvailable(feedback = FALSE)
	return ..() && isturf(owner.loc)

/datum/action/cooldown/alien/acid/banda/set_click_ability(mob/on_who)
	. = ..()
	if(!.)
		return

	to_chat(on_who, span_notice("Вы подготавливаете свою железу [projectile_name]. <B>Левый клик, чтобы выстрелить по цели!</B>"))

	button_icon_state = "[button_base_icon]_1"
	build_all_button_icons()
	on_who.update_icons()

/datum/action/cooldown/alien/acid/banda/unset_click_ability(mob/on_who, refund_cooldown = TRUE)
	. = ..()
	if(!.)
		return

	if(refund_cooldown)
		to_chat(on_who, span_notice("Вы опустошаете свою железу [projectile_name]."))

	button_icon_state = "[button_base_icon]_0"
	build_all_button_icons()
	on_who.update_icons()

/datum/action/cooldown/alien/acid/banda/InterceptClickOn(mob/living/clicker, params, atom/target)
	if(!IsAvailable())
		return FALSE

	. = ..()
	if(!.)
		unset_click_ability(clicker, refund_cooldown = FALSE)
		return FALSE

	var/turf/user_turf = clicker.loc
	var/turf/target_turf = get_step(clicker, target.dir)
	if(!isturf(target_turf))
		return FALSE

	var/modifiers = params2list(params)
	clicker.visible_message(
		span_danger("[clicker] выплёвывает [projectile_name]!"),
		span_alertalien("Вы выплёвываете [projectile_name]."),
	)

	if(acid_projectile)
		var/obj/projectile/spit_projectile = new acid_projectile(clicker.loc)
		spit_projectile.aim_projectile(target, clicker, modifiers)
		spit_projectile.firer = clicker
		spit_projectile.fire()
		playsound(clicker, spit_sound, 70, TRUE, 5, 0.9)
		clicker.newtonian_move(get_dir(target_turf, user_turf))
		//unset_click_ability(clicker, refund_cooldown = FALSE)
		StartCooldown()
		return TRUE

	if(acid_casing)
		var/obj/item/ammo_casing/casing = new acid_casing(clicker.loc)
		playsound(clicker, spit_sound, 70, TRUE, 5, 0.9)
		casing.fire_casing(target, clicker, null, null, null, ran_zone(), 0, clicker)
		clicker.newtonian_move(get_dir(target_turf, user_turf))
		//unset_click_ability(clicker, refund_cooldown = FALSE)
		StartCooldown()
		return TRUE

	CRASH("Для плевательной атаки [clicker] не заданы ни acid_projectile, ни acid_casing!")

/datum/action/cooldown/alien/acid/banda/Activate(atom/target)
	return TRUE

/obj/projectile/neurotoxin/banda
	name = "neurotoxin spit"
	icon_state = "neurotoxin"
	damage = 30
	paralyze = 0
	damage_type = STAMINA
	armor_flag = BIO

/obj/projectile/neurotoxin/banda/on_hit(atom/target, blocked = 0, pierce_hit)
	if(isalien(target))
		damage = 0
	return ..()

/datum/action/cooldown/alien/acid/banda/lethal
	name = "Spit Acid"
	desc = "Выплёвывает нейротоксин в цель, обжигая её."
	acid_projectile = /obj/projectile/neurotoxin/banda/acid
	button_icon_state = "acidspit_0"
	projectile_name = "acid"
	button_base_icon = "acidspit"

/obj/projectile/neurotoxin/banda/acid
	name = "acid spit"
	icon_state = "toxin"
	damage = 20
	paralyze = 0
	damage_type = BURN

// MARK:RAVAGER

/datum/action/cooldown/mob_cooldown/charge/triple_charge/ravager
	name = "Triple Charge Attack"
	desc = "Позволяет трижды совершить рывок к указанной точке, растаптывая всех на своём пути. Каждый рывок наносит дополнительный удар рукой, если вы в агресивном режиме"
	cooldown_time = 60 SECONDS
	charge_delay = 0.2 SECONDS
	charge_distance = 7
	charge_past = 3
	destroy_objects = FALSE
	charge_damage = 8
	button_icon = 'modular_bandastation/xeno_rework/icons/xeno_actions.dmi'
	button_icon_state = "ravager_charge"
	unset_after_click = TRUE

/datum/action/cooldown/mob_cooldown/charge/triple_charge/ravager/do_charge_indicator(atom/charger, atom/charge_target)
	playsound(charger, 'modular_bandastation/xeno_rework/sound/alien_roar2.ogg', 70, TRUE, 8, 0.9)

/datum/action/cooldown/mob_cooldown/charge/triple_charge/ravager/Activate(atom/target_atom)
	. = ..()
	return TRUE

#define RAVAGER_OUTLINE_EFFECT "ravager_endure_outline"

/datum/action/cooldown/spell/aoe/repulse/xeno/banda_tailsweep/slicing
	name = "Slicing Tail Sweep"
	desc = "Отбросьте нападающих взмахом хвоста, разрезая их его заострённым кончиком."
	aoe_radius = 2
	button_icon_state = "slice_tail"
	sparkle_path = /obj/effect/temp_visual/dir_setting/tailsweep/ravager

	sound = 'modular_bandastation/xeno_rework/sound/alien_tail_swipe.ogg' //The defender's tail sound isn't changed because its big and heavy, this isn't
	impact_sound = 'modular_bandastation/xeno_rework/sound/bloodyslice.ogg'

	impact_damage = 40
	impact_sharpness = SHARP_EDGED

/obj/effect/temp_visual/dir_setting/tailsweep/ravager
	icon = 'modular_bandastation/xeno_rework/icons/xeno_actions.dmi'
	icon_state = "slice_tail_anim"

/datum/action/cooldown/alien/banda/literally_too_angry_to_die
	name = "Endure"
	desc =  "Наполните своё тело невообразимой яростью (и плазмой), позволяя себе игнорировать всю боль на короткое время."
	button_icon_state = "literally_too_angry"
	plasma_cost = 250 //This requires full plasma to do, so there can be some time between armstrong moments
	/// If the endure ability is currently active or not
	var/endure_active = FALSE
	/// How long the endure ability should last when activated
	var/endure_duration = 20 SECONDS

/datum/action/cooldown/alien/banda/literally_too_angry_to_die/Activate()
	. = ..()
	if(endure_active)
		owner.balloon_alert(owner, "already enduring")
		return FALSE
	owner.balloon_alert(owner, "endure began")
	playsound(owner, 'modular_bandastation/xeno_rework/sound/alien_roar1.ogg', 70, TRUE, 8, 0.9)
	to_chat(owner, span_danger("Мы подавляем способность чувствовать боль, позволяя себе сражаться до самого конца в течение следующих [endure_duration/10] секунд."))
	addtimer(CALLBACK(src, PROC_REF(endure_deactivate)), endure_duration)
	owner.add_filter(RAVAGER_OUTLINE_EFFECT, 4, outline_filter(1, COLOR_RED_LIGHT))
	ADD_TRAIT(owner, TRAIT_STUNIMMUNE, TRAIT_XENO_ABILITY_GIVEN)
	ADD_TRAIT(owner, TRAIT_NOSOFTCRIT, TRAIT_XENO_ABILITY_GIVEN)
	ADD_TRAIT(owner, TRAIT_NOHARDCRIT, TRAIT_XENO_ABILITY_GIVEN)
	endure_active = TRUE
	return TRUE

/datum/action/cooldown/alien/banda/literally_too_angry_to_die/proc/endure_deactivate()
	endure_active = FALSE
	owner.balloon_alert(owner, "endure ended")
	owner.remove_filter(RAVAGER_OUTLINE_EFFECT)
	REMOVE_TRAIT(owner, TRAIT_STUNIMMUNE, TRAIT_XENO_ABILITY_GIVEN)
	REMOVE_TRAIT(owner, TRAIT_NOSOFTCRIT, TRAIT_XENO_ABILITY_GIVEN)
	REMOVE_TRAIT(owner, TRAIT_NOHARDCRIT, TRAIT_XENO_ABILITY_GIVEN)

#undef RAVAGER_OUTLINE_EFFECT

// MARK: QUEEN

/datum/action/cooldown/alien/banda/queen_screech
	name = "Deafening Screech"
	desc = "Издаёт оглушительный визг, который, вероятно, ненадолго выведет из строя всех слышащих существ вокруг. Перезарядка 3 минуты."
	button_icon_state = "screech"
	cooldown_time = 3 MINUTES

/datum/action/cooldown/alien/banda/queen_screech/Activate()
	. = ..()
	var/mob/living/carbon/alien/adult/banda/queenie = owner
	playsound(queenie, 'modular_bandastation/xeno_rework/sound/alien_queen_screech.ogg', 70, FALSE, 8, 0.9)
	queenie.create_shriekwave()
	shake_camera(owner, 2, 2)

	for(var/mob/living/carbon/human/screech_target in get_hearers_in_view(7, get_turf(queenie)))
		screech_target.soundbang_act(intensity = 5, stun_pwr = 50, damage_pwr = 10, deafen_pwr = 30) //Only being deaf will save you from the screech
		shake_camera(screech_target, 4, 3)
		to_chat(screech_target, span_red("[queenie] lets out a deafening screech!"))

	return TRUE

/datum/action/cooldown/spell/aoe/repulse/xeno/banda_tailsweep/hard_throwing
	name = "Flinging Tail Sweep"
	desc = "Размашистый удар хвоста отбрасывает врагов назад с огромной силой."

	aoe_radius = 2
	repulse_force = MOVE_FORCE_OVERPOWERING //Fuck everyone who gets hit by this tail in particular

	button_icon_state = "throw_tail"

	sparkle_path = /obj/effect/temp_visual/dir_setting/tailsweep/praetorian

	impact_sound = 'sound/items/weapons/slap.ogg'
	impact_damage = 20
	impact_wound_bonus = 10

/obj/effect/temp_visual/dir_setting/tailsweep/praetorian
	icon = 'modular_bandastation/xeno_rework/icons/xeno_actions.dmi'
	icon_state = "throw_tail_anim"

// MARK: DEFENDER

/datum/action/cooldown/spell/aoe/repulse/xeno/banda_tailsweep
	name = "Crushing Tail Sweep"
	desc = "Отбросьте нападающих взмахом хвоста, вероятно, ломая им кости."

	cooldown_time = 60 SECONDS

	aoe_radius = 1

	button_icon = 'modular_bandastation/xeno_rework/icons/xeno_actions.dmi'
	button_icon_state = "crush_tail"

	sparkle_path = /obj/effect/temp_visual/dir_setting/tailsweep/defender

	/// The sound that the tail sweep will make upon hitting something
	var/impact_sound = 'sound/effects/clang.ogg'
	/// How long mobs hit by the tailsweep should be knocked down for
	var/knockdown_time = 4 SECONDS
	/// How much damage tail sweep impacts should do to a mob
	var/impact_damage = 30
	/// What wound bonus should the tai sweep impact have
	var/impact_wound_bonus = 20
	/// What type of sharpness should this tail sweep have
	var/impact_sharpness = FALSE
	/// What type of damage should the tail sweep do
	var/impact_damage_type = BRUTE

/datum/action/cooldown/spell/aoe/repulse/xeno/banda_tailsweep/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/carbon/alien/adult/banda/owner_alien = owner
	if(!istype(owner_alien) || owner_alien.unable_to_use_abilities)
		return FALSE

/datum/action/cooldown/spell/aoe/repulse/xeno/banda_tailsweep/cast_on_thing_in_aoe(atom/movable/victim, atom/caster)
	if(!isliving(victim) && !istype(victim, /obj/vehicle/sealed))
		return

	if(isalien(victim))
		return

	var/turf/throwtarget = get_edge_target_turf(
		caster,
		get_dir(caster, get_step_away(victim, caster))
	)

	if(!throwtarget)
		return

	var/dist_from_caster = get_dist(victim, caster)

	if(isliving(victim))
		var/mob/living/victim_living = victim

		if(dist_from_caster <= 0)
			victim_living.Knockdown(knockdown_time)
		else
			victim_living.Knockdown(knockdown_time * 2)

		if(sparkle_path)
			new sparkle_path(get_turf(victim_living), get_dir(caster, victim_living))

		victim_living.apply_damage(
			impact_damage,
			impact_damage_type,
			BODY_ZONE_CHEST,
			wound_bonus = impact_wound_bonus,
			sharpness = impact_sharpness
		)

		shake_camera(victim_living, 4, 3)
		playsound(victim_living, impact_sound, 70, TRUE, 8, 0.9)

		to_chat(
			victim_living,
			span_userdanger("Хвост [caster] обрушивается на вас, отбрасывая назад!")
		)

	else if(istype(victim, /obj/vehicle/sealed))
		var/obj/vehicle/sealed/vehicle = victim

		if(sparkle_path)
			new sparkle_path(get_turf(vehicle), get_dir(caster, vehicle))

		playsound(vehicle, impact_sound, 70, TRUE, 8, 0.9)

	victim.throw_at(
		throwtarget,
		clamp(
			max_throw - clamp(dist_from_caster - 2, 0, dist_from_caster),
			3,
			max_throw
		),
		1,
		caster,
		FALSE,
		FALSE,
		null,
		repulse_force,
		FALSE,
		TRUE
	)

/obj/effect/temp_visual/dir_setting/tailsweep/defender
	icon = 'modular_bandastation/xeno_rework/icons/xeno_actions.dmi'
	icon_state = "crush_tail_anim"

/datum/action/cooldown/mob_cooldown/charge/basic_charge/defender
	name = "Charge Attack"
	desc = "Позволяет совершить рывок к указанной позиции, растаптывая всё на своём пути."
	cooldown_time = 15 SECONDS
	charge_delay = 0.3 SECONDS
	charge_distance = 5
	destroy_objects = FALSE
	charge_damage = 50
	button_icon = 'modular_bandastation/xeno_rework/icons/xeno_actions.dmi'
	button_icon_state = "defender_charge"
	unset_after_click = TRUE

/datum/action/cooldown/mob_cooldown/charge/basic_charge/defender/do_charge_indicator(atom/charger, atom/charge_target)
	. = ..()
	playsound(charger, 'modular_bandastation/xeno_rework/sound/alien_roar1.ogg', 100, TRUE, 8, 0.9)

/datum/action/cooldown/mob_cooldown/charge/basic_charge/defender/Activate(atom/target_atom)
	. = ..()
	return TRUE

// MARK: WARRIOR

/datum/action/cooldown/alien/banda/warrior_agility
	name = "Agility Mode"
	desc = "Опуститесь на четвереньки, увеличивая скорость за счёт снижения урона и невозможности использовать большинство способностей."
	button_icon_state = "the_speed_is_alot"
	cooldown_time = 1 SECONDS
	can_be_used_always = TRUE
	/// Is the warrior currently running around on all fours?
	var/being_agile = FALSE

/datum/action/cooldown/alien/banda/warrior_agility/Activate()
	. = ..()
	if(!being_agile)
		begin_agility()
		return TRUE
	if(being_agile)
		end_agility()
		return TRUE

/// Handles the visual indication and code activation of the warrior agility ability (say that five times fast)
/datum/action/cooldown/alien/banda/warrior_agility/proc/begin_agility()
	var/mob/living/carbon/alien/adult/banda/agility_target = owner
	agility_target.balloon_alert(agility_target, "agility active")
	to_chat(agility_target, span_danger("Мы опускаемся на четвереньки, позволяя себе двигаться намного быстрее, но теряя возможность использовать большинство способностей."))
	playsound(agility_target, 'modular_bandastation/xeno_rework/sound/alien_hiss.ogg', 79, TRUE, 8, 0.9)
	agility_target.icon_state = "alien[agility_target.caste]_mobility"

	being_agile = TRUE
	agility_target.add_movespeed_modifier(/datum/movespeed_modifier/warrior_agility)
	agility_target.unable_to_use_abilities = TRUE

	agility_target.melee_damage_lower = 15
	agility_target.melee_damage_upper = 20

/// Handles the visual indicators and code side of deactivating the agility ability
/datum/action/cooldown/alien/banda/warrior_agility/proc/end_agility()
	var/mob/living/carbon/alien/adult/banda/agility_target = owner
	agility_target.balloon_alert(agility_target, "agility ended")
	playsound(agility_target, 'modular_bandastation/xeno_rework/sound/alien_roar2.ogg', 70, TRUE, 8, 0.9) //Warrior runs up on all fours, stands upright, screams at you
	agility_target.icon_state = "alien[agility_target.caste]"

	being_agile = FALSE
	agility_target.remove_movespeed_modifier(/datum/movespeed_modifier/warrior_agility)
	agility_target.unable_to_use_abilities = FALSE

	agility_target.melee_damage_lower = initial(agility_target.melee_damage_lower)
	agility_target.melee_damage_upper = initial(agility_target.melee_damage_upper)

/datum/movespeed_modifier/warrior_agility
	multiplicative_slowdown = -2

// MARK:DRONE

/datum/action/cooldown/alien/banda/heal_aura
	name = "Healing Aura"
	desc = "Дружественные ксеноморфы в небольшом радиусе вокруг вас будут получать пассивное исцеление."
	button_icon_state = "healaura"
	plasma_cost = 100
	cooldown_time = 90 SECONDS
	/// Is the healing aura currently active or not
	var/aura_active = FALSE
	/// How long the healing aura should last
	var/aura_duration = 30 SECONDS
	/// How far away the healing aura should reach
	var/aura_range = 5
	/// How much brute/burn individually the healing aura should heal each time it fires
	var/aura_healing_amount = 5
	/// What color should the + particles caused by the healing aura be
	var/aura_healing_color = COLOR_BLUE_LIGHT
	/// The healing aura component itself that the ability uses
	var/datum/component/aura_healing/aura_healing_component

/datum/action/cooldown/alien/banda/heal_aura/Activate()
	. = ..()
	if(aura_active)
		owner.balloon_alert(owner, "already healing")
		return FALSE
	owner.balloon_alert(owner, "healing aura started")
	to_chat(owner, span_danger("Мы испускаем феромоны, которые побуждают сестёр рядом с нами исцеляться в течение следующих [aura_duration / 10] секунд."))
	addtimer(CALLBACK(src, PROC_REF(aura_deactivate)), aura_duration)
	aura_active = TRUE
	aura_healing_component = owner.AddComponent(/datum/component/aura_healing, range = aura_range, requires_visibility = TRUE, brute_heal = aura_healing_amount, burn_heal = aura_healing_amount, limit_to_trait = TRAIT_XENO_HEAL_AURA, healing_color = aura_healing_color)
	return TRUE

/datum/action/cooldown/alien/banda/heal_aura/proc/aura_deactivate()
	if(!aura_active)
		return
	aura_active = FALSE
	QDEL_NULL(aura_healing_component)
	owner.balloon_alert(owner, "healing aura ended")

/datum/action/cooldown/alien/banda/heal_aura/juiced
	name = "Strong Healing Aura"
	desc = "Дружественные ксеноморфы в большем радиусе вокруг вас будут получать пассивное исцеление."
	button_icon_state = "healaura_juiced"
	plasma_cost = 100
	cooldown_time = 90 SECONDS
	aura_range = 7
	aura_healing_amount = 10
	aura_healing_color = COLOR_RED_LIGHT

// MARK:PRAETORIAN

/datum/action/cooldown/alien/acid/banda/spread
	name = "Spit Neurotoxin Spread"
	desc = "Выплёвывает нейротоксин, истощая противника."
	plasma_cost = 50
	acid_projectile = null
	acid_casing = /obj/item/ammo_casing/xenospit
	spit_sound = 'modular_bandastation/xeno_rework/sound/alien_spitacid2.ogg'
	cooldown_time = 10 SECONDS

/obj/item/ammo_casing/xenospit //This is probably really bad, however I couldn't find any other nice way to do this
	name = "big glob of neurotoxin"
	projectile_type = /obj/projectile/neurotoxin/banda/spitter_spread
	pellets = 3
	variance = 20

/obj/item/ammo_casing/xenospit/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/caseless)

/obj/item/ammo_casing/xenospit/tk_firing(mob/living/user, atom/fired_from)
	return FALSE

/obj/projectile/neurotoxin/banda/spitter_spread //Slightly nerfed because its a shotgun spread of these
	name = "neurotoxin spit"
	icon_state = "neurotoxin"
	damage = 25

/datum/action/cooldown/alien/acid/banda/spread/lethal
	name = "Spit Acid Spread"
	desc = "Выплёвывает облако кислоты в цель, обжигая её."
	acid_projectile = null
	acid_casing = /obj/item/ammo_casing/xenospit/spread/lethal
	button_icon_state = "acidspit_0"
	projectile_name = "acid"
	button_base_icon = "acidspit"

/obj/item/ammo_casing/xenospit/spread/lethal
	name = "big glob of acid"
	projectile_type = /obj/projectile/neurotoxin/banda/acid/spitter_spread
	pellets = 4
	variance = 30

/obj/projectile/neurotoxin/banda/acid/spitter_spread
	name = "acid spit"
	icon_state = "toxin"
	damage = 15
	damage_type = BURN

// MARK:RUNNER

#define EVASION_VENTCRAWL_INABILTY_CD_PERCENTAGE 0.8
#define RUNNER_BLUR_EFFECT "runner_evasion"

/datum/action/cooldown/alien/banda/evade
	name = "Evade"
	desc = "Позволяет уклоняться от любых снарядов, которые могли бы попасть в вас, в течение нескольких секунд."
	button_icon_state = "evade"
	plasma_cost = 50
	cooldown_time = 60 SECONDS
	/// If the evade ability is currently active or not
	var/evade_active = FALSE
	/// How long evasion should last
	var/evasion_duration = 10 SECONDS

/datum/action/cooldown/alien/banda/evade/Activate()
	. = ..()
	if(evade_active) //Can't evade while we're already evading.
		owner.balloon_alert(owner, "already evading")
		return FALSE

	owner.balloon_alert(owner, "evasive movements began")
	playsound(owner, 'modular_bandastation/xeno_rework/sound/alien_hiss.ogg', 70, TRUE, 8, 0.9)
	to_chat(owner, span_danger("Мы совершаем уклоняющий манёвр, становясь неуязвимыми для снарядов в течение следующих [evasion_duration / 10] секунд."))
	addtimer(CALLBACK(src, PROC_REF(evasion_deactivate)), evasion_duration)
	evade_active = TRUE
	RegisterSignal(owner, COMSIG_PROJECTILE_ON_HIT, PROC_REF(on_projectile_hit))
	REMOVE_TRAIT(owner, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
	addtimer(CALLBACK(src, PROC_REF(give_back_ventcrawl)), (cooldown_time * EVASION_VENTCRAWL_INABILTY_CD_PERCENTAGE)) //They cannot ventcrawl until the defined percent of the cooldown has passed
	to_chat(owner, span_warning("Мы не сможем ползать по вентиляции в течение следующих [(cooldown_time * EVASION_VENTCRAWL_INABILTY_CD_PERCENTAGE) / 10] секунд."))
	return TRUE

/// Handles deactivation of the xeno evasion ability, mainly unregistering the signal and giving a balloon alert
/datum/action/cooldown/alien/banda/evade/proc/evasion_deactivate()
	evade_active = FALSE
	owner.balloon_alert(owner, "evasion ended")
	UnregisterSignal(owner, COMSIG_PROJECTILE_ON_HIT)

/datum/action/cooldown/alien/banda/evade/proc/give_back_ventcrawl()
	ADD_TRAIT(owner, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
	to_chat(owner, span_notice("Мы достаточно отдохнули и снова можем ползать по вентиляции."))

/// Handles if either BULLET_ACT_HIT or BULLET_ACT_FORCE_PIERCE happens to something using the xeno evade ability
/datum/action/cooldown/alien/banda/evade/proc/on_projectile_hit()
	if(!INCAPACITATED_IGNORING(owner, INCAPABLE_GRAB) || !isturf(owner.loc) || !evade_active)
		return BULLET_ACT_HIT

	owner.visible_message(span_danger("[owner] без труда уклоняется от снаряда!"), span_userdanger("Вы уклоняетесь от снаряда!"))
	playsound(get_turf(owner), pick('sound/items/weapons/bulletflyby.ogg', 'sound/items/weapons/bulletflyby2.ogg', 'sound/items/weapons/bulletflyby3.ogg'), 75, TRUE)
	owner.add_filter(RUNNER_BLUR_EFFECT, 2, gauss_blur_filter(5))
	addtimer(CALLBACK(owner, TYPE_PROC_REF(/datum, remove_filter), RUNNER_BLUR_EFFECT), 0.5 SECONDS)
	return BULLET_ACT_FORCE_PIERCE

#undef EVASION_VENTCRAWL_INABILTY_CD_PERCENTAGE
#undef RUNNER_BLUR_EFFECT

// MARK:BASE XENO

/datum/action/cooldown/alien/banda/sleepytime //I don't think this has a mechanical advantage but they have cool resting sprites so...
	name = "Rest"
	desc = "Иногда даже кровожадным чужим нужно немного полежать."
	button_icon_state = "sleepytime"

/datum/action/cooldown/alien/banda/sleepytime/Activate()
	var/mob/living/carbon/sleepytime_mob = owner
	if(!isalien(owner))
		return FALSE
	if(!sleepytime_mob.resting)
		sleepytime_mob.set_resting(new_resting = TRUE, silent = FALSE, instant = TRUE)
		return TRUE
	sleepytime_mob.set_resting(new_resting = FALSE, silent = FALSE, instant = FALSE)
	return TRUE

/datum/action/cooldown/alien/banda/generic_evolve
	name = "Evolve"
	desc = "Позволяет нам эволюционировать в высшую касту нашего типа, если такая ещё не существует."
	button_icon_state = "evolution"
	/// What type this ability will turn the owner into upon completion
	var/type_to_evolve_into

/datum/action/cooldown/alien/banda/generic_evolve/Grant(mob/grant_to)
	. = ..()
	if(!isalien(owner))
		return
	var/mob/living/carbon/alien/target_alien = owner
	plasma_cost = target_alien.get_max_plasma() //This ability should always require that a xeno be at their max plasma capacity to use

/datum/action/cooldown/alien/banda/generic_evolve/Activate()
	var/mob/living/carbon/alien/adult/banda/evolver = owner

	if(!istype(evolver))
		to_chat(owner, span_warning("You aren't an alien, you can't evolve!"))
		return FALSE

	type_to_evolve_into = evolver.next_evolution
	if(!type_to_evolve_into)
		to_chat(evolver, span_bolddanger("Something is wrong... We can't evolve into anything?"))
		CRASH("Couldn't find an evolution for [owner] ([owner.type]).")

	if(!isturf(evolver.loc))
		return FALSE

	if(get_alien_type(type_to_evolve_into))
		evolver.balloon_alert(evolver, "Слишком много наших эволюционировавших форм уже существует.")
		return FALSE

	var/obj/item/organ/alien/hivenode/node = evolver.get_organ_by_type(/obj/item/organ/alien/hivenode)
	if(!node)
		to_chat(evolver, span_bolddanger("Мы не ощущаем связь нашего узла с ульем... Мы не можем эволюционировать!"))
		return FALSE

	if(node.recent_queen_death)
		to_chat(evolver, span_bolddanger("Смерть нашей королевы... Мы не можем собрать достаточно ментальной энергии, чтобы эволюционировать..."))
		return FALSE

	if(evolver.has_evolved_recently)
		evolver.balloon_alert(evolver, "сможет эволюционировать через 1.5 минуты") //Make that 1.5 variable later, but it keeps fucking up for me :(
		return FALSE

	var/new_beno = new type_to_evolve_into(evolver.loc)
	evolver.alien_evolve(new_beno)
	return TRUE
