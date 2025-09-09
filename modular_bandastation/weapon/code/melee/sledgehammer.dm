/// Return values for wall tearing validation
#define WALL_TEAR_ALLOWED 1
#define WALL_TEAR_INVALID 0
#define WALL_TEAR_CANCEL_CHAIN -1

/obj/item/sledgehammer
	name = "sledgehammer"
	desc = "Большая и тяжелая кувалда из пластали для разрушения стен. Может также быть использована для разрушения горных пород."
	icon = 'modular_bandastation/weapon/icons/melee/sledgehammer.dmi'
	icon_state = "sledgehammer0"
	base_icon_state = "sledgehammer"
	worn_icon = 'modular_bandastation/weapon/icons/melee/melee_back.dmi'
	worn_icon_state = "sledgehammer"
	lefthand_file = 'modular_bandastation/weapon/icons/melee/inhands/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/melee/inhands/righthand.dmi'
	slot_flags = ITEM_SLOT_BACK
	obj_flags = CONDUCTS_ELECTRICITY
	force = 10
	throwforce = 10
	w_class = WEIGHT_CLASS_BULKY
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5, /datum/material/wood = SHEET_MATERIAL_AMOUNT * 2)
	attack_verb_continuous = list("whacks", "breaches", "bulldozes", "flings", "thwachs")
	attack_verb_simple = list("breach", "hammer", "whack", "slap", "thwach", "fling")
	armor_type = /datum/armor/item_sledgehammer
	tool_behaviour = TOOL_MINING
	demolition_mod = 4
	throw_range = 3
	custom_price = PAYCHECK_CREW * 4
	/// How much damage to do unwielded
	var/force_unwielded = 10
	/// How much damage to do wielded
	var/force_wielded = 20
	/// How much time it takes to use sledgehammer on wall
	var/tear_time = 6 SECONDS
	/// By how much we multiply the time of use when wall is reinforced, null if we cant
	var/reinforced_multiplier
	/// How much stamina is taken per use of sledgehammer on wall
	var/stamina_take = 40
	/// What interaction key do we use for our interaction
	var/do_after_key = "sledgehammer_tearing"

/obj/item/sledgehammer/tactical
	name = "D-4 tactical breaching hammer"
	desc = "Металлопластиковый композитный молот для создания брешей в стенах или уничтожения различных структур."
	icon_state = "sledgehammer_tactical0"
	base_icon_state = "sledgehammer_tactical"
	worn_icon_state = "sledgehammer_tactical"
	resistance_flags = FIRE_PROOF
	demolition_mod = 5
	tool_behaviour = TOOL_CROWBAR
	toolspeed = 1
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5, /datum/material/plastic = SHEET_MATERIAL_AMOUNT * 2)
	usesound = 'sound/items/tools/crowbar.ogg'
	tear_time = 5 SECONDS
	stamina_take = 30

/obj/item/sledgehammer/syndie
	name = "D-6 tactical breaching hammer"
	desc = "Пластитаниевый композитный абордажный молот для создания брешей в корпусах кораблей или уничтожения всего и вся. Выглядит как отличное оружие для перекаченного психа в сварочной маске."
	icon_state = "sledgehammer_syndie0"
	base_icon_state = "sledgehammer_syndie"
	worn_icon_state = "sledgehammer_syndie"
	force = 10
	throwforce = 30
	resistance_flags = FIRE_PROOF | ACID_PROOF | BOMB_PROOF
	custom_materials = list(/datum/material/titanium = SHEET_MATERIAL_AMOUNT * 5, /datum/material/plasma = SHEET_MATERIAL_AMOUNT * 2, /datum/material/plastic = SHEET_MATERIAL_AMOUNT * 2)
	force_unwielded = 15
	force_wielded = 45
	armour_penetration = 30
	demolition_mod = 5
	tool_behaviour = TOOL_CROWBAR
	toolspeed = 2
	usesound = 'sound/items/tools/crowbar.ogg'
	throw_range = 5
	tear_time = 3 SECONDS
	reinforced_multiplier = 2
	stamina_take = 20

/datum/armor/item_sledgehammer
	fire = 70
	acid = 50

/obj/item/sledgehammer/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded=force_unwielded, force_wielded=force_wielded, icon_wielded="[base_icon_state]1")
	AddComponent(/datum/component/stamina_cost_per_hit, stamina_cost=10)

/obj/item/sledgehammer/syndie/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/stamina_cost_per_hit, stamina_cost=0)

/obj/item/sledgehammer/get_demolition_modifier(obj/target)
	return HAS_TRAIT(src, TRAIT_WIELDED) ? demolition_mod : 0.8

