/datum/mood_event/hug
	description = "Люблю обнимашки."
	mood_change = 1
	timeout = 2 MINUTES

/datum/mood_event/hug/add_effects()
	if(HAS_PERSONALITY(owner, /datum/personality/aromantic))
		mood_change = -1
		description = "Обнимашки? Я звоню в отдел кадров!"
		return
	if(HAS_PERSONALITY(owner, /datum/personality/aloof))
		mood_change = -1
		description = "Я бы предпочел, чтобы меня не трогали."
		return
	if(HAS_PERSONALITY(owner, /datum/personality/callous))
		mood_change = 0
		description = "Я ненавижу обнимашки."
		return

/datum/mood_event/bear_hug
	description = "Меня очень сильно обняли, но это было довольно приятно."
	mood_change = 1
	timeout = 2 MINUTES

/datum/mood_event/bear_hug/add_effects()
	if(HAS_PERSONALITY(owner, /datum/personality/aromantic) \
		|| HAS_PERSONALITY(owner, /datum/personality/aloof) \
		|| HAS_PERSONALITY(owner, /datum/personality/callous) \
	)
		mood_change = -2
		description = "Они сжимают меня слишком сильно!"
		return

/datum/mood_event/betterhug
	description = "Кто-то был очень добр ко мне."
	mood_change = 3
	timeout = 4 MINUTES

/datum/mood_event/betterhug/add_effects(mob/friend)
	if(HAS_PERSONALITY(owner, /datum/personality/aromantic))
		mood_change = 1
		description = "[capitalize(friend.declent_ru(NOMINATIVE))] мил, но это всё."
		return
	if(HAS_PERSONALITY(owner, /datum/personality/aloof))
		mood_change = 1
		description = "[capitalize(friend.declent_ru(NOMINATIVE))] мил, но я бы предпочел, чтобы меня не трогали."
		return
	if(HAS_PERSONALITY(owner, /datum/personality/callous))
		mood_change = 0
		description = "[capitalize(friend.declent_ru(NOMINATIVE))] слишком мил для этой станции."
		return

	description = "[capitalize(friend.declent_ru(NOMINATIVE))] был очень добр ко мне."

/datum/mood_event/besthug
	description = "Весело находиться рядом с кем-то, не могу нарадоваться!"
	mood_change = 5
	timeout = 4 MINUTES

/datum/mood_event/besthug/add_effects(mob/friend)
	if(HAS_PERSONALITY(owner, /datum/personality/aromantic))
		mood_change = 2
		description = "Весело находиться рядом с [friend.declent_ru(NOMINATIVE)] но это всё."
		return
	if(HAS_PERSONALITY(owner, /datum/personality/aloof))
		mood_change = 2
		description = "Весело находиться рядом с [friend.declent_ru(NOMINATIVE)], но я бы предпочел, чтобы меня не трогали."
		return
	if(HAS_PERSONALITY(owner, /datum/personality/callous))
		mood_change = 0
		description = "[friend.declent_ru(NOMINATIVE)] слишком мил для этой станции."
		return

	description = "Весело находиться рядом с [friend.declent_ru(INSTRUMENTAL)], не могу нарадоваться!"

/datum/mood_event/warmhug
	description = "Теплые и уютные обнимашки самые лучшие!"
	mood_change = 1
	timeout = 2 MINUTES

/datum/mood_event/warmhug/add_effects()
	if(HAS_PERSONALITY(owner, /datum/personality/aromantic))
		mood_change = 0
		description = "Я не люблю обнимашки, но тепло приятно..."
		return
	if(HAS_PERSONALITY(owner, /datum/personality/aloof))
		mood_change = 0
		description = "Я бы предпочел, чтобы меня не трогали, но тепло приятно..."
		return
	if(HAS_PERSONALITY(owner, /datum/personality/callous))
		mood_change = 0
		description = "Я ненавижу обнимашки. Я могу согреться сам."
		return

