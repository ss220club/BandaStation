/datum/heretic_knowledge_tree_column/lock_to_flesh
	neighbour_type_left = /datum/heretic_knowledge_tree_column/main/lock
	neighbour_type_right = /datum/heretic_knowledge_tree_column/main/flesh

	route = PATH_SIDE

	tier1 = /datum/heretic_knowledge/dummy_lock_to_flesh
	tier2 = /datum/heretic_knowledge/spell/opening_blast
	tier3 = /datum/heretic_knowledge/spell/apetra_vulnera

/datum/heretic_knowledge/dummy_lock_to_flesh
	name = "Flesh and Lock ways"
	desc = "Research this to gain access to the other path"
	gain_text = "There are ways from feasting to wounding, the power of birth is close to the power of opening."
	cost = 1

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


