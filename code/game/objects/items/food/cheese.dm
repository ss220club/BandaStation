/**
 * # Abstract cheese class
 *
 * Everything that is a subclass of this counts as cheese for regal rats.
 */
/obj/item/food/cheese
	name = "the concept of cheese"
	desc = "Такого, возможно, не должно существовать."
	tastes = list("cheese" = 1)
	food_reagents = list(/datum/reagent/consumable/nutriment/fat = 3)
	foodtypes = DAIRY
	crafting_complexity = FOOD_COMPLEXITY_1
	/// used to determine how much health rats/regal rats recover when they eat it.
	var/rat_heal = 0

/obj/item/food/cheese/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_RAT_INTERACT, PROC_REF(on_rat_eat))

/obj/item/food/cheese/proc/on_rat_eat(datum/source, mob/living/basic/regal_rat/king)
	SIGNAL_HANDLER

	king.cheese_heal(src, rat_heal, span_green("Вы съедаете [src.declent_ru(ACCUSATIVE)], восстанавливая немного здоровья."))
	return COMPONENT_RAT_INTERACTED

/obj/item/food/cheese/wedge
	name = "cheese wedge"
	desc = "Кусочек восхитительного чеддера. Головка сыра, от которой он был отрезан, не могла далеко уйти."
	icon_state = "cheesewedge"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/fat = 2,
		/datum/reagent/consumable/nutriment/protein = 1,
		/datum/reagent/consumable/nutriment/vitamin = 1,
	)
	w_class = WEIGHT_CLASS_SMALL
	rat_heal = 10
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/cheese/wheel
	name = "cheese wheel"
	desc = "Большая головка восхитительного чеддера."
	icon_state = "cheesewheel"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/fat = 10,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/nutriment/vitamin = 5,
	) //Hard cheeses contain about 25% protein
	w_class = WEIGHT_CLASS_NORMAL
	rat_heal = 35
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/cheese/wheel/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/food_storage)

/obj/item/food/cheese/wheel/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/cheese/wedge, 5, 3 SECONDS, table_required = TRUE, screentip_verb = "Slice")

/obj/item/food/cheese/wheel/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/baked_cheese, rand(20 SECONDS, 25 SECONDS), TRUE, TRUE)

/**
 * Whiffs away cheese that was touched by the chaos entity byond the realm. In layman's terms, deletes the cheese and throws sparks.
 * Used in wizard grand rituals' optional cheesy alternative.
 */
/obj/item/food/cheese/wheel/proc/consume_cheese()
	visible_message(span_revenwarning("...и исчезает в водовороте хаоса!"))
	do_sparks(number = 1, cardinal_only = TRUE, source = get_turf(src))
	qdel(src)

/obj/item/food/cheese/royal
	name = "royal cheese"
	desc = "Взойди на трон. Съешь всю головку сыра. Почувствуй СИЛУ."
	icon_state = "royalcheese"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/fat = 15,
		/datum/reagent/consumable/nutriment/vitamin = 5,
		/datum/reagent/gold = 20,
		/datum/reagent/toxin/mutagen = 5,
	)
	w_class = WEIGHT_CLASS_BULKY
	tastes = list("cheese" = 4, "royalty" = 1)
	rat_heal = 70
	crafting_complexity = FOOD_COMPLEXITY_3

//Curd cheese, a general term which I will now proceed to stretch as thin as the toppings on a supermarket sandwich:
//I'll use it as a substitute for ricotta, cottage cheese and quark, as well as any other non-aged, soft grainy cheese
/obj/item/food/cheese/curd_cheese
	name = "curd cheese"
	desc = "Известный под многими названиями в человеческой кухне, творог полезен для широкого разнообразия блюд."
	icon_state = "curd_cheese"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 3,
		/datum/reagent/consumable/cream = 1,
	)
	tastes = list("cream" = 1, "cheese" = 1)
	w_class = WEIGHT_CLASS_SMALL
	rat_heal = 35
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/cheese/curd_cheese/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/cheese/cheese_curds, rand(15 SECONDS, 20 SECONDS), TRUE, TRUE)

/obj/item/food/cheese/curd_cheese/make_microwaveable()
	AddElement(/datum/element/microwavable, /obj/item/food/cheese/cheese_curds)

/obj/item/food/cheese/cheese_curds
	name = "cheese curds"
	desc = "Не путать с творогом. Вкусны в жареном виде."
	icon_state = "cheese_curds"
	w_class = WEIGHT_CLASS_SMALL
	rat_heal = 35
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/cheese/cheese_curds/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/dryable,  /obj/item/food/cheese/firm_cheese)

/obj/item/food/cheese/firm_cheese
	name = "firm cheese"
	desc = "Твёрдый выдержанный сыр, похожий по текстуре на твёрдый тофу. Из-за отсутствия влаги он особенно полезен для готовки, так как не плавится легко."
	icon_state = "firm_cheese"
	tastes = list("aged cheese" = 1)
	w_class = WEIGHT_CLASS_SMALL
	rat_heal = 35
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/cheese/firm_cheese/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/cheese/firm_cheese_slice, 3, 3 SECONDS, screentip_verb = "Slice")

/obj/item/food/cheese/firm_cheese_slice
	name = "firm cheese slice"
	desc = "Ломтик твёрдого сыра. Идеально подходит для гриля или приготовления вкусного песто."
	icon_state = "firm_cheese_slice"
	tastes = list("aged cheese" = 1)
	w_class = WEIGHT_CLASS_SMALL
	rat_heal = 10
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/cheese/firm_cheese_slice/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/food/grilled_cheese, rand(25 SECONDS, 35 SECONDS), TRUE, TRUE)

/obj/item/food/cheese/mozzarella
	name = "mozzarella cheese"
	desc = "Восхитительная, кремовая и сырная — всё в одной простой упаковке."
	icon_state = "mozzarella"
	tastes = list("mozzarella" = 1)
	w_class = WEIGHT_CLASS_SMALL
	rat_heal = 10
	crafting_complexity = FOOD_COMPLEXITY_2
