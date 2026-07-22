#define CHANNEL_TTS_TRADER 83
//MARK: ESCAPE FROM TAU EVENT
/obj/machinery/vending/trader
	name = "\improper Trade Point - Debug"
	desc = "Торговая точка блюспейс-передачи, которой лучше не пользоваться, если ты не являешься добросовестным разработчиком."
	icon = 'modular_bandastation/objects/icons/obj/machines/vending.dmi'
	icon_state = "nta"
	product_ads = "Не используй меня! Сообщи разработчику!"
	vend_reply = "Эх, ну и зря!"
	onstation = FALSE
	all_products_free = FALSE
	resistance_flags = INDESTRUCTIBLE
	var/tgui_interface = "VendingTraders"
	var/list/product_loyalty = list()
	var/list/buy_prices = list()
	var/list/user_messages = list()
	var/list/quest_chain = list()
	var/trader_id = TRADER_DEBUG
	var/trader_name = "Trader"
	var/trader_desc = "Описание"
	var/trader_portrait = null
	var/trader_message = "Приветствую."
	var/trader_portrait_base64

/obj/machinery/vending/trader/atom_destruction(damage_flag)
	. = ..()
	return

/obj/machinery/vending/trader/proc/get_random_message()
	var/list/messages = splittext(trader_message, ";")
	return pick(messages)

/obj/machinery/vending/trader/proc/speak_message(message, mob/listener)
	if(!listener || !message)
		return
	stop_trader_tts(listener)
	src.do_tts_message(message, null, list(), list(/datum/singleton/sound_effect/robot, /datum/singleton/sound_effect/radio), list(listener))
	src.cast_tts(listener, message)

/obj/machinery/vending/trader/proc/stop_trader_tts(mob/user)
	if(!user?.client)
		return
	var/sound/S = sound(null)
	S.channel = CHANNEL_TTS_TRADER
	SEND_SOUND(user, S)

/obj/machinery/vending/trader/vend(list/params, mob/user, list/greyscale_colors)
	var/datum/data/vending_product/item_record = locate(params["ref"])
	if(item_record)
		if(!ishuman(user))
			return FALSE

		var/mob/living/carbon/human/H = user
		var/player_loyalty = H.get_trader_level(src.trader_id)
		var/required_loyalty = src.product_loyalty[item_record.product_path]
		if(!required_loyalty)
			required_loyalty = 1
		if(player_loyalty < required_loyalty)
			to_chat(H, span_warning("Для покупки этого предмета требуется уровень лояльности [required_loyalty]."))
			flick(icon_deny, src)
			return FALSE

	return ..()

/obj/machinery/vending/trader/ui_interact(mob/user, datum/tgui/ui)
	if(SEND_SIGNAL(src, COMSIG_VENDING_UI_INTERACT, user, ui) & VENDING_DENIED)
		if(icon_deny)
			flick(icon_deny, src)
		return
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, tgui_interface, name)
		ui.open()
		var/key = REF(user)
		if(!user_messages[key])
			user_messages[key] = get_random_message()
		speak_message(user_messages[key], user)

/obj/machinery/vending/trader/ui_data(mob/user)
	. = ..()
	if(!ishuman(user))
		return .
	var/mob/living/carbon/human/H = user
	var/player_loyalty = H.get_trader_level(src.trader_id)
	.["player_loyalty"] = player_loyalty
	var/key = REF(user)
	if(!user_messages[key])
		user_messages[key] = get_random_message()
	.["vendor_message"] = user_messages[key]

	var/rep = H.trader_rep[src.trader_id] || 0
	var/level = H.get_trader_level(src.trader_id)
	var/next_rep
	switch(level)
		if(1)
			next_rep = 10
		if(2)
			next_rep = 50
		if(3)
			next_rep = 100
		else
			next_rep = rep

	.["trader_level"] = level
	.["trader_rep"] = rep
	.["trader_next_rep"] = next_rep
	.["trader_sales_progress"] = H.trader_rep_progress[src.trader_id] || 0

/obj/machinery/vending/trader/ui_static_data(mob/user)
	. = ..()

	.["vendor_name"] = trader_name
	.["vendor_desc"] = trader_desc
	.["vendor_portrait"] = trader_portrait_base64
	var/list/required = list()
	for(var/datum/data/vending_product/P in product_records)
		required[REF(P)] = product_loyalty[P.product_path] || 1
	for(var/datum/data/vending_product/P in coin_records)
		required[REF(P)] = product_loyalty[P.product_path] || 1
	for(var/datum/data/vending_product/P in hidden_records)
		required[REF(P)] = product_loyalty[P.product_path] || 1
	.["required_loyalty"] = required

/obj/machinery/vending/trader/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	switch(action)
		if("take_quest")
			var/mob/living/carbon/human/H = ui.user
			give_quest(H)
			SStgui.update_uis(src)
			return TRUE
		if("sell_all")
			var/mob/living/carbon/human/H = usr
			if(!istype(H))
				return TRUE
			sell_all_items(H)
			return TRUE

/obj/machinery/vending/trader/ui_close(mob/user)
	. = ..()
	user_messages -= REF(user)
	stop_trader_tts(user)

/obj/machinery/vending/trader/proc/sell_item(mob/living/carbon/human/H, obj/item/I)
	if(!I)
		return FALSE
	if(!(I.type in src.buy_prices))
		return FALSE
	var/price = src.buy_prices[I.type]
	qdel(I)
	credit_sale(H, price)
	return price

/obj/machinery/vending/trader/click_alt(mob/living/user)
	. = ..()

	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	var/obj/item/I = user.get_active_held_item()
	var/datum/trader_quest/Q = H.trader_quests[src.trader_id]
	if(Q && I)
		if(istype(Q, /datum/trader_quest/teresa_cyberimp))
			var/datum/trader_quest/teresa_cyberimp/C = Q
			if(C.try_turn_in(H, I, src.trader_id))
				return
		if(Q.can_complete(H, I))
			Q.complete(H, src.trader_id, I)
			return
	if(!I)
		to_chat(user, span_warning("Нужно держать предмет в активной руке."))
		return
	var/price = sell_item(H, I)
	if(!price)
		to_chat(user, span_warning("Торговец не заинтересован в этом предмете."))
		return
	to_chat(user, span_notice("Предмет продан за [price] кредитов."))

/obj/machinery/vending/trader/proc/credit_sale(mob/living/carbon/human/H, amount)
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(id_card?.registered_account)
		id_card.registered_account.adjust_money(amount)
	H.add_trader_sale(src.trader_id, amount)

/obj/machinery/vending/trader/proc/sell_all_items(mob/living/carbon/human/H)
	var/total_price = 0
	var/sold_count = 0
	for(var/obj/item/I in H.get_all_contents())
		if(I.loc == H) // защита от продажи предметов в руках/надетых
			continue
		var/price = sell_item(H, I)
		if(!price)
			continue
		total_price += price
		sold_count++
	if(!sold_count)
		to_chat(H, span_warning("У вас нет предметов для продажи."))
		return
	to_chat(H, span_notice("Продано предметов: [sold_count]. Получено: [total_price] кредитов."))

/obj/machinery/vending/trader/proc/build_trader_inventory()
	product_records = list()
	coin_records = list()
	hidden_records = list()
	product_loyalty = list()
	var/list/product_to_category = list()
	for(var/list/category as anything in product_categories)
		for(var/typepath in category["products"])
			product_to_category[typepath] = category
	for(var/list/category as anything in product_categories)
		var/list/products = category["products"]
		for(var/typepath in products)
			var/list/info = products[typepath]
			var/price = info[1]
			var/loyalty = info[2]
			var/amount = info[3]
			var/obj/item/temp = typepath
			var/datum/data/vending_product/P = new
			P.name = capitalize(declent_ru_initial(temp::name, NOMINATIVE, temp::name))
			P.product_path = typepath
			P.amount = amount
			P.max_amount = amount
			P.price = price
			P.age_restricted = initial(temp.age_restricted)
			P.colorable = !!(initial(temp.greyscale_config) && initial(temp.greyscale_colors) && (initial(temp.flags_1) & IS_PLAYER_COLORABLE_1))
			P.category = product_to_category[typepath]
			product_records += P
			product_loyalty[typepath] = loyalty

/obj/machinery/vending/trader/proc/give_quest(mob/living/carbon/human/H)
	if(H.trader_quests[src.trader_id])
		to_chat(H, span_warning("У вас уже есть активное задание."))
		return
	var/datum/trader_quest/Q
	for(var/path in quest_chain)
		var/datum/trader_quest/temp = new path
		if(!(temp.id in H.completed_trader_quests))
			Q = temp
			break
	if(!Q)
		to_chat(H, span_notice("Сейчас для вас нет новых заданий."))
		return
	for(var/id in H.trader_quests)
		if(id == src.trader_id)
			continue
		var/datum/trader_quest/Active = H.trader_quests[id]
		if(Active?.blocks_other_quests)
			Active.on_other_quest_taken(H, src.trader_id)
		if(!H.trader_quests[id])
			continue
	H.trader_quests[src.trader_id] = Q
	Q.start(H)
	user_messages[REF(H)] = Q.description
	if(H.client)
		speak_message(Q.description, H)
	playsound(H, 'sound/machines/ping.ogg', 50, TRUE)
	to_chat(H, span_notice("Задание [Q.name] принято к выполнению. [Q.context]"))

/obj/machinery/vending/trader/Initialize(mapload)
	. = ..()
	build_trader_inventory()
	if(trader_portrait)
		trader_portrait_base64 = icon2base64(icon(trader_portrait))

/obj/machinery/vending/trader/examine(mob/user)
	. = ..()
	. += "Нажмите <b>АЛЬТ - КЛИК</b> чтобы продать предметы."

