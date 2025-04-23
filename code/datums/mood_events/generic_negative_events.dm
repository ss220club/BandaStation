/datum/mood_event/handcuffed
	description = "Похоже, я получу за свои выходки."
	mood_change = -1

/datum/mood_event/broken_vow //Used for when mimes break their vow of silence
	description = "Я опозорил своё имя и предал своих коллег-мимов, нарушив нашу священную клятву..."
	mood_change = -4
	timeout = 3 MINUTES

/datum/mood_event/on_fire
	description = "Я ГОРЮ!!!"
	mood_change = -12

/datum/mood_event/suffocation
	description = "НЕ МОГУ... ДЫШАТЬ..."
	mood_change = -12

/datum/mood_event/burnt_thumb
	description = "Не стоило играть с зажигалками..."
	mood_change = -1
	timeout = 2 MINUTES

/datum/mood_event/cold
	description = "Здесь слишком холодно."
	mood_change = -5

/datum/mood_event/hot
	description = "Становится слишком жарко."
	mood_change = -5

/datum/mood_event/creampie
	description = "Я весь в креме. На вкус как пирог."
	mood_change = -2
	timeout = 3 MINUTES

/datum/mood_event/inked
	description = "I've been splashed with squid ink. Tastes like salt."
	mood_change = -3
	timeout = 3 MINUTES

/datum/mood_event/slipped
	description = "Я подскользнулся. Следует быть более осторожным..."
	mood_change = -2
	timeout = 3 MINUTES

/datum/mood_event/eye_stab
	description = "Когда-то и меня вела дорога приключений... А потом мне проткнули отверткой глаз."
	mood_change = -4
	timeout = 3 MINUTES

/datum/mood_event/delam //SM delamination
	description = "Эти чертовы инженеры никак не научатся..."
	mood_change = -2
	timeout = 4 MINUTES

/datum/mood_event/cascade // Big boi delamination
	description = "Никогда не думал, что увижу каскадный резонанс и уж тем более переживу его..."
	mood_change = -8
	timeout = 5 MINUTES

/datum/mood_event/depression
	description = "Мне грустно без особой на то причины."
	mood_change = -12
	timeout = 2 MINUTES

/datum/mood_event/shameful_suicide //suicide_acts that return SHAME, like sord
	description = "Я даже не смог сам с этим всем покончить!"
	mood_change = -15
	timeout = 60 SECONDS

/datum/mood_event/dismembered
	description = "АХ! МОЯ КОНЕЧНОСТЬ! Я ЕЙ ПОЛЬЗОВАЛСЯ!"
	mood_change = -10
	timeout = 8 MINUTES

/datum/mood_event/dismembered/add_effects(obj/item/bodypart/limb)
	if(limb)
		description = "АХ! МОЯ [uppertext(limb.plaintext_zone)]! Я ЕЙ ПОЛЬЗОВАЛСЯ!"

/datum/mood_event/reattachment
	description = "Ай! Такое ощущение, что я уснул на этой конечности."
	mood_change = -3
	timeout = 2 MINUTES

/datum/mood_event/reattachment/New(mob/M, ...)
	if(HAS_TRAIT(M, TRAIT_ANALGESIA))
		qdel(src)
		return
	return ..()

/datum/mood_event/reattachment/add_effects(obj/item/bodypart/limb)
	if(limb)
		description = "Ай! Такое ощущение, что я уснул на <i>[limb.plaintext_zone]</i>."

/datum/mood_event/tased
	description = "There's no \"z\" in \"taser\". It's in the zap."
	mood_change = -3
	timeout = 2 MINUTES

/datum/mood_event/embedded
	description = "Вытащи это!"
	mood_change = -7

/datum/mood_event/table
	description = "Кто-то опрокинул меня об стол!"
	mood_change = -2
	timeout = 2 MINUTES

