/obj/item/sledgehammer
	name = "D-4 tactical breaching hammer"
	desc = "Металлопластиковый композитный молот для создания брешей в стенах и уничтожения структур. Выглядит как отличное оружие для перекаченного психа в сварочной маске."
	icon = 'modular_bandastation/objects/icons/obj/weapons/sledgehammer.dmi'
	icon_state = "sledgehammer0"
	base_icon_state = "sledgehammer"
	worn_icon = 'modular_bandastation/objects/icons/mob/back/melee_back.dmi'
	worn_icon_state = "sledgehammer"
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/melee_lefthand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/melee_righthand.dmi'
	slot_flags = ITEM_SLOT_BACK
	obj_flags = CONDUCTS_ELECTRICITY
	force = 10
	throwforce = 10
	w_class = WEIGHT_CLASS_BULKY
	attack_verb_continuous = list("whacks", "breaches", "bulldozes", "flings", "thwachs")
	attack_verb_simple = list("breach", "hammer", "whack", "slap", "thwach", "fling")
	armor_type = /datum/armor/item_sledgehammer
	resistance_flags = FIRE_PROOF
	var/force_unwielded = 10
	/// How much damage to do wielded
	var/force_wielded = 20
	demolition_mod = 6
	tool_behaviour = TOOL_CROWBAR
	toolspeed = 1
	usesound = 'sound/items/tools/crowbar.ogg'
	throw_range = 3

/datum/armor/item_sledgehammer
	fire = 100
	acid = 50

/obj/item/sledgehammer/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded=force_unwielded, force_wielded=force_wielded, icon_wielded="[base_icon_state]1")

/obj/item/sledgehammer/get_demolition_modifier(obj/target)
	return HAS_TRAIT(src, TRAIT_WIELDED) ? demolition_mod : 0.8

/obj/item/sledgehammer/update_icon_state()
	icon_state = "[base_icon_state]0"
	return ..()

/obj/item/sledgehammer/proc/sledge_hit(atom/target, mob/living/user, list/modifiers, tear_time = 3 SECONDS, reinforced_multiplier = 3, do_after_key = "sledgehammer_tearing")
	if(istype(target, /turf/closed/wall))
		var/rip_time = (istype(target, /turf/closed/wall/r_wall) ? tear_time * reinforced_multiplier : tear_time) / 3
		if(rip_time > 0)
			if(DOING_INTERACTION_WITH_TARGET(user, target) || (!isnull(do_after_key) && DOING_INTERACTION(user, do_after_key)))
				user.balloon_alert(user, "заняты!")
				return
			if(user.getStaminaLoss() >= 90)
				user.balloon_alert(user, "вы слишком устали!")
				return
			user.visible_message(span_warning("[capitalize(user.declent_ru(NOMINATIVE))] начинает выламывать [target.declent_ru(ACCUSATIVE)]!"))
			target.balloon_alert(user, "выламываем...")
			if(!do_after(user, delay = rip_time, interaction_key = do_after_key))
				user.balloon_alert(user, "прервано!")
				return
			user.adjustStaminaLoss(30)
			user.do_attack_animation(target)
			target.AddComponent(/datum/component/torn_wall)

/obj/item/sledgehammer/pre_attack(atom/target, mob/living/user, list/modifiers, list/attack_modifiers)
	. = ..()
	if(!istype(target, /turf/closed/wall))
		return .

	if(!HAS_TRAIT(src, TRAIT_WIELDED))
		to_chat(user, span_warning("Вам нужно взять [src] в обе руки чтобы разрушить стену!"))
		return .

	sledge_hit(target, user, modifiers)
	return COMPONENT_CANCEL_ATTACK_CHAIN
