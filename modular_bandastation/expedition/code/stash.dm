GLOBAL_LIST_EMPTY(accessed_personal_stashes)

/obj/structure/personal_stash
	name = "personal stash terminal"
	desc = "Специализированный терминал-хранилище, связанный с единой персональной базой снаряжения."
	icon = 'modular_bandastation/objects/icons/obj/machines/vending.dmi'
	icon_state = "nta"
	density = TRUE
	anchored = TRUE

	var/unique_id = null
	var/max_storage = 40
	var/list/allowed_vars = list(
		"contents",
		"stored_ammo",
		"magazine",
		"chambered",
		"pin",
		"bayonet",
		"cell",
		"bcell",
		"stored_item",
		"name",
		"desc",
		"amount",
		"charge",
		"maxcharge",
		"uses",
		"uses_left",
		"health",
		"lit",
		"on",
		"fuel"
	)

/obj/structure/personal_stash/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	interact(user)

/obj/structure/personal_stash/interact(mob/user)
	if(!user || !ishuman(user))
		to_chat(user, "<span class='warning'>Терминал отклоняет доступ: не обнаружено биометрических данных человека.</span>")
		return

	var/mob/living/carbon/human/H = user
	var/list/dat = list()
	dat += "<div align='center'><h2>[name]</h2></div><hr>"

	if(!unique_id)
		dat += "<p>Добро пожаловать в персональное хранилище. Для загрузки ваших предметов авторизуйтесь.</p>"
		dat += "<p><a href='byond://?src=[REF(src)];action=login'>Авторизоваться как [H.ckey]</a></p>"
	else if(unique_id != H.ckey)
		dat += "<p><span class='danger'>Внимание: терминал занят учетной записью [unique_id].</span></p>"
	else
		dat += "<p>Авторизован: <b>[H.ckey]</b> | Слотов занято: <b>[contents.len] / [max_storage]</b></p>"
		dat += "<p><a href='byond://?src=[REF(src)];action=logout'>Завершить сеанс и сохранить</a></p><hr>"
		dat += "<h3>Предметы внутри:</h3>"

		if(!contents.len)
			dat += "<i>Хранилище пусто. Возьмите предмет в активную руку и нажмите им по терминалу.</i>"
		else
			dat += "<table width='100%' border='1' cellspacing='0' cellpadding='4'>"
			for(var/obj/item/I in contents)
				dat += "<tr>"
				dat += "<td><b>[I.name]</b></td>"
				dat += "<td width='120' align='center'><a href='byond://?src=[REF(src)];action=withdraw;item=[REF(I)]'>Извлечь</a></td>"
				dat += "</tr>"
			dat += "</table>"

	var/datum/browser/popup = new(user, "personal_stash", name, 480, 520)
	popup.set_content(dat.Join(""))
	popup.open()

/obj/structure/personal_stash/Topic(href, href_list)
	if(..())
		return TRUE

	var/mob/living/carbon/human/user = usr
	if(!istype(user) || !Adjacent(user))
		return FALSE

	switch(href_list["action"])
		if("login")
			if(unique_id)
				to_chat(user, "<span class='warning'>Терминал уже используется!</span>")
				return TRUE
			if(user.ckey in GLOB.accessed_personal_stashes)
				to_chat(user, "<span class='warning'>Ваш тайник уже открыт на другом терминале!</span>")
				return TRUE

			unique_id = user.ckey
			GLOB.accessed_personal_stashes += unique_id
			load_stash_data(unique_id)
//			playsound(src, 'sound/machines/terminal_button01.ogg', 30, FALSE)
			interact(user)
			return TRUE

		if("logout")
			if(unique_id == user.ckey)
				unload_stash_data()
