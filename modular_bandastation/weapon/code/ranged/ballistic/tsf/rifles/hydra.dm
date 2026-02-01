/obj/item/gun/ballistic/automatic/hydra
	name = "TCR-80 \"Hydra\""
	desc = "Штурмовая винтовка ТСФ схемы булл-пап под калибр 5.56x45мм. Сочетает в себе длинный ствол и общую компактность, \
		что делает её смертоносным оружием как на дистанции, так и при зачистке помещений. На ствольной коробке по правую сторону выгравирован серийный номер и \
		аббревиатура \"АСТ\" темно-синими буквами, отсылающая к производителю винтовки."
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic48x32.dmi'
	icon_state = "hydra"
	worn_icon = 'modular_bandastation/weapon/icons/ranged/guns_back.dmi'
	worn_icon_state = "hydra"
	lefthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/righthand.dmi'
	inhand_icon_state = "hydra"
	SET_BASE_PIXEL(-8, 0)
	bolt_type = BOLT_TYPE_LOCKING
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	slot_flags = ITEM_SLOT_BACK
	accepted_magazine_type = /obj/item/ammo_box/magazine/c223
	spawn_magazine_type = /obj/item/ammo_box/magazine/c223
	fire_sound = 'modular_bandastation/weapon/sound/ranged/hydra.ogg'
	suppressed_sound = 'modular_bandastation/weapon/sound/ranged/suppressed_rifle.ogg'
	can_suppress = FALSE
	suppressor_x_offset = 10
	burst_size = 1
	fire_delay = 0.18 SECONDS
	actions_types = list()
	spread = 2.5
	recoil = 0.3
	load_sound = 'modular_bandastation/weapon/sound/ranged/cm82_reload.ogg'
	load_empty_sound = 'modular_bandastation/weapon/sound/ranged/cm82_reload.ogg'
	eject_sound = 'modular_bandastation/weapon/sound/ranged/cm82_unload.ogg'
	eject_empty_sound = 'modular_bandastation/weapon/sound/ranged/cm82_unload.ogg'
	rack_sound = 'modular_bandastation/weapon/sound/ranged/ar_cock.ogg'

/obj/item/gun/ballistic/automatic/hydra/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, fire_delay)
	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/gun/ballistic/automatic/hydra/update_icon_state()
	. = ..()
	inhand_icon_state = "[icon_state][magazine ? "":"_nomag"]"
	worn_icon_state = "[icon_state][magazine ? "":"_nomag"]"

/obj/item/gun/ballistic/automatic/hydra/examine(mob/user)
	. = ..()
	. += span_notice("Вы можете [EXAMINE_HINT("изучить подробнее")], чтобы узнать немного больше об этом оружии.")

/obj/item/gun/ballistic/automatic/hydra/examine_more(mob/user)
	. = ..()
	. += "Основная боевая винтовка сил ТСФ под патрон 5.56x45мм. TCR-80 получила прозвище \"Гидра\" за свою исключительную скорострельность \
		и характерный силуэт прицельной планки. Несмотря на спорную эргономику, эта винтовка славится надежностью автоматики и способностью создать \
		плотную стену огня за считанные секунды. Благодаря компактным габаритам и смещенному назад центру тяжести. \
		Она идеально подходит для маневренного боя в узких коридорах космических кораблей. Эта винтовка стала дебютом концерна \"Астром\" на рынке вооружений, \
		обеспечив вооруженные силы ТСФ еще одним надежным стрелковым оружием для противодействия угрозам Федерации."

/obj/item/gun/ballistic/automatic/hydra/pmc
	icon_state = "hydra_pmc"
	inhand_icon_state = "hydra_pmc"
	worn_icon_state = "hydra_pmc"

/obj/item/gun/ballistic/automatic/hydra/tsf
	desc = parent_type::desc + "<br>Образец в стандартных цветах армии ТСФ."
	icon_state = "hydra_tsf"
	inhand_icon_state = "hydra_tsf"
	worn_icon_state = "hydra_tsf"

/obj/item/gun/ballistic/automatic/hydra/white
	desc = parent_type::desc + "<br>Образец в белой камуфляжной раскраске."
	icon_state = "hydra_white"
	inhand_icon_state = "hydra_white"
	worn_icon_state = "hydra_white"

/obj/item/gun/ballistic/automatic/hydra/gl
	name = "TCR-80 \"Hydra\" GL"
	desc = parent_type::desc + "<br>Вариант с встроенным подствольным гранатометом."
	desc_controls = "ПКМ чтобы использовать подствольный гранатомет."
	icon_state = "hydra_gl"
	inhand_icon_state = "hydra_gl"
	worn_icon_state = "hydra_gl"
	var/obj/item/gun/ballistic/revolver/grenadelauncher/underbarrel/underbarrel

/obj/item/gun/ballistic/automatic/hydra/gl/Initialize(mapload)
	. = ..()
	underbarrel = new /obj/item/gun/ballistic/revolver/grenadelauncher/unrestricted(src)
	update_appearance()

/obj/item/gun/ballistic/automatic/hydra/gl/Destroy()
	QDEL_NULL(underbarrel)
	return ..()

/obj/item/gun/ballistic/automatic/hydra/gl/try_fire_gun(atom/target, mob/living/user, params)
	if(LAZYACCESS(params2list(params), RIGHT_CLICK))
		return underbarrel.try_fire_gun(target, user, params)
	return ..()

/obj/item/gun/ballistic/automatic/hydra/gl/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(isammocasing(tool))
		if(istype(tool, underbarrel.magazine.ammo_type))
			underbarrel.item_interaction(user, tool, modifiers)
		return ITEM_INTERACT_BLOCKING
	return ..()

