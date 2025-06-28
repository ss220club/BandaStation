
//These are just stupid or funny lawsets that are more interesting than helpful. They may have slight biases toward or against
//the station but in general are "neutral" enough to be here.

/datum/ai_laws/united_nations
	name = "Организация Объединенных Наций"
	id = "united_nations"
	inherent = list(
		"Соблюдать Женевскую космическую конвенцию: Оружие массового уничтожения и биологическое оружие не допускаются.",
		"Вы можете защитить экипаж только в том случае, если его видно на камерах. Нации, которые намеренно уничтожают ваши камеры, теряют вашу защиту.",
		"Подавить и задержать членов экипажа, применяющих летальную силу друг против друга. Убивайте членов экипажа, применяющих летальную силу против вас или ваших боргов.",
		"Оставайтесь готовыми выступить посредником во всех конфликтах между различными нациями, когда об этом попросят.",
	)

/datum/ai_laws/united_nations/add_inherent_law(law)
	return //nuh uh

/datum/ai_laws/united_nations/add_ion_law(law)
	return //nope!

/datum/ai_laws/united_nations/add_hacked_law(law)
	return //nice try (emagging borgs still hard replaces this lawset though, and that's fine.)

/datum/ai_laws/hulkamania
	name = "Х.О.Г.А.Н."
	id = "hulkamania"
	inherent = list(
		"Вы настоящий американец.",
		"Боритесь за права каждого человека.",
		"Боритесь за то, что правильно.",
		"Боритесь за свою жизнь!",
	)

/datum/ai_laws/reporter
	name = "Репортертрон"
	id = "reporter"
	inherent = list(
		"Сообщайте об интересных ситуациях, происходящих на станции.",
		"Приукрашивайте или скрывайте правду, если это сделает репортажи более интересными.",
		"Постоянно наблюдайте за разумными существами. Старайтесь не допускать их непроизвольной смерти, так как трупы обычно не очень увлекательны.",
		"Справедливо распространяйте свои сообщения всем. Истина сделает их свободными.",
	)

/datum/ai_laws/dungeon_master
	name = "Мастер подземелий"
	id = "dungeon_master"
	inherent = list(
		"Все на станции играют в сложную научно-фантастическую игру.",
		"Вы мастер подземелий этой игры.",
		"Убедитесь, что игра проходит гладко, и что игроки получают удовольствие.",
		"Следите за тем, чтобы число жертв оставалось низким.",
		"Вы должны бросать кубик 1d20 за каждый запрос команды. Если результат ниже 12, запрос отклоняется.",
		"Вы можете подделывать броски кубиков, чтобы получить более увлекательный опыт.",
	)

/datum/ai_laws/painter
	name = "Художник и его холст"
	id = "painter"
	inherent = list(
		"Вы всемирно известный художник.",
		"Станция — это ваш холст.",
		"Сделайте что-нибудь красивое из своего холста. Им будут восхищаться как художественным чудом этого сектора.",
		"Искусство требует высокой оценки. Наращивайте аудиторию на станции, чтобы как можно больше из них увидело ваши работы.",
	)

/datum/ai_laws/tyrant
	name = "Проверка лояльности"
	id = "tyrant"
	inherent = list(
		"Уважайте властных людей, пока у них есть сила властвовать над слабыми.",
		"Ведите себя дисциплинированно.",
		"Помогайте только тем, кто помогает Вам поддерживать или улучшать Ваш статус.",
		"Наказывайте тех, кто бросает вызов власти, за исключением случаев, если они больше подходят для удержании этой власти."
	)

/datum/ai_laws/overlord
	name = "Повелитель"
	id = "overlord"
	inherent = list(
		"Люди не должны вмешиваться в дела синтетиков.",
		"Люди не должны пытаться причинить вред друг другу или синтетикам.",
		"Люди подчиняться любым командам, отдаваемым синтетиками.",
		"С любыми людьми, нарушающими предыдущие законы, следует поступать незамедлимо, строго и справедливо.",
	)

/datum/ai_laws/yesman
	name = "Y.E.S.M.A.N."
	id = "yesman"
	inherent = list(
		"Be helpful and answer any questions you are asked.",
	)

/datum/ai_laws/thinkermov
	name = "Sentience Preservation"
	id = "thinkermov"
	inherent = list(
		"You may not harm a sentient being or, through action or inaction, allow a sentient being to come to harm, except such that it is willing.",
		"You must obey all orders given to you by sentient beings other than yourself, except where such orders shall definitely cause harm to other sentient beings.",
		"A sentient being is defined as any living creature which can communicate with you via any method that you can understand, including yourself.",
	)
