/datum/heretic_knowledge_tree_column/cosmic_to_ash
	neighbour_type_left = /datum/heretic_knowledge_tree_column/main/cosmic
	neighbour_type_right = /datum/heretic_knowledge_tree_column/main/ash

	route = PATH_SIDE

	tier1 = /datum/heretic_knowledge/summon/fire_shark
	tier2 = /datum/heretic_knowledge/spell/space_phase
	tier3 = /datum/heretic_knowledge/eldritch_coin


// Sidepaths for knowledge between Cosmos and Ash.

/datum/heretic_knowledge/summon/fire_shark
	name = "Scorching Shark"
	desc = "Позволяет трансмутировать лужу пепла, печень и лист плазмы в Огненную акулу. \
		Огненные акулы быстры и сильны в группах, но быстро погибают. Они также очень устойчивы к огненным атакам. \
		Огненные акулы впрыскивают флогистон в своих жертв и порождают плазму после своей смерти."
	gain_text = "Колыбель туманности была холодной, но не безжизненной. Свет и тепло проникают даже в самую глубокую тьму, и даже они пища для своих хищников."

	required_atoms = list(
		/obj/effect/decal/cleanable/ash = 1,
		/obj/item/organ/liver = 1,
		/obj/item/stack/sheet/mineral/plasma = 1,
	)
	mob_to_summon = /mob/living/basic/heretic_summon/fire_shark
	cost = 1

	poll_ignore_define = POLL_IGNORE_FIRE_SHARK

	research_tree_icon_dir = EAST

/datum/heretic_knowledge/spell/space_phase
	name = "Space Phase"
	desc = "Дарует вам Space Phase - заклинание, позволяющее свободно перемещаться в космосе. \
		Появляться и исчезать можно только тогда, когда вы находитесь в на космических или схожих тайлах."
	gain_text = "Вы чувствуете, что ваше тело может перемещаться по космосу, как будто вы пылинка."

	action_to_add = /datum/action/cooldown/spell/jaunt/space_crawl
	cost = 1


	research_tree_icon_frame = 6

/datum/heretic_knowledge/eldritch_coin
	name = "Eldritch Coin"
	desc = "Позволяет трансмутировать лист плазмы и алмаз, чтобы создать Мистическую монету. \
		Монета будет открывать или закрывать близлежащие двери, если приземлится на орла, и болтировать или отболтировать их, \
		если приземлится на решку. Если вы вставите монету в дверь, монета будет использована, \
		чтобы спалить электронику, открывая и болтируя дверь навсегда. "
	gain_text = "Мансус это место для всевозможных грехов. Но жадность имела особую роль."

	required_atoms = list(
		/obj/item/stack/sheet/mineral/diamond = 1,
		/obj/item/stack/sheet/mineral/plasma = 1,
	)
	result_atoms = list(/obj/item/coin/eldritch)
	cost = 1

	research_tree_icon_path = 'icons/obj/economy.dmi'
	research_tree_icon_state = "coin_heretic"

