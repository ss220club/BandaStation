/obj/item/gun/ballistic/railgun
	name = "HEMC-62"
	desc = "Ручной Электромагнитный Ускоритель Масс изделие номер 62 или же простыми словами 'Рельсотрон'. Большая и тяжелая пушка для уничтожения самых серьезных противников Нанотрейзен."
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic40x32.dmi'
	icon_state = "railgun"
	righthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/lefthand40x32.dmi'
	lefthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/righthand40x32.dmi'
	inhand_icon_state = "railgun_worn"
	worn_icon = 'modular_bandastation/weapon/icons/ranged/railgun_back.dmi'
	worn_icon_state = "railgun_back"
	w_class = WEIGHT_CLASS_HUGE
	weapon_weight = WEAPON_HEAVY
	slot_flags = ITEM_SLOT_BACK
	accepted_magazine_type = /obj/item/ammo_box/magazine/railgun
	mag_display = TRUE
	mag_display_ammo = TRUE
	empty_alarm = TRUE
	tac_reloads = FALSE
	bolt_type = BOLT_TYPE_STANDARD
	semi_auto = FALSE
	fire_sound = 'modular_bandastation/weapon/sound/ranged/railgun_fire.ogg'
	fire_sound_volume = 90
	rack_sound = 'modular_bandastation/weapon/sound/ranged/railgun_cock.ogg'
	lock_back_sound = 'modular_bandastation/weapon/sound/ranged/railgun_open.ogg'
	bolt_drop_sound = 'modular_bandastation/weapon/sound/ranged/railgun_cock.ogg'
	load_sound = 'modular_bandastation/weapon/sound/ranged/railgun_magin.ogg'
	eject_sound = 'modular_bandastation/weapon/sound/ranged/railgun_magout.ogg'
	load_empty_sound = 'modular_bandastation/weapon/sound/ranged/railgun_magout.ogg'
	fire_delay = 7 SECONDS
	recoil = 1
	projectile_speed_multiplier = 1.5

	/// Determines how many shots we can make before the weapon needs to be maintained.
	var/shots_before_degradation = 10
	/// The max number of allowed shots this gun can have before degradation.
	var/max_shots_before_degradation = 10
	/// Determines the degradation stage. The higher the value, the more poorly the weapon performs.
	var/degradation_stage = 0
	/// Maximum degradation stage.
	var/degradation_stage_max = 5
	/// The probability of degradation increasing per shot.
	var/degradation_probability = 25
	/// The maximum speed malus for projectile flight speed. Projectiles probably shouldn't move too slowly or else they will start to cause problems.
	var/maximum_speed_malus = 0.7
	/// What is our damage multiplier if the gun is emagged?
	var/emagged_projectile_damage_multiplier = 1.6
	/// Whether or not our gun is suffering an EMP related malfunction.
	var/emp_malfunction = FALSE
	/// Our timer for when our gun is suffering an extreme malfunction. AKA it is going to explode
	var/explosion_timer

/obj/item/gun/ballistic/railgun/Initialize(mapload)
	. = ..()
	register_context()

/obj/item/gun/ballistic/railgun/examine(mob/user)
	. = ..()
	if(shots_before_degradation)
		. += span_notice("[declent_ru(NOMINATIVE)] может совершить [shots_before_degradation] выстрелов перед риском деградации системы рельсовых накопителей.")
	else
		. += span_notice("[declent_ru(NOMINATIVE)] в процессе деградации системы рельсовых накопителей. Стадия [degradation_stage] из [degradation_stage_max]. Используйте мультитул на [declent_ru(NOMINATIVE)] чтобы перезагрузить систему.")

/obj/item/gun/ballistic/railgun/emag_act(mob/user, obj/item/card/emag/emag_card)
	. = ..()
	if(obj_flags & EMAGGED)
		return FALSE
	obj_flags |= EMAGGED
	projectile_damage_multiplier = emagged_projectile_damage_multiplier
	balloon_alert(user, "конденсаторы перегружены")
	return TRUE

