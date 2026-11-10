GLOBAL_LIST_INIT(loot_goblin_recipes, list(
	list(
		"potion" = /obj/item/loot_goblin_potion/teleport,
		"ingredients" = list(
			/obj/item/stack/sheet/glass = 1,
			/obj/item/stack/ore/bluespace_crystal = 5,
			/obj/item/stack/sheet/mineral/gold = 1,
		),
	),
	list(
		"potion" = /obj/item/loot_goblin_potion/heal,
		"ingredients" = list(
			/obj/item/stack/sheet/glass = 1,
			/obj/item/organ/brain/primate = 1,
			/obj/item/food/grown/banana = 1,
		),
	),
	list(
		"potion" = /obj/item/loot_goblin_potion/invisibility,
		"ingredients" = list(
			/obj/item/stack/sheet/glass = 1,
			/obj/item/stack/sheet/mineral/diamond = 1,
			/obj/item/slime_extract = 1,
		),
	),
))

GLOBAL_LIST_INIT(loot_goblin_ingredient_names, list(
	/obj/item/stack/sheet/glass = "лист стекла",
	/obj/item/stack/ore/bluespace_crystal = "блюспейс-кристалл",
	/obj/item/stack/sheet/mineral/gold = "слиток золота",
	/obj/item/organ/brain/primate = "мозг мартышки",
	/obj/item/food/grown/banana = "банан",
	/obj/item/stack/sheet/mineral/diamond = "алмаз",
	/obj/item/slime_extract = "экстракт слайма",
))

/datum/action/loot_goblin_cauldron
	name = "Поставить котёл"
	desc = "Поставить гоблинский алхимический котёл на текущий тайл вплотную к логову. Котёл ставится один раз и не переносится. Новый можно поставить, только если старый разрушат. Доступно с тира 5."
	button_icon = 'modular_bandastation/loot_goblin/icons/cauldron.dmi'
	button_icon_state = "cauldron"
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_INCAPACITATED | AB_CHECK_HANDS_BLOCKED
	var/building = FALSE

/datum/action/loot_goblin_cauldron/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return
	var/datum/antagonist/loot_goblin/goblin = target
	if(goblin.tier < LOOT_GOBLIN_TIER_HEAD)
		if(feedback)
			owner.balloon_alert(owner, "нужен тир 5!")
		return FALSE

/datum/action/loot_goblin_cauldron/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return
	var/mob/living/user = owner
	if(building || !can_place(user))
		return FALSE
	var/turf/cauldron_turf = user.loc
	building = TRUE
	var/success = do_after(user, 3 SECONDS, target = cauldron_turf)
	building = FALSE
	if(!success || QDELETED(src) || owner != user || user.loc != cauldron_turf || !can_place(user))
		return FALSE
	var/datum/antagonist/loot_goblin/goblin = target
	if(QDELETED(goblin) || goblin.owner != user.mind || goblin.tier < LOOT_GOBLIN_TIER_HEAD)
		return FALSE
	goblin.create_cauldron(cauldron_turf)
	return TRUE

/datum/action/loot_goblin_cauldron/proc/can_place(mob/living/user)
	var/datum/antagonist/loot_goblin/goblin = target
	if(goblin.cauldron)
		to_chat(user, span_warning("Котёл уже стоит, перенести его нельзя."))
		return FALSE
	var/turf/cauldron_turf = user.loc
	var/turf/lair_turf = get_turf(goblin.lair)
	if(!lair_turf)
		to_chat(user, span_warning("Сначала обустройте логово!"))
		return FALSE
	if(!isfloorturf(cauldron_turf) || get_dist(cauldron_turf, lair_turf) != 1 || cauldron_turf.z != lair_turf.z)
		to_chat(user, span_warning("Котёл ставится на пол вплотную к логову, но не на само логово!"))
		return FALSE
	if(cauldron_turf.is_blocked_turf(exclude_mobs = TRUE))
		to_chat(user, span_warning("Здесь слишком тесно для котла!"))
		return FALSE
	return TRUE

/obj/structure/loot_goblin_cauldron
	name = "гоблинский алхимический котёл"
	desc = "Закопчённый котёл, в котором что-то булькает. Пахнет жадностью."
	icon = 'modular_bandastation/loot_goblin/icons/cauldron.dmi'
	icon_state = "cauldron"
	anchored = TRUE
	density = TRUE
	max_integrity = 150
	var/datum/antagonist/loot_goblin/goblin
	var/brewing = FALSE
	COOLDOWN_DECLARE(brew_cooldown)
	var/static/list/allowed_ingredients = typecacheof(list(
		/obj/item/stack/sheet/glass,
		/obj/item/stack/ore/bluespace_crystal,
		/obj/item/stack/sheet/bluespace_crystal,
		/obj/item/stack/sheet/mineral/gold,
		/obj/item/organ/brain/primate,
		/obj/item/food/grown/banana,
		/obj/item/stack/sheet/mineral/diamond,
		/obj/item/slime_extract,
	))

