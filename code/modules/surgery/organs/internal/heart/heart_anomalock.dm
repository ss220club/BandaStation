/*!
 * Contains Voltaic Combat Cyberheart
 */
#define DOAFTER_IMPLANTING_HEART "implanting"

/obj/item/organ/heart/cybernetic/anomalock
	name = "voltaic combat cyberheart"
	desc = "Кибернетическое сердце, что обогнало своё время. Активное сердце даёт пользователю защиту от ЭМИ и удерживает тело в вертикальном положении в самых тяжёлых условиях. Для работы требуется аномальное ядро флюкс"
	icon_state = "anomalock_heart"
	beat_noise = "an astonishing <b>BZZZ</b> of immense electrical power"
	bleed_prevention = TRUE
	toxification_probability = 0

	COOLDOWN_DECLARE(survival_cooldown)
	///Cooldown for the activation of the organ
	var/survival_cooldown_time = 5 MINUTES
	///The lightning effect on our mob when the implant is active
	var/mutable_appearance/lightning_overlay
	///how long the lightning lasts
	var/lightning_timer

	//---- Anomaly core variables:
	///The core item the organ runs off.
	var/obj/item/assembly/signaler/anomaly/core
	///Accepted types of anomaly cores.
	var/required_anomaly = /obj/item/assembly/signaler/anomaly/flux
	///If this one starts with a core in.
	var/prebuilt = FALSE
	///If the core is removable once socketed.
	var/core_removable = TRUE

/obj/item/organ/heart/cybernetic/anomalock/Destroy()
	QDEL_NULL(core)
	return ..()

/obj/item/organ/heart/cybernetic/anomalock/on_mob_insert(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()
	if(!core)
		return
	add_lightning_overlay(30 SECONDS)
	playsound(organ_owner, 'sound/items/eshield_recharge.ogg', 40)
	organ_owner.AddElement(/datum/element/empprotection, EMP_PROTECT_SELF|EMP_PROTECT_CONTENTS)
	RegisterSignal(organ_owner, SIGNAL_ADDTRAIT(TRAIT_CRITICAL_CONDITION), PROC_REF(activate_survival))
	RegisterSignal(organ_owner, COMSIG_ATOM_EMP_ACT, PROC_REF(on_emp_act))

/obj/item/organ/heart/cybernetic/anomalock/on_mob_remove(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()
	if(!core)
		return
	UnregisterSignal(organ_owner, SIGNAL_ADDTRAIT(TRAIT_CRITICAL_CONDITION))
	organ_owner.RemoveElement(/datum/element/empprotection, EMP_PROTECT_SELF|EMP_PROTECT_CONTENTS)
	tesla_zap(source = organ_owner, zap_range = 20, power = 2.5e5, cutoff = 1e3)
	qdel(src)

/obj/item/organ/heart/cybernetic/anomalock/attack(mob/living/target_mob, mob/living/user, list/modifiers, list/attack_modifiers)
	if(target_mob != user || !istype(target_mob) || !core)
		return ..()

	if(DOING_INTERACTION(user, DOAFTER_IMPLANTING_HEART))
		return
	user.balloon_alert(user, "это будет больно...")
	to_chat(user, span_userdanger("Чёрные кибервены разрывают вашу плоть, затягивая сердце в рёбра. Кажется, что это не очень хорошо..."))
	if(!do_after(user, 5 SECONDS, interaction_key = DOAFTER_IMPLANTING_HEART))
		return ..()
	playsound(target_mob, 'sound/items/weapons/slice.ogg', 100, TRUE)
	user.temporarilyRemoveItemFromInventory(src, TRUE)
	Insert(user)
	user.apply_damage(100, BRUTE, BODY_ZONE_CHEST)
	user.emote("scream")
	return TRUE

/obj/item/organ/heart/cybernetic/anomalock/proc/on_emp_act(severity)
	SIGNAL_HANDLER
	add_lightning_overlay(10 SECONDS)

/obj/item/organ/heart/cybernetic/anomalock/proc/add_lightning_overlay(time_to_last = 10 SECONDS)
	if(lightning_overlay)
		lightning_timer = addtimer(CALLBACK(src, PROC_REF(clear_lightning_overlay)), time_to_last, (TIMER_UNIQUE|TIMER_OVERRIDE))
		return
	lightning_overlay = mutable_appearance(icon = 'icons/effects/effects.dmi', icon_state = "lightning")
	owner.add_overlay(lightning_overlay)
	lightning_timer = addtimer(CALLBACK(src, PROC_REF(clear_lightning_overlay)), time_to_last, (TIMER_UNIQUE|TIMER_OVERRIDE))

/obj/item/organ/heart/cybernetic/anomalock/proc/clear_lightning_overlay()
	owner.cut_overlay(lightning_overlay)
	lightning_overlay = null

/obj/item/organ/heart/cybernetic/anomalock/attack_self(mob/user, modifiers)
	. = ..()
	if(.)
		return

	if(core)
		return attack(user, user, modifiers)

/obj/item/organ/heart/cybernetic/anomalock/on_life(seconds_per_tick, times_fired)
	. = ..()
	if(!core)
		return

	if(owner.blood_volume <= BLOOD_VOLUME_NORMAL)
		owner.blood_volume += 5 * seconds_per_tick

	if(owner.health <= owner.crit_threshold)
		activate_survival(owner)

	if(times_fired % (1 SECONDS))
		return

	var/list/batteries = list()
	for(var/obj/item/stock_parts/power_store/cell in owner.get_all_contents())
		if(cell.used_charge())
			batteries += cell

	if(!length(batteries))
		return

	var/obj/item/stock_parts/power_store/cell = pick(batteries)
	cell.give(cell.max_charge() * 0.1)

///Does a few things to try to help you live whatever you may be going through
/obj/item/organ/heart/cybernetic/anomalock/proc/activate_survival(mob/living/carbon/organ_owner)
	if(!COOLDOWN_FINISHED(src, survival_cooldown))
		return

	organ_owner.apply_status_effect(/datum/status_effect/voltaic_overdrive)
	add_lightning_overlay(30 SECONDS)
	COOLDOWN_START(src, survival_cooldown, survival_cooldown_time)
	addtimer(CALLBACK(src, PROC_REF(notify_cooldown), organ_owner), COOLDOWN_TIMELEFT(src, survival_cooldown))

///Alerts our owner that the organ is ready to do its thing again
/obj/item/organ/heart/cybernetic/anomalock/proc/notify_cooldown(mob/living/carbon/organ_owner)
	balloon_alert(organ_owner, "ваше сердце крепнет")
	playsound(organ_owner, 'sound/items/eshield_recharge.ogg', 40)

/obj/item/organ/heart/cybernetic/anomalock/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, required_anomaly))
		return NONE
	if(core)
		balloon_alert(user, "ядро уже установлено!")
		return ITEM_INTERACT_BLOCKING
	if(!user.transferItemToLoc(tool, src))
		return ITEM_INTERACT_BLOCKING
	core = tool
	balloon_alert(user, "ядро установлено")
	playsound(src, 'sound/machines/click.ogg', 30, TRUE)
	add_organ_trait(TRAIT_SHOCKIMMUNE)
	update_icon_state()
	return ITEM_INTERACT_SUCCESS

