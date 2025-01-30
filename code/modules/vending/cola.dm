
/obj/machinery/vending/cola
	name = "\improper Robust Softdrinks"
	desc = "A soft drinks vendor provided by Robust Industries, LLC."
	icon_state = "Cola_Machine"
	panel_type = "panel2"
	product_slogans = "Робаст Софтдринкс: крепче, чем тулбоксом по голове!"
	product_ads = "Освежает!;Надеюсь, вас одолела жажда!;Продано больше миллиона бутылок!;Хотите пить? Почему бы не взять колы?;Пей на здоровье!;Освежись!;Лучшие напитки в космосе."
	products = list(
		/obj/item/reagent_containers/cup/soda_cans/cola = 10,
		/obj/item/reagent_containers/cup/soda_cans/space_mountain_wind = 10,
		/obj/item/reagent_containers/cup/soda_cans/dr_gibb = 10,
		/obj/item/reagent_containers/cup/soda_cans/starkist = 10,
		/obj/item/reagent_containers/cup/soda_cans/space_up = 10,
		/obj/item/reagent_containers/cup/soda_cans/pwr_game = 10,
		/obj/item/reagent_containers/cup/soda_cans/lemon_lime = 10,
		/obj/item/reagent_containers/cup/soda_cans/sol_dry = 10,
		/obj/item/reagent_containers/cup/glass/waterbottle = 10,
		/obj/item/reagent_containers/cup/glass/bottle/mushi_kombucha = 3,
		/obj/item/reagent_containers/cup/soda_cans/volt_energy = 3,
	)
	contraband = list(
		/obj/item/reagent_containers/cup/soda_cans/thirteenloko = 6,
		/obj/item/reagent_containers/cup/soda_cans/shamblers = 6,
		/obj/item/reagent_containers/cup/soda_cans/wellcheers = 6,
	)
	premium = list(
		/obj/item/reagent_containers/cup/glass/drinkingglass/filled/nuka_cola = 1,
		/obj/item/reagent_containers/cup/soda_cans/air = 1,
		/obj/item/reagent_containers/cup/soda_cans/monkey_energy = 1,
		/obj/item/reagent_containers/cup/soda_cans/grey_bull = 1,
		/obj/item/reagent_containers/cup/glass/bottle/rootbeer = 1,
	)
	refill_canister = /obj/item/vending_refill/cola
	default_price = PAYCHECK_CREW * 0.7
	extra_price = PAYCHECK_CREW
	payment_department = ACCOUNT_SRV

	var/static/list/spiking_booze = list(
		// Your "common" spiking booze
		/datum/reagent/consumable/ethanol/vodka = 5,
		/datum/reagent/consumable/ethanol/beer = 5,
		/datum/reagent/consumable/ethanol/whiskey = 5,
		/datum/reagent/consumable/ethanol/gin = 5,
		/datum/reagent/consumable/ethanol/rum = 5,
		// A bit rarer, can be dangerous if you take too much
		/datum/reagent/consumable/ethanol/thirteenloko = 3,
		/datum/reagent/consumable/ethanol/absinthe = 3,
		/datum/reagent/consumable/ethanol/hooch = 3,
		/datum/reagent/consumable/ethanol/moonshine = 3,
		// Gets funky here
		/datum/reagent/consumable/ethanol/beepsky_smash = 1,
		/datum/reagent/consumable/ethanol/gargle_blaster = 1,
		/datum/reagent/consumable/ethanol/neurotoxin = 1,
		)

/obj/machinery/vending/cola/on_dispense(obj/item/vended_item)
	// 35% chance that your drink will be safe, as safe pure acid and sugar that these drinks probably are can be
	if(!onstation || !HAS_TRAIT(SSstation, STATION_TRAIT_SPIKED_DRINKS) || !prob(65))
		return
	// Don't fill booze with more booze
	if (isnull(vended_item.reagents) || vended_item.reagents.has_reagent(/datum/reagent/consumable/ethanol, check_subtypes = TRUE))
		return
	var/removed_volume = vended_item.reagents.remove_all(rand(5, vended_item.reagents.maximum_volume * 0.5))
	if (!removed_volume)
		return
	// Don't want bubbling sodas when we add some rum to cola
	ADD_TRAIT(vended_item, TRAIT_SILENT_REACTIONS, VENDING_MACHINE_TRAIT)
	vended_item.reagents.add_reagent(pick_weight(spiking_booze), removed_volume)
	vended_item.reagents.handle_reactions()
	REMOVE_TRAIT(vended_item, TRAIT_SILENT_REACTIONS, VENDING_MACHINE_TRAIT)

