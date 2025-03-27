#define INTERNAL_VOLUME 50
#define MAX_FUEL 30
#define FUEL_PER_COAL 30
#define FUEL_CONSUME_INTERVAL 30 SECONDS

#define SMOKE_CONSUME_INTERVAL 1 SECONDS
#define SMOKE_CONSUME_AMOUNT 0.1

#define INHALE_COOLDOWN 5 SECONDS
#define BASE_COUGH_STAMINA_LOSS 5
#define INHALE_STAMINA_LOSS 20

#define BASE_INHALE_VOLUME 3
#define BASE_INHALE_LIMIT 3

#define MAX_FOOD_ITEMS 5

#define RADIAL_CLEAR image(icon = 'modular_bandastation/bar_hookahs/icons/radial.dmi', icon_state = "eject")
#define RADIAL_EXTINGUISH image(icon = 'modular_bandastation/bar_hookahs/icons/radial.dmi', icon_state = "extinguish")
#define RADIAL_BLOW image(icon = 'modular_bandastation/bar_hookahs/icons/radial.dmi', icon_state = "blow")

#define OPTION_CLEAR "Очистить чашу"
#define OPTION_EXTINGUISH "Погасить угли"
#define OPTION_BLOW "Раскурить"

/obj/item/hookah
	name = "hookah"
	desc = "Простой стеклянный водный кальян."
	icon = 'modular_bandastation/bar_hookahs/icons/hookah.dmi'
	icon_state = "hookah"
	max_integrity = 50
	integrity_failure = 0

	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	inhand_icon_state = "beaker"

	w_class = WEIGHT_CLASS_HUGE
	pixel_y = 10

	var/mutable_appearance/pipe_overlay
	var/obj/item/reagent_container
	var/obj/item/hookah_mouthpiece/this_mouthpiece
	var/datum/mouthpiece_attachment/attachment
	var/fuel = 0
	var/lit = FALSE
	COOLDOWN_DECLARE(fuel_consume_cooldown)
	COOLDOWN_DECLARE(smoke_decrease_cooldown)
	var/mutable_appearance/coal_overlay
	var/mutable_appearance/coal_lit_overlay
	var/mutable_appearance/lit_emissive
	var/particle_type
	var/datum/light_source/glow_light
	var/list/food_items = list()
	/// Насколько кальян хорошо раскурен?
	var/smoke_amount = 0

	var/static/allowed_ingridients = typecacheof(list(
		/obj/item/food/grown,
		/obj/item/food/cheese,
		))

/obj/item/hookah/add_context(atom/source, list/context, atom/target, mob/user)
	. = ..()
	context[SCREENTIP_CONTEXT_RMB] = "Взять мундштук"
	context[SCREENTIP_CONTEXT_ALT_RMB] = "Действие"
	return CONTEXTUAL_SCREENTIP_SET

/obj/item/hookah/examine()
	. = ..()
	if(length(food_items))
		var/food_string = ""
		var/count = 1
		for(var/obj/item/food/this_food in food_items)
			food_string += this_food.declent_ru(NOMINATIVE)
			if(count == length(food_items) - 3)
				food_string += " и "
			if(count == length(food_items) - 4)
				food_string += ", "
			count += 1
		. += span_notice("Внутри [length(food_items) ? "- [food_string]" : "ничего нет"].")
	if(lit)
		. += span_notice("[capitalize(src.declent_ru(NOMINATIVE))] зажжён.")

/datum/mouthpiece_attachment
	var/obj/item/hookah/this_hookah
	var/atom/attached_to
	VAR_PRIVATE/datum/beam/beam
/datum/mouthpiece_attachment/New(obj/item/hookah/this_hookah, atom/attached_to)
	src.this_hookah = this_hookah
	src.attached_to = attached_to
	beam = this_hookah.Beam(
		attached_to,
		icon = 'icons/effects/beam.dmi',
		icon_state = "1-full",
		beam_color = COLOR_BLACK,
		layer = BELOW_MOB_LAYER,
		override_origin_pixel_y = 0,
	)

/datum/mouthpiece_attachment/Destroy(force)
	this_hookah = null
	attached_to = null
	QDEL_NULL(beam)
	return ..()

/obj/item/hookah/Initialize(mapload)
	. = ..()
	pipe_overlay = mutable_appearance('modular_bandastation/bar_hookahs/icons/hookah.dmi', "pipe")
	this_mouthpiece = new(src)
	this_mouthpiece.source_hookah = src
	update_appearance(UPDATE_OVERLAYS)
	create_reagents(INTERNAL_VOLUME, TRANSPARENT)
	reagent_container = src
	coal_overlay = mutable_appearance(icon, "coal")
	coal_lit_overlay = mutable_appearance(icon, "coal_lit")
	lit_emissive = emissive_appearance(icon, "lit_overlay", src, alpha = src.alpha)
	register_context()

