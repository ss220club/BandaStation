/datum/action/cooldown/spell/vampire_vamp_claws
	name = "Вампирские когти"
	desc = "Направьте магию крови, чтобы выковать смертоносные вампирские когти, высасывающие кровь и быстро наносящие удары. Нельзя использовать, если вы держите непередаваемый предмет."
	gain_desc = "Вы обрели способность превращать руки в вампирские когти."
	button_icon = 'modular_bandastation/vampire/icons/mob/actions/actions.dmi'
	button_icon_state = "vampire_claws"
	cooldown_time = 30 SECONDS

/datum/action/cooldown/spell/vampire_vamp_claws/New(Target)
	. = ..()
	add_vampire_ability(30)

/datum/action/cooldown/spell/vampire_vamp_claws/can_cast_spell(feedback = TRUE)
	if(!..())
		return FALSE
	var/mob/living/carbon/user = owner
	if(!user)
		return FALSE
	for(var/obj/item/held_item as anything in user.held_items)
		if(held_item && HAS_TRAIT(held_item, TRAIT_NODROP))
			return FALSE
	return TRUE

/datum/action/cooldown/spell/vampire_vamp_claws/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/user = owner
	if(user.get_num_held_items())
		to_chat(user, span_notice("Вы роняете то, что держали: из ваших пальцев вырастают большие клинки!"))
		user.drop_all_held_items()
	else
		to_chat(user, span_notice("Из ваших пальцев вырастают большие кровавые клинки!"))
	var/obj/item/vamp_claws/claws = new(get_turf(user))
	user.put_in_hands(claws)

/obj/item/vamp_claws
	name = "вампирские когти"
	desc = "Пара потусторонних когтей из живой крови."
	icon = 'modular_bandastation/vampire/icons/effects/vampire_effects.dmi'
	icon_state = "vamp_claws"
	w_class = WEIGHT_CLASS_BULKY
	obj_flags = ABSTRACT | DROPDEL
	force = 10
	armour_penetration = 20
	sharpness = SHARP_EDGED
	hitsound = 'modular_bandastation/vampire/sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("рубит", "протыкает", "рассекает", "царапает")
	attack_verb_simple = list("рубануть", "проткнуть", "рассечь", "царапнуть")
	var/durability = 15
	var/blood_drain_amount = 15
	var/blood_absorbed_amount = 5
	var/xenomorph_acid_boosted = FALSE
	var/heal_boost = 1

/obj/item/vamp_claws/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands = TRUE)
	ADD_TRAIT(src, TRAIT_NODROP, REF(src))

/obj/item/vamp_claws/attack(mob/living/target, mob/living/user, params)
	if(..())
		return
	var/datum/antagonist/vampire/vampire = user.mind?.has_antag_datum(/datum/antagonist/vampire)
	if(!vampire || !iscarbon(target))
		return
	var/mob/living/carbon/carbon_target = target
	if(isalien(carbon_target) && !xenomorph_acid_boosted && carbon_target.ckey && carbon_target.stat != DEAD)
		to_chat(user, span_warning("Когда [carbon_target] истекает кислотой, вы добавляете её в свои когти!"))
		xenomorph_acid_boosted = TRUE
		durability += 5
		blood_drain_amount *= 1.5
		blood_absorbed_amount *= 1.5
		force *= 1.5
		heal_boost = 2
		damtype = BURN
	if(carbon_target.ckey && carbon_target.stat != DEAD && carbon_target.affects_vampire(user) && (isalien(carbon_target) || carbon_target.get_blood_volume()))
		carbon_target.bleed(blood_drain_amount)
		vampire.adjust_blood(carbon_target, blood_absorbed_amount)
		user.adjust_stamina_loss(-20 * heal_boost)
		user.heal_overall_damage(4 * heal_boost, 4 * heal_boost)
		user.AdjustKnockdown(-1 SECONDS * heal_boost)
	if(!vampire.get_ability(/datum/vampire_passive/blood_spill) && !--durability)
		to_chat(user, span_warning("Ваши когти разбиваются!"))
		qdel(src)

