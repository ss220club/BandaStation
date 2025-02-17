#define INTERNAL_VOLUME 50
#define MAX_FUEL 30
#define FUEL_PER_COAL 30
#define FUEL_CONSUME_INTERVAL 30 SECONDS
#define INHALE_VOLUME 4
#define SPREAD_VOLUME 1
#define INHALE_COOLDOWN 5 SECONDS
#define COUGH_STAMINA_LOSS 5

/obj/machinery/hookah
	name = "hookah"
	desc = "Простой стеклянный водный кальян."
	icon = 'modular_bandastation/bar_hookahs/icons/hookah.dmi'
	icon_state = "hookah"
	max_integrity = 50
	integrity_failure = 0
	anchored = FALSE
	can_be_unanchored = TRUE

	pixel_y = 10

	var/mutable_appearance/pipe_overlay
	var/obj/item/reagent_container
	var/obj/item/hookah_mouthpiece/this_mouthpiece
	var/datum/mouthpiece_attachment/attachment
	var/fuel = 0
	var/lit = FALSE
	var/last_fuel_consume = 0
	var/mutable_appearance/coal_overlay
	var/mutable_appearance/coal_lit_overlay
	var/mutable_appearance/lit_emissive
	var/particle_type
	var/datum/light_source/glow_light
	var/list/food_items = list()
	var/max_food_items = 3

	var/static/allowed_ingridients = typecacheof(list(
		/obj/item/food/grown,
		/obj/item/food/cheese
		))

/obj/machinery/hookah/examine()
	. = ..()
	. += "<span class='info'>ALT+ЛКМ погасит кальян, ALT+ПКМ очистит ёмкость.</span>"
	if(length(food_items))
		var/food_string = ""
		var/count = 1
		for(var/obj/item/food/this_food in food_items)
			food_string += this_food.name
			if(count == length(food_items) - 1)
				food_string += " и "
			if(count == length(food_items) - 2)
				food_string += ", "
			count += 1
		. += "<span class='info'>Внутри - [food_string].</span>"
	if(lit)
		. += "<span class='info'>Кальян зажжён.</span>"

/datum/mouthpiece_attachment
	var/obj/machinery/hookah/this_hookah
	var/atom/attached_to
	VAR_PRIVATE
		datum/beam/beam
/datum/mouthpiece_attachment/New(
	obj/machinery/hookah/this_hookah,
	atom/attached_to
)
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

/obj/machinery/hookah/Initialize(mapload)
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

/obj/machinery/hookah/update_overlays()
	. = ..()
	if(this_mouthpiece in contents)
		. += pipe_overlay
	if(fuel > 0)
		. += coal_overlay
	if(lit)
		. += coal_lit_overlay
		. += lit_emissive

/obj/machinery/hookah/proc/return_mouthpiece(mouthpiece)
	var/obj/item/hookah_mouthpiece/current_mouthpiece = mouthpiece
	if(current_mouthpiece.source_hookah != src)
		return FALSE
	if(this_mouthpiece in contents)
		return FALSE
	current_mouthpiece.forceMove(src)
	update_appearance(UPDATE_OVERLAYS)
	return TRUE

/obj/machinery/hookah/update_appearance()
	. = ..()
	if(this_mouthpiece in contents)
		QDEL_NULL(attachment)

/obj/machinery/hookah/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(this_mouthpiece in contents)
		user.put_in_hands(this_mouthpiece)
		this_mouthpiece.source_hookah = src
		to_chat(user, span_notice("Вы берёте мундштук в руку."))
		update_appearance(UPDATE_OVERLAYS)
		attachment = new(src, user)
	else
		balloon_alert(user, "уже занято!")

/obj/machinery/hookah/proc/try_light(obj/item/O, mob/user)
	if(lit)
		to_chat(user, span_warning("Кальян уже зажжён!"))
		return
	if(!fuel)
		to_chat(user, span_warning("В кальяне нет углей!"))
		return
	var/msg = O.ignition_effect(src, user)
	if(msg)
		visible_message(msg)
		ignite()
		return TRUE

