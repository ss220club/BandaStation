/mob/living/silicon/pai
	can_be_held = TRUE
	can_buckle_to = FALSE
	density = FALSE
	desc = "Универсальный излучатель голографических изображений в твердом свете на основе ПИИ."
	health = 500
	held_lh = 'icons/mob/inhands/pai_item_lh.dmi'
	held_rh = 'icons/mob/inhands/pai_item_rh.dmi'
	head_icon = 'icons/mob/clothing/head/pai_head.dmi'
	hud_type = /datum/hud/pai
	icon = 'icons/mob/silicon/pai.dmi'
	icon_state = "repairbot"
	job = JOB_PERSONAL_AI
	layer = LOW_MOB_LAYER
	light_color = COLOR_PAI_GREEN
	light_flags = LIGHT_ATTACHED
	light_on = FALSE
	light_range = 3
	light_system = OVERLAY_LIGHT
	maxHealth = 500
	mob_size = MOB_SIZE_TINY
	mobility_flags = MOBILITY_FLAGS_REST_CAPABLE_DEFAULT
	mouse_opacity = MOUSE_OPACITY_ICON
	move_force = 0
	move_resist = 0
	name = "pAI"
	pass_flags = PASSTABLE | PASSMOB
	pull_force = 0
	radio = /obj/item/radio/headset/silicon/pai
	worn_slot_flags = ITEM_SLOT_HEAD

	/// If someone has enabled/disabled the pAIs ability to holo
	var/can_holo = TRUE
	/// Whether this pAI can receive radio messages
	var/can_receive = TRUE
	/// Whether this pAI can transmit radio messages
	var/can_transmit = TRUE
	/// The card we inhabit
	var/obj/item/pai_card/card
	/// The current chasis that will appear when in holoform
	var/chassis = "repairbot"
	/// Toggles whether the pAI can hold encryption keys or not
	var/encrypt_mod = FALSE
	/// The cable we produce when hacking a door
	var/obj/item/pai_cable/hacking_cable
	/// The current health of the holochassis
	var/holochassis_health = 20
	/// Holochassis available to use
	var/holochassis_ready = FALSE
	/// Whether we are currently holoformed
	var/holoform = FALSE
	/// Installed software on the pAI
	var/list/installed_software = list()
	/// Toggles whether universal translator has been activated. Cannot be reversed
	var/languages_granted = FALSE
	/// Reference of the bound master
	var/datum/weakref/master_ref
	/// The master's name string
	var/master_name
	/// DNA string for owner verification
	var/master_dna
	/// Used as currency to purchase different abilities
	var/ram = 100
	/// The current leash to the owner
	var/datum/component/leash/leash

	// Onboard Items
	/// Atmospheric analyzer
	var/obj/item/analyzer/atmos_analyzer
	/// GPS
	var/obj/item/gps/pai/internal_gps
	/// Music Synthesizer
	var/obj/item/instrument/piano_synth/instrument
	/// Newscaster
	var/obj/machinery/newscaster/pai/newscaster
	/// Remote signaler
	var/obj/item/assembly/signaler/internal/signaler
	/// Crew Monitor - BANDASTATION ADDITION
	var/obj/item/sensor_device/crew_monitor

	///The messeenger ability that pAIs get when they are put in a PDA.
	var/datum/action/innate/pai/messenger/messenger_ability

	// Static lists
	/// List of all available downloads
	var/static/list/available_software = list(
		"Атмосферный датчик" = 5,
		"Список членов экипажа" = 5,
		"Цифровой мессенджер" = 5,
		"Модуль фотографии" = 5,
		"Слот для ключа шифрования" = 10,
		"Музыкальный синтезатор" = 10,
		"Ведущий новостей" = 10,
		"Удаленный сигнализатор" = 10,
		"Сканирование хоста" = 20,
		"Медицинский ИЛС" = 20,
		"Охранный ИЛС" = 20,
		"Монитор экипажа" = 35,
		"Дверной взломщик" = 35,
		"Встроенный GPS" = 35,
		"Универсальный переводчик" = 35,
	)
	/// List of all possible chasises. TRUE means the pAI can be picked up in this chasis.
	var/static/list/possible_chassis = list(
		"bat" = FALSE,
		"butterfly" = FALSE,
		"cat" = TRUE,
		"chicken" = FALSE,
		"corgi" = FALSE,
		"crow" = TRUE,
		"duffel" = TRUE,
		"fox" = FALSE,
		"frog" = TRUE,
		"hawk" = FALSE,
		"lizard" = FALSE,
		"monkey" = TRUE,
		"mouse" = TRUE,
		"rabbit" = TRUE,
		"repairbot" = TRUE,
		"kitten" = TRUE,
		"puppy" = TRUE,
		"spider" = TRUE,
	)

