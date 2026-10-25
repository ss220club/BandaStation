/// Paradise's ambush predator, using native basic mob damage and jaunt systems.
/mob/living/basic/demon/shadow
	name = "тенедемон"
	real_name = "тенедемон"
	unique_name = FALSE
	desc = "Едва осязаемое существо. Его взгляд словно пронзает вас насквозь."
	icon = 'modular_bandastation/shadow_demon/icons/shadow_demon.dmi'
	icon_state = "shadow_demon"
	icon_living = "shadow_demon"
	maxHealth = 200
	health = 200
	melee_damage_lower = 30
	melee_damage_upper = 30
	obj_damage = 50
	melee_attack_cooldown = 2 SECONDS
	move_resist = MOVE_FORCE_STRONG
	mob_biotypes = MOB_ORGANIC | MOB_HUMANOID
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = INFINITY
	habitable_atmos = list("min_oxy" = 16, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	// Paradise applies 18 per two-second mob tick.
	unsuitable_atmos_damage = 9
	death_sound = 'modular_bandastation/shadow_demon/sound/shadowdeath.ogg'
	death_message = "рассыпается, издав пронзительный вопль."
	lighting_cutoff_red = 15
	lighting_cutoff_green = 15
	lighting_cutoff_blue = 15
	see_in_dark = 10
	/// Whether a corpse is currently being wrapped.
	var/wrapping = FALSE
	/// The light state last applied to our appearance and movement.
	var/in_light

/mob/living/basic/demon/shadow/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NOFIRE, INNATE_TRAIT)
	GRANT_ACTION(/datum/action/cooldown/spell/shadow_grapple)
	GRANT_ACTION(/datum/action/cooldown/spell/jaunt/shadow_demon)
	GRANT_ACTION(/datum/action/innate/shadow_demon_whisper)
	grant_language(/datum/language/common, source = LANGUAGE_ATOM)
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(on_shadow_moved))
	add_overlay(emissive_appearance(icon, "shadow_demon_eye_glow_overlay", src))
	check_darkness()

/mob/living/basic/demon/shadow/grant_loot()
	return list(/obj/item/organ/heart/shadow_demon)

/mob/living/basic/demon/shadow/mind_initialize()
	. = ..()
	mind.set_assigned_role(SSjob.get_job_type(/datum/job/shadow_demon))
	if(!mind.has_antag_datum(/datum/antagonist/shadow_demon))
		mind.add_antag_datum(/datum/antagonist/shadow_demon)

/mob/living/basic/demon/shadow/Life(seconds_per_tick = SSMOBS_DT)
	. = ..()
	if(QDELETED(src) || stat == DEAD)
		return
	apply_shadow_environment(seconds_per_tick)

/// Rate conversion preserves Paradise's two-second tick values across subsystem rates.
/mob/living/basic/demon/shadow/proc/apply_shadow_environment(seconds_per_tick)
	if(check_darkness() > 0.2)
		var/damage_rate = is_jaunting(src) ? 10 : 20
		adjust_brute_loss(damage_rate * seconds_per_tick)
		if(!QDELETED(src))
			SEND_SOUND(src, sound('sound/items/weapons/sear.ogg'))
			to_chat(src, span_userdanger("Свет обжигает вас!"))
	else
		adjust_brute_loss(-10 * seconds_per_tick)

/mob/living/basic/demon/shadow/proc/on_shadow_moved(datum/source)
	SIGNAL_HANDLER
	check_darkness()

/mob/living/basic/demon/shadow/proc/check_darkness()
	var/turf/current_turf = get_turf(src)
	var/luminosity = current_turf ? current_turf.get_lumcount() : 1
	var/now_in_light = luminosity > 0.2
	if(isnull(in_light) || in_light != now_in_light)
		in_light = now_in_light
		alpha = in_light ? 255 : 125
		set_varspeed(in_light ? initial(speed) : 0.5)
		if(in_light)
			throw_alert("shadow_demon_light", /atom/movable/screen/alert/shadow_demon_light)
		else
			clear_alert("shadow_demon_light")
	return luminosity

/mob/living/basic/demon/shadow/melee_attack(atom/target, list/modifiers, ignore_cooldown = FALSE)
	if(!Adjacent(target) || incapacitated || !isturf(loc))
		return FALSE
	if(ishuman(target))
		var/mob/living/carbon/human/victim = target
		if(victim.stat == DEAD)
			return wrap_victim(victim)
	else if(isitem(target))
		shadow_demon_extinguish(target)
	attack_sound = pick('modular_bandastation/shadow_demon/sound/shadowattack2.ogg', 'modular_bandastation/shadow_demon/sound/shadowattack3.ogg', 'modular_bandastation/shadow_demon/sound/shadowattack4.ogg')
	return ..()

