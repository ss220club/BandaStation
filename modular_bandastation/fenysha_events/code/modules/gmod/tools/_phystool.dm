#define TRAIT_PHYSGUN_PAUSE "physgun_pause"
#define PHYSGUN_EFFECTS "physgun_effects"

/obj/item/physgun
	name = "Физган"
	desc = "Инструмент для манипуляции физикой объектов."
	icon = 'modular_bandastation/fenysha_events/icons/items/tools/gmod_tools.dmi'
	icon_state = "gravitygun"
	inhand_icon_state = "gravitygun"
	lefthand_file = 'modular_bandastation/fenysha_events/icons/items/inhand/tools/gmod_tools_left.dmi'
	righthand_file = 'modular_bandastation/fenysha_events/icons/items/inhand/tools/gmod_tools_right.dmi'
	slot_flags = NONE
	demolition_mod = 0.5
	w_class = WEIGHT_CLASS_NORMAL
	throwforce = 0
	throw_speed = 1
	throw_range = 1
	drop_sound = 'sound/items/handling/tools/screwdriver_drop.ogg'
	pickup_sound = 'modular_bandastation/fenysha_events/sounds/tools/phystools/physgun_pickup.ogg'

	/// Наш персональный цвет, который мы выбрали для пушки
	var/personal_color = COLOR_TAN_ORANGE
	/// Цвет эффектов физпушки, равен personal_color, устанавливается при инициализации
	var/effects_color = null
	/// Усиленный захват
	var/force_grab = FALSE
	/// Продвинутый режим (разрешает больше действий)
	var/advanced = FALSE
	/// Коллдаун между использованиями
	var/use_cooldown = 3 SECONDS
	/// Максимальная дистанция граба обьекта(и удержания)
	var/maximum_distance = 4


	/// Перетаскиваемый объект
	var/atom/movable/handled_atom
	/// Пользователь физпушки
	var/mob/living/physgun_user
	/// Бим между пользователем и объектом
	var/datum/beam/physgun_beam
	/// Экранный элемент, следящий за курсором
	var/atom/movable/screen/fullscreen/cursor_catcher/physgun_catcher

	COOLDOWN_DECLARE(grab_cooldown)
	var/datum/looping_sound/gravgen/kinesis/phys_gun/loop_sound

	/// Сохранённые исходные смещения пикселей объекта
	var/stored_pixel_x = 0
	var/stored_pixel_y = 0

/obj/item/physgun/Initialize(mapload)
	effects_color = personal_color
	. = ..()

	loop_sound = new(src)

/obj/item/physgun/Destroy(force)
	. = ..()
	if(handled_atom)
		release_atom()
	qdel(loop_sound)


/obj/item/physgun/worn_overlays(mutable_appearance/standing, isinhands, icon_file)
	. = ..()
	if(!isinhands)
		return
	var/mutable_appearance/overlay = emissive_appearance(icon_file, "gravitygun_overlay")
	overlay.color = personal_color ? personal_color : initial(personal_color)
	. += overlay

/obj/item/physgun/update_overlays()
	. = ..()
	var/mutable_appearance/color_appearance = mutable_appearance(icon, "gravitygun_overlay")
	color_appearance.color = personal_color ? personal_color : initial(personal_color)
	. += color_appearance

/**
 * Захват объекта по дальнему клику.
 */
/obj/item/physgun/ranged_interact_with_atom(atom/movable/target, mob/living/user, list/modifiers)
	. = ..()
	if(istype(target))
		if(!can_catch(target, user))
			playsound(user, 'modular_bandastation/fenysha_events/sounds/tools/phystools/physgun_cant_grab.ogg', 100, TRUE)
			return
		if(!COOLDOWN_FINISHED(src, grab_cooldown) && !handled_atom)
			user.balloon_alert(user, "на перезарядке!")
			return
		if(!range_check(target, user) && !handled_atom)
			user.balloon_alert(user, "слишком далеко!")
			return
		catch_atom(target, user)
		COOLDOWN_START(src, grab_cooldown, use_cooldown)
		return

/obj/item/physgun/dropped(mob/user, silent)
	. = ..()
	if(handled_atom)
		release_atom()

/obj/item/physgun/click_alt(mob/user)
	if(handled_atom)
		balloon_alert(user, "Невозможно в текущем состоянии!")
		return CLICK_ACTION_SUCCESS
	var/chosen_color = tgui_color_picker(user, "Выберите новый цвет эффектов", "Цвет физпушки")
	if(!chosen_color)
		balloon_alert(user, "Невалидный цвет!")
		return

	effects_color = chosen_color
	personal_color = chosen_color

	update_appearance()
	return CLICK_ACTION_SUCCESS

