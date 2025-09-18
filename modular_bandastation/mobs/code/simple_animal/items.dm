/obj/item/food/meat/slab/dog
	name = "dog meat"
	desc = "Не слишком питательно, Но говорят деликатес для космокорейцев."
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 2,
		/datum/reagent/consumable/nutriment/epinephrine = 2
	)
	foodtypes = RAW | MEAT | GORE
	tastes = list("meat" = 1)

/obj/item/food/meat/slab/pug
	name = "pug meat"
	desc = "Чуть менее очарователен в нарезке."
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 2,
		/datum/reagent/consumable/nutriment/epinephrine = 2
	)
	foodtypes = RAW | MEAT | GORE
	tastes = list("meat" = 1)

/obj/item/food/meat/slab/security
	name = "security meat"
	desc = "Мясо наполненное чувством мужества и долга."
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 3,
		/datum/reagent/consumable/nutriment/epinephrine = 5
	)
	foodtypes = RAW | MEAT
	tastes = list("meat" = 1)

/obj/item/food/meat/slab/mouse
	name = "мышатина"
	desc = "На безрыбье и мышь мясо. Кто знает чем питался этот грызун до его подачи к столу."
	icon = 'modular_bandastation/mobs/icons/items.dmi'
	icon_state = "meat_clear"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/nutriment = 2,
		/datum/reagent/consumable/blood = 3,
		/datum/reagent/toxin = 1
	)
	foodtypes = RAW | MEAT | GORE
	tastes = list("meat" = 1)
