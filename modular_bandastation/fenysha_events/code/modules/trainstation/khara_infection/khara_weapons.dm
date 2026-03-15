/obj/projectile/bullet/anti_khara
	name = "Anti-khara bullet"
	icon = 'icons/obj/weapons/guns/projectiles.dmi'
	icon_state = "smartgun"
	color = COLOR_ASSEMBLY_GREEN
	damage = 30
	damage_type = BRUTE
	armor_flag = BULLET
	hitsound_wall = SFX_RICOCHET
	sharpness = SHARP_POINTY
	impact_effect_type = /obj/effect/temp_visual/impact_effect/anti_khara
	shrapnel_type = null
	embed_type = null
	wound_bonus = 0
	wound_falloff_tile = -5
	embed_falloff_tile = -3

	var/khara_damage = 50

/obj/projectile/bullet/anti_khara/on_hit(atom/target, blocked = 0, pierce_hit)
	if(isliving(target))
		var/mob/living/L = target
		if(!is_khara_creature(L))
			return BULLET_ACT_FORCE_PIERCE
		else
			L.take_overall_damage(khara_damage)
	return ..()

/obj/projectile/bullet/anti_khara/can_hit_target(atom/target, direct_target, ignore_loc, cross_failed)
	if(isliving(target))
		var/mob/living/L = target
		if(!is_khara_creature(L))
			return FALSE
	return ..()

/obj/projectile/bullet/anti_khara/Bump(atom/A)
	if(isliving(A))
		var/mob/living/L = A
		if(!is_khara_creature(L))
			return FALSE
	return ..()

/obj/projectile/bullet/anti_khara/strong
	khara_damage = 80
	speed = 4

/obj/projectile/bullet/anti_khara/shotgun
	khara_damage = 10
	speed = 1

/obj/projectile/bullet/anti_khara/smart
	khara_damage = 30
	speed = 1.3
	color = COLOR_BLUE_GRAY
	impact_effect_type = /obj/effect/temp_visual/impact_effect/anti_khara/smart

/obj/projectile/bullet/anti_khara/smart/shotgun
	khara_damage = 7
	speed = 1

/obj/item/ammo_casing
	var/anti_khara = FALSE

/**
 * ППШКИ / ТЯЖЁЛЫЕ КАЛИБРЫ
 */

/obj/item/ammo_casing/p50/anti_khara
	name = ".50 BMG anti-Khara casing"
	desc = "A .50 BMG anti-Khara round casing."
	projectile_type = /obj/projectile/bullet/anti_khara/strong
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 4,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 1.5
	)
	anti_khara = TRUE

/obj/item/ammo_casing/c46x30mm/anti_khara
	name = "4.6x30mm anti-Khara bullet casing"
	desc = "A 4.6x30mm anti-Khara bullet casing."
	projectile_type = /obj/projectile/bullet/anti_khara
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 1.2,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 0.6
	)
	anti_khara = TRUE

/obj/item/ammo_casing/c46x30mm/anti_khara/smart
	name = "4.6x30mm smart anti-Khara bullet casing"
	desc = "A 4.6x30mm smart anti-Khara bullet casing."
	projectile_type = /obj/projectile/bullet/anti_khara/smart
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 1.3,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 1.0
	)
	anti_khara = TRUE

/obj/item/ammo_casing/c46x30mm/anti_khara/smart/ready_proj(atom/target, mob/living/user, quiet, zone_override, atom/fired_from)
	if(is_khara_creature(target))
		loaded_projectile.set_homing_target(target)
		new /obj/effect/temp_visual/smartgun_target(get_turf(target))
	return ..()

/obj/item/ammo_casing/c45/anti_khara
	name = ".45 anti-Khara bullet casing"
	desc = "A .45 anti-Khara bullet casing."
	projectile_type = /obj/projectile/bullet/anti_khara
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 1.5,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 0.7
	)
	anti_khara = TRUE

/**
 * ДРОБОВИКИ
 */

/obj/item/ammo_casing/shotgun/anti_khara
	name = "anti-Khara slug"
	desc = "A 12 gauge slug designed to disrupt Khara-infected biomass."
	icon_state = "stunshell"
	projectile_type = /obj/projectile/bullet/anti_khara/strong
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2.5,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 1.0
	)
	anti_khara = TRUE