/obj/machinery/vending/trader/samopal
	name = "\improper Trade Point - Praporchik Samopal"
	desc = "Торговая точка блюспейс-передачи, принадлежащая связному от новосозданной СССП - Прапорщику Самопалу."
	icon = 'modular_bandastation/objects/icons/obj/machines/vending.dmi'
	icon_state = "nta"
	product_ads = "Выберимся из этой проклятой дыры благодаря Социалистической Партии, сынок!;Мои автоматы - не клинят, одежда - не боится грязи!;Бжж-Бзз-з!;Во славу Партии!;Генсек будет гордиться тобой, товарищ! Если будешь продавать всё мне. Или покупать..."
	vend_reply = "Ну, ни пуха тебе!"
	onstation = FALSE
	all_products_free = FALSE

	trader_id = TRADER_SAMOPAL
	trader_name = "Прапорщик Самопал"
	trader_desc = "Сепаратист недавно образовавшейся СССП - социалистического квазигосударства на территории ТСФ. На Тау-Кита командовал сводной ротой спецназа, в задачи которой входило внедрение на атомную станцию Сидней-Нова. После катастрофы, отколовшись от командования - обосновался с остатками роты на одном из заброшенных складов и наладил поставки излишек вооружений, которое сразу стало пользоваться спросом у обездоленных наемников на планете. Однако, ходят слухи, что не все из его бойцов согласились продолжать вести с ним дела - два брата-спецназовца под позывными Чук и Гек откололись от его группы и теперь всячески препядствуют Самопалу в налаживании поставок."
	trader_portrait = 'modular_bandastation/voyaker_events/icons/traders/samopal.png'
	trader_message = "Приветствую тебя, товарищ!;Эти треклятые капиталисты устроили целую ядерную бойню. Мы найдём ответственных.;Как ты? Ещё не светишься от радиации, как новогодняя ёлка? Хе-хе!;Рад, что ты до сих пор живой. Давай поболтаем, салага.;Партия поможет тебе выбраться отсюда, но сначала - потрудись на её благо.;Точно ничего не забыл купить, сынок? Места тут гиблые. Снаряжайся всегда, как в последний раз."

	quest_chain = list(
		/datum/trader_quest/samopal_medal,
		/datum/trader_quest/samopal_vtol,
		/datum/trader_quest/samopal_spiders,
		/datum/trader_quest/samopal_letter,
		/datum/trader_quest/samopal_bigots,
	)

	buy_prices = list(
		/obj/item/clothing/mask/bandana/gold = 50,
		/obj/item/stack/sheet/mineral/gold = 100,
		/obj/item/clothing/accessory/medal = 150,
		/obj/item/bikehorn/golden = 50,
		/obj/item/instrument/violin/golden = 300,
		/obj/item/clothing/accessory/anti_sec_pin = 75,
		/obj/item/clothing/accessory/deaf_pin = 75,
		/obj/item/clothing/accessory/debt_payer_pin = 75,
		/obj/item/clothing/accessory/kheiral_cuffs = 400,
		/obj/item/clothing/accessory/gloves_accessory/ring/silver = 150,
		/obj/item/clothing/accessory/gloves_accessory/ring = 300,
		/obj/item/clothing/accessory/gloves_accessory/ring/diamond = 500,
		/obj/item/reagent_containers/cup/glass/mug/britcup = 75,
		/obj/item/storage/belt/champion = 300,
		/obj/item/clothing/neck/necklace/dope = 300,
		/obj/item/documents = 200,
		/obj/item/documents/nanotrasen = 450,
		/obj/item/documents/syndicate = 500,
		/obj/item/documents/syndicate/red = 700,
		/obj/item/documents/syndicate/blue = 1000,
		/obj/item/disk/holodisk = 150,
		/obj/item/disk/holodisk/donutstation/whiteship = 300,
		/obj/item/disk/holodisk/ruin/cyborg_mothership = 500,
		/obj/item/disk/holodisk/ruin/waystation = 750,
		/obj/item/disk/computer = 100,
		/obj/item/disk/computer/super = 200,
		/obj/item/disk/computer/command = 300,
		/obj/item/disk/computer/hdd_theft = 300,
		/obj/item/disk/computer/syndie_ai_upgrade = 450,
		/obj/item/keycard/nt_labs = 350,
	)

	product_categories = list(
		list(
			"name" = "Weapon",
			"icon" = "gun",
			"products" = list(
				/obj/item/gun/ballistic/automatic/pistol = list(100, 1, 10000),
				/obj/item/gun/ballistic/rifle/sks = list(250, 1, 10000),
				/obj/item/gun/ballistic/rifle/boltaction/mosin = list(200, 1, 10000),
				/obj/item/gun/ballistic/automatic/pistol/zashch = list(150, 2, 10000),
				/obj/item/gun/ballistic/automatic/sabel/auto = list(350, 2, 10000),
				/obj/item/gun/ballistic/rifle/sks/c762x54mmr = list(300, 2, 10000),
				/obj/item/gun/ballistic/rifle/boltaction/mosin/strilka310 = list(300, 2, 10000),
				/obj/item/gun/ballistic/automatic/bison = list(250, 2, 10000),
				/obj/item/gun/ballistic/automatic/sabel/auto/army/alt = list(400, 3, 10000),
				/obj/item/gun/ballistic/automatic/sabel/auto/modern = list(450, 3, 10000),
				/obj/item/gun/ballistic/automatic/lanca = list(500, 3, 10000),
				/obj/item/gun/ballistic/revolver/dvoystvol/low_caliber = list(450, 3, 10000),
				/obj/item/gun/ballistic/automatic/pistol/clandestine/fisher = list(300, 4, 10000),
				/obj/item/gun/ballistic/automatic/lanca/army/suppressed = list(700, 4, 10000),
				/obj/item/gun/ballistic/automatic/sabel/auto/modern/bullpup/army = list(500, 4, 10000),
				/obj/item/gun/ballistic/automatic/vityaz = list(450, 4, 10000),
				/obj/item/gun/ballistic/revolver/dvoystvol = list(450, 4, 10000),
			),
		),

		list(
			"name" = "Ammo & Grenades",
			"icon" = "box",
			"products" = list(
				/obj/item/ammo_box/magazine/m9mm = list(10, 1, 10000),
				/obj/item/ammo_box/speedloader/strilka310 = list(15, 1, 10000),
				/obj/item/ammo_box/magazine/zashch = list(15, 1, 10000),
				/obj/item/ammo_box/c762x39/ricochet = list(30, 1, 10000),
				/obj/item/ammo_box/c762x54mmr = list(20, 1, 10000),
				/obj/item/ammo_box/magazine/c762x39mm/small/civ = list(30, 1, 10000),
				/obj/item/storage/toolbox/ammobox/c762x54mmr_bullets = list(80, 2, 10000),
				/obj/item/grenade/frag = list(150, 2, 10000),
				/obj/item/ammo_box/c762x39/hunting = list(35, 2, 10000),
				/obj/item/ammo_box/magazine/strilka310 = list(20, 2, 10000),
				/obj/item/ammo_box/magazine/c762x39mm = list(35, 2, 10000),
				/obj/item/ammo_box/magazine/m9mm/hp = list(15, 2, 10000),
				/obj/item/ammo_box/magazine/bison = list(25, 2, 10000),
				/obj/item/ammo_box/magazine/bison/hp = list(30, 2, 10000),
				/obj/item/storage/toolbox/ammobox/amk_mags = list(150, 3, 10000),
				/obj/item/ammo_box/c762x39/emp = list(80, 3, 10000),
				/obj/item/ammo_box/magazine/c762x39mm/emp = list(100, 3, 10000),
				/obj/item/ammo_box/magazine/m9mm/ap = list(40, 3, 10000),
				/obj/item/ammo_box/magazine/m10mm/hp = list(30, 4, 10000),
				/obj/item/ammo_box/magazine/m10mm/ap = list(60, 4, 10000),
				/obj/item/grenade/c4 = list(300, 4, 10000),
				/obj/item/ammo_box/magazine/bison/ap = list(150, 4, 10000),
				/obj/item/ammo_box/magazine/smg10mm = list(90, 4, 10000),
			),
		),

		list(
			"name" = "Equipment",
			"icon" = "hand-fist",
			"products" = list(
				/obj/item/clothing/shoes/jackboots = list(20, 1, 10000),
				/obj/item/clothing/head/hats/ussp = list(10, 1, 10000),
				/obj/item/radio/headset/heads/captain/alt/ussp = list(30, 1, 10000),
				/obj/item/storage/backpack/ussp = list(30, 1, 10000),
				/obj/item/clothing/suit/armor/vest/russian = list(50, 1, 10000),
				/obj/item/clothing/shoes/russian = list(20, 1, 10000),
				/obj/item/clothing/head/helmet/rus_helmet = list(40, 2, 10000),
				/obj/item/clothing/suit/armor/vest/ussp = list(70, 2, 10000),
				/obj/item/clothing/head/helmet/marine/security/ussp_kaska = list(150, 3, 10000),
				/obj/item/clothing/suit/armor/vest/marine/security/ussp_security = list(325, 3, 10000),
				/obj/item/clothing/mask/breath/red_gas = list(150, 4, 10000),
				/obj/item/clothing/glasses/hud/security/night = list(300, 4, 10000),
			),
		),
	)

/obj/machinery/vending/trader/samopal/examine(mob/user)
	. = ..()
	. += "<b>ПОКУПАЕТ:</b> Драгоценности и информационные предметы - бумаги, датадиски и т.д."

/obj/machinery/vending/trader/samopal/add_tts_component()
	AddComponent(/datum/component/tts_component, /datum/tts_seed/silero/brann)

/obj/machinery/vending/trader/samopal/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/tts_component, /datum/tts_seed/silero/brann)

