/datum/supply_pack/security/gp9_pistols
	name = "GP-9 Pistols Crate"
	desc = "В этом ящике находятся два пистолета GP-9 калибра 9x25мм, а также четыре нелетальных магазина калибра 9x25мм НТ."
	cost = CARGO_CRATE_VALUE * 10
	access_view = ACCESS_SECURITY
	contains = list(
		/obj/item/gun/ballistic/automatic/pistol/gp9/no_mag = 2,
		/obj/item/ammo_box/magazine/c9x25mm_pistol/rubber = 4,
	)
	crate_name = "GP-9 handguns crate"

/datum/supply_pack/security/gp9_ammo
	name = "9x25mm NT Ammo Crate"
	desc = "В этом ящике находятся два нелетальных магазина и два летальных магазина калибра 9x25мм НТ, и соответствующие коробки с боеприпасами."
	cost = CARGO_CRATE_VALUE * 6
	access_view = ACCESS_SECURITY
	contains = list(
		/obj/item/ammo_box/magazine/c9x25mm_pistol = 2,
		/obj/item/ammo_box/magazine/c9x25mm_pistol/rubber = 2,
		/obj/item/ammo_box/c9x25mm = 1,
		/obj/item/ammo_box/c9x25mm/rubber = 1,
	)
	crate_name = "9x25mm NT ammo crate"

/datum/supply_pack/security/gp9_ammospecial
	name = "9x25mm NT Special Ammo Crate"
	desc = "В этом ящике находятся два бронебойных магазина и два экспансивных магазина калибра 9x25мм НТ, и соответствующие коробки с боеприпасами."
	cost = CARGO_CRATE_VALUE * 8
	access_view = ACCESS_SECURITY
	contains = list(
		/obj/item/ammo_box/magazine/c9x25mm_pistol/ap = 2,
		/obj/item/ammo_box/magazine/c9x25mm_pistol/hp = 2,
		/obj/item/ammo_box/c9x25mm/ap = 1,
		/obj/item/ammo_box/c9x25mm/hp = 1,
	)
	crate_name = "9x25mm NT special ammo crate"

/datum/supply_pack/security/gp9_mags_extended
	name = "9x25mm NT Extended Magazines Crate"
	desc = "В этом ящике находятся два увеличенных магазина калибра 9x25мм НТ."
	cost = CARGO_CRATE_VALUE * 6
	access_view = ACCESS_SECURITY
	contains = list(
		/obj/item/ammo_box/magazine/c9x25mm_pistol/stendo = 1,
		/obj/item/ammo_box/magazine/c9x25mm_pistol/stendo/rubber = 1,
	)
	crate_name = "9x25mm NT extended magazines crate"

/datum/supply_pack/goody/gp9_mags_extended_single
	name = "9x25mm NT Extended Magazine Crate"
	desc = "B этом ящике находится один увеличенный магазин калибра 9x25мм НТ."
	cost = CARGO_CRATE_VALUE * 4
	access_view = ACCESS_WEAPONS
	contains = list(
		/obj/item/ammo_box/magazine/c9x25mm_pistol/stendo/starts_empty = 1,
	)

/datum/supply_pack/goody/gp9_single
	name = "GP-9 Pistol Single-Pack"
	desc = "В этом ящике находится один пистолет GP-9 калибра 9x25мм НТ с пустым магазином."
	cost = CARGO_CRATE_VALUE * 6
	access_view = ACCESS_WEAPONS
	contains = list(
		/obj/item/gun/ballistic/automatic/pistol/gp9/no_mag = 1,
		/obj/item/ammo_box/magazine/c9x25mm_pistol/starts_empty = 1,
	)

/datum/supply_pack/goody/c9x25mmrubber
	name = "9x25mm NT Rubber Ammo Box"
	desc = "В этом ящике находится коробка резиновых патронов калибра 9x25мм НТ."
	cost = CARGO_CRATE_VALUE * 2
	access_view = ACCESS_WEAPONS
	contains = list(
		/obj/item/ammo_box/c9x25mm/rubber = 1,
	)

