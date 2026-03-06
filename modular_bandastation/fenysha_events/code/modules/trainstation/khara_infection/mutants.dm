/datum/component/infection_attack
	var/chance_on_infection = 10
	var/only_with_wounds = TRUE
	var/disease

/datum/component/infection_attack/Initialize(disease, chance_on_infection = 10, only_with_wounds = TRUE)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	src.chance_on_infection = chance_on_infection
	if(!ispath(disease, /datum/disease))
		return COMPONENT_INCOMPATIBLE
	src.disease = disease
	src.only_with_wounds = only_with_wounds
	RegisterSignal(parent, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(on_parent_attack), TRUE)

/datum/component/infection_attack/proc/on_parent_attack(mob/living/attacker, atom/attacked, proximity)
	SIGNAL_HANDLER
	if(!ishuman(attacked) || !proximity)
		return
	var/mob/living/carbon/human/human = attacked

	// Если включена проверка ран и ран нет — заражение не происходит
	if(!human.all_wounds && only_with_wounds)
		return

	var/infect_chance = 10
	if(human.all_wounds && islist(human.all_wounds))
		for(var/datum/wound/wound in human.all_wounds)
			if(wound.severity >= WOUND_SEVERITY_MODERATE)
				infect_chance += 10

	infect_chance = clamp(infect_chance, 10, 40)

	if(prob(infect_chance))
		human.ForceContractDisease(new disease, del_on_fail = TRUE)


/proc/is_khara_creature(datum/thing)
	return istype(thing, /mob/living/basic/khara_mutant) || HAS_TRAIT(thing, TRAIT_KHARAMUTANT)

/obj/effect/mob_spawn/ghost_role/flesh_spider
	name = "Плоть-кокон"
	desc = "Огромное пульсирующее растение..."
	icon = 'icons/mob/simple/meteor_heart.dmi'
	icon_state = "flesh_pod"
	mob_type = /mob/living/basic/khara_mutant/flesh_spider
	density = FALSE
	uses = 1
	deletes_on_zero_uses_left = FALSE
	prompt_name = "плотоядная ловушка"
	you_are_text = "Ты — паук из плоти и крови."
	flavour_text = "Ты — паук из плоти и крови! Защищай своё гнездо любой ценой и пожирай всех, кто посмеет приблизиться!"
	important_text = "Ни при каких обстоятельствах не покидай своё гнездо!"
	faction = list(FACTION_KHARA)
	light_range = 2
	light_power = 3

/obj/effect/mob_spawn/ghost_role/flesh_spider/Initialize(mapload)
	. = ..()
	set_light(light_range, light_power, LIGHT_COLOR_FLARE)

/obj/effect/mob_spawn/ghost_role/flesh_spider/pre_ghost_take(mob/dead/observer/user)
	icon_state = "flesh_pod_open"
	for(var/turf/blood_turf in view(src, 2))
		new /obj/effect/decal/cleanable/blood(blood_turf)
		for(var/mob/living/mob_in_turf in blood_turf)
			mob_in_turf.visible_message(span_danger("[mob_in_turf] обрызган кровью!"), span_userdanger("Ты обрызган кровью!"))
			mob_in_turf.add_blood_DNA(list("Не-человеческая ДНК" = random_human_blood_type()))
			playsound(mob_in_turf, 'sound/effects/splat.ogg', 50, TRUE, extrarange = SILENCED_SOUND_EXTRARANGE)
	return ..()


