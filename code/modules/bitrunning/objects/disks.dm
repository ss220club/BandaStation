/**
 * Bitrunning tech disks which let you load items or programs into the vdom on first avatar generation.
 * For the record: Balance shouldn't be a primary concern.
 * You can make the custom cheese spells you've always wanted.
 * Just make it fun and engaging, it's PvE content.
 */
/obj/item/bitrunning_disk
	name = "generic bitrunning program"
	desc = "Диск с исходным кодом."
	icon = 'icons/obj/devices/circuitry_n_data.dmi'
	base_icon_state = "datadisk"
	icon_state = "datadisk0"
	/// Name of the choice made
	var/choice_made

/obj/item/bitrunning_disk/Initialize(mapload)
	. = ..()

	icon_state = "[base_icon_state][rand(0, 7)]"
	update_icon()

/obj/item/bitrunning_disk/examine(mob/user)
	. = ..()
	. += span_infoplain("Этот диск должен находится у вас, когда вы входите в нетпод.")

	if(isnull(choice_made))
		. += span_notice("Используйте в руке, чтобы изменить выбор.")
		return

	. += span_info("Сейчас выбрано: <b>[choice_made]</b>.")
	. += span_notice("Нельзя более вносить изменения.")

/obj/item/bitrunning_disk/ability
	desc = "Диск с исходным кодом. Позволяет загрузить способности в виртуальный домен. Повторные способности будут проигнорированы."
	/// The selected ability that this grants
	var/datum/action/granted_action
	/// The list of actions that this can grant
	var/list/datum/action/selectable_actions = list()

/obj/item/bitrunning_disk/ability/attack_self(mob/user, modifiers)
	. = ..()

	if(choice_made)
		return

	var/names = list()
	for(var/datum/action/thing as anything in selectable_actions)
		names += initial(thing.name)

	var/choice = tgui_input_list(user, message = "Выберите способность",  title = "Программа битраннинга", items = names)
	if(isnull(choice) || !user.is_holding(src))
		return

	for(var/datum/action/thing as anything in selectable_actions)
		if(initial(thing.name) == choice)
			granted_action = thing

	if(isnull(granted_action))
		return

	balloon_alert(user, "выбрано")
	playsound(user, 'sound/items/click.ogg', 50, TRUE)
	choice_made = choice

/// Tier 1 programs. Simple, funny, or helpful.
/obj/item/bitrunning_disk/ability/tier1
	name = "Программа битраннинга: базовая"
	selectable_actions = list(
		/datum/action/cooldown/spell/conjure/cheese,
		/datum/action/cooldown/spell/basic_heal,
	)

/// Tier 2 programs. More complex, powerful, or useful.
/obj/item/bitrunning_disk/ability/tier2
	name = "Программа битраннинга: комплексная"
	selectable_actions = list(
		/datum/action/cooldown/spell/pointed/projectile/fireball,
		/datum/action/cooldown/spell/pointed/projectile/lightningbolt,
		/datum/action/cooldown/spell/forcewall,
	)

/// Tier 3 abilities. Very powerful, game breaking.
/obj/item/bitrunning_disk/ability/tier3
	name = "Программа битраннинга: элитная"
	selectable_actions = list(
		/datum/action/cooldown/spell/shapeshift/dragon,
		/datum/action/cooldown/spell/shapeshift/polar_bear,
	)

/obj/item/bitrunning_disk/item
	desc = "Диск с исходным кодом. Позволяет загрузить предметы в виртуальный домен."
	/// The selected item that this grants
	var/obj/granted_item
	/// The list of actions that this can grant
	var/list/obj/selectable_items = list()

/obj/item/bitrunning_disk/item/attack_self(mob/user, modifiers)
	. = ..()

	if(choice_made)
		return

	var/names = list()
	for(var/obj/thing as anything in selectable_items)
		names += initial(thing.name)

	var/choice = tgui_input_list(user, message = "Выберите способность",  title = "Программа битраннинга", items = names)
	if(isnull(choice) || !user.is_holding(src))
		return

	for(var/obj/thing as anything in selectable_items)
		if(initial(thing.name) == choice)
			granted_item = thing

	balloon_alert(user, "selected")
	playsound(user, 'sound/items/click.ogg', 50, TRUE)
	choice_made = choice

/// Tier 1 items. Simple, funny, or helpful.
/obj/item/bitrunning_disk/item/tier1
	name = "Снаряжение битраннинга: простое"
	selectable_items = list(
		/obj/item/pizzabox/infinite,
		/obj/item/gun/medbeam,
		/obj/item/grenade/c4,
	)

/// Tier 2 items. More complex, powerful, or useful.
/obj/item/bitrunning_disk/item/tier2
	name = "Снаряжение битраннинга: комплексное"
	selectable_items = list(
		/obj/item/reagent_containers/hypospray/medipen/survival/luxury,
		/obj/item/gun/ballistic/automatic/pistol,
		/obj/item/clothing/suit/armor/vest,
	)

/// Tier 3 items. Very powerful, game breaking.
/obj/item/bitrunning_disk/item/tier3
	name = "Снаряжение битраннинга: продвинутое"
	selectable_items = list(
		/obj/item/gun/energy/e_gun/nuclear,
		/obj/item/dualsaber/green,
		/obj/item/grenade/syndieminibomb,
	)