//				playsound(src, 'sound/machines/terminal_button01.ogg', 30, FALSE)
				to_chat(user, "<span class='notice'>Сеанс завершен, предметы синхронизированы с базой данных.</span>")
				interact(user)
			return TRUE

		if("withdraw")
			if(!unique_id || unique_id != user.ckey)
				return TRUE

			var/obj/item/target_item = locate(href_list["item"]) in contents
			if(!target_item)
				interact(user)
				return TRUE

			if(user.put_in_hands(target_item))
				to_chat(user, "<span class='notice'>Вы извлекли [target_item] из хранилища.</span>")
			else
				target_item.forceMove(drop_location())
				to_chat(user, "<span class='notice'>Руки заняты: [target_item] падает под ноги.</span>")

			target_item.update_icon()
//			playsound(src, 'sound/handling/click_2.ogg', 30, FALSE)
			save_stash_data(unique_id)
			interact(user)
			return TRUE

/obj/structure/personal_stash/attackby(obj/item/I, mob/user, params)
	if(!unique_id)
		to_chat(user, "<span class='warning'>Сначала авторизуйтесь в терминале через интерфейс!</span>")
		return

	if(user.ckey != unique_id)
		to_chat(user, "<span class='danger'>Этот терминал занят чужой сессией!</span>")
		return

	if(contents.len >= max_storage)
		to_chat(user, "<span class='warning'>Хранилище заполнено до предела ([max_storage] шт.)!</span>")
		return

	if(!user.transferItemToLoc(I, src))
		return ..()

	to_chat(user, "<span class='notice'>Вы помещаете [I] в персональное хранилище.</span>")
//	playsound(src, 'sound/handling/click_2.ogg', 30, FALSE)
	save_stash_data(unique_id)
	interact(user)


//////////////////////////
// СИСТЕМА СОХРАНЕНИЯ   //
//////////////////////////

/obj/structure/personal_stash/proc/get_save_path(ckey)
	return "data/player_saves/[copytext(ckey, 1, 2)]/[ckey]/stash.json"

/obj/structure/personal_stash/proc/save_stash_data(ckey)
	if(!ckey)
		return

	var/file_path = get_save_path(ckey)
	var/list/data2save = list()

	for(var/i in 1 to contents.len)
		var/obj/item/I = contents[i]
		if(istype(I))
			data2save["[I.type]_[i]"] = get_vars(I, 0)

	fdel(file_path)
	WRITE_FILE(file(file_path), json_encode(data2save))

/obj/structure/personal_stash/proc/load_stash_data(ckey)
	var/file_path = get_save_path(ckey)
	if(!fexists(file_path))
		return

	var/raw_json = file2text(file_path)
	if(!raw_json)
		return

	var/list/json = json_decode(raw_json)
	if(!islist(json))
		return

	for(var/key in json)
		var/list/loaded_item_template = json[key]
		if(islist(loaded_item_template))
			recreate_item(loaded_item_template, src)

/obj/structure/personal_stash/proc/unload_stash_data()
	if(!unique_id)
		return

	save_stash_data(unique_id)
	GLOB.accessed_personal_stashes -= unique_id
	unique_id = null

	var/list/items_to_del = contents.Copy()
	for(var/obj/item/I in items_to_del)
		if(!QDELETED(I))
			qdel(I)

/obj/structure/personal_stash/Destroy()
	if(unique_id)
		unload_stash_data()
	return ..()


////////////////////////////////////
// СЕРИАЛИЗАЦИЯ И ВОССОЗДАНИЕ     //
////////////////////////////////////

/// Безопасное удаление значения переменной (защищает от передачи typepath в qdel)
/obj/structure/personal_stash/proc/safe_qdel_var(datum/holder, var_name)
	if(!holder || !(var_name in holder.vars))
		return
	var/val = holder.vars[var_name]
	if(!ispath(val) && istype(val, /datum))
		var/datum/D = val
		if(!QDELETED(D))
			qdel(D)
	holder.vars[var_name] = null

