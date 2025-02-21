/datum/heretic_knowledge_tree_column/lock_to_flesh
	neighbour_type_left = /datum/heretic_knowledge_tree_column/main/lock
	neighbour_type_right = /datum/heretic_knowledge_tree_column/main/flesh

	route = PATH_SIDE

	tier1 = /datum/heretic_knowledge/phylactery
	tier2 = /datum/heretic_knowledge/spell/opening_blast
	tier3 = /datum/heretic_knowledge/spell/apetra_vulnera

/**
 * Phylactery of Damnation
 */
/datum/heretic_knowledge/phylactery
	name = "Phylactery of Damnation"
	desc = "Allows you to transmute a sheet of glass and a poppy into a Phylactery that can instantly draw blood, even from long distances. \
		Be warned, your target may still feel a prick."
	gain_text = "A tincture twisted into the shape of a bloodsucker vermin. \
		Whether it chose the shape for itself, or this is the humor of the sickened mind that conjured this vile implement into being is something best not pondered."
	required_atoms = list(
		/obj/item/stack/sheet/glass = 1,
		/obj/item/food/grown/poppy = 1,
	)
	result_atoms = list(/obj/item/reagent_containers/cup/phylactery)
	cost = 1
	research_tree_icon_path = 'icons/obj/antags/eldritch.dmi'
	research_tree_icon_state = "phylactery_2"

// Sidepaths for knowledge between Knock and Flesh.
/datum/heretic_knowledge/spell/opening_blast
	name = "Wave Of Desperation"
	desc = "Дает заклинание Wave Of Desparation, которое можно использовать только связанным. \
		Снимает связки, отталкивает и сбивает с ног находящихся рядом людей, а также накладывает на них некоторые эффекты Хватки Мансуса. \
		Однако, вы потеряете сознание на короткий срок после использования"
	gain_text = "Мои оковы разрываются в темной ярости, их слабые цепи рассыпаются перед моей силой"

	action_to_add = /datum/action/cooldown/spell/aoe/wave_of_desperation
	cost = 1

/datum/heretic_knowledge/spell/apetra_vulnera
	name = "Apetra Vulnera"
	desc = "Дает заклинание Apetra Vulnera, которое \
		вызывает обильное кровотечение из каждой части тела, которое имеет более 15-и ушибов. \
		Накладывает рану на случайную часть тела, если не найдены подходящие части тела."
	gain_text = "Плоть открывается, кровь проливается. Мой хозяин ищет жертвоприношения, и я умиротворю его."

	action_to_add = /datum/action/cooldown/spell/pointed/apetra_vulnera
	cost = 1


