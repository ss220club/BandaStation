GLOBAL_VAR_INIT(tunnel_clown_darkness_active, FALSE)

/obj/effect/particle_effect/fluid/smoke/tunnel_clown
	lifetime = 30 SECONDS

/datum/mood_event/clown_tonnel
	description = "Весь мир - один большой цирк, и я в нём главный номер!"
	mood_change = 6

/datum/outfit/tunnel_clown
	name = "Туннельный Клоун"
	uniform = /obj/item/clothing/under/rank/civilian/clown
	suit = /obj/item/clothing/suit/hooded/chaplain_hoodie
	back = /obj/item/storage/backpack/messenger/explorer
	belt = /obj/item/gun/magic/hook
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/clown_shoes
	head = /obj/item/clothing/head/hooded/chaplain_hood
	mask = /obj/item/clothing/mask/gas/clown_hat
	ears = /obj/item/radio/headset
	glasses = /obj/item/clothing/glasses/thermal/monocle
	id = /obj/item/card/id/advanced/gold
	id_trim = /datum/id_trim/tunnel_clown
	l_pocket = /obj/item/food/grown/banana
	r_pocket = /obj/item/bikehorn
	l_hand = /obj/item/fireaxe

	backpack_contents = list(
		/obj/item/toy/crayon/red,
		/obj/item/book/granter/martial/cqc,

	)

/datum/outfit/tunnel_clown/post_equip(mob/living/carbon/human/equipped, visuals_only = FALSE)
	. = ..()
	if(visuals_only)
		return
	var/obj/item/card/id/id_card = equipped.wear_id
	if(istype(id_card))
		id_card.registered_name = equipped.real_name
		id_card.update_label()

// MARK: Antagonist
/datum/antagonist/tunnel_clown
	name = "Туннельный Клоун"
	roundend_category = "Туннельные Клоуны"
	antagpanel_category = "Туннельный Клоун"
	antag_moodlet = /datum/mood_event/clown_tonnel
	preview_outfit = /datum/outfit/tunnel_clown
	default_custom_objective = "Сейте хаос и страх на этой тёмной станции. Выживите и дайте экипажу повод вас запомнить."
	var/outfit_type = /datum/outfit/tunnel_clown
	var/list/ability_types = list(
		/datum/action/cooldown/tunnel_clown/darkness,
		/datum/action/cooldown/tunnel_clown/execution
	)
	var/list/datum/action/granted_abilities = list()

/datum/antagonist/tunnel_clown/can_be_owned(datum/mind/new_owner)
	if(!ishuman(new_owner?.current))
		return FALSE
	return ..()

/datum/antagonist/tunnel_clown/on_gain()
	forge_objectives()
	. = ..()
	equip_clown()

/datum/antagonist/tunnel_clown/greet()
	. = ..()
	to_chat(owner.current, span_userdanger("Вы Туннельный Клоун!"))
	to_chat(owner.current, span_boldwarning("Станция и техтоннели - ваши. Пусть экипаж запомнит этот Хэллоуин."))

/datum/antagonist/tunnel_clown/proc/equip_clown()
	var/mob/living/carbon/human/clown = owner?.current
	if(!istype(clown))
		return FALSE
	clown.delete_equipment()
	clown.equipOutfit(outfit_type)
	return TRUE

/datum/antagonist/tunnel_clown/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = mob_override || owner.current
	if(!current)
		return
	for(var/ability_type in ability_types)
		var/datum/action/ability = new ability_type(current)
		ability.Grant(current)
		granted_abilities += ability

/datum/antagonist/tunnel_clown/remove_innate_effects(mob/living/mob_override)
	. = ..()
	QDEL_LIST(granted_abilities)

/datum/action/cooldown/tunnel_clown/darkness
	name = "Пришествие Темноты"
	desc = "Погрузить станцию во тьму, разбив светильники и призвав туман."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "blind"
	cooldown_time = 0

