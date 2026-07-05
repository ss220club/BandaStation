/obj/item/book/granter/crafting_recipe/equipment_manual_light
	name = "Базовое руководство техника экспедиции"
	desc = "Потрёпанное руководство с самодельными схемами изготовления снаряжения."
	icon_state = "book3"
	crafting_recipe_types = list(
		/datum/crafting_recipe/compact_defib,
		/datum/crafting_recipe/medal,
		/datum/crafting_recipe/gasanalyther,
		/datum/crafting_recipe/trenchcoat,
		/datum/crafting_recipe/armor,
		/datum/crafting_recipe/helmet,
		/datum/crafting_recipe/belt,
		/datum/crafting_recipe/glasses,
		/datum/crafting_recipe/flashlight,
		/datum/crafting_recipe/suppressor,
		/datum/crafting_recipe/spess_knife,
	)
	remarks = list(
		"Компактный дефибриллятор требует качественных конденсаторов...",
		"Не экономьте на проводке.",
		"Медали штампуются из золота и ткани.",
		"Эти схемы пригодятся в полевых условиях.",
	)

/obj/item/book/granter/crafting_recipe/equipment_manual_light/recoil(mob/living/user)
	to_chat(user, span_notice("Вы запоминаете содержимое руководства. Бумага быстро рассыпается в прах."))
	qdel(src)

/obj/item/book/granter/crafting_recipe/equipment_manual_medium
	name = "Продвинутое руководство военного техника"
	desc = "Потрёпанное руководство с продвинутыми схемами изготовления снаряжения."
	icon_state = "book3"
	crafting_recipe_types = list(
		/datum/crafting_recipe/sunglasses,
		/datum/crafting_recipe/binocular,
		/datum/crafting_recipe/meson_glasses,
		/datum/crafting_recipe/night_vision,
		/datum/crafting_recipe/health_analyzer,
		/datum/crafting_recipe/marine_helmet,
		/datum/crafting_recipe/marine_vest,
		/datum/crafting_recipe/industrial_backpack,
		/datum/crafting_recipe/combat_gloves,
		/datum/crafting_recipe/jumpboots,
		/datum/crafting_recipe/radsuit,
		/datum/crafting_recipe/radsuit_hud,
		/datum/crafting_recipe/geiger,
		/datum/crafting_recipe/pump,
	)
	remarks = list(
		"Для бинокля нужны высокоточные линзы с масштабируемым сканирующим модулем...",
		"Большинство видов современной военной оптики требуют усиленного стекла.",
		"Пластины для бронежилетов изготавливаются из пластали.",
		"Множество схем и арифметических расчётов.",
	)

/obj/item/book/granter/crafting_recipe/equipment_manual_medium/recoil(mob/living/user)
	to_chat(user, span_notice("Вы запоминаете содержимое руководства. Бумага быстро рассыпается в прах."))
	qdel(src)

/obj/item/book/granter/crafting_recipe/equipment_manual_elite
	name = "Элитное научное руководство по экспериментальной экипировке"
	desc = "Потрёпанное руководство со схемами изготовления экспериментального снаряжения."
	icon_state = "book3"
	crafting_recipe_types = list(
		/datum/crafting_recipe/bag_of_holding,
		/datum/crafting_recipe/thermal_vision,
		/datum/crafting_recipe/pinpointer,
		/datum/crafting_recipe/autosurgeon,
		/datum/crafting_recipe/anti_drop,
		/datum/crafting_recipe/cns_rebooter,
		/datum/crafting_recipe/reviver,
	)
	remarks = list(
		"Концентрация блюспейс-поля научного рюкзака обеспечивается контроллируемой волной анализатора...",
		"Волновой спектр видимости термальных очков позволяет различать температурные оттенки...",
		"Сонарный сигнал, отправленный на объект по бета-сигналу целеуказателя, принимает обратный альфа-сигнал...",
		"Подробные схемы, формулы и расчёты, от которых пухнет голова...",
	)

