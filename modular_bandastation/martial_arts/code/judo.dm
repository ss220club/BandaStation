/datum/status_effect/judo_armbar
	id = "armbar"
	duration = 5 SECONDS
	alert_type = null
	status_type = STATUS_EFFECT_REPLACE

//Corporate Judo Belt
/datum/storage/security_belt/judo
	max_slots = 3
	max_total_storage = 7

/obj/item/storage/belt/judobelt
	name = "Corporate Judo Belt"
	desc = "Обучает носителя корпоративно дзюдо НТ."
	icon = 'modular_bandastation/martial_arts/icons/belts.dmi'
	icon_state = "judobelt"
	worn_icon = 'modular_bandastation/martial_arts/icons/mob/belt.dmi'
	worn_icon_state = "judo"
	w_class = WEIGHT_CLASS_BULKY
	var/datum/martial_art/judo/style
	storage_type = /datum/storage/security_belt/judo

/obj/item/storage/belt/judobelt/Initialize(mapload)
	. = ..()
	style = new()

/obj/item/storage/belt/judobelt/equipped(mob/user, slot)
	. = ..()
	if(!ishuman(user))
		return
	if(slot == ITEM_SLOT_BELT)
		var/mob/living/carbon/human/H = user
		if(HAS_TRAIT(user, TRAIT_PACIFISM))
			to_chat(H, span_warning("Искусство корпоративного дзюдо бесполезно отдается эхом в вашей голове, мысль о насилии вызывает у вас отвращение!"))
			return
		style.teach(H, TRUE)
		return

/obj/item/storage/belt/judobelt/dropped(mob/user)
	..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.get_item_by_slot(ITEM_SLOT_BELT) == src)
		style.unlearn(H)

/mob/living/proc/judo_help()
	set name = "Вспомнить основы дзюдо."
	set desc = "Вы взываете к техникам корпоратского дзюдо."
	set category = "IC"

	var/list/message = list()
	message += span_bolditalic("Вы взываете к техникам корпоратского дзюдо.")
	message += "[span_notice("Бросок")]: Grab Shove. Возьмите врага в захват и бросьте на пол. Наносит урон стамине."
	message += "[span_notice("Большое колесо")]: Grab Shove Punch. Перекиньте противника, захваченного 'рычагом', через себя или прижмите его к полу."
	message += "[span_notice("Тычок в глаза")]: Shove Punch. Ударьте противника в глаза, мгновенно ослепляя его."
	message += "[span_notice("Рычаг")]: Shove Shove Grab. Возьмите лежащего противника в захват."
	message += "[span_notice("Золотой взрыв")]: Help Shove Help Grab Shove Shove Grab Help Shove Shove Grab Help. Используя боевые искусства, вы можете оглушить противника жизненной энергией. Или перегрузив наниты пояса."
	message += "[span_notice("Сбить с толку")]: Нанесите противнику удар по уху, ненадолго сбив его с толку."
	message += span_bolditalic("Ваши удары кулаками примерно в два раза сильнее, чем у остальных.")

	to_chat(usr, message.Join("\n"))

/datum/martial_art/judo
	name = "Corporate Judo"
	id = "corporate judo"
	help_verb = /mob/living/proc/judo_help
	display_combos = TRUE
	max_streak_length = 12
	combo_timer = 15 SECONDS
	VAR_PRIVATE/datum/action/discombobulate/discombobulate

/datum/martial_art/judo/New()
	. = ..()
	discombobulate = new(src)

/datum/martial_art/judo/Destroy()
	discombobulate = null
	return ..()

/datum/martial_art/judo/activate_style(mob/living/new_holder)
	. = ..()
	to_chat(new_holder, span_userdanger("Наниты, содержащиеся в поясе, наделяют вас мастерством обладателя черного пояса по корпоративному дзюдо!"))
	to_chat(new_holder, span_notice("Вы можете посмотреть приёмы во вкладке IC."))
	discombobulate.Grant(new_holder)

/datum/martial_art/judo/deactivate_style(mob/living/remove_from)
	to_chat(remove_from, span_userdanger("Вы забываете мастерство корпоративного дзюдо..."))
	discombobulate?.Remove(remove_from)
	return ..()

//Increased harm damage
/datum/martial_art/judo/harm_act(mob/living/carbon/human/attacker, mob/living/carbon/human/defender)
	var/picked_hit_type = GLOB.ru_attack_verbs[pick("chops", "slices", "strikes")]
	attacker.do_attack_animation(defender, ATTACK_EFFECT_PUNCH)
	if(check_one_click_combo(attacker, defender))
		return MARTIAL_ATTACK_SUCCESS
	add_to_streak("H", defender)
	if(check_streak(attacker, defender))
		return MARTIAL_ATTACK_SUCCESS
	defender.apply_damage(6, BRUTE)
	playsound(get_turf(defender), 'sound/effects/hit_punch.ogg', 50, TRUE, -1)
	defender.visible_message(span_danger("[attacker.declent_ru(NOMINATIVE)] [picked_hit_type] [defender.declent_ru(ACCUSATIVE)]!"), \
					span_userdanger("[attacker.declent_ru(NOMINATIVE)] [picked_hit_type] вас!"))
	log_combat(attacker, defender, "Melee attacked with [src]")
	return MARTIAL_ATTACK_SUCCESS