/obj/machinery/vending/trader/teresa
	name = "\improper Trade Point - Teresa"
	desc = "Торговая точка блюспейс-передачи, принадлежащая анонимной торговке - Терезе."
	icon = 'modular_bandastation/objects/icons/obj/machines/vending.dmi'
	icon_state = "nta"
	product_ads = "Все потраченные средства - пойдут на помощь гражданским. Пусть Господь будет тому свидетелем.;Все товары, что ты видишь - были посланы лишь Господом;Бжж-Бзз-з!;Пусть Господь спасёт наши грешные души в это нелёгкое время.;Раненые и нуждающиеся будут благодарны вам, если вы пожертвуете немного денег, купив эти скромные товары."
	vend_reply = "Да благословит тебя Господь на твоём пути."
	onstation = FALSE
	all_products_free = FALSE

	trader_id = TRADER_TERESA
	trader_name = "Тереза"
	trader_desc = "Благотворительница и предпринимательница по совместительству. Доподлинно неизвестно, является ли Тереза настоящей священнослужительницей и действительно ли это женщина, а не мужчина. Известно лишь то, что она жила в пригородах Нового Сиднея с самого рождения и хорошо осведомлена о произошедших событиях в городе. После катастрофы она смогла организовать группу медиков, которые именуют себя Милосердными - они одни из первых отказались от эвакуации и посвятили себя лечению больных от облучения в оставшихся убежищах."
	trader_portrait = 'modular_bandastation/voyaker_events/icons/traders/teresa.png'
	trader_message = "Да пребудет с тобой Господь, дитя моё.;Даже в самоё тяжелое и грешное бремя - мы можем оставаться верны Господу.;Не позволяй никому осквернить злыми помыслами твою душу.;Приветствую вас. Хорошо, что Господь оберегает вас от погибели.;Вы точно хорошо себя чувствуете? Мой ассортимент лекарств от любых недугов - всегда открыт для вас.;Сохраняйте душу в чистоте, голову - в ясности, и тогда Господь приведёт вас на верный путь."

	quest_chain = list(
		/datum/trader_quest/teresa_defibrillator,
		/datum/trader_quest/teresa_mailboxes,
		/datum/trader_quest/teresa_charter,
		/datum/trader_quest/teresa_zombies,
		/datum/trader_quest/teresa_cyberimp,
	)

	buy_prices = list(
		/obj/item/clothing/mask/bandana/gold = 70,
		/obj/item/stack/sheet/mineral/gold = 125,
		/obj/item/clothing/accessory/medal = 175,
		/obj/item/bikehorn/golden = 75,
		/obj/item/instrument/violin/golden = 350,
		/obj/item/clothing/accessory/anti_sec_pin = 100,
		/obj/item/clothing/accessory/deaf_pin = 100,
		/obj/item/clothing/accessory/debt_payer_pin = 100,
		/obj/item/clothing/accessory/kheiral_cuffs = 450,
		/obj/item/clothing/accessory/gloves_accessory/ring/silver = 200,
		/obj/item/clothing/accessory/gloves_accessory/ring = 350,
		/obj/item/clothing/accessory/gloves_accessory/ring/diamond = 600,
		/obj/item/reagent_containers/cup/glass/mug/britcup = 100,
		/obj/item/storage/belt/champion = 400,
		/obj/item/clothing/neck/necklace/dope = 300,
		/obj/item/reagent_containers/cup/glass/bottle/holywater = 300,
		/obj/item/sticker/purity_seal = 125,
		/obj/item/clothing/suit/chaplainsuit/habit = 150,
		/obj/item/book/bible = 100,
		/obj/item/autosurgeon = 500,
		/obj/item/organ/cyberimp/chest/nutriment = 150,
		/obj/item/organ/cyberimp/brain/anti_drop = 450,
		/obj/item/pinpointer/crew = 500,
		/obj/item/reagent_containers/hypospray/combat = 300,
		/obj/item/healthanalyzer = 25,
		/obj/item/healthanalyzer/simple = 20,
		/obj/item/healthanalyzer/advanced = 50,
		/obj/item/clothing/neck/stethoscope = 50,
		/obj/item/food/cherrycupcake = 5,
		/obj/item/food/candy = 5,
		/obj/item/food/peanuts = 10,
		/obj/item/reagent_containers/cup/glass/coffee = 5,
		/obj/item/reagent_containers/cup/soda_cans/space_mountain_wind = 5,
		/obj/item/reagent_containers/cup/soda_cans/cola = 5,
		/obj/item/food/energybar = 15,
		/obj/item/food/shok_roks/random = 15,
		/obj/item/food/shok_roks = 15,
		/obj/item/reagent_containers/cup/soda_cans/volt_energy = 20,
		/obj/item/reagent_containers/cup/glass/mug/coco = 10,
		/obj/item/food/rationpack = 25,
		/obj/item/food/canned/beans = 15,
		/obj/item/artifact/fire_wing = 550,
		/obj/item/artifact/ice_crystal = 850,
		/obj/item/artifact/stone_eye = 750,
	)

	product_categories = list(
		list(
			"name" = "Food & Drinks",
			"icon" = "box",
			"products" = list(
				/obj/item/food/cherrycupcake = list(10, 1, INFINITY),
				/obj/item/food/candy = list(10, 1, INFINITY),
				/obj/item/food/sosjerky = list(15, 1, INFINITY),
				/obj/item/food/peanuts/random = list(20, 1, INFINITY),
				/obj/item/food/peanuts = list(20, 1, INFINITY),
				/obj/item/food/donkpocket = list(50, 1, INFINITY),
				/obj/item/reagent_containers/cup/glass/coffee = list(15, 1, INFINITY),
				/obj/item/reagent_containers/cup/soda_cans/space_mountain_wind = list(10, 1, INFINITY),
				/obj/item/reagent_containers/cup/soda_cans/cola = list(10, 1, INFINITY),
				/obj/item/food/energybar = list(30, 2, INFINITY),
				/obj/item/food/shok_roks/random = list(35, 2, INFINITY),
				/obj/item/food/shok_roks = list(35, 2, INFINITY),
				/obj/item/reagent_containers/cup/soda_cans/volt_energy = list(40, 2, INFINITY),
				/obj/item/reagent_containers/cup/glass/mug/coco = list(20, 2, INFINITY),
			),
		),

		list(
			"name" = "Equipment",
			"icon" = "hand-fist",
			"products" = list(
				/obj/item/storage/box = list(10, 1, INFINITY),
				/obj/item/storage/bag/trash/bluespace = list(20, 1, INFINITY),
				/obj/item/healthanalyzer = list(50, 1, INFINITY),
				/obj/item/healthanalyzer/simple = list(40, 1, INFINITY),
				/obj/item/healthanalyzer/advanced = list(100, 2, INFINITY),
				/obj/item/clothing/neck/stethoscope = list(100, 3, INFINITY),
				/obj/item/clothing/glasses/hud/health/sunglasses = list(200, 3, INFINITY),
				/obj/item/autosurgeon = list(1000, 3, INFINITY),
				/obj/item/organ/cyberimp/chest/pump = list(350, 3, INFINITY),
				/obj/item/organ/cyberimp/brain/anti_drop = list(700, 3, INFINITY),
				/obj/item/pinpointer/crew = list(1200, 4, INFINITY),
				/obj/item/organ/cyberimp/brain/anti_stun = list(800, 4, INFINITY),
				/obj/item/organ/cyberimp/chest/reviver = list(800, 4, INFINITY),
			),
		),

		list(
			"name" = "Medicine",
			"icon" = "heart",
			"products" = list(
				/obj/item/storage/box/bandages = list(30, 1, INFINITY),
				/obj/item/stack/medical/suture = list(30, 1, INFINITY),
				/obj/item/stack/medical/ointment = list(20, 1, INFINITY),
				/obj/item/stack/medical/mesh = list(25, 1, INFINITY),
				/obj/item/stack/medical/wrap/gauze = list(15, 1, INFINITY),
				/obj/item/stack/medical/wrap/sticky_tape/surgical = list(25, 1, INFINITY),
				/obj/item/reagent_containers/hypospray/medipen = list(30, 1, INFINITY),
				/obj/item/reagent_containers/cup/bottle/epinephrine = list(40, 1, INFINITY),
				/obj/item/reagent_containers/syringe/epinephrine = list(50, 2, INFINITY),
				/obj/item/reagent_containers/syringe/antiviral = list(30, 2, INFINITY),
				/obj/item/reagent_containers/applicator/patch/libital = list(50, 2, INFINITY),
				/obj/item/reagent_containers/applicator/patch/aiuri = list(40, 2, INFINITY),
				/obj/item/reagent_containers/cup/bottle/morphine = list(50, 2, INFINITY),
				/obj/item/storage/medkit/regular = list(100, 2, INFINITY),
				/obj/item/reagent_containers/blood/o_minus = list(75, 2, INFINITY),
				/obj/item/storage/pill_bottle/happinesspsych = list(50, 2, INFINITY),
				/obj/item/storage/pill_bottle/penacid = list(100, 2, INFINITY),
				/obj/item/storage/medkit/o2 = list(80, 2, INFINITY),
				/obj/item/reagent_containers/hypospray/cmo = list(200, 3, INFINITY),
				/obj/item/storage/medkit/toxin = list(400, 3, INFINITY),
				/obj/item/storage/medkit/brute = list(350, 3, INFINITY),
				/obj/item/storage/medkit/fire = list(350, 3, INFINITY),
				/obj/item/reagent_containers/medigel/libital = list(150, 3, INFINITY),
				/obj/item/reagent_containers/medigel/aiuri = list(150, 3, INFINITY),
				/obj/item/storage/medkit/surgery = list(500, 3, INFINITY),
				/obj/item/storage/pill_bottle/mannitol = list(150, 3, INFINITY),
				/obj/item/reagent_containers/cup/bottle/potass_iodide = list(300, 3, INFINITY),
				/obj/item/storage/medkit/advanced = list(500, 4, INFINITY),
				/obj/item/storage/medkit/tactical = list(650, 4, INFINITY),
				/obj/item/reagent_containers/hypospray/combat = list(700, 4, INFINITY),
			),
		),
	)

/obj/machinery/vending/trader/teresa/add_tts_component()
	AddComponent(/datum/component/tts_component, /datum/tts_seed/silero/diana)

/obj/machinery/vending/trader/teresa/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/tts_component,  /datum/tts_seed/silero/diana)

/obj/machinery/vending/trader/teresa/examine(mob/user)
	. = ..()
	. += "<b>ПОКУПАЕТ:</b> Драгоценности, религиозные предметы, медицину, еду, импланты и медицинские устройства."

