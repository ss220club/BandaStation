/obj/item/firing_pin
	name = "electronic firing pin"
	desc = "Небольшое устройство аутентификации, вставляемое в огнестрельное оружие для обеспечения стрельбы. Техника безопасности НТ требует использование устройства во всех новых дизайнах вооружения."
	icon = 'icons/obj/devices/gunmod.dmi'
	icon_state = "firing_pin"
	inhand_icon_state = "pen"
	worn_icon_state = "pen"
	obj_flags = CONDUCTS_ELECTRICITY
	w_class = WEIGHT_CLASS_TINY
	attack_verb_continuous = list("pokes")
	attack_verb_simple = list("poke")
	var/fail_message = "недопустимый пользователь!"
	/// Explode when user check is failed.
	var/selfdestruct = FALSE
	/// Can forcefully replace other pins.
	var/force_replace = FALSE
	/// Can be replaced by any pin.
	var/pin_hot_swappable = FALSE
	///Can be removed from the gun using tools or replaced by a pin with force_replace
	var/pin_removable = TRUE
	var/obj/item/gun/gun

/obj/item/firing_pin/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!isgun(interacting_with))
		return NONE

	var/obj/item/gun/targeted_gun = interacting_with
	var/obj/item/firing_pin/old_pin = targeted_gun.pin
	if(old_pin?.pin_removable && (force_replace || old_pin.pin_hot_swappable))
		if(Adjacent(user))
			user.put_in_hands(old_pin)
		else
			old_pin.forceMove(targeted_gun.drop_location())
		old_pin.gun_remove(user)

	if(!targeted_gun.pin)
		if(!user.temporarilyRemoveItemFromInventory(src))
			return .
		if(gun_insert(user, targeted_gun))
			if(old_pin)
				balloon_alert(user, "ударник заменен")
			else
				balloon_alert(user, "ударник вставлен")
	else
		to_chat(user, span_notice("Это огнестрельное оружие уже имеет установленный ударник."))

	return ITEM_INTERACT_SUCCESS

/obj/item/firing_pin/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	obj_flags |= EMAGGED
	balloon_alert(user, "проверка аутентификации переписана")
	return TRUE

/obj/item/firing_pin/proc/gun_insert(mob/living/user, obj/item/gun/new_gun)
	gun = new_gun
	forceMove(gun)
	gun.pin = src
	return TRUE

/obj/item/firing_pin/proc/gun_remove(mob/living/user)
	gun.pin = null
	gun = null
	return

/obj/item/firing_pin/proc/pin_auth(mob/living/user)
	return TRUE

/obj/item/firing_pin/proc/auth_fail(mob/living/user)
	if(user)
		balloon_alert(user, fail_message)
	if(selfdestruct)
		if(user)
			user.show_message("[span_danger("САМОУНИЧТОЖЕНИЕ...")]<br>", MSG_VISUAL)
			to_chat(user, span_userdanger("[capitalize(gun.declent_ru(NOMINATIVE))] взрывается!"))
		explosion(src, devastation_range = -1, light_impact_range = 2, flash_range = 3)
		if(gun)
			qdel(gun)


/obj/item/firing_pin/magic
	name = "magic crystal shard"
	desc = "A small enchanted shard which allows magical weapons to fire."


// Test pin, works only near firing range.
/obj/item/firing_pin/test_range
	name = "test-range firing pin"
	desc = "This safety firing pin allows weapons to be fired within proximity to a firing range."
	fail_message = "проверка полигона не пройдена!"
	pin_hot_swappable = TRUE

/obj/item/firing_pin/test_range/pin_auth(mob/living/user)
	if(!istype(user))
		return FALSE
	if (istype(get_area(user), /area/station/security/range))
		return TRUE
	return FALSE


// Implant pin, checks for implant
/obj/item/firing_pin/implant
	name = "implant-keyed firing pin"
	desc = "This is a security firing pin which only authorizes users who are implanted with a certain device."
	fail_message = "проверка импланта не пройдена!"
	var/obj/item/implant/req_implant = null

/obj/item/firing_pin/implant/pin_auth(mob/living/user)
	if(user)
		for(var/obj/item/implant/I in user.implants)
			if(req_implant && I.type == req_implant)
				return TRUE
	return FALSE