/mob/living/basic/demon/shadow/proc/wrap_victim(mob/living/carbon/human/target)
	if(wrapping || QDELETED(target) || target.stat != DEAD || !Adjacent(target) || !isturf(target.loc) || !isturf(loc) || incapacitated)
		return FALSE
	wrapping = TRUE
	visible_message(span_danger("[src] начинает оплетать [target] нитями тьмы."))
	var/completed = do_after(src, 4 SECONDS, target = target)
	wrapping = FALSE
	if(!completed)
		return FALSE
	return cocoon_victim(target)

/// Revalidate at completion: a revived or moved victim cannot be cocooned.
/mob/living/basic/demon/shadow/proc/cocoon_victim(mob/living/carbon/human/target)
	if(QDELETED(src) || incapacitated || !isturf(loc) || QDELETED(target) || !ishuman(target) || target.stat != DEAD || !isturf(target.loc) || !Adjacent(target))
		return FALSE
	var/obj/structure/shadowcocoon/cocoon = new(get_turf(target))
	shadow_demon_extinguish(target)
	target.visible_message(span_warning("[src] заключает [target] в призрачный кокон. Из него начинает расползаться тьма."))
	target.forceMove(cocoon)
	log_combat(src, target, "wrapped in a shadow cocoon")
	return TRUE

/mob/living/basic/demon/shadow/hitby(atom/movable/thrown_atom, skipcatch, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	if(isliving(thrown_atom))
		return
	return ..()

/atom/movable/screen/alert/shadow_demon_light
	name = "На свету"
	desc = "Свет выжигает вашу форму. Укройтесь в темноте!"
	icon = 'modular_bandastation/shadow_demon/icons/alerts.dmi'
	icon_state = "lightexposure"

/datum/action/innate/shadow_demon_whisper
	name = "Демонический шёпот"
	desc = "Прошепчите сообщение прямо в разум видимой жертвы."
	button_icon = 'modular_bandastation/shadow_demon/icons/actions.dmi'
	button_icon_state = "shadow_whisper"
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_INCAPACITATED

/datum/action/innate/shadow_demon_whisper/Activate()
	var/mob/caster = owner
	var/client/caster_client = caster?.client
	if(QDELETED(src) || QDELETED(caster) || !caster_client || !IsAvailable())
		return FALSE
	var/list/targets = get_whisper_targets()
	if(!length(targets))
		caster.balloon_alert(caster, "нет разумных целей рядом")
		to_chat(caster, span_warning("Поблизости нет живых разумных существ, которым можно передать шёпот."))
		return FALSE
	var/mob/living/chosen = tgui_input_list(caster, "Чей разум потревожить?", name, targets)
	if(QDELETED(src) || QDELETED(caster) || owner != caster || caster.client != caster_client || !IsAvailable() || QDELETED(chosen) || !(chosen in get_whisper_targets()))
		return FALSE
	var/message = tgui_input_text(caster, "Что вы хотите прошептать [chosen]?", name, max_length = MAX_MESSAGE_LEN, encode = FALSE)
	if(QDELETED(src) || QDELETED(caster) || owner != caster || caster.client != caster_client)
		return FALSE
	return send_whisper(caster, chosen, message)

/datum/action/innate/shadow_demon_whisper/proc/get_whisper_targets()
	var/list/targets = list()
	if(QDELETED(owner))
		return targets
	var/turf/source_turf = get_turf(owner)
	if(isnull(source_turf))
		return targets
	// Match Paradise's turf-centred targeting, independently of the holder's light mask or phased container.
	for(var/mob/living/target in view(owner.client?.view || world.view, source_turf))
		if(target != owner && target.mind && target.stat != DEAD)
			targets += target
	return targets

/datum/action/innate/shadow_demon_whisper/proc/send_whisper(mob/caster, mob/living/chosen, message)
	if(QDELETED(src) || QDELETED(caster) || owner != caster || !IsAvailable() || QDELETED(chosen) || !(chosen in get_whisper_targets()) || !istext(message))
		return FALSE
	message = trim(message)
	if(!length(message))
		return FALSE
	message = html_encode(message)
	caster.log_talk(message, LOG_SAY, tag = "shadow demon whisper to [key_name(chosen)]")
	to_chat(caster, span_notice("Вы шепчете [chosen]: [message]"))
	to_chat(chosen, span_deadsay("<b>Внезапно в вашей голове раздаётся демонический голос...</b> <i>[message]</i>"))
	for(var/mob/dead/observer/ghost in GLOB.dead_player_list)
		to_chat(ghost, "[FOLLOW_LINK(ghost, caster)] [caster] шепчет [FOLLOW_LINK(ghost, chosen)] [chosen]: [message]")
	return TRUE
