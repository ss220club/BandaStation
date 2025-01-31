#define BEAN_CAPACITY 10 //amount of coffee beans that can fit inside the impressa coffeemaker

/obj/machinery/coffeemaker
	name = "coffeemaker"
	desc = "A Modello 3 Coffeemaker that brews coffee and holds it at the perfect temperature of 176 fahrenheit. Made by Piccionaia Home Appliances."
	icon = 'icons/obj/machines/coffeemaker.dmi'
	icon_state = "coffeemaker_nopot_nocart"
	base_icon_state = "coffeemaker"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	circuit = /obj/item/circuitboard/machine/coffeemaker
	anchored_tabletop_offset = 4
	interaction_flags_machine = parent_type::interaction_flags_machine | INTERACT_MACHINE_OFFLINE
	var/obj/item/reagent_containers/cup/coffeepot/coffeepot = null
	var/brewing = FALSE
	var/brew_time = 20 SECONDS
	var/speed = 1
	/// The coffee cartridge to make coffee from. In the future, coffee grounds are like printer ink.
	var/obj/item/coffee_cartridge/cartridge = null
	/// The type path to instantiate for the coffee cartridge the device initially comes with, eg. /obj/item/coffee_cartridge
	var/initial_cartridge = /obj/item/coffee_cartridge
	/// The number of cups left
	var/coffee_cups = 15
	var/max_coffee_cups = 15
	/// The amount of sugar packets left
	var/sugar_packs = 10
	var/max_sugar_packs = 10
	/// The amount of sweetener packets left
	var/sweetener_packs = 10
	var/max_sweetener_packs = 10
	/// The amount of creamer packets left
	var/creamer_packs = 10
	var/max_creamer_packs = 10

	var/static/radial_examine = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_examine")
	var/static/radial_brew = image(icon = 'icons/hud/radial_coffee.dmi', icon_state = "radial_brew")
	var/static/radial_eject_pot = image(icon = 'icons/hud/radial_coffee.dmi', icon_state = "radial_eject_pot")
	var/static/radial_eject_cartridge = image(icon = 'icons/hud/radial_coffee.dmi', icon_state = "radial_eject_cartridge")
	var/static/radial_take_cup = image(icon = 'icons/hud/radial_coffee.dmi', icon_state = "radial_take_cup")
	var/static/radial_take_sugar = image(icon = 'icons/hud/radial_coffee.dmi', icon_state = "radial_take_sugar")
	var/static/radial_take_sweetener = image(icon = 'icons/hud/radial_coffee.dmi', icon_state = "radial_take_sweetener")
	var/static/radial_take_creamer = image(icon = 'icons/hud/radial_coffee.dmi', icon_state = "radial_take_creamer")

/obj/machinery/coffeemaker/Initialize(mapload)
	. = ..()
	if(mapload)
		coffeepot = new /obj/item/reagent_containers/cup/coffeepot(src)
		cartridge = new /obj/item/coffee_cartridge(src)

/obj/machinery/coffeemaker/on_deconstruction(disassembled)
	coffeepot?.forceMove(drop_location())
	cartridge?.forceMove(drop_location())

/obj/machinery/coffeemaker/Destroy()
	QDEL_NULL(coffeepot)
	QDEL_NULL(cartridge)
	remove_shared_particles(/particles/smoke)
	return ..()

/obj/machinery/coffeemaker/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == coffeepot)
		coffeepot = null
		update_appearance(UPDATE_OVERLAYS)
	if(gone == cartridge)
		cartridge = null
		update_appearance(UPDATE_OVERLAYS)

/obj/machinery/coffeemaker/RefreshParts()
	. = ..()
	speed = 0
	for(var/datum/stock_part/micro_laser/laser in component_parts)
		speed += laser.tier