/mob/living/basic/khara_mutant
	name = "Мутант Кхара"
	desc = "Мерзкая, окровавленная мерзость..."
	mob_biotypes = MOB_ORGANIC|MOB_BUG|MOB_SPECIAL
	speak_emote = list("рычит")
	damage_coeff = list(BRUTE = 1.5, BURN = 0.5, TOX = 0, STAMINA = 1, OXY = 0)
	basic_mob_flags = FLAMMABLE_MOB|IMMUNE_TO_FISTS|REMAIN_DENSE_WHILE_DEAD
	status_flags = CANSTUN
	speed = 1
	maxHealth = 250
	health = 250
	armour_penetration = 30
	melee_damage_lower = 20
	melee_damage_upper = 20
	wound_bonus = 20
	obj_damage = 50
	melee_attack_cooldown = CLICK_CD_MELEE
	attack_verb_continuous = "вгрызается"
	attack_verb_simple = "вгрызться"
	attack_sound = 'sound/items/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	unsuitable_cold_damage = 10
	unsuitable_heat_damage = 0
	maximum_survivable_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	minimum_survivable_temperature = T0C - 25
	combat_mode = TRUE
	faction = list(FACTION_KHARA)
	pass_flags = PASSTABLE
	unique_name = TRUE
	lighting_cutoff_red = 22
	lighting_cutoff_green = 5
	lighting_cutoff_blue = 5
	butcher_results = list(/obj/item/food/meat/slab/spider = 2, /obj/item/food/spiderleg = 8)
	max_stamina = 250
	stamina_crit_threshold = 90
	stamina_recovery = 5
	max_stamina_slowdown = 12
	habitable_atmos = null

	var/cast = KHARA_CAST_LESSER
	var/datum/component/khara_hivemind/hivemind_link = null

	var/spread_miasma_amount = 12
	var/spread_miasma_chance = 5
	var/spreads_miasma = FALSE
	var/regeneration_delay = 4 SECONDS
	var/health_regen_per_second = 4
	var/list/innate_actions

	var/spread_minimal_cooldown = 5 SECONDS
	COOLDOWN_DECLARE(spread_cd)

/mob/living/basic/khara_mutant/Initialize(mapload)
	. = ..()
	add_traits(list(TRAIT_NO_TELEPORT, TRAIT_LAVA_IMMUNE, TRAIT_ASHSTORM_IMMUNE, TRAIT_NO_FLOATING_ANIM, TRAIT_THERMAL_VISION, TRAIT_KHARAMUTANT), MEGAFAUNA_TRAIT)
	AddElement(/datum/element/prevent_attacking_of_types, GLOB.typecache_general_bad_hostile_attack_targets, "это бессмысленно!")
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_CLAW)
	AddElement(/datum/element/ai_retaliate)

	AddComponent(/datum/component/seethrough_mob)
	AddComponent(\
		/datum/component/blood_walk,\
		blood_type = /obj/effect/decal/cleanable/blood/bubblegum,\
		blood_spawn_chance = 15,\
	)
	AddComponent(\
		/datum/component/regenerator,\
		regeneration_delay = regeneration_delay,\
		brute_per_second = health_regen_per_second,\
		outline_colour = COLOR_PINK,\
	)
	AddComponent(\
		/datum/component/infection_attack, \
		disease = /datum/disease/khara,\
		chance_on_infection = 10, \
		only_with_wounds = TRUE, \
	)
	hivemind_link = AddComponent(\
		/datum/component/khara_hivemind, \
		cast = src.cast, \
	)
	apply_wibbly_filters(src)

	if(innate_actions && islist(innate_actions))
		grant_actions_by_list(innate_actions)
	update_sight()


/mob/living/basic/khara_mutant/Life(seconds_per_tick, times_fired)
	. = ..()
	if(spreads_miasma && SPT_PROB(spread_miasma_chance, seconds_per_tick) && COOLDOWN_FINISHED(src, spread_cd))
		COOLDOWN_START(src, spread_cd, spread_minimal_cooldown)
		spread_miasma()

/mob/living/basic/khara_mutant/say(message, bubble_type, list/spans, sanitize, datum/language/language, ignore_spam, forced, filterproof, message_range, datum/saymode/saymode, list/message_mods)
	if(hivemind_link && client)
		var/datum/action/cooldown/khara_hivemind_talk/hivemind = hivemind_link.action
		hivemind.talk_to_hivemind(message)
	return

/mob/living/basic/khara_mutant/proc/spread_miasma()
	var/datum/reagents/R = new(spread_miasma_amount)
	R.my_atom = src
	R.add_reagent(/datum/reagent/toxin/khara, spread_miasma_amount)

	var/datum/effect_system/fluid_spread/smoke/chem/S = new(location = get_turf(src), range = spread_miasma_amount, holder = R)
	S.start()