/datum/supply_pack/goody/c9x25mmhp
	name = "9x25mm NT HP Ammo Box"
	desc = "В этом ящике находится коробка экспансивных патронов калибра 9x25мм НТ."
	cost = CARGO_CRATE_VALUE * 2
	access_view = ACCESS_WEAPONS
	contains = list(
		/obj/item/ammo_box/c9x25mm/hp = 1,
	)

/datum/supply_pack/goody/c9x25mmap
	name = "9x25mm NT AP Ammo Box"
	desc = "В этом ящике находится коробка бронебойных патронов калибра 9x25мм НТ."
	cost = CARGO_CRATE_VALUE * 2
	access_view = ACCESS_WEAPONS
	contains = list(
		/obj/item/ammo_box/c9x25mm/ap = 1,
	)

/datum/supply_pack/goody/c9x25mm
	name = "9x25mm NT Ammo Box"
	desc = "В этом ящике находится коробка летальных патронов калибра 9x25мм НТ."
	cost = CARGO_CRATE_VALUE * 2
	access_view = ACCESS_WEAPONS
	contains = list(
		/obj/item/ammo_box/c9x25mm = 1,
	)

/datum/supply_pack/security/armory/sledgehammer
	name = "D4 Tactical Sledgehammer"
	crate_name = "D4 tactical sledgehammer crate"
	desc = "В этом ящике находится композитный молот для создания брешей или уничтожения препятствий."
	cost = CARGO_CRATE_VALUE * 15
	access_view = ACCESS_ARMORY
	contains = list(
		/obj/item/sledgehammer/tactical = 1,
	)

// MARK: Black Market
/datum/market_item/weapon/c46x30
	name = "4.6x30mm ammo box"
	desc = "Слушай, 4.6x30мм — это не то, что можно купить в ларьке. \
		Если хочешь достать их, не светя своей личностью, то не жалуйся. \
		Где-то тут качественный корпоративный стафф. А где-то — мусор с пола завода. \
		Мы ничего не обещаем, лады?"
	stock_max = 5
	availability_prob = 50
	item = /obj/effect/spawner/random/contraband/c46x30
	price_min = CARGO_CRATE_VALUE * 1
	price_max = CARGO_CRATE_VALUE * 3

/datum/market_item/weapon/c50
	name = ".50 BMG ammo box"
	desc = "Слушай, .50 BMG — это тебе не по банкам стрелять. \
		Если ты ищешь такой калибр, значит, ты ввязался в действительно крупные неприятности. \
		Тут может быть и бронебойный военный запас, и самокрут от безумных шахтеров. \
		Мы не гарантируем, что твои руки останутся целы после выстрела, усек?"
	stock_max = 5
	availability_prob = 20
	item = /obj/item/ammo_box/c50
	price_min = CARGO_CRATE_VALUE * 1
	price_max = CARGO_CRATE_VALUE * 3

/datum/market_item/weapon/c338
	name = ".338 ammo box"
	desc = "Послушай, .338 — это калибр для тех, кто привык решать проблемы с соседнего астероида. \
		Такое не продают в торговых автоматах, так что не задавай лишних вопросов. \
		В коробке может попасться снайперская элита, а может — кустарная пересборка. \
		Мы точность не гарантируем, лады?"
	stock_max = 5
	availability_prob = 30
	item = /obj/effect/spawner/random/contraband/c338
	price_min = CARGO_CRATE_VALUE * 1
	price_max = CARGO_CRATE_VALUE * 3