/datum/mood_event/tailpulled
	description = "Люблю, когда дергают за хвост!"
	mood_change = 1
	timeout = 2 MINUTES

/datum/mood_event/tailpulled/add_effects()
	if(HAS_PERSONALITY(owner, /datum/personality/aloof) \
		|| HAS_PERSONALITY(owner, /datum/personality/aromantic) \
		|| HAS_PERSONALITY(owner, /datum/personality/callous) \
	)
		mood_change = -2
		description = "Кто, чёрт возьми, трогает мой хвост?"

/datum/mood_event/arcade
	description = "Я победил в этой аркаде!"
	mood_change = 3
	timeout = 8 MINUTES
	event_flags = MOOD_EVENT_GAMING

/datum/mood_event/arcade/add_effects()
	if(HAS_PERSONALITY(owner, /datum/personality/industrious) || HAS_PERSONALITY(owner, /datum/personality/slacking/diligent))
		mood_change = -1
		description = "Вау, я прошел игру. Я мог бы делать что-то продуктивное вместо этого."

/datum/mood_event/blessing
	description = "Меня благословили."
	mood_change = 1
	timeout = 8 MINUTES
	event_flags = MOOD_EVENT_SPIRITUAL

/datum/mood_event/maintenance_adaptation
	mood_change = 8

/datum/mood_event/maintenance_adaptation/add_effects()
	description = "[GLOB.deity] помог мне адаптироваться к техническим помещениям!"

/datum/mood_event/book_nerd
	description = "Я недавно прочитал книгу."
	mood_change = 1
	timeout = 5 MINUTES

/datum/mood_event/book_nerd/add_effects()
	if(HAS_PERSONALITY(owner, /datum/personality/erudite))
		mood_change = 2
		description = "Я обожаю читать книги!"
	if(HAS_PERSONALITY(owner, /datum/personality/uneducated))
		mood_change = -1
		description = "Кому какое дело до книг?"

/datum/mood_event/exercise
	description = "Спорт высвобождает эндорфины!"
	mood_change = 1

/datum/mood_event/exercise/add_effects(fitness_level)
	mood_change = fitness_level // the more fit you are, the more you like to work out
	if(HAS_PERSONALITY(owner, /datum/personality/slacking/lazy))
		mood_change *= -0.5
		description = "Тренировки, какая рутина!"
	else if(!HAS_PERSONALITY(owner, /datum/personality/athletic))
		mood_change *= 0.5
		description = "Тренировки немного утомительны, но довольно приятны."

/datum/mood_event/pet_animal
	description = "Животные такие милые! Не могу перестать гладить!"
	timeout = 5 MINUTES
	/// Tracks the typepath of animal we last petted
	var/animal_type

/datum/mood_event/pet_animal/add_effects(mob/animal)
	animal_type = animal?.type

	if(HAS_PERSONALITY(owner, /datum/personality/animal_disliker))
		mood_change = -1
		description = "Фу, [animal.declent_ru(NOMINATIVE)] такой грязный! Я не хочу его трогать!"
		return

	var/dog_fan = HAS_PERSONALITY(owner, /datum/personality/dog_fan)
	var/isdog = istype(animal, /mob/living/basic/pet/dog)
	var/cat_fan = HAS_PERSONALITY(owner, /datum/personality/cat_fan)
	var/iscat = istype(animal, /mob/living/basic/pet/cat)
	if((dog_fan && isdog) || (cat_fan && iscat) || HAS_PERSONALITY(owner, /datum/personality/animal_friend))
		mood_change = 3
		description = "Я так люблю [animal.declent_ru(ACCUSATIVE)], [animal.ru_p_they()] такой очаровательный! Не могу перестать гладить [animal.p_them()]!"
		return
	if(dog_fan && iscat)
		mood_change = -1
		description = "Мне не нравится [animal.declent_ru(NOMINATIVE)]! Я предпочитаю собак!"
		return
	if(cat_fan && isdog)
		mood_change = -1
		description = "Мне не нравится [animal.declent_ru(NOMINATIVE)]! Я предпочитаю кошек!"
		return

	mood_change = 1
	description = "[animal.declent_ru(NOMINATIVE)] очарователен!"

