#define CALIBER_585SOL ".585 Sol"
#define CALIBER_980TYDHOUER ".980 Tydhouer"

/obj/projectile/bullet/c9x25mm/bs
	name = "9x25mm NT bluespace bullet"
	damage = 15
	wound_bonus = -5
	exposed_wound_bonus = 5
	embed_falloff_tile = 0
	armour_penetration = 20
	shrapnel_type = null
	embed_type = null
	speed = 2

/obj/projectile/bullet/c9x25mm/bs/admin
	name = "9x25mm NT bluespace-moth bullet"
	icon = 'icons/obj/toys/plushes.dmi'
	hitsound = 'sound/mobs/humanoids/moth/scream_moth.ogg'
	icon_state = "moffplush"
	damage = 100
	wound_bonus = 50
	exposed_wound_bonus = 50
	embed_falloff_tile = 0
	armour_penetration = 50
	speed = 2
	embed_type = /datum/embedding/moth_bullet

/datum/embedding/moth_bullet
	pain_mult = 4
	embed_chance = 100
	fall_chance = 0

/obj/projectile/bullet/c9x25mm/bs/admin/rubber
	name = "9x25mm NT bluespace-moth rubber bullet"
	damage = 0
	stamina = 30
	wound_bonus = 0
	exposed_wound_bonus = 0

// MARK: .585 Sol
/obj/projectile/bullet/c585sol
	name = ".585 Sol bullet"
	damage = 30
	wound_bonus = -10
	wound_falloff_tile = -10

/obj/projectile/bullet/c585sol/rubber
	name = ".585 Sol rubber bullet"
	damage = 5
	stamina = 30
	wound_bonus = -20
	exposed_wound_bonus = -20
	weak_against_armour = TRUE
	ricochet_auto_aim_angle = 30
	ricochet_auto_aim_range = 5
	ricochets_max = 4
	ricochet_incidence_leeway = 50
	ricochet_chance = 130
	ricochet_decay_damage = 0.8
	shrapnel_type = null
	sharpness = NONE
	embed_type = null

/obj/projectile/bullet/c585sol/ap
	name = ".585 Sol armor-piercing bullet"
	armour_penetration = 50
	wound_bonus = 0
	exposed_wound_bonus = 0
	shrapnel_type = null
	embed_type = null

/obj/projectile/bullet/c585sol/hp
	name = ".585 Sol hollow-point bullet"
	damage = 40
	wound_bonus = 20
	exposed_wound_bonus = 20
	armour_penetration = 0
	weak_against_armour = TRUE
	sharpness = SHARP_EDGED

/obj/projectile/bullet/incendiary/c585sol
	name = ".585 Sol incendiary bullet"
	damage = 20
	fire_stacks = 2
	light_system = OVERLAY_LIGHT
	light_range = 2
	light_power = 1
	light_color = LIGHT_COLOR_INTENSE_RED
	leaves_fire_trail = FALSE

// MARK: .980 Grenades
#define GRENADE_SMOKE_RANGE 0.75
/obj/projectile/bullet/c980grenade
	name = ".980 Tydhouer practice grenade"
	damage = 20
	stamina = 30
	range = 14
	speed = 1
	sharpness = NONE

/obj/projectile/bullet/c980grenade/on_hit(atom/target, blocked = 0, pierce_hit)
	..()
	fuse_activation(target)
	return BULLET_ACT_HIT

/obj/projectile/bullet/c980grenade/on_range()
	fuse_activation(get_turf(src))
	return ..()

/// Generic proc that is called when the projectile should 'detonate', being either on impact or when the range runs out
/obj/projectile/bullet/c980grenade/proc/fuse_activation(atom/target)
	playsound(src, 'modular_bandastation/voyaker_events/sounds/weapon/grenade_burst.ogg', 50, TRUE, -3)
	do_sparks(3, FALSE, src)

/obj/projectile/bullet/c980grenade/shrapnel
	name = ".980 Tydhouer shrapnel grenade"
	/// What type of casing should we put inside the bullet to act as shrapnel later
	var/casing_to_spawn = /obj/item/grenade/c980payload