/obj/item/vending_refill/cola
	machine_name = "Robust Softdrinks"
	icon_state = "refill_cola"

/obj/machinery/vending/cola/blue
	icon_state = "Cola_Machine"
	light_mask = "cola-light-mask"
	light_color = COLOR_MODERATE_BLUE

/obj/machinery/vending/cola/black
	icon_state = "cola_black"
	light_mask = "cola-light-mask"

/obj/machinery/vending/cola/red
	icon_state = "red_cola"
	name = "\improper Space Cola Vendor"
	desc = "It vends cola, in space."
	product_slogans = "Кола в космосе!"
	light_mask = "red_cola-light-mask"
	light_color = COLOR_DARK_RED

/obj/machinery/vending/cola/space_up
	icon_state = "space_up"
	name = "\improper Space-up! Vendor"
	desc = "Indulge in an explosion of flavor."
	product_slogans = "Спейс-ап! Как пробоина корпуса во рту."
	light_mask = "space_up-light-mask"
	light_color = COLOR_DARK_MODERATE_LIME_GREEN

/obj/machinery/vending/cola/starkist
	icon_state = "starkist"
	name = "\improper Star-kist Vendor"
	desc = "The taste of a star in liquid form."
	product_slogans = "Выпей звёзды! Стар-кист!"
	panel_type = "panel7"
	light_mask = "starkist-light-mask"
	light_color = COLOR_LIGHT_ORANGE

/obj/machinery/vending/cola/sodie
	icon_state = "soda"
	panel_type = "panel7"
	light_mask = "soda-light-mask"
	light_color = COLOR_WHITE

/obj/machinery/vending/cola/pwr_game
	icon_state = "pwr_game"
	name = "\improper Pwr Game Vendor"
	desc = "You want it, we got it. Brought to you in partnership with Vlad's Salads."
	product_slogans = "СИЛА, которую жаждут геймеры! ПАВЭР ГЕЙМ!"
	light_mask = "pwr_game-light-mask"
	light_color = COLOR_STRONG_VIOLET

/obj/machinery/vending/cola/shamblers
	name = "\improper Shambler's Vendor"
	desc = "~Shake me up some of that Shambler's Juice!~"
	icon_state = "shamblers_juice"
	products = list(
		/obj/item/reagent_containers/cup/soda_cans/cola = 10,
		/obj/item/reagent_containers/cup/soda_cans/space_mountain_wind = 10,
		/obj/item/reagent_containers/cup/soda_cans/dr_gibb = 10,
		/obj/item/reagent_containers/cup/soda_cans/starkist = 10,
		/obj/item/reagent_containers/cup/soda_cans/space_up = 10,
		/obj/item/reagent_containers/cup/soda_cans/pwr_game = 10,
		/obj/item/reagent_containers/cup/soda_cans/lemon_lime = 10,
		/obj/item/reagent_containers/cup/soda_cans/sol_dry = 10,
		/obj/item/reagent_containers/cup/soda_cans/shamblers = 10,
		/obj/item/reagent_containers/cup/soda_cans/wellcheers = 5,
		)
	product_slogans = "~Встряхни мне немного сока Шамблера!~"
	product_ads = "Освежает!;Жажда ДНК? Утолите свою жажду!;Выпито более триллиона душ!;Сделано с использованием настоящей ДНК!;Коллективный разум требует вашей жажды!;Пей на здоровье!;Поглотите свою жажду."
	light_mask = "shamblers-light-mask"
	light_color = COLOR_MOSTLY_PURE_PINK

/obj/machinery/vending/cola/shamblers/Initialize(mapload)
	. = ..()
	set_active_language(get_random_spoken_language())

/obj/machinery/vending/cola/shamblers/speak(message)
	. = ..()
	set_active_language(get_random_spoken_language())
