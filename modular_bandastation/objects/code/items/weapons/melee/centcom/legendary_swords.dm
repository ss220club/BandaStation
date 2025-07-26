#define LEGENDARY_SWORDS_CKEY_WHITELIST list("mooniverse")

/obj/item/dualsaber/legendary_saber
	name = "Злоба"
	desc = "\"Злоба\" - один из легендарных энергетических мечей Галактики. \
	Согласно легенде, это оружие - олицетворение самой Тьмы, впитавшее в себя всю ненависть и ярость своего создателя."
	icon = 'modular_bandastation/objects/icons/obj/weapons/saber/saber.dmi'
	lefthand_file = 'modular_bandastation/objects/icons/obj/weapons/saber/saber_left.dmi'
	righthand_file = 'modular_bandastation/objects/icons/obj/weapons/saber/saber_right.dmi'
	icon_state = "mid_dualsaber0"
	inhand_icon_state = "mid_dualsaber0"
	saber_color = "midnight"
	light_color = LIGHT_COLOR_INTENSE_RED
	var/wieldsound = 'modular_bandastation/objects/sounds/weapons/mid_saberon.ogg'
	var/unwieldsound = 'modular_bandastation/objects/sounds/weapons/mid_saberoff.ogg'
	var/saber_name = "mid"
	var/hit_wield = 'modular_bandastation/objects/sounds/weapons/mid_saberhit.ogg'
	var/hit_unwield = "swing_hit"
	var/ranged = FALSE
	var/power = 1
	var/refusal_text = "Злоба неподвластна твоей воле, усмрить её сможет лишь сильнейший."
	var/datum/enchantment/enchant
	possible_colors = null
	block_chance = 88
	two_hand_force = 45
	attack_speed = CLICK_CD_RAGE_MELEE

/obj/item/dualsaber/legendary_saber/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/ckey_and_role_locked_pickup, TRUE, LEGENDARY_SWORDS_CKEY_WHITELIST, pickup_damage = 10, refusal_text = refusal_text)
	var/datum/component/two_handed/th = src.GetComponent(/datum/component/two_handed)
	th.wieldsound = wieldsound
	th.unwieldsound = unwieldsound
	src.add_enchantment(new/datum/enchantment/dash())

/obj/item/dualsaber/legendary_saber/update_icon_state()
	. = ..()
	icon_state = inhand_icon_state = HAS_TRAIT(src, TRAIT_WIELDED) ? "[saber_name]_dualsaber[saber_color][HAS_TRAIT(src, TRAIT_WIELDED)]" : "[saber_name]_dualsaber0"

/obj/item/dualsaber/legendary_saber/on_wield(obj/item/source, mob/living/carbon/user)
	. = ..()
	hitsound = hit_wield

/obj/item/dualsaber/legendary_saber/on_unwield()
	. = ..()
	hitsound = hit_unwield

/obj/item/dualsaber/legendary_saber/sorrow_catcher
	name = "Ловец Скорби"
	desc = "\"Ловец  Скорби\" -  один из легендарных энергетических мечей Галактики. \
	Согласно легенде, предсмертные крики тех, кого сразило это оружие вырываются при каждой его активации, создавая специфических \"плачущий\" звук. "
	icon_state = "gr_dualsaber0"
	inhand_icon_state  = "gr_dualsaber0"
	saber_color = "gromov"
	refusal_text = "Ну, заплачь."
	light_color = LIGHT_COLOR_LIGHT_CYAN
	saber_name = "gr"
	wieldsound = 'modular_bandastation/objects/sounds/weapons/gr_saberon.ogg'
	unwieldsound = 'modular_bandastation/objects/sounds/weapons/gr_saberoff.ogg'
	hit_wield = 'modular_bandastation/objects/sounds/weapons/gr_saberhit.ogg'

/obj/item/dualsaber/legendary_saber/flame
	name = "Пламя"
	desc = "\"Пламя\" - один из легендарных энергетических мечей Галактики. \
	Согласно легенде, этот меч - оружие завоевателей и праведников, долго время являвшийся фамильной реликвией одного знатного Эллизианского дома."
	icon_state = "sh_dualsaber0"
	inhand_icon_state = "sh_dualsaber0"
	saber_color = "sharlotta"
	refusal_text = "Кровь и свет принадлежат лишь одному."
	light_color = LIGHT_COLOR_LAVENDER
	saber_name = "sh"
	wieldsound = 'modular_bandastation/objects/sounds/weapons/sh_saberon.ogg'
	unwieldsound = 'modular_bandastation/objects/sounds/weapons/sh_saberoff.ogg'
	hit_wield = 'modular_bandastation/objects/sounds/weapons/sh_saberhit.ogg'

