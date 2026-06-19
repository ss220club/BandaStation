/obj/item/card/id/advanced/ussp/passport
	name = "\improper Паспорт СССП"
	desc = "Паспорт гражданина СССП. Заодно это трудовая книжка, автомобильные права, военный билет и чёрт знает что ещё."
	icon_state = "ussp_passport"

/obj/item/card/id/advanced/ussp/passport/update_overlays()
	. = ..()
	for(var/mutable_appearance/overlay in .)
		if(overlay.icon_state == "subdepartment")
			. -= overlay

/obj/item/card/id/advanced/ussp/passport/update_label()
	var/name_string
	if(registered_name)
		if(trim && (honorific_position & ~HONORIFIC_POSITION_NONE))
			name_string = "Паспорт «[update_honorific()]»"
		else
			name_string = "Паспорт «[registered_name]»"
	else
		name_string = initial(name)

	var/assignment_string

	if(is_intern)
		if(assignment)
			assignment_string = trim?.intern_alt_name || "Стажёр [assignment]"
		else
			assignment_string = "Стажёр"
	else
		assignment_string = assignment

	name = "[name_string] ([assignment_string])"

	if(ishuman(loc))
		var/mob/living/carbon/human/human = loc
		human.update_visible_name()

/obj/item/card/id/advanced/ussp/passport/examine(mob/user)
	. = ..()
	if(!user.can_read(src))
		return

	if(registered_account && !isnull(registered_account.account_id))
		. -= "Аккаунт привязанный к ID-карте принадлежит '[registered_account.account_holder]' и отображает баланс в размере [registered_account.account_balance][MONEY_SYMBOL]."
		. += "Запись сберкассы привязанная к паспорту принадлежит '[registered_account.account_holder]' и отображает баланс в размере [registered_account.account_balance][MONEY_SYMBOL]."
		if(ACCESS_COMMAND in access)
			var/datum/bank_account/linked_dept = SSeconomy.get_dep_account(registered_account.account_job.paycheck_department)
			. -= "[linked_dept.account_holder] привязанный к ID-карте отображает баланс [linked_dept.account_balance][MONEY_SYMBOL]."
	else
		. -= span_notice("Alt-ПКМ, чтобы привязать ID-карту к банковскому счёту.")
		. += span_notice("Alt-ПКМ, чтобы привязать паспорт к записи сберкассы.")

/obj/item/card/id/advanced/ussp/passport/examine_more(mob/user)
	. = ..()
	if(!user.can_read(src))
		return

	if(registered_age)
		. -= "На карточке указан возраст [registered_age]. [(registered_age < AGE_MINOR) ? "Внизу карточки есть голографическая полоска с надписью <b>[span_danger("НЕСОВЕРШЕННОЛЕТНИЙ: НЕ ПОДАВАТЬ АЛКОГОЛЬ ИЛИ ТАБАК")]</b>." : ""]"
		. += "В паспорте указан возраст [registered_age]. [(registered_age < AGE_MINOR) ? "Внизу паспорта есть голографическая полоска с надписью <b>[span_danger("НЕСОВЕРШЕННОЛЕТНИЙ: НЕ ПОДАВАТЬ АЛКОГОЛЬ ИЛИ ТАБАК")]</b>." : ""]"
	if(registered_account)
		if(registered_account.mining_points)
			. -= "На карточке показывается шахтёрские очки в количестве [registered_account.mining_points]."
			. += "В паспорте показываются шахтёрские очки в количестве [registered_account.mining_points]."
		. -= "Привязанный аккаунт к ID-карте принадлежит «[registered_account.account_holder]» и отображает баланс в размере [registered_account.account_balance][MONEY_SYMBOL]."
		. += "Привязанная к паспорту запись сберкассы принадлежит «[registered_account.account_holder]» и отображает баланс в размере [registered_account.account_balance][MONEY_SYMBOL]."
		if(registered_account.account_debt)
			. += span_warning("На данный момент на счёте имеется задолженность в размере [registered_account.account_debt][MONEY_SYMBOL]. [100*DEBT_COLLECTION_COEFF]% заработанных средств пойдет на его погашение.")
		if(registered_account.account_job)
			var/datum/bank_account/D = SSeconomy.get_dep_account(registered_account.account_job.paycheck_department)
			if(D)
				. -= "[D.account_holder] имеет баланс [D.account_balance][MONEY_SYMBOL]."
		. -= span_info("Alt-ЛКМ, чтобы снять деньги с ID-карты в виде голочипов.")
		. += span_info("Alt-ЛКМ, чтобы снять деньги с паспорта в виде голочипов.")
		. -= span_info("Вы можете вставлять кредиты на привязанный аккаунт, прикладывая голочипы, наличку или монеты на ID-карту.")
		. += span_info("Вы можете вставлять кредиты на привязанную запись сберкассы, прикладывая голочипы, наличку или монеты в паспорт.")
		if(registered_account.replaceable)
			. -= span_info("Alt-ПКМ, чтобы поменять привязанный банковский аккаунт.")
			. += span_info("Alt-ПКМ, чтобы поменять привязанную запись сберкассы.")
		if(registered_account.civilian_bounty)
			. += span_info("<b>Активные гражданские заказы.</b>")
			. += span_info("<i>[registered_account.bounty_text()]</i>")
			. += span_info("Количество: [registered_account.bounty_num()]")
			. += span_info("Награда: [registered_account.bounty_value()]")
		if(registered_account.account_holder == user.real_name)
			. -= span_boldnotice("Если вы потеряете ID-карту, то можете восстановить аккаунт нажав Alt+ЛКМ на пустой ID-карте, когда держите его или введя номер аккаунта.")
			. += span_boldnotice("Если вы потеряете паспорт, то можете восстановить запись сберкассы нажав Alt+ЛКМ на пустом паспорте, когда держите его или введя номер записи.")
	else
		. -= span_info("Нет привязанного аккаунта к этой ID-карте. Alt-ЛКМ, чтобы добавить аккаунт.")
		. += span_info("Нет привязанной записи сберкассы для этого паспорта. Alt-ЛКМ, чтобы добавить запись.")

	return .

/obj/item/card/id/advanced/ussp/passport/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	if(istype(loc, /obj/item/storage/wallet) || istype(loc, /obj/item/modular_computer))
		icon_state = "card_ussp"
	else
		icon_state = "ussp_passport"

/obj/item/card/id/advanced/ussp/passport/Initialize(mapload)
	. = ..()
	if(istype(loc, /obj/item/storage/wallet) || istype(loc, /obj/item/modular_computer))
		icon_state = "card_ussp"