// Change the moodlet if we get refreshed (we may have pet another type of animal)
/datum/mood_event/pet_animal/be_refreshed(datum/mood/home, mob/animal)
	. = ..()
	if(animal_type == animal?.type)
		return
	add_effects(animal)

/datum/mood_event/honk
	description = "Меня захонкали!"
	mood_change = 2
	timeout = 4 MINUTES
	special_screen_obj = "honked_nose"
	special_screen_replace = FALSE
	event_flags = MOOD_EVENT_WHIMSY

/datum/mood_event/saved_life
	description = "Приятно спасать жизни."
	mood_change = 6
	timeout = 8 MINUTES

/datum/mood_event/saved_life/add_effects()
	if(HAS_PERSONALITY(owner, /datum/personality/callous))
		mood_change = 0
		description = "Меня не особо волнует спасение жизней."
	if(HAS_PERSONALITY(owner, /datum/personality/misanthropic))
		mood_change = -1
		description = "Спасение жизней - пустая трата времени."

/datum/mood_event/oblivious
	description = "Какой прекрасный день."
	mood_change = 3

/datum/mood_event/jolly
	description = "Мне радостно без особой на то причины."
	mood_change = 6
	timeout = 2 MINUTES

/datum/mood_event/focused
	description = "У меня есть цель, и я её выполню, чего бы это не стоило!" //Used for syndies, nukeops etc so they can focus on their goals
	mood_change = 8
	hidden = TRUE

/datum/mood_event/badass_antag
	description = "Как же я чертовски крут, и все вокруг это знают. Только посмотрите на то, как они чертовски дрожат от одной только мысли о том, что я рядом."
	mood_change = 8
	hidden = TRUE
	special_screen_obj = "badass_sun"
	special_screen_replace = FALSE

/datum/mood_event/ling
	description = "У нас есть цель, и мы достигнем её, чего бы это ни стоило!"
	mood_change = 12
	hidden = TRUE

/datum/mood_event/creeping
	description = "Голоса отпустили свои крючки с моего разума! Я снова свободен!" //creeps get it when they are around their obsession
	mood_change = 18
	timeout = 3 SECONDS
	hidden = TRUE

/datum/mood_event/revolution
	description = "ДА ЗДРАВСТВУЕТ РЕВОЛЮЦИЯ!"
	mood_change = 3
	hidden = TRUE

/datum/mood_event/cult
	description = "Я узрел правду, восславим же всемогущего!"
	mood_change = 12 //maybe being a cultist isn't that bad after all
	hidden = TRUE

/datum/mood_event/heretics
	description = "ЧЕМ ВЫШЕ Я ПОДНИМАЮСЬ, ТЕМ БОЛЬШЕ Я ВИЖУ."
	mood_change = 12 //maybe being a heretic isnt that bad after all
	hidden = TRUE

/datum/mood_event/rift_fishing
	description = "ЧЕМ БОЛЬШЕ Я РЫБАЧУ, ТЕМ ВЫШЕ Я ПОДНИМАЮСЬ."
	mood_change = 6
	timeout = 5 MINUTES

/datum/mood_event/family_heirloom
	description = "Моя семейная реликвия в безопасности со мной."
	mood_change = 1

/datum/mood_event/clown_enjoyer_pin
	description = "Мне нравится показывать свою клоунскую булавку!"
	mood_change = 1

/datum/mood_event/mime_fan_pin
	description = "Мне нравится показывать свою мимскую булавку!"
	mood_change = 1

/datum/mood_event/goodmusic
	description = "В этой музыке есть что-то успокаивающее."
	mood_change = 3
	timeout = 60 SECONDS
	event_flags = MOOD_EVENT_ART

