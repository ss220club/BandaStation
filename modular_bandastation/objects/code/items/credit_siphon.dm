/obj/item/credit_siphon
	name = "credit siphon"
	desc = "A clandestine device that skims credits from nearby bank accounts."
	icon = 'icons/obj/devices.dmi'
	icon_state = "radio"
	w_class = WEIGHT_CLASS_SMALL
	interaction_flags_click = NEED_DEXTERITY|FORBID_TELEKINESIS_REACH
	/// Credits currently held by the siphon.
	var/credits_stored = 0
	/// The fraction of a nearby account removed on each siphon tick.
	var/siphon_percentage = 0.15
	/// Maximum distance between the device and a target.
	var/siphon_range = 3
	/// Time between siphon ticks.
	var/siphon_interval = 15 SECONDS
	COOLDOWN_DECLARE(siphon_cooldown)

/obj/item/credit_siphon/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/credit_siphon/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/credit_siphon/attack_self(mob/living/user)
	ui_interact(user)

/obj/item/credit_siphon/process(seconds_per_tick)
	if(!COOLDOWN_FINISHED(src, siphon_cooldown))
		return
	COOLDOWN_START(src, siphon_cooldown, siphon_interval)

	var/mob/living/carbon/human/holder = recursive_loc_check(src, /mob/living/carbon/human)
	for(var/mob/living/carbon/human/target in viewers(siphon_range, get_turf(src)))
		if(target == holder || target.stat == DEAD)
			continue
		var/obj/item/card/id/id_card = target.get_idcard(TRUE)
		var/datum/bank_account/account = id_card?.registered_account
		if(!account || !account.account_balance)
			continue
		var/amount = max(1, round(account.account_balance * siphon_percentage))
		amount = min(amount, account.account_balance)
		if(!account.adjust_money(-amount, "Система: Несанкционированное списание"))
			continue
		credits_stored += amount
		account.bank_card_talk("С вашего счёта списано [amount][MONEY_NAME]. Источник не определён.")

/obj/item/credit_siphon/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	if(.)
		return FALSE
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CreditSiphon", name)
		ui.open()

/obj/item/credit_siphon/ui_status(mob/user, datum/ui_state/state)
	. = ..()
	if(!in_range(user, src) && !isobserver(user))
		return UI_CLOSE

/obj/item/credit_siphon/ui_data(mob/user)
	return list("credits_stored" = credits_stored)

/obj/item/credit_siphon/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return FALSE
	if(action != "withdraw" || !credits_stored || !in_range(usr, src))
		return FALSE
	var/amount = credits_stored
	credits_stored = 0
	var/obj/item/holochip/holochip = new (usr.drop_location(), amount)
	usr.put_in_hands(holochip)
	to_chat(usr, span_notice("Вы выводите [amount][MONEY_NAME] из устройства."))
	return TRUE
