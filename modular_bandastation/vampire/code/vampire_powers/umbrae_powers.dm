/datum/action/cooldown/spell/vampire_cloak
	name = "Покров тьмы"
	desc = "Включает или выключает сокрытие во тьме. Во тьме при включённой способности вы движетесь быстрее."
	gain_desc = "Вы обрели способность «Покров тьмы»: во тьме она делает вас почти невидимым и очень ловким."
	button_icon = 'modular_bandastation/vampire/icons/mob/actions/actions.dmi'
	button_icon_state = "vampire_cloak"
	cooldown_time = 2 SECONDS

/datum/action/cooldown/spell/vampire_cloak/New(Target)
	. = ..()
	add_vampire_ability()

/datum/action/cooldown/spell/vampire_cloak/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/user = owner
	var/datum/antagonist/vampire/vampire = user.mind.has_antag_datum(/datum/antagonist/vampire)
	vampire.iscloaking = !vampire.iscloaking
	if(istype(user))
		if(vampire.iscloaking)
			user.physiology.burn_mod *= 1.1
			RegisterSignal(user, COMSIG_LIVING_IGNITED, PROC_REF(update_vampire_cloak))
		else
			UnregisterSignal(user, COMSIG_LIVING_IGNITED)
			user.physiology.burn_mod /= 1.1
	to_chat(user, span_notice("Теперь во тьме вас будут [vampire.iscloaking ? "не замечать" : "видеть"]."))

/datum/action/cooldown/spell/vampire_cloak/proc/update_vampire_cloak(datum/source)
	SIGNAL_HANDLER
	var/mob/living/user = owner
	var/datum/antagonist/vampire/vampire = user.mind?.has_antag_datum(/datum/antagonist/vampire)
	vampire?.handle_vampire_cloak(user)

/datum/action/cooldown/spell/pointed/vampire_shadow_snare
	name = "Теневая ловушка"
	desc = "Призовите ловушку на полу. Тот, кто пересечёт её, ослепнет, погасит свои источники света и окажется опутанным."
	gain_desc = "Вы обрели способность призывать ловушку, ослепляющую, опутывающую и гасящую свет у пересёкших её."
	button_icon = 'modular_bandastation/vampire/icons/mob/actions/actions.dmi'
	button_icon_state = "shadow_snare"
	cooldown_time = 20 SECONDS
	cast_range = 7

/datum/action/cooldown/spell/pointed/vampire_shadow_snare/New(Target)
	. = ..()
	add_vampire_ability(20)

/datum/action/cooldown/spell/pointed/vampire_shadow_snare/is_valid_target(atom/cast_on)
	return ..() && isturf(cast_on)

/datum/action/cooldown/spell/pointed/vampire_shadow_snare/cast(atom/cast_on)
	. = ..()
	new /obj/effect/vampire_shadow_snare(get_turf(cast_on))

/obj/effect/vampire_shadow_snare
	name = "теневая ловушка"
	desc = "Почти прозрачная ловушка, растворяющаяся в тенях."
	alpha = 60
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/remaining_integrity = 100
	var/turf/host_turf

/obj/effect/vampire_shadow_snare/proc/on_entered(datum/source, atom/movable/entered)
	SIGNAL_HANDLER
	if(!iscarbon(entered))
		return
	var/mob/living/carbon/target = entered
	if(!target.affects_vampire())
		return
	target.set_light(0)
	target.set_temp_blindness(20 SECONDS)
	target.Immobilize(5 SECONDS)
	qdel(src)

/obj/effect/vampire_shadow_snare/process()
	var/turf/snare_turf = get_turf(src)
	if(snare_turf.get_lumcount() * 10 > 2)
		remaining_integrity -= 50
	if(remaining_integrity <= 0)
		visible_message(span_notice("[src] увядает."))
		qdel(src)

/obj/effect/vampire_shadow_snare/Initialize(mapload)
	. = ..()
	host_turf = get_turf(src)
	RegisterSignal(host_turf, COMSIG_ATOM_ENTERED, PROC_REF(on_entered))
	START_PROCESSING(SSobj, src)

