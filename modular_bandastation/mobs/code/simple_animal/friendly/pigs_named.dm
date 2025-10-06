
#define AGE_STAGE_1 "baby"
#define AGE_STAGE_2 "teen"
#define AGE_STAGE_3 "young"
#define AGE_STAGE_4 null // Так как нам не нужен icon_state под него
#define AGE_STAGE_5 "adult"
#define AGE_STAGE_6 "old"
#define AGE_STAGE_7 "ancient"
#define AGE_STAGE_DEFAULT null // Аналогично

// Базовый класс для запоминания возраста
/mob/living/basic/pig/named
	gold_core_spawnable = NO_SPAWN
	need_recolor = null // чтобы не перекрасил
	/// Отслеживает, сколько раундов выжила
	var/age = 0
	/// Вызов callback, выполняемый по завершении раунда, чтобы проверить, выжила ли свинья в раунде или нет
	var/datum/callback/i_will_survive

	/// Наивысшее количество раундов, в которых свинья выжила
	var/record_age = 1
	/// Сколько за каждый раунд будет добавляться "лет"
	var/addition_age = 1
	/// Со скольки лет начинает свою "новую жизнь"
	var/null_age = 0
	/// Словарь стадий: каждая стадия содержит имя и описание
	var/list/age_stage_data

	/// Записали ли мы уже достижения этой свиньи в базу данных?
	var/memory_saved = FALSE
	/// Имя с которым будет записываться в .json файл
	var/json_name = "pig"

/mob/living/basic/pig/named/Initialize(mapload)
	. = ..()
	// Ensure pig exists
	REGISTER_REQUIRED_MAP_ITEM(1, 1)

	//parent call must happen first to ensure pig
	//is not in nullspace when child puppies spawn
	Read_Memory()

	Setup_Memory()

	//setup roundend check for pig's whereabouts
	i_will_survive = CALLBACK(src, PROC_REF(check_survival))
	SSticker.OnRoundend(i_will_survive)

// Удаляем - выпиливаем callback чтобы не записало в память
/mob/living/basic/pig/named/Destroy()
	LAZYREMOVE(SSticker.round_end_events, i_will_survive) //cleanup the survival callback
	i_will_survive = null
	return ..()

// Записываем память только при смерти гиббом (мясо выпало - значит увыргск)
/mob/living/basic/pig/named/death(gibbed)
	if(!memory_saved && gibbed)
		Write_Memory(TRUE, gibbed)
	. = ..()

/mob/living/basic/pig/named/gib()
	if(!memory_saved)
		Write_Memory(TRUE, gibbed)
	. = ..()

/mob/living/basic/pig/named/Write_Memory(dead, gibbed)
	. = ..()
	if(!.)
		return
	memory_saved = TRUE
	var/json_file = file("data/npc_saves/[json_name].json")
	var/list/file_data = list()
	if(!gibbed)
		file_data["age"] = age + addition_age
		if((age + addition_age) > record_age)
			file_data["record_age"] = record_age + addition_age
		else
			file_data["record_age"] = record_age
	else
		file_data["age"] = null_age
		file_data["record_age"] = record_age
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(file_data))

/// Считывает файл сохранения .JSON и устанавливает age, record_age.
/mob/living/basic/pig/named/proc/Read_Memory()
	var/json_file = file("data/npc_saves/[json_name].json")
	if(!fexists(json_file))
		return
	var/list/json = json_decode(file2text(json_file))
	age = json["age"]
	record_age = json["record_age"]
	if(isnull(age))
		age = null_age
	if(isnull(record_age))
		record_age = addition_age

/// Проверяет, выжил ли в раунде или нет.
/mob/living/basic/pig/named/proc/check_survival()
	if(!stat && !memory_saved)
		Write_Memory(FALSE)

// =================================
// Загрузка характеристик из памяти
// =================================

/// Устанавливаем характеристики хрюшки после загрузки "памяти".
/mob/living/basic/pig/named/proc/Setup_Memory()
	var/stage = get_age_stage()
	var/suffix = get_suffix()

	// применяем характеристики
	switch(stage)
		if(AGE_STAGE_1) Apply_StatsFrom(/mob/living/basic/pig/baby)
		if(AGE_STAGE_2) Apply_StatsFrom(/mob/living/basic/pig/baby/teen)
		if(AGE_STAGE_3) Apply_StatsFrom(/mob/living/basic/pig/baby/young)
		if(AGE_STAGE_4) Apply_StatsFrom(/mob/living/basic/pig)
		if(AGE_STAGE_5) Apply_StatsFrom(/mob/living/basic/pig/adult)
		if(AGE_STAGE_6) Apply_StatsFrom(/mob/living/basic/pig/old)
		if(AGE_STAGE_7) Apply_StatsFrom(/mob/living/basic/pig/old/ancient)

	// собираем финальный спрайт
	var/final_icon = "[body_icon_state]"
	if(!isnull(stage))
		final_icon = "[final_icon]_[stage]"
	if(suffix)
		final_icon += suffix

	icon_state = final_icon
	icon_living = final_icon
	icon_resting = "[final_icon]_rest"
	icon_dead = "[final_icon]_dead"

	// подгружаем имя и описание из age_stage_data
	if(age_stage_data[stage])
		var/list/data = age_stage_data[stage]
		name = data["name"]
		desc = data["desc"]

/mob/living/basic/pig/named/proc/get_age_stage()
	switch(age)
		if(0 to 1)
			return AGE_STAGE_1
		if(2 to 3)
			return AGE_STAGE_2
		if(4 to 5)
			return AGE_STAGE_3
		if(6 to 7)
			return AGE_STAGE_4
		if(8 to 9)
			return AGE_STAGE_5
		if(10 to 11)
			return AGE_STAGE_6
		if(12 to INFINITY)
			return AGE_STAGE_7
	return AGE_STAGE_DEFAULT

/mob/living/basic/pig/named/proc/get_suffix()
	if(istype(src, /mob/living/basic/pig/named/Yanas))
		return "_black"
	if(istype(src, /mob/living/basic/pig/named/Marina))
		return "_mar"
	return ""

/// Копирование характеристик из шаблона
/mob/living/basic/pig/named/proc/apply_stats_from(var/typepath)
	var/mob/template = new typepath
	speed = template.speed
	health = template.health
	maxHealth = template.maxHealth
	ai_controller = template.ai_controller
	qdel(template)


// =================================
// Именованные хрюшки
// =================================

// Саня
/mob/living/basic/pig/named/Sanya
	gender = MALE
	json_name = "pig_sanya"

// Янас - инвертация Сани в виде черного хряка
/mob/living/basic/pig/named/Yanas
	gender = MALE
	json_name = "pig_yanas"

// Марина
/mob/living/basic/pig/named/Marina
	gender = FEMALE
	json_name = "pig_marina"
	age_stage_data = list(
		AGE_STAGE_1 = list("name" = "Маринка", "desc" = "Маленькая свинка с характером."),
		"adult" = list("name" = "Марина", "desc" = "Крепкая свинья, умеющая настоять на своём."),
		"ancient" = list("name" = "Марина-матрона", "desc" = "Древняя мудрая свиноматка.")
	)

поедатель змей в маринаде

#undef AGE_STAGE_1 // baby
#undef AGE_STAGE_2 // teen
#undef AGE_STAGE_3 // young
#undef AGE_STAGE_4 // null
#undef AGE_STAGE_5 // adult
#undef AGE_STAGE_6 // old
#undef AGE_STAGE_7 // ancient
#undef AGE_STAGE_DEFAULT