/// Проверяет, нужно ли игнорировать внутренний объект в contents при сохранении и очистке
/obj/structure/personal_stash/proc/is_internal_ignored_item(obj/item/parent, atom/child)
	if(!istype(child, /obj/item))
		return TRUE // Игнорируем не-предметы
	if(istype(child, /obj/item/ammo_casing/energy))
		return TRUE // Не трогаем внутренние режимы стрельбы энергооружия
	if(("paddles" in parent.vars) && parent.vars["paddles"] == child)
		return TRUE // Не трогаем привязанные электроды дефибриллятора
	if(("loaded_projectile" in parent.vars) && parent.vars["loaded_projectile"] == child)
		return TRUE // Не трогаем пулю внутри гильзы
	if(istype(parent, /obj/item/ammo_box))
		var/obj/item/ammo_box/AB = parent
		if(islist(AB.stored_ammo) && (child in AB.stored_ammo))
			return TRUE // Патроны магазина сохраняются отдельно через список stored_ammo
	return FALSE

/// Сбор переменных предмета в словарь для JSON
/obj/structure/personal_stash/proc/get_vars(obj/item/item, iteration = 0)
	if(!istype(item) || !item.vars)
		return null

	var/list/item_entry = list()
	item_entry["item"] = "[item.type]"

	// Сохраняем состояние стреляной гильзы (в Bandastation пуля хранится в loaded_projectile)
	if(istype(item, /obj/item/ammo_casing))
		if(("loaded_projectile" in item.vars) && !item.vars["loaded_projectile"])
			item_entry["spent"] = TRUE

	// Сохраняем реагенты (шприцы, мензурки, сварочники, баллончики, бутылки)
	if(item.reagents && islist(item.reagents.reagent_list) && item.reagents.reagent_list.len)
		var/list/reagent_data = list()
		for(var/datum/reagent/R in item.reagents.reagent_list)
			reagent_data += list(list("type" = "[R.type]", "volume" = R.volume))
		item_entry["reagents_data"] = reagent_data

	// Отдельно сохраняем contents (так как atom.contents в BYOND — системный список)
	var/list/saved_contents = save_contents_list(item, iteration + 1)
	item_entry["contents"] = saved_contents

	for(var/V in allowed_vars)
		if(V == "contents")
			continue
		if(!(V in item.vars))
			continue

		if(V == "name" && item.name == initial(item.name))
			continue
		if(V == "desc" && item.desc == initial(item.desc))
			continue

		var/val = item.vars[V]

		if(islist(val))
			var/list/list_var = val
			item_entry[V] = save_list(list_var, iteration + 1, V, item)
		else if(!ispath(val) && istype(val, /datum))
			var/datum/D = val
			item_entry[V] = "[D.type]"
		else if(isnull(val) || isnum(val) || istext(val))
			item_entry[V] = val
		else if(ispath(val))
			item_entry[V] = "[val]"

	return item_entry

/// Сериализация вложенных предметов из atom.contents
/obj/structure/personal_stash/proc/save_contents_list(obj/item/parent, iteration)
	var/list/contents_list = list()
	if(iteration > 20)
		return contents_list

	var/idx = 0
	for(var/obj/item/child in parent.contents)
		if(is_internal_ignored_item(parent, child))
			continue
		var/list/child_data = get_vars(child, iteration + 1)
		if(child_data)
			idx++
			contents_list["contents_[idx]"] = child_data

	return contents_list

/// Сериализация обычных списков (stored_ammo и др.)
/obj/structure/personal_stash/proc/save_list(list/list2save, iteration, var_name, obj/item/parent)
	var/list/result_list = list()
	if(iteration > 20)
		return result_list

	for(var/index in 1 to list2save.len)
		var/element = list2save[index]
		if(isnull(element))
			continue

		// В Bandastation элемент stored_ammo может быть как typepath (ленивый патрон), так и созданным объектом /obj/item/ammo_casing
		if(var_name == "stored_ammo")
			if(ispath(element))
				result_list["[var_name]_[index]"] = "[element]"
			else if(istype(element, /obj/item))
				var/list/casing_data = get_vars(element, iteration + 1)
				if(casing_data)
					result_list["[var_name]_[index]"] = casing_data
			continue

		if(!ispath(element) && istype(element, /datum))
			var/datum/T = element
			result_list["[var_name]_[index]"] = "[T.type]"

		else if(isnum(element) || istext(element))
			result_list["[var_name]_[index]"] = element

		else if(ispath(element))
			result_list["[var_name]_[index]"] = "[element]"

	return result_list

