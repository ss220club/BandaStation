/obj/item/melee/energy/ekatanka
	name = "energy katana"
	desc = "Энергетическая катана, созданная при помощи новых технологий Синдиката. Она способна наносить большой урон, а также оглушать противника при попадании. Имеет задержку при ударе."
	icon = 'icons/bandastation/obj/weapons/transforming_energy.dmi'
	icon_state = "ekatanka"
	inhand_icon_state = "ekatanka"
	lefthand_file = 'modular_bandastation/weapon/icons/melee/inhands/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/melee/inhands/righthand.dmi'
	var/attack_cooldown = 2 SECONDS
	COOLDOWN_DECLARE(next_attack)

/obj/item/melee/energy/ekatanka/make_transformable()
	active_force = 35
	return ..()

/obj/item/melee/energy/ekatanka/pre_attack(atom/target, mob/living/user, list/modifiers, list/attack_modifiers)
	. = ..()
	if(. || !HAS_TRAIT(src, TRAIT_TRANSFORM_ACTIVE) || !isliving(target))
		return .
	if(!COOLDOWN_FINISHED(src, next_attack))
		balloon_alert(user, "перезаряжается")
		return TRUE

/obj/item/melee/energy/ekatanka/afterattack(mob/living/user, mob/living/target)
	. = ..()
	if(!HAS_TRAIT(src, TRAIT_TRANSFORM_ACTIVE) || !isliving(target) || !COOLDOWN_FINISHED(src, next_attack))
		return

	var/mob/living/living_target = target
	living_target.Knockdown(1 SECONDS)
	living_target.Stun(1.5 SECONDS)
	COOLDOWN_START(src, next_attack, attack_cooldown)

