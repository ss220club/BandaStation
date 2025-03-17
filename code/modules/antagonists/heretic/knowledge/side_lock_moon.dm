/datum/heretic_knowledge_tree_column/moon_to_lock
	neighbour_type_left = /datum/heretic_knowledge_tree_column/main/moon
	neighbour_type_right = /datum/heretic_knowledge_tree_column/main/lock

	route = PATH_SIDE

	tier1 = /datum/heretic_knowledge/spell/mind_gate
	tier2 = list(/datum/heretic_knowledge/unfathomable_curio, /datum/heretic_knowledge/painting)
	tier3 = /datum/heretic_knowledge/codex_morbus

// Sidepaths for knowledge between Knock and Moon.

/datum/heretic_knowledge/spell/mind_gate
	name = "Mind Gate"
	desc = "Дает вам заклинание Mind Gate, которое \
		наносит вам 20 урона мозгу, и накладывает галлюцинации на цель, \
		замешательство на 10 секунд, потерю дыхания и урон мозгу."
	gain_text = "Мой разум распахивается, словно врата, и его озарение позволяет мне постичь правду."

	action_to_add = /datum/action/cooldown/spell/pointed/mind_gate
	cost = 1

/datum/heretic_knowledge/unfathomable_curio
	name = "Unfathomable Curio"
	desc = "Позволяет трансмутировать 3 железных стержня, легкие и любой пояс в Непостижимую диковинку\
			, пояс, который может хранить клинки и предметы для ритуалов. Пока вы его носите, \
			он также будет покрывать вас вуалью, позволяющей последующим 5 ударам не наносить по вам урон. \
			Вуаль очень медленно перезаряжается вне боя."
	gain_text = "В Мансусе хранится множество диковинок, но некоторые из них не предназначены для глаза смертных."

	required_atoms = list(
		/obj/item/organ/lungs = 1,
		/obj/item/stack/rods = 3,
		/obj/item/storage/belt = 1,
	)
	result_atoms = list(/obj/item/storage/belt/unfathomable_curio)
	cost = 1

	research_tree_icon_path = 'icons/obj/clothing/belts.dmi'
	research_tree_icon_state = "unfathomable_curio"


/datum/heretic_knowledge/painting
	name = "Unsealed Arts"
	desc = "Позволяет трансмутировать холст и дополнительный предмет, чтобы создать произведение искусства. \
			Эти картины имеют разные эффекты в зависимости от добавленного предмета. Можно создать следующие картины: \
			Сестра и Тот, Кто Плакал: Глаза. Очищает ваш разум, но проклинает не-еретиков галлюцинациями. \
			Первое Желание: Любая часть тела. Предоставляет вам случайные органы, но проклинает не-еретиков жаждой плоти. \
			Великий чапараль над холмами: Любая выращенная еда. Распространяет кудзу при установке и осмотре не-еретиками. Также дает вам маки и колокольчики. \
			Дама за воротами: Перчатки. Очищает ваши мутации, но мутирует всех не-еретиков и проклинает их чесоткой. \
			Подъем на ржавые горы: Мусло. Проклинает всех не-еретиков, заставляя их оставлять ржавчину на своем пути. \
			Не-еретики могут избавиться от этих эффектов, осматривая эти картины."
	gain_text = "Ветер вдохновения дует через меня; за стенами и за вратами лежит вдохновение, которое еще предстоит изобразить \
				Они снова жаждут взгляда смертных, и я исполню это желание."

	required_atoms = list(/obj/item/canvas = 1)
	result_atoms = list(/obj/item/canvas)
	cost = 1

	research_tree_icon_path = 'icons/obj/signs.dmi'
	research_tree_icon_state = "eldritch_painting_weeping"


/datum/heretic_knowledge/painting/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	if(locate(/obj/item/organ/eyes) in atoms)
		src.result_atoms = list(/obj/item/wallframe/painting/eldritch/weeping)
		src.required_atoms = list(
			/obj/item/canvas = 1,
			/obj/item/organ/eyes = 1,
		)
		return TRUE

	if(locate(/obj/item/bodypart) in atoms)
		src.result_atoms = list(/obj/item/wallframe/painting/eldritch/desire)
		src.required_atoms = list(
			/obj/item/canvas = 1,
			/obj/item/bodypart = 1,
		)
		return TRUE

	if(locate(/obj/item/food/grown) in atoms)
		src.result_atoms = list(/obj/item/wallframe/painting/eldritch/vines)
		src.required_atoms = list(
			/obj/item/canvas = 1,
			/obj/item/food/grown = 1,
		)
		return TRUE

	if(locate(/obj/item/clothing/gloves) in atoms)
		src.result_atoms = list(/obj/item/wallframe/painting/eldritch/beauty)
		src.required_atoms = list(
			/obj/item/canvas = 1,
			/obj/item/clothing/gloves = 1,
		)
		return TRUE

	if(locate(/obj/item/trash) in atoms)
		src.result_atoms = list(/obj/item/wallframe/painting/eldritch/rust)
		src.required_atoms = list(
			/obj/item/canvas = 1,
			/obj/item/trash = 1,
		)
		return TRUE

	user.balloon_alert(user, "no additional atom present!")
	return FALSE

/**
 * Codex Morbus, an upgrade to the base codex
 * Functionally an upgraded version of the codex, but it also has the ability to cast curses by right clicking at a rune.
 * Requires you to have the blood of your victim in your off-hand
 */
/datum/heretic_knowledge/codex_morbus
	name = "Codex Morbus"
	desc = "Allows you to to combine a codex cicatrix, and a body into a Codex Morbus. \
		It draws runes and siphons essences a bit faster. \
		Right Click on a rune to curse crewmembers, the target's blood is required in your off hand for a curse to take effect (Best combined with Phylactery Of Damnation)."
	gain_text = "The spine of this leather-bound tome creaks with an eerily pained sigh. \
		To ply page from place takes considerable effort, and I dare not linger on the suggestions the book makes for longer than necessary. \
		It speaks of coming plagues, of waiting supplicants of dead and forgotten gods, and the undoing of mortal kind. \
		It speaks of needles to peel the skin of the world back and leaving it to fester. And it speaks to me by name."
	required_atoms = list(
		/obj/item/codex_cicatrix = 1,
		/mob/living/carbon/human = 1,
	)
	result_atoms = list(/obj/item/codex_cicatrix/morbus)
	cost = 1
	research_tree_icon_path = 'icons/obj/antags/eldritch.dmi'
	research_tree_icon_state = "book_morbus"

/datum/heretic_knowledge/codex_morbus/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	var/mob/living/carbon/human/to_fuck_up = locate() in selected_atoms
	for(var/_limb in to_fuck_up.bodyparts)
		var/obj/item/bodypart/limb = _limb
		limb.force_wound_upwards(/datum/wound/slash/flesh/critical)
	for(var/obj/item/bodypart/limb as anything in to_fuck_up.bodyparts)
		to_fuck_up.cause_wound_of_type_and_severity(WOUND_BLUNT, limb, WOUND_SEVERITY_CRITICAL)
	return TRUE