/obj/effect/vampire_shadow_snare/Destroy()
	STOP_PROCESSING(SSobj, src)
	UnregisterSignal(host_turf, COMSIG_ATOM_ENTERED)
	return ..()

/obj/effect/vampire_shadow_snare/attack_hand(mob/user)
	if(iscarbon(user))
		on_entered(null, user)

/obj/effect/vampire_shadow_snare/attack_tk(mob/user)
	if(iscarbon(user))
		to_chat(user, span_userdanger("Ловушка посылает психический откат!"))
		var/mob/living/carbon/carbon_user = user
		carbon_user.set_temp_blindness(20 SECONDS)

/obj/effect/vampire_shadow_snare/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!istype(used, /obj/item/assembly/flash))
		return ..()
	var/obj/item/assembly/flash/flash = used
	if(!flash.try_use_flash(user))
		return ITEM_INTERACT_SUCCESS
	user.visible_message(span_danger("[user] направляет [used] на [src]!"), span_danger("Вы направляете [used] на [src]!"))
	visible_message(span_notice("[src] увядает."))
	qdel(src)
	return ITEM_INTERACT_SUCCESS

/datum/action/cooldown/spell/vampire_soul_anchor
	name = "Якорь души"
	desc = "После задержки призовите межпространственный якорь. Повторное применение телепортирует вас к нему. Через две минуты вас принудительно вернёт назад."
	gain_desc = "Вы обрели способность запоминать точку в пространстве и возвращаться к ней по желанию. Если не вернуться добровольно за две минуты, вас вернёт принудительно."
	button_icon = 'modular_bandastation/vampire/icons/mob/actions/actions.dmi'
	button_icon_state = "shadow_anchor"
	cooldown_time = 3 MINUTES
	var/obj/structure/shadow_anchor/anchor
	var/making_anchor = FALSE
	var/fake_recall_timer

/datum/action/cooldown/spell/vampire_soul_anchor/New(Target)
	. = ..()
	add_vampire_ability(30, FALSE)

/datum/action/cooldown/spell/vampire_soul_anchor/Destroy(force, ...)
	if(fake_recall_timer)
		deltimer(fake_recall_timer)
	QDEL_NULL(anchor)
	return ..()

/datum/action/cooldown/spell/vampire_soul_anchor/before_cast(atom/cast_on)
	return ..() | SPELL_NO_IMMEDIATE_COOLDOWN

/datum/action/cooldown/spell/vampire_soul_anchor/cast(atom/cast_on)
	. = ..()
	var/mob/living/user = owner
	if(making_anchor)
		to_chat(user, span_notice("Ваш якорь ещё не готов!"))
		return
	if(!anchor)
		var/turf/anchor_turf = get_turf(user)
		making_anchor = TRUE
		if(do_after(user, 5 SECONDS, timed_action_flags = IGNORE_USER_LOC_CHANGE|IGNORE_TARGET_LOC_CHANGE|IGNORE_INCAPACITATED|IGNORE_HELD_ITEM, show_progress = FALSE, cog_icon = null) && !QDELETED(src) && !QDELETED(user))
			anchor = new(anchor_turf)
			fake_recall_timer = addtimer(CALLBACK(src, PROC_REF(recall), user, TRUE), 2 MINUTES, TIMER_STOPPABLE)
		making_anchor = FALSE
		return
	recall(user)