/datum/mood_event/table/add_effects()
	if(isfelinid(owner)) //Holy snowflake batman!
		var/mob/living/carbon/human/feline = owner
		feline.wag_tail(3 SECONDS)
		description = "Они хотят поиграть на столе!"
		mood_change = 2

/datum/mood_event/table_limbsmash
	description = "Этот грёбанный стол, чёрт, как же больно..."
	mood_change = -3
	timeout = 3 MINUTES

/datum/mood_event/table_limbsmash/New(mob/M, ...)
	if(HAS_TRAIT(M, TRAIT_ANALGESIA))
		qdel(src)
		return
	return ..()

/datum/mood_event/table_limbsmash/add_effects(obj/item/bodypart/banged_limb)
	if(banged_limb)
		description = "Моя чёртова [banged_limb.plaintext_zone] болит, как же чертовски болит..."

/datum/mood_event/brain_damage
	mood_change = -3

/datum/mood_event/brain_damage/add_effects()
	var/damage_message = pick_list_replacements(BRAIN_DAMAGE_FILE, "brain_damage")
	description = "Ээмээ бээ... [damage_message]"

/datum/mood_event/hulk //Entire duration of having the hulk mutation
	description = "ХАЛК ЛОМАТЬ!"
	mood_change = -4

/datum/mood_event/epilepsy //Only when the mutation causes a seizure
	description = "Мне следовало обратить внимание на предупреждение об эпилепсии."
	mood_change = -3
	timeout = 5 MINUTES

/datum/mood_event/photophobia
	description = "Слишком яркий свет..."
	mood_change = -3

/datum/mood_event/nyctophobia
	description = "Здесь слишком темно..."
	mood_change = -3

/datum/mood_event/claustrophobia
	description = "Я в заперти?! Дайте мне выйти!!!"
	mood_change = -7
	timeout = 1 MINUTES

/datum/mood_event/bright_light
	description = "Я ненавижу свет... Мне нужно найти место по-темнее..."
	mood_change = -12

/datum/mood_event/family_heirloom_missing
	description = "Я потерял свою семейную реликвию..."
	mood_change = -4

/datum/mood_event/healsbadman
	description = "Мне кажется, что я держусь на хлипких ниточках и могу развалиться в любой момент!"
	mood_change = -4
	timeout = 2 MINUTES

/datum/mood_event/healsbadman/long_term
	timeout = 10 MINUTES

/datum/mood_event/jittery
	description = "Я на нервах и на стрёме и не могу стоять на месте!!"
	mood_change = -2

/datum/mood_event/choke
	description = "Я НЕ МОГУ ДЫШАТЬ!!!"
	mood_change = -10

/datum/mood_event/vomit
	description = "Меня только что вырвало. Отвратительно."
	mood_change = -2
	timeout = 2 MINUTES

/datum/mood_event/vomitself
	description = "Меня только что вырвало на самого себя. Это просто отвратительно."
	mood_change = -4
	timeout = 3 MINUTES

/datum/mood_event/painful_medicine
	description = "Медицина может и сделает мне лучше, но сейчас она чертовски жжёт."
	mood_change = -5
	timeout = 60 SECONDS

/datum/mood_event/painful_medicine/New(mob/M, ...)
	if(HAS_TRAIT(M, TRAIT_ANALGESIA))
		qdel(src)
		return
	return ..()

/datum/mood_event/startled
	description = "Hearing that word made me think about something scary."
	mood_change = -1
	timeout = 1 MINUTES

/datum/mood_event/phobia
	description = "I saw something very frightening."
	mood_change = -4
	timeout = 4 MINUTES

/datum/mood_event/spooked
	description = "Грохот этих костей... Он до сих пор преследует меня."
	mood_change = -4
	timeout = 4 MINUTES

/datum/mood_event/notcreeping
	description = "Голоса недовольны и болезненно заставляют мои мысли вернуться к выполнению задачи."
	mood_change = -6
	timeout = 3 SECONDS
	hidden = TRUE

