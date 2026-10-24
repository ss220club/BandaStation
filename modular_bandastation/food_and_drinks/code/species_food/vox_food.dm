GLOBAL_LIST_INIT(vox_edible_items, typecacheof(list(
	/obj/item/circuitboard,
	/obj/item/flashlight,
	/obj/item/modular_computer,
	/obj/item/gps,
	/obj/item/radio,
	/obj/item/electronics,
)))

/// Like golem_food, this owns a meal proxy without adding edible reagents to a functioning device.
/datum/component/vox_food
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// Deleted with the real device so pending bites cannot retain a phantom meal.
	var/obj/item/food/vox_snack/snack

/datum/component/vox_food/Initialize()
	if(!isitem(parent) || !is_type_in_typecache(parent, GLOB.vox_edible_items))
		return COMPONENT_INCOMPATIBLE

/datum/component/vox_food/Destroy(force)
	QDEL_NULL(snack)
	return ..()

/datum/component/vox_food/proc/create_snack()
	var/obj/item/item = parent
	snack = new(null)
	snack.name = item.name
	snack.source_item = WEAKREF(item)
	// Preserve the original PR's bite counts without reducing every device's combat durability.
	if(istype(item, /obj/item/radio))
		snack.damage_per_bite = item.max_integrity / 2
	else if(istype(item, /obj/item/flashlight) || istype(item, /obj/item/gps))
		snack.damage_per_bite = item.max_integrity / 3
	else if(istype(item, /obj/item/circuitboard) || istype(item, /obj/item/electronics))
		snack.damage_per_bite = item.max_integrity / 4

/datum/component/vox_food/proc/try_feed(mob/living/eater, mob/living/feeder)
	if(feeder.combat_mode || !isvox(eater) || !isvox(feeder))
		return NONE
	if(QDELETED(snack))
		create_snack()
	var/datum/component/edible/vox/edible = snack.GetComponent(/datum/component/edible/vox)
	edible.TryToEat(eater, feeder)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/item/food/vox_snack
	name = "temporary vox snack item"
	spawn_blacklisted = TRUE
	bite_consumption = 1
	eat_time = 1 SECONDS
	food_reagents = list(/datum/reagent/consumable/nutriment = INFINITY)
	foodtypes = TECH
	tastes = list("металл" = 1, "кремний" = 1, "медь" = 1)
	preserved_food = TRUE
	/// The device whose ownership and integrity are checked before each bite.
	var/datum/weakref/source_item
	/// Integrity consumed by one bite; ordinary handheld computers retain the original 15 damage.
	var/damage_per_bite = 15

/obj/item/food/vox_snack/make_edible()
	AddComponentFrom(
		SOURCE_EDIBLE_INNATE,\
		/datum/component/edible/vox,\
		initial_reagents = food_reagents,\
		foodtypes = foodtypes,\
		volume = INFINITY,\
		eat_time = eat_time,\
		tastes = tastes,\
		bite_consumption = bite_consumption,\
		after_eat = CALLBACK(src, PROC_REF(after_eat)),\
	)

/obj/item/food/vox_snack/proc/after_eat(mob/eater)
	var/obj/item/item = source_item?.resolve()
	if(!item)
		return
	item.obj_flags |= NO_DEBRIS_AFTER_DECONSTRUCTION
	item.take_damage(damage_per_bite, sound_effect = FALSE, damage_flag = CONSUME)

/// TakeBite calls CanConsume again after the eating delay and food signals.
/datum/component/edible/vox/CanConsume(mob/living/carbon/eater, mob/living/feeder)
	if(QDELETED(eater) || QDELETED(feeder) || !isvox(eater) || !isvox(feeder) || QDELETED(parent) || !..())
		return FALSE
	// Food attempt signals may move the device, transform its user or delete the proxy.
	if(QDELETED(parent) || QDELETED(eater) || QDELETED(feeder))
		return FALSE
	var/obj/item/food/vox_snack/snack = parent
	var/obj/item/item = snack.source_item?.resolve()
	if(!item || !isvox(eater) || !isvox(feeder) || feeder.combat_mode || feeder.incapacitated)
		return FALSE
	if(!item.uses_integrity || (item.resistance_flags & INDESTRUCTIBLE) || (item.flags_1 & HOLOGRAM_1) || item.get_armor_rating(CONSUME) >= 100)
		return FALSE
	if(item.get_integrity() <= 0)
		return FALSE
	if(!feeder.is_holding(item) || !feeder.Adjacent(eater))
		return FALSE
	return TRUE
