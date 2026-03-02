/datum/action/innate/notes
	name = "Заметки"
	button_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "pda"
	var/save_path = "data/XenobioNotes.json"

/datum/action/innate/notes/Activate()
	if(!target || !isliving(owner))
		return

	ui_interact(owner)

/datum/action/innate/notes/ui_interact(mob/user)
	var/current_notes = load_notes()

	var/new_notes = tgui_input_text(
		user = user,
		message = "Запишите здесь результаты экспериментов или текущие рецепты. Заметки общие для всех ученых и сохраняются между сменами.",
		title = "Заметки",
		default = current_notes,
		max_length = 9999,
		multiline = TRUE,
		encode = FALSE
	)

	if(isnull(new_notes))
		return

	if(new_notes != current_notes)
		var/confirmation = tgui_alert(user, "Сохранить изменения в общих заметках?", "Подтверждение", list("Да", "Нет"))

		if(confirmation != "Да")
			to_chat(user, span_warning("Изменения не сохранены."))
			return

	save_notes(new_notes)
	to_chat(user, span_nicegreen("Заметки успешно обновлены."))
	log_game("Xenobio Notes: [key_name(user)] updated notes. Text: [new_notes]")

/datum/action/innate/notes/proc/load_notes()
	var/json_file = file(save_path)
	if(!fexists(json_file))
		return ""

	var/list/data = json_decode(file2text(json_file))

	var/recipe_timestamp
	for(var/reagent_id in GLOB.chemical_reactions_list_reactant_index)
		for(var/datum/chemical_reaction/slime/R in GLOB.chemical_reactions_list_reactant_index[reagent_id])
			if(istype(R) && R.randomized)
				recipe_timestamp = R.created
				break
		if(recipe_timestamp)
			break

	// в идеальном мире это надо отслеживать читая метадату файла нотесов
	if(data["timestamp"] && recipe_timestamp && data["timestamp"] < recipe_timestamp)
		return "Старые записи стерты из-за смены селекции мутаций"

	return data["text"]

/datum/action/innate/notes/proc/save_notes(new_text)
	var/list/data = list(
		"text" = new_text,
		"timestamp" = world.realtime
	)

	var/json_file = file(save_path)
	if(fexists(json_file))
		fdel(json_file)
	WRITE_FILE(json_file, json_encode(data))

/obj/item/paper/fluff/xenobio_console_note
	name = "заметка у консоли ксенобиологии"
	default_raw_text = {"Приветствую коллега! На нашу станцию поставили мутированный подвид слаймов для разведения, - они стали изменчивы!
	<br>Каждые пару дней что-то происходит в их ДНК, и реакции их ядер на раздражители и реагенты меняются. Записывай находки в разделе \"Заметки\" на консоли.
	<br>Чтобы исследовать возможные реакции слайма - просканируй слайма ручным сканнером, и загрузи данные в консоль, или воспользуйся реконструктором реакций."
	<br>Удачных экспериментов!"}

/obj/machinery/computer/camera_advanced/xenobio/Initialize(mapload)
	actions += new /datum/action/innate/notes(src)
	actions += new /datum/action/innate/xenobio_recipes(src)
	. = ..()
	if(. != INITIALIZE_HINT_QDEL)
		var/turf/T = get_turf(src)
		if(T)
			new /obj/item/paper/fluff/xenobio_console_note(T)
			playsound(T, 'sound/items/handling/paper_drop.ogg', 30, TRUE)
