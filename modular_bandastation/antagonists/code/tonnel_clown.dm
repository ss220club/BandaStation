GLOBAL_VAR_INIT(tunnel_clown_darkness_active, FALSE)
GLOBAL_VAR_INIT(tunnel_clown_antagonist, null)

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
		/datum/action/cooldown/tunnel_clown/execution,
		/datum/action/cooldown/tunnel_clown/rescue,
		/datum/action/cooldown/tunnel_clown/veil,
		/datum/action/cooldown/tunnel_clown/summon_ghosts,
	)
	var/list/datum/action/granted_abilities = list()
	var/initial_max_health = 1000
	var/totem_check_interval = 5 SECONDS

/datum/antagonist/tunnel_clown/can_be_owned(datum/mind/new_owner)
	if(!ishuman(new_owner?.current))
		return FALSE
	return ..()

/datum/antagonist/tunnel_clown/on_gain()
	forge_objectives()
	. = ..()
	equip_clown()
	GLOB.tunnel_clown_antagonist = src
	var/mob/living/carbon/human/clown = owner?.current
	if(istype(clown))
		clown.maxHealth = initial_max_health
		clown.health = initial_max_health
		clown.add_faction(FACTION_CULT)
	update_totem_health()
	addtimer(CALLBACK(src, PROC_REF(check_totems)), totem_check_interval)

/datum/antagonist/tunnel_clown/greet()
	. = ..()
	to_chat(owner.current, span_userdanger("Вы Туннельный Клоун!"))
	to_chat(owner.current, span_boldwarning("Станция и техтоннели - ваши. Пусть экипаж запомнит этот Хэллоуин."))

/datum/antagonist/tunnel_clown/on_removal()
	if(GLOB.tunnel_clown_antagonist == src)
		GLOB.tunnel_clown_antagonist = null
	return ..()

/datum/antagonist/tunnel_clown/proc/equip_clown()
	var/mob/living/carbon/human/clown = owner?.current
	if(!istype(clown))
		return FALSE
	clown.delete_equipment()
	clown.equipOutfit(outfit_type)
	return TRUE

/datum/antagonist/tunnel_clown/proc/update_totem_health()
	var/mob/living/carbon/human/clown = owner?.current
	if(!istype(clown) || QDELETED(clown))
		return
	var/remaining_totems = 0
	for(var/obj/structure/statue/ell_good/halloween/one/totem in world)
		remaining_totems++
	for(var/obj/structure/statue/ell_good/halloween/two/totem in world)
		remaining_totems++
	for(var/obj/structure/statue/ell_good/halloween/tree/totem in world)
		remaining_totems++
	var/new_max_health = 250 + (remaining_totems * 250)
	clown.maxHealth = min(initial_max_health, new_max_health)
	clown.health = min(clown.health, clown.maxHealth)

/datum/antagonist/tunnel_clown/proc/check_totems()
	if(GLOB.tunnel_clown_antagonist != src)
		return
	var/mob/living/carbon/human/clown = owner?.current
	if(!istype(clown) || QDELETED(clown) || clown.stat == DEAD)
		return
	update_totem_health()
	addtimer(CALLBACK(src, PROC_REF(check_totems)), totem_check_interval)

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

/datum/action/cooldown/tunnel_clown/rescue
	name = "Спасение Хонкоматери"
	desc = "Исчезнуть в облаке дыма и переместиться к одному из сохранившихся тотемов."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "teleport"
	cooldown_time = 60 SECONDS

/datum/action/cooldown/tunnel_clown/rescue/Activate(atom/target)
	. = ..()
	var/mob/living/carbon/human/clown = owner
	if(!istype(clown) || QDELETED(clown) || clown.stat == DEAD)
		return FALSE
	var/list/totem_choices = list()
	var/list/totem_by_choice = list()
	for(var/obj/structure/statue/ell_good/halloween/totem in world)
		if(QDELETED(totem))
			continue
		var/turf/totem_turf = get_turf(totem)
		if(!totem_turf)
			continue
		var/choice_name = "[totem.name] ([totem_turf.x], [totem_turf.y])"
		totem_choices += choice_name
		totem_by_choice[choice_name] = totem
	if(!length(totem_choices))
		to_chat(clown, span_warning("Хонкомать не может найти ни одного сохранившегося тотема!"))
		return FALSE
	var/selected_choice = tgui_input_list(
		clown,
		"К какому тотему ты желаешь обратиться?",
		"Спасение Хонкоматери",
		totem_choices,
	)
	if(isnull(selected_choice) || QDELETED(src) || QDELETED(clown))
		return FALSE
	var/obj/structure/statue/ell_good/halloween/selected_totem = totem_by_choice[selected_choice]
	if(!selected_totem || QDELETED(selected_totem))
		to_chat(clown, span_warning("Выбранный тотем больше не существует!"))
		return FALSE
	var/turf/destination = get_turf(selected_totem)
	var/turf/origin = get_turf(clown)
	if(!origin || !destination || origin == destination)
		return FALSE
	create_rescue_effect(origin, clown)
	clown.forceMove(destination)
	create_rescue_effect(destination, clown)
	play_blink_sound(destination)
	apply_honker_effect(destination, clown)
	StartCooldown()
	return TRUE

