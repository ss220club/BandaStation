/// Element for enhanced movement with strongleg prosthesis
/datum/element/strongleg_movement
	/// Speed bonus per leg
	var/speed_bonus = -0.3

/datum/element/strongleg_movement/Attach(datum/target)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE

	var/mob/living/living_target = target
	living_target.add_movespeed_modifier(/datum/movespeed_modifier/strongleg_prosthesis)

/datum/element/strongleg_movement/Detach(datum/target)
	if(isliving(target))
		var/mob/living/living_target = target
		living_target.remove_movespeed_modifier(/datum/movespeed_modifier/strongleg_prosthesis)
	return ..()

/// Movespeed modifier for strongleg prosthesis
/datum/movespeed_modifier/strongleg_prosthesis
	movetypes = GROUND
	variable = TRUE
	multiplicative_slowdown = -0.3

/// Component for Strongleg prosthesis combat abilities
/// Handles enhanced kicks and stomp attacks
/datum/component/strongleg_combat
	/// Knockback distance on kick
	var/kick_knockback_distance = 2
	/// Stomp knockdown duration
	var/stomp_knockdown_time = 2 SECONDS
	/// Stomp damage multiplier
	var/stomp_damage_multiplier = 1.5

/datum/component/strongleg_combat/Initialize(_kick_knockback_distance, _stomp_knockdown_time, _stomp_damage_multiplier)
	. = ..()
	if(_kick_knockback_distance)
		kick_knockback_distance = _kick_knockback_distance
	if(_stomp_knockdown_time)
		stomp_knockdown_time = _stomp_knockdown_time
	if(_stomp_damage_multiplier)
		stomp_damage_multiplier = _stomp_damage_multiplier

/datum/component/strongleg_combat/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_HUMAN_PUNCHED, PROC_REF(on_kick))
	RegisterSignal(parent, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(on_stomp))

/datum/component/strongleg_combat/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(COMSIG_HUMAN_PUNCHED, COMSIG_LIVING_UNARMED_ATTACK))

/// Kick handler - adds knockback when kicking (attacking downed targets)
/datum/component/strongleg_combat/proc/on_kick(mob/living/carbon/human/source, mob/living/carbon/human/target, damage, attack_type, obj/item/bodypart/affecting, final_armor_block, kicking, limb_sharpness)
	SIGNAL_HANDLER

	if(!kicking)
		return

	if(!istype(source.get_bodypart(BODY_ZONE_L_LEG), /obj/item/bodypart/leg/left/strongleg) && !istype(source.get_bodypart(BODY_ZONE_R_LEG), /obj/item/bodypart/leg/right/strongleg))
		return

	var/throw_dir = get_dir(source, target)
	var/turf/throw_target = get_edge_target_turf(target, throw_dir)
	target.safe_throw_at(throw_target, kick_knockback_distance, 1, source, gentle = FALSE)

	target.visible_message(
		span_danger("[capitalize(target.declent_ru(NOMINATIVE))] отлетает от мощного пинка!"),
		span_userdanger("Мощный пинок отбрасывает вас!"),
		span_hear("Вы слышите глухой удар!"),
		COMBAT_MESSAGE_RANGE,
		source
	)
	to_chat(source, span_danger("Ваш пинок отбрасывает [target.declent_ru(ACCUSATIVE)]!"))

/// Stomp handler - enhanced damage and knockdown when stomping downed targets
/datum/component/strongleg_combat/proc/on_stomp(mob/living/source, atom/target, proximity, modifiers)
	SIGNAL_HANDLER

	if(!isliving(target))
		return NONE

	var/mob/living/living_target = target

	// Only enhanced when target is downed (stomping)
	if(living_target.body_position != LYING_DOWN)
		return NONE

	var/mob/living/carbon/human/human_source = source
	if(!istype(human_source))
		return NONE

	if(!istype(human_source.get_bodypart(BODY_ZONE_L_LEG), /obj/item/bodypart/leg/left/strongleg) && !istype(human_source.get_bodypart(BODY_ZONE_R_LEG), /obj/item/bodypart/leg/right/strongleg))
		return NONE

	// Apply knockdown
	living_target.Knockdown(stomp_knockdown_time)

	living_target.visible_message(
		span_danger("[capitalize(source.declent_ru(NOMINATIVE))] с силой топчет [living_target.declent_ru(ACCUSATIVE)]!"),
		span_userdanger("[capitalize(source.declent_ru(NOMINATIVE))] с огромной силой топчет вас!"),
		span_hear("Вы слышите глухой удар!"),
		COMBAT_MESSAGE_RANGE,
		source
	)
	to_chat(source, span_danger("Вы с силой топчете [living_target.declent_ru(ACCUSATIVE)]!"))

	log_combat(source, living_target, "strongleg stomp")

	return NONE // Don't cancel the attack, just add effects