/mob/living/basic/khara_mutant/death(gibbed)
	inflate_gib()
	. = ..()

/mob/living/basic/khara_mutant/gib()
	for(var/turf/blood_turf in view(src, 3))
		new /obj/effect/decal/cleanable/blood(blood_turf)
		for(var/mob/living/mob_in_turf in blood_turf)
			mob_in_turf.visible_message(span_danger("[mob_in_turf] обрызган кровью!"), span_userdanger("Ты обрызган кровью!"))
			mob_in_turf.add_blood_DNA(list("Не-человеческая ДНК" = random_human_blood_type()))
			playsound(mob_in_turf, 'sound/effects/splat.ogg', 50, TRUE, extrarange = SILENCED_SOUND_EXTRARANGE)
	return ..()


/mob/living/basic/khara_mutant/flesh_spider
	name = "Паук из плоти"
	desc = "Странное существо из плоти в форме паука. Глаза — чёрные бездонные провалы без намёка на душу."
	icon = 'icons/mob/simple/arachnoid.dmi'
	icon_state = "flesh"
	icon_living = "flesh"
	icon_dead = "flesh_dead"
	speak_emote = list("щёлкает")
	response_help_continuous = "гладит"
	response_help_simple = "погладить"
	response_disarm_continuous = "осторожно отталкивает"
	response_disarm_simple = "оттолкнуть"
	ai_controller = /datum/ai_controller/basic_controller/giant_spider
	health = 125
	maxHealth = 125
	innate_actions = list(
		/datum/action/cooldown/mob_cooldown/boss_bone_shard = BB_MOB_ABILITY_BONESHARD
	)

/mob/living/basic/khara_mutant/flesh_spider/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_WEB_SURFER, INNATE_TRAIT)
	AddElement(/datum/element/cliff_walking)
	AddElement(/datum/element/venomous, /datum/reagent/toxin/hunterspider, 5, injection_flags = INJECT_CHECK_PENETRATE_THICK)
	AddElement(/datum/element/web_walker, /datum/movespeed_modifier/fast_web)
	AddElement(/datum/element/nerfed_pulling, GLOB.typecache_general_bad_things_to_easily_move)


/mob/living/basic/khara_mutant/flesh_spider/weaker
	health = 75
	maxHealth = 75
	melee_damage_lower = 10
	melee_damage_upper = 10

/mob/living/basic/khara_mutant/arachnid
	name = "Искажённый арахнид"
	desc = "Несмотря на внушительные размеры, предпочитает нападать из засады и атаковать только уже искалеченную жертву."
	cast = KHARA_CAST_ADAPTED
	icon = 'icons/mob/simple/jungle/arachnid.dmi'
	icon_state = "arachnid"
	icon_living = "arachnid"
	icon_dead = "arachnid_dead"
	color = COLOR_RED
	armour_penetration = 50
	melee_damage_lower = 25
	melee_damage_upper = 35
	wound_bonus = -100
	maxHealth = 350
	health = 350

	regeneration_delay = 7 SECONDS
	health_regen_per_second = 10

	pixel_x = -16
	base_pixel_x = -16
	mob_size = MOB_SIZE_HUGE

	speak_emote = list("ревёт")
	attack_sound = 'sound/items/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	ai_controller = /datum/ai_controller/basic_controller/corrupted_arachnid

	innate_actions = list(
		/datum/action/cooldown/spell/pointed/projectile/flesh_restraints = BB_ARACHNID_RESTRAIN,
		/datum/action/cooldown/mob_cooldown/boss_leap = BB_MOB_ABILITY_LEAP,
	)


