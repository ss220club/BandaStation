/obj/item/melee/energy/ekatana
	name = "Тактическая катана 'Багровый порез'"
	desc = "Энергетическая Катана, созданная при помощи новых технологий Синдиката. Она способна наносить урон, а также оглушать противника при нанесении удара."
	icon = 'icons/bandastation/obj/weapons/transforming_energy.dmi'
	icon_state = "ekatana"
	base_icon_state = "ekatana_on"
	icon_angle = 35
	light_system = OVERLAY_LIGHT
	light_range = 2
	light_color = LIGHT_COLOR_LIGHT_CYAN
	force = 0
	armour_penetration = 70
	block_chance = 60
	throwforce = 0
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	hitsound = 'modular_bandastation/weapon/sound/melee/tsf_katana_hit.ogg'
	pickup_sound = 'modular_bandastation/weapon/sound/melee/tsf_katana_unsheath.ogg'
	drop_sound = 'modular_bandastation/weapon/sound/melee/tsf_katana_sheath.ogg'
	block_sound = 'modular_bandastation/weapon/sound/melee/tsf_katana_block.ogg'
	attack_verb_continuous = list("attacks", "slashes", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("attack", "slash", "slice", "tear", "lacerate", "rip", "dice", "cut")
	sharpness = NONE
	active_force = 40
	active_throwforce = 30
	active_throw_speed = 4
	active_sharpness = SHARP_EDGED
	active_w_class = WEIGHT_CLASS_HUGE

	var/next_strike = 0

/obj/item/melee/energy/ekatana/attack(mob/living/target, mob/living/user, params)
	if(world.time < next_strike)
		return FALSE

	next_strike = world.time + 15
	. = ..()
	if(. && target && HAS_TRAIT(src, TRAIT_TRANSFORM_ACTIVE))
		target.Stun(5)