/datum/action/cooldown/tunnel_clown/darkness/Activate(atom/target)
	. = ..()
	var/mob/living/carbon/human/user = owner
	if(!istype(user))
		return FALSE
	GLOB.tunnel_clown_darkness_active = TRUE
	to_chat(user, span_boldannounce("Хонкомать, потуши им яркий свет и окутай всё туманом, чтобы ты могла потешаться, как они будут спотыкаться в темноте..."))
	for(var/obj/machinery/light/light in world)
		if(!istype(get_area(light), /area/station))
			continue
		light.tunnel_clown_darkness = TRUE
		light.break_light_tube()
	var/datum/controller/tunnel_clown_fog/fog_controller = new(user)
	fog_controller.start()
	SSweather.run_weather(/datum/weather/particle/rain_storm/blood)
	minor_announce(
		"Этот Хеллоуин выглядит слишком озорным и смешным. Суть праздника испорчена — познайте же истинный ужас.",
		"Тёмный Посланник Хонкоматери",
		alert = TRUE,
		color_override = "white",
		sound_override = 'sound/mobs/non-humanoids/honkbot/honkbot_evil_laugh.ogg',
	)
	qdel(src)
	return TRUE

/datum/action/cooldown/tunnel_clown/darkness/proc/spawn_darkness_fog()
	var/list/valid_turfs = list()
	for(var/turf/open/floor/iron/T in world)
		valid_turfs += T
	for(var/turf/open/floor/plating/T in world)
		valid_turfs += T
	if(!length(valid_turfs))
		return
	for(var/i in 1 to 8)
		var/turf/fog_turf = pick(valid_turfs)
		do_smoke(range = 4, holder = owner, location = fog_turf, smoke_type = /datum/effect_system/fluid_spread/smoke)

/datum/controller/tunnel_clown_fog
	var/active = TRUE
	var/spawn_interval = 5 SECONDS
	var/clouds_per_spawn = 10
	var/mob/living/carbon/human/clown
	var/list/valid_turfs = list()
	var/list/tunnel_clown_sounds = list(
	'modular_bandastation/antagonists/sound/skary_laugh1.ogg',
	'modular_bandastation/antagonists/sound/skary_sound2.ogg',
	'modular_bandastation/antagonists/sound/skary_sound1.ogg',
	'modular_bandastation/antagonists/sound/skary_sound.ogg',
	'modular_bandastation/antagonists/sound/skary_laugh.ogg',
	'modular_bandastation/antagonists/sound/skary_whispers.ogg',
	'modular_bandastation/antagonists/sound/skary_laugh2.ogg',
	)


/datum/controller/tunnel_clown_fog/New(mob/living/carbon/human/clown_mob)
	. = ..()
	clown = clown_mob

/datum/controller/tunnel_clown_fog/proc/start()
	if(!active || !clown || QDELETED(clown))
		qdel(src)
		return
	collect_valid_turfs()
	if(!length(valid_turfs))
		qdel(src)
		return
	spawn_fog()
	addtimer(CALLBACK(src, PROC_REF(process_fog)), spawn_interval)

/datum/controller/tunnel_clown_fog/proc/collect_valid_turfs()
	valid_turfs = list()
	for(var/turf/open/floor/iron/T in world)
		valid_turfs += T
	for(var/turf/open/floor/plating/T in world)
		valid_turfs += T

/datum/controller/tunnel_clown_fog/proc/process_fog()
	if(!active || !clown || QDELETED(clown) || clown.stat == DEAD)
		qdel(src)
		return
	spawn_fog()
	addtimer(CALLBACK(src, PROC_REF(process_fog)), spawn_interval)

