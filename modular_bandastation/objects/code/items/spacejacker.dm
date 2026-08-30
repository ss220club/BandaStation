/obj/item/spacejacker
	name = "credit siphon"
	desc = "Портативное хакерское устройство, которое позволяет вам тайно снимать кредиты с банковских счетов других членов экипажа и прикреплять к их КПК вирус, который передаёт деньги на ваш космохакер. Также имеет выгодный обменник кредитов на ТК, но будьте осторожны, ТК ограничены, а также слишком частое использование может вызвать подозрения у других членов экипажа."
	icon = 'icons/obj/devices/voice.dmi'
	icon_state = "walkietalkie"
	w_class = WEIGHT_CLASS_SMALL
	interaction_flags_click = NEED_DEXTERITY|FORBID_TELEKINESIS_REACH
	var/credits_stored = 0
	var/active = FALSE
	var/siphon_percentage = 0.15
	var/siphon_range = 5
	var/siphon_interval = 15 SECONDS
	var/tc_purchased = 0
	var/tc_price = 950
	var/tc_purchase_limit = 8
	var/exchange_player_count = -1
	var/exchange_traitor_count = -1
	var/datum/weakref/attached_target_ref
	COOLDOWN_DECLARE(siphon_cooldown)
	COOLDOWN_DECLARE(attach_cooldown)

/obj/item/spacejacker/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/spacejacker/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/spacejacker/attack_self(mob/living/user)
	ui_interact(user)

/obj/item/spacejacker/process(seconds_per_tick)
	if(!active)
		return
	if(!COOLDOWN_FINISHED(src, siphon_cooldown))
		return
	COOLDOWN_START(src, siphon_cooldown, siphon_interval)

	var/mob/living/carbon/human/holder = recursive_loc_check(src, /mob/living/carbon/human)
	var/turf/siphon_center = get_turf(src)
	if(attached_target_ref)
		var/mob/living/carbon/human/attached_target = attached_target_ref.resolve()
		if(!attached_target)
			attached_target_ref = null
			return
		var/obj/item/modular_computer/pda/target_pda = locate() in attached_target.get_all_contents()
		if(!target_pda)
			attached_target_ref = null
			return
		siphon_center = get_turf(target_pda)
	var/list/targets = viewers(siphon_range, siphon_center)
	for(var/mob/living/carbon/human/target in targets)
		if(target == holder || target.stat == DEAD)
			continue
		var/obj/item/card/id/id_card = target.get_idcard(TRUE)
		var/datum/bank_account/account = id_card?.registered_account
		if(!account || !account.account_balance)
			continue
		var/amount = max(1, round(account.account_balance * siphon_percentage))
		amount = min(amount, account.account_balance)
		if(!account.adjust_money(-amount, "Система: несанкционированное списание"))
			continue
		credits_stored += amount
		account.bank_card_talk("С вашего счёта списано [amount][MONEY_NAME]. Источник не определён.")

/obj/item/spacejacker/proc/get_nearby_players()
	var/mob/living/carbon/human/holder = recursive_loc_check(src, /mob/living/carbon/human)
	var/list/nearby_players = list()
	for(var/mob/living/carbon/human/target in viewers(siphon_range, get_turf(src)))
		if(target == holder || target.stat == DEAD || !target.client)
			continue
		nearby_players += list(list("name" = target.name, "ref" = REF(target)))
	return nearby_players

/obj/item/spacejacker/proc/update_exchange_rate()
	var/player_count = length(GLOB.alive_player_list)
	var/traitor_count = length(get_antag_minds(/datum/antagonist/traitor))

	if(player_count == exchange_player_count && traitor_count == exchange_traitor_count)
		return

	exchange_player_count = player_count
	exchange_traitor_count = traitor_count
	var/threshold = CONFIG_GET(number/spacejacker_player_threshold)
	tc_purchase_limit = player_count >= threshold ? CONFIG_GET(number/spacejacker_tc_limit_high) : CONFIG_GET(number/spacejacker_tc_limit_low)
	tc_price = player_count >= threshold ? CONFIG_GET(number/spacejacker_tc_price_high) : CONFIG_GET(number/spacejacker_tc_price_low)
	for(var/traitor_number in 1 to traitor_count)
		tc_price += rand(5, 50)

/datum/config_entry/number/spacejacker_player_threshold
	default = 31

/datum/config_entry/number/spacejacker_tc_limit_low
	default = 7

/datum/config_entry/number/spacejacker_tc_limit_high
	default = 9

/datum/config_entry/number/spacejacker_tc_price_low
	default = 950

/datum/config_entry/number/spacejacker_tc_price_high
	default = 1000

/obj/item/spacejacker/proc/attach_to_player(mob/user, target_ref)
	if(!COOLDOWN_FINISHED(src, attach_cooldown))
		return FALSE
	var/mob/living/carbon/human/holder = recursive_loc_check(src, /mob/living/carbon/human)
	var/mob/living/carbon/human/target = locate(target_ref)
	if(!istype(target) || target == holder || target.stat == DEAD || !target.client)
		return FALSE
	if(get_dist(get_turf(src), get_turf(target)) > siphon_range)
		return FALSE
	var/obj/item/modular_computer/pda/target_pda = locate() in target.get_all_contents()
	if(!target_pda)
		return FALSE
	attached_target_ref = WEAKREF(target)
	playsound(target, 'sound/effects/youarehacked.ogg', 100, FALSE)
	COOLDOWN_START(src, attach_cooldown, 10 MINUTES)
	var/datum/computer_file/program/messenger/messenger_app = locate() in target_pda.stored_files
	if(messenger_app)
		target_pda.alert_call(messenger_app, "Обнаружен несанкционированный доступ к банковскому счёту.")
		messenger_app.alert_pending = TRUE
		target_pda.update_appearance(UPDATE_ICON)
	return TRUE

/obj/item/spacejacker/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	if(.)
		return FALSE
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CreditSiphon", name)
		ui.open()

/obj/item/spacejacker/ui_status(mob/user, datum/ui_state/state)
	. = ..()
	if(!in_range(user, src) && !isobserver(user))
		return UI_CLOSE

/obj/item/spacejacker/ui_data(mob/user)
	update_exchange_rate()
	return list(
		"credits_stored" = credits_stored,
		"tc_price" = tc_price,
		"tc_purchase_limit" = tc_purchase_limit,
		"tc_purchased" = tc_purchased,
		"active" = active,
		"attached" = !isnull(attached_target_ref),
		"nearby_players" = get_nearby_players(),
	)

/obj/item/spacejacker/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return FALSE
	switch(action)
		if("toggle")
			active = !active
			if(active)
				START_PROCESSING(SSobj, src)
				COOLDOWN_START(src, siphon_cooldown, siphon_interval)
			else
				STOP_PROCESSING(SSobj, src)
			return TRUE
		if("attach")
			return attach_to_player(usr, params["target"])
		if("buy_tc")
			update_exchange_rate()
			if(tc_purchased >= tc_purchase_limit || credits_stored < tc_price)
				return FALSE
			credits_stored -= tc_price
			tc_purchased++
			var/obj/item/stack/telecrystal/telecrystals = new (usr.drop_location(), 1)
			usr.put_in_hands(telecrystals)
			to_chat(usr, span_notice("Вы обмениваете [tc_price] [MONEY_NAME] на некоторую сумму телекристаллов."))
			return TRUE
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
