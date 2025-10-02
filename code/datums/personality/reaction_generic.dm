/datum/personality/apathetic
	savefile_key = "apathetic"
	name = "Безразличный"
	desc = "Мне почти ни до чего нет дела. Ни до хорошего, ни до плохого, и уж точно ни до отвратительного."
	neut_gameplay_desc = "Настроение влияет на вас слабее"
	groups = list(PERSONALITY_GROUP_MOOD_POWER)

/datum/personality/apathetic/apply_to_mob(mob/living/who)
	. = ..()
	who.mob_mood?.mood_modifier -= 0.2

/datum/personality/apathetic/remove_from_mob(mob/living/who)
	. = ..()
	who.mob_mood?.mood_modifier += 0.2

/datum/personality/sensitive
	savefile_key = "sensitive"
	name = "Чувствительный"
	desc = "На меня легко влияет всё, что происходит вокруг."
	neut_gameplay_desc = "Настроение влияет на вас сильнее"
	groups = list(PERSONALITY_GROUP_MOOD_POWER)

/datum/personality/sensitive/apply_to_mob(mob/living/who)
	. = ..()
	who.mob_mood?.mood_modifier += 0.2

/datum/personality/sensitive/remove_from_mob(mob/living/who)
	. = ..()
	who.mob_mood?.mood_modifier -= 0.2

/datum/personality/resilient
	savefile_key = "resilient"
	name = "Стойкий"
	desc = "Всё равно. Я всё смогу!"
	pos_gameplay_desc = "Негативное настроение проходит быстрее"
	groups = list(PERSONALITY_GROUP_MOOD_LENGTH)

/datum/personality/resilient/apply_to_mob(mob/living/who)
	. = ..()
	who.mob_mood?.negative_moodlet_length_modifier -= 0.2

/datum/personality/resilient/remove_from_mob(mob/living/who)
	. = ..()
	who.mob_mood?.negative_moodlet_length_modifier += 0.2

/datum/personality/brooding
	savefile_key = "brooding"
	name = "Унылый"
	desc = "Всё меня задевает, и я не могу перестать об этом думать."
	neg_gameplay_desc = "Негативное настроение длится дольше"
	groups = list(PERSONALITY_GROUP_MOOD_LENGTH)

/datum/personality/brooding/apply_to_mob(mob/living/who)
	. = ..()
	who.mob_mood?.negative_moodlet_length_modifier += 0.2

/datum/personality/brooding/remove_from_mob(mob/living/who)
	. = ..()
	who.mob_mood?.negative_moodlet_length_modifier -= 0.2

/datum/personality/hopeful
	savefile_key = "hopeful"
	name = "Надеющийся"
	desc = "Я верю, что всё всегда наладится."
	pos_gameplay_desc = "Позитивное настроение длится дольше"
	groups = list(PERSONALITY_GROUP_HOPE)

/datum/personality/hopeful/apply_to_mob(mob/living/who)
	. = ..()
	who.mob_mood?.positive_moodlet_length_modifier += 0.2

/datum/personality/hopeful/remove_from_mob(mob/living/who)
	. = ..()
	who.mob_mood?.positive_moodlet_length_modifier -= 0.2

/datum/personality/pessimistic
	savefile_key = "pessimistic"
	name = "Пессимистичный"
	desc = "Я считаю, что наши лучшие дни остались позади."
	neg_gameplay_desc = "Позитивное настроение длится меньше"
	groups = list(PERSONALITY_GROUP_HOPE)

/datum/personality/pessimistic/apply_to_mob(mob/living/who)
	. = ..()
	who.mob_mood?.positive_moodlet_length_modifier -= 0.2

/datum/personality/pessimistic/remove_from_mob(mob/living/who)
	. = ..()
	who.mob_mood?.positive_moodlet_length_modifier += 0.2

/datum/personality/whimsical
	savefile_key = "whimsical"
	name = "Причудливый"
	desc = "На этой станции иногда слишком серьёзно относятся ко всему, расслабьтесь!"
	pos_gameplay_desc = "Любит бессмысленные, но забавные вещи и не против клоунских проделок"

/datum/personality/snob
	savefile_key = "snob"
	name = "Снобистский"
	desc = "Я ожидаю от этой станции только самого лучшего — всё остальное неприемлемо!"
	neut_gameplay_desc = "Качество помещения влияет на ваше настроение"
	personality_trait = TRAIT_SNOB