/obj/projectile/bullet/c980grenade/shrapnel/fuse_activation(atom/target)
	var/obj/item/grenade/shrapnel_maker = new casing_to_spawn(get_turf(target))
	shrapnel_maker.detonate()
	playsound(src, 'modular_bandastation/voyaker_events/sounds/weapon/grenade_burst.ogg', 50, TRUE, -3)
	qdel(shrapnel_maker)

/obj/item/grenade/c980payload
	shrapnel_type = /obj/projectile/bullet/shrapnel/shorter_range
	shrapnel_radius = 3
	ex_dev = 0
	ex_heavy = 0
	ex_light = 0
	ex_flame = 0

/obj/projectile/bullet/shrapnel/shorter_range
	range = 2

/obj/projectile/bullet/c980grenade/shrapnel/stingball
	name = ".980 Tydhouer stingball grenade"
	casing_to_spawn = /obj/item/grenade/c980payload/stingball

/obj/item/grenade/c980payload/stingball
	shrapnel_type = /obj/projectile/bullet/pellet/stingball/shorter_range
	shrapnel_radius = 3

/obj/projectile/bullet/pellet/stingball/shorter_range
	range = 10

/obj/projectile/bullet/c980grenade/smoke
	name = ".980 Tydhouer smoke grenade"

/obj/projectile/bullet/c980grenade/smoke/fuse_activation(atom/target)
	playsound(src, 'modular_bandastation/voyaker_events/sounds/weapon/grenade_burst.ogg', 50, TRUE, -3)
	playsound(src, 'sound/effects/smoke.ogg', 50, TRUE, -3)
	do_smoke(GRENADE_SMOKE_RANGE, holder = src, location = src, smoke_type = /datum/effect_system/fluid_spread/smoke/bad, effect_type = /obj/effect/particle_effect/fluid/smoke/bad)

/obj/projectile/bullet/c980grenade/shrapnel/phosphor
	name = ".980 Tydhouer phosphor grenade"
	casing_to_spawn = /obj/item/grenade/c980payload/phosphor

/obj/projectile/bullet/c980grenade/shrapnel/phosphor/fuse_activation(atom/target)
	. = ..()
	playsound(src, 'sound/effects/smoke.ogg', 50, TRUE, -3)
	do_smoke(GRENADE_SMOKE_RANGE, holder = src, location = src, smoke_type = /datum/effect_system/fluid_spread/smoke/quick, effect_type = /obj/effect/particle_effect/fluid/smoke/quick)

/obj/item/grenade/c980payload/phosphor
	shrapnel_type = /obj/projectile/bullet/incendiary/fire/backblast/short_range

/obj/projectile/bullet/incendiary/fire/backblast/short_range
	range = 2

/obj/projectile/bullet/c980grenade/riot
	name = ".980 Tydhouer tear gas grenade"

/obj/projectile/bullet/c980grenade/riot/fuse_activation(atom/target)
	playsound(src, 'modular_bandastation/voyaker_events/sounds/weapon/grenade_burst.ogg', 50, TRUE, -3)
	playsound(src, 'sound/effects/smoke.ogg', 50, TRUE, -3)
	do_chem_smoke(GRENADE_SMOKE_RANGE, holder = src, location = src, reagent_type = /datum/reagent/consumable/condensedcapsaicin, reagent_volume = 10)

#undef GRENADE_SMOKE_RANGE

// MARK: 40mm Grenades
/obj/projectile/bullet/a40mm
	name ="40mm grenade"
	icon = 'modular_bandastation/voyaker_events/icons/weapon/ammo.dmi'
	icon_state = "40mm_projectile"
	damage = 60
	embed_type = null
	shrapnel_type = null
	range = 30

/obj/projectile/bullet/a40mm/proc/payload(atom/target)
	explosion(target, devastation_range = -1, light_impact_range = 2, flame_range = 3, flash_range = 1, adminlog = FALSE, explosion_cause = src)

/obj/projectile/bullet/a40mm/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	payload(target)
	return BULLET_ACT_HIT

/obj/projectile/bullet/a40mm/on_range()
	payload(get_turf(src))
	return ..()

/obj/projectile/bullet/a40mm/proc/valid_turf(turf1, turf2)
	for(var/turf/line_turf in get_line(turf1, turf2))
		if(line_turf.is_blocked_turf(exclude_mobs = TRUE, source_atom = src))
			return FALSE
	return TRUE

