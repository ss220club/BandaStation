/obj/item/credit_siphon
	name = "credit siphon"
	desc = "A clandestine device that skims credits from nearby bank accounts."
	icon = 'icons/obj/devices/voice.dmi'
	icon_state = "walkietalkie"
	w_class = WEIGHT_CLASS_SMALL
	interaction_flags_click = NEED_DEXTERITY|FORBID_TELEKINESIS_REACH
	var/credits_stored = 0
	var/active = FALSE
	var/siphon_percentage = 0.15
	var/siphon_range = 5
	var/siphon_interval = 15 SECONDS
	COOLDOWN_DECLARE(siphon_cooldown)
	COOLDOWN_DECLARE(attach_cooldown)

/obj/item/credit_siphon/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/credit_siphon/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/credit_siphon/attack_self(mob/living/user)
	ui_interact(user)

/obj/item/credit_siphon/process(seconds_per_tick)
	if(!active)
		return
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

/obj/item/credit_siphon/proc/get_nearby_players()
	var/mob/living/carbon/human/holder = recursive_loc_check(src, /mob/living/carbon/human)
	var/list/nearby_players = list()
	for(var/mob/living/carbon/human/target in viewers(siphon_range, get_turf(src)))
		if(target == holder || target.stat == DEAD || !target.client)
			continue
		nearby_players += list(list("name" = target.name, "ref" = REF(target)))
	return nearby_players

/obj/item/credit_siphon/proc/attach_to_player(mob/user, target_ref)
	if(!COOLDOWN_FINISHED(src, attach_cooldown))
		return FALSE
	var/mob/living/carbon/human/holder = recursive_loc_check(src, /mob/living/carbon/human)
	var/mob/living/carbon/human/target = locate(target_ref)
	if(!istype(target) || target == holder || target.stat == DEAD || !target.client)
		return FALSE
	if(get_dist(get_turf(src), get_turf(target)) > siphon_range)
		return FALSE
	forceMove(target)
	COOLDOWN_START(src, attach_cooldown, 10 MINUTES)
	for(var/obj/item/modular_computer/pda/pda in target.get_all_contents())
		var/datum/computer_file/program/messenger/messenger_app = locate() in pda.stored_files
		if(!messenger_app)
			continue
		pda.alert_call(messenger_app, "Обнаружен несанкционированный доступ к банковскому счёту.")
		messenger_app.alert_pending = TRUE
		pda.update_appearance(UPDATE_ICON)
		break
	return TRUE

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
	var/mob/living/carbon/human/holder = recursive_loc_check(src, /mob/living/carbon/human)
	return list(
		"credits_stored" = credits_stored,
		"active" = active,
		"attached" = !isnull(holder),
		"nearby_players" = get_nearby_players(),
	)

/obj/item/credit_siphon/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return FALSE
	switch(action)
		if("toggle")
			active = !active
			if(active)
				COOLDOWN_START(src, siphon_cooldown, siphon_interval)
			return TRUE
		if("attach")
			return attach_to_player(usr, params["target"])
		if("withdraw")
			if(!credits_stored || !in_range(usr, src))
				return FALSE
			var/amount = credits_stored
			credits_stored = 0
			var/obj/item/holochip/holochip = new (usr.drop_location(), amount)
			usr.put_in_hands(holochip)
			to_chat(usr, span_notice("Вы выводите [amount][MONEY_NAME] из устройства."))
			return TRUE
	return FALSE