/obj/structure/loot_goblin_cauldron/Initialize(mapload, datum/antagonist/loot_goblin/new_goblin)
	. = ..()
	goblin = new_goblin

/obj/structure/loot_goblin_cauldron/Destroy()
	if(goblin)
		goblin.cauldron = null
		goblin = null
	dump_contents()
	return ..()

/obj/structure/loot_goblin_cauldron/examine(mob/user)
	. = ..()
	if(!is_owner(user))
		return
	. += span_notice("Внутри: [length(contents) ? english_list(get_contents_names()) : "пусто"].")
	. += span_notice("Пустой рукой — сварить зелье, Alt-клик — вытащить всё. Рецепты — в меню гоблина.")
	if(!COOLDOWN_FINISHED(src, brew_cooldown))
		. += span_warning("Котёл остывает ещё [DisplayTimeText(COOLDOWN_TIMELEFT(src, brew_cooldown))].")

/obj/structure/loot_goblin_cauldron/proc/is_owner(mob/user)
	return goblin && user?.mind == goblin.owner

/obj/structure/loot_goblin_cauldron/proc/get_contents_names()
	var/list/names = list()
	for(var/obj/item/thing in contents)
		var/obj/item/stack/stack = thing
		names += istype(stack) ? "[thing.declent_ru(NOMINATIVE)] ([stack.amount])" : thing.declent_ru(NOMINATIVE)
	return names

/obj/structure/loot_goblin_cauldron/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!is_owner(user))
		return NONE
	if(!is_type_in_typecache(tool, allowed_ingredients))
		to_chat(user, span_warning("Это не годится для варки."))
		return ITEM_INTERACT_BLOCKING
	if(brewing)
		return ITEM_INTERACT_BLOCKING
	if(!user.transferItemToLoc(tool, src))
		return ITEM_INTERACT_BLOCKING
	to_chat(user, span_notice("Вы бросаете [tool.declent_ru(ACCUSATIVE)] в котёл."))
	return ITEM_INTERACT_SUCCESS

/obj/structure/loot_goblin_cauldron/click_alt(mob/user)
	if(!is_owner(user) || brewing)
		return CLICK_ACTION_BLOCKING
	dump_contents()
	to_chat(user, span_notice("Вы вываливаете содержимое котла."))
	return CLICK_ACTION_SUCCESS

/obj/structure/loot_goblin_cauldron/dump_contents()
	var/turf/drop_turf = drop_location()
	for(var/obj/item/thing in contents)
		thing.forceMove(drop_turf)

/obj/structure/loot_goblin_cauldron/attack_hand(mob/living/user, list/modifiers)
	if(!is_owner(user))
		return ..()
	INVOKE_ASYNC(src, PROC_REF(brew), user)
	return TRUE

/obj/structure/loot_goblin_cauldron/attack_paw(mob/living/user, list/modifiers)
	if(!is_owner(user))
		return ..()
	INVOKE_ASYNC(src, PROC_REF(brew), user)
	return TRUE

/obj/structure/loot_goblin_cauldron/proc/brew(mob/living/user)
	if(brewing)
		return
	if(!can_brew(user))
		return
	brewing = TRUE
	user.visible_message(span_notice("[capitalize(user.declent_ru(NOMINATIVE))] помешивает варево в котле."), span_notice("Вы начинаете варить зелье..."))
	var/success = do_after(user, 10 SECONDS, target = src)
	brewing = FALSE
	if(!success || QDELETED(src) || !can_brew(user))
		return
	var/list/recipe = find_recipe()
	consume_ingredients(recipe["ingredients"])
	var/potion_type = recipe["potion"]
	var/obj/item/potion = new potion_type(drop_location())
	COOLDOWN_START(src, brew_cooldown, LOOT_GOBLIN_CAULDRON_COOLDOWN)
	to_chat(user, span_boldnotice("Готово: [potion.declent_ru(NOMINATIVE)]."))

/obj/structure/loot_goblin_cauldron/proc/can_brew(mob/living/user)
	if(!is_owner(user) || !user.Adjacent(src))
		return FALSE
	if(goblin.tier < LOOT_GOBLIN_TIER_HEAD)
		to_chat(user, span_warning("Котёл не слушается: ваша жадность слишком мала."))
		return FALSE
	if(!COOLDOWN_FINISHED(src, brew_cooldown))
		to_chat(user, span_warning("Котёл ещё не остыл: [DisplayTimeText(COOLDOWN_TIMELEFT(src, brew_cooldown))]."))
		return FALSE
	if(!find_recipe())
		to_chat(user, span_warning("Из этого ничего не сварить."))
		return FALSE
	return TRUE