// 40mm Rubber Slug Grenade
/obj/projectile/bullet/shotgun_beanbag/a40mm
	name = "40mm rubber slug"
	icon = 'modular_bandastation/voyaker_events/icons/weapon/ammo.dmi'
	icon_state = "40mmRUBBER_projectile"
	damage = 20
	stamina = 250 //BONK
	paralyze = 5 SECONDS
	wound_bonus = 30
	weak_against_armour = FALSE

// Weak 40mm Grenade
/obj/projectile/bullet/a40mm/weak
	name ="light 40mm grenade"
	damage = 30

/obj/projectile/bullet/a40mm/weak/payload(atom/target)
	explosion(target, devastation_range = -1, heavy_impact_range = -1, light_impact_range = 3, flame_range = 0, flash_range = 1, adminlog = FALSE, explosion_cause = src)

// // 40mm Incendiary Grenade
// /obj/projectile/bullet/a40mm/incendiary
// 	name ="40mm incendiary grenade"
// 	damage = 15

// /obj/projectile/bullet/a40mm/incendiary/payload(atom/target)
// 	if(iscarbon(target))
// 		var/mob/living/carbon/extra_crispy_carbon = target
// 		extra_crispy_carbon.adjust_fire_stacks(20)
// 		extra_crispy_carbon.ignite_mob()
// 		extra_crispy_carbon.apply_damage(30, BURN)

// 	var/turf/our_turf = get_turf(src)
// 	for(var/turf/nearby_turf as anything in circle_range_turfs(src, 3))
// 		if(valid_turf(our_turf, nearby_turf))
// 			var/obj/effect/hotspot/fire_tile = locate(nearby_turf) || new(nearby_turf)
// 			fire_tile.temperature = 800
// 			nearby_turf.hotspot_expose(500, 125, 1)
// 			for(var/mob/living/crispy_living in nearby_turf.contents)
// 				crispy_living.apply_damage(30, BURN)
// 				if(iscarbon(crispy_living))
// 					var/mob/living/carbon/crispy_carbon = crispy_living
// 					crispy_carbon.adjust_fire_stacks(10)
// 					crispy_carbon.ignite_mob()
// 	explosion(target, flame_range = 1, flash_range = 3, adminlog = FALSE, explosion_cause = src)

// 40mm Smoke Grenade
/obj/projectile/bullet/a40mm/smoke
	name ="40mm smoke grenade"
	icon = 'modular_bandastation/voyaker_events/icons/weapon/ammo.dmi'
	icon_state = "40mm_projectile"
	damage = 15

/obj/projectile/bullet/a40mm/smoke/payload(atom/target)
	explosion(target, devastation_range = 0, heavy_impact_range = 0, light_impact_range = 0, flame_range = 0, flash_range = 0, adminlog = FALSE, explosion_cause = src)
	do_smoke(2, holder = src, location = src, smoke_type = /datum/effect_system/fluid_spread/smoke/bad, effect_type = /obj/effect/particle_effect/fluid/smoke/bad)

// 40mm Stun Grenade
/obj/projectile/bullet/a40mm/stun
	name ="40mm stun grenade"
	icon = 'modular_bandastation/voyaker_events/icons/weapon/ammo.dmi'
	icon_state = "40mm_projectile"
	damage = 15

/obj/projectile/bullet/a40mm/stun/payload(atom/target)
	playsound(src, 'sound/items/weapons/flashbang.ogg', 100, TRUE, 8, 0.9)
	explosion(target, flame_range = 0, flash_range = 3, adminlog = FALSE, explosion_cause = src)
	do_sparks(rand(5, 9), FALSE, src)
	var/turf/our_turf = get_turf(src)
	for(var/turf/nearby_turf as anything in circle_range_turfs(src, 3))
		if(valid_turf(our_turf, nearby_turf))
			if(prob(50))
				do_sparks(rand(1, 9), FALSE, nearby_turf)
			for(var/mob/living/stunned_living in nearby_turf.contents)
				stunned_living.Paralyze(5 SECONDS)
				stunned_living.Knockdown(8 SECONDS)
				stunned_living.soundbang_act(1, 200, 10, 15)

