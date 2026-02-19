// MARK: .35 Sol
/obj/projectile/bullet/c35sol
	name = ".35 Sol Short bullet"
	damage = 17
	wound_bonus = -5
	exposed_wound_bonus = 5
	embed_falloff_tile = -4

/obj/projectile/bullet/c35sol/rubber
	name = ".35 Sol Short rubber bullet"
	damage = 5
	stamina = 20
	wound_bonus = -40
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

/obj/projectile/bullet/c35sol/hp
	name = ".35 Sol hollow-point bullet"
	damage = 15
	weak_against_armour = TRUE
	sharpness = SHARP_EDGED
	wound_bonus = 20
	exposed_wound_bonus = 20
	embed_type = /datum/embedding/bullet/c35sol/hp
	embed_falloff_tile = -15

/datum/embedding/bullet/c35sol/hp
	embed_chance = 75
	fall_chance = 3
	jostle_chance = 4
	ignore_throwspeed_threshold = TRUE
	pain_stam_pct = 0.4
	pain_mult = 5
	jostle_pain_mult = 6
	rip_time = 1 SECONDS

/obj/projectile/bullet/c35sol/ap
	name = ".35 Sol Short armor-piercing bullet"
	damage = 15
	exposed_wound_bonus = -30
	armour_penetration = 40
	shrapnel_type = null
	embed_type = null

//  MARK: 7.62x39mm
/obj/projectile/bullet/c762x39
	name = "7.62x39mm bullet"
	damage = 30
	wound_bonus = 5
	armour_penetration = 10
	exposed_wound_bonus = 5
	wound_falloff_tile = -3

/obj/projectile/bullet/c762x39/rubber
	name = "7.62x39mm rubber bullet"
	damage = 5
	stamina = 25
	armour_penetration = 0
	ricochets_max = 4
	ricochet_incidence_leeway = 0
	ricochet_chance = 130
	ricochet_decay_damage = 0.7
	shrapnel_type = null
	sharpness = NONE
	embed_type = null
	wound_bonus = -40
	exposed_wound_bonus = -20
	weak_against_armour = TRUE

/obj/projectile/bullet/c762x39/ricochet
	name = "7.62x39mm match bullet"
	damage = 25
	armour_penetration = 5
	ricochets_max = 5
	ricochet_chance = 100
	ricochet_auto_aim_angle = 30
	ricochet_auto_aim_range = 15
	ricochet_incidence_leeway = 40
	ricochet_decay_damage = 1
	ricochet_shoots_firer = FALSE

/obj/projectile/bullet/incendiary/c762x39
	name = "7.62x39mm incendiary bullet"
	damage = 30
	wound_falloff_tile = -5
	fire_stacks = 2
	leaves_fire_trail = FALSE

/obj/projectile/bullet/c762x39/emp
	name = "7.62x39mm ion bullet"
	damage = 25
	wound_bonus = 0
	armour_penetration = 5
	var/heavy_emp_radius = -1
	var/light_emp_radius = 0

/obj/projectile/bullet/c762x39/emp/on_hit(atom/target, blocked = FALSE, pierce_hit)
	..()
	empulse(target, heavy_emp_radius, light_emp_radius)
	return BULLET_ACT_HIT

/obj/projectile/bullet/c762x39/civilian
	name = "7.62x39mm civilian bullet"
	damage = 25
	wound_bonus = 0
	armour_penetration = 0

/obj/projectile/bullet/c762x39/hunting
	name = "7.62x39mm hunting bullet"
	damage = 20
	wound_bonus = 10
	armour_penetration = 0
	weak_against_armour = TRUE
	/// Bonus force dealt against certain mobs
	var/nemesis_bonus_force = 30
	/// List (not really a list) of mobs we deal bonus damage to
	var/list/nemesis_path = /mob/living/basic