/obj/item/organ/heart/cybernetic/anomalock/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	if(!core)
		balloon_alert(user, "нет ядра!")
		return
	if(!core_removable)
		balloon_alert(user, "не удаётся достать ядро!")
		return
	balloon_alert(user, "извлечение ядра...")
	if(!do_after(user, 3 SECONDS, target = src))
		balloon_alert(user, "прервано!")
		return
	balloon_alert(user, "ядро извлечено")
	core.forceMove(drop_location())
	if(Adjacent(user) && !issilicon(user))
		user.put_in_hands(core)
	core = null
	remove_organ_trait(TRAIT_SHOCKIMMUNE)
	update_icon_state()

/obj/item/organ/heart/cybernetic/anomalock/update_icon_state()
	. = ..()
	icon_state = initial(icon_state) + (core ? "-core" : "")

/obj/item/organ/heart/cybernetic/anomalock/prebuilt/Initialize(mapload)
	. = ..()
	core = new /obj/item/assembly/signaler/anomaly/flux(src)
	update_icon_state()

/datum/status_effect/voltaic_overdrive
	id = "voltaic_overdrive"
	duration = 30 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/anomalock_active
	show_duration = TRUE

/datum/status_effect/voltaic_overdrive/tick(seconds_between_ticks)
	. = ..()

	if(owner.health <= owner.crit_threshold)
		owner.heal_overall_damage(5, 5)
		owner.adjustOxyLoss(-5)
		owner.adjustToxLoss(-5)

/datum/status_effect/voltaic_overdrive/on_apply()
	. = ..()
	owner.add_movespeed_mod_immunities(type, /datum/movespeed_modifier/damage_slowdown)
	REMOVE_TRAIT(src, TRAIT_CRITICAL_CONDITION, STAT_TRAIT)
	owner.reagents.add_reagent(/datum/reagent/medicine/coagulant, 5)
	owner.add_filter("emp_shield", 2, outline_filter(1, "#639BFF"))
	to_chat(owner, span_revendanger("Вы чувствуете прилив сил! Со щитом или на щите!"))
	owner.add_traits(list(TRAIT_NOSOFTCRIT, TRAIT_NOHARDCRIT, TRAIT_ANALGESIA), REF(src))

/datum/status_effect/voltaic_overdrive/on_remove()
	. = ..()
	owner.remove_movespeed_mod_immunities(type, /datum/movespeed_modifier/damage_slowdown)
	owner.remove_filter("emp_shield")
	owner.balloon_alert(owner, "ваше сердце слабнет")
	owner.remove_traits(list(TRAIT_NOSOFTCRIT, TRAIT_NOHARDCRIT, TRAIT_ANALGESIA), REF(src))

/atom/movable/screen/alert/status_effect/anomalock_active
	name = "Гальваническая перегрузка"
	icon_state = "anomalock_heart"
	desc = "Поступление гальванической энергии в кровь, которая будет поддерживать ваше тело на протяжении 30 секунд, прежде чем эффект закончится!"

/obj/item/organ/heart/cybernetic/anomalock/hear_beat_noise(mob/living/hearer)
	if(prob(1))
		to_chat(hearer, span_danger("Посмотрим, что выйдет, если прижать металлический диск к груди живой электрической дуги.")) //the guy is LITERALLY sparking like a tesla coil.
	else
		to_chat(hearer, span_danger("Электрическая дуга попадает в ваш стетоскоп и проникает в вас!"))
	if(hearer.electrocute_act(15, "stethoscope", flags = SHOCK_NOGLOVES)) //the stethoscope is in your ears. (returns true if it does damage so we only scream in that case)
		hearer.emote("scream")
	return span_danger("[owner.p_Their()] heart produces [beat_noise].")

#undef DOAFTER_IMPLANTING_HEART
