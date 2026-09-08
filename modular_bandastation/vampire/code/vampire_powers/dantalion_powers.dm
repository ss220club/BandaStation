/datum/vampire_passive/increment_thrall_cap/on_apply(datum/antagonist/vampire/vampire)
	vampire.subclass.thrall_cap++
	gain_desc = "You can now thrall one more person, up to a maximum of [vampire.subclass.thrall_cap]."

/datum/vampire_passive/increment_thrall_cap/two
/datum/vampire_passive/increment_thrall_cap/three

/datum/action/cooldown/spell/pointed/vampire_enthrall
	name = "Enthrall"
	desc = "Bite a nearby humanoid and bind them to your will."
	button_icon_state = "vampire_enthrall"
	cooldown_time = 30 SECONDS
	cast_range = 1

/datum/action/cooldown/spell/pointed/vampire_enthrall/New(Target)
	. = ..()
	add_vampire_ability(150, FALSE)

/datum/action/cooldown/spell/pointed/vampire_enthrall/is_valid_target(atom/cast_on)
	return ..() && ishuman(cast_on)

/datum/action/cooldown/spell/pointed/vampire_enthrall/cast(mob/living/carbon/human/target)
	. = ..()
	var/mob/living/user = owner
	user.visible_message(span_warning("[user] bites [target]'s neck!"), span_warning("You bite [target]'s neck and begin the flow of power."))
	to_chat(target, span_warning("You feel tendrils of evil invade your mind."))
	if(!do_after(user, 15 SECONDS, target = target))
		to_chat(user, span_warning("You or your target moved."))
		return
	if(!can_enthrall(user, target))
		return
	var/datum/antagonist/vampire/vampire = user.mind.has_antag_datum(/datum/antagonist/vampire)
	var/datum/component/vampire_ability/ability = GetComponent(/datum/component/vampire_ability)
	ability.deduct_blood(src)
	target.mind.add_antag_datum(/datum/antagonist/vampire_thrall, vampire)
	target.Stun(4 SECONDS)
	log_combat(user, target, "vampire enthralled")

/datum/action/cooldown/spell/pointed/vampire_enthrall/proc/can_enthrall(mob/living/user, mob/living/carbon/human/target)
	if(!target.mind)
		to_chat(user, span_warning("[target]'s mind is not there for you to enthrall."))
		return FALSE
	var/datum/antagonist/vampire/vampire = user.mind.has_antag_datum(/datum/antagonist/vampire)
	if(vampire.subclass.thrall_cap <= length(vampire.get_thralls()))
		to_chat(user, span_warning("You don't have enough power to enthrall anyone else."))
		return FALSE
	if(ismindshielded(target) || target.mind.has_antag_datum(/datum/antagonist/vampire) || target.mind.has_antag_datum(/datum/antagonist/vampire_thrall) || HAS_MIND_TRAIT(target, TRAIT_HOLY))
		target.visible_message(span_warning("[target] seems to resist the takeover!"), span_notice("You feel a familiar sensation in your skull that quickly dissipates."))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/vampire_commune
	name = "Commune"
	desc = "Speak telepathically with your thralls."
	button_icon_state = "vamp_communication"
	cooldown_time = 2 SECONDS

/datum/action/cooldown/spell/vampire_commune/New(Target)
	. = ..()
	add_vampire_ability()

/datum/action/cooldown/spell/vampire_commune/cast(atom/cast_on)
	. = ..()
	var/mob/living/user = owner
	var/message = tgui_input_text(user, "Enter a message for your thralls.", "Thrall Commune")
	if(!message)
		return
	var/datum/antagonist/vampire/vampire = user.mind.has_antag_datum(/datum/antagonist/vampire)
	for(var/datum/antagonist/vampire_thrall/thrall as anything in vampire.get_thralls())
		if(thrall.owner?.current)
			to_chat(thrall.owner.current, span_notice("[user.real_name] (Vampire Master): [message]"))
	to_chat(user, span_notice("[user.real_name] (Vampire Master): [message]"))
	log_say("(VAMPIRE) [message]", list("CONNECTION" = user))

/datum/action/cooldown/spell/pointed/vampire_pacify
	name = "Pacify"
	desc = "Pacify a humanoid temporarily, preventing them from causing harm."
	button_icon_state = "pacify"
	cooldown_time = 30 SECONDS
	cast_range = 7

/datum/action/cooldown/spell/pointed/vampire_pacify/New(Target)
	. = ..()
	add_vampire_ability(10)

/datum/action/cooldown/spell/pointed/vampire_pacify/is_valid_target(atom/cast_on)
	return ..() && ishuman(cast_on)

/datum/action/cooldown/spell/pointed/vampire_pacify/cast(mob/living/carbon/human/cast_on)
	. = ..()
	if(cast_on.affects_vampire(owner))
		cast_on.apply_status_effect(STATUS_EFFECT_PACIFIED)

/datum/action/cooldown/spell/pointed/vampire_switch_places
	name = "Subspace Swap"
	desc = "Switch positions with a target."
	button_icon_state = "subspace_swap"
	cooldown_time = 30 SECONDS
	cast_range = 7

/datum/action/cooldown/spell/pointed/vampire_switch_places/New(Target)
	. = ..()
	add_vampire_ability(30)