/obj/projectile/bullet/c762x39/hunting/prehit_pierce(mob/living/target, mob/living/carbon/human/user)
	if(istype(target, nemesis_path))
		damage += nemesis_bonus_force
	.=..()

/obj/projectile/bullet/c762x39/blank
	name = "hot gas"
	icon = 'icons/obj/weapons/guns/projectiles_muzzle.dmi'
	icon_state = "muzzle_bullet"
	damage = 5
	damage_type = BURN
	wound_bonus = -100
	armour_penetration = 0
	weak_against_armour = TRUE
	range = 0.01
	shrapnel_type = null
	sharpness = NONE
	embed_type = null

/obj/projectile/bullet/c762x39/ap
	name = "7.62x39mm armor-piercing bullet"
	damage = 25
	armour_penetration = 50
	wound_bonus = 0
	exposed_wound_bonus = 0
	shrapnel_type = null
	embed_type = null

/obj/projectile/bullet/c762x39/gauss
	icon = 'modular_bandastation/weapon/icons/ranged/projectiles.dmi'
	icon_state = "gauss_amk"
	name = "7.62x39mm gauss bullet"
	damage = 35
	wound_bonus = 15
	armour_penetration = 50
	projectile_piercing = PASSMOB | PASSTABLE | PASSGRILLE | PASSMACHINE | PASSDOORS
	light_system = OVERLAY_LIGHT
	light_range = 2
	light_power = 1
	light_color = LIGHT_COLOR_BLUE
	shrapnel_type = null
	embed_type = null

/obj/projectile/bullet/c762x39/gauss/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(isliving(target))
		if(blocked > 80 || pierces > 2)
			projectile_piercing = NONE
			damage = max(0, damage - 20)
			armour_penetration = max(0, armour_penetration - 20)
			wound_bonus = max(0, wound_bonus - 10)

	return ..()

// MARK: .40 Sol Long
/obj/projectile/bullet/c40sol
	name = ".40 Sol Long bullet"
	damage = 35
	armour_penetration = 10
	wound_bonus = 5
	exposed_wound_bonus = 5
	wound_falloff_tile = -3

/obj/projectile/bullet/c40sol/fragmentation
	name = ".40 Sol Long rubber-fragmentation bullet"
	damage = 5
	stamina = 25
	weak_against_armour = TRUE
	sharpness = SHARP_EDGED
	wound_bonus = -10
	exposed_wound_bonus = 10
	armour_penetration = 0
	shrapnel_type = /obj/item/shrapnel/stingball
	embed_type = /datum/embedding/c40sol_fragmentation
	embed_falloff_tile = -5

/datum/embedding/c40sol_fragmentation
	embed_chance = 50
	fall_chance = 5
	jostle_chance = 5
	ignore_throwspeed_threshold = TRUE
	pain_stam_pct = 0.4
	pain_mult = 2
	jostle_pain_mult = 3
	rip_time = 0.5 SECONDS

/obj/projectile/bullet/c40sol/ap
	name = ".40 Sol armor-piercing bullet"
	icon_state = "gaussphase"
	damage = 30
	armour_penetration = 60
	speed = 2
	wound_bonus = 0
	exposed_wound_bonus = 0
	projectile_piercing = PASSMOB | PASSTABLE | PASSGRILLE | PASSMACHINE | PASSDOORS
	shrapnel_type = null
	embed_type = null

/obj/projectile/bullet/c40sol/ap/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(isliving(target))
		if(blocked > 40 || pierces > 2)
			projectile_piercing = NONE
			damage = max(0, damage - 15)
			armour_penetration = max(0, armour_penetration - 15)

	return ..()

/obj/projectile/bullet/incendiary/c40sol
	name = ".40 Sol Long incendiary bullet"
	icon_state = "redtrac"
	light_system = OVERLAY_LIGHT
	light_range = 2
	light_power = 1
	light_color = LIGHT_COLOR_INTENSE_RED
	damage = 30
	fire_stacks = 2
	leaves_fire_trail = FALSE