/datum/martial_art/judo/disarm_act(mob/living/attacker, mob/living/defender)
	if(check_one_click_combo(attacker, defender))
		return MARTIAL_ATTACK_SUCCESS
	if(defender.check_block(attacker, 0, attacker.name, UNARMED_ATTACK))
		return MARTIAL_ATTACK_FAIL
	add_to_streak("D", defender)
	if(check_streak(attacker, defender))
		return MARTIAL_ATTACK_SUCCESS
	if(attacker == defender)//there is no disarming yourself, so we need to let user know
		to_chat(attacker, span_notice("Вы добавили толчек в комбо."))
		return MARTIAL_ATTACK_FAIL

	return MARTIAL_ATTACK_INVALID

/datum/martial_art/judo/grab_act(mob/living/attacker, mob/living/defender)
	if(defender.check_block(attacker, 0, "[attacker]'s grab", UNARMED_ATTACK))
		return MARTIAL_ATTACK_FAIL

	defender.Stun( 0.4 SECONDS)

	add_to_streak("G", defender)
	return check_streak(attacker, defender) ? MARTIAL_ATTACK_SUCCESS : MARTIAL_ATTACK_INVALID

/datum/martial_art/judo/help_act(mob/living/attacker, mob/living/defender)
	if(check_one_click_combo(attacker, defender))
		return MARTIAL_ATTACK_SUCCESS
	add_to_streak("E", defender)
	attacker.changeNext_move(CLICK_CD_MELEE / 2)
	return check_streak(attacker, defender) ? MARTIAL_ATTACK_SUCCESS : MARTIAL_ATTACK_INVALID

/datum/martial_art/judo/proc/check_streak(mob/living/attacker, mob/living/defender)
	if(findtext(streak, GOLDENBLAST_COMBO))
		reset_streak()
		return goldenblast(attacker, defender)
	// must be upper than eyepoke
	if(check_with_no_reset(WHEELTHROW_COMBO))
		reset_streak()
		return wheelthrow(attacker, defender)
	if(check_with_no_reset(ARMBAR_COMBO))
		return armbar(attacker, defender)
	if(check_with_no_reset(EYEPOKE_COMBO))
		return eyepoke(attacker, defender)
	if(check_with_no_reset(JUDOTHROW_COMBO))
		return judothrow(attacker, defender)
	return FALSE

/datum/martial_art/judo/proc/check_one_click_combo(mob/living/attacker, mob/living/defender)
	if(findtext(streak, DISCOMBOBULATE_COMBO))
		reset_streak()
		return discombobulate(attacker, defender)

///Used to make combos in other combos
/datum/martial_art/judo/proc/check_with_no_reset(combo)
	var/combo_len = length(combo)
	if(combo_len > length(streak))
		return FALSE
	return findtext(streak, combo, -1 * combo_len)

/datum/martial_art/judo/proc/armbar(mob/living/attacker, mob/living/defender)
	if(defender.body_position != LYING_DOWN)
		return FALSE
	defender.visible_message(span_warning("[attacker.declent_ru(NOMINATIVE)] берёт [defender.declent_ru(ACCUSATIVE)] в захват!"), \
						span_userdanger("[attacker.declent_ru(NOMINATIVE)] берёт вас в захват!"))
	playsound(get_turf(attacker), 'sound/items/weapons/slashmiss.ogg', 40, TRUE, -1)
	if(attacker.body_position != LYING_DOWN)
		defender.drop_all_held_items()
	defender.apply_damage(45, STAMINA)
	defender.apply_status_effect(/datum/status_effect/judo_armbar)
	defender.Knockdown(5 SECONDS)
	log_combat(attacker, defender, "Melee attacked with martial-art [src] : Armbar")
	return TRUE

/datum/martial_art/judo/proc/eyepoke(mob/living/attacker, mob/living/defender)
	if(defender.is_pepper_proof()) //not all eye_cover flags really cover eyes.
		to_chat(attacker, "Глаза цели защищены от удара.")
		return FALSE

	defender.visible_message(span_warning("[attacker.declent_ru(NOMINATIVE)] тыкает в глаза [defender.declent_ru(ACCUSATIVE)]!"), \
						span_userdanger("[attacker.declent_ru(ACCUSATIVE)] тыкает вам в глаза!"))
	playsound(get_turf(attacker), 'sound/items/weapons/whip.ogg', 40, TRUE, -1)
	defender.apply_damage(10, BRUTE)
	defender.set_eye_blur_if_lower(30 SECONDS)
	defender.adjust_temp_blindness(2 SECONDS)
	log_combat(attacker, defender, "Melee attacked with martial-art [src] : Eye Poke")
	return TRUE