/obj/item/book/granter/crafting_recipe/equipment_manual_elite/recoil(mob/living/user)
	to_chat(user, span_notice("Вы запоминаете содержимое руководства. Бумага быстро рассыпается в прах."))
	qdel(src)

/obj/item/book/granter/crafting_recipe/ammo_manual_light
	name = "Базовое охотничье руководство по сборке боеприпасов"
	desc = "Потрёпанное руководство со схемами изготовления обычных боеприпасов."
	icon_state = "book2"
	crafting_recipe_types = list(
		/datum/crafting_recipe/ammo_9mm_magazine_refill,
		/datum/crafting_recipe/ammo_9mm_magazine,
		/datum/crafting_recipe/ammo_310strilka_refill,
		/datum/crafting_recipe/ammo_310strilka,
		/datum/crafting_recipe/ammo_10mm_refill,
		/datum/crafting_recipe/ammo_10mm,
		/datum/crafting_recipe/ammo_762x54r_box,
		/datum/crafting_recipe/ammo_762x39_ricochet_box,
		/datum/crafting_recipe/ammo_762x39magshort_civ_refill,
		/datum/crafting_recipe/ammo_762x39magshort_civ,
		/datum/crafting_recipe/ammo_762x39mag_refill,
		/datum/crafting_recipe/ammo_762x39mag,
		/datum/crafting_recipe/ammo_35sol_refill,
		/datum/crafting_recipe/ammo_35sol,
		/datum/crafting_recipe/ammo_40solshort_refill,
		/datum/crafting_recipe/ammo_40solshort,
		/datum/crafting_recipe/ammo_40solstandard_refill,
		/datum/crafting_recipe/ammo_40solstandart,
		/datum/crafting_recipe/ammo_12gbuckshot,
		/datum/crafting_recipe/ammo_uzi9mm_refill,
		/datum/crafting_recipe/ammo_uzi9mm,
	)
	remarks = list(
		"Для обычных типов боеприпасов используется низкокачественный порох...",
		"Для сборки патронов вы можете использовать обычные коробки...",
		"Такие патроны годяться только для охоты на крупную дичь...",
		"Незамысловатая рукописная писанина, описывающая больше охоту, чем сборку патронов.",
	)

/obj/item/book/granter/crafting_recipe/ammo_manual_light/recoil(mob/living/user)
	to_chat(user, span_notice("Вы запоминаете содержимое руководства. Бумага быстро рассыпается в прах."))
	qdel(src)

