/obj/item/gun/ballistic/automatic/akm
	name = "АКМ rifle"
	desc = "Нестареющий дизайн автомата под патрон 7.62 мм. Оружие настолько простое и надежное что им сможет пользоватся любой."
	icon = 'modular_bandastation/objects/icons/obj/weapons/guns/ballistic40x32.dmi'
	icon_state = "akm"
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/guns_righthand.dmi'
	inhand_icon_state = "akm"
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	accepted_magazine_type = /obj/item/ammo_box/magazine/akm
	can_suppress = FALSE
	fire_delay = 0.25 SECONDS
	worn_icon = 'modular_bandastation/objects/icons/mob/back/guns_back.dmi'
	worn_icon_state = "akm"
	fire_sound = 'modular_bandastation/objects/sounds/weapons/akm_fire.ogg'
	rack_sound = 'modular_bandastation/objects/sounds/weapons/ltrifle_cock.ogg'
	load_sound = 'modular_bandastation/objects/sounds/weapons/ltrifle_magin.ogg'
	load_empty_sound = 'modular_bandastation/objects/sounds/weapons/ltrifle_magin.ogg'
	eject_sound = 'modular_bandastation/objects/sounds/weapons/ltrifle_magout.ogg'
	burst_size = 1
	actions_types = list()
	recoil = 0.5
	spread = 6.5
	obj_flags = UNIQUE_RENAME

/obj/item/gun/ballistic/automatic/akm/Initialize(mapload)
	. = ..()

	give_autofire()

/obj/item/gun/ballistic/automatic/akm/proc/give_autofire()
	AddComponent(/datum/component/automatic_fire, fire_delay)

/obj/item/gun/ballistic/automatic/akm/examine(mob/user)
	. = ..()
	. += span_notice("Вы можете <b>изучить подробнее</b>, чтобы узнать немного больше об этом оружии.")

/obj/item/gun/ballistic/automatic/akm/examine_more(mob/user)
	. = ..()

	. += "АКМ — надежная штурмовая винтовка под патрон 7.62×39 мм. Обладает высокой убойной силой, \
	хорошей пробиваемостью и стабильной эффективностью на средних дистанциях.\
	Имеет заметную отдачу, но компенсируется уроном и доступностью боеприпасов. \
	Подходит как для ближнего боя, так и для уверенной стрельбы на расстоянии."

	return .

/obj/item/gun/ballistic/automatic/akm/no_mag
    spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/akm/civ
	name = "Sabel-42 carbine"
	desc = "Нестареющий дизайн карабина под патрон 7.62 мм. Оружие настолько простое и надежное что им сможет пользоватся любой."
	icon_state = "akm_civ"
	inhand_icon_state = "akm_civ"
	accepted_magazine_type = /obj/item/ammo_box/magazine/akm/civ
	fire_delay = 0.75 SECONDS
	dual_wield_spread = 15
	spread = 1.5
	worn_icon_state = "akm_civ"
	recoil = 0.2

/obj/item/gun/ballistic/automatic/akm/civ/give_autofire()
	return

/obj/item/gun/ballistic/automatic/akm/civ/examine_more(mob/user)
	. = ..()

	. += "Внутренние изменения, внесенные в оружие для невоенного использования, \
	    сделали его несовместимым с обычными боеприпасами и лишили возможности вести автоматический огонь. \
	    'Cабля-42' предназначен для стрельбы низкосортными гражданскими патронами, \
	    более мощные патроны разрушат нарезку и сделают оружие бесполезным."

	return .

/obj/item/gun/ballistic/automatic/akm/civ/no_mag
    spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/akm/upp
	name = "AK-462 rifle"
	desc = "Модернизированный дизайн автомата под патрон 7.62 мм. Стадартный и надежный автомат солдат СССП."
	icon_state = "akm_new"
	inhand_icon_state = "akm_new"
	worn_icon_state = "akm_new"
	can_suppress = TRUE
	fire_delay = 0.20 SECONDS
	spread = 2.5
	recoil = 0.1

/obj/item/gun/ballistic/automatic/akm/upp/examine_more(mob/user)
	. = ..()

	. += "Это усовершенствованная версия самого культового огнестрельного оружия, когда-либо созданного человеком, \
	    перепроектированная для уменьшения веса, улучшения управляемости и точности стрельбы, под патрон 7.62 мм. \
	    На затворе выгравировано «Оборонная Коллегия СССП». По центру приклада мелким шрифтом написано: 'Изделие-462 не использует компановку Бул-пап'."

	return .