/obj/item/physgun/examine(mob/user)
	. = ..()
	. += span_notice("Краткое руководство:")
	. += span_notice("ALT + ЛКМ по устройству — выбрать цвет.")
	. += span_notice("ЛКМ по объекту — начать перетаскивание.")
	. += span_green("ПКМ во время перетаскивания — заморозить объект.")
	. += span_red("ЛКМ во время перетаскивания — отпустить объект.")
	. += span_notice("CTRL + ЛКМ во время перетаскивания — бросить объект.")
	. += span_notice("ALT + ЛКМ во время перетаскивания — повернуть объект.")

/**
 * Основной процесс движения перетаскиваемого объекта за курсором.
 */
/obj/item/physgun/process(seconds_per_tick)
	if(!physgun_user)
		release_atom()
		return
	if(!range_check(handled_atom, physgun_user))
		release_atom()
		return

	if(physgun_catcher.mouse_params)
		physgun_catcher.calculate_params()
	if(!physgun_catcher.given_turf)
		return

	physgun_user.setDir(get_dir(physgun_user, handled_atom))

	if(handled_atom.loc == physgun_catcher.given_turf)
		if(handled_atom.pixel_x == physgun_catcher.given_x - world.icon_size/2 && handled_atom.pixel_y == physgun_catcher.given_y - world.icon_size/2)
			return
		animate(handled_atom, time = 0.2 SECONDS, pixel_x = stored_pixel_x + physgun_catcher.given_x - world.icon_size/2, pixel_y = stored_pixel_y + physgun_catcher.given_y - world.icon_size/2)
		physgun_beam.redrawing()
		return

	animate(handled_atom, time = 0.2 SECONDS, pixel_x = stored_pixel_x + physgun_catcher.given_x - world.icon_size/2, pixel_y = stored_pixel_y + physgun_catcher.given_y - world.icon_size/2)
	physgun_beam.redrawing()

	var/turf/turf_to_move = get_step_towards(handled_atom, physgun_catcher.given_turf)
	handled_atom.Move(turf_to_move, get_dir(handled_atom, turf_to_move), 8)

	var/pixel_x_change = 0
	var/pixel_y_change = 0
	var/direction = get_dir(handled_atom, turf_to_move)
	if(direction & NORTH)
		pixel_y_change = world.icon_size/2
	else if(direction & SOUTH)
		pixel_y_change = -world.icon_size/2
	if(direction & EAST)
		pixel_x_change = world.icon_size/2
	else if(direction & WEST)
		pixel_x_change = -world.icon_size/2

	animate(handled_atom, time = 0.2 SECONDS, pixel_x = stored_pixel_x + pixel_x_change, pixel_y = stored_pixel_y + pixel_y_change)

/obj/item/physgun/proc/can_catch(atom/target, mob/user)
	if(target == user)
		return FALSE
	if(!ismovable(target))
		return FALSE
	var/atom/movable/movable_target = target
	if(iseffect(movable_target))
		return FALSE
	if(movable_target.anchored && !HAS_TRAIT(movable_target, TRAIT_PHYSGUN_PAUSE))
		if(!advanced)
			return FALSE
		movable_target.set_anchored(FALSE)
	if(ismob(movable_target))
		if(!isliving(movable_target))
			return FALSE
		var/mob/living/living_target = movable_target
		if(living_target.buckled)
			return FALSE
		if(living_target.client && !advanced)
			return FALSE
	return TRUE

/obj/item/physgun/proc/range_check(atom/target, mob/user)
	if(!isturf(user.loc))
		return FALSE
	if(!can_see(user, target, 4))
		return FALSE
	return TRUE

/**
 * Обработка кликов во время перетаскивания.
 */
/obj/item/physgun/proc/on_clicked(atom/source, atom/clicked_on, modifiers)
	SIGNAL_HANDLER
	if(!handled_atom || !physgun_user)
		stack_trace("Physgun tried to run its click signal with no linked atoms or users.")
		return
	. = COMSIG_MOB_CANCEL_CLICKON

	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		if(!advanced)
			physgun_user.balloon_alert(physgun_user, "мало энергии!")
			return
		pause_atom(handled_atom)
		return
	else if(LAZYACCESS(modifiers, CTRL_CLICK))
		repulse(handled_atom, physgun_user)
		return
	else if(LAZYACCESS(modifiers, ALT_CLICK))
		rotate_object(handled_atom)
		return
	release_atom()