/datum/controller/tunnel_clown_fog/proc/spawn_fog()
	if(!length(valid_turfs))
		return
	for(var/i in 1 to clouds_per_spawn)
		var/turf/fog_turf = pick(valid_turfs)
		do_smoke(
			range = 4,
			holder = clown,
			location = fog_turf,
			smoke_type = /datum/effect_system/fluid_spread/smoke,
			effect_type = /obj/effect/particle_effect/fluid/smoke/tunnel_clown,
		)
		play_random_sound()

/datum/controller/tunnel_clown_fog/proc/play_random_sound()
	if(!length(valid_turfs) || !length(tunnel_clown_sounds))
		return
	var/turf/sound_turf = pick(valid_turfs)
	var/sound/sound_effect = pick(tunnel_clown_sounds)
	playsound(sound_turf, sound_effect, 70, FALSE)

/datum/controller/tunnel_clown_fog/Destroy()
	active = FALSE
	clown = null
	valid_turfs = null
	return ..()

/datum/action/cooldown/tunnel_clown/execution
	name = "Казнь"
	desc = "Приготовьтесь отсечь голову противника ударом топора, пока он находится в агрессивном захвате."
	button_icon = 'icons/obj/weapons/fireaxe.dmi'
	button_icon_state = "fireaxe0"
	cooldown_time = 10 SECONDS
	var/obj/item/fireaxe/armed_axe
	var/mob/living/target_victim
	var/execution_armed = FALSE

/datum/action/cooldown/tunnel_clown/execution/proc/can_execute(mob/living/user, mob/living/target)
	if(!user || QDELETED(user) || user.stat == DEAD)
		return FALSE
	if(!istype(user.get_active_held_item(), /obj/item/fireaxe))
		return FALSE
	if(!user.combat_mode || user.zone_selected != BODY_ZONE_HEAD)
		return FALSE
	if(!target || QDELETED(target) || target == user || !ishuman(target))
		return FALSE
	if(user.pulling != target || user.grab_state < GRAB_AGGRESSIVE)
		return FALSE
	if(!target.get_bodypart(BODY_ZONE_HEAD))
		return FALSE
	return TRUE

/datum/action/cooldown/tunnel_clown/execution/Activate(atom/target)
	if(execution_armed)
		cancel_execution()
		return TRUE
	var/mob/living/user = owner
	if(!istype(user) || !can_execute(user, user.pulling))
		to_chat(user, span_warning("Для казни нужен топор в руке, выбранная голова и жертва в агрессивном захвате!"))
		return FALSE
	armed_axe = user.get_active_held_item()
	target_victim = user.pulling
	execution_armed = TRUE
	RegisterSignal(armed_axe, COMSIG_ITEM_ATTACK, PROC_REF(on_axe_attack))
	to_chat(user, span_boldwarning("Вы приготовились казнить жертву. Ударьте её топором по голове!"))
	return TRUE

/datum/action/cooldown/tunnel_clown/execution/proc/on_axe_attack(obj/item/source, mob/living/target, mob/living/user, list/modifiers, list/attack_modifiers,)
	SIGNAL_HANDLER
	if(!execution_armed || source != armed_axe)
		return
	if(user != owner || target != target_victim)
		return
	if(!can_execute(user, target))
		cancel_execution()
		return
	var/obj/item/bodypart/head = target.get_bodypart(BODY_ZONE_HEAD)
	if(!head)
		cancel_execution()
		return
	cancel_execution()
	if(!head.dismember())
		return COMPONENT_CANCEL_ATTACK_CHAIN
	playsound(user, 'modular_bandastation/antagonists/sound/dismembering.ogg', 70, FALSE,)
	user.say("Головёшка, отлетела как тыквёшка!!!")
	StartCooldown()
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/action/cooldown/tunnel_clown/execution/proc/cancel_execution()
	if(armed_axe && !QDELETED(armed_axe))
		UnregisterSignal(armed_axe, COMSIG_ITEM_ATTACK)
	armed_axe = null
	target_victim = null
	execution_armed = FALSE

// /obj/projectile/beam/scatter/weak /obj/item/storage/spooky