/obj/structure/loot_goblin_cauldron/proc/is_ingredient(obj/item/thing, ingredient_type)
	if(istype(thing, ingredient_type))
		return TRUE
	return ingredient_type == /obj/item/stack/ore/bluespace_crystal && istype(thing, /obj/item/stack/sheet/bluespace_crystal)

/obj/structure/loot_goblin_cauldron/proc/count_ingredient(ingredient_type)
	var/count = 0
	for(var/obj/item/thing in contents)
		if(!is_ingredient(thing, ingredient_type))
			continue
		var/obj/item/stack/stack = thing
		count += istype(stack) ? stack.amount : 1
	return count

/obj/structure/loot_goblin_cauldron/proc/find_recipe()
	for(var/list/recipe as anything in GLOB.loot_goblin_recipes)
		var/list/ingredients = recipe["ingredients"]
		var/fits = TRUE
		for(var/ingredient_type in ingredients)
			if(count_ingredient(ingredient_type) < ingredients[ingredient_type])
				fits = FALSE
				break
		if(fits)
			return recipe
	return null

/obj/structure/loot_goblin_cauldron/proc/consume_ingredients(list/ingredients)
	for(var/ingredient_type in ingredients)
		var/needed = ingredients[ingredient_type]
		for(var/obj/item/thing in contents)
			if(needed <= 0)
				break
			if(!is_ingredient(thing, ingredient_type))
				continue
			var/obj/item/stack/stack = thing
			if(istype(stack))
				var/used = min(needed, stack.amount)
				stack.use(used)
				needed -= used
			else
				qdel(thing)
				needed--

/obj/item/loot_goblin_potion
	name = "гоблинское зелье"
	desc = "Мутная бутылка с подозрительной жидкостью."
	icon = 'icons/obj/antags/eldritch.dmi'
	icon_state = "clarity"
	w_class = WEIGHT_CLASS_SMALL
	pickup_sound = 'sound/items/handling/materials/glass_pick_up.ogg'
	drop_sound = 'sound/items/handling/materials/glass_drop.ogg'
	var/effect_desc = ""

/obj/item/loot_goblin_potion/attack_self(mob/user)
	. = ..()
	if(. || !isliving(user))
		return
	var/mob/living/drinker = user
	var/is_goblin = !!drinker.mind?.has_antag_datum(/datum/antagonist/loot_goblin)
	if(is_goblin && !can_drink(drinker))
		return TRUE
	playsound(src, 'sound/effects/bubbles/bubbles.ogg', 50, TRUE)
	if(!is_goblin)
		to_chat(drinker, span_danger("Вы отпиваете из [declent_ru(GENITIVE)]. Ужасная гадость обжигает горло!"))
		drinker.adjust_tox_loss(LOOT_GOBLIN_POTION_TOXIN)
		qdel(src)
		return TRUE
	to_chat(drinker, span_notice("Вы залпом выпиваете [declent_ru(ACCUSATIVE)]."))
	potion_effect(drinker)
	qdel(src)
	return TRUE

/obj/item/loot_goblin_potion/proc/can_drink(mob/living/drinker)
	return TRUE

/obj/item/loot_goblin_potion/proc/potion_effect(mob/living/drinker)
	return

/obj/item/loot_goblin_potion/teleport
	name = "зелье гоблинского прыжка"
	desc = "Бутылка с мерцающей синей жидкостью."
	effect_desc = "Даёт одноразовый прыжок в видимую точку до 7 клеток."
	icon_state = "crucible_soul"

/obj/item/loot_goblin_potion/teleport/potion_effect(mob/living/drinker)
	var/datum/action/cooldown/spell/pointed/loot_goblin_blink/blink = new(drinker)
	blink.Grant(drinker)
	to_chat(drinker, span_notice("Используйте появившуюся способность, чтобы перенестись в видимую точку."))

/obj/item/loot_goblin_potion/heal
	name = "зелье гоблинского здоровья"
	desc = "Бутылка с густой зелёной жижей."
	effect_desc = "Постепенно лечит 40 урона от ударов и 40 от ожогов за 20 секунд. Пока действует, второе зелье лечения не выпить."
	icon_state = "marshal"

/obj/item/loot_goblin_potion/heal/can_drink(mob/living/drinker)
	if(drinker.has_status_effect(/datum/status_effect/loot_goblin_potion_heal))
		to_chat(drinker, span_warning("Прошлое зелье ещё не подействовало до конца!"))
		return FALSE
	return TRUE

/obj/item/loot_goblin_potion/heal/potion_effect(mob/living/drinker)
	drinker.apply_status_effect(/datum/status_effect/loot_goblin_potion_heal)