// MARK: .50 BMG
/obj/projectile/bullet/p50/mmg
	name =".50 BMG caseless bullet"
	damage = 40
	armour_penetration = 0
	paralyze = 0
	dismemberment = 0
	catastropic_dismemberment = FALSE
	icon_state = "gaussstrong"
	light_system = OVERLAY_LIGHT
	light_range = 2
	light_power = 1
	light_color = LIGHT_COLOR_FIRE

// MARK: 9x25mm NT
/obj/projectile/bullet/c9x25mm
	name = "9x25mm NT bullet"
	damage = 17
	wound_bonus = -5
	exposed_wound_bonus = 5
	embed_falloff_tile = -4

/obj/projectile/bullet/c9x25mm/rubber
	name = "9x25mm NT rubber bullet"
	damage = 5
	stamina = 20
	wound_bonus = -40
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

/obj/projectile/bullet/c9x25mm/hp
	name = "9x25mm NT hollow-point bullet"
	damage = 15
	weak_against_armour = TRUE
	sharpness = SHARP_EDGED
	wound_bonus = 20
	exposed_wound_bonus = 20
	embed_type = /datum/embedding/bullet/c9x25mm/hp
	embed_falloff_tile = -15

/datum/embedding/bullet/c9x25mm/hp
	embed_chance = 75
	fall_chance = 3
	jostle_chance = 4
	ignore_throwspeed_threshold = TRUE
	pain_stam_pct = 0.4
	pain_mult = 5
	jostle_pain_mult = 6
	rip_time = 1 SECONDS

/obj/projectile/bullet/c9x25mm/ap
	name = "9x25mm NT armor-piercing bullet"
	damage = 15
	exposed_wound_bonus = -30
	armour_penetration = 40
	shrapnel_type = null
	embed_type = null

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

// MARK: .223 aka 5.56mm
/obj/projectile/bullet/a223
	name = "5.56x45mm bullet"
	damage = 30
	armour_penetration = 10
	wound_bonus = 5
	exposed_wound_bonus = 5
	wound_falloff_tile = -3

/obj/projectile/bullet/a223/rubber
	name = "5.56x45mm rubber bullet"
	damage = 5
	stamina = 25
	armour_penetration = 0
	wound_bonus = -40
	exposed_wound_bonus = -20
	weak_against_armour = TRUE

/obj/projectile/bullet/a223/hp
	name = "5.56x45mm hollow-point bullet"
	damage = 35
	armour_penetration = 0
	wound_bonus = 30
	exposed_wound_bonus = 30
	weak_against_armour = TRUE

/obj/projectile/bullet/a223/ap
	name = "5.56x45mm armor-piercing bullet"
	damage = 25
	armour_penetration = 50
	wound_bonus = 0
	exposed_wound_bonus = 0
	shrapnel_type = null
	embed_type = null

/obj/projectile/bullet/incendiary/a223
	name = "5.56x45mm incendiary bullet"
	icon_state = "redtrac"
	light_system = OVERLAY_LIGHT
	light_range = 2
	light_power = 1
	light_color = LIGHT_COLOR_INTENSE_RED
	damage = 25
	fire_stacks = 2
	leaves_fire_trail = FALSE

// MARK: 7.62x51mm
/obj/projectile/bullet/c762x51mm
	name = "7.62x51mm bullet"
	damage = 35
	armour_penetration = 10
	wound_bonus = 5
	exposed_wound_bonus = 5
	wound_falloff_tile = -3

/obj/projectile/bullet/c762x51mm/rubber
	name = "7.62x51mm rubber bullet"
	damage = 5
	stamina = 30
	wound_bonus = -40
	exposed_wound_bonus = -20
	armour_penetration = 0
	weak_against_armour = TRUE
	sharpness = NONE