// 40mm HEDP Grenade
/obj/projectile/bullet/a40mm/hedp
	name ="40mm HEDP grenade"
	icon = 'modular_bandastation/voyaker_events/icons/weapon/ammo.dmi'
	icon_state = "40mmHEDP_projectile"
	damage = 40
	var/anti_material_damage_bonus = 75

/obj/projectile/bullet/a40mm/hedp/payload(atom/target)
	explosion(target, heavy_impact_range = 0, light_impact_range = 2,  flash_range = 1, adminlog = FALSE, explosion_cause = src)

	if(ismecha(target))
		var/obj/vehicle/sealed/mecha/mecha = target
		mecha.take_damage(anti_material_damage_bonus)
	if(issilicon(target))
		var/mob/living/silicon/borgo = target
		borgo.gib()

	if(isstructure(target) || isvehicle (target) || isclosedturf (target) || ismachinery (target)) //if the target is a structure, machine, vehicle or closed turf like a wall, explode that shit
		if(isclosedturf(target)) //walls get blasted
			explosion(target, heavy_impact_range = 1, light_impact_range = 1, flash_range = 2, explosion_cause = src)
			return
		if(target.density) //Dense objects get blown up a bit harder
			explosion(target, light_impact_range = 1, flash_range = 2, explosion_cause = src)
			target.take_damage(anti_material_damage_bonus)
			return
		else
			explosion(target, light_impact_range = 1, flash_range = 2, explosion_cause = src)
			target.take_damage(anti_material_damage_bonus)

// 40mm Frag Grenade
/obj/projectile/bullet/a40mm/frag
	name ="40mm fragmentation grenade"
	icon = 'modular_bandastation/voyaker_events/icons/weapon/ammo.dmi'
	icon_state = "40mm_projectile"

/obj/projectile/bullet/a40mm/frag/payload(atom/target)
	var/obj/item/grenade/shrapnel_maker = new /obj/item/grenade/a40mm_frag(drop_location())
	shrapnel_maker.detonate()
	qdel(shrapnel_maker)

/obj/item/grenade/a40mm_frag
	name = "40mm fragmentation payload"
	desc = "An anti-personnel fragmentation payload. How the heck did this get here?"
	icon = 'modular_bandastation/voyaker_events/icons/weapon/ammo.dmi'
	icon_state = "40mm_projectile"
	shrapnel_type = /obj/projectile/bullet/shrapnel/a40mm_frag
	shrapnel_radius = 4
	det_time = 0
	display_timer = FALSE
	ex_light = 2

/obj/projectile/bullet/shrapnel/a40mm_frag
	name = "flying shrapnel hunk"
	range = 4
	dismemberment = 15
	ricochets_max = 6
	ricochet_chance = 75
	ricochet_incidence_leeway = 0
	ricochet_decay_chance = 0.9


/obj/item/ammo_casing/c9x25mm/bs
	name = "9x25mm NT bluespace bullet casing"
	desc = "Экспериментальный пистолетный блюспейс патрон НТ калибра 9x25мм. Пробивает броню и движется быстрее чем другие пули."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "srr-casing"
	projectile_type = /obj/projectile/bullet/c9x25mm/bs

/obj/item/ammo_casing/c9x25mm/bs/admin
	name = "9x25mm NT bluespace-M bullet casing"
	desc = "Эксперементальный пистолетный блюспейс патрон НТ калибра 9x25мм. Пробивает броню и движется быстрее чем другие пули."
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "srr-casing"
	projectile_type = /obj/projectile/bullet/c9x25mm/bs/admin

/obj/item/ammo_casing/c9x25mm/bs/admin/rubber
	name = "9x25mm NT bluespace-M rubber bullet casing"
	projectile_type = /obj/projectile/bullet/c9x25mm/bs/admin/rubber

// MARK: .585 Sol
/obj/item/ammo_casing/c585sol
	name = ".585 Sol bullet casing"
	desc = "Пистолетный безгильзовый патрон калибра .585 Sol."
	projectile_type = /obj/projectile/bullet/c585sol
	icon = 'modular_bandastation/voyaker_events/icons/weapon/ammo.dmi'
	icon_state = "585sol"
	caliber = CALIBER_585SOL

/obj/item/ammo_casing/c585sol/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/caseless)