/obj/item/vamp_claws/melee_attack_chain(mob/user, atom/target, params)
	. = ..()
	if(HAS_TRAIT(src, TRAIT_WIELDED))
		user.changeNext_move(CLICK_CD_MELEE * 0.5)

/obj/item/vamp_claws/attack_self(mob/user)
	. = ..()
	if(.)
		return
	to_chat(user, span_notice("Вы развеиваете свои когти!"))
	qdel(src)

/datum/action/cooldown/spell/pointed/vampire_blood_tendrils
	name = "Кровавые щупальца"
	desc = "После задержки призовите небольшое поле ужасных кровавых щупалец, которое опутает и замедлит людей в области."
	gain_desc = "Вы обрели способность призывать кровавые щупальца, замедляющие людей в выбранной области."
	button_icon = 'modular_bandastation/vampire/icons/mob/actions/actions.dmi'
	button_icon_state = "blood_tendrils"
	cooldown_time = 30 SECONDS
	cast_range = 7
	var/area_of_affect = 1

/datum/action/cooldown/spell/pointed/vampire_blood_tendrils/New(Target)
	. = ..()
	add_vampire_ability(10)

/datum/action/cooldown/spell/pointed/vampire_blood_tendrils/cast(atom/cast_on)
	. = ..()
	var/turf/target_turf = get_turf(cast_on)
	for(var/turf/open/turf in range(area_of_affect, target_turf))
		new /obj/effect/temp_visual/blood_tendril(turf)
	addtimer(CALLBACK(src, PROC_REF(apply_slowdown), target_turf, owner), 0.5 SECONDS)

/datum/action/cooldown/spell/pointed/vampire_blood_tendrils/proc/apply_slowdown(turf/target_turf, mob/living/user)
	for(var/mob/living/target in range(area_of_affect, target_turf))
		if(target.affects_vampire(user))
			target.set_timed_status_effect(6 SECONDS, /datum/status_effect/staggered)
			target.visible_message(span_warning("[target] опутан кровавыми щупальцами!"))
			new /obj/effect/temp_visual/blood_tendril/long(get_turf(target))

/obj/effect/temp_visual/blood_tendril
	icon = 'modular_bandastation/vampire/icons/effects/vampire_effects.dmi'
	icon_state = "blood_tendril"
/obj/effect/temp_visual/blood_tendril/long
	duration = 2 SECONDS

/datum/action/cooldown/spell/pointed/vampire_blood_barrier
	name = "Кровавый барьер"
	desc = "Выберите две точки на расстоянии не более трёх клеток друг от друга, чтобы создать между ними барьер."
	gain_desc = "Вы обрели способность призывать между двумя точками кристаллическую стену из крови. Барьер легко разрушить, но вы можете свободно проходить сквозь него."
	button_icon = 'modular_bandastation/vampire/icons/mob/actions/actions.dmi'
	button_icon_state = "blood_barrier"
	cooldown_time = 1 MINUTES
	cast_range = 7
	var/max_walls = 3
	var/turf/start_turf

/datum/action/cooldown/spell/pointed/vampire_blood_barrier/New(Target)
	. = ..()
	add_vampire_ability(40, FALSE)

/datum/action/cooldown/spell/pointed/vampire_blood_barrier/before_cast(atom/cast_on)
	return ..() | SPELL_NO_IMMEDIATE_COOLDOWN

/datum/action/cooldown/spell/pointed/vampire_blood_barrier/cast(atom/cast_on)
	. = ..()
	var/turf/target_turf = get_turf(cast_on)
	if(target_turf == start_turf)
		to_chat(owner, span_notice("Вы отменяете выбор целевой клетки."))
		start_turf = null
		return
	if(!start_turf)
		start_turf = target_turf
		to_chat(owner, span_notice("Выберите другой конец кровавого барьера."))
		return
	var/wall_count = 0
	for(var/turf/turf as anything in get_line(target_turf, start_turf))
		if(wall_count++ >= max_walls)
			break
		new /obj/structure/blood_barrier(turf)
	GetComponent(/datum/component/vampire_ability).deduct_blood(src)
	start_turf = null
	StartCooldown()