/obj/machinery/hookah/attackby(obj/item/this_item, mob/user, params)
	if(istype(this_item, /obj/item/hookah_mouthpiece))
		return_mouthpiece(this_item)
		return
	if(istype(this_item, /obj/item/hookah_coals))
		if(fuel + FUEL_PER_COAL > MAX_FUEL)
			to_chat(user, span_warning("В кальяне уже достаточно углей!"))
			return
		fuel += FUEL_PER_COAL
		qdel(this_item)
		to_chat(user, span_notice("Вы добавляете угли в кальян."))
		return
	if(istype(this_item, /obj/item/food))
		if(food_items.len >= max_food_items)
			to_chat(user, span_warning("В кальяне уже достаточно ингридиентов!"))
			return
		food_items += this_item
		this_item.forceMove(src)
		to_chat(user, span_notice("Вы добавляете [this_item] в кальян."))
		return
	if(istype(this_item, /obj/item/reagent_containers))
		if(istype(this_item, /obj/item/reagent_containers/pill))
			return
		var/obj/item/reagent_containers/container = this_item
		if(!container.reagents.total_volume)
			to_chat(user, span_warning("[container] пуст!"))
			return
		if(!reagent_container)
			to_chat(user, span_warning("В кальяне нет контейнера для жидкости!"))
			return
		var/transferred = container.reagents.trans_to(reagent_container, container.amount_per_transfer_from_this)
		user.visible_message(span_notice("[user] переливает что-то в кальян."), span_notice("Вы перелили [transferred] единиц жидкости в кальян."))
		return
	if(try_light(this_item, user))
		return
	return ..()

/obj/item/hookah_mouthpiece
	name = "mouthpiece"
	desc = "Мундштук, выполненный из какого-то лёгкого металла. На его ручке что-то выгравировано."
	icon = 'modular_bandastation/bar_hookahs/icons/hookah.dmi'
	icon_state = "mouthpiece"
	w_class = WEIGHT_CLASS_SMALL
	var/obj/machinery/hookah/source_hookah
	var/datum/beam/beam
	var/last_inhale = 0
	var/particle_type

/obj/item/hookah_mouthpiece/Initialize(mapload, obj/machinery/hookah/hookah)
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

/obj/item/hookah_mouthpiece/pickup(mob/user)
	. = ..()

/obj/item/hookah_coals
	name = "hookah coals"
	desc = "Плотные угольки, филигранно обработанные до состояния кубика."
	icon = 'modular_bandastation/bar_hookahs/icons/hookah.dmi'
	icon_state = "coals"
	custom_premium_price = PAYCHECK_CREW * 1.5

/obj/item/hookah_coals/examine()
	. = ..()
	. += "<span class='info'>В кучке три кубика.</span>"

/obj/machinery/hookah/process()
	if(!lit || !fuel)
		return PROCESS_KILL

	if(world.time > last_fuel_consume + FUEL_CONSUME_INTERVAL)
		fuel = max(fuel - 1, 0)
		last_fuel_consume = world.time
		if(fuel <= 0)
			put_out()
			return PROCESS_KILL

	if(attachment)
		var/atom/attached_to = attachment.attached_to
		if(!(get_dist(src, attached_to) <= 1 && isturf(attached_to.loc)))
			if(ismob(attached_to))
				var/mob/user = attached_to
				user.dropItemToGround(this_mouthpiece)
				to_chat(user, span_warning("Вы отпускаете мундштук."))
			QDEL_NULL(attachment)

/obj/machinery/hookah/click_alt(mob/user)
	if(!lit)
		return CLICK_ACTION_BLOCKING
	to_chat(user, span_notice("Вы начинаете тушить кальян..."))
	if(!do_after(user, 2 SECONDS, src))
		return CLICK_ACTION_BLOCKING
	put_out()
	return CLICK_ACTION_SUCCESS

/obj/machinery/hookah/proc/ignite()
	particle_type = /particles/smoke/cig/big
	add_shared_particles(particle_type)
	lit = TRUE
	START_PROCESSING(SSmachines, src)
	visible_message(span_notice("Угли внутри кальяна медленно багровеют."))
	update_appearance()
	set_light(2, 1, LIGHT_COLOR_ORANGE)

/obj/machinery/hookah/proc/put_out()
	lit = FALSE
	visible_message(span_notice("Угли внутри кальяна возвращают свой привычный цвет."))
	update_appearance()
	if(!fuel)
		STOP_PROCESSING(SSmachines, src)
	stop_smoke()
	set_light(0)