/obj/item/physgun/proc/on_living_resist(mob/living)
	SIGNAL_HANDLER
	if(force_grab)
		handled_atom.balloon_alert(handled_atom, "не сбежать!")
		return
	if(handled_atom)
		release_atom()

/**
 * Захват объекта.
 */
/obj/item/physgun/proc/catch_atom(atom/movable/target, mob/user)
	if(isliving(target))
		var/mob/living/L = target
		if(force_grab)
			L.SetParalyzed(INFINITY, TRUE)
		if(L.has_status_effect(/datum/status_effect/physgun_pause))
			L.remove_status_effect(/datum/status_effect/physgun_pause)
		target.add_traits(list(TRAIT_HANDS_BLOCKED), REF(src))
		RegisterSignal(target, COMSIG_LIVING_RESIST, PROC_REF(on_living_resist), TRUE)

	// Сохраняем исходные пиксели
	stored_pixel_x = target.pixel_x
	stored_pixel_y = target.pixel_y

	target.movement_type = FLYING
	target.add_filter("physgun", 3, list("type" = "outline", "color" = effects_color, "size" = 2))
	physgun_beam = user.Beam(target, "light_beam")
	physgun_beam.beam_color = effects_color
	physgun_catcher = user.overlay_fullscreen("physgun_effect", /atom/movable/screen/fullscreen/cursor_catcher, 0)
	physgun_catcher.assign_to_mob(user)
	handled_atom = target
	handled_atom.plane = handled_atom.plane + 1
	handled_atom.set_density(FALSE)
	physgun_user = user
	loop_sound.start()

	RegisterSignal(user, COMSIG_MOB_CLICKON, PROC_REF(on_clicked), TRUE)
	START_PROCESSING(SSfastprocess, src)

/**
 * Отпускание объекта.
 */
/obj/item/physgun/proc/release_atom()
	if(isliving(handled_atom))
		var/mob/living/L = handled_atom
		if(force_grab)
			L.SetParalyzed(0)
		if(L.has_status_effect(/datum/status_effect/physgun_pause))
			L.remove_status_effect(/datum/status_effect/physgun_pause)
		handled_atom.remove_traits(list(TRAIT_HANDS_BLOCKED), REF(src))
		UnregisterSignal(handled_atom, COMSIG_LIVING_RESIST)

	if(HAS_TRAIT(handled_atom, TRAIT_PHYSGUN_PAUSE))
		REMOVE_TRAIT(handled_atom, TRAIT_PHYSGUN_PAUSE, PHYSGUN_EFFECTS)

	handled_atom.movement_type = initial(handled_atom.movement_type)
	STOP_PROCESSING(SSfastprocess, src)
	handled_atom.remove_filter("physgun")
	UnregisterSignal(physgun_catcher, COMSIG_CLICK)
	physgun_catcher = null
	physgun_user.clear_fullscreen("physgun_effect")

	// Возвращаем сохранённые пиксели
	handled_atom.pixel_x = stored_pixel_x
	handled_atom.pixel_y = stored_pixel_y

	handled_atom.anchored = initial(handled_atom.anchored)
	handled_atom.density = initial(handled_atom.density)
	handled_atom.plane = initial(handled_atom.plane)

	qdel(physgun_beam)
	physgun_user = null
	handled_atom = null
	loop_sound.stop()

/**
 * Поворот объекта.
 */
/obj/item/physgun/proc/rotate_object(atom/movable/target)
	target.setDir(turn(target.dir, -90))

/**
 * Заморозка объекта в воздухе.
 */
/obj/item/physgun/proc/pause_atom(atom/movable/target)
	if(isliving(handled_atom))
		var/mob/living/L = target
		if(force_grab)
			L.apply_status_effect(/datum/status_effect/physgun_pause/admin)
		else
			L.apply_status_effect(/datum/status_effect/physgun_pause)
		REMOVE_TRAIT(L, TRAIT_HANDS_BLOCKED, REF(src))

	ADD_TRAIT(handled_atom, TRAIT_PHYSGUN_PAUSE, PHYSGUN_EFFECTS)
	handled_atom.set_anchored(TRUE)
	STOP_PROCESSING(SSfastprocess, src)
	UnregisterSignal(physgun_catcher, list(COMSIG_CLICK, COMSIG_CLICK_ALT, COMSIG_CLICK_CTRL))
	physgun_catcher = null
	physgun_user.clear_fullscreen("physgun_effect")
	qdel(physgun_beam)
	physgun_user = null
	handled_atom = null
	loop_sound.stop()