/obj/item/book/granter/crafting_recipe/ammo_manual_medium
	name = "Продвинутое военное руководство по сборке боеприпасов"
	desc = "Потрёпанное руководство со схемами изготовления боевых боеприпасов."
	icon_state = "book2"
	crafting_recipe_types = list(
		/datum/crafting_recipe/frag_grenade,
		/datum/crafting_recipe/flashbang,
		/datum/crafting_recipe/gas_grenade,
		/datum/crafting_recipe/ammo_9mmhp_refill,
		/datum/crafting_recipe/ammo_9mmhp,
		/datum/crafting_recipe/ammo_9mmap_refill,
		/datum/crafting_recipe/ammo_9mmap,
		/datum/crafting_recipe/ammo_10mmhp_refill,
		/datum/crafting_recipe/ammo_10mmhp,
		/datum/crafting_recipe/ammo_10mmap_refill,
		/datum/crafting_recipe/ammo_10mmap,
		/datum/crafting_recipe/ammo762x39ion_refill,
		/datum/crafting_recipe/ammo762x39ion,
		/datum/crafting_recipe/ammo_9mmshnek_refill,
		/datum/crafting_recipe/ammo_9mmshnek,
		/datum/crafting_recipe/ammo_9mmshnekhp_refill,
		/datum/crafting_recipe/ammo_9mmshnekhp,
		/datum/crafting_recipe/ammo_9mmshnekap_refill,
		/datum/crafting_recipe/ammo_9mmshnekap,
		/datum/crafting_recipe/ammo_35soldrum_refill,
		/datum/crafting_recipe/ammo_35soldrum,
		/datum/crafting_recipe/ammo_35soldrumhp_refill,
		/datum/crafting_recipe/ammo_35soldrumhp,
		/datum/crafting_recipe/ammo_35soldrumap_refill,
		/datum/crafting_recipe/ammo_35soldrumap,
		/datum/crafting_recipe/ammo_40sollong_refill,
		/datum/crafting_recipe/ammo_40sollong,
		/datum/crafting_recipe/ammo_310strilkalong_refill,
		/datum/crafting_recipe/ammo_310strilkalong,
		/datum/crafting_recipe/ammo_45acp_refill,
		/datum/crafting_recipe/ammo_45acp,
		/datum/crafting_recipe/ammo_c45_refill,
		/datum/crafting_recipe/ammo_c45,
		/datum/crafting_recipe/ammo_smg45_refill,
		/datum/crafting_recipe/ammo_smg45,
		/datum/crafting_recipe/ammo_9mmsmgfn_refill,
		/datum/crafting_recipe/ammo_9mmsmgfn,
		/datum/crafting_recipe/ammo_9mmsteckin_refill,
		/datum/crafting_recipe/ammo_9mmsteckin,
		/datum/crafting_recipe/ammo_762x51fn4_refill,
		/datum/crafting_recipe/ammo_762x51fn4,
		/datum/crafting_recipe/ammo_as32_refill,
		/datum/crafting_recipe/ammo_as32,
	)
	remarks = list(
		"Использование пороха заводского качества для бронебойных боеприпасов пистолетов-пулемётов необходимо для обеспечения лучших баллистических характеристик...",
		"Траектория полёта пули зависит от пройдёной дистанции...",
		"Бронебойный боеприпас пистолета-пулемёта способен пробить броню 4 класса и выше...",
		"Расчёты траекторий, схемы составных частей боеприпасов, объяснение техники безопасности...",
	)

/obj/item/book/granter/crafting_recipe/ammo_manual_medium/recoil(mob/living/user)
	to_chat(user, span_notice("Вы запоминаете содержимое руководства. Бумага быстро рассыпается в прах."))
	qdel(src)

/obj/item/book/granter/crafting_recipe/ammo_manual_elite
	name = "Элитное руководство ССО по сборке боеприпасов"
	desc = "Потрёпанное руководство со схемами изготовления качественных боеприпасов."
	icon_state = "book2"
	crafting_recipe_types = list(
		/datum/crafting_recipe/c4,
		/datum/crafting_recipe/ammo_smg10mm_refill,
		/datum/crafting_recipe/ammo_smg10mm,
		/datum/crafting_recipe/ammo_smg10mmap_refill,
		/datum/crafting_recipe/ammo_smg10mmap,
		/datum/crafting_recipe/ammo_762x39ap_refill,
		/datum/crafting_recipe/ammo_762x39ap,
		/datum/crafting_recipe/ammo_40soldrum_refill,
		/datum/crafting_recipe/ammo_40soldrum,
		/datum/crafting_recipe/ammo_40sollongap_refill,
		/datum/crafting_recipe/ammo_40sollongap,
		/datum/crafting_recipe/ammo_c338_refill,
		/datum/crafting_recipe/ammo_c338,
		/datum/crafting_recipe/ammo_50ae_refill,
		/datum/crafting_recipe/ammo_50ae,
		/datum/crafting_recipe/ammo_12gslug,
		/datum/crafting_recipe/ammo_357match,
		/datum/crafting_recipe/ammo_m233_refill,
		/datum/crafting_recipe/ammo_m233,
		/datum/crafting_recipe/ammo_abiel50_refill,
		/datum/crafting_recipe/ammo_abiel50,
	)
	remarks = list(
		"Для изготовления бронебойных боеприпасов современного стандарта - потребуется применение высококачественного пороха...",
		"На винтовочные пули меньше воздействует сопротивление воздуха и сила Кориолиса...",
		"Пробитие бронежилетов стандарта 5 класса и выше гарантировано при стрельбе бронебойным винтовочным патроном...",
		"Множество расчётов траекторий, формул, вычислений и схем, от которых пухнет голова...",
	)

