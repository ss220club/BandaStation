/*!
 * Tier 4 knowledge: Combat related knowledge
 */

/datum/heretic_knowledge/spell/space_phase
	name = "Космичесская Фаза"
	desc = "Дарует вам «Космичесскую Фазу» - заклинание, позволяющее свободно перемещаться в космичесском пространстве. \
		Вы можете входить и выходить из фазы только тогда, когда находитесь в космосе."
	gain_text = "Вы ощущаете, что ваше тело может перемещаться по космосу так, словны вы стали космичессой пылью."

	action_to_add = /datum/action/cooldown/spell/jaunt/space_crawl
	cost = 2
	research_tree_icon_frame = 6
	drafting_tier = 4

/datum/heretic_knowledge/unfathomable_curio
	name = "Непостижимая Диковинка"
	desc = "Позволяет трансмутировать 3 железных прута, легкие, и любой пояс, чтобы получить Непостижимую Диковинку - \
			пояс, на котором можно хранить клинки и предметы для ритуалов. Пока вы носите его, он будет закрывать вас, \
			блокируя один удар входящего урона за счет вуали. Вуаль будет перезаряжаться после боя."
	gain_text = "Мансус хранит множество диковинок, некоторые не предназначаны для глаз смертных."

	required_atoms = list(
		/obj/item/organ/lungs = 1,
		/obj/item/stack/rods = 3,
		/obj/item/storage/belt = 1,
	)
	result_atoms = list(/obj/item/storage/belt/unfathomable_curio)
	cost = 2
	research_tree_icon_path = 'icons/obj/clothing/belts.dmi'
	research_tree_icon_state = "unfathomable_curio"
	drafting_tier = 4

/datum/heretic_knowledge/rust_sower
	name = "Граната-рассадник Ржавчины"
	desc = "Позволяет совместить гильзу от химичесской гранаты и немного заплесневелой еды, чтобы создать проклятую гранату, заполненную Паранормальной Ржавчиной, при взрыве граната выпускает огромное облако, ослепляющее органиков, подвергая ржавчине поверхности и уничтожая синтетиков и мехов."
	gain_text = "Засохшие виноградные лозы на Ржавых Холмах отягощены подобными, перезрелыми плодами. Они уничтожают признаки прогресса, оставляя чистый лист для создания новых форм."
	required_atoms = list(
		list(
			/obj/item/food/breadslice/moldy,
			/obj/item/food/badrecipe/moldy,
			/obj/item/food/deadmouse/moldy,
			/obj/item/food/pizzaslice/moldy,
			/obj/item/food/boiledegg/rotten,
			/obj/item/food/egg/rotten
		) = 1,
		/obj/item/grenade/chem_grenade = 1
	)
	result_atoms = list(/obj/item/grenade/chem_grenade/rust_sower)
	cost = 2
	research_tree_icon_path = 'icons/obj/weapons/grenade.dmi'
	research_tree_icon_state = "rustgrenade"
	drafting_tier = 4

/datum/heretic_knowledge/spell/crimson_cleave
	name = "Багровый Разрез"
	desc = "Дарует вам «Багровый Разрез» - направленное заклинание, поглощающее здоровье в небольшом радиусе. Очищает все раны при использовании."
	gain_text = "Поначалу я не понимал этих орудий войны, но Жрец велел мне использовать их несмотря ни на что. \
				Вскоре, сказал он, я познаю их хорошо."
	action_to_add = /datum/action/cooldown/spell/pointed/crimson_cleave
	cost = 2
	drafting_tier = 4

/datum/heretic_knowledge/rifle
	name = "Винтовку Охотника на Львов"
	desc = "Позволяет трансмутировать кусок дерева с шкурой любого животного и камеру, \
		чтобы создать Винтовку Охотника на Львов. \
		Винтовка Охотника на Львов - это дальнобойное баллистическое оружие с тремя выстрелами. \
		Эти выстрелы действуют как обычные, хотя и слабые, боеприпасы крупного калибра при стрельбе вблизи или по неодушевлённым объектам. \
		Используюя прицел, вы можете нацелиться на притивника, находящегося в дали, \
		в результате чего выстрел пометит жертву вашей Хваткой и мгновенно переместит вас к ней."
	gain_text = "Я встретил старика, в антикварном магазине которого, стояла крайне необычное оружие. \
		В то время я не мог его купить, но Они показали мне, как его создавали века назад."
	required_atoms = list(
		/obj/item/stack/sheet/mineral/wood = 1,
		/obj/item/stack/sheet/animalhide = 1,
		/obj/item/camera = 1,
	)
	result_atoms = list(/obj/item/gun/ballistic/rifle/lionhunter)
	cost = 2
	research_tree_icon_path = 'icons/obj/weapons/guns/ballistic.dmi'
	research_tree_icon_state = "goldrevolver"
	drafting_tier = 2

/datum/heretic_knowledge/rifle_ammo
	name = "Боеприпасы для винтовки Охотника на Львов"
	desc = "Позволяет трансмутировать 3 гильзы(использованных или неиспользованных) любого калибра, в том числе патроны дробовика, \
		чтобы создать дополнительную обойму патронов для Винтовки Охотника на Львов."
	gain_text = "К оружию прилагались три грубых железных шара, предназначенных для использования в качестве боеприпасов. \
		Они были очень эффективны для простого железа, но быстро кончались. Вскоре они закончились и у меня. \
		Никакие другие пули не могли заменить их. Это было именно то, чего оно хотело."
	required_atoms = list(
		/obj/item/ammo_casing = 3,
	)
	result_atoms = list(/obj/item/ammo_box/speedloader/strilka310/lionhunter)
	cost = 0
	research_tree_icon_path = 'icons/obj/weapons/guns/ammo.dmi'
	research_tree_icon_state = "310_strip"

	/// A list of calibers that the ritual will deny. Only ballistic calibers are allowed.
	var/static/list/caliber_blacklist = list(
		CALIBER_LASER,
		CALIBER_ENERGY,
		CALIBER_FOAM,
		CALIBER_ARROW,
		CALIBER_HARPOON,
		CALIBER_HOOK,
	)

/datum/heretic_knowledge/rifle_ammo/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	for(var/obj/item/ammo_casing/casing in atoms)
		if(!(casing.caliber in caliber_blacklist))
			continue

		// Remove any casings in the caliber_blacklist list from atoms
		atoms -= casing

	// We removed any invalid casings from the atoms list,
	// return to allow the ritual to fill out selected atoms with the new list
	return TRUE