/obj/item/hookah/update_overlays()
	. = ..()
	if(this_mouthpiece in contents)
		. += pipe_overlay
	if(fuel > 0)
		. += coal_overlay
	if(lit)
		. += coal_lit_overlay
		. += lit_emissive

/obj/item/hookah/proc/return_mouthpiece(obj/item/hookah_mouthpiece/current_mouthpiece)
	if(current_mouthpiece.source_hookah != src)
		return FALSE

	if(this_mouthpiece in contents)
		return FALSE

	current_mouthpiece.forceMove(src)
	update_appearance(UPDATE_OVERLAYS)
	return TRUE

/obj/item/hookah/update_appearance()
	. = ..()
	if(this_mouthpiece in contents)
		QDEL_NULL(attachment)

/obj/item/hookah/attack_hand_secondary(mob/user, list/modifiers)
	if(ismob(loc))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	if(!(this_mouthpiece in contents))
		balloon_alert(user, "уже занято!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	user.put_in_hands(this_mouthpiece)
	this_mouthpiece.source_hookah = src
	to_chat(user, span_notice("Вы берёте [src.declent_ru(NOMINATIVE)] в руку."))
	update_appearance(UPDATE_OVERLAYS)
	attachment = new(src, user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/hookah/proc/try_light(obj/item/O, mob/user)
	if(lit)
		to_chat(user, span_warning("[capitalize(src.declent_ru(NOMINATIVE))] уже зажжён!"))
		return
	if(!fuel)
		to_chat(user, span_warning("В [src.declent_ru(PREPOSITIONAL)] нет углей!"))
		return
	var/msg = O.ignition_effect(src, user)
	if(msg)
		visible_message(msg)
		ignite()
		return TRUE

/obj/item/hookah/attackby(obj/item/attacking_item, mob/user, params)
	if(istype(attacking_item, /obj/item/hookah_mouthpiece))
		return_mouthpiece(attacking_item)
		return
	if(istype(attacking_item, /obj/item/hookah_coals))
		if(fuel + FUEL_PER_COAL > MAX_FUEL)
			to_chat(user, span_warning("В [src.declent_ru(PREPOSITIONAL)] уже достаточно углей!"))
			return
		fuel += FUEL_PER_COAL
		qdel(attacking_item)
		to_chat(user, span_notice("Вы добавляете угли в [src.declent_ru(NOMINATIVE)]."))
		return
	if(istype(attacking_item, /obj/item/food))
		if(length(food_items) >= MAX_FOOD_ITEMS)
			to_chat(user, span_warning("В [src.declent_ru(PREPOSITIONAL)] уже достаточно ингридиентов!"))
			return
		food_items += attacking_item
		attacking_item.forceMove(src)
		to_chat(user, span_notice("Вы добавляете [attacking_item.declent_ru(NOMINATIVE)] в [src.declent_ru(NOMINATIVE)]."))
		return
	if(istype(attacking_item, /obj/item/reagent_containers))
		if(istype(attacking_item, /obj/item/reagent_containers/applicator/pill))
			return
		var/obj/item/reagent_containers/container = attacking_item
		if(!container.reagents.total_volume)
			to_chat(user, span_warning("Внутри [container.declent_ru(GENITIVE)] ничего нет!"))
			return
		if(!reagent_container)
			to_chat(user, span_warning("В [src.declent_ru(PREPOSITIONAL)] нет контейнера для жидкости!"))
			return
		var/transferred = container.reagents.trans_to(reagent_container, container.amount_per_transfer_from_this)
		user.visible_message(span_notice("[user] переливает что-то в [src.declent_ru(NOMINATIVE)]."), span_notice("Вы переливаете [transferred] единиц жидкости в [src.declent_ru(NOMINATIVE)]."))
		return
	if(try_light(attacking_item, user))
		return
	return ..()

/obj/item/hookah/process()
	if(!lit || !fuel)
		return PROCESS_KILL

	if(COOLDOWN_FINISHED(src, fuel_consume_cooldown))
		fuel = max(fuel - 1, 0)
		COOLDOWN_START(src, fuel_consume_cooldown, FUEL_CONSUME_INTERVAL)
		if(fuel <= 0)
			put_out()
			return PROCESS_KILL

	if(COOLDOWN_FINISHED(src, smoke_decrease_cooldown) && (smoke_amount - SMOKE_CONSUME_AMOUNT >= 0))
		smoke_amount -= SMOKE_CONSUME_AMOUNT
		COOLDOWN_START(src, smoke_decrease_cooldown, SMOKE_CONSUME_INTERVAL)

	if(!attachment)
		return

	var/atom/attached_to = attachment.attached_to
	if(!(get_dist(src, attached_to) <= 1 && isturf(attached_to.loc)))
		if(ismob(attached_to))
			var/mob/user = attached_to
			user.dropItemToGround(this_mouthpiece)
			to_chat(user, span_warning("Вы отпускаете [src.declent_ru(NOMINATIVE)]."))
		QDEL_NULL(attachment)

/obj/item/hookah/click_alt_secondary(mob/user)
	var/list/hookah_radial_options = list()
	if(lit)
		hookah_radial_options[OPTION_EXTINGUISH] = RADIAL_EXTINGUISH

	if((length(food_items) || reagent_container?.reagents?.total_volume) && lit)
		hookah_radial_options[OPTION_BLOW] = RADIAL_BLOW

	if(length(food_items) || reagent_container?.reagents?.total_volume)
		hookah_radial_options[OPTION_CLEAR] = RADIAL_CLEAR

	var/choice = show_radial_menu(user, src, hookah_radial_options, require_near = TRUE)

	if(!choice)
		return CLICK_ACTION_BLOCKING

	switch(choice)
		if(OPTION_EXTINGUISH)
			if(!lit)
				return CLICK_ACTION_BLOCKING

			to_chat(user, span_notice("Вы начинаете тушить [src.declent_ru(NOMINATIVE)]..."))
			if(!do_after(user, 2 SECONDS, src))
				return CLICK_ACTION_BLOCKING

			put_out()
			return CLICK_ACTION_SUCCESS

		if(OPTION_BLOW)
			if(!lit)
				return CLICK_ACTION_BLOCKING

			if(!length(food_items) && !reagent_container?.reagents?.total_volume)
				to_chat(user, span_warning("В [src.declent_ru(PREPOSITIONAL)] нет ингридиентов!"))
				return CLICK_ACTION_BLOCKING

			var/mob/living/living_user = user
			if(this_mouthpiece in living_user.held_items)
				user.visible_message(span_notice("[user] глубоко затягивается..."), span_notice("Вы делаете глубокую затяжку..."))
				if(!do_after(user, 5 SECONDS, src))
					return CLICK_ACTION_BLOCKING

				this_mouthpiece.inhale_smoke(living_user, BASE_INHALE_VOLUME * 2, TRUE)
				return CLICK_ACTION_SUCCESS

		if(OPTION_CLEAR)
			if(!reagent_container)
				return CLICK_ACTION_BLOCKING

			if(!do_after(user, 2 SECONDS, src))
				return CLICK_ACTION_BLOCKING

			reagent_container.reagents.clear_reagents()
			to_chat(user, span_notice("Вы очищаете чашу [src.declent_ru(GENITIVE)]."))
			return CLICK_ACTION_SUCCESS

/obj/item/hookah/proc/ignite()
	particle_type = /particles/smoke/cig/big
	add_shared_particles(particle_type)
	lit = TRUE
	START_PROCESSING(SSmachines, src)
	visible_message(span_notice("Угли внутри [src.declent_ru(GENITIVE)] медленно багровеют."))
	update_appearance()
	set_light(2, 1, LIGHT_COLOR_ORANGE)
	smoke_amount = 30
	COOLDOWN_START(src, fuel_consume_cooldown, FUEL_CONSUME_INTERVAL)
	COOLDOWN_START(src, smoke_decrease_cooldown, SMOKE_CONSUME_INTERVAL)

/obj/item/hookah/proc/put_out()
	lit = FALSE
	visible_message(span_notice("Угли внутри [src.declent_ru(GENITIVE)] возвращают свой привычный цвет."))
	update_appearance()
	if(!fuel)
		STOP_PROCESSING(SSmachines, src)
	stop_smoke()
	set_light(0)
	smoke_amount = 0

/obj/item/hookah/proc/stop_smoke()
	if(particle_type)
		remove_shared_particles(particle_type)
		particle_type = null

/obj/item/hookah/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(QDELETED(src))
		return
	atom_destruction()

/obj/item/hookah/atom_destruction(damage_flag)
	fuel = 0
	new /obj/item/shard(get_turf(src))
	if(reagent_container && reagent_container.reagents?.total_volume)
		reagent_container.reagents.expose(get_turf(src), TOUCH)

	if(length(food_items))
		for(var/obj/item/food/this_food in food_items)
			var/turf/drop_loc = get_turf(src)
			var/obj/item/food/food_item = this_food
			if(food_item.reagents?.total_volume)
				food_item.reagents.expose(drop_loc, TOUCH)
			qdel(food_item)

	if(this_mouthpiece)
		qdel(this_mouthpiece)

	QDEL_LIST(food_items)
	visible_message(span_warning("[capitalize(src.declent_ru(NOMINATIVE))] с треском разлетается на осколки!"))
	playsound(src, SFX_SHATTER, 50)
	return ..()

/obj/item/hookah/pickup(mob/user)
	. = ..()
	if(this_mouthpiece && !(this_mouthpiece in contents))
		return_mouthpiece(this_mouthpiece)
		if(attachment)
			QDEL_NULL(attachment)
		to_chat(user, span_notice("Мундштук возвращается в [src.declent_ru(NOMINATIVE)]."))

/obj/item/hookah/Destroy()
	if(reagent_container)
		reagent_container = null

	if(particle_type)
		remove_shared_particles(particle_type)
		particle_type = null

	QDEL_LIST(food_items)
	if(this_mouthpiece)
		this_mouthpiece.source_hookah = null
		qdel(this_mouthpiece)

	if(attachment)
		attachment = null

	set_light(0)
	return ..()

/obj/item/hookah_mouthpiece
	name = "mouthpiece"
	desc = "Мундштук, выполненный из какого-то лёгкого металла. На его ручке что-то выгравировано."
	icon = 'modular_bandastation/bar_hookahs/icons/hookah.dmi'
	icon_state = "mouthpiece"
	w_class = WEIGHT_CLASS_BULKY
	var/obj/item/hookah/source_hookah
	var/datum/beam/beam
	COOLDOWN_DECLARE(inhale_cooldown)
	var/particle_type

/obj/item/hookah_mouthpiece/Initialize(mapload, obj/item/hookah/hookah)
	. = ..()
	if(hookah)
		source_hookah = hookah

/obj/item/hookah_mouthpiece/Destroy()
	if(source_hookah)
		if(source_hookah.attachment)
			QDEL_NULL(source_hookah.attachment)
		source_hookah?.stop_smoke()
		source_hookah.this_mouthpiece = null
	return ..()

/obj/item/hookah_mouthpiece/dropped(mob/user)
	. = ..()
	if(source_hookah)
		source_hookah.return_mouthpiece(src)


/obj/item/hookah_mouthpiece/attack_self(mob/living/carbon/human/user)
	if(!source_hookah || !source_hookah.lit)
		return ..()
	start_inhale(user)

/obj/item/hookah_mouthpiece/attack(mob/living/carbon/human/this_human, mob/living/carbon/human/user)
	if(this_human == user && source_hookah?.lit)
		start_inhale(user)
		return
	return ..()

// мелкий прок для дуафтера
/obj/item/hookah_mouthpiece/proc/start_inhale(mob/living/carbon/human/user)
	user.visible_message(span_notice("[user] затягивается из [src.declent_ru(GENITIVE)]."), span_notice("Вы затягиваетесь..."))
	if(!do_after(user, 2 SECONDS, src)) // дымим?
		return
	inhale_smoke(user, BASE_INHALE_VOLUME)

// дымим, господа! разрешили!
/obj/item/hookah_mouthpiece/proc/inhale_smoke(mob/living/carbon/human/user, amount, skip_calculations = FALSE)
	var/is_safe = TRUE
	var/mob/living/living_user = user
	if(HAS_TRAIT(living_user, TRAIT_NOBREATH))
		to_chat(user, span_warning("Вы не можете сделать и вдоха!"))
		return

	if(!source_hookah || !source_hookah.reagent_container || !source_hookah.reagent_container.reagents)
		return

	var/datum/reagents/these_reagents = source_hookah.reagent_container.reagents
	for(var/obj/item/food/this_food in source_hookah.food_items)
		if(!this_food.reagents)
			qdel(this_food)
			continue

		if(!is_type_in_typecache(this_food, source_hookah.allowed_ingridients))
			is_safe = FALSE

		this_food.reagents.trans_to(these_reagents, amount / length(source_hookah.food_items))
		if(!this_food.reagents.total_volume)
			source_hookah.food_items -= this_food
			qdel(this_food)

	if(!is_safe)
		var/datum/effect_system/fluid_spread/smoke/chem/black_smoke = new
		black_smoke.set_up(2, location = source_hookah.loc, carry = these_reagents)
		black_smoke.start()
		QDEL_LIST(source_hookah.food_items)
		these_reagents?.clear_reagents()
		to_chat(user, span_warning("Вы чувствуете резкий неприятный запах!"))
		user.dropItemToGround(src)
		user.emote("cough")
		user.adjustStaminaLoss(BASE_COUGH_STAMINA_LOSS * 4)
		return

	if(!source_hookah.reagent_container || !source_hookah.reagent_container.reagents.total_volume)
		to_chat(user, span_warning("В [src.declent_ru(GENITIVE)] нет жидкости!"))
		return

	var/smoke_efficiency = min(source_hookah.smoke_amount, 100) / 100
	var/amount_to_transfer = 0

	if(skip_calculations)
		amount_to_transfer = amount
	else
		amount_to_transfer = amount * smoke_efficiency

	var/amount_to_waste = amount - amount_to_transfer
	var/transferred = these_reagents.trans_to(user, amount_to_transfer, methods = INHALE)

	playsound(src, 'sound/effects/bubbles/bubbles.ogg', 20)
	if(transferred)
		to_chat(user, span_notice("Вы вдыхаете дым из [src.declent_ru(GENITIVE)]."))
		user.add_mood_event("smoked", /datum/mood_event/smoked)

		if(!COOLDOWN_FINISHED(src, inhale_cooldown) || transferred > BASE_INHALE_LIMIT)
			user.visible_message(span_warning(pick("[user] закашливается!", "[user] морщится, откашливаясь.", "[user] задыхается!")), span_warning(pick("Голова кружится...", "Вы закашливаетесь, морщась от острого покалывания в горле.", "Вы задыхаетесь!")))
			user.emote("cough")
			user.adjustStaminaLoss(BASE_COUGH_STAMINA_LOSS * (transferred / BASE_INHALE_LIMIT))

		switch(smoke_efficiency * 100)
			if(-INFINITY to 20)
				to_chat(user, span_warning("Ваше горло словно обжигает..."))
				user.emote("cough")
			if(20 to 40)
				to_chat(user, span_notice("Слегка горчит."))
			if(40 to 80)
				to_chat(user, span_notice("Довольно приятный вкус..."))
			else
				to_chat(user, span_notice("Неплохой дымок."))

		COOLDOWN_START(src, inhale_cooldown, INHALE_COOLDOWN)
		source_hookah.smoke_amount = min(source_hookah.smoke_amount + rand(amount * 2, amount), 100)
		addtimer(CALLBACK(src, .proc/delayed_puff, user, amount_to_waste), 1 SECONDS)

/obj/item/hookah_mouthpiece/proc/delayed_puff(mob/user, amount)
	var/datum/effect_system/fluid_spread/smoke/chem/quick/puff = new
	puff.set_up(amount / 5, amount * 0.2, location = user.loc, carry = source_hookah.reagent_container.reagents)
	puff.start()

/obj/item/hookah_coals
	name = "hookah coals"
	desc = "Плотные угольки, филигранно обработанные до состояния кубика."
	icon = 'modular_bandastation/bar_hookahs/icons/hookah.dmi'
	icon_state = "coals"
	custom_premium_price = PAYCHECK_CREW * 1.5

/obj/item/hookah_coals/examine()
	. = ..()
	. += span_info("В кучке три кубика.")

/obj/machinery/vending/cigarette/New()
	premium += list(
		/obj/item/hookah_coals = 3,
	)
	. = ..()

/datum/supply_pack/misc/hookah_kit
	name = "Набор для кальяна"
	desc = "Комплект для любителей подымить и культурно расслабиться. Наполнение не включено."
	cost = 200
	contains = list(
		/obj/item/hookah,
		/obj/item/hookah_coals = 3
	)
	crate_name = "ящик с набором для кальяна"

#undef INTERNAL_VOLUME
#undef MAX_FUEL
#undef FUEL_PER_COAL
#undef FUEL_CONSUME_INTERVAL
#undef SMOKE_CONSUME_INTERVAL
#undef SMOKE_CONSUME_AMOUNT
#undef INHALE_COOLDOWN
#undef BASE_COUGH_STAMINA_LOSS
#undef INHALE_STAMINA_LOSS
#undef BASE_INHALE_VOLUME
#undef BASE_INHALE_LIMIT
#undef MAX_FOOD_ITEMS
#undef RADIAL_CLEAR
#undef RADIAL_EXTINGUISH
#undef RADIAL_BLOW
#undef OPTION_CLEAR
#undef OPTION_EXTINGUISH
#undef OPTION_BLOW