/datum/martial_art/judo/proc/goldenblast(mob/living/attacker, mob/living/defender)
	defender.visible_message(span_warning("[attacker.declent_ru(NOMINATIVE)] бьёт [defender.declent_ru(ACCUSATIVE)] энергией, прижимая к земле!"), \
						span_userdanger("[attacker.declent_ru(NOMINATIVE)] делает странные жесты руками, дико кричит и тычет вам прямо в грудь! Вы чувствуете, как гнев ЗОЛОТОГО РАЗРЯДА пронзает ваше тело! Вы совершенно обробастены!"))
	playsound(get_turf(defender), 'sound/items/weapons/taser.ogg', 55, TRUE, -1)
	defender.SpinAnimation(10, 1)
	do_sparks(5, FALSE, defender)
	attacker.say("ЗОЛОТОЙ РАЗРЯД!")
	playsound(get_turf(attacker), 'modular_bandastation/martial_arts/sound/goldenblast.ogg', 60, TRUE, -1)
	defender.apply_damage(120, STAMINA)
	defender.Knockdown(30 SECONDS)
	defender.set_confusion(30 SECONDS)
	log_combat(attacker, defender, "Melee attacked with martial-art [src] : Golden Blast")
	return TRUE

/datum/martial_art/judo/proc/judothrow(mob/living/attacker, mob/living/defender)
	if((attacker.body_position == LYING_DOWN) || (defender.body_position == LYING_DOWN))
		return FALSE
	defender.visible_message(span_warning("[attacker.declent_ru(NOMINATIVE)] бросает [defender.declent_ru(ACCUSATIVE)] на землю!"), \
						span_userdanger("[attacker.declent_ru(NOMINATIVE)] бросает вас на землю!"))
	playsound(get_turf(attacker), 'sound/items/weapons/slam.ogg', 40, TRUE, -1)
	defender.apply_damage(25, STAMINA)
	defender.Knockdown(7 SECONDS)
	log_combat(attacker, defender, "Melee attacked with martial-art [src] : Judo Throw")
	return TRUE

/datum/martial_art/judo/proc/wheelthrow(mob/living/attacker, mob/living/defender)
	if((defender.body_position != LYING_DOWN) || !defender.has_status_effect(/datum/status_effect/judo_armbar))
		return FALSE

	if(attacker.body_position != LYING_DOWN)
		defender.visible_message(span_warning("[attacker.declent_ru(NOMINATIVE)] бросает [defender.declent_ru(ACCUSATIVE)] через плечо, и стукает об землю!"), \
							span_userdanger("[attacker.declent_ru(NOMINATIVE)] бросает вас через плечо,стукая об землю!"))
		playsound(get_turf(attacker), 'sound/effects/magic/tail_swing.ogg', 40, TRUE, -1)
		defender.SpinAnimation(10, 1)
	else
		defender.visible_message(span_warning("[attacker.declent_ru(NOMINATIVE)] прижимает [defender.declent_ru(ACCUSATIVE)] к земле."), \
							span_userdanger("[attacker.declent_ru(NOMINATIVE)] прижимает вас к земле!"))
		playsound(get_turf(attacker), 'sound/items/weapons/slam.ogg', 40, TRUE, -1)

	defender.apply_damage(120, STAMINA)
	defender.Knockdown(15 SECONDS)
	defender.set_confusion(10 SECONDS)
	log_combat(attacker, defender, "Melee attacked with martial-art [src] : Wheel Throw / Floor Pin")
	return TRUE

/datum/action/discombobulate
	name = "Сбить с толку"
	desc = "Нанесите противнику удар по уху, ненадолго сбив его с толку."
	button_icon = 'modular_bandastation/martial_arts/icons/actions.dmi'
	button_icon_state = "discombobulate"
	check_flags = AB_CHECK_INCAPACITATED|AB_CHECK_HANDS_BLOCKED|AB_CHECK_CONSCIOUS

/datum/action/discombobulate/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return
	var/datum/martial_art/source = target
	if (source.streak ==  DISCOMBOBULATE_COMBO)
		owner.visible_message(span_danger("[owner.declent_ru(NOMINATIVE)] встает в нейтральную стойку."), span_bolditalic("Вы не готовите новых приёмов."))
		source.streak = ""
	else
		owner.visible_message(span_danger("[owner.declent_ru(NOMINATIVE)] встает в сбивающую стойку!"), span_bolditalic("Ваше следующеё приём это 'сбить с толку'."))
		source.streak = DISCOMBOBULATE_COMBO

/datum/martial_art/judo/proc/discombobulate(mob/living/attacker, mob/living/defender)
	defender.visible_message(span_warning("[attacker.declent_ru(NOMINATIVE)] бьёт [attacker.declent_ru(ACCUSATIVE)] ладонью по голове!"), \
						span_userdanger("[attacker.declent_ru(NOMINATIVE)] ударяет вас ладонью!"))
	playsound(get_turf(attacker), 'sound/items/weapons/slap.ogg', 40, TRUE, -1)
	defender.apply_damage(10, STAMINA)
	defender.adjust_confusion(5 SECONDS)
	log_combat(attacker, defender, "Melee attacked with martial-art [src] : Discombobulate")
	return TRUE
