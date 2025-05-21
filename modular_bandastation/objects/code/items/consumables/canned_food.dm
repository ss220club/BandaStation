/obj/item/food/cannedfood
    name = "Can"
    desc = "uhh??"
    food_reagents = list(
        /datum/reagent/oxygen = 6,
        /datum/reagent/nitrogen = 24,
    )
    icon = 'modular_bandastation/objects/icons/obj/items/cannedfood.dmi'
    icon_state = "Expiredcannedfood"
    food_flags = FOOD_IN_CONTAINER
    w_class = WEIGHT_CLASS_SMALL
    max_volume = 30
    preserved_food = TRUE

/obj/item/food/cannedfood/make_germ_sensitive(mapload)
    return // It's in a can

/obj/item/food/cannedfood/proc/open_can(mob/user)
    to_chat(user, span_notice("You pull back the tab of [src]."))
    playsound(user.loc, 'sound/items/foodcanopen.ogg', 50)
    reagents.flags |= OPENCONTAINER
    preserved_food = FALSE

/obj/item/food/cannedfood/attack_self(mob/user)
    if(!is_drainable())
        open_can(user)
        update_icon_state()
    return ..()

/obj/item/food/cannedfood/update_icon_state()
    if(preserved_food == FALSE)
        icon_state = "[icon_state]_open"
    return ..()

/obj/item/food/cannedfood/attack(mob/living/target, mob/user, def_zone)
    if (!is_drainable())
        to_chat(user, span_warning("[src]'s lid hasn't been opened!"))
        return FALSE
    return ..()

/obj/item/food/cannedfood/Expiredcannedfood
    name = "Expired canned food"
    desc = "Консервы КРАЙНЕ сомнительного качества со стёртой этикеткой, вероятней всего уже с гнильцой."
    icon_state = "Expiredcannedfood"
    trash_type = /obj/item/trash/can/Expiredcannedfood
    food_reagents = list(
        /datum/reagent/consumable/nutriment = 1,
        /datum/reagent/consumable/nutriment/protein = 5,
        /datum/reagent/consumable/nutriment/fat = 2,
        /datum/reagent/consumable/mold = 10,
    )
    tastes = list("mold" = 7, "tin" = 1)
    foodtypes = GROSS | MEAT

/obj/item/food/cannedfood/cannedbeef
    name = "canned beef"
    desc = "Самая обычная тушёнка с жирком."
    icon_state = "cannedbeef"
    trash_type = /obj/item/trash/can/cannedbeef
    food_reagents = list(
        /datum/reagent/consumable/nutriment/vitamin = 4,
        /datum/reagent/consumable/nutriment/protein = 6,
        /datum/reagent/consumable/nutriment/fat = 2,
    )
    tastes = list("meat" = 7, "tin" = 1)
    foodtypes = MEAT

/obj/item/food/cannedfood/cannedmushrooms
    name = "canned mushrooms"
    desc = "Консерва с крайне странными грибами неизвестного происхождения. Почему они покрыты зелёной жижой?"
    icon_state = "cannedmushrooms"
    trash_type = /obj/item/trash/can/cannedmushrooms
    food_reagents = list(
        /datum/reagent/consumable/nutriment = 3,
        /datum/reagent/toxin/slimejelly = 10,
    )
    tastes = list("mushrooms" = 4, "tin" = 1, "slime" = 2)
    foodtypes = VEGETABLES | TOXIC

/obj/item/food/cannedfood/condensedmilk
    name = "condensed milk"
    desc = "Банка старой доброй сгушёнки."
    icon_state = "condensedmilk"
    trash_type = /obj/item/trash/can/condensedmilk
    food_reagents = list(
        /datum/reagent/consumable/milk = 15,
        /datum/reagent/consumable/sugar = 10,
        /datum/reagent/consumable/nutriment = 5,
    )
    tastes = list("milk" = 5, "tin" = 1, "sugar" = 2)
    foodtypes = DAIRY | SUGAR

/obj/item/food/cannedfood/cannedpizza
    name = "canned pizza"
    desc = "Буквально целая пицца в консерв... Погодите, это пицца пропущенная через блендер?"
    icon_state = "cannedpizza"
    trash_type = /obj/item/trash/can/cannedpizza
    food_reagents = list(
        /datum/reagent/consumable/nutriment/protein = 10,
        /datum/reagent/consumable/ketchup = 5,
        /datum/reagent/consumable/nutriment/vitamin = 10,
    )
    tastes = list("pizza" = 7, "tin" = 1)
    foodtypes = GRAIN | MEAT | VEGETABLES

/obj/item/food/cannedfood/cannedtuna
    name = "canned tuna"
    desc = "Всеми любимый тунец в жестянке."
    icon_state = "cannedtuna"
    trash_type = /obj/item/trash/can/cannedtuna
    food_reagents = list(
        /datum/reagent/consumable/nutriment/protein = 5,
        /datum/reagent/consumable/nutriment/fat/oil = 2,
    )
    tastes = list("tuna" = 4, "tin" = 1)
    foodtypes = SEAFOOD