/obj/projectile/bullet/c762x51mm/hp
	name = "7.62x51mm hollow-point bullet"
	damage = 40
	wound_bonus = 30
	exposed_wound_bonus = 30
	armour_penetration = 0
	weak_against_armour = TRUE
	sharpness = SHARP_EDGED

/obj/projectile/bullet/c762x51mm/ap
	name = "7.62x51mm armor-piercing bullet"
	damage = 30
	wound_bonus = 0
	exposed_wound_bonus = 0
	armour_penetration = 60
	shrapnel_type = null
	embed_type = null

/obj/projectile/bullet/incendiary/c762x51mm
	name = "7.62x51mm incendiary bullet"
	icon_state = "redtrac"
	light_system = OVERLAY_LIGHT
	light_range = 2
	light_power = 1
	light_color = LIGHT_COLOR_INTENSE_RED
	damage = 30
	fire_stacks = 3
	leaves_fire_trail = FALSE

// MARK: .388 aka 8.6x70mm
/obj/projectile/bullet/c338
	name = ".338 bullet"
	damage = 55
	range = 80
	wound_bonus = 20
	exposed_wound_bonus = 15
	armour_penetration = 30
	wound_falloff_tile = -1
	speed = 2

/obj/projectile/bullet/c338/ap
	name = ".338 armor-piercing bullet"
	damage = 50
	wound_bonus = 0
	exposed_wound_bonus = 0
	armour_penetration = 75
	shrapnel_type = null
	embed_type = null

/obj/projectile/bullet/c338/hp
	name = ".338 hollow-point bullet"
	damage = 60
	wound_bonus = 45
	exposed_wound_bonus = 45
	armour_penetration = 10
	weak_against_armour = TRUE
	sharpness = SHARP_EDGED

/obj/projectile/bullet/incendiary/c338
	name = ".338 incendiary bullet"
	icon_state = "redtrac"
	light_system = OVERLAY_LIGHT
	light_range = 2
	light_power = 1
	light_color = LIGHT_COLOR_INTENSE_RED
	damage = 50
	fire_stacks = 4
	leaves_fire_trail = FALSE

// MARK: .38
/obj/projectile/bullet/c38/ap
	name = ".38 armor-piercing bullet"
	damage = 20
	ricochets_max = 0
	armour_penetration = 40

// MARK: 9mm
/obj/projectile/bullet/c9mm/rubber
	name = "9mm rubber bullet"
	damage = 5
	stamina = 20
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

/obj/projectile/bullet/incendiary/c9mm
	leaves_fire_trail = FALSE

// MARK: 10mm
/obj/projectile/bullet/c10mm/rubber
	name = "10mm rubber bullet"
	damage = 5
	stamina = 25
	wound_bonus = -40
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

// MARK: .45
/obj/projectile/bullet/c45/rubber
	name = ".45 rubber bullet"
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

/obj/projectile/bullet/incendiary/c45
	leaves_fire_trail = FALSE

// MARK: 4.6x30mm
/obj/projectile/bullet/c46x30mm/rubber
	name = "4.6x30mm rubber bullet"
	damage = 5
	stamina = 20
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

// MARK: .310 Strilka
/obj/projectile/bullet/strilka310/rubber
	name = ".310 Strilka rubber bullet"
	damage = 5
	stamina = 30
	wound_bonus = -40
	exposed_wound_bonus = -20
	armour_penetration = 0
	weak_against_armour = TRUE
	sharpness = NONE

/obj/projectile/bullet/strilka310/ap
	name = ".310 Strilka armor-piercing bullet"
	damage = 50
	armour_penetration = 60
	wound_bonus = 0

/obj/projectile/bullet/strilka310/hp
	name = ".310 Strilka hollow-point bullet"
	damage = 60
	wound_bonus = 45
	exposed_wound_bonus = 45
	armour_penetration = 10
	weak_against_armour = TRUE
	sharpness = SHARP_EDGED

