
/datum/heretic_knowledge_tree_column/main/rust
	neighbour_type_left = /datum/heretic_knowledge_tree_column/blade_to_rust
	neighbour_type_right = /datum/heretic_knowledge_tree_column/rust_to_cosmic

	route = PATH_RUST
	ui_bgr = "node_rust"

	start = /datum/heretic_knowledge/limited_amount/starting/base_rust
	grasp = /datum/heretic_knowledge/rust_fist
	tier1 = /datum/heretic_knowledge/rust_regen
	mark = /datum/heretic_knowledge/mark/rust_mark
	ritual_of_knowledge = /datum/heretic_knowledge/knowledge_ritual/rust
	unique_ability = /datum/heretic_knowledge/spell/rust_construction
	tier2 = /datum/heretic_knowledge/spell/area_conversion
	blade = /datum/heretic_knowledge/blade_upgrade/rust
	tier3 =	/datum/heretic_knowledge/spell/entropic_plume
	ascension = /datum/heretic_knowledge/ultimate/rust_final

/datum/heretic_knowledge/limited_amount/starting/base_rust
	name = "Blacksmith's Tale"
	desc = "Открывает перед вами Путь ржавчины. \
		Позволяет трансмутировать нож с любым мусором в Ржавый клинок. \
		Одновременно можно создать только два."
	gain_text = "\"Позвольте мне рассказать вам историю\", сказал Кузнец, вглядываясь в глубину своего ржавого клинка."
	required_atoms = list(
		/obj/item/knife = 1,
		/obj/item/trash = 1,
	)
	result_atoms = list(/obj/item/melee/sickly_blade/rust)
	research_tree_icon_path = 'icons/obj/weapons/khopesh.dmi'
	research_tree_icon_state = "rust_blade"

/datum/heretic_knowledge/rust_fist
	name = "Grasp of Rust"
	desc = "Ваша Хватка Мансуса наносит 500 единиц урона неживой материи и ржавеет любая поверхность, которой она коснется. \
		Уже заржавевшие поверхности разрушаются. Поверхности и структуры можно заставить ржаветь с помощью ПКМ. \
		Позволяет заставить ржаветь обычные железные стены и пол."
	gain_text = "На потолке Мансуса ржавчина растет, как мох на камне."
	cost = 1
	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "grasp_rust"

/datum/heretic_knowledge/rust_fist/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, PROC_REF(on_mansus_grasp))
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK_SECONDARY, PROC_REF(on_secondary_mansus_grasp))
	our_heretic.increase_rust_strength()

/datum/heretic_knowledge/rust_fist/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	UnregisterSignal(user, list(COMSIG_HERETIC_MANSUS_GRASP_ATTACK, COMSIG_HERETIC_MANSUS_GRASP_ATTACK_SECONDARY))

/datum/heretic_knowledge/rust_fist/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER

	if(!issilicon(target) && !(target.mob_biotypes & MOB_ROBOTIC))
		return

	source.do_rust_heretic_act(target)