/datum/market_item/weapon/c762x51
	name = "7.62x51mm ammo box"
	desc = "Слушай, 7.62x51 — это тяжелая старая школа, о которой местные инженеры только в книжках читали. \
		Если тебе нужна реальная боевая мощь, а не игрушки, придется брать кота в мешке. \
		Тут может быть и излишек наемников Синдиката, и ржавый резерв времен колониальных войн. \
		Мы за осечки не отвечаем, окей?"
	stock_max = 5
	availability_prob = 30
	item = /obj/effect/spawner/random/contraband/c762x51
	price_min = CARGO_CRATE_VALUE * 1
	price_max = CARGO_CRATE_VALUE * 3

/datum/market_item/weapon/c223
	name = "5.56x45mm ammo box"
	desc = "Слушай, 5.56 — это серьезный военный калибр, его на станции днем с огнем не сыщешь. \
		Если тебе нужен настоящий свинец, а не травмат для разгона толпы, то бери что дают. \
		Это может быть излишек наемников или остатки с разбитого грузового корабля. \
		Мы качество пороха не проверяли, понял?"
	stock_max = 5
	availability_prob = 30
	item = /obj/effect/spawner/random/contraband/c223
	price_min = CARGO_CRATE_VALUE * 1
	price_max = CARGO_CRATE_VALUE * 3

/datum/market_item/weapon/c9mm
	name = "9mm ammo box"
	desc = "Слушай, 9мм — самый ходовой калибр в галактике, но это не значит, что он бесплатный. \
		Если тебе нужны патроны, которые не приведут ищеек к тебе, бери эти. \
		Тут вперемешку, где-то заводской стандарт, а где-то грязный самокрут из подвала. \
		Мы за заклинивший затвор не отвечаем, понял?"
	stock_max = 5
	availability_prob = 75
	item = /obj/effect/spawner/random/contraband/c9mm
	price_min = CARGO_CRATE_VALUE * 1
	price_max = CARGO_CRATE_VALUE * 3

/datum/market_item/weapon/c10mm
	name = "10mm ammo box"
	desc = "Слушай, 10мм — это для тех, кому обычная «девятка» кажется детской игрушкой. \
		Он лягается как мул и пробивает то, что не должен. \
		Это может быть горячая партия от Синдиката или кустарная пересборка с передозировкой пороха. \
		Мы за твои вывихнутые кисти не отвечаем, окей?"
	stock_max = 5
	availability_prob = 75
	item = /obj/effect/spawner/random/contraband/c10mm
	price_min = CARGO_CRATE_VALUE * 1
	price_max = CARGO_CRATE_VALUE * 3

/datum/market_item/weapon/c585sol
	name = ".585 Sol ammo box"
	desc = "Эй, .585 — это уже не стрельба, это ручная артиллерия. \
		Если ты достаточно безумен, чтобы стрелять этим с рук, то удачи. \
		Такое делают только под заказ для ТСФ и охотников на мегафауну, так что цени каждый патрон. \
		Мы не гарантируем, что твой ствол не разорвет к чертям, усек?"
	stock_max = 5
	availability_prob = 30
	item = /obj/effect/spawner/random/contraband/c585sol
	price_min = CARGO_CRATE_VALUE * 1
	price_max = CARGO_CRATE_VALUE * 3

/datum/market_item/weapon/c45
	name = ".45 ammo box"
	desc = "Послушай, .45 — это выбор тех, кто не любит повторять дважды. \
		Это старое, тяжелое дерьмо, которое валит с ног. \
		В коробке может быть качественный экспансив или списанный военный запас прошлого века. \
		Мы не обещаем, что порох не отсырел, лады?"
	stock_max = 5
	availability_prob = 75
	item = /obj/effect/spawner/random/contraband/c45
	price_min = CARGO_CRATE_VALUE * 1
	price_max = CARGO_CRATE_VALUE * 3

