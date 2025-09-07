/datum/heretic_knowledge_tree_column/ash_to_moon
	neighbour_type_left = /datum/heretic_knowledge_tree_column/main/ash
	neighbour_type_right = /datum/heretic_knowledge_tree_column/main/moon

	route = PATH_SIDE

	tier1 = /datum/heretic_knowledge/medallion
	tier2 = /datum/heretic_knowledge/ether
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

/datum/heretic_knowledge/ether
	name = "Ether Of The Newborn"
	desc = "Преобразует лужу рвоты и осколок, в одноразовое зелье, выпив которое, вы избавитесь от любой аномалии в вашем теле, включая болезни, травмы и имплантаты, \
		а также полностью восстановите здоровье, ценой потери сознания на целую минуту."
	gain_text = "Зрение и мысли затуманиваются, как и пары этого ихора, уносящиеся навстречу мне. \
		Сквозь туманную пелену я с облегчением смотрю на себя или на нечто, очень напоминающее мой облик. \
		Это то жалкое создание, которое я предоставляю своей судьбе, и чье собственное я вырываю из тумана грез. Какими же глупцами мы были."
	required_atoms = list(
		/obj/item/shard = 1,
		/obj/effect/decal/cleanable/vomit = 1,
	)
	result_atoms = list(/obj/item/ether)
	cost = 1
	research_tree_icon_path = 'icons/obj/antags/eldritch.dmi'
	research_tree_icon_state = "poison_flask"

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