/obj/item/dualsaber/legendary_saber/devotion
	name = "Верность клятве"
	desc = "\"Верность Клятве\" - один из легендарных энергетических мечей Галактики. \
	В настоящий момент утерян."
	icon_state = "kir_dualsaber0"
	inhand_icon_state = "kir_dualsaber0"
	saber_color = "kirien"
	refusal_text = "Только достойный узрит свет."
	light_color = LIGHT_COLOR_VIVID_GREEN
	saber_name = "kir"
	wieldsound = 'modular_bandastation/objects/sounds/weapons/kir_saberon.ogg'
	unwieldsound = 'modular_bandastation/objects/sounds/weapons/kir_saberoff.ogg'
	hit_wield = 'modular_bandastation/objects/sounds/weapons/kir_saberhit.ogg'

/obj/item/dualsaber/legendary_saber/sister
	name = "Светлая Сестра"
	desc = "\"Светлая Сестра\" - один из легендарных энергетических мечей Галактики. \
	Согласно легенде, этот элегантный меч был создан для одного из лидеров Синдиката прошлого, что по иронии судьбы была им же и убита."
	icon_state = "norm_dualsaber0"
	inhand_icon_state = "norm_dualsaber0"
	saber_color = "normandy"
	refusal_text = "Ты не принадлежишь сестре, верни её законному владельцу."
	light_color = LIGHT_COLOR_HOLY_MAGIC
	saber_name = "norm"
	wieldsound = 'modular_bandastation/objects/sounds/weapons/norm_saberon.ogg'
	unwieldsound = 'modular_bandastation/objects/sounds/weapons/norm_saberoff.ogg'
	hit_wield = 'modular_bandastation/objects/sounds/weapons/norm_saberhit.ogg'

/obj/item/dualsaber/legendary_saber/flee_catcher
	name = "Ловец Бегущих"
	desc = "\"Ловец Бегущих\" - один из легендарных энергетических мечей Галактики. \
	Согласно легенде, это потрепанное временем оружие есть страшная кара всех беглецов и предателей, всегда находящая цель."
	icon_state = "kel_dualsaber0"
	inhand_icon_state = "kel_dualsaber0"
	saber_color = "kelly"
	refusal_text = "Ловец бегущих не слушается тебя, кажется он хочет вернуться к хозяину."
	light_color = LIGHT_COLOR_HOLY_MAGIC
	saber_name = "kel"
	wieldsound = 'modular_bandastation/objects/sounds/weapons/kel_saberon.ogg'
	unwieldsound = 'modular_bandastation/objects/sounds/weapons/kel_saberoff.ogg'
	hit_wield = 'modular_bandastation/objects/sounds/weapons/kel_saberhit.ogg'

/obj/item/dualsaber/legendary_saber/orphan
	name = "Сирота"
	desc = "\"Сирота\" -  один из легендарных энергетических мечей Галактики. \
	Согласно легенде, этот найденный среди пепла забытой битвы меч никогда не задерживается на долго в руках одного хозяина."
	icon_state = "lex_dualsaber0"
	inhand_icon_state = "lex_dualsaber0"
	saber_color = "lebel"
	refusal_text = "Сироте ты не хозяин."
	light_color = COLOR_AMMO_INCENDIARY
	saber_name = "lex"
	wieldsound = 'modular_bandastation/objects/sounds/weapons/lex_saberon.ogg'
	unwieldsound = 'modular_bandastation/objects/sounds/weapons/lex_saberoff.ogg'
	hit_wield = 'modular_bandastation/objects/sounds/weapons/lex_saberhit.ogg'

/obj/item/dualsaber/legendary_saber/pre_attack(atom/A, mob/living/user, params)
	var/charged = FALSE
	var/proximity = get_proximity(A, user)
	if(isliving(A))
		charged = enchant?.on_legendary_hit(A, usr, proximity, src)
	if(!proximity && !charged)
		return COMPONENT_SKIP_ATTACK
	return ..()