/obj/item/firing_pin/implant/mindshield
	name = "mindshield firing pin"
	desc = "This Security firing pin authorizes the weapon for only mindshield-implanted users."
	icon_state = "firing_pin_loyalty"
	req_implant = /obj/item/implant/mindshield

/obj/item/firing_pin/implant/pindicate
	name = "syndicate firing pin"
	icon_state = "firing_pin_pindi"
	req_implant = /obj/item/implant/weapons_auth



// Honk pin, clown's joke item.
// Can replace other pins. Replace a pin in cap's laser for extra fun!
/obj/item/firing_pin/clown
	name = "hilarious firing pin"
	desc = "Advanced clowntech that can convert any firearm into a far more useful object."
	color = COLOR_YELLOW
	fail_message = "хонк!"
	force_replace = TRUE

/obj/item/firing_pin/clown/pin_auth(mob/living/user)
	playsound(src, 'sound/items/bikehorn.ogg', 50, TRUE)
	return FALSE

// Ultra-honk pin, clown's deadly joke item.
// A gun with ultra-honk pin is useful for clown and useless for everyone else.
/obj/item/firing_pin/clown/ultra
	name = "ultra hilarious firing pin"

/obj/item/firing_pin/clown/ultra/pin_auth(mob/living/user)
	playsound(src.loc, 'sound/items/bikehorn.ogg', 50, TRUE)
	if(QDELETED(user))  //how the hell...?
		stack_trace("/obj/item/firing_pin/clown/ultra/pin_auth called with a [isnull(user) ? "null" : "invalid"] user.")
		return TRUE
	if(HAS_TRAIT(user, TRAIT_CLUMSY)) //clumsy
		return TRUE
	if(user.mind)
		if(is_clown_job(user.mind.assigned_role)) //traitor clowns can use this, even though they're technically not clumsy
			return TRUE
		if(user.mind.has_antag_datum(/datum/antagonist/nukeop/clownop)) //clown ops aren't clumsy by default and technically don't have an assigned role of "Clown", but come on, they're basically clowns
			return TRUE
		if(user.mind.has_antag_datum(/datum/antagonist/nukeop/leader/clownop)) //Wanna hear a funny joke?
			return TRUE //The clown op leader antag datum isn't a subtype of the normal clown op antag datum.
	return FALSE

/obj/item/firing_pin/clown/ultra/gun_insert(mob/living/user, obj/item/gun/new_gun)
	..()
	new_gun.clumsy_check = FALSE

/obj/item/firing_pin/clown/ultra/gun_remove(mob/living/user)
	gun.clumsy_check = initial(gun.clumsy_check)
	..()

// Now two times deadlier!
/obj/item/firing_pin/clown/ultra/selfdestruct
	name = "super ultra hilarious firing pin"
	desc = "Advanced clowntech that can convert any firearm into a far more useful object. It has a small nitrobananium charge on it."
	selfdestruct = TRUE


// DNA-keyed pin.
// When you want to keep your toys for yourself.
/obj/item/firing_pin/dna
	name = "DNA-keyed firing pin"
	desc = "This is a DNA-locked firing pin which only authorizes one user. Attempt to fire once to DNA-link."
	icon_state = "firing_pin_dna"
	fail_message = "проверка ДНК не пройдена!"
	var/unique_enzymes = null

/obj/item/firing_pin/dna/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(iscarbon(interacting_with))
		var/mob/living/carbon/M = interacting_with
		if(M.dna && M.dna.unique_enzymes)
			unique_enzymes = M.dna.unique_enzymes
			balloon_alert(user, "ДНК-замок установлен")
			return ITEM_INTERACT_SUCCESS
		return ITEM_INTERACT_BLOCKING
	return ..()

/obj/item/firing_pin/dna/pin_auth(mob/living/carbon/user)
	if(user && user.dna && user.dna.unique_enzymes)
		if(user.dna.unique_enzymes == unique_enzymes)
			return TRUE
	return FALSE

/obj/item/firing_pin/dna/auth_fail(mob/living/carbon/user)
	if(!unique_enzymes)
		if(user && user.dna && user.dna.unique_enzymes)
			unique_enzymes = user.dna.unique_enzymes
			balloon_alert(user, "ДНК-замок установлен")
	else
		..()

