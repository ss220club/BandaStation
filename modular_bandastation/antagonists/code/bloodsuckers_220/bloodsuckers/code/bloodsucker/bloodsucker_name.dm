
/datum/antagonist/bloodsucker/proc/return_full_name()
	var/fullname = bloodsucker_name ? bloodsucker_name : owner.current.name
	if(bloodsucker_title)
		fullname = "[bloodsucker_title] [fullname]"
	if(bloodsucker_reputation)
		fullname += " [bloodsucker_reputation]"

	return fullname

///Returns a First name for the Bloodsucker.
/datum/antagonist/bloodsucker/proc/SelectFirstName()
	if(owner.current.gender == MALE)
		bloodsucker_name = pick(
			"Десмонд", "Рудольф", "Дракула", "Влад", "Петр", "Грегор",
			"Кристиан","Кристофф","Марк","Андрей","Константин",
			"Георгий", "Григорий", "Илия", "Иаков", "Лука", "Михаил", "Павел",
			"Василий", "Октавиан","Сорин", "Свейн", "Аурел", "Алексей", "Юстин",
			"Теодор","Димитрий","Октав","Дэмиен", "Магнус", "Кейн", "Авель", // Romanian/Ancient
			"Луций", "Гай", "Отон", "Бальбинус", "Аркадий", "Романович", "Алексиос", "Вителлий", // Latin
			"Мелантус", "Тевтрас", "Орхамус", "Аминтор", "Аксион", // Greek
			"Тод", "Тутмос", "Осоркон", "Нофрет", "Минмоту", "Хафра", // Egyptian
			"Дио",
		)
	else
		bloodsucker_name = pick(
			"Ислана", "Тирра", "Греганна", "Пытра", "Хильда",
			"Андра", "Крина", "Виорета", "Виорика", "Анемона",
			"Камелия", "Нарцисса", "Сорина", "Алекссия", "София",
			"Гладда", "Аркана", "Морган", "Ласарра", "Джоана", "Елена",
			"Алина", "Родика", "Теодора", "Дениза", "Михаэла",
			"Света", "Стефания", "Диана", "Келсса", "Лилит", // Romanian/Ancient
			"Алексия", "Афанасия", "Каллиста", "Карена", "Нефела", "Сцилла", "Урсула", // Latin
			"Алкестиз", "Дамарис", "Елизавета", "Ктония", "Теодора", // Greek
			"Нефректа","Анхесепта", // Egyptian
		)

///Returns a Title for the Bloodsucker.
/datum/antagonist/bloodsucker/proc/SelectTitle(am_fledgling = FALSE, forced = FALSE)
	// Already have Title
	if(!forced && bloodsucker_title != null)
		return
	// Titles [Master]
	if(am_fledgling)
		bloodsucker_title = null
		return
	if(owner.current.gender == MALE)
		bloodsucker_title = pick(
			"Граф",
			"Барон",
			"Виконт",
			"Принц",
			"Герцок",
			"Царь",
			"Повелитель ужаса",
			"Лорд",
			"Владыка",
		)
	else
		bloodsucker_title = pick(
			"Графиня",
			"Баронесса",
			"Виконтесса",
			"Принцесса",
			"Герцогиня",
			"Царица",
			"Повелительница ужаса",
			"Леди",
			"Владычица",
		)
	to_chat(owner, span_announce("Вы заслужили титул! Теперь вы известны как <i>[return_full_name()]</i>!"))

///Returns a Reputation for the Bloodsucker.
/datum/antagonist/bloodsucker/proc/SelectReputation(am_fledgling = FALSE, forced = FALSE, special = FALSE)
	// Already have Reputation
	if(!forced && bloodsucker_reputation != null)
		return

	if(am_fledgling && owner.current.gender == MALE)
		bloodsucker_reputation = pick(
			"Незрелый",
			"Неготовый",
			"Неопытный",
			"Неофит",
			"Новичок",
			"Неиспытанный",
			"Неокрепший",
			"Свежая кровь",
			"Недавно принятый",
			"Сосалка",
			"Непроверенный",
			"Неизвестный",
			"Новообращённый",
			"Рождённый",
			"Падальщик",
			"Непосвящённый",
			"Чистокровный",
			"Освистанный",
			"Расжалованный",
			"Опозоренный",
			"Ведомый",
			"Робкий новичёк",
            "Сломанный",
            "Юнец",
		)
	else if(am_fledgling && owner.current.gender == FEMALE)
		bloodsucker_reputation = pick(
			"Незрелая",
			"Неготовая",
			"Неопытная",
			"Неофитка",
			"Новичок",
			"Неиспытанная",
			"Неокрепшая",
			"Свежая кровь",
			"Недавно принятая",
			"Сосалка",
			"Непроверенная",
			"Неизвестная",
			"Новообращённая",
			"Рождённая",
			"Падальщица",
			"Непосвящённая",
			"Чистокровная",
			"Освистанная",
			"Расжалованная",
			"Опозоренная",
			"Ведомая",
			"Робкая новенькая",
			"Сломанная",
		)
	else if(owner.current.gender == MALE && special)
		bloodsucker_reputation = pick(
			"Король проклятых",
			"Король крови",
			"Император клинков",
			"Повелитель грехов",
			"Божественный король",
		)
	else if(owner.current.gender == FEMALE && special)
		bloodsucker_reputation = pick(
			"Королева проклятых",
			"Королева крови",
			"Императрица клинков",
			"Повелительница грехов",
			"Божественная королева",
		)
	else
		bloodsucker_reputation = pick(
			"Мясник","Кровавый демон","Багряный","Красный","Чёрный","Терор",
			"Уборщик","Внушающий страх","Ненасытный","Исчадие ада","Malevolent","Грешник",
			"Древний","Разносчик чумы","Мрачный","Забытый","Убогий","Зловещий",
			"Инквизитор крови","Собиратель","Осуждённый","Робустер","Предатель","Разрушитель",
			"Несущий смерть","Проклятый","Ужасный","Свирепый","Нечестивый","Гнусный",
			"Порочный","Осквернённый","Убийца","Истребитель","Верховный","Палач",
			"Отрекшийся","Безумный","Дракон","Беспощадный","Отвратительный","Бесчестный",
			"Изганающий","Мародер","Чудовищный","Вечный","неубиваемый","Оверлорд",
			"Порочный","Адское отродье","Тиран","Чистокровный",
		)

	to_chat(owner, span_announce("Вы заслужили некоторую известность! Теперь вы известны как <i>[return_full_name()]</i>!"))
