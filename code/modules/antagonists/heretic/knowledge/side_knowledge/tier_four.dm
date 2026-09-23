/*!
 * Tier 4 knowledge: Combat related knowledge
 */

/datum/heretic_knowledge/spell/space_phase
	name = "Космическая фаза"
	desc = "Дарует вам «Космическую фазу» - заклинание, позволяющее свободно перемещаться в космическом пространстве. \
		Вы можете входить и выходить из фазы только тогда, когда находитесь в космосе."
	gain_text = "Вы ощущаете, что ваше тело может перемещаться по космосу так, словно вы стали космической пылью."

	action_to_add = /datum/action/cooldown/spell/jaunt/space_crawl
	cost = 2
	research_tree_icon_frame = 6
	drafting_tier = 4
	max_charges = 2
	path_recharge_amount = 0.0
	holywater_drain_amount = 0.5
	transmute_text = "Для перезарядки раздавите блюспейс-кристалл, стоя над руной."
	/// Tracks tim ein EVA
	var/seconds_in_eva = 0

/datum/heretic_knowledge/spell/space_phase/has_charges(mob/living/user)
	return HAS_TRAIT(user, TRAIT_MAGICALLY_PHASED) || ..()

/datum/heretic_knowledge/spell/space_phase/should_deduct_charge(mob/living/user)
	return !HAS_TRAIT(user, TRAIT_MAGICALLY_PHASED)

/datum/heretic_knowledge/spell/space_phase/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	RegisterSignal(user, COMSIG_MOB_CRUSHED_BLUESPACE_CRYSTAL, PROC_REF(on_crystal_crushed))

/datum/heretic_knowledge/spell/space_phase/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	UnregisterSignal(user, COMSIG_MOB_CRUSHED_BLUESPACE_CRYSTAL)

/datum/heretic_knowledge/spell/space_phase/proc/on_crystal_crushed(mob/living/source, obj/item/crystal)
	SIGNAL_HANDLER

	var/obj/effect/heretic_rune/rune = locate() in view(1, source)
	if(isnull(rune))
		return

	rune.ritual_animation()
	add_charges(1)

/datum/heretic_knowledge/unfathomable_curio
	name = "Непостижимая реликвия"
	desc = "Позволяет получить непостижимую реликвию - \
			пояс, на котором можно хранить клинки и предметы для ритуалов. Пока вы носите его, он будет окутывать вас вуалью, \
			блокируя один удар входящего урона за счет вуали. Вуаль будет перезаряжаться после боя."
	transmute_text = "Трансмутируйте 3 железных прута, лёгкие и любой пояс."
	gain_text = "Мансус хранит множество реликвий, некоторые не предназначены для глаз смертных."

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
	name = "Сеятель ржавчины"
	desc = "Позволяет создать проклятую гранату, заполненную паранормальной ржавчиной. При взрыве граната выпускает огромное облако, ослепляющее органиков, покрывая поверхности ржавчиной, уничтожая синтетиков и мехов."
	transmute_text = "Трансмутируйте гильзу от химической гранаты и немного заплесневелой еды."
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
	name = "Багровый тесак"
	desc = "Позволяет выковать Багровый тесак — устрашающее оружие, жаждущее крови.<br>\
		Его удары исцеляют вас на величину наносимого урона, а само оно способно поражать сразу нескольких врагов. \
		Это также довольно эффективное метательное оружие, которое возвращается к владельцу после броска."
	gain_text = "Поначалу я не понимал этих орудий войны, но Жрец велел мне использовать их несмотря ни на что. \
				Вскоре, сказал он, я познаю их хорошо."
	transmute_text = "Превратите мясницкий тесак и немного крови - \
		либо лужа или капли, окровавленные тряпье или бинты, мензурка или флакон, или даже сам окровавленный тесак."
	required_atoms = list(
		/obj/item/knife/butcher = 1,
	)
	result_atoms = list(/obj/item/knife/butcher/heretic)
	banned_atom_types = list(/obj/item/knife/butcher/heretic)
	cost = 2
	drafting_tier = 4
	research_tree_icon_path = /obj/item/knife/butcher/heretic::icon
	research_tree_icon_state = /obj/item/knife/butcher/heretic::icon_state