/obj/item/ammo_casing/c585sol/rubber
	name = ".585 Sol rubber bullet casing"
	desc = "Травматический безгильзовый пистолетный патрон c резиновой пулей калибра .585 Sol."
	icon_state = "585sol_rubber"
	projectile_type = /obj/projectile/bullet/c585sol/rubber

/obj/item/ammo_casing/c585sol/ap
	name = ".585 Sol armor-piercing bullet casing"
	desc = "Бронебойный пистолетный безгильзовый патрон калибра .585 Sol."
	projectile_type = /obj/projectile/bullet/c585sol/ap
	icon_state = "585sol_ap"

/obj/item/ammo_casing/c585sol/hp
	name = ".585 Sol hollow-point bullet casing"
	desc = "Экспансивный пистолетный безгильзовый патрон калибра .585 Sol."
	projectile_type = /obj/projectile/bullet/c585sol/hp
	icon_state = "585sol_hp"

/obj/item/ammo_casing/c585sol/incendiary
	name = ".585 Sol incendiary bullet casing"
	desc = "Зажигательный пистолетный безгильзовый патрон калибра .585 Sol."
	projectile_type = /obj/projectile/bullet/incendiary/c585sol
	icon_state = "585sol_ic"

// MARK: .980 GRENADES
/obj/item/ammo_casing/c980grenade
	name = ".980 Tydhouer practice grenade"
	desc = "Большой гранатовый снаряд, который взрывается на расстоянии, заданном орудием, из которого он выпущен. Учебные снаряды распадаются на безвредные искры."
	icon = 'modular_bandastation/voyaker_events/icons/weapon/ammo.dmi'
	icon_state = "980_solid"
	caliber = CALIBER_980TYDHOUER
	projectile_type = /obj/projectile/bullet/c980grenade
	harmful = FALSE

/obj/item/ammo_casing/c980grenade/fire_casing(atom/target, mob/living/user, params, distro, quiet, zone_override, spread, atom/fired_from)
	var/obj/item/gun/ballistic/automatic/kiboko/firing_launcher = fired_from
	if(istype(firing_launcher))
		loaded_projectile.range = firing_launcher.target_range
	. = ..()

/obj/item/ammo_casing/c980grenade/smoke
	name = ".980 Tydhouer smoke grenade"
	desc = "Большой гранатовый снаряд, который взрывается на расстоянии, заданном орудием, из которого он выпущен. Взрывается, образуя облако дыма, ослабляющее лазеры."
	icon_state = "980_smoke"
	projectile_type = /obj/projectile/bullet/c980grenade/smoke

/obj/item/ammo_casing/c980grenade/shrapnel
	name = ".980 Tydhouer shrapnel grenade"
	desc = "Большой гранатовый снаряд, который взрывается на расстоянии, заданном орудием, из которого он выпущен. При взрыве разлетается на осколки."
	icon_state = "980_explosive"
	projectile_type = /obj/projectile/bullet/c980grenade/shrapnel
	harmful = TRUE

/obj/item/ammo_casing/c980grenade/shrapnel/stingball
	name = ".980 Tydhouer stingball grenade"
	desc = "Большой гранатовый снаряд, который взрывается на расстоянии, заданном орудием, из которого он выпущен. При взрыве разрывается на травматические осколки."
	icon_state = "980_stingball"
	projectile_type = /obj/projectile/bullet/c980grenade/shrapnel/stingball

/obj/item/ammo_casing/c980grenade/shrapnel/phosphor
	name = ".980 Tydhouer phosphor grenade"
	desc = "Большой гранатовый снаряд, который взрывается на расстоянии, заданном орудием, из которого он выпущен. Взрывается, образуя облако фосфора."
	icon_state = "980_gas_alternate"
	projectile_type = /obj/projectile/bullet/c980grenade/shrapnel/phosphor

/obj/item/ammo_casing/c980grenade/riot
	name = ".980 Tydhouer tear gas grenade"
	desc = "Большой гранатовый снаряд, который взрывается на расстоянии, заданном орудием, из которого он выпущен. Взрывается, образуя облако слезоточивого газа."
	icon_state = "980_gas"
	projectile_type = /obj/projectile/bullet/c980grenade/riot