/datum/status_effect/loot_goblin_potion_heal
	id = "loot_goblin_potion_heal"
	status_type = STATUS_EFFECT_UNIQUE
	duration = LOOT_GOBLIN_POTION_HEAL_TIME
	tick_interval = 1 SECONDS
	alert_type = null

/datum/status_effect/loot_goblin_potion_heal/tick(seconds_between_ticks)
	if(owner.stat == DEAD)
		return
	var/heal_amount = LOOT_GOBLIN_POTION_HEAL / (LOOT_GOBLIN_POTION_HEAL_TIME / (1 SECONDS)) * seconds_between_ticks
	owner.heal_overall_damage(brute = heal_amount, burn = heal_amount)

/obj/item/loot_goblin_potion/invisibility
	name = "зелье гоблинской невидимости"
	desc = "Бутылка, которую трудно разглядеть."
	effect_desc = "20 секунд почти полной невидимости. Атака или полученный урон её снимают."
	icon_state = "clarity"

/obj/item/loot_goblin_potion/invisibility/potion_effect(mob/living/drinker)
	drinker.apply_status_effect(/datum/status_effect/loot_goblin_invisibility)

/datum/action/cooldown/spell/pointed/loot_goblin_blink
	name = "Гоблинский прыжок"
	desc = "Перенестись в видимую точку. Одноразово."
	button_icon = 'icons/obj/antags/eldritch.dmi'
	button_icon_state = "crucible_soul"
	school = SCHOOL_UNSET
	spell_requirements = NONE
	antimagic_flags = NONE
	invocation_type = INVOCATION_NONE
	cooldown_time = 0
	cast_range = 7
	active_msg = "Вы примериваетесь к прыжку."
	deactive_msg = "Вы передумали прыгать."

/datum/action/cooldown/spell/pointed/loot_goblin_blink/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return
	var/turf/destination = get_turf(cast_on)
	if(!isopenturf(destination) || destination.is_blocked_turf(exclude_mobs = TRUE) || !(destination in view(cast_range, owner)))
		to_chat(owner, span_warning("Туда не прыгнуть!"))
		return FALSE

/datum/action/cooldown/spell/pointed/loot_goblin_blink/cast(atom/cast_on)
	. = ..()
	var/turf/start_turf = get_turf(owner)
	var/turf/destination = get_turf(cast_on)
	var/start_dir = owner.dir
	if(!do_teleport(owner, destination, channel = TELEPORT_CHANNEL_FREE, forced = TRUE))
		return
	new /obj/effect/temp_visual/dir_setting/ninja/phase/out/loot_goblin(start_turf, start_dir)
	new /obj/effect/temp_visual/loot_goblin_aura(start_turf)
	playsound(start_turf, 'sound/effects/magic/teleport_diss.ogg', 50, TRUE)
	new /obj/effect/temp_visual/dir_setting/ninja/phase/loot_goblin(destination, owner.dir)
	new /obj/effect/temp_visual/loot_goblin_aura(destination)
	playsound(destination, 'sound/effects/magic/teleport_app.ogg', 50, TRUE)

/datum/action/cooldown/spell/pointed/loot_goblin_blink/after_cast(atom/cast_on)
	. = ..()
	qdel(src)

/datum/status_effect/loot_goblin_invisibility
	id = "loot_goblin_invisibility"
	status_type = STATUS_EFFECT_REFRESH
	duration = LOOT_GOBLIN_INVISIBILITY_TIME
	alert_type = null

/datum/status_effect/loot_goblin_invisibility/on_apply()
	animate(owner, alpha = LOOT_GOBLIN_INVISIBILITY_ALPHA, time = 1 SECONDS)
	RegisterSignals(owner, list(COMSIG_MOB_ITEM_ATTACK, COMSIG_LIVING_UNARMED_ATTACK, COMSIG_MOB_AFTER_APPLY_DAMAGE), PROC_REF(break_invisibility))
	to_chat(owner, span_notice("Вы растворяетесь в воздухе."))
	return TRUE

/datum/status_effect/loot_goblin_invisibility/on_remove()
	UnregisterSignal(owner, list(COMSIG_MOB_ITEM_ATTACK, COMSIG_LIVING_UNARMED_ATTACK, COMSIG_MOB_AFTER_APPLY_DAMAGE))
	animate(owner, alpha = initial(owner.alpha), time = 0.5 SECONDS)
	to_chat(owner, span_warning("Вы снова видимы."))

/datum/status_effect/loot_goblin_invisibility/proc/break_invisibility(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/obj/effect/temp_visual/dir_setting/ninja/phase/loot_goblin
	name = "гоблинская дымка"

/obj/effect/temp_visual/dir_setting/ninja/phase/out/loot_goblin
	name = "гоблинская дымка"