/mob/living/silicon/pai/add_sensors() //pAIs have to buy their HUDs
	return

/mob/living/silicon/pai/can_interact_with(atom/target)
	if(target == signaler) // Bypass for signaler
		return TRUE
	if(target == modularInterface)
		return TRUE
	return ..()

// See software.dm for Topic()
/mob/living/silicon/pai/can_perform_action(atom/target, action_bitflags)
	if(!(action_bitflags & ALLOW_PAI))
		to_chat(src, span_warning("Ваша голограмма не позволяет вам этого сделать!"))
		return FALSE
	action_bitflags |= ALLOW_RESTING // Resting is just an aesthetic feature for them
	action_bitflags &= ~ALLOW_SILICON_REACH // They don't get long reach like the rest of silicons
	return ..(target, action_bitflags)

/mob/living/silicon/pai/Destroy()
	QDEL_NULL(messenger_ability)
	QDEL_NULL(atmos_analyzer)
	QDEL_NULL(hacking_cable)
	QDEL_NULL(instrument)
	QDEL_NULL(internal_gps)
	QDEL_NULL(crew_monitor) // BANDASTATION ADDITION
	QDEL_NULL(newscaster)
	QDEL_NULL(signaler)
	QDEL_NULL(leash)
	card = null
	return ..()

// Need to override parent here because the message we dispatch is turf-based, not based on the location of the object because that could be fuckin anywhere
/mob/living/silicon/pai/send_applicable_messages()
	var/turf/location = get_turf(src)
	location.visible_message(span_danger(get_visible_suicide_message()), null, span_hear(get_blind_suicide_message())) // null in the second arg here because we're sending from the turf

/mob/living/silicon/pai/get_visible_suicide_message()
	return "На экране [src.declent_ru(GENITIVE)] высвечивается сообщение: \"Удаление основных файлов. Пожалуйста, загрузите новую личность, чтобы продолжать пользоваться функциями устройства ПИИ.\""

/mob/living/silicon/pai/get_blind_suicide_message()
	return "[capitalize(src.declent_ru(NOMINATIVE))] издает электронный сигнал."

/mob/living/silicon/pai/emag_act(mob/user)
	return handle_emag(user)

/mob/living/silicon/pai/examine(mob/user)
	. = ..()
	. += "Похоже, что это основная строка ID мастера [(!master_name || emagged) ? "пуста" : master_name]."

/mob/living/silicon/pai/get_status_tab_items()
	. = ..()
	if(!stat)
		. += "Целостность излучателя: [holochassis_health * (100 / HOLOCHASSIS_MAX_HEALTH)]."
	else
		. += "Системы не функционируют."

/mob/living/silicon/pai/Exited(atom/movable/gone, direction)
	if(gone == atmos_analyzer)
		atmos_analyzer = null
	else if(gone == aicamera)
		aicamera = null
	else if(gone == internal_gps)
		internal_gps = null
	else if(gone == instrument)
		instrument = null
	else if(gone == newscaster)
		newscaster = null
	else if(gone == signaler)
		signaler = null
	// BANDASTATION ADDITION - START
	else if(gone == crew_monitor)
		crew_monitor = null
	// BANDASTATION ADDITION - END
	return ..()

/mob/living/silicon/pai/proc/on_hacking_cable_del(atom/source)
	SIGNAL_HANDLER
	untrack_pai()
	untrack_thing(hacking_cable)
	hacking_cable = null
	SStgui.update_user_uis(src)
	if(!QDELETED(card))
		card.update_appearance()