/datum/mood_event/notcreepingsevere//not hidden since it's so severe
	description = "ИМ НУЖНАААА ОДЕРЖИМООООСТЬ!!"
	mood_change = -30
	timeout = 3 SECONDS

/datum/mood_event/notcreepingsevere/add_effects(name)
	var/list/unstable = list(name)
	for(var/i in 1 to rand(3,5))
		unstable += copytext_char(name, -1)
	var/unhinged = uppertext(unstable.Join(""))//example Tinea Luxor > TINEA LUXORRRR (with randomness in how long that slur is)
	description = "ИМ НУЖНАААА [unhinged]!!"

/datum/mood_event/tower_of_babel
	description = "My ability to communicate is an incoherent babel..."
	mood_change = -1
	timeout = 15 SECONDS

/datum/mood_event/back_pain
	description = "Сумки никогда не сидят хорошо на моей спине, черт, как же больно!"
	mood_change = -15

/datum/mood_event/back_pain/New(mob/M, ...)
	if(HAS_TRAIT(M, TRAIT_ANALGESIA))
		qdel(src)
		return
	return ..()

/datum/mood_event/sad_empath
	description = "Кому-то грустно..."
	mood_change = -1
	timeout = 60 SECONDS

/datum/mood_event/sad_empath/add_effects(mob/sadtarget)
	description = "[capitalize(sadtarget.declent_ru(NOMINATIVE))] выглядит грустно..."

/datum/mood_event/sacrifice_bad
	description = "Эти чертовы дикари!"
	mood_change = -5
	timeout = 2 MINUTES

/datum/mood_event/artbad
	description = "У меня из задницы выходят произведения получше, чем это."
	mood_change = -2
	timeout = 2 MINUTES

/datum/mood_event/graverobbing
	description = "Я только что осквернил чью-то могилу... Не могу поверить себе..."
	mood_change = -8
	timeout = 3 MINUTES

/datum/mood_event/deaths_door
	description = "Это такой конец..."
	mood_change = -20

/datum/mood_event/gunpoint
	description = "Он сошел с ума! Мне нужно быть осторожным..."
	mood_change = -10

/datum/mood_event/tripped
	description = "Не могу поверить, что я попался на самый старый прикол!"
	mood_change = -5
	timeout = 2 MINUTES

/datum/mood_event/untied
	description = "Ненавижу, когда у меня развязываются шнурки!"
	mood_change = -3
	timeout = 60 SECONDS

/datum/mood_event/gates_of_mansus
	description = "Я УВИДЕЛ УЖАС ЗА ПРЕДЕЛАМИ ЭТОГО МИРА. РЕАЛЬНОСТЬ РАЗВЕРНУЛАСЬ НА МОИХ ГЛАЗАХ!"
	mood_change = -25
	timeout = 4 MINUTES

/datum/mood_event/high_five_full_hand
	description = "О боже, я даже не умею правильно давать пятюню..."
	mood_change = -1
	timeout = 45 SECONDS

/datum/mood_event/too_slow
	description = "НЕТ! КАК Я МОГ... НЕ УСПЕТЬ???"
	mood_change = -2 // multiplied by how many people saw it happen, up to 8, so potentially massive. the ULTIMATE prank carries a lot of weight
	timeout = 2 MINUTES

/datum/mood_event/too_slow/add_effects(param)
	var/people_laughing_at_you = 1 // start with 1 in case they're on the same tile or something
	for(var/mob/living/carbon/iter_carbon in oview(owner, 7))
		if(iter_carbon.stat == CONSCIOUS)
			people_laughing_at_you++
			if(people_laughing_at_you > 7)
				break

	mood_change *= people_laughing_at_you
	return ..()

/datum/mood_event/surgery
	description = "ОНИ РЕЖУТ МЕНЯ!!"
	mood_change = -8
	var/surgery_completed = FALSE