/obj/machinery/coffeemaker/examine(mob/user)
	. = ..()
	if(!in_range(user, src) && !issilicon(user) && !isobserver(user))
		. += span_warning("Вы слишком далеко, чтобы изучить содержимое и дисплей [declent_ru(GENITIVE)]!")
		return

	if(brewing)
		. += span_warning("[capitalize(declent_ru(NOMINATIVE))] варит.")
		return

	if(panel_open)
		. += span_notice("Панель для обслуживания [declent_ru(GENITIVE)] открыта!")
		return

	if(coffeepot || cartridge)
		. += span_notice("[capitalize(declent_ru(NOMINATIVE))] содержит:")
		if(coffeepot)
			. += span_notice("- [coffeepot.declent_ru(ACCUSATIVE)].")
		if(cartridge)
			. += span_notice("- [cartridge.declent_ru(ACCUSATIVE)].")
		return

	if(!(machine_stat & (NOPOWER|BROKEN)))
		. += "[span_notice("На дисплее состояния отображается:")]\n"+\
		span_notice("- Заваривает кофе на <b>[speed*100]%</b>.")
		if(coffeepot)
			for(var/datum/reagent/consumable/cawfee as anything in coffeepot.reagents.reagent_list)
				. += span_notice("- [cawfee.volume] юнитов кофе в кофейнике.")
		if(cartridge)
			if(cartridge.charges < 1)
				. += span_notice("- кофейный картридж пуст.")
			else
				. += span_notice("- порций в кофейном картридже: [cartridge.charges].")

	if (coffee_cups >= 1)
		. += span_notice("[declension_ru(coffee_cups,"Осталась","Остались","Осталось")] [coffee_cups] [declension_ru(coffee_cups,"кофейная чашка","кофейные чашки","кофейных чашек")].")
	else
		. += span_notice("Чашек больше нет.")

	if (sugar_packs >= 1)
		. += span_notice("[declension_ru(sugar_packs,"Осталась","Остались","Осталось")] [sugar_packs] [declension_ru(sugar_packs,"пачка сахара","пачки сахара","пачек сахара")].")
	else
		. += span_notice("Сахара больше нет.")

	if (sweetener_packs >= 1)
		. += span_notice("[declension_ru(sweetener_packs,"Осталась","Остались","Осталось")] [sweetener_packs] [declension_ru(sweetener_packs,"пачка подсластителя","пачки подсластителя","пачек подсластителя")].")
	else
		. += span_notice("Подсластителя больше нет.")

	if (creamer_packs > 1)
		. += span_notice("[declension_ru(creamer_packs,"Осталась","Остались","Осталось")] [creamer_packs] [declension_ru(creamer_packs,"пачка сливок","пачки сливок","пачек сливок")].")
	else
		. += span_notice("Сливок больше нет.")