/datum/action/cooldown/spell/pointed/vampire_switch_places/is_valid_target(atom/cast_on)
	return ..() && isliving(cast_on)

/datum/action/cooldown/spell/pointed/vampire_switch_places/cast(mob/living/target)
	. = ..()
	var/mob/living/user = owner
	if(target.can_block_magic())
		to_chat(user, span_warning("The spell had no effect!"))
		to_chat(target, span_warning("You feel space bending, but it rapidly dissipates."))
		return
	var/turf/user_turf = get_turf(user)
	var/turf/target_turf = get_turf(target)
	if(!(SEND_SIGNAL(target, COMSIG_MOVABLE_TELEPORTING, user_turf) & COMPONENT_BLOCK_TELEPORT))
		target.forceMove(user_turf)
	if(!(SEND_SIGNAL(user, COMSIG_MOVABLE_TELEPORTING, target_turf) & COMPONENT_BLOCK_TELEPORT))
		user.forceMove(target_turf)

/datum/action/cooldown/spell/vampire_decoy
	name = "Deploy Decoy"
	desc = "Briefly turn invisible and deploy a decoy illusion."
	button_icon_state = "decoy"
	cooldown_time = 40 SECONDS

/datum/action/cooldown/spell/vampire_decoy/New(Target)
	. = ..()
	add_vampire_ability(30)

/datum/action/cooldown/spell/vampire_decoy/cast(atom/cast_on)
	. = ..()
	var/mob/living/user = owner
	var/mob/living/simple_animal/hostile/illusion/escape/decoy = new(get_turf(user))
	decoy.Copy_Parent(user, 20, 20)
	decoy.GiveTarget(user)
	decoy.Goto(user, decoy.move_to_delay, decoy.minimum_distance)
	user.make_invisible()
	addtimer(CALLBACK(user, TYPE_PROC_REF(/mob/living, reset_visibility)), 6 SECONDS)

/datum/action/cooldown/spell/aoe/vampire_rally_thralls
	name = "Rally Thralls"
	desc = "Remove incapacitating effects from nearby thralls."
	button_icon_state = "thralls_up"
	cooldown_time = 100 SECONDS
	aoe_radius = 7

/datum/action/cooldown/spell/aoe/vampire_rally_thralls/New(Target)
	. = ..()
	add_vampire_ability(100)

/datum/action/cooldown/spell/aoe/vampire_rally_thralls/get_things_to_cast_on(atom/center)
	. = list()
	var/datum/antagonist/vampire/vampire = owner.mind?.has_antag_datum(/datum/antagonist/vampire)
	for(var/datum/antagonist/vampire_thrall/thrall as anything in vampire?.get_thralls())
		if(thrall.owner?.current && get_dist(center, thrall.owner.current) <= aoe_radius)
			. += thrall.owner.current

/datum/action/cooldown/spell/aoe/vampire_rally_thralls/cast_on_thing_in_aoe(mob/living/carbon/human/thrall, atom/caster)
	var/image/overlay = image('icons/effects/vampire_effects.dmi', "rallyoverlay", layer = EFFECTS_LAYER)
	playsound(thrall, 'sound/magic/staff_healing.ogg', 30)
	thrall.remove_CC()
	thrall.add_overlay(overlay)
	addtimer(CALLBACK(thrall, TYPE_PROC_REF(/atom, cut_overlay), overlay), 6 SECONDS)

/datum/action/cooldown/spell/vampire_blood_bond
	name = "Blood Bond"
	desc = "Create a net that evenly shares damage between you and nearby thralls."
	button_icon_state = "blood_bond"
	cooldown_time = 2 SECONDS

/datum/action/cooldown/spell/vampire_blood_bond/New(Target)
	. = ..()
	add_vampire_ability(5)

/datum/action/cooldown/spell/vampire_blood_bond/cast(atom/cast_on)
	. = ..()
	var/mob/living/user = owner
	var/datum/status_effect/thrall_net/net = user.has_status_effect(STATUS_EFFECT_THRALL_NET)
	if(net)
		qdel(net)
	else
		user.apply_status_effect(STATUS_EFFECT_THRALL_NET, user.mind.has_antag_datum(/datum/antagonist/vampire))

/datum/action/cooldown/spell/aoe/vampire_hysteria
	name = "Mass Hysteria"
	desc = "Blind nearby humanoids before making them perceive each other as animals."
	button_icon_state = "hysteria"
	cooldown_time = 180 SECONDS
	aoe_radius = 8

/datum/action/cooldown/spell/aoe/vampire_hysteria/New(Target)
	. = ..()
	add_vampire_ability(70)

/datum/action/cooldown/spell/aoe/vampire_hysteria/get_things_to_cast_on(atom/center)
	. = list()
	for(var/mob/living/carbon/human/target in range(aoe_radius, center))
		if(target != owner && target.affects_vampire(owner))
			. += target

/datum/action/cooldown/spell/aoe/vampire_hysteria/cast_on_thing_in_aoe(mob/living/carbon/human/target, atom/caster)
	target.flash_eyes(1, TRUE)
	new /obj/effect/hallucination/delusion/long(get_turf(owner), target)