/obj/machinery/vending/trader/fashion
	name = "\improper Trade Point - Fashion"
	desc = "Торговая точка блюспейс-передачи, принадлежащая бывшему предпринимателю - Фэйшену."
	icon = 'modular_bandastation/objects/icons/obj/machines/vending.dmi'
	icon_state = "nta"
	product_ads = "Братуха, не зевай - скорее крутой дрип покупай!;У меня бренды - высший класс!;Бжж-Бзз-з!;В таких шмотках - на тебя даже смотреть будет страшно! Но не потому, что они херовые - потому что клёвые!;Будь стильным наёмником - затаривайся только у меня!"
	vend_reply = "Дороги бархатом, братишка!"
	onstation = FALSE
	all_products_free = FALSE

	trader_id = TRADER_FASHION
	trader_name = "Фэйшн"
	trader_desc = "Бывший владелец брендового магазина одежды The Boy в центральном торговом центре Нового Сиднея и капо одной из двух влиятельных мафиозных семей Тау-Кита - Павони. Его магазин использовался для отмывания денег мафии, в то время как его команда обеспечивала крышу над игорным бизнесом на Побережье, откуда и шёл основной поток средств. Фейшн вовремя спохватился и вместе со своими людьми - перевёз остаток товара из магазина на закрытые портовые склады, теперь торгуя не только обычной одеждой."
	trader_portrait = 'modular_bandastation/voyaker_events/icons/traders/fashion.gif'
	trader_message = "Чего ты мнёшься? Подходи, братуха, я не кусаюсь.;Заценил шмотки, да? Скажи ведь клёвые. Что смог выпер из сити-молла, когда весь шабаш начался - всё самое лучшее для тебя, братишка!;Ты ведь не из местных, да? Ничего, привыкнешь к нашей тусовке.;Аллоха! Ты как, приодеться зашёл, или так - за жизнь нелёгкую потрещать?;В моих шмотках - и сдыхать не страшно. Так что присматривай себе что угодно, братишка.;Ты ведь не водишься с этой рыжеволосой бестией? А, проехали, не бери в голову... Так что будешь тарить, братишка?"

	quest_chain = list(
		/datum/trader_quest/fashion_jacket,
		/datum/trader_quest/fashion_casino,
		/datum/trader_quest/fashion_armor,
		/datum/trader_quest/fashion_beacon,
		/datum/trader_quest/fashion_targets,
	)

	buy_prices = list(
		/obj/item/clothing/head/wig/natural = 50,
		/obj/item/clothing/head/beret = 50,
		/obj/item/clothing/head/beanie = 35,
		/obj/item/clothing/head/costume/fancy = 50,
		/obj/item/clothing/mask/bandana = 35,
		/obj/item/clothing/mask/bandana/skull = 40,
		/obj/item/clothing/mask/facescarf = 50,
		/obj/item/clothing/neck/scarf = 50,
		/obj/item/clothing/neck/large_scarf = 60,
		/obj/item/clothing/neck/tie = 50,
		/obj/item/clothing/neck/bowtie = 50,
		/obj/item/clothing/head/rasta = 75,
		/obj/item/clothing/head/hats/tophat = 125,
		/obj/item/clothing/head/fedora = 75,
		/obj/item/clothing/head/fedora/greyscale = 75,
		/obj/item/clothing/head/cowboy/white = 100,
		/obj/item/clothing/head/costume/sombrero/green = 150,
		/obj/item/clothing/neck/tie/horrible = 80,
		/obj/item/clothing/accessory/waistcoat = 70,
		/obj/item/clothing/glasses/regular = 50,
		/obj/item/clothing/glasses/red = 100,
		/obj/item/clothing/glasses/monocle = 200,
		/obj/item/clothing/gloves/fingerless = 75,
		/obj/item/clothing/neck/cloak/colorable_cloak = 50,
		/obj/item/clothing/under/costume/buttondown/skirt = 75,
		/obj/item/clothing/under/costume/buttondown/slacks = 75,
		/obj/item/clothing/under/dress/sundress = 100,
		/obj/item/clothing/under/dress/tango = 250,
		/obj/item/clothing/under/dress/skirt/plaid = 70,
		/obj/item/clothing/under/dress/skirt/turtleskirt = 90,
		/obj/item/clothing/under/misc/overalls = 75,
		/obj/item/clothing/under/pants/camo = 100,
		/obj/item/clothing/under/dress/striped = 90,
		/obj/item/clothing/under/dress/sailor = 125,
		/obj/item/clothing/under/dress/eveninggown = 350,
		/obj/item/clothing/suit/toggle/jacket/sweater = 40,
		/obj/item/clothing/suit/toggle/jacket/trenchcoat = 70,
		/obj/item/clothing/suit/jacket/fancy = 150,
		/obj/item/clothing/suit/toggle/lawyer/greyscale = 125,
		/obj/item/clothing/suit/hooded/wintercoat/pullover = 60,
		/obj/item/clothing/under/suit/navy = 125,
		/obj/item/clothing/under/suit/black_really = 150,
		/obj/item/clothing/under/suit/burgundy = 200,
		/obj/item/clothing/under/suit/white = 150,
		/obj/item/clothing/under/suit/charcoal = 150,
		/obj/item/clothing/suit/costume/hawaiian = 50,
		/obj/item/clothing/suit/jacket/letterman_red = 75,
		/obj/item/clothing/under/rank/civilian/purple_bartender = 90,
		/obj/item/clothing/under/dress/skirt = 125,
		/obj/item/clothing/suit/jacket/miljacket = 60,
		/obj/item/clothing/shoes/swagshoes = 250,
		/obj/item/instrument/piano_synth/headphones/spacepods = 500,
		/obj/item/clothing/under/suit/checkered = 400,
		/obj/item/clothing/suit/jacket/letterman_nanotrasen = 300,
		/obj/item/clothing/suit/jacket/leather/biker = 350,
	)

	product_categories = list(
		list(
			"name" = "Equipment",
			"icon" = "hand-fist",
			"products" = list(
				/obj/item/clothing/under/rank/centcom/military/ert = list(20, 1, INFINITY),
				/obj/item/clothing/under/syndicate = list(20, 1, INFINITY),
				/obj/item/clothing/under/syndicate/combat = list(30, 1, INFINITY),
				/obj/item/clothing/under/costume/russian_officer = list(25, 1, INFINITY),
				/obj/item/clothing/under/costume/soviet = list(25, 1, INFINITY),
				/obj/item/clothing/under/syndicate/camo = list(30, 1, INFINITY),
				/obj/item/clothing/suit/armor/vest = list(50, 1, INFINITY),
				/obj/item/clothing/suit/armor/vest/alt = list(50, 1, INFINITY),
				/obj/item/clothing/suit/armor/vest/russian_coat = list(50, 1, INFINITY),
				/obj/item/clothing/head/helmet/swat = list(30, 1, INFINITY),
				/obj/item/clothing/head/helmet/blueshirt = list(30, 1, INFINITY),
				/obj/item/clothing/head/helmet/swat/nanotrasen = list(30, 1, INFINITY),
				/obj/item/clothing/head/helmet/sec = list(30, 1, INFINITY),
				/obj/item/clothing/head/cowboy = list(15, 1, INFINITY),
				/obj/item/clothing/head/hats/tsf_cap = list(10, 1, INFINITY),
				/obj/item/clothing/head/chameleon = list(10, 1, INFINITY),
				/obj/item/clothing/head/costume/ushanka = list(10, 1, INFINITY),
				/obj/item/storage/backpack/satchel/blueshield = list(30, 1, INFINITY),
				/obj/item/storage/backpack = list(25, 1, INFINITY),
				/obj/item/clothing/suit/jacket/officer/tan = list(25, 1, INFINITY),
				/obj/item/clothing/mask/balaclava = list(20, 1, INFINITY),
				/obj/item/clothing/gloves/color/black = list(15, 1, INFINITY),
				/obj/item/clothing/shoes/jackboots = list(15, 1, INFINITY),
				/obj/item/storage/belt/military/army/ussp = list(40, 1, INFINITY),
				/obj/item/storage/belt/military/army/tsf = list(40, 1, INFINITY),
				/obj/item/storage/belt/military/army = list(40, 1, INFINITY),
				/obj/item/storage/bag/ore = list(50, 1, INFINITY),
				/obj/item/beacon = list(100, 2, INFINITY),
				/obj/item/clothing/glasses/sunglasses = list(150, 2, INFINITY),
				/obj/item/clothing/gloves/combat = list(100, 2, INFINITY),
				/obj/item/clothing/gloves/tackler/combat = list(150, 2, INFINITY),
				/obj/item/clothing/under/hoodie_black = list(40, 2, INFINITY),
				/obj/item/clothing/suit/costume/hawaiian = list(100, 2, INFINITY),
				/obj/item/storage/backpack/ert/security = list(30, 2, INFINITY),
				/obj/item/storage/backpack/satchel/leather = list(35, 2, INFINITY),
				/obj/item/storage/backpack/bannerpack/blue = list(40, 2, INFINITY),
				/obj/item/storage/backpack/bannerpack/red = list(40, 2, INFINITY),
				/obj/item/storage/backpack/industrial = list(80, 2, INFINITY),
				/obj/item/storage/belt/military = list(60, 2, INFINITY),
				/obj/item/clothing/accessory/holster = list(100, 2, INFINITY),
				/obj/item/clothing/accessory/ammo_vest = list(80, 2, INFINITY),
				/obj/item/clothing/accessory/ammo_vest/black = list(100, 2, INFINITY),
				/obj/item/clothing/under/syndicate/soviet = list(50, 3, INFINITY),
				/obj/item/clothing/mask/gas = list(200, 3, INFINITY),
				/obj/item/clothing/glasses/night = list(250, 3, INFINITY),
				/obj/item/clothing/head/helmet/space/syndicate = list(150, 3, INFINITY),
				/obj/item/clothing/head/helmet/space/syndicate/black = list(150, 3, INFINITY),
				/obj/item/clothing/head/helmet/space/syndicate/black/blue = list(150, 3, INFINITY),
				/obj/item/clothing/head/helmet/space/syndicate/blue = list(150, 3, INFINITY),
				/obj/item/clothing/head/helmet/marine/security = list(125, 3, INFINITY),
				/obj/item/clothing/head/helmet/marine/engineer = list(125, 3, INFINITY),
				/obj/item/clothing/suit/armor/vest/marine/security = list(250, 3, INFINITY),
				/obj/item/clothing/gloves/tackler/combat/insulated = list(200, 3, INFINITY),
				/obj/item/storage/belt/military/assault/ert = list(100, 3, INFINITY),
				/obj/item/storage/backpack/etamin_ind = list(100, 3, INFINITY),
				/obj/item/storage/backpack/ert/extra_large = list(150, 3, INFINITY),
				/obj/item/clothing/mask/gas/syndicate = list(250, 4, INFINITY),
				/obj/item/clothing/mask/gas/sechailer/swat = list(250, 4, INFINITY),
				/obj/item/clothing/mask/gas/hunter = list(250, 4, INFINITY),
				/obj/item/clothing/accessory/holster/tacticool = list(300, 4, INFINITY),
				/obj/item/clothing/glasses/hud/security/sunglasses = list(200, 4, INFINITY),
				/obj/item/clothing/glasses/thermal/eyepatch = list(1000, 4, INFINITY),
				/obj/item/storage/backpack/holding = list(750, 4, INFINITY),
				/obj/item/clothing/head/helmet/alt = list(250, 4, INFINITY),
				/obj/item/clothing/head/helmet/toggleable/riot/ussp_heavy = list(350, 4, INFINITY),
				/obj/item/clothing/suit/armor/bulletproof = list(400, 4, INFINITY),
				/obj/item/clothing/suit/armor/swat/ussp_heavy = list(500, 4, INFINITY),
			),
		),
	)