/datum/market_item/weapon/c357
	name = ".357 ammo box"
	desc = "Слушай, .357 — это классика, которая не стареет. \
		Если ты любишь решать вопросы одним точным выстрелом и вращением барабана, то бери. \
		Партия разная, что-то украли из вещдоков, что-то — трофей с складов Синдиката. \
		Мы не виноваты, если тебе выпадет пустышка, лады?"
	stock_max = 5
	availability_prob = 50
	item = /obj/item/ammo_box/c357
	price_min = CARGO_CRATE_VALUE * 1
	price_max = CARGO_CRATE_VALUE * 3

/datum/market_item/weapon/c38
	name = ".38 ammo box"
	desc = "Смотри, .38 обычно берут для дешевых револьверов и темных дел. \
		Это не для войны, а чтобы решить вопрос в тесном переулке. \
		Коробки не проверяем, что-то украли у копов, что-то нашли на свалке. \
		Если выстрелит — тебе повезло, мы гарантий не даем, ясно?"
	stock_max = 5
	availability_prob = 75
	item = /obj/effect/spawner/random/contraband/c38
	price_min = CARGO_CRATE_VALUE * 1
	price_max = CARGO_CRATE_VALUE * 3

/datum/market_item/weapon/c35sol
	name = ".35 Sol Short ammo box"
	desc = "Слушай, .35 Sol Short — это то, чем ТСФ кормит свои пистолеты каждый день. \
		Если хочешь стрелять казенным свинцом, не записываясь во флот ТСФ, то бери. \
		Эта коробка «упала» с погрузчика в доках, так что картон немного помят. \
		Внутри может быть заводской свежак, а может — отсыревший мусор. \
		Мы контроль качества не проводим, усек?"
	stock_max = 5
	availability_prob = 75
	item = /obj/effect/spawner/random/contraband/c35sol
	price_min = CARGO_CRATE_VALUE * 1
	price_max = CARGO_CRATE_VALUE * 3

/datum/market_item/weapon/c762x54mmr
	name = "7.62x54mmR ammo box"
	desc = "Послушай, 7.62x54ммR старше, чем сама эта станция, и он переживет нас всех. \
		Это древнее, злое дерьмо для старых винтовок, которое бьет как кувалда. \
		Часть выкопали из забытых складов СССП, часть сделали в подполье. \
		Мы не гарантируем, что закраина гильзы не застрянет, ясно?"
	stock_max = 5
	availability_prob = 30
	item = /obj/effect/spawner/random/contraband/c762x54mmr
	price_min = CARGO_CRATE_VALUE * 1
	price_max = CARGO_CRATE_VALUE * 3

/datum/market_item/weapon/a50box
	name = ".50 AE ammo box"
	desc = "Смотри, .50 AE берут не для скрытности, а для понтов и огромных дырок. \
		Если у тебя есть пушка под этого монстра, значит, ты любишь громкие звуки. \
		Тут может быть дорогой заказной экспансив или дешевая штамповка, которая клинит. \
		Мы не платим за лечение твоих запястий, усек?"
	stock_max = 5
	availability_prob = 30
	item = /obj/item/ammo_box/a50ae
	price_min = CARGO_CRATE_VALUE * 1
	price_max = CARGO_CRATE_VALUE * 3

/datum/market_item/weapon/n762_cylinder
	name = "7.62x38mm speedloader"
	desc = "Слушай, 7.62x38 обычно заряжают по одной пуле до второго пришествия, так что цени эту штуку. \
		Найти заряжатель для такого антиквариата сложнее, чем честного капитана. \
		Это либо музейный экспонат, либо кустарная работа местного механика. \
		Мы не обещаем, что патроны не вывалятся по дороге, усек?"
	stock_max = 5
	availability_prob = 30
	item = /obj/item/ammo_box/speedloader/n762_cylinder
	price_min = CARGO_CRATE_VALUE * 1
	price_max = CARGO_CRATE_VALUE * 3

