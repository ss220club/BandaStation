/datum/heretic_knowledge_tree_column/ash_to_moon
	neighbour_type_left = /datum/heretic_knowledge_tree_column/main/ash
	neighbour_type_right = /datum/heretic_knowledge_tree_column/main/moon

	route = PATH_SIDE

	tier1 = /datum/heretic_knowledge/medallion
	tier2 = /datum/heretic_knowledge/curse/paralysis
	tier3 = /datum/heretic_knowledge/summon/ashy

// Sidepaths for knowledge between Ash and Flesh.
/datum/heretic_knowledge/medallion
	name = "Ashen Eyes"
	desc = "Позволяет трансмутировать пару глаз, свечу и осколок стекла в Мистический медальон. \
		Мистический медальон дает вам термальное зрение при ношении, а также действует как фокус."
	gain_text = "Пронзительные глаза вели их сквозь обыденность. Ни тьма, ни ужас не могли остановить их."

	required_atoms = list(
		/obj/item/organ/eyes = 1,
		/obj/item/shard = 1,
		/obj/item/flashlight/flare/candle = 1,
	)
	result_atoms = list(/obj/item/clothing/neck/eldritch_amulet)
	cost = 1
	research_tree_icon_path = 'icons/obj/antags/eldritch.dmi'
	research_tree_icon_state = "eye_medalion"

/datum/heretic_knowledge/curse/paralysis
	name = "Curse of Paralysis"
	desc = "Позволяет трансмутировать топорик и левую, и правую ногу, чтобы наложить проклятие неподвижности на члена экипажа. \
		Во время проклятия жертва не сможет ходить. Для увеличения длительности проклятия можно дополнительно предоставить предмет, к которому прикасалась \
		ертва или который покрыт кровью жертвы."
	gain_text = "Плоть человечества слаба. Заставьте их истечь кровью. Покажите им их хрупкость."

	required_atoms = list(
		/obj/item/bodypart/leg/left = 1,
		/obj/item/bodypart/leg/right = 1,
		/obj/item/hatchet = 1,
	)
	duration = 3 MINUTES
	duration_modifier = 2
	curse_color = "#f19a9a"
	cost = 1

	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "curse_paralysis"


/datum/heretic_knowledge/curse/paralysis/curse(mob/living/carbon/human/chosen_mob, boosted = FALSE)
	if(chosen_mob.usable_legs <= 0) // What're you gonna do, curse someone who already can't walk?
		to_chat(chosen_mob, span_notice("На мгновение вы чувствуете легкую боль, но она вскоре проходит. Странно."))
		return

	to_chat(chosen_mob, span_danger("Вы внезапно перестаете чувствовать ног[chosen_mob.usable_legs == 1 ? "у" : "и"]!"))
	chosen_mob.add_traits(list(TRAIT_PARALYSIS_L_LEG, TRAIT_PARALYSIS_R_LEG), type)
	return ..()

/datum/heretic_knowledge/curse/paralysis/uncurse(mob/living/carbon/human/chosen_mob, boosted = FALSE)
	if(QDELETED(chosen_mob))
		return

	chosen_mob.remove_traits(list(TRAIT_PARALYSIS_L_LEG, TRAIT_PARALYSIS_R_LEG), type)
	if(chosen_mob.usable_legs > 1)
		to_chat(chosen_mob, span_green("Вы снова чувствуете ног[chosen_mob.usable_legs == 1 ? "у":"и"]!"))
	return ..()

/datum/heretic_knowledge/summon/ashy
	name = "Ashen Ritual"
	desc = "Позволяет трансмутировать голову, кучу пепла и книгу, чтобы создать Пепельного духа. \
		Пепельные духи обладают коротким джаунтом и способностью вызывать кровотечение у противников на расстоянии. \
		Они также обладают способностью создавать вокруг себя огненное кольцо на длительное время."
	gain_text = "Я объединил свой принцип голода с желанием разрушения. Маршал знал мое имя, а Ночной дозорный наблюдал."

	required_atoms = list(
		/obj/effect/decal/cleanable/ash = 1,
		/obj/item/bodypart/head = 1,
		/obj/item/book = 1,
		)
	mob_to_summon = /mob/living/basic/heretic_summon/ash_spirit
	cost = 1

	poll_ignore_define = POLL_IGNORE_ASH_SPIRIT