/datum/heretic_knowledge/rust_fist/proc/on_secondary_mansus_grasp(mob/living/source, atom/target)
	SIGNAL_HANDLER

	// Rusting an airlock causes it to lose power, mostly to prevent the airlock from shocking you.
	// This is a bit of a hack, but fixing this would require the entire wire cut/pulse system to be reworked.
	if(istype(target, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/airlock = target
		airlock.loseMainPower()

	source.do_rust_heretic_act(target)
	return COMPONENT_USE_HAND

/datum/heretic_knowledge/rust_regen
	name = "Leeching Walk"
	desc = "Дает вам пассивное исцеление и устойчивость к батонам, когда вы стоите над ржавчиной."
	gain_text = "Скорость была беспрецедентной, сила - неестественной. Кузнец улыбался."
	cost = 1
	research_tree_icon_path = 'icons/effects/eldritch.dmi'
	research_tree_icon_state = "cloud_swirl"


/datum/heretic_knowledge/rust_regen/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	user.AddElement(/datum/element/leeching_walk)

/datum/heretic_knowledge/rust_regen/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	user.RemoveElement(/datum/element/leeching_walk)

/datum/heretic_knowledge/mark/rust_mark
	name = "Mark of Rust"
	desc = "Ваша Хватка Мансуса теперь накладывает Метку ржавчины. Метка срабатывает при атаке вашим Ржавым клинком. \
		При срабатывании, жертва получит сильное отвращение и будет контужена. \
		Позволяет заставить ржаветь укрепленные стены и пол, а также пласталь."
	gain_text = "Кузнец смотрит вдаль. В давно потерянное место. \"Ржавые холмы помогают остро нуждающимся... за определенную плату.\""
	mark_type = /datum/status_effect/eldritch/rust

/datum/heretic_knowledge/mark/rust_mark/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	our_heretic.increase_rust_strength()

/datum/heretic_knowledge/knowledge_ritual/rust

/datum/heretic_knowledge/spell/rust_construction
	name = "Rust Construction"
	desc = "Дает вам Rust Construction - заклинание, позволяющее возвести стену из ржавого пола. \
		Любой человек, находящийся над стеной, будет отброшен в сторону (или вверх) и получит урон."
	gain_text = "В моем сознании начали плясать образы иноземных и зловещих сооружений. Покрытые с ног до головы толстым слоем ржавчины, \
		они больше не выглядели рукотворными. А может быть, они вообще никогда и не существовали."
	action_to_add = /datum/action/cooldown/spell/pointed/rust_construction
	cost = 1

/datum/heretic_knowledge/spell/area_conversion
	name = "Aggressive Spread"
	desc = "Дает вам заклинание Aggressive Spread, которое распространяет ржавчину на близлежащие поверхности. \
		Уже заржавевшие поверхности разрушаются. \ Также улучшает способности ржавчины еретиков не Пути ржавчины."
	gain_text = "Мудрецы знают, что не стоит посещать Ржавые холмы... Но рассказ Кузнеца был вдохновляющим."
	action_to_add = /datum/action/cooldown/spell/aoe/rust_conversion
	cost = 1
	research_tree_icon_frame = 5

/datum/heretic_knowledge/spell/area_conversion/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	our_heretic.increase_rust_strength(TRUE)

/datum/heretic_knowledge/blade_upgrade/rust
	name = "Toxic Blade"
	desc = "Ваш Ржавый клинок теперь отвращает врагов при атаке. \ Позволяет заставить ржаветь титаниум и пластитаниум."
	gain_text = "Кузнец протягивает вам свой клинок. \"Клинок проведет тебя через плоть, если ты позволишь ему.\" \
		Тяжелая ржавчина утяжеляет клинок. Вы пристально вглядываетесь в него. Ржавые холмы зовут тебя."
	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "blade_upgrade_rust"

/datum/heretic_knowledge/blade_upgrade/rust/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	our_heretic.increase_rust_strength()

/datum/heretic_knowledge/blade_upgrade/rust/do_melee_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	if(source == target || !isliving(target))
		return
	target.adjust_disgust(50)

/datum/heretic_knowledge/spell/area_conversion/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
/datum/heretic_knowledge/spell/entropic_plume
	name = "Entropic Plume"
	desc = "Дарует вам Entropic Plume, заклинание, выпускающее досаждающую волну ржавчины. \
		Ослепляет, отравляет и накладывает Amok на всех попавших язычников, заставляя их дико нападать \
		на друзей или врагов. Также ржавеет и разрушает поверхности, на которые попадает. Улучшает способности ржавчины еретиков не Пути ржавчины."
	gain_text = "Коррозия была неостановима. Ржавчина была неприятной. \
		Кузнец ушел, ты держишь его клинок. Чемпионы надежды, Повелитель ржавчины близок!"

	action_to_add = /datum/action/cooldown/spell/cone/staggered/entropic_plume
	cost = 1



/datum/heretic_knowledge/spell/entropic_plume/on_gain(mob/user)
	. = ..()
	var/datum/antagonist/heretic/our_heretic = GET_HERETIC(user)
	our_heretic.increase_rust_strength(TRUE)

/datum/heretic_knowledge/ultimate/rust_final
	name = "Rustbringer's Oath"
	desc = "Ритуал вознесения Пути ржавчины. \
		Принесите 3 трупа к руне трансмутации на мостик станции, чтобы завершить ритуал. \
		После завершения, ритуальное место будет бесконечно распространять ржавчину на любую поверхность, не останавливаясь ни перед чем. \
		Кроме того, вы станете чрезвычайно стойкими на ржавчине, исцеляясь втрое быстрее \
		и приобретая иммунитет ко многим эффектам и опасностям. Вы сможете заставлять ржаветь почти всё."
	gain_text = "Чемпион ржавчины. Разлагатель стали. Бойся темноты, ибо пришел ПОВЕЛИТЕЛЬ РЖАВЧИНЫ! \
		Работа Кузнеца продолжается! Ржавые холмы, УСЛЫШЬТЕ МОЕ ИМЯ! УЗРИТЕ МОЕ ВОЗНЕСЕНИЕ!"

	ascension_achievement = /datum/award/achievement/misc/rust_ascension
	announcement_text = "%SPOOKY% Бойтесь разложения, ибо Предводитель Ржавчины, %NAME%, вознесся! Никто не уйдет от коррозии! %SPOOKY%"
	announcement_sound = 'sound/music/antag/heretic/ascend_rust.ogg'
	/// If TRUE, then immunities are currently active.
	var/immunities_active = FALSE
	/// A typepath to an area that we must finish the ritual in.
	var/area/ritual_location = /area/station/command/bridge
	/// A static list of traits we give to the heretic when on rust.
	var/static/list/conditional_immunities = list(
		TRAIT_BOMBIMMUNE,
		TRAIT_IGNORESLOWDOWN,
		TRAIT_NO_SLIP_ALL,
		TRAIT_NOBREATH,
		TRAIT_PIERCEIMMUNE,
		TRAIT_PUSHIMMUNE,
		TRAIT_RADIMMUNE,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHEAT,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_SHOCKIMMUNE,
		TRAIT_SLEEPIMMUNE,
		TRAIT_STUNIMMUNE,
	)

/datum/heretic_knowledge/ultimate/rust_final/on_research(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	// This map doesn't have a Bridge, for some reason??
	// Let them complete the ritual anywhere
	if(!GLOB.areas_by_type[ritual_location])
		ritual_location = null

/datum/heretic_knowledge/ultimate/rust_final/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	if(ritual_location)
		var/area/our_area = get_area(loc)
		if(!istype(our_area, ritual_location))
			loc.balloon_alert(user, "ритуал провален, должны быть в [initial(ritual_location.name)]!") // "must be in bridge"
			return FALSE

	return ..()

/datum/heretic_knowledge/ultimate/rust_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	trigger(loc)
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	RegisterSignal(user, COMSIG_LIVING_LIFE, PROC_REF(on_life))
	user.client?.give_award(/datum/award/achievement/misc/rust_ascension, user)
	var/datum/action/cooldown/spell/aoe/rust_conversion/rust_spread_spell = locate() in user.actions
	rust_spread_spell?.cooldown_time /= 2

// I sure hope this doesn't have performance implications
/datum/heretic_knowledge/ultimate/rust_final/proc/trigger(turf/center)
	var/greatest_dist = 0
	var/list/turfs_to_transform = list()
	for (var/turf/transform_turf as anything in GLOB.station_turfs)
		if (transform_turf.turf_flags & NO_RUST)
			continue
		var/dist = get_dist(center, transform_turf)
		if (dist > greatest_dist)
			greatest_dist = dist
		if (!turfs_to_transform["[dist]"])
			turfs_to_transform["[dist]"] = list()
		turfs_to_transform["[dist]"] += transform_turf

	for (var/iterator in 1 to greatest_dist)
		if(!turfs_to_transform["[iterator]"])
			continue
		addtimer(CALLBACK(src, PROC_REF(transform_area), turfs_to_transform["[iterator]"]), (5 SECONDS) * iterator)

/datum/heretic_knowledge/ultimate/rust_final/proc/transform_area(list/turfs)
	turfs = shuffle(turfs)
	var/numturfs = length(turfs)
	var/first_third = turfs.Copy(1, round(numturfs * 0.33))
	var/second_third = turfs.Copy(round(numturfs * 0.33), round(numturfs * 0.66))
	var/third_third = turfs.Copy(round(numturfs * 0.66), numturfs)
	addtimer(CALLBACK(src, PROC_REF(delay_transform_turfs), first_third), 5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(delay_transform_turfs), second_third), 5 SECONDS * 0.33)
	addtimer(CALLBACK(src, PROC_REF(delay_transform_turfs), third_third), 5 SECONDS * 0.66)

/datum/heretic_knowledge/ultimate/rust_final/proc/delay_transform_turfs(list/turfs)
	for(var/turf/turf as anything in turfs)
		turf.rust_heretic_act(5)
		CHECK_TICK

/**
 * Signal proc for [COMSIG_MOVABLE_MOVED].
 *
 * Gives our heretic ([source]) buffs if they stand on rust.
 */
/datum/heretic_knowledge/ultimate/rust_final/proc/on_move(mob/living/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER

	// If we're on a rusty turf, and haven't given out our traits, buff our guy
	var/turf/our_turf = get_turf(source)
	if(HAS_TRAIT(our_turf, TRAIT_RUSTY))
		if(!immunities_active)
			source.add_traits(conditional_immunities, type)
			source.add_movespeed_mod_immunities(type, /datum/movespeed_modifier/damage_slowdown)
			immunities_active = TRUE

	// If we're not on a rust turf, and we have given out our traits, nerf our guy
	else
		if(immunities_active)
			source.remove_traits(conditional_immunities, type)
			source.remove_movespeed_mod_immunities(type, /datum/movespeed_modifier/damage_slowdown)
			immunities_active = FALSE

/**
 * Signal proc for [COMSIG_LIVING_LIFE].
 *
 * Gradually heals the heretic ([source]) on rust.
 */
/datum/heretic_knowledge/ultimate/rust_final/proc/on_life(mob/living/source, seconds_per_tick, times_fired)
	SIGNAL_HANDLER

	var/turf/our_turf = get_turf(source)
	if(!HAS_TRAIT(our_turf, TRAIT_RUSTY))
		return

	var/need_mob_update = FALSE
	var/base_heal_amt = 2.5 * DELTA_WORLD_TIME(SSmobs)
	need_mob_update += source.adjustBruteLoss(-base_heal_amt, updating_health = FALSE)
	need_mob_update += source.adjustFireLoss(-base_heal_amt, updating_health = FALSE)
	need_mob_update += source.adjustToxLoss(-base_heal_amt, updating_health = FALSE, forced = TRUE)
	need_mob_update += source.adjustOxyLoss(-base_heal_amt, updating_health = FALSE)
	need_mob_update += source.adjustStaminaLoss(-base_heal_amt * 4, updating_stamina = FALSE)
	if(source.blood_volume < BLOOD_VOLUME_NORMAL)
		source.blood_volume += base_heal_amt
	if(need_mob_update)
		source.updatehealth()