/obj/item/ammo_casing/shotgun/buckshot/anti_khara
	name = "anti-Khara buckshot shell"
	desc = "A 12 gauge shell loaded with pellets optimized against Khara tissue."
	icon_state = "gshell"
	projectile_type = /obj/projectile/bullet/anti_khara/shotgun
	pellets = 7
	variance = 16
	randomspread = TRUE
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2.8,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 1.2
	)
	anti_khara = TRUE

/obj/item/ammo_casing/shotgun/buckshot/anti_khara/smart
	name = "smart anti-Khara buckshot shell"
	desc = "A 12 gauge shell with smart pellets capable of trajectory correction toward Khara targets."
	icon_state = "gshell"
	projectile_type = /obj/projectile/bullet/anti_khara/smart/shotgun
	pellets = 6
	variance = 18
	randomspread = TRUE
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 3.0,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 1.8
	)
	anti_khara = TRUE

/obj/item/ammo_casing/shotgun/buckshot/anti_khara/smart/ready_proj(atom/target, mob/living/user, quiet, zone_override, atom/fired_from)
	if(is_khara_creature(target))
		loaded_projectile.set_homing_target(target)
		new /obj/effect/temp_visual/smartgun_target(get_turf(target))
	return ..()

/**
 * ПИСТОЛЕТНЫЕ КАЛИБРЫ
 */

/obj/item/ammo_casing/c10mm/anti_khara
	name = "10mm anti-Khara bullet casing"
	desc = "A 10mm bullet casing loaded with compound engineered to disrupt Khara biomass."
	projectile_type = /obj/projectile/bullet/anti_khara
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 1.8,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 0.8
	)
	anti_khara = TRUE

/obj/item/ammo_casing/c10mm/anti_khara/smart
	name = "10mm smart anti-Khara bullet casing"
	desc = "A 10mm bullet with micro-guidance system tuned to Khara biological signatures."
	projectile_type = /obj/projectile/bullet/anti_khara/smart
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2.0,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 1.3
	)
	anti_khara = TRUE

/obj/item/ammo_casing/c10mm/anti_khara/smart/ready_proj(atom/target, mob/living/user, quiet, zone_override, atom/fired_from)
	if(is_khara_creature(target))
		loaded_projectile.set_homing_target(target)
		new /obj/effect/temp_visual/smartgun_target(get_turf(target))
	return ..()

/obj/item/ammo_casing/c9mm/anti_khara
	name = "9mm anti-Khara bullet casing"
	desc = "A 9mm bullet casing containing payload optimized against Khara-infected tissue."
	projectile_type = /obj/projectile/bullet/anti_khara
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 1.6,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 0.7
	)
	anti_khara = TRUE

/obj/item/ammo_casing/c9mm/anti_khara/smart
	name = "9mm smart anti-Khara bullet casing"
	desc = "A 9mm round with integrated guidance for tracking Khara entities."
	projectile_type = /obj/projectile/bullet/anti_khara/smart
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 1.8,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 1.1
	)
	anti_khara = TRUE

/obj/item/ammo_casing/c9mm/anti_khara/smart/ready_proj(atom/target, mob/living/user, quiet, zone_override, atom/fired_from)
	if(is_khara_creature(target))
		loaded_projectile.set_homing_target(target)
		new /obj/effect/temp_visual/smartgun_target(get_turf(target))
	return ..()

/obj/item/ammo_casing/a50ae/anti_khara
	name = ".50AE anti-Khara bullet casing"
	desc = "A high-caliber .50AE round specially formulated to penetrate and degrade dense Khara biomass."
	projectile_type = /obj/projectile/bullet/anti_khara/strong
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 3.0,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 1.4
	)
	anti_khara = TRUE

/**
 * ВИНТОВОЧНЫЕ КАЛИБРЫ
 */

/obj/item/ammo_casing/strilka310/anti_khara
	name = ".310 Strilka anti-Khara bullet casing"
	desc = "A .310 Strilka block of red powder formulated to disrupt Khara biomass."
	icon_state = "310-casing"
	projectile_type = /obj/projectile/bullet/anti_khara
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2.2,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 1.0
	)
	anti_khara = TRUE

