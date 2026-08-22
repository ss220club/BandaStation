/obj/item/melee/energy/ekatana
	name = "energy katana"
	desc = "test"
	icon = 'icons/bandastation/obj/weapons/transforming_energy.dmi'
	icon_state = "ekatana"
	inhand_icon_state = "e_sword"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	var/attack_cooldown = 2 SECONDS
	COOLDOWN_DECLARE(next_attack)

/obj/item/melee/energy/ekatana/make_transformable()
	active_force = 35
	return ..()

/obj/item/melee/energy/ekatana/pre_attack(atom/target, mob/living/user, list/modifiers, list/attack_modifiers)
	. = ..()
	if(. || !HAS_TRAIT(src, TRAIT_TRANSFORM_ACTIVE) || !isliving(target))
		return .
	if(!COOLDOWN_FINISHED(src, next_attack))
		balloon_alert(user, "перезаряжается")
		return TRUE

/obj/item/melee/energy/ekatana/afterattack(atom/target, mob/user, list/modifiers)
	. = ..()
	if(!HAS_TRAIT(src, TRAIT_TRANSFORM_ACTIVE) || !isliving(target) || !COOLDOWN_FINISHED(src, next_attack))
		return

	var/mob/living/living_target = target
	living_target.Stun(1.5 SECONDS)
	COOLDOWN_START(src, next_attack, attack_cooldown)