/// Очистка дефолтных предметов, которые автоматически создались в Initialize() нового объекта
/obj/structure/personal_stash/proc/clear_default_contents(obj/item/loaded_item, list/item_template)
	// 1. Безопасно очищаем дефолтные патроны в магазинах и коробках с патронами
	if(istype(loaded_item, /obj/item/ammo_box))
		var/obj/item/ammo_box/AB = loaded_item
		if(islist(AB.stored_ammo))
			var/list/ammo_copy = AB.stored_ammo.Copy()
			AB.stored_ammo.Cut()
			for(var/ammo in ammo_copy)
				if(!ispath(ammo) && istype(ammo, /datum))
					var/datum/D = ammo
					if(!QDELETED(D))
						qdel(D)

	// 2. Безопасно очищаем дефолтный магазин, патрон в патроннике и штык у огнестрельного оружия
	if(istype(loaded_item, /obj/item/gun/ballistic))
		var/obj/item/gun/ballistic/BG = loaded_item
		safe_qdel_var(BG, "magazine")
		safe_qdel_var(BG, "chambered")
		safe_qdel_var(BG, "bayonet")

	// 3. Безопасно очищаем дефолтный ударник/спусковой крючок у оружия, если он сохранен в шаблоне
	if(istype(loaded_item, /obj/item/gun))
		var/obj/item/gun/G = loaded_item
		if("pin" in item_template)
			safe_qdel_var(G, "pin")

	// 4. Безопасно очищаем дефолтную батарейку у приборов/оружия/дефибрилляторов
	safe_qdel_var(loaded_item, "cell")
	safe_qdel_var(loaded_item, "bcell")

	// 5. Безопасно очищаем остальные дефолтные предметы из contents (по копии списка)
	var/list/children_copy = loaded_item.contents.Copy()
	for(var/obj/item/child in children_copy)
		if(QDELETED(child))
			continue
		if(is_internal_ignored_item(loaded_item, child))
			continue
		if(istype(loaded_item, /obj/item/gun) && istype(child, /obj/item/firing_pin) && !("pin" in item_template))
			continue
		qdel(child)

/// Поиск дочернего предмета в contents по типу
/obj/structure/personal_stash/proc/locate_item(obj/container, path, list/exclude_list = null)
	if(!container || !path)
		return null

	for(var/obj/item/I in container.contents)
		if(I.type == path)
			if(exclude_list && (I in exclude_list))
				continue
			return I
	return null