/obj/item/bodypart/leg/left/strongleg
	name = "augmented leg"
	desc = "Combat prosthesis with enhanced hydraulics for powerful kicks and rapid movement. \
		Kicks knockback enemies, stomps keep them down. \
		Based on technology similar to the Strongarm implant, but implemented as a full prosthesis."

	brute_modifier = 0.5
	burn_modifier = 0.5
	wound_resistance = 20
	max_damage = 80
	can_be_disabled = FALSE

	speed_modifier = -0.3

	unarmed_damage_low = 15
	unarmed_damage_high = 30
	unarmed_effectiveness = 25

	bodypart_traits = list(
		TRAIT_SHOCKIMMUNE,
		TRAIT_PIERCEIMMUNE,
		TRAIT_NODISMEMBER,
	)

/obj/item/bodypart/leg/left/strongleg/try_attach_limb(mob/living/carbon/new_owner, special)
	. = ..()
	if(. && istype(new_owner))
		new_owner.AddElement(/datum/element/strongleg_movement)
		new_owner.AddComponent(/datum/component/strongleg_combat, 2, 2 SECONDS, 1.5)

/obj/item/bodypart/leg/left/strongleg/on_removal(mob/living/carbon/old_owner)
	if(old_owner)
		old_owner.RemoveElement(/datum/element/strongleg_movement)
		var/datum/component/strongleg_combat/combat_component = old_owner.GetComponent(/datum/component/strongleg_combat)
		if(combat_component)
			qdel(combat_component)
	return ..()

/// EMP protection - prosthesis has shielding
/obj/item/bodypart/leg/left/strongleg/emp_effect(severity, protection)
	do_sparks(number = 2, cardinal_only = FALSE, source = owner || src)
	if(owner)
		to_chat(owner, span_notice("Ваш [plaintext_zone] слегка искрит, но защита от ЭМИ срабатывает!"))
	return TRUE

/obj/item/bodypart/leg/right/strongleg
	name = "augmented leg"
	desc = "Combat prosthesis with enhanced hydraulics for powerful kicks and rapid movement. \
		Kicks knockback enemies, stomps keep them down. \
		Based on technology similar to the Strongarm implant, but implemented as a full prosthesis."

	brute_modifier = 0.5
	burn_modifier = 0.5
	wound_resistance = 20
	max_damage = 80
	can_be_disabled = FALSE

	speed_modifier = -0.3

	unarmed_damage_low = 15
	unarmed_damage_high = 30
	unarmed_effectiveness = 25

	bodypart_traits = list(
		TRAIT_SHOCKIMMUNE,
		TRAIT_PIERCEIMMUNE,
		TRAIT_NODISMEMBER,
	)


/obj/item/bodypart/leg/right/strongleg/try_attach_limb(mob/living/carbon/new_owner, special)
	. = ..()
	if(. && istype(new_owner))
		new_owner.AddElement(/datum/element/strongleg_movement)
		new_owner.AddComponent(/datum/component/strongleg_combat, 2, 2 SECONDS, 1.5)

/obj/item/bodypart/leg/right/strongleg/on_removal(mob/living/carbon/old_owner)
	if(old_owner)
		old_owner.RemoveElement(/datum/element/strongleg_movement)
		var/datum/component/strongleg_combat/combat_component = old_owner.GetComponent(/datum/component/strongleg_combat)
		if(combat_component)
			qdel(combat_component)
	return ..()