/obj/item/ammo_casing/strilka310/anti_khara/smart
	name = ".310 Strilka smart anti-Khara bullet casing"
	desc = "A .310 Strilka propellant block with embedded micro-guidance tuned to Khara signatures."
	icon_state = "310-casing"
	projectile_type = /obj/projectile/bullet/anti_khara/smart
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2.4,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 1.6
	)
	anti_khara = TRUE

/obj/item/ammo_casing/strilka310/anti_khara/smart/ready_proj(atom/target, mob/living/user, quiet, zone_override, atom/fired_from)
	if(is_khara_creature(target))
		loaded_projectile.set_homing_target(target)
		new /obj/effect/temp_visual/smartgun_target(get_turf(target))
	return ..()

/obj/item/ammo_casing/a223/anti_khara
	name = ".223 anti-Khara bullet casing"
	desc = "A .223 bullet casing loaded with payload engineered to degrade Khara-infected tissue."
	icon_state = "223-casing"
	projectile_type = /obj/projectile/bullet/anti_khara
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2.0,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 0.9
	)
	anti_khara = TRUE

/obj/item/ammo_casing/a223/anti_khara/smart
	name = ".223 smart anti-Khara bullet casing"
	desc = "A .223 round with integrated targeting electronics for Khara priority targets."
	icon_state = "223-casing"
	projectile_type = /obj/projectile/bullet/anti_khara/smart
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2.2,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 1.4
	)
	anti_khara = TRUE

/obj/item/ammo_casing/a223/anti_khara/smart/ready_proj(atom/target, mob/living/user, quiet, zone_override, atom/fired_from)
	if(is_khara_creature(target))
		loaded_projectile.set_homing_target(target)
		new /obj/effect/temp_visual/smartgun_target(get_turf(target))
	return ..()

/**
 * ПУЛЕМЁТНЫЙ КАЛИБР
 */

/obj/item/ammo_casing/m7mm/anti_khara
	name = "7mm anti-Khara bullet casing"
	desc = "A 7mm bullet casing loaded with specialized compound to disrupt and degrade Khara biomass."
	icon_state = "762-casing"
	projectile_type = /obj/projectile/bullet/anti_khara
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2.5,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 1.1
	)
	anti_khara = TRUE

/obj/item/ammo_casing/m7mm/anti_khara/smart
	name = "7mm smart anti-Khara bullet casing"
	desc = "A 7mm round with micro-guidance electronics calibrated to seek out Khara biological signatures."
	icon_state = "762-casing"
	projectile_type = /obj/projectile/bullet/anti_khara/smart
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2.7,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 1.7
	)
	anti_khara = TRUE

/obj/item/ammo_casing/m7mm/anti_khara/smart/ready_proj(atom/target, mob/living/user, quiet, zone_override, atom/fired_from)
	if(is_khara_creature(target))
		loaded_projectile.set_homing_target(target)
		new /obj/effect/temp_visual/smartgun_target(get_turf(target))
	return ..()



/datum/design/anti_khara_ammunition
	name = "Диск Анти-Кхара аммуниции"
	desc = "Диск наполненный обновленными данными для верстака печати патронов. Эта аммуниция может эффективно бороться с пораждениями Кхары."
	id = "anti_khara_ammunition"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/silver = HALF_SHEET_MATERIAL_AMOUNT * 1.5,
		/datum/material/gold = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/diamond = SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/disk/ammo_workbench/advanced/anti_khara
	category = list(
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY


/obj/item/disk/ammo_workbench/advanced/anti_khara
	name = "диск боеприпасов типа 'Анти-Кхара'"
	desc = "Содержит данные по изготовлению особенных боеприпасов, что эффективно поражают создания Кхары - игнорируя обычных людей."

/obj/item/disk/ammo_workbench/advanced/anti_khara/on_bench_install(obj/machinery/ammo_workbench/bench)
	bench.allowed_antikhara = TRUE
	bench.update_ammotypes()




/obj/item/gun/energy/anti_khara
	name = "Анти-Кхара бластер"
	desc = "Продвинутый энергетический бластер испускающую пучки энергии колебающиеся на особой частоте. \
			Тонкая настройка позволяет им атаковать исключительно абоминации Кхары - игнорируя другие живые цели."
	icon_state = "instagibgreen"
	inhand_icon_state = "instagibgreen"
	w_class = WEIGHT_CLASS_BULKY
	ammo_type = list(
		/obj/item/ammo_casing/energy/anti_khara,
		/obj/item/ammo_casing/energy/anti_khara/smart,
	)
	cell_type = /obj/item/stock_parts/power_store/cell/high
	clumsy_check = FALSE
	selfcharge = TRUE
	self_charge_amount = 1000
	automatic_charge_overlays = FALSE


/obj/item/gun/energy/anti_khara/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/scope, range_modifier = 2)