/obj/item/dualsaber/legendary_saber/proc/add_enchantment(datum/enchantment/E)
	enchant = E
	enchant.on_gain(src)
	enchant.power *= power
	for(var/path in enchant.actions_types)
		add_item_action(path)
	enchant.actions_types = null

/obj/item/dualsaber/legendary_saber/proc/get_proximity(atom/A, mob/living/user)
	reach = 1
	var/proximity = user.CanReach(A, src)
	reach = enchant.range
	return proximity

/datum/enchantment/dash
	name = "Рывок"
	desc = "Этот клинок несёт владельца прямо к цели. Никто не уйдёт."
	ranged = TRUE
	range = 7
	actions_types = list(/datum/action/item_action/legendary_saber/rage)
	var/movespeed = 0.8
	var/on_leap_cooldown = FALSE
	var/charging = FALSE
	var/anim_time = 3 DECISECONDS
	var/anim_loop = 3 DECISECONDS
	var/rage_dashes = 7

/datum/enchantment/proc/on_legendary_hit(mob/living/target, mob/living/user, proximity, obj/item/dualsaber/legendary_saber/S)
	if(world.time < cooldown)
		return FALSE
	if(!istype(target))
		return FALSE
	if(target.stat == DEAD)
		return FALSE
	if(!ranged && !proximity)
		return FALSE
	cooldown = world.time + initial(cooldown)
	return TRUE

/datum/enchantment/dash/on_legendary_hit(mob/living/target, mob/living/user, proximity, obj/item/dualsaber/legendary_saber/S)
	if(proximity || !HAS_TRAIT(S, TRAIT_WIELDED)) // don't put it on cooldown if adjacent
		return
	. = ..()
	if(!.)
		return
	charge(user, target, S)

/datum/enchantment/dash/proc/charge(mob/living/user, atom/chargeat, obj/item/dualsaber/legendary_saber/S)
	if(on_leap_cooldown)
		return
	if(!chargeat)
		return
	var/turf/destination_turf  = get_turf(chargeat)
	if(!destination_turf)
		return
	charging = TRUE
	S.block_chance = 100
	var/obj/effect/temp_visual/decoy/D = new /obj/effect/temp_visual/decoy(user.loc, user)
	animate(D, alpha = 0, color = "#271e77", transform = matrix()*1, time = anim_time, loop = anim_loop)
	var/i
	for(i=0, i<5, i++)
		spawn(i * 9 MILLISECONDS)
			step_to(user, destination_turf , 1, movespeed)
			var/obj/effect/temp_visual/decoy/D2 = new /obj/effect/temp_visual/decoy(user.loc, user)
			animate(D2, alpha = 0, color = "#271e77", transform = matrix()*1, time = anim_time, loop = anim_loop)

	spawn(45 MILLISECONDS)
		if(get_dist(user, destination_turf) > 1)
			return
		charge_end(user, S)
		S.block_chance = initial(S.block_chance)

/datum/enchantment/dash/proc/charge_end(list/targets = list(), mob/living/user, obj/item/dualsaber/legendary_saber/S)
	charging = FALSE
	user.apply_damage(-40, STAMINA)

/datum/action/item_action/legendary_saber/rage
	name = "Swordsman Rage"

/datum/action/item_action/legendary_saber/rage/Trigger(trigger_flags)
	var/log_message = "[usr.name] triggered [name]"
	log_combat(log_message)
	message_admins(log_message)
	var/mob/living/user = usr
	var/obj/item/dualsaber/legendary_saber/S = src.target
	var/list/mob/living/charged_targets = list(user)
	var/datum/enchantment/dash/dash = S.enchant
	var/mob/range_center = user
	for(var/count in 1 to dash.rage_dashes)
		var/mob/living/target
		for(var/turf/T in RANGE_TURFS(3, range_center))
			for(var/mob/living/L in T.contents)
				if(!(L in charged_targets))
					target = L
					charged_targets += L
					if(!do_after(user, 5 DECISECONDS, target, IGNORE_USER_LOC_CHANGE | IGNORE_TARGET_LOC_CHANGE))
						target = null
					break
			if(target)
				break
		if(!target)
			break
		S.melee_attack_chain(user, target)
		range_center = target
	return