/obj/projectile/bullet/incendiary/strilka310
	name = ".310 Strilka incendiary bullet"
	icon_state = "redtrac"
	damage = 40
	light_system = OVERLAY_LIGHT
	light_range = 2
	light_power = 1
	light_color = LIGHT_COLOR_INTENSE_RED
	fire_stacks = 3
	leaves_fire_trail = FALSE

// MARK: .60 Strela
/obj/projectile/bullet/p50/strela60
	name =".60 Strela bullet"
	damage = 80
	icon_state = "gaussstrong"
	speed = 2
	range = 100
	damage = 50
	light_system = OVERLAY_LIGHT
	light_range = 2
	light_power = 1
	light_color = LIGHT_COLOR_FIRE

// MARK: 12.7x108mm
/obj/projectile/bullet/c127x108mm
	name ="12.7x108mm bullet"
	icon_state = "gaussstrong"
	speed = 2
	range = 100
	damage = 50
	light_system = OVERLAY_LIGHT
	light_range = 2
	light_power = 1
	light_color = LIGHT_COLOR_FIRE

// MARK: 7.62x54mmR
/obj/projectile/bullet/c762x54mmr
	name = "7.62x54mmR bullet"
	damage = 35
	armour_penetration = 10
	wound_bonus = 5
	exposed_wound_bonus = 5
	wound_falloff_tile = -3

/obj/projectile/bullet/c762x54mmr/rubber
	name = "7.62x54mmR rubber bullet"
	damage = 5
	stamina = 30
	wound_bonus = -40
	exposed_wound_bonus = -20
	armour_penetration = 0
	weak_against_armour = TRUE
	sharpness = NONE

/obj/projectile/bullet/c762x54mmr/hp
	name = "7.62x54mmR hollow-point bullet"
	damage = 40
	wound_bonus = 30
	exposed_wound_bonus = 30
	armour_penetration = 0
	weak_against_armour = TRUE
	sharpness = SHARP_EDGED

/obj/projectile/bullet/c762x54mmr/ap
	name = "7.62x54mmR armor-piercing bullet"
	damage = 30
	wound_bonus = 0
	exposed_wound_bonus = 0
	armour_penetration = 60
	shrapnel_type = null
	embed_type = null

/obj/projectile/bullet/incendiary/c762x54mmr
	name = "7.62x54mmR incendiary bullet"
	icon_state = "redtrac"
	light_system = OVERLAY_LIGHT
	light_range = 2
	light_power = 1
	light_color = LIGHT_COLOR_INTENSE_RED
	damage = 30
	fire_stacks = 3
	leaves_fire_trail = FALSE

// MARK: .456 Magnum
/obj/projectile/bullet/c456magnum
	name = ".456 magnum bullet"
	damage = 60
	armour_penetration = 40
	wound_falloff_tile = -1

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
	playsound(src, 'modular_bandastation/weapon/sound/ranged/grenade_burst.ogg', 50, TRUE, -3)
	do_sparks(3, FALSE, src)

/obj/projectile/bullet/c980grenade/shrapnel
	name = ".980 Tydhouer shrapnel grenade"
	/// What type of casing should we put inside the bullet to act as shrapnel later
	var/casing_to_spawn = /obj/item/grenade/c980payload

/obj/projectile/bullet/c980grenade/shrapnel/fuse_activation(atom/target)
	var/obj/item/grenade/shrapnel_maker = new casing_to_spawn(get_turf(target))
	shrapnel_maker.detonate()
	playsound(src, 'modular_bandastation/weapon/sound/ranged/grenade_burst.ogg', 50, TRUE, -3)
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
	playsound(src, 'modular_bandastation/weapon/sound/ranged/grenade_burst.ogg', 50, TRUE, -3)
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
	playsound(src, 'modular_bandastation/weapon/sound/ranged/grenade_burst.ogg', 50, TRUE, -3)
	playsound(src, 'sound/effects/smoke.ogg', 50, TRUE, -3)
	do_chem_smoke(GRENADE_SMOKE_RANGE, holder = src, location = src, reagent_type = /datum/reagent/consumable/condensedcapsaicin, reagent_volume = 10)