/datum/action/cooldown/spell/vampire_soul_anchor/proc/recall(mob/living/user, fake = FALSE)
	StartCooldown()
	if(fake_recall_timer)
		deltimer(fake_recall_timer)
		fake_recall_timer = null
	if(!anchor)
		return
	var/turf/start_turf = get_turf(user)
	var/turf/end_turf = get_turf(anchor)
	QDEL_NULL(anchor)
	if(end_turf.z != start_turf.z)
		return
	if(fake)
		var/mob/living/basic/illusion/escape/decoy = new(end_turf)
		decoy.full_setup(user, life = 10 SECONDS, damage = 0)
		for(var/mob/living/target in view(7, decoy))
			if(target != user)
				decoy.set_target(target)
				break
		var/previous_alpha = user.alpha
		user.alpha = 0
		addtimer(CALLBACK(src, PROC_REF(restore_visibility), user, previous_alpha), 4 SECONDS)
	else
		if(!do_teleport(user, end_turf, channel = TELEPORT_CHANNEL_MAGIC))
			return
	shadow_to_animation(start_turf, end_turf, user)
	GetComponent(/datum/component/vampire_ability).deduct_blood(src)

/datum/action/cooldown/spell/vampire_soul_anchor/proc/restore_visibility(mob/living/user, previous_alpha)
	if(!QDELETED(user))
		user.alpha = previous_alpha

/proc/shadow_to_animation(turf/start_turf, turf/end_turf, mob/user)
	var/obj/effect/immortality_talisman/effect = new(start_turf)
	effect.dir = user.dir
	var/x_difference = end_turf.x - start_turf.x
	var/y_difference = end_turf.y - start_turf.y
	var/distance = sqrt(x_difference ** 2 + y_difference ** 2)
	animate(effect, time = distance, alpha = 0, pixel_x = x_difference * 32, pixel_y = y_difference * 32)
	QDEL_IN(effect, distance)

/obj/structure/shadow_anchor
	name = "теневой якорь"
	desc = "Один взгляд на эту вещь вызывает тревогу."
	icon = 'icons/obj/antags/cult/structures.dmi'
	icon_state = "pylon"
	alpha = 120
	color = "#545454"
	density = TRUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE

/datum/action/cooldown/spell/pointed/vampire_dark_passage
	name = "Тёмный проход"
	desc = "Телепортируйтесь на выбранную клетку."
	gain_desc = "Вы обрели способность перемещаться на небольшое расстояние к выбранной клетке."
	button_icon = 'modular_bandastation/vampire/icons/mob/actions/actions.dmi'
	button_icon_state = "dark_passage"
	cooldown_time = 40 SECONDS
	cast_range = 7

/datum/action/cooldown/spell/pointed/vampire_dark_passage/New(Target)
	. = ..()
	add_vampire_ability(30)

/datum/action/cooldown/spell/pointed/vampire_dark_passage/is_valid_target(atom/cast_on)
	return ..() && isturf(cast_on)
/datum/action/cooldown/spell/pointed/vampire_dark_passage/cast(atom/cast_on)
	. = ..()
	var/turf/target = get_turf(cast_on)
	new /obj/effect/temp_visual/vamp_mist_out(get_turf(owner))
	if(!do_teleport(owner, target, channel = TELEPORT_CHANNEL_MAGIC))
		return
	new /obj/effect/temp_visual/vamp_mist_reappear(get_turf(owner))

/obj/effect/temp_visual/vamp_mist_out
	duration = 2 SECONDS
	icon = 'modular_bandastation/vampire/icons/mob/mob.dmi'
	icon_state = "mist"

/obj/effect/temp_visual/vamp_mist_reappear
	duration = 2 SECONDS
	icon = 'modular_bandastation/vampire/icons/mob/mob.dmi'
	icon_state = "mist_reappear"

/datum/action/cooldown/spell/aoe/vampire_extinguish
	name = "Погасить"
	desc = "Погасите все источники света вокруг себя."
	gain_desc = "Вы обрели способность гасить ближайшие источники света."
	button_icon = 'modular_bandastation/vampire/icons/mob/actions/actions.dmi'
	button_icon_state = "vampire_extinguish"
	cooldown_time = 20 SECONDS
	aoe_radius = 7

/datum/action/cooldown/spell/aoe/vampire_extinguish/New(Target)
	. = ..()
	add_vampire_ability()

/datum/action/cooldown/spell/aoe/vampire_extinguish/get_things_to_cast_on(atom/center)
	return range(aoe_radius, center)