/obj/machinery/vending/trader/fashion/add_tts_component()
	AddComponent(/datum/component/tts_component, /datum/tts_seed/silero/bandit3)

/obj/machinery/vending/trader/fashion/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/tts_component,  /datum/tts_seed/silero/bandit3)

/obj/machinery/vending/trader/fashion/examine(mob/user)
	. = ..()
	. += "<b>ПОКУПАЕТ:</b> Различную одежду и аксессуары."

/obj/machinery/vending/trader/survivor
	name = "\improper Trade Point - Выживайло"
	desc = "Торговая точка блюспейс-передачи, принадлежащая бывшему охраннику заповедника - Выживайло."
	icon = 'modular_bandastation/objects/icons/obj/machines/vending.dmi'
	icon_state = "nta"
	product_ads = "Если хочешь стать охотником, а не добычей - присмотрись к моим товарам.;Мои товары помогут тебе не откинуть копыта.;Бжж-Бзз-з!;Ружья, порох, припасы - здесь ты найдёшь всё для настоящего охотника.;Не стесняйся брать то, что поможет тебе выжить."
	vend_reply = "Удачной охоты, наёмник."
	onstation = FALSE
	all_products_free = FALSE

	trader_id = TRADER_SURVIVOR
	trader_name = "Выживайло"
	trader_desc = "Бывший шеф полиции Нового-Сиднея, после громкого скандала с местным криминалитетом - ставший смотрителем окружного заповедника. Ходят слухи, что бывшие мафиози до сих пор точат на него зуб, поскольку Выживайло даже на новом месте работы - не прекращал на них свою неформальную охоту. Но кто знает - может в этом он преследует не только благие цели. Обосновался в особняке в горах заповедника и превратил его в настоящую крепость, оборудовав небольшой склад различных припасов для выживания."
	trader_portrait = 'modular_bandastation/voyaker_events/icons/traders/survivor.png'
	trader_message = "Подходи, гость дорогой. Чаем угостить не смогу, извиняй, но вот работу подкинуть, или полезности для выживания предложить - всегда рад.;Долбанные братки виноваты в том, что случилось - зуб даю. Пока мы всех их не вытравим из Сиднея - не будет нам покоя.;Вижу, что до сих пор стоишь на ногах. Это хорошо. Значит не сгинешь раньше времени.;Запомни, настоящий охотник - не только тот, кто силён - но и тот, кто вовремя хитёр.;Бери у меня товары на все случаи жизни. Кто знает, когда они тебе пригодятся в ходке.;Не могу понять - на что Фейшн и эта рыжая дура расчитывают? Облопошить всех во время ядерного апокалипсиса? Ну ничего... Я им устрою сладкую жизнь. Ядерный пепел им солярием покажется, уродам."

	quest_chain = list(
		/datum/trader_quest/survivor_can,
		/datum/trader_quest/survivor_trust,
		/datum/trader_quest/survivor_shooter,
		/datum/trader_quest/survivor_mine,
		/datum/trader_quest/survivor_contact,
	)

	buy_prices = list(
		/obj/item/loot_mobs/bigot_claw = 400,
		/obj/item/loot_mobs/fleshspider_tongue = 150,
		/obj/item/loot_mobs/hunterspider_claw = 100,
		/obj/item/loot_mobs/faithless_heart = 150,
		/obj/item/loot_mobs/hyperzombie_gland = 225,
		/obj/item/stack/cable_coil = 5,
		/obj/item/assembly/igniter = 10,
		/obj/item/stock_parts/capacitor = 10,
		/obj/item/stock_parts/scanning_module = 10,
		/obj/item/stock_parts/servo = 10,
		/obj/item/stock_parts/subspace/ansible = 50,
		/obj/item/stock_parts/subspace/filter = 50,
		/obj/item/stock_parts/subspace/amplifier = 50,
		/obj/item/stock_parts/subspace/analyzer = 50,
		/obj/item/stock_parts/subspace/crystal = 100,
		/obj/item/stock_parts/card_reader = 100,
		/obj/item/stock_parts/water_recycler = 100,
		/obj/item/weaponcrafting/receiver = 50,
		/obj/item/assembly/signaler = 50,
		/obj/item/analyzer = 25,
		/obj/item/crafting_items/gunpowder = 10,
		/obj/item/crafting_items/gunpowder/medium = 30,
		/obj/item/crafting_items/gunpowder/high = 50,
		/obj/item/screwdriver = 15,
		/obj/item/weldingtool = 15,
		/obj/item/wirecutters = 15,
		/obj/item/artifact/fire_wing = 500,
		/obj/item/artifact/ice_crystal = 800,
		/obj/item/artifact/stone_eye = 700,
	)

	product_categories = list(
		list(
			"name" = "Weapon",
			"icon" = "gun",
			"products" = list(
				/obj/item/gun/ballistic/rifle/boltaction = list(150, 1, INFINITY),
				/obj/item/gun/ballistic/shotgun/riot = list(125, 1, INFINITY),
				/obj/item/knife/combat/survival = list(50, 1, INFINITY),
				/obj/item/gun/ballistic/rifle/boltaction/army/tactical/surplus = list(225, 2, INFINITY),
				/obj/item/gun/ballistic/automatic/carwo/marksman/wooden = list(300, 2, INFINITY),
				/obj/item/knife/combat = list(75, 2, INFINITY),
				/obj/item/spess_knife = list(75, 2, INFINITY),
				/obj/item/suppressor = list(100, 2, INFINITY),
				/obj/item/gun/ballistic/shotgun/automatic/combat = list(500, 3, INFINITY),
				/obj/item/fireaxe = list(220, 3, INFINITY),
				/obj/item/gun/ballistic/automatic/pistol/deagle = list(400, 4, INFINITY),
			),
	  	),

		list(
			"name" = "Ammo & Grenades",
			"icon" = "box",
			"products" = list(
				/obj/item/ammo_box/speedloader/strilka310 = list(10, 1, INFINITY),
				/obj/item/ammo_box/magazine/c40sol_rifle = list(20, 1, INFINITY),
				/obj/item/storage/box/lethalshot = list(15, 1, INFINITY),
				/obj/item/ammo_box/magazine/m50 = list(75, 4, INFINITY),
				/obj/item/ammo_box/c12ga/slug = list(100, 4, INFINITY),
			),
		),

		list(
			"name" = "Equipment",
			"icon" = "hand-fist",
			"products" = list(
				/obj/item/lighter/greyscale = list(20, 1, INFINITY),
				/obj/item/storage/box/matches = list(15, 1, INFINITY),
				/obj/item/flashlight = list(30, 1, INFINITY),
				/obj/item/storage/medkit/emergency = list(100, 1, INFINITY),
				/obj/item/stack/medical/mesh = list(30, 1, INFINITY),
				/obj/item/food/canned/beans = list(30, 1, INFINITY),
				/obj/item/radio/off = list(75, 1, INFINITY),
				/obj/item/clothing/gloves/bracer = list(50, 1, INFINITY),
				/obj/item/hatchet = list(50, 1, INFINITY),
				/obj/item/stack/medical/wrap/sticky_tape = list(15, 1, INFINITY),
				/obj/item/stack/sheet/iron = list(10, 2, INFINITY),
				/obj/item/stack/sheet/mineral/wood = list(5, 2, INFINITY),
				/obj/item/stack/sheet/glass = list(10, 2, INFINITY),
				/obj/item/flashlight/seclite = list(50, 2, INFINITY),
				/obj/item/geiger_counter = list(175, 2, INFINITY),
				/obj/item/reagent_containers/hypospray/medipen/survival = list(100, 2, INFINITY),
				/obj/item/storage/toolbox/emergency = list(150, 2, INFINITY),
				/obj/item/stack/medical/wrap/sticky_tape/super = list(75, 2, INFINITY),
				/obj/item/extinguisher/mini = list(80, 2, INFINITY),
				/obj/item/binoculars = list(200, 2, INFINITY),
				/obj/item/grenade/barrier = list(100, 2, INFINITY),
				/obj/item/clothing/gloves/color/yellow = list(100, 2, INFINITY),
				/obj/item/food/rationpack = list(50, 2, INFINITY),
				/obj/item/clothing/head/utility/welding = list(80, 2, INFINITY),
				/obj/item/multitool = list(100, 2, INFINITY),
				/obj/item/clothing/head/utility/radiation = list(150, 3, INFINITY),
				/obj/item/clothing/suit/utility/radiation = list(350, 3, INFINITY),
				/obj/item/clothing/mask/gas/welding = list(200, 3, INFINITY),
				/obj/item/tank/internals/oxygen = list(100, 3, INFINITY),
				/obj/item/clothing/glasses/hud/security/night = list(250, 3, INFINITY),
				/obj/item/clothing/shoes/bhop = list(300, 3, INFINITY),
				/obj/item/clothing/glasses/hud/toggle/thermal = list(800, 4, INFINITY),
				/obj/item/clothing/suit/hooded/stealth_cloak = list(1500, 4, INFINITY),
				/obj/item/clothing/gloves/kaza_ruk/combatglovesplus = list(750, 4, INFINITY),
				/obj/item/crowbar/power/paramedic = list(500, 4, INFINITY),
			),
		),
	)

/obj/machinery/vending/trader/survivor/add_tts_component()
	AddComponent(/datum/component/tts_component, /datum/tts_seed/silero/brimstone)

/obj/machinery/vending/trader/survivor/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/tts_component,  /datum/tts_seed/silero/brimstone)

/obj/machinery/vending/trader/survivor/examine(mob/user)
	. = ..()
	. += "<b>ПОКУПАЕТ:</b> Части мутантов, артефакты, инструменты и детали."

