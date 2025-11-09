/datum/personality/ascetic
	savefile_key = "ascetic"
	name = "Аскетичный"
	desc = "Мне не нужна роскошная еда - это всего лишь топливо для тела."
	pos_gameplay_desc = "Снижена грусть от употребления нелюбимой еды"
	neg_gameplay_desc = "Ограничено удовольствие от употребления любимой еды"
	groups = list(PERSONALITY_GROUP_FOOD)

/datum/personality/gourmand
	savefile_key = "gourmand"
	name = "Гурман"
	desc = "Еда для меня значит всё!"
	pos_gameplay_desc = "Усилено удовольствие от употребления любимой еды"
	neg_gameplay_desc = "Усилена грусть от употребления нелюбимой еды, а посредственная еда менее приятна"
	groups = list(PERSONALITY_GROUP_FOOD)

/datum/personality/teetotal
	savefile_key = "teetotal"
	name = "Трезвенник"
	desc = "Алкоголь не для меня."
	neg_gameplay_desc = "Не любит употреблять алкоголь"
	groups = list(PERSONALITY_GROUP_ALCOHOL)

/datum/personality/bibulous
	savefile_key = "bibulous"
	name = "Любитель выпить"
	desc = "Я всегда готов выпить ещё!"
	pos_gameplay_desc = "Удовлетворение от выпивки длится дольше, даже после того, как вы протрезвеете"
	groups = list(PERSONALITY_GROUP_ALCOHOL)