// MARK: 40mm Grenades
/obj/item/ammo_casing/a40mm
	name = "40mm HE grenade"
	desc = "Граната калибра 40-мм, которая может быть активирована только после выстрела из гранатомета."
	caliber = CALIBER_40MM
	icon = 'modular_bandastation/voyaker_events/icons/weapon/ammo.dmi'
	icon_state = "40mmHE"
	projectile_type = /obj/projectile/bullet/a40mm
	custom_materials = list(/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT)

/obj/item/ammo_casing/a40mm/rubber
	name = "40mm rubber slug shell"
	desc = "Резиновый снаряд в 40-мм оболочке. Старший брат резиновой пули для дробовиков, этот снаряд сбивает с ног с одного удара. <br>Не очень эффективен против людей в броне."
	icon_state = "40mmRUBBER"
	projectile_type = /obj/projectile/bullet/shotgun_beanbag/a40mm

/obj/item/ammo_casing/a40mm/weak
	name = "light 40mm HE grenade"
	desc = parent_type::desc + "<br>Облегченная версия для юных гранатометчиков."
	icon_state = "40mm"
	projectile_type = /obj/projectile/bullet/a40mm/weak

/obj/item/ammo_casing/a40mm/incendiary
	name = "40mm incendiary grenade"
	desc = parent_type::desc + "<br>Зажигательная версия, при взрыве образует облако фосфорного дыма."
	icon_state = "40mmINCEN"
	projectile_type = /obj/projectile/bullet/a40mm/incendiary

/obj/item/ammo_casing/a40mm/smoke
	name = "40mm smoke grenade"
	desc = parent_type::desc + "<br>Дымовая версия, при взрыве образует облако дыма."
	icon_state = "40mmSMOKE"
	projectile_type = /obj/projectile/bullet/a40mm/smoke

/obj/item/ammo_casing/a40mm/stun
	name = "40mm stun grenade"
	desc = parent_type::desc + "<br>Светошумовая версия, при взрыве ослепляет и оглушает окружающих."
	icon_state = "40mmSTUN"
	projectile_type = /obj/projectile/bullet/a40mm/stun

/obj/item/ammo_casing/a40mm/hedp
	name = "40mm HEDP grenade"
	desc = parent_type::desc + "<br>Бронебойно-пробивная версия, уничтожает экзокостюмы и роботов, также может пробивать стены."
	icon_state = "40mmHEDP"
	projectile_type = /obj/projectile/bullet/a40mm/hedp

/obj/item/ammo_casing/a40mm/frag
	name = "40mm fragmentation grenade"
	desc = parent_type::desc + "<br>Осколочно-разрывная версия, при взрыве разбрасывает множество осколков."
	icon_state = "40mmFRAG"
	projectile_type = /obj/projectile/bullet/a40mm/frag

/obj/item/ammo_box/speedloader/a50ae_cylinder
	name = "speed loader (.50 AE)"
	desc = "Предназначен для быстрой перезарядки револьверов калибра .50 AE."
	icon = 'modular_bandastation/voyaker_events/icons/weapon/ammo.dmi'
	icon_state = "50speedload"
	ammo_type = /obj/item/ammo_casing/a50ae
	max_ammo = 5
	caliber = CALIBER_50AE
	multiple_sprites = AMMO_BOX_PER_BULLET
	item_flags = NO_MAT_REDEMPTION
	ammo_band_icon = "+38_ammo_band"
	ammo_band_color = null

/obj/item/ammo_box/speedloader/c38/ap
	name = "speed loader (.38 AP)"
	desc = parent_type::desc + "<br>Бронебойные пули хорошо пробивают броню, но наносят мало увечий."
	ammo_type = /obj/item/ammo_casing/c38/ap
	ammo_band_color = COLOR_AMMO_ARMORPIERCE

/obj/item/ammo_box/c45/incendiary
	name = "ammo box (.45 incendiary)"
	desc = parent_type::desc + "<br>Красная полоска указывает на то, что в ней должны храниться зажигательные боеприпасы."
	icon_state = "45box-incendiary"
	ammo_type = /obj/item/ammo_casing/c45/inc