/obj/item/book/granter/crafting_recipe/ammo_manual_elite/recoil(mob/living/user)
	to_chat(user, span_notice("Вы запоминаете содержимое руководства. Бумага быстро рассыпается в прах."))
	qdel(src)

/obj/item/book/granter/crafting_recipe/medical_manual_light
	name = "Базовое руководство фармацевта-практиканта по изготовлению лекарственных препаратов"
	desc = "Потрёпанное руководство с формулами и схемами изготовления простых лекарственных препаратов."
	icon_state = "book4"
	crafting_recipe_types = list(
		/datum/crafting_recipe/suture,
		/datum/crafting_recipe/bandages,
		/datum/crafting_recipe/surgical_tape,
		/datum/crafting_recipe/libital_patch,
		/datum/crafting_recipe/aiuri_patch,
	)
	remarks = list(
		"Степень натяжения хирургического шва зависит от качества используемой ткани...",
		"Антибактериальные пластыри хорошо справляются с лечением ушибов и ссадин...",
		"Хирургическая лента подходит для изготовления различных лечебных пластырей...",
		"Довольно простые и понятные формулы расчёта веществ и соотношений реагентов.",
	)

/obj/item/book/granter/crafting_recipe/medical_manual_light/recoil(mob/living/user)
	to_chat(user, span_notice("Вы запоминаете содержимое руководства. Бумага быстро рассыпается в прах."))
	qdel(src)

/obj/item/book/granter/crafting_recipe/medical_manual_medium
	name = "Продвинутое медицинское руководство по изготовлению лекарственных препаратов"
	desc = "Потрёпанное руководство с формулами и схемами изготовления продвинутых медицинских лекарственных препаратов."
	icon_state = "book4"
	crafting_recipe_types = list(
		/datum/crafting_recipe/medkit_regular,
		/datum/crafting_recipe/spray_libital,
		/datum/crafting_recipe/spray_aiuri,
		/datum/crafting_recipe/hypospray,
	)
	remarks = list(
		"В состав набора первой помощи обязательно должны входить хирургические швы и марля...",
		"При определенном нагреве удаётся добится жидкой консистенции аиури и либитала, что позволяет использовать их в качестве спрея...",
		"Гипоспрей является универсальным инструментом для моментального ввода лекарственных препаратов...",
		"Печатные руководства с медицинскими формулами и вычислениями.",
	)

/obj/item/book/granter/crafting_recipe/medical_manual_medium/recoil(mob/living/user)
	to_chat(user, span_notice("Вы запоминаете содержимое руководства. Бумага быстро рассыпается в прах."))
	qdel(src)

/obj/item/book/granter/crafting_recipe/medical_manual_elite
	name = "Элитное руководство учёного-химика по изготовлению лекарственных препаратов"
	desc = "Потрёпанное руководство с формулами и схемами изготовления высококачественных медицинских лекарственных препаратов."
	icon_state = "book4"
	crafting_recipe_types = list(
		/datum/crafting_recipe/surgical_medkit,
		/datum/crafting_recipe/medkit_advanced,
	)
	remarks = list(
		"Для изготовления хирургического набора по медицинскому стандарту, необходимо правильное соотношение инструментов и реагентов...",
		"Универсальный медицинский набор подходит для решения большинства врачебных задач благодаря наличию пластырей синтплоти...",
		"Нагревание этилового спирта с образованием фенолов при определенном смешивании других реагентов, позволяет выработать атропин в нужном соотношении...",
		"Множество расчётов и химических формул, от которых пухнет голова...",
	)

/obj/item/book/granter/crafting_recipe/medical_manual_elite/recoil(mob/living/user)
	to_chat(user, span_notice("Вы запоминаете содержимое руководства. Бумага быстро рассыпается в прах."))
	qdel(src)