/obj/item/gun/ballistic/automatic/akm/upp/no_mag
    spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/akm/modern
	name = "modern АКМ rifle"
	desc = "Нестареющий дизайн автомата под патрон 7.62 мм. Оружие настолько простое и надежное что им сможет пользоватся любой."
	icon_state = "akm_modern"
	inhand_icon_state = "akm_modern"
	worn_icon_state = "akm_modern"
	fire_delay = 0.20 SECONDS
	spread = 2.5
	recoil = 0.1

/obj/item/gun/ballistic/automatic/akm/modern/examine_more(mob/user)
	. = ..()

	. += "Этот вариант является модернизированной версией автомата АКМ с использованием более совершенных деталей. \
	    На замену оригинальных деталей были установлены новые, обновленные версии. \
	    Внутренний механизм был смазан и настроен, что повышает боевые способности данного варианта."

	return .

/obj/item/gun/ballistic/automatic/akm/modern/no_mag
    spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/akm/gauss
	name = "gauss AKM rifle"
	desc = "Эксперементальный дизайн автомата под патрон 7.62 мм. Оружие совмещаюшее в себе новые технологии и нестареющую классику."
	icon_state = "akm_gauss"
	inhand_icon_state = "akm"
	base_icon_state = "akm_gauss"
	worn_icon_state = "akm"
	projectile_damage_multiplier = 1.2
	projectile_speed_multiplier = 1.2
	fire_sound = 'modular_bandastation/objects/sounds/weapons/laser1.ogg'

	/// Determines how many shots we can make before the weapon needs to be maintained.
	var/shots_before_degradation = 30
	/// The max number of allowed shots this gun can have before degradation.
	var/max_shots_before_degradation = 30
	/// Determines the degradation stage. The higher the value, the more poorly the weapon performs.
	var/degradation_stage = 0
	/// Maximum degradation stage.
	var/degradation_stage_max = 5
	/// The probability of degradation increasing per shot.
	var/degradation_probability = 50
	/// The maximum speed malus for projectile flight speed. Projectiles probably shouldn't move too slowly or else they will start to cause problems.
	var/maximum_speed_malus = 0.7
	/// What is our damage multiplier if the gun is emagged?
	var/emagged_projectile_damage_multiplier = 1.6

	/// Whether or not our gun is suffering an EMP related malfunction.
	var/emp_malfunction = FALSE

	/// Our timer for when our gun is suffering an extreme malfunction. AKA it is going to explode
	var/explosion_timer

/obj/item/gun/ballistic/automatic/akm/gauss/examine_more(mob/user)
	. = ..()

	. += "Этот вариант является эксперементальной переделкой автомата АКМ с использованием гаусс-технологий. \
	    На оригинальные детали были установлены капаситоры и катушки, используемые для ускорения пули в стволе. \
	    На прикладе имеется батарея с индикатором загруженности капаситоров. \
		Из-за того что модификация сделана 'на коленке', о защите от ЭМИ можно только мечтать."

	return .

/obj/item/gun/ballistic/automatic/akm/gauss/Initialize(mapload)
	. = ..()
	register_context()

/obj/item/gun/ballistic/automatic/akm/gauss/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()

	if(held_item?.tool_behaviour == TOOL_MULTITOOL) //&& shots_before_degradation < max_shots_before_degradation)
		context[SCREENTIP_CONTEXT_LMB] = "Перезагрузить капаситоры"
		return CONTEXTUAL_SCREENTIP_SET

/obj/item/gun/ballistic/automatic/akm/gauss/update_overlays()
	. = ..()
	if(degradation_stage)
		. += "[base_icon_state]_empty"
	else if(shots_before_degradation)
		var/ratio_for_overlay = CEILING(clamp(shots_before_degradation / max_shots_before_degradation, 0, 1) * 3, 1)
		. += "[icon_state]_stage_[ratio_for_overlay]"

/obj/item/gun/ballistic/automatic/akm/gauss/emp_act(severity)
	. = ..()
	if (!(. & EMP_PROTECT_SELF) && prob(50 / severity))
		shots_before_degradation = 0
		emp_malfunction = TRUE
		attempt_degradation(TRUE)

/obj/item/gun/ballistic/automatic/akm/gauss/emag_act(mob/user, obj/item/card/emag/emag_card)
	. = ..()
	if(obj_flags & EMAGGED)
		return FALSE
	obj_flags |= EMAGGED
	projectile_damage_multiplier = emagged_projectile_damage_multiplier
	balloon_alert(user, "капаситоры перегружены")
	return TRUE