// MARK: .585 Sol
/obj/item/ammo_box/c585sol
	name = "ammo box (.585 Sol)"
	desc = "Коробка с пистолетными патронами калибра .585 Sol, вмещает 30 патронов."
	icon = 'modular_bandastation/voyaker_events/icons/weapon/ammo.dmi'
	icon_state = "585box"
	w_class = WEIGHT_CLASS_SMALL
	caliber = CALIBER_585SOL
	ammo_type = /obj/item/ammo_casing/c585sol
	max_ammo = 30

/obj/item/ammo_box/c585sol/rubber
	name = "ammo box (.585 Sol rubber)"
	desc = parent_type::desc + "<br>Синяя полоска указывает на то, что здесь должны храниться нелетальные боеприпасы."
	icon_state = "585box_rubber"
	ammo_type = /obj/item/ammo_casing/c585sol/rubber

/obj/item/ammo_box/c585sol/hp
	name = "ammo box (.585 Sol hollow-point)"
	desc = parent_type::desc + "<br>Оранжевая полоска указывает на то, что в ней должны храниться экспансивные боеприпасы."
	icon_state = "585box_hp"
	ammo_type = /obj/item/ammo_casing/c585sol/hp

/obj/item/ammo_box/c585sol/ap
	name = "ammo box (.585 Sol armor-piercing)"
	desc = parent_type::desc + "<br>Серая полоска указывает на то, что в ней должны храниться бронебойные боеприпасы."
	icon_state = "585box_ap"
	ammo_type = /obj/item/ammo_casing/c585sol/ap

/obj/item/ammo_box/c585sol/incendiary
	name = "ammo box (.585 Sol incendiary)"
	desc = parent_type::desc + "<br>Красная полоска указывает на то, что в ней должны храниться зажигательные боеприпасы."
	icon_state = "585box_ic"
	ammo_type = /obj/item/ammo_casing/c585sol/incendiary

// MARK: .50 AE
/obj/item/ammo_box/a50ae
	name = "ammo box (.50 AE)"
	desc = "Коробка с винтовочными патронами калибра .50 AE, вмещает 20 патронов."
	icon = 'modular_bandastation/voyaker_events/icons/weapon/ammo.dmi'
	icon_state = "a50aebox"
	w_class = WEIGHT_CLASS_NORMAL
	caliber = CALIBER_50AE
	ammo_type = /obj/item/ammo_casing/a50ae
	max_ammo = 20

// MARK: .980 Grenades
/obj/item/ammo_box/c980grenade
	name = "ammo box (.980 Tydhouer practice)"
	desc = "Коробка с четырьмя учебными гранатами калибра .980 \"Тайдхойер\". Инструкции на коробке указывают, что это гранаты которые при взрыве распадаются на искры."
	icon = 'modular_bandastation/voyaker_events/icons/weapon/ammo.dmi'
	icon_state = "980box_solid"
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	w_class = WEIGHT_CLASS_NORMAL
	caliber = CALIBER_980TYDHOUER
	ammo_type = /obj/item/ammo_casing/c980grenade
	max_ammo = 4

/obj/item/ammo_box/c980grenade/shrapnel
	name = "ammo box (.980 Tydhouer shrapnel)"
	desc = "Коробка с четырьмя шрапнельными гранатами калибра .980 \"Тайдхойер\". На ней также нанесены знаки опасности, но кому они нужны?"
	icon_state = "980box_explosive"
	ammo_type = /obj/item/ammo_casing/c980grenade/shrapnel

/obj/item/ammo_box/c980grenade/shrapnel/stingball
	name = "ammo box (.980 Tydhouer stingball)"
	desc = "Коробка с четырьмя травматическими гранатами калибра .980 \"Тайдхойер\". На ней также нанесены знаки опасности, но кому они нужны?"
	icon_state = "980box_stingball"
	ammo_type = /obj/item/ammo_casing/c980grenade/shrapnel/stingball

/obj/item/ammo_box/c980grenade/shrapnel/phosphor
	name = "ammo box (.980 Tydhouer phosphor)"
	desc = "Коробка с четырьмя фосфорными гранатами калибра .980 \"Тайдхойер\". Инструкции на коробке указывают, что это зажигательные взрывные снаряды. На ней также нанесены знаки опасности, но кому они нужны?"
	icon_state = "980box_gas_alternate"
	ammo_type = /obj/item/ammo_casing/c980grenade/shrapnel/phosphor