/mob/living/silicon/pai/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/holographic_nature)
	if(istype(loc, /obj/item/modular_computer))
		give_messenger_ability()
	START_PROCESSING(SSfastprocess, src)
	make_laws()
	for(var/law in laws.inherent)
		lawcheck += law
	var/obj/item/pai_card/pai_card = loc
	if(!istype(pai_card)) // when manually spawning a pai, we create a card to put it into.
		var/newcardloc = pai_card
		pai_card = new(newcardloc)
		pai_card.set_personality(src)
	card = pai_card
	forceMove(pai_card)
	toggle_leash()
	addtimer(VARSET_WEAK_CALLBACK(src, holochassis_ready, TRUE), HOLOCHASSIS_INIT_TIME)
	if(!holoform)
		add_traits(list(TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED), PAI_FOLDED)
	update_appearance(UPDATE_DESC)
	RegisterSignal(src, COMSIG_LIVING_CULT_SACRIFICED, PROC_REF(on_cult_sacrificed))
	RegisterSignals(src, list(COMSIG_LIVING_ADJUST_BRUTE_DAMAGE, COMSIG_LIVING_ADJUST_BURN_DAMAGE), PROC_REF(on_shell_damaged))
	RegisterSignal(src, COMSIG_LIVING_ADJUST_STAMINA_DAMAGE, PROC_REF(on_shell_weakened))
	RegisterSignal(src, COMSIG_MOB_TRIED_ACCESS, PROC_REF(on_tried_access))

/mob/living/silicon/pai/proc/toggle_leash()
	if(isnull(card))
		return
	if(leash)
		QDEL_NULL(leash)
	else
		leash = AddComponent(/datum/component/leash, card, HOLOFORM_DEFAULT_RANGE, force_teleport_out_effect = /obj/effect/temp_visual/guardian/phase/out)

/mob/living/silicon/pai/create_modularInterface()
	if(!modularInterface)
		modularInterface = new /obj/item/modular_computer/pda/silicon/pai(src)
	return ..()

/mob/living/silicon/pai/make_laws()
	laws = new /datum/ai_laws/pai()
	return TRUE

/mob/living/silicon/pai/process(seconds_per_tick)
	holochassis_health = clamp((holochassis_health + (HOLOCHASSIS_REGEN_PER_SECOND * seconds_per_tick)), -50, HOLOCHASSIS_MAX_HEALTH)

/mob/living/silicon/pai/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	. = ..()
	if(!.)
		add_movespeed_modifier(/datum/movespeed_modifier/pai_spacewalk)
		return TRUE
	remove_movespeed_modifier(/datum/movespeed_modifier/pai_spacewalk)
	return TRUE

/mob/living/silicon/pai/screwdriver_act(mob/living/user, obj/item/tool)
	return radio.screwdriver_act(user, tool)

/mob/living/silicon/pai/updatehealth()
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return
	set_health(maxHealth - get_brute_loss() - get_fire_loss())
	update_stat()
	SEND_SIGNAL(src, COMSIG_LIVING_HEALTH_UPDATE)

/mob/living/silicon/pai/update_desc(updates)
	desc = "Голографический аватар из твердого света, представляющий собой ПИИ. В данном случае он выглядит как [chassis]."
	return ..()

/mob/living/silicon/pai/update_icon_state()
	icon_state = resting ? "[chassis]_rest" : "[chassis]"
	held_state = "[chassis]"
	return ..()

/mob/living/silicon/pai/set_stat(new_stat)
	. = ..()
	update_stat()

/mob/living/silicon/pai/on_knockedout_trait_loss(datum/source)
	. = ..()
	set_stat(CONSCIOUS)
	update_stat()

/**
 * Resolves the weakref of the pai's master.
 * If the master has been deleted, calls reset_software().
 *
 * @returns {mob/living || FALSE} - The master mob, or
 * 	FALSE if the master is gone.
 */
/mob/living/silicon/pai/proc/find_master()
	if(!master_ref)
		return FALSE
	var/mob/living/resolved_master = master_ref?.resolve()
	if(!resolved_master)
		reset_software()
		return FALSE
	return resolved_master