/obj/structure/blood_barrier
	name = "кровавый барьер"
	desc = "Гротескное сооружение из кристаллизованной крови. Оно медленно тает."
	max_integrity = 100
	icon_state = "blood_barrier"
	icon = 'modular_bandastation/vampire/icons/effects/vampire_effects.dmi'
	density = TRUE
	anchored = TRUE

/obj/structure/blood_barrier/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)
/obj/structure/blood_barrier/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()
/obj/structure/blood_barrier/process()
	take_damage(20, sound_effect = FALSE)
/obj/structure/blood_barrier/atom_destruction(damage_flag)
	new /obj/effect/decal/cleanable/blood(loc)
	return ..()
/obj/structure/blood_barrier/CanPass(atom/movable/mover, border_dir)
	..()
	if(!isliving(mover))
		return FALSE
	var/mob/living/living_mover = mover
	var/datum/antagonist/vampire/vampire = living_mover.mind?.has_antag_datum(/datum/antagonist/vampire)
	return vampire && is_type_in_list(vampire.subclass, list(SUBCLASS_HEMOMANCER, SUBCLASS_ANCIENT))

/datum/action/cooldown/spell/jaunt/ethereal_jaunt/vampire_blood_pool
	name = "Кровавая лужа"
	desc = "Превратитесь в лужу крови, став неуязвимым и способным проходить через всё, кроме стен и космоса. При движении вы оставляете кровавый след."
	gain_desc = "Вы обрели способность превращаться в лужу крови, чтобы с высокой мобильностью уходить от преследователей."
	button_icon = 'modular_bandastation/vampire/icons/mob/actions/actions.dmi'
	button_icon_state = "blood_pool"
	cooldown_time = 30 SECONDS
	jaunt_duration = 3 SECONDS
	jaunt_type = /obj/effect/dummy/phased_mob/vampire_blood_pool

/datum/action/cooldown/spell/jaunt/ethereal_jaunt/vampire_blood_pool/New(Target)
	. = ..()
	add_vampire_ability(50)

/obj/effect/dummy/phased_mob/vampire_blood_pool
	parent_type = /obj/effect/dummy/phased_mob/spell_jaunt

/obj/effect/dummy/phased_mob/vampire_blood_pool/relaymove(mob/living/user, direction)
	var/turf/old_turf = get_turf(src)
	. = ..()
	if(get_turf(src) != old_turf)
		new /obj/effect/decal/cleanable/blood(old_turf)

/datum/action/cooldown/spell/vampire_predator_senses
	name = "Чувства хищника"
	desc = "Выследите добычу — ей негде спрятаться..."
	gain_desc = "Ваши чувства обострились: теперь от вас никто не скроется."
	button_icon = 'modular_bandastation/vampire/icons/mob/actions/actions.dmi'
	button_icon_state = "predator_sense"
	cooldown_time = 20 SECONDS

/datum/action/cooldown/spell/vampire_predator_senses/New(Target)
	. = ..()
	add_vampire_ability()

/datum/action/cooldown/spell/vampire_predator_senses/cast(atom/cast_on)
	. = ..()
	var/mob/living/user = owner
	var/list/prey = list()
	for(var/mob/living/carbon/human/target in GLOB.alive_mob_list)
		if(target != user && target.mind && target.z == user.z)
			prey[target.real_name] = target
	if(!length(prey))
		to_chat(user, span_warning("Здесь нет добычи для охоты."))
		return
	var/target_name = tgui_input_list(user, "Кого выследить", "Запах крови", prey)
	if(!target_name)
		return
	var/mob/living/carbon/human/target = prey[target_name]
	var/message = "[target_name] находится в [get_area(target)], [dir2text(get_dir(user, target))] от вас."
	if((target.maxHealth - target.health >= 40) || target.get_bleed_rate())
		message += " Цель ранена."
	to_chat(user, span_notice(message))

/datum/action/cooldown/spell/aoe/vampire_blood_eruption
	name = "Кровавое извержение"
	desc = "Из каждой лужи крови в радиусе четырёх клеток вырывается шип из живой крови, ранящий стоящих на ней."
	gain_desc = "Вы обрели способность превращать лужи крови в оружие против стоящих на них."
	button_icon = 'modular_bandastation/vampire/icons/mob/actions/actions.dmi'
	button_icon_state = "blood_spikes"
	cooldown_time = 200 SECONDS
	aoe_radius = 4