/obj/machinery/hookah/click_alt_secondary(mob/user)
	if(!reagent_container)
		return CLICK_ACTION_BLOCKING
	if(!do_after(user, 2 SECONDS, src))
		return CLICK_ACTION_BLOCKING
	reagent_container.reagents.clear_reagents()
	to_chat(user, span_notice("Вы очистили внутреннее хранилище реагентов кальяна."))
	return CLICK_ACTION_SUCCESS

/obj/item/hookah_mouthpiece/attack_self(mob/living/carbon/human/user)
	if(!source_hookah || !source_hookah.lit)
		return ..()
	start_inhale(user)

/obj/item/hookah_mouthpiece/attack(mob/living/carbon/human/this_human, mob/living/carbon/human/user)
	if(this_human == user && source_hookah?.lit)
		start_inhale(user)
		return
	return ..()

/obj/item/hookah_mouthpiece/proc/start_inhale(mob/living/carbon/human/user)
	user.visible_message(span_notice("[user] затягивается из кальяна."), span_notice("Вы затягиваетесь..."))
	if(!do_after(user, 2 SECONDS, src))
		return
	inhale_smoke(user)

/obj/item/hookah_mouthpiece/proc/inhale_smoke(mob/living/carbon/human/user)
	var/is_safe = TRUE

	if(!source_hookah || !source_hookah.reagent_container || !source_hookah.reagent_container.reagents)
		return
	var/datum/reagents/these_reagents = source_hookah.reagent_container.reagents
	for(var/obj/item/food/this_food in source_hookah.food_items)
		if(!this_food.reagents)
			qdel(this_food)
			continue
		if(!is_type_in_typecache(this_food, source_hookah.allowed_ingridients))
			is_safe = FALSE
		this_food.reagents.trans_to(these_reagents, INHALE_VOLUME / source_hookah.food_items.len)
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
		user.adjustStaminaLoss(COUGH_STAMINA_LOSS * 2)
		return
	if(!source_hookah.reagent_container || !source_hookah.reagent_container.reagents.total_volume)
		to_chat(user, span_warning("В кальяне нет жидкости!"))
		return
	var/transferred = these_reagents.trans_to(user, INHALE_VOLUME, methods = INHALE)
	playsound(src, 'sound/effects/bubbles/bubbles.ogg', 20)
	if(transferred)
		to_chat(user, span_notice("Вы вдыхаете дым из кальяна."))
		user.add_mood_event("smoked", /datum/mood_event/smoked)
		if(world.time < (last_inhale + INHALE_COOLDOWN))
			to_chat(user, span_warning("Вы вдыхаете слишком резко и закашливаетесь!"))
			user.emote("cough")
			user.adjustStaminaLoss(COUGH_STAMINA_LOSS)
		last_inhale = world.time
		addtimer(CALLBACK(src, .proc/delayed_puff, user), 1 SECONDS)

/obj/item/hookah_mouthpiece/proc/delayed_puff(mob/user)
	var/datum/effect_system/fluid_spread/smoke/chem/quick/puff = new
	puff.set_up(1, SPREAD_VOLUME, location = user.loc, carry = source_hookah.reagent_container.reagents)
	puff.start()

/obj/machinery/hookah/proc/stop_smoke()
	if(particle_type)
		remove_shared_particles(particle_type)
		particle_type = null

/obj/machinery/hookah/on_deconstruction(disassembled = FALSE)
	if(lit)
		put_out()
	fuel = 0
	new /obj/item/shard(get_turf(src))
	if(reagent_container && reagent_container.reagents?.total_volume)
		reagent_container.reagents.expose(get_turf(src), TOUCH)
	if(this_mouthpiece)
		qdel(this_mouthpiece)
	QDEL_LIST(food_items)
	qdel(src)

/obj/machinery/hookah/Destroy()
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

#undef INTERNAL_VOLUME
#undef MAX_FUEL
#undef FUEL_PER_COAL
#undef FUEL_CONSUME_INTERVAL
#undef INHALE_VOLUME
#undef SPREAD_VOLUME
#undef INHALE_COOLDOWN
#undef COUGH_STAMINA_LOSS


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
		/obj/machinery/hookah,
		/obj/item/hookah_coals = 3
	)
	crate_name = "ящик с набором для кальяна"

/obj/machinery/hookah/wrench_act(mob/living/user, obj/item/tool)
	default_unfasten_wrench(user, tool, time = 2 SECONDS)
	return ITEM_INTERACT_SUCCESS