// Не бойся Жнеца!
/mob/living/basic/khara_mutant/reaper
	name = "Жнец"
	desc = "Ужасающая мерзость на тонких окровавленных ногах. Конечности двигаются хаотично и неестественно."
	cast = KHARA_CAST_ADAPTED
	icon = 'modular_bandastation/fenysha_events/icons/mob/64x64.dmi'
	icon_state = "reaper"
	icon_living = "reaper"
	icon_dead = "reaper_dead"
	armour_penetration = 20
	melee_damage_lower = 30
	melee_damage_upper = 30
	wound_bonus = 35
	maxHealth = 150
	health = 150

	speed = 0
	regeneration_delay = 15 SECONDS
	health_regen_per_second = 10

	pixel_x = -16
	base_pixel_x = -16
	mob_size = MOB_SIZE_HUGE

	speak_emote = list("ревёт")
	attack_sound = 'sound/items/weapons/bladeslice.ogg'
	attack_vis_effect = null
	ai_controller = /datum/ai_controller/basic_controller/corrupted_arachnid

	innate_actions = list(
		/datum/action/cooldown/mob_cooldown/aoe_slash = BB_MOB_AILITY_SLASH,
		/datum/action/cooldown/mob_cooldown/boss_charge/weak = BB_MOB_ABILITY_FAST_CHARGE,
	)

/mob/living/basic/khara_mutant/reaper/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	if(isliving(target))
		new /obj/effect/temp_visual/slash(get_turf(target), target, world.icon_size / 2, world.icon_size / 2, COLOR_RED)
	. = ..()
	if(!. || !ishuman(target) || !prob(70))
		return

	var/mob/living/carbon/human/victim = target
	var/obj/item/bodypart/to_cut = null
	for(var/obj/item/bodypart/part in victim.bodyparts)
		if(part.max_damage >= LIMB_MAX_HP_CORE)
			continue
		if(part.brute_dam >= (part.max_damage * 0.8))
			to_cut = part
			break
	if(!to_cut)
		return
	new /obj/effect/temp_visual/slash(get_turf(target), target, world.icon_size / 2, world.icon_size / 2, COLOR_RED)
	do_attack_animation(target)
	to_cut.dismember(silent=FALSE)


/mob/living/basic/khara_mutant/spreader
	name = "Распространитель"
	desc = "Огромная мерзость, напоминающая живое лёгкое. Извергает колоссальные объёмы заражённого миазмами Кхара тумана."
	cast = KHARA_CAST_ASSIMILATING
	icon = 'modular_bandastation/fenysha_events/icons/mob/256x256.dmi'
	icon_state = "spreader"
	icon_living = "spreader"
	icon_dead = "spreader"

	speed = 12
	maxHealth = 3000
	health = 3000

	regeneration_delay = 30 SECONDS
	health_regen_per_second = 10

	pixel_x = -112
	base_pixel_x = -112
	pixel_y = -16
	base_pixel_y = -16

	mob_size = MOB_SIZE_HUGE
	plane = MASSIVE_OBJ_PLANE
	layer = LARGE_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_OPAQUE

	move_force = MOVE_FORCE_OVERPOWERING
	move_resist = MOVE_FORCE_OVERPOWERING
	pull_force = MOVE_FORCE_OVERPOWERING

	spread_miasma_amount = 36
	spreads_miasma = TRUE
	spread_miasma_chance = 100
	spread_minimal_cooldown = 25 SECONDS

	ai_controller = /datum/ai_controller/basic_controller/boss_spreader
	innate_actions = list(
		/datum/action/cooldown/mob_cooldown/boss_bone_shard = BB_MOB_ABILITY_BONESHARD,
		/datum/action/cooldown/mob_cooldown/throw_spider = BB_MOB_ABILITY_MEAT_BALL,
		/datum/action/cooldown/mob_cooldown/rumble = BB_MOB_ABILITY_RUMBLE,
	)


/mob/living/basic/khara_mutant/spreader/Initialize(mapload)
	. = ..()
	SSweather.run_weather(/datum/weather/khara_infection)

/mob/living/basic/khara_mutant/spreader/death(gibbed)
	for(var/datum/weather/weather in SSweather.processing)
		if(istype(weather, /datum/weather/khara_infection) && (z in weather.impacted_z_levels))
			weather.wind_down()
			break
	. = ..()