/datum/mood_event/chemical_euphoria
	description = "Хех... Хехехе... Хехе..."
	mood_change = 4

/datum/mood_event/chemical_laughter
	description = "Смех и правда продлевает жизнь, не так ли?"
	mood_change = 4
	timeout = 3 MINUTES

/datum/mood_event/chemical_superlaughter
	description = "*ЗАДЫХАЮСЬ ОТ СМЕХА*"
	mood_change = 12
	timeout = 3 MINUTES

/datum/mood_event/religiously_comforted
	description = "Меня утешает присутствие святого человека."
	mood_change = 3
	timeout = 5 MINUTES
	event_flags = MOOD_EVENT_SPIRITUAL

/datum/mood_event/clownshoes
	description = "Эти ботинки наследие клоунов, и я никогда их не сниму!"
	mood_change = 3

/datum/mood_event/sacrifice_good
	description = "Боги довольны этим подношением!"
	mood_change = 5
	timeout = 3 MINUTES
	event_flags = MOOD_EVENT_SPIRITUAL

/datum/mood_event/artok
	description = "Приятно видеть, что люди занимаются здесь искусством."
	mood_change = 2
	timeout = 5 MINUTES
	event_flags = MOOD_EVENT_ART

/datum/mood_event/artgood
	description = "Это произведение искусства заставляет задуматься. Я надолго запомню его."
	mood_change = 4
	timeout = 5 MINUTES
	event_flags = MOOD_EVENT_ART

/datum/mood_event/artgreat
	description = "Это произведение искусства было настолько великолепным, что я вновь поверил в доброту человечества. Это многое говорит об этом месте."
	mood_change = 6
	timeout = 5 MINUTES
	event_flags = MOOD_EVENT_ART

/datum/mood_event/bottle_flip
	description = "То, как приземлилась эта бутылка, было приятным."
	mood_change = 2
	timeout = 3 MINUTES

/datum/mood_event/hope_lavaland
	description = "Какая необычная эмблема. Она вселяет надежду в моё будущее."
	mood_change = 6

/datum/mood_event/hope_lavaland/add_effects(...)
	if(HAS_PERSONALITY(owner, /datum/personality/pessimistic))
		mood_change = 0
		description = "Эта эмблема - ложь. Для меня нет надежды."
		return

/datum/mood_event/confident_mane
	description = "Я более уверен с полной волос головой."
	mood_change = 2

/datum/mood_event/holy_consumption
	description = "Воистину, эта еда была Божественна!"
	mood_change = 1 // 1 + 5 from it being liked food makes it as good as jolly
	timeout = 3 MINUTES

/datum/mood_event/high_five
	description = "Я люблю получать пятюни!"
	mood_change = 2
	timeout = 45 SECONDS

/datum/mood_event/helped_up
	description = "Мне понравилось помогать им!"
	timeout = 45 SECONDS

/datum/mood_event/helped_up/can_effect_mob(datum/mood/home, mob/living/who, ...)
	if(!HAS_PERSONALITY(owner, /datum/personality/compassionate) \
		&& !HAS_PERSONALITY(owner, /datum/personality/callous) \
		&& !HAS_PERSONALITY(owner, /datum/personality/misanthropic))
		return FALSE

	return ..()

/datum/mood_event/helped_up/add_effects(mob/other_person, helper)
	if(!other_person)
		return

	if(HAS_PERSONALITY(owner, /datum/personality/callous) || HAS_PERSONALITY(owner, /datum/personality/misanthropic))
		mood_change = -2
		if(helper)
			description = "Им следовало помочь себе самим."
		else
			description = "Я мог бы подняться сам."

	else if(HAS_PERSONALITY(owner, /datum/personality/compassionate))
		mood_change = 2
		if(helper)
			description = "Мне понравилось помогать [other_person]!"
		else
			description = "[other_person.declent_ru(NOMINATIVE)] помог мне подняться, как мило с [other_person.ru_p_them()] стороны!"