/obj/machinery/coffeemaker/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(!can_interact(user) || !user.can_perform_action(src, FORBID_TELEKINESIS_REACH|SILENT_ADJACENCY))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(brewing)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	replace_pot(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/coffeemaker/attack_robot_secondary(mob/user, list/modifiers)
	return attack_hand_secondary(user, modifiers)

/obj/machinery/coffeemaker/attack_ai_secondary(mob/user, list/modifiers)
	return attack_hand_secondary(user, modifiers)

/obj/machinery/coffeemaker/update_overlays()
	. = ..()
	. += overlay_checks()

/obj/machinery/coffeemaker/proc/overlay_checks()
	. = list()
	if(coffeepot)
		if(istype(coffeepot, /obj/item/reagent_containers/cup/coffeepot/bluespace))
			. += "coffeemaker_pot_bluespace"
		else
			. += "coffeemaker_pot_[coffeepot.reagents.total_volume ? "full" : "empty"]"
	if(cartridge)
		. += "coffeemaker_cartidge"
	return .

/obj/machinery/coffeemaker/proc/replace_pot(mob/living/user, obj/item/reagent_containers/cup/coffeepot/new_coffeepot)
	if(!user)
		return FALSE
	if(coffeepot)
		try_put_in_hand(coffeepot, user)
	if(new_coffeepot)
		coffeepot = new_coffeepot
	balloon_alert(user, "кофейник заменен")
	update_appearance(UPDATE_OVERLAYS)
	return TRUE

/obj/machinery/coffeemaker/proc/replace_cartridge(mob/living/user, obj/item/coffee_cartridge/new_cartridge)
	if(!user)
		return FALSE
	if(cartridge)
		try_put_in_hand(cartridge, user)
	if(new_cartridge)
		cartridge = new_cartridge
	update_appearance(UPDATE_OVERLAYS)
	return TRUE

/obj/machinery/coffeemaker/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/coffeemaker/attackby(obj/item/attack_item, mob/living/user, params)
	//You can only screw open empty grinder
	if(!coffeepot && default_deconstruction_screwdriver(user, icon_state, icon_state, attack_item))
		return FALSE

	if(default_deconstruction_crowbar(attack_item))
		return

	if(panel_open) //Can't insert objects when its screwed open
		return TRUE

	if (istype(attack_item, /obj/item/reagent_containers/cup/coffeepot) && !(attack_item.item_flags & ABSTRACT) && attack_item.is_open_container())
		var/obj/item/reagent_containers/cup/coffeepot/new_pot = attack_item
		. = TRUE //no afterattack
		if(!user.transferItemToLoc(new_pot, src))
			return TRUE
		replace_pot(user, new_pot)
		update_appearance(UPDATE_OVERLAYS)
		return TRUE //no afterattack

	if (istype(attack_item, /obj/item/reagent_containers/cup/glass/coffee_cup) && !(attack_item.item_flags & ABSTRACT) && attack_item.is_open_container())
		var/obj/item/reagent_containers/cup/glass/coffee_cup/new_cup = attack_item
		if(new_cup.reagents.total_volume > 0)
			balloon_alert(user, "чашка должна быть пустой!")
			return
		if(coffee_cups >= max_coffee_cups)
			balloon_alert(user, "отделение для чашек заполнено!")
			return
		if(!user.transferItemToLoc(attack_item, src))
			return
		coffee_cups++
		update_appearance(UPDATE_OVERLAYS)
		return TRUE //no afterattack

	if (istype(attack_item, /obj/item/reagent_containers/condiment/pack/sugar))
		var/obj/item/reagent_containers/condiment/pack/sugar/new_pack = attack_item
		if(new_pack.reagents.total_volume < new_pack.reagents.maximum_volume)
			balloon_alert(user, "пачка должна быть полной!")
			return
		if(sugar_packs >= max_sugar_packs)
			balloon_alert(user, "отделение для сахара заполнено!")
			return
		if(!user.transferItemToLoc(attack_item, src))
			return
		sugar_packs++
		update_appearance(UPDATE_OVERLAYS)
		return TRUE //no afterattack

	if (istype(attack_item, /obj/item/reagent_containers/condiment/creamer))
		var/obj/item/reagent_containers/condiment/creamer/new_pack = attack_item
		if(new_pack.reagents.total_volume < new_pack.reagents.maximum_volume)
			balloon_alert(user, "пачка должна быть полной!")
			return
		if(creamer_packs >= max_creamer_packs)
			balloon_alert(user, "отделение для сливок заполнено!")
			return
		if(!user.transferItemToLoc(attack_item, src))
			return
		creamer_packs++
		update_appearance(UPDATE_OVERLAYS)
		return TRUE //no afterattack

	if (istype(attack_item, /obj/item/reagent_containers/condiment/pack/astrotame))
		var/obj/item/reagent_containers/condiment/pack/astrotame/new_pack = attack_item
		if(new_pack.reagents.total_volume < new_pack.reagents.maximum_volume)
			balloon_alert(user, "пачка должна быть полной!")
			return
		else if(sweetener_packs >= max_sweetener_packs)
			balloon_alert(user, "отделение для подсластителя заполнено!")
			return
		else if(!user.transferItemToLoc(attack_item, src))
			return
		sweetener_packs++
		update_appearance(UPDATE_OVERLAYS)
		return TRUE //no afterattack

	if (istype(attack_item, /obj/item/coffee_cartridge) && !(attack_item.item_flags & ABSTRACT))
		var/obj/item/coffee_cartridge/new_cartridge = attack_item
		if(!user.transferItemToLoc(new_cartridge, src))
			return
		replace_cartridge(user, new_cartridge)
		balloon_alert(user, "картридж вставлен")
		update_appearance(UPDATE_OVERLAYS)
		return TRUE //no afterattack

/obj/machinery/coffeemaker/proc/try_brew()
	if(!cartridge)
		balloon_alert(usr, "не вставлен картридж для кофе!")
		return FALSE
	if(cartridge.charges < 1)
		balloon_alert(usr, "кофейный картридж пуст!")
		return FALSE
	if(!coffeepot)
		balloon_alert(usr, "нет кофейника внутри!")
		return FALSE
	if(machine_stat & (NOPOWER|BROKEN))
		balloon_alert(usr, "кофеварка обесточена!")
		return FALSE
	if(coffeepot.reagents.total_volume >= coffeepot.reagents.maximum_volume)
		balloon_alert(usr, "кофейник уже полон!")
		return FALSE
	return TRUE

/obj/machinery/coffeemaker/ui_interact(mob/user) // The microwave Menu //I am reasonably certain that this is not a microwave //I am positively certain that this is not a microwave
	. = ..()

	if(brewing || !user.can_perform_action(src, SILENT_ADJACENCY))
		return

	var/list/options = list()

	if(coffeepot)
		options["Eject Pot"] = radial_eject_pot

	if(cartridge)
		options["Eject Cartridge"] = radial_eject_cartridge

	options["Brew"] = radial_brew //brew is always available as an option, when the machine is unable to brew the player is told by balloon alerts whats exactly wrong

	if(coffee_cups > 0)
		options["Take Cup"] = radial_take_cup

	if(sugar_packs > 0)
		options["Take Sugar"] = radial_take_sugar

	if(sweetener_packs > 0)
		options["Take Sweetener"] = radial_take_sweetener

	if(creamer_packs > 0)
		options["Take Creamer"] = radial_take_creamer

	if(isAI(user))
		if(machine_stat & NOPOWER)
			return
		options["Examine"] = radial_examine

	var/choice

	if(length(options) < 1)
		return
	if(length(options) == 1)
		choice = options[1]
	else
		choice = show_radial_menu(user, src, options, require_near = !HAS_SILICON_ACCESS(user))

	// post choice verification
	if(brewing || (isAI(user) && machine_stat & NOPOWER) || !user.can_perform_action(src, SILENT_ADJACENCY))
		return

	switch(choice)
		if("Brew")
			brew(user)
		if("Eject Pot")
			eject_pot(user)
		if("Eject Cartridge")
			eject_cartridge(user)
		if("Examine")
			examine(user)
		if("Take Cup")
			take_cup(user)
		if("Take Sugar")
			take_sugar(user)
		if("Take Sweetener")
			take_sweetener(user)
		if("Take Creamer")
			take_creamer(user)

/obj/machinery/coffeemaker/proc/eject_pot(mob/user)
	if(coffeepot)
		replace_pot(user)

/obj/machinery/coffeemaker/proc/eject_cartridge(mob/user)
	if(cartridge)
		replace_cartridge(user)

/obj/machinery/coffeemaker/proc/take_cup(mob/user)
	if(!coffee_cups) //shouldn't happen, but we all know how stuff manages to break
		balloon_alert(user, "нет чашек!")
		return
	var/obj/item/reagent_containers/cup/glass/coffee_cup/new_cup = new(get_turf(src))
	user.put_in_hands(new_cup)
	coffee_cups--
	update_appearance(UPDATE_OVERLAYS)

/obj/machinery/coffeemaker/proc/take_sugar(mob/user)
	if(!sugar_packs)
		balloon_alert(user, "сахар закончился!")
		return
	var/obj/item/reagent_containers/condiment/pack/sugar/new_pack = new(get_turf(src))
	user.put_in_hands(new_pack)
	sugar_packs--
	update_appearance(UPDATE_OVERLAYS)

/obj/machinery/coffeemaker/proc/take_sweetener(mob/user)
	if(!sweetener_packs)
		balloon_alert(user, "подсластитель закончился!")
		return
	var/obj/item/reagent_containers/condiment/pack/astrotame/new_pack = new(get_turf(src))
	user.put_in_hands(new_pack)
	sweetener_packs--
	update_appearance(UPDATE_OVERLAYS)

/obj/machinery/coffeemaker/proc/take_creamer(mob/user)
	if(!creamer_packs)
		balloon_alert(user, "сливки закончились!")
		return
	var/obj/item/reagent_containers/condiment/creamer/new_pack = new(drop_location())
	user.put_in_hands(new_pack)
	creamer_packs--
	update_appearance(UPDATE_OVERLAYS)

///Updates the smoke state to something else, setting particles if relevant
/obj/machinery/coffeemaker/proc/toggle_steam()
	if(!brewing)
		remove_shared_particles("smoke_coffeemaker")
		return

	var/obj/effect/abstract/shared_particle_holder/smoke_particles = add_shared_particles(/particles/smoke/steam/mild, "smoke_coffeemaker")
	smoke_particles.particles.position = list(-6, 0, 0)

/obj/machinery/coffeemaker/proc/operate_for(time, silent = FALSE)
	brewing = TRUE
	if(!silent)
		playsound(src, 'sound/machines/coffeemaker_brew.ogg', 20, vary = TRUE)
	toggle_steam()
	use_energy(active_power_usage * time / (1 SECONDS)) // .1 needed here to convert time (in deciseconds) to seconds such that watts * seconds = joules
	addtimer(CALLBACK(src, PROC_REF(stop_operating)), time / speed)

/obj/machinery/coffeemaker/proc/stop_operating()
	brewing = FALSE
	toggle_steam()

/obj/machinery/coffeemaker/proc/brew()
	power_change()
	if(!try_brew())
		return
	operate_for(brew_time)
	coffeepot.reagents.add_reagent_list(cartridge.drink_type)
	cartridge.charges--
	update_appearance(UPDATE_OVERLAYS)

//Coffee Cartridges: like toner, but for your coffee!
/obj/item/coffee_cartridge
	name = "coffeemaker cartridge- Caffè Generico"
	desc = "Кофейный картридж производства Piccionaia Coffee, предназначенный для использования с системой Modello 3."
	icon = 'icons/obj/food/cartridges.dmi'
	icon_state = "cartridge_basic"
	var/charges = 4
	var/list/drink_type = list(/datum/reagent/consumable/coffee = 120)

/obj/item/coffee_cartridge/examine(mob/user)
	. = ..()
	if(charges)
		. += span_warning("Осталось порций в картридже: [charges].")
	else
		. += span_warning("В картридже ничего не осталось")

/obj/item/coffee_cartridge/fancy
	name = "coffeemaker cartridge - Caffè Fantasioso"
	desc = "Изысканный кофейный картридж производства Piccionaia Coffee, предназначенный для использования с системой Modello 3."
	icon_state = "cartridge_blend"

//Here's the joke before I get 50 issue reports: they're all the same, and that's intentional
/obj/item/coffee_cartridge/fancy/Initialize(mapload)
	. = ..()
	var/coffee_type = pick("blend", "blue_mountain", "kilimanjaro", "mocha")
	switch(coffee_type)
		if("blend")
			name = "coffeemaker cartridge - Miscela di Piccione"
			icon_state = "cartridge_blend"
		if("blue_mountain")
			name = "coffeemaker cartridge - Montagna Blu"
			icon_state = "cartridge_blue_mtn"
		if("kilimanjaro")
			name = "coffeemaker cartridge - Kilimangiaro"
			icon_state = "cartridge_kilimanjaro"
		if("mocha")
			name = "coffeemaker cartridge - Moka Arabica"
			icon_state = "cartridge_mocha"

/obj/item/coffee_cartridge/decaf
	name = "coffeemaker cartridge - Caffè Decaffeinato"
	desc = "Картридж для кофе без кофеина, произведенный компанией Piccionaia Coffee, предназначенный для использования с системой Modello 3."
	icon_state = "cartridge_decaf"

// no you can't just squeeze the juice bag into a glass!
/obj/item/coffee_cartridge/bootleg
	name = "coffeemaker cartridge - Botany Blend"
	desc = "Картридж для приготовления кофе. Должен работать с системой Modello 3, хотя это может привести к потере гарантии."
	icon_state = "cartridge_bootleg"

// blank cartridge for crafting's sake, can be made at the service lathe
/obj/item/blank_coffee_cartridge
	name = "blank coffee cartridge"
	desc = "Пустой кофейный картридж, готовый к заполнению кофейным помолом."
	icon = 'icons/obj/food/cartridges.dmi'
	icon_state = "cartridge_blank"

//now, how do you store coffee carts? well, in a rack, of course!
/obj/item/storage/fancy/coffee_cart_rack
	name = "coffeemaker cartridge rack"
	desc = "Небольшая подставка для хранения картриджей кофемашины."
	icon = 'icons/obj/food/containers.dmi'
	icon_state = "coffee_cartrack4"
	base_icon_state = "coffee_cartrack"
	contents_tag = "coffee cartridge"
	open_status = FANCY_CONTAINER_ALWAYS_OPEN
	spawn_type = /obj/item/coffee_cartridge
	spawn_count = 1

/obj/item/storage/fancy/coffee_cart_rack/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 4
	atom_storage.set_holdable(/obj/item/coffee_cartridge)

/*
 * impressa coffee maker
 * its supposed to be a premium line product, so its cargo-only, the board cant be therefore researched
 */

/obj/machinery/coffeemaker/impressa
	name = "impressa coffeemaker"
	desc = "An industry-grade Impressa Modello 5 Coffeemaker of the Piccionaia Home Appliances premium coffeemakers product line. Makes coffee from fresh dried whole beans."
	icon_state = "coffeemaker_impressa"
	circuit = /obj/item/circuitboard/machine/coffeemaker/impressa
	initial_cartridge = null //no cartridge, just coffee beans
	brew_time = 15 SECONDS //industrial grade, its faster than the regular one
	density = TRUE
	pass_flags = PASSTABLE
	/// Current amount of coffee beans stored
	var/coffee_amount = 0
	/// List of coffee bean objects are stored
	var/list/coffee = list()

/obj/machinery/coffeemaker/impressa/Initialize(mapload)
	. = ..()
	if(mapload)
		coffeepot = new /obj/item/reagent_containers/cup/coffeepot(src)
		cartridge = null

/obj/machinery/coffeemaker/impressa/Destroy()
	QDEL_NULL(coffeepot)
	QDEL_NULL(coffee)
	return ..()

/obj/machinery/coffeemaker/impressa/examine(mob/user)
	. = ..()
	if(coffee)
		. += span_notice("Внутренняя кофемолка содержит [coffee.len] [declension_ru(coffee.len,"порцию","порции","порций")] кофейных зерен")

/obj/machinery/coffeemaker/impressa/update_overlays()
	. = ..()
	. += overlay_checks()

/obj/machinery/coffeemaker/impressa/overlay_checks()
	. = list()
	if(coffeepot)
		if(istype(coffeepot, /obj/item/reagent_containers/cup/coffeepot/bluespace))
			. += "pot_bluespace"
		else
			. += "pot_[coffeepot.reagents.total_volume ? "full" : "empty"]"
	if(coffee_cups > 0)
		if(coffee_cups >= max_coffee_cups/3)
			if(coffee_cups > max_coffee_cups/1.5)
				. += "cups_3"
			else
				. += "cups_2"
		else
			. += "cups_1"
	if(sugar_packs)
		. += "extras_1"
	if(creamer_packs)
		. += "extras_2"
	if(sweetener_packs)
		. += "extras_3"
	if(coffee_amount)
		if(coffee_amount < 0.7*BEAN_CAPACITY)
			. += "grinder_half"
		else
			. += "grinder_full"
	return .

/obj/machinery/coffeemaker/impressa/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone in coffee)
		coffee -= gone
		update_appearance(UPDATE_OVERLAYS)