/obj/item/sledgehammer/update_icon_state()
	icon_state = "[base_icon_state]0"
	return ..()

/obj/item/sledgehammer/pre_attack(atom/target, mob/living/user, list/modifiers, list/attack_modifiers)
	. = ..()
	if(!iswallturf(target))
		return .

	var/is_valid = validate_target(target, user)
	if(is_valid != WALL_TEAR_ALLOWED)
		return is_valid == WALL_TEAR_CANCEL_CHAIN ? COMPONENT_CANCEL_ATTACK_CHAIN : .

	INVOKE_ASYNC(src, PROC_REF(rip_and_tear), user, target)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/item/sledgehammer/proc/validate_target(atom/target, mob/living/user)
	if(!isclosedturf(target) || isindestructiblewall(target))
		return WALL_TEAR_INVALID

	if(!HAS_TRAIT(src, TRAIT_WIELDED))
		target.balloon_alert(user, "нужно держать двумя руками!")
		return WALL_TEAR_CANCEL_CHAIN

	var/reinforced = istype(target, /turf/closed/wall/r_wall)
	if(!reinforced_multiplier && reinforced)
		target.balloon_alert(user, "слишком крепкое!")
		return WALL_TEAR_CANCEL_CHAIN

	return WALL_TEAR_ALLOWED

/obj/item/sledgehammer/proc/rip_and_tear(mob/living/user, atom/target)
	if(QDELETED(target))
		return

	var/reinforced = istype(target, /turf/closed/wall/r_wall)
	if(reinforced && !reinforced_multiplier)
		return

	var/rip_time = (reinforced ? tear_time * reinforced_multiplier : tear_time) / 3
	if(rip_time > 0)
		if(DOING_INTERACTION_WITH_TARGET(user, target) || DOING_INTERACTION(user, do_after_key))
			user.balloon_alert(user, "заняты!")
			return
		if(user.getStaminaLoss() >= 90)
			user.balloon_alert(user, "вы слишком устали!")
			return
		user.visible_message(span_warning("[capitalize(user.declent_ru(NOMINATIVE))] начинает выламывать [target.declent_ru(ACCUSATIVE)]!"))
		playsound(user, 'sound/machines/airlock/airlock_alien_prying.ogg', vol = 100, vary = TRUE)
		target.balloon_alert(user, "выламываем...")
		if(!do_after(user, delay = rip_time, target = target, interaction_key = do_after_key))
			user.balloon_alert(user, "прервано!")
			return

	var/is_valid = validate_target(target, user)
	if(is_valid != WALL_TEAR_ALLOWED)
		return

	user.do_attack_animation(target)
	target.AddComponent(/datum/component/torn_wall)
	user.adjustStaminaLoss(stamina_take)
	playsound(target, 'sound/effects/meteorimpact.ogg', 100, TRUE)

	is_valid = validate_target(target, user)
	if(is_valid == WALL_TEAR_ALLOWED)
		rip_and_tear(user, target)

/datum/uplink_item/role_restricted/syndiesledge
	name = "Syndicate Breaching Sledgehammer"
	desc = "Plastitanium sledgehammer made for destruction and chaos. Great for tearing down unnecessary walls or bystanders."
	item = /obj/item/sledgehammer/syndie
	cost = 10
	restricted_roles = list(JOB_STATION_ENGINEER, JOB_CHIEF_ENGINEER, JOB_ATMOSPHERIC_TECHNICIAN)

/datum/uplink_item/weapon_kits/medium_cost/syndiesledge
	name = "Syndicate Breaching Sledgehammer (Hard)"
	desc = "Contains a plastitanium sledgehammer made for destruction and chaos. Great for tearing down unnecessary walls or bystanders. Comes with a welding helmet for your safety on the workplace!"
	item = /obj/item/storage/toolbox/guncase/syndiesledge
	purchasable_from = UPLINK_ALL_SYNDIE_OPS
	surplus = 0

/obj/item/storage/toolbox/guncase/syndiesledge
	name = "syndicate sledgehammer case"
	weapon_to_spawn = /obj/item/sledgehammer/syndie
	extra_to_spawn = /obj/item/clothing/head/utility/welding

/obj/item/storage/toolbox/guncase/syndiesledge/PopulateContents()
	new weapon_to_spawn(src)
	new extra_to_spawn(src)

/obj/machinery/vending/security/Initialize(mapload)
	premium |= list(/obj/item/sledgehammer/tactical = 1)
	. = ..()

#undef WALL_TEAR_ALLOWED
#undef WALL_TEAR_INVALID
#undef WALL_TEAR_CANCEL_CHAIN