/datum/mood_event/high_ten
	description = "ВЕЛИКОЛЕПНО! ДВОЙНАЯ ПЯТЮНЯ!"
	mood_change = 3
	timeout = 45 SECONDS
	event_flags = MOOD_EVENT_WHIMSY

/datum/mood_event/down_low
	description = "ХА! Вот глупыш, у них не было и шанса..."
	mood_change = 4
	timeout = 90 SECONDS
	event_flags = MOOD_EVENT_WHIMSY

/datum/mood_event/aquarium_positive
	description = "Наблюдение за рыбками в аквариуме успокаивает."
	mood_change = 3
	timeout = 90 SECONDS

/datum/mood_event/gondola
	description = "Я чувствую умиротворенность и не испытываю потребности совершать какие-либо резкие или необдуманные поступки."
	mood_change = 6

/datum/mood_event/kiss
	description = "Воздушный поцелуй от кого-то, я настоящая находка!"
	mood_change = 1.5
	timeout = 2 MINUTES

/datum/mood_event/kiss/add_effects(mob/beau, direct)
	if(HAS_PERSONALITY(owner, /datum/personality/aromantic))
		mood_change = -2
		description = "Поцелуй? Я звоню в отдел кадров!"
		return
	if(!beau)
		return
	if(direct)
		description = "Поцелуй от [beau.declent_ru(GENITIVE)], ахх!!"
	else
		description = "Воздушный поцелуй от [beau.declent_ru(GENITIVE)], я настоящая находка!"

/datum/mood_event/honorbound
	description = "Следование кодесу чести приносит удовлетворение!"
	mood_change = 4

/datum/mood_event/et_pieces
	description = "Ммм... Я люблю арахисовое масло..."
	mood_change = 50
	timeout = 10 MINUTES

/datum/mood_event/memories_of_home
	description = "Этот вкус приятно напоминает о прошлом..."
	mood_change = 3
	timeout = 5 MINUTES

/datum/mood_event/observed_soda_spill
	description = "Ахаха! Всегда забавно видеть то, как кто-то проливает на себя газировку."
	mood_change = 2
	timeout = 30 SECONDS
	event_flags = MOOD_EVENT_WHIMSY

/datum/mood_event/observed_soda_spill/add_effects(mob/spilled_mob, atom/soda_can)
	if(!spilled_mob)
		return

	description = "Ахаха! [spilled_mob] пролил свою же газировку на себя! Классика."

/datum/mood_event/gaming
	description = "Я наслаждаюсь хорошей игровой сессией!"
	mood_change = 2
	timeout = 30 SECONDS
	event_flags = MOOD_EVENT_GAMING

/datum/mood_event/gaming/add_effects()
	if(HAS_PERSONALITY(owner, /datum/personality/industrious) || HAS_PERSONALITY(owner, /datum/personality/slacking/diligent))
		mood_change = -1
		description = "Разве сейчас время для игр? Мне следует работать."

/datum/mood_event/gamer_won
	description = "Я люблю выигрывать в видеоигры!"
	mood_change = 6
	timeout = 5 MINUTES
	event_flags = MOOD_EVENT_GAMING

/datum/mood_event/love_reagent
	description = "Эта еда напоминает мне о старых добрых временах."
	mood_change = 5

/datum/mood_event/love_reagent/add_effects(duration)
	if(HAS_PERSONALITY(owner, /datum/personality/pessimistic))
		mood_change = 0
		description = "Эта еда нормальная, наверное."
		return

	if(isnum(duration))
		timeout = duration

/datum/mood_event/won_52_card_pickup
	description = "ХА! Этот неудачник будет долго подбирать все эти карты с пола!"
	mood_change = 3
	timeout = 3 MINUTES
	event_flags = MOOD_EVENT_WHIMSY | MOOD_EVENT_GAMING