/datum/market_item/weapon/c762x39
	name = "7.62x39mm ammo box"
	desc = "Слушай, 7.62x39 — это топливо для революций и войн по всей галактике. \
		Грязный, дешевый и надежный как кусок железа. \
		В ящике может быть что угодно, от военного резерва Красных до самоделки из ржавых гильз. \
		Мы не обещаем, что порох будет чистым, окей?"
	stock_max = 5
	availability_prob = 30
	item = /obj/effect/spawner/random/contraband/c762x39
	price_min = CARGO_CRATE_VALUE * 1
	price_max = CARGO_CRATE_VALUE * 3

/datum/market_item/weapon/c40sol
	name = ".40 Sol Long ammo box"
	desc = "Эй, .40 Sol сейчас встретишь нечасто, это эхо старых времен и правительственных заказов. \
		Если у тебя есть под это ствол, тебе повезло найти хоть какие-то патроны, так что не ной. \
		Это списанные остатки со складов Солнечной системы, которые «потерялись» при перевозке. \
		Мы не знаем, сколько лет они там пылились, понял?"
	stock_max = 5
	availability_prob = 30
	item = /obj/effect/spawner/random/contraband/c40sol
	price_min = CARGO_CRATE_VALUE * 1
	price_max = CARGO_CRATE_VALUE * 3

/datum/market_item/weapon/bobr
	name = "Bóbr revolver"
	desc = "Послушай, его назвали \"Бобр\", потому что он валит всё, как деревья на лесоповале. \
		Это чистая советская мощь, никакой эргономики, только сталь и картечь. \
		Эту штуку выменяли на ящик водки у интенданта где-то на окраине сектора. \
		Смазка может быть старой, но эта дура выстрелит в любом состоянии, лады?"
	item = /obj/item/gun/ballistic/revolver/bobr
	price_min = CARGO_CRATE_VALUE * 10
	price_max = CARGO_CRATE_VALUE * 20
	stock_max = 1
	availability_prob = 50

/datum/market_item/weapon/bobr/short
	name = "Bóbr revolver (short)"
	desc = "Слушай, \"Бобр\" — это не револьвер, это карманная гаубица. \
		Советские инженеры СССП, видимо, ненавидели человеческие запястья, когда проектировали револьвер 12-го калибра. \
		Он тяжелый, грубый и валит с ног даже стрелка. \
		Мы не гарантируем, что ты удержишь его в руках после первого выстрела, усек?"
	item = /obj/item/gun/ballistic/revolver/bobr/short
	price_min = CARGO_CRATE_VALUE * 10
	price_max = CARGO_CRATE_VALUE * 20
	stock_max = 1
	availability_prob = 30

/datum/market_item/weapon/renoster
	name = "Renoster shotgun"
	desc = "Послушай, это штатный дробовик ТСФ. Они используют такие для абордажей и подавления бунтов. \
		Это тяжелая, тупая груда металла, созданная, чтобы сносить двери и головы 12-м калибром. \
		Мы спилили серийные номера, но на прикладе еще видны царапины от прошлой зачистки. \
		Он лягается как черт, и мы не оплачиваем лечение твоего плеча, усек?"
	item = /obj/effect/spawner/random/contraband/renoster
	price_min = CARGO_CRATE_VALUE * 20
	price_max = CARGO_CRATE_VALUE * 25
	stock_max = 1
	availability_prob = 50

/datum/market_item/weapon/skild
	name = "Skild pistol"
	desc = "Послушай, по документам ТСФ это проходит как «тяжелое личное оружие», но весит оно как кирпич. \
		Этой штукой можно делать дырки в обшивке шаттлов, если отдачей тебя не выкинет в шлюз. \
		Партия списанная, может ствол перегрет, а может из него вообще боялись стрелять. \
		Мы точность не гарантируем, тут главное попасть в ту же сторону, лады?"
	item = /obj/effect/spawner/random/contraband/skild
	price_min = CARGO_CRATE_VALUE * 20
	price_max = CARGO_CRATE_VALUE * 25
	stock_max = 1
	availability_prob = 35