/datum/heretic_knowledge/crimson_cleave/prepare_atom_for_ritual_test(atom/what)
	. = ..()
	what.add_blood_DNA(list("Test DNA" = get_blood_type(/datum/blood_type/human/o_minus)))

/datum/heretic_knowledge/crimson_cleave/get_extra_requirements()
	return "немного крови — лужа или капли, окровавленные тряпки или бинты, мензурка или флакон, или даже сам окровавленный тесак"

/datum/heretic_knowledge/crimson_cleave/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	for(var/obj/item/knife/butcher/cleaver in atoms)
		selected_atoms += cleaver
		if(GET_ATOM_BLOOD_DNA_LENGTH(cleaver))
			return TRUE // two for one deal
		break

	for(var/obj/effect/decal/cleanable/blood/blood in atoms)
		selected_atoms += blood // blood is blood
		return TRUE

	for(var/obj/item/rag/rag in atoms)
		if(GET_ATOM_BLOOD_DNA_LENGTH(rag))
			selected_atoms += rag
			return TRUE

	for(var/obj/item/stack/medical/wrap/gauze/medwrap in atoms)
		if(GET_ATOM_BLOOD_DNA_LENGTH(medwrap))
			selected_atoms += medwrap
			return TRUE

	for(var/obj/item/reagent_containers/container in atoms)
		for(var/datum/reagent/reagent_content as anything in container.reagents.reagent_list)
			if(LAZYACCESS(reagent_content.data, BLOOD_DATA_DNA))
				selected_atoms += container
				return TRUE

	loc.balloon_alert(user, "Ритуал не удался — нет крови!")
	to_chat(user, span_mansus("Вам не хватает крови для завершения ритуала. \"[name]\"."))
	return FALSE

/datum/heretic_knowledge/crimson_cleave/cleanup_atoms(list/selected_atoms)
	for(var/obj/item/reagent_containers/container in selected_atoms)
		for(var/datum/reagent/reagent_content as anything in container.reagents.reagent_list)
			if(LAZYACCESS(reagent_content.data, BLOOD_DATA_DNA))
				container.reagents.del_reagent(reagent_content.type)
		selected_atoms -= container

	for(var/obj/item/stack/medical/wrap/gauze/medwrap in selected_atoms)
		medwrap.use(1)
		selected_atoms -= medwrap

	return ..()

/datum/heretic_knowledge/rifle
	name = "Винтовка Охотника на Львов"
	desc = "Позволяет создать винтовку Охотника на Львов. \
		Винтовка Охотника на Львов - это дальнобойное баллистическое оружие с тремя зарядами. \
		Эти заряды действуют как обычные, хотя и слабые, боеприпасы крупного калибра при стрельбе вблизи или по неодушевлённым объектам. \
		Используя прицел, вы можете нацелиться на противника находящегося вдали, \
		при попадании выстрел пометит жертву вашей Хваткой и мгновенно переместит вас к ней."
	transmute_text = "Трансмутируйте кусок дерева, шкуру любого животного и камеру."
	gain_text = "Я встретил старика в антикварном магазине, в котором стояло крайне необычное оружие. \
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
	desc = "Позволяет создать дополнительную обойму патронов для винтовки Охотника на Львов."
	transmute_text = "Трансмутируйте 3 гильзы (использованные или неиспользованные) любого калибра, в том числе патроны для дробовика."
	gain_text = "К оружию прилагались три грубых железных шара, предназначенных для использования в качестве боеприпасов. \
		Они были слишком эффективны для простого железа, но быстро кончались. Вскоре они закончились и у меня. \
		Никакие другие пули не могли заменить их. Оно было привередливо в том, чего хотело."
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

/datum/heretic_knowledge/rifle_ammo/pre_research(mob/user, datum/antagonist/heretic/our_heretic)
	if(!our_heretic.get_knowledge(/datum/heretic_knowledge/rifle))
		tgui_alert(user, "Сначала необходимо изучить знание винтовки Охотника на Львов, и только потом - боеприпасы к ней.")
		return FALSE

	return TRUE

/datum/heretic_knowledge/rifle_ammo/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	for(var/obj/item/ammo_casing/casing in atoms)
		if(!(casing.caliber in caliber_blacklist))
			continue

		// Remove any casings in the caliber_blacklist list from atoms
		atoms -= casing
	// We removed any invalid casings from the atoms list,
	// return to allow the ritual to fill out selected atoms with the new list
	return TRUE
