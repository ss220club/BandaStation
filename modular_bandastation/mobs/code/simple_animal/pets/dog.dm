/mob/living/basic/pet/dog
	icon = 'modular_bandastation/mobs/icons/mob/pets.dmi'
	maxHealth = 50
	health = 50
	melee_damage_type = STAMINA
	melee_damage_lower = 6
	melee_damage_upper = 10
	attack_verb_continuous = "вгрызается"
	attack_verb_simple = "кусает"
	var/growl_sound = list('modular_bandastation/mobs/sound/dog_grawl1.ogg','modular_bandastation/mobs/sound/dog_grawl2.ogg') //Used in emote.

	butcher_results = list(/obj/item/food/meat/slab/corgi/dog = 4)

/mob/living/basic/pet/dog/attack_hand(mob/living/carbon/human/user, list/modifiers)
	. = ..()
	if(user.combat_mode)
		wuv(-1, user)
	else
		wuv(1, user)

/mob/living/basic/pet/dog/proc/wuv(change, mob/M)
	if(change)
		if(change > 0)
			if(M && stat != DEAD) // Added check to see if this mob (the corgi) is dead to fix issue 2454
				new /obj/effect/temp_visual/heart(loc)
				manual_emote("счастливо скулит!")
		else
			if(M && stat != DEAD) // Same check here, even though emote checks it as well (poor form to check it only in the help case)
				emote("growl")
				playsound(src, pick(src.growl_sound), 75, TRUE)


/mob/living/basic/pet/dog/corgi
	// holder_type = /obj/item/holder/corgi

/mob/living/basic/pet/dog/corgi/ian/Initialize(mapload)
	. = ..()
	//if(age == record_age)
		// holder_type = /obj/item/holder/old_corgi

/mob/living/basic/pet/dog/corgi/narsie
	maxHealth = 300
	health = 300
	melee_damage_type = STAMINA	//Пади ниц!
	melee_damage_lower = 50
	melee_damage_upper = 100
	// holder_type = /obj/item/holder/narsian

/mob/living/basic/pet/dog/corgi/puppy
	maxHealth = 20
	health = 20
	butcher_results = list(/obj/item/food/meat/slab/corgi = 1)

/mob/living/basic/pet/dog/corgi/puppy/void
	maxHealth = 80
	health = 80
	// holder_type = /obj/item/holder/void_puppy

/mob/living/basic/pet/dog/corgi/puppy/slime
	name = "\improper slime puppy"
	real_name = "slimy"
	desc = "Крайне склизкий. Но прикольный!"
	icon_state = "slime_puppy"
	icon_living = "slime_puppy"
	icon_dead = "slime_puppy_dead"
	habitable_atmos = null
	minimum_survivable_temperature = 250 //Weak to cold
	maximum_survivable_temperature = INFINITY
	// holder_type = /obj/item/holder/slime_puppy

/mob/living/basic/pet/dog/corgi/lisa
	// holder_type = /obj/item/holder/lisa

/mob/living/basic/pet/dog/pug
	// holder_type = /obj/item/holder/pug

/mob/living/basic/pet/dog/bullterrier
	// holder_type = /obj/item/holder/bullterrier

/mob/living/basic/pet/dog/tamaskan
	name = "tamaskan"
	real_name = "tamaskan"
	desc = "Хорошая семейная собака. Уживается с другими собаками и ассистентами."
	icon = 'modular_bandastation/mobs/icons/mob/pets.dmi'
	icon_state = "tamaskan"
	icon_living = "tamaskan"
	icon_dead = "tamaskan_dead"
	// holder_type = /obj/item/holder/bullterrier

/mob/living/basic/pet/dog/german
	name = "german"
	real_name = "german"
	desc = "Немецкая овчарка с помесью двортерьера. Судя по крупу - явно не породистый."
	icon = 'modular_bandastation/mobs/icons/mob/pets.dmi'
	icon_state = "german"
	icon_living = "german"
	icon_dead = "german_dead"

/mob/living/basic/pet/dog/brittany
	name = "brittany"
	real_name = "brittany"
	desc = "Старая порода, которую любят аристократы."
	icon = 'modular_bandastation/mobs/icons/mob/pets.dmi'
	icon_state = "brittany"
	icon_living = "brittany"
	icon_dead = "brittany_dead"



// named
/mob/living/basic/pet/dog/brittany/psycho
	name = "Перрито"
	real_name = "Перрито"
	desc = "Собака, обожающая котов, особенно в сапогах, прекрасно лающая на Испанском, прошла терапевтические курсы, готова выслушать все ваши проблемы и выдать вам целебных объятий с завершением в виде почесыванием животика."
	icon = 'modular_bandastation/mobs/icons/mob/pets.dmi'
	resting = TRUE
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE

/mob/living/basic/pet/dog/pug/frank
	name = "Фрэнк"
	real_name = "Фрэнк"
	desc = "Мопс полученный в результате эксперимента ученых в черном. Почему его не забрали интересный вопрос. Похоже он всем надоел своей болтовней, после чего его лишили дара речи."
	resting = TRUE
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE

/mob/living/basic/pet/dog/bullterrier/genn
	name = "Геннадий"
	desc = "Собачий аристократ. Выглядит очень важным и начитанным. Доброжелательный любимец ассистентов."
	icon = 'modular_bandastation/mobs/icons/mob/pets.dmi'
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE
	resting = TRUE