/obj/machinery/vending/trader/robinson
	name = "\improper Trade Point - Полковник Робинсон"
	desc = "Торговая точка блюспейс-передачи, принадлежащая кадровому военному ТСФ - Полковнику Робинсону."
	icon = 'modular_bandastation/objects/icons/obj/machines/vending.dmi'
	icon_state = "nta"
	product_ads = "Все отступники - получат заслуженную кару.;Оплот человечества выстоит под натиском любой угрозы.;Бжж-Бзз-з!;Всё оружие великой Транс-Солнечной Федерации - ты найдёшь здесь, салага.;Наше государство - едино, воля - непоколебима, а Солнце - всегда будет сиять ярко."
	vend_reply = "Удачи тебе, боец."
	onstation = FALSE
	all_products_free = FALSE

	trader_id = TRADER_ROBINSON
	trader_name = "Полковник Робинсон"
	trader_desc = "Командир 607-го полка Сил Планетарной Обороны войск ТСФ на планете Прометея, сектор Тау-Кита. Во время масштабной высадки войск СССП на планету - его полку было поручено занять линию обороны на периферии атомной электростанции Сидней Нова. В результате прорыва - разрозненным группам пехотинцев пришлось отступить, сам Робинсон - смог эвакуироваться по неизвестному стечению обстоятельств на борт флагманского корабля миротворческих сил - Видение. Оттуда он продолжает командовать оставшимися группами и вести неформальные контакты с наемниками для того, чтобы прояснить ситуацию произошедшего."
	trader_portrait = 'modular_bandastation/voyaker_events/icons/traders/robinson.png'
	trader_message = "Ищешь нормальное оружие и экипировку, боец? Можешь посмотреть мой ассортимент. Он тебя точно не обидит.;Коммунисты применили против нас свои самые грязные методы. Что же - мы не оставим их в долгу.;Много моих бойцов отдало жизни за Прометею. Многие меня заклеймили трусом за то, что я их бросил.... Но ничего. Битва ещё не проиграна.;Мне не важно, на кого ты работал до этого, наёмник. Сейчас у нас с тобой общие цели и задачи - помочь выбраться отсюда тебе и всем моим бойцам.;Я договорился об орбитальных поставках из штаба нашего новейшего вооружения. Присматривай себе всё, что будет необходимо.;Красные думали, что смогли одолеть нас ядерным взрывом на планете? Это только начало конца их преступной и утопичной идеи. И мы с тобой сможем это доказать."

	quest_chain = list(
		/datum/trader_quest/robinson_scout,
		/datum/trader_quest/robinson_trucks,
		/datum/trader_quest/robinson_guns,
		/datum/trader_quest/robinson_documents,
		/datum/trader_quest/robinson_provocation,
	)

	buy_prices = list(
		/obj/item/clothing/mask/bandana/gold = 50,
		/obj/item/stack/sheet/mineral/gold = 100,
		/obj/item/bikehorn/golden = 50,
		/obj/item/instrument/violin/golden = 300,
		/obj/item/clothing/accessory/anti_sec_pin = 75,
		/obj/item/clothing/accessory/deaf_pin = 75,
		/obj/item/clothing/accessory/debt_payer_pin = 75,
		/obj/item/clothing/accessory/kheiral_cuffs = 400,
		/obj/item/clothing/accessory/gloves_accessory/ring/silver = 150,
		/obj/item/clothing/accessory/gloves_accessory/ring = 300,
		/obj/item/clothing/accessory/gloves_accessory/ring/diamond = 500,
		/obj/item/reagent_containers/cup/glass/mug/britcup = 75,
		/obj/item/storage/belt/champion = 300,
		/obj/item/clothing/neck/necklace/dope = 300,
		/obj/item/documents = 200,
		/obj/item/documents/nanotrasen = 450,
		/obj/item/documents/syndicate = 500,
		/obj/item/documents/syndicate/red = 700,
		/obj/item/documents/syndicate/blue = 1000,
		/obj/item/disk/holodisk = 150,
		/obj/item/disk/holodisk/donutstation/whiteship = 300,
		/obj/item/disk/holodisk/ruin/cyborg_mothership = 500,
		/obj/item/disk/holodisk/ruin/waystation = 750,
		/obj/item/disk/computer = 100,
		/obj/item/disk/computer/super = 200,
		/obj/item/disk/computer/command = 300,
		/obj/item/disk/computer/hdd_theft = 300,
		/obj/item/disk/computer/syndie_ai_upgrade = 450,
		/obj/item/keycard/nt_labs = 350,
	)

	product_categories = list(
		list(
			"name" = "Weapon",
			"icon" = "gun",
			"products" = list(
				/obj/item/gun/ballistic/automatic/pistol/wespe = list(75, 1, INFINITY),
				/obj/item/gun/ballistic/automatic/carwo = list(175, 1, INFINITY),
				/obj/item/gun/ballistic/automatic/pistol/m1911 = list(150, 2, INFINITY),
				/obj/item/gun/ballistic/shotgun/riot/renoster/sawoff = list(200, 2, INFINITY),
				/obj/item/gun/ballistic/automatic/carwo/auto = list(250, 2, INFINITY),
				/obj/item/gun/ballistic/automatic/sindano = list(200, 2, INFINITY),
				/obj/item/gun/ballistic/automatic/carwo/marksman = list(400, 3, INFINITY),
				/obj/item/gun/ballistic/automatic/sindano/compact/suppressed = list(300, 3, INFINITY),
				/obj/item/gun/ballistic/automatic/vektor = list(275, 3, INFINITY),
				/obj/item/gun/ballistic/shotgun/riot/renoster = list(350, 3, INFINITY),
				/obj/item/gun/ballistic/automatic/carwo/auto/machinegun = list(650, 4, INFINITY),
				/obj/item/gun/ballistic/automatic/bogseo/suppressed = list(600, 4, INFINITY),
			),
	  	),

		list(
			"name" = "Ammo & Grenades",
			"icon" = "box",
			"products" = list(
				/obj/item/ammo_box/magazine/c35sol_pistol = list(10, 1, INFINITY),
				/obj/item/ammo_box/magazine/c40sol_rifle = list(15, 1, INFINITY),
				/obj/item/grenade/smokebomb = list(75, 2, INFINITY),
				/obj/item/storage/box/lethalshot = list(20, 2, INFINITY),
				/obj/item/ammo_box/magazine/m45 = list(25, 2, INFINITY),
				/obj/item/ammo_box/magazine/c40sol_rifle/standard = list(20, 2, INFINITY),
				/obj/item/ammo_box/magazine/c35sol_pistol/stendo = list(15, 2, INFINITY),
				/obj/item/ammo_box/magazine/c35sol_pistol/hp = list(15, 2, INFINITY),
				/obj/item/ammo_box/magazine/c35sol_pistol/drum = list(25, 3, INFINITY),
				/obj/item/ammo_box/magazine/c35sol_pistol/drum/hp = list(30, 3, INFINITY),
				/obj/item/ammo_box/magazine/smgm9mm = list(20, 3, INFINITY),
				/obj/item/ammo_box/magazine/c35sol_pistol/stendo/hp = list(20, 3, INFINITY),
				/obj/item/ammo_box/magazine/c40sol_rifle/long = list(40, 3, INFINITY),
				/obj/item/ammo_box/magazine/c35sol_pistol/drum/ap = list(75, 4, INFINITY),
				/obj/item/ammo_box/magazine/c40sol_rifle/drum = list(80, 4, INFINITY),
				/obj/item/ammo_box/magazine/c35sol_pistol/ap = list(40, 4, INFINITY),
				/obj/item/ammo_box/magazine/c35sol_pistol/stendo/ap = list(50, 4, INFINITY),
				/obj/item/ammo_box/magazine/smgm9mm/ap = list(60, 4, INFINITY),
				/obj/item/ammo_box/magazine/c40sol_rifle/box = list(150, 4, INFINITY),
				/obj/item/ammo_box/magazine/c40sol_rifle/long/incendiary = list(150, 4, INFINITY),
				/obj/item/ammo_box/magazine/c585sol/extended = list(60, 4, INFINITY),
			),
		),

		list(
			"name" = "Equipment",
			"icon" = "hand-fist",
			"products" = list(
				/obj/item/clothing/under/rank/tsf/marine = list(10, 1, INFINITY),
				/obj/item/storage/backpack/tsf = list(30, 1, INFINITY),
				/obj/item/clothing/head/beret/tsf_marine = list(15, 1, INFINITY),
				/obj/item/radio/headset/heads/captain/alt/tsf = list(25, 1, INFINITY),
				/obj/item/clothing/shoes/jackboots = list(20, 1, INFINITY),
				/obj/item/beacon = list(75, 1, INFINITY),
				/obj/item/clothing/mask/gas/sechailer = list(100, 2, INFINITY),
				/obj/item/clothing/glasses/hud/security/sunglasses/tsf = list(250, 2, INFINITY),
				/obj/item/clothing/suit/armor/vest/marine/security = list(350, 3, INFINITY),
				/obj/item/clothing/head/helmet/marine/security = list(175, 3, INFINITY),
				/obj/item/clothing/glasses/meson/night = list(300, 3, INFINITY),
				/obj/item/clothing/mask/breath/breathscarf/tsf_infiltrator = list(300, 4, INFINITY),
			),
		),
	)

/obj/machinery/vending/trader/robinson/add_tts_component()
	AddComponent(/datum/component/tts_component, /datum/tts_seed/silero/cyberpunk_victor)

/obj/machinery/vending/trader/robinson/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/tts_component, /datum/tts_seed/silero/cyberpunk_victor)

/obj/machinery/vending/trader/robinson/examine(mob/user)
	. = ..()
	. += "<b>ПОКУПАЕТ:</b> Драгоценности и информационные предметы - бумаги, датадиски и похожее."