/datum/mood_event/playing_cards
	description = "Мне нравится играть в карты с другими людьми!"
	mood_change = 2
	timeout = 3 MINUTES
	event_flags = MOOD_EVENT_GAMING

/datum/mood_event/playing_cards/add_effects(param)
	var/card_players = 1
	for(var/mob/living/carbon/player in viewers(COMBAT_MESSAGE_RANGE, owner))
		var/player_has_cards = player.is_holding(/obj/item/toy/singlecard) || player.is_holding_item_of_type(/obj/item/toy/cards)
		if(player_has_cards)
			card_players++
			if(card_players > 5)
				break

	mood_change *= card_players
	return ..()

/datum/mood_event/garland
	description = "Эти цветы довольно успокаивающие."
	mood_change = 1

/datum/mood_event/russian_roulette_win
	description = "Я поставил на кон свою жизнь и выиграл! Живу благодаря удаче..."
	mood_change = 2
	timeout = 5 MINUTES

/datum/mood_event/russian_roulette_win/add_effects(loaded_rounds)
	var/base = HAS_PERSONALITY(owner, /datum/personality/gambler) ? 2 : 1.8
	mood_change = round(base ** loaded_rounds, 1)

/datum/mood_event/fishing
	description = "Рыбалка расслабляет."
	mood_change = 4
	timeout = 3 MINUTES

/datum/mood_event/fish_released
	description = "Плыви, рыбка, плыви и будь свободна!"
	mood_change = 1
	timeout = 2 MINUTES

/datum/mood_event/fish_released/add_effects(morbid, obj/item/fish/fish)
	if(!morbid)
		description = "Плыви, [fish.declent_ru(NOMINATIVE)], плыви и будь свободна!"
		return
	if(fish.status == FISH_DEAD)
		description = "Какой-нибудь падальщик наверняка найдет применение останкам [fish.declent_ru(INSTRUMENTAL)]. Как практично."
	else
		description = "Вернулся к бремени глубин. Но разве это милосердие, [fish.declent_ru(NOMINATIVE)]? Всегда найдется рыбка покрупнее..."

/datum/mood_event/fish_petting
	description = "Было приятно погладить рыбку."
	mood_change = 2
	timeout = 2 MINUTES
	event_flags = MOOD_EVENT_WHIMSY

/datum/mood_event/fish_petting/add_effects(obj/item/fish/fish, morbid)
	if(!morbid)
		description = "Было приятно погладить [fish.declent_ru(INSTRUMENTAL)]."
	else
		description = "Я ласкаю [fish.declent_ru(INSTRUMENTAL)], пока [fish.ru_p_they()] извивается под моим прикосновением, блаженно не осознавая, насколько жесток этот мир."

/datum/mood_event/kobun
	description = "Вы все любимы Вселенной. Я не одинок, как и вы."
	mood_change = 14
	timeout = 10 SECONDS

/datum/mood_event/sabrage_success
	description = "Я проделал этот трюк с саблей! Приятно похвастаться этим."
	mood_change = 2
	timeout = 4 MINUTES

/datum/mood_event/sabrage_witness
	description = "Я видел, как кто-то выбил пробку из шампанского весьма радикальным способом."
	mood_change = 1
	timeout = 2 MINUTES

/datum/mood_event/birthday
	description = "Сегодня мой день рождения!"
	mood_change = 2
	special_screen_obj = "birthday"
	special_screen_replace = FALSE

/datum/mood_event/basketball_score
	description = "Свищ! Только сетка."
	mood_change = 2
	timeout = 5 MINUTES
	event_flags = MOOD_EVENT_WHIMSY | MOOD_EVENT_GAMING

/datum/mood_event/basketball_dunk
	description = "Слэм-данк! Бум, шакалака!"
	mood_change = 2
	timeout = 5 MINUTES
	event_flags = MOOD_EVENT_WHIMSY | MOOD_EVENT_GAMING