/obj/item/gun/ballistic/railgun/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(held_item?.tool_behaviour == TOOL_MULTITOOL && shots_before_degradation < max_shots_before_degradation)
		context[SCREENTIP_CONTEXT_LMB] = "Перезагрузить конденсаторы"
		return CONTEXTUAL_SCREENTIP_SET

/obj/item/gun/ballistic/railgun/multitool_act(mob/living/user, obj/item/tool)
	if(!tool.use_tool(src, user, 20 SECONDS, volume = 50))
		balloon_alert(user, "прервано!")
		return ITEM_INTERACT_BLOCKING

	emp_malfunction = FALSE
	shots_before_degradation = initial(shots_before_degradation)
	degradation_stage = initial(degradation_stage)
	projectile_speed_multiplier = initial(projectile_speed_multiplier)
	fire_delay = initial(fire_delay)
	balloon_alert(user, "конденсаторы перезагружены")
	return ITEM_INTERACT_SUCCESS

/obj/item/gun/ballistic/railgun/emp_act(severity)
	. = ..()
	if (!(. & EMP_PROTECT_SELF) && prob(50 / severity))
		shots_before_degradation = 0
		emp_malfunction = TRUE
		attempt_degradation(TRUE)

/obj/item/gun/ballistic/railgun/try_fire_gun(atom/target, mob/living/user, params)
	. = ..()
	if(!chambered || (chambered && !chambered.loaded_projectile))
		return

/obj/item/gun/ballistic/railgun/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	if(chambered.loaded_projectile && prob(75) && (emp_malfunction || degradation_stage == degradation_stage_max))
		balloon_alert_to_viewers("*шелк*")
		playsound(src, dry_fire_sound, dry_fire_sound_volume, TRUE)
		return

	. = ..()
	if(.)
		if(shots_before_degradation)
			shots_before_degradation --
		else if((obj_flags & EMAGGED) && degradation_stage == degradation_stage_max && !explosion_timer)
			perform_extreme_malfunction(user)
		else
			attempt_degradation(FALSE)

	return ..()

/obj/item/gun/ballistic/railgun/proc/attempt_degradation(force_increment = FALSE)
	if(!prob(degradation_probability) && !force_increment || degradation_stage == degradation_stage_max)
		return

	degradation_stage = clamp(degradation_stage + (obj_flags & EMAGGED ? 2 : 1), 0, degradation_stage_max)
	projectile_speed_multiplier = clamp(initial(projectile_speed_multiplier) + degradation_stage * 0.1, initial(projectile_speed_multiplier), maximum_speed_malus)
	fire_delay = initial(fire_delay) + (degradation_stage * 0.5)
	do_sparks(1, TRUE, src)

/obj/item/gun/ballistic/railgun/proc/perform_extreme_malfunction(mob/living/user)
	balloon_alert(user, "оружие сейчас взорвется, выкидывай его!")
	explosion_timer = addtimer(CALLBACK(src, PROC_REF(explodes_you)), 5 SECONDS, (TIMER_UNIQUE|TIMER_OVERRIDE))
	playsound(src, 'sound/items/weapons/gun/general/empty_alarm.ogg', 50, FALSE)

/obj/item/gun/ballistic/railgun/proc/explodes_you()
	explosion(src, devastation_range = 1, heavy_impact_range = 3, light_impact_range = 6, explosion_cause = src)

/obj/item/gun/ballistic/railgun/update_icon()
	. = ..()
	if(!magazine)
		icon_state = "railgun_open"
	else
		icon_state = "railgun_closed"

/obj/item/gun/ballistic/railgun/nomag
	spawnwithmagazine = FALSE

/obj/item/gun/ballistic/railgun/scoped
	name = "HEMC-60"
	desc = "Ручной Электромагнитный Ускоритель Масс изделие номер 60 или же простыми словами 'Рельсотрон'. Более увесистая модель с более сильной отдачей, но взамен оснащенная оптическим прицелом."
	recoil = 3
	slowdown = 0.25

/obj/item/gun/ballistic/railgun/scoped/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/scope, range_modifier = 1.5)