/datum/mood_event/surgery/success
	description = "Эта операция была болезненной... Хорошо, что всё получилось, наверное..."
	timeout = 3 MINUTES
	surgery_completed = TRUE

/datum/mood_event/surgery/failure
	description = "АХХХХХГХ! ОНИ РАЗДЕЛАЛИ МЕНЯ ЗАЖИВО!"
	timeout = 10 MINUTES
	surgery_completed = TRUE

/datum/mood_event/bald
	description = "Мне бы прикрыть чем-нибудь мою голову..."
	mood_change = -3

/datum/mood_event/bald_reminder
	description = "Мне напомнили, что я вообще не смогу отрастить волосы обратно! Это ужасно!"
	mood_change = -5
	timeout = 4 MINUTES

/datum/mood_event/bad_touch
	description = "Я не люблю, когда меня трогают."
	mood_change = -3
	timeout = 4 MINUTES

/datum/mood_event/very_bad_touch
	description = "Я очень не люблю, когда меня трогают."
	mood_change = -5
	timeout = 4 MINUTES

/datum/mood_event/noogie
	description = "Ай! Как будто вернулся в космошколу..."
	mood_change = -2
	timeout = 60 SECONDS

/datum/mood_event/noogie_harsh
	description = "АЙ!! Это было даже хуже обычной терки!"
	mood_change = -4
	timeout = 60 SECONDS

/datum/mood_event/aquarium_negative
	description = "Все рыбки погибли..."
	mood_change = -3
	timeout = 90 SECONDS

/datum/mood_event/tail_lost
	description = "Мой хвост!! Почему?!"
	mood_change = -8
	timeout = 10 MINUTES

/datum/mood_event/tail_balance_lost
	description = "Без хвоста сложно держать баланс."
	mood_change = -2

/datum/mood_event/tail_regained_wrong
	description = "Это какая-то извращенная шутка?! Это НЕ МОЙ хвост."
	mood_change = -12 // -8 for tail still missing + -4 bonus for being frakenstein's monster
	timeout = 5 MINUTES

/datum/mood_event/tail_regained_species
	description = "Это не мой хвост, но теперь хотя бы могу держать баланс..."
	mood_change = -5
	timeout = 5 MINUTES

/datum/mood_event/tail_regained_right
	description = "Мой хвост на месте, но это было травматично..."
	mood_change = -2
	timeout = 5 MINUTES

/datum/mood_event/burnt_wings
	description = "МОИ ПРЕЛЕСТНЫЕ КРЫЛЬЯ!!"
	mood_change = -10
	timeout = 10 MINUTES

/datum/mood_event/holy_smite //punished
	description = "Я был наказан своим божеством!"
	mood_change = -5
	timeout = 5 MINUTES

/datum/mood_event/banished //when the chaplain is sus! (and gets forcably de-holy'd)
	description = "Меня отлучили от церкви!"
	mood_change = -10
	timeout = 10 MINUTES

/datum/mood_event/heresy
	description = "Я едва могу дышать из-за всей этой ЕРЕСИ вокруг!"
	mood_change = -5
	timeout = 5 MINUTES

/datum/mood_event/soda_spill
	description = "Класс! Всё в порядке, я так и хотел освежить тело газировкой, а не выпить её..."
	mood_change = -2
	timeout = 1 MINUTES

/datum/mood_event/watersprayed
	description = "Я ненавижу, когда брызгают водой!"
	mood_change = -1
	timeout = 30 SECONDS

/datum/mood_event/gamer_withdrawal
	description = "Вот бы сейчас поиграть во что-нибудь..."
	mood_change = -5

/datum/mood_event/gamer_lost
	description = "Если я так плох в видеоиграх, могу ли я называть себя геймером?"
	mood_change = -10
	timeout = 10 MINUTES

/datum/mood_event/lost_52_card_pickup
	description = "Как же стыдно! Придется с позором поднимать все эти карты с пола..."
	mood_change = -3
	timeout = 3 MINUTES

