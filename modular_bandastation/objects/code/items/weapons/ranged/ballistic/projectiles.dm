// MARK: .35 Sol
/obj/projectile/bullet/c35sol
	name = ".35 Sol Short bullet"
	damage = 15
	wound_bonus = -5 // Normal bullets are 20
	bare_wound_bonus = 5
	embed_falloff_tile = -4

/obj/projectile/bullet/c35sol/rubber
	name = ".35 Sol Short rubber bullet"
	damage = 5
	stamina = 20
	wound_bonus = -40
	bare_wound_bonus = -20
	weak_against_armour = TRUE
	// The stats of the ricochet are a nerfed version of detective revolver rubber ammo
	// This is due to the fact that there's a lot more rounds fired quickly from weapons that use this, over a revolver
	ricochet_auto_aim_angle = 30
	ricochet_auto_aim_range = 5
	ricochets_max = 4
	ricochet_incidence_leeway = 50
	ricochet_chance = 130
	ricochet_decay_damage = 0.8
	shrapnel_type = null
	sharpness = NONE
	embed_type = null

/obj/projectile/bullet/c35sol/ripper
	name = ".35 Sol ripper bullet"
	damage = 12
	weak_against_armour = TRUE
	sharpness = SHARP_EDGED
	ricochets_max = 0
	wound_bonus = 20
	bare_wound_bonus = 20
	embed_type = /datum/embedding/bullet/c35sol/ripper
	embed_falloff_tile = -15

/datum/embedding/bullet/c35sol/ripper
	embed_chance = 75
	fall_chance = 3
	jostle_chance = 4
	ignore_throwspeed_threshold = TRUE
	pain_stam_pct = 0.4
	pain_mult = 5
	jostle_pain_mult = 6
	rip_time = 1 SECONDS

/obj/projectile/bullet/c35sol/ap
	name = ".35 Sol Short armor piercing bullet"
	damage = 13
	bare_wound_bonus = -30
	armour_penetration = 20

//  MARK: 7.62x39mm
/obj/projectile/bullet/a762x39/rubber
	name = "7.62x39mm rubber bullet"
	damage = 5
	armour_penetration = 0
	stamina = 20
	ricochets_max = 6
	ricochet_incidence_leeway = 0
	ricochet_chance = 130
	ricochet_decay_damage = 0.7
	shrapnel_type = null
	sharpness = NONE
	embed_type = null
	wound_bonus = -50

/obj/projectile/bullet/a762x39
	name = "7.62x39mm bullet"
	damage = 30
	wound_bonus = 15
	armour_penetration = 10
	wound_falloff_tile = 0

/obj/projectile/bullet/a762x39/ricochet
	name = "7.62x39mm match bullet"
	damage = 30
	wound_bonus = 5
	armour_penetration = 5
	ricochets_max = 2
	ricochet_chance = 100
	ricochet_auto_aim_angle = 30
	ricochet_auto_aim_range = 15
	ricochet_incidence_leeway = 40
	ricochet_decay_damage = 1
	ricochet_shoots_firer = FALSE

/obj/projectile/bullet/incendiary/a762x39
	name = "7.62x39mm incendiary bullet"
	damage = 30
	wound_bonus = 5
	armour_penetration = 0
	wound_falloff_tile = -5
	fire_stacks = 2
	leaves_fire_trail = FALSE

/obj/projectile/bullet/a762x39/emp
	name = "7.62x39mm ion bullet"
	damage = 25
	wound_bonus = 5
	armour_penetration = 5
	var/heavy_emp_radius = -1
	var/light_emp_radius = 0

/obj/projectile/bullet/a762x39/civilian
	name = "7.62x39mm civilian bullet"
	damage = 25
	wound_bonus = 5
	armour_penetration = 5
	wound_falloff_tile = 3

/obj/projectile/bullet/a762x39/hunting
	name = "7.62x39mm hunting bullet"
	damage = 20
	wound_bonus = 10
	armour_penetration = 0
	wound_falloff_tile = 3
	/// Bonus force dealt against certain mobs
	var/nemesis_bonus_force = 30
	/// List (not really a list) of mobs we deal bonus damage to
	var/list/nemesis_path = /mob/living/simple_animal

/obj/projectile/bullet/a762x39/blank
	name = "hot gas"
	icon = 'icons/obj/weapons/guns/projectiles_muzzle.dmi'
	icon_state = "muzzle_bullet"
	damage = 5
	damage_type = BURN
	wound_bonus = -100
	armour_penetration = 0
	wound_falloff_tile = 15
	weak_against_armour = TRUE
	range = 0.01
	shrapnel_type = null
	sharpness = NONE
	embed_type = null

/obj/projectile/bullet/a762x39/ap
	name = "7.62x39mm armor-piercing bullet"
	damage = 30
	wound_bonus = 15
	armour_penetration = 40

/obj/projectile/bullet/a762x39/gauss
	icon = 'modular_bandastation/objects/icons/obj/weapons/guns/projectiles.dmi'
	icon_state = "gauss_amk"
	name = "7.62x39mm gauss bullet"
	damage = 35
	wound_bonus = 15
	armour_penetration = 20
	light_system = OVERLAY_LIGHT
	light_range = 2
	light_power = 1
	light_color = LIGHT_COLOR_BLUE

// MARK: .40 Sol Long
/obj/projectile/bullet/c40sol
	name = ".40 Sol Long bullet"
	damage = 35
	wound_bonus = 10
	bare_wound_bonus = 20

/obj/projectile/bullet/c40sol/fragmentation
	name = ".40 Sol Long fragmentation bullet"
	damage = 5
	stamina = 25
	weak_against_armour = TRUE
	sharpness = SHARP_EDGED
	wound_bonus = 0
	bare_wound_bonus = 10
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

/obj/projectile/bullet/c40sol/pierce
	name = ".40 Sol pierce bullet"
	icon_state = "gaussphase"
	speed = 2
	damage = 30
	armour_penetration = 30
	wound_bonus = -30
	bare_wound_bonus = -10
	projectile_piercing = PASSMOB | PASSTABLE | PASSGRILLE | PASSMACHINE | PASSDOORS

/obj/projectile/bullet/c40sol/pierce/on_hit(atom/target, blocked = 0, pierce_hit)
	if(isliving(target))
		var/mob/living/poor_sap = target
		// If the target mob has enough armor to stop the bullet, or the bullet has already gone through two people, stop it on this hit
		if((poor_sap.run_armor_check(def_zone, BULLET, "", "", silent = TRUE) > 20) || (pierces > 2))
			projectile_piercing = NONE

			if(damage > 10) // Lets just be safe with this one
				damage -= 5
			armour_penetration -= 10

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

// MARK: Visual effect after firing (muzzle flash)
/obj/effect/temp_visual/dir_setting/firing_effect
	light_system = OVERLAY_LIGHT
	light_range = 2
	light_power = 1
	light_color = LIGHT_COLOR_FIRE