/obj/machinery/vending/trader/keksuha
	name = "\improper Trade Point - Камилла"
	desc = "Торговая точка блюспейс-передачи, принадлежащая роковой контрабандистке - Камилле."
	icon = 'modular_bandastation/objects/icons/obj/machines/vending.dmi'
	icon_state = "nta"
	product_ads = "Здесь ты найдёшь оружие на любой вкус и цвет, солнышко.;Забей на проблемы. Их всегда можно решить с помощью этих стволов.;Бжж-Бзз-з!;Другие - продают фуфло. У меня ты найдёшь только самое лучшее.;Лучшие контрабандные шпалеры со всей Галактики."
	vend_reply = "Ну бывай, красавчик."
	onstation = FALSE
	all_products_free = FALSE

	trader_id = TRADER_KAMILLA
	trader_name = "Камилла"
	trader_desc = "Молодая девушка бунтарского поведения, дочь главы мафиозного клана Ренотти, любительница цитат из кинофильмов - именно так можно охарактеризовать Камиллу - одну из самых коварных и влиятельных контрабандисток в Галактике. По иронии судьбы, свою дурную репутацию она смогла приобрести после кончины горячо любимого отца, который незадолго до катастрофы на Прометее - был убит киллерами при выезде из своего ресторана. Камилла считает, что заказчиком является Фейшн - её давний заклятый враг по старому бизнесу. Теперь же, возглавив небольшую группу своих теневых посредников, она осталась на Тау-Кита с одной единственной целью - отомстить предполагаемому убийце и ненадолго, но вернуть влияние семьи Ренотти на уже умирающую планету."
	trader_portrait = 'modular_bandastation/voyaker_events/icons/traders/kamilla.gif'
	trader_message = "Ну привет, мерк. Ты так и будешь глазеть на меня, или уже что-то купишь? А можешь продать мне свои стволы, если они конечно у тебя не рассыпятся в руках.;У меня, как у Виктора Бута из Оружейного барона - ты найдёшь любой ствол по душе и стилю. Впрочем, чужие пушки тоже покупаю, если они не фуфло. Но ты же не фуфлыжник, прадва?;Добрался сюда, да ещё живой? Ты прям как Форест Гамп - бежишь без оглядки, не зная куда. Но раз ты здесь - можем поговорить о делах.;Ты как Роберт Невилл из Я - Легенда - пытаешься цепляться за возможность выжить тут и найти пути к тому, чтобы отсюда выбраться. Но запомни - только я тебе дам билет отсюда.;Этот Фейшн - такой слащавый мудачок. Думает, что если смог выкинуть мои терминалы на пустоши - значит смог урыть меня. Как жаль, что он не знает про мои тузы в рукавах.;Не спрашивай, откуда я достала все эти пушки. Я как Волк с Уолл-стрит - надёжно храню свои предпринимательские секреты."

	quest_chain = list(
		/datum/trader_quest/keksuha_faithless,
		/datum/trader_quest/keksuha_donate,
		/datum/trader_quest/keksuha_massacre,
		/datum/trader_quest/keksuha_explosive,
		/datum/trader_quest/keksuha_western,
	)

	buy_prices = list(
		/obj/item/gun/ballistic/automatic/pistol/zashch = 75,
		/obj/item/gun/ballistic/revolver/dvoystvol/low_caliber = 225,
		/obj/item/gun/ballistic/automatic/pistol/clandestine/fisher = 150,
		/obj/item/gun/ballistic/revolver/dvoystvol = 225,
		/obj/item/gun/ballistic/automatic/pistol/m1911 = 75,
		/obj/item/gun/ballistic/automatic/pistol/clandestine = 37,
		/obj/item/gun/ballistic/automatic/bison = 125,
		/obj/item/gun/ballistic/automatic/sabel/auto/army/alt = 200,
		/obj/item/gun/ballistic/automatic/sabel/auto/modern = 225,
		/obj/item/gun/ballistic/automatic/lanca = 250,
		/obj/item/gun/ballistic/shotgun/automatic/combat = 250,
		/obj/item/gun/ballistic/automatic/carwo = 90,
		/obj/item/gun/ballistic/shotgun/riot/renoster/sawoff = 100,
		/obj/item/gun/ballistic/automatic/carwo/auto = 125,
		/obj/item/gun/ballistic/automatic/sindano = 100,
		/obj/item/gun/ballistic/automatic/carwo/marksman = 200,
		/obj/item/gun/ballistic/automatic/carwo/auto/black = 100,
		/obj/item/gun/ballistic/automatic/pistol/tp14 = 50,
		/obj/item/gun/ballistic/automatic/pistol/aps = 60,
		/obj/item/gun/ballistic/rifle/krov = 110,
		/obj/item/gun/ballistic/automatic/c20r/unrestricted = 125,
		/obj/item/gun/ballistic/automatic/fn18 = 125,
		/obj/item/gun/ballistic/automatic/fn4 = 200,
		/obj/item/gun/ballistic/automatic/as32 = 200,
		/obj/item/gun/ballistic/shotgun/riot/renoster/black = 175,
		/obj/item/gun/ballistic/automatic/sindano/black = 175,
		/obj/item/gun/ballistic/automatic/sabel/auto/upgraded = 210,
		/obj/item/gun/ballistic/rifle/hlrm = 275,
		/obj/item/gun/ballistic/revolver/badass = 200,
		/obj/item/gun/ballistic/automatic/m90 = 260,
		/obj/item/gun/ballistic/automatic/smartgun = 350,
		/obj/item/gun/ballistic/automatic/sabel/auto/gauss = 300,
		/obj/item/gun/ballistic/shotgun/bulldog/unrestricted = 300,
		/obj/item/gun/ballistic/rifle/sniper_rifle = 450,
		/obj/item/disk/computer/black_market = 500,
		/obj/item/disk/computer/virus = 500,
	)

	product_categories = list(
		list(
			"name" = "Weapon",
			"icon" = "gun",
			"products" = list(
				/obj/item/gun/ballistic/automatic/pistol/clandestine = list(75, 1, INFINITY),
				/obj/item/gun/ballistic/rifle/boltaction/tactical = list(125, 1, INFINITY),
				/obj/item/gun/ballistic/automatic/mini_uzi = list(100, 1, INFINITY),
				/obj/item/gun/ballistic/automatic/carwo/auto/wooden = list(175, 1, INFINITY),
				/obj/item/gun/ballistic/automatic/carwo/auto/black/suppressed = list(200, 2, INFINITY),
				/obj/item/gun/ballistic/automatic/pistol/tp14 = list(100, 2, INFINITY),
				/obj/item/gun/ballistic/automatic/pistol/aps = list(125, 2, INFINITY),
				/obj/item/gun/ballistic/rifle/krov = list(225, 2, INFINITY),
				/obj/item/gun/ballistic/automatic/c20r/unrestricted = list(250, 2, INFINITY),
				/obj/item/gun/ballistic/automatic/fn18 = list(250, 2, INFINITY),
				/obj/item/gun/ballistic/automatic/fn4 = list(400, 3, INFINITY),
				/obj/item/gun/ballistic/automatic/as32 = list(400, 3, INFINITY),
				/obj/item/gun/ballistic/shotgun/riot/renoster/black = list(375, 3, INFINITY),
				/obj/item/gun/ballistic/automatic/sindano/black/suppressed = list(375, 3, INFINITY),
				/obj/item/gun/ballistic/automatic/vektor/black = list(300, 3, INFINITY),
				/obj/item/gun/ballistic/automatic/sabel/auto/upgraded = list(425, 3, INFINITY),
				/obj/item/gun/ballistic/rifle/hlrm = list(550, 3, INFINITY),
				/obj/item/gun/ballistic/revolver/badass = list(400, 4, INFINITY),
				/obj/item/gun/ballistic/automatic/m90 = list(525, 4, INFINITY),
				/obj/item/gun/ballistic/automatic/smartgun = list(700, 4, INFINITY),
				/obj/item/gun/ballistic/automatic/sabel/auto/gauss = list(600, 4, INFINITY),
				/obj/item/gun/ballistic/shotgun/bulldog/unrestricted = list(600, 4, INFINITY),
				/obj/item/gun/ballistic/rifle/sniper_rifle = list(900, 4, INFINITY),
			),
	  	),

		list(
			"name" = "Ammo & Grenades",
			"icon" = "box",
			"products" = list(
				/obj/item/ammo_box/magazine/uzim9mm = list(10, 1, INFINITY),
				/obj/item/ammo_box/magazine/m10mm = list(10, 1, INFINITY),
				/obj/item/ammo_box/magazine/c40sol_rifle/standard = list(15, 1, INFINITY),
				/obj/item/ammo_box/magazine/strilka310 = list(15, 1, INFINITY),
				/obj/item/ammo_box/magazine/c45 = list(15, 2, INFINITY),
				/obj/item/ammo_box/magazine/smgm45 = list(20, 2, INFINITY),
				/obj/item/ammo_box/magazine/fn18 = list(20, 2, INFINITY),
				/obj/item/ammo_box/magazine/m9mm_aps = list(15, 2, INFINITY),
				/obj/item/ammo_box/magazine/c762x39mm = list(25, 3, INFINITY),
				/obj/item/ammo_box/magazine/c762x51mm = list(35, 3, INFINITY),
				/obj/item/ammo_box/magazine/smgm9mm = list(15, 3, INFINITY),
				/obj/item/ammo_box/magazine/as32 = list(30, 3, INFINITY),
				/obj/item/ammo_box/magazine/c35sol_pistol/drum = list(20, 3, INFINITY),
				/obj/item/ammo_box/magazine/c35sol_pistol/drum/hp = list(25, 3, INFINITY),
				/obj/item/ammo_box/magazine/c35sol_pistol/drum/ap = list(50, 3, INFINITY),
				/obj/item/ammo_box/magazine/c338 = list(60, 3, INFINITY),
				/obj/item/ammo_box/speedloader/c357/match = list(50, 4, INFINITY),
				/obj/item/ammo_box/speedloader/c357/phasic = list(90, 4, INFINITY),
				/obj/item/ammo_box/speedloader/c357/heartseeker = list(75, 4, INFINITY),
				/obj/item/ammo_box/magazine/c762x39mm/ap = list(125, 4, INFINITY),
				/obj/item/ammo_box/magazine/m223 = list(40, 4, INFINITY),
				/obj/item/ammo_box/magazine/m223/phasic = list(80, 4, INFINITY),
				/obj/item/ammo_box/magazine/smartgun = list(90, 4, INFINITY),
				/obj/item/ammo_box/magazine/m12g = list(50, 4, INFINITY),
				/obj/item/ammo_box/magazine/m12g/dragon = list(80, 4, INFINITY),
				/obj/item/ammo_box/magazine/m12g/flechette = list(75, 4, INFINITY),
				/obj/item/ammo_box/magazine/m12g/slug = list(125, 4, INFINITY),
				/obj/item/ammo_box/magazine/sniper_rounds = list(200, 4, INFINITY),
				/obj/item/ammo_box/magazine/smgm9mm/ap = list(60, 4, INFINITY),
			),
		),
	)