/obj/machinery/coffeemaker/impressa/try_brew()
	if(coffee_amount <= 0)
		balloon_alert_to_viewers("нет кофейных зерен!")
		return FALSE
	if(!coffeepot)
		balloon_alert_to_viewers("нет [coffeepot.declent_ru(GENITIVE)] внутри!")
		return FALSE
	if(machine_stat & (NOPOWER|BROKEN) )
		balloon_alert_to_viewers("[declent_ru(NOMINATIVE)] без питания!")
		return FALSE
	if(coffeepot.reagents.total_volume >= coffeepot.reagents.maximum_volume)
		balloon_alert_to_viewers("[coffeepot.declent_ru(NOMINATIVE)] уже полон!")
		return FALSE
	return TRUE

/obj/machinery/coffeemaker/impressa/attackby(obj/item/attack_item, mob/living/user, params)
	//You can only screw open empty grinder
	if(!coffeepot && default_deconstruction_screwdriver(user, icon_state, icon_state, attack_item))
		return

	if(default_deconstruction_crowbar(attack_item))
		return

	if(panel_open) //Can't insert objects when its screwed open
		return TRUE

	if (istype(attack_item, /obj/item/reagent_containers/cup/coffeepot) && !(attack_item.item_flags & ABSTRACT) && attack_item.is_open_container())
		var/obj/item/reagent_containers/cup/coffeepot/new_pot = attack_item
		if(!user.transferItemToLoc(new_pot, src))
			return TRUE
		replace_pot(user, new_pot)
		update_appearance(UPDATE_OVERLAYS)
		return TRUE //no afterattack

	if (istype(attack_item, /obj/item/reagent_containers/cup/glass/coffee) && !(attack_item.item_flags & ABSTRACT) && attack_item.is_open_container())
		var/obj/item/reagent_containers/cup/glass/coffee/new_cup = attack_item //different type of cup
		if(new_cup.reagents.total_volume > 0 )
			balloon_alert(user, "чашка должна быть пуста!")
			return
		if(coffee_cups >= max_coffee_cups)
			balloon_alert(user, "чашка полная!")
			return
		if(!user.transferItemToLoc(attack_item, src))
			return
		coffee_cups++
		update_appearance(UPDATE_OVERLAYS)
		return TRUE //no afterattack

	if (istype(attack_item, /obj/item/reagent_containers/condiment/pack/sugar))
		var/obj/item/reagent_containers/condiment/pack/sugar/new_pack = attack_item
		if(new_pack.reagents.total_volume < new_pack.reagents.maximum_volume)
			balloon_alert(user, "пачка должна быть полной!")
			return
		if(sugar_packs >= max_sugar_packs)
			balloon_alert(user, "отделение для сахара заполнено!")
			return
		if(!user.transferItemToLoc(attack_item, src))
			return
		sugar_packs++
		update_appearance(UPDATE_OVERLAYS)
		return TRUE //no afterattack

	if (istype(attack_item, /obj/item/reagent_containers/condiment/creamer))
		var/obj/item/reagent_containers/condiment/creamer/new_pack = attack_item
		if(new_pack.reagents.total_volume < new_pack.reagents.maximum_volume)
			balloon_alert(user, "пачка должна быть полной!")
			return
		if(creamer_packs >= max_creamer_packs)
			balloon_alert(user, "отделение для сливок заполнено!")
			return
		if(!user.transferItemToLoc(attack_item, src))
			return
		creamer_packs++
		update_appearance(UPDATE_OVERLAYS)
		return TRUE //no afterattack

	if (istype(attack_item, /obj/item/reagent_containers/condiment/pack/astrotame))
		var/obj/item/reagent_containers/condiment/pack/astrotame/new_pack = attack_item
		if(new_pack.reagents.total_volume < new_pack.reagents.maximum_volume)
			balloon_alert(user, "пачка должна быть полной!")
			return
		if(sweetener_packs >= max_sweetener_packs)
			balloon_alert(user, "отделение для подсластителя заполнено!")
			return
		if(!user.transferItemToLoc(attack_item, src))
			return
		sweetener_packs++
		update_appearance(UPDATE_OVERLAYS)
		return TRUE //no afterattack

	if (istype(attack_item, /obj/item/food/grown/coffee) && !(attack_item.item_flags & ABSTRACT))
		if(coffee_amount >= BEAN_CAPACITY)
			balloon_alert(user, "емкость для кофе заполнена!")
			return
		if(!HAS_TRAIT(attack_item, TRAIT_DRIED))
			balloon_alert(user, "кофейные зерна должны быть сухими!")
			return
		var/obj/item/food/grown/coffee/new_coffee = attack_item
		if(!user.transferItemToLoc(new_coffee, src))
			return
		coffee += new_coffee
		coffee_amount++
		balloon_alert(user, "добавлено кофе")


	if (istype(attack_item, /obj/item/storage/box/coffeepack))
		if(coffee_amount >= BEAN_CAPACITY)
			balloon_alert(user, "емкость для кофе заполнена!")
			return
		var/obj/item/storage/box/coffeepack/new_coffee_pack = attack_item
		for(var/obj/item/food/grown/coffee/new_coffee in new_coffee_pack.contents)
			if(HAS_TRAIT(new_coffee, TRAIT_DRIED)) //the coffee beans inside must be dry
				if(coffee_amount < BEAN_CAPACITY)
					if(user.transferItemToLoc(new_coffee, src))
						coffee += new_coffee
						coffee_amount++
						new_coffee.forceMove(src)
						balloon_alert(user, "добавлено кофе")
						update_appearance(UPDATE_OVERLAYS)
					else
						return
				else
					return
			else
				balloon_alert(user, "не высушенные зерна в упаковке с кофе!")
				return

	update_appearance(UPDATE_OVERLAYS)
	return TRUE //no afterattack

