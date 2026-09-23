//	VOX EDIBLE ITEMS
GLOBAL_LIST_INIT(vox_edible_items, typecacheof(list(
	/obj/item/circuitboard,
	/obj/item/flashlight,
	/obj/item/modular_computer,
	/obj/item/gps,
	/obj/item/radio,
	/obj/item/electronics,
)))

/obj/item/food/vox_snack
	name = "temporary vox snack item"
	spawn_blacklisted = TRUE
	bite_consumption = 1
	food_reagents = list(/datum/reagent/consumable/nutriment = INFINITY)
	foodtypes = TECH
	tastes = list("металл" = 1 ,"кремний" = 1, "медь" = 1)

	var/datum/weakref/source_item
	var/damage_per_bite = 15

/obj/item/food/vox_snack/make_edible()
	. = ..()
	AddComponentFrom(SOURCE_EDIBLE_INNATE, /datum/component/edible, after_eat = CALLBACK(src, PROC_REF(after_eat)))

/obj/item/food/vox_snack/proc/after_eat(mob/eater)
	var/obj/item/real_item = source_item?.resolve()
	if(real_item)
		real_item.take_damage(damage_per_bite, sound_effect = FALSE, damage_flag = CONSUME)
	else
		qdel(src)

/proc/vox_create_snack(obj/item/source)
	var/obj/item/food/vox_snack/snack = new
	snack.name = source.name
	snack.source_item = WEAKREF(source)
	source.obj_flags |= NO_DEBRIS_AFTER_DECONSTRUCTION

//	snack.make_edible()
	return snack

/obj/item
	var/obj/item/food/vox_snack/vox_snack

/obj/item/attack(mob/living/target, mob/living/user, list/modifiers, list/attack_modifiers)
	if(!user.combat_mode && isvox(user) && is_type_in_typecache(src, GLOB.vox_edible_items))
		if(isnull(vox_snack))
			vox_snack = vox_create_snack(src)
		return vox_snack.attack(target, user, modifiers)
	return ..()

//	VOX EDIBLE ITEMS INTEGRITY
/obj/item/circuitboard
	max_integrity = 60
	integrity_failure = 0

/obj/item/flashlight
	max_integrity = 45
	integrity_failure = 0

/obj/item/gps
	max_integrity = 45
	integrity_failure = 0

/obj/item/radio
	max_integrity = 30
	integrity_failure = 0

/obj/item/electronics
	max_integrity = 60
	integrity_failure = 0