/datum/mood_event/moon_smile
	description = "ЛУНА ПОКАЗЫВАЕТ МНЕ ПРАВДУ, И ЕЁ УЛЫБКА ОБРАЩЕНА КО МНЕ!!!"
	mood_change = 10
	timeout = 2 MINUTES

///Wizard cheesy grand finale - what the wizard gets
/datum/mood_event/madness_elation
	description = "Безумие - величайшее из благославлений..."
	mood_change = 200

/datum/mood_event/prophat
	description = "Эта шляпа наполняет меня причудливой радостью!"
	mood_change = 2
	event_flags = MOOD_EVENT_WHIMSY

/datum/mood_event/slots
	description = "Давайте играть в азартные игры!"
	mood_change = 1
	timeout = 1 MINUTES
	event_flags = MOOD_EVENT_GAMING

/datum/mood_event/slots/add_effects()
	if(HAS_PERSONALITY(owner, /datum/personality/gambler))
		mood_change *= 2
	else if(HAS_PERSONALITY(owner, /datum/personality/industrious) || HAS_PERSONALITY(owner, /datum/personality/slacking/diligent))
		mood_change *= -1
		description = "Зачем я трачу время и деньги на азартные игры?"


/datum/mood_event/slots/win
	description = "О да, я выиграл!"
	mood_change = 2
	timeout = 5 MINUTES
	event_flags = MOOD_EVENT_GAMING

/datum/mood_event/slots/win/be_replaced(datum/mood/home, datum/mood_event/new_event, ...)
	if(new_event.mood_change < mood_change)
		return BLOCK_NEW_MOOD
	return ..()

/datum/mood_event/slots/win/big
	mood_change = 3
	timeout = 10 MINUTES

/datum/mood_event/slots/win/jackpot
	description = "ДЖЕКПОТ! О ДА!"
	mood_change = 6
	timeout = 30 MINUTES

/datum/mood_event/empathetic_happy
	description = "Видеть счастливых людей приятно."
	mood_change = 2
	timeout = 2 MINUTES

/datum/mood_event/misanthropic_happy
	description = "Видеть грустных людей радует."
	mood_change = 2
	timeout = 2 MINUTES

/datum/mood_event/paranoid/alone
	description = "Мир и тишина, никого рядом, чтобы угрожать мне."
	mood_change = 1

/datum/mood_event/paranoid/small_group
	description = "Я чувствую себя в безопасности в этой небольшой группе. Мы прикрываем друг друга."
	mood_change = 2

/datum/mood_event/nt_loyalist
	description = "Я горжусь тем, что являюсь частью семьи NT™!"
	mood_change = 2

/datum/mood_event/loyalist_revs_lost
	description = "Революция разгромлена! Да здравствует NanoTrasen!"
	mood_change = 4
	timeout = 10 MINUTES

/datum/mood_event/disillusioned_revs_win
	description = "Революция победила! Да здравствует революция!"
	mood_change = 4
	timeout = 10 MINUTES

/datum/mood_event/enjoying_department_area
	description = "Я обожаю свою работу."
	mood_change = 1

/datum/mood_event/slacking_off_lazy
	description = "Босс получает доллар, я получаю десять центов. Поэтому я бездельничаю на работе."
	mood_change = 1

/datum/mood_event/working_diligent
	description = "Усердная работа сама по себе награда."
	mood_change = 1

/datum/mood_event/creative_patronage
	description = "Поддерживаю художников!"
	mood_change = 2
	timeout = 5 MINUTES

/datum/mood_event/creative_framing
	description = "Развешивание картин действительно связывает комнату воедино."
	mood_change = 2
	timeout = 5 MINUTES

/datum/mood_event/creative_sculpting
	description = "Скульптура - отличный творческий выход."
	mood_change = 2
	timeout = 5 MINUTES

/datum/mood_event/whimsical_slip
	description = "Хаха! Этот парень упал!"
	mood_change = 3
	timeout = 2 MINUTES
	event_flags = MOOD_EVENT_WHIMSY
