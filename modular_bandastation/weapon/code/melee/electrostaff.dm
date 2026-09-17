/obj/item/melee/baton/security/electrostaff
	name = "electrostaff"
	desc = "Шоковая дубинка, только более мощная, двуручная и доступная наиболее авторитетным членам силовых структур Нанотрейзен. А ещё у неё нет тупого конца."
	icon = 'modular_bandastation/weapon/icons/melee/electrostaff.dmi'
	base_icon_state = "electrostaff_orange"
	icon_state = "electrostaff_orange"
	inhand_icon_state = "electrostaff_orange"
	lefthand_file = 'modular_bandastation/weapon/icons/melee/inhands/electrostaff_lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/melee/inhands/electrostaff_righthand.dmi'
	/// What sound plays when its opening
	var/sound_on = 'modular_bandastation/weapon/sound/melee/electrostaff_on.ogg'

	block_chance = 0
	var/block_chance_two_handed = 50
	block_sound = 'sound/items/weapons/block_blade.ogg'

	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_HUGE
	force = 5
	var/two_hand_force = 10
	throwforce = 7
	throw_range = 5
	/// Additional burn damage dealt by a powered Harm attack.
	var/burn_damage = 5

	cell_hit_cost = round(STANDARD_CELL_CHARGE * 1.5)
	stamina_damage = 80
	var/depleted_stamina_damage = 20
	cooldown = (3.5 SECONDS)
	knockdown_time = (2.5 SECONDS)
	/// The hit sound used when the staff is out of power.
	var/depleted_hit_sound = 'sound/effects/woodhit.ogg'

// Initialize the two-handed and reskin components.
/obj/item/melee/baton/security/electrostaff/Initialize(mapload)
	. = ..()

	AddComponent(/datum/component/two_handed, \
		force_unwielded = force, \
		force_wielded = two_hand_force, \
		wield_callback = CALLBACK(src, PROC_REF(on_wield)), \
		unwield_callback = CALLBACK(src, PROC_REF(on_unwield)), \
	)

	AddComponent(/datum/component/reskinable_item, /datum/atom_skin/electrostaff)

	update_appearance()

// Variant that starts with a high-capacity cell.
/obj/item/melee/baton/security/electrostaff/loaded
	preload_cell_type = /obj/item/stock_parts/power_store/cell/high

// Handle switching between one-handed and two-handed grip.
/obj/item/melee/baton/security/electrostaff/attack_self(mob/user)
	var/datum/component/two_handed/twohanded = GetComponent(/datum/component/two_handed)

	if(!twohanded)
		return

	if(twohanded.wielded)
		twohanded.unwield(user)
		return

	if(user.is_holding(src))
		twohanded.wield(user)
		return

//Check whether the battery has enough charge for an electric attack.
/obj/item/melee/baton/security/electrostaff/proc/has_power()
	return cell && cell.charge >= cell_hit_cost

// Allow a powered-down staff to use the stun attack as a physical two-handed strike
/obj/item/melee/baton/security/electrostaff/try_stun(
	mob/living/target,
	mob/living/user,
	harmbatonning
)
	if(!has_power() && HAS_TRAIT(src, TRAIT_WIELDED))
		var/was_staff_active = active
		active = TRUE
		. = ..()
		active = was_staff_active
		return

	return ..()

// Replace the electric effect with a physical strike when the staff has no power.
/obj/item/melee/baton/security/electrostaff/baton_effect(
	mob/living/target,
	mob/living/user,
	stun_override,
	clumsy
)
	if(!has_power())
		target.apply_damage(depleted_stamina_damage, STAMINA)
		target.Knockdown(knockdown_time)
		playsound(src, depleted_hit_sound, 75, TRUE)
		return TRUE

	var/baton_effect_success = ..()

	if(!baton_effect_success)
		return FALSE

	return TRUE

// Mark powered Harm attacks so additional burn damage can be applied afterward.
/obj/item/melee/baton/security/electrostaff/pre_attack(
	atom/target,
	mob/living/user,
	list/modifiers,
	list/attack_modifiers
)
	if(has_power() && LAZYACCESS(modifiers, RIGHT_CLICK))
		LAZYSET(attack_modifiers, "electrostaff_harm_attack", TRUE)

	return ..()