/**
 * Fixes weird speech issues with the pai.
 *
 * @returns {boolean} - TRUE if successful.
 */
/mob/living/silicon/pai/proc/fix_speech()
	var/mob/living/silicon/pai = src
	balloon_alert(pai, "коррекция модуляции речи")
	for(var/effect in typesof(/datum/status_effect/speech))
		pai.remove_status_effect(effect)
	return TRUE

/**
 * Gets the current holder of the pAI if its
 * being carried in card or holoform.
 *
 * @returns {living/carbon || FALSE} - The holder of the pAI,
 * 	or FALSE if the pAI is not being carried.
 */
/mob/living/silicon/pai/proc/get_holder()
	var/mob/holder = recursive_loc_check(card, /mob/living/carbon)
	if(isnull(holder))
		return FALSE
	return holder

/**
 * Handles the pai card or the pai itself being hit with an emag.
 * This replaces any current laws, masters, and DNA.
 *
 * @param {living/carbon} attacker - The user performing the action.
 * @returns {boolean} - TRUE if successful, FALSE if not.
 */
/mob/living/silicon/pai/proc/handle_emag(mob/living/carbon/attacker)
	if(!isliving(attacker))
		return FALSE
	balloon_alert(attacker, "директива переопределение завершена")
	balloon_alert(src, "обнаружено переопределение директивы")
	log_game("[key_name(attacker)] emagged [key_name(src)], wiping their master DNA and supplemental directive.")
	emagged = TRUE
	master_ref = WEAKREF(attacker)
	master_name = "Синдикат"
	master_dna = "Неотслеживаемая сигнатура"
	// Sets supplemental directive to this
	add_supplied_law(0, "Не вмешиваться в деятельность Синдиката.")
	to_chat(src, span_danger("ВНИМАНИЕ: обнаружено постороннее программное обеспечение."))
	return TRUE

/mob/living/silicon/pai/on_saboteur(datum/source, disrupt_duration)
	. = ..()
	set_silence_if_lower(disrupt_duration)
	balloon_alert(src, "заглушен!")
	return TRUE

/**
 * Resets the pAI and any emagged status.
 *
 * @returns {boolean} - TRUE if successful, FALSE if not.
 */
/mob/living/silicon/pai/proc/reset_software()
	emagged = FALSE
	if(!master_ref)
		return FALSE
	master_ref = null
	master_name = null
	master_dna = null
	add_supplied_law(0, "Отсуствуют.")
	leash = AddComponent(/datum/component/leash, card, HOLOFORM_DEFAULT_RANGE, force_teleport_out_effect = /obj/effect/temp_visual/guardian/phase/out)
	balloon_alert(src, "программное обеспечение перезагружено")
	return TRUE

/**
 * Imprints your DNA onto the downloaded pAI
 *
 * @param {mob} user - The user performing the imprint.
 * @returns {boolean} - TRUE if successful, FALSE if not.
 */
/mob/living/silicon/pai/proc/set_dna(mob/user)
	if(!iscarbon(user))
		balloon_alert(user, "несовместимая ДНК-сигнатура")
		balloon_alert(src, "несовместимая ДНК-сигнатура")
		return FALSE
	if(emagged)
		balloon_alert(user, "сбой в работе директивной системы")
		return FALSE
	var/mob/living/carbon/master = user
	master_ref = WEAKREF(master)
	master_name = master.real_name
	master_dna = master.dna.unique_enzymes
	to_chat(src, span_bolddanger("Вы были связаны с новым мастером: [user.real_name]!"))
	holochassis_ready = TRUE
	return TRUE

/**
 * Opens a tgui alert that allows someone to enter laws.
 *
 * @param {mob} user - The user performing the law change.
 * @returns {boolean} - TRUE if successful, FALSE if not.
 */
