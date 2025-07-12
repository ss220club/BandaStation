/datum/heretic_knowledge_tree_column/flesh_to_void
	neighbour_type_left = /datum/heretic_knowledge_tree_column/main/flesh
	neighbour_type_right = /datum/heretic_knowledge_tree_column/main/void

	route = PATH_SIDE

	tier1 = /datum/heretic_knowledge/void_cloak
	tier2 = /datum/heretic_knowledge/spell/blood_siphon
	tier3 = list(/datum/heretic_knowledge/spell/void_prison, /datum/heretic_knowledge/spell/cleave)

// Sidepaths for knowledge between Flesh and Void.

/datum/heretic_knowledge/void_cloak
	name = "Void Cloak"
	desc = "Позволяет трансмутировать осколок стекла, простыню и любой предмет верхней одежды (например, броню или куртку), \
		чтобы создать Пустотный плащ. Пока капюшон опущен, плащ работает как фокусировка, \
		а когда капюшон поднят, плащ полностью невидим. Он также обеспечивает достойную броню \
		и имеет карманы, в которых можно хранить один из ваших клинков, различные ритуальные компоненты (например, органы) и небольшие еретические безделушки."
	gain_text = "Сова - хранительница вещей, которые на практике не совсем таковы, но в теории таковыми являются. Многие вещи таковыми являются."

	required_atoms = list(
		/obj/item/shard = 1,
		/obj/item/clothing/suit = 1,
		/obj/item/bedsheet = 1,
	)
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/void)
	cost = 1

	research_tree_icon_path = 'icons/obj/clothing/suits/armor.dmi'
	research_tree_icon_state = "void_cloak"

/datum/heretic_knowledge/spell/blood_siphon
	name = "Blood Siphon"
	desc = "Дает вам Blood Siphon, заклинание, которое истощает кровь и здоровье жертвы, передавая их вам. \
		Также имеет шанс передать раны от вас к жертве."
	gain_text = "\"Независимо от человека, кровь у нас течет одинаково.\" Так мне сказал Маршал."

	action_to_add = /datum/action/cooldown/spell/pointed/blood_siphon
	cost = 1

/datum/heretic_knowledge/spell/void_prison
	name = "Void Prison"
	desc = "Grants you Void Prison, a spell that places your victim into ball, making them unable to do anything or speak. \
		Applies void chill afterwards."
	gain_text = "At first, I see myself, waltzing along a snow-laden street. \
		I try to yell, grab hold of this fool and tell them to run. \
		But the only welts made are on my own beating fist. \
		My smiling face turns to regard me, reflecting back in glassy eyes the empty path I have been lead down."

	action_to_add = /datum/action/cooldown/spell/pointed/void_prison
	cost = 1

/datum/heretic_knowledge/spell/cleave
	name = "Blood Cleave"
	desc = "Дает вам Cleave, заклинание с выбором цели с действием по области \
		которое вызывает сильное кровотечение и потерю крови у всех попавших."
	gain_text = "Сначала я не понимал этих инструментов войны, но Жрец \
		сказал мне использовать их независимо от этого. Скоро, сказал он, я буду знать их хорошо."

	action_to_add = /datum/action/cooldown/spell/pointed/cleave
	cost = 1