/datum/action/cooldown/tunnel_clown/rescue/proc/create_rescue_effect(turf/center, mob/living/carbon/human/clown)
	if(!center)
		return
	var/list/peel_types = list(
		/obj/item/grown/bananapeel/bluespace,
		/obj/item/grown/bananapeel/specialpeel,
		/obj/item/grown/bananapeel/gros_michel,
	)
	for(var/turf/T in range(1, center))
		do_smoke(range = 0, holder = clown, location = T, smoke_type = /datum/effect_system/fluid_spread/smoke,)
		var/peel_type = pick(peel_types)
		new peel_type(T)

/datum/action/cooldown/tunnel_clown/rescue/proc/play_blink_sound(turf/location)
	if(!location)
		return
	playsound(location, 'sound/effects/phasein.ogg', 75, TRUE)

/datum/action/cooldown/tunnel_clown/rescue/proc/apply_honker_effect(turf/center, mob/living/carbon/human/clown)
	if(!center)
		return
	playsound(center, 'sound/items/airhorn/airhorn.ogg', 100, TRUE)
	for(var/mob/living/carbon/M in ohearers(6, center))
		if(M == clown)
			continue
		if(HAS_TRAIT(M, TRAIT_DEAF))
			continue
		var/turf/turf_check = get_turf(M)
		if(isspaceturf(turf_check) && !turf_check.Adjacent(center))
			continue
		to_chat(M, "<font color='red' size='7'>HONK</font>")
		M.SetSleeping(0)
		M.adjust_stutter(40 SECONDS)
		M.sound_damage(deafen = 30 SECONDS)
		M.Paralyze(30)
		if(prob(30))
			M.Stun(20)
			M.Unconscious(80)
		else
			M.set_jitter_if_lower(200 SECONDS)

/datum/action/cooldown/tunnel_clown/veil
	name = "Покров Хонкоматери"
	desc = "Раствориться в дыму и стать почти невидимым на 20 секунд. Покров снимает болы и наручники"
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "void_magnet"
	cooldown_time = 30 SECONDS
	var/invisibility_duration = 20 SECONDS

/datum/action/cooldown/tunnel_clown/veil/Activate(atom/target)
	. = ..()
	var/mob/living/carbon/human/clown = owner
	if(!istype(clown) || QDELETED(clown) || clown.stat == DEAD)
		return FALSE
	var/obj/item/clothing/suit/hooded/chaplain_hoodie/hoodie = clown.wear_suit
	if(!istype(hoodie) || !hoodie.hood || clown.head != hoodie.hood)
		to_chat(clown, span_warning("Для Покрова Хонкоматери необходимо надеть накидку с поднятым капюшоном!"))
		return FALSE
	var/obj/item/clothing/shoes/clown_shoes/shoes = clown.shoes
	var/datum/component/squeak/squeak_component
	if(istype(shoes))
		squeak_component = shoes.GetComponent(/datum/component/squeak)
	var/old_alpha = clown.alpha
	var/old_squeak_suppressed = squeak_component?.squeak_suppressed
	clown.alpha = 15
	if(squeak_component)
		squeak_component.squeak_suppressed = TRUE
	var/turf/clown_turf = get_turf(clown)
	if(clown_turf)
		do_smoke(
			range = 0,
			holder = clown,
			location = clown_turf,
			smoke_type = /datum/effect_system/fluid_spread/smoke,
		)
	clown.uncuff(3 MINUTES)
	playsound(clown, 'sound/mobs/non-humanoids/honkbot/honkbot_evil_laugh.ogg', 50, TRUE)
	addtimer(CALLBACK(src, PROC_REF(end_veil), clown, old_alpha, squeak_component, old_squeak_suppressed,), invisibility_duration)
	StartCooldown()
	return TRUE

/datum/action/cooldown/tunnel_clown/veil/proc/end_veil(mob/living/carbon/human/clown, old_alpha, datum/component/squeak/squeak_component, old_squeak_suppressed,)
	if(!clown || QDELETED(clown))
		return
	clown.alpha = old_alpha
	if(squeak_component && !QDELETED(squeak_component))
		squeak_component.squeak_suppressed = old_squeak_suppressed

/datum/action/cooldown/tunnel_clown/summon_ghosts
	name = "Призыв духов"
	desc = "Призывает трёх духов-призраков Хонкоматери, которые помогут вам в бою."
	button_icon = 'modular_bandastation/mobs/icons/sheet_ghost.dmi'
	button_icon_state = "sheet_ghost"
	cooldown_time = 1 MINUTES

/datum/action/cooldown/tunnel_clown/summon_ghosts/Activate(atom/target)
	. = ..()
	var/mob/living/carbon/human/clown = owner
	if(!istype(clown) || QDELETED(clown))
		return
	var/list/spawn_turfs = list()
	for(var/turf/T in orange(1, clown))
		spawn_turfs += T
	if(length(spawn_turfs) < 3)
		return
	for(var/i in 1 to 3)
		var/turf/T = pick(spawn_turfs)
		spawn_turfs -= T
		new /obj/effect/temp_visual/small_smoke(T)
		new /mob/living/basic/mining/ice_demon/ghost(T)
	playsound(clown, 'sound/effects/phasein.ogg', 50, TRUE)