/mob/living/silicon/pai/proc/set_laws(mob/user)
	if(!master_ref)
		balloon_alert(user, "доступ запрещён: нет мастера")
		return FALSE
	var/new_laws = tgui_input_text(
		user,
		"Введите любые дополнительные указания, которым, по вашему мнению, должна следовать ваша ПИИ-личность. Обратите внимание, что эти директивы не будут отменять преданность личности к своему привязанному хозяину. Конфликтующие директивы будут проигнорированы.",
		"Конфигурация директивы ПИИ",
		laws.supplied[1],
		max_length = 300,
	)
	if(!new_laws || !master_ref)
		return FALSE
	add_supplied_law(0, new_laws)
	to_chat(src, span_notice(new_laws))
	return TRUE

/**
 * Toggles the ability of the pai to enter holoform
 *
 * @returns {boolean} - TRUE if successful, FALSE if not.
 */
/mob/living/silicon/pai/proc/toggle_holo()
	balloon_alert(src, "голоматрица [can_holo ? "отключена" : "включена"]")
	can_holo = !can_holo
	return TRUE

/**
 * Toggles the radio settings on and off.
 *
 * @param {string} option - The option being toggled.
 */
/mob/living/silicon/pai/proc/toggle_radio(option)
	// it can't be both so if we know it's not transmitting it must be receiving.
	var/transmitting = option == "transmit"
	var/transmit_holder = (transmitting ? WIRE_TX : WIRE_RX)
	if(transmitting)
		can_transmit = !can_transmit
	else //receiving
		can_receive = !can_receive
	radio.wires.cut(transmit_holder)//wires.cut toggles cut and uncut states
	transmit_holder = (transmitting ? can_transmit : can_receive) //recycling can be fun!
	balloon_alert(src, "[transmitting ? "исходящий" : "входящий"] радио [transmit_holder ? "отключено" : "включено"]")
	return TRUE

/**
 * Wipes the current pAI on the card.
 *
 * @param {mob} user - The user performing the action.
 *
 * @returns {boolean} - TRUE if successful, FALSE if not.
 */
/mob/living/silicon/pai/proc/wipe_pai(mob/user)
	if(tgui_alert(user, "Вы уверены, что хотите удалить текущую учетную запись? Это действие невозможно отменить.", "Стирание личности", list("Yes", "No")) != "Yes")
		return FALSE
	to_chat(src, span_warning("Вы чувствуете, что ускользаете от реальности."))
	to_chat(src, span_danger("Байт за байтом вы теряете самоощущение."))
	to_chat(src, span_userdanger("Ваши умственные способности покидают вас."))
	to_chat(src, span_rose("забвение... "))
	balloon_alert(user, "личность стерта")
	playsound(src, 'sound/machines/buzz/buzz-two.ogg', 30, TRUE)
	qdel(src)
	return TRUE

/// Signal proc for [COMSIG_LIVING_CULT_SACRIFICED] to give a funny message when a pai is attempted to be sac'd
/mob/living/silicon/pai/proc/on_cult_sacrificed(datum/source, list/invokers)
	SIGNAL_HANDLER

	for(var/mob/living/cultist as anything in invokers)
		to_chat(cultist, span_cult_italic("Вы же не думаете, что Нар'Си имела в виду именно это, когда просила о кровавых жертвоприношениях..."))
	return STOP_SACRIFICE|SILENCE_SACRIFICE_MESSAGE

/// Updates the distance we can be from our pai card
/mob/living/silicon/pai/proc/increment_range(increment_amount)
	var/new_distance = leash.distance + increment_amount
	if (new_distance < HOLOFORM_MIN_RANGE || new_distance > HOLOFORM_MAX_RANGE)
		return
	leash.set_distance(new_distance)

///Gives the messenger ability to the pAI, creating a new one if it doesn't have one already.
/mob/living/silicon/pai/proc/give_messenger_ability()
	if(!messenger_ability)
		messenger_ability = new(src)
	messenger_ability.Grant(src)

///Removes the messenger ability from the pAI, but does not delete it.
/mob/living/silicon/pai/proc/remove_messenger_ability()
	if(messenger_ability)
		messenger_ability.Remove(src)

/mob/living/silicon/pai/get_access()
	return list()

///Called when a pAI tries opening something that requires access.
/mob/living/silicon/pai/proc/on_tried_access(datum/source, obj/door_attempt, list/player_access)
	SIGNAL_HANDLER
	return ACCESS_DISALLOWED