// Apply the additional burn damage to powered Harm attacks.
/obj/item/melee/baton/security/electrostaff/afterattack(
	atom/target,
	mob/user,
	list/modifiers,
	list/attack_modifiers
)
	var/parent_result = ..()

	if(LAZYACCESS(attack_modifiers, "electrostaff_harm_attack") && isliving(target))
		var/mob/living/living_target = target
		living_target.apply_damage(burn_damage, BURN)

	return parent_result

// Handle activation when the staff is picked up with both hands
/obj/item/melee/baton/security/electrostaff/proc/on_wield(
	obj/item/source,
	mob/living/carbon/user
)
	if(has_power())
		playsound(src, sound_on, 75, TRUE)
		turn_on(user)
		balloon_alert(user, "включение")
	else if(!cell)
		balloon_alert(user, "нет источника питания!")
	else
		balloon_alert(user, "не хватает заряда!")

	update_appearance(UPDATE_ICON)

// Handle deactivation when the staff is returned to one-handed use.
/obj/item/melee/baton/security/electrostaff/proc/on_unwield(
	obj/item/source,
	mob/living/carbon/user
)
	if(active && has_power())
		playsound(src, sound_on, 75, TRUE)
		turn_off()
		balloon_alert(user, "выключение")
	else if(active)
		turn_off()

	update_appearance(UPDATE_ICON)

// Provide a 50% block chance while the staff is properly wielded.
/obj/item/melee/baton/security/electrostaff/hit_reaction(
	mob/living/carbon/human/owner,
	atom/movable/hitby,
	attack_text = "the attack",
	final_block_chance = 0,
	damage = 0,
	attack_type = MELEE_ATTACK,
	damage_type = BRUTE
)

	if(!HAS_TRAIT(src, TRAIT_WIELDED))
		return FALSE

	var/effective_block_chance = final_block_chance

	effective_block_chance = block_chance_two_handed

	if(attack_type == THROWN_PROJECTILE_ATTACK)
		effective_block_chance += 20
	if(attack_type == OVERWHELMING_ATTACK)
		effective_block_chance = 0
	if(attack_type == LEAP_ATTACK)
		effective_block_chance = 50

	final_block_chance = clamp(effective_block_chance, 0, 100)

	return ..(owner, hitby, attack_text, final_block_chance, damage, attack_type, damage_type)

// Define the available color reskins for the electrostaff.
/datum/atom_skin/electrostaff
	abstract_type = /datum/atom_skin/electrostaff
	change_base_icon_state = TRUE
	change_inhand_icon_state = TRUE
	change_worn_icon_state = FALSE

/datum/atom_skin/electrostaff/orange
	preview_name = "Orange"
	new_icon_state = "electrostaff_orange"
	new_inhand_icon_state = "electrostaff_orange"

/datum/atom_skin/electrostaff/red
	preview_name = "Red"
	new_icon_state = "electrostaff_red"
	new_inhand_icon_state = "electrostaff_red"

/datum/atom_skin/electrostaff/purple
	preview_name = "Purple"
	new_icon_state = "electrostaff_purple"
	new_inhand_icon_state = "electrostaff_purple"

/datum/atom_skin/electrostaff/blue
	preview_name = "Blue"
	new_icon_state = "electrostaff_blue"
	new_inhand_icon_state = "electrostaff_blue"

// Select the correct world and in-hand sprite for the current state.
/obj/item/melee/baton/security/electrostaff/update_icon_state()
	var/icon_suffix = ""

	if(HAS_TRAIT(src, TRAIT_WIELDED))
		if(active && has_power())
			icon_suffix = "_active"
		else if(cell)
			icon_suffix = "_wield"
		else
			icon_suffix = "_nocell_wield"
	else
		if(!cell)
			icon_suffix = "_nocell"

	icon_state = "[base_icon_state][icon_suffix]"
	inhand_icon_state = "[base_icon_state][icon_suffix]"

	return

// Refresh the held item appearance when the battery becomes too weak to power the staff.
/obj/item/melee/baton/security/electrostaff/deductcharge(deducted_charge)
	var/charge_used = ..()

	if(!has_power() && HAS_TRAIT(src, TRAIT_WIELDED))
		if(isliving(loc))
			var/mob/living/user = loc
			user.update_held_items()

	return charge_used