/obj/item/firing_pin/dna/dredd
	desc = "This is a DNA-locked firing pin which only authorizes one user. Attempt to fire once to DNA-link. It has a small explosive charge on it."
	selfdestruct = TRUE

// Paywall pin, brought to you by ARMA 3 DLC.
// Checks if the user has a valid bank account on an ID and if so attempts to extract a one-time payment to authorize use of the gun. Otherwise fails to shoot.
/obj/item/firing_pin/paywall
	name = "paywall firing pin"
	desc = "A firing pin with a built-in configurable paywall."
	color = COLOR_GOLD
	fail_message = ""
	///list of account IDs which have accepted the license prompt. If this is the multi-payment pin, then this means they accepted the waiver that each shot will cost them money
	var/list/gun_owners = list()
	///how much gets paid out to license yourself to the gun
	var/payment_amount
	var/datum/bank_account/pin_owner
	///if true, user has to pay everytime they fire the gun
	var/multi_payment = FALSE
	var/owned = FALSE
	///purchase prompt to prevent spamming it, set to the user who opens to prompt to prevent locking the gun up for other users.
	var/active_prompt_user

/obj/item/firing_pin/paywall/attack_self(mob/user)
	multi_payment = !multi_payment
	to_chat(user, span_notice("Вы устанавливаете режим оплаты ударника на [( multi_payment ) ? "оплату каждым выстрелом" : "одноразовую оплату лицензии"]."))

/obj/item/firing_pin/paywall/examine(mob/user)
	. = ..()
	if(pin_owner)
		. += span_notice("Этот ударник настроен на оплату счета имени: [pin_owner.account_holder].")

/obj/item/firing_pin/paywall/gun_insert(mob/living/user, obj/item/gun/new_gun)
	if(!pin_owner)
		if(isnull(user))
			forceMove(new_gun.drop_location())
		else
			to_chat(user, span_warning("ОШИБКА: Пожалуйста, проведите действующую ID-карту перед установкой ударника!"))
			user.put_in_hands(src)
		return FALSE
	..()
	if(multi_payment)
		gun.desc += span_notice(" [capitalize(gun.declent_ru(NOMINATIVE))] требует оплату за каждый выстрел в размере [payment_amount] кредит[declension_ru(payment_amount, "", "а", "ов")].")
		return TRUE
	gun.desc += span_notice(" [capitalize(gun.declent_ru(NOMINATIVE))] требует оплаты лицензии в размере [payment_amount] кредит[declension_ru(payment_amount, "", "а", "ов")].")
	return TRUE


/obj/item/firing_pin/paywall/gun_remove(mob/living/user)
	gun.desc = gun::desc
	..()