/obj/item/gun/energy/anti_khara/update_icon_state()
	. = ..()
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	if(istype(shot, /obj/item/ammo_casing/energy/anti_khara/smart))
		inhand_icon_state = "instagibblue"
		icon_state = "instagibblue"
	else
		inhand_icon_state = "instagibgreen"
		icon_state = "instagibgreen"

/obj/item/gun/energy/anti_khara/examine(mob/user)
	. = ..()
	. += span_hypnophrase("Это невероятное оружие. \n")

	if(selfcharge)
		. += span_boldnicegreen("Ядро оружие автоматически восстанавливает энергию в нем.")
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	if(istype(shot, /obj/item/ammo_casing/energy/anti_khara/smart))
		. += span_boldnotice("Включен умный режим стрельбы с доводкой по цели.")
	else
		. += span_boldnotice("Включен усиленный режим стрельбы с повышенным уроном.")



/obj/item/ammo_casing/energy/anti_khara
	projectile_type = /obj/projectile/energy/anti_khara
	select_name = "anti-khara"
	e_cost = LASER_SHOTS(100, STANDARD_CELL_CHARGE * 10)

/obj/item/ammo_casing/energy/anti_khara/smart
	projectile_type = /obj/projectile/energy/anti_khara/smart
	e_cost = LASER_SHOTS(30, STANDARD_CELL_CHARGE * 10)
	select_name = "smart anti-khara"

/obj/item/ammo_casing/energy/anti_khara/smart/ready_proj(atom/target, mob/living/user, quiet, zone_override, atom/fired_from)
	if(is_khara_creature(target))
		loaded_projectile.set_homing_target(target)
		new /obj/effect/temp_visual/smartgun_target(get_turf(target))
	return ..()



/obj/projectile/energy/anti_khara
	name = "anti-khara bolt"
	icon_state = "spell"
	damage = 0
	damage_type = BRUTE
	armor_flag = ENERGY
	impact_effect_type = /obj/effect/temp_visual/impact_effect/anti_khara

	var/smart = FALSE
	var/khara_damage = 45

/obj/projectile/energy/anti_khara/Initialize(mapload)
	. = ..()
	if(!smart)
		var/matrix/big = matrix()
		big.Scale(2, 2,)
		animate(src, transform = big, time = 3 SECONDS)

/obj/effect/temp_visual/impact_effect/anti_khara
	icon_state = "mech_toxin"
	duration = 5

/obj/effect/temp_visual/impact_effect/anti_khara/smart
	icon_state = "shieldsparkles"

/obj/projectile/energy/anti_khara/smart
	name = "anti-khara smart bolt"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/anti_khara/smart
	smart = TRUE
	khara_damage = 25
	range = 10
	homing_turn_speed = 10
	homing_inaccuracy_min = 1
	homing_inaccuracy_max = 1

/obj/projectile/energy/anti_khara/on_hit(atom/target, blocked = 0, pierce_hit)
	if(isliving(target))
		var/mob/living/L = target
		if(!is_khara_creature(L))
			return BULLET_ACT_FORCE_PIERCE
		else
			L.take_overall_damage(khara_damage)
	return ..()

/obj/projectile/energy/anti_khara/can_hit_target(atom/target, direct_target, ignore_loc, cross_failed)
	if(isliving(target))
		var/mob/living/L = target
		if(!is_khara_creature(L))
			return FALSE
	return ..()

/obj/projectile/energy/anti_khara/Bump(atom/A)
	if(isliving(A))
		var/mob/living/L = A
		if(!is_khara_creature(L))
			return FALSE
	return ..()