#undef GRENADE_SMOKE_RANGE

// MARK: 40mm Grenades
/obj/projectile/bullet/a40mm
	name ="40mm grenade"
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
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
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "40mmRUBBER_projectile"
	damage = 20
	stamina = 250 //BONK
	paralyze = 5 SECONDS
	wound_bonus = 30
	weak_against_armour = TRUE

// Weak 40mm Grenade
/obj/projectile/bullet/a40mm/weak
	name ="light 40mm grenade"
	damage = 30

/obj/projectile/bullet/a40mm/weak/payload(atom/target)
	explosion(target, devastation_range = -1, heavy_impact_range = -1, light_impact_range = 3, flame_range = 0, flash_range = 1, adminlog = FALSE, explosion_cause = src)

// 40mm Incendiary Grenade
/obj/projectile/bullet/a40mm/incendiary
	name ="40mm incendiary grenade"
	damage = 15

/obj/projectile/bullet/a40mm/incendiary/payload(atom/target)
	if(iscarbon(target))
		var/mob/living/carbon/extra_crispy_carbon = target
		extra_crispy_carbon.adjust_fire_stacks(20)
		extra_crispy_carbon.ignite_mob()
		extra_crispy_carbon.apply_damage(30, BURN)

	var/turf/our_turf = get_turf(src)
	for(var/turf/nearby_turf as anything in circle_range_turfs(src, 3))
		if(valid_turf(our_turf, nearby_turf))
			var/obj/effect/hotspot/fire_tile = locate(nearby_turf) || new(nearby_turf)
			fire_tile.temperature = 800
			nearby_turf.hotspot_expose(500, 125, 1)
			for(var/mob/living/crispy_living in nearby_turf.contents)
				crispy_living.apply_damage(30, BURN)
				if(iscarbon(crispy_living))
					var/mob/living/carbon/crispy_carbon = crispy_living
					crispy_carbon.adjust_fire_stacks(10)
					crispy_carbon.ignite_mob()
	explosion(target, flame_range = 1, flash_range = 3, adminlog = FALSE, explosion_cause = src)

// 40mm Smoke Grenade
/obj/projectile/bullet/a40mm/smoke
	name ="40mm smoke grenade"
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "40mm_projectile"
	damage = 15

/obj/projectile/bullet/a40mm/smoke/payload(atom/target)
	explosion(target, devastation_range = null, heavy_impact_range = null, light_impact_range = null, flame_range = null, flash_range = null, adminlog = FALSE, explosion_cause = src)
	do_smoke(4, holder = src, location = src, smoke_type = /datum/effect_system/fluid_spread/smoke/bad, effect_type = /obj/effect/particle_effect/fluid/smoke/bad)

// 40mm Stun Grenade
/obj/projectile/bullet/a40mm/stun
	name ="40mm stun grenade"
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
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
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
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
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "40mm_projectile"

/obj/projectile/bullet/a40mm/frag/payload(atom/target)
	var/obj/item/grenade/shrapnel_maker = new /obj/item/grenade/a40mm_frag(drop_location())
	shrapnel_maker.detonate()
	qdel(shrapnel_maker)

/obj/item/grenade/a40mm_frag
	name = "40mm fragmentation payload"
	desc = "An anti-personnel fragmentation payload. How the heck did this get here?"
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
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

//MARK: Shotgun shells
/obj/projectile/bullet/shotgun_breaching/on_hit(atom/target, blocked = 0, pierce_hit)
	if(istype(target, /obj/structure/blob) || istype(target, /obj/structure/carp_rift))
		target.take_damage(30, damage_type, 0)
		return TRUE
	return ..()