/obj/item/physgun/proc/repulse(atom/movable/target, mob/user)
	release_atom()
	var/turf/target_turf = get_turf_in_angle(get_angle(user, target), get_turf(user), 10)
	target.throw_at(target_turf, range = 9, speed = target.density ? 3 : 4, thrower = user, spin = isitem(target))
	playsound(user, 'modular_bandastation/fenysha_events/sounds/tools/phystools/physgun_repulse.ogg', 100, TRUE)

/obj/item/physgun/advanced
	advanced = TRUE
	use_cooldown = 1 SECONDS

/obj/item/physgun/advanced/admin
	force_grab = TRUE

/datum/looping_sound/gravgen/kinesis/phys_gun
	mid_sounds = list('modular_bandastation/fenysha_events/sounds/tools/phystools/physgun_hold_loop.ogg' = 1)

/datum/status_effect/physgun_pause
	id = "physgun_pause"
	alert_type = null

	var/force = FALSE

/datum/status_effect/physgun_pause/on_apply()
	. = ..()
	RegisterSignal(owner, COMSIG_LIVING_RESIST, PROC_REF(on_resist), TRUE)
	ADD_TRAIT(owner, TRAIT_IMMOBILIZED, REF(src))
	ADD_TRAIT(owner, TRAIT_HANDS_BLOCKED, REF(src))

/datum/status_effect/physgun_pause/on_remove()
	. = ..()
	UnregisterSignal(owner, COMSIG_LIVING_RESIST)
	REMOVE_TRAIT(owner, TRAIT_IMMOBILIZED, REF(src))
	REMOVE_TRAIT(owner, TRAIT_HANDS_BLOCKED, REF(src))

/datum/status_effect/physgun_pause/proc/on_resist()
	SIGNAL_HANDLER

	if(force)
		owner.balloon_alert(owner, "не сбежать!")
		return

	if(!HAS_TRAIT(owner, TRAIT_PHYSGUN_PAUSE))
		return
	REMOVE_TRAIT(owner, TRAIT_PHYSGUN_PAUSE, PHYSGUN_EFFECTS)
	owner.pixel_x = initial(owner.pixel_x)
	owner.pixel_y = initial(owner.pixel_y)
	owner.anchored = initial(owner.anchored)
	owner.density = initial(owner.density)
	owner.movement_type = initial(owner.movement_type)
	owner.remove_status_effect(src)
	owner.remove_filter("physgun")
	owner.plane = initial(owner.plane)

/datum/status_effect/physgun_pause/admin
	id = "physgun_pause_admin"
	force = TRUE


/datum/component/physgun_grab
	VAR_PRIVATE/atom/movable/movable_parent = null
	VAR_PRIVATE/atom/movable/physgun = null
	VAR_PRIVATE/paused = FALSE

	var/static/list/given_traits = list()

/datum/component/physgun_grab/Initialize(obj/item/physgun/physgun)
	if(!ismovable(parent) || !istype(physgun))
		return COMPONENT_INCOMPATIBLE
	src.movable_parent = parent
	src.physgun = physgun

/datum/component/physgun_grab/RegisterWithParent()
	. = ..()
	RegisterSignal(movable_parent, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(on_pre_move))
	RegisterSignal(movable_parent, COMSIG_MOVABLE_PHYSGUN_GRABBED, PROC_REF(on_physgun_grab))
	RegisterSignal(movable_parent, COMSIG_MOVABLE_PHYSGUN_RELEASED, PROC_REF(on_physgun_release))
	RegisterSignal(movable_parent, COMSIG_MOVABLE_PHYSGUN_PAUSED, PROC_REF(on_physgun_pause))

/datum/component/physgun_grab/UnregisterFromParent()
	. = ..()

/datum/component/physgun_grab/proc/on_pre_move(atom/movable/source)
	if(!HAS_TRAIT(source, TRAIT_PHYSGUN_PAUSE))
		return
	if(HAS_TRAIT(source, TRAIT_GODMODE))
		return
	return COMPONENT_MOVABLE_BLOCK_PRE_MOVE


#undef TRAIT_PHYSGUN_PAUSE
#undef PHYSGUN_EFFECTS