/datum/action/cooldown/spell/aoe/vampire_blood_eruption/New(Target)
	. = ..()
	add_vampire_ability(100)

/datum/action/cooldown/spell/aoe/vampire_blood_eruption/get_things_to_cast_on(atom/center)
	. = list()
	for(var/mob/living/target in range(aoe_radius, center))
		if(target.affects_vampire(owner) && target.client && locate(/obj/effect/decal/cleanable/blood) in get_turf(target))
			. += target

/datum/action/cooldown/spell/aoe/vampire_blood_eruption/cast_on_thing_in_aoe(mob/living/target, atom/caster)
	var/turf/turf = get_turf(target)
	var/obj/effect/decal/cleanable/blood/blood = locate(/obj/effect/decal/cleanable/blood) in turf
	var/obj/effect/temp_visual/blood_spike/spike = new(turf)
	spike.color = blood.color
	playsound(target, 'modular_bandastation/vampire/sound/misc/demon_attack1.ogg', 50, TRUE)
	target.apply_damage(50, BRUTE, BODY_ZONE_CHEST)
	target.visible_message(span_warning("[target] пронзён шипом из живой крови!"))

/obj/effect/temp_visual/blood_spike
	icon = 'modular_bandastation/vampire/icons/effects/vampire_effects.dmi'
	icon_state = "bloodspike_white"
	duration = 0.3 SECONDS

/datum/action/cooldown/spell/vampire_blood_spill
	name = "Ритуал несущего кровь"
	desc = "При включении все вокруг начинают обильно истекать кровью. Вы высасываете её и омолаживаете себя."
	gain_desc = "Вы обрели способность вырывать из людей саму жизненную силу и поглощать её, исцеляясь."
	button_icon = 'modular_bandastation/vampire/icons/mob/actions/actions.dmi'
	button_icon_state = "blood_bringers_rite"
	cooldown_time = 2 SECONDS

/datum/action/cooldown/spell/vampire_blood_spill/New(Target)
	. = ..()
	add_vampire_ability(10)

/datum/action/cooldown/spell/vampire_blood_spill/cast(atom/cast_on)
	. = ..()
	var/datum/antagonist/vampire/vampire = owner.mind.has_antag_datum(/datum/antagonist/vampire)
	var/datum/vampire_passive/blood_spill/rite = vampire.get_ability(/datum/vampire_passive/blood_spill)
	if(rite)
		vampire.remove_ability(rite)
	else
		vampire.force_add_ability(/datum/vampire_passive/blood_spill)

/datum/vampire_passive/blood_spill
	var/max_beams = 10

/datum/vampire_passive/blood_spill/New()
	. = ..()
	START_PROCESSING(SSobj, src)

/datum/vampire_passive/blood_spill/Destroy(force, ...)
	STOP_PROCESSING(SSobj, src)
	return ..()

/datum/vampire_passive/blood_spill/process()
	var/datum/antagonist/vampire/vampire = owner.mind?.has_antag_datum(/datum/antagonist/vampire)
	if(!vampire)
		return
	var/beam_number = 0
	for(var/mob/living/carbon/human/target in view(7, owner))
		if(!target.get_blood_volume() || !target.affects_vampire(owner) || target.stat)
			continue
		var/drain_amount = rand(5, 10)
		target.bleed(drain_amount)
		target.Beam(owner, icon_state = "drainbeam", time = 2 SECONDS)
		target.adjust_brute_loss(2)
		owner.heal_overall_damage(8, 2, TRUE)
		owner.adjust_stamina_loss(-15)
		owner.AdjustStun(-2 SECONDS)
		owner.AdjustKnockdown(-2 SECONDS)
		owner.AdjustImmobilized(-2 SECONDS)
		if(++beam_number >= max_beams)
			break
	vampire.bloodusable = max(vampire.bloodusable - 10, 0)
	if(!vampire.bloodusable || owner.stat == DEAD)
		vampire.remove_ability(src)