/obj/item/gun/ballistic/automatic/hydra/gl/pmc
	icon_state = "hydra_gl_pmc"
	inhand_icon_state = "hydra_gl_pmc"
	worn_icon_state = "hydra_gl_pmc"

/obj/item/gun/ballistic/automatic/hydra/gl/tsf
	desc = parent_type::desc + "<br>Образец в стандартных цветах армии ТСФ."
	icon_state = "hydra_gl_tsf"
	inhand_icon_state = "hydra_gl_tsf"
	worn_icon_state = "hydra_gl_tsf"

/obj/item/gun/ballistic/automatic/hydra/gl/white
	desc = parent_type::desc + "<br>Образец в белой камуфляжной раскраске."
	icon_state = "hydra_gl_white"
	inhand_icon_state = "hydra_gl_white"
	worn_icon_state = "hydra_gl_white"

/obj/item/gun/ballistic/automatic/hydra/dmr
	name = "SBR-80 \"Hydra\""
	desc = parent_type::desc + "<br>Данная модель сконфигурирована как снайперская винтовка с удлиненным стволом и оптическим прицелом со средним увеличением. \
		Легкий патрон компенсируется режимом стрельбы очередями по 2 выстрела."
	icon_state = "hydra_dmr"
	inhand_icon_state = "hydra_dmr"
	worn_icon_state = "hydra_dmr"
	fire_delay = 1 SECONDS
	burst_size = 2
	spread = 1

/obj/item/gun/ballistic/automatic/hydra/dmr/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/scope, range_modifier = 2)

/obj/item/gun/ballistic/automatic/hydra/dmr/tsf
	desc = parent_type::desc + "<br>Образец в стандартных цветах армии ТСФ."
	icon_state = "hydra_dmr_tsf"
	inhand_icon_state = "hydra_dmr_tsf"
	worn_icon_state = "hydra_dmr_tsf"

/obj/item/gun/ballistic/automatic/hydra/dmr/pmc
	icon_state = "hydra_dmr_pmc"
	inhand_icon_state = "hydra_dmr_pmc"
	worn_icon_state = "hydra_dmr_pmc"

/obj/item/gun/ballistic/automatic/hydra/dmr/white
	desc = parent_type::desc + "<br>Образец в белой камуфляжной раскраске."
	icon_state = "hydra_dmr_white"
	inhand_icon_state = "hydra_dmr_white"
	worn_icon_state = "hydra_dmr_white"

/obj/item/gun/ballistic/automatic/hydra/lmg
	name = "SAW-80 \"Hydra\""
	desc = parent_type::desc + "<br>Этот образец сконфигурирован как оружие поддержки, с более тяжелыми компонентами для продолжительной стрельбы и большим дульным тормозом."
	icon_state = "hydra_lmg"
	inhand_icon_state = "hydra_lmg"
	worn_icon_state = "hydra_lmg"
	fire_delay = 0.12 SECONDS
	spread = 3

/obj/item/gun/ballistic/automatic/hydra/lmg/tsf
	desc = parent_type::desc + "<br>Образец в стандартных цветах армии ТСФ."
	icon_state = "hydra_lmg_tsf"
	inhand_icon_state = "hydra_lmg_tsf"
	worn_icon_state = "hydra_lmg_tsf"

/obj/item/gun/ballistic/automatic/hydra/lmg/pmc
	icon_state = "hydra_lmg_pmc"
	inhand_icon_state = "hydra_lmg_pmc"
	worn_icon_state = "hydra_lmg_pmc"

/obj/item/gun/ballistic/automatic/hydra/lmg/white
	desc = parent_type::desc + "<br>Образец в белой камуфляжной раскраске."
	icon_state = "hydra_lmg_white"
	inhand_icon_state = "hydra_lmg_white"
	worn_icon_state = "hydra_lmg_white"

/obj/item/gun/ballistic/automatic/hydra/gl/cr13
	name = "CR-13 BW"
	desc = "Опытный образец эксперементальной штурмовой винтовки на базе TCR-80 в конструкции которой используются БС-технологии. \
		Благодаря использованию этих технологий значительно усиливается скорость и дальность полета пули, что способствует повышению боевых характеристик данной винтовки. \
		На ствольной коробке по правую сторону выгравирован серийный номер и аббревиатура \"АСТ\" темно-синими буквами, отсылающая к производителю винтовки."
	icon_state = "hydra_white_spec"
	inhand_icon_state = "hydra_white_spec"
	worn_icon_state = "hydra_white_spec"
	projectile_damage_multiplier = 1.3
	projectile_speed_multiplier = 1.5
	fire_sound = 'modular_bandastation/weapon/sound/ranged/laser1.ogg'

/obj/item/gun/ballistic/automatic/hydra/gl/cr13/tsf
	desc = parent_type::desc + "<br>Образец в стандартных цветах армии ТСФ."
	icon_state = "hydra_tsf_spec"
	inhand_icon_state = "hydra_tsf_spec"
	worn_icon_state = "hydra_tsf_spec"

/obj/item/gun/ballistic/automatic/hydra/pmc/cr13
	name = "CR-18 BW \"Whitefire\""
	desc = "Опытный образец эксперементальной штурмовой винтовки на базе TCR-80 в конструкции которой используются БС-технологии. \
		Благодаря использованию этих технологий значительно усиливается скорость и дальность полета пули, что способствует повышению боевых характеристик данной винтовки. \
		Серийный номер и аббревиатура производителя были стерты."
	icon_state = "hydra_pmc_spec"
	inhand_icon_state = "hydra_pmc_spec"
	worn_icon_state = "hydra_pmc_spec"
	projectile_damage_multiplier = 1.3
	projectile_speed_multiplier = 1.5
	fire_sound = 'modular_bandastation/weapon/sound/ranged/laser1.ogg'