/obj/item/gun/ballistic/automatic/akm/gauss/multitool_act(mob/living/user, obj/item/tool)
	if(!tool.use_tool(src, user, 20 SECONDS, volume = 50))
		balloon_alert(user, "прервано!")
		return ITEM_INTERACT_BLOCKING

	emp_malfunction = FALSE
	shots_before_degradation = initial(shots_before_degradation)
	degradation_stage = initial(degradation_stage)
	projectile_speed_multiplier = initial(projectile_speed_multiplier)
	fire_delay = initial(fire_delay)
	update_appearance()
	balloon_alert(user, "капаситоры перезагружены")
	return ITEM_INTERACT_SUCCESS

/obj/item/gun/ballistic/automatic/akm/gauss/try_fire_gun(atom/target, mob/living/user, params)
	. = ..()
	if(!chambered || (chambered && !chambered.loaded_projectile))
		return

	if(shots_before_degradation)
		shots_before_degradation --
		return

	else if ((obj_flags & EMAGGED) && degradation_stage == degradation_stage_max && !explosion_timer)
		perform_extreme_malfunction(user)

	else
		attempt_degradation(FALSE)

/obj/item/gun/ballistic/automatic/akm/gauss/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	if(chambered.loaded_projectile && prob(75) && (emp_malfunction || degradation_stage == degradation_stage_max))
		balloon_alert_to_viewers("*шелк*")
		playsound(src, dry_fire_sound, dry_fire_sound_volume, TRUE)
		return

	if(chambered.loaded_projectile)
		chambered.loaded_projectile.icon = 'modular_bandastation/objects/icons/obj/weapons/guns/projectiles.dmi'
		chambered.loaded_projectile.icon_state = "gauss_ak"

	return ..()

/// Proc to handle weapon degradation. Called when attempting to fire or immediately after an EMP takes place.
/obj/item/gun/ballistic/automatic/akm/gauss/proc/attempt_degradation(force_increment = FALSE)
	if(!prob(degradation_probability) && !force_increment || degradation_stage == degradation_stage_max)
		return //Only update if we actually increment our degradation stage

	degradation_stage = clamp(degradation_stage + (obj_flags & EMAGGED ? 2 : 1), 0, degradation_stage_max)
	projectile_speed_multiplier = clamp(initial(projectile_speed_multiplier) + degradation_stage * 0.1, initial(projectile_speed_multiplier), maximum_speed_malus)
	fire_delay = initial(fire_delay) + (degradation_stage * 0.5)
	do_sparks(1, TRUE, src)
	update_appearance()

/// Proc to handle the countdown for our detonation
/obj/item/gun/ballistic/automatic/akm/gauss/proc/perform_extreme_malfunction(mob/living/user)
	balloon_alert(user, "оружие сейчас взорвется, выкидывай его!")
	explosion_timer = addtimer(CALLBACK(src, PROC_REF(fucking_explodes_you)), 5 SECONDS, (TIMER_UNIQUE|TIMER_OVERRIDE))
	playsound(src, 'sound/items/weapons/gun/general/empty_alarm.ogg', 50, FALSE)

/// proc to handle our detonation
/obj/item/gun/ballistic/automatic/akm/gauss/proc/fucking_explodes_you()
	explosion(src, devastation_range = 1, heavy_impact_range = 3, light_impact_range = 6, explosion_cause = src)

/obj/item/gun/ballistic/automatic/akm/gauss/tactical
	name = "tactical gauss AKM rifle"
	desc = "Эксперементальный дизайн автомата под патрон 7.62 мм. Оружие совмещаюшее в себе новые технологии и нестареющую классику."
	icon_state = "akm_gauss_tacticool"
	inhand_icon_state = "akm_modern"
	base_icon_state = "akm_gauss_tacticool"
	worn_icon_state = "akm_modern"

/obj/item/gun/ballistic/automatic/akm/gauss/tactical/examine_more(mob/user)
	. = ..()

	. += "Этот вариант является эксперементальной переделкой автомата АКМ с использованием гаусс-технологий. \
	    На оригинальные детали были установлены капаситоры и катушки, используемые для ускорения пули в стволе. \
	    На прикладе имеется батарея с индикатором загруженности капаситоров. \
		Этот экземпляр имеет более надежный и тактикульный вид, но о защите от ЭМИ все равно можно только мечтать."

	return .