/// Рекурсивное воссоздание предмета и всех его свойств из шаблона
/obj/structure/personal_stash/proc/recreate_item(list/item_template, atom/location)
	if(!islist(item_template) || !item_template["item"])
		return null

	var/item_path = text2path(item_template["item"])
	if(!ispath(item_path, /obj/item))
		return null

	var/obj/item/loaded_item = new item_path(location)

	// Стреляная гильза: удаляем пулю loaded_projectile, созданную в Initialize()
	if(item_template["spent"] && istype(loaded_item, /obj/item/ammo_casing))
		safe_qdel_var(loaded_item, "loaded_projectile")
		loaded_item.update_icon()

	// Восстанавливаем реагенты, если они были сохранены
	if(islist(item_template["reagents_data"]) && loaded_item.reagents)
		loaded_item.reagents.clear_reagents()
		for(var/list/R_info in item_template["reagents_data"])
			var/r_path = text2path(R_info["type"])
			var/r_vol = R_info["volume"]
			if(r_path && isnum(r_vol))
				loaded_item.reagents.add_reagent(r_path, r_vol)

	// ШАГ 1: Очищаем дефолтные объекты из Initialize() и воссоздаем contents
	if(("contents" in item_template) || ("stored_ammo" in item_template))
		clear_default_contents(loaded_item, item_template)

	if("contents" in item_template)
		var/list/contents_template = item_template["contents"]
		if(islist(contents_template))
			for(var/idx in contents_template)
				var/val = contents_template[idx]
				if(islist(val))
					recreate_item(val, loaded_item)

	// ШАГ 2: Восстанавливаем остальные переменные из allowed_vars
	for(var/key in allowed_vars)
		if(key == "contents")
			continue
		if(!(key in loaded_item.vars) || !(key in item_template))
			continue

		var/template_val = item_template[key]

		if(isnull(template_val))
			loaded_item.vars[key] = null
			continue

		// Специальная обработка списка патронов stored_ammo
		if(key == "stored_ammo" && islist(template_val))
			var/list/new_ammo_list = list()
			loaded_item.vars[key] = new_ammo_list

			for(var/idx in template_val)
				var/val = template_val[idx]
				// Если патрон был сохранен как созданный объект (словарь свойств)
				if(islist(val))
					var/obj/item/ammo_casing/AC = recreate_item(val, loaded_item)
					if(istype(AC))
						new_ammo_list += AC
				// Если патрон был сохранен как ленивый typepath (строка пути)
				else if(istext(val))
					var/parsed_path = text2path(val)
					if(ispath(parsed_path, /obj/item/ammo_casing))
						new_ammo_list += parsed_path
			continue

		if(islist(template_val))
			var/list/new_list = list()
			loaded_item.vars[key] = new_list

			for(var/idx in template_val)
				var/val = template_val[idx]
				var/parsed_path = text2path(val)
				if(parsed_path)
					var/found = locate_item(loaded_item, parsed_path, new_list)
					if(found)
						new_list += found
						continue
				new_list += val

		else if(key == "magazine")
			var/obj/item/gun/ballistic/gun = loaded_item
			if(istype(gun))
				gun.magazine = locate_item(loaded_item, text2path(template_val))

		else if(key == "chambered")
			var/obj/item/gun/ballistic/gun = loaded_item
			if(istype(gun))
				var/obj/item/ammo_casing/AC = locate_item(loaded_item, text2path(template_val))
				if(!AC && gun.magazine && length(gun.magazine.stored_ammo))
					var/first_ammo = gun.magazine.stored_ammo[1]
					if(istype(first_ammo, /obj/item/ammo_casing))
						AC = first_ammo
				gun.chambered = AC

		else if(key == "pin")
			var/obj/item/gun/gun = loaded_item
			if(istype(gun))
				var/pin_path = text2path(template_val)
				var/obj/item/firing_pin/FP = locate_item(loaded_item, pin_path)
				if(!FP && ispath(pin_path, /obj/item/firing_pin))
					FP = new pin_path(loaded_item)
				gun.pin = FP

		else if(key == "cell" || key == "bcell" || key == "stored_item" || key == "bayonet")
			loaded_item.vars[key] = locate_item(loaded_item, text2path(template_val))

		else
			var/parsed_path = text2path(template_val)
			if(parsed_path)
				var/found = locate_item(loaded_item, parsed_path)
				loaded_item.vars[key] = found ? found : parsed_path
			else
				loaded_item.vars[key] = template_val

	// Защита для старых сохранений оружия, где переменная "pin" еще не записывалась в JSON
	if(istype(loaded_item, /obj/item/gun))
		var/obj/item/gun/G = loaded_item
		if(!G.pin && !("pin" in item_template))
			var/obj/item/firing_pin/existing_pin = locate(/obj/item/firing_pin) in G.contents
			if(existing_pin)
				G.pin = existing_pin
			else
				var/default_pin_type = initial(G.pin)
				if(ispath(default_pin_type))
					G.pin = new default_pin_type(G)

	loaded_item.update_icon()
	return loaded_item
