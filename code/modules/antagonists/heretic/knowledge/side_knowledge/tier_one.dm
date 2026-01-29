/*!
 * Tier 1 knowledge: Stealth and general utility
 */

/datum/heretic_knowledge/void_cloak
	name = "Накидка Пустоты"
	desc = "Позволяет трансмутировать осколок стекла, простыню, и любую верхнюю одежду (например броню или костюм), \
		чтобы создать накидку Пустоты. Пока капюшон опущен, накидка защищает вас от космоса и действует как фокусировка. \
		Когда капюшон поднят, плащ полностью невидим. Он также обеспечивает неплохую броню и \
		имеет карманы, в которые можно поместить один из ваших клинков, различные ритуальные компоненты (например, органы) и небольшие еретические безделушки."
	gain_text = "Сова хранит то, что не обрело формы в действительности, но уже существует в теории. А таких сущностей немало."
	required_atoms = list(
		/obj/item/shard = 1,
		/obj/item/clothing/suit = 1,
		/obj/item/bedsheet = 1,
	)
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/void)
	cost = 1
	research_tree_icon_path = 'icons/obj/clothing/suits/armor.dmi'
	research_tree_icon_state = "void_cloak"
	drafting_tier = 1

/datum/heretic_knowledge/medallion
	name = "Пепельные глаза"
	desc = "Позволяет трансмутировать глаза, свечу, и осколок стекла в Потусторонний медальон. \
		При ношении Потусторонний медальон дает термальное зрение, а также работает как фокусировщик."
	gain_text = "Пронзительный взгляд вел их сквозь обыденность. Ни темнота, ни ужас не могли их остановить."
	required_atoms = list(
		/obj/item/organ/eyes = 1,
		/obj/item/shard = 1,
		/obj/item/flashlight/flare/candle = 1,
	)
	result_atoms = list(/obj/item/clothing/neck/eldritch_amulet)
	cost = 1
	research_tree_icon_path = 'icons/obj/antags/eldritch.dmi'
	research_tree_icon_state = "eye_medalion"
	drafting_tier = 1

/datum/heretic_knowledge/essence // AKA Eldritch Flask
	name = "Священный ритуал"
	desc = "Позволяет трансмутировать емкость с водой и осколок стекла во флягу Потусторонней эссенции. \
		Потустороннюю эссенцию можно употреблять для мощного исцеления или дать язычникам, для смертельного отравления"
	gain_text = "Это наш старый рецепт. Нашептала мне Сова. \
		Созданная Жрецом - жидкость, которая существовала и нет одновременно."
	required_atoms = list(
		/obj/structure/reagent_dispensers/watertank = 1,
		/obj/item/shard = 1,
	)
	result_atoms = list(/obj/item/reagent_containers/cup/beaker/eldritch)
	cost = 1
	research_tree_icon_path = 'icons/obj/antags/eldritch.dmi'
	research_tree_icon_state = "eldritch_flask"
	drafting_tier = 1

/datum/heretic_knowledge/phylactery
	name = "Филактерия проклятия"
	desc = "Позволяет трансмутировать лист стекла и мак в филактерию, способную мгновенно вытягивать кровь, даже на большой дистанции. \
		Имейте в виду, что ваша цель все еще может почувствовать укол."
	gain_text = "Настойка, извращённая в форму кровососущего паразита. \
		Выбрала ли она этот облик сама, или же это - шутка больного разума, породившего этот мерзкий артефакт, - вопрос, над которым лучше не задумываться."
	required_atoms = list(
		/obj/item/stack/sheet/glass = 1,
		/obj/item/food/grown/poppy = 1,
	)
	result_atoms = list(/obj/item/reagent_containers/cup/phylactery)
	cost = 1
	research_tree_icon_path = 'icons/obj/antags/eldritch.dmi'
	research_tree_icon_state = "phylactery_2"
	drafting_tier = 1

/datum/heretic_knowledge/crucible
	name = "Зубастый тигель"
	desc = "Позволяет трансмутировать переносной бак с водой и стол, чтобы создать Зубастый тигель. \
		Зубастый Тигель открывает возможность варить могущественные зелья, как для боя, так и общего назначения, однако между использованиями его нужно подкармливать органами, или частями тела."
	gain_text = "Это чистейшая агония. Мне не удалось призвать образ Аристократа, \
		но, привлёкши внимание Жреца, я наткнулся на иной рецепт…"
	required_atoms = list(
		/obj/structure/reagent_dispensers/watertank = 1,
		/obj/structure/table = 1,
	)
	result_atoms = list(/obj/structure/destructible/eldritch_crucible)
	cost = 1
	research_tree_icon_path = 'icons/obj/antags/eldritch.dmi'
	research_tree_icon_state = "crucible"
	drafting_tier = 1

/datum/heretic_knowledge/eldritch_coin
	name = "Потусторонняя монета"
	desc = "Позволяет трансмутировать лист плазмы и алмаз, чтобы создать Потустороннюю монету \
		Монета откроет или закроет ближайшие двери если выпадет орёл, и заболтирует их, если выпадет решка. \
		Если вставить монету в шлюз, она сожжет его плату, оставив шлюз открытым, если он не болтирован."
	gain_text = "Мансус - место для всех видов греха. Но алчность занимает в нём особое место."
	required_atoms = list(
		/obj/item/stack/sheet/mineral/diamond = 1,
		/obj/item/stack/sheet/mineral/plasma = 1,
	)
	result_atoms = list(/obj/item/coin/eldritch)
	cost = 1
	research_tree_icon_path = 'icons/obj/economy.dmi'
	research_tree_icon_state = "coin_heretic"
	drafting_tier = 1