/datum/market_item/weapon/sindano
	name = "Sindano SMG"
	desc = "Послушай, это компактная «поливалка» из ТСФ для их бойцов и не только их. \
		Калибр .35 Sol — редкая, злая штука, мелкая пуля, но бешеная скорость. \
		ТСФ разработали этот ПП под калибр .35 Sol, чтобы дырявить бронежилеты в узких коридорах кораблей. \
		Эта штука жрет магазины за секунду, так что запасайся патронами. \
		Этот ствол, скорее всего, «потерялся» во время учений или переброски войск. \
		Механизм может быть разболтан от частой стрельбы очередями, мы гарантий не даем, лады?"
	item = /obj/effect/spawner/random/contraband/sindano
	price_min = CARGO_CRATE_VALUE * 20
	price_max = CARGO_CRATE_VALUE * 25
	stock_max = 1
	availability_prob = 50

/datum/market_item/weapon/tp14
	name = "TP-14 pistol"
	desc = "Слушай, в Республике Элизиум любят порядок, и ТП14 — это их «инструмент убеждения». \
		Калибр .45 не пробивает обшивку станции, зато отлично ломает ребра, не вызывая разгерметизации. \
		ТП-14 сидит в руке как влитой, а механика работает мягче, чем твои уговоры. \
		Эта пушка выглядит слишком аккуратной и эргономичной для этой дыры, так что не свети ей лишний раз. \
		Он может быть капризным к грязным патронам, так что не пихай в него всякий мусор, лады?"
	item = /obj/item/gun/ballistic/automatic/pistol/tp14
	price_min = CARGO_CRATE_VALUE * 20
	price_max = CARGO_CRATE_VALUE * 25
	stock_max = 1
	availability_prob = 35

/datum/market_item/weapon/fn18
	name = "FN-18 SMG"
	desc = "Послушай, это тебе не кустарный металлолом, это изящная инженерия Республики. \
		FN-18 работает плавно, как швейная машинка, и выплевывает магазин быстрее, чем ты успеешь испугаться. \
		Идеально для узких коридоров, где не нужна пробивная сила гаубицы. \
		Компактная, скорострельная и жрет дешевые 9мм патроны, не давясь. \
		Правда, эта крошка не любит песок и грязь, так что не роняй ее, лады?"
	item = /obj/item/gun/ballistic/automatic/fn18
	price_min = CARGO_CRATE_VALUE * 40
	price_max = CARGO_CRATE_VALUE * 50
	stock_max = 1
	availability_prob = 30

/datum/market_item/weapon/takbok
	name = "Takbok revolver"
	desc = "Послушай, это не игрушка для ковбоев, это тяжелый «аргумент» офицеров ТСФ. \
		Барабан всего на пять гнезд, зато калибр .50 AE пробивает бронепластины как картон. \
		Эта пушка выглядит потертой, будто прошла пару войн на границе, но механизм надежен, как кусок скалы. \
		Если промахнешься всеми пятью — можешь просто ударить им по голове, эффект будет тот же, лады?"
	item = /obj/effect/spawner/random/contraband/takbok
	price_min = CARGO_CRATE_VALUE * 40
	price_max = CARGO_CRATE_VALUE * 50
	stock_max = 1
	availability_prob = 35

/datum/market_item/weapon/sabel
	name = "AMK rifle"
	desc = "Слушай, АМК — это не просто автомат, это молот, которым СССП забивает гвозди в крышку гроба капитализма. \
		Грубая штампованная сталь, фанера и механизм, который работает даже в вакууме или болоте. \
		Этот ствол, наверное, прошел через три революции, прежде чем попасть к нам. \
		Он будет стрелять всегда, даже если ты забудешь, как его чистить, усек?"
	item = /obj/effect/spawner/random/contraband/amk
	price_min = CARGO_CRATE_VALUE * 40
	price_max = CARGO_CRATE_VALUE * 50
	stock_max = 1
	availability_prob = 30

