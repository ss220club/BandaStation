/datum/heretic_knowledge_tree_column/blade_to_rust
	neighbour_type_left = /datum/heretic_knowledge_tree_column/main/blade
	neighbour_type_right = /datum/heretic_knowledge_tree_column/main/rust

	route = PATH_SIDE

	tier1 = /datum/heretic_knowledge/armor
	tier2 = list(/datum/heretic_knowledge/crucible, /datum/heretic_knowledge/rifle)
	tier3 = list(/datum/heretic_knowledge/spell/rust_charge, /datum/heretic_knowledge/greaves_of_the_prophet)

// Sidepaths for knowledge between Rust and Blade.
/datum/heretic_knowledge/armor
	name = "Armorer's Ritual"
	desc = "Позволяет трансмутировать стол и противогаз для создания Мистической брони. \
		Мистическая броня обеспечивает отличную защиту, а также действует как фокус, когда на него накинут капюшон."
	gain_text = "Ржавые холмы приветствовали Кузнеца в своей щедрости. И Кузнец \
		ответил им щедростью на щедрость."

	required_atoms = list(
		/obj/structure/table = 1,
		/obj/item/clothing/mask/gas = 1,
	)
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/eldritch)
	cost = 1

	research_tree_icon_path = 'icons/obj/clothing/suits/armor.dmi'
	research_tree_icon_state = "eldritch_armor"
	research_tree_icon_frame = 12


/datum/heretic_knowledge/crucible
	name = "Mawed Crucible"
	desc = "Позволяет трансмутировать переносной бак с водой и стол для создания Голодного горнила. \
		Голодное горнило позволяет варить мощные боевые и воспомогательные зелья, но взамен требует части тела и органы."
	gain_text = "Это чистая агония. Мне не удалось вызвать образ Аристократа, \
		но благодаря вниманию Жреца я наткнулся на другой рецепт..."

	required_atoms = list(
		/obj/structure/reagent_dispensers/watertank = 1,
		/obj/structure/table = 1,
	)
	result_atoms = list(/obj/structure/destructible/eldritch_crucible)
	cost = 1

	research_tree_icon_path = 'icons/obj/antags/eldritch.dmi'
	research_tree_icon_state = "crucible"


/datum/heretic_knowledge/rifle
	name = "Lionhunter's Rifle"
	desc = "Позволяет трансмутировать любую деревянную доску, шкуру \
		любого животного и камеру в винтовку Lionhunter. \
		Lionhunter - это дальнобойное баллистическое оружие с тремя выстрелами. \
		При стрельбе с близкого расстояния или по неодушевленным предметам эти выстрелы \
		действуют как обычные, хотя и слабые высококалиберные боеприпасы. Ты можешь направить винтовку на противников на большом расстояние,\
		в результате чего выстрел даст Метку жертве и телепортирует вас к ней."
	gain_text = "В антикварном магазине я встретил старика, который владел очень необычным оружием. \
		В то время я не мог его приобрести, но они показали мне, как они делали его много лет назад."

	required_atoms = list(
		/obj/item/stack/sheet/mineral/wood = 1,
		/obj/item/stack/sheet/animalhide = 1,
		/obj/item/camera = 1,
	)
	result_atoms = list(/obj/item/gun/ballistic/rifle/lionhunter)
	cost = 1


	research_tree_icon_path = 'icons/obj/weapons/guns/ballistic.dmi'
	research_tree_icon_state = "goldrevolver"

/datum/heretic_knowledge/rifle_ammo
	name = "Lionhunter Rifle Ammunition"
	desc = "Позволяет трансмутировать 3 баллистические гильзы (использованные или неиспользованные) любого калибра, \
		включая дробь, чтобы создать дополнительную обойму боеприпасов для винтовки Lionhunter."
	gain_text = "К оружию прилагались три грубых железных шара, предназначенных для использования в качестве боеприпасов. \
		Они были очень эффективны для простого железа, но быстро расходовались. Вскоре они у меня закончились. \
		Никакие запасные боеприпасы не помогали. Винтовка была своеобразна в том, чего она хотела."
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

/datum/heretic_knowledge/spell/rust_charge
	name = "Rust Charge"
	desc = "Рывок, который должен начаться на ржавом тайле, уничтожающий все ржавые объекты по пути. Наносит большой урон остальным и создает ржавчину вокруг вас во время рывка."
	gain_text = "Холмы сверкали, и по мере приближения мой разум начал метаться. Я быстро вернул свою решимость и устремился вперед, ведь последний этап будет самым коварным."

	action_to_add = /datum/action/cooldown/mob_cooldown/charge/rust
	cost = 1

/datum/heretic_knowledge/greaves_of_the_prophet
	name = "Greaves Of The Prophet"
	desc = "Allows you to combine a pair of Jackboots and 2 sheets of Titanium into a pair of Armored Greaves, they confer to the user fully immunity to slips."
	gain_text = " \
		Gristle churns into joint, a pop, and the fool twists a blackened foot from the \
		jaws of another. At their game for centuries, this mangled tree of limbs twists, \
		thrashing snares buried into snarling gums, seeking to shred the weight of grafted \
		neighbors. Weighed down by lacerated feet, this canopy of rancid idiots ever seeks \
		the undoing of its own bonds. I dread the thought of walking in their wake, but \
		I must press on all the same. Their rhythms keep the feud fresh with indifference \
		to barrier or border. Pulling more into their turmoil as they waltz."
	cost = 1
	required_atoms = list(
		/obj/item/clothing/shoes/jackboots = 1,
		/obj/item/stack/sheet/mineral/titanium = 2,
	)
	result_atoms = list(/obj/item/clothing/shoes/greaves_of_the_prophet)
	research_tree_icon_path = 'icons/obj/clothing/shoes.dmi'
	research_tree_icon_state = "hereticgreaves"