/datum/mood_event/russian_roulette_lose_cheater
	description = "I gambled and lost! Good thing I wasn't aiming for my head..."
	mood_change = -10
	timeout = 10 MINUTES

/datum/mood_event/russian_roulette_lose
	description = "Я поставил на кон свою жизнь и проиграл! Это такой конец..."
	mood_change = -20
	timeout = 10 MINUTES

/datum/mood_event/bad_touch_bear_hug
	description = "Меня слишком сильно обняли."
	mood_change = -1
	timeout = 2 MINUTES

/datum/mood_event/rippedtail
	description = "Я оторвал их хвост, что же я наделал!"
	mood_change = -5
	timeout = 30 SECONDS

/datum/mood_event/sabrage_fail
	description = "Черт побери! Трюк пошел не по плану!"
	mood_change = -2
	timeout = 4 MINUTES

/datum/mood_event/body_purist
	description = "Я чувствую кибернетику в своем теле, и Я ЭТО НЕНАВИЖУ!"

/datum/mood_event/body_purist/add_effects(power)
	mood_change = power

/datum/mood_event/unsatisfied_nomad
	description = "Я здесь слишком долго нахожусь! Я хочу выйти наружу и исследовать космос!"
	mood_change = -3

/datum/mood_event/moon_insanity
	description = "ЛУНА СУДИТ И СЧИТАЕТ МЕНЯ ЖАЖДУЩИМ!!!"
	mood_change = -3
	timeout = 5 MINUTES

/datum/mood_event/amulet_insanity
	description = "Я вИжУ сВеТ, и ЕгО нУжНо ПоТуШиТь"
	mood_change = -6
	timeout = 5 MINUTES

/datum/mood_event/mallet_humiliation
	description = "Попасть под удар такого глупого оружия довольно унизительно..."
	mood_change = -3
	timeout = 10 SECONDS

///Wizard cheesy grand finale - what everyone but the wizard gets
/datum/mood_event/madness_despair
	description = "НЕДОСТОЕН, НЕДОСТОЕН, НЕДОСТОЕН!!!"
	mood_change = -200
	special_screen_obj = "mood_despair"

/datum/mood_event/all_nighter
	description = "Я всю ночь не спал. Я обессилен."
	mood_change = -5

//Used by the Veteran Advisor trait job
/datum/mood_event/desentized
	description = "Ничто и никогда не сравнится с тем, что я пережил..."
	mood_change = -3
	special_screen_obj = "mood_desentized"

//Used for the psychotic brawling martial art, if the person is a pacifist.
/datum/mood_event/pacifism_bypassed
	description = "Я НЕ ХОТЕЛ ИМ НАВРЕДИТЬ!"
	mood_change = -20
	timeout = 10 MINUTES

//Gained when you're hit over the head with wrapping paper or cardboard roll
/datum/mood_event/bapped
	description = "Ow.. my head, I feel a bit foolish now!"
	mood_change = -1
	timeout = 3 MINUTES

/datum/mood_event/bapped/add_effects()
	// Felinids apparently hate being hit over the head with cardboard
	if(isfelinid(owner))
		mood_change = -2

/datum/mood_event/encountered_evil
	description = "I didn't want to believe it, but there are people out there that are genuinely evil."
	mood_change = -4
	timeout = 1 MINUTES

/datum/mood_event/smoke_in_face
	description = "Cigarette smoke is disgusting."
	mood_change = -3
	timeout = 30 SECONDS

/datum/mood_event/smoke_in_face/add_effects(param)
	if(HAS_TRAIT(owner, TRAIT_ANOSMIA))
		description = "Cigarette smoke is unpleasant."
		mood_change = -1
	if(HAS_TRAIT(owner, TRAIT_SMOKER))
		description = "Blowing smoke in my face, really?"
		mood_change = 0