/datum/action/cooldown/spell/aoe/vampire_extinguish/cast_on_thing_in_aoe(turf/target, atom/caster)
	target.set_light(0)
	for(var/atom/atom in target)
		atom.set_light(0)

/datum/action/cooldown/spell/pointed/vampire_shadow_boxing
	name = "Теневой бой"
	desc = "Выберите кого-то, чтобы ваша тень избила его. Для работы нужно находиться не далее двух клеток."
	gain_desc = "Вы обрели способность заставлять свою тень сражаться за вас."
	button_icon = 'modular_bandastation/vampire/icons/mob/actions/actions.dmi'
	button_icon_state = "shadow_boxing"
	cooldown_time = 30 SECONDS
	cast_range = 2

/datum/action/cooldown/spell/pointed/vampire_shadow_boxing/New(Target)
	. = ..()
	add_vampire_ability(50)
/datum/action/cooldown/spell/pointed/vampire_shadow_boxing/is_valid_target(atom/cast_on)
	return ..() && isliving(cast_on)
/datum/action/cooldown/spell/pointed/vampire_shadow_boxing/cast(mob/living/target)
	. = ..()
	if(target.affects_vampire(owner))
		target.apply_status_effect(/datum/status_effect/vampire_shadow_boxing, owner)

/datum/action/cooldown/spell/vampire_eternal_darkness
	name = "Вечная тьма"
	desc = "При включении вы окутываете область вокруг себя тьмой и медленно понижаете температуру тел людей поблизости. Энергетические снаряды в радиусе действия тускнеют."
	gain_desc = "Вы обрели способность окутывать область вокруг себя тьмой. Лишь самый яркий свет способен пробить ваши нечестивые силы."
	button_icon = 'modular_bandastation/vampire/icons/mob/actions/actions.dmi'
	button_icon_state = "eternal_darkness"
	cooldown_time = 2 SECONDS

/datum/action/cooldown/spell/vampire_eternal_darkness/New(Target)
	. = ..()
	add_vampire_ability(5)

/datum/action/cooldown/spell/vampire_eternal_darkness/cast(atom/cast_on)
	. = ..()
	var/datum/antagonist/vampire/vampire = owner.mind.has_antag_datum(/datum/antagonist/vampire)
	var/datum/vampire_passive/eternal_darkness/darkness = vampire.get_ability(/datum/vampire_passive/eternal_darkness)
	if(darkness)
		vampire.remove_ability(darkness)
	else
		owner.set_light(8, -6, "#ddd6cf")
		vampire.force_add_ability(/datum/vampire_passive/eternal_darkness)

/datum/vampire_passive/eternal_darkness
	gain_desc = "Вы окружаете себя противоестественной тьмой, замораживая тех, кто рядом, и ослабляя энергетические снаряды."

/datum/vampire_passive/eternal_darkness/New()
	. = ..()
	START_PROCESSING(SSfastprocess, src)

/datum/vampire_passive/eternal_darkness/Destroy(force, ...)
	owner.set_light(0)
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/datum/vampire_passive/eternal_darkness/process()
	var/datum/antagonist/vampire/vampire = owner.mind?.has_antag_datum(/datum/antagonist/vampire)
	for(var/mob/living/target in view(8, owner))
		if(target.affects_vampire(owner))
			target.adjust_bodytemperature(-3 * TEMPERATURE_DAMAGE_COEFFICIENT)
	for(var/obj/projectile/projectile in view(8, owner))
		if(projectile.armor_flag == ENERGY || projectile.armor_flag == LASER)
			projectile.damage *= 0.7
	vampire.bloodusable = max(vampire.bloodusable - 0.25, 0)
	if(!vampire.bloodusable || owner.stat == DEAD)
		vampire.remove_ability(src)

/datum/vampire_passive/vision/xray
	gain_desc = "Теперь вы видите сквозь стены — если вдруг не заметили."
	lighting_cutoff = LIGHTING_CUTOFF_FULLBRIGHT
	vision_traits = list(TRAIT_THERMAL_VISION, TRAIT_XRAY_VISION)
