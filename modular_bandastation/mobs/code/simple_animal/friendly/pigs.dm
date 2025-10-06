/mob/living/basic/pig
	icon = 'modular_bandastation/mobs/icons/pigs.dmi'
	icon_state = "pig"
	icon_living = "pig"
	icon_dead = "pig_dead"
	icon_resting = "pig_rest"
	icon_gib = "gib"
	attack_verb_continuous = "лягает"
	attack_verb_simple = "лягает"
	death_sound = 'modular_bandastation/mobs/sound/pig_death.ogg'

	// Переменные для перекрашивания
	/// Будем пытаться перекрасить при инициализации?
	var/need_recolor = TRUE
	/// Определение icon_state
	var/body_icon_state  = "pig"
	/// Черный, маринадный, дефолтный.
	var/body_color
	/// Шанс покрасить в другой цвет
	var/color_chance = 5
	/// Какой цвет перекраски возможен. null - дефолт
	var/list/possible_body_colors = list("black")

/mob/living/basic/pig/Initialize(mapload)
	. = ..()
	try_recolor()

/mob/living/basic/pig/proc/try_recolor()
	if(!need_recolor)
		return
	if(isnull(body_icon_state) || isnull(possible_body_colors) || !length(possible_body_colors))
		WARNING("У [src] не определены переменные для перекраски")
		return
	if(!prob(color_chance))
		return
	var/picked_color = possible_body_colors
	if(!isnull(body_icon_state))
		AddElement(/datum/element/animal_variety, "[body_icon_state]", "[picked_color]", modify_pixels = FALSE)

/mob/living/basic/pig/baby
	name = "поросенок"
	desc = "Маленький и смышленный, его ждет вкусное будущее!"
	body_icon_state = "pig_baby"

/mob/living/basic/pig/baby/teen
	name = "подсвинок"
	desc = "Задорная хрюшка, готовая к приключениям на кухне!"
	body_icon_state = "pig_teen"

/mob/living/basic/pig/baby/young
	name = "свинка"
	desc = "Молодая и пухленькая, полна сил и хрюканья."
	body_icon_state = "pig_young"

/mob/living/basic/pig
	name = "свинья"
	desc = "Классическая хрюшка, что-то среднее между кормушкой и копилкой."
	body_icon_state = "pig"

/mob/living/basic/pig/adult
	name = "свин"
	desc = "Здоровенный хрюндель, внушает уважение своим видом."
	body_icon_state = "pig_adult"

/mob/living/basic/pig/old
	name = "хряк"
	desc = "Старый и опытный, накопивший огромное достоинство."
	body_icon_state = "pig_old"

/mob/living/basic/pig/old/ancient
	name = "прахряк"
	desc = "Легенда свинарника, древний хрюкун, переживший больше обедов, чем можно сосчитать."
	body_icon_state = "pig_ancient"





/mob/living/basic/pig
	icon = 'modular_bandastation/mobs/icons/pigs.dmi'
	icon_state = "pig"
	icon_living = "pig"
	icon_dead = "pig_dead"
	icon_resting = "pig_rest"
	icon_gib = "gib"
	attack_verb_continuous = "лягает"
	attack_verb_simple = "лягает"
	death_sound = 'modular_bandastation/mobs/sound/pig_death.ogg'

/mob/living/basic/pig/big
	name = "хряк"
	desc = "Большой упитанный толстый порось. В нем много мяса."
	icon_state = "pig_big"
	icon_living = "pig_big"
	icon_dead = "pig_big_dead"
	icon_resting = "pig_big_rest"
	health = 100
	maxHealth = 100
	speed = 2
	butcher_results = list(/obj/item/food/meat/slab/pig = 12)

	ai_controller = /datum/ai_controller/basic_controller/pig/big

/mob/living/basic/pig/big/old
	name = "боров"
	desc = "Большой старый упитанный хряк. В нем очень много мяса."
	icon_state = "pig_hog"
	icon_living = "pig_hog"
	icon_dead = "pig_hog_dead"
	icon_resting = "pig_hog_rest"
	health = 150
	maxHealth = 150
	speed = 3
	butcher_results = list(/obj/item/food/meat/slab/pig = 18)