/obj/machinery/coffeemaker/impressa/take_cup(mob/user)
	if(!coffee_cups) //shouldn't happen, but we all know how stuff manages to break
		balloon_alert(user, "чашек не осталось!")
		return
	balloon_alert_to_viewers("чашка взята!")
	var/obj/item/reagent_containers/cup/glass/coffee/no_lid/new_cup = new(get_turf(src))
	user.put_in_hands(new_cup)
	coffee_cups--
	update_appearance(UPDATE_OVERLAYS)

/obj/machinery/coffeemaker/impressa/toggle_steam()
	if(!brewing)
		remove_shared_particles("smoke_impressa")
		return

	var/obj/effect/abstract/shared_particle_holder/smoke_particles = add_shared_particles(/particles/smoke/steam/mild, "smoke_impressa")
	smoke_particles.particles.position = list(-2, 1, 0)

/obj/machinery/coffeemaker/impressa/brew()
	power_change()
	if(!try_brew())
		return
	operate_for(brew_time)

	// create a reference bean reagent list
	var/list/reference_bean_reagents = list()
	var/obj/item/food/grown/coffee/reference_bean = new /obj/item/food/grown/coffee(src)
	for(var/datum/reagent/ref_bean_reagent as anything in reference_bean.reagents.reagent_list)
		reference_bean_reagents += ref_bean_reagent.name

	// add all the reagents from the coffee beans to the coffeepot (ommit the ones from the reference bean)
	var/list/reagent_delta = list()
	var/obj/item/food/grown/coffee/bean = coffee[coffee_amount]
	for(var/datum/reagent/substance as anything in bean.reagents.reagent_list)
		if(!(reference_bean_reagents.Find(substance.name)))	// we only add the reagent if it's a non-standard for coffee beans
			reagent_delta += list(substance.type = substance.volume)
	coffeepot.reagents.add_reagent_list(reagent_delta)

	qdel(reference_bean)

	// remove the coffee beans from the machine
	coffee.Cut(1,2)
	coffee_amount--

	// fill the rest of the pot with coffee
	if(coffeepot.reagents.total_volume < 120)
		var/extra_coffee_amount = 120 - coffeepot.reagents.total_volume
		coffeepot.reagents.add_reagent(/datum/reagent/consumable/coffee, extra_coffee_amount)

	update_appearance(UPDATE_OVERLAYS)

#undef BEAN_CAPACITY
