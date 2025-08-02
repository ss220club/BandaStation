#define LEGENDARY_SWORDS_CKEY_WHITELIST list("mooniverse")

/obj/item/dualsaber/legendary_saber
	name = "Злоба"
	desc = "\"Злоба\" - один из легендарных энергетических мечей Галактики. Словно источая мистическую энергию, \"Злоба\" является олицетворением самой Тьмы, вызывающей трепет и ужас врагов её владельца. Гладкая и простая рукоять меча не может похвастаться орнаментами, узорами или древними рунами, но способна выплескивать рванный энергетический клинок кроваво-красного света, словно кричащий о непокорности и ярости своего владельца.  Некоторые истории гласят, что в этом клинке прибывает сама темная сущность могущества и бесконечного гнева, готовая исполнить волю своего хозяина даже за пределами пространства и времени. \n Создатель: Согда К'Трим. Текущий владелец: Миднайт Блэк."
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
	desc = "\"Ловец  Скорби\"  (Второе название \"Плакса\") -  один из легендарных энергетических мечей Галактики. Он символизирует не только силу власти и могущества, но и является предметом гордости своего обладателя.  Искусно выполненный клинок излучает мягкий голубой свет, словно призывая к миру и согласию, но при этом скрывает в себе силу и решимость защитить своего хозяина любой ценой. Рукоять меча сконструирована строго и со вкусом, создана из темного металла с матовым покрытием и украшена фреской логотипа NT. \"Ловец  Скорби\" имеет специфический звук, отдалённо напоминающий женский плач. Поэтому, немногие очевидцы гнева его хозяина дали мечу второе название - \"Плакса.\" \n Создатель: Гаскон-Валлен-Деламот. Текущий владелец: Билл Громов."
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
	desc = "\"Пламя\" - один из легендарных энергетических мечей Галактики. Он отражает неумолимую справедливость и рьяность характера своего хозяина. В противоречие грозному названию, эфес меча представляет собой аккуратное и \"нежное\" произведение искусства - отполированная нарезная титановая основа завершается золотым навершием, а декоративная гарда выполнен в виде раскрывшегося бутона. Энергетический клинок источает яркий фиолетовый свет, несущий очищение и упокоение своим врагам. Рукоять меча крайне хорошо сбалансирована и отдает дань аристократическим традициям человеческого прошлого. \n Создатель: Гаскон-Валлен-Деламот. Текущий владелец: Шарлотта Дитерхис."
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
	desc = "\"Верность Клятве\" - один из легендарных энергетических мечей Галактики. Этот меч в первую очередь является сакральным символом, связывающий своего владельца вечной Клятвой. Его украшенную древними иероглифами человеческой расы рукоять покрывает хромированный сатин, а двойное изумрудно-зелёное лезвие меча требует от своего хозяина виртуозности и мастерства в обращении, в то же время являясь испытанием доблести, чести и силы духа. Одна из историй этого артефакта гласит, что в свечении клинка отражается душа его создателя - Арканона, который проводил долгие годы в изоляции в попытках создать что-то большее, чем просто оружие.  \n Создатель: Арканон.  Текущий владелец: Хель Кириэн."
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
	name = "Сестра"
	desc = "\"Сестра\" - один из легендарных энергетических мечей Галактики. Являясь \"старшей\" парной частью еще одного легендарного меча - \"Ловца Бегущих\", это оружие представляет собой удивительный артефакт с глубокой историей и мистическими свойствами.  Его лезвие излучает мягкий  золотой свет, который извечно является символом мудрости и мощи. \"Сестра\" - это не просто меч, а символ верности высшим идеалам, дающий своему хозяину силу и решимость. Форма рукояти отсылает к оружию Справедливых Рыцарей древней человеческой истории и обладает строгим стилем, дополняющим своего владельца. Всю свою историю этот меч являлся желанным объектом многих великих существ, но \"Сестра\" способна поистине раскрыться лишь в руках того, кто искренне верит в силу справедливости и не понаслышке знает что такое честь и доблесть. \n Создатель: Коникс`Хеллькикс. Текущий Владелец: Мунивёрс Нормандия."
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
	desc = "\"Ловец Бегущих\" - один из легендарных энергетических мечей Галактики. Являясь \"младшей\" парной частью еще одного легендарного меча - \"Сестры\", это оружие представляет собой более грубое и практичное творение. Корпус рукояти, изобилующий царапинами и потёртостями, говорит о тяжелой истории меча. Одной из традиций владельцев этого оружия является рисование под кнопкой включения отметок в виде белых жетонов, коих уже насчитывается семь штук. Рядом с самым первым жетоном выгравирована надпись : \"2361. А.М.\" \n Цвет клинка ярко-желтый,  его рукоять удлинена для комфортного боя как одной, так и двумя руками, навершие Типа \"P\" покрыто золотом и обладает специальным разъёмом для подключения своей старшей \"Сестры\", а гарда представляет собой два закругленных декоративных отростка. Из старых легенд известно, что строптивый и бурный характер меча могли сдержать лишь настоящие мастера, которые использовали хаотичный, но адаптивный под врага стиль боя. \n Создатель: Коникс`Хеллькикс. Текущий Владелец: Мунивёрс Нормандия, в последствии был передан Рицу Келли."
	icon_state = "kel_dualsaber0"
	inhand_icon_state = "kel_dualsaber0"
	saber_color = "kelly"
	refusal_text = "Ловец бегущих не слушается тебя, кажется он хочет вернуться к хозяину."
	light_color = LIGHT_COLOR_HOLY_MAGIC
	saber_name = "kel"
	wieldsound = 'modular_bandastation/objects/sounds/weapons/kel_saberon.ogg'
	unwieldsound = 'modular_bandastation/objects/sounds/weapons/kel_saberoff.ogg'
	hit_wield = 'modular_bandastation/objects/sounds/weapons/kel_saberhit.ogg'

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