/datum/market_item/weapon/sabel
	name = "Sabel carbine"
	desc = "Послушай, «Сабля» — это тот же АМК, который попытался стать цивилизованным. \
		Гражданский карабин, только одиночный огонь, никакой автоматики, чтобы не нервировать местных копов. \
		Но внутри это всё тот же неубиваемый советский трактор под 7.62. \
		Идеально для охоты или самообороны, если ты не планируешь устраивать маленькую войну. \
		И не пытайся кустарно вернуть ему автоогонь, лады?"
	item = /obj/item/gun/ballistic/automatic/sabel
	price_min = CARGO_CRATE_VALUE * 25
	price_max = CARGO_CRATE_VALUE * 40
	stock_max = 1
	availability_prob = 50

/datum/market_item/weapon/wespe
	name = "Wespe pistol"
	desc = "Послушай, это стандартная рабочая лошадка флота ТСФ. Их штампуют тысячами, и они работают везде. \
		Никаких понтов, только пластик, сталь и короткий патрон .35 Sol. \
		Партия, скажем так, «списанная» — может со склада, а может с холодного трупа. \
		Это не пушка героя боевика, но она выстрелит, когда прижмет. \
		Мы чистку не проводили, так что проверь ствол сам, лады?"
	item = /obj/effect/spawner/random/contraband/wespe
	price_min = CARGO_CRATE_VALUE * 20
	price_max = CARGO_CRATE_VALUE * 25
	stock_max = 1
	availability_prob = 50

/datum/market_item/weapon/carwo
	name = "Carwo rifle"
	desc = "Эй, само наличие у тебя этой винтовки — это уже срок в пяти секторах. \
		«Карво» — это штатное оружие штурмовиков ТСФ, и они очень не любят, когда оно попадает к гражданским. \
		Калибр .40 Sol Long, злой и пробивает стандартные бронежилеты охраны навылет. \
		Эта штука досталась нам с очень мутной сделки, так что не свети ей перед камерами. \
		Ствол потертый, номера спилены... может она прошла войну, а может валялась в шлюзе. \
		Если ее заклинит в бою — мы тебя не знаем, понял?"
	item = /obj/effect/spawner/random/contraband/carwo
	price_min = CARGO_CRATE_VALUE * 40
	price_max = CARGO_CRATE_VALUE * 50
	stock_max = 1
	availability_prob = 35

// MARK: GUNCASEs
/obj/item/storage/toolbox/guncase/soviet
	desc = "Оружейный кейс. Символ СССП отпечатан на боковой стороне."

/obj/item/storage/toolbox/guncase/china_lake
	name = "China Lake grenade launcher guncase"
	weapon_to_spawn = /obj/item/gun/ballistic/shotgun/china_lake
	extra_to_spawn = /obj/item/storage/fancy/a40mm_box

/obj/item/storage/toolbox/guncase/china_lake/PopulateContents()
	new weapon_to_spawn (src)
	new extra_to_spawn (src)
	new /obj/item/storage/fancy/a40mm_box/rubber (src)
	new /obj/item/storage/fancy/a40mm_box/smoke (src)

/obj/item/storage/toolbox/guncase/desert_eagle
	name = "desert eagle guncase"
	weapon_to_spawn = /obj/item/gun/ballistic/automatic/pistol/deagle/nuclear
	extra_to_spawn = /obj/item/ammo_box/magazine/m50

/obj/item/storage/toolbox/guncase/syndiesledge
	name = "syndicate sledgehammer case"
	weapon_to_spawn = /obj/item/sledgehammer/syndie
	extra_to_spawn = /obj/item/clothing/head/utility/welding

/obj/item/storage/toolbox/guncase/syndiesledge/PopulateContents()
	new weapon_to_spawn(src)
	new extra_to_spawn(src)