/obj/machinery/vending/trader/keksuha/add_tts_component()
	AddComponent(/datum/component/tts_component, /datum/tts_seed/silero/xenia)

/obj/machinery/vending/trader/keksuha/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/tts_component,  /datum/tts_seed/silero/xenia)

/obj/machinery/vending/trader/keksuha/examine(mob/user)
	. = ..()
	. += "<b>ПОКУПАЕТ:</b> Оружие качественного и армейского образца и патроны, запрещённый информационный софт."

/obj/machinery/vending/trader/visitor
	name = "\improper Trade Point - Визитёр"
	desc = "Торговая точка блюспейс-передачи, принадлежащая дипломатическому представителю от НТ - Визитёру."
	icon = 'modular_bandastation/objects/icons/obj/machines/vending.dmi'
	icon_state = "nta"
	product_ads = "Здесь собрано только лучшее вооружение компании.;Думаю, ты найдёшь достойное применение этому ассортименту.;Бжж-Бзз-з!;Продажа вооружения корпорации осуществляется исключительно в миротворческих целях."
	vend_reply = "Приятно иметь с тобой дело. Слава Компании."
	onstation = FALSE
	all_products_free = FALSE
	trader_id = TRADER_VISITOR
	trader_name = "Визитёр"
	trader_desc = "Официально - является представителем дипломатической миссии НаноТрейзен в секторе Тау-Кита, осуществляя контакты с выжившими на планете с целью поиска путей для их дальнейшей эвакуации в условиях орбитальной блокады. Неофициально - по некоторым неподтвержденным данным - пытается заручиться поддержкой наёмников для расследования причин катастрофы. Как любой уважающий себя корпорат - Визитёр не станет довольствоваться только небольшими единицами информации о происходящем на планете - ему нужно видеть цельную картину. Поэтому и доверенных лиц - он отбирает со строгостью и свойственным профессионализмом, что реже замечается у остальных представителей бизнеса на Пустошах. На данный момент, он, как и его команда аналитиков и некоторых представители разведки корпорации - находятся на борту миротворческого судна Видение."
	trader_portrait = 'modular_bandastation/voyaker_events/icons/traders/visitor.png'
	trader_message = "Приветствую, наёмник. У меня не так много времени. Говори коротко и по делу.;Корпорация не желает нажиться на возникшем кризисе, возместив убытки за утрату своих объектов на Прометее. Сейчас информация о произошедшем здесь - гораздо более ценный ресурс, у которого есть разное направление применений. Поэтому реализацию продажи вооружения - можешь воспринимать как стимул к этому, наёмник.;Я смогу предпринять шаги по вашей эвакуации отсюда только после того, как получу на руки необходимые сведения. Думаю, что это справедливый и равноценный обмен.;Нам обоим приходилось принимать сложные решения и нести ответственность за них, наёмник. Думаю, что у вас сейчас есть возможность исправить последствия некоторых из них, если будете сотрудничать со мной.;У меня довольно плотный график, чтобы занимать его разговорами не по существу, наёмник. Расспрашивать о делах, не связанных с возможным раскрытием причин катастрофы - вы вполне можете и других торговцев.;Особые образцы вооружения отпускаются на руки только доверенным лицам, которые раздобыли для нас полезную информацию. Поэтому, если хотите открыть доступ к ним - придётся оказать нам помощь в этой деятельности."

	quest_chain = list(
		/datum/trader_quest/visitor_detective,
		/datum/trader_quest/visitor_breeze,
		/datum/trader_quest/visitor_pandora,
		/datum/trader_quest/visitor_chess,
		/datum/trader_quest/visitor_picture,
	)

	buy_prices = list(
		/obj/item/documents = 250,
		/obj/item/documents/nanotrasen = 540,
		/obj/item/documents/syndicate = 600,
		/obj/item/documents/syndicate/red = 840,
		/obj/item/documents/syndicate/blue = 1200,
		/obj/item/disk/holodisk = 180,
		/obj/item/disk/holodisk/donutstation/whiteship = 360,
		/obj/item/disk/holodisk/ruin/cyborg_mothership = 600,
		/obj/item/disk/holodisk/ruin/waystation = 900,
		/obj/item/disk/computer = 120,
		/obj/item/disk/computer/super = 240,
		/obj/item/disk/computer/command = 360,
		/obj/item/disk/computer/hdd_theft = 360,
		/obj/item/disk/computer/syndie_ai_upgrade = 540,
		/obj/item/artifact/fire_wing = 700,
		/obj/item/artifact/ice_crystal = 960,
		/obj/item/artifact/stone_eye = 840,
		/obj/item/keycard/nt_labs = 500,
	)

	product_categories = list(
		list(
			"name" = "Weapon",
			"icon" = "gun",
			"products" = list(
				/obj/item/switchblade =  list(50, 1, INFINITY),
				/obj/item/gun/ballistic/automatic/pistol/gp9 = list(80, 1, INFINITY),
				/obj/item/gun/ballistic/revolver/c38 = list(110, 1, INFINITY),
				/obj/item/gun/ballistic/automatic/wt550 = list(150, 1, INFINITY),
				/obj/item/gun/ballistic/automatic/pistol/cm70 = list(125, 2, INFINITY),
				/obj/item/gun/ballistic/automatic/pistol/cm23 = list(130, 2, INFINITY),
				/obj/item/gun/ballistic/automatic/cm5 = list(225, 2, INFINITY),
				/obj/item/gun/ballistic/automatic/battle_rifle = list(375, 2, INFINITY),
				/obj/item/gun/ballistic/automatic/pistol/gp9/spec = list(175, 3, INFINITY),
				/obj/item/gun/ballistic/automatic/cm5/compact = list(300, 3, INFINITY),
				/obj/item/gun/ballistic/automatic/cm82 = list(600, 3, INFINITY),
				/obj/item/gun/ballistic/automatic/cm15 = list(565, 3, INFINITY),
				/obj/item/gun/ballistic/automatic/f4 = list(700, 4, INFINITY),
				/obj/item/gun/ballistic/automatic/f90 = list(850, 4, INFINITY),
				/obj/item/gun/ballistic/automatic/pistol/cm357 = list(400, 4, INFINITY),
			),
	  	),

		list(
			"name" = "Ammo & Grenades",
			"icon" = "box",
			"products" = list(
				/obj/item/ammo_box/magazine/c9x25mm_pistol = list(10, 1, INFINITY),
				/obj/item/ammo_box/speedloader/c38 = list(15, 1, INFINITY),
				/obj/item/ammo_box/magazine/wt550m9 = list(30, 1, INFINITY),
				/obj/item/grenade/flashbang = list(200, 2, INFINITY),
				/obj/item/ammo_box/magazine/c38 = list(30, 2, INFINITY),
				/obj/item/ammo_box/magazine/c45 = list(30, 2, INFINITY),
				/obj/item/ammo_box/magazine/cm5 = list(35, 2, INFINITY),
				/obj/item/ammo_box/magazine/m38 = list(40, 2, INFINITY),
				/obj/item/ammo_box/magazine/c9x25mm_pistol/hp = list(20, 2, INFINITY),
				/obj/item/ammo_box/magazine/c9x25mm_pistol/stendo = list(25, 2, INFINITY),
				/obj/item/ammo_box/magazine/c9x25mm_pistol/stendo/hp = list(35, 2, INFINITY),
				/obj/item/ammo_box/magazine/wt550m9/wtap = list(70, 3, INFINITY),
				/obj/item/ammo_box/magazine/cm5/hp = list(40, 3, INFINITY),
				/obj/item/ammo_box/magazine/c38/hp = list(40, 3, INFINITY),
				/obj/item/ammo_box/magazine/c38/match = list(50, 3, INFINITY),
				/obj/item/ammo_box/magazine/c9x25mm_pistol/stendo/ap = list(90, 3, INFINITY),
				/obj/item/ammo_box/magazine/cm15 = list(60, 3, INFINITY),
				/obj/item/ammo_box/magazine/c223 = list(70, 3, INFINITY),
				/obj/item/ammo_box/magazine/c45/hp = list(40, 3, INFINITY),
				/obj/item/grenade/c4/x4 = list(750, 4, INFINITY),
				/obj/item/ammo_box/magazine/c762x51mm = list(80, 4, INFINITY),
				/obj/item/ammo_box/magazine/c338 = list(110, 4, INFINITY),
				/obj/item/ammo_box/magazine/c357 = list(90, 4, INFINITY),
				/obj/item/ammo_box/magazine/cm5/ap = list(100, 4, INFINITY),
				/obj/item/ammo_box/magazine/c45/ap = list(80, 4, INFINITY),
				/obj/item/ammo_box/magazine/c38/ap = list(90, 4, INFINITY),
			),
		),

		list(
			"name" = "Equipment",
			"icon" = "hand-fist",
			"products" = list(
				/obj/item/clothing/head/helmet/sec = list(40, 1, INFINITY),
				/obj/item/clothing/suit/armor/swat/ert = list(70, 1, INFINITY),
				/obj/item/clothing/suit/armor/vest/alt/sec = list(60, 1, INFINITY),
				/obj/item/storage/backpack/ert = list(40, 1, INFINITY),
				/obj/item/radio/headset/headset_cent/alt/leader = list(50, 1, INFINITY),
				/obj/item/clothing/shoes/combat/swat = list(30, 1, INFINITY),
				/obj/item/clothing/under/rank/security/officer/blueshirt = list(40, 1, INFINITY),
				/obj/item/clothing/under/rank/security/officer/grey = list(40, 1, INFINITY),
				/obj/item/clothing/under/rank/centcom/military/ert = list(55, 1, INFINITY),
				/obj/item/clothing/mask/gas/sechailer = list(125, 2, INFINITY),
				/obj/item/clothing/glasses/hud/security/night = list(275, 2, INFINITY),
				/obj/item/shield/energy/advanced = list(750, 4, INFINITY),
			),
		),
	)

/obj/machinery/vending/trader/visitor/add_tts_component()
	AddComponent(/datum/component/tts_component, /datum/tts_seed/silero/lucian)

/obj/machinery/vending/trader/visitor/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/tts_component,  /datum/tts_seed/silero/lucian)

/obj/machinery/vending/trader/visitor/examine(mob/user)
	. = ..()
	. += "<b>ПОКУПАЕТ</b>: Только информационные предметы и артефакты (на 20% дороже, чем остальные торговцы)."