/obj/item/ammo_box/c980grenade/smoke
	name = "ammo box (.980 Tydhouer smoke)"
	desc = "Коробка с четырьмя дымовыми гранатами калибра .980 \"Тайдхойер\". Инструкции на коробке указывают, что это дымовые снаряды, которые при взрыве образуют небольшое облако дыма, гасящего лазерное излучение."
	icon_state = "980box_smoke"
	ammo_type = /obj/item/ammo_casing/c980grenade/smoke

/obj/item/ammo_box/c980grenade/riot
	name = "ammo box (.980 Tydhouer tear gas)"
	desc = "Коробка с четырьмя гранатами со слезоточивым газом калибра .980 \"Тайдхойер\". Инструкции на коробке указывают, что это дымовые гранаты, которые при взрыве образуют небольшое облако слезоточивого газа."
	icon_state = "980box_gas"
	ammo_type = /obj/item/ammo_casing/c980grenade/riot

// MARK: 40mm GRENADE BOX
#define A40MM_GRENADE_INBOX_SPRITE_WIDTH 3
/datum/storage/a40mm_box
	max_slots = 4

/obj/item/storage/fancy/a40mm_box
	name = "40mm grenade box"
	desc = "Металлическая коробка, предназначенная для хранения 40-мм гранат."
	icon = 'modular_bandastation/voyaker_events/icons/weapon/ammo.dmi'
	icon_state = "40mm_box"
	base_icon_state = "40mm_box"
	spawn_type = /obj/item/ammo_casing/a40mm
	spawn_count = 4
	open_status = FALSE
	appearance_flags = KEEP_TOGETHER|LONG_GLIDE
	contents_tag = "grenade"
	foldable_result = null
	custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT*5)
	force = 8
	throwforce = 12
	throw_speed = 2
	throw_range = 7
	resistance_flags = null
	storage_type = /datum/storage/a40mm_box

/obj/item/storage/fancy/a40mm_box/Initialize(mapload)
	. = ..()
	atom_storage.set_holdable(list(/obj/item/ammo_casing/a40mm))

/obj/item/storage/fancy/a40mm_box/attack_self(mob/user)
	..()
	if(open_status == FANCY_CONTAINER_OPEN)
		playsound(src, 'sound/machines/click.ogg', 30, TRUE)

/obj/item/storage/fancy/a40mm_box/PopulateContents()
	. = ..()
	update_appearance()

/obj/item/storage/fancy/a40mm_box/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state][open_status ? "_open" : null]"

/obj/item/storage/fancy/a40mm_box/update_overlays()
	. = ..()
	if(!open_status)
		return

	var/grenades = 0
	for(var/_grenade in contents)
		var/obj/item/ammo_casing/a40mm/grenade = _grenade
		if (!istype(grenade))
			continue
		. += image(icon = initial(icon), icon_state = (initial(grenade.icon_state) + "_inbox"), pixel_x = grenades * A40MM_GRENADE_INBOX_SPRITE_WIDTH)
		grenades += 1

#undef A40MM_GRENADE_INBOX_SPRITE_WIDTH

/obj/item/storage/fancy/a40mm_box/rubber
	name = "40mm RUBBER grenade box"
	spawn_type = /obj/item/ammo_casing/a40mm/rubber

/obj/item/storage/fancy/a40mm_box/weak
	name = "40mm LIGHT grenade box"
	spawn_type = /obj/item/ammo_casing/a40mm/weak

/obj/item/storage/fancy/a40mm_box/incendiary
	name = "40mm INCENDIARY grenade box"
	spawn_type = /obj/item/ammo_casing/a40mm/incendiary

/obj/item/storage/fancy/a40mm_box/smoke
	name = "40mm SMOKE grenade box"
	spawn_type = /obj/item/ammo_casing/a40mm/smoke

/obj/item/storage/fancy/a40mm_box/stun
	name = "40mm STUN grenade box"
	spawn_type = /obj/item/ammo_casing/a40mm/stun

/obj/item/storage/fancy/a40mm_box/hedp
	name = "40mm HEDP grenade box"
	spawn_type = /obj/item/ammo_casing/a40mm/hedp

/obj/item/storage/fancy/a40mm_box/frag
	name = "40mm FRAG grenade box"
	spawn_type = /obj/item/ammo_casing/a40mm/frag