/obj/item/firing_pin/paywall/attackby(obj/item/M, mob/living/user, params)
	if(isidcard(M))
		var/obj/item/card/id/id = M
		if(!id.registered_account)
			to_chat(user, span_warning("ОШИБКА: ID-карта не имеет зарегистрированного банковского счета!"))
			return
		if(id.registered_account != pin_owner && owned)
			to_chat(user, span_warning("ОШИБКА: Этот ударник уже имеет привязанный счет!"))
			return
		if(id.registered_account == pin_owner)
			to_chat(user, span_notice("Вы отвязываете ID-карту от ударника."))
			gun_owners -= user.get_bank_account()
			pin_owner = null
			owned = FALSE
			return
		var/transaction_amount = tgui_input_number(user, "Введите допустимую сумму оплаты оружия", "Сумма оплаты")
		if(!transaction_amount || QDELETED(user) || QDELETED(src) || !user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
			return
		pin_owner = id.registered_account
		owned = TRUE
		payment_amount = transaction_amount
		gun_owners += user.get_bank_account()
		to_chat(user, span_notice("Вы привязываете ID-карту к ударнику."))

/obj/item/firing_pin/paywall/pin_auth(mob/living/user)
	if(!istype(user))//nice try commie
		return FALSE
	var/datum/bank_account/credit_card_details = user.get_bank_account()
	if(credit_card_details in gun_owners)
		if(multi_payment && credit_card_details)
			if(!gun.can_shoot())
				return TRUE //So you don't get charged for attempting to fire an empty gun.
			if(credit_card_details.adjust_money(-payment_amount, "Ударник: оплата аренды оружия"))
				if(pin_owner)
					pin_owner.adjust_money(payment_amount, "Ударник: зарплата за аренду оружия")
				return TRUE
			to_chat(user, span_warning("ОШИБКА: Недостаточно баланса у пользователя для транзакции!"))
			return FALSE
		return TRUE
	if(!credit_card_details)
		to_chat(user, span_warning("ОШИБКА: Пользователь не имеет действующего банковского счета для снятия средств!"))
		return FALSE
	if(active_prompt_user == user)
		return FALSE
	active_prompt_user = user
	var/license_request = tgui_alert(user, "Вы готовы к оплате [payment_amount] кредит[declension_ru(payment_amount, "", "а", "ов")] за [( multi_payment ) ? "каждый выстрел из [gun.declent_ru(GENITIVE)]" : "лицензию [gun.declent_ru(GENITIVE)]"]?", "Покупка оружия", list("Да", "Нет"), 15 SECONDS)
	if(!user.can_perform_action(src))
		active_prompt_user = null
		return FALSE
	switch(license_request)
		if("Да")
			if(multi_payment)
				gun_owners += credit_card_details
				to_chat(user, span_notice("Условия аренды оружия согласованы, безопасного вам дня!"))

			else if(credit_card_details.adjust_money(-payment_amount, "Ударник: оплата лицензии оружия"))
				if(pin_owner)
					pin_owner.adjust_money(payment_amount, "Ударник: зарплата за лицензию оружия")
				gun_owners += credit_card_details
				to_chat(user, span_notice("Лицензия на оружие куплена, безопасного вам дня!"))

			else
				to_chat(user, span_warning("ОШИБКА: Недостаточно баланса у пользователя для транзакции!"))

		if("Нет", null)
			to_chat(user, span_warning("ОШИБКА: Пользователь отказался от оплаты оружия!"))
	active_prompt_user = null
	return FALSE //we return false here so you don't click initially to fire, get the prompt, accept the prompt, and THEN the gun

// Explorer Firing Pin- Prevents use on station Z-Level, so it's justifiable to give Explorers guns that don't suck.
/obj/item/firing_pin/explorer
	name = "outback firing pin"
	desc = "A firing pin used by the Australian defense force, retrofit to prevent weapon discharge on the station."
	icon_state = "firing_pin_explorer"
	fail_message = "вы на территории станции, дружок!"

// This checks that the user isn't on the station Z-level.
/obj/item/firing_pin/explorer/pin_auth(mob/living/user)
	var/turf/station_check = get_turf(user)
	if(!station_check || is_station_level(station_check.z))
		return FALSE
	return TRUE

// Laser tag pins
/obj/item/firing_pin/tag
	name = "laser tag firing pin"
	desc = "A recreational firing pin, used in laser tag units to ensure users have their vests on."
	fail_message = "не тот цвет брони!"
	var/obj/item/clothing/suit/suit_requirement = null
	var/tagcolor = ""

/obj/item/firing_pin/tag/pin_auth(mob/living/user)
	if(ishuman(user))
		var/mob/living/carbon/human/M = user
		if(istype(M.wear_suit, suit_requirement))
			return TRUE
	to_chat(user, span_warning("Вам нужно иметь лазер-таг броню [tagcolor] цвета!"))
	return FALSE

/obj/item/firing_pin/tag/red
	name = "red laser tag firing pin"
	icon_state = "firing_pin_red"
	suit_requirement = /obj/item/clothing/suit/redtag
	tagcolor = "красного"

/obj/item/firing_pin/tag/blue
	name = "blue laser tag firing pin"
	icon_state = "firing_pin_blue"
	suit_requirement = /obj/item/clothing/suit/bluetag
	tagcolor = "синего"

/obj/item/firing_pin/monkey
	name = "monkeylock firing pin"
	desc = "This firing pin prevents non-monkeys from firing a gun."
	fail_message = "вы не мартышка!"

/obj/item/firing_pin/monkey/pin_auth(mob/living/user)
	if(!is_simian(user))
		playsound(src, SFX_SCREECH, 75, TRUE)
		return FALSE
	return TRUE

/obj/item/firing_pin/Destroy()
	if(gun)
		gun.pin = null
		gun = null
	return ..()
